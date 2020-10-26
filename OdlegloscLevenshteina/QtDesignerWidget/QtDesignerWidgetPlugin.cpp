#include "QtDesignerWidget.h"
#include "QtDesignerWidgetPlugin.h"

#include <QtCore/QtPlugin>

QtDesignerWidgetPlugin::QtDesignerWidgetPlugin(QObject *parent)
    : QObject(parent)
{
    initialized = false;
}

void QtDesignerWidgetPlugin::initialize(QDesignerFormEditorInterface * /*core*/)
{
    if (initialized)
        return;

    initialized = true;
}

bool QtDesignerWidgetPlugin::isInitialized() const
{
    return initialized;
}

QWidget *QtDesignerWidgetPlugin::createWidget(QWidget *parent)
{
    return new QtDesignerWidget(parent);
}

QString QtDesignerWidgetPlugin::name() const
{
    return "QtDesignerWidget";
}

QString QtDesignerWidgetPlugin::group() const
{
    return "My Plugins";
}

QIcon QtDesignerWidgetPlugin::icon() const
{
    return QIcon();
}

QString QtDesignerWidgetPlugin::toolTip() const
{
    return QString();
}

QString QtDesignerWidgetPlugin::whatsThis() const
{
    return QString();
}

bool QtDesignerWidgetPlugin::isContainer() const
{
    return false;
}

QString QtDesignerWidgetPlugin::domXml() const
{
    return "<widget class=\"QtDesignerWidget\" name=\"QtDesignerWidget\">\n"
        " <property name=\"geometry\">\n"
        "  <rect>\n"
        "   <x>0</x>\n"
        "   <y>0</y>\n"
        "   <width>100</width>\n"
        "   <height>100</height>\n"
        "  </rect>\n"
        " </property>\n"
        "</widget>\n";
}

QString QtDesignerWidgetPlugin::includeFile() const
{
    return "QtDesignerWidget.h";
}
