PImage centerpiece;
String path;
String[] segments;
float angle2 = random(0, 2*PI);
float angle3 = 0;
float speed = 0;
import processing.sound.*;
SoundFile tick;

void setup() {
  background(255);
  size(800, 800);
  path = "C:\\code\\processing-4.3\\Wheel\\";
  tick = new SoundFile(this, path + "sound_click.wav");
  tick.play();
  try {
    centerpiece = loadImage(path + "center1.png");
  }
  catch (java.lang.NullPointerException e) {
    println("no image found");
    centerpiece = null;
  }

  try {
    segments = loadStrings(path + "segments.txt");
  }
  catch (java.lang.NullPointerException e) {
    println("no image found");
    segments = null;
  }
}

void draw() {
  if (segments == null){
      segments = new String[2];
    segments[0] = "Heads";
    segments[1] = "Tails";
  }
  var friction = 0.99;
  if (angle3<0.009) {
    friction=0.9;
  }
  angle3 = (angle3)*friction;
  if (angle3<1e-7) {
    angle3 = 0;
    println("WHEEL STOPPED");
  }
  angle2 = angle2 + angle3;
  int c_rad = 25;

  float full = height;
  float half = height/2;
  float quarter = height/4;
  float boundary = 10;
  float almost = full - boundary;
  float angle = 2*PI/segments.length;
  fill(100);
  ellipse(half, half, almost, almost);
  fill(200);
  //draw segments
  drawSegments(half, almost, angle, angle2);
  //label segments
  drawLabels(half, angle, angle2);
  if (centerpiece != null) {
    image(centerpiece, half - c_rad, half - c_rad, 2*c_rad, 2*c_rad);
  } else{
    ellipse(half, half, 2*c_rad, 2*c_rad);
  }
  fill(200);
  triangle(full - 2*c_rad, half, almost+boundary/2, half - c_rad, almost+boundary/2, half + c_rad);
  //println(angle2);
}

void drawLabels(float half, float angle, float angle2){
  translate(half, half);
  rotate(angle/2+ angle2);
  for (int i=0; i< segments.length; i++) {
    fill(0, 255, 100*i);
    rotate(angle);
    text(segments[i], 50, 0);
  }
  rotate(-angle/2 - angle2);
  translate(-half, -half);
}

void drawSegments(float half, float almost, float angle, float angle2){
  for (int i=0; i< segments.length; i++) {
    //println(segments[i]);
    fill(i*255/segments.length);

    arc(half, half, almost-10, almost-10, i*angle + angle2, (i+1)*angle + angle2 );
  }
}

void mouseClicked() {
  if (abs(mouseX-height/2)<25 & abs(mouseY-height/2)<25 ) {
    float denominator =random(23.99, 31.65); // these values represent 3 and 4 complete spins of the wheel. Hence the sample is "fair enough" between the entire range.
    angle3 = 2*PI/denominator; 
  }
}
