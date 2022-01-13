from typing import Tuple
from OpenGL.GL import *
from OpenGL.GLU import *
from OpenGL.GLUT import *
from typing import NewType, Dict, Any, Tuple, List, Union, Set
import math
import sys


def math_func(a: float = 3.0, b: float = 2.0, eps: float = 0.1) -> Tuple[List[float], List[float], List[float]]:
    '''y^2 = x^3 / (a - x), 0<=x<=b; a,b > 0 - function parameters; eps - delta'''
    x_lst = []
    y_lst1 = []
    y_lst2 = []
    init_x = 0.0
    while init_x <= b:
        if init_x < a:
            x_lst.append(init_x)
        init_x += eps
    for x in x_lst:
        y = math.sqrt(x*x*x / (a-x))
        y_lst1.append(y)
        y_lst2.append(-y)
    return x_lst, y_lst1, y_lst2


def draw(MARGIN: float = 50.0, EPS: float = 1.0) -> None:
    '''draw own function by pair of points'''
    curr_w = glutGet(GLUT_WINDOW_WIDTH)
    curr_h = glutGet(GLUT_WINDOW_HEIGHT)
    margin_w = MARGIN / curr_w
    margin_h = MARGIN / curr_h
    x_lst, y_lst1, y_lst2 = math_func(a=A, b=B, eps=EPS)
    x_lst = [(i / curr_w) for i in x_lst if (((i / curr_w) > (-1.0 + margin_w)) and ((i / curr_w) < (1.0 - margin_w)))]
    y_lst1 = [(i / curr_h) for i in y_lst1 if (((i / curr_h) > (-1.0 + margin_h)) and ((i / curr_h) < (1.0 - margin_h)))]
    y_lst2 = [(i / curr_h) for i in y_lst2 if (((i / curr_h) > (-1.0 + margin_h)) and ((i / curr_h) < (1.0 - margin_h)))]

    glColor4f(0, 1, 0, 1)
    glLineWidth(4)
    glBegin(GL_LINE_STRIP)
    for x, y in zip(x_lst, y_lst1):
        glVertex2fv((x, y))
    glEnd()

    glBegin(GL_LINE_STRIP)
    for x, y in zip(x_lst, y_lst2):
        glVertex2fv((x, y))
    glEnd()

    glColor4f(255, 255, 255, 1)
    glLineWidth(1)
    glBegin(GL_LINE_STRIP)
    for x, y in zip([-1.0 + margin_w, 1.0 - margin_w], [0.0, 0.0]):
        glVertex2fv((x, y))
    glEnd()

    glBegin(GL_LINE_STRIP)
    for x, y in zip([0.0, 0.0], [-1.0 + margin_h, 1.0 - margin_h]):
        glVertex2fv((x, y))
    glEnd()


def display() -> None:
    '''display screen function'''
    MARGIN = 50.0
    EPS = 1.0
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)  # clear screen
    glClearColor(0.0, 0.0, 0.0, 1.0)  # rgba parametrs for screen
    glLoadIdentity()  # replace current matrix with the identity matrix
    draw(MARGIN=MARGIN, EPS=EPS)
    glutSwapBuffers()  # double buffering


def main(a: float = None, b: float = None) -> None:
    '''main program function'''
    global A, B
    A = a
    B = b
    W, H = 720, 480
    OUR_W, OUR_H = 1366, 768
    glutInit()  # init glut
    glutInitDisplayMode(GLUT_RGBA)  # set display mode to rgba
    glutInitWindowSize(W, H)  # set w,h for current window
    glutInitWindowPosition(int((OUR_W-W)/2), int((OUR_H-H)/2))  # set the window start position
    glutCreateWindow('CG TASK 1')  # set a window title
    glutDisplayFunc(display)  # set display callback for current window
    glutIdleFunc(display)  # set global idle callback
    glutMainLoop()  # main loop


if __name__ == '__main__':
    try:
        main(a=float(sys.argv[1]), b=float(sys.argv[2]))
    except Exception as e:
        print(str(e))
