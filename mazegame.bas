#include <printfzx.bas>

BORDER 0
PAPER 0
INK 7
BRIGHT 0
FLASH 0
CLS

REM ==================================================
REM USER-DEFINED GRAPHICS: BALL, DIAMOND, EXIT AND BRICK WALL
REM ==================================================

DIM UdgByte AS UBYTE
DIM UdgValue AS UBYTE

FOR UdgByte=0 TO 31
  READ UdgValue
  POKE 65368+UdgByte,UdgValue
NEXT UdgByte

REM Select Boriel's bundled large bold FZX font
printFzxSetFontAddr(@BigFont)

REM Ball
DATA 60,126,255,255,255,255,126,60
REM Diamond
DATA 24,60,126,255,126,60,24,0
REM Exit
DATA 126,66,90,90,90,66,126,0
REM Brick wall
DATA 251,251,251,0,223,223,223,0

REM ==================================================
REM TITLE SCREEN
REM ==================================================

INK 6
FLASH 0
CLS
FOR AttrRow=5 TO 7
  FOR AttrCol=11 TO 20
    POKE 22528+AttrRow*32+AttrCol,134
  NEXT AttrCol
NEXT AttrRow
printFzxAt(45,92)
printFzxStr("MAZE GAME")

FLASH 0
INK 7
PRINT AT 10,6;"PRESS ANY KEY TO START"

PRINT AT 14,10;"Q - UP"
PRINT AT 15,10;"A - DOWN"
PRINT AT 16,10;"O - LEFT"
PRINT AT 17,10;"P - RIGHT"
PRINT AT 18,7;"SPACE - START AGAIN"

PAUSE 0

REM ==================================================
REM SCREEN SCRUB
REM ==================================================

FOR ScrubRow=0 TO 10
  BEEP 0.015,20-ScrubRow*2
  PRINT AT ScrubRow,0;"                                "
  PRINT AT 21-ScrubRow,0;"                                "
NEXT ScrubRow

CLS

REM ==================================================
REM MAZE ARRAYS
REM ==================================================

DIM Maze(21,31) AS UBYTE
DIM Visited(9,14) AS UBYTE
DIM DiamondMap(9,14) AS UBYTE

DIM StackCol(149) AS UBYTE
DIM StackRow(149) AS UBYTE

DIM DeltaCol(3) AS INTEGER
DIM DeltaRow(3) AS INTEGER
DIM AvailableDirection(3) AS UBYTE
DIM WallColour(3) AS UBYTE

REM ==================================================
REM MAZE VARIABLES
REM ==================================================

DIM ScreenRow AS UBYTE
DIM ScreenCol AS UBYTE

DIM CellCol AS UBYTE
DIM CellRow AS UBYTE

DIM NextCol AS INTEGER
DIM NextRow AS INTEGER

DIM Direction AS UBYTE
DIM Choices AS UBYTE
DIM Choice AS UBYTE
DIM StackPointer AS UBYTE

DIM PlayerRow AS UBYTE
DIM PlayerCol AS UBYTE
DIM OldPlayerRow AS UBYTE
DIM OldPlayerCol AS UBYTE
DIM DiamondRow AS UBYTE
DIM DiamondCol AS UBYTE
DIM DiamondsTotal AS UBYTE
DIM DiamondsRemaining AS UBYTE
DIM DiamondsPlaced AS UBYTE
DIM Stage AS UBYTE
DIM MovementDelay AS UBYTE
DIM MovementWait AS UBYTE
DIM MovementFrame AS UBYTE
DIM MessageChoice AS UBYTE
DIM Message$ AS STRING
DIM AttrRow AS UBYTE
DIM AttrCol AS UBYTE
DIM CurrentWallColour AS UBYTE

DIM Key$ AS STRING

DIM Wall$ AS STRING
LET Wall$=CHR$ 147

DIM Player$ AS STRING
LET Player$=CHR$ 144

