;+---------------------------------------------------------------------------
; MXOS
; ������� �������� ���
;
; ��� �������� �����������
;
; 2013-12-12 ����������������� vinxru
;----------------------------------------------------------------------------

LETTER = 'H'	; ����� ��� ����������
ROM_SIZE = 0C0h	; ������������ ������ ��� = 48 ��

IO_KEYB_MODE	= 0FFE3h
IO_EXT_A	= 0FFE4h
IO_EXT_B	= 0FFE5h
IO_EXT_C	= 0FFE6h
IO_EXT_MODE	= 0FFE7h

sys_installDriver = 0C860h
sys_fileGetSetDrive = 0C842h

.org 0FA00h

start:		; ���������� �������
		mvi     a, LETTER-'A'
                lxi     h, driver
                jmp     sys_installDriver

; ---------------------------------------------------------------------------

		; ������� �������� ���� H (���� ��� �� ������������)
                mvi     e, 1
                mvi     a, 7
                jmp     sys_fileGetSetDrive

; ---------------------------------------------------------------------------

driver:		; ������ �� ��������������
                mov     a, e
                cpi     1
                rz

		; ��������� ��������
                push    h
                push    d
                push    b

		; ��������� ������
                mvi     a, 90h
                sta     IO_EXT_MODE

		; 6 ����� = 1
                mvi     a, 0Dh
                sta     IO_KEYB_MODE

		; ����������� �������
                mov     a, e
                cpi     3
                jz      fn3

		; ����������� �������
                cpi     2
                jnz     exit

		; ������ ����
                xra     a
                mov     e, a
readLoop:	call    read
                mov     m, a
                inx     h
                inr     e
                jz      exit
                jmp     readLoop

; ---------------------------------------------------------------------------
; ����������� ������ ���

fn3:            ; ������� ����� � FAT, ��� ����� �� ����� 0FFh
		xra     a
                mov     b, a
                mov     d, a
                mvi     e, 4
loc_FA3E:       call    read
                cpi     0FFh
                jnz     loc_FA47
                inr     b
loc_FA47:       inr     e
                mov     a, e
                cpi     ROM_SIZE
                jnz     loc_FA3E

		; � ����� ����� ��� ���������� ROM_SIZE-0FFh
                mvi     a, ROM_SIZE
                sub     b

exit:		push    psw

		; 6 ����� = 0
                mvi     a, 0Ch
                sta     IO_KEYB_MODE

                ; �������������� ������ ������
                mvi     a, 9Bh
                sta     IO_EXT_MODE

                pop     psw

		; �������������� ���������
                pop     b
                pop     d
                pop     h
                ret

; ---------------------------------------------------------------------------

read:		xchg
                shld    IO_EXT_B
                lda     IO_EXT_A
                xchg
                ret

.end