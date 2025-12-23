; =============================================================================
; ATARI 8-BIT DISPLAY MODULE
; =============================================================================

; -----------------------------------------------------------------------------
; Initialize display (GR.0 text mode)
; -----------------------------------------------------------------------------
display_init
        lda #ATASCII_CLEAR
        jsr print_char

        lda #$00
        sta COLOR4
        sta COLOR2
        lda #$0E
        sta COLOR1

        rts

; -----------------------------------------------------------------------------
; Set cursor position
; Input: X = column (0-39), Y = row (0-23)
; -----------------------------------------------------------------------------
set_cursor
        stx ZP_TEMP1
        sty ZP_TEMP2

        ; row * 40 = row * 32 + row * 8
        tya
        asl
        asl
        asl
        sta ZP_TEMP3

        tya
        asl
        asl
        asl
        asl
        asl
        clc
        adc ZP_TEMP3
        sta ZP_PTR1

        lda #0
        adc #0
        sta ZP_PTR1+1

        lda ZP_PTR1
        clc
        adc ZP_TEMP1
        sta ZP_PTR1
        lda ZP_PTR1+1
        adc #0
        sta ZP_PTR1+1

        lda ZP_PTR1
        clc
        adc SAVMSC
        sta ZP_PTR1
        lda ZP_PTR1+1
        adc SAVMSC+1
        sta ZP_PTR1+1

        lda ZP_PTR1
        sta CURSOR_ADDR
        lda ZP_PTR1+1
        sta CURSOR_ADDR+1

        rts

CURSOR_ADDR     dta a(0)

; -----------------------------------------------------------------------------
; Print single character via CIO E: device
; -----------------------------------------------------------------------------
print_char
        pha
        ldx #$00
        pla
        sta pc_buf

        lda #<pc_buf
        sta ICBAL,x
        lda #>pc_buf
        sta ICBAH,x

        lda #1
        sta ICBLL,x
        lda #0
        sta ICBLH,x

        lda #CIO_PUTCHR
        sta ICCOM,x

        jsr CIOV
        rts

pc_buf  dta 0

; -----------------------------------------------------------------------------
; Print null-terminated string
; Input: ZP_PTR1 = pointer to string
; -----------------------------------------------------------------------------
print_string
        ldy #0
ps_lp
        lda (ZP_PTR1),y
        beq ps_dn
        jsr print_char
        iny
        bne ps_lp
ps_dn
        rts

; -----------------------------------------------------------------------------
; Print decimal number (0-255)
; -----------------------------------------------------------------------------
print_number
        sta ZP_TEMP4
        lda #0
        sta ZP_TEMP3

        lda ZP_TEMP4
        ldx #0
pn_hnd
        cmp #100
        bcc pn_tns
        sbc #100
        inx
        bne pn_hnd

pn_tns
        sta ZP_TEMP4
        txa
        beq pn_skh
        ora #'0'
        jsr print_char
        inc ZP_TEMP3

pn_skh
        lda ZP_TEMP4
        ldx #0
pn_tnl
        cmp #10
        bcc pn_unt
        sbc #10
        inx
        bne pn_tnl

pn_unt
        sta ZP_TEMP4
        txa
        bne pn_prt
        lda ZP_TEMP3
        beq pn_skt

pn_prt
        txa
        ora #'0'
        jsr print_char

pn_skt
        lda ZP_TEMP4
        ora #'0'
        jsr print_char
        rts

; -----------------------------------------------------------------------------
; Clear a screen row
; -----------------------------------------------------------------------------
clear_row
        ldx #0
        jsr set_cursor
        ldx #40
cr_lp
        lda #' '
        jsr print_char
        dex
        bne cr_lp
        rts

; -----------------------------------------------------------------------------
; Draw horizontal border line
; -----------------------------------------------------------------------------
draw_border
        ldx #0
        jsr set_cursor
        ldx #40
db_lp
        lda #'-'
        jsr print_char
        dex
        bne db_lp
        rts

; =============================================================================
; CARD SUIT DISPLAY
; =============================================================================

CHAR_HEART      = 'H'
CHAR_DIAMOND    = 'D'
CHAR_CLUB       = 'C'
CHAR_SPADE      = 'S'

print_suit
        and #3
        tax
        lda suit_chars,x
        jsr print_char
        rts

suit_chars
        dta CHAR_HEART, CHAR_DIAMOND, CHAR_CLUB, CHAR_SPADE

print_rank
        cmp #10
        bcc pr_num

        cmp #10
        beq pr_ten
        cmp #11
        beq pr_jack
        cmp #12
        beq pr_qn
        cmp #13
        beq pr_kg
        lda #'A'
        jmp pr_out

pr_ten
        lda #'1'
        jsr print_char
        lda #'0'
        jmp pr_out

pr_num
        ora #'0'
pr_out
        jsr print_char
        rts

pr_jack
        lda #'J'
        jmp pr_out
pr_qn
        lda #'Q'
        jmp pr_out
pr_kg
        lda #'K'
        jmp pr_out

print_card
        pha
        and #$0F
        jsr print_rank
        pla
        lsr
        lsr
        lsr
        lsr
        and #$03
        jsr print_suit
        lda #' '
        jsr print_char
        rts