DIM Diamond$ AS STRING
LET Diamond$=CHR$ 145

DIM Exit$ AS STRING
LET Exit$=CHR$ 146

REM A complete screen row, used to draw the maze efficiently
DIM DrawRow$ AS STRING

REM ==================================================
REM DIRECTION TABLE
REM ==================================================

LET DeltaCol(0)=1
LET DeltaRow(0)=0

LET DeltaCol(1)=-1
LET DeltaRow(1)=0

LET DeltaCol(2)=0
LET DeltaRow(2)=1

LET DeltaCol(3)=0
LET DeltaRow(3)=-1

LET WallColour(0)=2
LET WallColour(1)=1
LET WallColour(2)=3
LET WallColour(3)=4

RANDOMIZE

LET Stage=1

REM Number of 50Hz video frames between player steps
LET MovementDelay=4


NewMaze:

CLS

INK 6
PRINT AT 10,10;"MAKING MAZE..."

BuildMaze:

REM ==================================================
REM FILL SCREEN WITH WALLS
REM ==================================================

FOR ScreenRow=0 TO 21
  FOR ScreenCol=0 TO 31
    LET Maze(ScreenRow,ScreenCol)=1
  NEXT ScreenCol
NEXT ScreenRow

REM ==================================================
REM CLEAR VISITED CELLS
REM ==================================================

FOR CellRow=0 TO 9
  FOR CellCol=0 TO 14
    LET Visited(CellRow,CellCol)=0
  NEXT CellCol
NEXT CellRow

REM ==================================================
REM START AT BOTTOM LEFT
REM ==================================================

LET StackPointer=0

LET StackCol(0)=0
LET StackRow(0)=9

LET Visited(9,0)=1
LET Maze(19,1)=0


GenerateMaze:

LET CellCol=StackCol(StackPointer)
LET CellRow=StackRow(StackPointer)

LET Choices=0

REM ==================================================
REM COUNT AVAILABLE NEIGHBOURS
REM ==================================================

FOR Direction=0 TO 3

  LET NextCol=CellCol+DeltaCol(Direction)
  LET NextRow=CellRow+DeltaRow(Direction)

  IF NextCol>=0 THEN
    IF NextCol<=14 THEN
      IF NextRow>=0 THEN
          IF NextRow<=9 THEN
            IF Visited(NextRow,NextCol)=0 THEN
              LET AvailableDirection(Choices)=Direction
              LET Choices=Choices+1
            END IF
        END IF
      END IF
    END IF
  END IF

NEXT Direction

REM ==================================================
REM BACKTRACK IF CELL HAS NO AVAILABLE ROUTES
REM ==================================================

IF Choices=0 THEN

  IF StackPointer=0 THEN
    GO TO DrawMaze
  END IF

  LET StackPointer=StackPointer-1
  GO TO GenerateMaze

END IF

REM ==================================================
REM CHOOSE A RANDOM AVAILABLE ROUTE
REM ==================================================

LET Choice=INT(RND*Choices)
LET Direction=AvailableDirection(Choice)
LET NextCol=CellCol+DeltaCol(Direction)
LET NextRow=CellRow+DeltaRow(Direction)


CarvePassage:

REM Remove wall between the current and next cells

LET Maze(2*CellRow+1+DeltaRow(Direction),2*CellCol+1+DeltaCol(Direction))=0

REM Open the centre of the next cell

LET Maze(2*NextRow+1,2*NextCol+1)=0

LET Visited(NextRow,NextCol)=1

LET StackPointer=StackPointer+1
LET StackCol(StackPointer)=NextCol
LET StackRow(StackPointer)=NextRow

GO TO GenerateMaze


DrawMaze:

CLS
LET CurrentWallColour=WallColour((Stage-1) MOD 4)
INK CurrentWallColour

