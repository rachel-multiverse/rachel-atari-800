; =============================================================================
; RUBP PROTOCOL MODULE - Atari 8-bit
; =============================================================================

; -----------------------------------------------------------------------------
; Initialize message header in TX buffer
; Input: A = message type
; -----------------------------------------------------------------------------
rubp_init_header
        sta ZP_TEMP1

        lda #MAGIC_0
        sta SERIAL_TX_BUF
        lda #MAGIC_1
        sta SERIAL_TX_BUF+1
        lda #MAGIC_2
        sta SERIAL_TX_BUF+2
        lda #MAGIC_3
        sta SERIAL_TX_BUF+3

        lda #PROTOCOL_VER
        sta SERIAL_TX_BUF+HDR_VERSION

        lda ZP_TEMP1
        sta SERIAL_TX_BUF+HDR_TYPE

        lda SEQUENCE_HI
        sta SERIAL_TX_BUF+HDR_SEQ
        lda SEQUENCE_LO
        sta SERIAL_TX_BUF+HDR_SEQ+1

        inc SEQUENCE_LO
        bne rih_nc
        inc SEQUENCE_HI
rih_nc
        lda PLAYER_ID_HI
        sta SERIAL_TX_BUF+HDR_PLAYER_ID
        lda PLAYER_ID_LO
        sta SERIAL_TX_BUF+HDR_PLAYER_ID+1

        lda GAME_ID_HI
        sta SERIAL_TX_BUF+HDR_GAME_ID
        lda GAME_ID_LO
        sta SERIAL_TX_BUF+HDR_GAME_ID+1

        ; Vintage clients do not maintain Unix time. Zero is canonical.
        lda #0
        sta SERIAL_TX_BUF+HDR_TIMESTAMP
        sta SERIAL_TX_BUF+HDR_TIMESTAMP+1
        sta SERIAL_TX_BUF+HDR_TIMESTAMP+2
        sta SERIAL_TX_BUF+HDR_TIMESTAMP+3

        ldx #PAYLOAD_SIZE-1
        lda #0
rih_clr
        sta SERIAL_TX_BUF+PAYLOAD_START,x
        dex
        bpl rih_clr

        rts

; -----------------------------------------------------------------------------
; Compatibility name retained for callers. RUBP v1 bytes 12-15 are a
; timestamp, not a checksum; rubp_init_header has already set them to zero.
; -----------------------------------------------------------------------------
rubp_set_checksum
        rts

; -----------------------------------------------------------------------------
; Send HELLO message
; -----------------------------------------------------------------------------
rubp_send_hello
        lda #MSG_HELLO
        jsr rubp_init_header

        ldy #0
rsh_cp
        lda (ZP_PTR1),y
        beq rsh_dn
        sta SERIAL_TX_BUF+PAYLOAD_START,y
        iny
        cpy #16
        bne rsh_cp

rsh_dn
        ; Platform ID at payload+16 (big-endian)
        ; Atari 8-bit = 0x000B
        lda #$00
        sta SERIAL_TX_BUF+PAYLOAD_START+16
        lda #$0B                ; Platform 11 = Atari 8-bit
        sta SERIAL_TX_BUF+PAYLOAD_START+17

        ; RachelSpec v1 (big-endian)
        lda #0
        sta SERIAL_TX_BUF+PAYLOAD_START+18
        lda #RACHEL_SPEC_VER
        sta SERIAL_TX_BUF+PAYLOAD_START+19

        jsr rubp_set_checksum
        jsr net_send
        rts

; -----------------------------------------------------------------------------
; Send PLAY_CARD message
; Input: A = nominated suit ($FF if none)
; -----------------------------------------------------------------------------
rubp_send_play_card
        sta ZP_TEMP3

        lda #MSG_PLAY_CARD
        jsr rubp_init_header

        jsr count_selected
        sta SERIAL_TX_BUF+PAYLOAD_START

        lda ZP_TEMP3
        sta SERIAL_TX_BUF+PAYLOAD_START+33

        lda #0
        sta SERIAL_TX_BUF+PAYLOAD_START+34
        lda #RACHEL_SPEC_VER
        sta SERIAL_TX_BUF+PAYLOAD_START+35

        ldx #0
        ldy #1
        lda SELECTED_LO
        sta ZP_TEMP1
        lda SELECTED_HI
        sta ZP_TEMP2

rsp_lp
        lda ZP_TEMP1
        and #1
        beq rsp_nx

        lda MY_HAND,x
        sta SERIAL_TX_BUF+PAYLOAD_START,y
        iny

rsp_nx
        lsr ZP_TEMP2
        ror ZP_TEMP1
        inx
        cpx HAND_COUNT
        bcc rsp_lp

        jsr rubp_set_checksum
        jsr net_send
        rts

; -----------------------------------------------------------------------------
; Count set bits in SELECTED_LO/HI
; -----------------------------------------------------------------------------
count_selected
        lda #0
        sta ZP_TEMP4

        lda SELECTED_LO
        sta ZP_TEMP1
        lda SELECTED_HI
        sta ZP_TEMP2

        ldx #16
