; =============================================================================
; FUJINET NETWORK DRIVER - Atari 8-bit
; =============================================================================
; Talks directly to the real FujiNet Atari SIO network device ($71). This is
; independent of the optional resident N: CIO handler, so the XEX can be loaded
; directly from FujiNet, SIO2SD, or another DOS disk.
;
; FujiNet commands used here: O=open, S=status, R=read, W=write, C=close.

fn_tcp
        dta c'N:TCP://',0

; OPEN always transfers a 256-byte URL buffer.
fn_url  :256 dta 0

; =============================================================================
; NETWORK DRIVER INTERFACE
; =============================================================================

net_init
        lda #0
        rts

net_connect
        lda #0
        ldx #0
nc_clr
        sta fn_url,x
        inx
        bne nc_clr

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

        lda #'O'
        sta DCOMND
        lda #SIO_WRITE
        sta DSTATS
        lda #<fn_url
        sta DBUFL
        lda #>fn_url
        sta DBUFH
        lda #$1F
        sta DTIMLO
        lda #0
        sta DBYTL
        lda #1
        sta DBYTH
        lda #AUX_READWRITE
        sta DAUXL
        lda #0                 ; raw/no character translation
        sta DAUXH
        jsr fn_sio
        jmp fn_result

net_send
        lda #'W'
        sta DCOMND
        lda #SIO_WRITE
        sta DSTATS
        lda #<SERIAL_TX_BUF
        sta DBUFL
        lda #>SERIAL_TX_BUF
        sta DBUFH
        lda #64
        sta DBYTL
        sta DAUXL
        lda #0
        sta DBYTH
        sta DAUXH
        lda #$1F
        sta DTIMLO
        jsr fn_sio
        jmp fn_result

net_recv
        ; TCP is a stream. Wait until a complete RUBP frame is buffered.
nr_wait
        jsr fn_status
        cmp #0
        bne nr_err
        lda DVSTAT+3           ; FujiNet extended status (1 = success)
        cmp #SIO_OK
        bne nr_err
        lda DVSTAT+1
        bne nr_read
        lda DVSTAT
        cmp #64
        bcc nr_wait

nr_read
        lda #'R'
        sta DCOMND
        lda #SIO_READ
        sta DSTATS
        lda #<SERIAL_RX_BUF
        sta DBUFL
        lda #>SERIAL_RX_BUF
        sta DBUFH
        lda #64
        sta DBYTL
        sta DAUXL
        lda #0
        sta DBYTH
        sta DAUXH
        lda #$1F
        sta DTIMLO
        jsr fn_sio
        jmp fn_result

nr_err
        lda #1
        rts

net_close
        lda #'C'
        sta DCOMND
        lda #0
        sta DSTATS
        sta DBUFL
        sta DBUFH
        sta DBYTL
        sta DBYTH
        sta DAUXL
        sta DAUXH
        lda #$1F
        sta DTIMLO
        jsr fn_sio
        jmp fn_result

net_available
        jsr fn_status
        cmp #0
        bne na_none
        lda DVSTAT
        ora DVSTAT+1
        rts
na_none
        lda #0
        rts

; =============================================================================
; LOW-LEVEL FUJINET SIO
; =============================================================================

fn_status
        lda #'S'
        sta DCOMND
        lda #SIO_READ
        sta DSTATS
        lda #<DVSTAT
        sta DBUFL
        lda #>DVSTAT
        sta DBUFH
        lda #4
        sta DBYTL
        lda #0
        sta DBYTH
        sta DAUXL
        sta DAUXH
        lda #$1F
        sta DTIMLO
        jsr fn_sio
        jmp fn_result

fn_sio
        lda #FUJINET_NDEV
        sta DDEVIC
        lda #1
        sta DUNIT
        jsr SIOV
        lda DSTATS
        rts

; Convert Atari SIO success (1) to Rachel network success (0).
fn_result
        cmp #SIO_OK
        beq fr_ok
        lda #1
        rts
fr_ok
        lda #0
        rts
