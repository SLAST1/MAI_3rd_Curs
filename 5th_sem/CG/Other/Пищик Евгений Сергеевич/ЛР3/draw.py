from os import pipe
from typing import Tuple
from OpenGL.GL import *
from OpenGL.GLU import *
from OpenGL.GLUT import *
from typing import NewType, Dict, Any, Tuple, List, Union, Set
import sys
import numpy as np


class Point():
    def __init__(self, x: float, y: float, z: float) -> None:
        self.x = x
        self.y = y
        self.z = z

    def get_x(self) -> float:
        return self.x

    def get_y(self) -> float:
        return self.y

    def get_z(self) -> float:
        return self.z


def xflip(angle: float, point: Point) -> Point:
    mx = np.matrix([[1.0, 0.0, 0.0], [0.0, np.cos(np.pi * angle / 180.0), -np.sin(np.pi * angle / 180.0)], [0.0, np.sin(np.pi * angle / 180.0), np.cos(np.pi * angle / 180.0)]])
    inp = np.matrix([point.get_x(), point.get_y(), point.get_z()]).T
    resp = mx @ inp
    return Point(float(resp[0]), float(resp[1]), float(resp[2]))


def yflip(angle: float, point: Point) -> Point:
    my = np.matrix([[np.cos(np.pi * angle / 180.0), 0.0, np.sin(np.pi * angle / 180.0)], [0.0, 1.0, 0.0], [-np.sin(np.pi * angle / 180.0), 0.0, np.cos(np.pi * angle / 180.0)]])
    inp = np.matrix([point.get_x(), point.get_y(), point.get_z()]).T
    resp = my @ inp
    return Point(float(resp[0]), float(resp[1]), float(resp[2]))


def zflip(angle: float, point: Point) -> Point:
    mz = np.matrix([[np.cos(np.pi * angle / 180.0), -np.sin(np.pi * angle / 180.0), 0.0], [np.sin(np.pi * angle / 180.0), np.cos(np.pi * angle / 180.0), 0.0], [0.0, 0.0, 1.0]])
    inp = np.matrix([point.get_x(), point.get_y(), point.get_z()]).T
    resp = mz @ inp
    return Point(float(resp[0]), float(resp[1]), float(resp[2]))


def figure() -> List[List[Any]]:
    points3d = [[], []]
    r = R
    height = L
    approx = N
    ang = 30
    angles = np.linspace(0.0, 2 * np.pi, approx)
    for angle in angles:
        points3d[0].append(Point(r * np.cos(angle), r * np.sin(angle), np.tan(ang * np.pi / 180) * np.sin(r * np.cos(angle))))
        points3d[1].append(Point(r * np.cos(angle), r * np.sin(angle), height))

    if PJ == 'x':
        points3d[0] = [Point(0.0, p.get_y(), p.get_z()) for p in points3d[0]]
        points3d[1] = [Point(0.0, p.get_y(), p.get_z()) for p in points3d[1]]
    elif PJ == 'y':
        points3d[0] = [Point(p.get_x(), 0.0, p.get_z()) for p in points3d[0]]
        points3d[1] = [Point(p.get_x(), 0.0, p.get_z()) for p in points3d[1]]
    elif PJ == 'z':
        points3d[0] = [Point(p.get_x(), p.get_y(), 0.0) for p in points3d[0]]
        points3d[1] = [Point(p.get_x(), p.get_y(), 0.0) for p in points3d[1]]

    points3d[0] = [Point(XS * p.get_x(), YS * p.get_y(), ZS * p.get_z()) for p in points3d[0]]
    points3d[1] = [Point(XS * p.get_x(), YS * p.get_y(), ZS * p.get_z()) for p in points3d[1]]

    points3d[0] = [zflip(ZA, yflip(YA, xflip(XA, pi))) for pi in points3d[0]]
    points3d[1] = [zflip(ZA, yflip(YA, xflip(XA, pi))) for pi in points3d[1]]

    px = 0.0
    py = 0.0
    pz = 0.0

    for p1, p2 in zip(points3d[0], points3d[1]):
        px += p1.get_x() + p2.get_x()
        py += p1.get_y() + p2.get_y()
        pz += p1.get_z() + p2.get_z()

    px /= (len(points3d[0]) + len(points3d[1]))
    py /= (len(points3d[0]) + len(points3d[1]))
    pz /= (len(points3d[0]) + len(points3d[1]))

    points3d[0] = [Point(p.get_x() - px, p.get_y() - py, p.get_z() - pz) for p in points3d[0]]
    points3d[1] = [Point(p.get_x() - px, p.get_y() - py, p.get_z() - pz) for p in points3d[1]]

    return points3d


