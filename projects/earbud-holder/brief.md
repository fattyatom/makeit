# Earbud case under-desk holder

## What it's for
A tall, narrow sleeve screwed (or hot-glued) to the underside of the desk
that holds the Lenovo earbud case with the braided USB-C lanyard. The case
stands on edge (vertical), slides in from the front, and the cable leaves
through the opening in the back wall below a 19 mm solid band. A detent
(the "stopper") keeps the case from creeping out, and you can still pull it
out with one hand. It prints upside down in PETG with no supports.

## Inputs (in `inputs/`)
| File | What it is |
|---|---|
| `photo-and-sketch.jpg` | Top-down photo of the case with dimensions written on it, and a sketch of the holder (front/back views, 19 mm cable opening) |

## Measurements
| Name | Value (mm) | Source | Notes |
|---|---|---|---|
| case_w | 21.0 | sketch note "210" | case thickness, across the sleeve (x) |
| case_h | 57.0 | photo note "570" | standing height (z) |
| case_l | 64.0 | photo note "640" | slide direction (y); the lanyard side goes to the back |
| case_edge_r | 5 | **PLACEHOLDER**, estimated from the photo | radius of the rounded edges round the case's faces. The bump position depends on it |
| back_band_h | 19 | sketch "19 mm" | back wall solid for the top 19 mm, open below |

## Design
- Desk plate 3 mm with four countersunk 4 mm screw holes on 12 mm ears, plus
  one in the ceiling between the fingers. 45° gussets brace the ears. The
  top is flat for hot glue.
- Walls 2.4 mm, floor 2 mm (it bridges 22 mm when printed upside down).
- Stopper: the top 30 mm of each side wall continues past the floor as a
  1.6 mm spring finger (25 mm long). Each has a 3 mm radius bump that stands
  1.5 mm into the cavity and sits behind the case's rounded front edge,
  0.3 mm preloaded so it pushes the case against the back wall. Below the
  fingers the front of the case is open on both faces: pinch it and pull.
  You can also push it out from behind through the back opening.
- Clearance 0.5 mm per side in x and y, 0.6 mm in total over the thickness.

## Constraints
- Printer / bed size: Bambu Lab, 256 × 256 mm
- Material: PETG
- Print orientation: upside down (desk face on the bed), no supports

## Fit log
| Date | Version | Printed | Result / change |
|---|---|---|---|
| 2026-11-13 | v1 | – | First draft, case lying flat. Footprint 86.8 × 64.1 × 26.6 mm |
| 2026-11-13 | v2 | – | User: the case should stand vertical. Sleeve now 21 mm wide and 57 mm tall, the back is open below a 19 mm band, ears braced with gussets. 50.8 × 68.0 × 62.6 mm |
