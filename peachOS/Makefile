all:
	nasm -f bin -o boot.bin boot.nasm
	dd if=message.txt >> boot.bin
	dd if=/dev/zero bs=512 count=1 >> boot.bin