use crate::figure::Figure;
use crate::state::State;
use crate::point::Point;
use crate::canvas::{CairoCanvas, Canvas};
use std::cmp::min;
use std::rc::Rc;
use std::cell::RefCell;

use std::cell::Ref;

pub fn handle_draw(canvas: &mut CairoCanvas, circle: &mut Figure, state: &mut State) {
    let width = canvas.width();
    let height = canvas.height();
    let coefficient = min(width, height) as f64 / 600.0;

    state.coefficient = coefficient;
    state.width = width;
    state.height = height;

    circle.set_base_points(&state.points);
    circle.parts(state.cntPoints as u32);
    circle.rotate_axis(state.rotateAxes as f64);
    circle.shift(Point::new(state.moveFigureOx + width / 2, state.moveFigureOy + height / 2));
    circle.zoom(state.zoom as f64 / 10.0 * coefficient);
    circle.scaleOx(state.scaleOx as f64);
    circle.scaleOy(state.scaleOy as f64);
    circle.shift_axis(Point::new(state.moveAxisOx, state.moveAxisOy));
    circle.draw(canvas);
}
