// ����� ��� ��0010
// (c) 5-03-2012 VINXRU (aleksey.f.morozov@gmail.com)
// 10-03-2012 ���� ���������� �� ���� �>>


	        ORG 01000;

EntryPoint:     // �������������� ����
		SP = #16384;

		// �������� ����� ������ 256x256
		R0 = #0233;
		EMT 016;

		// ���������� �������
		R0 = #0232;
		EMT 016;

		// ������ �������
		@#0177706 = #731;
		@#0177712 = #0160;

		// ��������� ���������� ����������
		@#0177660 = #64;

		// ������� ������
Menu:		clearScreen();

		// ����� ����		
		R0 = #bmpLogo;
		R1 = #045020;
		R3 = #37;
		do {
		  R2 = #16;
		  do {
		    (R1)+ = (R0)+;
		  } while(R2--);
		  R1 += #32;
		} while(R3--);

		// ����� ����
		R0 = #txtMenu;
		print();

		do {
		  // �������������� ��������� ��������� �����.
		  R1 = #256;
                  rand();

		  // ������������ �������
		  R0 = @#0177662;

		  // ������ �������
		  R5 = #menuItems;
		  do {
		    R1 = (R5)+;
		    if(R1 == #0) break;
		    if(R1 == R0) goto startGame;
		    R5 += #8;
		  };
		};

//----------------------------------------------------------------------------
// ������ ����

txtMenu:	DB 10,12,0222,"0. ������",0;
		DB 10,13,     "1. �������",0;
		DB 10,14,     "2. ��������",0;
		DB 10,15,     "3. ������������",0;
		DB  9,22,0221,"(c) 2012 VINXRU",0;
		DB  3,23,0223,"aleksey.f.morozov@gmail.com",0,255;

		ALIGN 2;

menuItems:	DW '0', 9, 9, 3, 21006; // �������, ������, ������, ���-�� ����, ��������� �� ������
		DW '1', 9, 9, 10, 21006;
	 	DW '2', 13, 10, 20, 20486;
		DW '3', 16, 14, 43, 18432;
		DW 0;

//----------------------------------------------------------------------------
// ����

startGame:      // ��������� �������� ����
		gameWidth   = (R5)+;
		gameHeight  = (R5)+;
		bombsCnt    = (R5)+;
		playfieldVA = (R5)+;

		// ������� ������
		clearScreen();
		fillBlocks();

		// ������������� ������ � ����� ����
		cursorX = gameWidth >> #1;
		cursorY = gameHeight >> #1;

		// ������� �������� ����������
		bombsPutted = #0;
		gameOverFlag = #0;
		time = #0;

		// ������� �������� ����
		R0 = #0;
		R1 = #254;
		do {
		  playfield(R0b) = R1b;
		  userMarks(R0b) = #0;
		} while(R0b++);

		// ����� ��������
		R0 = #bmpGood;
		drawSmile();

		// ��������� �������� ����
		drawPlayField();
	
		// ����� �����
		leftNumber();
		rightNumber();
		
		
mainLoop:       do {
                  do {
		    // �����
		    if(gameOverFlag!=#1) {
		      if(time!=#999) {
		        // ������ �������?
		        R0 = #0;
		        if(@#0177710 > #365) R0++;
		        if(lastTimer != R0) {
		          lastTimer = R0;

		          // �� ������. ����������� ���������� � �������������� �����
		          time++;
		          rightNumber();
		        };
		      };
		    };

		    // ����, ���� �� ������ �������
		  } while(#128 & @#0177660 == #0);

		  // ������� �������
		  hideCursor();

		  // ��� ������� �������
		  R0 = @#0177662;

		  if(R0==#8  ) { 
		    if(cursorX != #0) cursorX--; 
		  } else
		  if(R0==#1Ah) {
		    if(cursorY != #0) cursorY--; } else
		  if(R0==#19h) {
		    cursorX++; if(cursorX == gameWidth) cursorX--; 
		  } else
		  if(R0==#1Bh) {
		    cursorY++; if(cursorY == gameHeight) cursorY--; 
		  } else
		  if(R0==#' ') { 
		    leftClick();
                  } else {
		    rightClick();
  		    hideCursor();
		  };

		  // ������ ������
		  showCursor();
		};

//----------------------------------------------------------------------------

MenuFar:	goto Menu;

//----------------------------------------------------------------------------
// ����� ������ ����

leftClick:	// ���� ����� �� �����������, ���������� �����
		if(bombsPutted == #0) goto putBombs;

		// ���� ���� ���������, �� ����� � ����
putBombsRet:	if(gameOverFlag != #0) goto MenuFar;

		// ������ � �����?
		R0 = cursorX;
		R1 = cursorY;
		mul01();
	        if(playfield(R2b) == #255) goto die;

		// ������� ������ � ��� ������ ������
		open();

		// ���������, �������� �� ��
		checkWin();
	
		// �������� ���� ����	
		return;

//----------------------------------------------------------------------------
// ����� ����

die:		// ����� ��������
		R0 = #bmpBad;
		drawSmile();
		goto gameOver;

//----------------------------------------------------------------------------
// ����� ������ ���������� - ��������� �����

rightClick:	// ���� ���� ���������, �� ������ �� ������
		if(gameOverFlag != #0) goto rightClickRet;

		// ������ ������
		R0 = cursorX;
		R1 = cursorY;
		mul01();
		userMarks(R2b)++;
		if(userMarks(R2b) == #3) userMarks(R2b) = #0;

		// ����������� ����� �����
		leftNumber();

rightClickRet:	return;

//----------------------------------------------------------------------------
// ��������� ����� �� ����

putBombs:	bombsPutted++;

                // ����
		R4 = bombsCnt;
		do {
putBombs2:	  // ���������� Y
		  R1 = gameHeight;
		  rand();		// R1->R0, R1=R2=? 
		  R3 = R0;

                  // ���������� X
		  R1 = gameWidth;
		  rand();		// R1->R0, R1=R2=?
		  R1 = R3;

		  // ����� �� ������ ���� ��� �������
		  if(cursorX==R0) if(cursorY==R1) goto putBombs2;

		  // ������ ������ � �������
		  mul01();		// R0,R1->R2

		  // ����� � ���� ������ ��� ����
		  if(playfield(R2b) == #255) goto putBombs2;

		  // ������ �����
		  playfield(R2b) = #255;
		} while(R4--);

		goto putBombsRet;

//----------------------------------------------------------------------------
// ������������ ������ (������� ������)

hideCursor:	R0 = cursorX;
		R1 = cursorY;
		mul01();		// R0+R1*16 -> R2
		calcCell2();		// R0,R1 -> R1
		R0b = playfield(R2b);   
		getBitmap();		// R0 -> R0
		if(R0b==#bmpUn) {
		  R5b = userMarks(R2b);
		  if(R5 == #1) R0 = #bmpF;
		  if(R5 == #2) R0 = #bmpQ;
		};
drawCursor5:	drawImage();		// R0=R1=R2=?
		return; 

//----------------------------------------------------------------------------
// ���������� ������ ������ ������

showCursor:	R0 = cursorX;
		R1 = cursorY;
		calcCell2();		// R0,R1 -> R1
		R0 = #bmpCursor;
		goto drawTransImage;

//----------------------------------------------------------------------------
// ������ ������ � ����������� ������ �������� ���� 
// R0,R1 - ���������� => R1 - �����

calcCell2:	ASM SWAB R1;
		R1 = R1 << #2 + R0 + R0 + R0 + R0 + playfieldVA;
		return;

//----------------------------------------------------------------------------
// ������ ����
// R0,R1 - ����������. R3 - ������� => R2 - ������

check:		if(unsigned R0 >= gameWidth ) goto checkRet;
		if(unsigned R1 >= gameHeight) goto checkRet;
		mul01();
		if(playfield(R2b) == #255) R3++;
checkRet:	return;

//----------------------------------------------------------------------------
// ������ ����

call8:		R1--;       call81(); 
		R0--; R1++; (R5)();
		R0++; R0++; (R5)();
		R0--; R1++; call81();
		R1--;
		return;

//----------------------------------------------------------------------------
// ������ ����

call81:         R0--; (R5)();
		R0++; (R5)();
		R0++; (R5)();
		R0--;
		return;

//----------------------------------------------------------------------------
// R0+R1*16 => R2

mul01:		R2 = R1 << #4 + R0;
		return;

//----------------------------------------------------------------------------
// ������ ����

// ��, � ���� ��� ��� ��� ����� �������������� :)

open:		if(unsigned R0 >= gameWidth ) goto openRet;
                if(unsigned R1 >= gameHeight) goto openRet;
		mul01();
		if(userMarks(R2b) != #0) goto openRet;
		if(playfield(R2b) != #254) goto openRet;
		// ��������� ����� ���� ������. ��������� � R3
		R5 = #check;
		R3 = #0;
		call8();
		R5 = #open;

		// ���������� ���������
		mul01();
		playfield(R2b) = R3b;

		// �������������� ������
  		push R0, R1 {
		  calcCell2();		// R0,R1 -> R1
		  R0 = R3;
		  getBitmap();		// R0 -> R0
		  drawImage();		// R0=R1=R2=?
		};

		// ���� � ������ 0, �� ��������� �������� ������
		if(R3 == #0) call8();
		
openRet:        return;

//----------------------------------------------------------------------------
// �������� ��������� �� ����������� �� ������ �����������
// R0 => R0

getBitmap:      R0 += #2;
		R0 !&= 0FF000h;
		if(gameOverFlag==#0) if(R0==#1) R0=#0;
getBitmap2:	ASM SWAB R0;
		R0 = R0 >> #2 + #bmpUn;
                return; 

//----------------------------------------------------------------------------
// ��������� ��������� �����
// R1 - �������� => R0 - ��������� �����. R1,R2 - ������.

rand_state:	dw 1245h;
		
rand:           R0 = rand_state;
		R2 = R0 << #2;
		R0 = R0 >> #5 ^ R2;
		rand_state = R0;
		R0 = R2;
		ASM SWAB R0;
		R0 ^= R2;
		R2 = @#0177710;
		R0 ^= R2;
		R0 !&= #0FF00h;

		goto div;

//----------------------------------------------------------------------------
// �������
// R0/R1 => R2, ������� � R0

div:		R2 = #0;
		do {
		  R0 -= R1;
		  ASM BCS div2;
		  R2++;
		};
div2:		R0 += R1;
		return;

//----------------------------------------------------------------------------
// ��������, ������� �� �����
// => ������ ��� ��������

checkWin:	// ������� �� �������� ������ ��� ����.
		R3 = #254;
		R1 = #0;
checkWin2:	do {
		  R0 = #0;
		  do {
checkWin1:	    mul01();
		    if(playfield(R2b) == R3b) goto checkWin3;
		    R0++;
		  } while(R0 != gameWidth);
		  R1++;
		} while(R1 != gameHeight);
		
		// ������������ �������

		// ������ �������
		R0 = #bmpWin;
		drawSmile();

gameOver:	// ����� ����
		gameOverFlag = #1;

		// �������� ��� �����
		drawPlayField();

checkWin3:	return;
                               
//----------------------------------------------------------------------------
// ������ � ����� �� ����� ������ �����
// => ������ ��� ��������

leftNumber:	// ������� ���-�� ������
		R0 = #0;
		R1 = bombsCnt;
		do {
		  if(unsigned playfield(R0b) >= #254) {
  		    if(usermarks(R0b) == #1) {
		      R1--;
		      ASM BEQ leftNumber4;
		    };
 		  };
		} while(R0b++);

		// ����� ����� �� �����
leftNumber4:	R0 = R1;
	        R3 = #040510;
		goto drawNumber;

//----------------------------------------------------------------------------
// ����� �� ����� ������� �����
// => ������ ��� ��������
		          
rightNumber:	R0 = time;		// �������� �����
	        R3 = #040573;		// ����� � �����������

//----------------------------------------------------------------------------
// ����� ������������ ����� �� �����
// R0 - �����, R3 - ����� � �����������. => ������ ��� ��������.

drawNumber:	R5 = #3;		// ���-�� �����
                do {
		  // �������� ������ �����
		  R1 = #10;
		  div();		// R0/R1 -> �������=, �������=R0

		  // ������ ��������� �������
		  ASM SWAB R0;
		  R0 = R0 >> #2 + #bmpN0;

		  // ����� ����������
		  R4 = #21;
		  do {
		    (R3b)+ = (R0b)+;
		    (R3b)+ = (R0b)+;
		    (R3b)+ = (R0b)+;
		    R3 += #61;
		  } while(R4--);

		  // ��������� ���������� �������
		  R3 -= #1347;

		  // ����
		  R0 = R2;
		} while(R5--);		
		return;

//-----------------------------------------------
// ����� ��������
// => R0 - �����������. ������ R1,R2

drawSmile:	R1 = #040435;
		R2 = #24;
		do {
		  (R1)+ = (R0)+;
		  (R1)+ = (R0)+;
		  (R1)+ = (R0)+;
		  R1 += #58;
		} while(R2--);
		return;

//----------------------------------------------------------------------------
// ��������� �������� ���� � �������
// => ������ ��� ��������

drawPlayField:	R4 = #0;
		do {
		  R3 = #0;
		  do {
		    R0=R3;
		    R1=R4;
  	     	    mul01();			// R0,R1 -> R2
		    calcCell2();		// R0,R1 -> R1
		    R0b = playfield(R2b);	// R2 -> R0	
		    getBitmap();		// R0 -> R0
		    drawImage();		// R0=R1=R2=?
		    R3++;
		  } while(R3 < gameWidth);
		  R4++;
		} while(R4 < gameHeight);		
		goto showCursor;

//----------------------------------------------------------------------------
// �������� �����
// => ������ R0, R2

clearScreen:	R0 = #040000;
		R2 = #2048;
		do {
		  (R0)+ = #0;
		  (R0)+ = #0;
		  (R0)+ = #0;
		  (R0)+ = #0;
		} while(R2--);
		return;

//----------------------------------------------------------------------------
// ��������� �����

fillBlocks:	R0 = #044000;
		R4 = #14;
fillBlocks3:	do {
		  R1 = #bmpBlock;
		  R3 = #16;
fillBlocks2:	  do {
	  	    R2 = #16;
fillBlocks1:	    do {
		      (R0)+ = (R1)+;
		      (R0)+ = (R1)+;
		      R1 -= #4;
		    } while(R2--);
		    R1 += #4;
	  	  } while(R3--);
		} while(R4--);
		return;

//----------------------------------------------------------------------------
// ���������� ����������� 16x16 � �������������
// R0 - �����������, R1 - ���� => ������ R1, R2

drawTransImage: R2 = #16;
		do {
		  (R1)  !&= (R0)+;
		  (R1)+ |=  (R0)+;
		  (R1)  !&= (R0)+;
		  (R1)+ |=  (R0)+;
		  R1 += #60;
		} while(R2--); 
		return;

//----------------------------------------------------------------------------
// ���������� ����������� 16x16
// R0 - �����������, R1 - ���� => ������ R1, R2

drawImage:      R2 = #16;
		do {
		  (R1)+ = (R0)+;
		  (R1)+ = (R0)+;
		  R1 += #60;
		} while(R2--); 
		return;

//----------------------------------------------------------------------------
// ����� ������

Print:		do {
		  // ��������� ���������
		  R1 = #0;
     		  R1b = (R0b)+;
		  R2 = #0;
		  R2b = (R0b)+;
		  EMT 024;		                       

		  // ����� ������
		  R1 = R0;
		  R2 = #0FFh;
		  EMT 020;

		  // ����� ���� ������
Print1:		  do { } while((R0b)+ != #0);
		} while((R0b) != #255);
		return;

//----------------------------------------------------------------------------
// �����������

bmpLogo:   	insert_bitmap2 "resources/logo.bmp",  128, 37;

bmpCursor:  	insert_bitmap2t "resources/cursor.bmp",  16, 16;

bmpF:    	insert_bitmap2 "resources/f.bmp", 16, 16;
bmpQ:    	insert_bitmap2 "resources/q.bmp", 16, 16;

bmpUn:   	insert_bitmap2 "resources/un.bmp", 16, 16;
bmpB:    	insert_bitmap2 "resources/b.bmp",  16, 16;
bmp0:    	insert_bitmap2 "resources/0.bmp",  16, 16;
bmp1:    	insert_bitmap2 "resources/1.bmp",  16, 16;
bmp2:    	insert_bitmap2 "resources/2.bmp",  16, 16;
bmp3:    	insert_bitmap2 "resources/3.bmp",  16, 16;
bmp4:    	insert_bitmap2 "resources/4.bmp",  16, 16;
bmp5:    	insert_bitmap2 "resources/5.bmp",  16, 16;
bmp6:    	insert_bitmap2 "resources/6.bmp",  16, 16;
bmp7:    	insert_bitmap2 "resources/7.bmp",  16, 16;
bmp8:    	insert_bitmap2 "resources/8.bmp",  16, 16;

bmpGood: 	insert_bitmap2 "resources/good.bmp", 24, 24;
bmpBad:  	insert_bitmap2 "resources/bad.bmp", 24, 24;
bmpWin:  	insert_bitmap2 "resources/win.bmp", 24, 24;

bmpN0:   	insert_bitmap2 "resources/n0.bmp", 12, 21;
bmpN1:   	insert_bitmap2 "resources/n1.bmp", 12, 21;
bmpN2:   	insert_bitmap2 "resources/n2.bmp", 12, 21;
bmpN3:   	insert_bitmap2 "resources/n3.bmp", 12, 21;
bmpN4:   	insert_bitmap2 "resources/n4.bmp", 12, 21;
bmpN5:   	insert_bitmap2 "resources/n5.bmp", 12, 21;
bmpN6:   	insert_bitmap2 "resources/n6.bmp", 12, 21;
bmpN7:   	insert_bitmap2 "resources/n7.bmp", 12, 21;
bmpN8:   	insert_bitmap2 "resources/n8.bmp", 12, 21;
bmpN9:   	insert_bitmap2 "resources/n9.bmp", 12, 21;                          

bmpBlock:   	insert_bitmap2 "resources/block.bmp", 16, 16;                       

endOfROM:              

//-----------------------------------------------

pfSize equ 256; // ������� ����� ��� ������, ���� ������������ ������ ���� 16x14

gameWidth:	dw 0;
gameHeight:	dw 0;
gameOverFlag:  	dw 0;
cursorX:    	dw 0;
cursorY:    	dw 0;
playfieldVA:	dw 0;
bombsCnt:   	dw 0;
bombsPutted:	dw 0;
time:	    	dw 0;
lastTimer:      dw 0;
playfield:    	db pfSize dup(0);
userMarks:    	db pfSize dup(0);

//-----------------------------------------------

make_bk0010_rom "bk0010_miner.bin", EntryPoint, endOfROM;
