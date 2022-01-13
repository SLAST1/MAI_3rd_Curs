use std::ops;
use std::cmp::{max, min};

#[derive(Copy, Clone, Debug)]
pub struct Point {
    pub x: i32,
    pub y: i32,
}

impl Point {
    pub fn new(x: i32, y: i32) -> Self {
        Point { x, y }
    }

    pub fn from(pt: Point_f64) -> Self {
        Self {
            x: pt.x() as i32,
            y: pt.y() as i32
        }
    }

    pub fn x(&self) -> i32 {
        self.x
    }

    pub fn y(&self) -> i32 {
        self.y
    }
}

impl ops::Add for Point {
    type Output = Point;

    fn add(self, _rhs: Point) -> Self::Output {
        Self {
            x: self.x() + _rhs.x(),
            y: self.y() + _rhs.y(),
        }
    }
}

impl ops::Sub for Point {
    type Output = Point;

    fn sub(self, _rhs: Point) -> Self::Output {
        Self {
            x: self.x() - _rhs.x(),
            y: self.y() - _rhs.y(),
        }
    }
}

impl ops::Mul<i32> for Point {
    type Output = Point;

    fn mul(self, _rhs: i32) -> Self::Output {
        Self {
            x: self.x() * _rhs,
            y: self.y() * _rhs,
        }
    }
}

#[derive(Copy, Clone, Debug)]
pub struct Point_f64 {
    pub x: f64,
    pub y: f64,
}

impl Point_f64 {
    pub fn new(x: f64, y: f64) -> Self {
        Self { x, y }
    }

    pub fn from(pt: Point) -> Self {
        Self {
            x: pt.x() as f64,
            y: pt.y() as f64
        }
    }

    pub fn x(&self) -> f64 {
        self.x
    }

    pub fn y(&self) -> f64 {
        self.y
    }
}

impl ops::Add for Point_f64 {
    type Output = Point_f64;

    fn add(self, _rhs: Point_f64) -> Self::Output {
        Self {
            x: self.x() + _rhs.x(),
            y: self.y() + _rhs.y(),
        }
    }
}

impl ops::Sub for Point_f64 {
    type Output = Point_f64;

    fn sub(self, _rhs: Point_f64) -> Self::Output {
        Self {
            x: self.x() - _rhs.x(),
            y: self.y() - _rhs.y(),
        }
    }
}

impl ops::Mul<f64> for Point_f64 {
    type Output = Point_f64;

    fn mul(self, _rhs: f64) -> Self::Output {
        Self {
            x: self.x() * _rhs,
            y: self.y() * _rhs,
        }
    }
}

impl ops::Neg for Point_f64 {
    type Output = Point_f64;

    fn neg(self) -> Self::Output {
        Self {
            x: -self.x(),
            y: -self.y(),
        }
    }
}

pub fn is_in_rectangle(lu: Point_f64, rd: Point_f64, point: Point_f64) -> bool {
    lu.x() <= point.x() && point.x() <= rd.x &&
        lu.y() <= point.y() && point.y() <= rd.y
}

