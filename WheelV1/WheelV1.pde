PImage centerpiece; // object to hold centerpiece image //<>// //<>// //<>//
PImage[] images;    // array to hold segment images
String path;        // base path of text files, images and sounds
String[] imagestrings;  // array of filenames of segment background images
String[] segments;      // array of labels of the segments
String[] colours;       // array of lines from colour text file
String[] weights;       // array of probability weights, to be converted into probabilities
float[] probabilities;  // array of probabilies, to be converted into angles
float[] cumulativeAngles;  // array of angles
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
int half;
int quarter;
int removalIndex;
int serverPort;
int[] clientPorts;
Client[] clients;
String wheelName;
boolean signalSent = false;

import processing.sound.*;
import java.io.File;
import javax.swing.JFileChooser;
import javax.swing.JOptionPane;
import processing.net.*;

Server server;   // server for external comms

SoundFile tick;  // object to carry tick sound.

// File loaders and Error Handlers

void exitWithMessage(String message) {
  JOptionPane.showMessageDialog(null, message, "Error", JOptionPane.ERROR_MESSAGE);
  println(message);
  System.exit(0);
}

PImage safeLoadImage(String path, String errorMessage, boolean stretch) {
  try {
    PImage loadedImage = loadImage(path);
    if (stretch) {
      loadedImage.resize(width, height);
    }
    return loadedImage;
  }
  catch(java.lang.NullPointerException e) {
    println(errorMessage);
    return null;
  }
}


String[] safeLoadStrings(String path, String errorMessage) {
  try {
    return loadStrings(path);
  }
  catch(java.lang.NullPointerException e) {
    println(errorMessage);
    return null;
  }
}

SoundFile safeLoadSoundFile(String path, String errorMessage) {

  try {
    tick = new SoundFile(this, path);
    tick.play();
    return tick;
  }
  catch(java.lang.NullPointerException e) {
    println(errorMessage);
    return null;
  }
  catch(java.lang.RuntimeException e) {
    println("The soundfile was found but could not be loaded!");
    return null;
  }
}


int findIndex(float angleRot) {
  if (angleRot <0) {
    while (angleRot < 0)
    {
      angleRot = angleRot + 2*PI;
    }
  } else {
    while (angleRot > 2*PI)
    {
      angleRot = angleRot - 2*PI;
    }
  }
  float[] cumulativeAngles = determineAngles();
  for (int i=0; i< segments.length; i++) {
    if ((cumulativeAngles[i]<angleRot)&&(angleRot<cumulativeAngles[i+1]))
    {
      return i;
    }
  }
  return 0;
}

void setup() {
  background(0, 255, 0);
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


  centerpiece = safeLoadImage(path +"/" + configs[3], "No centerpiece image found", false);


  imagestrings = safeLoadStrings(path +"/" + configs[5], "No image file found");
  if (imagestrings != null) {
    images = new PImage[imagestrings.length];

    for (int i=0; i<imagestrings.length; i++) {

      images[i] = safeLoadImage(path + "/" + imagestrings[i], "Segment image file not found", true);
    }
  }

  tick = safeLoadSoundFile(path + "/" + configs[2], "No soundfile found");

  segments = safeLoadStrings(path +"/" + configs[1], "no segments found");

  colours = safeLoadStrings(path +"/" + configs[4], "no colours found");

  weights = safeLoadStrings(path +"/" + configs[6], "no weights found");

  serverPort = int(configs[8]);
  String clientPortString = configs[9];
  String[] clientPortStrings = clientPortString.split(" ");
  clientPorts = new int[clientPortStrings.length];
  for (int i=0; i<clientPortStrings.length; i++) {
    clientPorts[i] = int(clientPortStrings[i]);
  }
  clients = new Client[clientPortStrings.length];
  for (int i=0; i<clientPortStrings.length; i++) {
    clients[i] = new Client(this, "127.0.0.1", clientPorts[i]);
  }

  wheelName = configs[7];
  surface.setTitle(wheelName);

  // Start server for communcation with outside
  server = new Server(this, serverPort);
}

float[] convertWeightsToProbs(String[] weights) {
  boolean allIsWell = true;
  float[] probs = new float[weights.length];
  float accumulator = 0;
  for (int i=0; i< weights.length; i++) {
    try {
      probs[i] = float(weights[i]);
      accumulator += probs[i];
    }
    catch(java.lang.NullPointerException e) {
      allIsWell = false;
    }
  }
  if (accumulator<=0) {
    allIsWell = false;
  } else {
    for (int i=0; i< weights.length; i++) {
      probs[i] = probs[i]/accumulator;
    }
  }
  if (!allIsWell) {
    for (int i=0; i< weights.length; i++) {
      probs[i] = 1/weights.length;
    }
  }
  return probs;
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
  //println("Could not get colour");
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
  //println("Could not get colour");
  return unhex("FF000000");
}

void draw() {
  // Begin Server/Client communications
  Client client = server.available();
  if (client != null) {
    String data = client.readString();
    println(data);
    if (data.equals("Spin " + wheelName)) {
      spinTheWheel();
    }
  }
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

  probabilities = convertWeightsToProbs(weights);


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
    removalIndex =(segnum  + (findIndex(-angle2))) % segnum;//(segnum-1) - (ceil((angle2/angle)) % segnum);
    displayText = segments[removalIndex];
    if (!showresult) {
      signalSent=false;
    }
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
  //float oldAngleScale = oldAngle/(2*PI)*segnum;
  //float newAngleScale = angle2/(2*PI)*segnum;
  int oldAngleIndex = findIndex(-oldAngle);
  int newAngleIndex = findIndex(-angle2);
  if (oldAngleIndex != newAngleIndex) {
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
    // rect to display removal option
    fill(200, 0, 0);
    rect(quarter-5, half + quarter/2, half+10, quarter/2);
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
    textSize(50);
    text("Remove Segment?", quarter+5, half+quarter-30);
    noFill();
    if (!signalSent) {
      sendSegmentToServers(displayText);
      signalSent = true;
    }
  }
}

