#include "music.h"

struct MusicChannel musicChannels[3];

//----------------------------------------------------------------------------
// ������������� ������

void musicStart() {
  asm {

MUSIC_SPEED = 5
MUSIC_NOTE_LENGTH = 6
PLUMK_SPEED = 400h


	lxi h, music
	shld musicptr
	lxi h, musicChannels
	xra a
	mov m, a
	inx h
	mov m, a
	inx h
	mov m, a
	inx h
	mov m, a
	inx h
	mov m, a
	inx h
	mov m, a
  }
}

//----------------------------------------------------------------------------
// ������ ������

void musicTick() {
  asm {
	push b
	; ��������� ���� � ������
	mvi e, 0
	lxi h, musicChannels
	call processChannel
                mvi e, 1
	lxi h, musicChannels+4
	call processChannel
                mvi e, 2
	lxi h, musicChannels+8
	call processChannel	

	; �������� ���� ����� �������� �������� �������
	lxi h, 0EC03h
	lxi d, musicChannels+1
	mvi b, 3Eh
	call muteChannel
	mvi b, 40h|3Eh
	call muteChannel
	mvi b, 80h|3Eh
	call muteChannel

	; �������� ����� ��������� ��������� ���
                mvi a, MUSIC_SPEED
melodyDelay:	push psw

	; ������ ���������
plumkLoop:
	; �������� ������ �� ������ ������
	call plumkTick
	lxi h, musicChannels+1 ; +5 +9
	lxi d, 0EC00h ; +1 +2
	call plumkChannel

	; ������� ���������
	lxi h, PLUMK_SPEED
plumkDelay:
	dcx h
	mov a, h
	ora l
	jnz plumkDelay
	
	; ��������� ���������, ���� �� ���
	lda 0EF01h
	ani 20h
	jz plumkLoop

	; �������� ����� ��������� ��������� ���
	pop psw
	dcr a
	jnz melodyDelay

	pop b
	ret

;------------------------------------------------------------------

muteChannel:
	ldax d
	ora a
	jz muteChannel_2
	dcr a
	jnz muteChannel_1
	mov m, b
muteChannel_1:
	stax d
muteChannel_2:
	inx d
	inx d
	inx d
	inx d
	ret

;------------------------------------------------------------------

plumkTick:	lda plumk
	inr a
	ani 3
	sta plumk
	cpi 2
	jc plumkTick_1
	mvi a, 1
plumkTick_1:	ret

;------------------------------------------------------------------
; HL - ��������� �� musicChannels+1
; DE - ����� �������
	
plumkChannel:   ; ����� ������?
	mov b, m
	inr b
	dcr b
	rz

	; �������
	inx h
	mov c, m
	inx h
	mov b, m

	mov h, a
                inr h
plumkChannel_2:	; �������� ������ �� A
	dcr h
	jz plumkChannel_3
	sub a
	mov a, b	
	rar
	mov b, a
	mov a, c
	rar
	mov c, a
	jmp plumkChannel_2

plumkChannel_3:	; ��������� � ������
	xchg
	mov m, c
	mov m, b
	ret

;------------------------------------------------------------------
; hl - ��������� �� musicChannels
; e - �����

processChannel:	; ����� ����� ��������� ��������� ����
	mov a, m
	ora a
	jnz channelWait

                ; ������ ���� � ������� � A
	push h
	lhld musicptr
	mov a, m
	pop h
	cpi 0FFh
	rz
	push h
	lhld musicptr
	inx h
	shld musicptr
	pop h

	; �������� ��������
	mov d, a	
	rlc
	rlc
	rlc
	ani 7

	; ��������� ��������
	mov m, a	

	; �������� ����
	mov a, d
	ani 01Fh

	; ��� ����, �������
	rz

	; �������� ������� ����
	push h
	mov l, a
	mvi h, 0
	dad h
	lxi b, notes
	dad b
	mov c, m
	inx h
	mov b, m
	pop h
	
	; ���������� ������������ ����
	mvi a, MUSIC_NOTE_LENGTH
      	inx h
	mov m, a

	; ����� ������ ��� ������� ������
;	push h
;	mvi h, 0
;	mov l, e
;	dad h
;	dad h
;	dad b
;	mov b, h
;	mov c, l
;	pop h

	; ������ �������
      	inx h
	mov m, c
      	inx h
	mov m, b

	; ���������������� �������
	mov l, e
	mvi h, 0ECh
	mov m, c
	mov m, b

	ret
	
;------------------------------------------------------------------

channelWait:	dcr m
	ret

;------------------------------------------------------------------

musicptr:	.dw music
plumk:          .db 0

;------------------------------------------------------------------

notes:	
.include "music/music_notes.inc";

music:
.include "music/music_data.inc"

  }
}

void musicStop() {
  *(uchar*)0xEC03 = 0x3E;
  *(uchar*)0xEC03 = 0x3E|0x40;
  *(uchar*)0xEC03 = 0x3E|0x80;
}