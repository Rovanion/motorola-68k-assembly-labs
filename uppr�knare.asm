;;; Reset the machinery!
RESET	CLR.L D0
	CLR.L D1
	CLR.L D2
	CLR.L D3
	CLR.L D4
	CLR.L D5
	CLR.L D6
	CLR.L D7
	MOVE.L #SJUSTEG,A0
	MOVE.L #KLOCKINTERRUPT,$68 ; Run this function on interrupt at CRB.
	MOVE.L #MUXINTERRUPT,$74   ; Run this function on interrupt at CRA.
	;; Setup of PIA.
	CLR.B $10084		; Set PIA to config mode.
	MOVE.B #%01111111,$10080
	MOVE.B #$04,$10084	; Set PIAA to output mode and enable CRA.
	CLR.B $10086		; Set PIA to config mode.
	MOVE.B #%00000011,$10082
	MOVE.B #$05,$10086	; Set PIAB to output mode and enable CRB.
	AND.W #$F8FF,SR		; Turn on interrupts.
	;; A0 contains the address to the SJUSTEG table.
	;; D0-3 holds the value of the time.
	;; D4 is the counter which keeps track of which 7-segment display we are on.
IDLE	MOVE.B #%00,$10082
	MOVE.B (A0,D0.W),$10080
	MOVE.B #%01,$10082
	MOVE.B (A0,D1.W),$10080
	MOVE.B #%10,$10082
	MOVE.B (A0,D2.W),$10080
	MOVE.B #%11,$10082
	MOVE.B (A0,D3.W),$10080
	JMP IDLE
	
;;; Function called when the clock interrupts the processor
KLOCKINTERRUPT
	TST.B $10082		; Reset the interrupt bit
	BSR ENSEKUND
	RTE
ENSEKUND
	ADD.B #1,D0
	CMP #10,D0
	BEQ TIOSEKUND
	RTS
TIOSEKUND
	CLR D0
	ADD.B #1,D1
	CMP #6,D1
	BEQ ENMINUT
	RTS
ENMINUT
	CLR D1
	ADD.B #1,D2
	CMP #10,D2
	BEQ TIOMINUT
	RTS
TIOMINUT
	CLR D2
	ADD.B #1,D3
	CMP #6,D3
	BEQ NOLLATIOMINUT
	RTS
NOLLATIOMINUT
	CLR D3
	RTS

MUXINTERRUPT
	RTE

	;; TODO: Fånga upp avbrotten
	;; TODO: Avkoda den decadecimala siffran i registren och skriv rätt konstant till PIA.
	

;;; Define a bunch of constants.
SJUSTEG	DC.B $3F 		; '0'
	DC.B $06		; '1'
	DC.B $5B		; '2'
	DC.B $84		; '3'
	DC.B $66		; '4'
	DC.B $6D		; '5'
	DC.B $7D		; '6'
	DC.B $07		; '7'
	DC.B $7F		; '8'
	DC.B $64		; '9'

	