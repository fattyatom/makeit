# Sink Drain

Page record: makeit artifact, part `p-mvmhaob9zbme` (the page is the source
of truth; this file mirrors it).

## What it's for
Cover the tiled window sill behind the sink and the step down from the sill
to the sink deck, so that water landing there all drains into the sink.
In the photo, green is the part that sits on the window sill, red is the
apron down to the sink, sloped toward the drainage point. Diagonals inside
each shape show the fall from the corners to the lowest point.

Design (v2, from the user's round-2 answers):
- **Plate** (3 pieces, 210 mm each): ribbed cover on the sill, styled on
  `Sink_Drain_v3.stl`. Falls 10 mm from the window frame toward the sink
  (4.5°). Its 8 mm nose overhangs the sill edge and has a drip groove
  underneath. Joins land on rib centres, with 1.75 mm filament pins.
- **Apron** (2 pieces, 185 mm each): on the 40 mm strip from the left wall
  to the spout. Falls 5° toward the bowl, keys over the 3 mm rim and
  overhangs 10 mm into the left bowl. Its back upstand stops 1 mm under the
  plate's nose.
- **Gutter** (1 piece): a channel on the strip from the mullion to the
  spout. Falls 2° toward the spout, passes behind the tap, and turns into a
  spout centred 380 mm from the left wall that reaches 100 mm out over the
  left bowl (4° fall). Prints upside down on its wall tops. Waits on the
  tap measurements.

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
| left apron length | 350 | photo annotation | along the sink edge, left end to the tap (superseded by spout position) |
| spout position | 380 | user (round 3) | spout centre from the left wall, left of the tap |
| sill-to-deck drop | 30 | photo annotation | sill top down to the worktop strip, right end |
| wall to sink gap | 40 | user (round 2, 3) | sill face to bowl edge, flat steel, no fall |
| bowl rim height | 3 | user (round 3) | above the flat strip |
| corner rise | 10 | user | back corners above the drain point |
| tap centre from left wall | 420 | GUESS | to confirm |
| tap pillar diameter | 35 | GUESS | to confirm |
| tap base diameter / height | 55 / 8 | GUESS | to confirm |
| sill face to back of tap base | 22 | GUESS | the gutter needs at least 19.5 |

## Constraints
- Printer / bed size: 255 x 255 x 255 (user)
- Material: PETG
- Sits loose (user). Must clear the tap.

## Fit log
| Date | Version | Printed | Result / change |
|---|---|---|---|
| 2026-10-24 | v1 concept | not yet | Concept with guessed tap dims; right-plate test slice `print/sink-drain-v1-test-slice.stl` |
| 2026-10-24 | v1 | no | User: gap is 40 mm not 3 mm, spout >= 100 mm out, sill piece may look like Sink_Drain_v3.stl. v1 test slice withdrawn. |
| 2026-10-24 | v2 | not yet | Plate x3 + apron x2 released, test slice `print/sink-drain-v2-test-slice.stl`; gutter waits on tap measurements |
