TITLE Designing low-level I/O procedures     (Proj4_greenede.asm)

; Author: Derek Greene
; Last Modified: 6/1/2024
; OSU email address: greenede@oregonstate.edu
; Course number/section:   CS271 Section [400]
; Project Number: 6                Due Date: 6/9/24
; Description: Program displays title and programmers name, followed by an introduction explaining the
;              program. Program then prompts user to enter 10 signed decimal integers in range of 32 bits/number.
;              Input is read in as a string and converted from ASCII to decimal. Each input is then checked for if it is valid.
;              If it is not valid, the program will display an error message and prompt the user to re-enter the number.
;              If the number is valid, it is stored in an array. The program then displays the numbers entered, followed by the sum
;              and average for the values inputed. Results are converted to ASCII and then displayed to the user along with a list
;              of the numbers entered. The program then displays a goodbye message and exits.

INCLUDE Irvine32.inc

; constant definitions for 32 bit range [-2147483648, 2147483647]
LO equ 2147483648  ; (2^31) -> unsigned, which is effectively -2^31 signed
HI equ 2147483647  ; (2^31 - 1)

; ---------------------------------------------------------------------------------
; Name: mGetString
; 
; Displays a message to the user, reads a string of characters from 
; input, and stores in a specified buffer. It also records the number of bytes read.
;
; Preconditions: Buffer provided is large enough to store input
;
; Receives:
;   msg - message to display to user
;   buffer - buffer to store input
;   bufSize - size of buffer
;   Bytes - number of bytes read
;
; Returns: Input string in buffer, number of bytes read in bytes variable
; ---------------------------------------------------------------------------------
mGetString MACRO msg, buffer, bufSize, Bytes
    push    EAX
    push    ECX
    push    EDX
    mov     EDX, msg
    call    WriteString
    mov     EDX, buffer
    mov     ECX, bufSize
    call    ReadString
    mov     Bytes, EAX
    pop     EDX
    pop     ECX
    pop     EAX
ENDM

; ------------------------------------------
; Name: mDisplayString
;
; Displays a message to the user.
;
; Receives:
;   msg - address of the message to display
; ------------------------------------------
mDisplayString MACRO msg
    push    EDX
    mov     EDX, msg
    call    WriteString
    pop     EDX
ENDM

.data
programTitle        BYTE    "PROGRAMMING ASSIGNMENT 6: Designing low-level I/O procedures     by Derek Greene",0
instruct1           BYTE    "Enter 10 signed decimal integers.",0
instruct2           BYTE    "Numbers need to be small enough to fit in a 32 bit register. Program will then display a list ",0
instruct3           BYTE    "of the numbers, their sums, and average values.",0
userInputMsg        BYTE    "Enter a signed number: ",0
invalidInput        BYTE    "Invalid input! Please enter a signed number that can fit in a 32 bit register. ",0
numList             BYTE    "The numbers you entered are: ",0
sumMsg              BYTE    "The sum of the numbers is: ",0
avgMsg              BYTE    "The truncated average of the numbers is: ",0
goodbyeMsg          BYTE    "Goodbye!",0
buffer              BYTE    100 DUP(?)          ;10 up to 10-digit long numbers
decimalArray        DWORD   10 DUP(?)
asciiArray          BYTE    100 DUP(?)
bytesArray          DWORD   10 DUP(?)
bytes               DWORD   ?
userInput           SDWORD  ?
negate              DWORD   0
counter             DWORD   0      
sum                 DWORD   0
sumBuffer           BYTE    11 DUP(?)
sumDigits           DWORD   0
avgBuffer           BYTE    11 DUP(?)
firstChar           DWORD   ?

