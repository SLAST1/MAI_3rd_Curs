#pragma once
#include <QOpenGLWidget>
#include <QGLWidget>
#include <QtWidgets>
#include <QtOpenGL>
#include <QOpenGLFunctions>
#include <QtMath>
#include "spline.h"


class MyOpenGLWidget : public QOpenGLWidget
{
    Q_OBJECT
public:
    MyOpenGLWidget(QWidget *parent = nullptr);

public slots:
    void setXRot(int xRot);
    void setYRot(int yRot);
    void setZRot(int zRot);
    void setParam(int param);
    void setApro(int apro);
    void setxa1(int x);
    void setya1(int x);
    void setza1(int x);
    void setxa2(int x);
    void setya2(int x);
    void setza2(int x);
    void setxa3(int x);
    void setya3(int x);
    void setza3(int x);
    void setxa4(int x);
    void setya4(int x);
    void setza4(int x);

    void setxb1(int x);
    void setyb1(int x);
    void setzb1(int x);
    void setxb2(int x);
    void setyb2(int x);
    void setzb2(int x);
    void setxb3(int x);
    void setyb3(int x);
    void setzb3(int x);
    void setxb4(int x);
    void setyb4(int x);
    void setzb4(int x);

signals:
    void xRotChanged(int xRot);
    void yRotChanged(int yRot);
    void zRotChanged(int zRot);
    void paramChanged(int param);

protected:
    void calcInit();
    virtual void initializeGL();
    virtual void resizeGL(int w, int h);
    void drawSurface(spline& s1, spline& s2);
    virtual void paintGL();

private:   
    GLfloat c = 0.3;
    int xRotation = 30;
    int yRotation = 30;
    int zRotation = 30;
    int p = 10;
    spline spl1;
    spline spl2;
    GLfloat xa1=-10, xa2=2, xa3=4, xa4=14, xb1=-4, xb2=-3, xb3=5, xb4=6;
    GLfloat ya1=2, ya2=-1, ya3=9, ya4=0, yb1=2, yb2=-2, yb3=-1, yb4=3;
    GLfloat za1=0, za2=-4, za3=-6, za4=2, zb1=1, zb2=3, zb3=7, zb4=-2;
};
