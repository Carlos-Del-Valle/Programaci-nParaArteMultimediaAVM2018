import oscP5.*;
import netP5.*;
OscP5 oscP5;
NetAddress myRemoteLocation;

import processing.serial.*; // importamos al librería Serial
Serial myPort; // Creamos un objeto de la clase serial
String val; // Variable donde almacenaremos el valor que pase por el serial
int valor = 0; // variable que utilizaremos para la conversión de string a entero
int valorAnterior = 0; // variable que utilizaremos para la conversión de string a entero
boolean acelerando = false;

// variables globales

int delta=0;
int valueAvg=0;

int[] colors;
int[] colorsTransparencia;

void setup() {
  println(Serial.list());// Serial.list() nos permitirá saber que puerto estamos utilizando en MAC y en WIN 
  String portName = Serial.list()[3]; //cambiaremos el puerto 0,1,2,3... dependiendo del que estemos utilizando 
  myPort = new Serial(this, portName, 19200);


  size(640, 480);
  frameRate(30);

  colors=new int[6];
  colors[0] = color(255, 0, 0);
  colors[1] = color(255, 127, 0);
  colors[2] = color(255, 255, 0);
  colors[3] = color(0, 255, 0);
  colors[4] = color(0, 0, 255);
  colors[5] = color(139, 0, 255);

  colorsTransparencia=new int[6];
  colorsTransparencia[0] = color(255, 0, 0, 1);
  colorsTransparencia[1] = color(255, 127, 0, 1);
  colorsTransparencia[2] = color(255, 255, 0, 1);
  colorsTransparencia[3] = color(0, 255, 0, 1);
  colorsTransparencia[4] = color(0, 0, 255, 1);
  colorsTransparencia[5] = color(139, 0, 255, 1);


  oscP5 = new OscP5(this, 12000);

  myRemoteLocation = new NetAddress("127.0.0.1", 5000);
}




void draw()
{
  //  background(0);

//falso Blur

  fill(0, 0, 0, 10); 
  noStroke();
  rect(0, 0, width, height);

//Convertir los valores de Arduino a valores pantalla
  int x1;
  x1 = (int) map(valueAvg, 25, 250, width, 0);
  int x2;
  x2 = (int) map(valorAnterior, 25, 250, width, 0);
  int x3;
  x3 = (int) lerp(x1, x2, 0.1);

//Dibujo de las 6 barras de colores
  for (int i = 0; i<6; i++) {
    fill( colors[i] );
    int y1 = height / 6 * i;
    int y2 = height / 6;
    //rect(x1, y1, width, y2);
    //rect(x2, y1, width, y2);
    setGradient(x1, y1, (float)width-x1, (float)y2, colorsTransparencia[i], colors[i], X_AXIS);
  }

//Beep de testeo
  //stroke(255); 
  //if (acelerando) stroke(200, 200, 0);
  //line(frameCount%width, valueAvg, (frameCount%width)+1, valueAvg);

  OscMessage myMessage = new OscMessage("/value");
  myMessage.add(valueAvg);
  oscP5.send(myMessage, myRemoteLocation);
}

//Lectura Arduino

void serialEvent(Serial myPort) {
  // read a byte from the serial port:
  valorAnterior = valor;
  valor = myPort.read(); // lee la cadena que viene por el puerto y guárdala en la variable val 
  //  println(valor);

//Promediar
  //valueAvg = vsum / 20;
  valueAvg = (valorAnterior + valor ) /2 ;






  //delta = abs(valorAnterior-valor);
  //acelerando = false;

  //if ( delta > 10) { 
  //  tiempoUltimaAcel = millis();
  //  acelerando = true;
  //}
}







// https://processing.org/examples/lineargradient.html
int Y_AXIS = 1;
int X_AXIS = 2;
void setGradient(int x, int y, float w, float h, color c1, color c2, int axis ) {

  noFill();
  noStroke();


  if (axis == Y_AXIS) {  // Top to bottom gradient
    for (int i = y; i <= y+h; i++) {
      float inter = map(i, y, y+h, 0, 1);
      color c = lerpColor(c1, c2, inter);
      fill(c);
      line(x, i, x+w, i);
    }
  } else if (axis == X_AXIS) {  // Left to right gradient
    for (int i = x; i <= x+w; i++) {
      float inter = map(i, x, x+w, 0, 1);
      color c = lerpColor(c1, c2, inter);
      stroke(c);
      line(i, y, i, y+h);
    }
  }
}
