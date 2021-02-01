
#include "pch.h" 
#include <utility>
#include <limits.h>
#include "Cpp.h"

int algorithm(int ** a,unsigned char* b, int rows, int columns)
{
    int cost;

    /*
    int** a = new int* [rows];//utworzenie tablicy dynamicznej
    for (int i = 0; i < rows; ++i)
        a[i] = new int[columns];

    for (int i = 0; i < rows; i++)//wype³nienie pierwszego wiersza i pierwszej kolumny 
        a[i][0] = i;
    for (int j = 1; j < columns; j++)
        a[0][j] = j;
*/

    for (int i = 1; i < rows; i++)
        for (int j = 1; j < columns; j++)
        {
            if (b[i-1] == b[j-1+rows-1])
                cost = 0;
            else
                cost = 1;

            a[i][j] = minimum(a[i - 1][j] + 1, a[i][j - 1] + 1, a[i - 1][j - 1] + cost);
        }

    return a[rows-1][columns-1];
}

int minimum(int x, int y, int z)
{
    return min(x, (min(y, z)));
}