FOR ScreenRow=0 TO 21

  LET DrawRow$="                                "

  FOR ScreenCol=0 TO 31

    IF Maze(ScreenRow,ScreenCol)=1 THEN
      LET DrawRow$(ScreenCol)=Wall$
    END IF

  NEXT ScreenCol

  PRINT AT ScreenRow,0;DrawRow$;

NEXT ScreenRow

REM ==================================================
REM SCATTER DIAMONDS
REM ==================================================

FOR CellRow=0 TO 9
  FOR CellCol=0 TO 14
    LET DiamondMap(CellRow,CellCol)=0
  NEXT CellCol
NEXT CellRow

LET DiamondsTotal=Stage+1
IF DiamondsTotal>148 THEN
  LET DiamondsTotal=148
END IF

LET DiamondsRemaining=DiamondsTotal
LET DiamondsPlaced=0

PlaceDiamonds:

IF DiamondsPlaced=DiamondsTotal THEN
  GO TO DrawGamePieces
END IF

LET DiamondRow=INT(RND*10)
LET DiamondCol=INT(RND*15)

REM Do not place a diamond on the player or exit
IF DiamondRow=9 THEN
  IF DiamondCol=0 THEN
    GO TO PlaceDiamonds
  END IF
END IF

IF DiamondRow=0 THEN
  IF DiamondCol=14 THEN
    GO TO PlaceDiamonds
  END IF
END IF

IF DiamondMap(DiamondRow,DiamondCol)=1 THEN
  GO TO PlaceDiamonds
END IF

LET DiamondMap(DiamondRow,DiamondCol)=1
LET DiamondsPlaced=DiamondsPlaced+1
GO TO PlaceDiamonds


DrawGamePieces:

FOR CellRow=0 TO 9
  FOR CellCol=0 TO 14
    IF DiamondMap(CellRow,CellCol)=1 THEN
      PRINT AT 2*CellRow+1,2*CellCol+1;INK 6;Diamond$
    END IF
  NEXT CellCol
NEXT CellRow

LET PlayerRow=19
LET PlayerCol=1

PRINT AT 1,29;INK 2;Exit$
PRINT AT PlayerRow,PlayerCol;INK 5;Player$

REM ==================================================
REM PLAYER MOVEMENT
REM ==================================================

MovePlayer:

LET Key$=INKEY$

IF Key$="" THEN
  GO TO MovePlayer
END IF

IF Key$=" " THEN
  LET Stage=1
  GO TO NewMaze
END IF

LET OldPlayerRow=PlayerRow
LET OldPlayerCol=PlayerCol

IF Key$="q" OR Key$="Q" THEN
  IF Maze(PlayerRow-1,PlayerCol)=0 THEN
    LET PlayerRow=PlayerRow-2
  END IF
END IF

IF Key$="a" OR Key$="A" THEN
  IF Maze(PlayerRow+1,PlayerCol)=0 THEN
    LET PlayerRow=PlayerRow+2
  END IF
END IF

IF Key$="o" OR Key$="O" THEN
  IF Maze(PlayerRow,PlayerCol-1)=0 THEN
    LET PlayerCol=PlayerCol-2
  END IF
END IF

IF Key$="p" OR Key$="P" THEN
  IF Maze(PlayerRow,PlayerCol+1)=0 THEN
    LET PlayerCol=PlayerCol+2
  END IF
END IF

REM A red exit warns the player, but does not block their route
IF PlayerRow=1 THEN
  IF PlayerCol=29 THEN
    IF DiamondsRemaining>0 THEN
      GO SUB LockedExitTune
    END IF
  END IF
END IF

IF PlayerRow=OldPlayerRow THEN
  IF PlayerCol=OldPlayerCol THEN
    GO TO MovePlayer
  END IF
END IF

PRINT AT OldPlayerRow,OldPlayerCol;" "

IF OldPlayerRow=1 THEN
  IF OldPlayerCol=29 THEN
    IF DiamondsRemaining=0 THEN
      PRINT AT 1,29;INK 6;FLASH 1;Exit$
      FLASH 0
    ELSE
      PRINT AT 1,29;INK 2;Exit$
    END IF
  END IF
