  .inesprg 1    ; 2 bancos PRG (32KB en total)
  .ineschr 1     ; 1 banco CHR (8KB)
  .inesmap 0     ; Mapper NROM
  .inesmir 1     ; Mirroring vertical

;;; Variables
   .rsset $0010
vblank_occurred .rs 1 
botonAp .rs 1
botonBp .rs 1
botonSelect .rs 1
botonStart .rs 1
botonArriba .rs 1
botonAbajo .rs 1
botonIzq .rs 1
botonDer .rs 1

estadoDeDisparo .rs 1
estadoNaveEnemiga1 .rs 1

timer .rs 1
timer2 .rs 1
randomX .rs 1
randomY .rs 1
semillaX .rs 1
semillaY .rs 1

posicionNaveX .rs 1
posicionNaveY .rs 1

posicionDisparoX .rs 1
posicionDisparoY .rs 1

posicionRayo1X .rs 1
posicionRayo1Y .rs 1

posicionRayo2X .rs 1
posicionRayo2Y .rs 1

posicionRayo3X .rs 1
posicionRayo3Y .rs 1

posicionRayo4X .rs 1
posicionRayo4Y .rs 1

posicionNaveEnemigaX .rs 1
posicionNaveEnemigaY .rs 1

posicionPrueba1_Y .rs 1
posicionPrueba2_Y .rs 1
posicionPrueba3_y .rs 1
posicionPrueba4_y .rs 1

timerDeActualizacion .rs 1




  .bank 0
  .org $C000
RESET:
  SEI          ; Deshabilitar interrupciones
  CLD          ; Modo decimal desactivado (no usado en NES)
  

vblankwait1:
    BIT $2002
    BPL vblankwait1
    
    LDX #$00
limpiarRam:
    LDA #$00
    STA $00, x
    STA $0100, x
    STA $0300, x
    STA $0400, x
    STA $0500, x
    STA $0600, x
    STA $0700, x
    LDA #$FE
    STA $0200
    INX
    BNE limpiarRam

vblankwait2:
    BIT $2002
    BPL vblankwait2

inicializarVariables:
    LDA #$00
    STA timer
    STA timer2
    STA vblank_occurred
    STA estadoDeDisparo
    STA timerDeActualizacion

    LDA #$01
    STA estadoNaveEnemiga1

inicialiazarRandom:
    LDA #%10101011
    STA semillaX
    STA semillaY
    
cargarPaleta:
    LDA $2002
    LDA #$3F
    STA $2006
    LDA #$00
    STA $2006
    
    LDX #$00
loopCargarPaletaFondo:
    LDA paletas, x
    STA $2007
    INX
    CPX #$10
    BNE loopCargarPaletaFondo

cargarPaletaSprite:
    LDA $2002
    LDA #$3F
    STA $2006
    LDA #$10
    STA $2006

    LDX #$00

loopCargarPaletaSprite
    LDA paletas, x
    STA $2007
    INX
    CPX #$10
    BNE loopCargarPaletaSprite

;escribir en la name table
    LDA #$20
    STA $2006
    LDA #$00
    STA $2006

;Pasar bloques de byte de fondo
    LDX #$00
loopFondoBloque1:
    LDA fondo, x
    STA $2007
    INX
    BNE loopFondoBloque1

    LDX #0
loopFondoBloque2:
    LDA fondo+256, x
    STA $2007
    INX
    BNE loopFondoBloque2

    LDX #0
loopFondoBloque3:
    LDA fondo+512, x
    STA $2007
    INX
    BNE loopFondoBloque3

    LDX #0
loopFondoBloque4:
    CPX #192
    BEQ hecho
    LDA fondo+768, x
    STA $2007
    INX 
    BNE loopFondoBloque4

hecho:

;tabla de atributos

    LDA #$23
    STA $2006
    LDA #$C0
    STA $2006
    LDX #$40
