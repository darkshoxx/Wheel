PImage centerpiece; // object to hold centerpiece image //<>//
PImage[] images;    // array to hold segment images
String path;        // base path of text files, images and sounds
String[] imagestrings;  // array of filenames of segment background images
String[] segments;      // array of labels of the segments
String[] colours;       // array of lines from colour text file
float angle2 = random(0, 2*PI);  // initial wheel rotation, will be changed by spinning
float angle3 = 0;                // initial offset, 0 means stopped, will jump up on spinning and decrease with friction
boolean showresult = false;    // bool to check for displaying result of spin
boolean isPressed = false;     // bool to check button press depth
String displayText="";         // label of segment the wheel has landed on AKA the result
String emptyText = "";         // constant, helper string for flashing text
String placeholderText="";     // recieves displaytext and emptytext in sequence. Is displayed
String myDefaultPathWin = "C:/Code/GithubRepos/Wheel/WheelV1";  //shoddy hack for convenience
String myDefaultPathLin = "/mnt/c/Code/GithubRepos/Wheel/";     //shoddy hack for convenience
int centerpieceYOffset = 0;  // button pressing depth
long timestamp = 0;          // button pressing time


import processing.sound.*;
import java.io.File;
import javax.swing.JFileChooser;
import javax.swing.JOptionPane;