.code
; ---------------------------------------------------------------------
; Name: Introduction
;
; Displays the program title, decription, and instructions to the user.
;
; Postconditions: title, description, and instructions are displayed
;
; Receives:
;   [EBP+8]   programTitle - title of the program
;   [EBP+12]  instruct1 - first instruction
;   [EBP+16]  instruct2 - second instruction
;   [EBP+20]  instruct3 - third instruction
;
; Changes Registers: EBP, EDX
; ----------------------------------------------------------------------
Introduction    PROC
    push    EBP
    mov     EBP, ESP
    mDisplayString [EBP+8]      ; OFFSET programTitle
    call    Crlf
    call    Crlf    
    mDisplayString [EBP+12]     ; OFFSET instruct1
    call    Crlf
    mDisplayString [EBP+16]     ; OFFSET instruct2
    call    Crlf
    mDisplayString [EBP+20]     ; OFFSET instruct3
    call    Crlf
    call    Crlf
    pop     EBP
    ret     16
Introduction    ENDP


; -----------------------------------------------------------------------------------------
; Name: ReadVal
;
; Reads a string input from the user, then validates it in the range of 32 bits.
; If out of range, an error message is displayed, otherwise, the value is stored in
; an a array. Values are also converted from ASCII to their decimal representations.
;
; Postconditions: if input is valid, value is stored in decimalArray otherwise,
; error message is displayed
;
; Receives:
;   [EBP+8]   OFFSET invalidInput - address of invalid input message
;   [EBP+12]  OFFSET userInputMsg - address of user input message
;   [EBP+16]  OFFSET buffer - address of buffer for user input
;   [EBP+20]  OFFSET bytes - address of the variable storing number of bytes read
;   [EBP+24]  OFFSET buffer - address of buffer containing the input string
;   [EBP+28]  OFFSET counter - address of the variable tracking number of valid inputs
;   [EBP+32]  OFFSET decimalArray - address of the array storing valid integers
;   [EBP+36]  OFFSET negate - address of the variable indicating if the number is negative
;   [EBP+40]  SIZEOF buffer - size of the buffer
;   [EBP+44]  OFFSET firstChar - address of the first character of the input string
;
; Returns: decimalArray is appended with valid integers
;
; Changes Registers: EAX, EBX, ECX, EDX, ESI, EDI, EBP
; -----------------------------------------------------------------------------------------
ReadVal     PROC
    push    EBP
    mov     EBP,ESP
    push    EAX
    push    EBX
    push    ECX
    push    EDI
    push    ESI
    push    EDX                                                    
    push    EAX
    mov     EAX, [EBP+36]        ; OFFSET negate
    mov     DWORD PTR [EAX], 0   ; Reset negate var 0         
    pop     EAX
    jmp     _skipError
_invalidInput:
    mDisplayString [EBP+8]       ; OFFSET invalidInput
    push    EAX
    mov     EAX, [EBP+36]        ; OFFSET negate
    mov     DWORD PTR [EAX], 0   ; Reset negate var 0  
    pop     EAX
    call    Crlf
_skipError:
    mGetString [EBP+12], [EBP+16], [EBP+40], [EBP+20]       ; [EBP+12] = OFFSET userInputMsg, [EBP+16] = OFFSET buffer, [EBP+40] = SIZEOF buffer, [EBP+20] = OFFSET bytes
    mov     ECX, DWORD PTR [EBP+20] ; OFFSET bytes
    mov     ESI, [EBP+24]         ; OFFSET buffer
    push    EDX
    mov     EDX, [EBP+28]         ; OFFSET counter
    mov     EBX, DWORD PTR [EDX]
    pop     EDX
    push    EDX
    mov     EDX, [EBP+32]         ; OFFSET decimalArray
    mov     DWORD PTR [EDX+EBX*4], ECX
    pop     EDX
    imul    EDI, EBX, 4
    add     EDI, [EBP+32]         ; OFFSET decimalArray
    xor     EDX, EDX              
    xor     EAX, EAX              
    xor     EBX, EBX              ; EBX to count digits
    jmp     _firstChar