loopAtributos:
    LDA #$00
    STA $2007
    DEX
    BNE loopAtributos

;mostrar sprite
;cargar a la ppu el sprite de nave
    LDA #100
    STA $0200
    LDA #$03
    STA $0201
    LDA #%00000001
    STA $0202
    LDA #80
    STA $0203

    LDA $0200
    STA posicionNaveY
    LDA $0203
    STA posicionNaveX

;sprite de luna 1
    LDA #0
    STA $021C
    LDA #$07
    STA $021D
    LDA #%00000010
    STA $021E
    LDA #100
    STA $021F

    LDA $021C
    STA posicionPrueba1_Y

;sprite de luna 2
    LDA #0
    STA $0220
    LDA #$08
    STA $0221
    LDA #%00000010
    STA $0222
    LDA #108
    STA $0223

    LDA $0220
    STA posicionPrueba2_Y

;sprite de luna 3
    LDA #8
    STA $0224
    LDA #23
    STA $0225
    LDA #%00000010
    STA $0226
    LDA #100
    STA $0227

    LDA $0224
    STA posicionPrueba1_Y

;sprite de luna 4
     LDA #8
    STA $0228
    LDA #24
    STA $0229
    LDA #%00000010
    STA $022A
    LDA #108
    STA $022B

    LDA $0228
    STA posicionPrueba4_y

    

;habilitar graficos
    LDA #%10000000
    STA $2000
    LDA #%00011110
    STA $2001

;----------------------------------
;;juego principal
;----------------------------------


juegoPrincipal:

    LDA vblank_occurred
    BEQ juegoPrincipal       ; Esperar hasta que VBlank ocurra

    ; Limpiar la bandera para el próximo frame
    LDA #$00
    STA vblank_occurred

    ;logica del juego
    INC timer
    INC timer2
    INC timerDeActualizacion
    
    ;funciones primarias del juego
    JSR aparecerNaveEnemiga
    JSR dispararNaveEnemiga
    JSR animarDisparosEnemigos
    JSR leerControles
    JSR actualizarNave
    JSR animarDisparo
    JSR checarColisionANaveHumana
    JSR checarColisionDisparo
    JSR generarNumeroAleatorioX
    JSR teletransportarseNaveEnemiga
    JSR actualizarPrueba

    JMP juegoPrincipal

;---------------------------
;;firmas y logica de componentes
;---------------------------

;-----------------------------------
;firma de aparicion de nave enemiga
;----------------------------------
aparecerNaveEnemiga:

    LDA estadoNaveEnemiga1
    CMP #$00
    BEQ naveYaApacerida

    LDA timer2
    CMP #60
    BNE naveYaApacerida

    LDA #15
    STA $0208
    STA posicionNaveEnemigaY
    LDA #$05
    STA $0209
    LDA #%00000010
    STA $020A
    LDA #100
    STA $020B
    STA posicionNaveEnemigaX

    LDA #$00
    STA estadoNaveEnemiga1
    STA timer2

naveYaApacerida:
    RTS
;--------------------------
;primera firma - Disparo nave enemiga
;-------------------------

dispararNaveEnemiga:

    LDA estadoNaveEnemiga1
    CMP #$1
    BEQ regresarLoop
    ;;comprobar segundo 1
    LDA timer
    CMP #60
    BNE comprobar2Segundos
    JSR dispararRayoE

comprobar2Segundos:
    LDA timer
    CMP #120
    BNE comprobar3Segundos
    JSR dispararRayoE2

comprobar3Segundos:
    LDA timer
    CMP #180
    BNE comprobar4Segundos
    JSR dispararRayoE3

comprobar4Segundos:
    LDA timer
    CMP #240
    BNE regresarLoop
    JSR dispararRayoE4

regresarLoop:
    RTS

