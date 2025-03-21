TITLE A Random Number Generator     (Proj4_greenede.asm)

; Author: Derek Greene
; Last Modified: 5/20/2024
; OSU email address: greenede@oregonstate.edu
; Course number/section:   CS271 Section [400]
; Project Number: 5                Due Date: 5/26/24
; Description: Program displays title and programmers name, followed by an introduction explaining the
;              program. Program then generates 200 random numbers in range [15,50] (inclusive), converts them
;              to their ascii representation, directly and then writes them direectly into a text file.
;              These numbers are then read back into an ascii array which is then parsed into a decimal array. 
;              The unsorted random numbers are displayed first (ascii array) followed by the sorted numbers, 
;              and then the medium value of the array, followed by the number of instances fo reach value generated
;              in ascending order of instances. Numbers are displayed 20 per row. Program then displays goodbye message. 

INCLUDE Irvine32.inc

; constant definitions for range [15,50]
LO = 15
HI = 50
ARRAY_SIZE = 200

.data

programTitle        BYTE    "A Random Number Generator     by Derek Greene",0
extraCredit1        BYTE    "**EC: Random numbers are generated into a file and then read into an array.",0
extra1              BYTE    "**Just for fun the numbers are converted to ASCII so you can view them in the file created,",0
extra2              BYTE    "**then they are read back from the file and into an array of ASCII characters!",0
instruct1           BYTE    "This program generates 200 random numbers in the range [15,50].",0
instruct2           BYTE    "Numbers generated are then displayed without sorting followed by with sorting, then the median value,",0
instruct3           BYTE    "and finally the number of instances that each occur are displayed.",0
unsortRand          BYTE    "Unsorted:",0
sortRand            BYTE    "Sorted:",0
medValue            BYTE    "Median Value: ",0
numInstan           BYTE    "Instances of each number generated:",0
goodbyeMsg          BYTE    "Thanks for using A Random Number Generator by Derek Greene, Goodbye!",0
space               BYTE    32
randNumsFile        BYTE    "Random Number Array.txt",0
fileHandle          DWORD   ?
fileBuffer          BYTE    ARRAY_SIZE*3 DUP(?)
randArray           BYTE    ARRAY_SIZE*3 DUP(?)
decimalArray        DWORD   ARRAY_SIZE   DUP(?)
occArray            DWORD   ARRAY_SIZE+1 DUP(?)
digit1              BYTE    49
digit2              BYTE    50
digit3              BYTE    51
digit4              BYTE    52
digit5              BYTE    53
digit6              BYTE    54
tempAL              BYTE    ?

.code

; ----------------------------------------------------
; Name: introduction
;
; Displays program title and description.
;
; Preconditions: memory addresses of programTitle,
; extraCredit1, extra1, extra2, instruct1, instruct2,
; instruct3 pushed to the stack before call
;
; Postconditions: prints title and program description
;
; Receives: OFFSET of programTitle,
; extraCredit1, extra1, extra2, instruct1, instruct2,
; instruct3
;
; Changes Registers: EDX 
; -----------------------------------------------------
introduction    PROC
    push    EBP
    mov     EBP, ESP
    mov     EDX, [EBP+32]   ; programTitle
    call    WriteString
    call    CrLf
    call    CrLf
    mov     EDX, [EBP+28]   ; extraCredit1
    call    WriteString
    call    CrLf
    mov     EDX, [EBP+24]   ; extra1
    call    WriteString
    call    CrLf
    mov     EDX, [EBP+20]   ; extra2
    call    WriteString
    call    CrLf
    call    CrLf
    mov     EDX, [EBP+16]   ; instruct1
    call    WriteString
    call    CrLf            
    mov     EDX, [EBP+12]   ; instruct2
    call    WriteString
    call    CrLf
    mov     EDX, [EBP+8]    ; instruct3
    call    WriteString
    call    CrLf
    pop     EBP
    ret     24
introduction    ENDP

