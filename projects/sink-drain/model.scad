// Sink drain: loose-fitting pieces that send every drop from the window sill
// into the sink.
//   plate  - ribbed cover on the sill; level rib tops, grooves falling toward
//            the sink, drips off its nose just past the sill edge (3 pieces).
//   left   - apron on the 40 mm steel strip from the left wall to the spout;
//            falls forward and tips the drips over the rim into the left
//            bowl along its whole length (2 pieces).
//   right  - channel on the strip from the mullion to the spout, falling
//            toward it, plus the spout reaching out over the left bowl beside
//            the tap (1 piece).
//   plinth - cover round the tap base; drains into the spout and the channel
//            (2 halves, so they can go on round the tap body).
//
// Installed frame: x = toward the sink, x=0 at the sill's front face (the
// sill is at x<0); y = along the window from the left wall; z = up, z=0 on
// the sill top (the steel strip is at z=-riser_drop).
use <../../lib/makeit.scad>

/* [Measured] */
sill_length = 630;     // photo annotation: left wall to the window mullion
sill_depth = 120;      // user: window frame to the sill's front edge, both sides
riser_drop = 30;       // photo annotation: sill top down to the steel strip
strip_width = 40;      // user: sill front face to the bowl edge, flat steel
rim_h = 3;             // user: bowl rim height above the strip
spout_y = 380;         // user: left edge of the spout, from the left wall
spout_reach = 100;     // user: at least this far out from the sill face
tap_gap = 55;          // user: sill front face to the tap base
tap_base_d = 50;       // user sketch
tap_base_h = 6;        // user sketch
tap_body_d = 43;       // user sketch
tap_body_h = 100;      // user sketch
tap_y = 395 + 25;      // user: tap's left-most point 395 from the left wall

/* [Design] */
plate_rise = 10;       // user: back edge this much above the front
plate_min = 3;         // floor thickness at the nose
nose = 8;              // plate overhang past the sill edge
rib_count = 30;        // ribs along the plate (one more than this, ends included)
rib_fill = 0.5;        // rib width / pitch (reference STL: 10 mm ribs, 10 mm grooves)
rib_h = 4;             // above the groove floor at the back; rib tops are level
end_wall_h = 4;        // end walls at the outer ends, above the plate or apron top
drip_w = 2;            // groove under the nose so drips let go at the edge
drip_d = 1.2;
lift_angle = 60;       // apron underside and drip groove sides, from horizontal: no slicer overhang
wall_t = 1.6;
floor_t = 1.6;
apron_over = 6;        // apron front edge past the bowl edge
apron_t = 2;           // apron thickness at its front edge
apron_fall = 5;        // apron top, toward the bowl (°)
flange_over = 5;       // right channel's top flange reaches this far past the strip
flange_t = 2;
top_tilt = 2;          // channel wall tops and flange fall this much toward the sink (°)
gutter_fall = 1.2;     // right channel floor, toward the spout (°)
spout_fall = 2;        // spout floor, out over the bowl (°)
chan_w_spout = 10.4;   // spout inside width: fits between 380 and the tap at 395
rim_room = 0.5;        // clearance over the rim
tap_room = 1;          // clearance round the tap
plinth_right = 10;     // plinth reaches this far right of the tap base
plinth_front = 5;      // and this far in front of it
plinth_back = 36;      // back edge, over the channel so it drips in
plinth_t = 2;          // top plate
plinth_fall_y = 3;     // top falls toward the spout (°)
plinth_fall_x = 1.5;   // and toward the channel (°)
plinth_lip = 6;        // front half laps this far over the back half
hollow = true;         // pocket under the channel floor, open to the strip

/* [Print] */
piece = "all";         // "plate" | "left" | "right" | "plinth" | "all"
bed = 255;             // user: 255 x 255 x 255
diag_angle = 57;       // for pieces longer than the bed
plate_segments = 3;
clearance = 0.3;       // per side: off the riser, the wall, the mullion and between pieces
test_slice = 0;        // >0: only the first N mm of the piece
segment = -1;          // plate: which third; left: 0 = by the spout, 1 = by the wall;
                       // plinth: 0 = back half, 1 = front half; -1 = all
orient = "installed";  // "print": plate and aprons flat, channel and plinth upside down

z0 = -riser_drop;
big = 60;

// Plate
plate_len = sill_length - 2 * clearance;
xb = -(sill_depth - clearance);      // back edge, at the window frame
plate_fall = atan(plate_rise / (nose - xb));
function plate_top(x) = plate_min + (nose - x) * tan(plate_fall);
pitch = plate_len / rib_count;
// Rib tops are level (0°) so things stand on them; the grooves between still fall.
rib_top = plate_top(xb) + rib_h;

