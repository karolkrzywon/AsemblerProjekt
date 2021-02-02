;														Odleg�o�� Levenshteina v0.5
;
;														   autor: Karol Krzywo�

.data
.code					
;
; algorithm(int** inputArray, unsigned char* inputWord, int rows, int columns);
;
; Parametry wejsciowe procedury:
;	- int** inputArray - wskaznik na dwuwymiarowa tablice int�w slu��ca do realizacji algorytmu pozwalaj�cego obliczy� odleg�o�� edycyjn� - przechowywany w RCX
;	- unsigned char * input - wskaznik na jednowymiarowa tablice char�w sk�adaj�ca si� z dw�ch por�wnywanych s��w - przechowywany w rejestrze RDX
;	- int rows - ilosc wierszy w tablicy (d�ugo�� pierwszego s�owa + 1) - przechowywana w rejestrze R8
;	- int columns - ilosc kolumn w tablicy (d�ugo�� pierwszego s�owa + 1) - przechowywana w rejetrze R9
;
;
; Parametry wyjsciowe procedury:
;	- procedura zwraca odleg�o�� Levenshteina mi�dzy dwoma wyrazami
;	
; U�ywane rejestry: RAX, RBX, RCX, RDX, R8, R9, R10, R11, R12, R13, R14, R15
;
algorithm proc				
	push rbx										;wrzucenie warto�ci rejestru rbx na stos

	mov R15, 0										; R15 jest wykorzystywany jako licznik p�tli - p�tla rozpoczyna si� iterowa�  od warto�ci 0
rowsloop:											; p�tla wpisuj�ca kolejne warto�ci (0,1,2,3,......,rows-1) do kolumny 0 w tabeli
	cmp R15, R8										; sprawdzenie warunku ko�ca p�tli (w c++ (i<rows))
	jge rowsloopend									;je�li koniec p�tli skok poza p�tl�
	mov eax, R15d									;wczytanie do rejestru eax aktualnej warto�ci R15 (sprawdzenie, kt�ra to iteracja p�tli)
	sal rax, 3										;przesuni�cie bitowe warto��i w rax o 3 w lewo, aby uzyska� poprawny adres wska�nika na odpowiedni wiersz
	mov rbx, QWORD PTR [rcx+rax]					; wczytanie do rbx wska�nika na pierwszy element w wybranym wierszy (elemnt w kolumnie 0)
	mov DWORD PTR[rbx], R15d						; zapisanie warto�ci R15 do adresu znajduj�cego si� pod wska�nikiem na pierwszy elemnt wiersza
	inc R15											;inkrementacja licznika p�tli
	jmp rowsloop									;skok do pocz�tku p�tli
rowsloopend:										;koniec p�tli
	mov R15, 0										; wyzerowanie rejestru R15, aby mo�na go by�o u�y� w nast�pnej p�tli
		
columnsloop:										; p�tla analogiczna do powy�szej (rowsloop), wykonuje to samo tylko �e dla pierwszej kolumny a nie wiersza
	cmp R15, R9
	jge columnsloopend
	mov rbx, QWORD PTR [rcx]
	mov eax, R15d
	sal rax, 2
	mov DWORD PTR[rbx+rax], R15d
	inc R15
	jmp columnsloop
columnsloopend:

	mov R14, 1										;R14 b�dzie licznikiem zewn�trznej p�tli, rozpoczyna si� ona od 1
outerloop:
	cmp R14, R8										;sprawdzenie warunku p�tli (i<rows)
	jge outerloopend								;je�li warto�� w R14 wi�ksza lub r�wna R8 (ilo�ci wierszy) to koniec p�tli
	mov R15, 1										;licznik wewn�trznej p�tli, rozpoczyna si� od 1
