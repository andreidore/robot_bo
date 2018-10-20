/*  
    Another round corner cube library by towa  
    Version: 2014-10-05  

    rcorn_cube(size, r, f, center)  
        size        : size of the object like in cube-function  
        r as scalar : corner radius of a sphere  
        r[r, h]     : corner radius of a sphere and height of an additional, overlayed cylinder  
        r[r, h, t]  : corner radius of a sphere, height of an additional cylinder and  
                      vertical translation of the cylinder  
        f           : number of facets of sphere and cylinder  
        center      : false if the object should not be centered  

    Examples:  
        translate([0, -60, 0])  
        rcorn_cube([50, 40, 30], 10, 8);  
        translate([0, 0, 0])  
        rcorn_cube([50, 40, 30], [8, 4], 24);  
        translate([0, 60, 0])  
        rcorn_cube([50, 40, 30], [10, 5, -5], 64);  
*/  

// include in your project with "use <rcorn_cube.scad>;"  

difference(){
    
   rcorn_cube([100, 80, 60 ], [10, 5, 5],  fn = 64, center = true);  
   translate([0,0,2]){
       scale(0.95){
           rcorn_cube([100, 80, 60 ], [10, 5, 5],  fn = 64, center = true);  
    
       }
    }
}

function gz(val) = (val > 0) ? val : 0;  

module corner_transl(i, size) {  
    translate(  [(floor(i  ) % 2 == 0) ? -size[0] : size[0],  
                 (floor(i/2) % 2 == 0) ? -size[1] : size[1],  
                 (floor(i/4) % 2 == 0) ? -size[2] : size[2]])  
    children();  
}  

module rcorn_cube(size, r, fn, center = true) {  
    //%cube(size, center = center);                 // check if cube is inside boundaries  
    r       = (len(r) == undef) ? [r] : r;          // force r to be an array  
    sh      = size / 2;                             // vector with half of the object size  
    shlim   = [(r[0] > sh[0]) ? sh[0] : r[0],  
               (r[0] > sh[1]) ? sh[1] : r[0],  
               (r[0] > sh[2]) ? sh[2] : r[0]];      // intersection boundaries  

    // properties of a low resolution sphere  
    rs      = r[0] / cos(90 / ceil(fn / 2));        // radius to adjust a given height of a low resolution sphere  
    redg    = (ceil(fn / 2) % 2 == 0) ? r[0] : rs;  // the edge radius of the low resolution sphere  
    sc      = 360 / fn;                             // corners of a low resolution sphere  

    // horizontal distance the sphere or cylinder has to be moved  
    // inside the object to be in the specified boundaries  
    md      = redg * cos(min(abs(135 % sc), abs(135 % sc - sc), abs(135 % sc + sc)));  
    shm     = [gz(sh[0] - md), gz(sh[1] - md), gz(sh[2] - r[0])];  

    // echo(fn, r, redg, rs, md);                       // debugging  
    hull() {  
        for (i = [0:7]) {  
            translate((center == false) ? sh : [0, 0, 0])  
            corner_transl(i, shm)                       // translate to the eight corners of a cube  
            intersection() {                            // in any case keep box inside boundaries  
                mirror([(floor(i  ) % 2 == 0) ? 0 : 1,  // first corner points towards the middle  
                        (floor(i/2) % 2 == 0) ? 0 : 1,  // in this way all 8 corners are arranged symmetrically  
                                                         0])  
                rotate([0, 0, 45])                      // rotate in such a way that the first corner  
                union() {                               // points towards the middle of sphere and optional cylinder  
                    sphere(r = rs, $fn = fn);  
                    // %sphere(r = redg, $fn = fn);     // compare with a high resolution sphere for debugging  
                    if ((len(r) >= 2) && (r[1] > 0)) {  
                        translate([0, 0, (len(r) >= 3) ? r[2] : 0])  
                        cylinder(h = 2*r[1], r = redg, $fn = fn, center = true);  
                    }  
                }  

                corner_transl(i, shlim/2)               // translate to the eight corners of a cube  
                cube(shlim, center = true);  
            }  
        }  
    }  
}  
