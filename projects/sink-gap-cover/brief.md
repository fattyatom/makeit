# Sink-to-wall gap cover

## What it's for
Water splashes into the gap between the back of the sink and the wall. A
cover should bridge the gap and slope so the water runs back into the sink,
with a lip against the wall so nothing gets behind it.

## Inputs (in `inputs/`)
| File | What it is |
|---|---|
| `scan.ply` | TODO: LiDAR scan of the sink back and wall |
| `sketch.jpg` | TODO: sketch of the profile |
| `rim-profile.jpg` | TODO: profile gauge / clay impression of the rim edge on grid paper |

## Measurements
All values in `model.scad` are **placeholders** until filled in here.

| Name | Value (mm) | Source | Notes |
|---|---|---|---|
| length | 600 (placeholder) | scan / tape | along the wall, across the rim |
| gap_left | 8 (placeholder) | calipers | wall to rim edge, left end |
| gap_right | 8 (placeholder) | calipers | wall to rim edge, right end |
| flat rim depth | ? | ruler | how much flat rim there is to rest on; limits `rim_overlap` |
| gap depth | ? | ruler / probe | limits `tab_depth` |

## Constraints
- Printer / bed size: TODO
- Material: PETG or ASA (wet, sometimes hot)
- Must not: stop the tap from swinging, or hide water pooling underneath

## Fit log
| Date | Version | Printed | Result / change |
|---|---|---|---|
