// Sink drain: loose-fitting pieces that send every drop from the window sill
// into the sink.
//   plate  - ribbed cover on the sill; level rib tops, grooves falling toward
//            the sink, drips off its nose just past the sill edge (3 pieces).
//   left   - apron on the 40 mm strip from the left wall to the spout: a
//            gutter along the riser catches the plate's drips and runs to
//            the collector, and the rest slopes into the sink over the rim.
//            The spout-end piece carries the collector and the spout reaching
//            out over the left bowl beside the tap (2 pieces).
//   right  - the same apron from the mullion, gutter falling to the
//            collector; under the plinth its top falls back into the gutter
//            (1 piece).
//   plinth - cover round the tap base; drains into the spout and onto the
//            right piece (2 halves, so they can go on round the tap body).
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
gutter_w = 10;         // gutter along the riser, under the plate's drip line
ridge_w = 1.6;         // wall between the gutter and the front slope
ridge_h = 3;           // ridge above the wall-end gutter floor
front_fall = 8;        // front slope, toward the sink (°)
apron_over = 3;        // front edge past the bowl edge
apron_t = 2;           // apron thickness at its front edge
upstand_h = 1.5;       // back upstand above the gutter's high end
end_h = 3;             // end walls above the front slope
cross_back = 4;        // right piece under the plinth: top falls back to the gutter (°)
spout_fall = 1.5;      // spout floor, out over the bowl (°)
spout_wall_h = 5;      // spout walls above the collector floor
chan_w_spout = 10.4;   // spout inside width: fits between 380 and the tap at 395
rim_room = 0.5;        // clearance over the rim
notch = [36, 50];      // spout underside clears the rim between these x (60° sides)
lap = 1;               // tongues reach this far past each joint gap, into the next gutter downstream
lap_t = 1;             // tongue thickness at its tip
weir = 0.5;            // collector floor rises this much to its open left end
tap_room = 1;          // clearance round the tap
plinth_right = 10;     // plinth reaches this far right of the tap base
plinth_front = 5;      // and this far in front of it
plinth_back = 36;      // back edge, over the right piece so it drips onto it
plinth_t = 2;          // top plate
plinth_fall_y = 3;     // top falls toward the spout (°)
plinth_fall_x = 1.5;   // and toward the sill (°)
plinth_lip = 6;        // front half laps this far over the back half

/* [Print] */
piece = "all";         // "plate" | "left" | "right" | "plinth" | "all"
bed = 255;             // user: 255 x 255 x 255
diag_angle = 57;       // for pieces longer than the bed
plate_segments = 3;
clearance = 0.3;       // per side: off the riser, the wall, the mullion and between pieces
test_slice = 0;        // >0: only the first N mm of the piece
segment = -1;          // plate: which third; left: 0 = by the spout, 1 = by the wall;
                       // plinth: 0 = back half, 1 = front half; -1 = all
orient = "installed";  // "print": plate and strip pieces flat, plinth upside down

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
x_in = xg0 + wall_t;                 // inside of the upstand
x_g = x_in + gutter_w;               // front of the gutter
x_s = x_g + ridge_w;                 // front slope starts here
xa1 = strip_width + apron_over;      // front edge, over the bowl
// Underside: flat on the strip, then lifts at lift_angle to clear the rim.
xr0 = strip_width - (rim_h + rim_room) / tan(lift_angle);
function lift(x) = z0 + max(0, x - xr0) * tan(lift_angle);
tf = tan(front_fall);
gtop = -1 - upstand_h;               // gutter floor at its high end; upstand top 1 mm under the nose
// Lowest the front slope may start and keep apron_t at the front edge.
f_min = lift(xa1) + apron_t + (xa1 - x_s) * tf;

// Spout and collector (part of the spout-end apron), from spout_y to ys1.
// The collector floor is as low as lets the spout floor clear the rim notch.
notch_h = rim_h + rim_room;
notch_top = [notch[0] + notch_h / tan(lift_angle), notch[1] - notch_h / tan(lift_angle)];
fc = z0 + notch_h + floor_t + (notch_top[1] - x_in) * tan(spout_fall);
function spout_floor(x) = fc - (x - x_in) * tan(spout_fall);
spout_w_out = chan_w_spout + 2 * wall_t;
ys1 = spout_y + spout_w_out;

