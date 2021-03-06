.INCLUDE "dat.inc"

.SECTION "CODE"
fatal:	jmp sdfatal
main:
--	jsr consinit
	rep #$30
	ldx #title
	jsr puts
	jsr box
	sep #$20
	lda #NOCARD
	bit SDSTAT
	beq ++
	ldx #nocard
	jsr puts
	lda #NOCARD
-	bit SDSTAT
	bne -
	jsr box
	bra +
++	lda #RESETCMD
	sta SDCMD
+	ldx #busystr
	jsr puts
	rep #$20
	jsr busy
	jsr sramflush
	jsr sramdis
	jsr sramflush
	jsr mbr
	jsr initfat
	jsr endbox
	jsr redraw

poll	rep #$30
	wai
-	bit cardsw-1
	bmi --
	lda btn
	beq -
	pea poll-1
	bit #BTNUP
	bne _up
	bit #BTNDOWN
	bne _down
	bit #BTNA
	bne loadgame
	bit #BTNB
	beq +
	jmp parent
+	lda $4218
	and #BTNFLASH
	eor #BTNFLASH
	bne +
	jmp flash
+	rts
_up	ldy sel
	jsr prevshown
	sty sel
	cpy #0
	bpl +
	tya
	clc
	adc scrtop
	sta scrtop
	stz sel
+	jmp redraw
_down	ldy sel
	jsr nextshown
	sty sel
	cpy scrbot
	bcc +
	beq +
	ldy #0
	jsr nextshown
	tya
	sta tmp
	clc
	adc scrtop
	sta scrtop
	lda sel
	sec
	sbc tmp
	sta sel
+	jmp redraw

loadgame:
	rep #$30
	jsr box
	ldx #busystr
	jsr puts
	sep #$20
	stz gamectl
	jsr readheader
	bcs +
	sep #$20
	lda HEAD+$1D5
	and #$EF
	cmp #$20
	beq ++
	lda #HIROM
	sta gamectl
	jsr readheader
	bcs +
	sep #$20
	lda HEAD+$1D5
	and #$EF
	cmp #$21
	beq ++
	rep #$30
	jsr box
-	ldx #_hdmsg
	jsr puts
	jmp confirm
+	rts
++	rep #$30
	jsr box
	ldx #(HEAD+$1C0)&$FFFF
	ldy #buf
	lda #20
	mvn $00, HEAD>>16
	lda #$000A
	sta buf+21
	ldx #buf
	jsr puts
	jsr romregion
	jsr parseheader
	bcc +
	jmp confirm
+	jsr waitkey
	bcc +
	rts
+	and #BTNA
	bne +
	jmp endbox
+	jsr box
	ldx #busystr
	jsr puts
	lda #SAVERAM
	bit gamectl
	beq +
	lda rammask
	beq +
	jsr loadsave
	bcc +
	lda #SAVERAM
	trb gamectl
	lda #BTNA
	bit key
	bne +
	jmp endbox
+	jsr readrom
	bcc +
	jsr endbox
	rts
+	jsr endbox

	rep #$30
	ldx #gamestart
	ldy #buf
	lda #gameend-gamestart
	mvn $00, $00

	sep #$20
	stz $4200
	stz $420c
	lda $4210
	
	lda #SAVERAM
	bit gamectl
	beq +
	rep #$20
	lda #MAGIC
	sta LOCK
	sep #$20
	lda dmactrl
	ora #SAVERAM
	sta DMACTRL
	rep #$20
	stz LOCK

+	rep #$20
	lda rommask
	sta ROMMASK
	lda rammask
	sta RAMMASK
	jmp buf

romregion:
	php
	sep #$20
	rep #$10
	lda HEAD+$1D9
	cmp #$E
	bcc +
	ldx #_unk
-	jsr puts
	plp
	rts
+	cmp #$D
	beq +
	cmp #$2
	bcc +
	ldx #_pal
	bra -
+	ldx #_ntsc
	bra -
_unk:	.ASC "???", 10, 0
_pal:	.ASC "PAL", 10, 0
_ntsc:	.ASC "NTSC", 10, 0

mask:
	php
	rep #$30
	and #$FF
	beq +
	tax
	lda #$4
-	asl
	dex
	bne -
	dea
+	plp
	rts
	
parseheader:
	php
	rep #$30
	lda HEAD+$1D7
	and #$FF
	bne ++
	ldx #_hdmsg
	jsr puts
	bra +
++	cmp #ROMMAX+1
	bcc ++
	ldx #_roml
	jsr puts
	bra +
++	jsr mask
	sta rommask
	lda HEAD+$1D8
	jsr mask
	cmp #NSRAM*2
	bcc ++
	ldx #_raml
	jsr puts
	bra +
++	sta rammask
	sep #$20
	lda HEAD+$1D6
	cmp #$3
	bcs +
	cmp #$2
	bne ++
	lda #SAVERAM
	tsb gamectl 
++	lda #ROMDIS
	tsb gamectl
	plp
	clc
	rts
+	plp
	sec
	rts

waitkey:
	php
	rep #$20
	wai
	lda #(BTNA|BTNB)
-	bit cardsw-1
	bmi +
	bit btn
	beq -
	lda btn
	sta key
	wai
	plp
	clc
	rts
+	stz key
	plp
	sec
	rts
	
	
confirm:
	jsr waitkey
	jsr endbox
	sec
	rts

loadsave:
	jsr filename
	jsr modname
	jsr openfile
	bcc +
	jsr createfile
+	jsr checkclust
	bcs +
	jsr readin
	bcs +
	clc
	rts
+	sec
	rts
	
gamestart:
	sep #$30
	lda gamectl
	sta DMACTRL
	sec
	xce
	jmp ($FFFC)
gameend:

title: .ASC 10, " SNES FLASH CART", 0
busystr: .ASC "BUSY", 10, 0
_hdmsg: .ASC 10, "INVALID HEADER", 0
_roml: .ASC 10, "GAME REQUIRES", 10, "TOO MUCH ROM", 0
_raml: .ASC 10, "GAME REQUIRES", 10, "TOO MUCH SRAM", 0
.ENDS
