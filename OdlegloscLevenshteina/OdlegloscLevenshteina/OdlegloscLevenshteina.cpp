#include "OdlegloscLevenshteina.h"

typedef int(__cdecl* algo)(int** inputArray, unsigned char* inputWord, int rows, int columns);
double PCFreq = 0.0;
__int64 CounterStart = 0;
vector<string> wektor;

void OdlegloscLevenshteina::loadfromfile()
{

    ifstream infile;
    infile.open(wejscienazwa.toStdString());
    if (infile)
    {
        string s;
        string s1;
        string s2;
        int i = 0;
        bool sw = 0;

        while (getline(infile, s))
        {
            for (char c : s)
            {
                if (c == ' ')
                {
                    sw = 1;
                }
                else
                {
                    if (sw)
                        s2 = s2 + c;
                    else
                        s1 = s1 + c;                  
                }
            }
            wektor.push_back(s1);
            wektor.push_back(s2);
            s1.clear();
            s2.clear();
            sw = 0;
        }
    }
    else
    {
    }
    infile.close();
}

void OdlegloscLevenshteina::writetofile(int *distance_tab,int size_of_tab)
{
    ofstream outfile;
    outfile.open(wyjscienazwa.toStdString());
    if (outfile)
    {
        for (int i = 0; i < size_of_tab; i++)
        {
            outfile << distance_tab[i] << endl;
        }
    }
    else
    {
    }
    outfile.close();
}

void threadfunc(int *distance_tab, HMODULE hModule, vector<string> buf, algo algorithm)
{
    string s1;
    string s2;
    int rows;
    int columns;
    int pos;
    
    for (int i = 0; i < buf.size(); i += 2)
    {
        s1 = buf[i];
        s2 = buf[i + 1];
        rows = s1.length() + 1;
        columns = s2.length() + 1;
        pos = i / 2;

        int** a = new int* [rows];//utworzenie tablicy dynamicznej
        for (int i = 0; i < rows; ++i)
            a[i] = new int[columns];

        unsigned char* b = new unsigned char[rows + columns - 2];
        for (int i = 0; i < rows - 1; i++)
            b[i] = s1[i];
        for (int i = 0; i < columns - 1; i++)
            b[i + rows - 1] = s2[i];

        distance_tab[pos] = algorithm(a, b, rows, columns);


        for (int i = 0; i < rows; ++i)
            delete[] a[i];
        delete[] a;
        delete[] b;
    }
}

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

    if (ui.asm_radioButton->isChecked())
    {
        hModule = LoadLibrary(TEXT("C:\\Users\\Karol\\source\\repos\\AsemblerProjekt\\OdlegloscLevenshteina\\x64\\Debug\\Asm.dll"));
    }
    else if (ui.c_radioButton->isChecked())
    {
        hModule = LoadLibrary(TEXT("C:\\Users\\Karol\\source\\repos\\AsemblerProjekt\\OdlegloscLevenshteina\\x64\\Debug\\Cpp.dll"));
    }
    
    algo algorithm = (algo)GetProcAddress(hModule, "algorithm");
    s1 = ui.slowo1_lineEdit->text().toStdString();
    s2 = ui.slowo2_lineEdit->text().toStdString();
    int thread_amount = ui.watki_spinBox->value();
 
    if ((s1 != "") || (s2 != ""))
    {
        int rows = s1.length() + 1;
        int columns = s2.length() + 1;

        int** a = new int* [rows];//utworzenie tablicy dynamicznej
        for (int i = 0; i < rows; ++i)
            a[i] = new int[columns];

        

        unsigned char* b = new unsigned char[rows + columns - 2];
        for (int i = 0; i < rows - 1; i++)//wype³nienie pierwszego wiersza i pierwszej kolumny 
            b[i] = s1[i];
        for (int i = 0; i < columns - 1; i++)
            b[i+rows-1] = s2[i];
        

        StartCounter();
        ui.odlegloscwynik_label->setText(QString::number(algorithm(a, b, rows, columns)));

        for (int i = 0; i < rows; ++i)
            delete[] a[i];
        delete[] a;
        delete[] b;

        ui.czaswynik_label->setText(QString::number(GetCounter()) + " ms");
    }

    if ((ui.sciezkawe_lineEdit->text() != "")&&(ui.sciezkawy_lineEdit->text()!=""))
    {
        loadfromfile();
        int size_of_tab = wektor.size()/2;
        int* distance_tab;
        distance_tab = new int [size_of_tab];
        int line_amount = floor(size_of_tab / thread_amount);
        vector<std::thread> threads;
        vector<vector<string>> pieces;
        vector<string> buf;

        for (int i = 0; i < thread_amount-1; i++)
        {
            for (int j = 0; j < line_amount * 2; j++)
            {
                buf.push_back(wektor[2 * line_amount * i + j]);
            }
            pieces.push_back(buf);
            buf.clear();
        }
        for (int i = 2 * line_amount * (thread_amount-1); i < wektor.size(); i++)
        {
            buf.push_back(wektor[i]);
        }
        pieces.push_back(buf);



        StartCounter();
        for (int i = 0; i < thread_amount; i++)
        {
  
           threads.push_back(std::thread(threadfunc, std::ref(distance_tab), hModule, pieces[i], algorithm));
        }

        for (std::thread& th : threads)
        {
            if (th.joinable())
                th.join();
        }

        auto time = GetCounter();
        ui.czaswynik_label->setText(QString::number(time) + " ms");
        writetofile(distance_tab,size_of_tab);
        delete[] distance_tab;
        wektor.clear();
    }
    FreeLibrary(hModule);
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

void OdlegloscLevenshteina::StartCounter()
{
    LARGE_INTEGER li;
    if (!QueryPerformanceFrequency(&li))
        cout << "QueryPerformanceFrequency failed!";

    PCFreq = double(li.QuadPart) / 1000.0;

    QueryPerformanceCounter(&li);
    CounterStart = li.QuadPart;
}

double OdlegloscLevenshteina::GetCounter()
{
    LARGE_INTEGER li;
    QueryPerformanceCounter(&li);
    return double(li.QuadPart - CounterStart) / PCFreq;
}

