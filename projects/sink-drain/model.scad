// <PART NAME> — see brief.md for the measurements and where each came from.
// Units: mm. Installed frame: z up; say here what x and y mean for this part.
use <../../lib/makeit.scad>

/* [Measured] */
// Every number copied from brief.md, with its source in the comment.
length = 100;        // hand: tape, along ...

/* [Design] */
thickness = 2.4;

/* [Print] */
clearance = 0.3;     // per side, for parts that slot into something
test_slice = 0;      // >0: only the first N mm, for a quick test fit
segments = 1;        // split along y when longer than the bed
segment = -1;        // which piece to export, -1 = all
orient = "installed"; // "installed" for previews, "print" for export (set by the build)

module part() {
    cube([20, length, thickness]);
}

// Ghost geometry of the surroundings: shows in previews, never exported.
module context() {
}

if (orient == "print") {
    // Rotate so the flattest face is on the bed with minimal overhangs.
    print_cut(length, test_slice, segments, segment) part();
} else {
    %print_cut(length, test_slice, segments, segment) context();
    print_cut(length, test_slice, segments, segment) part();
}
