#include "OdlegloscLevenshteina.h"
#include <QtWidgets/QApplication>


typedef int(_cdecl* FunAdd)(int a, int b);

int main(int argc, char *argv[])
{
  //  QApplication a(argc, argv);
    //OdlegloscLevenshteina w;
    //w.show();
    //return a.exec();
    HMODULE hModule;
    hModule = LoadLibrary(TEXT("C:\\Users\\Karol\\source\\repos\\AsemblerProjekt\\OdlegloscLevenshteina\\x64\\Debug\\C++.dll"));

    if (NULL == hModule)
    {
        cout << "no nie wyszlo";
    }
    cout << "git";
    FunAdd Additionfun = (FunAdd)GetProcAddress(hModule, "Addition:");
    if (NULL == Additionfun)
    {
        cout << "no nie wyszlo";
    }
    cout << "git" << endl;

    cout << Additionfun(10, 5);

    FreeLibrary(hModule);
   
   
    system("PAUSE");
    return 0;
}
