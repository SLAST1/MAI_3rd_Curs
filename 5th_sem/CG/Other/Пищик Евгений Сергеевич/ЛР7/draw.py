from typing import Tuple
from OpenGL.GL import *
from OpenGL.GLU import *
from OpenGL.GLUT import *
import sys


def polyfunc(parr=None, eps=0.1):
    x_curr = 0
    x_lst = []
    y_lst = []
    while x_curr < W / 2:
        lagr = 0
        for i in range(len(parr)):
            y = parr[i][1]
            mul = 1.0
            for j in range(len(parr)):
                if i != j:
                    mul *= (x_curr - parr[j][0]) / (parr[i][0] - parr[j][0])
            lagr += y * mul
        x_lst.append(x_curr)
        y_lst.append(lagr)
        x_curr += eps
    return x_lst, y_lst


def draw(MARGIN=50.0, EPS=1.0):
    parr = [(X1, Y1), (X2, Y2), (X3, Y3), (X4, Y4), (X5, Y5), (X6, Y6)]
    curr_w = glutGet(GLUT_WINDOW_WIDTH)
    curr_h = glutGet(GLUT_WINDOW_HEIGHT)
    margin_w = MARGIN / curr_w
    margin_h = MARGIN / curr_h
    x_lst, y_lst = polyfunc(parr=parr, eps=EPS)
    x_lst = [(i / curr_w) for i in x_lst if (((i / curr_w) > (-1.0 + margin_w)) and ((i / curr_w) < (1.0 - margin_w)))]
    y_lst = [(i / curr_h) for i in y_lst if (((i / curr_h) > (-1.0 + margin_h)) and ((i / curr_h) < (1.0 - margin_h)))]

    glColor4f(0, 1, 0, 1)
    glLineWidth(4)
    glBegin(GL_LINE_STRIP)
    for x, y in zip(x_lst, y_lst):
        glVertex2fv((x, y))
    glEnd()

    glColor4f(255, 255, 255, 1)
    glLineWidth(1)
    glBegin(GL_LINE_STRIP)
    for x, y in zip([-1 * W / 2 + margin_w, W / 2 - margin_w], [0.0, 0.0]):
        glVertex2fv((x, y))
    glEnd()

    glBegin(GL_LINE_STRIP)
    for x, y in zip([0.0, 0.0], [-1 * H / 2 + margin_h, H / 2 - margin_h]):
        glVertex2fv((x, y))
    glEnd()


def display():
    MARGIN = 50.0
    EPS = 5.0
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)
    glClearColor(0.0, 0.0, 0.0, 1.0)
    glLoadIdentity()
    draw(MARGIN=MARGIN, EPS=EPS)
    glutSwapBuffers()


def main(x1, x2, x3, x4, x5, x6, y1, y2, y3, y4, y5, y6):
    global X1, X2, X3, X4, X5, X6, Y1, Y2, Y3, Y4, Y5, Y6, W, H
    X1, X2, X3, X4, X5, X6, Y1, Y2, Y3, Y4, Y5, Y6 = x1, x2, x3, x4, x5, x6, y1, y2, y3, y4, y5, y6
    W, H = 720, 480
    OUR_W, OUR_H = 1366, 768
    glutInit()
    glutInitDisplayMode(GLUT_RGBA)
    glutInitWindowSize(W, H)
    glutInitWindowPosition(int((OUR_W - W) / 2), int((OUR_H - H) / 2))
    glutCreateWindow('CG TASK 7')
    glutDisplayFunc(display)
    glutIdleFunc(display)
    glutMainLoop()


if __name__ == '__main__':
    try:
        x1, y1, x2, y2, x3, y3, x4, y4, x5, y5, x6, y6 = float(sys.argv[1]), float(sys.argv[2]), float(sys.argv[3]), float(sys.argv[4]), float(sys.argv[5]), float(sys.argv[6]), float(sys.argv[7]), float(sys.argv[8]), float(sys.argv[9]), float(sys.argv[10]), float(sys.argv[11]), float(sys.argv[12])
        main(x1, x2, x3, x4, x5, x6, y1, y2, y3, y4, y5, y6)
    except Exception as e:
        print(str(e))
