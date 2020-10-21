#include<Windows.h>
#include"pch.h"

#ifdef _cplusplus
extern "C" {
#endif

	_declspec(dllexport) int _cdecl Addition(int x, int y)
	{
		int z;
		z = x + y;
		return z;
	}

#ifdef _cplusplus
}
#endif