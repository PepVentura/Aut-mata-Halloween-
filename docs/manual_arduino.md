# Manual del Arduino Uno

Manual de conexionado, programación, configuración y pruebas del Arduino Uno que controla el Autómata de Halloween.

---

## 1. Qué hace el Arduino

El Uno es el cerebro del autómata. Vigila el sensor de movimiento y, cuando detecta a alguien, pone en marcha el espectáculo:

```
Encendido
   │
   ▼
Espera 1 minuto a que se estabilice el PIR
   │
   ▼
┌─► ¿Hay movimiento? (D2 en HIGH) ── no ──┐
│      │ sí                               │
│      ▼                                  │
│   Dispara el sonido (pulso en D6)       │
│   Enciende las figuras (D5 en HIGH)     │
│   Mueve el motor 20 s (D8–D11):         │
│     tramos de ½ a 1½ vueltas,           │
│     con pausas y cambios de sentido     │
│     al azar                             │
│   Apaga las figuras y el motor          │
│      │                                  │
│      ▼                                  │
│   Descansa 5 s                          │
│      │                                  │
└──────┴──────────────────────────────────┘
```

Mientras baila no vuelve a leer el sensor. Si al terminar los 5 s de descanso sigue habiendo alguien delante, repite el baile.

---

## 2. Pines utilizados

| Pin del Uno | Se conecta a | Función |
|---|---|---|
| **5V** | 5 V del USB-C (placa de reparto) | Alimentación del Uno |
| **GND** | GND común | Masa |
| **3.3V** | Resistencia de 10–22 Ω → + de las figuras | Alimentación de las figuras LED (máx. 150 mA) |
| **D2** | OUT del PIR HC-SR501 | Entrada: HIGH = movimiento |
| **D5** | Resistencia de 1 kΩ → base del NPN | Salida: HIGH = figuras encendidas |
| **D6** | Pad **PE** del módulo de sonido | Pulso a GND de 100 ms = reproducir |
| **D8** | IN1 del ULN2003 | Bobina 1 del motor |
| **D9** | IN2 del ULN2003 | Bobina 2 del motor |
| **D10** | IN3 del ULN2003 | Bobina 3 del motor |
| **D11** | IN4 del ULN2003 | Bobina 4 del motor |
| **A0** | **Nada, déjalo libre** | Su ruido eléctrico hace que cada baile sea distinto |

El resto de pines quedan libres. El esquema completo está en [esquema.png](esquema.png).

---

## 3. Alimentación

- **Entrada:** los 5 V del conector USB-C entran por el **pin 5V** del Uno, y la masa por **GND**.
- **No uses el jack ni el pin VIN:** pasan por el regulador interno, que necesita al menos 7 V. Con 5 V el Uno funcionaría mal o se reiniciaría.
- **Condensador de 470 µF:** junto a la entrada USB-C, entre 5 V y GND. Absorbe los picos del motor y evita que el Uno se reinicie al empezar el baile.
- **Consumo total:** menos de 0,5 A (motor unos 250 mA, Uno unos 50 mA, figuras menos de 100 mA). Basta un cargador de 1 A.

> ⚠️ **Para programar el Uno, desenchufa antes el USB-C de la caja.** Así las dos fuentes de 5 V, la del ordenador y la del cargador, nunca quedan unidas. Mientras está conectado al ordenador, el USB alimenta solo el Uno: el motor y el resto no reciben corriente. Para probarlo todo con el ordenador conectado, sigue la sección 6.

---

## 4. Preparar el ordenador

1. Instala el **Arduino IDE 2** desde arduino.cc (Windows, macOS o Linux).
2. Conecta el Uno al ordenador con su cable USB.
3. En el IDE, ve a **Herramientas → Placa → Arduino AVR Boards → Arduino Uno**.
4. Ve a **Herramientas → Puerto** y elige el que aparece al conectar el Uno: COMx en Windows, /dev/ttyACM0 o /dev/ttyUSB0 en Linux, /dev/cu.usbmodem… en macOS.
5. **Si no aparece ningún puerto** y tu Uno es un clon, mira el chip junto al conector USB. Si pone **CH340**, necesitas instalar su driver: busca "CH340 driver" junto al nombre de tu sistema operativo.

