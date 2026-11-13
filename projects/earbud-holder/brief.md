# Earbud case under-desk holder

## What it's for
A sleeve screwed (or hot-glued) to the underside of the desk that holds the
Lenovo earbud case with the braided USB-C lanyard. The case slides in from
the front and the cable leaves through a window in the back wall. A detent
(the "stopper") keeps the case from creeping out, and you can still pull it
out with one hand. It prints upside down in PETG with no supports.

## Inputs (in `inputs/`)
| File | What it is |
|---|---|
| `photo-and-sketch.jpg` | Top-down photo of the case with dimensions written on it, and a sketch of the holder (front/back views, 19 mm cable opening) |

## Measurements
| Name | Value (mm) | Source | Notes |
|---|---|---|---|
| case_w | 57.0 | photo note "570" | across the holder (x) |
| case_l | 64.0 | photo note "640" | slide direction (y); the lanyard side goes to the back |
| case_t | 21.0 | sketch note "210" | thickness |
| case_corner_r | 10 | **PLACEHOLDER**, estimated from the photo | plan-view corner radius. The bump position depends on it |
| cable_window_h | 19 | sketch "19 mm" | read as the height of the back opening, from the floor up |

## Design
- Desk plate 3 mm with four countersunk 4 mm screw holes on 12 mm ears, plus
  one in the ceiling between the fingers. The top is flat for hot glue.
- Walls 2.4 mm, floor 2 mm (it bridges 58 mm when printed upside down).
- Stopper: the side walls continue past the floor as 1.8 mm spring fingers
  (21 mm long). Each has a 3 mm radius bump that stands 1.5 mm into the
  cavity and sits behind the case's rounded front corner, 0.3 mm preloaded
  so it pushes the case against the back wall. Pull firmly to get the case
  out. You can also push it out from behind through the cable window.
- Clearance 0.5 mm per side in x and y, 0.6 mm in total over the thickness.

## Constraints
- Printer / bed size: Bambu Lab, 256 × 256 mm
- Material: PETG
- Print orientation: upside down (desk face on the bed), no supports

## Fit log
| Date | Version | Printed | Result / change |
|---|---|---|---|
| 2026-11-13 | v1 | – | First draft. Footprint 86.8 × 64.1 × 26.6 mm, 27.8 cm³ |
