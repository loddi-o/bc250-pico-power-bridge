// =====================================================================
//  Adapter for a 12 mm button (M12x0.75) in the REDUX faceplate
//  Fits in the hexagonal counterbore behind the button hole and is glued.
//  Dimensions taken from the faceplate file:
//   - counterbore: rounded hexagon, 23.46 mm across flats, corner
//     radius about 5 mm, 6.0 mm deep
//   - front hole: 18.0 mm diameter in a 0.8 mm skin
//  The button goes in from the front, the nut tightens from behind.
//  Print with the large face (the back) on the bed, no supports.
// =====================================================================

clearance    = 0.20;   // gap per side between adapter and counterbore (glue)
flats        = 23.46;  // counterbore: distance across flats
corner_r     = 5.3;    // counterbore: corner radius
depth        = 6.0;    // counterbore: depth
front_hole   = 18.0;   // hole in the front skin
skin         = 0.8;    // front skin thickness
button_hole  = 12.4;   // clearance for the button's M12 thread
recess       = 0.1;    // how far it sits below both faces
$fn = 96;

module rounded_hexagon(af, rc) {
    // hexagon with "af" across flats and corners of radius "rc"
    offset(r=rc) circle(r=(af/2 - rc)/cos(30), $fn=6);
}

module adapter() {
    difference() {
        union() {
            // body inside the counterbore (from the back to its bottom)
            linear_extrude(depth - recess)
                offset(delta=-clearance) rounded_hexagon(flats, corner_r);
            // ring that fills the front hole (flush with the front)
            translate([0, 0, depth - recess - 0.01])
                cylinder(d=front_hole - 2*clearance, h=skin + 0.01);
        }
        translate([0, 0, -1]) cylinder(d=button_hole, h=20);
        // lead-in chamfer from the front, so the thread does not catch
        translate([0, 0, depth - recess + skin - 0.6]) cylinder(d1=button_hole, d2=button_hole + 1.2, h=0.61);
    }
}

adapter();
echo(str("Total thickness: ", depth - recess + skin, " mm (the button accepts up to 8 mm)"));
