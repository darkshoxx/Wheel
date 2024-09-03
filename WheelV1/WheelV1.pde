PImage centerpiece;   //<>// //<>// //<>// //<>//
String path;
String[] segments;
float angle2 = random(0, 2*PI);
float angle3 = 0;
boolean showresult = false;
String displayText="";
String emptyText = "";
String placeholderText="";
import processing.sound.*;
SoundFile tick;

void setup() {
  background(255);
  size(800, 800);
  path = "C:\\code\\GithubRepos\\Wheel\\";
  tick = new SoundFile(this, path + "click_short.wav");
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
  // truncate segments
  for (int i=0; i< segments.length; i++) {
    segments[i] = segments[i].substring(0, min(40, segments[i].length()));
  }
  var friction = 0.99;
  int segnum = segments.length;
  float angle = 2*PI/segnum;
  float quarter = height/4;
  float half = height/2;
  float full = height;
  if (angle3<0.009) {
    friction=0.9;
  }
  angle3 = (angle3)*friction;
  if (angle3<1e-7&angle3>0) {
    angle3 = 0;
    println("WHEEL STOPPED! Segment index is:");
    println((segnum-1) - (ceil((angle2/angle)) % segnum) );
    println("WHEEL STOPPED! Segment Label is:");
    displayText = segments[(segnum-1) - (ceil((angle2/angle)) % segnum)];
    showresult = true;
  }
  float oldAngle = angle2;
  angle2 = angle2 + angle3;
  int c_rad = 25;



  float boundary = 10;
  float almost = full - boundary;

  fill(100);
  ellipse(half, half, almost, almost);
  fill(200);
  // test for segment change
  boolean newSegment = false;
  float oldAngleScale = oldAngle/(2*PI)*segnum;
  float newAngleScale = angle2/(2*PI)*segnum;
  if (floor(oldAngleScale) != floor(newAngleScale)) {
    newSegment = true;
    // tick.play();
  }


  // draw segments
  drawSegments(half, almost, angle, angle2);
  // label segments
  drawLabels(half, angle, angle2, almost, segnum);

  if (newSegment) {
    tick.play();
  }

  // draw centerpiece
  if (centerpiece != null) {
    image(centerpiece, half - c_rad, half - c_rad, 2*c_rad, 2*c_rad);
  } else {
    ellipse(half, half, 2*c_rad, 2*c_rad);
  }
  // draw triangle
  fill(200);
  triangle(full - 2*c_rad, half, almost+boundary/2, half - c_rad, almost+boundary/2, half + c_rad);
  if (showresult){
      rect(quarter-5, quarter, half+10, quarter/2);
      fill(0);
      float textHeight = determineFontSize(displayText, half, quarter/2);
      textSize(textHeight);
      float tWidth = textWidth(displayText);
      float b = (half - tWidth)/2;
      float a = (quarter/2 - textHeight)/2;
      float px = quarter + b;
      float py = quarter + a + textHeight;
      if ((millis()%1000)>500 ){
      placeholderText = displayText;
      } else {
      placeholderText = emptyText;
      }
      text(placeholderText, px, py) ; //<>//
      noFill();
  }
}

int[] colourpath(float along) {
  int[] return_colours = new int[3];
  if (along<0.0 || along >1.0) {
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

  switch(floor(along_six)) {
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
    blue = upper; //<>// //<>// //<>//
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
  return_colours[2] = round(blue); //<>// //<>// //<>//
  return return_colours;
} 

float determineFontSize(String inputText, float targetWidth, float maxHeightSize){
  textSize(25);
  float currentWidth = textWidth(inputText);
  float maxWidthSize = 25*(targetWidth/currentWidth); //<>//
  return max(min(maxWidthSize, maxHeightSize), 10); //<>//
}

void drawLabels(float half, float angle, float angle2, float almost, int segnum) {
  float text_angle = 2*PI/segnum;
  translate(half, half); //<>//
  rotate(angle/2+ angle2);
  for (int i=0; i< segments.length; i++) {  
    fill(0);
    rotate(angle);

    //float currentWidth = textWidth();
    float targetWidth = almost/2 - 150; //<>//
    // float maxWidthSize = 25*(targetWidth/currentWidth); //<>//
    float maxHeightSize = tan(text_angle/2)*100;
    float newSize = determineFontSize(segments[i], targetWidth, maxHeightSize);
    if (newSize<10) {
      //segments[i] = segments[i].substring(0, min(40, segments[i].length()));
      newSize = 10; //<>//
    }
    textSize(newSize); 
    float adjustAngle = asin(newSize/(almost/2));
    rotate(adjustAngle);
    text(segments[i], 100, 0);
    rotate(-adjustAngle);
  } //<>//
  rotate(-angle/2 - angle2); //<>//
  translate(-half, -half);
}

void drawSegments(float half, float almost, float angle, float angle2) {
  for (int i=0; i< segments.length; i++) { //<>//
    //println(segments[i]);
    float along = float(i)/segments.length; 
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
    showresult = false;
    float denominator =random(23.99, 31.65); // these values represent 3 and 4 complete spins of the wheel. Hence the sample is "fair enough" between the entire range.
    angle3 = 2*PI/denominator;
  }
}