; ---------------------------------------------------------------------------------
; Name: genRandNums
;
; Generates ARRA_SIZE amount of random numbers, then passes them to sub-procedure
; ConverToAscii which converts the values to their ASCII representation. A call is
; then made to sub-procedure addToFile which adds each ASCII number to the file
; "Random Number Array.txt" seperated by a space char. The file is then closed.
;
; Preconditions: memory addresses of digit1, digit2, digit3, digit4, digit5, digit6,
; space, fileBuffer, randNumsFile, fileHandle pushed to the stack before call
;
; Postconditions: file created with ASCII array of random numbers
;
; Receives: OFFSET of digit1, digit2, digit3, digit4, digit5, digit6,
; space, fileBuffer, randNumsFile, fileHandle
;
; Returns: file containing an ASCII array
;
; Changes Registers: EAX, ECX, EDX, ESI, EDI
; ---------------------------------------------------------------------------------
genRandNums     PROC
    push    EBP
    mov     EBP, ESP
    mov     EDX, [EBP+16]   ; randNumsFile
    call    CreateOutputFile
    mov     [ESI], EAX      ; fileHandle
    mov     ECX, ARRAY_SIZE
_numGen:
    mov     EAX, HI
    inc     EAX             ; increment EAX +1 as RandomRange is upper limit exclusive 
    sub     EAX, LO
    call    RandomRange     
    add     EAX, LO
    mov     EDX, [ESI]
    push    EDX
    mov     EDX, [EBP+8]    ; fileBuffer
    push    EDX
    mov     EDX, [EBP+48]   ; digit6
    push    EDX
    mov     EDX, [EBP+44]   ; digit5
    push    EDX
    mov     EDX, [EBP+40]   ; digit4
    push    EDX
    mov     EDX, [EBP+36]   ; digit3
    push    EDX
    mov     EDX, [EBP+32]   ; digit2
    push    EDX
    mov     EDX, [EBP+28]   ; digit1
    push    EDX
    call    ConvertToAscii
    mov     EDX, [EBP+24]   ; space
    push    EDX
    mov     [EDI], BL       ; save randomRange num second digit
    mov     EAX, [ESI]
    push    EAX
    mov     EAX, [EBP+8]    ; fileBuffer
    push    EAX
    call    addToFile
    loop    _numGen
    mov     EAX, [ESI]
    call    CloseFile
    pop     EBP
    ret     44
genRandNums     ENDP

; ------------------------------------------------------------------------------------
; Name: ConvertToAscii
;
; Sub-procedure of genRandNums, Converts the values generated from call to RandomRange
; to ASCII representation seperated by a space char. For each random number, the ASCII
; chars are stored in fileBuffer.
;
; Preconditions: memory addresses of digit1, digit2, digit3, digit4, digit5, digit6,
; fileBuffer pushed to stack before call
;
; Postconditions: Number generated by call to RandomRange is represented as ASCII
;
; Receives: OFFSET of digit1, digit2, digit3, digit4, digit5, digit6,
; space, fileBuffer, randNumsFile, fileHandle, and value from genRandNums (EAX) 
;
; Returns: ASCII representation of number into fileBuffer
;
; Changes Registers: EAX, EBX, ECX, EDX
; ------------------------------------------------------------------------------------
ConvertToAscii  PROC
    push    EBP
    mov     EBP, ESP
    push    ECX
    cmp     EAX, 10
    jb      _eq1to9
    jmp     _eq10to19
_eq1to9:
    add     EAX, 48
    mov     EBX, EAX
    jmp     _skip
_eq10to19:
    cmp     EAX, 19
    jg      _eq20to29
    sub     EAX, 10
    add     EAX, 48
    mov     EBX, EAX
    mov     EAX, [EBP+36]   ; fileHandle
    mov     ECX, 1
    mov     EDX, [EBP+8]    ; digit1
    call    WriteToFile
    jmp     _skip
_eq20to29:
    cmp     EAX, 29
    jg      _eq30to39
    sub     EAX, 20
    add     EAX, 48
    mov     EBX, EAX
    mov     EAX, [EBP+36]   ; fileHandle
    mov     ECX, 1
    mov     EDX, [EBP+12]   ; digit2
    call    WritetoFile
    jmp     _skip
_eq30to39:
    cmp     EAX, 39
    jg      _eq40to49
    sub     EAX, 30
    add     EAX, 48
    mov     EBX, EAX
    mov     EAX, [EBP+36]   ; fileHandle
    mov     ECX, 1
    mov     EDX, [EBP+16]   ; digit3
    call    WriteToFile
    jmp     _skip
