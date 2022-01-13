#pragma once

#include <QOpenGLWidget>


class MyPyramid : public QOpenGLWidget {
private:
    GLuint  m_nPyramid;
    GLfloat m_xRotate;
    GLfloat m_yRotate;
    QPoint  m_ptPosition;

protected:
    virtual void   initializeGL   (                       );
    virtual void   resizeGL       (int nWidth, int nHeight);
    virtual void   paintGL        (                       );
    virtual void   mousePressEvent(QMouseEvent* pe        );
    virtual void   mouseMoveEvent (QMouseEvent* pe        );
            GLuint createPyramid  (GLfloat fSize = 1.0f   );

public:
    MyPyramid(QWidget* pwgt = 0);
};


class MyPyramidProjection : public QOpenGLWidget {
private:
    GLuint  m_nPyramid;
    GLfloat m_xRotate;
    GLfloat m_yRotate;
    QPoint  m_ptPosition;

protected:
    virtual void   initializeGL   (                       );
    virtual void   resizeGL       (int nWidth, int nHeight);
    virtual void   paintGL        (                       );
    virtual void   mousePressEvent(QMouseEvent* pe        );
    virtual void   mouseMoveEvent (QMouseEvent* pe        );

public:
    MyPyramidProjection(QWidget* pwgt = 0);
    void draw1(int xOffset, int yOffset);
};


