// Айрапетова 306
#include"splineview.h"
#include <QApplication>

int main(int argc, char *argv[])
{
    QApplication a(argc, argv);
    SplineView spl;
    spl.setWindowTitle("Айрапетова Евгения 306");
    spl.show();
    return a.exec();
}
