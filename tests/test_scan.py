import numpy as np
import pytest
import trimesh

from makeit import planes as pl
from makeit import scan


def _plane_points(origin, u, v, n=2000, size=(1.0, 1.0), noise=0.0, seed=0):
    rng = np.random.default_rng(seed)
    a = rng.uniform(0, size[0], n)[:, None]
    b = rng.uniform(0, size[1], n)[:, None]
    pts = np.asarray(origin) + a * np.asarray(u) + b * np.asarray(v)
    return pts + rng.normal(0, noise, pts.shape)


def test_detects_floor_and_wall_at_right_angle():
    floor = _plane_points([0, 0, 0], [1, 0, 0], [0, 1, 0], size=(500, 500), noise=0.5)
    wall = _plane_points([0, 0, 0], [0, 1, 0], [0, 0, 1], size=(500, 300), noise=0.5, seed=1)
    found = pl.detect_planes(np.vstack([floor, wall]), max_planes=2, threshold=2.0)
    assert len(found) == 2
    assert pl.angle_between(found[0], found[1]) == pytest.approx(90, abs=1)
    tilts = sorted(pl.tilt_from_horizontal(p, np.array([0, 0, 1.0])) for p in found)
    assert tilts[0] == pytest.approx(0, abs=1)
    assert tilts[1] == pytest.approx(90, abs=1)


def test_parallel_plane_gap():
    a = _plane_points([0, 0, 0], [0, 1, 0], [0, 0, 1], size=(300, 100))
    b = _plane_points([8.5, 0, 0], [0, 1, 0], [0, 0, 1], size=(300, 100), seed=1)
    found = pl.detect_planes(np.vstack([a, b]), max_planes=2, threshold=1.0)
    assert pl.angle_between(*found) < 1
    assert pl.plane_gap(*found) == pytest.approx(8.5, abs=0.1)


def test_plane_size_matches_extent():
    pts = _plane_points([0, 0, 0], [1, 0, 0], [0, 1, 0], n=5000, size=(600, 40))
    (plane,) = pl.detect_planes(pts, max_planes=1)
    assert max(plane.size) == pytest.approx(600, abs=5)
    assert min(plane.size) == pytest.approx(40, abs=2)


def test_load_scales_metres_to_mm(tmp_path):
    path = tmp_path / "box.ply"
    trimesh.creation.box(extents=[0.6, 0.04, 0.02]).export(path)
    geom, scale = scan.load(path)
    assert scale == 1000
    assert np.allclose(geom.extents, [600, 40, 20], atol=0.01)
    _, scale = scan.load(path, units="mm")
    assert scale == 1


def test_analyze_box_reports_face_gaps(tmp_path):
    path = tmp_path / "box.stl"
    trimesh.creation.box(extents=[0.2, 0.1, 0.05]).export(path)
    report = scan.analyze(path, up="z", max_planes=6, threshold=0.5)
    assert len(report["planes"]) == 6
    gaps = sorted(p["gap_mm"] for p in report["pairs"] if "gap_mm" in p)
    assert gaps == pytest.approx([50, 100, 200], abs=1)
    kinds = [p["kind"] for p in report["planes"]]
    assert kinds.count("horizontal") == 2 and kinds.count("vertical") == 4
    assert "plane pairs" in scan.format_report(report)


def test_section_of_box_is_its_outline(tmp_path):
    path = tmp_path / "box.stl"
    trimesh.creation.box(extents=[30, 10, 20]).export(path)
    lines = scan.section(path, origin=[0, 0, 0], normal=[0, 1, 0], units="mm", out_prefix=tmp_path / "cut")
    assert len(lines) == 1
    span = lines[0].max(axis=0) - lines[0].min(axis=0)
    assert sorted(span) == pytest.approx([20, 30], abs=0.01)
    assert (tmp_path / "cut.svg").exists()
    assert (tmp_path / "cut.csv").read_text().startswith("polyline,x_mm,y_mm")
