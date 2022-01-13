#include "myopenglwidget.h"

MyOpenGLWidget::MyOpenGLWidget(QWidget* parent) : QOpenGLWidget{parent} {}

void MyOpenGLWidget::setParam(int param)
{
    if((GLfloat)param != c * 100)
    {
        c = (GLfloat)param / 100;
        emit paramChanged(param);
        update();
    }
}

void MyOpenGLWidget::setApro(int apro)
{
    if(p != apro)
    {
        p = apro;
        update();
    }
}

void MyOpenGLWidget::setxa1(int x)
{
    if(x != xa1)
    {
        xa1 = x;
        calcInit();
        update();
    }
}
void MyOpenGLWidget::setya1(int x)
{
    if(x != ya1)
    {
        ya1 = x;
        calcInit();
        update();
    }
}
void MyOpenGLWidget::setza1(int x)
{
    if(x != za1)
    {
        za1 = x;
        calcInit();
        update();
    }
}
void MyOpenGLWidget::setxa2(int x)
{
    if(x != xa2)
    {
        xa2 = x;
        calcInit();
        update();
    }
}
void MyOpenGLWidget::setya2(int x)
{
    if(x != ya2)
    {
        ya2 = x;
        calcInit();
        update();
    }
}
void MyOpenGLWidget::setza2(int x)
{
    if(x != za2)
    {
        za2 = x;
        calcInit();
        update();
    }
}
void MyOpenGLWidget::setxa3(int x)
{
    if(x != xa3)
    {
        xa3 = x;
        calcInit();
        update();
    }
}
void MyOpenGLWidget::setya3(int x)
{
    if(x != ya3)
    {
        ya3 = x;
        calcInit();
        update();
    }
}
void MyOpenGLWidget::setza3(int x)
{
    if (x != za3) {
        za3 = x;
        calcInit();
        update();
    }
}
void MyOpenGLWidget::setxa4(int x)
{
    if(x != xa4)
    {
        xa4 = x;
        calcInit();
        update();
    }
}
void MyOpenGLWidget::setya4(int x)
{
    if(x != ya4)
    {
        ya4 = x;
        calcInit();
        update();
    }
}
void MyOpenGLWidget::setza4(int x)
{
    if(x != za4)
    {
        za4 = x;
        calcInit();
        update();
    }
}
void MyOpenGLWidget::setxb1(int x)
{
    if(x != xb1)
    {
        xb1 = x;
        calcInit();
        update();
    }
}
void MyOpenGLWidget::setyb1(int x)
{
    if(x != yb1)
    {
        yb1 = x;
        calcInit();
        update();
    }
}
void MyOpenGLWidget::setzb1(int x)
{
    if(x != zb1)
    {
        zb1 = x;
        calcInit();
        update();
    }
}
void MyOpenGLWidget::setxb2(int x)
{
    if(x != xb2)
    {
        xb2 = x;
        calcInit();
        update();
    }
}
void MyOpenGLWidget::setyb2(int x)
{
    if(x != yb2)
    {
        yb2 = x;
        calcInit();
        update();
    }
}
void MyOpenGLWidget::setzb2(int x)
{
    if(x != zb2)
    {
        zb2 = x;
        calcInit();
        update();
    }
}
void MyOpenGLWidget::setxb3(int x)
{
    if(x != xb3)
    {
        xb3 = x;
        calcInit();
        update();
    }
}
void MyOpenGLWidget::setyb3(int x)
{
    if(x != yb3)
    {
        yb3 = x;
        calcInit();
        update();
    }
}
void MyOpenGLWidget::setzb3(int x)
{
    if(x != zb3)
    {
        zb3 = x;
        calcInit();
        update();
    }
}
void MyOpenGLWidget::setxb4(int x)
{
    if(x != xb4)
    {
        xb4 = x;
        calcInit();
        update();
    }
}
void MyOpenGLWidget::setyb4(int x)
{
    if(x != yb4)
    {
        yb4 = x;
        calcInit();
        update();
    }
}
void MyOpenGLWidget::setzb4(int x)
{
    if(x != zb4)
    {
        zb4 = x;
        calcInit();
        update();
    }
}