dispararRayoE:


    LDA $0208
    STA $020C
    LDA #$06
    STA $020D
    LDA #%00000011
    STA $020E
    LDA $020B
    STA $020F

    LDA $020C
    STA posicionRayo1Y
    LDA $020F
    STA posicionRayo1X

    RTS

dispararRayoE2:

   

    LDA $0208
    STA $0210
    LDA #$06
    STA $0211
    LDA #%00000011
    STA $0212
    LDA $020B
    STA $0213

    LDA $0210
    STA posicionRayo2Y
    LDA $0213
    STA posicionRayo2X

    RTS
dispararRayoE3:
    LDA $0208
    STA $0214
    LDA #$06
    STA $0215
    LDA #%00000011
    STA $0216
    LDA $020B
    STA $0217

    LDA $0214
    STA posicionRayo3Y
    LDA $0217
    STA posicionRayo3X

    RTS

dispararRayoE4:
    LDA $0208
    STA $0218
    LDA #$06
    STA $0219
    LDA #%00000011
    STA $021A
    LDA $020B
    STA $021B
    
    LDA $0218
    STA posicionRayo4Y
    LDA $021B
    STA posicionRayo4X



    RTS

;------------------------------------
;;segunda firma - animacion de disparos enemigo
;-------------------------------------
animarDisparosEnemigos:

animarDisparoE1:
    LDA $020C
    CLC
    ADC #4
    STA $020C
    STA posicionRayo1Y
    
    CMP #239
    BNE animarDisparE2

    ;;eliminar rayo
    LDA #$00
    STA $020C
    LDA #$00
    STA $020D
    LDA #%00000000
    STA $020E
    LDA #$00
    STA $020F

    STA posicionRayo1Y
    STA posicionRayo1X

animarDisparE2:
    LDA $0210
    CLC
    ADC #4
    STA $0210
    STA posicionRayo2Y

    ;;eliminar disparo 2
    LDA $0210
    CMP #239
    BNE animarDisparoE3

    LDA #00
    STA $0210
    LDA #$00
    STA $0211
    LDA #%00000000
    STA $0212
    LDA #00
    STA $0213
    STA posicionRayo2Y
    STA posicionRayo2X

animarDisparoE3:
    LDA $0214
    CLC
    ADC #4
    STA $0214
    STA posicionRayo3Y

    ;;eliminar disparo 3
    LDA $0214
    CMP #239
    BNE animarDisparE4

    LDA #00
    STA $0214
    LDA #$00
    STA $0215
    LDA #%00000000
    STA $0216
    LDA #00
    STA $0217
    STA posicionRayo3Y
    STA posicionRayo3X

animarDisparE4:
    LDA $0218
    CLC
    ADC #4
    STA $0218
    STA posicionRayo4Y

        ;;eliminar disparo 4
    LDA $0218
    CMP #239
    BNE salirDeAnimacion

    LDA #00
    STA $0218
    LDA #$00
    STA $0219
    LDA #%00000000
    STA $021A
    LDA #00
    STA $021B
    STA posicionRayo4Y
    STA posicionRayo4X

    ;;salir a el bucle del juego
salirDeAnimacion:
    RTS

;---------------------
;;;Tercer registro - lectura de botones
;---------------------

leerControles:

     ; Resetear todos los botones al inicio de cada frame
    LDA #$00
    STA botonAp
    STA botonBp
    STA botonSelect
    STA botonStart
    STA botonArriba
    STA botonAbajo
    STA botonIzq
    STA botonDer

    LDA #$01
    STA $4016
    LDA #$00
    STA $4016  
    
leerA:
    LDA $4016 
    AND #%00000001
    BNE guardarPulsacion1
    JMP leerADone

guardarPulsacion1:
    LDA #%00000001
    STA botonAp

leerADone:

leerB:
    LDA $4016 
    AND #%00000001
    BNE guardarPulsacion2
    JMP leerBHecho

guardarPulsacion2:
    LDA #%00000001
    STA botonBp

