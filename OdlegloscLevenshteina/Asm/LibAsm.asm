; Biblioteka DLL b�dzie wykonywa� cz�� algorytmu wykonywanego przy obliczaniu odleg�o�ci Levenshteina - przyjmowa� 
; trzy warto�ci z tablicy i sprawdza�, kt�ra opcja dodania odleg�o�ci edycyjnej jest minimalna

.data
.code					
algorithm proc				;funkcja algorithm obliczaj�ca odleg�o�� Levenshteina dla podanych dw�ch wyraz�w
	mov rax, 111			;przesuni�cie do rejestru rax warto�ci 123 co umo�liwi zwr�cenie jej w g��wnym programie w c++
	ret						;powr�t z funkcji
algorithm endp				;koniec funkcji	
end