_skipNegativeSign:
    lodsb                         ; Load next character from array
    sub     AL, '0'
    push    EDX
    mov     EDX, [EBP+44]         ; OFFSET firstChar
    mov     DWORD PTR [EDX], EAX
    pop     EDX
    sub     ESI, 1
    pop     EAX
    jmp     _validate
_firstChar:
    lodsb                       ; Load first character from array
    push    EAX
    cmp     AL, '-'
    je      _skipNegativeSign 
    sub     AL, '0'
    push    EDX
    mov     EDX, [EBP+44]       ; OFFSET firstChar
    mov     DWORD PTR [EDX], EAX
    pop     EDX
    pop     EAX
    jmp     _validate
_convertToDec:
    lodsb                       ; Load next character from array
_validate:
    cmp     AL, 43
    je      _skipNegate
    cmp     AL, 45
    je      _setNegate
    jmp     _nextCheck
_setNegate:
    push    EDX
    mov     EDX, 1
    push    EAX
    mov     EAX, [EBP+36]      ; OFFSET negate
    mov     DWORD PTR [EAX], EDX
    pop     EAX
    pop     EDX
    dec     ECX
    jmp     _convertToDec
_nextCheck:
    cmp     AL, 48
    jl      _invalidInput
    cmp     AL, 57
    jg      _invalidInput
_valid: 
    sub     AL, '0'               ; Convert AL value
    imul    EDX, EDX, 10
    add     EDX, EAX
    inc     EBX                   ; Count number of digits
_skipNegate:
    loop    _convertToDec
    cmp     EBX, 10                ; Check > 10 digits = invalid
    jg      _invalidInput
    je      _10digits
    cmp     EBX, 9                ; Check =< 9 digits
    jle     _validate_range     
_10digits:
    mov     EAX, [EBP+44]         ; OFFSET firstChar
    mov     EAX, DWORD PTR [EAX]
    cmp     AL, 2
    jg      _invalidInput         ; If first digit not = 2, invalid
_validate_range:
    mov     EAX, EDX
    push    EAX
    mov     EAX, [EBP+36]         ; OFFSET negate
    mov     EDX, DWORD PTR [EAX]         
    pop     EAX
    cmp     EDX, 0
    je      _positive
    mov     EDX, EAX
    cmp     EDX, LO
    ja     _invalidInput
    neg     EAX
    jmp     _store
_positive:
    cmp     EAX, HI
    ja      _invalidInput
_store:
    push    EDX
    mov     EDX, [EBP+28]          ; OFFSET counter
    inc     DWORD PTR [EDX]
    pop     EDX
    stosd                          ; Store EAX into decimalArray
    add     EDI, 4
    pop     EDX
    pop     ESI
    pop     EDI
    pop     ECX
    pop     EBX
    pop     EAX
    pop     EBP
    ret     40
ReadVal     ENDP


; -------------------------------------------------------------------------------------------
; Name: WriteVal
;
; Converts integers from a given array to their ASCII  string representations and 
; stores them in another array. It handles negative numbers and separates the 
; integers with commas and spaces.
; 
; Preconditions: decimalArray contains valid integers
;
; Postconditions: integers in array are converted to strings and stored in asciiArray,
;                 strings are seperated by a comma and space and are null-terminated.
;
; Receives:
;   [EBP+8]   OFFSET decimalArray - address of the array of integers
;   [EBP+12]  OFFSET asciiArray - address of the array where ASCII strings will be stored
;   [EBP+16]  OFFSET numList - address of the message to display before the ASCII array
;   [EBP+20]  OFFSET counter - address of the variable tracking number of processed integers
;   [EBP+24]  OFFSET bytesArray - address of the array of byte counts for each integer
;
; Changes Registers: EAX, EBX, ECX, EDX, ESI, EDI, EBP
; -------------------------------------------------------------------------------------------
WriteVal PROC
    push    EBP
    mov     EBP, ESP
    sub     ESP, 64                ; Space on stack for local vars and buffer
    push    EAX
    push    EBX
    push    ECX
    push    EDX
    push    ESI
    push    EDI
    mov     ESI, [EBP+8]           ; OFFSET decimalArray
    mov     ECX, 10                ; Number integers to process
    mov     EDI, [EBP+12]          ; OFFSET asciiArray
    push    EDX
    mov     EDX, [EBP+20]          ; OFFSET counter
    mov     DWORD PTR [EDX], 0
    pop     EDX
