ORG 0x7c00  ;Originating from address `0x7c00` to make the BIOS load the bootloader from memory
BITS 16     ;This will ensure that the Assembler will only assemble assembly instructions into 16-bit code


start:
    mov si, message     ;storing the address of the message label into the `si` register (register to process strings [arrays])
    
    call print          ;calling the `print` routine

    jmp $               ;similar to while true, this jump statement will keep on jumping back to itself, keeping the
                        ;program alive and preventing execution of the code below, which we really won't want to at this point


print:
    mov bx, 0           ;entering null value to the register just for the sake of it (not required but included
                        ;nonetheless for clarity)

.loop:

    lodsb               ;IMPORTANT: this instruction loads the first character from the `si` register that is `H`
                        ;and stores it into the `al` register which is used by the `0x10` BIOS routine to print the
                        ;character to the screen. After lodsb has loaded the data in the `al` register, it then also
                        ;increments the `si` register by 1 such that it will then point a the character `e` next.

    cmp al, 0           ;comparing the content of `al` register with 0.

    je .done            ;we are saying that if the content of the `al` register is zero, then jump to done. Everything
                        ;below this is in case the value of the `al` register is not zero.

    call print_char     ;calling the print_char subroutine.

    jmp .loop           ;jumping back to the sub-label loop to print the next character in case it is not 0.

.done:

    ret


print_char:
    mov ah, 0eh         ;converts to 10 decimal. Tells the routine below to print the character in the `al` register

    int 0x10            ;calling the BIOS Video Services routine to configure video related settings. `al` - data to print
                        ;`ah` - configuration for the rountine.

    ret

message: db 'Hello World!', 0   ;created some data bytes that say hello world, followed by the null terminator in the end
                                ;which is later used to compare the end of the string.


times 510-($ - $$) db 0     ;`db` stands for data bytes. We are padding data upto 510 bytes with zeroes.
                            ;Note: it won't pad the data that we have written to.


dw 0xAA55           ;Entering the 511th and 512th bytes as `0x55AA` for the `boot signature` which is necessary for the
                    ;bootloader to work. The 512 bytes in total comprises of our `boot sector`.


;NOTE: This project can be booted using the `Qemu` qemu-system-x86_64 emulator.


/*

##########################################
############## Explanation ###############
##########################################


##### times 510-($ - $$) db 0 #######

times 510-($ - $$) db 0
times directive:

The times directive is used to repeat a certain instruction or data a specific number of times. It's typically used to fill memory with a value or pad data to a specific size.
510 - ($ - $$):

510 refers to the size in bytes of the boot sector minus the last 2 bytes (which are reserved for the boot signature).
$ is a special symbol in assembly that represents the current address (the address of the next instruction or data).
$$ is a special symbol representing the beginning of the section (or in this case, the beginning of the boot sector).
($ - $$) calculates the number of bytes from the start of the section (boot sector) to the current position $. This gives the number of bytes already written to the boot sector.
So, 510 - ($ - $$) calculates how many bytes remain to reach the 510th byte of the boot sector.
db 0:

db stands for "define byte", and it inserts a byte of data.
db 0 inserts a byte with the value 0 (i.e., a null byte).

####### FINISHED ##########


##### dw 0xAA55 #######


The line dw 0xAA55 is placing the boot signature at the end of the boot sector. Here's a breakdown of what it does:

dw 0xAA55
dw directive:

dw stands for "define word." In x86 assembly, a "word" is typically 2 bytes (16 bits).
This directive stores a 16-bit (2-byte) value at the current memory location.
0xAA55:

This is the value being stored, written in hexadecimal (base 16).
It is a magic number that serves as the boot signature. The specific value 0xAA55 is used by the BIOS to identify a valid boot sector.
0xAA is the high byte, and 0x55 is the low byte when stored in little-endian format (which is typical on x86 systems).


####### FINISHED ##########

*/