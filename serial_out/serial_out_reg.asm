    .device atmega328p
    .equ UBRRnH = 0xC5  ; USARTボーレートレジスタ上位
    .equ UBRRnL = 0xC4  ; USARTボーレートレジスタ下位
    .equ UCSRnA = 0xC0  ; USART制御／状態レジスタA
    .equ UCSRnB = 0xC1  ; USART制御／状態レジスタB
    .equ UCSRnC = 0xC2  ; USART制御／状態レジスタC
    .equ UDRn   = 0xC6  ; USARTデータレジスタ

    .cseg               ; コード部の開始
    .org 0x0000         ; 0x0000番地に配置
    jmp main            ; mainへジャンプ

main:
    ldi r24, low(103)
    ldi r25, high(103)
    rcall UART_begin
mainloop:
    ldi r24, 0b11111111
    rcall UART_regdump

    rjmp mainloop
    
    ; UARTの準備をする関数
    ; 引数baudrateはシステムクロックを用いた演算値なので注意
    ; 破壊レジスタ r24
    ; void UART_begin(uint16_t baudrate);
UART_begin:
    sts UBRRnH, r25     ; ボーレート上位バイト設定
    sts UBRRnL, r24     ; ボーレート下位バイト設定

    ; 非同期動作, ﾊﾟﾘﾃｨなし, ｽﾄｯﾌﾟﾋﾞｯﾄ1bit, 8bitに設定
    ldi r24, 0b00000110
    sts UCSRnC, r24
    ldi r24, 0b00011000 ; 送受信を許可に設定
    sts UCSRnB, r24
    ret

    ; UARTに1文字送信する関数
    ; 破壊レジスタ r25
    ; void UART_send(char c);
UART_send:
    lds r25, UCSRnA
    sbrs r25, 5         ; 送信できるかチェック(1=送信可能)
    rjmp UART_send      ; 送信待機

    sts UDRn, r24       ; 'a'を送信
    ret

    ; レジスタ値を2進文字列で出力する関数
    ; 破壊レジスタ r25, r24, r22, r23
    ; void UART_regdump(uint8_t d)
UART_regdump:
    mov r22, r24
    ldi r23, 0
    
UART_regdump_loop1:
    cpi R23, 8
    brge UART_regdump_exit

    sbrs r22, 0
    ; r22の最下位ビットが1のとき飛ばされる
    rjmp UART_regdump_outzero
    rjmp UART_regdump_outone

UART_regdump_outzero:
    ldi r24, '0'
    rcall UART_send

    lsr r22             ; 送信値の右シフト
    inc r23             ; カウンタのインクリメント
    rjmp UART_regdump_loop1
UART_regdump_outone:
    ldi r24, '1'
    rcall UART_send

    lsr r22             ; 送信値の右シフト
    inc r23             ; カウンタのインクリメント
    rjmp UART_regdump_loop1

UART_regdump_exit:
    ret
