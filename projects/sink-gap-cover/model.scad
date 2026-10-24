// Sink-to-wall gap cover: a strip that sits on the back rim of the sink,
// keys into the gap with a tab, rises against the wall with an upstand, and
// slopes so splashes drain back into the sink instead of down the gap.
//
// Installed frame: x = from the wall toward the sink (wall face at x=0),
// y = along the wall, z = up with z=0 at the top of the sink rim.
use <../../lib/makeit.scad>

/* [Measured] */
length = 600;          // PLACEHOLDER: along the wall, edge to edge of the sink rim
gap_left = 8;          // PLACEHOLDER: wall to rim edge at y=0
gap_right = 8;         // PLACEHOLDER: wall to rim edge at y=length
rim_overlap = 15;      // how far onto the rim the cover reaches (keep < flat part of rim)

/* [Design] */
thickness = 2.4;       // plate thickness at the sink edge (thinnest point)
slope_deg = 4;         // fall toward the sink
upstand_height = 10;   // lip against the wall, above the sloped top
upstand_thickness = 2;
tab_depth = 6;         // how far the locating tab drops into the gap
end_dams = true;       // short walls at both ends so water can't run off sideways
dam_height = 4;        // above the sloped top
dam_thickness = 2;

/* [Print] */
clearance = 0.3;       // per side: off the wall and inside the gap
test_slice = 0;        // >0: only the first N mm from the y=0 end
segments = 1;          // split along y when longer than the bed
segment = -1;          // which piece to export, -1 = all
orient = "installed";  // "print" lays it on its wall-side face: no supports

gap_max = max(gap_left, gap_right);
x0 = clearance;                      // back (wall-side) face
x1 = gap_max + rim_overlap;          // front edge over the sink
fall = tan(slope_deg);
function top_z(x) = thickness + (x1 - x) * fall;

assert(min(gap_left, gap_right) - 2 * clearance >= 1,
       "gap too narrow for a tab: lower clearance or set tab_depth = 0");

// Constant cross-section (x, z), extruded along y.
module extrude_y(len) {
    translate([0, len, 0]) rotate([90, 0, 0]) linear_extrude(len) children();
}

module body() {
    xu = x0 + upstand_thickness;
    extrude_y(length) polygon([
        [x0, 0], [x1, 0], [x1, thickness],
        [xu, top_z(xu)], [xu, top_z(x0) + upstand_height], [x0, top_z(x0) + upstand_height],
    ]);
}

module tab() {
    if (tab_depth > 0) hull() {
        translate([x0, 0, -tab_depth]) cube([gap_left - 2 * clearance, 0.01, tab_depth + thickness / 2]);
        translate([x0, length - 0.01, -tab_depth]) cube([gap_right - 2 * clearance, 0.01, tab_depth + thickness / 2]);
    }
}

module dam_profile() {
    polygon([[x0, 0], [x1, 0], [x1, top_z(x1) + dam_height], [x0, top_z(x0) + dam_height]]);
}

module dams() {
    if (end_dams) {
        extrude_y(dam_thickness) dam_profile();
        translate([0, length - dam_thickness, 0]) extrude_y(dam_thickness) dam_profile();
    }
}

module part() { union() { body(); tab(); dams(); } }

// Wall and sink rim, for previews only.
module context() {
    translate([-8, 0, -15]) cube([8, length, 45]);                    // wall
    translate([gap_left, 0, -15]) cube([x1 - gap_left + 10, length, 15]); // rim, simplified
}

if (orient == "print") {
    // Wall-side face down: every layer is a subset of the one below it.
    translate([0, 0, -x0]) rotate([0, -90, 0])
        print_cut(length, test_slice, segments, segment) part();
} else {
    %print_cut(length, test_slice, segments, segment) context();
    print_cut(length, test_slice, segments, segment) part();
}
