# makeit

Describe a part, get a printable file. A phone scan, a sketch and a few hand
measurements go in. Claude writes a parametric OpenSCAD model and exports
STL/3MF, with previews to check before printing.

```
iPhone (LiDAR scan + photos)  ─┐
hand sketch + 2–4 measurements ├─► projects/<name>/inputs + brief.md
                               │
Claude session in this repo ◄──┘
  analyze scan → model.scad → build → look at previews → test slice → print/
```

## Start from your phone

The [makeit page](https://claude.ai/artifact/AaAurTgD9kAzqn1F95etpy) (source:
`artifact/makeit.html`) is the front door. Open it in the Claude app or on
claude.ai:

1. **New part**: name it, say what it's for, add the measurements, and
   attach photos, sketches or a scan (OBJ or ASCII PLY).
2. **Start design session** starts a Claude Code session on this repo. That
   session follows `.claude/skills/make-part/SKILL.md`: it reads the part
   from the page and models it, then posts previews and an STL download
   back to the page.
3. Answer Claude's questions, or send fit feedback ("1 mm tight at the
   left"), from the box on the part. It goes straight to the session.

The page needs the **Claude Code Remote** connector, which claude.ai
provides. It asks for your approval the first time it starts a session.

## How to use it by hand

1. **Capture** (about 5 minutes)
   - Scan the area with a LiDAR scanner app, e.g. *3D Scanner App* (free).
     Export **PLY or OBJ**. USDZ isn't supported.
   - Take a few photos with a ruler or card in frame for scale.
   - Measure by hand anything that has to fit to the millimetre: gaps, lips,
     hole spacing. LiDAR is about ±1 cm. For curved profiles, press a profile
     gauge or modelling clay into the shape and photograph it on grid paper.
   - Sketch the idea on paper and write numbers on it.
2. **Hand off.** Start a Claude Code session on this repo and say something
   like *"new part `shelf-clip`: here's the scan, sketch and measurements"*.
   Upload or commit the files into `projects/<name>/inputs/`. Claude fills
   in `brief.md`, asks for anything missing, models it and shows you
   previews.
3. **Test fit.** Print the short test slice Claude offers first, report back
   ("2 mm loose at the wall"), then print the full part from
   `projects/<name>/print/`.

## Commands

```bash
scripts/setup.sh                               # OpenSCAD, xvfb, Python deps
python -m makeit new <name>                    # projects/<name> from the template
python -m makeit analyze scan.ply              # planes, angles, gaps (mm)
python -m makeit section scan.ply --origin 0,0,0 --normal 1,0,0 --out out/sec
python -m makeit build projects/<name>         # out/model.stl, .3mf, previews
python -m makeit build projects/<name> --set test_slice=30 --tag test-slice
python -m pytest -q
```

Each model is plain OpenSCAD, so you can also open `model.scad` in OpenSCAD
and change values with its Customizer panel.

## Example

`projects/sink-gap-cover/` is a strip that sits on the sink's back rim,
keys into the gap with a tab, rises against the wall, and slopes so water
drains into the sink. Its measurements are placeholders until real ones go
into its `brief.md`.
