"""Find flat surfaces (wall, countertop, sink rim...) in a scanned point set.

Plain-numpy RANSAC: good enough for the handful of large planes a household
scan contains, and avoids a heavy open3d dependency.
"""

from __future__ import annotations

from dataclasses import dataclass, field

import numpy as np


@dataclass
class Plane:
    normal: np.ndarray  # unit vector
    offset: float  # plane is {p : normal . p == offset}
    centroid: np.ndarray
    inliers: int
    size: tuple[float, float] = (0.0, 0.0)  # extent of inliers within the plane
    points: np.ndarray = field(default=None, repr=False)

    def distance(self, p: np.ndarray) -> np.ndarray:
        return np.asarray(p) @ self.normal - self.offset


def fit_plane(points: np.ndarray) -> tuple[np.ndarray, float, np.ndarray]:
    """Least-squares plane through points: (normal, offset, centroid)."""
    centroid = points.mean(axis=0)
    _, _, vt = np.linalg.svd(points - centroid, full_matrices=False)
    normal = vt[-1]
    return normal, float(normal @ centroid), centroid


def _in_plane_size(points: np.ndarray, normal: np.ndarray) -> tuple[float, float]:
    """Width/height of points projected onto the plane (via in-plane PCA)."""
    centered = points - points.mean(axis=0)
    flat = centered - np.outer(centered @ normal, normal)
    _, _, vt = np.linalg.svd(flat, full_matrices=False)
    uv = flat @ vt[:2].T
    span = uv.max(axis=0) - uv.min(axis=0)
    return float(span[0]), float(span[1])


def ransac_plane(points, threshold, iterations, rng):
    best_mask, best_count = None, 0
    n = len(points)
    for _ in range(iterations):
        a, b, c = points[rng.choice(n, 3, replace=False)]
        normal = np.cross(b - a, c - a)
        norm = np.linalg.norm(normal)
        if norm < 1e-12:
            continue
        normal /= norm
        mask = np.abs(points @ normal - normal @ a) < threshold
        count = int(mask.sum())
        if count > best_count:
            best_mask, best_count = mask, count
    return best_mask


def detect_planes(
    points: np.ndarray,
    max_planes: int = 6,
    threshold: float = 2.0,
    min_fraction: float = 0.03,
    iterations: int = 400,
    seed: int = 0,
) -> list[Plane]:
    """Greedily peel off the largest planes. `threshold` is in the points' units."""
    rng = np.random.default_rng(seed)
    remaining = np.asarray(points, dtype=float)
    min_inliers = max(3, int(min_fraction * len(remaining)))
    planes: list[Plane] = []
    while len(planes) < max_planes and len(remaining) >= min_inliers:
        mask = ransac_plane(remaining, threshold, iterations, rng)
        if mask is None or mask.sum() < min_inliers:
            break
        normal, offset, centroid = fit_plane(remaining[mask])
        # Refit once with inliers of the refined plane.
        mask = np.abs(remaining @ normal - offset) < threshold
        inlier_pts = remaining[mask]
        normal, offset, centroid = fit_plane(inlier_pts)
        planes.append(
            Plane(
                normal=normal,
                offset=offset,
                centroid=centroid,
                inliers=len(inlier_pts),
                size=_in_plane_size(inlier_pts, normal),
                points=inlier_pts,
            )
        )
        remaining = remaining[~mask]
    return planes


def angle_between(a: Plane, b: Plane) -> float:
    """Angle between two planes in degrees, folded to [0, 90]."""
    cos = abs(float(a.normal @ b.normal))
    return float(np.degrees(np.arccos(np.clip(cos, 0.0, 1.0))))


def tilt_from_horizontal(plane: Plane, up: np.ndarray) -> float:
    """0 = horizontal surface (floor/counter), 90 = vertical (wall)."""
    cos = abs(float(plane.normal @ up))
    return float(np.degrees(np.arccos(np.clip(cos, 0.0, 1.0))))


def plane_gap(a: Plane, b: Plane) -> float:
    """Distance between two (near-)parallel planes, measured at b's centroid."""
    return float(abs(a.distance(b.centroid)))