cs_lp
        lsr ZP_TEMP2
        ror ZP_TEMP1
        bcc cs_sk
        inc ZP_TEMP4
cs_sk
        dex
        bne cs_lp

        lda ZP_TEMP4
        rts

; -----------------------------------------------------------------------------
; Send DRAW_CARD message
; -----------------------------------------------------------------------------
rubp_send_draw_card
        sta ZP_TEMP3

        lda #MSG_DRAW_CARD
        jsr rubp_init_header

        lda ZP_TEMP3
        sta SERIAL_TX_BUF+PAYLOAD_START

        lda #1
        sta SERIAL_TX_BUF+PAYLOAD_START+1
        lda #0
        sta SERIAL_TX_BUF+PAYLOAD_START+2
        lda #RACHEL_SPEC_VER
        sta SERIAL_TX_BUF+PAYLOAD_START+3

        jsr rubp_set_checksum
        jsr net_send
        rts

; -----------------------------------------------------------------------------
; Receive a message into RX buffer
; -----------------------------------------------------------------------------
rubp_receive
        jsr net_recv
        rts

; -----------------------------------------------------------------------------
; Validate received message
; Returns: Z flag set if valid
; -----------------------------------------------------------------------------
rubp_validate
        lda SERIAL_RX_BUF
        cmp #MAGIC_0
        bne rv_inv
        lda SERIAL_RX_BUF+1
        cmp #MAGIC_1
        bne rv_inv
        lda SERIAL_RX_BUF+2
        cmp #MAGIC_2
        bne rv_inv
        lda SERIAL_RX_BUF+3
        cmp #MAGIC_3
        bne rv_inv

        lda SERIAL_RX_BUF+HDR_VERSION
        cmp #PROTOCOL_VER
        bne rv_inv

        lda #0
        rts

rv_inv
        lda #1
        rts

; -----------------------------------------------------------------------------
; Get message type
; -----------------------------------------------------------------------------
rubp_get_type
        lda SERIAL_RX_BUF+HDR_TYPE
        rts

; -----------------------------------------------------------------------------
; Parse WELCOME message
; -----------------------------------------------------------------------------
rubp_parse_welcome
        lda SERIAL_RX_BUF+PAYLOAD_START+1
        sta PLAYER_ID_LO
        lda SERIAL_RX_BUF+PAYLOAD_START
        sta PLAYER_ID_HI

        lda SERIAL_RX_BUF+PAYLOAD_START+2
        sta GAME_ID_HI
        lda SERIAL_RX_BUF+PAYLOAD_START+3
        sta GAME_ID_LO

        lda SERIAL_RX_BUF+PAYLOAD_START+1
        sta MY_INDEX

        lda SERIAL_RX_BUF+PAYLOAD_START+4
        sta PLAYER_COUNT

        rts

; -----------------------------------------------------------------------------
; Parse GAME_START message
; -----------------------------------------------------------------------------
rubp_parse_game_start
        lda SERIAL_RX_BUF+PAYLOAD_START
        cmp #33
        bcc pgs_start_count_ok
        lda #32
pgs_start_count_ok
        sta HAND_COUNT

        tax
        beq pgs_start_done
        ldy #0
pgs_start_hand
        lda SERIAL_RX_BUF+PAYLOAD_START+1,y
        sta MY_HAND,y
        iny
        dex
        bne pgs_start_hand
pgs_start_done

        rts

; -----------------------------------------------------------------------------
; Parse GAME_STATE message
; -----------------------------------------------------------------------------
rubp_parse_game_state
        lda SERIAL_RX_BUF+PAYLOAD_START
        sta CURRENT_TURN

        lda SERIAL_RX_BUF+PAYLOAD_START+1
        sta DIRECTION

        lda SERIAL_RX_BUF+PAYLOAD_START+2
        sta DISCARD_TOP

        lda SERIAL_RX_BUF+PAYLOAD_START+3
        sta NOMINATED_SUIT

        lda SERIAL_RX_BUF+PAYLOAD_START+4
        sta PENDING_DRAWS

        lda SERIAL_RX_BUF+PAYLOAD_START+5
        sta PENDING_SKIPS

        lda SERIAL_RX_BUF+PAYLOAD_START+6
        sta DECK_COUNT

        ldx #0
pgs_cnt
        lda SERIAL_RX_BUF+PAYLOAD_START+7,x
        sta PLAYER_COUNTS,x
        inx
        cpx #8
        bne pgs_cnt

        rts

; CARD_DRAWN has the same count + card-array shape as GAME_START.
rubp_parse_card_drawn
        lda SERIAL_RX_BUF+PAYLOAD_START
        beq pcd_done
        sta ZP_TEMP1
        ldy #0
pcd_loop
        lda HAND_COUNT
        cmp #32
        bcs pcd_done
        tax
        lda SERIAL_RX_BUF+PAYLOAD_START+1,y
        sta MY_HAND,x
        inc HAND_COUNT
        iny
        dec ZP_TEMP1
        bne pcd_loop
pcd_done
        rts
