use crate::point::{self, Point, Point_f64};
use crate::color::Color;

use std::f64::consts::PI;
use crate::canvas::{CairoCanvas, Canvas};

struct Axis {
    xoy: Point,
    angle: f64,
    zoom: u32,
    real_zoom: f64,
    center: Point,
}

impl<'a> Axis {
    pub fn new(canvas: &'a CairoCanvas) -> Self {
        Axis {
            xoy: Point::new(
                canvas.width() / 2,
                canvas.height() / 2,
            ),
            angle: 0.0,
            zoom: 100,
            real_zoom: 1.0,
            center: Point::new(
                canvas.width() / 2,
                canvas.height() / 2,
            ),
        }
    }

    pub fn rotate(&mut self, angle: f64) {
        self.angle = to_radians(angle);
    }

    pub fn zoom(&mut self, zoom: u32) {
        self.zoom = zoom;
        self.real_zoom = 2_f64.powi(100 - self.zoom as i32);
    }

    pub fn shift(&mut self, offset: Point) {
        self.xoy = self.center + offset;
    }

    pub fn draw(&self, canvas: &mut CairoCanvas) {
        let diagonal = ((canvas.width() * canvas.width()
            + canvas.height() * canvas.height()) as f64)
            .sqrt()
            * 2.0;
        let a = Point::new(
            self.xoy.x() + (diagonal * self.angle.cos()) as i32,
            self.xoy.y() + (diagonal * self.angle.sin()) as i32,
        );
        let b = Point::new(
            self.xoy.x() + (diagonal * (self.angle + PI * 0.5).cos()) as i32,
            self.xoy.y() + (diagonal * (self.angle + PI * 0.5).sin()) as i32,
        );
        let c = Point::new(
            self.xoy.x() + (diagonal * (self.angle + PI).cos()) as i32,
            self.xoy.y() + (diagonal * (self.angle + PI).sin()) as i32,
        );
        let d = Point::new(
            self.xoy.x() + (diagonal * (self.angle + PI * 1.5).cos()) as i32,
            self.xoy.y() + (diagonal * (self.angle + PI * 1.5).sin()) as i32,
        );

        self.draw_strokes(canvas);
        // Find intersection with borders
        // let  = point::intersect_rect_line(&self.corner, (&a, &c));
        // let [b, d] = point::intersect_rect_line(&self.corner, (&b, &d));

        canvas.draw_line(&[a, c]);
        canvas.draw_line(&[b, d]);
    }

    fn draw_strokes(&self, canvas: &mut CairoCanvas) {
        const MAG: u32 = 100;

        let step = MAG;// - (MAG / 2) * self.zoom % MAG;
        let astep = Point_f64::new(
            step as f64 * self.angle.cos(),
            step as f64 * self.angle.sin()
        );
        let bstep = Point_f64::new(
            step as f64 * (PI * 0.5 + self.angle).cos(),
            step as f64 * (PI * 0.5 + self.angle).sin(),
        );

        const STROKE_LEN: f64 = 4.0;
        let aperp = Point_f64::new(
            STROKE_LEN * (PI * 0.5 + self.angle).cos(),
            STROKE_LEN * (PI * 0.5 + self.angle).sin(),
        );

        let bperp = Point_f64::new(
            STROKE_LEN * (PI * 1.0 + self.angle).cos(),
            STROKE_LEN * (PI * 1.0 + self.angle).sin(),
        );

        let pt: Point_f64 = Point_f64::from(self.xoy.clone());

        let lu = Point_f64::new(0.0, 0.0);
        let rd = Point_f64::new(
            canvas.width() as f64,
            canvas.height() as f64,
        );

        // GoGo paint it out!
        let apt = self.draw_axis(canvas, pt, astep, aperp, lu, rd, 1.0);
        let apt = self.point_arrow(apt - astep, apt, lu, rd);
        canvas.draw_line(&[
            Point::from(apt + bperp * 2.0 + aperp),
            Point::from(apt),
        ]);
        canvas.draw_line(&[
            Point::from(apt + bperp * 2.0 - aperp),
            Point::from(apt),
        ]);

        self.draw_axis(canvas, pt, -astep, aperp, lu, rd, -1.0);

        self.draw_axis(canvas, pt, bstep, bperp, lu, rd, -1.0);

        let bpt = self.draw_axis(canvas, pt, -bstep, bperp, lu, rd, 1.0);
        let bpt = self.point_arrow(bpt + bstep, bpt, lu, rd);
        canvas.draw_line(&[
            Point::from(bpt + aperp * 2.0 + bperp),
            Point::from(bpt),
        ]);
        canvas.draw_line(&[
            Point::from(bpt + aperp * 2.0 - bperp),
            Point::from(bpt),
        ]);
    }

    fn draw_axis(&self, canvas: &mut CairoCanvas,
                 pt: Point_f64, step: Point_f64, perp: Point_f64,
                 lu: Point_f64, rd: Point_f64, sign: f64
    ) -> Point_f64 {
        let mut pt = pt;
        let num = 100.0 / 2_f64.powi(100 - self.zoom as i32);
        for i in 1..40 {
            pt = pt + step;
            if !point::is_in_rectangle(lu, rd, pt) {
                break;
            }
            canvas.draw_line(&[ Point::from(pt + perp), Point::from(pt - perp) ]);
            canvas.print_text(&Point::from(pt + perp * 4.0),
                              &(format!("{:.1}", sign * (i as f64 * num))));
        }
        pt
    }

    fn point_arrow(&self, pre_pt: Point_f64, pt: Point_f64,
                  lu: Point_f64, rd: Point_f64) -> Point_f64 {
        let mut l = pre_pt;
        let mut r = pt;

        const EPS: f64 = 0.001;
        while (r - l).x().abs() > EPS || (r - l).y().abs() > EPS {
            let mid = (l + r) * 0.5;

            if !point::is_in_rectangle(lu, rd, mid) {
                r = mid;
            } else {
                l = mid;
            }
        }
        r
    }
}


