// Autómata de Halloween — sketch de PRUEBA de componentes
//
// Sirve para comprobar cada parte por separado antes de cargar el sketch definitivo.
// Abre el monitor serie a 9600 baudios y envía una letra:
//
//   m  Motor: una vuelta en un sentido y otra en el contrario
//   p  PIR: muestra durante 30 s cuándo detecta movimiento
//   s  Sonido: dispara la reproducción del módulo (pad PE)
//   l  Figuras LED: las enciende 3 segundos
//   b  Baile completo de prueba (sonido + luz + motor), 10 s
//   ?  Muestra el menú
//
// Los pines son los mismos que en el sketch definitivo.

const int PIN_PIR = 2;
const int PIN_LUZ = 5;
const int PIN_SONIDO = 6;
const int BOBINAS[4] = {8, 9, 10, 11};

const unsigned int US_POR_PASO = 1500;
const long PASOS_POR_VUELTA = 4096;    // medios pasos del 28BYJ-48

const byte SECUENCIA[8][4] = {
  {1,0,0,0}, {1,1,0,0}, {0,1,0,0}, {0,1,1,0},
  {0,0,1,0}, {0,0,1,1}, {0,0,0,1}, {1,0,0,1}
};
int fase = 0;

void apagarBobinas() {
  for (int i = 0; i < 4; i++) digitalWrite(BOBINAS[i], LOW);
}

void paso(int dir) {
  fase = (fase + dir + 8) % 8;
  for (int i = 0; i < 4; i++) digitalWrite(BOBINAS[i], SECUENCIA[fase][i]);
  delayMicroseconds(US_POR_PASO);
}

void dispararSonido() {
  pinMode(PIN_SONIDO, OUTPUT);
  digitalWrite(PIN_SONIDO, LOW);
  delay(100);
  pinMode(PIN_SONIDO, INPUT);
}

void menu() {
  Serial.println();
  Serial.println(F("=== Prueba de componentes ==="));
  Serial.println(F(" m  Motor (una vuelta y vuelta atrás)"));
  Serial.println(F(" p  PIR (30 s)"));
  Serial.println(F(" s  Sonido"));
  Serial.println(F(" l  Figuras LED (3 s)"));
  Serial.println(F(" b  Baile de prueba (10 s)"));
  Serial.println(F(" ?  Este menú"));
}

void pruebaMotor() {
  Serial.println(F("Motor: una vuelta hacia delante..."));
  for (long p = 0; p < PASOS_POR_VUELTA; p++) paso(1);
  Serial.println(F("...y una vuelta hacia atrás"));
  for (long p = 0; p < PASOS_POR_VUELTA; p++) paso(-1);
  apagarBobinas();
  Serial.println(F("Motor: fin. ¿Ha dado dos vueltas completas sin saltos ni enganches?"));
}

void pruebaPIR() {
  Serial.println(F("PIR: muévete delante del sensor durante 30 s"));
  int anterior = -1;
  unsigned long inicio = millis();
  while (millis() - inicio < 30000UL) {
    int ahora = digitalRead(PIN_PIR);
    if (ahora != anterior) {
      Serial.print((millis() - inicio) / 1000);
      Serial.println(ahora == HIGH ? F(" s  -> MOVIMIENTO (HIGH)") : F(" s  -> nada (LOW)"));
      anterior = ahora;
    }
    delay(20);
  }
  Serial.println(F("PIR: fin"));
}

void pruebaSonido() {
  Serial.println(F("Sonido: disparando el pad PE"));
  dispararSonido();
}

void pruebaLuz() {
  Serial.println(F("Figuras LED: encendidas 3 s"));
  digitalWrite(PIN_LUZ, HIGH);
  delay(3000);
  digitalWrite(PIN_LUZ, LOW);
  Serial.println(F("Figuras LED: apagadas"));
}

void pruebaBaile() {
  Serial.println(F("Baile de prueba: 10 s"));
  dispararSonido();
  digitalWrite(PIN_LUZ, HIGH);
  unsigned long inicio = millis();
  int dir = 1;
  while (millis() - inicio < 10000UL) {
    for (int p = 0; p < 2048 && millis() - inicio < 10000UL; p++) paso(dir);
    dir = -dir;
  }
  apagarBobinas();
  digitalWrite(PIN_LUZ, LOW);
  Serial.println(F("Baile de prueba: fin"));
}

void setup() {
  Serial.begin(9600);
  pinMode(PIN_PIR, INPUT);
  pinMode(PIN_LUZ, OUTPUT);
  pinMode(PIN_SONIDO, INPUT);
  for (int i = 0; i < 4; i++) pinMode(BOBINAS[i], OUTPUT);
  apagarBobinas();
  Serial.println(F("Recuerda: el PIR tarda ~1 min en estabilizarse tras encenderlo."));
  menu();
}

void loop() {
  if (Serial.available()) {
    char c = Serial.read();
    switch (c) {
      case 'm': case 'M': pruebaMotor();  break;
      case 'p': case 'P': pruebaPIR();    break;
      case 's': case 'S': pruebaSonido(); break;
      case 'l': case 'L': pruebaLuz();    break;
      case 'b': case 'B': pruebaBaile();  break;
      case '?':           menu();         break;
      default: break;    // ignora saltos de línea y otras teclas
    }
  }
}
