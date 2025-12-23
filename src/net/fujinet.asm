; =============================================================================
; FUJINET NETWORK DRIVER - Atari 8-bit
; =============================================================================

fn_dev
        dta c'N:',0

fn_tcp
        dta c'N:TCP://',0

fn_url  :64 dta 0

; =============================================================================
; NETWORK DRIVER INTERFACE
; =============================================================================

net_init
        lda #0
        rts

net_connect
        ldx #0

nc_pfx
        lda fn_tcp,x
        beq nc_hst
        sta fn_url,x
        inx
        bne nc_pfx

nc_hst
        ldy #0
nc_cp
        lda (ZP_PTR1),y
        beq nc_sl
        sta fn_url,x
        inx
        iny
        bne nc_cp

nc_sl
        lda #'/'
        sta fn_url,x
        inx
        lda #0
        sta fn_url,x

        ldx #$10

        lda #<fn_url
        sta ICBAL,x
        lda #>fn_url
        sta ICBAH,x

        lda #AUX_READWRITE
        sta ICAX1,x
        lda #0
        sta ICAX2,x

        lda #CIO_OPEN
        sta ICCOM,x

        jsr CIOV

        bmi nc_err

        lda #0
        rts

nc_err
        lda #1
        rts

net_send
        ldx #$10

        lda #<SERIAL_TX_BUF
        sta ICBAL,x
        lda #>SERIAL_TX_BUF
        sta ICBAH,x

        lda #64
        sta ICBLL,x
        lda #0
        sta ICBLH,x

        lda #CIO_PUTCHR
        sta ICCOM,x

        jsr CIOV

        bmi ns_err

        lda #0
        rts

ns_err
        lda #1
        rts

net_recv
        ldx #$10

        lda #<SERIAL_RX_BUF
        sta ICBAL,x
        lda #>SERIAL_RX_BUF
        sta ICBAH,x

        lda #64
        sta ICBLL,x
        lda #0
        sta ICBLH,x

        lda #CIO_GETCHR
        sta ICCOM,x

        jsr CIOV

        bmi nr_err

        lda #0
        rts

nr_err
        lda #1
        rts

net_close
        ldx #$10
        lda #CIO_CLOSE
        sta ICCOM,x
        jsr CIOV
        rts

net_available
        ldx #$10
        lda #CIO_STATUS
        sta ICCOM,x
        jsr CIOV
        lda $02EA
        ora $02EB
        rts