pub struct Figure {
    points: Vec<Point_f64>, // точки, по которым строим окружность
    base_points: Vec<Point_f64>,
    axis: Axis, // абсциссы, к которым привязана фигура
    offset: Point, // сдвиг к центру
    parts: u32, // количество точек, по которым строится фигура
    scale_ox: f64,
    scale_oy: f64,
    zoom: f64,
}

fn to_radians(angle: f64) -> f64 {
    angle / 180.0 * PI
}

fn points_to_i32(pts_f64: &Vec<Point_f64>) -> Vec<Point> {
    let mut pts_i32: Vec<Point> = Vec::new();
    for pt in pts_f64 {
        pts_i32.push(Point::new(pt.x() as i32, pt.y() as i32));
    }
    pts_i32
}

impl Figure {
    pub fn new(canvas: &CairoCanvas) -> Self {
        Figure {
            points: Vec::new(),
            base_points: Vec::new(),
            axis: Axis::new(&canvas),
            offset: Point::new(0, 0),
            parts: 0u32,
            scale_ox: 100f64,
            scale_oy: 100f64,
            zoom: 0.0,
        }
    }

    pub fn set_base_points(&mut self, pts: &Vec<Point_f64>) {
        self.base_points = pts.clone();
    }

    pub fn parts(&mut self, parts: u32) {
        self.parts = parts;
    }

    pub fn rotate_axis(&mut self, angle: f64) {
        self.axis.rotate(angle);
    }

    pub fn shift_axis(&mut self, offset: Point) {
        self.axis.shift(offset);
    }

    pub fn zoom(&mut self, zoom: f64) {
        //self.axis.zoom(zoom as u32);
        self.zoom = zoom;
    }

    pub fn shift(&mut self, offset: Point) {
        self.offset = offset;
    }

    pub fn scaleOx(&mut self, scale: f64) {
        self.scale_ox = scale;
    }

    pub fn scaleOy(&mut self, scale: f64) {
        self.scale_oy = scale;
    }

    fn lagrange(&self, x: f64) -> f64 {
        let mut y: f64 = 0.0;
        for i in 0..self.base_points.len() {
            let mut l_up: f64 = 1.0;
            let mut l_down: f64 = 1.0;
            for j in 0..self.base_points.len() {
                if i != j {
                    l_up *= x - self.base_points[j].x();
                    l_down *= self.base_points[i].x() - self.base_points[j].x();
                }
            }
            y += l_up / l_down * self.base_points[i].y();
        }
        y
    }

    fn construct(&mut self, canvas: &mut CairoCanvas) {
        let begin: f64 = 0.0;
        let end: f64 = canvas.width() as f64;

        let width = end - begin;
        let step = width / (self.parts as f64);

        //println!("begin = {}, end = {}, steep = {}", begin, end, step);

        for num in 0..=self.parts {
            let x = begin + step * num as f64;
            if x > begin + width {
                break
            }
            self.points.push(Point_f64::new(x, self.lagrange(x)));
            //println!("x = {}", x);
        }
    }

    fn transform_points(&self, pts_f64: &Vec<Point_f64>) -> Vec<Point_f64> {
        let mut pts_i32: Vec<Point_f64> = Vec::new();
        for pt in pts_f64 {
            let new_pt = Point_f64::new(pt.x(), -pt.y()) * self.zoom +
                Point_f64::from(self.offset);
            pts_i32.push(new_pt);
            println!("{:?} -> {:?}", pt, pts_i32.last());
        }
        pts_i32
    }

    pub fn draw(&mut self, canvas: &mut CairoCanvas) {
        canvas.set_draw_color(Color::new(0, 0, 0));

        self.points = self.transform_points(&self.points);
        self.base_points = self.transform_points(&self.base_points);
        self.construct(canvas);

        canvas.draw_line(&points_to_i32(&self.points));
        canvas.draw_line(&points_to_i32(&self.base_points));

        for pt in &points_to_i32(&self.base_points) {
            canvas.draw_filled_circle(pt, 5.0);
        }
        //self.axis.draw(canvas);
    }
}
