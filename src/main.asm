; =============================================================================
; RACHEL ATARI 8-BIT - MAIN ENTRY POINT
; =============================================================================
; A render-only client for the Rachel card game.
; Connects to iOS host via FujiNet N: device.
;
; Assemble with MADS:
;   mads src/main.asm -o:build/rachel.xex

; =============================================================================
; INCLUDES
; =============================================================================

        icl "src/equates.asm"

; =============================================================================
; XEX HEADER
; =============================================================================

        opt h+                  ; Generate XEX header

; =============================================================================
; PROGRAM START
; =============================================================================

        org $2000

; =============================================================================
; ENTRY POINT
; =============================================================================

start
        ; Initialize variables
        jsr init_variables

        ; Initialize display
        jsr display_init

        ; Draw initial screen
        jsr draw_game_screen

        ; Show welcome message
        ldx #10
        ldy #5
        jsr set_cursor
        lda #<txt_welcome
        sta ZP_PTR1
        lda #>txt_welcome
        sta ZP_PTR1+1
        jsr print_string

        ; Show instructions
        ldx #4
        ldy #23
        jsr set_cursor
        lda #<txt_press_key
        sta ZP_PTR1
        lda #>txt_press_key
        sta ZP_PTR1+1
        jsr print_string

        ; Wait for keypress
        jsr wait_key

connect_loop
        ; Get IP address
        jsr input_ip_address
        cmp #0
        beq start

        ; Attempt connection
        jsr do_connect
        cmp #0
        bne conn_failed

        ; Wait for game to start
        jsr wait_for_game
        cmp #0
        bne conn_failed

        ; Enter game loop
        jmp game_loop

conn_failed
        jsr wait_key
        jmp start

; =============================================================================
; MAIN GAME LOOP
; =============================================================================

game_loop
        jsr redraw_game

gl_main
        jsr check_network
        jsr check_game_input

        ; Wait for vblank
        lda VCOUNT
gl_wait
        cmp VCOUNT
        beq gl_wait

        jmp gl_main

; -----------------------------------------------------------------------------
; Check for incoming network messages
; -----------------------------------------------------------------------------
check_network
        jsr net_available
        beq cn_done

        jsr rubp_receive
        cmp #0
        bne cn_done
        jsr rubp_validate
        bne cn_done

        jsr rubp_get_type

        cmp #MSG_GAME_STATE
        beq cn_gstate

        cmp #MSG_CARD_DRAWN
        beq cn_drawn

        cmp #MSG_HAND_SYNC
        beq cn_hsync

        cmp #MSG_PLAYER_WON
        beq cn_gover

cn_done
        rts

cn_gstate
        jsr rubp_parse_game_state
        jsr redraw_game
        rts

cn_drawn
        jsr rubp_parse_card_drawn
        jsr draw_hand
        rts

cn_hsync
        jsr rubp_parse_game_start
        jsr draw_hand
        rts

cn_gover
        rts

; -----------------------------------------------------------------------------
; Check for keyboard input during game
; -----------------------------------------------------------------------------
check_game_input
        jsr check_key
        beq cgi_done

        lda MY_INDEX
        cmp CURRENT_TURN
        bne cgi_done

        jsr check_key
        beq cgi_done

        cmp #','
        beq cgi_left
        cmp #'-'
        beq cgi_left

        cmp #'.'
        beq cgi_right
        cmp #'='
        beq cgi_right

        cmp #' '
        beq cgi_select

        cmp #KEY_RETURN
        beq cgi_play

        cmp #'d'
        beq cgi_draw
        cmp #'D'
        beq cgi_draw

cgi_done
        rts

cgi_left
        lda CURSOR_POS
        beq cgi_wrap_l
        dec CURSOR_POS
        jmp cgi_update

cgi_wrap_l
        lda HAND_COUNT
        sec
        sbc #1
        sta CURSOR_POS
        jmp cgi_update

cgi_right
        inc CURSOR_POS
        lda CURSOR_POS
        cmp HAND_COUNT
        bcc cgi_update
        lda #0
        sta CURSOR_POS
        jmp cgi_update

