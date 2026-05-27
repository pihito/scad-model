// Trou d'aération pour fenêtre
// paramètre pour lisser le cylindre 
$fn=120;

// cylindre de base
d1 = 9;
h1 = 10;

//cylindre haut
d2 = 11;
h2 = 2;

epaisseur = 1;   //épaisseur de la paroi en mm
eps = 0.01; // petit décalage pour éviter les problèmes de boolean

epaisseur_croix = 1; // épaisseur des rectangles de la croix


union() {
    difference() {
    
            union() {
                // Cylindre bas
                cylinder(h = h1, d = d1, center = false);

                // Cylindre haut d2
                translate([0, 0, h1])
                    cylinder(h = h2, d = d2, center = false);
            }

            // Perçage central
            translate([0, 0, -eps])
                cylinder(h = h1 + h2 + 2*eps, d = d1 - 2*epaisseur, center = false);
      }
     // 1er rectangle traversant le diamètre du cylindre d2
    translate([0, 0, h1 + h2/2])
        cube([d2-epaisseur, epaisseur_croix, h2], center = true);

    // 2e rectangle à 90°
    translate([0, 0, h1 + h2/2])
        rotate([0, 0, 90])
            cube([d2-epaisseur, epaisseur_croix, h2], center = true);
}