    .device atmega328p
    .equ DDRB = 0x04  ; DDRBを0x04と定義
    .equ PORTB = 0x05 ; PORTBを0x05と定義
    .equ DDRD = 0x0A
    .equ PORTD = 0x0B

    .cseg             ; コード部の開始
    .org 0x0000       ; 0x0000番地に配置
    jmp main          ; mainへジャンプ

main:
    sbi DDRD, 2      ; D13を出力に指定
    sbi PORTD, 2      ; D13にHIGHを出力
loop:
    rjmp loop         ; メインループ
