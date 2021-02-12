;														Odleg³oœæ Levenshteina v1.0
;
;														   autor: Karol Krzywoñ
;	Changelog:
;	- 11.10.2020 - wersja 0.1.0 - utoworzenie projektu wraz z repozytorium na Githubie
;	- 15.10.2020 - wersja 0.1.1 - utworzenie szkicu projektu oraz 
;				   dwóch dodatkowych projektów s³u¿acyh do tworzenia bibliotek dll 
;	- 17.10.2020 - wesja 0.1.2 - stworzenie GUI
;	- 19.10.2020 - wersja 0.2 - dodanie funkcji obliczaj¹cej odleg³oœæ levenshteina w c++
;	- 22.10.2020 - wersja 0.3 - dodanie wczytywania wyrazów z pliku txt - zmiana GUI
;	- 30.10.2020 - wersja 0.4 - dodanie obs³ugi w¹tków pomiaru czasu dla funkcji dll
;	- 14.01.2020 - wersja 0.5 - pierwsza wersja biblioteki w asm
;   - 01.02.2020 - wersja 1.0 - poprawiona biblioteka asm, nale¿ycie skomentowana
.data
_8 QWORD 8, 0
_4 QWORD 0, 4

.code					
;
; algorithm(int** inputArray, unsigned char* inputWord, int rows, int columns)
;
; Parametry wejsciowe procedury:      
;	- int** inputArray - wskaznik na dwuwymiarowa tablice intów slu¿¹ca do realizacji algorytmu pozwalaj¹cego obliczyæ odleg³oœæ edycyjn¹ - przechowywany w RCX
;	- unsigned char * input - wskaznik na jednowymiarowa tablice charów sk³adaj¹ca siê z dwóch porównywanych s³ów - przechowywany w rejestrze RDX
;	- int rows - ilosc wierszy w tablicy (d³ugoœæ pierwszego s³owa + 1) - przechowywana w rejestrze R8 - wartoœæ ta powinna byæ zawsze wiêksza od 0, przyjmuje wartoœci w zakresie 0-64
;	- int columns - ilosc kolumn w tablicy (d³ugoœæ pierwszego s³owa + 1) - przechowywana w rejetrze R9 - - wartoœæ ta powinna byæ zawsze wiêksza od 0, przyjmuje wartoœci w zakresie 0-64
;
;
; Parametry wyjsciowe procedury:
;	- procedura zwraca odleg³oœæ Levenshteina miêdzy dwoma wyrazami
;	
; U¿ywane rejestry: RAX, R10, R11, R12, R13, R14, R15 
;

algorithm proc				
	push rbx										;wrzucenie wartoœci rejestru rbx na stos

	mov R15, 0										; licznik pêtli, pêtla zaczynaæ bêdzie iteracjê od wartoœci 0
rowsloop:											; pêtla wpisuj¹ca kolejne wartoœci (0,1,2,3,......,rows-1) do kolumny 0 w tabeli
	cmp R15, R8										; sprawdzenie warunku koñca pêtli - czy pêtla przeiterowa³a przez wszystkie wiersze (w c++ (i<rows))
	jge rowsloopend									;jeœli koniec pêtli skok poza pêtlê
	mov eax, R15d									;wczytanie do rejestru eax aktualnej wartoœci iteratora pêtli, aby uzyskaæ odpowiedni adres z tabeli
	sal rax, 3										;przesuniêcie bitowe wartoœæi w rax o 3 w lewo, aby uzyskaæ poprawny adres wskaŸnika na odpowiedni wiersz (wskaŸnik wielkoœci 8 bajtów)
	mov rbx, QWORD PTR [rcx+rax]					; wczytanie do rbx wskaŸnika na pierwszy element w wybranym wierszu (element w kolumnie 0)
	mov DWORD PTR[rbx], R15d						; zapisanie wartoœci iteratora] do adresu znajduj¹cego siê pod wskaŸnikiem na pierwszy elemnt wiersza  [i][0]
	inc R15											;inkrementacja licznika pêtli
	jmp rowsloop									;skok do pocz¹tku pêtli
