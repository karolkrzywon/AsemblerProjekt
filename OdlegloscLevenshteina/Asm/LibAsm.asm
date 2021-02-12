;														Odleg�o�� Levenshteina v1.0
;
;														   autor: Karol Krzywo�
;	Changelog:
;	- 11.10.2020 - wersja 0.1.0 - utoworzenie projektu wraz z repozytorium na Githubie
;	- 15.10.2020 - wersja 0.1.1 - utworzenie szkicu projektu oraz 
;				   dw�ch dodatkowych projekt�w s�u�acyh do tworzenia bibliotek dll 
;	- 17.10.2020 - wesja 0.1.2 - stworzenie GUI
;	- 19.10.2020 - wersja 0.2 - dodanie funkcji obliczaj�cej odleg�o�� levenshteina w c++
;	- 22.10.2020 - wersja 0.3 - dodanie wczytywania wyraz�w z pliku txt - zmiana GUI
;	- 30.10.2020 - wersja 0.4 - dodanie obs�ugi w�tk�w pomiaru czasu dla funkcji dll
;	- 14.01.2020 - wersja 0.5 - pierwsza wersja biblioteki w asm
;   - 01.02.2020 - wersja 1.0 - poprawiona biblioteka asm, nale�ycie skomentowana
.data
_8 QWORD 8, 0
_4 QWORD 0, 4

.code					
;
; algorithm(int** inputArray, unsigned char* inputWord, int rows, int columns)
;
; Parametry wejsciowe procedury:      
;	- int** inputArray - wskaznik na dwuwymiarowa tablice int�w slu��ca do realizacji algorytmu pozwalaj�cego obliczy� odleg�o�� edycyjn� - przechowywany w RCX
;	- unsigned char * input - wskaznik na jednowymiarowa tablice char�w sk�adaj�ca si� z dw�ch por�wnywanych s��w - przechowywany w rejestrze RDX
;	- int rows - ilosc wierszy w tablicy (d�ugo�� pierwszego s�owa + 1) - przechowywana w rejestrze R8 - warto�� ta powinna by� zawsze wi�ksza od 0, przyjmuje warto�ci w zakresie 0-64
;	- int columns - ilosc kolumn w tablicy (d�ugo�� pierwszego s�owa + 1) - przechowywana w rejetrze R9 - - warto�� ta powinna by� zawsze wi�ksza od 0, przyjmuje warto�ci w zakresie 0-64
;
;
; Parametry wyjsciowe procedury:
;	- procedura zwraca odleg�o�� Levenshteina mi�dzy dwoma wyrazami
;	
; U�ywane rejestry: RAX, R10, R11, R12, R13, R14, R15 
;

algorithm proc				
	push rbx										;wrzucenie warto�ci rejestru rbx na stos

	mov R15, 0										; licznik p�tli, p�tla zaczyna� b�dzie iteracj� od warto�ci 0
rowsloop:											; p�tla wpisuj�ca kolejne warto�ci (0,1,2,3,......,rows-1) do kolumny 0 w tabeli
	cmp R15, R8										; sprawdzenie warunku ko�ca p�tli - czy p�tla przeiterowa�a przez wszystkie wiersze (w c++ (i<rows))
	jge rowsloopend									;je�li koniec p�tli skok poza p�tl�
	mov eax, R15d									;wczytanie do rejestru eax aktualnej warto�ci iteratora p�tli, aby uzyska� odpowiedni adres z tabeli
	sal rax, 3										;przesuni�cie bitowe warto��i w rax o 3 w lewo, aby uzyska� poprawny adres wska�nika na odpowiedni wiersz (wska�nik wielko�ci 8 bajt�w)
	mov rbx, QWORD PTR [rcx+rax]					; wczytanie do rbx wska�nika na pierwszy element w wybranym wierszu (element w kolumnie 0)
	mov DWORD PTR[rbx], R15d						; zapisanie warto�ci iteratora] do adresu znajduj�cego si� pod wska�nikiem na pierwszy elemnt wiersza  [i][0]
	inc R15											;inkrementacja licznika p�tli
	jmp rowsloop									;skok do pocz�tku p�tli
rowsloopend:										;koniec p�tli
	mov R15, 0										; wyzerowanie licznika p�tli
		
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

	mov R14, 1										;licznik zewn�trznej p�tli, rozpoczyna ona iteracj� od 1 (pierwszy wiersz i kolumna ju� wype�nione)
outerloop:
	cmp R14, R8										;sprawdzenie warunku p�tli (i<rows)
	jge outerloopend								;je�li warto�� licznika wi�ksza lub r�wna ilo�ci wierszy to koniec p�tli
	mov R15, 1										;licznik wewn�trznej p�tli, rozpoczyna si� od 1
