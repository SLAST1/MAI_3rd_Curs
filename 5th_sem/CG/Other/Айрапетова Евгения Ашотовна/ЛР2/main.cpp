//Айрапетова
#include <QApplication>
#include "OGLPyramid.h"

int main(int argc, char** argv)
{
    QApplication app(argc, argv);
    MyPyramid   MyPyramid;

    MyPyramid.resize(200, 200);
    MyPyramid.setWindowTitle("Изометрическая проекция");
    MyPyramid.show();

    MyPyramidProjection  Projection;
    Projection.setWindowTitle("Ортографические проекции");
    Projection.resize(400, 200);
    Projection.show();
    return app.exec();
}
