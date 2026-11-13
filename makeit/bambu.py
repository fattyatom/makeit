"""Write a 3MF laid out the way Bambu Studio expects: one named object,
centred on the plate, with per-object print settings in
Metadata/model_settings.config. Printer and filament presets stay the
user's choice in the slicer."""

from __future__ import annotations

import zipfile
from pathlib import Path
from xml.sax.saxutils import quoteattr

import numpy as np
import trimesh

CONTENT_TYPES = """<?xml version="1.0" encoding="UTF-8"?>
<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">
 <Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>
 <Default Extension="model" ContentType="application/vnd.ms-package.3dmanufacturing-3dmodel+xml"/>
 <Default Extension="config" ContentType="text/xml"/>
</Types>
"""

RELS = """<?xml version="1.0" encoding="UTF-8"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
 <Relationship Target="/3D/3dmodel.model" Id="rel-1" Type="http://schemas.microsoft.com/3dmanufacturing/2013/01/3dmodel"/>
</Relationships>
"""


def _model_xml(mesh: trimesh.Trimesh, name: str, offset: np.ndarray, title: str) -> str:
    v = "\n".join(f'     <vertex x="{x:.4f}" y="{y:.4f}" z="{z:.4f}"/>' for x, y, z in mesh.vertices)
    t = "\n".join(f'     <triangle v1="{a}" v2="{b}" v3="{c}"/>' for a, b, c in mesh.faces)
    ox, oy, oz = offset
    return f"""<?xml version="1.0" encoding="UTF-8"?>
<model unit="millimeter" xml:lang="en-US" xmlns="http://schemas.microsoft.com/3dmanufacturing/core/2015/02">
 <metadata name="Title">{title}</metadata>
 <metadata name="Application">makeit</metadata>
 <resources>
  <object id="1" type="model" name={quoteattr(name)}>
   <mesh>
    <vertices>
{v}
    </vertices>
    <triangles>
{t}
    </triangles>
   </mesh>
  </object>
 </resources>
 <build>
  <item objectid="1" transform="1 0 0 0 1 0 0 0 1 {ox:.4f} {oy:.4f} {oz:.4f}" printable="1"/>
 </build>
</model>
"""


def _settings_xml(name: str, settings: dict[str, str], n_faces: int) -> str:
    meta = "\n".join(f'    <metadata key={quoteattr(k)} value={quoteattr(str(v))}/>'
                     for k, v in {"name": name, "extruder": "1", **settings}.items())
    return f"""<?xml version="1.0" encoding="UTF-8"?>
<config>
  <object id="1">
{meta}
    <part id="1" subtype="normal_part">
      <metadata key="name" value={quoteattr(name)}/>
      <metadata key="matrix" value="1 0 0 0 0 1 0 0 0 0 1 0 0 0 0 1"/>
      <mesh_stat face_count="{n_faces}" edges_fixed="0" degenerate_facets="0" facets_removed="0" facets_reversed="0" backwards_edges="0"/>
    </part>
  </object>
  <plate>
    <metadata key="plater_id" value="1"/>
    <metadata key="plater_name" value=""/>
    <metadata key="locked" value="false"/>
    <model_instance>
      <metadata key="object_id" value="1"/>
      <metadata key="instance_id" value="0"/>
    </model_instance>
  </plate>
</config>
"""


def write_bambu_3mf(
    stl: str | Path,
    out: str | Path,
    name: str,
    settings: dict[str, str] | None = None,
    bed_mm: tuple[float, float] = (256, 256),
) -> dict:
    """Pack `stl` (already in print orientation) into a 3MF for Bambu Studio.

    The mesh is moved so its footprint is centred on the bed and its lowest
    point sits at z=0. `settings` are per-object overrides by Bambu Studio
    key, e.g. {"enable_support": "0", "wall_loops": "4"}.
    """
    mesh = trimesh.load(str(stl), force="mesh")
    lo, hi = mesh.bounds
    size = hi - lo
    if size[0] > bed_mm[0] or size[1] > bed_mm[1]:
        raise ValueError(f"part {size[:2].round(1).tolist()} mm does not fit the {bed_mm} mm bed")
    mesh.apply_translation([-(lo[0] + hi[0]) / 2, -(lo[1] + hi[1]) / 2, -lo[2]])
    offset = np.array([bed_mm[0] / 2, bed_mm[1] / 2, 0.0])
    out = Path(out)
    out.parent.mkdir(parents=True, exist_ok=True)
    with zipfile.ZipFile(out, "w", zipfile.ZIP_DEFLATED) as z:
        z.writestr("[Content_Types].xml", CONTENT_TYPES)
        z.writestr("_rels/.rels", RELS)
        z.writestr("3D/3dmodel.model", _model_xml(mesh, name, offset, name))
        z.writestr("Metadata/model_settings.config", _settings_xml(name, settings or {}, len(mesh.faces)))
    return {"file": str(out), "size_mm": np.round(size, 2).tolist()}
