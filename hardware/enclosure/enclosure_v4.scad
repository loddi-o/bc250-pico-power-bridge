// =====================================================================
//  Enclosure v4 · Pico 2 WH + perfboard (BC-250 power bridge project)
//  Simple two-part box, held closed by ONE zip tie.
//
//  - Seam: on the short ends it runs at the top face of the perfboard;
//    on the long sides it drops to wire height, so the wires are clamped
//    between the two halves when the zip tie is pulled tight.
//  - Wires: one groove for every column C1-C20 on both long sides,
//    except C11-C12 where the zip tie passes. Half groove in the base,
//    half in the lid, with a small tooth that bites into the insulation.
//  - Zip tie: runs through a tunnel inside the base (the bottom stays
//    flat, so it can be glued) and in a recess on the sides and the top.
//  - Mounting: flat bottom for glue + 2 holes for M3 heat-set inserts,
//    open from below.
//  Units: mm. Looking at the USB end: right = low y, left = high y.
// =====================================================================

part = "all";   // base | lid | lid_view | test_piece | all | exploded

// ---------- the assembly (measured) ----------
board_l = 54.0;    // perfboard length
board_w = 23.0;    // width
board_t = 1.6;     // thickness
height  = 15.0;    // from the copper side to the top of the Pico / USB
pitch   = 2.54;

// ---------- box ----------
clearance = 0.5;   // gap between board and walls
wall      = 2.0;
floor_t   = 2.0;
bay       = 8.0;   // space below the board
headroom  = 2.5;   // gap above the highest point (same as v3.1)
roof      = 2.0;
radius    = 2.0;
protrusion= 3.0;   // how far solder joints may stick out below the board
margin    = 0.8;   // gap between solder joints and the thickest wires
ledge     = 1.6;   // small ledge at the short ends, under the board edge
lip       = 1.3;   // how far the lid covers the board at the short ends
lip_gap   = 0.1;   // gap between lip and board

// ---------- wires ----------
wire_solid = 1.1;  // solid-core wire: outer diameter incl. insulation
wire_cable = 2.0;  // button cable
bite_solid = 0.10; // how much smaller than the wire the closed hole is
bite_cable = 0.25;
tooth_solid = 0.15;  // tooth in the lid: extra bite, only mid-wall
tooth_cable = 0.20;  // (solid-core insulation is thin: go easy)
tooth_l     = 0.6;
tol         = 0.05;
CABLES_R = [6, 14, 16, 18];     // 2 mm grooves on the right side
CABLES_L = [6, 14, 16, 18];     // same positions on the left (spare)
ZIPTIE_ZONE = [11, 12];         // no grooves there

// ---------- zip tie ----------
ziptie_w = 3.6;    // zip tie width
ziptie_t = 1.3;    // thickness
recess   = 0.6;    // recess depth on the sides and top

// ---------- M3 inserts for mounting (from below) ----------
insert_d = 4.0;  insert_h = 5.5;  boss_d = 8.0;

// ---------- openings (same as v3.1) ----------
usb_w = 13.0;  usb_h = 9.5;
win_x0 = 4.0;  win_x1 = 19.0;  win_w = 13.0;      // BOOTSEL / LED
debug_l = 9.0; debug_w = 11.0;                    // debug connector
nose_t = 1.2;  nose_w = 6.0;  nose_h = 1.5;       // alignment on the short ends
$fn = 40;

// ---------- derived dimensions ----------
in_l = board_l + 2*clearance;   in_w = board_w + 2*clearance;
out_l = in_l + 2*wall;          out_w = in_w + 2*wall;
z_brd   = floor_t + bay;                 // copper side of the board
z_split = z_brd + board_t;               // seam on the short ends
z_top   = z_brd + height + headroom;     // inner ceiling
h_tot   = z_top + roof;
z_s     = z_brd - protrusion - margin - wire_cable/2;   // seam on long sides = wire centre
m_l = (board_l - 19*pitch)/2;
function cx(c) = wall + clearance + m_l + (c-1)*pitch;
pico_edge = wall + clearance + (board_l - 51)/2;
yc = out_w/2;
x_tie = cx((ZIPTIE_ZONE[0] + ZIPTIE_ZONE[1]) / 2);
lf    = ziptie_w + 0.8;                  // width of tunnel and recesses
z_tun = 0.8;  h_tun = ziptie_t + 0.5;    // tunnel in the base
X_INS = [wall + 3.2, out_l - wall - 3.2];
lip_x = clearance + lip;

