; =============================================================================
; ATARI 8-BIT OS EQUATES AND MEMORY MAP
; =============================================================================
; System equates for Rachel Atari 8-bit client
; MADS assembler syntax

; =============================================================================
; ZERO PAGE VARIABLES ($00-$FF)
; =============================================================================

; Temporary registers
ZP_TEMP1        = $80
ZP_TEMP2        = $81
ZP_TEMP3        = $82
ZP_TEMP4        = $83

; Pointers
ZP_PTR1         = $84           ; $84-$85
ZP_PTR2         = $86           ; $86-$87
ZP_PTR3         = $88           ; $88-$89

; Protocol state
ZP_PLAYER_ID    = $90           ; $90-$91 (16-bit big-endian)
ZP_GAME_ID      = $92           ; $92-$93
ZP_SEQUENCE     = $94           ; $94-$95
ZP_MY_INDEX     = $96
ZP_CURRENT_TURN = $97

; Hand state
ZP_HAND_COUNT   = $98
ZP_CURSOR_POS   = $99
ZP_SELECTED_LO  = $9A
ZP_SELECTED_HI  = $9B

; Network state
ZP_NET_CHANNEL  = $9C           ; CIO channel number (1)
ZP_NET_STATUS   = $9D
ZP_RECV_COUNT   = $9E
ZP_SEND_COUNT   = $9F

; Connection state
ZP_CONN_STATE   = $A0

; Connection states
CONN_DISCONNECTED = 0
CONN_DIALING      = 1
CONN_HANDSHAKE    = 2
CONN_WAITING      = 3
CONN_PLAYING      = 4

; =============================================================================
; APPLICATION BUFFERS
; =============================================================================

; These labels are allocated inside the XEX in main.asm.  Do not place them in
; page 3: $0340-$03BF is the Atari OS IOCB table used by CIO/FujiNet.
CONN_STATE      = VAR_BASE
SEQUENCE_LO     = VAR_BASE+1
SEQUENCE_HI     = VAR_BASE+2
PLAYER_ID_LO    = VAR_BASE+3
PLAYER_ID_HI    = VAR_BASE+4
GAME_ID_LO      = VAR_BASE+5
GAME_ID_HI      = VAR_BASE+6
MY_INDEX        = VAR_BASE+7
CURRENT_TURN    = VAR_BASE+8
DIRECTION       = VAR_BASE+9
DISCARD_TOP     = VAR_BASE+10
NOMINATED_SUIT  = VAR_BASE+11
PENDING_DRAWS   = VAR_BASE+12
PENDING_SKIPS   = VAR_BASE+13
DECK_COUNT      = VAR_BASE+14
HAND_COUNT      = VAR_BASE+15
CURSOR_POS      = VAR_BASE+16
SELECTED_LO     = VAR_BASE+17
SELECTED_HI     = VAR_BASE+18
PLAYER_COUNT    = VAR_BASE+19

; =============================================================================
; RUBP PROTOCOL CONSTANTS
; =============================================================================

MSG_SIZE        = 64

; Magic bytes
MAGIC_0         = 'R'
MAGIC_1         = 'A'
MAGIC_2         = 'C'
MAGIC_3         = 'H'

; Protocol version
PROTOCOL_VER    = $01
RACHEL_SPEC_VER = $01

; Message types
MSG_HELLO       = $01
MSG_WELCOME     = $02
MSG_GAME_START  = $03
MSG_PLAY_CARD   = $04
MSG_DRAW_CARD   = $05
MSG_CARD_DRAWN  = $06
MSG_GAME_STATE  = $07
MSG_TURN_START  = $08
MSG_TURN_END    = $09
MSG_PLAYER_WON  = $0A
MSG_ERROR       = $0B
MSG_PLAYER_LIST = $0C
MSG_ANNOUNCE    = $0D
MSG_PLAYER_NAME = $0E
MSG_HAND_SYNC   = $0F
MSG_SYNC_REQUEST= $10

; Header offsets
HDR_MAGIC       = 0
HDR_VERSION     = 4
HDR_TYPE        = 5
HDR_SEQ         = 6
HDR_PLAYER_ID   = 8
HDR_GAME_ID     = 10
HDR_TIMESTAMP   = 12
HDR_SIZE        = 16

