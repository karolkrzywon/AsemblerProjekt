#pragma once

#include <QtWidgets/QMainWindow>
#include <QFileDialog>
#include "ui_OdlegloscLevenshteina.h"
#include <Windows.h>
#include <iostream>

using namespace std;

class OdlegloscLevenshteina : public QMainWindow
{
    Q_OBJECT

public:
    OdlegloscLevenshteina(QWidget *parent = Q_NULLPTR);

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


void StartCounter();
double GetCounter();