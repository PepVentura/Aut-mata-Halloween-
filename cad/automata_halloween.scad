// Autómata de Halloween — 3 figuras sobre cigüeñal hexagonal con motor 28BYJ-48
//
// MODO = "montaje"   -> vista del conjunto (Ver > Animar con FPS 10, Pasos 36 para verlo bailar)
// MODO = "imprimir"  -> piezas del mecanismo colocadas para imprimir
// MODO = "caja"      -> caja con ventana para el PIR y hueco para el USB-C (imprimir boca arriba)
// MODO = "tapa"      -> tapa con los agujeros de las varillas y de los cables
// MODO = "plantilla" -> plantilla 2D de la tapa (por si prefieres hacerla en DM)
// MODO = "eje" | "manivela" | "biela" | "paleta" | "acople" | "soporte" | "soporte_motor" -> pieza suelta
//
// Piezas a imprimir: 1 eje, 3 manivelas, 3 bielas, 3 paletas, 2 soportes, 1 soporte de motor, 1 acople,
//                    1 caja y 1 tapa (caben enteras en una cama de 260x260)
// Tornillería: 3 tornillos M3x8 (o rosca chapa 2,5) + arandela para retener las bielas,
//              2 tornillos M3/M4 para el motor,
//              6 tornillos M3x8 avellanados (rosca chapa) desde debajo de la caja para los soportes,
//              2 tornillos M2 de rosca chapa para la placa del PIR.
// Sonido: módulo grabador de voz (30/120 s) + altavoz 8 ohm 2 W tras la rejilla frontal.

MODO = "montaje";
$fn = 48;

// ---------- Parámetros generales ----------
separacion     = 65;   // distancia entre figuras
x_primera      = 40;   // 1ª manivela, medida desde la cara de la placa del motor
altura_eje     = 30;   // del suelo de la caja al eje
altura_tapa    = 90;   // del suelo a la cara INFERIOR de la tapa
grosor_tapa    = 3;
radio_manivela = 8;    // sube y baja ±8 mm
holgura        = 0.3;

// Eje hexagonal (imprime tumbado sobre una cara plana)
hex_ec     = 8;        // medida entre caras
inicio_eje = 13;       // x donde empieza (metido dentro del acople)
largo_eje  = 200;

// Motor 28BYJ-48
m_offset_eje = 8;      // el eje está desplazado 8 mm del centro del cuerpo
m_tabs       = 35;     // distancia entre agujeros de fijación
m_tab_d      = 4.2;
m_boss_d     = 10;     // agujero para el resalte del eje
m_eje_d      = 5;
m_eje_planos = 3;

// Manivela
disco_d = 26; disco_t = 5;
pin_d = 5; pin_l = 6; tornillo_d = 2.5;

// Biela
biela_ancho  = 5;      // dirección delante-detrás
biela_grueso = 4;      // dirección del eje
anillo_d     = 12;
biela_l      = 85;     // del centro del pasador a la punta

// Paleta donde se pega la figura (por detrás)
paleta_w = 28; paleta_h = 30; paleta_t = 2.5;
encaje   = 12;

// Tapa
tapa_x0 = -28; tapa_x1 = 218; tapa_fondo = 96;   // interior de la caja
agujero_varilla = 9;
agujero_cable   = 5;
cable_dy        = 11;  // agujero del cable, por detrás de la varilla

// ---------- Caja ----------
pared        = 2.4;
suelo        = 2.4;
holgura_tapa = 0.4;
repisa       = 3;      // apoyo interior de la tapa (con chaflán a 45°, imprime sin soportes)

// Sensor PIR HC-SR501 en la pared frontal
pir_x         = (tapa_x0 + tapa_x1) / 2;
pir_z         = 60;
pir_lente_d   = 23.5;
pir_tornillos = 28;    // separación entre los agujeros de la placa
pir_sep       = 4;     // distancia de la placa a la pared (ajusta según la base de la lente)

// Conector USB-C de panel en la pared derecha  (MEDIR cuando llegue y ajustar)
usb_w     = 13;        // ancho del hueco
usb_h     = 7;         // alto del hueco
usb_y     = 25;        // hacia atrás desde el centro
usb_z     = 14;        // altura sobre el suelo
usb_pared = 1.6;       // pared adelgazada alrededor para que encajen las pestañas

