include <BOSL2-master/std.scad>;

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

// =====================================
// Paramètres organiseur
// =====================================
comp_longueur      = 100;  // taille cible en Y
comp_largeur       = 30;   // taille cible en X
cloison_ep         = 2;    // épaisseur des cloisons internes
marge_ext          = 2;    // marge minimale sur les bords

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
// Organiseur : grille de compartiments
// autant que possible 100 x 30 mm
// =====================================
module organiseur_interieur(size=[largeur,longueur,hauteur], wall=epaisseur) {
    lx = size[0];
    ly = size[1];
    lz = size[2];

    inner_x = lx - 2*wall;
    inner_y = ly - 2*wall;
    inner_h = lz - wall;

    // Nombre de colonnes/rangées standard possibles
    n_cols = max(floor((inner_x + cloison_ep) / (comp_largeur + cloison_ep)), 1);
    n_rows = max(floor((inner_y + cloison_ep) / (comp_longueur + cloison_ep)), 1);

    // Taille occupée par une grille standard
    total_x_std = n_cols*comp_largeur + (n_cols+1)*cloison_ep;
    total_y     = n_rows*comp_longueur + (n_rows+1)*cloison_ep;

    // Reste disponible en largeur
    reste_x = max(inner_x - total_x_std, 0);

    // Grille collée au bord gauche intérieur
    x0 = wall;

    // Centrage en Y conservé
    //y0 = wall + max((inner_y - total_y)/2, 0);
    y0 = wall;

    // Largeur de la première colonne à gauche
    first_col_width = comp_largeur + reste_x;

    // Positions X des cloisons verticales
    // Cloison 0 = bord gauche
    translate([x0, y0, wall])
        cuboid([cloison_ep, total_y, inner_h], anchor=BOTTOM+LEFT+FRONT);

    // Cloison après la première colonne élargie
    x_pos = x0 + cloison_ep + first_col_width;
    translate([x_pos, y0, wall])
        cuboid([cloison_ep, total_y, inner_h], anchor=BOTTOM+LEFT+FRONT);

    // Cloisons suivantes pour colonnes standard
    for (i = [1:n_cols-1]) {
        x_cloison = x_pos + i*(comp_largeur + cloison_ep);
        translate([x_cloison, y0, wall])
            cuboid([cloison_ep, total_y, inner_h], anchor=BOTTOM+LEFT+FRONT);
    }

    // Cloisons horizontales
    for (j = [0:n_rows]) {
        y_cloison = y0 + j*(comp_longueur + cloison_ep);
        translate([x0, y_cloison, wall])
            cuboid([inner_x, cloison_ep, inner_h], anchor=BOTTOM+LEFT+FRONT);
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

        // Organiseur interne
        organiseur_interieur(size=size, wall=wall);
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