// Sink drain: loose-fitting pieces that send every drop from the window sill
// into the left bowl.
//   plate - ribbed cover on the sill; falls toward the sink and drips off its
//           nose, just past the sill edge (3 pieces).
//   left  - channel covering the 40 mm steel strip from the left wall to the
//           spout, falling toward it (2 pieces, joined spigot-in-socket).
//   right - channel covering the strip from the mullion to the spout, plus
//           the collector and the spout itself, which reaches out over the
//           left bowl beside the tap (1 piece).
// Wherever two channel pieces meet, the upstream one ends in a narrower
// spigot that sits inside the downstream one, above a small ridge, so water
// drops from one floor onto the next and never reaches the join.
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
tap_y = 430;           // GUESS: tap centre from the left wall (right of the spout)

/* [Design] */
plate_rise = 10;       // user: back edge this much above the front
plate_min = 3;         // floor thickness at the nose
nose = 8;              // plate overhang past the sill edge
rib_count = 30;        // ribs along the plate (one more than this, ends included)
rib_fill = 0.5;        // rib width / pitch (reference STL: 10 mm ribs, 10 mm grooves)
rib_h = 4;             // above the groove floor
end_wall_h = 4;        // plate end walls, above the rib tops
drip_w = 2;            // groove under the nose so drips let go at the edge
drip_d = 1.2;
wall_t = 1.6;
floor_t = 1.6;
flange_over = 5;       // channel top flange reaches this far past the bowl edge
flange_t = 2;
top_tilt = 2;          // wall tops and flange fall this much toward the sink (°)
gutter_fall = 1.2;     // channel floors, toward the spout (°)
spout_fall = 2;        // spout floor, out over the bowl (°)
chan_w_spout = 14;     // spout inside width
spigot_len = 8;        // how far a spigot reaches into the next piece
ridge_w = 1.6;         // ridge across the floor where a spigot comes in
ridge_h = 2.5;
spigot_gap = 0.5;      // spigot underside above the ridge
rim_room = 0.5;        // spout underside above the rim
tap_room = 2;          // clearance round the tap
pin_d = 1.75;          // filament pins across each plate join
pin_len = 10;          // into each side
hollow = true;         // pocket under channel floors, open to the strip

/* [Print] */
piece = "all";         // "plate" | "left" | "right" | "all"
bed = 255;             // user: 255 x 255 x 255
diag_angle = 57;       // for pieces longer than the bed
plate_segments = 3;
clearance = 0.3;       // per side: off the riser, the wall, the mullion and between pieces
test_slice = 0;        // >0: only the first N mm of the piece (from its low end for channels)
segment = -1;          // plate: which third; left: 0 = by the spout, 1 = by the wall; -1 = all
orient = "installed";  // "print": plate flat, channels upside down on their wall tops

z0 = -riser_drop;
pin_hole = pin_d + 0.35;
big = 60;

// Plate
plate_len = sill_length - 2 * clearance;
xb = -(sill_depth - clearance);      // back edge, at the window frame
plate_fall = atan(plate_rise / (nose - xb));
function plate_top(x) = plate_min + (nose - x) * tan(plate_fall);
pitch = plate_len / rib_count;
plate_pin_xs = [-100, -55, -15];
plate_pin_z = 4.5;

// Channels: one cross-section for both sides.
xg0 = clearance;                     // back face, against the riser
x_in = xg0 + wall_t;                 // inside of the back wall
xf1 = strip_width - clearance;       // front face, just behind the bowl rim
x_in2 = xf1 - wall_t;                // inside of the front wall
xfl = strip_width + flange_over;     // flange edge, over the bowl
// Every wall top lies on this plane, so the channels print upside down on it.
function top_z(x) = -1 - x * tan(top_tilt);
// Spigot: fits inside the next piece's walls.
sx0 = x_in + clearance;
sx1 = x_in2 - clearance;
step = ridge_h + spigot_gap + floor_t;   // floor rise across each spigot join

// Spout and collector (part of the right piece), local y from spout_y.
spout_w_out = chan_w_spout + 2 * wall_t;
function spout_floor(x) = fc - (x - x_in) * tan(spout_fall);
// Collector floor: low enough to fall into the spout, high enough that the
// spout's underside clears the rim a few mm past the bowl edge.
fc = z0 + rim_h + rim_room + floor_t + (strip_width + 5 - x_in) * tan(spout_fall);
right_len = sill_length - clearance - spout_y;

// Left run: two pieces from the spout (segment 0) out to the wall.
left_total = spout_y - 2 * clearance;
left_seg = (left_total - clearance) / 2;
left_f0 = [fc + step, fc + step + left_seg * tan(gutter_fall) + step];
function chan_floor(f0, y) = f0 + y * tan(gutter_fall);

assert(rib_count % plate_segments == 0, "plate joins must land on rib centres");
assert(plate_pin_z - pin_hole / 2 >= 1.2 && plate_top(-15) + rib_h - plate_pin_z - pin_hole / 2 >= 1.2,
       "plate pin holes leave walls under 1.2 mm");
