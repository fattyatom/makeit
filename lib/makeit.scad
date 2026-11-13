// Shared helpers for makeit models. Use with: use <../../lib/makeit.scad>
// Conventions: millimetres; x/y/z of the *installed* part, z up.

// Keep only the part of children() with y in [y0, y1].
module keep_y(y0, y1, big = 2000) {
    intersection() {
        children();
        translate([-big / 2, y0, -big / 2]) cube([big, y1 - y0, big]);
    }
}

// Piece `index` (0-based) of `count` equal cuts along y, for parts longer
// than the print bed. index < 0 keeps the whole part.
module segment_y(length, count, index) {
    if (count <= 1 || index < 0) children();
    else keep_y(length / count * index, length / count * (index + 1)) children();
}

// Short test-fit slice from the y=0 end (0 = off), else the chosen segment.
// The build sets $section_at (0..1 along y) to render a thin cross-section
// for the profile view.
module print_cut(length, test_slice = 0, segments = 1, segment = -1) {
    if (!is_undef($section_at)) keep_y(length * $section_at, length * $section_at + 0.5) children();
    else if (test_slice > 0) keep_y(0, test_slice) children();
    else segment_y(length, segments, segment) children();
}

// ---- Shapes that keep coming back (2D unless noted) ----

// Rounded rectangle from corner (x0, y0) to (x1, y1).
module rrect(x0, y0, x1, y1, r) {
    r_ = min(r, (x1 - x0) / 2 - 0.01, (y1 - y0) / 2 - 0.01);
    translate([x0 + r_, y0 + r_]) offset(r_) square([x1 - x0 - 2 * r_, y1 - y0 - 2 * r_]);
}

// 3D: countersunk screw hole through a plate of thickness t lying on z=0..t,
// head at z=t. Subtract it. Defaults suit a 4 mm (#8) wood screw. Printed
// head-up, the cone opens upward, so it needs no support.
module cs_screw_hole(t, d = 4.2, head_d = 8.4, fn = 32) {
    translate([0, 0, -0.01]) cylinder(d = d, h = t + 0.02, $fn = fn);
    translate([0, 0, t - head_d / 2 + 0.01]) cylinder(d1 = 0, d2 = head_d, h = head_d / 2, $fn = fn * 1.5);
}

// 3D: 45° brace in the corner between a floor (z=0 up) and a wall face at
// x=0 (body at x<0), sticking out along +x, `leg` long, `t` thick along y
// (centred). It prints without support with the floor on the bed.
module gusset45(leg, t) {
    translate([-0.01, t / 2, -0.01]) rotate([90, 0, 0]) linear_extrude(t)
        polygon([[0, 0], [leg, 0], [0, leg]]);
}

// y position for a detent bump of radius rb standing `depth` into a channel
// so it touches a rounded corner (radius rc) of the part it holds.
// wall_x = the channel's inner wall (x), part_x = the part's side face (x),
// corner_y = y where the part's corner rounding starts (its end minus rc).
// Subtract a little preload so the bump pulls the part home.
function detent_y(wall_x, part_x, rc, rb, depth, corner_y) =
    let(xb = wall_x - depth + rb, ax = part_x - rc)
    corner_y + sqrt(pow(rc + rb, 2) - pow(xb - ax, 2));

// Hook detent (stronger than detent_y's round bump): a barb on a spring
// finger whose retaining face leans `angle` degrees off the channel wall
// (45 = firm click-out, 90 = locked). The face starts at the wall (x =
// wall_x) at the returned y and runs inward and forward, so it touches the
// part's corner arc (radius rc, side face at part_x, front at front_y).
// Pull-out force per finger ≈ finger force × tan(angle + friction angle),
// whatever rc really is. The hook must stand at least
// (wall_x - part_x) + rc * (1 - cos(angle)) into the channel to catch.
function hook_root_y(wall_x, part_x, rc, angle, front_y) =
    front_y - rc + rc * sin(angle) - ((wall_x - part_x) + rc * (1 - cos(angle))) * cos(angle) / sin(angle);

// 2D hook for a finger whose inner face is the line x = 0 (finger at x>0),
// facing -x. Retaining face from (0, y_root) leaning `angle` off the wall to
// the tip `depth` in; then an entry ramp at `entry` degrees back to the wall.
module hook2d(y_root, depth, angle, entry = 30) {
    tip_y = y_root + depth * cos(angle) / sin(angle);
    polygon([[0.01, y_root], [-depth, tip_y], [-depth, tip_y + 0.4],
             [0.01, tip_y + 0.4 + depth / tan(entry)]]);
}
