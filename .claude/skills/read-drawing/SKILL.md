---
name: read-drawing
description: Turn a hand sketch or an annotated photo into dimensions, an orientation and a list of questions before modelling. Use whenever a part request comes with a drawing, a sketch, or a photo with numbers or arrows written on it.
---

# read-drawing: from a sketch to numbers you can model

Hand drawings are fast to make and easy to misread. Most lost iterations
come from reading the drawing wrong, not from bad CAD. Spend the time
here, before `model.scad`.

## 1. Pull out every number

- Write down each annotation with what it points at:
  `"570" → arrow across the photographed case, vertical`.
- **Every number is in mm, read literally, including its decimal point.**
  The user's rule: "assume everything in mm, unless you see a clear
  period". Zoom in on each number and look for a small or faint period:
  the earbud case's "57.0 / 64.0 / 21.0" read as "570 / 640 / 210" because
  the dots were hard to see.
- If a number can't be right for the object (×10 too big for a pocket
  case), suspect a missed period. **Ask** before modelling, with both
  readings, and record the answer in the brief. Never rescale quietly.
- Units written on the drawing ("19 mm") are mm too.
- A number next to a ↕ or ↔ symbol is a size along that axis of the
  drawn view, not necessarily along the part's x/y/z. Map it in step 2.

## 2. Fix the orientation from the drawing's proportions

v1 of `earbud-holder` held the case lying flat. The sketch showed a sleeve
**taller than it was wide**, which meant the case stood on edge. Proportions
in a sketch are intent even when no number says so:

- Compare the drawn box's height to its width. If the ratio fits one way
  of placing the object (57:21 standing, not 21:57 lying), use that one.
- Labels such as FRONT, BACK and TOP name the views. A view's open side
  is usually the way the object goes in.
- Look for where the object attaches (a desk, a wall, a rail) and which
  face is drawn against it.

Write the orientation in the restatement as a sentence the user can
check: "the case stands on its 21 mm edge and slides in front to back,
lanyard first". **Then ask**, in the same message as the missing
measurements. One wrong orientation costs a whole round.

## 3. Read features as functions, then size them

For every drawn feature, say what it is for: an opening for the cable,
flanges for screws, hatching for solid wall. A dimension on a feature
("19 mm" by the back opening) may be the feature's size **or** the
material around it. Pick the reading that lets the function work (the
cable must fit through), record the alternative in the brief, and ask.

## 4. List what the drawing doesn't say

The usual gaps for a holder, clip or mount:

| Gap | Why it matters | Default if the user says "go ahead" |
|---|---|---|
| Edge and corner radii of the held object | Detent and snap positions sit on them | Estimate from the photo and mark it PLACEHOLDER |
| Which face carries the cable or button | Openings and orientation | Ask |
| Fixing (screw size, glue, tape) | Hole size, plate thickness | 4 mm wood screw, countersunk; flat top for glue |
| Surface it mounts on (desk thickness, wall material) | Screw length, gussets | Not modelled |
| Material and bed | Clearances, wall thickness | From the brief or `CLAUDE.md` defaults |

Put every value you chose into the brief's measurement table, with the
source "estimated from photo" or "default" and **PLACEHOLDER** in bold, so
the next round knows what to confirm.

## 5. Before you show anything

Compare the `profile` and `iso` previews with the sketch's own views. The
silhouettes should match: tall or flat, open side, where the flanges are.
If they don't, the reading is wrong, not the sketch.