innerloop:
	cmp R15, R9										;sprawdzenie warunku p�tli (j<columns)
	jge innerloopend								;je�li warto�� w licznika wi�ksza lub r�wna ilo�ci kolumn to koniec p�tli

	mov R10, 1										;koszt operacji - je�eli wybrane znaki z obu wyraz�w s� takie same b�dzie to 0, jezeli nie to 1

	mov eax, R14d									;wczytanie warto�ci licznika zewn�trznej p�tli do rax
	movzx R11d, BYTE PTR [rdx+rax-1]				;wczytanie znaku z pierwszego wyrazu do por�wnania spod indeksu [i-1] 
													;warto�� przechowywana w R11 b�dzie wykorzystana od obliczenia kosztu
	mov eax, R15d									;wczytanie znaku jak wy�ej spod indeksu [i+rows-2]
	mov rbx, R8
	add rax, rbx
	movzx R12d, BYTE PTR [rdx+rax-2]

	mov eax, 0										;wpisanie zera do rax potrzebnego w przypadku, gdy oba znaki s� takie same - cmove przyjmuje jedynie dwa rejestry
	cmp R11b, R12b									;por�wnanie znak�w z obu wyraz�w 
	cmove R10, rax									;wpisanie 0 jako koszt operacji, je�eli znaki s� takie same

													;poni�ej obliczanie odpowiednich adres�w kom�rek w tabeli [i-1][j], [i][j-1], [i-1][j-1], a nast�pnie wczytanie zawarto�ci spod tych adres�w
	movq xmm0, R14									;wczytanie zawarto�ci licznika zewn�trznej p�tli (i) do xmm0
	psllq xmm0, 3									;przesuni�cie bitowe o 3 w lewo, aby uzyska� dobry adres (wska�nik zajmuje 8 bajt�w w pami�ci)
	movq xmm1, rcx									;wczytanie adresu na pocz�tek tabeli 
	paddq xmm0, xmm1								;dodanie offsetu do adresu pocz�tku tabeli - wybranie odpowiedniego wiersza
    vpunpcklqdq xmm0, xmm0, xmm0					;skopiowanie zawarto�ci ni�szej po�owy rejestru xmm0 do wy�szej - adresy kom�rek [i-1][j] i [i][j-1] b�d� obliczane jednocz�snie w obu po�owach xmm0
	movdqu xmm1, xmmword ptr [_8]					;wczytanie do xmm1 zawarto�ci potrzebnej do odejmowania
	psubd xmm0, xmm1								;odj�cie od zawarto�ci ni�szej po�owy 8, aby zamiast [i] uzyska� [i-1]
	pextrq rax, xmm0, 0								;wczytanie adresu z dolnej po�owy xmm0 do rax
	pextrq rbx, xmm0, 1								;wczytanie adresu z g�rnej po�owy xmm0 do rbx
	movq xmm0, QWORD PTR[rax]						;wczytanie do dolnej po�owy xmm0 wska�nika na pierwsz� kom�rk� w kolumnie [i-1] - kom�rka [i-1][0]
	movhps xmm0, QWORD PTR[rbx]						;wczytanie do g�rnej po�owy xmm0 wska�nika na pierwsz� kom�rk� w kolumnie [i] - kom�rka [i][0]					
	
	movq xmm1, R15									;wczytanie licznika wewn�trznej p�tli (j) do xmm1
	psllq xmm1, 2									;przesuni�cie bitowe o 2 w lewo, aby uzyska� dobry adres (integer zajmuje 4 bajt�w w pami�ci)		
    vpunpcklqdq xmm1, xmm1, xmm1					;skopiowanie zawarto�ci ni�szej po�owy rejestru xmm0 do wy�szej - adresy kom�rek [i-1][j] i [i][j-1] b�d� obliczane jednocz�snie w obu po�owach xmm0
	movdqu xmm2, xmmword ptr [_4]					;wczytanie zawarto�ci do odejmowania
	psubd xmm1, xmm2								;odj�cie od zawarto�ci g�rnej po�owy 4, aby zamiast [j] uzyska� [j-1]						
	paddd xmm1, xmm0								;dodanie offsetu (kolumny) do adresu pierwszej kom�rki w wybranym wcze�niej wierszu 
	pextrq rax, xmm1, 0								;wczytanie adresu z dolnej po�owy xmm1 do rax
	pextrq rbx, xmm1, 1								;wczytanie adresu z g�rnej po�owy xmm1 do rbx
	mov R11d, DWORD PTR[rax]						;zawarto�� [i-1][j] do R11
	mov R12d, DWORD PTR[rbx]						;zawarto�� [i][j-1] do R12
	mov R13d, DWORD PTR[rax-4]						;zawarto�� [i-1][j-1] do R13
	inc R11											;zwi�kszenie zawarto�ci z [i-1][j] wed�ug algorytmu
	inc R12											;zwi�kszenie zawarto�ci z [i][j-1] wed�ug algorytmu
	add R13, R10									;dodanie do zawarto�ci z [i-1][j-1] kosztu operacji (0 lub 1)

	cmp R11, R12									;znalezienie minimum z powy�ej odczytanych warto�ci zapisanych w rejestrach R11, R12, R13 - min(R11,R12,R13)
	cmovg R11, R12									;wpisanie minimum do R11
	cmp R11, R13
	cmovg R11, R13									;wpisanie minimum do R11

													;wpisanie minimum do aktualnie wype�nianej kom�rki pod adresem [i][j], znalezienie adresu w taki sam 
													;spos�b jak w powy�szych przypadkach
	mov eax, R14d									
	sal rax, 3
	mov rbx, QWORD PTR [rcx+rax]
	mov eax, R15d
	sal rax, 2
	mov DWORD PTR[rbx+rax], R11d					;wpisanie wybranego minimum z trzech warto�ci do tablicy pod indeks[i][j]

	inc R15											;inkrementacja licznika wewn�trznej p�tli
	jmp innerloop									;skok do pocz�tku wewn�trznej p�tli

innerloopend:										;koniec wewn�trznej p�tli
	inc R14											;zwi�kszenie licznika zewn�trznej p�tli
	jmp outerloop									;skok do pocz�tku zwen�trznej p�tlii

outerloopend:										;koniec zewn�trznej p�tli
	mov rax, R8										;wczytanie ilo�ci wierszy
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