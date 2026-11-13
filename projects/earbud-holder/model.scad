// Under-desk holder for the Lenovo earbud case (the one with the braided
// USB-C lanyard). The case stands on edge in a tall, narrow sleeve hanging
// from the desk: a top plate with screw ears, two side walls, a back wall
// (solid for the top 19 mm, open below for the cable) and a floor the case
// stands on. The front is open. The upper part of each side wall carries
// on past the floor as a spring finger with a hook. The hooks' 45° faces
// catch behind the case's rounded front edge: it clicks in, stays put, and
// a deliberate pull (≈30 N) brings it out. v2 used round bumps, which held
// too weakly.
//
// Installed frame: x = across the sleeve (centred), y = into the holder
// (y=0 at the back face, the case slides in toward -y), z = up with z=0 at
// the underside of the desk (the part hangs below, z < 0).
//
// Prints upside down: the desk plate goes on the bed. Walls, fingers and
// hooks are straight vertical extrusions, 45° gussets brace the ears, the
// back opening's top is the floor, and the floor is a short wall-to-wall
// bridge. No supports.
use <../../lib/makeit.scad>

/* [Measured] */
case_w = 21.0;       // hand: sketch note "210" (mm, read as 21.0: see brief), case thickness (x)
case_h = 57.0;       // hand: photo note "570" (read as 57.0: see brief), standing height (z). Lanyard side faces the back.
case_l = 64.0;       // hand: photo note "640" (read as 64.0: see brief), slide direction (y)
case_edge_r = 5;     // PLACEHOLDER: radius of the rounded edges round the case's faces (from the photo)
back_band_h = 19;    // sketch: back wall solid for the top 19 mm, open below

/* [Design] */
clearance = 0.5;     // per side, x and y: the case should drop in, not press in
clearance_z = 0.6;   // total, over the height
plate_t = 3.0;       // desk plate (on the bed when printing)
wall = 2.4;          // side and back walls (6 perimeters at 0.4)
floor_t = 2.0;       // bridged floor
ear = 12;            // screw ear width beyond each side wall
ear_r = 4;           // ear corner radius
gusset_t = 3;        // 45° brace from each ear down its wall (0 = none)
floor_depth = 40;    // floor and walls run 0..floor_depth; fingers carry on past it
back_open_w = 14;    // opening below the band: cable out, or a finger to push the case out
finger_h = 30;       // spring finger height from the desk (includes the plate)
finger_t = 1.6;      // spring finger thickness (x)
hook_depth = 2.5;    // how far each hook stands into the cavity
hook_angle = 45;     // retaining face off the wall: 35 softer, 55 firmer, 90 locked
hook_entry = 30;     // entry ramp off the wall: lower = easier to push in
hook_preload = 0.3;  // hook sits this far back: pulls the case to the back wall
friction = 0.3;      // PETG on the case, for the force estimate only
petg_e = 2000;       // MPa, for the force estimate only
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
hi = case_h + clearance_z;            // inner height
y0 = wall;                            // inner back face
h_total = plate_t + hi + floor_t;
xo = wi / 2 + wall;                   // outer face of the side walls
xe = xo + ear;                        // ear tips
// Hook: its retaining face touches the case's rounded front edge when the
// case is fully in, against the back wall.
yh = hook_root_y(wi / 2, case_w / 2, case_edge_r, hook_angle, y0 + case_l) - hook_preload;
hook_tip_y = yh + hook_depth * cos(hook_angle) / sin(hook_angle);
y_end = hook_tip_y + 0.4 + hook_depth / tan(hook_entry);   // fingers end here
length = y_end;
plate_front_x = wi / 2 - hook_depth - finger_gap;
hole_ys = [y0 + 8, floor_depth - 8];
finger_len = yh - floor_depth;

// Pull-out estimate: each finger must bend out (hook_depth - clearance) to let
// the case pass; the 45° face turns that into a pull of F·tan(angle + friction).
finger_k = 3 * petg_e * (finger_h * pow(finger_t, 3) / 12) / pow(finger_len, 3);  // N/mm
finger_f = finger_k * (hook_depth - clearance);
pull_n = 2 * finger_f * tan(hook_angle + atan(friction));
push_n = 2 * finger_f * tan(hook_entry + atan(friction));
strain = 3 * finger_t * (hook_depth - clearance) / (2 * pow(finger_len, 2));