// Altavoz 8 ohm 2 W en la pared frontal, a la derecha del PIR  (MEDIR el diámetro y ajustar)
alt_d     = 28;        // diámetro exterior del altavoz
alt_x     = pir_x + 55;
alt_z     = 55;
alt_aro_h = 3;         // aro interior donde se apoya y se pega el altavoz
alt_rejilla_d = 2.5;   // agujeros de la rejilla

function hex_ac(ec) = ec / cos(30);
function x_manivela(i) = x_primera + i * separacion;
function x_varilla(i)  = x_manivela(i) + disco_t + biela_grueso / 2;
x_soportes = [x_primera + separacion / 2, x_primera + 2 * separacion + 25];

echo(str("Caja exterior: ", tapa_x1 - tapa_x0 + 2 * pared, " x ", tapa_fondo + 2 * pared, " x ", altura_tapa + grosor_tapa + suelo, " mm"));
for (i = [0:2]) echo(str("Agujero varilla ", i + 1, ": x = ", x_varilla(i) - tapa_x0, " mm desde el borde izquierdo de la tapa, centrado en fondo"));

// ---------- Piezas ----------

module eje_hex() {
    // con la cara plana hacia abajo; eje a lo largo de X
    rotate([0, 90, 0]) rotate([0, 0, 30]) cylinder(d = hex_ac(hex_ec), h = largo_eje, $fn = 6);
}

module agujero_hex(h) {
    rotate([0, 0, 30]) cylinder(d = hex_ac(hex_ec + holgura), h = h, $fn = 6);
}

module manivela() {
    // Las tres son iguales: al montarlas, gira cada una dos caras del hexágono (120°)
    difference() {
        union() {
            cylinder(d = disco_d, h = disco_t);
            translate([radio_manivela, 0, 0]) cylinder(d = pin_d, h = disco_t + pin_l);
        }
        translate([0, 0, -1]) agujero_hex(disco_t + 2);
        translate([radio_manivela, 0, -1]) cylinder(d = tornillo_d, h = disco_t + pin_l + 2);
        // marca en el borde para alinear las manivelas a 120°
        translate([-disco_d / 2 - 1, -0.6, disco_t - 0.6]) cube([3, 1.2, 1]);
    }
}

module biela() {
    difference() {
        union() {
            cylinder(d = anillo_d, h = biela_grueso);
            translate([-biela_ancho / 2, 0, 0]) cube([biela_ancho, biela_l, biela_grueso]);
        }
        translate([0, 0, -1]) cylinder(d = pin_d + 0.4, h = biela_grueso + 2);
    }
}

module paleta() {
    // Se imprime con la cara de pegar la figura contra la cama
    hx = biela_grueso + 0.4;
    hz = biela_ancho + 0.4;
    difference() {
        union() {
            translate([-paleta_w / 2, 0, 0]) cube([paleta_w, paleta_h, paleta_t]);
            translate([-(hx + 4) / 2, -encaje, 0]) cube([hx + 4, encaje + 6, hz + 3]);
        }
        translate([-hx / 2, -encaje - 1, 1.5]) cube([hx, encaje + 1, hz]);
    }
}

module acople() {
    difference() {
        cylinder(d = 16, h = 22);
        // lado del motor: eje de 5 mm con dos planos
        translate([0, 0, -1]) intersection() {
            cylinder(d = m_eje_d + 0.3, h = 9);
            cube([m_eje_planos + 0.3, 10, 20], center = true);
        }
        // lado del eje hexagonal
        translate([0, 0, 12]) agujero_hex(11);
    }
}

module soporte() {
    // Pieza en el plano Y-Z, agujero del eje a altura_eje
    difference() {
        union() {
            translate([-3, -10, 0]) cube([6, 20, altura_eje]);
            translate([-3, 0, altura_eje]) rotate([0, 90, 0]) cylinder(d = 20, h = 6);
            translate([-10, -17, 0]) cube([20, 34, 3]);
        }
        translate([-4, 0, altura_eje]) rotate([0, 90, 0]) cylinder(d = hex_ac(hex_ec) + 0.8, h = 8);
        for (y = [-13, 13]) translate([0, y, -1]) cylinder(d = 2.6, h = 5);
    }
}

