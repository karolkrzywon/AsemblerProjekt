#pragma once

#include <QtWidgets/QMainWindow>
#include <QFileDialog>
#include "ui_OdlegloscLevenshteina.h"
#include <Windows.h>
#include <iostream>
#include <queue> 
#include<fstream>
#include<thread>

using namespace std;

class indata
{
public:
    string s1;
    string s2;
    int position;
    indata::indata(string _s1, string _s2, int _position)
    {
        s1 = _s1;
        s2 = _s2;
        position = _position;
    }
    indata::indata()
    {
        s1 = "";
        s2 = "";
        position = 0;
    }
};

class OdlegloscLevenshteina : public QMainWindow
{
    Q_OBJECT

public:
    OdlegloscLevenshteina(QWidget *parent = Q_NULLPTR);
    void StartCounter();
    double GetCounter();
    void loadfromfile(); 
    void writetofile(int *distance_tab,int size_of_tab);

private:
    Ui::OdlegloscLevenshteinaClass ui;
    QString wejscienazwa;
    QString wyjscienazwa;

private slots:
        void exit();
        void run();
        void wejscie();
        void wyjscie();
};

void threadfunction(int *distance_tab, HMODULE hModule);