include <BOSL2/std.scad>;

// =====================================
// Paramètres principaux
// =====================================
largeur   = 170;   // mm (X)
longueur  = 270;   // mm (Y)
hauteur   = 35;    // mm (Z)
epaisseur = 2;     // mm
rayon     = 2;     // arrondi extérieur

origine = [0,0,0];

// =====================================
// Paramètres couvercle
// =====================================
jeu_couvercle      = 0.35;
hauteur_couvercle  = 8;
ep_couvercle       = 2;
profondeur_emboit  = 6;

// =====================================
// Paramètres clips
// =====================================
clip_largeur     = 12;
clip_epaisseur   = 1.6;
clip_hauteur     = 5;
clip_bosse       = 0.8;
clip_z           = 2.5;

// =====================================
// Paramètres empilage
// =====================================
stack_plot_size    = 10;
stack_plot_height  = 2;
stack_offset_coin  = 8;
stack_jeu          = 0.4;

module clip_x() {
    union() {
        cuboid([clip_largeur, clip_epaisseur, clip_hauteur], anchor=BOTTOM+LEFT+FRONT);
        translate([0, -clip_bosse, clip_hauteur-1.4])
            cuboid([clip_largeur, clip_bosse, 1.4], anchor=BOTTOM+LEFT+FRONT);
    }
}

module clip_y() {
    union() {
        cuboid([clip_epaisseur, clip_largeur, clip_hauteur], anchor=BOTTOM+LEFT+FRONT);
        translate([-clip_bosse, 0, clip_hauteur-1.4])
            cuboid([clip_bosse, clip_largeur, 1.4], anchor=BOTTOM+LEFT+FRONT);
    }
}

module couvercle_bosl2(box_size=[largeur,longueur,hauteur], wall=epaisseur, r=rayon) {
    lx = box_size[0];
    ly = box_size[1];

    ext_x = lx + 2*wall + 2*jeu_couvercle;
    ext_y = ly + 2*wall + 2*jeu_couvercle;

    difference() {
        cuboid([ext_x, ext_y, hauteur_couvercle], rounding=r, anchor=BOTTOM+LEFT+FRONT);

        // Jupe intérieure
        translate([ep_couvercle, ep_couvercle, ep_couvercle])
            cuboid([
                ext_x - 2*ep_couvercle,
                ext_y - 2*ep_couvercle,
                profondeur_emboit + 0.1
            ], rounding=max(r-ep_couvercle,0), anchor=BOTTOM+LEFT+FRONT);

        // Encoches d'empilage sur le dessus
        for (x = [stack_offset_coin + wall + jeu_couvercle,
                  ext_x - stack_offset_coin - (stack_plot_size + stack_jeu) - wall - jeu_couvercle])
        for (y = [stack_offset_coin + wall + jeu_couvercle,
                  ext_y - stack_offset_coin - (stack_plot_size + stack_jeu) - wall - jeu_couvercle])
            translate([x, y, hauteur_couvercle - stack_plot_height])
                cuboid([
                    stack_plot_size + stack_jeu,
                    stack_plot_size + stack_jeu,
                    stack_plot_height + 0.1
                ], anchor=BOTTOM+LEFT+FRONT);
    }

    // Clips internes
    translate([(ext_x - clip_largeur)/2, ep_couvercle + 0.2, clip_z])
        clip_x();

    translate([(ext_x - clip_largeur)/2, ext_y - ep_couvercle - 0.2, clip_z])
        mirror([0,1,0]) clip_x();

    translate([ep_couvercle + 0.2, (ext_y - clip_largeur)/2, clip_z])
        clip_y();

    translate([ext_x - ep_couvercle - 0.2, (ext_y - clip_largeur)/2, clip_z])
        mirror([1,0,0]) clip_y();
}

// Affichage
couvercle_bosl2();