_processLoop:
    mov     EAX, [ESI]             
    lea     EBX, [EBP-32]          ; Point EBX to local buffer
    mov     DWORD PTR [EBP-4], EBX ; Save buffer pointer
    push    EDX
    mov     EDX, [EBP+20]          ; OFFSET counter
    mov     EBX, DWORD PTR [EDX]   ; Load current counter value
    pop     EDX
    mov     EDX, [EBP+24]                ; OFFSET bytesArray
    mov     ECX, DWORD PTR [EDX+EBX*4]   
    mov     DWORD PTR [EBP-8], 0         
    cmp     EAX, 0
    jge     _convertToDec
    neg     EAX
    mov     BYTE PTR [EDI], '-'    ; Store '-' for negative numbers
    inc     EDI
_convertToDec:
    xor     EDX, EDX               
    mov     EBX, 10                
    div     EBX                    ; EAX = EAX / 10, EDX = EAX % 10 (remainder is the digit)
    add     DL, '0'                
    push    EDX                    
    inc     DWORD PTR [EBP-8]      ; Increment digit count
    cmp     EAX, 0
    jnz     _convertToDec
_popDigits:
    mov     EAX, [EBP-8]           
    mov     EBX, [EBP-4]           ; Restore buffer pointer
_popLoop:
    dec     EAX                    ; Decrement digit count
    jl      _nextNumber
    pop     EDX                    ; Pop the digit from the stack
    mov     [EDI], DL              
    inc     EDI
    jmp     _popLoop
_nextNumber:
    push    EAX
    push    EDX
    mov     EDX, [EBP+20]          ; OFFSET counter
    mov     EAX, DWORD PTR [EDX]   ; Current counter value
    pop     EDX
    cmp     EAX, 9                 ; Check if last number
    pop     EAX
    je      _finish
    mov     BYTE PTR [EDI], ','
    inc     EDI
    mov     BYTE PTR [EDI], ' '
    inc     EDI
    push    EDX
    mov     EDX, [EBP+20]          ; OFFSET counter
    inc     DWORD PTR [EDX]   
    pop     EDX
    add     ESI, 4                 ; Move to next integer in array
    jmp     _processLoop
_finish:
    mov     BYTE PTR [EDI], 0      ; Null-terminate string
    call    Crlf
    mDisplayString [EBP+16]        ; OFFSET numList
    mDisplayString [EBP+12]        ; OFFSET asciiArray
    call    Crlf    
    pop     EDI
    pop     ESI
    pop     EDX
    pop     ECX
    pop     EBX
    pop     EAX
    add     ESP, 64              ; Free local stack space
    pop     EBP
    ret     20
WriteVal ENDP


; -------------------------------------------------------------------------------------------------
; Name: CalcSum
;
; Calculates the sum of integers from a given array, converts the sum to its ASCII
; string representation, and stores it in a provided buffer.
;
; Preconditions: decimalArray contains valid integers
;
; Postconditions: sum of integers is calculated and stored in sumBuffer as ASCII string,
;                 string is null-terminated 
; Receives:
;   [EBP+8]   OFFSET decimalArray - address of the array of integers
;   [EBP+12]  OFFSET sumBuffer - address of the buffer where the ASCII sum will be stored
;   [EBP+16]  OFFSET sumMsg - address of the message to display before the sum
;   [EBP+20]  OFFSET sumDigits - address of the variable tracking the number of digits in the sum
;
; Changes Registers: EAX, EBX, ECX, EDX, ESI, EBP
; ------------------------------------------------------------------------------------------------
CalcSum PROC
    push    EBP
    mov     EBP, ESP
    push    EAX
    push    EBX
    push    ECX
    push    EDX
    push    ESI 
    xor     EAX, EAX             
    mov     ECX, 10              ; Number elements in array
    mov     ESI, [EBP+8]         ; OFFSET decimalArray
