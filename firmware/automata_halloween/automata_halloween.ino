// Autómata de Halloween: 3 figuras con cigüeñal
// Motor 28BYJ-48 + driver ULN2003 + sensor PIR HC-SR501
//
// Conexiones:
//   HC-SR501  VCC -> 5V   GND -> GND   OUT -> D2
//             Jumper en H (redisparo), potenciómetro de tiempo al mínimo
//   ULN2003   IN1..IN4 -> D8..D11
//             + y - del driver a una fuente de 5V aparte (cargador USB),
//             con GND común con el Arduino
//   Opcional  D5 -> resistencia 1k -> base de un NPN (2N2222/BC547) que
//             enciende la guirnalda de LEDs solo mientras bailan

const int PIN_PIR = 2;
const int PIN_LUZ = 5;
const int BOBINAS[4] = {8, 9, 10, 11};

const unsigned long DURACION_BAILE    = 20000; // ms que dura cada baile
const unsigned long PAUSA_TRAS_BAILE  = 5000;  // ms de descanso antes de volver a detectar
const unsigned long CALENTAMIENTO_PIR = 60000; // el HC-SR501 necesita ~1 min al arrancar
const unsigned int  US_POR_PASO       = 1500;  // menos = más rápido (no bajar de ~1000)

// Secuencia de medio paso: suave y con buen par
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

void bailar() {
  Serial.println("¡A bailar!");
  digitalWrite(PIN_LUZ, HIGH);
  unsigned long inicio = millis();
  int dir = 1;

  while (millis() - inicio < DURACION_BAILE) {
    // Un tramo de entre media vuelta y vuelta y media (~4096 medios pasos por vuelta)
    long pasos = random(2000, 6000);
    for (long p = 0; p < pasos && millis() - inicio < DURACION_BAILE; p++) {
      paso(dir);
    }
    // A veces una pequeña "pose" y cambio de sentido para que no sea monótono
    if (random(3) == 0) {
      apagarBobinas();
      delay(random(200, 600));
      dir = -dir;
    }
  }

  apagarBobinas();               // sin esto el motor se calienta estando parado
  digitalWrite(PIN_LUZ, LOW);
  Serial.println("Fin del baile");
}

void setup() {
  Serial.begin(9600);
  pinMode(PIN_PIR, INPUT);
  pinMode(PIN_LUZ, OUTPUT);
  for (int i = 0; i < 4; i++) pinMode(BOBINAS[i], OUTPUT);
  apagarBobinas();
  randomSeed(analogRead(A0));

  Serial.println("Calentando el PIR (1 min)...");
  delay(CALENTAMIENTO_PIR);
  Serial.println("Listo, esperando víctimas");
}

void loop() {
  if (digitalRead(PIN_PIR) == HIGH) {
    bailar();
    delay(PAUSA_TRAS_BAILE);
  }
}
