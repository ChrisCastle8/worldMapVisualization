//battle related data from: https://data.worldbank.org/indicator/VC.BTL.DETH?end=2017&start=2017&view=map&year=1989
//world map from: http://www.amcharts.com/svg-maps/
//reference code by Bárbara Almeida, Prof. Eric W Cooper(Endangered Languages- got my inspiration from here) and SVCNT(probably != author's real name-https://www.openprocessing.org/sketch/377267); 
//the deathtrolls data includes deaths due to terrorists attacks and civils wars

PShape shapeWorld;  //PShape with the world map
PShape[] shapeCountry;  //Array of PShapes with each country
PGraphics[][] pgYear;  //Array of PGraphics for each year

float[][] listDeaths;  //list of Deaths for country for year
int[] listYear;  //list of years
String[][] listCountry;  //list of countries 

float minDeaths = 0;  //minimum Deaths shown
float maxDeaths =  80000;  //maximum Deaths shown
int thisYear;  //number of the year on the listYear array 

Timeline tl;  //object for the timeline
Button btm;  //object for the pause, play and stop buttons 
Eye ey;  //object for the eye to see only countries with death trolls in a given year


//color pallete with 3 colors of red to pick from
int[] colorPallete = {#990606, #992806, #994306};
color[] clr;  //Array of colors
color mapColor;  //color used on the map 
color dark = color(0);
color lightGray = color(200);

void setup()
{
  size(1600, 700);


  loadData(); 

  //create screen ellements
  tl = new Timeline( width/2, height - 30);
  btm = new Button(width/2, height - 65);
  ey = new Eye(50, height/1.6);

  thisYear = listYear.length - 1;  //set current year to the last year of the list
  chooseColor();  //choose the color used on the map
  loadPG();  //prepare the PGraphics for each year
}

void draw()
{ 

  tl.rollover(mouseX, mouseY);
  btm.rollover(mouseX, mouseY);
  ey.rollover(mouseX, mouseY);

  btm.applyButton();  
  image(pgYear[thisYear][ey.seeCountries()], 0, 0); 

  displayTitle();

  tl.display(thisYear); 
  btm.display(); 
  ey.display();
  detailCountry();
}

void mousePressed()
{
  btm.press(mouseX, mouseY);
  tl.press(mouseX, mouseY);
}

void mouseReleased()
{
  tl.noPress();
  btm.noPress();
}

class Button
{
  boolean pause, play, stop;
  PVector[] pos;
  int diam;
  boolean[] pressed;
  boolean[] roll;
  int counter;  //counter to allow the play button to work

  Button(float x, float y)
  {    
    diam = 20;
    pos= new PVector[3];
    pos[0] = new PVector(x - 1.5*diam, y);
    pos[1] = new PVector(x, y);
    pos[2] = new PVector(x + 1.5*diam, y);

    pressed = new boolean[3];
    for (int i = 0; i < pressed.length; i++)    pressed[i] = false;

    roll = new boolean[3];
    for (int i = 0; i < roll.length; i++)    roll[i] = false;

    counter = 0;
  }

  void applyButton()
  {
    if (pressed[0]) pgPause(); 
    if (pressed[1]) pgPlay();
    if (pressed[2]) pgStop();

    if (play)
    {    
      thisYear = int(counter/80.) % listYear.length; // you can divide counter by a number less than 80 to make the animation faster of a number greater than 50 to make it slower
      counter++;
    } else  counter = thisYear*80;
  }


  void pgPause() {  
    play= false;
  }  
  void pgPlay() {  
    play = true;
  }  
  void pgStop() {  
    play = false;  
    thisYear = listYear.length - 1;
  }

  void press(float mx, float my)  //verify if any Button is pressed and make pressed true (use with mousePressed and mouse coordinates)
  {
    for (int i = 0; i < pos.length; i++)
    {
      if (dist(mx, my, pos[i].x, pos[i].y) < diam/2)
        pressed[i] = true;
    }
  }

  void noPress()  //make pressed false for each Button (use with mouseReleased)
  {
    for (int i = 0; i < pos.length; i++)
      pressed[i] = false;
  }


  void rollover(float mx, float my)  //verify if the mouse is over any Button and make roll true or false (use with mouse coordinates)
  {
    for (int i = 0; i < pos.length; i++)
    {
      if (dist(mx, my, pos[i].x, pos[i].y) < diam/2)
        roll[i] = true;
      else
        roll[i] = false;
    }
  }


  void display()
  {
    noStroke();

    //draw the circles according with their status
    for (int i = 0; i < pos.length; i++)
    {
      if (pressed[i])  fill(mapColor);
      else if (roll[i]) fill(lightGray);
      else             fill(dark);
      ellipse(pos[i].x, pos[i].y, diam, diam);
    }

    //draw the icons on white   
    fill(255);
    displayPause(pos[0].x, pos[0].y);
    displayPlay(pos[1].x, pos[1].y);
    displayStop(pos[2].x, pos[2].y);
  }

  //icons:
  void displayPause(float x, float y)  //two vertical lines for the pause Button
  {
    rectMode(CENTER);
    rect(x-3, y, 4, 9);
    rect(x+3, y, 4, 9);
  }

  void displayPlay(float x, float y)  //a triangle for the play Button
  {   
    triangle(x-3, y-5, x-3, y+5, x+5, y);
  }

  void displayStop(float x, float y)  //a square for the stop Button
  {
    rectMode(CENTER);
    rect(x, y, 9, 9);
  }
}

class Eye
{
  PVector position;  
  PShape[] shapeEye;  //Array with the PShapes of the eyes
  boolean eye;  //boolean to define if all the contries are shown


  Eye(float x, float y)
  {    
    position = new PVector(x, y);

    //load svg files with the eyes
    shapeEye = new PShape[2];
    shapeEye[0] = loadShape("openeye.svg");
    shapeEye[1] = loadShape("closedeye.svg");

    for (int i = 0; i < shapeEye.length; i++)  shapeEye[i].disableStyle();  //disable style  of the eyes

    eye = false;
  }

  void rollover(float mX, float mY)  //verify if the mouse is over the eye and make eye true or false (use with mouse coordinates)
  {
    if (dist(position.x, position.y, mX, mY) < 75)  eye = true;
    else  eye = false;
  }

  void display()
  {
    shapeMode(CENTER);
    fill(dark);

    if (eye)
    {
      shape(shapeEye[1], position.x, position.y, 80, 50);
    } else
    {
      shape(shapeEye[0], position.x, position.y, 80, 50);

      textAlign(CENTER, BOTTOM);
      textSize(16);
      text("See deaths", position.x, position.y - 40);
      text("only", position.x, position.y-20);
    }
  }

  int seeCountries()  //used to define each PGraphics will be shown
  {
    int i = 0;
    if (eye) i = 1;    
    return i;
  }
}

class Timeline
{
  PVector p0;  //center of the timeline
  PVector[] pos;  //array with the position of each circle

  int n;  //number of years
  int mid;  //middle year
  int r;  //radius of the circles
  int d;  //distance between circles

  Boolean[] rolling;
  Boolean[] pressed; 

  Timeline( int x, int y)
  {
    n = listYear.length;
    mid = n/2;
    r = 6;
    d = 2*r + 20;

    p0 = new PVector(x, y);
    pos = setPosition();

    rolling = new Boolean[n];    
    for (int i = 0; i < n; i++) rolling[i] = false;    
    pressed = new Boolean[n];    
    for (int i = 0; i < n; i++) pressed[i] = false;
  }

  PVector[] setPosition()  //set the position of each circle
  {
    PVector[] p = new PVector[n];

    for (int i = mid; i >= 0; i--)  p[i] = new PVector(p0.x - (mid - i)*d, p0.y);    
    for (int i = mid + 1; i < n; i++)  p[i] = new PVector(p0.x + (i - mid)*d, p0.y);

    return p;
  }


  void rollover(float mx, float my)  //verify if the mouse is over any Button and make roll true or false (use with mouse coordinates)
  {
    for (int i = 0; i < n; i++)
    {
      if (dist(mx, my, pos[i].x, pos[i].y) < r)  rolling[i] = true;
      else  rolling[i] = false;
    }
  }


  void press(float mx, float my)  //verify if any Button is pressed and make pressed true (use with mousePressed and mouse coordinates)
  {
    for (int i = 0; i < n; i++)
      if (dist(mx, my, pos[i].x, pos[i].y) < r)
      {
        pressed[i] = true;
        thisYear = i;
      }
  }


  void noPress()  //make pressed false for each Button (use with mouseReleased)
  {
    for (int i = 0; i < n; i++)  pressed[i] = false;
  }

  void display(int tyear)
  {        
    //line
    strokeWeight(2);
    stroke(dark);
    line(pos[0].x, pos[0].y, pos[n-1].x, pos[n-1].y); 

    //circles
    strokeWeight(4);
    for (int i = 0; i < n; i++)
    {
      if (pressed[i]) {   
        stroke(mapColor);    
        fill(mapColor);
      } else if (tyear == i) {   
        stroke(dark);    
        fill(mapColor);
      } else if (rolling[i]) {   
        stroke(mapColor);    
        fill(255);
      } else {   
        stroke(dark);    
        fill(255);
      }
      ellipse(pos[i].x, pos[i].y, 2*r, 2*r);
    } 

    //text
    textAlign(CENTER);
    textSize(14);
    fill(mapColor);
    for (int i = 0; i < n; i++)    
      if (rolling[i])  text(listYear[i], pos[i].x, pos[i].y - 2*r);  

    fill(dark);
    text(listYear[0], pos[0].x, pos[0].y + 3*r); 
    text(listYear[mid], pos[mid].x, pos[mid].y + 3*r);  
    text(listYear[n -1], pos[n -1].x, pos[n -1].y + 3*r);
  }
}

void loadData()
{
  shapeWorld = loadShape("world.svg");  //load svg file with the world map

  String[] s_Deaths = loadStrings("deaths.txt");  //load list of Deaths for country for year as an array of Strings 
  //make sure all the deaths.txt character values are off the same length
  // the original csv had no values for countries where there were no deaths required i had to replace them with zerosand made sure all values were to the length if the highest value recorded
  String[] s_year = loadStrings("year.txt");  //load list of years as an array of Strings 
  // be careful to make sure there is no spaces between the year inputs
  String[] s_country = loadStrings("country.txt");  //load list of iso codes and their respective countries as an array of Strings
  //println(s_year.length);

  listDeaths = new float[s_country.length][s_year.length];  //prepare 2d array for the list of Deaths for country for year
  listYear = new int[s_year.length];  //prepare array for the list of years
  listCountry = new String[s_country.length][2];  //prepare array for the list of countries


  //fill the listDeaths array
  for (int i = 0; i < s_country.length; i++)  
  {
    for (int j = 0; j < s_year.length; j ++)
    {
      listDeaths[i][j] = float(s_Deaths[i].substring(6*j, 6*j+5));
    }
  }
  //println(listDeaths[1]); check if it does match with the death.txt file values


  //fill the listYear array
  for (int i = 0; i < s_year.length; i++)  
  { 
    listYear[i] = int(s_year[i]);
  }

  //println(listYear[2]);

  //fill the listCountry array
  for (int i = 0; i < s_country.length; i++)
  {
    listCountry[i][0] = s_country[i].substring(0, 2);  //ISO2 code of the country the original csv file had codes written to 3; i had to check with the resulting codes after the substring n reduced some of the codes to a length of 2 to eliminate those that were the same
    listCountry[i][1] = s_country[i].substring(3);  //name of the country
  }


  //create an array of PShapes with the number of countrys on the data 
  shapeCountry = new PShape[listCountry.length];  
  for (int j = 0; j < listCountry.length; j++)
  {
    shapeCountry[j] = shapeWorld.getChild(listCountry[j][0]);  //use the iso2 code to find the country on the svg file
    if (shapeCountry[j] != null  )  //verify if the country exists on the PShape array

      shapeCountry[j].disableStyle();  //disable style to be able to change color later
  }


  //create one PGraphics for each year
  pgYear = new PGraphics[listYear.length][2];  
  for (int i = 0; i < pgYear.length; i++)
  {
    pgYear[i][0] = createGraphics(width, height);  //PGraphics that will show only the countries with death trolls 
    pgYear[i][1] = createGraphics(width, height);  //PGraphics that will show every country
  }
}


void chooseColor()  //choose the color used on the map
{  
  float m = (minDeaths + maxDeaths)/maxDeaths;  //i wanted to show all the deaths but u could change the minDeath amd maxdeaths values to see a few of the countries with deaths in that range
  m *=0;  //map mean Deaths to an interval between 0 and 2 to find the position on the color pallete
  mapColor = colorPallete[int(m)];  //choose the color on the pallete



  //find the red, green and blue components of the mapColor chose
  int rmin = mapColor >> 16 & 0xFF;
  int gmin = mapColor >> 8  & 0xFF;
  int bmin = mapColor       & 0xFF;


  //create an array of 3000 colors slightly modifing the input color i had to try out various values for the total colors in order to find out a minimum that would show all the countries in daeths in a given year
  clr = new color[3000];  // try the values greater than 265 -- the total number of countries from the csv file

  int i = 0;
  for (int r = rmin; r < rmin + 12; r++) 
    for (int g = gmin; g < gmin + 12; g++)    
      for (int b = bmin; b < bmin + 12; b++)
      {
        clr[i] = color(r, g, b);
        i++;
      }
}


void loadPG()  //prepare the PGraphics for each year  
{  
  for (int k = 0; k < 2; k++)
  {
    for (int y = 0; y < pgYear.length; y++)  //for each year:
    {      
      pgYear[y][k].beginDraw();    
      pgYear[y][k].background(255);    
      pgYear[y][k].strokeWeight(1);
      pgYear[y][k].stroke(255); 

      for (int i = 0; i < shapeCountry.length; i++)
      {
        if (shapeCountry[i] != null)  //verify if the country exists on the svg file
        {
          if (listDeaths[i][y]> minDeaths  && listDeaths[i][y] < maxDeaths)  //if the country Deaths is between the interval
            pgYear[y][k].fill(clr[i+1]);   //fill with the equivalent color on the array (use i+1 to reserve the first color)
          else
          {
            pgYear[y][0].fill(lightGray);  
            pgYear[y][1].fill(0, 0);
          }

          pgYear[y][k].shape(shapeCountry[i], -100, 0, width, height);  //draw the country
        }
      }

      pgYear[y][k].endDraw();
    }
  }
}

void detailCountry()
{ 
  int mouseCountry;  
  color test = pgYear[thisYear][0].get(mouseX, mouseY);

  for (int i = 0; i < shapeCountry.length; i++)
  {
    if (test == clr[i+1]) mouseCountry = i;
    else mouseCountry = -1;

    if (mouseCountry == i)
    {  
      noStroke();
      fill(255, 100);
      shapeMode(CENTER);      
      shape(shapeCountry[i], -100, 0, width, height);// had to start at -100 since at 0 there we some  parts of Australia that were not covered

      stroke(2);
      noFill();
      fill(dark);
      textSize(18);
      textAlign(CENTER);
      String txt = listCountry[i][1] + " - Deathtroll " + listYear[thisYear] +  " = " + nf(listDeaths[i][thisYear], 1, 0);
      text(txt, width/2, height - 100);
    }
  }
}

void displayTitle()
{
  fill(dark);
  textSize(20);
  textAlign(CENTER);
  text("Countries with Battle Related Deaths between " + nf(minDeaths, 1, 0) + " and " + nf(maxDeaths, 1, 0), width/2, 25);
  textSize(25);
  text(listYear[thisYear], width/2, 55);
}
