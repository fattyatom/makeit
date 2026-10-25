# Sink Drain

Page record: makeit artifact, part `p-mvmhaob9zbme` (the page is the source
of truth; this file mirrors it).

## What it's for
Cover the tiled window sill behind the sink and the step down from the sill
to the sink deck, so that water landing there all drains into the sink.
In the photo, green is the part that sits on the window sill, red is the
apron down to the sink, sloped toward the drainage point. Diagonals inside
each shape show the fall from the corners to the lowest point.

Design (v5; v4 made print-friendly, see the fit log):
- **Plate** (3 pieces, 210 mm each): ribbed cover on the sill, styled on
  `Sink_Drain_v3.stl`. Rib tops are level (0°) so things stand on them;
  the grooves fall 10 mm toward the sink. 8 mm nose with a 45° V drip
  groove, teardrop pin holes, end walls at the wall and mullion ends. Joins on rib centres with
  1.75 mm filament pins.
- **Channels** cover the whole 40 mm strip on both sides: back wall under
  the plate's nose, front wall just behind the bowl rim, and a flange over
  the rim. Floors fall 1.2° toward the spout. Closed ends at the wall and
  the mullion. Hollow underneath; printed upside down on their wall tops.
- **Left** (2 pieces, wall end and spout end) and **right** (1 piece,
  includes the collector and spout). Each join is spigot-in-socket: the
  upstream end narrows and sits inside the next piece above a 2.5 mm
  ridge, so water drops onto the next floor and never reaches the seam.
- **Spout**: left edge at 380 mm, 10.4 mm wide inside (13.6 outside, so it
  clears the tap at 395), reaches 100 mm out from the sill face beside the
  tap, falls 2°, clears the 3 mm rim.
- **Plinth** (2 halves, back and front, split through the tap centre so
  they can go on round the tap body): covers the tap base and the steel
  round it, from over the channel to 5 mm in front of and 10 mm right of
  the base. Top sits about at sill height, falls 3° toward the spout and
  1.5° toward the channel, and drips into both. Rests on the channel
  flange, the spout wall and the tap's base flange. The front half laps
  6 mm over the back half.

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
| spout position | 380 | user (round 4) | left edge of the spout, from the left wall |
| sill-to-deck drop | 30 | photo annotation | sill top down to the worktop strip, right end |
| wall to sink gap | 40 | user (round 2, 3) | sill face to bowl edge, flat steel, no fall |
| bowl rim height | 3 | user (round 3) | above the flat strip |
| corner rise | 10 | user | back corners above the drain point |
| sill face to tap base | 55 | user (round 4) | back of tap body ~60-61 |
| tap base diameter / height | 50 / 6 | user sketch | |
| tap body diameter / height | 43 / 100 | user sketch | |
| tap left edge from left wall | 395 | user (round 5) | tap centre at 420 |

## Constraints
- Printer / bed size: 255 x 255 x 255 (user)
- Material: PETG
- Sits loose (user). Must clear the tap.
- No water past the outer ends; cover the strip and surrounds as much as possible (user).

## Fit log
| Date | Version | Printed | Result / change |
|---|---|---|---|
| 2026-10-24 | v1 concept | not yet | Concept with guessed tap dims; right-plate test slice `print/sink-drain-v1-test-slice.stl` |
| 2026-10-24 | v1 | no | User: gap is 40 mm not 3 mm, spout >= 100 mm out, sill piece may look like Sink_Drain_v3.stl. v1 test slice withdrawn. |
| 2026-10-24 | v2 | not yet | Plate x3 + apron x2 released, test slice `print/sink-drain-v2-test-slice.stl`; gutter waits on tap measurements |
| 2026-10-24 | v3 | not yet | Full-width channels both sides into one spout, spigot joins, end walls, tap from sketch. Test slice `print/sink-drain-v3-test-slice.stl`. v2 files withdrawn. |
| 2026-10-25 | v4 | not yet | Spout narrowed (it ran 2 mm into the tap at 395); added the two-piece plinth round the tap base. v3 files withdrawn. |
| 2026-10-25 | v5 | not yet | Level rib tops (user: things must sit on the sill), V drip groove and teardrop pin holes so the plate has no overhangs. Channels unchanged: their floors print as bridges (36 mm, 10 mm at the spout). Four bed 3MFs + one with every piece (`beds.py`). v4 files withdrawn. |
