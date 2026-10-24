import shutil
from pathlib import Path

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
        "model-iso", "model-profile", "model-side", "model-top"]
