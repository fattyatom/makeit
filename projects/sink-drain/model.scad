// Sink drain cover: two sloped plates that sit loose on the tiled window
// sill behind the sink, one each side of the tap. Each falls from its far and
// back corners to a drain point at the front edge behind the tap; a front lip
// keeps the water on the plate until it gets there, and a spout on the left
// plate carries it past the tap into the left bowl. A skirt hangs over the
// sill's front face and the 3 mm gap so splashes land on the steel.
//
// Section frame (both plates are modelled in it): x = depth, x=0 at the
// sill's front face, + toward the window; y = along the sill from the
// junction behind the tap (y=0) out to the far end; z = up, z=0 on the sill
// top. The left plate's frame is the installed frame with y toward the left
// wall; the right plate is its mirror image.
use <../../lib/makeit.scad>

/* [Measured] */
sill_length = 630;     // photo annotation: left wall to the window mullion, back edge
left_length = 350;     // photo annotation: left end to the tap, along the left bowl
sill_depth = 120;      // photo annotation: window frame to the sill's front edge, right end
riser_drop = 30;       // photo annotation: sill top down to the steel sink deck
rim_gap = 3;           // photo annotation + user: sill front face to the steel rim
spout_reach = 110;     // user: spout outlet this far out from the sill front face
tap_neck_d = 35;       // GUESS: tap pillar diameter
tap_base_d = 55;       // GUESS: tap base flange diameter
tap_base_h = 8;        // GUESS: base flange height above the deck
tap_setback = 5;       // GUESS: sill front face to the edge of the tap base
tap_offset = -18;      // GUESS: tap centre along y from the junction (+ = toward the left wall)

/* [Design] */
corner_rise = 10;      // user: back and far corners this much above the drain point
plate_min = 3;         // plate thickness at the drain point
skirt_t = 3;           // covers the 3 mm gap so drips land on the steel
skirt_lift = 1;        // skirt stops this far above the steel; the plate rests on the sill
lip_h = 5;             // front lip above the plate top
lip_t = 2;
dam_t = 2;             // end dam at the far end of each plate
spout_angle = 50;      // in plan, from straight out from the sill toward the left wall
spout_end_lift = 12;   // outlet floor this far above the steel deck
spout_w = 14;          // inside width of the channel
spout_wall = 1.6;
spout_depth = 6;       // inside depth of the channel
inlet_len = 16;        // how far the channel's trough reaches back into the plate
tap_room = 2;          // clearance round the tap
pin_d = 1.75;          // filament pins across each joint
pin_len = 10;          // into each side

/* [Print] */
section = "both";      // "left" | "right" | "both"
bed = 255;             // user: 255 x 255 x 255
left_segments = 2;     // 350 mm doesn't fit the bed; the right plate fits diagonally
right_segments = 1;
clearance = 0.3;       // per side, off the riser, the wall and the mullion
test_slice = 0;        // >0: only the first N mm from the junction end
segment = -1;          // which piece of the chosen section, -1 = all
orient = "installed";  // "print": spout piece stands on its junction end, the rest lie on the skirt

right_length = sill_length - left_length;
xf = -(clearance + skirt_t);         // front face of skirt and lip
xb = sill_depth - clearance;         // back edge, at the window frame
pin_hole = pin_d + 0.35;
pin_z = 3.2;
pin_xs = [xf + 0.45 * (xb - xf), xf + 0.85 * (xb - xf)];
tap_x = -(tap_setback + tap_base_d / 2);

function sec_len(sec) = (sec == "left" ? left_length : right_length) - clearance;
function sec_segs(sec) = sec == "left" ? left_segments : right_segments;
// Plate top: L-shaped contours round the drain corner, with a valley along
// the diagonal from the drain corner to the far back corner.
function top_z(x, y, len) = plate_min + corner_rise * max(y / len, (x - xf) / (xb - xf));

// Spout axis and start: leaves the front face just clear of the junction.
spout_y0 = (spout_w / 2 + spout_wall) * cos(spout_angle) + 1;
spout_z0 = plate_min - 1;            // channel floor where it leaves the plate
spout_run = (spout_reach + xf) / cos(spout_angle);     // in plan, from the skirt face
spout_drop = spout_z0 + riser_drop - spout_end_lift;
spout_fall = atan(spout_drop / spout_run);
spout_length = sqrt(spout_run * spout_run + spout_drop * spout_drop);
echo(spout_length = spout_length, spout_fall = spout_fall);

assert(left_length > 0 && right_length > 0, "left_length must be inside sill_length");
assert(plate_min >= 2, "plate thinner than 2 mm at the drain");
assert(pin_z - pin_hole / 2 >= 1.2 && plate_min + corner_rise / 2 - pin_z - pin_hole / 2 >= 1.2,
       "pin holes leave walls under 1.2 mm");
assert(spout_fall >= 3, "spout falls less than 3°: lower spout_end_lift");
assert(skirt_t >= rim_gap, "skirt must cover the gap so drips land on the steel");

