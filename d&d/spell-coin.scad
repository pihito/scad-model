// ============================================================
// Jeton D&D empilable - impression 3D
// Diametre 45 mm, epaisseur reglable (<= 10 mm)
//
// Une seule face porte les deux inscriptions :
//   - "1" (ou autre numero) au centre
//   - "D&D" gravé en arc de cercle le long du bord, en haut
// L'autre face reste vierge (donc parfaitement plate) par defaut.
// Toutes les inscriptions sont GRAVEES (en creux) pour que les
// faces restent plates et que les jetons s'empilent proprement.
// ============================================================

/* [Dimensions generales] */
diametre        = 45;   // diametre du jeton (mm)
epaisseur       = 6;    // epaisseur du jeton, max 10 mm
chanfrein       = 0.6;  // petit chanfrein sur les 2 bords (confort au toucher)

/* [Texte central] */
texte_centre        = "1";   // change ici pour numeroter d'autres jetons (2, 3, ...)
taille_texte_centre  = 16;
offset_texte = -3; //décalage sur axe Y du texte central

/* [Texte en arc le long du bord] */
texte_anneau        = "D&D";
taille_texte_anneau = 6;     // taille des lettres de l'arc
rayon_anneau         = diametre / 2 - 6;  // distance du centre au milieu des lettres
pas_angle_anneau     = 20;   // ecart angulaire entre les lettres (deg) - ajuster si les lettres se touchent ou sont trop espacees

/* [Face arriere (optionnelle)] */
texte_verso         = "";    // laisser vide pour une face arriere lisse, ou mettre un texte

/* [Stries sur la tranche (effet jeton de poker)] */
stries_actives      = true;  // true pour activer les stries, false pour une tranche lisse
nb_stries           = 60;    // nombre de stries tout autour de la tranche
largeur_strie       = 1.2;   // largeur de chaque strie (mm)
profondeur_strie    = 0.5;   // profondeur de chaque strie (mm)
hauteur_strie       = epaisseur - 2 * chanfrein - 1; // hauteur des stries, garde une marge avec les chanfreins

/* [Reglages communs] */
taille_texte_verso  = 20;
police              = "Liberation Sans:style=Bold";
profondeur_gravure  = 0.8;   // profondeur des inscriptions (mm)

/* [Qualite] */
resolution = 180; // $fn global, augmenter pour un rendu plus lisse

$fn = resolution;

// ------------------------------------------------------------
// Securites simples sur les parametres
// ------------------------------------------------------------
assert(epaisseur <= 10, "L'epaisseur doit rester <= 10 mm.");
assert(chanfrein * 2 < epaisseur, "Le chanfrein est trop grand par rapport a l'epaisseur.");
assert(profondeur_gravure < epaisseur / 2, "La gravure est trop profonde par rapport a l'epaisseur.");
assert(hauteur_strie < epaisseur - 2 * chanfrein, "Les stries sont trop hautes par rapport a la partie plate de la tranche.");
assert(profondeur_strie < diametre / 4, "La profondeur des stries est trop importante.");

// ------------------------------------------------------------
// Disque de base avec un petit chanfrein sur les deux bords
// (le disque est centre sur l'axe Z, de -epaisseur/2 a +epaisseur/2)
// ------------------------------------------------------------
module disque_chanfreine(d, h, c) {
    r = d / 2;
    difference() {
        cylinder(d = d, h = h, center = true);

        // chanfrein sur le bord du dessus
        rotate_extrude()
            polygon(points = [
                [r - c, h / 2],
                [r + 1, h / 2],
                [r + 1, h / 2 - c]
            ]);

        // chanfrein sur le bord du dessous (miroir du precedent)
        mirror([0, 0, 1])
            rotate_extrude()
                polygon(points = [
                    [r - c, h / 2],
                    [r + 1, h / 2],
                    [r + 1, h / 2 - c]
                ]);
    }
}

// ------------------------------------------------------------
// Gravure du texte central, sur la face du dessus (recto)
// ------------------------------------------------------------
module gravure_centre(txt, taille, prof) {
    translate([0, offset_texte, epaisseur / 2 - prof])
        linear_extrude(height = prof + 0.5)
            text(txt, size = taille, font = police,
                 halign = "center", valign = "center");
}

// ------------------------------------------------------------
// Gravure d'un texte en arc de cercle, centre en haut (12h),
// sur la meme face que le texte central (recto).
// Chaque lettre est placee sur le cercle de rayon "rayon" et
// tourne avec sa position, comme les chiffres d'une horloge :
// le texte se lit de gauche a droite en suivant le bord.
// ------------------------------------------------------------
module gravure_anneau(txt, rayon, taille, pas_angle, prof) {
    n = len(txt);
    decalage = (n - 1) / 2 * pas_angle;
    translate([0, 0, epaisseur / 2 - prof])
        for (i = [0 : n - 1]) {
            theta = decalage - i * pas_angle;
            rotate([0, 0, theta])
                translate([0, rayon, 0])
                    linear_extrude(height = prof + 0.5)
                        text(txt[i], size = taille, font = police,
                             halign = "center", valign = "center");
        }
}

// ------------------------------------------------------------
// Gravure du verso (miroir en X pour que le texte se lise bien
// une fois le jeton retourne et vu depuis le dessous). Utilisee
// seulement si "texte_verso" n'est pas vide.
// ------------------------------------------------------------
module gravure_verso(txt, taille, prof) {
    translate([0, 0, -epaisseur / 2 - 0.5])
        mirror([1, 0, 0])
            linear_extrude(height = prof + 0.5)
                text(txt, size = taille, font = police,
                     halign = "center", valign = "center");
}

// ------------------------------------------------------------
// Stries verticales sur la tranche, reparties uniformement
// (effet "jeton de poker"). La partie plate de la tranche se
// situe entre les deux chanfreins ; les stries sont centrees
// en Z sur cette partie plate pour ne pas mordre les chanfreins.
// ------------------------------------------------------------
module stries(nb, largeur, profondeur, hauteur) {
    r = diametre / 2;
    for (i = [0 : nb - 1]) {
        angle = i * 360 / nb;
        rotate([0, 0, angle])
            translate([r, 0, 0])
                cube([profondeur * 2, largeur, hauteur], center = true);
    }
}

// ------------------------------------------------------------
// Assemblage final
// ------------------------------------------------------------
module jeton() {
    difference() {
        disque_chanfreine(diametre, epaisseur, chanfrein);
        gravure_centre(texte_centre, taille_texte_centre, profondeur_gravure);
        gravure_anneau(texte_anneau, rayon_anneau, taille_texte_anneau, pas_angle_anneau, profondeur_gravure);
        if (texte_verso != "") {
            gravure_verso(texte_verso, taille_texte_verso, profondeur_gravure);
        }
        if (stries_actives) {
            stries(nb_stries, largeur_strie, profondeur_strie, hauteur_strie);
        }
    }
}

jeton();

