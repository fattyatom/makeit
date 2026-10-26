"""Pack the release pieces onto 255 mm beds and write one 3MF per bed, plus a
Bambu Studio / Orca project 3MF with one plate per bed
(python projects/sink-drain/beds.py [version], after the per-piece builds)."""
import math
import sys
import zipfile
from pathlib import Path

import trimesh

BED, GAP = 255.0, 6.0
# Bambu Studio lays plates out in a grid, ceil(sqrt(n)) columns, each plate
# (bed width x 1.2) from the last; its beds are 256 mm.
PLATE_STRIDE = 256 * 1.2
OUT = Path(__file__).parent / "out"
PRINT = Path(__file__).parent / "print"
VERSION = sys.argv[1] if len(sys.argv) > 1 else "v6"

# Each bed: pieces placed left to right; a [list] is a column stacked front to back.
BEDS = [
    ["plate-0", "left-1"],
    ["plate-1", "left-0"],
    ["plate-2", ["plinth-0", "plinth-1"]],
    ["right--1@36"],   # turned 36° so it fits with its 5 mm brim
]
# PETG process settings, written per object (Bambu Studio / Orca read these
# as object overrides). Every piece: 0.2 mm layers, 3 walls, 15 % gyroid,
# no supports (nothing needs them).
COMMON = {"layer_height": "0.2", "wall_loops": "3", "top_shell_layers": "5", "bottom_shell_layers": "4",
          "sparse_infill_density": "15%", "sparse_infill_pattern": "gyroid", "enable_support": "0",
          "seam_position": "aligned"}
SETTINGS = {
    # Big flat footprint: no brim needed.
    "plate": {"brim_type": "no_brim"},
    # Long solid block: a small brim stops the ends lifting.
    "left": {"brim_type": "outer_only", "brim_width": "3"},
    # Long, flat on the bed; the only bridge is the 10 mm rim notch under the spout.
    "right": {"brim_type": "outer_only", "brim_width": "5", "thick_bridges": "1", "bridge_speed": "25",
              "bridge_flow": "0.95"},
    # Stands on its top plate.
    "plinth": {"brim_type": "outer_only", "brim_width": "3"},
}
# Filament settings live in the filament preset, not per object, so they go
# in the project description.
DESCRIPTION = ("PETG. Nozzle 240 C (245 C first layer), bed 75 C on textured PEI (use glue stick on smooth PEI), "
               "part fan 30-40 %, overhang/bridge fan 90 %, max volumetric speed 12 mm3/s, "
               "dry the filament (65 C, 4-6 h) if it has been open. Per-object process settings are set in this file: "
               "0.2 mm layers, 3 walls, 5 top / 4 bottom layers, 15 % gyroid, no supports; brims on the aprons, "
               "plinth halves and the right piece; thick bridges at 25 mm/s for the right piece's rim notch.")

NAMES = {"plate-0": "plate-1", "plate-1": "plate-2", "plate-2": "plate-3",
         "left-0": "apron-spout-end", "left-1": "apron-wall-end", "right--1": "right-with-spout",
         "plinth-0": "plinth-back", "plinth-1": "plinth-front",
         "ts-left": "test-apron-spout-end", "ts-right": "test-right-spout-end"}


def load(key):
    """key, optionally with @degrees to turn the piece about z."""
    key, _, turn = key.partition("@")
    m = trimesh.load(OUT / f"model-{key}.stl")
    if turn:
        m.apply_transform(trimesh.transformations.rotation_matrix(math.radians(float(turn)), [0, 0, 1]))
    m.apply_translation(-m.bounds[0])
    return m


def layout(bed):
    placed, x = [], 0.0
    for col in bed:
        col = col if isinstance(col, list) else [col]
        meshes = [(k.partition("@")[0], load(k)) for k in col]
        w = max(m.extents[0] for _, m in meshes)
        y = 0.0
        for k, m in meshes:
            m.apply_translation([x, y, 0])
            placed.append((k, m))
            y += m.extents[1] + GAP
        x += w + GAP
    # Centre the group on the bed and check it fits.
    lo = min(m.bounds[0][0] for _, m in placed), min(m.bounds[0][1] for _, m in placed)
    hi = max(m.bounds[1][0] for _, m in placed), max(m.bounds[1][1] for _, m in placed)
    # Room for a 5 mm brim all round.
    assert hi[0] - lo[0] <= BED - 10 and hi[1] - lo[1] <= BED - 10, f"bed overflows: {hi[0] - lo[0]:.1f} x {hi[1] - lo[1]:.1f}"
    shift = [(BED - (hi[0] - lo[0])) / 2 - lo[0], (BED - (hi[1] - lo[1])) / 2 - lo[1], 0]
    for _, m in placed:
        m.apply_translation(shift)
    return placed, (hi[0] - lo[0], hi[1] - lo[1])


