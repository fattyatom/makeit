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
| case_w | 21.0 | sketch note "210" | case thickness, across the sleeve (x). |
| case_h | 57.0 | photo note "570" | standing height (z). |
| case_l | 64.0 | photo note "640" | slide direction (y); the lanyard side goes to the back. |

Units: every number is in mm, read literally including the decimal point.
The notes are 57.0 / 64.0 / 21.0 with faint periods. The user confirmed
57 × 64 × 21 mm.
| case_edge_r | 5 | **PLACEHOLDER**, estimated from the photo | radius of the rounded edges round the case's faces. The bump position depends on it |
| back_band_h | 19 | sketch "19 mm" | back wall solid for the top 19 mm, open below |

## Design
- Desk plate 3 mm with four countersunk 4 mm screw holes on 12 mm ears, plus
  one in the ceiling between the fingers. 45° gussets brace the ears. The
  top is flat for hot glue.
- Walls 2.4 mm, floor 2 mm (it bridges 22 mm when printed upside down).
- Stopper (v3): the top 30 mm of each side wall continues past the floor
  as a 1.6 mm spring finger (22.7 mm to the hook). Each hook stands 2.5 mm
  into the cavity. A 45° retaining face sits behind the case's rounded
  front edge, 0.3 mm preloaded so it pulls the case to the back wall, and
  a 30° ramp faces the front for pushing in. Model estimate: ≈ 39 N to
  pull out, ≈ 22 N to push in, 0.9 % root strain. Set `hook_angle` lower
  for a softer pull (40° ≈ 32 N) or higher for a firmer one.
- Below the fingers the front of the case is open on both faces: pinch it
  and pull. You can also push it out from behind through the back
  opening.
- Clearance 0.5 mm per side in x and y, 0.6 mm in total over the height.

## Constraints
- Printer / bed size: Bambu Lab, 256 × 256 mm
- Material: PETG
- Print orientation: upside down (desk face on the bed), no supports

## Fit log
| Date | Version | Printed | Result / change |
|---|---|---|---|
| 2026-11-13 | v1 | – | First draft, case lying flat. Footprint 86.8 × 64.1 × 26.6 mm |
| 2026-11-13 | v2 | yes | User: the case should stand vertical. Sleeve now 21 mm wide and 57 mm tall, the back is open below a 19 mm band, ears braced with gussets. 50.8 × 68.0 × 62.6 mm |
| 2026-11-13 | v3 | – | User on v2: "retention clip doesn't really work, strength not enough". The round bumps (1 mm of travel, contact angle flattening to ~0) held only a few N. Replaced with 45° hooks, 2.5 mm deep (2 mm of travel): ≈ 39 N pull-out (estimate). 50.8 × 69.9 × 62.6 mm |