SoundFile tick;  // object to carry tick sound.

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
    if ( chooser.showOpenDialog(null) != JFileChooser.APPROVE_OPTION) {
      exitWithMessage("No path selected, terminating!");
    }

    configfile = chooser.getSelectedFile().getAbsolutePath();
    println(configfile);
    fileObject = new File(configfile);
    if (!fileObject.exists()) {
      exitWithMessage("Path does not contain config file! Terminating!");
    }
  }

  String[] configs = loadStrings(configfile);
  path = configs[0];
  try {
    centerpiece = loadImage(path +"/" + configs[3]);
  }
  catch (java.lang.NullPointerException e) {
    println("no image found");
    centerpiece = null;
  }

  try {
    imagestrings = loadStrings(path +"/" + configs[5]);
    images = new PImage[imagestrings.length];

    for (int i=0; i<imagestrings.length; i++) {
      try {

        String tempImagePath =  path + "/" + imagestrings[i];
        PImage tempImageObj = loadImage(tempImagePath); //<>//
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

/**
* Parses a line of the colour file to return the first colour
*
* @param  colourline   the line to be parsed
* @return              the first colour object
*/
color get_first_colour_from_line(String colourline) {
  int len = colourline.length();
  if (len>6) {
    return unhex("FF" + colourline.substring(1, 7));
  }
  println("Could not get colour");
  return unhex("FF000000");
}

/**
* Parses a line of the colour file to return the second colour
*
* @param  colourline   the line to be parsed
* @return              the second colour object
*/
color get_second_colour_from_line(String colourline) {
  int len = colourline.length();
  if (len>14) {
    return unhex("FF" + colourline.substring(9, 15));
  }
  println("Could not get colour");
  return unhex("FF000000");
}

void draw() {
  // If no segment file given, default to coin toss
  if (segments == null) {
    segments = new String[2];
    segments[0] = "Heads";
    segments[1] = "Tails";
  }
  // truncate lenght of segment lables to 40
  for (int i=0; i< segments.length; i++) {
    segments[i] = segments[i].substring(0, min(40, segments[i].length()));
  }
  // decrease rate of wheel. 0.99 corresponds to exactly 3 to 4 rotations with the given
  // denominator values in the mouseClicked event. lower number means decrease faster.
  var friction = 0.99; 
  // convenience variables
  int segnum = segments.length;
  float angle = 2*PI/segnum;
  float quarter = height/4;
  float half = height/2;
  float full = height;
  // if not much turning left, decrease rate.
  if (angle3<0.009) {
    friction=0.9;
  }
  // apply friction
  angle3 = (angle3)*friction;
  // on the last moments: Stop wheel, return result
  if (angle3<1e-7&angle3>0) {
    angle3 = 0;
    displayText = segments[(segnum-1) - (ceil((angle2/angle)) % segnum)];
    showresult = true;
  }
  // see top of file to see how angles work
  float oldAngle = angle2;
  angle2 = angle2 + angle3;
  int c_rad = 25;
  float boundary = 10;
  // Wheel of radius "almost" sits in slightly larger socket of size "full"
  float almost = full - boundary;
  // draw grey socket
  fill(100);
  ellipse(half, half, almost, almost);
  // test for segment change
  boolean newSegment = false;
  float oldAngleScale = oldAngle/(2*PI)*segnum;
  float newAngleScale = angle2/(2*PI)*segnum;
  if (floor(oldAngleScale) != floor(newAngleScale)) {
    newSegment = true;
  }


  // draw segments
  drawSegments(half, almost, angle, angle2);
  // label segments
  drawLabels(half, angle, angle2, almost, segnum);
  // play tick sound
  if (newSegment) {
    if (tick != null) {
      tick.play();
    }
  }

  // draw centerpiece
  if (centerpiece != null) {
    centerpieceYOffset = 0;
    // lower centerpiece by 10 pixels right after click to give impression of pressing button.
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
  // show result
  if (showresult) {
    // rect to display text
    rect(quarter-5, quarter, half+10, quarter/2);
    fill(0);
    // geometry calculations to ensure text fits in box
    float textHeight = determineFontSize(displayText, half, quarter/2);
    textSize(textHeight);
    float tWidth = textWidth(displayText);
    float b = (half - tWidth)/2;
    float a = (quarter/2 - textHeight)/2;
    float px = quarter + b;
    float py = quarter + a + textHeight;
    // font flashing every half second
    if ((millis()%1000)>500 ) {
      placeholderText = displayText;
    } else {
      placeholderText = emptyText;
    }
    text(placeholderText, px, py) ;
    noFill();
  }
}

/**
* Converts float between 0 and 1 to position on colour wheel
*
* @param  along   float between 0 and 1
* @return         integer array of 3 colours (R,G,B) 
*/
int[] colourpath(float along) {
  int[] return_colours = new int[3];
  // default to black if wrong float is given
  if (along<0.0 || along >1.0) {
    return_colours[0] = 0;
    return_colours[1] = 0;
    return_colours[2] = 0;
    return return_colours;
  }
  // upper and lower bounds of each colour. (100,255) corresponds to a pastel-like selection
  int lower = 100;
  int upper = 255;

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

  // actual algorithm. In each of the six segments keep to colours constant and set the 
  // third to the opposit limit.
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
    blue = upper;  //<>//
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
  // requires integers
  return_colours[0] = round(red);
  return_colours[1] = round(green);
  return_colours[2] = round(blue);  //<>//
  return return_colours;
}

/**
* Helper function to find the right font for  long text in a rectanlge. Used in both
* segment labelling and result presentation.
*
* @param  inputText       string to be displayed
* @param  targetWidth     maximal font width
* @param  maxHeightSize   maximal font height
* @return                 float as font size 
*/
float determineFontSize(String inputText, float targetWidth, float maxHeightSize) {
  textSize(25);
  float currentWidth = textWidth(inputText);
  float maxWidthSize = 25*(targetWidth/currentWidth);
  return max(min(maxWidthSize, maxHeightSize), 10);
}

/**
* Helper function draw the labels onto the segments
*
* @param  half     half screen size, required for translations
* @param  angle    angle 1, see explanation at top of file
* @param  angle2   angle 1, see explanation at top of file
* @param  almost   size of wheel
* @param  segnum   int, number of segments
*/
void drawLabels(float half, float angle, float angle2, float almost, int segnum) {
  float text_angle = 2*PI/segnum;
  // center of rotation is center of wheel
  translate(half, half);
  rotate(angle/2+ angle2);
  for (int i=0; i< segments.length; i++) {
    // get font colour 
    if (colours != null){
    fill(get_first_colour_from_line(colours[i]));
    } else {
    //default font colour: black
    fill(0);
    }
    rotate(angle);
    // inital estimates on font size, requried for helper function
    float targetWidth = almost/2 - 150;
    float maxHeightSize = 0;
    if (segnum == 2) {
      maxHeightSize = 100;
    } else {
      maxHeightSize = tan(text_angle/2)*100;
    }


    float newSize = determineFontSize(segments[i], targetWidth, maxHeightSize);
    // size minimum: 10
    if (newSize<10) {
      newSize = 10;
    }
    textSize(newSize);
    // rotate font in each segments
    float adjustAngle = asin(newSize/(almost/2));
    rotate(adjustAngle);
    text(segments[i], 100, 0);
    // rotate back to origin for next segment
    rotate(-adjustAngle);
  }
  // undo rotation and translation to return to original point of reference (top right corner)
  rotate(-angle/2 - angle2);
  translate(-half, -half);
}

/**
* Helper function draw the segments
*
* @param  half     half screen size, required for translations
* @param  angle    angle 1, see explanation at top of file
* @param  angle2   angle 1, see explanation at top of file
* @param  almost   size of wheel
*/
void drawSegments(float half, float almost, float angle, float angle2) {
  for (int i=0; i< segments.length; i++) {
    // get segment bg colours if available
    if (colours != null) { //<>//
      // I somehow messed up the index further down, so I'm hiding the crimes in this 
      // fixedindex variable
      int fixedindex = ((i+segments.length - 1)%segments.length);
      color inbetween = get_second_colour_from_line(colours[fixedindex]);
      fill(inbetween);
    } else {
      // no background colours: follow colour wheel
      float along = float(i)/segments.length;
      int[] rgb = colourpath(along);
      int red = rgb[0];
      int green = rgb[1];
      int blue = rgb[2];
      fill(red, green, blue);
    }
    // images present overrides everything
    if (images != null) {
      PGraphics maskImage;
      int fixedindex = ((i+segments.length - 1)%segments.length);
      // the arc becomes a mask to mask out everything OTHER than the arc from the picture
      maskImage = createGraphics(width, width);
      maskImage.beginDraw();
      maskImage.arc(half, half, almost-10, almost-10, i*angle + angle2, (i+1)*angle + angle2 );
      maskImage.endDraw();
      images[fixedindex].mask(maskImage);
      image(images[fixedindex], 0, 0);
    } else { //<>//
      arc(half, half, almost-10, almost-10, i*angle + angle2, (i+1)*angle + angle2 );
    }
  }
}

void mouseClicked() {
  // TODO: for some reason, sometimes clicks are not registered.
  if (abs(mouseX-height/2)<25 & abs(mouseY-height/2)<25 ) {
    // hide result when pressed
    showresult = false;
    isPressed = true;
    // required for measuring lenght of button press
    timestamp = System.currentTimeMillis();
    float denominator = random(23.99, 31.65); 
    // these values represent 3 and 4 complete spins of the wheel.
    // Hence the sample is "fair enough" between the entire range.
    angle3 = 2*PI/denominator;
  }
}
