import zipfile
import xml.etree.ElementTree as ET

import numpy as np
import pytest
import trimesh

from makeit.__main__ import main
from makeit.bambu import write_bambu_3mf


def _box(tmp_path, extents=(20, 10, 5)):
    stl = tmp_path / "box.stl"
    trimesh.creation.box(extents=extents).export(stl)
    return stl


def test_bambu_3mf_centres_part_and_keeps_settings(tmp_path):
    out = tmp_path / "out" / "box.3mf"
    res = write_bambu_3mf(_box(tmp_path), out, "box", {"enable_support": "0"})
    assert res["size_mm"] == [20, 10, 5]
    with zipfile.ZipFile(out) as z:
        names = set(z.namelist())
        assert {"[Content_Types].xml", "_rels/.rels", "3D/3dmodel.model",
                "Metadata/model_settings.config"} <= names
        cfg = ET.fromstring(z.read("Metadata/model_settings.config"))
        meta = {m.get("key"): m.get("value") for m in cfg.find("object").findall("metadata")}
        assert meta["name"] == "box" and meta["enable_support"] == "0"
        model = ET.fromstring(z.read("3D/3dmodel.model"))
    # Parse with ElementTree: trimesh's 3MF loader needs lxml, which CI lacks.
    ns = {"m": "http://schemas.microsoft.com/3dmanufacturing/core/2015/02"}
    verts = np.array([[float(v.get(k)) for k in "xyz"] for v in model.iterfind(".//m:vertex", ns)])
    offset = np.array([float(t) for t in model.find(".//m:item", ns).get("transform").split()[9:]])
    lo, hi = verts.min(0) + offset, verts.max(0) + offset
    assert abs(lo[2]) < 1e-3
    assert abs((lo[0] + hi[0]) / 2 - 128) < 1e-3 and abs((lo[1] + hi[1]) / 2 - 128) < 1e-3


def test_bambu_rejects_part_bigger_than_bed(tmp_path):
    with pytest.raises(ValueError):
        write_bambu_3mf(_box(tmp_path, (300, 10, 5)), tmp_path / "x.3mf", "big")


def test_bambu_cli(tmp_path, capsys):
    out = tmp_path / "b.3mf"
    assert main(["bambu", str(_box(tmp_path)), str(out), "--name", "b", "--set", "wall_loops=4"]) == 0
    assert out.exists() and '"size_mm"' in capsys.readouterr().out
