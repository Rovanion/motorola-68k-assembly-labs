RESET	CLR.L D0
	CLR.L D1
	CLR.L D2
	CLR.L D3
	CLR.L D4
	CLR.L D5
	CLR.L D6
	CLR.L D7
	;; In order to reset PIA
	CLR.B $10084
	MOVE.B #$FF,$10080
	MOVE.B #$04,$10084
	CLR.B $10086
	MOVE.B #$FF,$10082
	MOVE.B #$04,$10086
	LEA $8000,A7		; Set the stackpointer to $8000.
	LEA $6000,A0		; Set A0 to point to the string we want to read.
	;	MOVE.L #$534F5300,$6000	; Set SOS to address $6000.
	MOVE.B #$AF,$7104	; Some arbitrary number. (N)
TABLE	MOVE.B #$00,$7020
	LEA $7041,A1
	MOVE.B #$60,(A1)+
	MOVE.B #$88,(A1)+
	MOVE.B #$A8,(A1)+
	MOVE.B #$90,(A1)+
	MOVE.B #$40,(A1)+
	MOVE.B #$28,(A1)+
	MOVE.B #$D0,(A1)+
	MOVE.B #$08,(A1)+
	MOVE.B #$20,(A1)+
	MOVE.B #$78,(A1)+
	MOVE.B #$B0,(A1)+
	MOVE.B #$48,(A1)+
	MOVE.B #$E0,(A1)+
	MOVE.B #$A0,(A1)+
	MOVE.B #$F0,(A1)+
	MOVE.B #$68,(A1)+
	MOVE.B #$D8,(A1)+
	MOVE.B #$50,(A1)+
	MOVE.B #$10,(A1)+
	MOVE.B #$C0,(A1)+
	MOVE.B #$30,(A1)+
	MOVE.B #$18,(A1)+
	MOVE.B #$70,(A1)+
	MOVE.B #$98,(A1)+
	MOVE.B #$B8,(A1)+
	MOVE.B #$C8,(A1)+
	MOVE.B #$6C,(A1)+
	MOVE.B #$58,(A1)+
	MOVE.B #$E8,(A1)+
	MOVE.B #$FC,(A1)+
	MOVE.B #$7C,(A1)+
	MOVE.B #$3C,(A1)+
	MOVE.B #$1C,(A1)+
	MOVE.B #$0C,(A1)+
	MOVE.B #$04,(A1)+
	MOVE.B #$84,(A1)+
	MOVE.B #$C4,(A1)+
	MOVE.B #$E4,(A1)+
	MOVE.B #$F4,(A1)+
	MOVE.B #$56,(A1)+
	MOVE.B #$CE,(A1)+
	MOVE.B #$E2,(A1)+
	MOVE.B #$AA,(A1)+
	MOVE.B #$32,(A1)+
	MOVE.B #$7A,(A1)+
	MOVE.B #$86,(A1)+
	MOVE.B #$94,(A1)+
	MOVE.B #$B4,(A1)+
	MOVE.B #$B6,(A1)+
	MOVE.B #$A4,(A1)+
	MOVE.B #$8C,(A1)+
	;; D0 contains the next character
	;; D1 contains the length of the next beep
	;; D2 contains wether or beep or not
	;; D3 contains the tone of the beep
;;; Read the next character.
NEXTCHAR
	MOVE.B #$00,$10080
	MOVE.B (A0)+,D0	    	; D0 contains the next character.
	CMP.B #0,D0 		; Compare to termination charer.
	BEQ END			; If equal, end transmission.
	BSR LOOKUP		; Otherwise: Look up the character.
	CMP.B #0,D0		; If the caracter doesn't exist, read next.
	BEQ BLANK
	BSR SEND		; Otherwise send the character.
	BSR NEXTCHAR		; Read the next character.
	
;;; Looks up a characters morse code in the table.
LOOKUP	LEA $7000,A1
	AND.W #$00ff,D0
	MOVE.B (A1,D0.W),D0
	RTS

;;; Send the character
SEND	MOVE.B $7104,D1
	; Left shift the register containing the morse code for the char.
	LSL.B #1,D0		; If there is only a ane left in the register;
	BEQ READY		
	BCC DOT			; If outputting a dot, skip the next row.
DASH	MULU #3,D1		; A dash is 3 times as long as a dot.
DOT	MOVE.B #1,D2		; Make a sound.
	BSR BEEP
	MOVE.B $7104,D1
	MOVE.B #0,D2		; Silence!
	BSR BEEP
	BRA SEND
READY	ASL.L #1,D1
	MOVE.B #0,D2		; Silence!
	BSR BEEP
	RTS
	
;; Sends the current character
BEEP	CMP.B #1,D2
	SEQ $10082
	BSR DELAY
	CLR $10082
	BSR DELAY
	SUBQ.L #1,D1
	BNE BEEP
	RTS
	
;;; The tiny tiny delay which defines the frequenzy of the tone.
DELAY	MOVE.L #50,D3 		; We wait around for 100*2 clock cycles (T)
WAITLOOP
	SUBQ.L #1,D3
	BNE WAITLOOP
	RTS
;;; Function to write the blank between words.
BLANK	MOVE.B $7104,D1
	MULU #4,D1
	MOVE.B #0,D2
	BSR BEEP
	BRA NEXTCHAR

	;;; Ends the program as a whole.
END	MOVE.B #228,D7
	TRAP #14


	