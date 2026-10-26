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
    ["right--1"],
]
NAMES = {"plate-0": "plate-1", "plate-1": "plate-2", "plate-2": "plate-3",
         "left-0": "apron-spout-end", "left-1": "apron-wall-end", "right--1": "right-with-spout",
         "plinth-0": "plinth-back", "plinth-1": "plinth-front"}


def load(key):
    m = trimesh.load(OUT / f"model-{key}.stl")
    m.apply_translation(-m.bounds[0])
    return m


def layout(bed):
    placed, x = [], 0.0
    for col in bed:
        col = col if isinstance(col, list) else [col]
        meshes = [(k, load(k)) for k in col]
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
    assert hi[0] - lo[0] <= BED and hi[1] - lo[1] <= BED, f"bed overflows: {hi[0] - lo[0]:.1f} x {hi[1] - lo[1]:.1f}"
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
            settings.append(f'<object id="{oid}"><metadata key="name" value="{name}"/>'
                            f'<metadata key="extruder" value="1"/>'
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
print(f"all, one plate per bed -> sink-drain-{VERSION}-all-beds.3mf")
