; =============================================================================
; GAME MODULE - Atari 8-bit
; =============================================================================

; -----------------------------------------------------------------------------
; Draw the complete game screen
; -----------------------------------------------------------------------------
draw_game_screen
        jsr display_init

        ldx #14
        ldy #0
        jsr set_cursor
        lda #<gm_title
        sta ZP_PTR1
        lda #>gm_title
        sta ZP_PTR1+1
        jsr print_string

        ldy #1
        jsr draw_border
        ldy #4
        jsr draw_border
        ldy #10
        jsr draw_border
        ldy #18
        jsr draw_border
        ldy #20
        jsr draw_border

        ldx #1
        ldy #11
        jsr set_cursor
        lda #<gm_hand
        sta ZP_PTR1
        lda #>gm_hand
        sta ZP_PTR1+1
        jsr print_string

        ldx #1
        ldy #19
        jsr set_cursor
        lda #<gm_ctrl
        sta ZP_PTR1
        lda #>gm_ctrl
        sta ZP_PTR1+1
        jsr print_string

        rts

gm_title
        dta c'RACHEL V1.0',0
gm_hand
        dta c'YOUR HAND:',0
gm_ctrl
        dta c'<-> MOVE  SPC SELECT  RET PLAY  D DRAW',0

; -----------------------------------------------------------------------------
; Full game redraw
; -----------------------------------------------------------------------------
redraw_game
        jsr draw_players
        jsr draw_discard
        jsr draw_hand
        jsr draw_turn_indicator
        rts

; =============================================================================
; PLAYER LIST
; =============================================================================

draw_players
        ldx #0
        ldy #2
        jsr set_cursor

        lda #0
dp_l1
        sta dp_idx
        jsr draw_one_player
        lda dp_idx
        clc
        adc #1
        cmp #4
        bcc dp_l1

        ldx #0
        ldy #3
        jsr set_cursor

        lda #4
dp_l2
        sta dp_idx
        jsr draw_one_player
        lda dp_idx
        clc
        adc #1
        cmp #8
        bcc dp_l2

        rts

dp_idx  dta 0

draw_one_player
        lda #'P'
        jsr print_char
        lda dp_idx
        clc
        adc #'1'
        jsr print_char
        lda #':'
        jsr print_char

        ldx dp_idx
        lda PLAYER_COUNTS,x
        jsr print_number_2d

        lda #' '
        jsr print_char
        lda #' '
        jsr print_char

        rts

print_number_2d
        sta ZP_TEMP4
        ldx #0
pn2d_t
        cmp #10
        bcc pn2d_p
        sbc #10
        inx
        bne pn2d_t

pn2d_p
        sta ZP_TEMP4
        txa
        ora #'0'
        jsr print_char
        lda ZP_TEMP4
        ora #'0'
        jsr print_char
        rts

; =============================================================================
; DISCARD PILE
; =============================================================================

draw_discard
        ldx #14
        ldy #6
        jsr set_cursor
        lda #<dd_lbl
        sta ZP_PTR1
        lda #>dd_lbl
        sta ZP_PTR1+1
        jsr print_string

        ldx #16
        ldy #7
        jsr set_cursor

        lda DISCARD_TOP
        beq dd_emp
        jsr print_card
        jmp dd_st

dd_emp
        lda #<dd_mt
        sta ZP_PTR1
        lda #>dd_mt
        sta ZP_PTR1+1
        jsr print_string
        rts

dd_st
        lda NOMINATED_SUIT
        cmp #$FF
        beq dd_dn

        ldx #14
        ldy #8
        jsr set_cursor
        lda #<dd_st_lbl
        sta ZP_PTR1
        lda #>dd_st_lbl
        sta ZP_PTR1+1
        jsr print_string

        lda NOMINATED_SUIT
        jsr print_suit_name

dd_dn
        rts

dd_lbl
        dta c'DISCARD:',0
dd_mt
        dta c'[EMPTY]',0
dd_st_lbl
        dta c'SUIT: ',0

print_suit_name
        and #3
        asl
        tax
        lda sn_ptrs,x
        sta ZP_PTR1
        lda sn_ptrs+1,x
        sta ZP_PTR1+1
        jsr print_string
        rts

sn_ptrs
        dta a(sn_h), a(sn_d), a(sn_c), a(sn_s)

sn_h    dta c'HEARTS',0
sn_d    dta c'DIAMONDS',0
sn_c    dta c'CLUBS',0
sn_s    dta c'SPADES',0

; =============================================================================
; HAND DISPLAY
; =============================================================================

draw_hand
        lda HAND_COUNT
        bne dh_has

        ldx #1
        ldy #12
        jsr set_cursor
        lda #<dh_no
        sta ZP_PTR1
        lda #>dh_no
        sta ZP_PTR1+1
        jsr print_string
        rts

dh_has
        ldx #1
        ldy #12
        jsr set_cursor

        lda #0
        sta dh_pos
        sta dh_col

dh_lp
        lda dh_pos
        jsr check_selected
        beq dh_nsel

        lda #'['
        jsr print_char
        jmp dh_crd

dh_nsel
        lda dh_pos
        cmp CURSOR_POS
        bne dh_ncur

        lda #'>'
        jsr print_char
        jmp dh_crd

dh_ncur
        lda #' '
        jsr print_char

dh_crd
        ldx dh_pos
        lda MY_HAND,x
        jsr print_card

        lda dh_pos
        jsr check_selected
        beq dh_ncls
        lda #']'
        jsr print_char
        jmp dh_spc
dh_ncls
        lda #' '
        jsr print_char

dh_spc
        inc dh_pos
        inc dh_col

        lda dh_col
        cmp #6
        bne dh_nonl

        lda #0
        sta dh_col

        lda dh_pos
        lsr
        lsr
        clc
        adc #12
        tay
        ldx #1
        jsr set_cursor

dh_nonl
        lda dh_pos
        cmp HAND_COUNT
        bcc dh_lp

        rts

dh_pos  dta 0
dh_col  dta 0

dh_no
        dta c'(NO CARDS)',0

; -----------------------------------------------------------------------------
; Check if card at position is selected
; Input: A = position
; Returns: Z flag clear if selected
; -----------------------------------------------------------------------------
check_selected
        cmp #8
        bcs cks_hi

        tax
        lda SELECTED_LO
        jmp cks_sh

cks_hi
        sec
        sbc #8
        tax
        lda SELECTED_HI

cks_sh
        cpx #0
        beq cks_ts
cks_sl
        lsr
        dex
        bne cks_sl

cks_ts
        and #1
        rts

; =============================================================================
; TURN INDICATOR
; =============================================================================

draw_turn_indicator
        ldy #21
        jsr clear_row

        ldx #1
        ldy #21
        jsr set_cursor

        lda CURRENT_TURN
        cmp MY_INDEX
        bne dti_oth

        lda #<dti_yr
        sta ZP_PTR1
        lda #>dti_yr
        sta ZP_PTR1+1
        jsr print_string
        rts

dti_oth
        lda #<dti_pl
        sta ZP_PTR1
        lda #>dti_pl
        sta ZP_PTR1+1
        jsr print_string

        lda CURRENT_TURN
        clc
        adc #'1'
        jsr print_char

        lda #<dti_tn
        sta ZP_PTR1
        lda #>dti_tn
        sta ZP_PTR1+1
        jsr print_string
        rts

dti_yr
        dta c'>>> YOUR TURN <<<',0
dti_pl
        dta c'PLAYER ',0
dti_tn
        dta c"'S TURN",0
