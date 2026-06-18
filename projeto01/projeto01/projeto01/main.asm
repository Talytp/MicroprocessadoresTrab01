; ### Trabalho Individual - Microprocessadores - ATmega328P  (8 MHz)

.def AUX   = r16            ; registrador de trabalho
.def TMP   = r19            ; espera de transmissao
.equ TRACO = 16             ; indice do traco na tabela

; ## vetores 
.org 0x0000
    rjmp RESET              ; reset
.org INT0addr
    rjmp ISR_INT0           ; botao (INT0)
.org URXCaddr
    rjmp ISR_RX             ; recepcao da USART (RXC)
.org 0x0034                 ; codigo apos a tabela de vetores

; ## inicializacoes 
RESET:
    ldi  AUX, high(RAMEND)  ; pilha
    out  SPH, AUX
    ldi  AUX, low(RAMEND)
    out  SPL, AUX

    ldi  AUX, 0b01111111    ; PB0..PB6 saida (segmentos)
    out  DDRB, AUX
    ldi  AUX, 0x3F			; (catodo comum)
    out  PORTB, AUX

    ldi  AUX, 0b00000100    ; pull-up no PD2 (botao)
    out  PORTD, AUX
    ldi  AUX, (1<<ISC01)    ; INT0 por borda de descida
    sts  EICRA, AUX
    ldi  AUX, (1<<INT0)     ; habilita INT0
    out  EIMSK, AUX

    ldi  AUX, 103           ; UBRR0 = 103 -> 4800 bps e 8 MHz
    sts  UBRR0L, AUX
    ldi  AUX, (1<<RXEN0)|(1<<TXEN0)|(1<<RXCIE0)  ; RX, TX e int. de recepcao
    sts  UCSR0B, AUX
    ldi  AUX, (1<<UCSZ01)|(1<<UCSZ00)            ; 8 bits, 1 stop, sem paridade
    sts  UCSR0C, AUX

    sei                     ; habilita interrupcoes

Principal:
    rjmp Principal          ; o trabalho acontece nas interrupcoes

; ## ISR: recepcao da USART  (converte ASCII e mostra no display)
ISR_RX:
    push AUX
    in   AUX, SREG
    push AUX                ; salva SREG 
    lds  AUX, UDR0          ; le o byte (ler tambem limpa RXC0)

    cpi  AUX, '0'
    brlo RX_traco
    cpi  AUX, '9'+1
    brlo RX_dig				; '0'..'9'
	cbr  AUX, 0x20          ; minuscula -> maiuscula (a...f vira A...F)        
    cpi  AUX, 'A'
    brlo RX_traco
    cpi  AUX, 'F'+1
    brlo RX_letra           ; 'A'..'F'
RX_traco:
    ldi  AUX, TRACO         ; invalido -> traco
    rjmp RX_dec
RX_dig:
    subi AUX, '0'           ; indice = codigo - 0x30
    rjmp RX_dec
RX_letra:
    subi AUX, 'A'-10        ; indice = codigo - 0x37
RX_dec:
    ldi  ZL, low(Tabela<<1)
    ldi  ZH, high(Tabela<<1)
    add  ZL, AUX            ; aponta Tabela[indice]
    brcc RX_le
    inc  ZH
RX_le:
    lpm  r0, Z              ; le o padrao de segmentos
    out  PORTB, r0          ; mostra no display

    pop  AUX
    out  SREG, AUX          ; restaura SREG
    pop  AUX
    reti

; ## ISR: botao  (envia o nome pela UART)
ISR_INT0:
    push AUX
    in   AUX, SREG
    push AUX
    ldi  ZL, low(Nome<<1)
    ldi  ZH, high(Nome<<1)
BT_prox:
    lpm  AUX, Z+            ; le um caractere do nome
    cpi  AUX, 0             ; terminador?
    breq BT_fim
BT_espera:
    lds  TMP, UCSR0A
    sbrs TMP, UDRE0         ; transmissor pronto?
    rjmp BT_espera
    sts  UDR0, AUX          ; envia
    rjmp BT_prox
BT_fim:
    pop  AUX
    out  SREG, AUX
    pop  AUX
    reti

; ## tabelas (flash) 
; Catodo comum, 16 = traco.
Tabela:
    .db 0x3F,0x06,0x5B,0x4F,0x66,0x6D,0x7D,0x07
    .db 0x7F,0x67,0x77,0x7C,0x39,0x5E,0x79,0x71  ; 8 9 A B C D E F
    .db 0X40,0X40           ; 16 = traco (so o segmento g)

Nome:
    .db "Talyta Pompeu", 0x0D, 0x0A, 0