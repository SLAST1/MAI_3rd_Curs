use std::collections::HashMap;
use gtk::prelude::*;
use crate::point::Point_f64;
use std::vec::Vec;

// Shared state for communication between buttons and drawingarea
pub struct State {
    pub points: Vec<Point_f64>,
    pub cntPoints: i32,
    pub moveFigureOx: i32,
    pub moveFigureOy: i32,
    pub scale: i32,
    pub scaleOx: i32,
    pub scaleOy: i32,
    pub zoom: i32,
    pub moveAxisOx: i32,
    pub moveAxisOy: i32,
    pub rotateAxes: i32,
    pub point_chosen_num: i32,
    pub coefficient: f64,
    pub width: i32,
    pub height: i32,
    pub mouse_x: f64,
    pub mouse_y: f64,
}
// And i really sorry about camel case

fn default_points() -> Vec<Point_f64> {
    vec![
        Point_f64::new(-9.0, 5.0),
        Point_f64::new(-4.0, 2.0),
        Point_f64::new(-1.0, -2.0),
        Point_f64::new(7.0, 9.0),
        Point_f64::new(14.0, 2.0),
    ]
}

impl State {
    pub fn new(buttons: &HashMap<String, gtk::SpinButton>) -> Self {
        State {
            points:       default_points(),
            cntPoints:    1000, //buttons.get("cntPoints").unwrap().get_value_as_int(),
            moveFigureOx: buttons.get("moveFigureOx").unwrap().get_value_as_int(),
            moveFigureOy: buttons.get("moveFigureOy").unwrap().get_value_as_int(),
            scale:        buttons.get("scale").unwrap().get_value_as_int(),
            scaleOx:      buttons.get("scaleOx").unwrap().get_value_as_int(),
            scaleOy:      buttons.get("scaleOy").unwrap().get_value_as_int(),
            zoom:         buttons.get("zoom").unwrap().get_value_as_int(),
            moveAxisOx:   buttons.get("moveAxisOx").unwrap().get_value_as_int(),
            moveAxisOy:   buttons.get("moveAxisOy").unwrap().get_value_as_int(),
            rotateAxes:   buttons.get("rotateAxes").unwrap().get_value_as_int(),
            point_chosen_num: -1,
            coefficient: 1.0,
            width: 0,
            height: 0,
            mouse_x: 0.0,
            mouse_y: 0.0,
        }
    }
}
