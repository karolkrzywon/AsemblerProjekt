#include "OdlegloscLevenshteina.h"
#include <QtWidgets/QApplication>

typedef bool(__cdecl* pInit)();

int main(int argc, char *argv[])
{
    QApplication a(argc, argv);
    OdlegloscLevenshteina w;
    w.show();

    return a.exec();
}
