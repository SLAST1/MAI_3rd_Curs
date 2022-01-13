#pragma once
#include <QOpenGLWidget>
#include <QtWidgets>
#include <QtOpenGL>
#include <QtMath>


struct segment
{
    QVector<GLfloat> x_pol;
    QVector<GLfloat> y_pol;
    QVector<GLfloat> z_pol;

};

struct my_point
{
    GLfloat x;
    GLfloat y;
    GLfloat z;
};

class spline
{
public:
    spline();
    spline(QVector<my_point>& pnts);
    GLfloat get_f(GLfloat a, GLfloat b, GLfloat c, GLfloat d, GLfloat t);
    void  pre_calc();
    void  calc();
    void  post_calc();
    void calc_pol(QVector<GLfloat>& f_p, QVector<GLfloat>& s_p);
    void calc_last_pol(QVector<GLfloat>& pol, float pl, float pr);
    void draw();
    QVector<segment> segments;

private:
    QVector<my_point> points;
    int k = 1;
};
