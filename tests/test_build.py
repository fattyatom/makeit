import shutil
from pathlib import Path

import numpy as np
import pytest

from makeit import build as b
from makeit.__main__ import _parse_sets, main

ROOT = Path(__file__).resolve().parents[1]
needs_openscad = pytest.mark.skipif(not shutil.which("openscad"), reason="openscad not installed")


def _copy_repo_bits(tmp_path, project):
    shutil.copytree(ROOT / "lib", tmp_path / "lib")
    shutil.copytree(ROOT / "templates", tmp_path / "templates")
    if project:
        shutil.copytree(ROOT / "projects" / project, tmp_path / "projects" / project,
                        ignore=shutil.ignore_patterns("out"))


def test_analyze_cli_writes_json_into_new_dir(tmp_path, capsys):
    import trimesh

    mesh = tmp_path / "box.stl"
    trimesh.creation.box(extents=[0.2, 0.1, 0.05]).export(mesh)
    out = tmp_path / "out" / "scan.json"
    assert main(["analyze", str(mesh), "--up", "z", "--threshold", "0.5", "--json", str(out)]) == 0
    assert out.exists() and "planes (largest first)" in capsys.readouterr().out


def test_parse_sets():
    assert _parse_sets(["a=1", ' name = "x" ']) == {"a": "1", "name": '"x"'}
    with pytest.raises(SystemExit):
        _parse_sets(["nope"])


def test_new_project_copies_template(tmp_path):
    _copy_repo_bits(tmp_path, None)
    dest = b.new_project("shelf-clip", root=tmp_path)
    assert (dest / "model.scad").exists() and (dest / "brief.md").exists()
    with pytest.raises(FileExistsError):
        b.new_project("shelf-clip", root=tmp_path)


@needs_openscad
def test_template_builds(tmp_path):
    _copy_repo_bits(tmp_path, None)
    dest = b.new_project("t", root=tmp_path)
    result = b.build(dest, previews=False)
    assert result["print_orientation"]["size_mm"] == pytest.approx([20, 100, 2.4], abs=0.01)
    assert (dest / "out" / "model.3mf").stat().st_size > 0


@needs_openscad
def test_sink_cover_print_orientation_and_slices(tmp_path):
    _copy_repo_bits(tmp_path, "sink-gap-cover")
    project = tmp_path / "projects" / "sink-gap-cover"
    sets = {"length": "200", "gap_left": "8", "gap_right": "10", "rim_overlap": "15",
            "slope_deg": "0", "thickness": "2", "upstand_height": "10", "tab_depth": "6",
            "clearance": "0.5"}

    full = b.build(project, sets, formats=("stl",), previews=False)
    stats = full["print_orientation"]
    assert stats["watertight"]
    # Lying on its wall-side face: height = depth from wall face to sink edge.
    x0, x1 = 0.5, 10 + 15
    assert stats["bounds_mm"][0][2] == pytest.approx(0, abs=0.01)
    assert stats["size_mm"][2] == pytest.approx(x1 - x0, abs=0.01)
    # Profile height (tab bottom to upstand top) lies along x; length along y.
    assert stats["size_mm"][0] == pytest.approx(6 + 2 + 10, abs=0.01)
    assert stats["size_mm"][1] == pytest.approx(200, abs=0.01)

    test = b.build(project, {**sets, "test_slice": "30"}, formats=("stl",), previews=False, tag="t")
    assert test["print_orientation"]["size_mm"][1] == pytest.approx(30, abs=0.01)

    half = b.build(project, {**sets, "segments": "2", "segment": "1"}, formats=("stl",),
                   previews=False, tag="s")
    assert half["print_orientation"]["bounds_mm"][0][1] == pytest.approx(100, abs=0.01)


@needs_openscad
def test_sink_cover_rejects_gap_too_narrow_for_tab(tmp_path):
    _copy_repo_bits(tmp_path, "sink-gap-cover")
    project = tmp_path / "projects" / "sink-gap-cover"
    with pytest.raises(RuntimeError, match="gap too narrow"):
        b.build(project, {"gap_left": "1.2"}, formats=("stl",), previews=False)


@needs_openscad
@pytest.mark.skipif(not shutil.which("xvfb-run"), reason="previews need xvfb-run")
def test_previews_render(tmp_path):
    _copy_repo_bits(tmp_path, None)
    dest = b.new_project("t", root=tmp_path)
    result = b.build(dest, formats=("stl",))
    assert sorted(Path(p).stem for p in result["previews"]) == [
        "model-bed", "model-iso", "model-profile", "model-side", "model-top"]


