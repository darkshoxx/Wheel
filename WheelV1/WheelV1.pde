PImage centerpiece;   //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>//
PImage[] images;
String path;
String[] imagestrings;
String[] segments;
String[] colours;
float angle2 = random(0, 2*PI);
float angle3 = 0;
boolean showresult = false;
boolean isPressed = false;
String displayText="";
String emptyText = "";
String placeholderText="";
String myDefaultPathWin = "C:/Code/GithubRepos/Wheel/WheelV1";
String myDefaultPathLin = "/mnt/c/Code/GithubRepos/Wheel/";
int centerpieceYOffset = 0;
long timestamp = 0;
import processing.sound.*;
import java.io.File;
import javax.swing.JFileChooser;
import javax.swing.JOptionPane;

SoundFile tick;

void exitWithMessage(String message) {
  JOptionPane.showMessageDialog(null, message, "Error", JOptionPane.ERROR_MESSAGE);
  println(message);
  System.exit(0);
}

void setup() {
  background(255);
  size(800, 800);
  String configfile = "config.txt";
  File fileObject = new File(configfile);
  if (!fileObject.exists()) {
    JFileChooser chooser = new JFileChooser(myDefaultPathWin);
    chooser.setDialogTitle("Please select config.txt");
    //chooser.setFileSelectionMode(JFileChooser.DIRECTORIES_ONLY);
    if ( chooser.showOpenDialog(null) != JFileChooser.APPROVE_OPTION) {
      exitWithMessage("No path selected, terminating!");
    }
    //configfile = chooser.getSelectedFile().getAbsolutePath()+"/config.txt";

    configfile = chooser.getSelectedFile().getAbsolutePath();
    println(configfile);
    fileObject = new File(configfile);
    if (!fileObject.exists()) {
      exitWithMessage("Path does not contain config file! Terminating!");
      //String mypath = JOptionPane.showInputDialog("yadaya");
    }
  }

  String[] configs = loadStrings(configfile);
  path = configs[0];
  //tick = new SoundFile(this, path + "/" + configs[2]);
  try {
    centerpiece = loadImage(path +"/" + configs[3]);
  }
  catch (java.lang.NullPointerException e) {
    println("no image found");
    centerpiece = null;
  }

  try {
    imagestrings = loadStrings(path +"/" + configs[5]);
    PImage[] images = new PImage[imagestrings.length];

    for (int i=0; i<imagestrings.length; i++) {
      try {

        String tempImagePath =  path + "/" + imagestrings[i];
        PImage tempImageObj = loadImage(tempImagePath);
        tempImageObj.resize(width, height);
        images[i] = tempImageObj;
      }

      catch (java.lang.NullPointerException e) {
        println("no images found");
        images[i] = null;
      }
    }
  }



  catch (java.lang.NullPointerException e) {
    println("no image file found");
    imagestrings = null;
  }



  try {
    tick = new SoundFile(this, path + "/" + configs[2]);
  }
  catch (java.lang.NullPointerException e) {
    println("no soundfile found");
    tick = null;
  }
  catch(java.lang.RuntimeException e) {
    println("soundfile error");
    tick = null;
  }

  try {
    segments = loadStrings(path +"/" + configs[1]);
  }
  catch (java.lang.NullPointerException e) {
    println("no segments found");
    segments = null;
  }

  try {
    colours = loadStrings(path +"/" + configs[4]);
  }
  catch (java.lang.NullPointerException e) {
    println("no colours found");
    colours = null;
  }
}

color get_first_colour_from_line(String colourline) {
  int len = colourline.length();
  if (len>6) {
    return unhex("FF" + colourline.substring(1, 7));
  }
  println("Could not get colour");
  return unhex("FF000000");
}