assert(nose + tap_room <= tap_gap && xfl + tap_room <= tap_gap, "channel or plate reaches the tap");
assert(spout_y + spout_w_out + tap_room <= tap_y - tap_base_d / 2, "spout hits the tap base");
assert(spout_reach > xfl + 10, "spout must reach past the bowl edge");
assert(top_z(x_in) - chan_floor(left_f0[1], left_seg) >= 4, "left channel too shallow at the wall end");
assert(spout_floor(strip_width + 5) - floor_t >= z0 + rim_h, "spout underside hits the rim");

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
    ew = 2;
    difference() {
        union() {
            extrude_y(plate_len) polygon([[xb, 0], [nose, 0], [nose, plate_top(nose)], [xb, plate_top(xb)]]);
            // Ribs run toward the sink and stop at the sill edge, so the
            // grooves empty across the plain nose.
            intersection() {
                for (k = [1 : rib_count - 1]) translate([0, k * pitch - rw / 2, 0]) extrude_y(rw)
                    polygon([[xb, 0], [0, 0], [0, plate_top(0) + rib_h], [xb, plate_top(xb) + rib_h]]);
                translate([xb - 1, 0, -1]) cube([nose - xb + 2, plate_len, 100]);
            }
            // End walls, so nothing runs off the ends.
            for (y = [0, plate_len - ew]) translate([0, y, 0]) extrude_y(ew) polygon([
                [xb, 0], [nose, 0], [nose, plate_top(nose) + end_wall_h], [xb, plate_top(xb) + rib_h + end_wall_h]]);
        }
        translate([nose - 3 - drip_w, -1, -1]) cube([drip_w, plate_len + 2, drip_d + 1]);
        for (j = [1 : plate_segments - 1]) pins_at(plate_len / plate_segments * j, plate_pin_xs, plate_pin_z);
    }
}

// Below the wall-top plane.
module under_top(len, y0 = -1) {
    translate([0, y0, 0]) extrude_y(len - y0 + 1) polygon([
        [xg0 - 1, z0 - 1], [spout_reach + 1, z0 - 1],
        [spout_reach + 1, top_z(spout_reach + 1)], [xg0 - 1, top_z(xg0 - 1)]]);
}

module flange(len) {
    extrude_y(len) polygon([[xf1 - 1, top_z(xf1 - 1) - flange_t - 1], [xfl, top_z(xfl) - flange_t],
                            [xfl, top_z(xfl) + 1], [xf1 - 1, top_z(xf1 - 1) + 1]]);
}

// A run of channel in its own frame: y from 0 (low end, toward the spout)
// to len; the floor rises with y from f0. Options: a spigot below y=0, a
// closed wall at y=len, or a socket ridge at y=len for the next spigot.
module channel(len, f0, spigot = false, closed = false, socket = false) {
    hi = chan_floor(f0, len);
    difference() {
        intersection() {
            union() {
                translate([xg0, 0, z0]) cube([xf1 - xg0, len, big]);
                flange(len);
                if (spigot) translate([sx0, -spigot_len, f0 - floor_t]) cube([sx1 - sx0, spigot_len, big]);
            }
            under_top(len, spigot ? -spigot_len - 1 : -1);
        }
        // Channel, with a socket ridge at the far end if one is wanted.
        hull() {
            ylo = spigot ? 10 : 0;   // with a spigot, the taper below does the low end
            translate([x_in, ylo, chan_floor(f0, ylo)]) cube([x_in2 - x_in, 0.01, big]);
            yhi = closed ? len - wall_t : socket ? len - ridge_w : len + 1;
            translate([x_in, yhi - 0.01, chan_floor(f0, yhi)]) cube([x_in2 - x_in, 0.01, big]);
        }
        if (socket) translate([x_in, len - ridge_w - 0.01, hi + ridge_h]) cube([x_in2 - x_in, ridge_w + 1, big]);
        // Pocket under the floor, open to the strip, leaving floor_t of floor.
        if (hollow) hull() {
            y1 = spigot ? 12 : 2;
            y2 = len - (closed ? wall_t : 0) - 2;
            translate([x_in, y1, z0 - 1]) cube([x_in2 - x_in, 0.01, chan_floor(f0, y1) - floor_t - z0 + 1]);
            translate([x_in, y2, z0 - 1]) cube([x_in2 - x_in, 0.01, chan_floor(f0, y2) - floor_t - z0 + 1]);
        }
        // Spigot: narrows from the full channel to fit the next piece.
        if (spigot) hull() {
            translate([sx0 + wall_t, -spigot_len - 1, f0]) cube([sx1 - sx0 - 2 * wall_t, 0.01, big]);
            translate([sx0 + wall_t, 0, f0]) cube([sx1 - sx0 - 2 * wall_t, 0.01, big]);
            translate([x_in, 10, chan_floor(f0, 10)]) cube([x_in2 - x_in, 0.01, big]);
        }
    }
}

