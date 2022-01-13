#include <QOpenGLFunctions>
#include <QtGui>
#include <QVector>
#include <QPointF>
#include "OGLPyramid.h"

// ----------------------------------------------------------------------
MyPyramid::MyPyramid(QWidget* pwgt/*= 0*/) : QOpenGLWidget(pwgt)
                                             , m_xRotate(0)
                                             , m_yRotate(0)
{
}

// ----------------------------------------------------------------------
/*virtual*/void MyPyramid::initializeGL()
{
    QOpenGLFunctions* pFunc = 
        QOpenGLContext::currentContext()->functions();
    pFunc->glClearColor(0.0f, 0.0f, 0.0f, 1.0f);

    pFunc->glEnable(GL_DEPTH_TEST);
    glShadeModel(GL_FLAT);
    m_nPyramid = createPyramid(1.2f);
}

// ----------------------------------------------------------------------
/*virtual*/void MyPyramid::resizeGL(int nWidth, int nHeight)
{
    glViewport(0, 0, (GLint)nWidth, (GLint)nHeight);
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    glFrustum(-1.0, 1.0, -1.0, 1.0, 1.0, 10.0);
}

// ----------------------------------------------------------------------
/*virtual*/void MyPyramid::paintGL()
{
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
    glTranslatef(0.0, 0.0, -3.0);

    glRotatef(m_xRotate, 1.0, 0.0, 0.0);
    glRotatef(m_yRotate, 0.0, 1.0, 0.0);

    glCallList(m_nPyramid);
}

// ----------------------------------------------------------------------
/*virtual*/void MyPyramid::mousePressEvent(QMouseEvent* pe)
{
    m_ptPosition = pe->pos();
}

// ----------------------------------------------------------------------
/*virtual*/void MyPyramid::mouseMoveEvent(QMouseEvent* pe)
{
    m_xRotate += 180 * (GLfloat)(pe->y() - m_ptPosition.y()) / height();
    m_yRotate += 180 * (GLfloat)(pe->x() - m_ptPosition.x()) / width();
    update();

    m_ptPosition = pe->pos();
}

// ----------------------------------------------------------------------
GLuint MyPyramid::createPyramid(GLfloat fSize/*=1.0f*/)
{
    int k = 8;
    QVector<QPointF> A(k);
    GLuint n = glGenLists(1);

    glNewList(n, GL_COMPILE);

    glBegin(GL_POLYGON);
        glColor4f(1.0f, 0.0f, 0.0f, 1.0f);
        for(int i = 0; i<k; ++i){
            float fAngle = 2 * 3.14 * i / k;
            A[i].setX(fSize*cos(fAngle));
            A[i].setY(fSize*sin(fAngle));
            glVertex3f(A[i].x(), A[i].y(), 0);
        }

    glEnd();
    glBegin(GL_QUADS);
        float r,g,b,a;
        r = 0.2;
        b = 0;
        g = 1;
        a = 1;

        for (int i = 0; i< k-1; ++i){
            glColor4f(r, g, b, a);
            glVertex3f(A[i].x(), A[i].y(), 0.0);
            glVertex3f(A[i].x()*0.6, A[i].y()*0.6, fSize);
            glVertex3f(A[i+1].x()*0.6, A[i+1].y()*0.6, fSize);
            glVertex3f(A[i+1].x(), A[i+1].y(), 0.0);

            r+=0.3;
            g-=0.2;
            b+=0.3;
            a-=0.1;
        }

        glColor4f(0.0f, 0.3f, 1.0f, 0.6f);
        glVertex3f(A[7].x(), A[7].y(), 0.0);
        glVertex3f(A[7].x()*0.6, A[7].y()*0.6, fSize);
        glVertex3f(A[0].x()*0.6, A[0].y()*0.6, fSize);
        glVertex3f(A[0].x(), A[0].y(), 0.0);

    glEnd();
    glBegin(GL_POLYGON);
        glColor4f(0.0f, 0.5f, 0.5f, 0.5f);
        for(int i = 0; i<k; ++i){
            glVertex3f(A[i].x()*0.6, A[i].y()*0.6, fSize);
        }
    glEnd();

    glEndList();

    return n;
}


// ----------------------------------------------------------------------
// ----------------------------------------------------------------------
// ----------------------------------------------------------------------
MyPyramidProjection::MyPyramidProjection(QWidget* pwgt/*= 0*/) : QOpenGLWidget(pwgt)
                                             , m_xRotate(0)
                                             , m_yRotate(0)
{
}

// ----------------------------------------------------------------------
/*virtual*/void MyPyramidProjection::initializeGL()
{
    QOpenGLFunctions* pFunc =
        QOpenGLContext::currentContext()->functions();
    pFunc->glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
}

// ----------------------------------------------------------------------
/*virtual*/void MyPyramidProjection::resizeGL(int nWidth, int nHeight)
{
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    glViewport(0, 0, (GLint)nWidth, (GLint)nHeight);
    glOrtho(0, 400, 200, 0, -1, 1);
}

// ----------------------------------------------------------------------
/*virtual*/void MyPyramidProjection::paintGL()
{
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

    draw1(0, 40);
}

// ----------------------------------------------------------------------
/*virtual*/void MyPyramidProjection::mousePressEvent(QMouseEvent* pe)
{
    m_ptPosition = pe->pos();
}

// ----------------------------------------------------------------------
/*virtual*/void MyPyramidProjection::mouseMoveEvent(QMouseEvent* pe)
{
    m_xRotate += 180 * (GLfloat)(pe->y() - m_ptPosition.y()) / height();
    m_yRotate += 180 * (GLfloat)(pe->x() - m_ptPosition.x()) / width();
    update();

    m_ptPosition = pe->pos();
}

void MyPyramidProjection::draw1(int xOffset, int yOffset) //offset - координаты, с которых начать отрисовку
{
    int n = 8;

    glPointSize(2);
    glBegin(GL_POLYGON);
        glColor3f(1, 1, 1);
        for (int i = 0; i < n; ++i) {
            float fAngle = 2 * 3.14 * i / n;
            int   x      = (int)(50 + cos(fAngle) * 40 + xOffset);
            int   y      = (int)(50 + sin(fAngle) * 40 + yOffset);
            glVertex2f(x, y);
        }
    glEnd();

    xOffset+=100;
    yOffset = 70;

    glBegin(GL_QUADS);
        glColor3f(1, 1, 1);

        glVertex2f(60+xOffset, yOffset*2);
        glVertex2f(xOffset+60*1.6, yOffset);
        glVertex2f(xOffset+60*1.6 +xOffset, yOffset);
        glVertex2f(2*xOffset+60*1.6 +30*1.6, yOffset*2);

    glEnd();


}