leerBHecho:

leerSelect:
    LDA $4016 
    AND #%00000001
    BNE guardarPulsacion3
    JMP leerSelectHecho

guardarPulsacion3:
    LDA #%00000001
    STA botonSelect

leerSelectHecho:

leerStart:
    LDA $4016 
    AND #%00000001
    BNE guardarPulsacion4
    JMP leerStartHecho

guardarPulsacion4:
    LDA #%00000001
    STA botonStart

leerStartHecho:

leerArriba:
    LDA $4016 
    AND #%00000001
    BNE guardarPulsacion5
    JMP leerArribaHecho

guardarPulsacion5:
    LDA #%00000001
    STA botonArriba

leerArribaHecho:

leerAbajo:
    LDA $4016 
    AND #%00000001
    BNE guardarPulsacion6
    JMP leerAbajoHecho

guardarPulsacion6:
    LDA #%00000001
    STA botonAbajo

leerAbajoHecho:

leerIzquierda:
    LDA $4016 
    AND #%00000001
    BNE guardarPulsacion7
    JMP leerIzquierdaHecho

guardarPulsacion7:
    LDA #%00000001
    STA botonIzq

leerIzquierdaHecho:

leerDerecha:
    LDA $4016 
    AND #%00000001
    BNE guardarPulsacion8
    JMP leerDerechaHecho

guardarPulsacion8:
    LDA #%00000001
    STA botonDer

leerDerechaHecho:
    RTS  ;;regresamos a el loop principal del juego

;---------------------
;;;cuarto registro - actualizacion de movimiento de nave
;---------------------

actualizarNave:

checarBotonA:
    LDA botonAp
    CMP #%00000001
    BNE checarBotonB
    
    LDA estadoDeDisparo
    CMP #$01
    BEQ checarBotonB  ;si hay un tile de rayo en la pantalla, pasa a checar si esta presinado B

crearTileRayo:
     LDA $0200 ;;tomamos la ubicacion en y de la nave
    STA $0204
    LDA #$04
    STA $0205
    LDA #%00000010
    STA $0206
    LDA $0203  ;;tomamos la ubicacion de x, es igual que la nave
    STA $0207

    LDA $0204
    STA posicionDisparoY
    LDA $0207
    STA posicionDisparoX

    LDA #$01
    STA estadoDeDisparo

checarBotonB:
    LDA botonBp
    CMP #%00000001
    BNE checarBotonSelect


checarBotonSelect:
    LDA botonSelect
    CMP #%00000001
    BNE checarBotonStart

checarBotonStart:
    LDA botonStart
    CMP #%00000001
    BNE checarBotonArriba

checarBotonArriba:
    LDA botonArriba
    CMP #%00000001
    BNE checarBotonAbajo

    LDA $0200
    ;chechar si se puede subir
    CMP #$01
    BEQ checarBotonAbajo
    
    CLC
    SEC
    SBC #01
    STA $0200
    STA posicionNaveY


checarBotonAbajo:
    LDA botonAbajo
    CMP #%00000001
    BNE checarBotonIzq

    LDA $0200
    ;chechar si se puede bajar
    CMP #232
    BEQ checarBotonIzq
    
    CLC
    ADC #01
    STA $0200
    STA posicionNaveY


checarBotonIzq:
    LDA botonIzq
    CMP #%00000001
    BNE checarBotonDer

    LDA $0203
    ;chechar si se puede ir a la izquierda
    CMP #$01
    BEQ checarBotonDer
    
    CLC
    SEC
    SBC #01
    STA $0203

    STA posicionNaveX

checarBotonDer:
    LDA botonDer
    CMP #%00000001
    BEQ DerAct
    RTS

DerAct:
DerAct:
    LDA $0203
    ;chechar si se puede ir a la izquierda
    CMP #247
    BEQ salir
    
    CLC
    ADC #01
    STA $0203
    STA posicionNaveX

