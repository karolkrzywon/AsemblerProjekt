#include "OdlegloscLevenshteina.h"
#include <QtWidgets/QApplication>

typedef bool(__cdecl* pInit)();

int main(int argc, char *argv[])
{
    QApplication a(argc, argv);
    OdlegloscLevenshteina w;
    w.show();
   
    HMODULE hModule;
   // hModule = LoadLibrary(TEXT("C:\\Users\\Karol\\source\\repos\\AsemblerProjekt\\OdlegloscLevenshteina\\x64\\Debug\\Cpp.dll"));
    hModule = LoadLibrary(TEXT("C:\\Users\\Karol\\source\\repos\\AsemblerProjekt\\OdlegloscLevenshteina\\x64\\Debug\\Asm.dll"));
    if (NULL == hModule)
    {
        cout << "no nie wyszlo";
    }
    cout << "git";
    pInit init = (pInit)GetProcAddress(hModule, "init");
    if (NULL == init)
    {
        cout << "no nie wyszlo";
    }
    cout << "git" << endl;

    cout << init();

    FreeLibrary(hModule);
   
    //system("PAUSE");
    return a.exec();
}
