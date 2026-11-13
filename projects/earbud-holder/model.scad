// Under-desk holder for the Lenovo earbud case (the one with the braided
// USB-C lanyard). A sleeve hangs from the desk: a top plate with screw ears,
// two side walls, a back wall with a cable window and a floor the case
// sits on. The front is open. Two spring fingers carry on past the floor
// with a bump each. The bumps click in behind the case's rounded front
// corners, so the case can't creep out, and a firm pull pops it free.
//
// Installed frame: x = across the desk edge (centred), y = into the holder
// (y=0 at the back face, the case slides in toward -y), z = up with z=0 at
// the underside of the desk (the part hangs below, z < 0).
//
// Prints upside down: the desk plate goes on the bed. Walls, fingers and
// bumps are straight vertical extrusions, the cable window's top is the
// floor, and the floor is a wall-to-wall bridge. No supports.
use <../../lib/makeit.scad>

/* [Measured] */
case_w = 57.0;       // hand: photo note "570" (across, x). Lanyard side faces the back.
case_l = 64.0;       // hand: photo note "640" (slide direction, y)
case_t = 21.0;       // hand: sketch note "210" (thickness, z)
case_corner_r = 10;  // PLACEHOLDER: plan-view corner radius, estimated from the photo
cable_window_h = 19; // sketch: "19 mm" opening in the back wall

/* [Design] */
clearance = 0.5;     // per side, x and y: a case should drop in, not press in
clearance_z = 0.6;   // total, over the thickness
plate_t = 3.0;       // desk plate (on the bed when printing)
wall = 2.4;          // side and back walls (6 perimeters at 0.4)
floor_t = 2.0;       // bridged floor
ear = 12;            // screw ear width beyond each side wall
ear_r = 4;           // ear corner radius
floor_depth = 40;    // floor and walls run 0..floor_depth; fingers carry on past it
cable_window_w = 14; // a USB-C plug passes through, or a finger to push the case out
cable_x = 0;         // window centre, from the middle
finger_t = 1.8;      // spring finger thickness (x)
detent_depth = 1.5;  // how far each bump stands into the cavity
detent_r = 3;        // bump radius (plan view)
detent_preload = 0.3;// bump sits this far behind the corner: pulls the case to the back
finger_gap = 0.8;    // slot between the fingers and the plate around them
screw_d = 4.2;       // clearance for a 4 mm (#8) wood screw
screw_head_d = 8.4;  // 90° countersink
front_screw = true;  // extra countersunk screw in the ceiling between the fingers

/* [Print] */
test_slice = 0;      // >0: only the back N mm (checks width/height fit)
segments = 1;
segment = -1;
orient = "installed";

// Derived
wi = case_w + 2 * clearance;          // inner width
hi = case_t + clearance_z;            // inner height
y0 = wall;                            // inner back face
h_total = plate_t + hi + floor_t;
xo = wi / 2 + wall;                   // outer face of the side walls
xe = xo + ear;                        // ear tips
// Bump centre: a circle of radius detent_r standing detent_depth into the
// cavity, touching the case's front corner arc when the case is fully in.
xb = wi / 2 - detent_depth + detent_r;
arc_x = case_w / 2 - case_corner_r;
arc_y = y0 + case_l - case_corner_r;
yb = arc_y + sqrt(pow(case_corner_r + detent_r, 2) - pow(xb - arc_x, 2)) - detent_preload;
y_end = yb + detent_r;                // fingers end here
length = y_end;
plate_front_x = wi / 2 - detent_depth - finger_gap;
hole_ys = [y0 + 8, floor_depth - 8];
finger_len = yb - floor_depth;

echo(str("holder ", 2 * xe, " x ", length, " x ", h_total, " mm; finger ", finger_len,
         " mm; case sticks out ", y0 + case_l - y_end, " mm past the fingers"));

assert(pow(case_corner_r + detent_r, 2) > pow(xb - arc_x, 2), "bump misses the corner arc");
assert(finger_len >= 15, "fingers too short to flex: lower floor_depth");
assert(floor_depth > y0 + case_l / 2 + 3, "floor must reach past the case's middle");
assert(cable_window_h <= hi, "cable window taller than the cavity");
assert(detent_depth > clearance + 0.5, "bumps would not touch the case");
assert(xb - detent_r < wi / 2 + finger_t, "bump detached from its finger");

module rrect(x0, y0_, x1, y1, r) {
    translate([x0 + r, y0_ + r]) offset(r) square([x1 - x0 - 2 * r, y1 - y0_ - 2 * r]);
}

// Countersunk screw hole through the plate; the head sits on the cavity side.
module screw_hole(x, y) {
    translate([x, y, -plate_t - 0.01]) {
        cylinder(d = screw_d, h = plate_t + 0.02, $fn = 32);
        cylinder(d1 = screw_head_d, d2 = 0, h = screw_head_d / 2, $fn = 48);
    }
}

module body() {
    // Plate with ears, over the walled section only (fingers need free space).
    translate([0, 0, -plate_t]) linear_extrude(plate_t)
        rrect(-xe, 0, xe, floor_depth, ear_r);
    // Ceiling between the fingers, clear of the bumps.
    translate([0, 0, -plate_t]) linear_extrude(plate_t)
        rrect(-plate_front_x, floor_depth - 2, plate_front_x, y_end, 2);
    // Side walls + floor + back wall as one U, full height.
    translate([0, 0, -h_total]) difference() {
        translate([-xo, 0, 0]) cube([2 * xo, floor_depth, h_total]);
        translate([-wi / 2, y0, floor_t]) cube([wi, floor_depth, hi + 1]);
    }
}

module fingers() {
    for (s = [-1, 1]) mirror([s < 0 ? 1 : 0, 0, 0])
        translate([0, 0, -plate_t - hi]) linear_extrude(plate_t + hi) {
            translate([wi / 2, floor_depth - 0.01]) square([finger_t, y_end - floor_depth + 0.01]);
            intersection() {
                translate([xb, yb]) circle(r = detent_r, $fn = 48);
                translate([0, floor_depth]) square([wi / 2 + finger_t, y_end]);
            }
        }
}

module part() {
    difference() {
        union() { body(); fingers(); }
        // Cable window in the back wall, from the floor up.
        translate([cable_x - cable_window_w / 2, -1, -plate_t - hi]) cube([cable_window_w, y0 + 2, cable_window_h]);
        for (s = [-1, 1], y = hole_ys) screw_hole(s * (xo + ear / 2), y);
        if (front_screw) screw_hole(0, (floor_depth + y_end) / 2);
    }
}

// Desk underside and the earbud case (fully inserted), previews only.
module context() {
    translate([-xe - 20, -20, 0]) cube([2 * xe + 40, length + 40, 18]);
    color("dimgray") translate([0, 0, -plate_t - case_t - clearance_z / 2])
        linear_extrude(case_t) rrect(-case_w / 2, y0, case_w / 2, y0 + case_l, case_corner_r);
}

if (orient == "print") {
    // Upside down: desk face on the bed.
    rotate([180, 0, 0]) print_cut(length, test_slice, segments, segment) part();
} else {
    %print_cut(length, test_slice, segments, segment) context();
    print_cut(length, test_slice, segments, segment) part();
}