void sendSegmentToServers(String broadcastText) {
  for (Client client : clients) {
    client.write(broadcastText);
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
  // requires integers
  return_colours[0] = round(red);
  return_colours[1] = round(green);
  return_colours[2] = round(blue);
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
  cumulativeAngles = determineAngles();
  //float text_angle = 2*PI/segnum;
  // center of rotation is center of wheel
  translate(half, half);
  rotate(angle2);
  for (int i=0; i< segments.length; i++) {
    // get font colour
    color fontColour = 0;
    color fontColour2 = 0;
    if (colours != null) {
      fontColour = get_first_colour_from_line(colours[i%colours.length]);
      fontColour2 = get_second_colour_from_line(colours[i%colours.length]);
    }
    float thisAngle = probabilities[i]*2*PI;
    rotate(thisAngle);
    // inital estimates on font size, requried for helper function
    float targetWidth = almost/2 - 150;
    float maxHeightSize = 0;
    //if (segnum == 2) {
    //  maxHeightSize = 100;
    //} else {
    maxHeightSize = tan(probabilities[i]*2*PI /2)*100;
    //}
    if (maxHeightSize >100) {
      maxHeightSize = 100;
    }

    float newSize = determineFontSize(segments[i], targetWidth, maxHeightSize);
    // size minimum: 10
    if (newSize<10) {
      newSize = 10;
    }
    textSize(newSize);
    // rotate font in each segments
    float adjustAngle = asin(newSize/(almost/2));
    rotate(-thisAngle/2);
    int heightShift = int(newSize/3); // this should be /2 but /3 looks better.
    strokeText(segments[i], 100, heightShift, 0, fontColour, newSize);
    // strokeText(segments[i], 100, 0, fontColour2, fontColour); // optional: choose font border yourself
    // rotate back to origin for next segment
    rotate(thisAngle/2);
  }
  // undo rotation and translation to return to original point of reference (top right corner)
  rotate( - angle2);
  translate(-half, -half);
}

float[] determineAngles() {
  float accumulator = 0.0;
  float[] cumulativeAngles = new float[segments.length+1];
  cumulativeAngles[0] = 0.0;
  for (int i=1; i<= segments.length; i++) {
    cumulativeAngles[i] = probabilities[i-1]*2*PI + accumulator;
    accumulator += probabilities[i-1]*2*PI;
  }
  return cumulativeAngles;
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
  cumulativeAngles = determineAngles();


  for (int i=0; i< segments.length; i++) {
    // get segment bg colours if available
    if (colours != null) {
      // I somehow messed up the index further down, so I'm hiding the crimes in this
      // fixedindex variable
      int fixedindex = ((i+segments.length - 1)%segments.length);
      color inbetween = get_second_colour_from_line(colours[fixedindex%colours.length]);
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
      maskImage.arc(half, half, almost-10, almost-10, cumulativeAngles[i] + angle2, cumulativeAngles[i+1] + angle2 );
      maskImage.endDraw();
      PImage currentImage = images[(fixedindex+1)%images.length];
      currentImage.mask(maskImage);
      image(currentImage, 0, 0);
    } else {
      arc(half, half, almost-10, almost-10, cumulativeAngles[i] + angle2, cumulativeAngles[i+1] + angle2 );
    }
  }
}

void strokeText(String message, int x, int y, color c1, color c2, float fontsize)
{
  float thickness = fontsize/25;
  fill(c1);
  text(message, x-thickness, y);
  text(message, x, y-thickness);
  text(message, x+thickness, y);
  text(message, x, y+thickness);
  fill(c2);
  text(message, x, y);
}

void spinTheWheel() {
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

//void keyPressed(KeyEvent e){
//if (e.isControlDown()  && e.isShiftDown() && e.isAltDown()) {
//        spinTheWheel();
//}
//}

String[] removeWeight(String[] weights, int index) {
  String[] newWeights = new String[weights.length-1];
  for (int i=0; i< weights.length; i++) {
    if (i < index) {
      newWeights[i] = weights[i];
    }
    if (i> index) {
      newWeights[i-1] = weights[i];
    }
  }
  return newWeights;
}

PImage[] removeImage(PImage[] images, int index) {

  PImage[] newImages = new PImage[images.length-1];
  for (int i=0; i< images.length; i++) {
    if (i < index) {
      newImages[i] = images[i];
    }
    if (i> index) {
      newImages[i-1] = images[i];
    }
  }
  return newImages;
}


String[] removeSegment(String[] segments, int index) {

  String[] newSegments = new String[segments.length-1];
  for (int i=0; i< segments.length; i++) {
    if (i < index) {
      newSegments[i] = segments[i];
    }
    if (i> index) {
      newSegments[i-1] = segments[i];
    }
  }
  return newSegments;
}

void mouseClicked() {
  // TODO: for some reason, sometimes clicks are not registered.
  if (abs(mouseX-height/2)<25 & abs(mouseY-height/2)<25 ) {
    spinTheWheel();
  }
  half = height/2;
  quarter = half/2;
  if ((mouseX >quarter-5) & (mouseX < half+quarter+5) & (mouseY <half + quarter) & (mouseY >half + quarter - quarter/2)) {
    segments = removeSegment(segments, removalIndex);
    if (images!=null) {
      images = removeImage(images, removalIndex);
    }
    if (weights!=null) {
      weights = removeWeight(weights, removalIndex);
    }
    showresult=false;
  }
}
