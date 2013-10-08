class YellowTail{

    boolean theTrigger = false;

    Gesture gestureArray[];
    final int nGestures = 36;  // Number of gestures
    final int minMove = 3;     // Minimum travel for a new point
    int currentGestureID;

    Polygon tempP;
    int tmpXp[];
    int tmpYp[];

    color c = color(255,255,245,50);

    YellowTail(color _c){
      c = _c;
      currentGestureID = -1;
      gestureArray = new Gesture[nGestures];
      for (int i=0; i<nGestures; i++){
        gestureArray[i] = new Gesture(sW, sH);
      }
      clearGestures();
    }

    void update(){
      updateGeometry();
    }

    void draw(){
      noStroke();
      fill(c);
      for (int G=0; G<nGestures; G++){
        renderGesture(gestureArray[G],sW,sH);
      }
    }

    void run(){
        update();
        draw();
    }

    void triggerStart(float x, float y){
      theTrigger = true;
      currentGestureID = (currentGestureID+1)%nGestures;
      Gesture G = gestureArray[currentGestureID];
      G.clear();
      G.clearPolys();
      G.addPoint(x,y);
    }

    void triggerDrag(float x, float y){
      theTrigger = true;
      if (currentGestureID >= 0){
        Gesture G = gestureArray[currentGestureID];
        if (G.distToLast(x, y) > minMove) {
          G.addPoint(x, y);
          G.smooth();
          G.compile();
        }
      }
    }

    void triggerMove (Event evt, float x, float y){
      theTrigger = false;
    }

    void triggerMove (float x, float y){
      theTrigger = false;
    }


    void triggerEnd(){
      theTrigger = false;
    }

//RENDERING
void renderGesture (Gesture gesture, int w, int h){
  if (gesture.exists){
    if (gesture.nPolys > 0){
      Polygon polygons[] = gesture.polygons;
      int crosses[] = gesture.crosses;

      int xpts[];
      int ypts[];
      Polygon p;
      int cr;

      beginShape(QUADS);
      int gnp = gesture.nPolys;
      for (int i=0; i<gnp; i++){

        p = polygons[i];
        xpts = p.xpoints;
        ypts = p.ypoints;

        vertex(xpts[0], ypts[0]);
        vertex(xpts[1], ypts[1]);
        vertex(xpts[2], ypts[2]);
        vertex(xpts[3], ypts[3]);

        if ((cr = crosses[i]) > 0){
          if ((cr & 3)>0){
            vertex(xpts[0]+w, ypts[0]);
            vertex(xpts[1]+w, ypts[1]);
            vertex(xpts[2]+w, ypts[2]);
            vertex(xpts[3]+w, ypts[3]);

            vertex(xpts[0]-w, ypts[0]);
            vertex(xpts[1]-w, ypts[1]);
            vertex(xpts[2]-w, ypts[2]);
            vertex(xpts[3]-w, ypts[3]);
          }
          if ((cr & 12)>0){
            vertex(xpts[0], ypts[0]+h);
            vertex(xpts[1], ypts[1]+h);
            vertex(xpts[2], ypts[2]+h);
            vertex(xpts[3], ypts[3]+h);

            vertex(xpts[0], ypts[0]-h);
            vertex(xpts[1], ypts[1]-h);
            vertex(xpts[2], ypts[2]-h);
            vertex(xpts[3], ypts[3]-h);
          }

          // I have knowingly retained the small flaw of not
          // completely dealing with the corner conditions
          // (the case in which both of the above are true).
        }
      }
      endShape();
    }
  }
}

private void updateGeometry(){
  Gesture J;
  for (int g=0; g<nGestures; g++){
    if ((J=gestureArray[g]).exists){
      if (g!=currentGestureID){
        advanceGesture(J);
      } else if (!theTrigger){
        advanceGesture(J);
      }
    }
  }
}

void advanceGesture(Gesture gesture){
  // move a Gesture one step
  if (gesture.exists){ // check
    int nPts = gesture.nPoints;
    int nPts1 = nPts-1;
    Vec3f path[];
    float jx = gesture.jumpDx;
    float jy = gesture.jumpDy;

    if (nPts > 0){
      path = gesture.path;
      for (int i=nPts1; i>0; i--){
        path[i].x = path[i-1].x;
        path[i].y = path[i-1].y;
      }
      path[0].x = path[nPts1].x - jx;
      path[0].y = path[nPts1].y - jy;
      gesture.compile();
    }
  }
}

void clearGestures(){
  for (int i=0; i<nGestures; i++){
    gestureArray[i].clear();
  }
}



}