rowsloopend:										;koniec pêtli
	mov R15, 0										; wyzerowanie licznika pêtli
		
columnsloop:										; pêtla analogiczna do powy¿szej (rowsloop), wykonuje to samo tylko ¿e dla pierwszej kolumny a nie wiersza
	cmp R15, R9
	jge columnsloopend
	mov rbx, QWORD PTR [rcx]
	mov eax, R15d
	sal rax, 2
	mov DWORD PTR[rbx+rax], R15d
	inc R15
	jmp columnsloop
columnsloopend:

	mov R14, 1										;licznik zewnêtrznej pêtli, rozpoczyna ona iteracjê od 1 (pierwszy wiersz i kolumna ju¿ wype³nione)
outerloop:
	cmp R14, R8										;sprawdzenie warunku pêtli (i<rows)
	jge outerloopend								;jeœli wartoœæ licznika wiêksza lub równa iloœci wierszy to koniec pêtli
	mov R15, 1										;licznik wewnêtrznej pêtli, rozpoczyna siê od 1
innerloop:
	cmp R15, R9										;sprawdzenie warunku pêtli (j<columns)
	jge innerloopend								;jeœli wartoœæ w licznika wiêksza lub równa iloœci kolumn to koniec pêtli

	mov R10, 1										;koszt operacji - je¿eli wybrane znaki z obu wyrazów s¹ takie same bêdzie to 0, jezeli nie to 1

	mov eax, R14d									;wczytanie wartoœci licznika zewnêtrznej pêtli do rax
	movzx R11d, BYTE PTR [rdx+rax-1]				;wczytanie znaku z pierwszego wyrazu do porównania spod indeksu [i-1] 
													;wartoœæ przechowywana w R11 bêdzie wykorzystana od obliczenia kosztu
	mov eax, R15d									;wczytanie znaku jak wy¿ej spod indeksu [i+rows-2]
	mov rbx, R8
	add rax, rbx
	movzx R12d, BYTE PTR [rdx+rax-2]

	mov eax, 0										;wpisanie zera do rax potrzebnego w przypadku, gdy oba znaki s¹ takie same - cmove przyjmuje jedynie dwa rejestry
	cmp R11b, R12b									;porównanie znaków z obu wyrazów 
	cmove R10, rax									;wpisanie 0 jako koszt operacji, je¿eli znaki s¹ takie same

													;poni¿ej obliczanie odpowiednich adresów komórek w tabeli [i-1][j], [i][j-1], [i-1][j-1], a nastêpnie wczytanie zawartoœci spod tych adresów
	movq xmm0, R14									;wczytanie zawartoœci licznika zewnêtrznej pêtli (i) do xmm0
	psllq xmm0, 3									;przesuniêcie bitowe o 3 w lewo, aby uzyskaæ dobry adres (wskaŸnik zajmuje 8 bajtów w pamiêci)
	movq xmm1, rcx									;wczytanie adresu na pocz¹tek tabeli 
	paddq xmm0, xmm1								;dodanie offsetu do adresu pocz¹tku tabeli - wybranie odpowiedniego wiersza
    vpunpcklqdq xmm0, xmm0, xmm0					;skopiowanie zawartoœci ni¿szej po³owy rejestru xmm0 do wy¿szej - adresy komórek [i-1][j] i [i][j-1] bêd¹ obliczane jednoczêsnie w obu po³owach xmm0
	movdqu xmm1, xmmword ptr [_8]					;wczytanie do xmm1 zawartoœci potrzebnej do odejmowania
	psubd xmm0, xmm1								;odjêcie od zawartoœci ni¿szej po³owy 8, aby zamiast [i] uzyskaæ [i-1]
	pextrq rax, xmm0, 0								;wczytanie adresu z dolnej po³owy xmm0 do rax
	pextrq rbx, xmm0, 1								;wczytanie adresu z górnej po³owy xmm0 do rbx
	movq xmm0, QWORD PTR[rax]						;wczytanie do dolnej po³owy xmm0 wskaŸnika na pierwsz¹ komórkê w kolumnie [i-1] - komórka [i-1][0]
	movhps xmm0, QWORD PTR[rbx]						;wczytanie do górnej po³owy xmm0 wskaŸnika na pierwsz¹ komórkê w kolumnie [i] - komórka [i][0]					
	
	movq xmm1, R15									;wczytanie licznika wewnêtrznej pêtli (j) do xmm1
	psllq xmm1, 2									;przesuniêcie bitowe o 2 w lewo, aby uzyskaæ dobry adres (integer zajmuje 4 bajtów w pamiêci)		
    vpunpcklqdq xmm1, xmm1, xmm1					;skopiowanie zawartoœci ni¿szej po³owy rejestru xmm0 do wy¿szej - adresy komórek [i-1][j] i [i][j-1] bêd¹ obliczane jednoczêsnie w obu po³owach xmm0
	movdqu xmm2, xmmword ptr [_4]					;wczytanie zawartoœci do odejmowania
	psubd xmm1, xmm2								;odjêcie od zawartoœci górnej po³owy 4, aby zamiast [j] uzyskaæ [j-1]						
	paddd xmm1, xmm0								;dodanie offsetu (kolumny) do adresu pierwszej komórki w wybranym wczeœniej wierszu 
	pextrq rax, xmm1, 0								;wczytanie adresu z dolnej po³owy xmm1 do rax
	pextrq rbx, xmm1, 1								;wczytanie adresu z górnej po³owy xmm1 do rbx
	mov R11d, DWORD PTR[rax]						;zawartoœæ [i-1][j] do R11
	mov R12d, DWORD PTR[rbx]						;zawartoœæ [i][j-1] do R12
	mov R13d, DWORD PTR[rax-4]						;zawartoœæ [i-1][j-1] do R13
	inc R11											;zwiêkszenie zawartoœci z [i-1][j] wed³ug algorytmu
	inc R12											;zwiêkszenie zawartoœci z [i][j-1] wed³ug algorytmu
	add R13, R10									;dodanie do zawartoœci z [i-1][j-1] kosztu operacji (0 lub 1)

	cmp R11, R12									;znalezienie minimum z powy¿ej odczytanych wartoœci zapisanych w rejestrach R11, R12, R13 - min(R11,R12,R13)
	cmovg R11, R12									;wpisanie minimum do R11
	cmp R11, R13
	cmovg R11, R13									;wpisanie minimum do R11

													;wpisanie minimum do aktualnie wype³nianej komórki pod adresem [i][j], znalezienie adresu w taki sam 
													;sposób jak w powy¿szych przypadkach
	mov eax, R14d									
	sal rax, 3
	mov rbx, QWORD PTR [rcx+rax]
	mov eax, R15d
	sal rax, 2
	mov DWORD PTR[rbx+rax], R11d					;wpisanie wybranego minimum z trzech wartoœci do tablicy pod indeks[i][j]

	inc R15											;inkrementacja licznika wewnêtrznej pêtli
	jmp innerloop									;skok do pocz¹tku wewnêtrznej pêtli

innerloopend:										;koniec wewnêtrznej pêtli
	inc R14											;zwiêkszenie licznika zewnêtrznej pêtli
	jmp outerloop									;skok do pocz¹tku zwenêtrznej pêtlii

outerloopend:										;koniec zewnêtrznej pêtli
	mov rax, R8										;wczytanie iloœci wierszy
	sal rax, 3										;przesuniêcie bitowe o 3 w lewo 
	mov rbx, QWORD PTR[rcx+rax-8]					;odczytanie wskaŸnika na wiersz i wpisanie go do rejestru rbx
	mov rax, R9										;wczytanie iloœci kolumn do rejestru rax
	sal rax, 2										;przesuniêcie bitowe o 2 w lewo
	mov eax, DWORD PTR[rbx+rax-4]					;wczytanie komórki z tabeli o indeksie [rows-1][columns-1] (wynik zwrócony przez algorytm)
													;do rejestru rax, tak aby by³ zwrócony przez procedurê algorithm

	pop rbx											;zwrócenie ze stosu wartoœci rejestru rbx przed wywo³aniem procedury algorithm do rejestru rbx
	ret												;powrót z funkcji
algorithm endp										;koniec funkcji	
end