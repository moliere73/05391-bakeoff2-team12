import java.util.ArrayList;
import java.util.Collections;


//these are variables you should probably leave alone
int index = 0; //starts at zero-ith trial
float border = 0; //some padding from the sides of window, set later
int trialCount = 12; //this will be set higher for the bakeoff
int trialIndex = 0; //what trial are we on
int errorCount = 0;  //used to keep track of errors
float errorPenalty = 0.5f; //for every error, add this value to mean time
int startTime = 0; // time starts when the first click is captured
int finishTime = 0; //records the time of the final click
boolean userDone = false; //is the user done
boolean squareWithCursor = false; // initiates that the square is moving with cursor
boolean gameStarted = false; //used to track whether time should start

final int screenPPI = 72; //what is the DPI of the screen you are using
//you can test this by drawing a 72x72 pixel rectangle in code, and then confirming with a ruler it is 1x1 inch. 

//These variables are for my example design. Your input code should modify/replace these!
float logoX = 500;
float logoY = 500;
float logoZ = 50f;
float logoRotation = 0;

// submit button dimensions
//int buttonWidth = 100;
//int buttonHeight = 40;
//int buttonCenterX = 1000/2; // given size defined in setup, width = 1000
//int buttonCenterY = 800/2; // given size defined in setup, size, height = 800

int buttonWidth = 100;
int buttonHeight = 40;
int buttonCenterX;
int buttonCenterY;

private class Destination
{
  float x = 0;
  float y = 0;
  float rotation = 0;
  float z = 0;
}

ArrayList<Destination> destinations = new ArrayList<Destination>();

void setup() {
  size(1000, 800);  
  rectMode(CENTER);
  textFont(createFont("Arial", inchToPix(.3f))); //sets the font to Arial that is 0.3" tall
  textAlign(CENTER);
  rectMode(CENTER); //draw rectangles not from upper left, but from the center outwards
 
  
  //don't change this! 
  border = inchToPix(2f); //padding of 1.0 inches

  for (int i=0; i<trialCount; i++) //don't change this! 
  {
    Destination d = new Destination();
    d.x = random(border, width-border); //set a random x with some padding
    d.y = random(border, height-border); //set a random y with some padding
    d.rotation = random(0, 360); //random rotation between 0 and 360
    int j = (int)random(20);
    d.z = ((j%12)+1)*inchToPix(.25f); //increasing size from .25 up to 3.0" 
    destinations.add(d);
    println("created target with " + d.x + "," + d.y + "," + d.rotation + "," + d.z);
  }

  Collections.shuffle(destinations); // randomize the order of the button; don't change this.
}



void draw() {
  
  // submit button dimensions
  int buttonCenterX = (int)logoX; // calculate where it should be based on logo
  int buttonCenterY = (int)(logoY - logoZ / 2 - buttonHeight / 2 - 30);

  background(40); //background is dark grey
  
  //===========DRAW GRID=================
  drawGrid(); // Draw the grid before other elements for better visibility
  
  fill(200);
  noStroke();

  //shouldn't really modify this printout code unless there is a really good reason to
  if (userDone)
  {
    text("User completed " + trialCount + " trials", width/2, inchToPix(.4f));
    text("User had " + errorCount + " error(s)", width/2, inchToPix(.4f)*2);
    text("User took " + (finishTime-startTime)/1000f/trialCount + " sec per destination", width/2, inchToPix(.4f)*3);
    text("User took " + ((finishTime-startTime)/1000f/trialCount+(errorCount*errorPenalty)) + " sec per destination inc. penalty", width/2, inchToPix(.4f)*4);
    return;
  }

  //===========DRAW DESTINATION SQUARES=================
  for (int i=trialIndex; i<trialCount; i++) // reduces over time
  {
    pushMatrix();
    Destination d = destinations.get(i); //get destination trial
    translate(d.x, d.y); //center the drawing coordinates to the center of the destination trial
    rotate(radians(d.rotation)); //rotate around the origin of the destination trial
    noFill();
    strokeWeight(3f);
    if (trialIndex==i)
      stroke(255, 0, 0, 192); //set color to semi translucent
    else
      stroke(128, 128, 128, 128); //set color to semi translucent
    rect(0, 0, d.z, d.z);
    popMatrix();
  }

  //===========DRAW LOGO SQUARE=================
  pushMatrix();
  translate(logoX, logoY); //translate draw center to the center oft he logo square
  rotate(radians(logoRotation)); //rotate using the logo square as the origin
  noStroke();
  fill(60, 60, 192, 192);
  rect(0, 0, logoZ, logoZ);
  popMatrix();
  
  // DRAW SUBMIT BUTTON
  if (!squareWithCursor) {
    fill(255, 105, 180); // pink fill color
    rectMode(CENTER);
    rect(buttonCenterX, buttonCenterY, buttonWidth, buttonHeight);
    fill(0);
    textAlign(CENTER, CENTER);
    text("Submit", buttonCenterX, buttonCenterY); 
  }
  
   //===========PROGRESS FEEDBACK=================
  if (checkProgress()) {
    fill(0, 255, 0); // Green text for positive feedback
    textAlign(CENTER);
    text("You're close! Keep adjusting!", width / 2, inchToPix(1.5f));
  }
  
  //===========TRIAL INFORMATION=================
  fill(255);
  textAlign(CENTER);
  text("Trial " + (trialIndex + 1) + " of " + trialCount, width / 2, inchToPix(.8f));
  
  //===========ROTATION FEEDBACK=================
  displayRotationFeedback();
  
  //===========DRAW EXAMPLE CONTROLS=================
  fill(255);
  scaffoldControlLogic(); //you are going to want to replace this!
  //text("Trial " + (trialIndex+1) + " of " +trialCount, width/2, inchToPix(.8f));
}

