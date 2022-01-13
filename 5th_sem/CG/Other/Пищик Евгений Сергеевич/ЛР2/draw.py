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


class Line():
    def __init__(self, p1: Point, p2: Point) -> None:
        self.p1 = p1
        self.p2 = p2

    def length(self) -> float:
        return ((self.p2.get_x() - self.p1.get_x())**2 + (self.p2.get_y() - self.p1.get_y())**2 + (self.p2.get_z() - self.p1.get_z())**2)**0.5

    def get_p1(self) -> Point:
        return self.p1

    def get_p2(self) -> Point:
        return self.p2


class Plane():
    def __init__(self, n, p) -> None:
        self.pl = []
        for i in range(n):
            self.pl.append(p[i])

    def __len__(self) -> int:
        return len(self.pl)

    def get_pi(self, i) -> Point:
        return self.pl[i]


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


def planeeq(pl: Plane) -> List[Any]:
    x1, y1, z1 = pl.get_pi(0).get_x(), pl.get_pi(0).get_y(), pl.get_pi(0).get_z()
    x2, y2, z2 = pl.get_pi(1).get_x(), pl.get_pi(1).get_y(), pl.get_pi(1).get_z()
    x3, y3, z3 = pl.get_pi(2).get_x(), pl.get_pi(2).get_y(), pl.get_pi(2).get_z()

    a1 = x2 - x1
    b1 = y2 - y1
    c1 = z2 - z1
    a2 = x3 - x1
    b2 = y3 - y1
    c2 = z3 - z1

    a = b1 * c2 - b2 * c1
    b = a2 * c1 - a1 * c2
    c = a1 * b2 - b1 * a2
    d = -a * x1 - b * y1 - c * z1

    return [a, b, c, d]


def figure() -> Tuple[List[Any], List[Any]]:
    points = []
    angle = 2 * np.pi / N
    for i in range(N):
        points.append(Point(R * np.sin(angle * i), R * np.cos(angle * i), 0.0))
    for i in range(N):
        points.append(Point(points[i].get_x(), points[i].get_y(), points[i].get_z() + L))

    if PJ == 'x':
        points = [Point(0.0, p.get_y(), p.get_z()) for p in points]
    elif PJ == 'y':
        points = [Point(p.get_x(), 0.0, p.get_z()) for p in points]
    elif PJ == 'z':
        points = [Point(p.get_x(), p.get_y(), 0.0) for p in points]

    points = [Point(XS * p.get_x(), YS * p.get_y(), ZS * p.get_z()) for p in points]

    points = [zflip(ZA, yflip(YA, xflip(XA, pi))) for pi in points]

    px = 0.0
    py = 0.0
    pz = 0.0

    for p in points:
        px += p.get_x()
        py += p.get_y()
        pz += p.get_z()

    px /= len(points)
    py /= len(points)
    pz /= len(points)

    points = [Point(p.get_x() - px, p.get_y() - py, p.get_z() - pz) for p in points]

    planes = []
    for i in range(N - 1):
        planes.append(Plane(4, [points[i], points[i + 1], points[i + N + 1], points[i + N]]))
    planes.append(Plane(4, [points[N - 1], points[0], points[N], points[2 * N - 1]]))
    planes.append(Plane(N, [points[i] for i in range(N)]))
    planes.append(Plane(N, [points[i] for i in range(N, 2 * N)]))

    view = [planeeq(planes[i])[2] < 0 for i in range(len(planes))]
    view[-2] = False

    lines = []
    for i in range(len(view)):
        if view[i]:
            for j in range(planes[i].__len__() - 1):
                lines.append(Line(planes[i].get_pi(j), planes[i].get_pi(j + 1)))
            lines.append(Line(planes[i].get_pi(planes[i].__len__() - 1), planes[i].get_pi(0)))

    return lines, points


def draw() -> None:
    lines, _ = figure()
    glColor4f(0, 1, 0, 1)
    glLineWidth(3)
    for line in lines:
        glBegin(GL_LINE_STRIP)
        points = [line.get_p1(), line.get_p2()]
        for p in points:
            glVertex3fv((p.get_x(), p.get_y(), p.get_z()))
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
    glutCreateWindow('CG TASK 2')
    glutDisplayFunc(display)
    glutIdleFunc(display)
    glutMainLoop()


if __name__ == '__main__':
    try:
        if float(sys.argv[1]) < 0.0:
            raise ValueError("h can't be < 0")
        if int(sys.argv[2]) < 3:
            raise ValueError("n can't be < 3")
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