salir:
    RTS ;;salir al loop del juego principal


;---------------------------------------------------
;Quinta firma - animar y destruir el disparo humano
;-----------------------------------------------------

animarDisparo:
    LDA $0204
    CLC
    SEC
    SBC #$01
    STA $0204
    STA posicionDisparoY

    CMP #$01
    BEQ eliminarRayo
    RTS
    
eliminarRayo:
    LDA #$00 ;;tomamos la ubicacion en y de la nave
    STA $0204
    LDA #$00
    STA $0205
    LDA #%00000000
    STA $0206
    LDA #$00  ;;tomamos la ubicacion de x, es igual que la nave
    STA $0207

    LDA #$00
    STA posicionDisparoX
    STA posicionDisparoY
    STA estadoDeDisparo
    RTS

;----------------------------------------------------------------
;sexta firma - sistema de colision nave humana-disparos enemigos
;----------------------------------------------------------------
checarColisionANaveHumana:

checarColisionRayo1:

    LDA posicionNaveX
    STA $300      ;;guardar la posicion del tile superior izquierda de la nave
    CLC
    ADC #$08
    STA $301   ;;guardar la posicion del tile superior derecha de la nave 

        ;;ver si la parte izquierda del rayo esta fuera de los 8 pixeles de la nave
    LDA posicionRayo1X    ;parti izquierda del rayo
    STA $302   
    CLC
    ADC #$08
    STA $303   ;aqui se guarda la parte derecha del tile del rayo

    ;;chechar si el rayo se sobrepone con el tile de la nave por izquierda
    LDA $303
    CMP $300
    BCC checarColisionRayo2

    ;;si es mayor, se checa la parte izquierda del rayo en la parte derecha de la nave
    LDA $302
    CMP $301
    BCS checarColisionRayo2


    ;------------------
    ;;probar en y
    ;------------------

    LDA posicionNaveY
    STA $304      ;;guardar la posicion del tile superior izquierda de la nave
    CLC
    ADC #$08
    STA $305   ;;guardar la posicion del tile superior derecha de la nave 

        ;;ver si la parte izquierda del rayo esta fuera de los 8 pixeles de la nave
    LDA posicionRayo1Y  ;parti izquierda del rayo
    STA $306   
    CLC
    ADC #$08
    STA $307   ;aqui se guarda la parte derecha del tile del rayo

    ;;chechar si el rayo se sobrepone con el tile de la nave por izquierda
    LDA $307
    CMP $304
    BCC checarColisionRayo2

    ;;si es mayor, se checa la parte izquierda del rayo en la parte derecha de la nave
    LDA $306
    CMP $305
    BCS checarColisionRayo2

    ;;se borra el tile de la nave
    JSR activarColision
    RTS

    

checarColisionRayo2:

    LDA posicionNaveX
    STA $306      ;;guardar la posicion del tile superior izquierda de la nave
    CLC
    ADC #$08
    STA $307   ;;guardar la posicion del tile superior derecha de la nave 

        ;;ver si la parte izquierda del rayo esta fuera de los 8 pixeles de la nave
    LDA posicionRayo2X    ;parti izquierda del rayo
    STA $308   
    CLC
    ADC #$08
    STA $309   ;aqui se guarda la parte derecha del tile del rayo

    ;;chechar si el rayo se sobrepone con el tile de la nave por izquierda
    LDA $309
    CMP $306
    BCC checarColisionRayo3

    ;;si es mayor, se checa la parte izquierda del rayo en la parte derecha de la nave
    LDA $308
    CMP $307
    BCS checarColisionRayo3


    ;------------------
    ;;probar en y
    ;------------------

    LDA posicionNaveY
    STA $30A      ;;guardar la posicion del tile superior izquierda de la nave
    CLC
    ADC #$08
    STA $30B   ;;guardar la posicion del tile superior derecha de la nave 

        ;;ver si la parte izquierda del rayo esta fuera de los 8 pixeles de la nave
    LDA posicionRayo2Y  ;parti izquierda del rayo
    STA $30C  
    CLC
    ADC #$08
    STA $30D   ;aqui se guarda la parte derecha del tile del rayo

    ;;chechar si el rayo se sobrepone con el tile de la nave por izquierda
    LDA $30D
    CMP $30A
    BCC checarColisionRayo3

    ;;si es mayor, se checa la parte izquierda del rayo en la parte derecha de la nave
    LDA $30C
    CMP $30B
    BCS checarColisionRayo3

    ;;se borra el tile de la nave
    JSR activarColision
    RTS

