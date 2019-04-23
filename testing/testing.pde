
// import the TUIO library
import TUIO.*;
// declare a TuioProcessing client
TuioProcessing tuioClient;

int removeTrig = 0;
int placeTrig = 0;
int objectID = 0;

int blueCount = 0; 
int redCount = 0;
int rows = 8 ;
int cols = 3;
int boardArray[][] = new int[cols][rows];
int boardXPos = 0;
int boardPos[] =  {0, 0, 0};
int ID_1 = 5;
int ID_2 = 2;
int current = 0;
int previous = 0;
int start = 0;
float currentXPosition = 0;

float cursor_size = 15;
float object_size = 60;
float table_size = 760;
float scale_factor = 1;

PFont font;


boolean verbose = false; // print console debug messages
boolean callback = true; // updates only after callbacks
boolean turn = true; 


//comment 
void setup() {
  size(1200, 800);
  // periodic updates
  if (!callback) {
    frameRate(60);
    loop();
  } else noLoop(); // or callback updates 

  font = createFont("Arial", 18);
  scale_factor = height/table_size;
  tuioClient  = new TuioProcessing(this);
}

void draw()
{

  background(255);
  textFont(font, 18*scale_factor);
  float obj_size = object_size*scale_factor*.0001; 



  //creates a list of all the tuio objects in view
  ArrayList<TuioObject> tuioObjectList = tuioClient.getTuioObjectList();
  for (int i=0; i<tuioObjectList.size(); i++) {
    TuioObject tobj = tuioObjectList.get(i);
    stroke(0);
    fill(0, 0, 0);
    pushMatrix();
    translate(tobj.getScreenX(width), tobj.getScreenY(height));
    rotate(tobj.getAngle());
    rect(-obj_size/2, -obj_size/2, obj_size, obj_size);
    popMatrix();
    fill(255);
    text(""+tobj.getSymbolID(), tobj.getScreenX(width), tobj.getScreenY(height));

    //gets current x possition of each object 
    currentXPosition = (tobj.getScreenX(width));
    objectID = tobj.getSymbolID();
  }

  //if an object is placed on the board a red or blue ball is drawn based on its last X location and its ID
  if (placeTrig == 1) {
    placeObject();
  }


  //this continuously draws the state of the board based on the values in the 2D game array 
  drawAll();

  //if all three columns are full this resets the game arry and the board is redrawn 
  if (((boardArray[0][7]!=0)&&(boardArray[1][7]!=0)&&(boardArray[2][7]!=0))) {

    //delays for a second so players can see the board 
    delay(1000);

    //fills the game array with zeros 
    for (int i = 0; i < cols; i++) {
      for (int j=0; j<rows; j++) {
        boardArray[i][j] = 0;
      }
    }
  }
}
int size = 40;








// --------------------------------------------------------------
// these callback methods are called whenever a TUIO event occurs
// there are three callbacks for add/set/del events for each object/cursor/blob type
// the final refresh callback marks the end of each TUIO frame

// called when an object is added to the scene
void addTuioObject(TuioObject tobj) {
  placeTrig = 1;
  removeTrig =0;
  if (verbose) println("add obj "+tobj.getSymbolID()+" ("+tobj.getSessionID()+") "+tobj.getX()+" "+tobj.getY()+" "+tobj.getAngle()+ placeTrig);
  println("object placed");
}

// called when an object is moved
void updateTuioObject (TuioObject tobj) {
  if (verbose) println("set obj "+tobj.getSymbolID()+" ("+tobj.getSessionID()+") "+tobj.getX()+" "+tobj.getY()+" "+tobj.getAngle()
    +" "+tobj.getMotionSpeed()+" "+tobj.getRotationSpeed()+" "+tobj.getMotionAccel()+" "+tobj.getRotationAccel());
}

// called when an object is removed from the scene
void removeTuioObject(TuioObject tobj) {
  if (verbose) println("del obj "+tobj.getSymbolID()+" ("+tobj.getSessionID()+")");
  removeTrig = 1;
  placeTrig = 0;

  println("object removed");
  checkTurn();
  updateBoard();
  start = 1 ;
}



// --------------------------------------------------------------
// called at the end of each TUIO frame
void refresh(TuioTime frameTime) {
  if (verbose) println("frame #"+frameTime.getFrameID()+" ("+frameTime.getTotalMilliseconds()+")");
  if (callback) redraw();
}

//draw ball function 
//use of this function means that x and y and colours can be changed and set easily without having to call 'fill' everytime an elipse is drawn 
void drawBall(float currentXPosition, int y, int r, int g, int b) {
  fill(r, g, b);
  ellipse(currentXPosition, y, size, size);
}

