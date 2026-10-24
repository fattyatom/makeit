"""Render a project's model.scad to printable files plus preview images."""

from __future__ import annotations

import os
import shutil
import subprocess
import tempfile
from pathlib import Path

import numpy as np
import trimesh

# name: (gimbal rotation, projection, axes visible on screen, extra -D).
# "profile" looks along +y at a thin slice from the middle of the part
# (lib/makeit.scad print_cut honours $section_at).
VIEWS = {
    "iso": ("55,0,25", "perspective", (0, 1, 2), {}),
    "profile": ("90,0,0", "ortho", (0, 2), {"$section_at": "0.5"}),
    "side": ("90,0,90", "ortho", (1, 2), {}),
    "top": ("0,0,0", "ortho", (0, 1), {}),
}


def _openscad() -> str:
    exe = shutil.which("openscad")
    if not exe:
        raise RuntimeError("openscad not found; run scripts/setup.sh")
    return exe


def _defines(sets: dict[str, str]) -> list[str]:
    """`-D` args. Values are OpenSCAD expressions: 12.5, true, "text" (with quotes)."""
    args = []
    for key, value in sets.items():
        args += ["-D", f"{key}={value}"]
    return args


def _run(cmd: list[str], headless: bool = False) -> list[str]:
    """Run openscad; raise on errors, return its warnings (ECHO lines included)."""
    if headless and not os.environ.get("DISPLAY") and shutil.which("xvfb-run"):
        cmd = ["xvfb-run", "-a"] + cmd
    result = subprocess.run(cmd, capture_output=True, text=True)
    if result.returncode != 0 or "ERROR:" in result.stderr:
        raise RuntimeError(f"openscad failed:\n{result.stderr[-3000:]}")
    return [line for line in result.stderr.splitlines() if line.startswith(("WARNING:", "ECHO:"))]


def _frame(exe: str, model: Path, sets: dict[str, str], rot: str, axes) -> str:
    """Gimbal camera string centred on the part. OpenSCAD's --viewall does
    not zoom when rendering headless, so frame from the part's own bounds."""
    with tempfile.TemporaryDirectory() as tmp:
        stl = Path(tmp) / "frame.stl"
        _run([exe, "-o", str(stl), *_defines(sets), str(model)])
        lo, hi = trimesh.load(str(stl)).bounds
    center = (lo + hi) / 2
    span = max(float(np.max((hi - lo)[list(axes)])), 1.0)
    dist = span * (2.2 if len(axes) == 3 else 3.5)
    return ",".join(f"{v:.3f}" for v in [*center, *map(float, rot.split(",")), dist])


def mesh_stats(stl_path: Path) -> dict:
    mesh = trimesh.load(str(stl_path))
    lo, hi = mesh.bounds
    return {
        "bounds_mm": np.round([lo, hi], 2).tolist(),
        "size_mm": np.round(hi - lo, 2).tolist(),
        "volume_cm3": round(float(mesh.volume) / 1000, 2),
        "watertight": bool(mesh.is_watertight),
    }


def build(
    project: str | Path,
    sets: dict[str, str] | None = None,
    formats: tuple[str, ...] = ("stl", "3mf"),
    previews: bool = True,
    tag: str = "",
) -> dict:
    """Export model.scad to out/ and render previews.

    Exports use `orient="print"` (lying the way it should go on the bed),
    previews use `orient="installed"` with context ghosts; models that don't
    declare `orient` simply ignore it.
    """
    project = Path(project)
    model = project / "model.scad"
    if not model.exists():
        raise FileNotFoundError(model)
    out = project / "out"
    out.mkdir(exist_ok=True)
    sets = dict(sets or {})
    stem = "model" + (f"-{tag}" if tag else "")
    exe = _openscad()

    files, messages = [], []
    for fmt in formats:
        target = out / f"{stem}.{fmt}"
        messages += _run([exe, "-o", str(target), *_defines({"orient": '"print"', **sets}), str(model)])
        files.append(str(target))

    images = []
    if previews:
        for name, (rot, projection, axes, extra) in VIEWS.items():
            target = out / f"{stem}-{name}.png"
            camera = _frame(exe, model, {"orient": '"installed"', **sets, **extra}, rot, axes)
            messages += _run(
                [
                    exe, "-o", str(target),
                    f"--camera={camera}", f"--projection={projection}",
                    "--imgsize=1000,750", "--colorscheme=Tomorrow",
                    *_defines({"orient": '"installed"', **sets, **extra}), str(model),
                ],
                headless=True,
            )
            if target.exists() and target.stat().st_size > 0:
                images.append(str(target))

    stl = out / f"{stem}.stl"
    stats = mesh_stats(stl) if stl.exists() else {}
    return {
        "files": files,
        "previews": images,
        "print_orientation": stats,
        "openscad_messages": sorted(set(messages)),
    }


def new_project(name: str, root: str | Path = ".") -> Path:
    root = Path(root)
    dest = root / "projects" / name
    if dest.exists():
        raise FileExistsError(dest)
    shutil.copytree(root / "templates" / "part", dest)
    return dest
