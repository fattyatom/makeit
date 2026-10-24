# CLAUDE.md — makeit

Turn a phone scan, photos, a sketch and a few hand measurements into a
parametric OpenSCAD model and printable STL/3MF. You (Claude) are the CAD
operator: the code here gives you measurements and renders. The design
judgement is yours.

## Layout

- `projects/<name>/` — one folder per part: `brief.md` (the source of truth
  for intent + measurements), `inputs/` (scan, photos, sketches),
  `model.scad`, `out/` (generated, git-ignored), `print/` (committed
  release files)
- `templates/part/` — copied by `python -m makeit new <name>`
- `lib/makeit.scad` — shared helpers (`print_cut`, `segment_y`, `keep_y`)
- `makeit/` — Python CLI: `new`, `analyze`, `section`, `build`
- `artifact/makeit.html` — the makeit page (claude.ai artifact
  `https://claude.ai/artifact/AaAurTgD9kAzqn1F95etpy`) where the user files
  part requests. A session started from it follows
  `.claude/skills/make-part/SKILL.md`. Republish edits to that URL, and
  keep its field names in step with the skill.

Setup (the cloud session hook does this): `scripts/setup.sh`.
Tests: `python -m pytest -q`. Every change to `makeit/` or `lib/` ships a test.

## Workflow for a new part

1. **Read everything first.** `brief.md`, then each file in `inputs/`.
   Look at every photo and sketch. Restate the part in 2–3 lines and list
   any measurement that is missing. Ask the user for the missing ones
   **before** modelling. Never invent a critical dimension.
2. **Get numbers from the scan** (if there is one):
   `python -m makeit analyze projects/<name>/inputs/scan.ply --json projects/<name>/out/scan.json`
   iPhone/ARKit scans are in metres with **y up**. The tool converts to mm.
   Use it for layout (lengths, angles, whether walls are square, whether a
   gap tapers). Take cross-sections where the profile matters:
   `python -m makeit section projects/<name>/inputs/scan.ply --origin X,Y,Z --normal 1,0,0 --out projects/<name>/out/sec-x`
   Phone LiDAR is only good to roughly ±10 mm. **Hand measurements win**,
   and any disagreement over 3 mm goes to the user as a question.
3. **Model it.** `model.scad` follows the template:
   - all dimensions are named top-level parameters in mm, grouped
     `[Measured]` / `[Design]` / `[Print]`, and each measured value says its
     source in a comment (`// calipers, left end`)
   - `module part()` holds the geometry and `module context()` holds ghost
     surroundings for the previews (wall, sink, shelf...)
   - honour `orient`: `"installed"` for previews, `"print"` lies the part
     on the bed with no supports where possible
   - wrap the part in `print_cut(...)` so test slices and segments work
   - `assert()` the parameter combinations that can't be printed
4. **Build and look.**
   `python -m makeit build projects/<name>` writes `out/model.stl`,
   `out/model.3mf` and four previews: `iso`, `profile` (the cross-section
   at mid-length), `side` and `top`. **Read the PNGs** and check them
   against the sketch before you show the user anything. Check
   `print_orientation.size_mm` against the bed size in the brief. Any
   `openscad_messages` warning is a bug until proven otherwise.
5. **Test fit before the full print.** Offer a short slice first:
   `python -m makeit build projects/<name> --set test_slice=30 --tag test-slice`
6. **Iterate from feedback.** "1 mm tight at the left end" means change a
   parameter, rebuild and re-check. Add each round to the brief's fit log.
7. **Release.** Copy the files the user will print into
   `projects/<name>/print/` (e.g. `sink-gap-cover-v2.3mf`), commit, and
   tell them the path. In a cloud session they get files through git (or
   SendUserFile), so commit what they need.

## Design defaults (override in the brief)

- Fit clearance 0.3 mm per side. Minimum wall 1.2 mm (3 perimeters at a
  0.4 mm nozzle). Plates at least 2 mm.
- Wet, hot or outdoor parts: PETG or ASA. Dry indoor parts: PLA.
- Water-shedding surfaces: slope at least 3°, and nothing that pools.
- Parts longer than the bed: split with `segments`/`segment`. Say where the
  joins land.
- Keep geometry simple and parametric. Don't import the scan mesh as part
  geometry: it's too noisy. Measure from it, then model clean shapes.