// Function to draw a smaller, denser grid in the background
void drawGrid() {
  stroke(200, 200, 200, 100); // Very light gray with some transparency
  strokeWeight(1);

  int gridSize = (int) inchToPix(0.25); // Grid cell size of 0.25 inches

  // Draw vertical grid lines
  for (int x = gridSize; x < width; x += gridSize) {
    line(x, 0, x, height);
  }

  // Draw horizontal grid lines
  for (int y = gridSize; y < height; y += gridSize) {
    line(0, y, width, y);
  }
}

// Function to display feedback on rotation angles at the bottom right corner
void displayRotationFeedback() {
  Destination d = destinations.get(trialIndex);
  float angleDifference = (float) calculateDifferenceBetweenAngles(d.rotation, logoRotation);

  fill(255); // White text
  textAlign(RIGHT);
  text("Target Rotation: " + nf(d.rotation, 0, 2) + "°", width - inchToPix(0.5f), height - inchToPix(2.0f));
  text("Your Rotation: " + nf(logoRotation, 0, 2) + "°", width - inchToPix(0.5f), height - inchToPix(1.5f));
  text("Difference: " + nf(angleDifference, 0, 2) + "°", width - inchToPix(0.5f), height - inchToPix(1.0f));
}


// Utility function to check if the user is close to solving the trial
boolean checkProgress() {
  Destination d = destinations.get(trialIndex);

  // Calculate closeness criteria
  boolean closeDist = dist(d.x, d.y, logoX, logoY) < inchToPix(.2f); // within +-0.2"
  boolean closeRotation = calculateDifferenceBetweenAngles(d.rotation, logoRotation) <= 10; // within 10 degrees
  boolean closeZ = abs(d.z - logoZ) < inchToPix(.2f); // within +-0.2"

  // If any of the criteria are met, give feedback
  return (closeDist || closeRotation || closeZ);
}

//my example design for control, which is terrible
void scaffoldControlLogic()
{
  
  // implementation of click and drag for moving logoX and logoY
  if (squareWithCursor)
  {
    logoX = mouseX;
    logoY = mouseY;
  }
  
  //upper left corner, rotate counterclockwise
  text("CCW", inchToPix(.8f), inchToPix(.4f));
  if (mousePressed && dist(0, 0, mouseX, mouseY)<inchToPix(.8f))
    logoRotation--;

  //upper right corner, rotate clockwise
  text("CW", width-inchToPix(.4f), inchToPix(.4f));
  if (mousePressed && dist(width, 0, mouseX, mouseY)<inchToPix(.8f))
    logoRotation++;

  //lower left corner, decrease Z
  text("-", inchToPix(.4f), height-inchToPix(.4f));
  if (mousePressed && dist(0, height, mouseX, mouseY)<inchToPix(.8f))
    logoZ = constrain(logoZ-inchToPix(.02f), .01, inchToPix(4f)); //leave min and max alone!

  //lower right corner, increase Z
  text("+", width-inchToPix(.4f), height-inchToPix(.4f));
  if (mousePressed && dist(width, height, mouseX, mouseY)<inchToPix(.8f))
    logoZ = constrain(logoZ+inchToPix(.02f), .01, inchToPix(4f)); //leave min and max alone! 

  //left middle, move left
  text("left", inchToPix(.7f), height/2);
  if (mousePressed && dist(0, height/2, mouseX, mouseY)<inchToPix(.8f))
    logoX-=inchToPix(.02f);

  text("right", width-inchToPix(.4f), height/2);
  if (mousePressed && dist(width, height/2, mouseX, mouseY)<inchToPix(.8f))
    logoX+=inchToPix(.02f);

  text("up", width/2, inchToPix(.4f));
  if (mousePressed && dist(width/2, 0, mouseX, mouseY)<inchToPix(.8f))
    logoY-=inchToPix(.02f);

  text("down", width/2, height-inchToPix(.4f));
  if (mousePressed && dist(width/2, height, mouseX, mouseY)<inchToPix(.8f))
    logoY+=inchToPix(.02f);
}