_SumLoop:
    add     EAX, [ESI]           
    add     ESI, 4               
    loop    _SumLoop
    mov     EBX, EAX             ; Move sum to EBX for conversion
    mov     ESI, [EBP+12]        ; OFFSET sumBuffer
    cmp     EBX, 0
    jne     _convertLoop
    mov     BYTE PTR [ESI], '0'  ; Special case for zero
    inc     ESI
    jmp     _endConvert
_convertLoop: 
    xor     EDX, EDX             
    mov     ECX, 10              
    div     ECX                  ; EAX = EBX / 10, EDX = EBX % 10 (remainder is the digit)
    add     DL, '0'              
    push    EDX                  ; Push ASCII digit onto stack
    push    EDX
    mov     EDX, [EBP+20]        ; OFFSET sumDigits
    inc     DWORD PTR [EDX]      ; Increment digit count
    pop     EDX
    mov     EBX, EAX             ; Prepare EBX for next iteration
    cmp     EBX, 0
    jne     _convertLoop
_PopDigits:
    pop     EDX                  ; Pop digit from stack
    mov     [ESI], DL             
    inc     ESI                   
    push    EDX
    mov     EDX, [EBP+20]        ; OFFSET sumDigits
    dec     DWORD PTR [EDX]      ; Decrement digit count
    pop     EDX
    push    EDX
    mov     EDX, [EBP+20]        ; OFFSET sumDigits
    mov     EAX, DWORD PTR [EDX] ; Load digit count
    pop     EDX
    cmp     EAX, 0               ; Check stack back to base
    jg      _PopDigits
_endConvert:
    mov     BYTE PTR [ESI], 0    ; Null-terminate buffer
    call    Crlf
    mDisplayString [EBP+16]      ; OFFSET sumMsg
    mDisplayString [EBP+12]      ; OFFSET sumBuffer
    call    Crlf
    pop     ESI
    pop     EDX
    pop     ECX
    pop     EBX
    pop     EAX
    pop     EBP
    ret     16
CalcSum ENDP


; -----------------------------------------------------------------------------------------
; Name: CalcAverage
; 
; Calculates the average of integers from a given array, converts the average to its
; ASCII string representation, and stores it in a provided buffer.
;
; Preconditions: decimalArray contains valid integers
;
; Postconditions: average of integers is calculated and stored in avgBuffer as ASCII string,
;                 string is null-terminated 
;
; Receives:
;   [EBP+8]   OFFSET decimalArray - address of the array of integers
;   [EBP+12]  OFFSET avgBuffer - address of the buffer where the ASCII average will be stored
;   [EBP+16]  OFFSET avgMsg - address of the message to display before the average
;
; Changes Registers: EAX, EBX, ECX, EDX, ESI, EDI, EBP
; -----------------------------------------------------------------------------------------
CalcAverage PROC
    push    EBP
    mov     EBP, ESP
    push    EAX
    push    EBX
    push    ECX
    push    EDX
    push    ESI
    push    EDI
    xor     EAX, EAX             
    mov     ECX, 10              ; Number of elements in the array
    mov     ESI, [EBP+8]         ; OFFSET decimalArray
    mov     EDI, [EBP+12]        ; OFFSET avgBuffer
