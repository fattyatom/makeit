---
name: retention-features
description: Size printable retention features (spring-finger detents, snap bumps, stoppers) that hold an object in a holder yet let it out by hand. Use when a brief asks for a stopper, a click, a snap, "doesn't slide out", or "stays put but easy to remove".
---

# retention-features: hold it, but let go on purpose

A fixed lip only holds an object if the object can be lifted over it, and
then it rattles. For holders, use a **flexing finger with a hook** that
sits behind a rounded edge of the object. It clicks in, pulls the object
home, and lets go when you pull firmly.

**Use a hook with an angled face, not a round bump.** `earbud-holder` v2
had round bumps (r 3 mm, 1 mm of travel) on 4 N/mm fingers. In use they
"didn't hold it securely". A round bump against a rounded edge meets it at
a contact angle that flattens just as the finger bends most, so the pull
needed peaks at only a few N. A flat 45° face keeps the same angle all the
way out. v3 has hooks with 2 mm of travel and a 45° face, on the same
fingers: about 40 N to pull out.

## Spring-finger hook (used in `projects/earbud-holder` v3)

```
 wall ─────────────┐ finger
                   │  ╲   ← entry ramp (30°): the object pushes it aside going in
 object ─────╮    ╱│      ← retaining face (45°): touches the object's corner arc
             ╰───╱ │
```

- **Finger** = a wall that carries on past the last fixed point (floor or
  back wall), anchored at one end. In a support-free print it must rise
  from the bed (see `support-free-print`), so cut its slots in the bed
  plate, not in a roof.
- **Hook** = `hook2d(y_root, depth, angle, entry)` extruded vertically
  (`lib/makeit.scad`). Place it with `hook_root_y(wall_x, part_x, rc,
  angle, front_y)`, minus 0.3 mm of preload so it pulls the object home.
  The retaining face is tangent to the object's corner arc at `angle`, so
  the holding force barely depends on the real radius. If the radius is
  off, the case is either preloaded harder or has up to ~1 mm of play.
- **Depth**: at least `clearance + rc·(1 − cos angle) + 0.3` so the face,
  not its tip, meets the arc. 2.5 mm suits radii up to ~6 mm at 45°.
- **Travel**: the finger deflects by `depth − clearance`, usually 1.5–2 mm.
- **Forces** (write them as an `echo` in the model, as earbud-holder does):
  pull-out ≈ `2 · k · travel · tan(angle + atan μ)`, push-in ≈ the same
  with the entry angle. Take μ ≈ 0.3 for PETG. **Aim for 25–40 N to pull
  out** and under ~25 N to push in. Tune the angle first (35° softer,
  55° firmer, 90° locked, which then needs a release tab), the finger
  stiffness second.
- `detent_y` (round bump) is still in the lib, but use it only for a
  light click.

### Size the finger

Cantilever force at the bump for deflection δ:

`F = 3·E·I·δ / L³`, with `I = h·t³/12`. For PETG take E ≈ 2000 MPa.

Strain at the root: `ε = 3·t·δ / (2·L²)`. Keep it under ~1% for PETG and
PLA, which survives repeated use.

| t (mm) | h (mm) | L (mm) | δ (mm) | F (N) | ε |
|---|---|---|---|---|---|
| 1.6 | 30 | 25 | 1.0 | ≈ 4 | 0.4% |
| 1.6 | 30 | 22.7 | 2.0 | ≈ 10.5 | 0.9% (earbud-holder v3: ≈ 39 N pull-out with 45° hooks) |
| 1.8 | 24 | 21 | 1.0 | ≈ 7.5 | 0.6% |
| 1.6 | 60 | 21 | 1.0 | ≈ 13 | 0.5% (too stiff: shorten h) |

The finger force alone is not the holding force: the hook angle multiplies
it (×1.9 at 45° with friction). If it is too stiff, make the finger shorter
in height `h` (it only needs to reach the object's edge), not thinner than
1.6 mm.

### Placement checks

- The corner radius is usually a PLACEHOLDER estimated from a photo. A
  hook tolerates a wrong value. A round bump doesn't: the object stops
  short on it and rocks.
- Leave part of the object reachable: open faces below or beside the
  fingers, or a window behind it, so it can be pinched or pushed out.
- The object's centre of mass must sit over the fixed floor, not between
  the fingers. Assert `floor_depth > back + length/2 + 3`.
- `assert` the hook depth rule above and root strain under 1.5%, so a
  parameter change can't build a hook that misses or a finger that cracks.

## Other options, and when to use them

| Feature | Use when | Watch out |
|---|---|---|
| Friction (0 to −0.2 mm clearance) | A rigid object with flat sides, never removed | PETG creeps, so it loosens over months |
| Lip plus extra headroom | The object can tip up and out | It rattles by the lip height |
| Magnet pocket | A metal object, or one with room for a magnet | Pause the print to insert the magnet, or glue it in after |
| Spring finger + hook (above) | Removed often, by hand | Check the pull-out estimate, then test-print |
