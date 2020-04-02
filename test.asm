;
;Creation of macros
  SYSPRINT equ 4
  SCREEN equ 1
  OPEN equ 5
  READ equ 0
  ORERR equ 06
  SYSREAD equ 3
;
;
section .bss
;
section .data
;
  number db 0; Reserved byte for the read number
  space db 0; Reserved byte for the space
  buf db 1; Number of bytes in the buffer
  som dd 0; Variable where to store the partial/total sum
  filename: db "buffer.txt"; Name of the file
;
  errMsg: db 'Cannot open the file', 10; Error message if buffer.txt is not found, 10 is the ASCII code for new line
  len: equ $ - errMsg; Length of the message errmsg
;
section .text
  global _start
    _start:
    jmp openfile; Starting the program opening the file
;
    print:
      mov edx, 4; Number of bytes to write
      mov ecx, som; Variable to write
      mov ebx, 1; Where to write (screen)
      mov eax, 4; System call write is evoked
      int 0x80; Kernel is called
      jmp exit; Exit is called
;
    sum:
      add [som], dword number; Add the just read value to the temporary total
      jmp scanEl; Instruction scanEl to read the next element is called
;
    scanEl:
;Check if the EOF is reach and if there is no more input to take...
      cmp eax, ORERR;
      je print; ...and jump to print
;
;Reading next operandcle
      mov eax, SYSREAD; System call read is evoked
      mov ebx, filename; Reading from filename
      mov ecx, number; Writing the ASCII code for the read bytes to number
      mov edx, buf; Reading a number of bytes defined by buf
      int 0x80; Kernel is called
      sub [number], byte 48; Type conversation from ASCII to number to decimal integer
;
;Check if EOF is reached
      cmp eax, ORERR; If EOF is reached and...
      je sum; ...jump to sum
;
;Continuing, if the condition is false, with moving the pointer
;
      add bx, buf; Add to the pointer a position to move the buffer
      mov [filename], bx; Set the 'moved' pointer to filename
;
      mov eax, SYSREAD; System call read is evoked
      mov ebx, filename; Reading from filename
      mov ecx, number; Writing the ASCII code for the read bytes to number
      mov edx, buf; Reading a number of bytes defined by buf
      int 0x80; Kernel is called
      add bx, buf; Add to the pointer a position to move the buffer
      mov [filename], bx; Set the 'moved' pointer to filename
      jmp sum; Jump to sum
;
    openfile:
      mov eax, OPEN; "Open the file" function is called
      mov ebx, filename; Move file name in the register ebx
      mov ecx, READ; Read-only option is given
      int 0x80; Services register 0x80 is called
      cmp eax, ORERR;
      je cantopen;
      jmp scanEl;
;
    cantopen:
      mov edx, len; The length of the message to show is given as third argument
      mov ecx, errMsg; The error message is given as second argument to be written in output
      mov ebx, SCREEN; The output device is given as first argument, in this case the screen (code 1)
      mov eax, SYSPRINT; The function to print a message on terminal is called
      int 0x80; Services register 0x80 is called
      jmp exit
;
    exit:
      mov eax, 1; "Close the program" function is called
      mov ebx, 0; Move 1 to the register ebx to properly close the program
      int 0x80; Services register 0x80 is called
