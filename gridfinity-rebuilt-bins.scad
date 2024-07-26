// ===== INFORMATION ===== //
/*
 IMPORTANT: rendering will be better for analyzing the model if fast-csg is enabled. As of writing, this feature is only available in the development builds and not the official release of OpenSCAD, but it makes rendering only take a couple seconds, even for comically large bins. Enable it in Edit > Preferences > Features > fast-csg
 the magnet holes can have an extra cut in them to make it easier to print without supports
 tabs will automatically be disabled when gridz is less than 3, as the tabs take up too much space
 base functions can be found in "gridfinity-rebuilt-utility.scad"
 examples at end of file

 BIN HEIGHT
 the original gridfinity bins had the overall height defined by 7mm increments
 a bin would be 7*u millimeters tall
 the lip at the top of the bin (3.8mm) added onto this height
 The stock bins have unit heights of 2, 3, and 6:
 Z unit 2 -> 7*2 + 3.8 -> 17.8mm
 Z unit 3 -> 7*3 + 3.8 -> 24.8mm
 Z unit 6 -> 7*6 + 3.8 -> 45.8mm

https://github.com/kennetek/gridfinity-rebuilt-openscad

*/

// ===== PARAMETERS ===== //

/* [Setup Parameters] */
$fa = 8;
$fs = 0.25;

/* [General Settings] */
// number of bases along x-axis
gridx = 3;
// number of bases along y-axis
gridy = 2;
// bin height. See bin height information and "gridz_define" below.
gridz = 6;
// wall width. Default: 0.95
Wall_Width = 0.95;
Nozzle_Diameter = 0.4; // [0.0:0.1:1.0]
Layer_Height = 0.20; // [0.00:0.01:1.00]
Overhang = 60; // [0:90]
Bottom_Thickness = 5;
function d_wall() = Wall_Width;
function nozzle() = Nozzle_Diameter;
function layer_height() = Layer_Height;
function overhang_angle() = 90-Overhang;
function bin_bottom_thickness() = layer_height()*Bottom_Thickness;

/* [Linear Compartments] */
// number of X Divisions (set to zero to have solid bin)
divx = [0, 0];
// number of Y Divisions (set to zero to have solid bin)
divy = [0, 0];
// tab height factor
tabh = 1; // [0.00:0.01:2.00]
x_scale = 0; // [0.0:0.1:1.0]

/* [Socket Compartments] */
// number of cylindrical X Divisions (mutually exclusive to Linear Compartments)
cdivx = 0;
// number of cylindrical Y Divisions (mutually exclusive to Linear Compartments)
cdivy = 0;
// orientation
c_orientation = 2; // [0: x direction, 1: y direction, 2: z direction]
// diameter of cylindrical cut outs
cd = [2.5, 3.9, 4.9, 6.75, 8.35, 12.5]; // [0.01:20]
// cylinder height
ch = 1;
// spacing to lid
c_depth = 1;
// chamfer around the top rim of the holes
c_chamfer = 0.5;
// chamfer around the top rim of the holes
c_style = "circle"; // [circle,square,hexagon]
// chamfer around the top rim of the holes
c_depth_style = "lid"; // [lid,bottom]

/* [Height] */
// determine what the variable "gridz" applies to based on your use case
gridz_define = 0; // [0:gridz is the height of bins in units of 7mm increments - Zack's method,1:gridz is the internal height in millimeters, 2:gridz is the overall external height of the bin in millimeters]
// overrides internal block height of bin (for solid containers). Leave zero for default height. Units: mm
height_internal = 0;
// snap gridz height to nearest 7mm increment
enable_zsnap = false;

/* [Features] */
// the type of tabs
style_tab = 1; //[0:Full,1:Auto,2:Left,3:Center,4:Right,5:None]
// how should the top lip act
style_lip = 0; //[0: Regular lip, 1:remove lip subtractively, 2: remove lip and retain height]
// scoop weight percentage. 0 disables scoop, 1 is regular scoop. Any real number will scale the scoop.
scoop = 1; //[0:0.01:2]
// only cut magnet/screw holes at the corners of the bin to save uneccesary print time
only_corners = false;

/* [Base] */
style_hole = 4; // [0:no holes, 1:magnet holes only, 2: magnet and screw holes - no printable slit, 3: magnet and screw holes - printable slit, 4: Gridfinity Refined hole - no glue needed]
// number of divisions per 1 unit of base along the X axis. (default 1, only use integers. 0 means automatically guess the right division)
div_base_x = 0;
// number of divisions per 1 unit of base along the Y axis. (default 1, only use integers. 0 means automatically guess the right division)
div_base_y = 0;

include <gridfinity-rebuilt-utility.scad>

// ===== IMPLEMENTATION ===== //

