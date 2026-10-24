# Sink Drain

Page record: makeit artifact, part `p-mvmhaob9zbme` (the page is the source
of truth; this file mirrors it).

## What it's for
Cover the tiled window sill behind the sink and the step down from the sill
to the sink deck, so that water landing there all drains into the sink.
In the photo, green is the part that sits on the window sill, red is the
apron down to the sink, sloped toward the drainage point. Diagonals inside
each shape show the fall from the corners to the lowest point.

Design (confirmed with the user, round 1):
- Two plates, one each side of the tap, sitting loose on the sill. They
  meet behind the tap. The right plate starts at the tap.
- Each plate falls to a drain point at its front edge behind the tap. The
  back corners (and the far front corner) are 10 mm higher.
- A spout on the left plate carries all the water past the tap into the
  left bowl. Its outlet is 110 mm out from the sill.
- Pieces: left plate in 2 (350 mm > 255 mm bed), right plate in 1 (280 mm,
  diagonally on the bed). Filament pins (1.75 mm) align the joints.

## Inputs (in `inputs/`)
| File | What it is |
|---|---|
| `IMG_0412.jpg` | Photo of sink, tap and sill with the part drawn on (green/red) and dimensions in purple; tape measure along the sill |

## Measurements
Hand measurements win over the scan. Note which is which.

| Name | Value (mm) | Source | Notes |
|---|---|---|---|
| sill length covered | 630 | photo annotation | back edge, left wall to the window mullion |
| sill depth, right end | 120 | photo annotation | window frame to sill front edge |
| spout reach | 110 | user | spout outlet this far out from the sill front |
| left apron length | 350 | photo annotation | along the sink edge, left end to the tap |
| sill-to-deck drop | 30 | photo annotation | sill top down to the worktop strip, right end |
| sill face to steel rim | 3 | photo annotation + user | the gap the skirt covers |
| corner rise | 10 | user | back corners above the drain point |
| tap pillar diameter | 35 | GUESS | to confirm |
| tap base diameter / height | 55 / 8 | GUESS | to confirm |
| sill face to tap base edge | 5 | GUESS | to confirm |
| junction to tap centre | 18 | GUESS | junction at the pillar's left edge |

## Constraints
- Printer / bed size: 255 x 255 x 255 (user)
- Material: PETG
- Sits loose (user). Must clear the tap.

## Fit log
| Date | Version | Printed | Result / change |
|---|---|---|---|
| 2026-10-24 | v1 concept | not yet | Concept with guessed tap dims; right-plate test slice `print/sink-drain-v1-test-slice.stl` |
