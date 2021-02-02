;														Odleg³oœæ Levenshteina v0.5
;
;														   autor: Karol Krzywoñ

.data
.code					
;
; algorithm(int** inputArray, unsigned char* inputWord, int rows, int columns);
;
; Parametry wejsciowe procedury:
;	- int** inputArray - wskaznik na dwuwymiarowa tablice intów slu¿¹ca do realizacji algorytmu pozwalaj¹cego obliczyæ odleg³oœæ edycyjn¹ - przechowywany w RCX
;	- unsigned char * input - wskaznik na jednowymiarowa tablice charów sk³adaj¹ca siê z dwóch porównywanych s³ów - przechowywany w rejestrze RDX
;	- int rows - ilosc wierszy w tablicy (d³ugoœæ pierwszego s³owa + 1) - przechowywana w rejestrze R8
;	- int columns - ilosc kolumn w tablicy (d³ugoœæ pierwszego s³owa + 1) - przechowywana w rejetrze R9
;
;
; Parametry wyjsciowe procedury:
;	- procedura zwraca odleg³oœæ Levenshteina miêdzy dwoma wyrazami
;	
; U¿ywane rejestry: RAX, RBX, RCX, RDX, R8, R9, R10, R11, R12, R13, R14, R15
;
algorithm proc				
	push rbx										;wrzucenie wartoœci rejestru rbx na stos

	mov R15, 0										; R15 jest wykorzystywany jako licznik pêtli - pêtla rozpoczyna siê iterowaæ  od wartoœci 0
rowsloop:											; pêtla wpisuj¹ca kolejne wartoœci (0,1,2,3,......,rows-1) do kolumny 0 w tabeli
	cmp R15, R8										; sprawdzenie warunku koñca pêtli (w c++ (i<rows))
	jge rowsloopend									;jeœli koniec pêtli skok poza pêtlê
	mov eax, R15d									;wczytanie do rejestru eax aktualnej wartoœci R15 (sprawdzenie, która to iteracja pêtli)
	sal rax, 3										;przesuniêcie bitowe wartoœæi w rax o 3 w lewo, aby uzyskaæ poprawny adres wskaŸnika na odpowiedni wiersz
	mov rbx, QWORD PTR [rcx+rax]					; wczytanie do rbx wskaŸnika na pierwszy element w wybranym wierszy (elemnt w kolumnie 0)
	mov DWORD PTR[rbx], R15d						; zapisanie wartoœci R15 do adresu znajduj¹cego siê pod wskaŸnikiem na pierwszy elemnt wiersza
	inc R15											;inkrementacja licznika pêtli
	jmp rowsloop									;skok do pocz¹tku pêtli
rowsloopend:										;koniec pêtli
	mov R15, 0										; wyzerowanie rejestru R15, aby mo¿na go by³o u¿yæ w nastêpnej pêtli
		
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

	mov R14, 1										;R14 bêdzie licznikiem zewnêtrznej pêtli, rozpoczyna siê ona od 1
outerloop:
	cmp R14, R8										;sprawdzenie warunku pêtli (i<rows)
	jge outerloopend								;jeœli wartoœæ w R14 wiêksza lub równa R8 (iloœci wierszy) to koniec pêtli
	mov R15, 1										;licznik wewnêtrznej pêtli, rozpoczyna siê od 1