//color("lightgrey")
{
    gridfinityInit(gridx, gridy, height(gridz, gridz_define, style_lip, enable_zsnap), height_internal, sl=style_lip) {
        if (divx.x > 0 && divy.x > 0) {
            cutEqual(n_divx = divx.x, n_divy = divy.x, style_tab = style_tab, scoop_weight = scoop, tab_height = d_tabh*tabh);
            //cutProgression(n_divx = divx, n_divy = divy, style_tab = style_tab, scoop_weight = scoop, tab_height = d_tabh*tabh, x_scale=x_scale);
            // cut( 0/12, 0, 8/12, 1, style_tab, tab_height=d_tabh*tabh);
            // cut( 8/12, 0, 7/12, 1, style_tab, tab_height=d_tabh*tabh);
            // cut(15/12, 0, 7/12, 1, style_tab, tab_height=d_tabh*tabh);
            // cut(22/12, 0, 7/12, 1, style_tab, tab_height=d_tabh*tabh);
            // cut(29/12, 0, 7/12, 1, style_tab, tab_height=d_tabh*tabh);
        } else if (cdivx > 0 && cdivy > 0) {
            cutCylinders(n_divx=cdivx, n_divy=cdivy, cylinder_diameter=cd, cylinder_height=ch, cutout_depth=c_depth, orientation=c_orientation, chamfer=c_chamfer, style=c_style);
        }
    }
    
    gridfinityBase(gridx, gridy, l_grid, div_base_x, div_base_y, style_hole, only_corners=only_corners);
}


// ===== EXAMPLES ===== //

// 3x3 even spaced grid
/*
gridfinityInit(3, 3, height(6), 0, 42) {
	cutEqual(n_divx = 3, n_divy = 3, style_tab = 0, scoop_weight = 0);
}
gridfinityBase(3, 3, 42, 0, 0, 1);
*/

// Compartments can be placed anywhere (this includes non-integer positions like 1/2 or 1/3). The grid is defined as (0,0) being the bottom left corner of the bin, with each unit being 1 base long. Each cut() module is a compartment, with the first four values defining the area that should be made into a compartment (X coord, Y coord, width, and height). These values should all be positive. t is the tab style of the compartment (0:full, 1:auto, 2:left, 3:center, 4:right, 5:none). s is a toggle for the bottom scoop.
/*
gridfinityInit(3, 3, height(6), 0, 42) {
    cut(x=0, y=0, w=1.5, h=0.5, t=5, s=0);
    cut(0, 0.5, 1.5, 0.5, 5, 0);
    cut(0, 1, 1.5, 0.5, 5, 0);

    cut(0,1.5,0.5,1.5,5,0);
    cut(0.5,1.5,0.5,1.5,5,0);
    cut(1,1.5,0.5,1.5,5,0);

    cut(1.5, 0, 1.5, 5/3, 2);
    cut(1.5, 5/3, 1.5, 4/3, 4);
}
gridfinityBase(3, 3, 42, 0, 0, 1);
*/

// Compartments can overlap! This allows for weirdly shaped compartments, such as this "2" bin.
/*
gridfinityInit(3, 3, height(6), 0, 42)  {
    cut(0,2,2,1,5,0);
    cut(1,0,1,3,5);
    cut(1,0,2,1,5);
    cut(0,0,1,2);
    cut(2,1,1,2);
}
gridfinityBase(3, 3, 42, 0, 0, 1);
*/

// Areas without a compartment are solid material, where you can put your own cutout shapes. using the cut_move() function, you can select an area, and any child shapes will be moved from the origin to the center of that area, and subtracted from the block. For example, a pattern of three cylinderical holes.
/*
gridfinityInit(3, 3, height(6), 0, 42) {
    cut(x=0, y=0, w=2, h=3);
    cut(x=0, y=0, w=3, h=1, t=5);
    cut_move(x=2, y=1, w=1, h=2)
        pattern_linear(x=1, y=3, sx=42/2)
            cylinder(r=5, h=1000, center=true);
}
gridfinityBase(3, 3, 42, 0, 0, 1);
*/

// You can use loops as well as the bin dimensions to make different parametric functions, such as this one, which divides the box into columns, with a small 1x1 top compartment and a long vertical compartment below
/*
gx = 3;
gy = 3;
gridfinityInit(gx, gy, height(6), 0, 42) {
    for(i=[0:gx-1]) {
        cut(i,0,1,gx-1);
        cut(i,gx-1,1,1);
    }
}
gridfinityBase(gx, gy, 42, 0, 0, 1);
*/

// Pyramid scheme bin
/*
gx = 4.5;
gy = 4;
gridfinityInit(gx, gy, height(6), 0, 42) {
    for (i = [0:gx-1])
    for (j = [0:i])
    cut(j*gx/(i+1),gy-i-1,gx/(i+1),1,0);
}
gridfinityBase(gx, gy, 42, 0, 0, 1);
*/