// Strip pieces share these x positions.
xg0 = clearance;                     // back face, against the riser
x_in = xg0 + wall_t;                 // inside of the back wall / upstand
xf1 = strip_width - clearance;       // channel front face, just behind the bowl rim
x_in2 = xf1 - wall_t;                // inside of the front wall
xfl = strip_width + flange_over;     // flange edge
// Every channel wall top lies on this plane, so the right piece prints
// upside down on it.
function top_z(x) = -1 - x * tan(top_tilt);

// Left aprons: underside flat on the strip, then lifts to clear the rim.
left_total = spout_y - 2 * clearance;
left_seg = (left_total - clearance) / 2;
xa1 = strip_width + apron_over;      // apron front edge, over the bowl
// Underside lifts at lift_angle from here, clearing the rim at the bowl edge.
xr0 = strip_width - (rim_h + rim_room) / tan(lift_angle);
apron_tf = z0 + (xa1 - xr0) * tan(lift_angle) + apron_t;
function apron_top(x) = apron_tf + (xa1 - x) * tan(apron_fall);

// Spout and collector (part of the right piece), local y from spout_y.
spout_w_out = chan_w_spout + 2 * wall_t;
function spout_floor(x) = fc - (x - x_in) * tan(spout_fall);
// Collector floor: low enough to fall into the spout, high enough that the
// spout's underside clears the rim a few mm past the bowl edge.
fc = z0 + rim_h + rim_room + floor_t + (strip_width + 5 - x_in) * tan(spout_fall);
right_len = sill_length - clearance - spout_y;
function chan_floor(f0, y) = f0 + y * tan(gutter_fall);

// Plinth round the tap, local y from its left edge (just inside the spout).
tap_x = tap_gap + tap_base_d / 2;
pl_y = spout_y + wall_t + chan_w_spout - 1;
pl_w = tap_y + tap_base_d / 2 + plinth_right - pl_y;
pl_x1 = tap_x + tap_base_d / 2 + plinth_front;
pl_tx = tan(plinth_fall_x);
pl_ty = tan(plinth_fall_y);
// Top plane: its back-left corner rests just clear of the channel flange
// and the spout wall.
pl_z0 = top_z(plinth_back) + plinth_t;
function plinth_top(x, y) = pl_z0 + y * pl_ty + (x - plinth_back) * pl_tx;
pl_hole = tap_body_d / 2 + 0.7;

assert(rib_count % plate_segments == 0, "plate joins must land on rib centres");
assert(nose + tap_room <= tap_gap && xfl + tap_room <= tap_gap, "channel or plate reaches the tap");
assert(spout_y + spout_w_out + tap_room <= tap_y - tap_base_d / 2, "spout hits the tap base");
assert(spout_reach > xfl + 10, "spout must reach past the bowl edge");
assert(spout_floor(strip_width + 5) - floor_t >= z0 + rim_h, "spout underside hits the rim");
assert(apron_top(x_in) <= -2, "apron upstand must stay under the plate's nose");

// Profile in (x, z), extruded along y from 0 to len.
module extrude_y(len) {
    translate([0, len, 0]) rotate([90, 0, 0]) linear_extrude(len) children();
}

module plate() {
    rw = pitch * rib_fill;
    ew = 2;
    difference() {
        union() {
            extrude_y(plate_len) polygon([[xb, 0], [nose, 0], [nose, plate_top(nose)], [xb, plate_top(xb)]]);
            // Ribs run toward the sink and stop at the sill edge, so the
            // grooves empty across the plain nose.
            intersection() {
                for (k = [1 : rib_count - 1]) translate([0, k * pitch - rw / 2, 0]) extrude_y(rw)
                    polygon([[xb, 0], [0, 0], [0, rib_top], [xb, rib_top]]);
                translate([xb - 1, 0, -1]) cube([nose - xb + 2, plate_len, 100]);
            }
            // End walls, so nothing runs off the ends.
            for (y = [0, plate_len - ew]) translate([0, y, 0]) extrude_y(ew) polygon([
                [xb, 0], [nose, 0], [nose, rib_top + end_wall_h], [xb, rib_top + end_wall_h]]);
        }
        // Drip groove: a V with sides at lift_angle, so its roof needs no bridging.
        gx = nose - 3 - drip_w / 2;
        translate([0, -1, 0]) extrude_y(plate_len + 2)
            polygon([[gx - (drip_d + 1) / tan(lift_angle), -1], [gx + (drip_d + 1) / tan(lift_angle), -1], [gx, drip_d]]);
    }
}

