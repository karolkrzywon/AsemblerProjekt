; Biblioteka DLL bêdzie wykonywaæ czêœæ algorytmu wykonywanego przy obliczaniu odleg³oœci Levenshteina - przyjmowaæ 
; trzy wartoœci z tablicy i sprawdzaæ, która opcja dodania odleg³oœci edycyjnej jest minimalna

.data
.code					
algorithm proc				;funkcja algorithm obliczaj¹ca odleg³oœæ Levenshteina dla podanych dwóch wyrazów
	mov rax, 111			;przesuniêcie do rejestru rax wartoœci 123 co umo¿liwi zwrócenie jej w g³ównym programie w c++
	ret						;powrót z funkcji
algorithm endp				;koniec funkcji	
end