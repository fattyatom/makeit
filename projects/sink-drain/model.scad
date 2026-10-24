// Sink drain: three kinds of loose-fitting piece that send every drop from
// the window sill into the sink.
//   plate  - ribbed cover on the sill; falls toward the sink and drips off
//            its nose, just past the sill edge (3 pieces).
//   apron  - on the flat 40 mm steel strip left of the spout; keys over the
//            bowl rim and tips the drips into the left bowl (2 pieces).
//   gutter - on the strip right of the spout; a channel that falls toward
//            the spout, runs behind the tap, and turns into a spout reaching
//            out over the left bowl (1 piece).
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
spout_y = 380;         // user: spout centre from the left wall
spout_reach = 100;     // user: at least this far out from the sill face
tap_y = 420;           // GUESS: tap centre from the left wall
tap_base_d = 55;       // GUESS: tap base flange diameter
tap_base_h = 8;        // GUESS: flange height above the strip
tap_pillar_d = 35;     // GUESS
tap_gap = 22;          // GUESS: sill front face to the back of the tap base

/* [Design] */
plate_rise = 10;       // user: back edge this much above the front
plate_min = 3;         // floor thickness at the nose
nose = 8;              // plate overhang past the sill edge
rib_count = 30;        // ribs along the plate (one more than this, ends included)
rib_fill = 0.5;        // rib width / pitch (reference STL: 10 mm ribs, 10 mm grooves)
rib_h = 4;             // above the groove floor
drip_w = 2;            // groove under the nose so drips let go at the edge
drip_d = 1.2;
wall_t = 1.6;
apron_over = 10;       // apron front edge past the bowl edge
apron_t = 2;           // apron thickness at its front edge
apron_fall = 5;        // degrees, toward the bowl
rim_notch = 6;         // underside clears the rim from this far back from the bowl edge
rim_room = 1;          // clearance over the rim
chan_w = 14;           // gutter channel inside width
gutter_fall = 2;       // degrees, along the strip toward the spout
spout_fall = 4;        // degrees, out over the bowl
floor_t = 2;           // gutter and spout floor
tap_room = 2;          // clearance round the tap
pin_d = 1.75;          // filament pins across each join
pin_len = 10;          // into each side

/* [Print] */
piece = "all";         // "plate" | "apron" | "gutter" | "all"
bed = 255;             // user: 255 x 255 x 255
diag_angle = 57;       // for pieces longer than the bed: the gutter's L then takes 227 x 226
plate_segments = 3;
apron_segments = 2;
clearance = 0.3;       // per side: off the riser, the wall and the mullion
test_slice = 0;        // >0: only the first N mm from the left end of the piece
segment = -1;          // which segment of the chosen piece, -1 = all
orient = "installed";  // "print": plate flat, apron on its back face, gutter upside down

z0 = -riser_drop;
pin_hole = pin_d + 0.35;

// Plate
plate_len = sill_length - 2 * clearance;
xb = -(sill_depth - clearance);      // back edge, at the window frame
plate_fall = atan(plate_rise / (nose - xb));
function plate_top(x) = plate_min + (nose - x) * tan(plate_fall);
pitch = plate_len / rib_count;
plate_pin_xs = [-100, -55, -15];
plate_pin_z = 4.5;

// Gutter and spout
spout_out_w = chan_w + 2 * wall_t;
yg0 = spout_y - spout_out_w / 2;     // gutter's left end (spout's left wall)
gutter_len = sill_length - clearance - yg0;
xg0 = clearance;                     // back face, against the riser
x_in = xg0 + wall_t;                 // inside of the back wall
xg1 = x_in + chan_w + wall_t;        // front face of the channel
// Spout floor where it leaves the channel: high enough that its underside
// clears the rim a few mm past the bowl edge.
floor0 = z0 + rim_h + rim_room + floor_t + (strip_width + 5 - x_in) * tan(spout_fall);
function gutter_floor(y) = floor0 + max(0, y - spout_out_w) * tan(gutter_fall);
function spout_floor(x) = floor0 - (x - x_in) * tan(spout_fall);
// Every wall top lies on this plane, so the gutter prints upside down on it.
function gutter_top(x) = -1 - x * tan(spout_fall);

