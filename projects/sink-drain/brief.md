# Sink Drain

Page record: makeit artifact, part `p-mvmhaob9zbme` (the page is the source
of truth; this file mirrors it).

## What it's for
Cover the tiled window sill behind the sink and the step down from the sill
to the sink deck, so that water landing there all drains into the sink.
In the photo, green is the part that sits on the window sill, red is the
apron down to the sink, sloped toward the drainage point. Diagonals inside
each shape show the fall from the corners to the lowest point.

Design (v9: left and right aprons share one profile; 8 pieces on 4 beds):
- **Plate** (3 pieces, 210 mm each): ribbed cover on the sill, styled on
  `Sink_Drain_v3.stl`. Rib tops level (0°) so things stand on them; grooves
  fall 10 mm toward the sink. 8 mm nose with a 60° V drip groove, end walls
  at the wall and mullion. Joins just butt (no pins).
- **Apron profile** (left and right): back upstand 1 mm under the plate's
  nose; a 10 mm gutter under the plate's drip line; a 1.6 mm ridge 3 mm
  above the gutter floor; the rest slopes 8° toward the sink and overhangs
  the bowl edge by 3 mm, its underside lifting over the rim at 60°. Solid,
  prints flat with no overhangs.
- **Left aprons** (2 pieces, 190 mm each): gutters fall 3.5° (was 1.5°).
  The wall-end piece's gutter is dammed at the joint and empties onto the
  front slope through a 30 mm gap in its ridge; the spout-end piece's gutter
  starts again at the joint and laps a tongue into the collector. The front
  slope is continuous across the joint.
- **Right piece** (1): same profile from the mullion to the spout; its
  gutter falls 5.1° to the collector. Under the plinth the whole top falls
  back into the gutter instead. Collector open on the left for the apron's
  tongue (floor rises 0.5 mm to that edge). Spout: left edge at 380 mm,
  10.4 mm wide inside, reaches 100 mm out beside the tap, floor falls 1.5°;
  solid to the bed except a 60°-sided notch over the rim (10 mm bridge).
  Prints flat, turned 36° on its bed.
- **Plinth** (2 halves, back and front, split through the tap centre so
  they go on round the tap body): covers the tap base and the steel round
  it. Top falls toward the spout and the sill; rests on the spout's right
  wall and the tap's base flange and drips into the spout and onto the right
  piece. The front half laps 6 mm over the back half.

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
- Material: PETG. Filament: 240 °C (245 first layer), bed 75 °C textured PEI (glue on smooth),
  fan 30-40 %, bridges/overhangs 90 %, max 12 mm³/s, dry if opened.
  Process (written per object into the 3MFs): 0.2 mm layers, 3 walls, 5/4 top/bottom, 15 % gyroid,
  no supports; 3 mm brim on aprons and plinth, 5 mm brim + thick bridges at 25 mm/s (rim notch) on the right piece.
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
| 2026-10-25 | v6 | not yet | Simplified (option B): left channels and spigot joins replaced by two forward-falling aprons into the bowl, plate pins dropped, collector closed on the left. Plinth kept in two halves. v5 files withdrawn. |
| 2026-10-26 | v7 | not yet | User saw an overhang on the left bottom piece: apron underside lift and plate drip groove steepened from 45° to 60°; nothing in the plate, aprons or plinth now faces down more than 33° from vertical. `all-beds` 3MF is now a Bambu Studio / Orca project with one plate per bed. v6 files withdrawn. |
| 2026-10-26 | v7 | not yet | PETG settings added to the 3MFs: per-object process overrides, filament settings in the project description. Bed 4 turned 57° so the right piece fits with its brim. |
| 2026-10-26 | v7 | test slice | Plate slice fits the sill. Apron base width right, but tipping water forward over the rim didn't work and left water in the gap. |
| 2026-10-26 | v8 | not yet | Aprons rebuilt: solid on the strip to the rim, gutter along the riser falling 1.5° to the spout, tongue laps at each join and into the collector (now open on the left). Test slice is the spout end: 30 mm of the apron and of the right piece. v7 files withdrawn. |
| 2026-10-26 | v9 | not yet | User: gutter too shallow; match left and right; gutter needn't take the whole width, the rest can slope into the sink over the edge. Common profile (gutter + ridge + 8° front slope overhanging 3 mm); left gutters 3.5°, wall-end piece empties forward through its ridge; right gutter 5.1°; right piece prints flat. Plinth lowered to rest on the spout wall. v8 files withdrawn. |