module plate(len) {
    t0 = top_z(xf, 0, len);
    t1 = plate_min + corner_rise;
    polyhedron(
        points = [[xf, 0, 0], [xb, 0, 0], [xb, len, 0], [xf, len, 0],
                  [xf, 0, t0], [xb, 0, t1], [xb, len, t1], [xf, len, t1]],
        faces = [[0, 1, 2, 3], [4, 7, 6], [4, 6, 5],
                 [0, 4, 5, 1], [1, 5, 6, 2], [2, 6, 7, 3], [3, 7, 4, 0]]);
}

module skirt(len) {
    translate([xf, 0, -riser_drop + skirt_lift]) cube([skirt_t, len, riser_drop - skirt_lift + 0.01]);
}

module lip(len, from) {
    hull() {
        translate([xf, from, 0]) cube([lip_t, 0.01, top_z(xf, from, len) + lip_h]);
        translate([xf, len - 0.01, 0]) cube([lip_t, 0.01, top_z(xf, len, len) + lip_h]);
    }
}

module dam(len) {
    translate([xf, len - dam_t, 0]) cube([xb - xf, dam_t, plate_min + corner_rise + lip_h]);
}

// Channel along +x from the origin, floor at z=0, then aimed down the spout.
module along_spout() {
    translate([xf, spout_y0, spout_z0])
        rotate([0, 0, 180 - spout_angle]) rotate([0, spout_fall, 0]) children();
}

module spout_outer() {
    along_spout() translate([0, -spout_w / 2 - spout_wall, -spout_wall])
        cube([spout_length, spout_w + 2 * spout_wall, spout_wall + spout_depth]);
}

module spout_void() {
    along_spout() translate([-inlet_len, -spout_w / 2, 0])
        cube([spout_length + inlet_len + 1, spout_w, 60]);
}

module tap_clear(ty) {
    translate([tap_x, ty, -riser_drop - 1]) {
        cylinder(d = tap_neck_d + 2 * tap_room, h = 200, $fn = 72);
        cylinder(d = tap_base_d + 2 * tap_room, h = tap_base_h + tap_room + 1, $fn = 72);
    }
}

module pin_holes(y, len) {
    for (x = pin_xs) translate([x, y, pin_z]) rotate([90, 0, 0])
        cylinder(d = pin_hole, h = 2 * (pin_len + 0.5), center = true, $fn = 24);
}

module part(sec) {
    len = sec_len(sec);
    segs = sec_segs(sec);
    left = sec == "left";
    intersection() {
        difference() {
            union() {
                plate(len); skirt(len); dam(len);
                lip(len, left ? spout_y0 + spout_w : 0);
                if (left) spout_outer();
            }
            if (left) spout_void();
            tap_clear(left ? tap_offset : -tap_offset);
            for (i = [0 : segs - 1]) pin_holes(len / segs * i, len);
        }
        translate([-500, 0, -500]) cube([1000, len, 1000]);
    }
}

// Sill, riser, steel deck and tap, for previews only.
module context() {
    y0 = -right_length; y1 = left_length;
    translate([0, y0, -riser_drop]) cube([sill_depth, y1 - y0, riser_drop]);           // sill + riser
    difference() {
        translate([-rim_gap - 160, y0, -riser_drop - 2]) cube([160, y1 - y0, 2]);       // steel deck
        translate([-rim_gap - 150, tap_offset + tap_base_d / 2 + 15, -riser_drop - 5])
            cube([140, y1 - tap_offset - tap_base_d / 2 - 25, 10]);                     // left bowl
    }
    translate([tap_x, tap_offset, -riser_drop]) {
        cylinder(d = tap_base_d, h = tap_base_h, $fn = 72);
        cylinder(d = tap_neck_d, h = 180, $fn = 72);
    }
}

module installed(sec) {
    if (sec == "left") children();
    else mirror([0, 1, 0]) children();
}

module piece(sec, seg) {
    print_cut(sec_len(sec), test_slice, sec_segs(sec), seg) part(sec);
}

// One piece laid for printing. The spout piece stands on its junction end
// (the spout then rises at 45°+); every other piece lies on its skirt face,
// with the lip and skirt flat on the bed. A piece longer than the bed goes
// on the diagonal.
module print_piece(sec, seg) {
    len = sec_len(sec);
    segs = sec_segs(sec);
    y0 = seg < 0 ? 0 : len / segs * seg;
    plen = test_slice > 0 ? test_slice : seg < 0 ? len : len / segs;
    if (sec == "left" && y0 == 0) {
        translate([0, 0, -y0]) rotate([90, 0, 0]) piece(sec, seg);
    } else {
        rotate([0, 0, plen > bed ? 45 : 0]) translate([0, -y0 - plen / 2, -xf]) rotate([0, -90, 0])
            mirror([0, sec == "right" ? 1 : 0, 0]) translate([0, sec == "right" ? -2 * y0 - plen : 0, 0])
                piece(sec, seg);
    }
}

secs = section == "both" ? ["left", "right"] : [section];

if (orient == "print") {
    for (i = [0 : len(secs) - 1]) translate([i * 300, 0, 0]) {
        s = secs[i];
        if (segment >= 0 || test_slice > 0) print_piece(s, max(segment, 0));
        else for (j = [0 : sec_segs(s) - 1]) translate([0, j * 260, 0]) print_piece(s, j);
    }
} else {
    %context();
    for (s = secs) installed(s) piece(s, segment);
}