END IF

LET CellRow=(PlayerRow-1)/2
LET CellCol=(PlayerCol-1)/2

IF DiamondMap(CellRow,CellCol)=1 THEN
  LET DiamondMap(CellRow,CellCol)=0
  LET DiamondsRemaining=DiamondsRemaining-1
  BEEP 0.015,28

  IF DiamondsRemaining=0 THEN
    GO SUB DiamondsCollectedTune
    PRINT AT 1,29;INK 6;FLASH 1;Exit$
    FLASH 0
  END IF
END IF

PRINT AT PlayerRow,PlayerCol;INK 5;Player$

IF PlayerRow=1 THEN
  IF PlayerCol=29 THEN
    IF DiamondsRemaining=0 THEN
      GO SUB VictoryTune
      LET Stage=Stage+1
      GO SUB ShowStageMessage
      GO TO BuildMaze
    END IF
  END IF
END IF

GO SUB MovementPause
GO TO MovePlayer


MovementPause:

REM Wait for complete video frames; unlike PAUSE, held keys cannot skip this
FOR MovementWait=1 TO MovementDelay
  LET MovementFrame=PEEK 23672

WaitForNextFrame:

  IF PEEK 23672=MovementFrame THEN
    GO TO WaitForNextFrame
  END IF
NEXT MovementWait
RETURN


LockedExitTune:

REM Two low notes mean that more diamonds are needed
BEEP 0.035,-12
BEEP 0.045,-16
RETURN


ShowStageMessage:

INK 6
FLASH 0
CLS
FOR AttrRow=5 TO 7
  FOR AttrCol=11 TO 20
    POKE 22528+AttrRow*32+AttrCol,134
  NEXT AttrCol
NEXT AttrRow
printFzxAt(42,91)
printFzxStr("WELL DONE!")
INK 7

LET MessageChoice=INT(RND*12)

IF MessageChoice=0 THEN
  LET Message$="THAT MAZE NEVER STOOD A CHANCE!"
END IF

IF MessageChoice=1 THEN
  LET Message$="SHARP TURNS, SHARPER THINKING!"
END IF

IF MessageChoice=2 THEN
  LET Message$="YOU MAKE DEAD ENDS LOOK EASY!"
END IF

IF MessageChoice=3 THEN
  LET Message$="ANOTHER MAZE MASTERED!"
END IF

IF MessageChoice=4 THEN
  LET Message$="NO WALL CAN HOLD YOU!"
END IF

IF MessageChoice=5 THEN
  LET Message$="YOUR MAZE SKILLS KEEP GROWING!"
END IF

IF MessageChoice=6 THEN
  LET Message$="THAT WAS SOME FANCY FOOTWORK!"
END IF

IF MessageChoice=7 THEN
  LET Message$="DIAMONDS NEVER SAW YOU COMING!"
END IF

IF MessageChoice=8 THEN
  LET Message$="BRILLIANT ROUTE FINDING!"
END IF

IF MessageChoice=9 THEN
  LET Message$="NEXT MAZE, STEP RIGHT UP!"
END IF

IF MessageChoice=10 THEN
  LET Message$="THAT WAS A-MAZE-ING! HO HO!"
END IF

IF MessageChoice=11 THEN
  LET Message$="THE WALLS ARE GETTING NERVOUS!"
END IF

PRINT AT 10,(32-LEN(Message$))/2;Message$
RETURN


DiamondsCollectedTune:

BEEP 0.025,16
BEEP 0.025,21
BEEP 0.025,25
RETURN


VictoryTune:

BEEP 0.04,9
BEEP 0.04,13
BEEP 0.04,16
BEEP 0.07,21
RETURN


BigFont:
ASM
INCBIN "fzx_fonts/bigbold.fzx"
END ASM
