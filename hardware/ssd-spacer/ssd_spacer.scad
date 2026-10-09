// Dummy 2.5" SSD (7 mm) to fill the empty slot of the REDUX case.
// Envelope and holes like a standard SATA SSD (SFF-8201):
// 100 x 69.85 x 7 mm, M3 holes underneath and on the sides at 14 and 90.6 mm from the connector end.
L = 100.0; W = 69.85; H = 7.0;
wall = 2.0; floor_t = 1.2;
hole = 2.6;          // pilot hole for an M3 self-tapping screw into plastic
X = [14.0, 90.6];    // hole distance from the connector end
bottom_inset = 4.07; // bottom holes: distance from the sides
side_z = 3.0;        // side holes: height from the bottom
$fn = 32;
difference() {
    union() {
        difference() {                                   // hollow frame with floor
            cube([L, W, H]);
            translate([wall, wall, floor_t]) cube([L - 2*wall, W - 2*wall, H]);
        }
        for (x = X, y = [bottom_inset, W - bottom_inset])  // bosses under the bottom holes
            translate([x, y, 0]) cylinder(d=7, h=H);
        for (x = X, y = [0, W - 6])                        // reinforcement behind the side holes
            translate([x - 4, y, 0]) cube([8, 6, H]);
        for (x = [L/3, 2*L/3]) translate([x - 1, 0, 0]) cube([2, W, H * 0.6]);   // ribs
    }
    for (x = X, y = [bottom_inset, W - bottom_inset]) translate([x, y, -1]) cylinder(d=hole, h=6);
    for (x = X) translate([x, -1, side_z]) rotate([-90, 0, 0]) cylinder(d=hole, h=W + 2);
}