LIB_DEMO = """
use <lib/makeit.scad>
difference() {
    union() {
        linear_extrude(3) rrect(-20, -10, 20, 10, 4);
        translate([-20, 0, 0]) cube([2, 4, 20]);     // a wall at x=-18
        translate([-18, 2, 3]) gusset45(8, 2);
    }
    cs_screw_hole(3);
}
"""


@needs_openscad
def test_lib_helpers_build(tmp_path):
    _copy_repo_bits(tmp_path, None)
    scad = tmp_path / "demo.scad"
    scad.write_text(LIB_DEMO)
    stl = tmp_path / "demo.stl"
    b._run([b._openscad(), "-o", str(stl), str(scad)])
    stats = b.mesh_stats(stl)
    assert stats["watertight"]
    assert stats["size_mm"] == pytest.approx([40, 20, 20], abs=0.01)
    # Plate (rounded corners) + wall + gusset, minus the countersunk hole,
    # which takes the 4.2 mm shaft and most of the 8.4 mm cone out of 3 mm.
    plate = 40 * 20 - 4 * (16 - 3.14159 * 4)
    solid = plate * 3 + 2 * 4 * 17 + 2 * 32
    assert solid - 120 < 1000 * stats["volume_cm3"] < solid - 60


@needs_openscad
def test_detent_y_touches_corner(tmp_path):
    _copy_repo_bits(tmp_path, None)
    scad = tmp_path / "d.scad"
    # wall at 11, part face at 10.5, rc 5, rb 3, depth 1.5 -> bump centre x 12.5,
    # corner centre x 5.5: dx 7, rc+rb 8, so y = corner_y + sqrt(15).
    scad.write_text('use <lib/makeit.scad>\necho(y = detent_y(11, 10.5, 5, 3, 1.5, 100));\ncube(1);\n')
    msgs = b._run([b._openscad(), "-o", str(tmp_path / "d.stl"), str(scad)])
    y = float(next(m for m in msgs if "y =" in m).split("=")[-1])
    assert y == pytest.approx(100 + 15 ** 0.5, abs=1e-4)


@needs_openscad
@pytest.mark.skipif(not shutil.which("xvfb-run"), reason="previews need xvfb-run")
def test_tall_part_fits_in_3d_previews(tmp_path):
    from PIL import Image

    _copy_repo_bits(tmp_path, None)
    dest = b.new_project("t", root=tmp_path)
    # Template part: 20 wide, 30 long, 60 tall. Tall parts used to be cropped.
    result = b.build(dest, {"length": "30", "thickness": "60"}, formats=("stl",))
    for name in ("model-iso", "model-bed"):
        png = next(p for p in result["previews"] if Path(p).stem == name)
        img = np.asarray(Image.open(png).convert("RGB")).astype(int)
        bg = img[0, 0]
        border = np.concatenate([img[0], img[-1], img[:, 0], img[:, -1]])
        assert np.abs(border - bg).max() < 10, f"{name} touches the image edge"


@needs_openscad
def test_hook_root_y_touches_corner(tmp_path):
    import math

    _copy_repo_bits(tmp_path, None)
    scad = tmp_path / "h.scad"
    # Wall at x=11, part side at 10.5, corner radius 5, 45° face, front at 100.
    scad.write_text('use <lib/makeit.scad>\necho(y = hook_root_y(11, 10.5, 5, 45, 100));\n'
                    'linear_extrude(1) translate([11, 0]) hook2d(90, 2.5, 45);\n')
    msgs = b._run([b._openscad(), "-o", str(tmp_path / "h.stl"), str(scad)])
    y = float(next(m for m in msgs if "y =" in m).split("=")[-1])
    # Tangent point of the 45° face on the arc centred (5.5, 95): (5.5 + 5/√2, 95 + 5/√2).
    tx, ty = 5.5 + 5 / math.sqrt(2), 95 + 5 / math.sqrt(2)
    assert ty - y == pytest.approx(11 - tx, abs=1e-4)          # on the 45° line from (11, y)
    assert y == pytest.approx(100 - 0.5 - 5 * (2 - math.sqrt(2)), abs=1e-4)
    stats = b.mesh_stats(tmp_path / "h.stl")
    # Hook spans 2.5 mm in x; in y from the root to the end of the 30° entry ramp.
    assert stats["size_mm"][0] == pytest.approx(2.51, abs=0.02)
    assert stats["size_mm"][1] == pytest.approx(2.5 + 0.4 + 2.5 / math.tan(math.radians(30)), abs=0.02)
