use gtk::prelude::*;
use gtk::Application;
use gio::prelude::*;

use std::collections::HashMap;
use std::env::args;
use std::rc::Rc;
use std::cell::RefCell;
use std;

mod canvas;
mod color;
mod figure;
mod point;
mod state;
mod buttons_events;
mod handle_draw;
use crate::figure::Figure;
use crate::canvas::{CairoCanvas, Canvas};
use crate::state::State;
use gdk::EventMask;

fn build_ui(app: &gtk::Application) {
    // Initialize the UI with Glade XML.
    let glade_src = include_str!("gui_lab1.glade");
    let builder = gtk::Builder::from_string(glade_src);

    // Get handles for the various controls we need to use.
    let window: gtk::Window = builder.get_object("mainWindow")
        .expect("Couldn't get mainWindow");


    // Get handles for all the buttons.
    let mut buttons: HashMap<String, gtk::SpinButton> = HashMap::new();
    for name in &["cntPoints", "moveFigureOx", "moveFigureOy", "rotateFigure",
                  "scale", "scaleOx", "scaleOy",
                  "zoom", "moveAxisOx", "moveAxisOy", "rotateAxes"] {
        buttons.insert(name.to_string(), builder.get_object(name)
                       .expect(&format!("Couldn't get button {}", name)));
    }

    let state = Rc::new(RefCell::new(State::new(&buttons)));

    let drawing_area: gtk::DrawingArea = builder.get_object("drawingArea")
        .expect("Couldn't get drawingArea");
    let drawing = Rc::new(RefCell::new(drawing_area));

    setup_canvas_area(&builder, &state, &drawing);
    crate::buttons_events::setup_buttons_events(&buttons, &state, &drawing);

    window.set_application(Some(app));
    window.show_all();
}

fn setup_canvas_area(
    builder: &gtk::Builder,
    state: &Rc<RefCell<State>>,
    drawing_area: &Rc<RefCell<gtk::DrawingArea>>,
) {
    {
        let draw_box: gtk::Box = builder.get_object("box").expect("Can't get boxx");
        let draw_state = Rc::clone(&state);
        let drawing = Rc::clone(&drawing_area);

        drawing.borrow().connect_draw(move |_, cr| {
            let size: (i32, i32) = (
                draw_box.get_allocated_width(),
                draw_box.get_allocated_height()
            );
            let mut canvas = CairoCanvas::new(&cr, size);
            canvas.set_line_width(0.002);

            let mut cur_draw_state = draw_state.borrow_mut();

            let mut circle: Figure = Figure::new(&canvas);

            crate::handle_draw::handle_draw(&mut canvas, &mut circle, &mut cur_draw_state);

            Inhibit(false)
        });
    }

    {
        let drawing_area_cloned = Rc::clone(&drawing_area);
        let drawing = drawing_area_cloned.borrow();
        drawing.add_events(
            EventMask::BUTTON_MOTION_MASK |
            EventMask::BUTTON_PRESS_MASK |
            EventMask::BUTTON_RELEASE_MASK
        );
    }

    {
        let button_state = Rc::clone(&state);
        let drawing_area_cloned = Rc::clone(&drawing_area);
        let drawing = drawing_area_cloned.borrow();
        drawing.connect_button_press_event(move |_, event| {
            let mut state = button_state.borrow_mut();
            let (x, y) = event.get_position();

            println!("({}, {})", x, y);

            for i in 0..state.points.len() {
                let px = state.points[i].x() *
                    state.zoom as f64 / 10.0 * state.coefficient +
                    (state.moveFigureOx + state.width / 2) as f64;
                let py = -state.points[i].y() *
                    state.zoom as f64 / 10.0 * state.coefficient +
                    (state.moveFigureOy + state.height / 2) as f64;
                println!("point ({}, {})", px, py);
                if (px - x) * (px - x) + (py - y) * (py - y) <= 100.0 {
                    state.point_chosen_num = i as i32;
                    state.mouse_x = x;
                    state.mouse_y = y;
                }
            }
            println!("state.numm {}", state.point_chosen_num);
            Inhibit(false)
        });
    }

    {
        let button_state = Rc::clone(&state);
        let drawing_area_cloned = Rc::clone(&drawing_area);
        let drawing = drawing_area_cloned.borrow();
        drawing.connect_button_release_event(move |area, _| {
            let mut state = button_state.borrow_mut();

            state.point_chosen_num = -1;
            area.queue_draw();
            Inhibit(false)
        });
    }

    {
        let button_state = Rc::clone(&state);
        let drawing_area_cloned = Rc::clone(&drawing_area);
        let drawing = drawing_area_cloned.borrow();
        drawing.connect_motion_notify_event(move |area, event| {
            let mut state = button_state.borrow_mut();
            if state.point_chosen_num != -1 {
                let (x, y) = event.get_position();
                let id = state.point_chosen_num as usize;
                state.points[id].x +=
                    (x - state.mouse_x) * 10.0 / state.zoom as f64 / state.coefficient;
                state.points[id].y -=
                    (y - state.mouse_y) * 10.0 / state.zoom as f64 / state.coefficient;
                state.mouse_x = x;
                state.mouse_y = y;
                println!("({}, {})", x, y);
            }
            area.queue_draw();
            Inhibit(false)
        });
    }
}

fn main() {
    // Initializing GTK application
    let application = Application::new(
        Some("src.main"),
        gio::ApplicationFlags::NON_UNIQUE,
    ).expect("failed to initialize GTK application");

    // The activation signal is emitted on the activation occurs
    application.connect_activate(|app| build_ui(app));

    // Run the application
    application.run(&args().collect::<Vec<_>>());
}