module soporte_motor() {
    // Placa vertical: el motor va atornillado por detrás (x < -3), el eje sale hacia +X
    zc = altura_eje - m_offset_eje;
    difference() {
        union() {
            translate([-3, -25, 0]) cube([3, 50, altura_eje + 12]);
            translate([-3, -25, 0]) cube([22, 50, 3]);
            for (y = [-25, 22]) hull() {
                translate([-3, y, 0]) cube([3, 3, 25]);
                translate([-3, y, 0]) cube([18, 3, 3]);
            }
        }
        translate([-4, 0, altura_eje]) rotate([0, 90, 0]) cylinder(d = m_boss_d, h = 5);
        for (y = [-m_tabs / 2, m_tabs / 2])
            translate([-4, y, zc]) rotate([0, 90, 0]) cylinder(d = m_tab_d, h = 5);
        for (y = [-12, 12]) translate([11, y, -1]) cylinder(d = 2.6, h = 5);
    }
}

module tapa_2d() {
    difference() {
        translate([tapa_x0 + holgura_tapa / 2, -tapa_fondo / 2 + holgura_tapa / 2])
            square([tapa_x1 - tapa_x0 - holgura_tapa, tapa_fondo - holgura_tapa]);
        // muesca para levantar la tapa con el dedo
        translate([tapa_x1 - 20, tapa_fondo / 2]) circle(d = 14);
        for (i = [0:2]) {
            translate([x_varilla(i), 0]) circle(d = agujero_varilla);
            translate([x_varilla(i), cable_dy]) circle(d = agujero_cable);
        }
    }
}

module tapa() {
    linear_extrude(grosor_tapa) tapa_2d();
}

function puntos_suelo() = concat(
    [[11, -12], [11, 12]],
    [for (x = x_soportes, y = [-13, 13]) [x, y]]
);

module repisas() {
    yi = tapa_fondo / 2;
    L = tapa_x1 - tapa_x0;
    z1 = altura_tapa;
    for (s = [-1, 1]) hull() {
        translate([tapa_x0, s > 0 ? yi - 0.01 : -yi, z1 - repisa]) cube([L, 0.01, repisa]);
        translate([tapa_x0, s > 0 ? yi - repisa : -yi, z1 - 0.01]) cube([L, repisa, 0.01]);
    }
    for (s = [-1, 1]) hull() {
        translate([s > 0 ? tapa_x1 - 0.01 : tapa_x0, -yi, z1 - repisa]) cube([0.01, 2 * yi, repisa]);
        translate([s > 0 ? tapa_x1 - repisa : tapa_x0, -yi, z1 - 0.01]) cube([repisa, 2 * yi, 0.01]);
    }
}

module caja() {
    yi = tapa_fondo / 2;
    h = altura_tapa + grosor_tapa;
    difference() {
        union() {
            difference() {
                translate([tapa_x0 - pared, -yi - pared, -suelo])
                    cube([tapa_x1 - tapa_x0 + 2 * pared, 2 * yi + 2 * pared, h + suelo]);
                translate([tapa_x0, -yi, 0]) cube([tapa_x1 - tapa_x0, 2 * yi, h + 1]);
            }
            repisas();
            // aro para centrar el altavoz (se pega con unos puntos de termocola)
            translate([alt_x, -tapa_fondo / 2, alt_z]) rotate([-90, 0, 0])
                difference() { cylinder(d = alt_d + 4, h = alt_aro_h); translate([0, 0, -1]) cylinder(d = alt_d + 0.6, h = alt_aro_h + 2); }
            // postes para la placa del PIR
            for (s = [-1, 1]) translate([pir_x + s * pir_tornillos / 2, -yi, pir_z])
                rotate([-90, 0, 0]) cylinder(d = 4, h = pir_sep);
        }
        // rejilla del altavoz: agujeros en anillos concéntricos
        for (rr = [0 : 4 : alt_d / 2 - 3], k = [0 : max(1, round(2 * PI * rr / 4.5)) - 1])
            let (a = 360 * k / max(1, round(2 * PI * rr / 4.5)))
            translate([alt_x + rr * cos(a), -tapa_fondo / 2 + 1, alt_z + rr * sin(a)])
                rotate([90, 0, 0]) cylinder(d = alt_rejilla_d, h = pared + 2, $fn = 16);
        // ventana de la lente del PIR
        translate([pir_x, -yi + 1, pir_z]) rotate([90, 0, 0]) cylinder(d = pir_lente_d, h = pared + 2);
        for (s = [-1, 1]) translate([pir_x + s * pir_tornillos / 2, -yi - 1, pir_z])
            rotate([-90, 0, 0]) cylinder(d = 1.6, h = pir_sep + 2);
        // USB-C: pared adelgazada por dentro + hueco ovalado
        translate([tapa_x1 - 1, usb_y - (usb_w + 8) / 2, usb_z - (usb_h + 8) / 2])
            cube([1 + pared - usb_pared, usb_w + 8, usb_h + 8]);
        hull() for (s = [-1, 1]) translate([tapa_x1 - 1, usb_y + s * (usb_w - usb_h) / 2, usb_z])
            rotate([0, 90, 0]) cylinder(d = usb_h, h = pared + 2);
        // agujeros avellanados en el suelo para atornillar soportes y motor desde abajo
        for (p = puntos_suelo()) translate([p[0], p[1], -suelo - 1]) {
            cylinder(d = 3.4, h = suelo + 2);
            cylinder(d1 = 7, d2 = 3.4, h = 2.8);
        }
    }
}