//checks whoes turn it is, if its the first turn of the game start is set to true so the first move can take place
//for any other turn it compares the current ID and the previous ID and if they are the same turn is set to false and the turn witll not be taken 
void checkTurn() {

  if (start == 0) { 
    turn = true;
    previous = objectID;
  } else {
    current = objectID;

    if (current == previous) {
      turn = false;
    } else {
      turn = true;
    }
  }
  println("turn: ", turn);
  println("previous: ", previous);
  println("current: ", current);
}

//if an object is placed and its the players turn this function places a ball in the relevent place 
//checks for ID first then where the ball is placed, a 1 or 2 is placed in the relevent place in the 2D array 
void updateBoard() {

  if (objectID == ID_1 && turn) {
    for (int i = 0; i < cols; i++) {
      if (boardXPos == i && (boardArray[i][7] == 0)) {
        boardPos[i]++;
        boardArray[i][boardPos[i]] = 1;
      }
    }
  } else if (objectID == ID_2 && turn) {
    for (int i = 0; i < cols; i++) {
      if (boardXPos == i && (boardArray[i][7] == 0)) {
        boardPos[i]++;
        boardArray[i][boardPos[i]] = 2;
      }
    }
  }
}


//using the values in the boardArray this function contiously draws the board 
//the numbers in here are hardcoded based on the current board in use but will need to be updated and refined for the full board 
void drawAll() {
  for (int i = 0; i < cols; i++) {
    for (int j=0; j<rows; j++) {
      if (boardArray[i][j] == 1) {
        drawBall(200+i*200, (600-j*50), 100, 0, 0);
      } else if (boardArray[i][j] == 2) {
        drawBall(200+i*200, (600-j*50), 0, 0, 100);
      }
    }
  }
}

//function to draw inital placement of an object/ball on screen 
//x values are relevent to the current board but the threshold can also be drastically reduced 
void placeObject() {
  //y position is set as a constant for all placements 
  int yPos = 200;

  if (objectID == ID_1) {
    if ((currentXPosition>200)&&(currentXPosition<400)) {
      drawBall(600, yPos, 100, 0, 0);
      boardXPos = 2;
    } else if ((currentXPosition>400)&&(currentXPosition<700)) {
      drawBall(400, yPos, 100, 0, 0);
      boardXPos = 1;
    } else if ((currentXPosition>720)) {
      drawBall(200, yPos, 100, 0, 0);
      boardXPos = 0;
    }
  }

  if (objectID ==ID_2) {
    if ((currentXPosition>200)&&(currentXPosition<400)) {
      drawBall(600, yPos, 0, 0, 100);
      boardXPos = 2;
    } else if ((currentXPosition>400)&&(currentXPosition<700)) {
      drawBall(400, yPos, 0, 0, 100);
      boardXPos = 1;
    } else if ((currentXPosition>720)) {
      drawBall(200, yPos, 00, 0, 100);
      boardXPos = 0;
    }
  }
}



// --------------------------------------------------------------
// called when a cursor is added to the scene
void addTuioCursor(TuioCursor tcur) {
  if (verbose) println("add cur "+tcur.getCursorID()+" ("+tcur.getSessionID()+ ") " +tcur.getX()+" "+tcur.getY());
  //redraw();
}

// called when a cursor is moved
void updateTuioCursor (TuioCursor tcur) {
  if (verbose) println("set cur "+tcur.getCursorID()+" ("+tcur.getSessionID()+ ") " +tcur.getX()+" "+tcur.getY()
    +" "+tcur.getMotionSpeed()+" "+tcur.getMotionAccel());
  //redraw();
}

// called when a cursor is removed from the scene
void removeTuioCursor(TuioCursor tcur) {
  if (verbose) println("del cur "+tcur.getCursorID()+" ("+tcur.getSessionID()+")");
  //redraw()
}

// --------------------------------------------------------------
// called when a blob is added to the scene
void addTuioBlob(TuioBlob tblb) {
  if (verbose) println("add blb "+tblb.getBlobID()+" ("+tblb.getSessionID()+") "+tblb.getX()+" "+tblb.getY()+" "+tblb.getAngle()+" "+tblb.getWidth()+" "+tblb.getHeight()+" "+tblb.getArea());
  //redraw();
}

// called when a blob is moved
void updateTuioBlob (TuioBlob tblb) {
  if (verbose) println("set blb "+tblb.getBlobID()+" ("+tblb.getSessionID()+") "+tblb.getX()+" "+tblb.getY()+" "+tblb.getAngle()+" "+tblb.getWidth()+" "+tblb.getHeight()+" "+tblb.getArea()
    +" "+tblb.getMotionSpeed()+" "+tblb.getRotationSpeed()+" "+tblb.getMotionAccel()+" "+tblb.getRotationAccel());
  //redraw()
}

// called when a blob is removed from the scene
void removeTuioBlob(TuioBlob tblb) {
  if (verbose) println("del blb "+tblb.getBlobID()+" ("+tblb.getSessionID()+")");
  //redraw()
}
