#include "glwidget.h"

#include <QApplication>
#include <viewwidget.h>
int main(int argc, char *argv[])
{
    QApplication a(argc, argv);
    ViewWidget* view = new ViewWidget;
    view->setWindowTitle("Айрапетова Евегния 306");
    view->show();
    return a.exec();
}
