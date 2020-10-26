#pragma once

#include <QtWidgets/QWidget>
#include<qlineedit.h>
/*
class QtDesignerWidget : public QWidget
{
    Q_OBJECT

public:
    QtDesignerWidget(QWidget *parent = Q_NULLPTR);
};
*/
class LineEdit : public QLineEdit
{
public:
    using QLineEdit::QLineEdit;
protected:
    void mousePressEvent(QMouseEvent* event)
    {
        QLineEdit::mousePressEvent(event);
        setCursorPosition(0);
    }
};
