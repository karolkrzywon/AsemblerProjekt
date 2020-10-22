#include "OdlegloscLevenshteina.h"

typedef bool(__cdecl* check)();

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


    // watki


    if (ui.asm_radioButton->isChecked())
    {
        hModule = LoadLibrary(TEXT("C:\\Users\\Karol\\source\\repos\\AsemblerProjekt\\OdlegloscLevenshteina\\x64\\Debug\\Asm.dll"));
    }
    else if (ui.c_radioButton->isChecked())
    {
        hModule = LoadLibrary(TEXT("C:\\Users\\Karol\\source\\repos\\AsemblerProjekt\\OdlegloscLevenshteina\\x64\\Debug\\Cpp.dll"));
    }

    if (hModule == NULL)
    {
        // nie udalo siewczytac jakis dialog
    }
    else
    {
        check init = (check)GetProcAddress(hModule, "init");

        if (init == NULL)
        {
            // jakis blad z dll
        }
        else
        {
            init();
            FreeLibrary(hModule);
        }
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