color get_second_colour_from_line(String colourline) {
  int len = colourline.length();
  if (len>14) {
    return unhex("FF" + colourline.substring(9, 15));
  }
  println("Could not get colour");
  return unhex("FF000000");
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
    if (tick != null) {
      tick.play();
    }
  }

  // draw centerpiece
  if (centerpiece != null) {
    centerpieceYOffset = 0;
    if (timestamp + 100 > System.currentTimeMillis() ) {
      centerpieceYOffset = 10;
    }
    image(centerpiece, half - c_rad, half - c_rad + centerpieceYOffset, 2*c_rad, 2*c_rad);
  } else {
    ellipse(half, half, 2*c_rad, 2*c_rad);
  }
  // draw triangle
  fill(200);
  triangle(full - 2*c_rad, half, almost+boundary/2, half - c_rad, almost+boundary/2, half + c_rad);
  if (showresult) {
    rect(quarter-5, quarter, half+10, quarter/2);
    fill(0);
    float textHeight = determineFontSize(displayText, half, quarter/2);
    textSize(textHeight);
    float tWidth = textWidth(displayText);
    float b = (half - tWidth)/2;
    float a = (quarter/2 - textHeight)/2;
    float px = quarter + b;
    float py = quarter + a + textHeight;
    if ((millis()%1000)>500 ) {
      placeholderText = displayText;
    } else {
      placeholderText = emptyText;
    }
    text(placeholderText, px, py) ;
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
    blue = upper; //<>// //<>//
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
  return_colours[2] = round(blue); //<>// //<>//
  return return_colours;
}

float determineFontSize(String inputText, float targetWidth, float maxHeightSize) {
  textSize(25);
  float currentWidth = textWidth(inputText);
  float maxWidthSize = 25*(targetWidth/currentWidth);
  return max(min(maxWidthSize, maxHeightSize), 10);
}

void drawLabels(float half, float angle, float angle2, float almost, int segnum) {
  float text_angle = 2*PI/segnum;
  translate(half, half);
  rotate(angle/2+ angle2);
  for (int i=0; i< segments.length; i++) {
    fill(get_first_colour_from_line(colours[i]));
    rotate(angle);

    //float currentWidth = textWidth();
    float targetWidth = almost/2 - 150;
    // float maxWidthSize = 25*(targetWidth/currentWidth);
    float maxHeightSize = 0;
    if (segnum == 2) {
      maxHeightSize = 100;
    } else {
      maxHeightSize = tan(text_angle/2)*100;
    }


    float newSize = determineFontSize(segments[i], targetWidth, maxHeightSize);
    if (newSize<10) {
      //segments[i] = segments[i].substring(0, min(40, segments[i].length()));
      newSize = 10;
    }
    textSize(newSize);
    float adjustAngle = asin(newSize/(almost/2));
    rotate(adjustAngle);
    text(segments[i], 100, 0);
    rotate(-adjustAngle);
  }
  rotate(-angle/2 - angle2);
  translate(-half, -half);
}

void drawSegments(float half, float almost, float angle, float angle2) {
  for (int i=0; i< segments.length; i++) {
    //println(segments[i]);
    if (colours != null) {
      int fixedindex = ((i+5)%6);
      color inbetween = get_second_colour_from_line(colours[fixedindex]);
      fill(inbetween);
    } else {
      float along = float(i)/segments.length;
      int[] rgb = colourpath(along);
      int red = rgb[0];
      int green = rgb[1];
      int blue = rgb[2];
      fill(red, green, blue);
    }
    if (images != null) {
      PGraphics maskImage;
      maskImage = createGraphics(width, width);
      maskImage.beginDraw();
      maskImage.arc(half, half, almost-10, almost-10, i*angle + angle2, (i+1)*angle + angle2 );
      maskImage.endDraw();
      images[i].mask(maskImage);
      image(images[i], 0, 0);
    } else {
      arc(half, half, almost-10, almost-10, i*angle + angle2, (i+1)*angle + angle2 );
    }
  }
}

void mouseClicked() {
  if (abs(mouseX-height/2)<25 & abs(mouseY-height/2)<25 ) {
    showresult = false;
    isPressed = true;
    timestamp = System.currentTimeMillis() ;
    println(timestamp);
    float denominator =random(23.99, 31.65); // these values represent 3 and 4 complete spins of the wheel. Hence the sample is "fair enough" between the entire range.
    angle3 = 2*PI/denominator;
  }
}
