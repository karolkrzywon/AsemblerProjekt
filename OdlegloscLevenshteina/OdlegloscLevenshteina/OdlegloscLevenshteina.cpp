#include "OdlegloscLevenshteina.h"

typedef int(__cdecl* algo)(string s1, string s2, int rows, int columns);
double PCFreq = 0.0;
__int64 CounterStart = 0;

OdlegloscLevenshteina::OdlegloscLevenshteina(QWidget *parent)
    : QMainWindow(parent)
{
    ui.setupUi(this);
}

void OdlegloscLevenshteina::exit()
{
    QApplication::exit();
}

void OdlegloscLevenshteina::run()
{
    HMODULE hModule;
    string s1;
    string s2;
    int rows;
    int columns;
    // watki

    if (ui.asm_radioButton->isChecked())
    {
        hModule = LoadLibrary(TEXT("C:\\Users\\Karol\\source\\repos\\AsemblerProjekt\\OdlegloscLevenshteina\\x64\\Debug\\Asm.dll"));
    }
    else if (ui.c_radioButton->isChecked())
    {
        hModule = LoadLibrary(TEXT("C:\\Users\\Karol\\source\\repos\\AsemblerProjekt\\OdlegloscLevenshteina\\x64\\Debug\\Cpp.dll"));
    }

    
    s1 = ui.slowo1_lineEdit->text().toStdString();
    s2 = ui.slowo2_lineEdit->text().toStdString();
    rows = s1.length()+1;
    columns = s2.length()+1;

    

    if (hModule == NULL)
    {
        // nie udalo siewczytac jakis dialog
    }
    else
    {
        algo algorithm = (algo)GetProcAddress(hModule, "algorithm");
        StartCounter();
        ui.odlegloscwynik_label->setText(QString::number(algorithm(s1, s2, rows, columns)));
        ui.czaswynik_label->setText(QString::number(GetCounter())+" ms");

            FreeLibrary(hModule);
    }
}

void OdlegloscLevenshteina::wejscie()
{
    wejscienazwa = QFileDialog::getOpenFileName(this, tr("Open file"), "C://", "Plik tekstowy (*.txt)");

    if (wejscienazwa != NULL)
    {
        ui.sciezkawe_lineEdit->setText(wejscienazwa);
    }
}

void OdlegloscLevenshteina::wyjscie()
{
    wyjscienazwa = QFileDialog::getSaveFileName(this, tr("Save file"), "C://", "Plik tekstowy (*.txt)");

   if (wyjscienazwa != NULL)
   {
       ui.sciezkawy_lineEdit->setText(wyjscienazwa);
   }
}

void StartCounter()
{
    LARGE_INTEGER li;
    if (!QueryPerformanceFrequency(&li))
        cout << "QueryPerformanceFrequency failed!";

    PCFreq = double(li.QuadPart) / 1000.0;

    QueryPerformanceCounter(&li);
    CounterStart = li.QuadPart;
}
double GetCounter()
{
    LARGE_INTEGER li;
    QueryPerformanceCounter(&li);
    return double(li.QuadPart - CounterStart) / PCFreq;
}