checarColisionRayo3:

    LDA posicionNaveX
    STA $30E      ;;guardar la posicion del tile superior izquierda de la nave
    CLC
    ADC #$08
    STA $30F   ;;guardar la posicion del tile superior derecha de la nave 

        ;;ver si la parte izquierda del rayo esta fuera de los 8 pixeles de la nave
    LDA posicionRayo3X    ;parti izquierda del rayo
    STA $310   
    CLC
    ADC #$08
    STA $311   ;aqui se guarda la parte derecha del tile del rayo

    ;;chechar si el rayo se sobrepone con el tile de la nave por izquierda
    LDA $311
    CMP $30E
    BCC checarColisionRayo4

    ;;si es mayor, se checa la parte izquierda del rayo en la parte derecha de la nave
    LDA $310
    CMP $30F
    BCS checarColisionRayo4

    ;------------------
    ;;probar en y
    ;------------------

    LDA posicionNaveY
    STA $312      ;;guardar la posicion del tile superior izquierda de la nave
    CLC
    ADC #$08
    STA $313   ;;guardar la posicion del tile superior derecha de la nave 

        ;;ver si la parte izquierda del rayo esta fuera de los 8 pixeles de la nave
    LDA posicionRayo3Y  ;parti izquierda del rayo
    STA $314  
    CLC
    ADC #$08
    STA $315   ;aqui se guarda la parte derecha del tile del rayo

    ;;chechar si el rayo se sobrepone con el tile de la nave por izquierda
    LDA $315
    CMP $312
    BCC checarColisionRayo4

    ;;si es mayor, se checa la parte izquierda del rayo en la parte derecha de la nave
    LDA $314
    CMP $313
    BCS checarColisionRayo4

    ;;se borra el tile de la nave
    JSR activarColision
    RTS

checarColisionRayo4:

    LDA posicionNaveX
    STA $316      ;;guardar la posicion del tile superior izquierda de la nave
    CLC
    ADC #$08
    STA $317   ;;guardar la posicion del tile superior derecha de la nave 

        ;;ver si la parte izquierda del rayo esta fuera de los 8 pixeles de la nave
    LDA posicionRayo4X    ;parti izquierda del rayo
    STA $318   
    CLC
    ADC #$08
    STA $319   ;aqui se guarda la parte derecha del tile del rayo

    ;;chechar si el rayo se sobrepone con el tile de la nave por izquierda
    LDA $319
    CMP $316
    BCC salir4

    ;;si es mayor, se checa la parte izquierda del rayo en la parte derecha de la nave
    LDA $318
    CMP $317
    BCS salir4


    ;------------------
    ;;probar en y
    ;------------------

    LDA posicionNaveY
    STA $31A      ;;guardar la posicion del tile superior izquierda de la nave
    CLC
    ADC #$08
    STA $31B   ;;guardar la posicion del tile superior derecha de la nave 

        ;;ver si la parte izquierda del rayo esta fuera de los 8 pixeles de la nave
    LDA posicionRayo4Y  ;parti izquierda del rayo
    STA $31C  
    CLC
    ADC #$08
    STA $31D ;aqui se guarda la parte derecha del tile del rayo

    ;;chechar si el rayo se sobrepone con el tile de la nave por izquierda
    LDA $31D
    CMP $31A
    BCC salir4

    ;;si es mayor, se checa la parte izquierda del rayo en la parte derecha de la nave
    LDA $31C
    CMP $31B
    BCS salir4

    ;;se borra el tile de la nave
    JSR activarColision