cgi_select
        lda CURSOR_POS
        cmp #8
        bcs cgi_done

        tax
        lda #1
cgi_shft
        cpx #0
        beq cgi_tog
        asl
        dex
        jmp cgi_shft

cgi_tog
        eor SELECTED_LO
        sta SELECTED_LO
        jmp cgi_update

cgi_play
        lda SELECTED_LO
        ora SELECTED_HI
        beq cgi_done

        jsr check_for_ace
        beq cgi_sendp

        jsr get_suit_nomination
        jmp cgi_sends

cgi_sendp
        lda #$FF
        jsr rubp_send_play_card
        jmp cgi_clrsel

cgi_sends
        jsr rubp_send_play_card

cgi_clrsel
        lda #0
        sta SELECTED_LO
        sta SELECTED_HI

cgi_update
        jsr draw_hand
        rts

cgi_draw
        lda #0
        jsr rubp_send_draw_card
        rts

; -----------------------------------------------------------------------------
; Check if any selected card is an Ace
; -----------------------------------------------------------------------------
check_for_ace
        lda SELECTED_LO
        sta ZP_TEMP1
        lda SELECTED_HI
        sta ZP_TEMP2

        ldx #0
cfa_lp
        lda ZP_TEMP1
        and #1
        beq cfa_nxt

        lda MY_HAND,x
        and #$0F
        cmp #14
        beq cfa_fnd

cfa_nxt
        lsr ZP_TEMP2
        ror ZP_TEMP1
        inx
        cpx HAND_COUNT
        bcc cfa_lp

        lda #0
        rts

cfa_fnd
        lda #1
        rts

; -----------------------------------------------------------------------------
; Get suit nomination from user
; -----------------------------------------------------------------------------
get_suit_nomination
        ldx #0
        ldy #23
        jsr set_cursor
        lda #<txt_nominate
        sta ZP_PTR1
        lda #>txt_nominate
        sta ZP_PTR1+1
        jsr print_string

gsn_wt
        jsr wait_key

        cmp #'h'
        beq gsn_h
        cmp #'H'
        beq gsn_h
        cmp #'d'
        beq gsn_d
        cmp #'D'
        beq gsn_d
        cmp #'c'
        beq gsn_c
        cmp #'C'
        beq gsn_c
        cmp #'s'
        beq gsn_s
        cmp #'S'
        beq gsn_s

        jmp gsn_wt

gsn_h
        lda #0
        rts
gsn_d
        lda #1
        rts
gsn_c
        lda #2
        rts
gsn_s
        lda #3
        rts

txt_nominate
        dta c"SUIT? H/D/C/S                   ",0

; =============================================================================
; INITIALIZATION
; =============================================================================

init_variables
        ldx #32
        lda #0
init_clr
        dex
        sta VAR_BASE,x
        bne init_clr

        lda #1
        sta SEQUENCE_LO
        lda #0
        sta SEQUENCE_HI

        lda #$FF
        sta NOMINATED_SUIT

        rts

; =============================================================================
; DATA
; =============================================================================

txt_welcome
        dta c'RACHEL ATARI 8-BIT',0

txt_press_key
        dta c'PRESS ANY KEY TO CONNECT...',0

; Application-owned storage. Keeping it in the load image avoids collisions
; with Atari OS/DOS workspaces (especially the IOCB table in page 3).
VAR_BASE        :32 dta 0
MY_HAND         :32 dta 0
PLAYER_COUNTS   :8 dta 0
PLAYER_NAMES    :128 dta 0
IP_INPUT_BUF    :32 dta 0
SERIAL_RX_BUF   :64 dta 0
SERIAL_TX_BUF   :64 dta 0

; =============================================================================
; MODULE INCLUDES
; =============================================================================

        icl "src/display.asm"
        icl "src/input.asm"
        icl "src/rubp.asm"
        icl "src/game.asm"
        icl "src/connect.asm"
        icl "src/net/fujinet.asm"

; =============================================================================
; RUN ADDRESS
; =============================================================================

        run start
