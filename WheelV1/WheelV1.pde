PImage centerpiece;
String path;
String[] segments;
float angle2 = 0;
float angle3 = 0;

void setup() {
  background(255);
  size(800, 800);
  path = "C:\\code\\processing-4.3\\Wheel\\";
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
  angle3 = (angle3)*0.99;
  angle2 = angle2 + angle3;
  var c_rad = 25;

  var full = height;
  var half = height/2;
  var quarter = height/4;
  var boundary = 10;
  var almost = full - boundary;
  var angle = 2*PI/segments.length;
  fill(100);
  ellipse(half, half, almost, almost);
  fill(200);
  //draw segments
  for (int i=0; i< segments.length; i++) {
    //println(segments[i]);
    fill(i*255/segments.length);

    arc(half, half, almost-10, almost-10, i*angle + angle2, (i+1)*angle + angle2 );
  }
  //label segments
  translate(half, half);
  rotate(angle/2+ angle2);
  for (int i=0; i< segments.length; i++) {
    fill(0, 255, 100*i);
    rotate(angle);
    text(segments[i], 50, 0);
  }
  rotate(-angle/2 - angle2);
  translate(-half, -half);
  if (centerpiece != null) {
    image(centerpiece, half - c_rad, half - c_rad, 2*c_rad, 2*c_rad);
  } else{
    ellipse(half, half, 2*c_rad, 2*c_rad);
  }
  fill(200);
  triangle(full - 2*c_rad, half, almost+boundary/2, half - c_rad, almost+boundary/2, half + c_rad);
  //println(angle2);
}

void mouseClicked() {
  if (abs(mouseX-height/2)<25 & abs(mouseY-height/2)<25 ) {
    angle2 = random(2*PI);
    println("random angle");
    println(angle2);
    angle3 = PI/20;
  }
}
