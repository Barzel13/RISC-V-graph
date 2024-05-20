.data
	.align 2
offset:	.space 4
	.align 2
size:	.space 4
	.align 2
height:	.space 4
	.align 2
width:	.space 4
	.align 2
bsize:	.space 4
	.align 2
A:	.space 4
	.align 2
B:	.space 4
	.align 2
C:	.space 4
	.align 2
D:	.space 4
	.align 2
start: 	.space 4
	.align 1
bm:	.space 2
msg: 	.asciz "program do rysowania wielomianu stopnia 3 \n"
inmsg:	.asciz "podaj kolejno wszpulczynniki A, B, C, D \n"
inmsg2:	.asciz "liczby nalezy podawac w foramcie x*2^y dzie najpierw podawany jest x a nastepnie y \n"
emsg:	.asciz "ERROR: error ocured during file loading\n"
path:	.asciz "graph.bmp"
out:	.asciz "out.bmp"

	.text
	.globl main
main:
	li a7, 4
	la a0, msg
	ecall
read:
# odczyt pliku wykres.bmp
# otwarcie pliku
	la a0, path
	li a1, 0
	li a7, 1024
	ecall
	
	mv t0, a0
	bltz a0, error
# odczytanie wartoœæi BM (2 pierwsze bajty)
	mv a0, t0
	la a1, bm
	li a2, 2
	li a7, 63
	ecall
	#bltz a0, error
#odczytanie rozmiaru pliku (4 kolejne bajty)
	mv a0, t0
	la a1, size
	li a2, 4
	li a7, 63
	ecall
	bltz a0, error
#dynamiczna alokacja pamieci 
	lw a0, size
	li a7, 9
	ecall
	
	mv t1, a0
	la a2, start
	sw a0, (a2)
#odczytanie kolejnych neznacz¹cych 4 bajtow
	mv a0, t0
	la a1, offset
	li a2, 4
	li a7, 63
	ecall
	bltz a0, error
#odczytanie 4 bajtów ofsetu
	mv a0, t0
	la a1, offset
	li a2, 4
	li a7, 63
	ecall
	bltz a0, error
#odczytanie rozmiaru nagluwka DIB
	mv a0, t0
	la a1, bsize
	li a2, 4
	li a7, 63
	ecall
	bltz a0, error
#odczytanie szerokosci
	mv a0, t0
	la a1, width
	li a2, 4
	li a7, 63
	ecall
	lw a3, width
	bltz a0, error
#odczytanie wysokoœci 
	mv a0, t0
	la a1, height
	li a2, 4
	li a7, 63
	ecall
	bltz a0, error
#zamkniecie pliku do odczytu
	li a7, 57
	mv a0, t0
	ecall 
#pozyskanie od urzytkownika wartoœci A, B, C, D 
#format liczb 16b-czesc calkowita 16b-czesc ulamkowa
	la a0, inmsg
	li a7, 4
	ecall
	la a0, inmsg2
	li a7, 4
	ecall
	li a7, 5
	ecall
	mv t6, a0
	li a7, 5
	ecall
	li t5, 16
	add t5, t5, a0
	sll t6, t6, t5
	la t5, A
	sw t6, (t5)
	li a7, 5
	ecall
	mv t6, a0
	li a7, 5
	ecall
	li t5, 16
	add t5, t5, a0
	sll t6, t6, t5
	la t5, B
	sw t6, (t5)
	li a7, 5
	ecall
	mv t6, a0
	li a7, 5
	ecall
	li t5, 16
	add t5, t5, a0
	sll t6, t6, t5
	la t5, C
	sw t6, (t5)
	li a7, 5
	ecall
	mv t6, a0
	li a7, 5
	ecall
	li t5, 16
	add t5, t5, a0
	sll t6, t6, t5
	la t5, D
	sw t6, (t5)
# otwarcie pliku i zapis do pamieci tablicy pikseli
	la a0, path
	li a1, 0
	li a7, 1024
	ecall
	mv t0, a0
	bltz a0, error
	
	mv a0, t0
	mv a1, t1
	lw a2, size
	li a7, 63
	ecall
	
	mv a0, t6
	li a7, 57
	ecall

	lw a0, height #a0 - height
	lw a1, width 
	srli a1, a1, 1 #a1 - x max
	li a7, -1
	mul a7, a7, a1
	slli a7, a7, 12 # a7 aktualne x
#oblicznie paddingu
	slli a1, a3, 1
	add a1, a1, a3
	andi a1, a1, 0x03
	li a2, 4 
	sub a2, a2, a1 #a2 - padding
	

#rysowanie osi pionowej
	lw a1, width 
	srli a5, a1, 1 # ustawienie licznika kolumn na srodku obrazka
	lw a1, height
	li t0, 0
	
yloop:
	lw a3, start
	lw a4, offset
	add a3, a3, a4 #obliczenie adresu poczatku tablicy pikseli
	lw  a4, width
	mv t1, a5