_eq40to49:
    cmp     EAX, 49
    jg      _eq50to59
    sub     EAX, 40
    add     EAX, 48
    mov     EBX, EAX
    mov     EAX, [EBP+36]   ; fileHandle
    mov     ECX, 1
    mov     EDX, [EBP+20]   ; digit4
    call    WriteToFile
    jmp     _skip
_eq50to59:
    cmp     EAX, 59
    jg      _eq60to69
    sub     EAX, 50
    add     EAX, 48
    mov     EBX, EAX
    mov     EAX, [EBP+36]   ; fileHandle
    mov     ECX, 1
    mov     EDX, [EBP+24]   ; digit5
    call    WriteToFile
    jmp     _skip
_eq60to69:
    sub     EAX, 60
    add     EAX, 48
    mov     EBX, EAX
    mov     EAX, [EBP+36]   ; fileHandle
    mov     ECX, 1
    mov     EDX, [EBP+28]   ; digit6
    call    WriteToFile
_skip:     
    pop     ECX
    pop     EBP
    ret     32
ConvertToAscii  ENDP

; ------------------------------------------------------------------------------------
; Name: addToFile
;
; Sub-procedure of genRandNums, writes values to ASCII file.
;
; Preconditions: memory addresses of fileHandle, space, fileBuffer pushed to stack 
; before call
;
; Postconditions: ASCII value written to file
;
; Receives: fileHandle, OFFSET of space, and ASCII value to be written
;
; Returns: ASCII value written to file "Random Number Array.txt"
;
; Changes Registers: EAX, ECX, EDX
; ---------------------------------------------------------------------------------
addToFile   PROC
    push    EBP
    mov     EBP, ESP
    push    ECX
    mov     EAX, [EBP+12]   ; fileHandle
    mov     EDX, [EBP+8]    ; fileBuffer
    mov     ECX, 1
    call    WriteToFile
    mov     EAX, [EBP+12]   ; fileHandle
    mov     EDX, [EBP+16]   ; spaceChar
    mov     ECX, 1
    call    WriteToFile
    pop     ECX
    pop     EBP
    ret     12
addToFile ENDP

; ------------------------------------------------------------------------------------
; Name: addToArray
;
; Opens file "Random Number Array.txt" and reads each byte, one byte at a time, keeping
; a count of how many bytes are read before encountering a space char. Upon encountering
; a space char, the (count) amount of bytes is then read into the ASCII array. This is
; necessary to handle 1 vs 2 digit numbers (1 vs 2 BYTE) ASCII chars. 
;
; Preconditions: memory address of randNumsFile, fileBuffer, fileHandle, randArray
; pushed to stack before call
;
; Postconditions: contents of file "Random Number Array.txt" are read into array randArray
;
; Receives: OFFSET of randNumsFile, fileBuffer, fileHandle, randArray
;
; Returns: array randArray filled with ASCII values
;
; Changes Registers: EAX, EBX, ECX, EDX, EDI, ESI
; ----------------------------------------------------------------------------------
addToArray  PROC
    push    EBP
    mov     EBP, ESP    
    mov     EDX, [EBP+8]        ; randNumsFile
    call    OpenInputFile
    mov     [EBP-4], EAX
    mov     EDX, [EBP+12]       ; read file content into fileBuffer
    mov     ECX, ARRAY_SIZE*4
    call    ReadFromFile
    mov     ESI, [EBP+12]       ; fileBuffer
    mov     EDI, [EBP+16]       ; randArray
    xor     EBX, EBX            
    mov     ECX, ARRAY_SIZE*4   ; num bytes to read into AL
    mov     EDX, [EBP+20]       ; tempAL
_parseLoop:
    mov     AL, [ESI]           ; load current byte from fileBuffer
    push    ECX
    mov     ECX, 1          
    pop     ECX
    mov     [EDI], AL           ; atore number in randArray
    add     EDI, TYPE BYTE
_skipStore:
    xor     EBX, EBX            ; reset EBX for next number
    inc     ESI
    loop    _parseLoop
_endParse:
    pop     EBP
    ret     16
addToArray ENDP