// Apron
apron_len = yg0 - 2 * clearance;
xa1 = strip_width + apron_over;
xr0 = strip_width - rim_notch;
apron_tf = z0 + rim_h + rim_room + apron_t;
function apron_top(x) = apron_tf + (xa1 - x) * tan(apron_fall);
apron_pin_xs = [8, 26];
apron_pin_z = z0 + 4;

assert(rib_count % plate_segments == 0, "plate joins must land on rib centres");
assert(plate_pin_z - pin_hole / 2 >= 1.2 && plate_top(-15) + rib_h - plate_pin_z - pin_hole / 2 >= 1.2,
       "plate pin holes leave walls under 1.2 mm");
assert(apron_pin_z - z0 - pin_hole / 2 >= 1.2 && apron_top(max(apron_pin_xs)) - apron_pin_z - pin_hole / 2 >= 1.2,
       "apron pin holes leave walls under 1.2 mm");
assert(nose + tap_room <= tap_gap, "plate nose reaches the tap");
assert(xg1 + tap_room <= tap_gap, "gutter channel too wide to pass behind the tap");
assert(spout_y + spout_out_w / 2 + tap_room <= tap_y - tap_base_d / 2, "spout hits the tap base");
assert(spout_reach > strip_width + 10, "spout must reach past the bowl edge");
assert(gutter_top(xg1) - gutter_floor(gutter_len) >= 6, "gutter too shallow at its far end");

// Profile in (x, z), extruded along y from 0 to len.
module extrude_y(len) {
    translate([0, len, 0]) rotate([90, 0, 0]) linear_extrude(len) children();
}

module pins_at(y, xs, z) {
    for (x = xs) translate([x, y, z]) rotate([90, 0, 0])
        cylinder(d = pin_hole, h = 2 * (pin_len + 0.5), center = true, $fn = 24);
}

module plate() {
    rw = pitch * rib_fill;
    difference() {
        union() {
            extrude_y(plate_len) polygon([[xb, 0], [nose, 0], [nose, plate_top(nose)], [xb, plate_top(xb)]]);
            // Ribs run toward the sink and stop at the sill edge, so the
            // grooves empty across the plain nose.
            intersection() {
                for (k = [0 : rib_count]) translate([0, k * pitch - rw / 2, 0]) extrude_y(rw)
                    polygon([[xb, 0], [0, 0], [0, plate_top(0) + rib_h], [xb, plate_top(xb) + rib_h]]);
                translate([xb - 1, 0, -1]) cube([nose - xb + 2, plate_len, 100]);
            }
        }
        translate([nose - 3 - drip_w, -1, -1]) cube([drip_w, plate_len + 2, drip_d + 1]);
        for (j = [1 : plate_segments - 1]) pins_at(plate_len / plate_segments * j, plate_pin_xs, plate_pin_z);
    }
}

module apron() {
    xw = xg0 + wall_t;
    k = rim_h + rim_room;
    difference() {
        // Back upstand stops 1 mm under the plate's nose; the nose drips
        // onto the apron in front of it.
        extrude_y(apron_len) polygon([
            [xg0, z0], [xr0, z0], [xr0 + k, z0 + k], [xa1, z0 + k], [xa1, apron_tf],
            [xw, apron_top(xw)], [xw, -1], [xg0, -1]]);
        for (j = [1 : apron_segments - 1]) pins_at(apron_len / apron_segments * j, apron_pin_xs, apron_pin_z);
    }
}