void MyOpenGLWidget::calcInit()
{
    my_point p1, p2, p3, p4;
    p1.x = xa1; p1.y = ya1; p1.z = za1;
    p2.x = xa2; p2.y = ya2; p2.z = za2;
    p3.x = xa3; p3.y = ya3; p3.z = za3;
    p4.x = xa4; p4.y = ya4; p4.z = za4;

    my_point po1, po2, po3, po4;
    po1.x = xb1; po1.y = yb1; po1.z = zb1;
    po2.x = xb2; po2.y = yb2; po2.z = zb2;
    po3.x = xb3; po3.y = yb3; po3.z = zb3;
    po4.x = xb4; po4.y = yb4; po4.z = zb4;

    QVector<my_point> pts1;
    pts1.push_back(p1);
    pts1.push_back(p2);
    pts1.push_back(p3);
    pts1.push_back(p4);

    QVector<my_point> pts2;
    pts2.push_back(po1);
    pts2.push_back(po2);
    pts2.push_back(po3);
    pts2.push_back(po4);

    spline spln1(pts1);
    spline spln2(pts2);
    spln1.calc();
    spln2.calc();

    spl1 = spln1;
    spl2 = spln2;
}

void MyOpenGLWidget::setXRot(int xRot)
{
    if(xRot != xRotation)
    {
        xRotation = xRot;
        emit xRotChanged(xRot);
        update();
    }
}

void MyOpenGLWidget::setYRot(int yRot)
{
    if(yRot != yRotation)
    {
        yRotation = yRot;
        emit yRotChanged(yRot);
        update();
    }
}

void MyOpenGLWidget::setZRot(int zRot)
{
    if(zRot != zRotation)
    {
        zRotation = zRot;
        emit zRotChanged(zRot);
        update();
    }
}

void MyOpenGLWidget::initializeGL()
{
    glClearColor(0, 0, 0, 1);
    glEnable(GL_DEPTH_TEST);
    glEnable(GL_CULL_FACE);
    calcInit();
}

void MyOpenGLWidget::resizeGL(int w, int h)
{
    glViewport(0, 0, w, h);
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    GLfloat x = (GLfloat)w / h;
    if (x > 1) { glFrustum(-x, x, -1.0, 1.0, 4.0, 15.0); }
    else { glFrustum(-1, 1, -1 / x, 1 / x, 4.0, 15.0); }
    glMatrixMode(GL_MODELVIEW);
}

void MyOpenGLWidget::drawSurface(spline &s1, spline &s2)
{
    s1.draw();
    s2.draw();

    GLfloat x1,y1,z1,x2,y2,z2;
    glColor3f(0.0f, 0.0f, 1.0f);
    glBegin(GL_LINES);
    GLfloat step = (GLfloat)1 / p;
    for(int i =0; i < s1.segments.size(); ++i)
    {
        for (GLfloat t = 0.0; t < 1.0; t += step) {
            x1 = s1.get_f(s1.segments[i].x_pol[0], s1.segments[i].x_pol[1], s1.segments[i].x_pol[2], s1.segments[i].x_pol[3], t);
            y1 = s1.get_f(s1.segments[i].y_pol[0], s1.segments[i].y_pol[1], s1.segments[i].y_pol[2], s1.segments[i].y_pol[3], t);
            z1 = s1.get_f(s1.segments[i].z_pol[0], s1.segments[i].z_pol[1], s1.segments[i].z_pol[2], s1.segments[i].z_pol[3], t);
            glVertex3f(x1, y1, z1);

            x2 = s1.get_f(s2.segments[i].x_pol[0], s2.segments[i].x_pol[1], s2.segments[i].x_pol[2], s2.segments[i].x_pol[3], t);
            y2 = s1.get_f(s2.segments[i].y_pol[0], s2.segments[i].y_pol[1], s2.segments[i].y_pol[2], s2.segments[i].y_pol[3], t);
            z2 = s1.get_f(s2.segments[i].z_pol[0], s2.segments[i].z_pol[1], s2.segments[i].z_pol[2], s2.segments[i].z_pol[3], t);
            glVertex3f(x2, y2, z2);
        }
    }
    glEnd();
}

void MyOpenGLWidget::paintGL()
{
      glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
      glLoadIdentity();
      glTranslatef(0.0, 0.0, -10.0);
      glRotatef(xRotation, 1.0, 0.0, 0.0);
      glRotatef(yRotation, 0.0, 1.0, 0.0);
      glRotatef(zRotation, 0.0, 0.0, 1.0);
      glScalef(c,c,c);
      drawSurface(spl1, spl2);
}