echo(str("holder ", 2 * xe, " x ", length, " x ", h_total, " mm; finger ", finger_len,
         " mm, ", finger_k, " N/mm; pull-out ≈ ", pull_n, " N, push-in ≈ ", push_n,
         " N; root strain ", strain * 100, " %"));

assert(hook_depth >= clearance + case_edge_r * (1 - cos(hook_angle)) + 0.3,
       "hook too shallow to catch the case's rounded edge");
assert(strain < 0.015, "fingers bend too far for PETG: make them longer or the hooks shallower");
assert(finger_len >= 15, "fingers too short to flex: lower floor_depth");
assert(floor_depth > y0 + case_l / 2 + 3, "floor must reach past the case's middle");
assert(back_band_h < hi, "back band taller than the cavity");
assert(back_open_w <= wi, "back opening wider than the cavity");
assert(finger_h >= plate_t + 10 && finger_h <= plate_t + hi, "finger_h out of range");
assert(2 * plate_front_x > screw_head_d + 2 || !front_screw, "no room for the front screw");

// Countersunk screw hole through the plate; the head sits on the underside.
module screw_hole(x, y) {
    translate([x, y, 0]) mirror([0, 0, 1]) cs_screw_hole(plate_t, screw_d, screw_head_d);
}

module body() {
    // Plate with ears, over the walled section only (fingers need free space).
    translate([0, 0, -plate_t]) linear_extrude(plate_t)
        rrect(-xe, 0, xe, floor_depth, ear_r);
    // Ceiling between the fingers, clear of the bumps.
    translate([0, 0, -plate_t]) linear_extrude(plate_t)
        rrect(-plate_front_x, floor_depth - 2, plate_front_x, y_end, 2);
    // 45° gussets under the ears, between the two screw holes.
    if (gusset_t > 0) for (s = [-1, 1]) mirror([s < 0 ? 1 : 0, 0, 0])
        translate([xo, (hole_ys[0] + hole_ys[1]) / 2, -plate_t]) mirror([0, 0, 1]) gusset45(ear - 1, gusset_t);
    // Side walls + floor + back wall as one U, full height.
    translate([0, 0, -h_total]) difference() {
        translate([-xo, 0, 0]) cube([2 * xo, floor_depth, h_total]);
        translate([-wi / 2, y0, floor_t]) cube([wi, floor_depth, hi + 1]);
    }
}

module fingers() {
    for (s = [-1, 1]) mirror([s < 0 ? 1 : 0, 0, 0])
        translate([0, 0, -finger_h]) linear_extrude(finger_h) {
            translate([wi / 2, floor_depth - 0.01]) square([finger_t, y_end - floor_depth + 0.01]);
            translate([wi / 2, 0]) hook2d(yh, hook_depth, hook_angle, hook_entry);
        }
}

module part() {
    difference() {
        union() { body(); fingers(); }
        // Back wall: solid band under the plate, open below it down to the floor.
        translate([-back_open_w / 2, -1, -plate_t - hi]) cube([back_open_w, y0 + 2, hi - back_band_h]);
        for (s = [-1, 1], y = hole_ys) screw_hole(s * (xo + ear / 2), y);
        if (front_screw) screw_hole(0, (floor_depth + y_end) / 2);
    }
}

// Desk underside and the earbud case (fully inserted), previews only.
module context() {
    translate([-xe - 20, -20, 0]) cube([2 * xe + 40, length + 40, 18]);
    color("dimgray") translate([0, 0, -plate_t - case_h - clearance_z / 2])
        linear_extrude(case_h) rrect(-case_w / 2, y0, case_w / 2, y0 + case_l, case_edge_r);
}

if (orient == "print") {
    // Upside down: desk face on the bed.
    rotate([180, 0, 0]) print_cut(length, test_slice, segments, segment) part();
} else {
    %print_cut(length, test_slice, segments, segment) context();
    print_cut(length, test_slice, segments, segment) part();
}