function contains(v, x) = len([for (e = v) if (e == x) 1]) > 0;
POSITIONS = [for (c = [1:20]) if (!contains(ZIPTIE_ZONE, c)) c];
function diam(side, c) = contains(side == 0 ? CABLES_R : CABLES_L, c) ? wire_cable : wire_solid;
function bite(d) = (d == wire_cable) ? bite_cable : bite_solid;
function tooth(d) = (d == wire_cable) ? tooth_cable : tooth_solid;

module rounded(l, w, h, r) {
    hull() for (x=[r, l-r], y=[r, w-r]) translate([x, y, 0]) cylinder(r=r, h=h);
}
// truncated cone along y through a long wall: starts "start" mm from
// the outer face and goes inwards for "l" mm
module tube(side, x, z, r1, r2, start, l) {
    if (side == 0) translate([x, start, z]) rotate([-90, 0, 0]) cylinder(r1=r1, r2=r2, h=l);
    else           translate([x, out_w - start, z]) rotate([90, 0, 0]) cylinder(r1=r1, r2=r2, h=l);
}
// one groove: in the base, a half circle centred on the seam; in the lid
// the circle is lowered by (bite + 2 tol), so with the box closed the hole
// is "bite" smaller than the wire; mid-wall the tooth bites even more.
module groove(side, c, upper) {
    d = diam(side, c);  r = d/2 + tol;  x = cx(c);
    zc = upper ? z_s - bite(d) - 2*tol : z_s;
    if (!upper) tube(side, x, zc, r, r, -1, wall + 2);
    else {
        a = wall/2 - tooth_l/2;
        tube(side, x, zc, r, r, -1, a + 1);
        tube(side, x, zc, r - tooth(d), r - tooth(d), a - 0.01, tooth_l + 0.02);
        tube(side, x, zc, r, r, a + tooth_l, wall - a - tooth_l + 1);
    }
    // chamfers on both faces, so the wire is not cut when bent
    tube(side, x, zc, r + 0.35, r, -0.01, 0.6);
    tube(side, x, zc, r, r + 0.35, wall - 0.59, 0.6);
}
module ziptie_tunnel() {
    translate([x_tie - lf/2, -1, z_tun]) cube([lf, out_w + 2, h_tun]);
}
module side_recess(z0, z1) {
    for (y = [-1, out_w - recess]) translate([x_tie - lf/2, y, z0]) cube([lf, recess + 1, z1 - z0]);
}
module insert_holes() {
    for (x = X_INS) translate([x, yc, -0.01]) {
        cylinder(d=insert_d, h=insert_h + 0.01);
        cylinder(d1=insert_d + 1.0, d2=insert_d, h=0.5);
    }
}

// =============================== BASE ===============================
module base_box() {
    difference() {
        union() {
            rounded(out_l, out_w, z_s, radius);                    // lower part
            intersection() {                                       // tall short ends
                rounded(out_l, out_w, z_split, radius);
                union() {
                    cube([wall, out_w, z_split]);
                    translate([out_l - wall, 0, 0]) cube([wall, out_w, z_split]);
                }
            }
            for (x = [wall/2, out_l - wall/2])                     // alignment noses
                translate([x - nose_t/2, yc - nose_w/2, z_split - 0.01]) cube([nose_t, nose_w, nose_h + 0.01]);
        }
        translate([wall, wall, floor_t]) cube([in_l, in_w, 100]);
        for (side = [0, 1], c = POSITIONS) groove(side, c, false);
        ziptie_tunnel();
        side_recess(z_tun, z_s + 1);
        insert_holes();
    }
    difference() {
        union() {
            // support ledges at the short ends
            translate([wall - 0.01, wall - 0.01, floor_t - 0.01])
                cube([clearance + ledge + 0.01, in_w + 0.02, z_brd - floor_t + 0.01]);
            translate([out_l - wall - clearance - ledge, wall - 0.01, floor_t - 0.01])
                cube([clearance + ledge + 0.01, in_w + 0.02, z_brd - floor_t + 0.01]);
            // rib over the zip-tie tunnel
            translate([x_tie - lf/2 - 1.2, wall - 0.01, floor_t - 0.01])
                cube([lf + 2.4, in_w + 0.02, z_tun + h_tun + 0.8 - floor_t + 0.01]);
            // insert bosses
            for (x = X_INS) translate([x, yc, 0]) cylinder(d=boss_d, h=insert_h + 1.2);
        }
        ziptie_tunnel();
        insert_holes();
    }
}

