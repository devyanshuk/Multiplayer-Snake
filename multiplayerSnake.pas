program MultiPlayerSnake;

uses crt, sysutils;
//if you want to setup board anywhere on the screen, note this:
//widthStart + width <=110   ; default:91
//heightStart + height <=30 ; default:28 
//(widthStart,Heightstart) is the position of the top left corner of the board
const width  = 90;
      height = 24;
      widthStart = 4; 
      heightStart = 6; 
      
Type
  dir = (up,down,left,right); 
  positionRec = record
                X,Y : byte;
              End;
  snakeRec = record
             direction : dir;
             head : positionRec;
             length : integer;
             tail : array [1..100] of positionRec;
             colour : byte;
             headChar, tailChar : char;
             dead : boolean;
           end;
  foodRec = record
            position : positionRec;
            prevPosition : positionRec;
            exists : Boolean;
         end;
Var
  snake : array [1..2] of snakeRec;
   allDead :byte;
  food : foodRec;
  gameMode:string;
  gameSpeed:integer=70; (*Default speed*)
  player1color:integer=7; (*Default color (WHITE)*)
  player2color:integer=3; (*Default color (SKY BLUE)*)


Function randomPosition : positionRec;
//Returns a new random position on the board
var position : positionRec;
    playerNo : Byte;
    tailNo : Integer;
    validPosition : boolean;
begin
  repeat
    validPosition := true;
    position.X := random(width-3)+2;
    position.Y := random(height-3)+2;
    //Collision with snake/s check
    for playerNo := 1 To 2 Do //Needs to be changed with max no of players
      begin
        if (position.X =snake[playerNo].head.X) and
           (position.Y = snake[playerNo].head.Y)
          then validPosition :=false;
        for tailNo := 1 To snake[playerNo].length Do
          If (position.X = snake[playerNo].tail[tailNo].X) AND
             (position.Y = snake[playerNo].tail[tailNo].Y)
             then validPosition := false;
      end;
   
  until validPosition = true;
  randomPosition := position;
end;

Procedure initSnakes(var numberOfPlayers : byte);
var playerNo : byte;
begin
  snake[1].head.X := (width div 3)*2+2;
  snake[2].head.X := (width div 3);
  for playerNo := 1 To numberOfPlayers Do
    begin
      snake[playerNo].head.Y    := heightStart+1;
      snake[playerNo].direction := down;
      snake[playerNo].length    := 2;
      snake[playerNo].tail[1].X := snake[playerNo].head.X;
      snake[playerNo].tail[1].Y := 5;
     snake[playerNo].dead    := false;
   end;
end;

Procedure drawSnake(playerNo : byte);
var Count : Integer;
begin
cursoroff;
  textcolor(Snake[PlayerNo].Colour);
  gotoXY(widthStart+snake[playerNo].Head.X,heightStart+Snake[playerNo].head.Y);
  write(snake[playerNo].headChar);
  for count := snake[playerNo].length-1 downTo 1 do begin
      gotoXY(widthStart+snake[playerNo].tail[count].X,heightStart+snake[playerNo].tail[count].Y);
      write(snake[playerNo].tailChar);
    end;
{Remove end tail}
  If snake[playerNo].Tail[snake[playerNo].length].X > 0 Then {If tail exists}
  begin  gotoXY(widthStart+snake[playerNo].tail[snake[playerNo].length].X,heightStart+snake[playerNo].Tail[Snake[PlayerNo].Length].Y);
    Write(' ');
  End;
End;

Function snakeCollision(var playerNo : Byte) : boolean;
var 
Count : Integer;
//other:integer;
begin
{self collision}
  for count := snake[playerNo].Length+2 downto 1 do
    If (snake[playerNo].tail[count].X = snake[playerNo].head.X) and
       (snake[playerNo].tail[count].Y = snake[playerNo].head.Y)
    then exit(true);
 {Player 1 collision with player 2}
  If PlayerNo = 1 Then
    Begin
      For Count := Snake[PlayerNo].Length+2 Downto 1 Do
        If (Snake[2].Tail[Count].X = Snake[1].Head.X) AND
           (Snake[2].Tail[Count].Y = Snake[1].Head.Y)
        then exit(true);
    end;
{Player 2 collision with player 1}
  If PlayerNo = 2 Then
    Begin
      For Count := Snake[1].Length+2 Downto 1 Do
        If (Snake[1].Tail[Count].X = Snake[2].Head.X) AND
           (Snake[1].Tail[Count].Y = Snake[2].Head.Y)
        then exit(true);
    end;
exit(false);
  end;

function collision(playerNo : byte) : boolean;
begin
  exit ((snake[playerNo].head.X = width) or
     (snake[playerNo].head.X=0) or
     (snake[playerNo].head.Y=height) or
     (snake[playerNo].head.Y=0)or
     (snakeCollision(playerNo) = true));
end;