; Payload
PAYLOAD_START   = 16
PAYLOAD_SIZE    = 48

; Card suits
SUIT_HEARTS     = 0
SUIT_DIAMONDS   = 1
SUIT_CLUBS      = 2
SUIT_SPADES     = 3

; =============================================================================
; ATARI OS EQUATES
; =============================================================================

; CIO Vector
CIOV            = $E456
SIOV            = $E459

; Device Control Block used by the Atari OS SIO vector
DCB             = $0300
DDEVIC          = DCB
DUNIT           = DCB+1
DCOMND          = DCB+2
DSTATS          = DCB+3
DBUFL           = DCB+4
DBUFH           = DCB+5
DTIMLO          = DCB+6
DBYTL           = DCB+8
DBYTH           = DCB+9
DAUXL           = DCB+10
DAUXH           = DCB+11
DVSTAT          = $02EA

; FujiNet Atari SIO network device
FUJINET_NDEV    = $71
SIO_READ        = $40
SIO_WRITE       = $80
SIO_OK          = 1

; IOCB (Input/Output Control Block) base addresses
IOCB0           = $0340         ; E: device (screen)
IOCB1           = $0350         ; N: device (FujiNet)
IOCB2           = $0360
IOCB3           = $0370
IOCB4           = $0380
IOCB5           = $0390
IOCB6           = $03A0
IOCB7           = $03B0

; IOCB offsets
ICHID           = $00           ; Handler ID
ICDNO           = $01           ; Device number
ICCOM           = $02           ; Command
ICSTA           = $03           ; Status
ICBAL           = $04           ; Buffer address low
ICBAH           = $05           ; Buffer address high
ICPTL           = $06           ; Put routine address low
ICPTH           = $07           ; Put routine address high
ICBLL           = $08           ; Buffer length low
ICBLH           = $09           ; Buffer length high
ICAX1           = $0A           ; Auxiliary 1
ICAX2           = $0B           ; Auxiliary 2
ICAX3           = $0C
ICAX4           = $0D
ICAX5           = $0E
ICAX6           = $0F

; CIO Commands
CIO_OPEN        = $03
CIO_GETREC      = $05           ; Get record (text line)
CIO_GETCHR      = $07           ; Get characters
CIO_PUTREC      = $09           ; Put record (text line)
CIO_PUTCHR      = $0B           ; Put characters
CIO_CLOSE       = $0C
CIO_STATUS      = $0D

; IOCB AUX values for OPEN
AUX_READ        = $04
AUX_WRITE       = $08
AUX_READWRITE   = $0C

; Keyboard
CH              = $02FC         ; Last key pressed ($FF = none)
KBCODE          = $D209         ; POKEY keyboard code

; Screen memory
SAVMSC          = $58           ; Screen memory pointer ($58-$59)

; Colors
COLOR0          = $02C4         ; Background
COLOR1          = $02C5         ; Playfield 1
COLOR2          = $02C6         ; Playfield 2
COLOR3          = $02C7         ; Playfield 3
COLOR4          = $02C8         ; Border

; Hardware
POKEY           = $D200
GTIA            = $D000
ANTIC           = $D400

; POKEY registers
AUDF1           = $D200
AUDC1           = $D201
AUDCTL          = $D208
RANDOM          = $D20A
SKSTAT          = $D20F
SKCTL           = $D20F

; GTIA registers
CONSOL          = $D01F

; ANTIC registers
DMACTL          = $D400
CHACTL          = $D401
DLISTL          = $D402
DLISTH          = $D403
VCOUNT          = $D40B
NMIEN           = $D40E
NMIST           = $D40F

; System vectors
VVBLKI          = $0222         ; VBI immediate
VVBLKD          = $0224         ; VBI deferred

; ATASCII Characters
ATASCII_CLEAR   = $7D           ; Clear screen
ATASCII_BELL    = $FD           ; Bell
ATASCII_EOL     = $9B           ; End of line
ATASCII_BKSP    = $7E           ; Backspace
ATASCII_TAB     = $7F           ; Tab
ATASCII_ESC     = $1B           ; Escape

; Key codes
KEY_RETURN      = $9B
KEY_ESC         = $1C
KEY_SPACE       = $21
KEY_NOKEY       = $FF

; Screen dimensions
SCREEN_WIDTH    = 40
SCREEN_HEIGHT   = 24
