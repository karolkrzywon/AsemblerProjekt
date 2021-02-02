
#include "pch.h" 
#include <utility>
#include <limits.h>
#include "Cpp.h"

int algorithm(int ** inputArray,unsigned char* inputWord, int rows, int columns)
{
    int cost;

    for (int i = 0; i < rows; i++)//wype³nienie pierwszego wiersza i pierwszej kolumny 
        inputArray[i][0] = i;
    for (int j = 1; j < columns; j++)
        inputArray[0][j] = j;

    for (int i = 1; i < rows; i++)
        for (int j = 1; j < columns; j++)
        {
            if (inputWord[i-1] == inputWord[j-1+rows-1])
                cost = 0;
            else
                cost = 1;

            inputArray[i][j] = minimum(inputArray[i - 1][j] + 1, inputArray[i][j - 1] + 1, inputArray[i - 1][j - 1] + cost);
        }

    return inputArray[rows-1][columns-1];
}

int minimum(int x, int y, int z)
{
    return min(x, (min(y, z)));
}