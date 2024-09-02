PImage centerpiece;
String path;
String[] segments;
float angle2 = random(0, 2*PI);
float angle3 = 0;
import processing.sound.*;
SoundFile tick;

void setup() {
  background(255);
  size(800, 800);
  path = "C:\\code\\GithubRepos\\Wheel\\";
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
  if (segments == null) {
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
    // println("WHEEL STOPPED");
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
  } else {
    ellipse(half, half, 2*c_rad, 2*c_rad);
  }
  fill(200);
  triangle(full - 2*c_rad, half, almost+boundary/2, half - c_rad, almost+boundary/2, half + c_rad);
  //println(angle2);
}

int[] colourpath(float along) {
  int[] return_colours = new int[3]; 
    if (along<0.0 || along >1.0) { //<>// //<>// //<>//
    return_colours[0] = 0;
      return_colours[1] = 0;
      return_colours[2] = 0;
      return return_colours;
  }
  int upper = 255;
  int lower = 100;
  float along_six = along*6;
  float decimals = along_six - floor(along_six);
  float red = upper;
  float green = lower;
  float blue = lower;
  //0 100
  //1 110
  //2 010
  //3 011
  //4 001
  //5 101
  //6 100

switch(floor(along_six)){
  case 0:
  red = upper;
  green = lower + (upper - lower)*decimals;
  blue = lower;
  break;
  case 1:
  red = upper + (lower - upper)*decimals;
  green = upper;
  blue = lower;
  break;
  case 2:
  red = lower;
  green = upper;
  blue = lower + (upper - lower)*decimals;
  break;
  case 3:
  red = lower;
  green = upper + (lower - upper)*decimals;
  blue = upper;
  break;
  case 4:
  red = lower + (upper - lower)*decimals;
  green = lower;
  blue = upper;
  break;
  case 5:
  red = upper;
  green = lower;
  blue = upper + (lower - upper)*decimals;
  break;
}



  return_colours[0] = round(red);
    return_colours[1] = round(green);
    return_colours[2] = round(blue);
    return return_colours;
}

void drawLabels(float half, float angle, float angle2) {
  translate(half, half);
  rotate(angle/2+ angle2);
  for (int i=0; i< segments.length; i++) {
    fill(0);
    rotate(angle);
    text(segments[i], 150, 0);
  }
  rotate(-angle/2 - angle2);
  translate(-half, -half);
}

void drawSegments(float half, float almost, float angle, float angle2) {
  for (int i=0; i< segments.length; i++) {
    //println(segments[i]);
    float along = float(i)/segments.length; //<>//
    int[] rgb = colourpath(along);
    int red = rgb[0];
    int green = rgb[1];
    int blue = rgb[2];
    fill(red, green, blue);

    arc(half, half, almost-10, almost-10, i*angle + angle2, (i+1)*angle + angle2 );
  }
}

void mouseClicked() {
  if (abs(mouseX-height/2)<25 & abs(mouseY-height/2)<25 ) {
    float denominator =random(23.99, 31.65); // these values represent 3 and 4 complete spins of the wheel. Hence the sample is "fair enough" between the entire range.
    angle3 = 2*PI/denominator;
  }
}