#wylicznie pozycji piksela
	#wylicznie y
	slli t2, a4, 1
	add t2, t2, a4
	mul t2, t2, t0
	add a3, a3, t2
	#wyliczanie x
	mv t6, t1
	slli t1, t1, 1
	add t1, t1, t6
	add a3, a3, t1
#obsuga paddingu
	mul t2, t0, a2 # jak nie to zamiast a7 t0
	add a3, a3, t2
#kolorowanie piksela
	li t2, 0x00
	sb t2, (a3)
	addi a3, a3, 1
	sb t2, (a3)
	addi a3, a3, 1
	sb t2, (a3) 

	addi t0, t0, 1
	blt t0, a1, yloop
	

#rysowanie osi poziomej
	li a5, 0
	lw a1, width 
	lw t0, height
	srli t0, t0, 1
	
xloop:
	lw a3, start
	lw a4, offset
	add a3, a3, a4 #obliczenie adresu poczatku tablicy pikseli
	lw  a4, width
	mv t1, a5
#wylicznie pozycji piksela
	#wylicznie y
	slli t2, a4, 1
	add t2, t2, a4
	mul t2, t2, t0
	add a3, a3, t2
	#wyliczanie x
	mv t6, t1
	slli t1, t1, 1
	add t1, t1, t6
	add a3, a3, t1
#obsuga paddingu
	mul t2, t0, a2
	add a3, a3, t2
#kolorowanie piksela
	li t2, 0x00
	sb t2, (a3)
	addi a3, a3, 1
	sb t2, (a3)
	addi a3, a3, 1
	sb t2, (a3) 

	addi a5, a5, 1
	blt a5, a1 xloop


	li a5, 0 #a5 - licznik kolumn
count:
# obliczanie wartoœæi y	
	lw t6, A
	lw t5, B
	lw t4, C
	lw t3, D
#obliczanie Ax^3
	mul t2, t6, a7
	mulh t1, t6, a7
	slli t1, t1, 16
	srli t2, t2, 16
	or t0, t1, t2
	
	mul t2, t0, a7
	mulh t1, t0, a7
	slli t1, t1, 16
	srli t2, t2, 16
	or t0, t1, t2
	
	mul t1, t0, a7
	mulh t2, t0, a7
	slli t2, t2, 16
	srli t1, t1, 16
	or t0, t1, t2
#oblicznanie Bx^2
	mul t2, t5, a7
	mulh t1, t5, a7
	slli t1, t1, 16
	srli t2, t2, 16
	or t6, t1, t2
	
	mul t1, t6, a7
	mulh t2, t6, a7
	slli t2, t2, 16
	srli t1, t1, 16
	or t6, t1, t2
#obliczanie Cx
	mul t1, t4, a7
	mulh t2, t4, a7
	slli t2, t2, 16
	srli t1, t1, 16
	or t5, t1, t2
# suma skladnikow
	add t0, t0, t6
	add t0, t0, t5
	add t0, t0, t3
	srai t0, t0, 12
	 
	srli t1, a0, 1 #t1 - height/2
	add t0, t0, t1 #t0 - aktualne y
	mv t1, a5
	li t4, 0x00001000
	add a7, a7, t4  # a7 - nastempne x
	addi a5, a5, 1 #inkremnetacja licznika
	lw a4, width
	bge a5, a4, saveexit
#sprawdzenie czy obraz nie 'wyszedl' poza rysunek
	bgt t0, a0, count
	bltz t0, count
# kolorowanie pikseli na wykresie
	# t0 - aktualne y
	# a0 - height
	#a1 - x max
	#a2 - padding
	#a5 - licznik kolumn 
	lw a3, start
	lw a4, offset
	add a3, a3, a4 #obliczenie adresu poczatku tablicy pikseli
	lw  a4, width
#wylicznie pozycji piksela
	#wylicznie y
	slli t2, a4, 1
	add t2, t2, a4
	mul t2, t2, t0
	add a3, a3, t2
	#wyliczanie x
	mv t6, t1
	slli t1, t1, 1
	add t1, t1, t6
	add a3, a3, t1
#obsuga paddingu
	mul t2, t0, a2
	add a3, a3, t2
#kolorowanie piksela
	li t2, 0xff
	sb t2, (a3)
	li t2, 0x00
	addi a3, a3, 1
	sb t2, (a3)
	addi a3, a3, 1
	sb t2, (a3) 
	
	blt a5, a4, count
saveexit:	
#zapisanie obrazu BMP
	la a0, out
	li a1, 1
	li a7, 1024
	ecall
	
	mv t0, a0
	bltz a0, error
	
	lw a1, start
	lw a2, size
	li a7, 64
	ecall
	mv a0, t0
	li a7, 57
	ecall
			
end:
#zakoñczenie programu bez bledu
	li a7, 10
	ecall
error:
	la a0, emsg
	li a7, 4
	ecall
	li a7, 93
	li a0, -1
	ecall
	
