RESET	MOVE.B D1,$10082
	MOVE.B D1,$10082
	CLR.L D0
	CLR.L D1
	CLR.L D2
	CLR.L D3
	CLR.L D4
	CLR.L D5
	CLR.L D6
	CLR.L D7
	;; In order to reset PIA
	CLR.B $10084
	MOVE.B #$00,$10080
	MOVE.B #$04,$10084
	CLR.B $10086
	MOVE.B #$FF,$10082
	MOVE.B #$04,$10086
	;; First loop while waiting for the init signal
IDLE	CMP.B #$FF,$10080
	BEQ GOTIME
	JMP IDLE
	
	;; Wait and then theck if the signal is still on.
GOTIME	BSR DELAY
	;; Is it is off, go back to idle.
	CMP.B #$FF,$10080
	BEQ READATA
	JMP IDLE
	
	;; Read the four bits of data sent to us over IR.
READATA	CLR.L D0	; The final output
	CLR.L D1	; Temporary storage
	CLR.L D2 	; Set our counter D2 to 0
READ	BSR DELAY
	BSR DELAY
	BSR AVKODA
	ADD #1,D2	; Increse the counter by 1
	CMP.B #04,D2	; Have we gone 4 times?
	BNE READ
	MOVE.B D0,$10082
	MOVE.B $10082,D6
	BSR DELAY
	JMP IDLE

AVKODA  MOVE.B $10080,D1
	AND #1,D1
	LSL D2,D1	; Shift left counter steps
	OR D1,D0	; Move the one bit into D0
	RTS
	
	;; A delay routine that waits for T/2 time.
DELAY	MOVE.L #35,D7
DEL2	BSET #7,$10082
	SUB.L #1,D7
	BNE.S DEL2
	BCLR #7,$10082
	RTS

EXIT	MOVE.B #228,D7
	TRAP #14

	