// Strip pieces in the installed frame: wall-end apron yl0..ya, spout-end
// apron (with the collector and spout) yb..ys1, right piece yr0..yr1.
yl0 = clearance;
yj = (yl0 + ys1) / 2;
ya = yj - clearance / 2;
yb = yj + clearance / 2;
yr0 = ys1 + clearance;
yr1 = sill_length - clearance;
// An upstream gutter sits lap_step above the next one, so its tongue (tip
// lap_t thick, underside lifting at lift_angle) clears that floor.
lap_step = clearance + lap * (tan(lift_angle) + 0.1) + lap_t;

// Left gutter: one run from gtop at the wall to the collector floor at the
// spout, stepping down lap_step at the joint. The ridge and front slope are
// single surfaces across the joint; the front slope falls only as far as
// f_min by the spout.
gl = (gtop - lap_step - fc) / (spout_y - yl0);
function r_left(y) = gtop - (y - yl0) * gl + ridge_h;
f_spout = f_min + 0.2;
fl_s = (gtop - 0.5 - f_spout) / (spout_y - yl0);
function f_left(y) = gtop - 0.5 - (y - yl0) * fl_s;

// Plinth round the tap, local y from its left edge (over the spout's right wall).
tap_x = tap_gap + tap_base_d / 2;
pl_y = spout_y + wall_t + chan_w_spout - 1;
pl_w = tap_y + tap_base_d / 2 + plinth_right - pl_y;
pl_x1 = tap_x + tap_base_d / 2 + plinth_front;
pl_tx = tan(plinth_fall_x);
pl_ty = tan(plinth_fall_y);

// Right piece: gutter from gtop at the mullion down to lap_step above the
// collector's weir, where its tongue laps in. Under the plinth (to ypb) the
// top falls back into the gutter; beyond, the front slope falls as far as
// f_min toward the plinth.
gr_0 = fc + weir + lap_step;
gr = (gtop - gr_0) / (yr1 - yr0);
function g_right(y) = gr_0 + (y - yr0) * gr;
function band_top(x, y) = g_right(y) + (x - x_in) * tan(cross_back);
ypb = pl_y + pl_w + 2;
fr_s = min(gr, (gtop - 0.5 - f_spout) / (yr1 - ypb));
function f_right(y) = gtop - 0.5 - (yr1 - y) * fr_s;

// Plinth top plane, set so it rests on the spout's right wall or the right
// piece's top, whichever is higher, and drips onto them.
function pl_rel(x, y) = y * pl_ty + (x - plinth_back) * pl_tx;
pl_z0 = plinth_t + max(concat(
    [for (x = [plinth_back, spout_reach]) fc + spout_wall_h - pl_rel(x, 0)],
    [for (x = [plinth_back, xa1], y = [yr0, pl_y + pl_w]) band_top(x, y) - pl_rel(x, y - pl_y)]));
function plinth_top(x, y) = pl_z0 + pl_rel(x, y);
pl_hole = tap_body_d / 2 + 0.7;

assert(rib_count % plate_segments == 0, "plate joins must land on rib centres");
assert(nose + tap_room <= tap_gap && xa1 + tap_room <= tap_gap, "plate or apron reaches the tap");
assert(spout_y + spout_w_out + tap_room <= tap_y - tap_base_d / 2, "spout hits the tap base");
assert(spout_reach > notch[1] + 10, "spout must reach past the bowl edge");
assert(notch[0] < strip_width && notch[1] > strip_width + 4, "rim notch must span the rim");
assert(nose + 1 < x_g, "ridge must stand clear of the plate's nose");
assert(f_right(ypb) >= f_min, "right front slope too low");
assert(g_right(ys1 - lap) - (fc + weir + clearance + lap * tan(lift_angle)) >= lap_t - 0.05, "right tongue too thin");
assert(pl_z0 - plinth_t > z0 + tap_base_h + 2, "plinth sits on the tap base");

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