def _mesh_xml(m):
    v = "".join(f'<vertex x="{a:.4f}" y="{b:.4f}" z="{c:.4f}"/>' for a, b, c in m.vertices)
    t = "".join(f'<triangle v1="{a}" v2="{b}" v3="{c}"/>' for a, b, c in m.faces)
    return f"<mesh><vertices>{v}</vertices><triangles>{t}</triangles></mesh>"


def write_project(path, plates):
    """plates: [[(name, mesh in bed coordinates), ...], ...] -> one 3MF with
    a plate per entry, in Bambu Studio's project layout."""
    cols = math.ceil(math.sqrt(len(plates)))
    objects, items, settings, plate_cfg = [], [], [], []
    oid = 0
    for i, plate in enumerate(plates):
        ox, oy = (i % cols) * PLATE_STRIDE, -(i // cols) * PLATE_STRIDE
        inst = []
        for name, m in plate:
            oid += 1
            objects.append(f'<object id="{oid}" type="model" name="{name}">{_mesh_xml(m)}</object>')
            items.append(f'<item objectid="{oid}" transform="1 0 0 0 1 0 0 0 1 {ox:.3f} {oy:.3f} 0" printable="1"/>')
            kind = next(k for k in SETTINGS if f"-{k}" in name or (k == "left" and "-apron" in name))
            opts = "".join(f'<metadata key="{k}" value="{v}"/>' for k, v in {**COMMON, **SETTINGS[kind]}.items())
            settings.append(f'<object id="{oid}"><metadata key="name" value="{name}"/>'
                            f'<metadata key="extruder" value="1"/>{opts}'
                            f'<part id="1" subtype="normal_part"><metadata key="name" value="{name}"/></part></object>')
            inst.append(f'<model_instance><metadata key="object_id" value="{oid}"/>'
                        f'<metadata key="instance_id" value="0"/><metadata key="identify_id" value="{100 + oid}"/></model_instance>')
        plate_cfg.append(f'<plate><metadata key="plater_id" value="{i + 1}"/><metadata key="plater_name" value="bed {i + 1}"/>'
                         f'<metadata key="locked" value="false"/>{"".join(inst)}</plate>')
    model = ('<?xml version="1.0" encoding="UTF-8"?>\n'
             '<model unit="millimeter" xml:lang="en-US" xmlns="http://schemas.microsoft.com/3dmanufacturing/core/2015/02" '
             'xmlns:BambuStudio="http://schemas.bambulab.com/package/2021">'
             '<metadata name="Application">BambuStudio-01.10.02.76</metadata>'
             '<metadata name="BambuStudio:3mfVersion">1</metadata>'
             f'<metadata name="Title">Sink drain {VERSION}</metadata>'
             f'<metadata name="Description">{DESCRIPTION}</metadata>'
             f'<resources>{"".join(objects)}</resources><build>{"".join(items)}</build></model>')
    config = f'<?xml version="1.0" encoding="UTF-8"?>\n<config>{"".join(settings)}{"".join(plate_cfg)}</config>'
    types = ('<?xml version="1.0" encoding="UTF-8"?>\n<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">'
             '<Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>'
             '<Default Extension="model" ContentType="application/vnd.ms-package.3dmanufacturing-3dmodel+xml"/>'
             '<Default Extension="config" ContentType="text/xml"/></Types>')
    rels = ('<?xml version="1.0" encoding="UTF-8"?>\n<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">'
            '<Relationship Target="/3D/3dmodel.model" Id="rel-1" Type="http://schemas.microsoft.com/3dmanufacturing/2013/01/3dmodel"/>'
            '</Relationships>')
    with zipfile.ZipFile(path, "w", zipfile.ZIP_DEFLATED) as z:
        z.writestr("[Content_Types].xml", types)
        z.writestr("_rels/.rels", rels)
        z.writestr("3D/3dmodel.model", model)
        z.writestr("Metadata/model_settings.config", config)


plates = []
for i, bed in enumerate(BEDS, 1):
    placed, size = layout(bed)
    named = [(f"sink-drain-{VERSION}-{NAMES[k]}", m) for k, m in placed]
    plates.append(named)
    path = PRINT / f"sink-drain-{VERSION}-bed-{i}.3mf"
    write_project(path, [named])
    print(f"bed {i}: {', '.join(NAMES[k] for k, _ in placed)}  ({size[0]:.0f} x {size[1]:.0f} mm) -> {path.name}")
write_project(PRINT / f"sink-drain-{VERSION}-all-beds.3mf", plates)

# Test slices of the spout end (30 mm of the apron with its tongue, and of the
# right piece with the open collector and the spout) on one bed, same settings.
placed, size = layout([["ts-left"], ["ts-right"]])
write_project(PRINT / f"sink-drain-{VERSION}-test-slice.3mf", [[(f"sink-drain-{VERSION}-{NAMES[k]}", m) for k, m in placed]])
print(f"test slice ({size[0]:.0f} x {size[1]:.0f} mm) -> sink-drain-{VERSION}-test-slice.3mf")
print(f"all, one plate per bed -> sink-drain-{VERSION}-all-beds.3mf")
