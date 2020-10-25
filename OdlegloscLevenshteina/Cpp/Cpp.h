#pragma once
#include <string>

#ifdef CPPLIB_EXPORTS
#define CPPLIB_API __declspec(dllexport)
#else
#define CPPLIB_API __declspec(dllimport)
#endif


extern "C" CPPLIB_API int algorithm(std::string s1, std::string s2, int rows, int columns);

int minimum(int x, int y, int z);