innerloop:
	cmp R15, R9										;sprawdzenie warunku p�tli (j<columns)
	jge innerloopend								;je�li warto�� w R15 wi�ksza lub r�wna R9 (ilo�ci kolumn) to koniec p�tli

	mov R10, 1										;koszt operacji - je�eli wybrane znaki z obu wyraz�w s� takie same b�dzie to 0, j�zeli nie to 1

	mov eax, R14d									;wczytanie warto�ci licznika zewn�trznej p�tli do rax
	movzx R11d, BYTE PTR [rdx+rax-1]				;wczytanie znaku z tablicy spod indeksu [i-1] do rejestru R11 w taki spos�b, aby wype�ni� ca�y rejestr w po��dany spos�b
													;warto�� przechowywana w R11 b�dzie wykorzystana od obliczenia kosztu
	mov eax, R15d									;wczytanie znaku jak wy�ej spod indeksu [i+rows-2]
	mov rbx, R8
	add rax, rbx
	movzx R12d, BYTE PTR [rdx+rax-2]

	mov eax, 0										;wpisanie zera do rax potrzebnego w przypadku, gdy oba znaki s� takie same - cmove przyjmuje jedynie dwa rejestry
	cmp R11b, R12b									;por�wnanie znaku w R11b ze znakiem w R12b
	cmove R10, rax									;wpisanie 0 do R10, je�eli R11b=R12b

													;warto�� spod indeksu [i-1][j] (z kom�rki znajduj�cej si� nad wype�nian�) z tabeli i zapisanie jej do rejestru R11	
	mov eax, R14d									;wczytanie licznika zewn�trznej p�tli do rax
	sal rax, 3										;przesuni�cie bitowe o 3 w lewo, aby obliczy� dobry adres
	mov rbx, QWORD PTR [rcx+rax-8]					;wska�nik na wiersz o indeksie [i-1]
	mov eax, R15d									;wczytanie licznika wewn�trznej p�tli do rax
	sal rax, 2										;przesuni�cie bitowe o 2 w lewo, aby obliczy� dobry adres
	mov R11d, DWORD PTR[rbx+rax]					;zapisanie warto�ci z tablicy do rejestru R11
	inc R11											;zwi�kszenie warto�ci w R11 o 1 - zgodnie z algorytmem obliczania odleg�o�ci edycyjnej

	mov eax, R14d									;post�powanie takie same jak w powy�szym, jednak tym razem warto�� spod indeksu [i][j-1] (z kom�rki po lewej)
	sal rax, 3
	mov rbx, QWORD PTR [rcx+rax]
	mov eax, R15d
	sal rax, 2
	mov R12d, DWORD PTR[rbx+rax-4]  
	inc R12
	
	mov eax, R14d									;post�powanie jak w powy�szych spod indeksu [i-1][j-1] - zamiast inkrementowa� rejestr z wynikiem 
	sal rax, 3										;dodawany jest koszt zamiany znaku obliczony wcze�niej
	mov rbx, QWORD PTR [rcx+rax-8]
	mov eax, R15d
	sal rax, 2
	mov R13d, DWORD PTR[rbx+rax-4]  
	add R13, R10									;dodanie kosztu przekszta�cenia znaku

	cmp R11, R12									;znalezienie minimum z powy�szych warto�ci zapisanych w rejestracj R11, R12, R13
	cmovg R11, R12									;je�li R11 wi�ksze od R12, wpisanie warto�ci z R12 do R11
	cmp R11, R13
	cmovg R11, R13									;je�li R11 wi�ksze od R13, wpisanie warto�ci z R13 do R11

													;wpisanie minimum do aktualnie wype�nianej kom�rki pod adresem [i][j], znalezienie adresu w taki sam 
													;spos�b jak w powy�szych przypadkach
	mov eax, R14d									
	sal rax, 3
	mov rbx, QWORD PTR [rcx+rax]
	mov eax, R15d
	sal rax, 2
	mov DWORD PTR[rbx+rax], R11d					;wpisanie wybranego minimum do tablicy 

	inc R15											;inkrementacja licznika wewn�trznej p�tli
	jmp innerloop									;skok do pocz�tku wewn�trznej p�tli

innerloopend:										;koniec wewn�trznej p�tli
	inc R14											;zwi�kszenie licznika zewn�trznej p�tli
	jmp outerloop									;skok do pocz�tku zwen�trznej p�tlii

outerloopend:										;koniec zewn�trznej p�tli
	mov rax, R8										;wczytanie ilo�ci wierszy do rejestru rax
	sal rax, 3										;przesuni�cie bitowe o 3 w lewo 
	mov rbx, QWORD PTR[rcx+rax-8]					;odczytanie wska�nika na wiersz i wpisanie go do rejestru rbx
	mov rax, R9										;wczytanie ilo�ci kolumn do rejestru rax
	sal rax, 2										;przesuni�cie bitowe o 2 w lewo
	mov eax, DWORD PTR[rbx+rax-4]					;wczytanie kom�rki z tabeli o indeksie [rows-1][columns-1] (wynik zwr�cony przez algorytm)
													;do rejestru rax, tak aby by� zwr�cony przez procedur� algorithm

	pop rbx											;zwr�cenie ze stosu warto�ci rejestru rbx przed wywo�aniem procedury algorithm do rejestru rbx
	ret												;powr�t z funkcji
algorithm endp										;koniec funkcji	
end