// Solid over x0..x1, y0..y1, between the surfaces z = lo(x, y) and hi(x, y)
// (planes, so every face is flat).
module prism(x0, x1, y0, y1, lo, hi) {
    polyhedron(
        points = [[x0, y0, lo(x0, y0)], [x1, y0, lo(x1, y0)], [x1, y1, lo(x1, y1)], [x0, y1, lo(x0, y1)],
                  [x0, y0, hi(x0, y0)], [x1, y0, hi(x1, y0)], [x1, y1, hi(x1, y1)], [x0, y1, hi(x0, y1)]],
        faces = [[0, 1, 2, 3], [4, 7, 6, 5], [0, 4, 5, 1], [1, 5, 6, 2], [2, 6, 7, 3], [3, 7, 4, 0]]);
}

flat = function(x, u) z0;
lifted = function(x, u) lift(x);

// Apron cross-section over y0..y1: upstand, gutter floor g(y), ridge r(y),
// front slope starting at f(y) and falling front_fall to the front edge over
// the bowl. g, r and f are linear in y.
module strip(y0, y1, g, r, f) {
    fs = function(x, y) f(y) - (x - x_s) * tf;
    prism(xg0, x_in + 0.01, y0, y1, flat, function(x, y) -1);
    prism(x_in, x_s, y0, y1, flat, function(x, y) g(y));
    prism(x_g, x_s, y0, y1, flat, function(x, y) r(y));
    prism(x_s - 0.01, xr0, y0, y1, flat, fs);
    prism(xr0, xa1, y0, y1, lifted, fs);
}

// End wall at y0..y1: 1 mm under the plate's nose over the gutter, up to the
// ridge, and end_h above the front slope.
module end_wall(y0, y1, r, f) {
    prism(x_in, x_g, y0, y1, flat, function(x, y) -1);
    prism(x_g, x_s, y0, y1, flat, function(x, y) r);
    prism(x_s - 0.01, xr0, y0, y1, flat, function(x, y) f - (x - x_s) * tf + end_h);
    prism(xr0, xa1, y0, y1, lifted, function(x, y) f - (x - x_s) * tf + end_h);
}

// Tongue over the next gutter downstream, from y_root to y_tip. Its
// underside sits clearance above the floor `under` at the joint (y_j) and
// lifts at lift_angle toward the tip; its top carries on the gutter `top`.
module tongue(y_root, y_tip, y_j, under, top) {
    sgn = sign(y_tip - y_root);
    prism(x_in + clearance, x_g - clearance, min(y_root, y_tip), max(y_root, y_tip),
          function(x, y) under + clearance + (y - y_j) * sgn * tan(lift_angle), top);
}

// Left aprons in the installed frame. Seg 1 (wall end): end wall, tongue
// over seg 0's gutter. Seg 0 (spout end): gutter into the collector, which is
// open on the right for the right piece's tongue, and the spout.
module apron(seg) {
    g1 = function(y) gtop - (y - yl0) * gl;
    g0 = function(y) g1(y) - lap_step;
    if (seg == 1) {
        strip(yl0, ya, g1, function(y) r_left(y), function(y) f_left(y));
        end_wall(yl0, yl0 + wall_t, r_left(yl0), f_left(yl0));
        tongue(ya - 0.01, yb + lap, yb, g0(yb), function(x, y) g1(y));
    } else {
        strip(yb, spout_y + 0.01, g0, function(y) r_left(y), function(y) f_left(y));
        prism(xg0, x_in + 0.01, spout_y, ys1, flat, function(x, y) -1);
        prism(x_in, x_g, spout_y, ys1, flat, function(x, y) fc);
        // The floor rises weir toward the open end so nothing runs back out.
        prism(x_in, x_g, ys1 - wall_t, ys1, flat, function(x, y) fc + weir * (y - ys1 + wall_t) / wall_t);
        difference() {
            prism(x_g - 0.01, spout_reach, spout_y, ys1, flat, function(x, y) fc + spout_wall_h);
            hull() {
                translate([x_in, spout_y + wall_t, fc]) cube([0.01, chan_w_spout, big]);
                translate([spout_reach + 1, spout_y + wall_t, spout_floor(spout_reach + 1)]) cube([0.01, chan_w_spout, big]);
            }
            // Rim notch: 60° sides, its top bridged.
            translate([0, spout_y - 1, 0]) extrude_y(spout_w_out + 2) polygon([[notch[0], z0 - 1], [notch[1], z0 - 1],
                [notch_top[1], z0 + notch_h], [notch_top[0], z0 + notch_h]]);
        }
    }
}

