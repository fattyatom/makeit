"""CLI: python -m makeit {new,analyze,section,build} ..."""

from __future__ import annotations

import argparse
import json
import os
import sys

from . import build as b
from . import scan


def _parse_sets(items: list[str]) -> dict[str, str]:
    sets = {}
    for item in items:
        key, sep, value = item.partition("=")
        if not sep:
            raise SystemExit(f"--set expects key=value, got {item!r}")
        sets[key.strip()] = value.strip()
    return sets


def _vec(text: str) -> list[float]:
    return [float(v) for v in text.split(",")]


def main(argv=None) -> int:
    ap = argparse.ArgumentParser(prog="makeit", description=__doc__)
    sub = ap.add_subparsers(dest="cmd", required=True)

    p = sub.add_parser("new", help="start projects/<name> from the template")
    p.add_argument("name")

    p = sub.add_parser("analyze", help="find planes, angles and gaps in a scan")
    p.add_argument("mesh")
    p.add_argument("--units", default="auto", choices=["auto", "m", "cm", "mm"])
    p.add_argument("--up", default="y", choices=["x", "y", "z"], help="up axis (iPhone/ARKit scans: y)")
    p.add_argument("--planes", type=int, default=6)
    p.add_argument("--threshold", type=float, default=2.0, help="plane tolerance, mm")
    p.add_argument("--json", help="also write the report here")

    p = sub.add_parser("section", help="cross-section a scan with a plane -> svg + csv")
    p.add_argument("mesh")
    p.add_argument("--origin", type=_vec, required=True, help="x,y,z in mm")
    p.add_argument("--normal", type=_vec, required=True, help="x,y,z")
    p.add_argument("--units", default="auto", choices=["auto", "m", "cm", "mm"])
    p.add_argument("--out", required=True, help="output prefix, e.g. projects/x/out/section")

    p = sub.add_parser("build", help="export STL/3MF + preview PNGs to <project>/out")
    p.add_argument("project")
    p.add_argument("--set", action="append", default=[], metavar="KEY=VALUE",
                   help='override a model parameter (OpenSCAD expression, strings quoted: name="\\"x\\"")')
    p.add_argument("--formats", default="stl,3mf")
    p.add_argument("--no-previews", action="store_true")
    p.add_argument("--tag", default="", help="suffix for output names, e.g. test-slice")

    args = ap.parse_args(argv)

    if args.cmd == "new":
        print(b.new_project(args.name))
    elif args.cmd == "analyze":
        report = scan.analyze(args.mesh, units=args.units, up=args.up,
                              max_planes=args.planes, threshold=args.threshold)
        print(scan.format_report(report))
        if args.json:
            os.makedirs(os.path.dirname(args.json) or ".", exist_ok=True)
            with open(args.json, "w") as f:
                json.dump(report, f, indent=2)
    elif args.cmd == "section":
        lines = scan.section(args.mesh, args.origin, args.normal, units=args.units, out_prefix=args.out)
        print(f"{len(lines)} polyline(s) -> {args.out}.svg / .csv")
    elif args.cmd == "build":
        result = b.build(args.project, _parse_sets(args.set),
                         formats=tuple(args.formats.split(",")),
                         previews=not args.no_previews, tag=args.tag)
        print(json.dumps(result, indent=2))
    return 0


if __name__ == "__main__":
    sys.exit(main())