salir4:
    RTS

;-----------------------------------------------------------------------------------
;septima firma - checar colision disparo a nave enemiga
;------------------------------------------------------------------------------------
checarColisionDisparo:

   
    

    LDA posicionNaveEnemigaX
    STA $300      ;;guardar la posicion del tile superior izquierda de la nave
    CLC
    ADC #$08
    STA $301   ;;guardar la posicion del tile superior derecha de la nave 

    LDA posicionDisparoX
    CLC 
    ADC #$2    ;sumar 2 para estrechar el tile del disparo, para que su esquina izquierda inicie en el rato
    STA $302   
    CLC
    ADC #$02
    STA $303   ;aqui se guarda la parte derecha del tile del rayo

    ;;chechar si el rayo se sobrepone con el tile de la nave por izquierda
    LDA $303
    CMP $300
    BCC salir3

    ;;si es mayor, se checa la parte izquierda del rayo en la parte derecha de la nave
    LDA $302
    CMP $301
    BCS salir3


    ;------------------
    ;;probar en y
    ;------------------

    LDA posicionNaveEnemigaY
    STA $304      ;;guardar la posicion del tile superior izquierda de la nave
    CLC
    ADC #$08
    STA $305   ;;guardar la posicion del tile superior derecha de la nave 

        ;;ver si la parte izquierda del rayo esta fuera de los 8 pixeles de la nave
    LDA posicionDisparoY ;parti izquierda del rayo
    STA $306   
    CLC
    ADC #$08
    STA $307   ;aqui se guarda la parte derecha del tile del rayo

    ;;chechar si el rayo se sobrepone con el tile de la nave por izquierda
    LDA $307
    CMP $304
    BCC salir3

    ;;si es mayor, se checa la parte izquierda del rayo en la parte derecha de la nave
    LDA $306
    CMP $305
    BCS salir3

    ;;se borra el tile de la nave
    JSR activarColisionNaveEnemiga

salir3:
    RTS

;-----------------------------------------------------------------------------------
;octava firma firma - creacion de numero random 
;------------------------------------------------------------------------------------
generarNumeroAleatorioX:

crearXrandom:
    ;crear un numero random
    LDA semillaX
    LSR A
    BCC saltarXor1
    EOR #$D4
saltarXor1:
    LSR A
    BCC saltarXor2
    EOR #$4C

saltarXor2:
    STA randomX
    STA semillaX

    RTS
;-----------------------------------------------
;novena firma - nueva posicion de nave enemiga
;------------------------------------------------

teletransportarseNaveEnemiga:
    LDA timer
    CMP #120
    BNE cambiarCicloGeneral

    LDA randomX
    STA $020B
    STA posicionNaveEnemigaX

cambiarCicloGeneral:
    RTS

;------------------------------------------------
; Metodo para actualizar prueba
;------------------------------------------------
actualizarPrueba:
    LDA timerDeActualizacion
    CMP #30
    BNE salirPrueba

    ;suma de animacion
    LDA $021C
    CLC
    ADC #$1
    STA $021C

    LDA $0220
    CLC
    ADC #$1
    STA $0220

    LDA $0224
    CLC 
    ADC #$1
    STA $0224

    LDA $0228
    CLC 
    ADC #$1
    STA $0228

    LDA #$00
    STA timerDeActualizacion

salirPrueba:

    RTS

;-----------------------
;firmas de uso general
;------------------------

