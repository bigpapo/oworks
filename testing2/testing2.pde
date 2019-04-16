
// import the TUIO library
import TUIO.*;
// declare a TuioProcessing client
TuioProcessing tuioClient;

int trig;
int turn;
int changeover;
int[] currentState = new int[8];
int[][] board = new int[9][8];
float currentXPosition = 0;
int removeTrig = 0;
int placeTrig = 0;
int objectID = 5;


float cursor_size = 15;
float object_size = 60;
float table_size = 760;
float scale_factor = 1;
PFont font;
int count = 0;

boolean verbose = false; // print console debug messages
boolean callback = true; // updates only after callbacks


//comment 
void setup(){
    size(1200, 800);
    for(int i = 0; i < 7; i++){
     currentState[i] = 0; 
    }
    turn = 1;
    
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
  textFont(font,18*scale_factor);
  float obj_size = object_size*scale_factor*.0001; 
  float cur_size = cursor_size*scale_factor; 
  
  
  /*
  if(placeTrig == 1){
    if (currentXPosition<400){
      if(objectID ==0){
        fill(200,0,0);
        ellipse(1*50,1*50 , size, size);
         }
        else if (objectID ==2){
          fill(0,0,200);
          ellipse(1*50,1*50 , size, size);
        }
    }
     else if ((currentXPosition>400)&&(currentXPosition<800)){
       if(objectID ==0){
        fill(200,0,0);
        ellipse(2*50,1*50 , size, size);
       }
        else if (objectID ==2){
          fill(0,0,200);
          ellipse(2*50,1*50 , size, size);
        }
    }
    else if ((currentXPosition>800)&&(currentXPosition<1200)){
        if(objectID ==0){
            fill(200,0,0);
            ellipse(3*50,1*50 , size, size);
           }
            else if (objectID ==2){
              fill(0,0,200);
              ellipse(3*50,1*50 , size, size);
            }
    }
    }
  */

 
  if (placeTrig == 1 ){
    placeTrig =0;
    if (currentXPosition<400){
          trig = 1;
          currentState[1] += 1;
          board[1][currentState[1]] = turn;
          changeover = 1;
          key = 'x';
    }
     else if ((currentXPosition>400)&&(currentXPosition<700)){
          trig = 1;
          currentState[2] += 1;
          board[2][currentState[2]] = turn;
          changeover = 1;
          key = 'x';
    }
    else if ((currentXPosition>700)&&(currentXPosition<1200)){
      trig = 1;
      currentState[3] += 1;
      board[3][currentState[3]] = turn;
      changeover = 1;
      key = 'x';
    }
  
  } else{
      trig = 0;
        if (changeover ==1) {
          turn *= -1;
          changeover =0;
      }
    }
  
  
  ArrayList<TuioObject> tuioObjectList = tuioClient.getTuioObjectList();
  for (int i=0;i<tuioObjectList.size();i++) {
     TuioObject tobj = tuioObjectList.get(i);
     stroke(0);
     fill(0,0,0);
     pushMatrix();
     translate(tobj.getScreenX(width),tobj.getScreenY(height));
     rotate(tobj.getAngle());
     rect(-obj_size/2,-obj_size/2,obj_size,obj_size);
     popMatrix();
     fill(255);
     text(""+tobj.getSymbolID(), tobj.getScreenX(width), tobj.getScreenY(height));
     
     currentXPosition = (tobj.getScreenX(width));
     objectID = tobj.getSymbolID();

   }
   
   ArrayList<TuioCursor> tuioCursorList = tuioClient.getTuioCursorList();
   for (int i=0;i<tuioCursorList.size();i++) {
      TuioCursor tcur = tuioCursorList.get(i);
      ArrayList<TuioPoint> pointList = tcur.getPath();
      
      if (pointList.size()>0) {
        stroke(0,0,255);
        TuioPoint start_point = pointList.get(0);
        for (int j=0;j<pointList.size();j++) {
           TuioPoint end_point = pointList.get(j);
           line(start_point.getScreenX(width),start_point.getScreenY(height),end_point.getScreenX(width),end_point.getScreenY(height));
           start_point = end_point;
        }
        
        stroke(192,192,192);
        fill(192,192,192);
        ellipse( tcur.getScreenX(width), tcur.getScreenY(height),cur_size,cur_size);
        fill(0);
        text(""+ tcur.getCursorID(),  tcur.getScreenX(width)-5,  tcur.getScreenY(height)+5);
      }
   }
   
  ArrayList<TuioBlob> tuioBlobList = tuioClient.getTuioBlobList();
  for (int i=0;i<tuioBlobList.size();i++) {
     TuioBlob tblb = tuioBlobList.get(i);
     stroke(0);
     fill(0);
     pushMatrix();
     translate(tblb.getScreenX(width),tblb.getScreenY(height));
     rotate(tblb.getAngle());
     ellipse(-1*tblb.getScreenWidth(width)/2,-1*tblb.getScreenHeight(height)/2, tblb.getScreenWidth(width), tblb.getScreenWidth(width));
     popMatrix();
     fill(255);
     text(""+tblb.getBlobID(), tblb.getScreenX(width), tblb.getScreenX(width));
   }


drawAll();
println(placeTrig);
println(currentXPosition);
}



int x = 20;
int y = 20;
int size = 40;

  
void drawAll(){
  for(int i = 0; i < 9; i++){
    for(int j=0; j<8; j++){
      if (board[i][j] == 1){
        fill(255,0,0);
        ellipse(i*50,j*50 , size, size);
      }
      else if (board[i][j] == -1){
        fill(0,0,255);
        ellipse(i*50,j*50 , size, size);
      }
    }
  }
}
  
  



// --------------------------------------------------------------
// these callback methods are called whenever a TUIO event occurs
// there are three callbacks for add/set/del events for each object/cursor/blob type
// the final refresh callback marks the end of each TUIO frame

// called when an object is added to the scene
void addTuioObject(TuioObject tobj) {
  placeTrig = 1;
  if (verbose) println("add obj "+tobj.getSymbolID()+" ("+tobj.getSessionID()+") "+tobj.getX()+" "+tobj.getY()+" "+tobj.getAngle()+ placeTrig);
  
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
  removeTrig = 3;
}

// called when a blob is moved
void updateTuioBlob (TuioBlob tblb) {
  if (verbose) println("set blb "+tblb.getBlobID()+" ("+tblb.getSessionID()+") "+tblb.getX()+" "+tblb.getY()+" "+tblb.getAngle()+" "+tblb.getWidth()+" "+tblb.getHeight()+" "+tblb.getArea()
          +" "+tblb.getMotionSpeed()+" "+tblb.getRotationSpeed()+" "+tblb.getMotionAccel()+" "+tblb.getRotationAccel());
  //redraw()
}

// called when a blob is removed from the scene
void removeTuioBlob(TuioBlob tblb) {
  removeTrig = 1;
  if (verbose) println("del blb "+tblb.getBlobID()+" ("+tblb.getSessionID()+")"+removeTrig);
  //redraw()
}

// --------------------------------------------------------------
// called at the end of each TUIO frame
void refresh(TuioTime frameTime) {
  if (verbose) println("frame #"+frameTime.getFrameID()+" ("+frameTime.getTotalMilliseconds()+")");
  if (callback) redraw();
}