module gutter() {
    big = 60;
    // Underside of the spout: stands on the strip, then a 45° step up and
    // over the rim.
    xs = (floor0 - floor_t + x_in * tan(spout_fall) - z0 + xr0) / (1 + tan(spout_fall));
    difference() {
        intersection() {
            union() {
                translate([xg0, 0, z0]) cube([xg1 - xg0, gutter_len, big]);
                extrude_y(spout_out_w) polygon([
                    [xg0, z0], [xr0, z0], [xs, spout_floor(xs) - floor_t],
                    [spout_reach, spout_floor(spout_reach) - floor_t], [spout_reach, big], [xg0, big]]);
            }
            // Wall tops on one plane (the print bed).
            extrude_y(gutter_len) polygon([[xg0 - 1, z0 - 1], [spout_reach + 1, z0 - 1],
                [spout_reach + 1, gutter_top(spout_reach + 1)], [xg0 - 1, gutter_top(xg0 - 1)]]);
        }
        // Channel, falling toward the spout end.
        hull() {
            translate([x_in, wall_t, floor0]) cube([chan_w, spout_out_w - wall_t, big]);
            translate([x_in, gutter_len - wall_t - 0.01, gutter_floor(gutter_len - wall_t)]) cube([chan_w, 0.01, big]);
        }
        // Spout, falling out over the bowl.
        hull() {
            translate([x_in, wall_t, floor0]) cube([0.01, chan_w, big]);
            translate([spout_reach + 1, wall_t, spout_floor(spout_reach + 1)]) cube([0.01, chan_w, big]);
        }
    }
}

// Sill, strip, bowl rim and tap, for previews only.
module context() {
    translate([-sill_depth, 0, z0]) cube([sill_depth, sill_length, riser_drop]);       // sill
    translate([0, 0, z0 - 2]) cube([strip_width, sill_length, 2]);                      // steel strip
    translate([strip_width, 0, z0 - 2]) cube([4, tap_y - tap_base_d / 2 - 10, 2 + rim_h]); // left bowl rim
    translate([strip_width + 4, tap_y - tap_base_d / 2 - 10, z0 - 2])
        cube([80, sill_length - tap_y + tap_base_d / 2 + 10, 2]);                       // deck right of the bowl
    translate([tap_gap + tap_base_d / 2, tap_y, z0]) {
        cylinder(d = tap_base_d, h = tap_base_h, $fn = 72);
        cylinder(d = tap_pillar_d, h = 150, $fn = 72);
    }
}

function p_len(p) = p == "plate" ? plate_len : p == "apron" ? apron_len : gutter_len;
function p_segs(p) = p == "plate" ? plate_segments : p == "apron" ? apron_segments : 1;
function p_y(p) = p == "gutter" ? yg0 : clearance;

module body(p) {
    if (p == "plate") plate();
    else if (p == "apron") apron();
    else gutter();
}

module cut(p, seg) {
    print_cut(p_len(p), test_slice, p_segs(p), seg) body(p);
}

// One piece on the bed. Plate: flat side down. Apron: on the face against
// the riser. Gutter: upside down on its wall tops, which share one plane.
// A piece longer than the bed is turned to fit (diag_angle).
module print_piece(p, seg) {
    segs = p_segs(p);
    y0 = test_slice > 0 || seg < 0 ? 0 : p_len(p) / segs * seg;
    plen = test_slice > 0 ? test_slice : seg < 0 ? p_len(p) : p_len(p) / segs;
    rotate([0, 0, plen > bed - 5 ? diag_angle : 0]) translate([0, -plen / 2, 0]) {
        if (p == "plate") translate([0, -y0, 0]) cut(p, seg);
        else if (p == "apron") translate([0, -y0, -xg0]) rotate([0, -90, 0]) cut(p, seg);
        else translate([0, 0, -cos(spout_fall)]) rotate([0, spout_fall, 0]) rotate([180, 0, 0])
            translate([0, -plen, 0]) cut(p, seg);
    }
}

pieces = piece == "all" ? ["plate", "apron", "gutter"] : [piece];

if (orient == "print") {
    for (i = [0 : len(pieces) - 1]) translate([i * 300, 0, 0]) {
        p = pieces[i];
        if (segment >= 0 || test_slice > 0 || p_segs(p) == 1) print_piece(p, segment);
        else for (j = [0 : p_segs(p) - 1]) translate([j * 150, 0, 0]) print_piece(p, j);
    }
} else {
    %context();
    for (p = pieces) translate([0, p_y(p), 0]) cut(p, segment);
}