; ------------------------------------------------------------------------------------
; Name: printUnsArray
;
; Iterates through the unsorted ASCII array of random numbers generated keeping track
; of how many bytes before a space char is encountered, and how many numbers (not digits)
; are printed. Each time 20 numbers have been printed, a new line is printed. 
;
; Preconditions: memory address of randArray pushed to stack before call
;
; Postconditions: prints array of unsorted random numbers randArray
;
; Receives: OFFSET of randArray
;
; Changes Registers: EAX, EBX, ECX, EDX, ESI
; ----------------------------------------------------------------------------------------
printUnsArray  PROC
    push    EBP
    mov     EBP, ESP
    mov     ESI, [EBP+8]        ; randArray
    mov     ECX, ARRAY_SIZE*3
    call    CrLf
    mov     EDX, 0
_pArrLoop:
    push    ECX
    cmp     EDX, 20
    jge     _newLine
    jmp     _sameLine
_newLine:
    call    CrLf
    mov     EDX, 0
_sameLine:
    mov     AL, [ESI+EBX]   
    call    WriteChar         
    add     EBX, 1
    add     ECX, 1
    cmp     AL, 32
    jne      _noDigit
    inc     EDX
_noDigit:
    pop     ECX
    loop    _pArrLoop
    pop     EBP
    ret     8
printUnsArray  ENDP

; ------------------------------------------------------------------------------------
; Name: convertArray
;
; Parses ASCII chars in randArray, converting the value of the digits encountered
; before a space char occurs into their decimal value. Then adds the decimal value
; into an array decimalArray. Each decimal value is added in 4 byte segments.
;
; Preconditions: memory addresses of randArray, decimalArray pushed to stack before call
;
; Postconditions: converted array decimalArray from ASCII to decimal
;
; Receives: OFFSET of randArray, decimalArray
;
; Returns: decimal array decimalArray
;
; Changes Registers: EAX, EBX, ECX, EDX, EDI, ESI
; ------------------------------------------------------------------------------------
convertArray PROC
    push    EBP
    mov     EBP, ESP
    mov     EBX, 0
    mov     EDX, 0
    mov     EDI, 0
    mov     ECX, ARRAY_SIZE
    mov     ESI, [EBP+8]                    ; randArray
_convert:
    mov     ECX, 0                          ; initialize char count for current integer
_convert2:
    mov     AL, [ESI+EDX]                   ; load current char
    cmp     AL, ' '                         ; check if space
    je      _parse           
    cmp     AL, 0                           ; check if end of array
    je      _endConvert     
    sub     AL, '0'                         ; convert ASCII to int
    imul    ECX, ECX, 10
    movzx   EBX, AL                         ; zero extend AL to 32 bits in EBX
    add     ECX, EBX
    inc     EDX                             ; move to the next char
    jmp     _convert2        
_parse:
    push    EDX
    mov     EDX, [EBP+12]                   ; decimalArray
    mov     DWORD PTR [EDX+EDI*4], ECX      ; store result in array at index EDI
    pop     EDX
    inc     EDI                             ; increment index for storing integers
    mov     ECX, 0                          ; reset char count
    inc     EDX              
    jmp     _convert         
_endConvert:
    pop     EBP
    ret     4
convertArray ENDP

; ---------------------------------------------------------------------------------
; Name: sortArray
;
; Sorts decimalArray into ascending order using a bubble sort method. After call to
; sortArray, sorted vales overwrite original values of decimalArray. 
;
; Preconditions: memory address of decimalArray pushed to stack before call
;
; Postconditions: sorted decimal array decimalArray
;
; Receives: OFFSET of decimalArray
;
; Returns: sorted decimal array decimalArray
;
; Changes Registers: EAX, EBX, ECX, EDX, ESI, EDI
; ---------------------------------------------------------------------------------
sortArray PROC
    push    EBP
    mov     EBP, ESP
    mov     ECX, ARRAY_SIZE-1           ; number of iterations for the outer loop
    mov     EDX, [EBP+8]                ; decimalArray
_outerLoop:
    mov     EDI, 0                      ; initialize index for comparing elements
    mov     EAX, 0                      ; flag to track if any swaps were made