boolean clickInsideSquare() // checks if a user clicks inside the square
{
  float translatedMouseX = mouseX - logoX;
  float translatedMouseY = mouseY - logoY;
  
  float angle = radians(-logoRotation);
  
  float unrotatedMouseX = translatedMouseX * cos(angle) - translatedMouseY * sin(angle);
  float unrotatedMouseY = translatedMouseX * sin(angle) + translatedMouseY * cos(angle);
  
  float halfSize = logoZ / 2;
  boolean result =  unrotatedMouseX >= -halfSize && unrotatedMouseX <= halfSize &&
         unrotatedMouseY >= -halfSize && unrotatedMouseY <= halfSize; 
  return result;
}

void mousePressed()
{
  if (gameStarted == false && startTime == 0) //start time on the instant of the first user click
  {
    startTime = millis();
    println("time started!");
    gameStarted = true;
  }
}

void mouseReleased()
{
    // submit button dimensions
    int buttonCenterX = (int)logoX; // calculate where it should be based on logo
    int buttonCenterY = (int)(logoY - logoZ / 2 - buttonHeight / 2 - 30); // given size defined in setup, size, height = 800
    // --- CHECKS IF USER CLICKS SUBMIT: can only click submit if squareWithCursor is false ---
    // Calculate button boundaries
    int leftBound = buttonCenterX - buttonWidth / 2;
    int rightBound = buttonCenterX + buttonWidth / 2;
    int topBound = buttonCenterY - buttonHeight / 2;
    int bottomBound = buttonCenterY + buttonHeight / 2;
    if (squareWithCursor == false && mouseX >= leftBound && mouseX <= rightBound && mouseY >= topBound && mouseY <= bottomBound)
    {
      if (userDone==false && !checkForSuccess())
        errorCount++;
  
      trialIndex++; //and move on to next trial
  
      if (trialIndex==trialCount && userDone==false)
      {
        userDone = true;
        finishTime = millis();
      }
    }
    // --- ENDS CHECK ---
    else if (squareWithCursor == true && clickInsideSquare()) {
      squareWithCursor = false;
    }
    else if (squareWithCursor == false && clickInsideSquare()) {
      squareWithCursor = true;
    }
}

//probably shouldn't modify this, but email me if you want to for some good reason.
public boolean checkForSuccess()
{
  Destination d = destinations.get(trialIndex);  
  boolean closeDist = dist(d.x, d.y, logoX, logoY)<inchToPix(.05f); //has to be within +-0.05"
  boolean closeRotation = calculateDifferenceBetweenAngles(d.rotation, logoRotation)<=5;
  boolean closeZ = abs(d.z - logoZ)<inchToPix(.1f); //has to be within +-0.1"  

  println("Close Enough Distance: " + closeDist + " (logo X/Y = " + d.x + "/" + d.y + ", destination X/Y = " + logoX + "/" + logoY +")");
  println("Close Enough Rotation: " + closeRotation + " (rot dist="+calculateDifferenceBetweenAngles(d.rotation, logoRotation)+")");
  println("Close Enough Z: " +  closeZ + " (logo Z = " + d.z + ", destination Z = " + logoZ +")");
  println("Close enough all: " + (closeDist && closeRotation && closeZ));

  return closeDist && closeRotation && closeZ;
}

//utility function I include to calc diference between two angles
double calculateDifferenceBetweenAngles(float a1, float a2)
{
  double diff=abs(a1-a2);
  diff%=90;
  if (diff>45)
    return 90-diff;
  else
    return diff;
}

//utility function to convert inches into pixels based on screen PPI
float inchToPix(float inch)
{
  return inch*screenPPI;
}
