#include "spline.h"
#include <QDebug>


spline::spline() {}

spline::spline(QVector<my_point>& pnts)
{
    points = pnts;
    segments.resize(points.size() - 1);
    for(int i = 0; i < segments.size(); ++i)
    {
        segments[i].x_pol.resize(4);
        segments[i].y_pol.resize(4);
        segments[i].z_pol.resize(4);
    }
}

GLfloat spline::get_f(GLfloat a, GLfloat b, GLfloat c, GLfloat d, GLfloat t) { return qPow(t, 3) * a + qPow(t, 2) * b + t * c + d; }

void spline::calc()
{
    pre_calc();
    for(int i = 0; i < (int)segments.size() - 1; ++i)
    {
        calc_pol(segments[i].x_pol, segments[i + 1].x_pol);
        calc_pol(segments[i].y_pol, segments[i + 1].y_pol);
        calc_pol(segments[i].z_pol, segments[i + 1].z_pol);
    }
    post_calc();
}

void spline::calc_pol(QVector<GLfloat>& f_p, QVector<GLfloat>& s_p)
{
    GLfloat m = s_p[3] - f_p[3] - f_p[2];
    GLfloat q = s_p[2] - f_p[2];
    f_p[0] = q - 2 * m;
    f_p[1] = 3 * m - q;
}

void spline::pre_calc()
{
    segments[0].x_pol[2] = k*(points[1].x-points[0].x)/2;
    segments[0].y_pol[2] = k*(points[1].y-points[0].y)/2;
    segments[0].z_pol[2] = k*(points[1].z-points[0].z)/2;

    for(int i = 1; i < (int)segments.size(); ++i)
    {
        segments[i].x_pol[2] = k * (points[i+1].x-points[i-1].x);
        segments[i].y_pol[2] = k * (points[i+1].y-points[i-1].y);
        segments[i].z_pol[2] = k * (points[i+1].z-points[i-1].z);
    }
    for(int i = 0; i < (int)segments.size();++i)
    {
        segments[i].x_pol[3] = points[i].x;
        segments[i].y_pol[3] = points[i].y;
        segments[i].z_pol[3] = points[i].z;
    }
}

void spline::post_calc()
{
    calc_last_pol(segments.back().x_pol, points.back().x, points[points.size()-2].x);
    calc_last_pol(segments.back().y_pol, points.back().y, points[points.size()-2].y);
    calc_last_pol(segments.back().z_pol, points.back().z, points[points.size()-2].z);
}

void spline::calc_last_pol(QVector<GLfloat>& pol, float pl, float pr)
{
    float t = k * (pl - pr) / 2;
    float m = t - pol[2];
    float q = pl - pol[2] - pol[3];
    pol[1] = 3 * q - m;
    pol[0] = m - 2 * q;

}

void spline::draw()
{
    glBegin(GL_LINE_STRIP);
    glColor3f(0.0f, 1.0f, 0.0f);
    GLfloat dx, dy, dz;
    for(int i = 0; i < (int)segments.size(); ++i)
    {
        glVertex3f(points[i].x, points[i].y, points[i].z);

        for(GLfloat t = 0.0; t < 1.0; t += 0.1)
        {
            dx = get_f(segments[i].x_pol[0], segments[i].x_pol[1], segments[i].x_pol[2], segments[i].x_pol[3], t);
            dy = get_f(segments[i].y_pol[0], segments[i].y_pol[1], segments[i].y_pol[2], segments[i].y_pol[3], t);
            dz = get_f(segments[i].z_pol[0], segments[i].z_pol[1], segments[i].z_pol[2], segments[i].z_pol[3], t);
            glColor3f(0.0f, 1.0f, 0.0f);
            glVertex3f(dx, dy, dz);
        }
        glVertex3f(points[i + 1].x, points[i + 1].y, points[i + 1].z);
    }
    glEnd();
}
