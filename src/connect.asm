; =============================================================================
; CONNECTION MODULE - Atari 8-bit
; =============================================================================

; -----------------------------------------------------------------------------
; Input IP address from user
; -----------------------------------------------------------------------------
input_ip_address
        ldx #0
        ldy #22
        jsr set_cursor

        lda #<iia_prm
        sta ZP_PTR1
        lda #>iia_prm
        sta ZP_PTR1+1
        jsr print_string

        lda #<IP_INPUT_BUF
        sta ZP_PTR1
        lda #>IP_INPUT_BUF
        sta ZP_PTR1+1
        ldx #30
        jsr input_line

        rts

iia_prm
        dta c'HOST:PORT> ',0

; -----------------------------------------------------------------------------
; Perform full connection sequence
; -----------------------------------------------------------------------------
do_connect
        jsr ssc_con

        jsr net_init
        cmp #0
        bne dc_fl

        lda #<IP_INPUT_BUF
        sta ZP_PTR1
        lda #>IP_INPUT_BUF
        sta ZP_PTR1+1
        jsr net_connect
        cmp #0
        bne dc_fl

        lda #CONN_HANDSHAKE
        sta CONN_STATE

        jsr ssc_hs

        lda #<dc_nm
        sta ZP_PTR1
        lda #>dc_nm
        sta ZP_PTR1+1
        jsr rubp_send_hello

        jsr rubp_receive
        cmp #0
        bne dc_fl
        jsr rubp_validate
        bne dc_fl

        jsr rubp_get_type
        cmp #MSG_WELCOME
        bne dc_fl

        jsr rubp_parse_welcome

        lda #CONN_WAITING
        sta CONN_STATE

        jsr ssc_wt

        lda #0
        rts

dc_fl
        jsr ssc_fail
        lda #1
        rts

dc_nm
        dta c'ATARI PLAYER',0

; -----------------------------------------------------------------------------
; Wait for GAME_START message
; -----------------------------------------------------------------------------
wait_for_game
wfg_lp
        jsr check_key
        cmp #KEY_ESC
        beq wfg_cn

        jsr rubp_receive
        cmp #0
        bne wfg_cn
        jsr rubp_validate
        bne wfg_lp

        jsr rubp_get_type

        cmp #MSG_GAME_START
        beq wfg_gs

        cmp #MSG_GAME_STATE
        beq wfg_st

        jmp wfg_lp

wfg_gs
        jsr rubp_parse_game_start
        lda #CONN_PLAYING
        sta CONN_STATE
        lda #0
        rts

wfg_st
        jsr rubp_parse_game_state
        lda #CONN_PLAYING
        sta CONN_STATE
        lda #0
        rts

wfg_cn
        lda #1
        rts

; -----------------------------------------------------------------------------
; Status display helpers
; -----------------------------------------------------------------------------
ssc_con
        ldx #0
        ldy #23
        jsr set_cursor
        lda #<ss_con
        sta ZP_PTR1
        lda #>ss_con
        sta ZP_PTR1+1
        jsr print_string
        rts

ssc_hs
        ldx #0
        ldy #23
        jsr set_cursor
        lda #<ss_hs
        sta ZP_PTR1
        lda #>ss_hs
        sta ZP_PTR1+1
        jsr print_string
        rts

ssc_wt
        ldx #0
        ldy #23
        jsr set_cursor
        lda #<ss_wt
        sta ZP_PTR1
        lda #>ss_wt
        sta ZP_PTR1+1
        jsr print_string
        rts

ssc_fail
        ldx #0
        ldy #23
        jsr set_cursor
        lda #<ss_fail
        sta ZP_PTR1
        lda #>ss_fail
        sta ZP_PTR1+1
        jsr print_string
        rts

ss_con
        dta c'CONNECTING...                   ',0
ss_hs
        dta c'HANDSHAKING...                  ',0
ss_wt
        dta c'WAITING FOR GAME...             ',0
ss_fail
        dta c'CONNECTION FAILED               ',0
