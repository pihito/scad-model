include <BOSL2-master/std.scad>;

// =====================================
// Paramètres principaux
// =====================================
largeur   = 170;   // mm
longueur  = 270;   // mm
hauteur   = 35;    // mm
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

// =====================================
// Clip unitaire BOSL2
// =====================================
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

// =====================================
// Boîte BOSL2
// =====================================
module boite_bosl2(size=[largeur,longueur,hauteur], wall=epaisseur, r=rayon) {
    lx = size[0];
    ly = size[1];
    lz = size[2];

    translate(origine)
    union() {
        difference() {
            cuboid([lx, ly, lz], rounding=r, anchor=BOTTOM+LEFT+FRONT);

            translate([wall, wall, wall])
                cuboid([
                    lx - 2*wall,
                    ly - 2*wall,
                    lz - wall
                ], rounding=max(r-wall,0), anchor=BOTTOM+LEFT+FRONT);
        }

        // Nervures d'accroche pour couvercle clipsable
        translate([wall, -0.6, lz - 4])
            cuboid([lx - 2*wall, 0.8, 2], anchor=BOTTOM+LEFT+FRONT);

        translate([wall, ly - 0.2, lz - 4])
            cuboid([lx - 2*wall, 0.8, 2], anchor=BOTTOM+LEFT+FRONT);

        translate([-0.6, wall, lz - 4])
            cuboid([0.8, ly - 2*wall, 2], anchor=BOTTOM+LEFT+FRONT);

        translate([lx - 0.2, wall, lz - 4])
            cuboid([0.8, ly - 2*wall, 2], anchor=BOTTOM+LEFT+FRONT);

        // Plots sous le fond pour empilage
        for (x = [stack_offset_coin, lx - stack_offset_coin - stack_plot_size])
        for (y = [stack_offset_coin, ly - stack_offset_coin - stack_plot_size])
            translate([x, y, -stack_plot_height])
                cuboid([stack_plot_size, stack_plot_size, stack_plot_height],
                       anchor=BOTTOM+LEFT+FRONT);
    }
}

// =====================================
// Couvercle clipsable BOSL2
// =====================================
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

// =====================================
// Affichage
// =====================================
boite_bosl2();

translate([largeur + 30, 0, 0])
    couvercle_bosl2();