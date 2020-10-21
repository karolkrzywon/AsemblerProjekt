#pragma once

#include <QtWidgets/QMainWindow>
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
};
