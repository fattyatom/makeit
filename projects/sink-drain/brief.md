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
- Round 2 (proposal, awaiting answers): ribbed sill plate like
  `Sink_Drain_v3.stl`, grooves falling forward, nose dropping water into a
  separate gutter on the 40 mm strip that falls to the tap; spout into
  the left bowl.
- v1 pieces: left plate in 2 (350 mm > 255 mm bed), right plate in 1 (280 mm,
  diagonally on the bed). Filament pins (1.75 mm) align the joints.

## Inputs (in `inputs/`)
| File | What it is |
|---|---|
| `Sink_Drain_v3.stl` | User's reference for the sill piece: 155 x 145.5 x 22 ribbed plate, 9 ribs 10 mm with 10 mm grooves falling ~5° to a rounded nose; 26 x 9 mm recess under the nose |
| `IMG_0412.jpg` | Photo of sink, tap and sill with the part drawn on (green/red) and dimensions in purple; tape measure along the sill |

## Measurements
Hand measurements win over the scan. Note which is which.

| Name | Value (mm) | Source | Notes |
|---|---|---|---|
| sill length covered | 630 | photo annotation | back edge, left wall to the window mullion |
| sill depth | 120 | user (round 2) | window frame to sill front edge |
| spout reach | >= 100 | user (round 2) | spout outlet at least this far out from the sill front edge |
| left apron length | 350 | photo annotation | along the sink edge, left end to the tap |
| sill-to-deck drop | 30 | photo annotation | sill top down to the worktop strip, right end |
| wall to sink gap | 40 | user (round 2) | replaces the 3 mm; to confirm it's sill face to bowl edge, horizontal |
| "3 mm" | 3 | photo annotation | meaning unclear again (rim height?) |
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
| 2026-10-24 | v1 | no | User: gap is 40 mm not 3 mm, spout >= 100 mm out, sill piece may look like Sink_Drain_v3.stl. v1 test slice withdrawn. |