// Left apron in its own frame: y from 0 (spout end) to len. The upstand
// stops 1 mm under the plate's nose, which drips onto the apron in front of
// it; the top falls forward and the front edge overhangs the bowl. The wall
// end (seg 1) gets an end wall.
module apron(seg) {
    k = rim_h + rim_room;
    function prof(dz) = [[xg0, z0], [xr0, z0], [xa1, z0 + (xa1 - xr0) * tan(lift_angle)], [xa1, apron_tf + dz],
                         [x_in, apron_top(x_in) + dz], [x_in, -1], [xg0, -1]];
    extrude_y(left_seg) polygon(prof(0));
    if (seg == 1) translate([0, left_seg - 2, 0]) extrude_y(2) polygon(prof(end_wall_h));
}

// Below the channel's wall-top plane.
module under_top(len) {
    translate([0, -1, 0]) extrude_y(len + 2) polygon([
        [xg0 - 1, z0 - 1], [spout_reach + 1, z0 - 1],
        [spout_reach + 1, top_z(spout_reach + 1)], [xg0 - 1, top_z(xg0 - 1)]]);
}

module flange(len) {
    extrude_y(len) polygon([[xf1 - 1, top_z(xf1 - 1) - flange_t - 1], [xfl, top_z(xfl) - flange_t],
                            [xfl, top_z(xfl) + 1], [xf1 - 1, top_z(xf1 - 1) + 1]]);
}

// Right piece in its own frame: y from spout_y. Collector and spout at
// y < spout_w_out, then the channel out to the mullion, closed at both ends.
module right_piece() {
    cl = right_len - wall_t;             // inside end of the channel
    xs = (fc - floor_t + x_in * tan(spout_fall) - z0 + (xf1 - 4)) / (1 + tan(spout_fall));
    difference() {
        intersection() {
            union() {
                translate([xg0, 0, z0]) cube([xf1 - xg0, right_len, big]);
                flange(right_len);
                // Spout: stands on the strip, then lifts over the rim at 45°.
                extrude_y(spout_w_out) polygon([
                    [xg0, z0], [xf1 - 4, z0], [xs, spout_floor(xs) - floor_t],
                    [spout_reach, spout_floor(spout_reach) - floor_t], [spout_reach, big], [xg0, big]]);
            }
            under_top(right_len);
        }
        // Collector and channel, falling toward the spout.
        hull() {
            translate([x_in, wall_t, fc]) cube([x_in2 - x_in, spout_w_out - wall_t, big]);
            translate([x_in, cl - 0.01, chan_floor(fc, cl - spout_w_out)]) cube([x_in2 - x_in, 0.01, big]);
        }
        // Spout, falling out over the bowl.
        hull() {
            translate([x_in, wall_t, fc]) cube([0.01, chan_w_spout, big]);
            translate([spout_reach + 1, wall_t, spout_floor(spout_reach + 1)]) cube([0.01, chan_w_spout, big]);
        }
        // Pocket under the channel floor, open to the strip, leaving floor_t.
        if (hollow) hull() {
            y1 = spout_w_out + 2;
            y2 = cl - 2;
            translate([x_in, y1, z0 - 1]) cube([x_in2 - x_in, 0.01, chan_floor(fc, y1 - spout_w_out) - floor_t - z0 + 1]);
            translate([x_in, y2, z0 - 1]) cube([x_in2 - x_in, 0.01, chan_floor(fc, y2 - spout_w_out) - floor_t - z0 + 1]);
        }
    }
}

// Region from the steel up to the plinth plane, over a rectangle in the
// plinth's frame.
module under_plinth(x0, x1, y0, y1, dz = 0, zb = z0) {
    polyhedron(
        points = [[x0, y0, zb], [x1, y0, zb], [x1, y1, zb], [x0, y1, zb],
                  [x0, y0, plinth_top(x0, y0) + dz], [x1, y0, plinth_top(x1, y0) + dz],
                  [x1, y1, plinth_top(x1, y1) + dz], [x0, y1, plinth_top(x0, y1) + dz]],
        faces = [[0, 1, 2, 3], [4, 7, 6, 5], [0, 4, 5, 1], [1, 5, 6, 2], [2, 6, 7, 3], [3, 7, 4, 0]]);
}