// ---------- Montaje animado ----------

module figura_en(i, ang) {
    phi = ang + i * 120;
    yp = radio_manivela * cos(phi);
    zp = altura_eje + radio_manivela * sin(phi);
    zh = altura_tapa + grosor_tapa / 2;
    theta = atan2(radio_manivela * cos(phi), zh - zp);
    xm = x_manivela(i);

    color("orange") translate([xm, 0, altura_eje]) rotate([phi + 90, 0, 0]) rotate([0, 90, 0]) manivela();
    translate([xm + disco_t, yp, zp]) rotate([theta, 0, 0]) rotate([90, 0, 90]) {
        color("silver") biela();
        color("white") translate([-(biela_ancho + 0.4) / 2 - 1.5, biela_l, biela_grueso / 2])
            rotate([0, 90, 0]) translate([0, 0, 0]) paleta();
    }
}

module montaje() {
    ang = $t * 360;
    color("SteelBlue") soporte_motor();
    color("DodgerBlue", 0.6) translate([-3 - 19, 0, altura_eje - m_offset_eje])
        rotate([0, 90, 0]) cylinder(d = 28, h = 19);
    color("gray") translate([1, 0, altura_eje]) rotate([0, 90, 0]) acople();
    color("gold") translate([inicio_eje, 0, altura_eje]) rotate([ang, 0, 0]) eje_hex();
    for (x = x_soportes) color("SteelBlue") translate([x, 0, 0]) soporte();
    for (i = [0:2]) figura_en(i, ang);
    color("DarkSlateGray", 0.35) translate([0, 0, altura_tapa]) tapa();
    color("Purple", 0.15) caja();
}

module imprimir() {
    translate([0, -10, 0]) translate([0, 0, hex_ec / 2]) eje_hex();
    for (i = [0:2]) translate([20 + i * 32, 15, 0]) manivela();
    for (i = [0:2]) translate([120 + i * 16, 10, 0]) biela();
    for (i = [0:2]) translate([20 + i * 35, 50, 0]) paleta();
    translate([20, 100, 0]) acople();
    for (i = [0:1]) translate([60 + i * 30, 105, 0]) rotate([0, 0, 90]) soporte();
    translate([165, 110, 0]) soporte_motor();
}

if (MODO == "montaje") montaje();
else if (MODO == "imprimir") imprimir();
else if (MODO == "eje") translate([0, 0, hex_ec / 2]) eje_hex();
else if (MODO == "manivela") manivela();
else if (MODO == "biela") biela();
else if (MODO == "paleta") paleta();
else if (MODO == "acople") acople();
else if (MODO == "soporte") soporte();
else if (MODO == "soporte_motor") soporte_motor();
else if (MODO == "caja") caja();
else if (MODO == "tapa") tapa();
else if (MODO == "plantilla") tapa_2d();
