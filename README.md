# Display Hexadecimal via UART — ATmega328P (Assembly)

Trabalho individual da disciplina de **Microprocessadores**. O firmware roda em um **ATmega328P a 8 MHz**, programado em **Assembly AVR** com manipulação direta de registradores, e foi validado em simulação no **SimulIDE**.

## Visão geral

O sistema tem duas funções, ambas tratadas por interrupção (o laço principal fica vazio):

- **Recepção via USART → display de 7 segmentos.** Cada byte recebido é interpretado como um caractere ASCII. Se for um dígito hexadecimal válido (`0`–`9`, `A`–`F`, maiúsculo ou minúsculo), o padrão correspondente é exibido no display. Qualquer outro caractere mostra um traço (`-`).
- **Botão (INT0) → transmissão do nome via UART.** Ao pressionar o botão, o programa  envia uma string de identificação pela UART, terminada por `CR LF`.

## Hardware

| Componente            | Ligação no ATmega328P                    |
|-----------------------|------------------------------------------|
| Display 7 segmentos   | Segmentos `a`–`g` em **PB0–PB6** (catodo comum) |
| Botão                 | **PD2 / INT0** (com pull-up interno, borda de descida) |
| UART                  | **PD0 (RXD)** e **PD1 (TXD)**            |

## Detalhes técnicos

- **MCU:** ATmega328P @ 8 MHz
- **USART:** 4800 bps, 8 bits de dados, 1 stop, sem paridade (8N1)
  - `UBRR0 = 103` → `8.000.000 / (16 × 104) ≈ 4807 bps` (~0,2% de erro)
- **Interrupções usadas:** `INT0` (botão) e `RXC` (recepção da USART)
- **Tabela de segmentos** gravada em flash, lida com `LPM`. O display é **catodo comum**,
  então um bit em `1` acende o segmento.

### Mapa da tabela de segmentos (catodo comum)

| Dígito | Byte | Dígito | Byte | Dígito | Byte |
|:------:|:----:|:------:|:----:|:------:|:----:|
| 0 | `0x3F` | 6 | `0x7D` | C | `0x39` |
| 1 | `0x06` | 7 | `0x07` | d | `0x5E` |
| 2 | `0x5B` | 8 | `0x7F` | E | `0x79` |
| 3 | `0x4F` | 9 | `0x67` | F | `0x71` |
| 4 | `0x66` | A | `0x77` | –  | `0x40` |
| 5 | `0x6D` | b | `0x7C` |    |        |

## Como compilar

Projeto feito no **Atmel Studio 7 / Microchip Studio**:

1. Abra `projeto01/projeto01.atsln`.
2. Confirme que o device é o **ATmega328P**.
3. Compile com **Build → Build Solution** (`F7`). O `.hex` é gerado em `Debug/`.

## Como simular

1. Abra `projeto.sim1` no **SimulIDE**.
2. Carregue o firmware (`projeto01.hex`) no microcontrolador do circuito.
3. Defina o clock do MCU para **8 MHz** e rode a simulação.
4. Use o serial monitor a **4800 bps** para enviar caracteres e ver o nome ao apertar o botão.

## Estrutura do repositório

```
.
├── README.md
├── .gitignore
├── projeto.sim1                 # circuito de simulação (SimulIDE)
└── projeto01/                   # solução do Atmel/Microchip Studio
    ├── projeto01.atsln
    └── projeto01/
        ├── main.asm             # código-fonte
        ├── projeto01.asmproj
        └── projeto01.componentinfo.xml
```

As saídas de compilação (`Debug/`) e os arquivos de cache da IDE (`.vs/`, `.atsuo`)
não são versionados — veja o `.gitignore`.

## Autor

Talyta Pompeu
