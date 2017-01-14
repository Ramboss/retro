;+---------------------------------------------------------------------------
; MXOS
;
; 2013-12-12 �����ᥬ���஢��� vinxru
;----------------------------------------------------------------------------

; ���� �����:
;   8FDF-8FFF - ��६����
;   9000-BFFF - ��࠭
;   C000-CFFF - DOS.SYS (� ���� ���� ���� ᢮������� ���� ��� ��ࠡ�⪨)
;   D000-E1FF - NC.COM (� ���� ��� ��� ᯨ᮪ 䠩��� � ���� ���� ᢮������� ���� ��� ��ࠡ�⪨)
;   E200-E7FF - (᢮����� 1536 ����)
;   E900-F0FF - ���� (����� �⪫���� ����᪮� ROMFNT.COM ��� ��樥� LOAD_FONT=0)
;   F100-F837 - ������ 2
;   FA00-FAFF - �ࠩ��� ���譥�� ���
;   FB00-FDFF - ��᪮�� ����
;   FF00-FF81 - ���������� ��ப�. ���������� �㭪樥� fileExec
;   FF82-FFC0 - �⥪
;   FFC0-FFEF - ���祪 �ࠩ���
;   FFD0-FFFF - ����㤮�����

fat		= 0FB00h
diskDirectory	= 0FC00h
diskDirectoryL	= 0FE00h
v_cmdLine	= 0FF00h
STACK_ADDR	= 0FFC0h

INIT_COLOR	= 070h

IO_KEYB_A	= 0FFE0h
IO_KEYB_B	= 0FFE1h
IO_KEYB_C	= 0FFE2h
IO_KEYB_MODE	= 0FFE3h
IO_PROG		= 0FFE4h
IO_TIMER	= 0FFECh
IO_COLOR	= 0FFF8h
IO_RAM		= 0FFFCh
IO_ARAM		= 0FFFDh
IO_ROM		= 0FFFEh
IO_PAGE_STD	= 0FFFFh

BIG_MEM		= 1		; ������� �����প� ���� ����襣� 祬 64 ��
ROM_64K		= 1		; ������� �����প� ��� 64 �� ���樠���� ��2
DISABLE_COLOR_BUG = 1		; ������� �����প� 梥�
LOAD_FONT	= 1		; ����㦠�� ���� � ���
FONT_ADDR	= 0E900h	; ���� ����

.org 08FDFh

vars:		.block 2
v_tapeError:	.block 2	; ���� �㤠 �ந�室�� ���室 �� �訡�� �⥭�� � �����
v_tapeAddr:	.block 2	; ���� �ணࠬ�� ����㦥���� � �����
		.block 2
v_charGen:	.block 2	; ���� ����ୠ⨢���� ������������ /8
v_cursorCfg:	.block 1	; ���譨� ��� ����� (7 - ��� ���������, 654 - ���������, 3210 - ����)
v_koi8:		.block 1	; 0FFh=����祭 KOI-8, 0=����祭 KOI-7
v_escMode:	.block 1	; ��ࠡ�⪠ ESC-��᫥����⥫쭮��
v_keyLocks:	.block 1
		.block 2
unk_8FEF:	.block 1
v_lastKey:	.block 1
v_beep:		.block 2	; ���⥫쭮��� � ���� ��㪮���� ᨣ����
v_tapeInverse:	.block 1
v_cursorDelay:	.block 1
byte_8FF5:	.block 1
v_oldSP:	.block 2	; �ᯮ������ ��� ��࠭���� SP ������묨 �㭪�ﬨ
		.block 2
v_inverse:	.block 2	; 0=��ଠ��� ⥪��, 0FFFFh=������� ⥪��
v_cursorY:	.block 1	; ��������� ����� �� ���⨪��� � ���ᥫ��
v_cursorX:	.block 1	; ��������� ����� �� ��ਧ��⠫� � ���ᥫ�� / 2
v_writeDelay:	.block 1	; ������� �� ����� �� �����
v_readDelay:	.block 1	; ������� �� �⥭�� � �����

.org 0C000h

.include "jmps_c000.inc"
.include "reboot0.inc"
.db 0
.include "clearScreen.inc"
.include "printChar.inc"
.db 2Ah, 0FCh
.include "printChar5.inc" ; �த�������� � drawChar
.include "drawChar.inc"
.include "printChar3.inc"
.db 0FFh
.include "beep.inc"
.include "delay_l.inc"
.db 0C9h
.include "printChar4.inc" ; �த�������� � scrollUp
.include "scrollUp.inc"
v_char:	.db 0FFh, 0FFh,	0FFh, 0FFh, 0FFh, 0FFh,	0FFh, 0FFh, 0FFh, 0FFh,	0FFh, 0FFh, 0FFh
.include "keyScan.inc"
.include "getch2.inc"
.include "calcCursorAddr.inc"
.include "getch.inc"
.include "calcCursorAddr2.inc"
.include "drawCursor.inc"
.include "tapeWriteDelay.inc"
.include "tapeRead.inc"
.include "tapeReadDelay.inc"
.include "tapeWrite.inc"
.db 0, 0, 0, 0
.include "tapeLoadInt.inc"
.include "cmp_hl_de.inc"
.include "memcpy_bc_hl.inc"
.include "printString1.inc"
.include "printChar6.inc"
.db 0, 0
.include "drawCursor2.inc"
.include "reboot1.inc"
.db 0
.include "tapeReadError.inc"

