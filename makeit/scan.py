"""Load a phone scan and turn it into numbers Claude can design against."""

from __future__ import annotations

from pathlib import Path

import numpy as np
import trimesh

from . import planes as pl

UP_AXES = {"x": [1, 0, 0], "y": [0, 1, 0], "z": [0, 0, 1]}
PARALLEL_DEG = 5.0  # pairs closer than this are reported as parallel, with a gap


def load(path: str | Path, units: str = "auto"):
    """Load a mesh or point cloud and scale it to millimetres.

    Returns (geometry, scale_used). iPhone scanner apps (ARKit) export metres,
    so `auto` assumes metres when the whole scan is under 20 units across.
    """
    geom = trimesh.load(str(path), force=None)
    if isinstance(geom, trimesh.Scene):
        geom = geom.to_geometry() if hasattr(geom, "to_geometry") else geom.dump(concatenate=True)
    extent = float(np.max(geom.bounds[1] - geom.bounds[0]))
    if units == "auto":
        scale = 1000.0 if extent < 20 else 1.0
    else:
        scale = {"m": 1000.0, "cm": 10.0, "mm": 1.0}[units]
    if scale != 1.0:
        geom = geom.copy()
        geom.apply_scale(scale)
    return geom, scale


def sample_points(geom, count: int = 40000, seed: int = 0) -> np.ndarray:
    if isinstance(geom, trimesh.Trimesh) and len(geom.faces):
        pts, _ = trimesh.sample.sample_surface(geom, count, seed=seed)
        return np.asarray(pts)
    pts = np.asarray(geom.vertices)
    if len(pts) > count:
        pts = pts[np.random.default_rng(seed).choice(len(pts), count, replace=False)]
    return pts


def analyze(path, units="auto", up="y", max_planes=6, threshold=2.0, seed=0) -> dict:
    """Detect the main planes in a scan and how they relate. All lengths in mm."""
    geom, scale = load(path, units)
    points = sample_points(geom, seed=seed)
    up_vec = np.array(UP_AXES[up], dtype=float)
    found = pl.detect_planes(points, max_planes=max_planes, threshold=threshold, seed=seed)

    report = {
        "file": str(path),
        "scale_to_mm": scale,
        "up_axis": up,
        "bounds_mm": np.round(geom.bounds, 1).tolist(),
        "size_mm": np.round(geom.bounds[1] - geom.bounds[0], 1).tolist(),
        "planes": [],
        "pairs": [],
    }
    for i, p in enumerate(found):
        tilt = pl.tilt_from_horizontal(p, up_vec)
        kind = "horizontal" if tilt < 10 else "vertical" if tilt > 80 else "sloped"
        report["planes"].append(
            {
                "id": i,
                "kind": kind,
                "tilt_deg": round(tilt, 1),
                "normal": np.round(p.normal, 4).tolist(),
                "centroid_mm": np.round(p.centroid, 1).tolist(),
                "size_mm": [round(s, 1) for s in p.size],
                "share": round(p.inliers / len(points), 3),
            }
        )
    for i in range(len(found)):
        for j in range(i + 1, len(found)):
            angle = pl.angle_between(found[i], found[j])
            pair = {"planes": [i, j], "angle_deg": round(angle, 2)}
            if angle < PARALLEL_DEG:
                pair["gap_mm"] = round(pl.plane_gap(found[i], found[j]), 1)
            report["pairs"].append(pair)
    return report


def format_report(report: dict) -> str:
    lines = [
        f"{report['file']}  (scale x{report['scale_to_mm']:g} -> mm, up={report['up_axis']})",
        f"overall size: {' x '.join(f'{v:g}' for v in report['size_mm'])} mm",
        "",
        "planes (largest first):",
    ]
    for p in report["planes"]:
        lines.append(
            f"  #{p['id']} {p['kind']:<10} tilt {p['tilt_deg']:>5}°  "
            f"size {p['size_mm'][0]:g} x {p['size_mm'][1]:g} mm  "
            f"at {p['centroid_mm']}  ({p['share']:.0%} of points)"
        )
    lines.append("")
    lines.append("plane pairs:")
    for pair in report["pairs"]:
        a, b = pair["planes"]
        extra = f"  gap {pair['gap_mm']} mm" if "gap_mm" in pair else ""
        lines.append(f"  #{a}-#{b}: {pair['angle_deg']}°{extra}")
    return "\n".join(lines)


def section(path, origin, normal, units="auto", out_prefix=None) -> list[np.ndarray]:
    """Cut the scan with a plane; return 2D polylines (mm) in that plane.

    Writes <out_prefix>.svg and <out_prefix>.csv when out_prefix is given.
    """
    geom, _ = load(path, units)
    if not isinstance(geom, trimesh.Trimesh):
        raise ValueError("section needs a mesh with faces, not a point cloud")
    cut = geom.section(plane_origin=np.asarray(origin, float), plane_normal=np.asarray(normal, float))
    if cut is None:
        return []
    planar, _ = cut.to_2D() if hasattr(cut, "to_2D") else cut.to_planar()
    polylines = [np.asarray(d) for d in planar.discrete]
    if out_prefix:
        out_prefix = Path(out_prefix)
        out_prefix.parent.mkdir(parents=True, exist_ok=True)
        planar.export(str(out_prefix.with_suffix(".svg")))
        with open(out_prefix.with_suffix(".csv"), "w") as f:
            f.write("polyline,x_mm,y_mm\n")
            for k, line in enumerate(polylines):
                for x, y in line:
                    f.write(f"{k},{x:.2f},{y:.2f}\n")
    return polylines
