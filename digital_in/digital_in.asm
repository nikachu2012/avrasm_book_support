    .device atmega328p
    .equ DDRB = 0x04  ; DDRBを0x04と定義
    .equ PORTB = 0x05 ; PORTBを0x05と定義
    .equ PORTD = 0x0B
    .equ DDRD = 0x0A
    .equ PIND = 0x09
    .equ MCUCR = 0x35

    .cseg             ; コード部の開始
    .org 0x0000       ; 0x0000番地に配置
    jmp main          ; mainへジャンプ

main:
    ldi r16, 0
    out MCUCR, r16    ; プルアップ有効に設定

    sbi DDRB, 5       ; D13を出力に設定
    cbi DDRD, 2       ; D2を入力に設定
    sbi PORTD, 2      ; D2のプルアップ抵抗を有効
loop:
    sbic PIND, 2      ; PIND2=0のとき次の命令をスキップ
    rjmp true         ; PIND2=1のとき
    rjmp false        ; PIND2=0のとき
true:
    sbi PORTB, 5      ; 内蔵LEDを光らせる
    rjmp loop         ; メインループ
false:
    cbi PORTB, 5      ; 内蔵LEDを消す
    rjmp loop         ; メインループ