; ---------------------------------------------------------------------------

initVars:	.dw -1
		.dw 0C800h		; v_tapeError
		.dw -1			; v_tapeAddr
		.dw -1
#if LOAD_FONT
		.dw FONT_ADDR/8		; v_charGen
#else
		.dw -1			; v_charGen
#endif
		.db 0A9h		; v_cursorCfg
		.db -1			; v_koi8
		.db -1			; v_escMode
		.db 03Ah		; v_keyLocks
		.dw -1
		.db -1			; unk_8FEF
		.db -1			; v_lastKey
		.db 05Fh, 20h		; v_beep
		.db 0FFh		; v_tapeInverse
		.db 020h		; v_cursorDelay
		.db 0E0h		; byte_8FF5
		.dw -1			; v_oldSP
		.dw -1
		.dw 0			; v_inverse
		.db -1			; v_cursorY
		.db -1			; v_cursorX
		.db 28h			; v_writeDelay
		.db 3Ch			; v_readDelay
initVarsEnd:	.db 00h

; ���������

v_keybTbl:	.db 81h, 0Ch, 19h, 1Ah, 09h, 1Bh, 20h,  8,  80h, 18h, 0Ah, 0Dh, 0, 0, 0, 0
		.db 71h, 7Eh, 73h, 6Dh, 69h, 74h, 78h, 62h, 60h, 2Ch, 2Fh, 7Fh, 0, 0, 0, 0
		.db 66h, 79h, 77h, 61h, 70h, 72h, 6Fh, 6Ch, 64h, 76h, 7Ch, 2Eh, 0, 0, 0, 0
		.db 6Ah, 63h, 75h, 6Bh, 65h, 6Eh, 67h, 7Bh, 7Dh, 7Ah, 68h, 3Ah, 0, 0, 0, 0
		.db 3Bh, 31h, 32h, 33h, 34h, 35h, 36h, 37h, 38h, 39h, 30h, 2Dh, 0, 0, 0, 0
		.db 00h, 01h, 02h, 03h, 04h, 05h, 06h, 07h, 8Ah, 8Bh, 8Ch, 1Fh, 0, 0, 0, 0

.include "printer.inc"
.include "printString.inc"
.include "reboot2.inc"
.include "getch3.inc"
.include "printChar2.inc"	; �த�������� � scrollDown
.include "scrollDown.inc"
.include "scrollUp2.inc"

; �� �ᯮ������

		.db 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh
		.db 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh
		.db 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh
		.db 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh
		.db 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh
		.db 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh
		.db 0FFh

.org 0C800h

.include "jmps_c800.inc"
.include "setGetCursorPos.inc"
.include "setGetMemTop.inc"
.include "printHex.inc"
.include "input.inc"
.include "cmp_hl_de_2.inc"
.include "sbb_de_hl_to_hl.inc"
.include "memmove_bc_hl.inc"
.include "calcCS.inc"
.include "tapeSave.inc"
.include "tapeWriteWord.inc"
.include "tapeLoad.inc"
.include "reboot3.inc"
.include "fileExecBat.inc"
.include "fileExec.inc"
.include "fileCmpExt.inc"
.include "driver_FFC0.inc"
.include "driver.inc"
.include "installDriver.inc"
.include "fileGetSetDrive.inc"
.include "loadSaveFatDir.inc"
.include "fileFindCluster.inc"
.include "fileCreate.inc"
.include "fileFind.inc"
.include "fileLoad.inc"
.include "fileDelete.inc"
.include "fileRename.inc"
.include "fileGetSetAttr.inc"
.include "fileGetSetAddr.inc"
.include "fileGetInfoAddr.inc"
.include "fileList.inc"
.include "fileNamePrepare.inc"
.include "memset_de_20_b.inc"

; ---------------------------------------------------------------------------

aBadCommandOrFi:.db 0Ah
		.text "BAD COMMAND OR FILE NAME"
		.db 0
v_drives:	.dw diskDriver, diskDriver, diskDriver, diskDriver
		.dw diskDriver, diskDriver, diskDriver, diskDriver
v_findCluster:	.dw 0
v_drive:	.db 1
v_input_start:	.dw 0
v_createdFile:	.dw 0
v_foundedFile:	.dw 0
v_input_end:	.dw 0
v_batPtr:	.dw 0
v_memTop:	.dw 0FAFFh
aANc_com:	.text "A:NC.COM"
		.db 0Dh
aBAutoex_bat:	.text "B:AUTOEX.BAT"
		.db 0Dh
aBat:		.text "BAT"
aCom:		.text "COM"
aExe:		.text "EXE"
v_fileName:	.db 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh

v_fileName_ext:	.db 0FFh, 0FFh, 0FFh
		.db 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh
v_fileName_end:	.db 0FFh ; ����஢���� �ந�室�� ������ ��� ���ᯮ��㥬� ����

v_batFileName:	.db 0FFh, 0FFh,	0FFh
		.db 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh
v_batFileN_end:	.db 0FFh ; ����஢���� �ந�室�� ������ ��� ���ᯮ��㥬� ����

#if LOAD_FONT
.include "font.inc"
#else
notused:	.db 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh
		.db 0FFh, 0FFh,	0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh
		.db 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh
		.db 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh
		.db 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh
		.db 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh
		.db 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh
#endif
.end