// One half of the plinth round the tap (a one-piece ring can't pass the
// tap's neck). It rests on the channel flange, the spout wall and the tap's
// base flange, and drains off its back-left corner into the spout and the
// channel. Back half: x up to the tap centre. Front half: sits 0.3 mm higher
// and laps over the back half.
module plinth_half(half) {
    dz = half == 1 ? plinth_t + clearance : 0;
    xa = half == 0 ? plinth_back : tap_x - plinth_lip;
    xm = half == 0 ? tap_x : pl_x1;
    ty = tap_y - pl_y;
    ds = dz - 0.05;   // skirts and ring sit 0.05 mm into the plate: one clean solid
    difference() {
        union() {
            difference() {
                under_plinth(xa, xm, 0, pl_w, dz);
                translate([0, 0, -plinth_t]) under_plinth(xa - 1, xm + 1, -1, pl_w + 1, dz, z0 - plinth_t - 1);
            }
            // Skirts to the steel: right side, front, and left beyond the spout.
            if (half == 0) under_plinth(max(xa, xfl + clearance), xm, pl_w - wall_t, pl_w, ds);
            else {
                under_plinth(tap_x, xm, pl_w - wall_t, pl_w, ds);
                under_plinth(xm - wall_t, xm, 0, pl_w, ds);
                under_plinth(spout_reach + clearance, xm, 0, wall_t, ds);
            }
            // Ring round the tap body, standing on the base flange.
            intersection() {
                translate([tap_x, ty, z0 + tap_base_h]) cylinder(r = pl_hole + wall_t, h = 80, $fn = 96);
                under_plinth(half == 0 ? plinth_back : tap_x, half == 0 ? tap_x : pl_x1, 0, pl_w, ds);
            }
        }
        translate([tap_x, ty, z0 - 1]) cylinder(r = pl_hole, h = 120, $fn = 96);
    }
}

// Sill, strip, bowl rim and tap, for previews only.
module context() {
    translate([-sill_depth, 0, z0]) cube([sill_depth, sill_length, riser_drop]);       // sill
    translate([0, 0, z0 - 2]) cube([strip_width, sill_length, 2]);                      // steel strip
    translate([strip_width, 0, z0 - 2]) cube([4, tap_y - tap_base_d / 2 - 10, 2 + rim_h]); // left bowl rim
    translate([strip_width, tap_y - tap_base_d / 2 - 10, z0 - 2])
        cube([90, sill_length - tap_y + tap_base_d / 2 + 10, 2]);                       // deck round the tap
    translate([tap_x, tap_y, z0]) {
        cylinder(d = tap_base_d, h = tap_base_h, $fn = 72);
        cylinder(d = tap_body_d, h = tap_body_h, $fn = 72);
    }
}

// Each piece in its own frame (y from 0), and where it goes.
function p_len(p) = p == "plate" ? plate_len : p == "left" ? left_seg : p == "right" ? right_len : pl_w;
function p_list(p) = p == "left" || p == "plinth" ? (segment < 0 ? [0, 1] : [segment])
                   : p == "plate" && segment < 0 && test_slice == 0 ? [0, 1, 2] : [segment];

module body(p, seg) {
    if (p == "plate") print_cut(plate_len, test_slice, plate_segments, seg) plate();
    else if (p == "left") print_cut(left_seg, test_slice) apron(seg);
    else if (p == "right") print_cut(right_len, test_slice) right_piece();
    else plinth_half(seg);
}

module place(p, seg) {
    if (p == "plate") translate([0, clearance, 0]) children();
    else if (p == "right") translate([0, spout_y, 0]) children();
    else if (p == "plinth") translate([0, pl_y, 0]) children();
    // Aprons run from the spout toward the wall: mirrored in y.
    else translate([0, spout_y - clearance - seg * (left_seg + clearance), 0]) mirror([0, 1, 0]) children();
}

// One piece on the bed. Plate and aprons: flat side down. Right piece:
// upside down on its wall tops, which share one plane. Plinth: upside down
// on its top (both halves). A piece longer than the bed is turned to fit.
module print_piece(p, seg) {
    y0 = p == "plate" && test_slice == 0 && seg >= 0 ? plate_len / plate_segments * seg : 0;
    plen = test_slice > 0 ? test_slice : p == "plate" && seg >= 0 ? plate_len / plate_segments : p_len(p);
    n = [-pl_tx, -pl_ty, 1] / norm([-pl_tx, -pl_ty, 1]);
    if (p == "plinth")
        translate([0, 0, n * [plinth_back, 0, pl_z0 + (seg == 1 ? plinth_t + clearance : 0)]]) rotate(a = acos(-n[2]), v = cross(n, [0, 0, -1])) body(p, seg);
    else rotate([0, 0, plen > bed - 5 ? diag_angle : 0]) translate([0, -plen / 2, 0]) {
        if (p == "plate") translate([0, -y0, 0]) body(p, seg);
        else if (p == "left") translate([0, 0, -z0]) body(p, seg);
        else translate([0, 0, -cos(top_tilt)]) rotate([0, top_tilt, 0]) rotate([180, 0, 0])
            translate([0, -plen, 0]) body(p, seg);
    }
}

pieces = piece == "all" ? ["plate", "left", "right", "plinth"] : [piece];

if (orient == "print") {
    for (i = [0 : len(pieces) - 1]) translate([i * 300, 0, 0]) {
        p = pieces[i];
        segs = p_list(p);
        for (j = [0 : len(segs) - 1]) translate([j * 150, 0, 0]) print_piece(p, segs[j]);
    }
} else {
    %context();
    for (p = pieces) for (s = p_list(p))
        place(p, s) body(p, s);
}
