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
    ; ldi r24, 'a'
    ; rcall UART_send
    
    ldi r24, low(msg<<1)   ; 第１引数の取得 
    ldi r25, high(msg<<1)  ; 第１引数の取得 
    rcall UART_puts     ; 送信関数の呼び出し
sleep:
    rjmp sleep          ; 無限ループ

msg:                    ; 文字列を定義
    .db "as the moon, so beautiful.", 0, 0  ; 最後のヌル文字大事

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
UART_send_loop1:
    lds r25, UCSRnA
    sbrs r25, 5         ; 送信できるかチェック(1=送信可能)
    rjmp UART_send_loop1; 送信待機

    sts UDRn, r24       ; 'a'を送信
    ret

    ; UARTに文字列を送信する関数
    ; 破壊レジスタ r24, r25
    ; void UART_puts(char *s);
UART_puts:
    movw r30, r24         ; r25:r24をZレジスタにコピー

UART_puts_loop1:
    ; プログラム用フラッシュメモリから文字の取得後にZ+1
    lpm r24, Z+

    cpi r24, 0          ; ヌル文字の判定
    breq UART_puts_Exit

UART_puts_loop2:
    lds  r25, UCSRnA    ;
    sbrs r25, 5         ; 送信できるかチェック(1=送信可能)
    rjmp UART_puts_loop2; 送信待機

    sts UDRn, r24       ; 文字の送信

    rjmp UART_puts_loop1; 戻る

UART_puts_Exit:
    ; 改行コードの送信
UART_puts_loop3:
    lds  r25, UCSRnA    ;
    sbrs r25, 5         ; 送信できるかチェック(1=送信可能)
    rjmp UART_puts_loop3; 送信待機

    ldi r24, 0x0a       ; 改行コード(\n=0Ah)の送信
    sts UDRn, r24       ; 文字の送信

    ret