_innerLoop:
    mov     EBX, EDI
    inc     EBX
    imul    EBX, EBX, 4                 ; multiply by 4 (since each element is 4 bytes)
    mov     ESI, DWORD PTR [EDX+EDI*4]
    mov     ECX, DWORD PTR [EDX+EBX]
    cmp     ESI, ECX
    jle     _noSwap                     ; if ESI <= ECX, no swap
    mov     DWORD PTR [EDX+EDI*4], ECX
    mov     DWORD PTR [EDX+EBX], ESI
    mov     EAX, 1                      ; set the swap flag
_noSwap:
    inc     EDI
    cmp     EDI, ARRAY_SIZE-1
    jl      _innerLoop                  ; continue inner loop if not end of array
    cmp     EAX, 0
    jnz     _outerLoop                  ; continue outer loop if swaps were made
    pop     EBP
    ret     4
sortArray ENDP

; -----------------------------------------------------------------------------------
; Name: printSortArray
;
; Prints the sorted decimalArray incrementing 4 bytes at a time. Each value is
; seperated by a space char by printing the ASCII value 32. A count of how many
; numbers printed is kept, after 20 numbers have been printed, a new line is printed.
;
; Preconditions: memory address of decimalArray pushed to stack before call
;
; Postconditions: prints array decimalArray of sorted random numbers 
;
; Receives: OFFSET of decimalArray
;
; Changes Registers: EAX, ECX, EDX, EDI, ESP
; -----------------------------------------------------------------------------------
printSortArray PROC
    push    EBP
    mov     EBP, ESP
    sub     ESP, 4          
    mov     ECX, ARRAY_SIZE   
    mov     EDI, [EBP+8]            ; decimalArray
    call    CrLf
    mov     DWORD PTR [EBP-4], 0    ; initialize local variable to count printed numbers
_loopP:
    mov     EAX, [EDI]       
    call    WriteDec         
    mov     EAX, 32
    call    WriteChar
    add     EDI, 4           
    inc     DWORD PTR [EBP-4]       ; increment count of printed numbers
    cmp     DWORD PTR [EBP-4], 20
    jl      _continueP
    call    CrLf             
    mov     DWORD PTR [EBP-4], 0    ; reset count
_continueP:
    loop    _loopP
    mov     ESP, EBP        
    pop     EBP
    ret     4
printSortArray ENDP

; ---------------------------------------------------------------------------------
; Name: findMedian
;
; Parses decimalArray to calculate the median value. Uses ARRAY_SIZE / 2 to get
; middle index and then checks even/odd. If even calcuate avg of two middle
; numbers, if odd, median is middle number.
;
; Preconditions: memory address of decimalArray pushed to stack before call
;
; Postconditions: printed median value
;
; Receives: OFFSET of decimalArray
;
; Returns: median value in EAX
;
; Changes Registers: EAX, EBX, ECX, EDX
; ---------------------------------------------------------------------------------
findMedian PROC
    push    EBP
    mov     EBP, ESP
    sub     ESP, 8                      
    mov     ECX, ARRAY_SIZE
    push    [EBP+8]                     ; push decimalArray parameter to sortArray
    call    sortArray
    mov     EAX, ARRAY_SIZE   
    shr     EAX, 1                      ; divide / 2 to get  middle index
    mov     DWORD PTR [EBP-4], EAX      ; store middle index 
    mov     EAX, ARRAY_SIZE
    and     EAX, 1                      ; check if number of elements is odd/even
    jz      _evenMedian       
_oddMedian:                             ; if odd, median is element at middle index
    mov     EAX, DWORD PTR [EBP-4]
    mov     EBX, DWORD PTR [EBP+8]      ; decimalArray
    mov     EAX, DWORD PTR [EBX+EAX*4]  ; load element at middle index
    jmp     _medianFound
_evenMedian:                            ; if even, get the two middle elements and calculate average
    mov     EAX, DWORD PTR [EBP-4]
    mov     EBX, DWORD PTR [EBP+8]      ; decimalArray parameter
    mov     EDX, DWORD PTR [EBX+EAX*4]  ; load element at middle index
    dec     EAX
    mov     ECX, DWORD PTR [EBX+EAX*4]  ; load element before middle index
    add     EDX, ECX                    
    sar     EDX, 1                      ; divide sum / 2 to get average
    mov     EAX, EDX
