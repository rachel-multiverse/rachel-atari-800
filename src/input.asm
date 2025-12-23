; =============================================================================
; ATARI 8-BIT INPUT MODULE
; =============================================================================

; -----------------------------------------------------------------------------
; Wait for any key press (blocking)
; -----------------------------------------------------------------------------
wait_key
        lda #$FF
        sta CH
wk_lp
        lda CH
        cmp #$FF
        beq wk_lp

        pha
        lda #$FF
        sta CH
        pla
        rts

; -----------------------------------------------------------------------------
; Check for key (non-blocking)
; Returns: A = key if pressed, 0 if no key
; -----------------------------------------------------------------------------
check_key
        lda CH
        cmp #$FF
        beq ck_no

        pha
        lda #$FF
        sta CH
        pla
        sec
        rts

ck_no
        lda #0
        clc
        rts

; -----------------------------------------------------------------------------
; Input a line of text
; Input: ZP_PTR1 = buffer address, X = max length
; Returns: A = length entered
; -----------------------------------------------------------------------------
input_line
        stx ZP_TEMP1
        lda #0
        sta ZP_TEMP2
        ldy #0

il_lp
        jsr wait_key

        cmp #KEY_RETURN
        beq il_dn

        cmp #ATASCII_BKSP
        beq il_del
        cmp #126
        beq il_del

        cpy ZP_TEMP1
        bcs il_lp

        cmp #32
        bcc il_lp
        cmp #127
        bcs il_lp

        sta (ZP_PTR1),y
        iny
        jsr print_char
        jmp il_lp

il_del
        cpy #0
        beq il_lp

        dey

        lda #ATASCII_BKSP
        jsr print_char
        lda #' '
        jsr print_char
        lda #ATASCII_BKSP
        jsr print_char

        jmp il_lp

il_dn
        lda #0
        sta (ZP_PTR1),y
        tya
        rts