// Right piece in its own frame: y from spout_y. Collector and spout at
// y < spout_w_out, then the channel out to the mullion.
module right_piece() {
    cw = right_len - spout_w_out;
    difference() {
        union() {
            translate([0, spout_w_out, 0]) channel(cw, fc, closed = true);
            intersection() {
                union() {
                    translate([xg0, 0, z0]) cube([xf1 - xg0, spout_w_out + 0.01, big]);
                    flange(spout_w_out + 0.01);
                    // Spout: stands on the strip, then lifts over the rim.
                    xs = (fc - floor_t + x_in * tan(spout_fall) - z0 + (xf1 - 4)) / (1 + tan(spout_fall));
                    extrude_y(spout_w_out) polygon([
                        [xg0, z0], [xf1 - 4, z0], [xs, spout_floor(xs) - floor_t],
                        [spout_reach, spout_floor(spout_reach) - floor_t], [spout_reach, big], [xg0, big]]);
                }
                under_top(spout_w_out + 0.01);
            }
        }
        // Collector: open to the left, behind a ridge, for the left spigot.
        translate([x_in, ridge_w, fc]) cube([x_in2 - x_in, spout_w_out - ridge_w + 0.02, big]);
        translate([x_in, -1, fc + ridge_h]) cube([x_in2 - x_in, ridge_w + 1.01, big]);
        // Spout, falling out over the bowl.
        hull() {
            translate([x_in, wall_t, fc]) cube([0.01, chan_w_spout, big]);
            translate([spout_reach + 1, wall_t, spout_floor(spout_reach + 1)]) cube([0.01, chan_w_spout, big]);
        }
    }
}

module left_piece(seg) {
    channel(left_seg, left_f0[seg], spigot = true, closed = seg == 1, socket = seg == 0);
}

// Sill, strip, bowl rim and tap, for previews only.
module context() {
    tx = tap_gap + tap_base_d / 2;
    translate([-sill_depth, 0, z0]) cube([sill_depth, sill_length, riser_drop]);       // sill
    translate([0, 0, z0 - 2]) cube([strip_width, sill_length, 2]);                      // steel strip
    translate([strip_width, 0, z0 - 2]) cube([4, tap_y - tap_base_d / 2 - 10, 2 + rim_h]); // left bowl rim
    translate([strip_width, tap_y - tap_base_d / 2 - 10, z0 - 2])
        cube([90, sill_length - tap_y + tap_base_d / 2 + 10, 2]);                       // deck round the tap
    translate([tx, tap_y, z0]) {
        cylinder(d = tap_base_d, h = tap_base_h, $fn = 72);
        cylinder(d = tap_body_d, h = tap_body_h, $fn = 72);
    }
}

// Each piece in its own frame (y from 0 at its low end), and where it goes.
function p_len(p) = p == "plate" ? plate_len : p == "left" ? left_seg : right_len;
function p_segs(p) = p == "plate" ? plate_segments : 1;
function p_list(p) = p == "left" ? (segment < 0 ? [0, 1] : [segment]) : [segment];

module body(p, seg) {
    if (p == "plate") print_cut(plate_len, test_slice, plate_segments, seg) plate();
    else if (p == "left") print_cut(left_seg, test_slice) left_piece(seg);
    else print_cut(right_len, test_slice) right_piece();
}

module place(p, seg) {
    if (p == "plate") translate([0, clearance, 0]) children();
    else if (p == "right") translate([0, spout_y, 0]) children();
    // Left pieces run from the spout toward the wall: mirrored in y.
    else translate([0, spout_y - clearance - seg * (left_seg + clearance), 0]) mirror([0, 1, 0]) children();
}

// One piece on the bed. Plate: flat side down. Channels: upside down on
// their wall tops, which share one plane. A piece longer than the bed is
// turned to fit.
module print_piece(p, seg) {
    y0 = p == "plate" && test_slice == 0 && seg >= 0 ? plate_len / plate_segments * seg : 0;
    plen = test_slice > 0 ? test_slice : p == "plate" && seg >= 0 ? plate_len / plate_segments : p_len(p);
    rotate([0, 0, plen > bed - 5 ? diag_angle : 0]) translate([0, -plen / 2, 0]) {
        if (p == "plate") translate([0, -y0, 0]) body(p, seg);
        else translate([0, 0, -cos(top_tilt)]) rotate([0, top_tilt, 0]) rotate([180, 0, 0])
            translate([0, -plen, 0]) body(p, seg);
    }
}

pieces = piece == "all" ? ["plate", "left", "right"] : [piece];

if (orient == "print") {
    for (i = [0 : len(pieces) - 1]) translate([i * 300, 0, 0]) {
        p = pieces[i];
        segs = p == "plate" && segment < 0 && test_slice == 0 ? [0 : plate_segments - 1] : p_list(p);
        for (j = [0 : len([for (s = segs) s]) - 1]) translate([j * 150, 0, 0])
            print_piece(p, [for (s = segs) s][j]);
    }
} else {
    %context();
    for (p = pieces) for (s = (p == "left" ? (segment < 0 ? [0, 1] : [segment]) : [segment]))
        place(p, s) body(p, s);
}