_medianFound:                           ; return the median value in EAX
    mov     ESP, EBP
    pop     EBP
    ret     4                 
findMedian ENDP

; ---------------------------------------------------------------------------------
; Name: displayList
;
; Displays whichever string is passed to it. Used to print the titles of each array
; and the median value title. 
;
; Preconditions:  memory address of string to display pushed to stack before call
;
; Postconditions: string is displayed followed by a newline
;
; Receives: EBP+8 - address of the string to be displayed
;
; Changes Registers: EDX
; ---------------------------------------------------------------------------------
displayList     PROC
    push    EBP
    mov     EBP, ESP
    call    CrLf
    mov     EDX, [ESP+8]        ; whichever string is passed first to the stack before calling procedure
    call    WriteString
    pop     EBP
    ret     4
displayList     ENDP

; ---------------------------------------------------------------------------------
; Name: countOcc
;
; Parses the decimalArray and keeps a count for each value, of how many times it
; occurs, the number of instances is stored in an array occArray.
;
; Preconditions: memory address of decimalArray, occArray pushed to stack before call
;
; Postconditions: filled occArray with occurrences of each value
;
; Receives: OFFSET of decimalArray, occArray
;
; Returns: filled occArray
;
; Changes Registers: EAX, ECX, EDX, EDI
; ---------------------------------------------------------------------------------
countOcc PROC
    push    EBP
    mov     EBP, ESP
    mov     ECX, HI                     ; maximum possible value in decimalArray
    xor     EDI, EDI                    ; clear index register
_initLoop:
    push    EDX
    mov     EDX, [EBP+8]                ;  occArray
    mov     DWORD PTR [EDX+EDI*4], 0    
    pop     EDX
    inc     EDI
    loop    _initLoop                   ; count occurrences of each number in decimalArray                   
    mov     ECX, ARRAY_SIZE    
    mov     EDI, 0                      ; initialize index for decimalArray
_countLoop:
    push    EDX
    mov     EDX, [EBP+12]               ; decimalArray
    mov     EAX, DWORD PTR [EDX+EDI*4]  ; load current number
    pop     EDX
    push    EDX
    mov     EDX, [EBP+8]                ; occArray
    inc     DWORD PTR [EDX+EAX*4]       
    pop     EDX
    inc     EDI                         ; move to next element in decimalArray
    loop    _countLoop
    pop     EBP
    ret
countOcc ENDP

; --------------------------------------------------------------------------------------
; Name: printOcc
;
; Prints each element that is not 0 as countOcc records 0 for values not in decimalArray.
; Instances are printed seperated by a space char by moving ASCII char 32 into EAX
; before calling WriteChar. A count of how many instances printed is kept, after 20
; printed, a new line is printed. 
;
; Preconditions: memory address of occArray pushed to stack before call
;
; Postconditions: prints occurrences of each value in the occurance array occArray
;
; Receives: OFFSET of occArray
;
; Changes Registers: EAX, ECX, EDX, ESI
; --------------------------------------------------------------------------------------
printOcc PROC
    push    EBP
    mov     EBP, ESP
    mov     EDX, 0
    mov     ECX, HI + 1             ; number of elements in the occurrences array
    mov     ESI, DWORD PTR [EBP+8]  ; get the address of the occurrences array
    call    CrLf
_printLoop:
    cmp     DWORD PTR [ESI], 0  
    je      _skipPrint3
    cmp     EDX, 20
    jge     _newLinee
    jmp     _sameLinee
_newLinee:
    call    CrLf
    mov     EDX, 0
_sameLinee:
    mov     EAX, [ESI]
    call    WriteDec
    inc     EDX
    push    EDX
    mov     EAX, 32                 ; ascii space char
    call    WriteChar
    pop     EDX
_skipPrint3:
    add     ESI, 4               
    loop    _printLoop
    call    CrLf
    call    CrLf
    pop     EBP
    ret     4
printOcc ENDP

