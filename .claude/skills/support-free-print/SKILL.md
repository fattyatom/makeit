---
name: support-free-print
description: Design rules and ready patterns for FDM parts that print with no supports: choosing the bed face, bridges vs cantilevers, 45° gussets, holes, windows and slots. Use when modelling any part for printing, especially when the user asks for "no supports", "print upside down", or a mount, holder, bracket or enclosure.
---

# support-free-print: shape the part so the slicer has nothing to hold up

Work in the **print** frame (what `orient = "print"` produces), not the
installed one. After each build, look at `out/model-bed.png`: it shows the
exported part as it sits on the bed. For a part that hangs under something,
the standard `iso` view looks down through the ghost desk or shelf, and
`bed` is the clearest view of its underside.

## Pick the bed face first

- The biggest flat face that everything else grows from: a mounting plate,
  a back, a base.
- A part that hangs from something (under a desk, under a shelf) prints
  **upside down**: the mounting plate goes on the bed. `rotate([180,0,0])`
  in the `orient == "print"` branch; with z=0 at the mounting face and the
  part at z<0, it lands at z=0..h.
- Holes for screws go through that plate. Countersinks then open upward
  (`cs_screw_hole`, mirrored for installed previews) and need nothing.

## What prints and what doesn't

| Feature (in the print frame) | OK? | Notes |
|---|---|---|
| Anything that is a straight extrusion up from the bed: walls, ribs, fingers, bumps whose axis is vertical | ✅ | Prefer this form for every detail you can |
| Slopes ≥ 45° from horizontal | ✅ | `gusset45` for braces; chamfer instead of fillet underneath |
| **Bridge**: a flat roof held at **both** ends (a floor between two walls, the top of a window) | ✅ | PETG ≤ ~60 mm, best ≤ 30 mm. Span the short direction. Ask for `thick_bridges=1` |
| **Cantilever**: a flat roof held at one end (a lip, a tongue, a shelf) | ❌ | Turn it into a 45° chamfer, or make it a bridge, or rotate the part |
| A notch or cutout **in** a bridged roof | ❌ | It turns the lines through it into cantilevers. Move the opening into a wall |
| A window in a vertical wall | ✅ | Its top is a short bridge, or the roof itself |
| A slot that separates a feature from the bed plate around it | ✅ | Gap ≥ 0.6 mm; the feature must still start at z=0 |
| A feature that starts above the bed with nothing under it | ❌ | Extend it down to the bed and cut a clearance slot around it |

## Patterns that worked

- **Sleeve / holder printed upside down** (`projects/earbud-holder`): plate
  with ears on the bed, U of side walls + back wall straight up, floor as
  the last 2 mm bridging wall to wall. Make the held object stand so the
  floor span is its short side (22 mm, not 58 mm).
- **Ear braces**: `gusset45(ear - 1, 3)` under each ear, between the screw
  holes, so a screwdriver still reaches the heads.
- **Openings for cables or fingers**: cut them in a wall, from the roof
  down (the roof bridges over the opening), never into the roof.

## Before you hand it over

1. `model-bed.png`: no face hangs in the air apart from bridges you meant.
2. Every bridge: held at both ends, under ~60 mm in PETG (~80 mm PLA).
3. Thin walls ≥ 1.2 mm, plates ≥ 2 mm (`CLAUDE.md`). Springs may go to
   1.6 mm.
4. Export with `python -m makeit bambu out/model.stl print/<slug>-vN.3mf
   --name <slug>-vN --set enable_support=0 --set thick_bridges=1
   --set wall_loops=4`. Tell the user Bambu Studio may ignore
   per-object settings in a file it didn't write, and list them in your reply.