---

## 5. Los dos sketches

En la carpeta `firmware/` del repositorio hay dos programas. Cada uno va en su carpeta, con el mismo nombre que el archivo, como exige el IDE.

| Sketch | Para qué |
|---|---|
| `prueba_componentes/prueba_componentes.ino` | Comprobar cada parte por separado desde el monitor serie |
| `automata_halloween/automata_halloween.ino` | El programa definitivo de la fiesta |

Para cargar cualquiera de los dos:

1. **Archivo → Abrir** y elige el `.ino`.
2. Pulsa **Subir**, la flecha →. Primero compila y luego lo carga en el Uno.
3. Si todo va bien, abajo aparece «Carga completada».

Los dos compilan para Uno y ocupan alrededor del 14 % de la memoria.

---

## 6. Pruebas por partes

Carga primero **`prueba_componentes`**. Con el USB-C de la caja enchufado y el del ordenador desconectado no podrías ver el monitor serie, así que para estas pruebas haz lo siguiente:

- **Conecta el Uno al ordenador** con su cable USB.
- **Alimenta el resto desde una fuente aparte de 5 V:** cargador o power bank, con su + a la pista de 5 V de la placa de reparto y su − a GND. El cable que va al pin 5V del Uno tiene que estar **desconectado** mientras tanto.
- **Comprueba la masa común:** el GND del Uno sigue unido al GND de la placa de reparto.

Abre **Herramientas → Monitor serie**, pon la velocidad en **9600 baudios** y aparecerá el menú. Escribe una letra y pulsa Enter:

| Letra | Prueba | Qué debe pasar |
|---|---|---|
| **m** | Motor | Una vuelta completa en un sentido y otra en el contrario, unos 6 s cada una, suave y sin saltos |
| **p** | PIR | Durante 30 s, cada vez que te mueves aparece «MOVIMIENTO (HIGH)» y al rato «nada (LOW)» |
| **s** | Sonido | Suena la grabación completa del módulo |
| **l** | Figuras | Se encienden 3 s y se apagan |
| **b** | Baile de prueba | Sonido, figuras encendidas y motor alternando de sentido durante 10 s |
| **?** | Menú | Vuelve a mostrar las opciones |

Haz las pruebas en este orden: **m → l → s → p → b**. Si una falla, consulta la sección 9 antes de seguir.

> El PIR necesita alrededor de **1 minuto** desde que recibe alimentación para estabilizarse. Durante ese rato puede dar detecciones falsas.

---

## 7. Configuración del sketch definitivo

Todos los ajustes están al principio de `automata_halloween.ino`:

| Constante | Valor por defecto | Qué controla | Ajuste |
|---|---|---|---|
| `DURACION_BAILE` | `20000` (20 s) | Duración de cada baile, en ms | Iguálala a la duración del sonido grabado |
| `PAUSA_TRAS_BAILE` | `5000` (5 s) | Descanso antes de volver a detectar | Súbela si quieres que no repita tan seguido |
| `CALENTAMIENTO_PIR` | `60000` (1 min) | Espera inicial para el PIR | No bajar de 30000 |
| `US_POR_PASO` | `1500` | Velocidad del motor (µs por medio paso) | Menos = más rápido. 1500 ≈ 10 rpm, 1200 ≈ 12 rpm. **No bajar de 1000**, porque el motor pierde pasos |

El carácter del baile se cambia en la función `bailar()`:

