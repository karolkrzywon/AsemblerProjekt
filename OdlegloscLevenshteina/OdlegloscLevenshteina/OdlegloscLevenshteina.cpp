#include "OdlegloscLevenshteina.h"

typedef int(__cdecl* algo)(string s1, string s2, int rows, int columns);
double PCFreq = 0.0;
__int64 CounterStart = 0;
queue<indata>q;
mutex m;

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
            q.push(indata(s1, s2, i++));
            s1.clear();
            s2.clear();
            sw = 0;
        }
    }
    else
    {
        //komunikat o nieudanym wczytaniu pliku
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
        //komunikat o bledzie
    }
    outfile.close();
}

void threadfunction(int *distance_tab, HMODULE hModule)
{
    algo algorithm = (algo)GetProcAddress(hModule, "algorithm");
    indata buf;
    string s1;
    string s2;
    int rows;
    int columns;
    int pos;
 
    while (!q.empty())
    {
        m.lock();
        if (!q.empty())
        {
            buf = q.front();
            q.pop();
            m.unlock();

            s1 = buf.s1;
            s2 = buf.s2;
            rows = s1.length() + 1;
            int columns = s2.length() + 1;
            pos = buf.position;
            distance_tab[pos] = algorithm(s1, s2, rows, columns);
        }
        else
        {
            m.unlock();
        }
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
    

    s1 = ui.slowo1_lineEdit->text().toStdString();
    s2 = ui.slowo2_lineEdit->text().toStdString();
    int thread_amount = ui.watki_spinBox->value();
 
    if ((s1 != "") || (s2 != ""))
    {
        algo algorithm = (algo)GetProcAddress(hModule, "algorithm");
        int rows = s1.length() + 1;
        int columns = s2.length() + 1;
        StartCounter();
        ui.odlegloscwynik_label->setText(QString::number(algorithm(s1, s2, rows, columns)));
        ui.czaswynik_label->setText(QString::number(GetCounter()) + " ms");
    }

    if ((ui.sciezkawe_lineEdit->text() != "")&&(ui.sciezkawy_lineEdit->text()!=""))
    {
        loadfromfile();
        int size_of_tab = q.size();
        int* distance_tab;
        distance_tab = new int [size_of_tab];
        vector<std::thread> threads;
        
        StartCounter();
        for (int i = 0; i < thread_amount; i++)
        {
           threads.push_back(std::thread(threadfunction, std::ref(distance_tab), hModule));
        }

        for (std::thread& th : threads)
        {
            if (th.joinable())
                th.join();
        }

        ui.czaswynik_label->setText(QString::number(GetCounter()) + " ms");
        writetofile(distance_tab,size_of_tab);
        delete[] distance_tab;
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