Procedure moveSnake(playerNo : byte);
var count : integer;
begin
cursoroff;
  for count := snake[playerNo].length downto 2 do  begin
      snake[playerNo].Tail[count] := snake[playerNo].tail[count-1]
    end; 
  snake[playerNo].Tail[1] := snake[playerNo].head;
  case snake[playerNo].direction of
    right : snake[playerNo].head.X := snake[playerNo].head.X+1;
    left : snake[playerNo].head.X := snake[playerNo].head.X-1;
    up : snake[playerNo].head.Y := snake[playerNo].head.Y-1;
    down : snake[playerNo].head.Y := snake[playerNo].head.Y+1;
  end;
end;

Procedure placefood;
Begin
  textcolor(12);
  If food.exists = True Then
    If (food.position.X > 0) Or (Food.Position.Y > 0) then begin
        goToXY(widthStart+Food.Position.X,heightStart+Food.Position.Y);
        textColor(lightcyan);
        write(Chr(149));
        delay(100); 
        gotoXY(widthStart+Food.Position.X,heightStart+Food.Position.Y);
        write(' ');
    end;
  food.position := RandomPosition;
  gotoXY(widthStart+Food.Position.X,heightStart+Food.Position.Y);
  textColor(lightcyan);
  write(chr(149)); //writes a bigger dot
  food.exists := true;
end;