// Right piece in the installed frame: tongue into the collector, the band
// under the plinth to ypb, then gutter, ridge and front slope to the mullion.
module right_piece() {
    tongue(yr0 + 0.01, ys1 - lap, ys1, fc + weir, function(x, y) band_top(x, y));
    prism(xg0, x_in + 0.01, yr0, ypb + 0.01, flat, function(x, y) -1);
    prism(x_in, xr0, yr0, ypb + 0.01, flat, function(x, y) band_top(x, y));
    prism(xr0, xa1, yr0, ypb + 0.01, lifted, function(x, y) band_top(x, y));
    strip(ypb, yr1, function(y) g_right(y), function(y) g_right(y) + ridge_h, function(y) f_right(y));
    end_wall(yr1 - wall_t, yr1, g_right(yr1) + ridge_h, f_right(yr1));
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
// tap's neck). It rests on the spout's right wall or the right piece and the
// tap's base flange, and drains off its back and left edges into the spout
// and onto the right piece. Back half: x up to the tap centre. Front half: sits 0.3 mm higher
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
            if (half == 0) under_plinth(max(xa, xa1 + clearance), xm, pl_w - wall_t, pl_w, ds);
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
function y_start(p, seg) = p == "left" ? (seg == 1 ? yl0 : yb) : p == "right" ? yr0 : p == "plinth" ? pl_y : clearance;
function p_len(p, seg) = p == "plate" ? plate_len : p == "left" ? (seg == 1 ? ya - yl0 : ys1 - yb)
                       : p == "right" ? yr1 - yr0 : pl_w;
function p_list(p) = p == "left" || p == "plinth" ? (segment < 0 ? [0, 1] : [segment])
                   : p == "plate" && segment < 0 && test_slice == 0 ? [0, 1, 2] : [segment];

// Strip pieces are built in the installed frame. Their test slice is the
// spout end (with the tongue): the last test_slice mm of the spout-end apron,
// the first of the right piece.
module strip_body(p, seg) {
    y0 = y_start(p, seg);
    len = p_len(p, seg);
    ts0 = p == "right" ? 0 : len - test_slice;
    if (test_slice > 0 && is_undef($section_at))
        translate([0, -ts0, 0]) keep_y(ts0 - lap - 1, ts0 + test_slice + lap + 1) translate([0, -y0, 0]) children();
    else print_cut(len, 0) translate([0, -y0, 0]) children();
}

module body(p, seg) {
    if (p == "plate") print_cut(plate_len, test_slice, plate_segments, seg) plate();
    else if (p == "left") strip_body(p, seg) apron(seg);
    else if (p == "right") strip_body(p, seg) right_piece();
    else plinth_half(seg);
}

module place(p, seg) {
    translate([0, y_start(p, seg), 0]) children();
}

// One piece on the bed. Plate and strip pieces: flat side down. Plinth:
// upside down on its top (both halves). A piece longer than the bed is turned to fit.
module print_piece(p, seg) {
    y0 = p == "plate" && test_slice == 0 && seg >= 0 ? plate_len / plate_segments * seg : 0;
    plen = test_slice > 0 ? test_slice : p == "plate" && seg >= 0 ? plate_len / plate_segments : p_len(p, seg);
    n = [-pl_tx, -pl_ty, 1] / norm([-pl_tx, -pl_ty, 1]);
    if (p == "plinth")
        translate([0, 0, n * [plinth_back, 0, pl_z0 + (seg == 1 ? plinth_t + clearance : 0)]]) rotate(a = acos(-n[2]), v = cross(n, [0, 0, -1])) body(p, seg);
    else rotate([0, 0, plen > bed - 5 ? diag_angle : 0]) translate([0, -plen / 2, 0]) {
        if (p == "plate") translate([0, -y0, 0]) body(p, seg);
        else translate([0, 0, -z0]) body(p, seg);
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
