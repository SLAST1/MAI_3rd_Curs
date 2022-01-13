var stage;
var s;
var dragged = null;
var dots = [];

window.innerWidth = 850;
window.innerHeight = 600;

function Start() {
    stage = new Stage("default");
    s = new Sprite();
    stage.addChild(s);

    for (var i = 0; i < 3; i++) {
        var d = new Dot();
        d.x = 50 + i * 150;
        d.y = 50 + i * 100 + Math.sin(100 * i);
        d.addEventListener(MouseEvent.MOUSE_DOWN, onMD);
        stage.addChild(d);
        dots.push(d);
    }

    stage.addEventListener(MouseEvent.MOUSE_DOWN, addDot);
    stage.addEventListener(MouseEvent.MOUSE_MOVE, onMM);
    stage.addEventListener(MouseEvent.MOUSE_UP, onMU);
    redraw();
}

function onMD(e) {
    dragged = e.target;
}

function onMU(e) {
    dragged = null;
}

function onMM(e) {
    if (dragged == null) {
        return;
    }
    dragged.x = stage.mouseX;
    dragged.y = stage.mouseY;
    redraw();
}

function addDot(e) {
    if (e.target != stage) {
        return;
    }
    var d = new Dot();
    d.x = stage.mouseX;
    d.y = stage.mouseY;
    d.addEventListener(MouseEvent.MOUSE_DOWN, onMD);
    stage.addChild(d);
    dots.push(d);
    dragged = d;
    redraw();
}

function redraw() {
    dots.sort(function(a,b) {
        return a.x - b.x;
    });

    var xs = []; ys = []; ks = [];
    for (var i = 0; i < dots.length; i++) {
        var d = dots[i];
        xs[i] = d.x; ys[i] = d.y; ks[i] = 1;
    }
    CSPL.getNaturalKs(xs, ys, ks);

    s.graphics.clear();
    s.graphics.lineStyle(3, 0x000000);

    var minx = dots[0].x;
    var maxx = dots[dots.length-1].x;

    s.graphics.moveTo(minx, CSPL.evalSpline(minx, xs, ys, ks));
    for (var i = minx + 4; i <= maxx; i+= 4) {
        s.graphics.lineTo(i, CSPL.evalSpline(i, xs, ys, ks));
    }
}

function Dot() {
    Sprite.apply(this); // наследуется от Sprite
    this.graphics.beginFill(0x000000, 0.1);
    this.graphics.drawCircle(0, 0, 20);
    this.graphics.beginFill(0x999999, 1.0);
    this.graphics.drawCircle(0,0, 6);
    this.buttonMode = true;
}

Dot.prototype = new Sprite(); // Sprite Animation

window.onload = function () {
    Start();
};