_sumLoop:
    add     EAX, [ESI]           ; Add each element to EAX
    add     ESI, 4               
    loop    _sumLoop
    mov     EBX, EAX             
    mov     ECX, 10              ; Number of elements in the array
    cdq                          
    idiv    ECX                  ; EAX = EBX / 10 (average), EDX = EBX % 10 (remainder)
    cmp     EAX, 9                  
    xor     EBX, EBX             
    jge     _convertLoop
    add     AL, '0'              
    mov     [EDI], AL            
    inc     EDI  
    jmp     _EndConvert
_convertLoop:
    xor     EDX, EDX             
    mov     ECX, 10             
    div     ECX                  ; EAX = EAX / 10, EDX = EAX % 10 (remainder)
    add     DL, '0'            
    push    EDX                
    inc     EBX                  ; Increment digit count
    test    EAX, EAX            
    jnz     _convertLoop         ; If not zero, continue conversion loop
_reverseLoop:                    ; Reverse the order of ASCII digits buffer
    pop     EDX                  
    mov     [EDI], DL            
    inc     EDI                  ; Move next position
    dec     EBX                  ; Decrement digit count
    cmp     EBX, 0               ; Check if all digits processed
    jne     _reverseLoop         
_EndConvert:
    mov     BYTE PTR [EDI], 0    ; Null-terminate buffer
    call    Crlf
    mDisplayString [EBP+16]      ; OFFSET avgMsg
    mDisplayString [EBP+12]      ; OFFSET avgBuffer
    call    Crlf
    pop     EDI
    pop     ESI
    pop     EDX
    pop     ECX
    pop     EBX
    pop     EAX
    pop     EBP
    ret     12
CalcAverage ENDP


; --------------------------------------------------------------------------
; Name: GoodBye
;
; Displays goodbye message then invokes ExitProcess
;
; Postconditions:  Goodbye message is displayed and program is terminated.
;
; Receives: 
;   [EBP+8]  OFFSET goodbyeMsg - address of goodbye message string
;
; Changes Registers: EBP, EDX
; ---------------------------------------------------------------------------
GoodBye PROC
    push    EBP
    mov     EBP, ESP
    call    Crlf
    mDisplayString [EBP+8]      ; OFFSET goodbyeMsg
    call    Crlf
    pop     EBP
    Invoke ExitProcess,0	    ; Exit to operating system
GoodBye ENDP


main PROC
    push    OFFSET instruct3
    push    OFFSET instruct2
    push    OFFSET instruct1
    push    OFFSET programTitle

;---------------------------------------------------
; Display program title and description of program
;---------------------------------------------------
    call    Introduction
    mov     ECX, 10         ; To call ReadVal 10 times
_readVals:
    push    OFFSET firstChar
    push    SIZEOF buffer
    push    OFFSET negate
    push    OFFSET decimalArray
    push    OFFSET counter
    push    OFFSET buffer
    push    OFFSET bytes
    push    OFFSET buffer
    push    OFFSET userInputMsg
    push    OFFSET invalidInput

;------------------------------------
; Read in 10 signed decimal integers
;------------------------------------
    call    ReadVal
    loop    _readVals
    push    OFFSET bytesArray
    push    OFFSET counter
    push    OFFSET numList
    push    OFFSET asciiArray
    push    OFFSET decimalArray

;------------------------------------------------
; Display the 10 signed decimal inputted by user
;------------------------------------------------
    call    WriteVal
    push    OFFSET sumDigits
    push    OFFSET sumMsg
    push    OFFSET sumBuffer
    push    OFFSET decimalArray

;---------------------------------------------------
; Calculate the sum of the 10 signed decimal numbers
;---------------------------------------------------
    call    CalcSum
    push    OFFSET avgMsg
    push    OFFSET avgBuffer 
    push    OFFSET decimalArray

;-------------------------------------------------------
; Calculate the average of the 10 signed decimal numbers
;-------------------------------------------------------
    call    CalcAverage
    push    OFFSET goodbyeMsg

;------------------------------------------------
; Display goodbye message and invoke ExitProcess
;------------------------------------------------
    call    GoodBye
main ENDP
    
END main
