ORG 0                   ;Originating from address `0` instead of `0x7c00` to prevent conflicts between the segment register
                        ;values and the ORG address, when the BIOS loads the bootloader from memory.

BITS 16                 ;This will ensure that the Assembler will only assemble assembly instructions into 16-bit code


_start:                 ;This label includes a Short Jump (Short Jump is a jump that is made within +/-128 bytes in
    jmp short start     ;memory) that is expected by the BIOS Parameter Block (BPB) on some devices.
    
    nop                 ;Including a nop (No Operation) instruction as expected by the BPB.                    
    

times 33 db 0           ;Reserving 33 bytes for the BIOS Parameter Block configurations that may be made by the BIOS
                        ;upon booting in a real device.


start:
    jmp 0x7c0:main      ;Ensuring that our `code segment` is also 0x7c0


main:
    cli                 ;Clearing (disabiling) Interrupts. We have done so, because we would be changing the values of the 
                        ;segment registers and we wouldn't want some hardware interrupt now to interrupt us while we are 
                        ;doing this because this is a very critical operation. Else, the segments won't be setup correctly.

    mov ax, 0x7c0       
    
    mov ds, ax          ;Configuring segment registers with the `bootloader` address. The value cannot be moved directly to
                        ;the `ds` register, so moved it to the `ax` register first.

    mov es, ax

    mov ax, 0x00        

    mov ss, ax          ;Setting `stack segment` register to zero to prevent offsetting from the `stack pointer` register
                        ;set below.

    mov sp, 0x7c00      ;Setting the `stack pointer` to 0x7c00 as the address upwards from this memory location will be
                        ;occupied by our bootloader or boot sector. And the stack grows downwards in memory, so because
                        ;of this, it will not interfere with the memory that will be used by our bootloader.

    sti                 ;Enable Interrupts

    mov ah, 2           ;READ SECTOR COMMAND

    mov al, 1           ;ONE SECTOR TO READ
    
    mov ch, 0           ;Cylinder low eight bits
    
    mov cl, 2           ;Read sector two
    
    mov dh, 0           ;Head number
    
    mov bx, buffer      ;pointing bx register to buffer label
    
    int 0x13            ;IMPORTANT: Interrupt to load another sector from Hard Disk

    jc error            ;Jump carry instruction used to move to the error label address in case the carry flag is set.

    mov si, buffer      ;Printing the message inside `message.txt`

    call print

    jmp $


error:
    mov si, error_message
    
    call print

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


error_message: db 'Failed to load message', 0


times 510-($ - $$) db 0     ;`db` stands for data bytes. We are padding data upto 510 bytes with zeroes.
                            ;Note: it won't pad the data that we have written to.


dw 0xAA55           ;Entering the 511th and 512th bytes as `0x55AA` for the `boot signature` which is necessary for the
                    ;bootloader to work. The 512 bytes in total comprises of our `boot sector`.


buffer:


;NOTE: This project can be booted using the `Qemu` qemu-system-x86_64 emulator. Pass `-hda` as the argument when running
;this project. This argument emulates a Hard Drive for our bootloader. It creates a disk whose type and location depends
;on the machine type QEMU is emulating,



;##########################################
;############## Explanation ###############
;##########################################


;##### times 510-($ - $$) db 0 #######

;times 510-($ - $$) db 0
;times directive:

;The times directive is used to repeat a certain instruction or data a specific number of times. It's typically used to fill memory with a value or pad data to a specific size.
;510 - ($ - $$):

;510 refers to the size in bytes of the boot sector minus the last 2 bytes (which are reserved for the boot signature).
;$ is a special symbol in assembly that represents the current address (the address of the next instruction or data).
;$$ is a special symbol representing the beginning of the section (or in this case, the beginning of the boot sector).
;($ - $$) calculates the number of bytes from the start of the section (boot sector) to the current position $. This gives the number of bytes already written to the boot sector.
;So, 510 - ($ - $$) calculates how many bytes remain to reach the 510th byte of the boot sector.
;db 0:

;db stands for "define byte", and it inserts a byte of data.
;db 0 inserts a byte with the value 0 (i.e., a null byte).

;####### FINISHED ##########


;##### dw 0xAA55 #######


;The line dw 0xAA55 is placing the boot signature at the end of the boot sector. Here's a breakdown of what it does:

;dw 0xAA55
;dw directive:

;dw stands for "define word." In x86 assembly, a "word" is typically 2 bytes (16 bits).
;This directive stores a 16-bit (2-byte) value at the current memory location.
;0xAA55:

;This is the value being stored, written in hexadecimal (base 16).
;It is a magic number that serves as the boot signature. The specific value 0xAA55 is used by the BIOS to identify a valid boot sector.
;0xAA is the high byte, and 0x55 is the low byte when stored in little-endian format (which is typical on x86 systems).


;####### FINISHED ##########
