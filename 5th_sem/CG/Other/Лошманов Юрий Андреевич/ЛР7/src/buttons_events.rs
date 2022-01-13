use gtk::prelude::*;
use std::rc::Rc;
use std::cell::RefCell;
use std::collections::HashMap;
use crate::state::State;

pub fn setup_buttons_events(
    buttons: &HashMap<String, gtk::SpinButton>,
    state: &Rc<RefCell<State>>,
    drawing_area: &Rc<RefCell<gtk::DrawingArea>>,
) {
    {
        let button_state = Rc::clone(&state);
        let drawing = Rc::clone(&drawing_area);
        buttons.get("cntPoints").unwrap().connect_value_changed(move |spin_button| {
            let mut cur_state = button_state.borrow_mut();
            let area = drawing.borrow();
            cur_state.cntPoints = spin_button.get_value_as_int();
            area.queue_draw();
        });
    }

    {
        let button_state = Rc::clone(&state);
        let drawing = Rc::clone(&drawing_area);
        buttons.get("moveFigureOx").unwrap().connect_value_changed(move |spin_button| {
            let mut cur_state = button_state.borrow_mut();
            let area = drawing.borrow();
            cur_state.moveFigureOx = spin_button.get_value_as_int();
            area.queue_draw();
        });
    }

    {
        let button_state = Rc::clone(&state);
        let drawing = Rc::clone(&drawing_area);
        buttons.get("moveFigureOy").unwrap().connect_value_changed(move |spin_button| {
            let mut cur_state = button_state.borrow_mut();
            let area = drawing.borrow();
            cur_state.moveFigureOy = spin_button.get_value_as_int();
            area.queue_draw();
        });
    }
    {
        let button_state = Rc::clone(&state);
        let drawing = Rc::clone(&drawing_area);
        buttons.get("scale").unwrap().connect_value_changed(move |spin_button| {
            let mut cur_state = button_state.borrow_mut();
            let area = drawing.borrow();
            cur_state.scale = spin_button.get_value_as_int();
            area.queue_draw();
        });
    }
    {
        let button_state = Rc::clone(&state);
        let drawing = Rc::clone(&drawing_area);
        buttons.get("scaleOx").unwrap().connect_value_changed(move |spin_button| {
            let mut cur_state = button_state.borrow_mut();
            let area = drawing.borrow();
            cur_state.scaleOx = spin_button.get_value_as_int();
            area.queue_draw();
        });
    }
    {
        let button_state = Rc::clone(&state);
        let drawing = Rc::clone(&drawing_area);
        buttons.get("scaleOy").unwrap().connect_value_changed(move |spin_button| {
            let mut cur_state = button_state.borrow_mut();
            let area = drawing.borrow();
            cur_state.scaleOy = spin_button.get_value_as_int();
            area.queue_draw();
        });
    }

    {
        let button_state = Rc::clone(&state);
        let drawing = Rc::clone(&drawing_area);
        buttons.get("zoom").unwrap().connect_value_changed(move |spin_button| {
            let mut cur_state = button_state.borrow_mut();
            let area = drawing.borrow();
            cur_state.zoom = spin_button.get_value_as_int();
            area.queue_draw();
        });
    }
    {
        let button_state = Rc::clone(&state);
        let drawing = Rc::clone(&drawing_area);
        buttons.get("moveAxisOx").unwrap().connect_value_changed(move |spin_button| {
            let mut cur_state = button_state.borrow_mut();
            let area = drawing.borrow();
            cur_state.moveAxisOx = spin_button.get_value_as_int();
            area.queue_draw();
        });
    }
        {
        let button_state = Rc::clone(&state);
        let drawing = Rc::clone(&drawing_area);
        buttons.get("moveAxisOy").unwrap().connect_value_changed(move |spin_button| {
            let mut cur_state = button_state.borrow_mut();
            let area = drawing.borrow();
            cur_state.moveAxisOy = spin_button.get_value_as_int();
            area.queue_draw();
        });
    }
    {
        let button_state = Rc::clone(&state);
        let drawing = Rc::clone(&drawing_area);
        buttons.get("rotateAxes").unwrap().connect_value_changed(move |spin_button| {
            let mut cur_state = button_state.borrow_mut();
            let area = drawing.borrow();
            cur_state.rotateAxes = spin_button.get_value_as_int();
            area.queue_draw();
        });
    }
}