Procedure doFood(numberOfPlayers : Byte);
var Count : Integer;
begin
  if not food.exists Then placefood;
{Check if food's been eaten}
  for count := 1 To numberOfPlayers do begin
      If (snake[count].head.X = food.position.X) and
         (snake[count].head.Y = food.position.Y) then begin
          food.exists := false;
          snake[count].length := snake[count].length+1;
        end;
   end;
end;

procedure SetUpGame(numberOfPlayers : Byte);
begin
  food.exists := false;
  allDead := 0;
  initSnakes(numberOfPlayers);
end;

Procedure GameOver(numberOfPlayers : byte);
Var PlayerNo : Byte;
Begin
  if snake[1].Length > Snake[2].length Then playerNo := 1;
  if snake[1].Length < Snake[2].length Then playerNo := 2;
  if snake[1].length = Snake[2].length Then playerNo := 3;
  gotoXY(widthStart+4,heightStart+3);
  textColor(12);
  write(' GAME OVER! ');
//Single player score message
  If numberOfPlayers = 1 then   begin
      textColor(Snake[1].Colour);
      write('Score: ',Snake[1].Length-2,' ');
    end;
//Two player score message
  If numberOfPlayers = 2 then begin 
      If playerNo = 3 Then //If it's a draw
        Write('It was a draw! ')
      else begin //If not a draw
          textColor(Snake[PlayerNo].Colour);
          write('Player ',PlayerNo,' ');
          textColor(12);
         write('wins! ');
          goToXY(widthStart+5,heightStart+4);
          textcolor(snake[1].colour);
          writeln('Player 1 Length:',snake[1].length-2);
          goToXY(widthStart+5,heightStart+5);
          textcolor(snake[2].colour);
          writeln('Player 2 Length:', snake[2].length-2);
        end;
    end;
    gotoxy(widthstart,heightstart+height+1);
          halt;
end;

Procedure PlayGame(numberOfPlayers : Byte);
Var 
    playerNo,playerNo2 : Byte;
    k:char; //keypressed
Begin
  repeat
    doFood(numberOfPlayers); 
    delay(gameSpeed);
     If Keypressed then k := readkey;
        Case k of
        //Upper and Lower case WASD
          'w', 'W' : if Snake[2].direction <> down then Snake[2].Direction := up; 
          's', 'S' : if Snake[2].direction <> up then Snake[2].Direction := down; 
          'a', 'A' : if Snake[2].direction <> right then  Snake[2].Direction := left;
          'd', 'D' : if Snake[2].direction <> left then Snake[2].Direction := right; 
        //Arrow keys
          #0  : Begin
                  k := Readkey;
                    Case k of
                      #72 :  if Snake[1].direction <> down then  Snake[1].direction := up; 
                      #80 :  if Snake[1].direction <>  up then     Snake[1].direction := down; 
                      #75 :  if Snake[1].direction <> right then   Snake[1].direction := left; 
                      #77 :  if Snake[1].direction <> left then     Snake[1].direction := right; 
                    end;
                end
           end;
    
    For playerNo := 1 To numberOfPlayers Do
      begin
        if snake[PlayerNo].dead = false Then
          begin
            moveSnake(playerNo);
            if (collision(playerNo)) then
              begin
                snake[playerNo].dead := true;
                allDead := allDead+1;
              end
            else drawSnake(playerNo);
          end;
      end;

    if numberOfPlayers > 1 then
      if allDead = numberOfPlayers-1 then
        for PlayerNo := 1 to numberOfPlayers do
          if snake[PlayerNo].dead = false then
            for playerNo2 := 1 to numberOfPlayers do
              if snake[playerNo].length > snake[playerNo2].length Then
                allDead := numberOfPlayers;
  until allDead = numberOfPlayers;
  gameOver(numberOfPlayers);
end;

procedure resetSnake(SnakeNo : Byte);
begin
    case snakeNo Of
      1 : snake[snakeNo].colour := player1color;  
      2 : snake[snakeNo].colour := player2color;  
    end; 
  snake[snakeNo].headChar := 'O';
 snake[snakeNo].tailChar := 'x';
end;    

procedure initOptions;
begin
  resetSnake(1);
  resetSnake(2);
end;

procedure generateoutline;
var
x:integer;
begin
gotoxy(widthstart,heightstart);
		for x:=1 to (width div 2) do
		write('.x');
gotoxy(widthstart,height+heightStart); 
	for x:=1 to (width div 2) do
		write('.x');
	for x:=1 to (height-1) do begin
		gotoxy(widthStart,heightstart+x); 
		writeln('x');
	end;
	for x:=1 to (height-1) do begin
		gotoxy(widthstart+width,heightstart+x);
		write('x');
		end;
end;
procedure movestartscreen(var a:integer);
var
 b,p:integer;
begin
	textcolor(yellow);
	a+=1;
	b:=a;
	if a=79 then a:=1; (*79+length(multiplayer snake game)=100*)
	gotoxy(a,12); (*multiplayer snake game is in the 12th row*)
		write('MUTIPLAYER SNAKE GAME');
		gotoxy(a,13); (*press enter is in the 13th row*)
		write('PRESS ANY KEY TO BEGIN');
		if a<>1 then begin
		gotoxy(a-1,12);
		write(' ');
		gotoxy(a-1,13);
		write(' ');
		end; 
	if b=79 then begin
	for p:=b to 100 do begin (*100 being the total width*)
		gotoxy(p-1,12);
		write(' ');
		gotoxy(p-1,13);
		write(' ');
		end; 
		end;
		cursoroff;
end;
procedure startscreen; // The first screen to appear
var
	a:		integer=2; //for moving the 'press enter' statements
	coolProject:array [0..10]of string=('C','O','O','L','P','R','O','J','E','C','T');
begin // Begin startscreen
			repeat // Begin finding random spot
			randomize;
			movestartscreen(a);
			textcolor(green);
			gotoxy(random(100)+1,random(27)+1);
			write (coolProject[random(11)]);
			gotoxy(random(100)+1,random(27)+1);
			write(chr(random(128)+128));
			delay(100);
		until keypressed // End print
	end; // End startscreen
procedure mainMenu;
var
 inp:string; (*input for game modes (1,2,3,4 or 5*)
 colinp,spinp:string; (*input for color setting*)
begin
repeat
	clrscr;
	textcolor(white);
	gotoxy(1,40);
	writeln('Welcome to the Snake game');
	gotoxy(1,2);
	writeln();
	textcolor(white);
	writeln('1. Single Player Mode');
	writeln('2. Multi-Player Mode');
	writeln('3. Exit'); 
	writeln('Select an option(type 1,2,3)');
	cursoron;
	readln(gamemode);
	if gamemode='3' then exit;
	if gamemode='1' then exit;
until (gamemode='2');
repeat
clrscr;
textcolor(white);
gotoxy(40,5);
writeln('Speed and Skin Colors');
gotoxy(10,10);
textcolor(yellow);
writeln('Player 1');
gotoxy(10,12);
textcolor(7);
writeln('1.Speed = ',gameSpeed);
gotoxy(10,15);
textcolor(player1color);
write('2.ooooooo');
gotoxy(80,10);
textcolor(yellow);
writeln('player 2');
gotoxy(80,12);
textcolor(7);
writeln('3.Speed = ',gameSpeed);
gotoxy(80,15);
textcolor(player2color);
write('4.xxxxxO');
gotoxy(1,17);
textcolor(7);
writeln('Press 1,2,3 or 4 to change settings. Press 5 to begin');
cursoron;
repeat
readln(inp);
until (inp='1') or (inp='2') or (inp='3') or (inp='4') or (inp='5');
if (inp='2') or (inp='4') then begin
		writeln('1. Blue');
		writeln('2.Green');
		writeln('3.Cyan');
		writeln('4.Red');
		writeln('5.Magneta');
		writeln('Enter a number (1..5)');
repeat
		readln(colinp);
until (colinp='1') or (colinp='2') or (colinp='3') or (colinp='4') or (colinp='5');
if inp='2' then player1color:=strtoint(colinp)
else player2color:=strtoint(colinp);
end
 else if (inp='1') or (inp='3') then 
  begin
	writeln('1. Hard (speed=40)');
	
	writeln('2. Medium (speed=100)');
	writeln('3. Easy (speed=140)');
	repeat
	readln(spInp); (*for color*)
	until  (spInp='1') or (spInp='2') or (spInp='3');
			if spinp='1' then gameSpeed:=40
			else if spinp='2'then gameSpeed:=100
				else gameSpeed:=140;
		end;
until (inp='5') or (gameMode='1');
end;
Begin
  randomize;
  clrscr;
startscreen;
mainMenu;
initOptions;
    case gameMode of
	  '1' : begin  clrscr; generateoutline; setUpGame(1); playGame(1); end;
      '2' : begin  clrscr; generateoutline; setUpGame(2); playGame(2); end;
      '3' : exit;
    end;
end.


