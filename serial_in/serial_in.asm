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
    rcall UART_recv     ; 受信関数を呼ぶ
    rcall UART_send     ; 戻り値をそのまま引数として送信関数
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

    ; UARTから1文字取得する関数
    ; 破壊レジスタ r25
    ; uint8_t UART_recv(void);
UART_recv:
    lds r25, UCSRnA
    sbrs r25, 7         ; 受信するデータがあるかチェック(1=送信可能)
    rjmp UART_recv      ; ない場合はループ

    lds r24, UDRn       ; 'a'を送信
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