innerloop:
	cmp R15, R9										;sprawdzenie warunku pêtli (j<columns)
	jge innerloopend								;jeœli wartoœæ w R15 wiêksza lub równa R9 (iloœci kolumn) to koniec pêtli

	mov R10, 1										;koszt operacji - je¿eli wybrane znaki z obu wyrazów s¹ takie same bêdzie to 0, jêzeli nie to 1

	mov eax, R14d									;wczytanie wartoœci licznika zewnêtrznej pêtli do rax
	movzx R11d, BYTE PTR [rdx+rax-1]				;wczytanie znaku z tablicy spod indeksu [i-1] do rejestru R11 w taki sposób, aby wype³niæ ca³y rejestr w po¿¹dany sposób
													;wartoœæ przechowywana w R11 bêdzie wykorzystana od obliczenia kosztu
	mov eax, R15d									;wczytanie znaku jak wy¿ej spod indeksu [i+rows-2]
	mov rbx, R8
	add rax, rbx
	movzx R12d, BYTE PTR [rdx+rax-2]

	mov eax, 0										;wpisanie zera do rax potrzebnego w przypadku, gdy oba znaki s¹ takie same - cmove przyjmuje jedynie dwa rejestry
	cmp R11b, R12b									;porównanie znaku w R11b ze znakiem w R12b
	cmove R10, rax									;wpisanie 0 do R10, je¿eli R11b=R12b

													;wartoœæ spod indeksu [i-1][j] (z komórki znajduj¹cej siê nad wype³nian¹) z tabeli i zapisanie jej do rejestru R11	
	mov eax, R14d									;wczytanie licznika zewnêtrznej pêtli do rax
	sal rax, 3										;przesuniêcie bitowe o 3 w lewo, aby obliczyæ dobry adres
	mov rbx, QWORD PTR [rcx+rax-8]					;wskaŸnik na wiersz o indeksie [i-1]
	mov eax, R15d									;wczytanie licznika wewnêtrznej pêtli do rax
	sal rax, 2										;przesuniêcie bitowe o 2 w lewo, aby obliczyæ dobry adres
	mov R11d, DWORD PTR[rbx+rax]					;zapisanie wartoœci z tablicy do rejestru R11
	inc R11											;zwiêkszenie wartoœci w R11 o 1 - zgodnie z algorytmem obliczania odleg³oœci edycyjnej

	mov eax, R14d									;postêpowanie takie same jak w powy¿szym, jednak tym razem wartoœæ spod indeksu [i][j-1] (z komórki po lewej)
	sal rax, 3
	mov rbx, QWORD PTR [rcx+rax]
	mov eax, R15d
	sal rax, 2
	mov R12d, DWORD PTR[rbx+rax-4]  
	inc R12
	
	mov eax, R14d									;postêpowanie jak w powy¿szych spod indeksu [i-1][j-1] - zamiast inkrementowaæ rejestr z wynikiem 
	sal rax, 3										;dodawany jest koszt zamiany znaku obliczony wczeœniej
	mov rbx, QWORD PTR [rcx+rax-8]
	mov eax, R15d
	sal rax, 2
	mov R13d, DWORD PTR[rbx+rax-4]  
	add R13, R10									;dodanie kosztu przekszta³cenia znaku

	cmp R11, R12									;znalezienie minimum z powy¿szych wartoœci zapisanych w rejestracj R11, R12, R13
	cmovg R11, R12									;jeœli R11 wiêksze od R12, wpisanie wartoœci z R12 do R11
	cmp R11, R13
	cmovg R11, R13									;jeœli R11 wiêksze od R13, wpisanie wartoœci z R13 do R11

													;wpisanie minimum do aktualnie wype³nianej komórki pod adresem [i][j], znalezienie adresu w taki sam 
													;sposób jak w powy¿szych przypadkach
	mov eax, R14d									
	sal rax, 3
	mov rbx, QWORD PTR [rcx+rax]
	mov eax, R15d
	sal rax, 2
	mov DWORD PTR[rbx+rax], R11d					;wpisanie wybranego minimum do tablicy 

	inc R15											;inkrementacja licznika wewnêtrznej pêtli
	jmp innerloop									;skok do pocz¹tku wewnêtrznej pêtli

innerloopend:										;koniec wewnêtrznej pêtli
	inc R14											;zwiêkszenie licznika zewnêtrznej pêtli
	jmp outerloop									;skok do pocz¹tku zwenêtrznej pêtlii

outerloopend:										;koniec zewnêtrznej pêtli
	mov rax, R8										;wczytanie iloœci wierszy do rejestru rax
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