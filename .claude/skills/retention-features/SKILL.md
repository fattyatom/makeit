---
name: retention-features
description: Size printable retention features (spring-finger detents, snap bumps, stoppers) that hold an object in a holder yet let it out by hand. Use when a brief asks for a stopper, a click, a snap, "doesn't slide out", or "stays put but easy to remove".
---

# retention-features: hold it, but let go on purpose

A fixed lip only holds an object if the object can be lifted over it, and
then it rattles. For holders, use a **flexing finger with a bump** that
sits behind a rounded edge of the object. It clicks in, pulls the object
home, and lets go when you pull firmly.

## Spring-finger detent (used in `projects/earbud-holder`)

```
 wall ──────────┐ finger (free end)
                │╲ bump
 object ──────╮ │ ╯   ← bump sits on the object's corner arc
              ╰─┘
```

- **Finger** = a wall that carries on past the last fixed point (floor or
  back wall), anchored at one end. In a support-free print it must rise
  from the bed (see `support-free-print`), so cut its slots in the bed
  plate, not in a roof.
- **Bump** = a circle of radius `rb` (≈3 mm) extruded vertically, standing
  `depth` into the channel. Its centre sits behind the object's rounded
  corner: `detent_y(wall_x, part_x, rc, rb, depth, corner_y)` in
  `lib/makeit.scad`, minus 0.3 mm of preload so it pushes the object home.
- **Travel**: the finger deflects by `depth − clearance`. Aim for 0.8–1.2 mm.

### Size the finger

Cantilever force at the bump for deflection δ:

`F = 3·E·I·δ / L³`, with `I = h·t³/12`. For PETG take E ≈ 2000 MPa.

Strain at the root: `ε = 3·t·δ / (2·L²)`. Keep it under ~1% for PETG and
PLA, which survives repeated use.

| t (mm) | h (mm) | L (mm) | δ (mm) | F (N) | ε |
|---|---|---|---|---|---|
| 1.6 | 30 | 25 | 1.0 | ≈ 4 | 0.4% |
| 1.8 | 24 | 21 | 1.0 | ≈ 7.5 | 0.6% |
| 1.6 | 60 | 21 | 1.0 | ≈ 13 | 0.5% (too stiff: shorten h) |

3–8 N per finger feels like a definite click that still lets go with one
hand. If it is too stiff, make the finger shorter in height `h` (it only
needs to reach the object's edge), not thinner than 1.6 mm.

### Placement checks

- The bump must sit on the object's **real** corner radius. The radius is
  usually a PLACEHOLDER estimated from a photo, so tell the user it is the
  number to measure. If the radius is smaller than assumed, the object
  stops short on the bump and rocks.
- Leave part of the object reachable: open faces below or beside the
  fingers, or a window behind it, so it can be pinched or pushed out.
- The object's centre of mass must sit over the fixed floor, not between
  the fingers. Assert `floor_depth > back + length/2 + 3`.
- `assert` that the bump circle reaches the corner arc
  (`(rc + rb)² > (xb − ax)²`), or `detent_y` returns NaN.

## Other options, and when to use them

| Feature | Use when | Watch out |
|---|---|---|
| Friction (0 to −0.2 mm clearance) | A rigid object with flat sides, never removed | PETG creeps, so it loosens over months |
| Lip plus extra headroom | The object can tip up and out | It rattles by the lip height |
| Magnet pocket | A metal object, or one with room for a magnet | Pause the print to insert the magnet, or glue it in after |
| Spring finger (above) | Removed often, by hand | Needs the corner radius |