; ---------------------------------------------------------------------------------
; Name: goodBye
;
; Displays goodbye message then invokes ExitProcess
;
; Preconditions: memory address of goodbyeMsg pushed to stack before call
;
; Postconditions: Displays a goodbye message to the user and terminates the program.
;
; Receives: OFFSET of goodbyeMsg
;
; Changes Registers: EDX
; ---------------------------------------------------------------------------------
goodBye     PROC
    push    EBP
    mov     EBP, ESP
    mov     EDX, [EBP+8]        ; goodbyeMsg
    call    WriteString
    call    CrLf
    Invoke ExitProcess,0	    ; exit to operating system
goodBye     ENDP

main PROC
    push    OFFSET programTitle
    push    OFFSET extraCredit1
    push    OFFSET extra1
    push    OFFSET extra2
    push    OFFSET instruct1
    push    OFFSET instruct2
    push    OFFSET instruct3

;---------------------------------------------------
; Displays program title and description of program
;---------------------------------------------------
    call    introduction
    call    Randomize           ; generate random seed
    push    OFFSET digit6
    push    OFFSET digit5
    push    OFFSET digit4
    push    OFFSET digit3
    push    OFFSET digit2
    push    OFFSET digit1
    push    OFFSET space
    mov     EDI, OFFSET fileBuffer
    push    EDI
    push    OFFSET randNumsFile
    mov     ESI, OFFSET fileHandle
    push    ESI
    push    OFFSET fileBuffer

;-----------------------------------------------
; Generates ARRAY_SIZE amount of random numbers
; Nums get converted to ASCII and wrote to file
;-----------------------------------------------
    call    genRandNums
    push    OFFSET tempAL
    push    OFFSET randArray       
    push    OFFSET fileBuffer
    push    OFFSET randNumsFile

;------------------------------------------------
; Reads ASCII nums from file into array randArray
; randArray is an array of ASCII chars
;------------------------------------------------
    call    addToArray
    push    OFFSET unsortRand

;------------------------------------------------
; Prints "Unsorted:" label for unsorted array of
; random numbers to be printed next
;------------------------------------------------
    call    displayList
    mov     EDX, TYPE randArray
    push    EDX
    mov     ESI, OFFSET randArray
    push    ESI

;------------------------------------------------
; Prints the ASCII array of unsorted values that
; were read into randArray from file 
;------------------------------------------------
    call    printUnsArray
    call    CrLf    
    push    OFFSET sortRand

;---------------------------------------------------
; Prints "Sorted:" label for sorted array of random
; numbers to be printed 
;---------------------------------------------------
    call    displayList
    push    OFFSET decimalArray
    push    OFFSET randArray

;--------------------------------------------------
; Converts ASCII array randArray values into their
; decimal representations and adds to decimalArray 
;--------------------------------------------------
    call    convertArray
    push    OFFSET decimalArray

;-------------------------------------------------------
; Sorts decimalArray into ascending order using a
; bubble sort method. Overwrites values in decimalArray
;-------------------------------------------------------
    call    sortArray
    push    OFFSET decimalArray

;---------------------------------------------------
; Prints the sorted decimalArray 20 numbers per line
; seperated by a space char
;---------------------------------------------------
    call    printSortArray
    push    OFFSET medValue

;--------------------------------------------------
; Prints "Median Value:" label for median value to
; be calculated and printed next
;--------------------------------------------------
    call    displayList
    push    OFFSET decimalArray

;-------------------------------------------------
; Parses the sorted decimalArray to calculate the
; median value which is returned in EAX
;-------------------------------------------------
    call    findMedian
    call    WriteDec
    call    CrLf
    push    OFFSET decimalArray
    push    OFFSET occArray

;-----------------------------------------------------
; Parses the decimalArray keeping track of how many
; times each num occurs. Instances stored in occArray
;-----------------------------------------------------
    call    countOcc
    push    OFFSET numInstan

;---------------------------------------------------
; Prints "Instances of each number generated:" label
; for array of instances occArray to be printed next
;---------------------------------------------------
    call    displayList

;-------------------------------------------------
; Prints the array of instances occArray, numbers
; are seperated by a space char 
;-------------------------------------------------
    call    printOcc  
    push    OFFSET  goodbyeMsg

;------------------------------------------------
; Prints goodbye message and invokes ExitProcess
;------------------------------------------------
    call    goodBye
main ENDP

END main
