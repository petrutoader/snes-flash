.MEMORYMAP
SLOTSIZE $8000
DEFAULTSLOT 0
SLOT 0 $8000
.ENDME

.ROMBANKSIZE $8000
.ROMBANKS 1
.LOROM

.SNESHEADER
NAME "FLASH CART"
ROMSIZE $05
.ENDSNES

.ENUM $0
inf	DS 2
tmp	DS 2
tmp2	DS 2
ptr	DS 3
dmactrl	DB

pos	DS 3
attrib	DB
window	DB

sdaddr	DS 2
sdblk	DS 4
partoff	DS 4

clsiz	DB
clsh	DB
dir	DS 4
clust	DS 4
cloff	DS 4
eof	DB

dirend	DS 3
dpend	DS 3
dent	DS 3

scrtop	DS 3
sel	DS 2

btn	DS 2
bmask	DS 2

smch	DS 1
gamectl	DS 1

buf	DS 256
.ENDE

.EQU PICSIZ 1920
.EQU BOXL 4
.EQU BOXT 4
.EQU BOXW 20
.EQU BOXH 10
.EQU BOX BOXL | (BOXT << 8)
.EQU NAMES $0303

.EQU REGLOC 2*64 - 10

.EQU DIRMAX 2048
.EQU NAMEMAX 256
.EQU DISPLEN 24
.EQU DISPNUM 10

.ENUM $7F0000
pic	DS PICSIZ
picbak	DS PICSIZ
dirp	DS DIRMAX*3+3
.ENDE

.EQU SDSTAT $3000
.EQU SDCMD $3000
.EQU RESETCMD 0
.EQU READCMD 1
.EQU SDRESP $3001
.EQU SDBLK $3001
.EQU MEMMODE 1
.EQU ROMDIS 2
.EQU HIROM 4
.EQU DMACTRL $3010
.EQU DMAADDR $3011
.EQU ROMMASK $3013

.EQU BREC $FF0000
.EQU FAT $FF0200
.EQU DIR $400000
.EQU HEAD $FF0400
.EQU ROMOFF $400000

.MACRO LDADDR
	lda #((\1>>9)&$4000)|((\1>>8)&$3FFF)
.ENDM

.EQU BTNB $8000
.EQU BTNA $0080
.EQU BTNUP $0800
.EQU BTNDOWN $0400