activarColision:

 ;;se borra el tile de la nave
    LDA #10
    STA $0200
    LDA #$03
    STA $0201
    LDA #%00000001
    STA $0202
    LDA #10
    STA $0203

    LDA $200
    STA posicionNaveY
    LDA $0203
    STA posicionNaveX

    RTS

activarColisionNaveEnemiga:
    ;;imprimir sprite de nave enemigo
    LDA #00
    STA $0208
    STA posicionNaveEnemigaY
    LDA #$00
    STA $0209
    LDA #%00000000
    STA $020A
    LDA #00
    STA $020B
    STA posicionNaveEnemigaX
    
    LDA #$01
    STA estadoNaveEnemiga1  ;;actualizar el estado de la nave a 1, que significa destruida

        LDA #$00 ;;tomamos la ubicacion en y de la nave
    STA $0204
    LDA #$00
    STA $0205
    LDA #%00000000
    STA $0206
    LDA #$00  ;;tomamos la ubicacion de x, es igual que la nave
    STA $0207

    LDA #$00
    STA posicionDisparoX
    STA posicionDisparoY
    STA estadoDeDisparo  ;;actualizamos el estado del disparo a 0, que significa que no hay disparp

    RTS

NMI:
    ;-------------------------------
    ;------------------------------
    ;;experimentar con los fondoooos
    ;-------------------------------
    ;-------------------------------

    ; Establecer bandera de VBlank
    LDA #$01
    STA vblank_occurred

    LDA #$00
    STA $2005
    STA $2005


    ; Transferir datos de sprites mediante DMA
    LDA #$00
    STA $2003   ; Dirección baja de OAM
    LDA #$02
    STA $4014   ; Iniciar transferencia DMA desde la página $0200


    RTI



  .bank 1
  .org $E000
paletas:
  .db $0F, $20, $16, $29
  .db $0F, $07, $06, $2C  
  .db $0F, $31, $20, $02   
  .db $0F, $06, $2A, $26   

fondo:
    .db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
    .db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
    .db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
    .db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
    .db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
    .db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $01, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
    .db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $02, $00, $00, $00, $00
    .db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
    .db $00, $00, $00, $02, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
    .db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
    .db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
    .db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
    .db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
    .db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
    .db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $01, $00, $00, $00, $00, $00, $00, $00, $00
    .db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
    .db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
    .db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
    .db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
    .db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
    .db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
    .db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $02, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
    .db $00, $00, $00, $00, $00, $00, $01, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
    .db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
    .db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
    .db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
    .db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
    .db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
    .db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
    .db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00


  .org $FFFA
  .dw NMI
  .dw RESET
  .dw 0

  .bank 2
  .org $0000

;tile fondo negro
 .db $00, $00
 .db $00, $00
 .db $00, $00
 .db $00, $00
 .db $00, $00
 .db $00, $00
 .db $00, $00
 .db $00, $00

 ;tile estrella amarilla
 .db $18, $18, $3C, $FF, $FF, $3C, $18, $18
 .db $18, $18, $3C, $FF, $FF, $3C, $18, $18

 ;tile estrella roja
 .db $00, $00, $00, $00, $00, $00, $00, $00
 .db $3C, $42, $BD, $BD, $BD, $BD, $42, $3C

;tile de nave espacial
 .db $18, $18, $3C, $3C, $BD, $FF, $C3, $81
 .db $18, $00, $00, $00, $00, $00, $18, $18

 ;;tile de rayo 
 .db $18, $3C, $3C, $18, $18, $18, $18, $18
 .db $00, $00, $00, $00, $00, $00, $00, $00

 ;;tile de naves enemigas
 .db $00, $00, $00, $3C, $3C, $00, $00, $00
 .db $18, $3C, $7E, $7E, $7E, $7E, $3C, $18

  ;tile de disparo enemigo
 .db $00, $00, $00, $00, $00, $00, $00, $00
 .db $C3, $24, $99, $42, $3C, $81, $42, $3C

 CHRSprite:
    .incbin "luna.chr"