def draw() -> None:
    points3d = figure()
    glColor4f(0, 1, 0, 1)
    glLineWidth(1)
    pbot, ptop = points3d[0], points3d[1]

    resdist = []
    for i in range(len(pbot) - 1):
        meanx = (pbot[i].get_x() + pbot[i + 1].get_x() + ptop[i].get_x() + ptop[i + 1].get_x()) / 4.0
        meany = (pbot[i].get_y() + pbot[i + 1].get_y() + ptop[i].get_y() + ptop[i + 1].get_y()) / 4.0
        meanz = (pbot[i].get_z() + pbot[i + 1].get_z() + ptop[i].get_z() + ptop[i + 1].get_z()) / 4.0
        resdist.append(((meanx - 1.0)**2 + (meany - 1.0)**2 + (meanz - 1.0)**2)**0.5)

    meanx = (pbot[-1].get_x() + pbot[0].get_x() + ptop[-1].get_x() + ptop[0].get_x()) / 4.0
    meany = (pbot[-1].get_y() + pbot[0].get_y() + ptop[-1].get_y() + ptop[0].get_y()) / 4.0
    meanz = (pbot[-1].get_z() + pbot[0].get_z() + ptop[-1].get_z() + ptop[0].get_z()) / 4.0
    resdist.append(((meanx - 10.0)**2 + (meany - 10.0)**2 + (meanz - 10.0)**2)**0.5)

    colors = np.linspace(0.0, 1.0, N)
    inds = np.argsort(resdist)

    color_ind = [(color, ind) for color, ind in zip(colors, inds)]

    for cind in color_ind:
        i = cind[1]
        glClearColor(0.0, 0.0, 0.0, 1.0)
        glColor4f(0, cind[0], 0, 1)

        glBegin(GL_POLYGON)
        glVertex3fv((pbot[i].get_x(), pbot[i].get_y(), pbot[i].get_z()))
        glVertex3fv((ptop[i].get_x(), ptop[i].get_y(), ptop[i].get_z()))
        glVertex3fv((ptop[i].get_x(), ptop[i].get_y(), ptop[i].get_z()))
        if i != N - 1:
            glVertex3fv((ptop[i + 1].get_x(), ptop[i + 1].get_y(), ptop[i + 1].get_z()))
            glVertex3fv((ptop[i + 1].get_x(), ptop[i + 1].get_y(), ptop[i + 1].get_z()))
            glVertex3fv((pbot[i + 1].get_x(), pbot[i + 1].get_y(), pbot[i + 1].get_z()))
            glVertex3fv((pbot[i + 1].get_x(), pbot[i + 1].get_y(), pbot[i + 1].get_z()))
        else:
            glVertex3fv((ptop[0].get_x(), ptop[0].get_y(), ptop[0].get_z()))
            glVertex3fv((ptop[0].get_x(), ptop[0].get_y(), ptop[0].get_z()))
            glVertex3fv((pbot[0].get_x(), pbot[0].get_y(), pbot[0].get_z()))
            glVertex3fv((pbot[0].get_x(), pbot[0].get_y(), pbot[0].get_z()))
        glVertex3fv((pbot[i].get_x(), pbot[i].get_y(), pbot[i].get_z()))
        glEnd()


def display() -> None:
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)
    glClearColor(0.0, 0.0, 0.0, 1.0)
    glLoadIdentity()
    draw()
    glutSwapBuffers()


def main(h, n, r, pj, xs, ys, zs, xa, ya, za) -> None:
    global L, N, R, PJ, XS, YS, ZS, XA, YA, ZA
    L, N, R, PJ, XS, YS, ZS, XA, YA, ZA = h, n, r, pj, xs, ys, zs, xa, ya, za
    W, H = 720, 480
    OUR_W, OUR_H = 1366, 768
    glutInit()
    glutInitDisplayMode(GLUT_RGBA)
    glutInitWindowSize(W, H)
    glutInitWindowPosition(int((OUR_W - W) / 2), int((OUR_H - H) / 2))
    glutCreateWindow('CG TASK 3')
    glutDisplayFunc(display)
    glutIdleFunc(display)
    glutMainLoop()


if __name__ == '__main__':
    try:
        if float(sys.argv[1]) < 0.0:
            raise ValueError("h can't be < 0")
        if int(sys.argv[2]) < 1:
            raise ValueError("n can't be < 1")
        if float(sys.argv[3]) < 0.0:
            raise ValueError("r can't be < 0")
        if float(sys.argv[5]) < 0.0 or float(sys.argv[5]) > 1.0:
            raise ValueError("xs must be >= 0 and <= 1")
        if float(sys.argv[6]) < 0.0 or float(sys.argv[6]) > 1.0:
            raise ValueError("ys must be >= 0 and <= 1")
        if float(sys.argv[7]) < 0.0 or float(sys.argv[7]) > 1.0:
            raise ValueError("zs must be >= 0 and <= 1")
        if float(sys.argv[8]) < -90.0 or float(sys.argv[8]) > 90.0:
            raise ValueError("xa must be >= -90 and <= 90")
        if float(sys.argv[9]) < -90.0 or float(sys.argv[9]) > 90.0:
            raise ValueError("ya must be >= -90 and <= 90")
        if float(sys.argv[10]) < -90.0 or float(sys.argv[10]) > 90.0:
            raise ValueError("zs must be >= -90 and <= 90")
        main(h=float(sys.argv[1]), n=int(sys.argv[2]), r=float(sys.argv[3]), pj=str(sys.argv[4]), xs=float(sys.argv[5]), ys=float(sys.argv[6]), \
                zs=float(sys.argv[7]), xa=float(sys.argv[8]), ya=float(sys.argv[9]), za=float(sys.argv[10]))
    except Exception as e:
        print(str(e))