- **`random(2000, 6000)`:** longitud de cada tramo en medios pasos, entre ½ y 1½ vueltas. Valores más pequeños dan un baile más nervioso.
- **`random(3) == 0`:** probabilidad de pausa y cambio de sentido después de cada tramo, 1 de cada 3. Con `random(2)` cambia más a menudo.
- **`random(200, 600)`:** duración de la pausa, en ms.

Los pines también son constantes (`PIN_PIR`, `PIN_LUZ`, `PIN_SONIDO`, `BOBINAS`), por si alguna vez cambias el cableado.

---

## 8. Funcionamiento normal

Cuando las pruebas vayan bien, carga **`automata_halloween`**, desconecta el cable del ordenador, vuelve a conectar el cable al pin 5V del Uno y enchufa el USB-C de la caja.

Si quieres seguir lo que hace, conecta el Uno al ordenador alimentando el resto con una fuente aparte, como en la sección 6, y abre el monitor serie a 9600. Verás estos mensajes:

| Mensaje | Significado |
|---|---|
| `Calentando el PIR (1 min)...` | Recién encendido. Espera |
| `Listo, esperando víctimas` | Ya vigila el sensor |
| `¡A bailar!` | Ha detectado a alguien. Empiezan el sonido, las luces y el motor |
| `Fin del baile` | Terminado. Descansa 5 s y vuelve a vigilar |

### Ajustes del sensor PIR (HC-SR501)

En la placa del sensor, con la lente hacia abajo:

- **Jumper en H** (redisparo): mientras haya movimiento, la salida se mantiene en HIGH.
- **Potenciómetro de tiempo (Tx), al mínimo**, girado a tope en sentido antihorario: la duración del baile la decide el Arduino, no el sensor.
- **Potenciómetro de sensibilidad (Sx):** en sentido horario aumenta la distancia de detección, hasta unos 7 m. Para una mesa en una fiesta, a la mitad suele ir bien. Si se dispara solo, bájalo.

---

## 9. Solución de problemas

| Problema | Causa probable | Solución |
|---|---|---|
| El IDE no encuentra el puerto | Clon con chip CH340 sin driver, o cable USB que solo carga | Instala el driver CH340 o prueba con otro cable |
| «Carga fallida» o «not in sync» | Placa o puerto equivocados, o algo conectado a D0/D1 | Revisa Placa y Puerto, y que D0/D1 estén libres |
| El motor vibra pero no gira | Bobinas en orden incorrecto, o `US_POR_PASO` demasiado bajo | Comprueba D8–D11 → IN1–IN4 en orden, y sube a 1500 |
| El motor gira a tirones o se para | Falta de corriente, o algo roza en el mecanismo | Usa un cargador de al menos 1 A y gira el eje a mano para buscar el roce |
| El Uno se reinicia al empezar el baile | Caída de tensión al arrancar el motor | Pon el condensador de 470 µF y revisa los cables de 5 V/GND |
| El motor se calienta estando parado | Bobinas que quedan activadas | El sketch las apaga. Si pasa, comprueba que cargaste la última versión |
| Baila solo, sin nadie delante | El PIR no ha terminado de estabilizarse, la sensibilidad está alta, o hay corrientes de aire o calor delante | Espera el minuto, baja Sx y aleja el autómata de radiadores y ventanas |
| Nunca detecta | Jumper o potenciómetros mal, o cable OUT suelto | Usa la prueba **p**. El HC-SR501 no tiene LED indicador, así que fíate del monitor serie |
| No suena | Pad equivocado (PL en vez de PE), diodo al revés o sin masa común | Consulta el [manual del módulo de sonido](manual_modulo_sonido.md) |
| Las figuras no se encienden | Transistor mal orientado, o cables + y − cambiados | Comprueba qué patilla es emisor, base y colector en la hoja de datos de tu transistor (cambia entre 2N2222 y BC547) |
| Las figuras brillan poco | Resistencia demasiado alta | Pasa de 22 Ω a 10 Ω |
| Cada baile es idéntico | A0 conectado a algo | Deja A0 libre |