// ================================ LID ================================
// modelled in its assembled position
module lid_box() {
    difference() {
        union() {
            translate([0, 0, z_split]) rounded(out_l, out_w, h_tot - z_split, radius);
            // long walls that drop down to the wire seam
            for (y = [0, out_w - wall])
                translate([wall + 0.2, y, z_s]) cube([out_l - 2*wall - 0.4, wall, z_split - z_s + 0.01]);
        }
        translate([wall, wall, z_s - 1]) cube([in_l, in_w, z_top - z_s + 1]);
        for (side = [0, 1], c = POSITIONS) groove(side, c, true);
        for (x = [wall/2, out_l - wall/2])                         // slots for the noses
            translate([x - nose_t/2 - 0.2, yc - nose_w/2 - 0.2, z_split - 0.01]) cube([nose_t + 0.4, nose_w + 0.4, nose_h + 0.25]);
        side_recess(z_s - 1, h_tot + 1);                           // zip tie
        translate([x_tie - lf/2, -1, h_tot - recess]) cube([lf, out_w + 2, 1]);
        translate([-1, yc - usb_w/2, z_brd + height - usb_h + 1]) cube([wall + 3, usb_w, 100]);   // USB
        translate([pico_edge + win_x0, yc - win_w/2, z_top - 1]) cube([win_x1 - win_x0, win_w, roof + 2]);
        translate([pico_edge + 51 - debug_l, yc - debug_w/2, z_top - 1]) cube([debug_l + 1, debug_w, roof + 2]);
    }
    // lips that hold the board down at the short ends (attached to the walls)
    for (x = [wall - 0.01, out_l - wall - lip_x + 0.01])
        translate([x, wall - 0.01, z_split + lip_gap]) cube([lip_x, in_w + 0.02, 1.5]);
}

// ============================ TEST PIECE ============================
// Two small blocks clamped by a small zip tie: channels for
// 1.0 · 1.1 · 1.2 (solid-core) and 2.0 (button cable), same bite and
// same tooth as the box. Use it to check the grip before printing the
// whole enclosure.
TEST_D = [1.0, 1.1, 1.2, 2.0];
TEST_X = [4.5, 10.5, 16.5, 24];
module test_half(upper) {
    L = 29; W = 8; H = 4;
    difference() {
        cube([L, W, H]);
        for (i = [0:3]) {
            d = TEST_D[i]; r = d/2 + tol; m = (d >= 2) ? bite_cable : bite_solid; dt = (d >= 2) ? tooth_cable : tooth_solid;
            zc = upper ? -m - 2*tol : H;
            a = W/2 - tooth_l/2;
            if (!upper) translate([TEST_X[i], -1, zc]) rotate([-90, 0, 0]) cylinder(r=r, h=W + 2);
            else {
                translate([TEST_X[i], -1, zc]) rotate([-90, 0, 0]) cylinder(r=r, h=a + 1);
                translate([TEST_X[i], a - 0.01, zc]) rotate([-90, 0, 0]) cylinder(r=r - dt, h=tooth_l + 0.02);
                translate([TEST_X[i], a + tooth_l, zc]) rotate([-90, 0, 0]) cylinder(r=r, h=W);
            }
        }
        // zip-tie recess (along x, on the outer face)
        translate([-1, W/2 - lf/2, upper ? H - recess : -1]) cube([L + 2, lf, recess + 1]);
        for (x = [-1, L - recess]) translate([x, W/2 - lf/2, -1]) cube([recess + 1, lf, H + 2]);
        // numbers on the side of the lower piece
        if (!upper) for (i = [0:3]) translate([TEST_X[i], 0.4, 0.7]) rotate([90, 0, 0])
            linear_extrude(1) text(str(TEST_D[i]*10), size=1.8, halign="center", font="Liberation Sans:style=Bold");
    }
}

// ============================== OUTPUT ==============================
if (part == "base") base_box();
else if (part == "lid") translate([0, out_w, h_tot]) rotate([180, 0, 0]) lid_box();  // printed upside down
else if (part == "lid_view") lid_box();
else if (part == "test_piece") { test_half(false); translate([0, 20, 4]) rotate([180, 0, 0]) translate([0, -8, 0]) test_half(true); }
else if (part == "exploded") { color("DimGray") base_box(); color("Silver") translate([0, 0, 25]) lid_box(); }
else { color("DimGray") base_box(); color("Silver", 0.7) lid_box(); }

echo(str("Outside: ", out_l, " x ", out_w, " x ", h_tot, " mm"));
echo(str("Wire centres at z = ", z_s, " mm; board copper side at z = ", z_brd, " mm"));
echo(str("Zip tie: ", ziptie_w, " mm wide, at least ", ceil((2*out_w + 2*(h_tot - z_tun) + 30)/10)*10, " mm long"));
