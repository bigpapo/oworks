int trig;
int turn;
int changeover;
int[] currentState = new int[8];
int[][] board = new int[9][8];

//comment 
void setup(){
    size(680, 480);
    for(int i = 0; i < 7; i++){
     currentState[i] = 0; 
    }
    turn = 1;
}

void draw(){
  background(255);
  if (keyPressed){
    if (key == 'a'){
      trig = 1;
      currentState[1] += 1;
      board[1][currentState[1]] = turn;
      changeover = 1;
      key = 'x';
    }
    else if (key == 's'){
      trig = 1;
      currentState[2] += 1;
      board[2][currentState[2]] = turn;
      changeover = 1;
      key = 'x';
    }
    else if (key == 'd'){
      trig = 1;
      currentState[3] += 1;
      board[3][currentState[3]] = turn;
      changeover = 1;
      key = 'x';
    }
    }
    else{
      trig = 0;
        if (changeover ==1) {
          turn *= -1;
          changeover =0;
      }
    }
  
  
drawAll();
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
