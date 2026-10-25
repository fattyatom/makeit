"""Pack the release pieces onto 255 mm beds and write one 3MF per bed plus one
with every piece (python projects/sink-drain/beds.py, after the per-piece builds)."""
import sys
from pathlib import Path

import trimesh

BED, GAP = 255.0, 6.0
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


everything = trimesh.Scene()
for i, bed in enumerate(BEDS, 1):
    placed, size = layout(bed)
    scene = trimesh.Scene()
    for k, m in placed:
        scene.add_geometry(m, geom_name=f"sink-drain-{VERSION}-{NAMES[k]}")
        everything.add_geometry(m.copy().apply_translation([(i - 1) * (BED + 20), 0, 0]),
                                geom_name=f"bed{i}-{NAMES[k]}")
    path = PRINT / f"sink-drain-{VERSION}-bed-{i}.3mf"
    scene.export(path)
    print(f"bed {i}: {', '.join(NAMES[k] for k, _ in placed)}  ({size[0]:.0f} x {size[1]:.0f} mm) -> {path.name}")
everything.export(PRINT / f"sink-drain-{VERSION}-all-beds.3mf")
print(f"all -> sink-drain-{VERSION}-all-beds.3mf")
