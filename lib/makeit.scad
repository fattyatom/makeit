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
