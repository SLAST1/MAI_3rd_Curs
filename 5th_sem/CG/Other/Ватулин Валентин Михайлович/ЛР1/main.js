'use strict';

function getPoints(a) {
    function f(temp1, temp2) {
        return ((temp1 + temp2) / 2).toFixed(10) ** 0.5;
    }

    let points = [];
    for (let x = -a*2; x <= a / 2; x = Number((x + 0.01).toFixed(10))) {
        const temp1 = a**1.5 * (a - 4*x)**0.5;
        const temp2 = a**2 - 2*a*x - 2*x**2;
        let y = [f(temp1, temp2), -f(temp1, temp2), f(-temp1, temp2), -f(-temp1, temp2)];
        if (!Number.isNaN(y[0])) {
            points.push([x, y[0]]);
            for (let i = 1; i < y.length; ++i) {
                if (y[i] !== y[i-1] && !Number.isNaN(y[i])) {
                    points.push([x, y[i]]);
                }
            }
        }
    }
    points.sort((a, b) => Math.atan2(a[1], a[0]) - Math.atan2(b[1], b[0]));
    return points;
}

function drawAxes(ctx) {
    const canvas = ctx.canvas;
    ctx.strokeStyle = '#000';
    ctx.lineWidth = 1;
    ctx.beginPath();
    ctx.moveTo(0, -canvas.height / 2);
    ctx.lineTo(0, canvas.height / 2);

    ctx.moveTo(-canvas.width / 2, 0);
    ctx.lineTo(canvas.width / 2, 0);

    ctx.moveTo(-canvas.width / 200, canvas.height * 0.48);
    ctx.lineTo(0, canvas.height / 2);
    ctx.lineTo(canvas.width / 200, canvas.height * 0.48);

    ctx.moveTo(canvas.width * 0.49, canvas.height / 100);
    ctx.lineTo(canvas.width / 2, 0);
    ctx.lineTo(canvas.width * 0.49, -canvas.height / 100);
    ctx.stroke();
}

function drawGraph(ctx, points) {
    const canvas = ctx.canvas;
    ctx.clearRect(-canvas.width / 2, -canvas.height / 2, canvas.width, canvas.height);
    drawAxes(ctx);
    ctx.strokeStyle = '#f00';
    ctx.lineWidth = 2;
    const scale = Math.min(canvas.width / 64, canvas.height / 36);
    ctx.beginPath();
    ctx.moveTo(points[0][0] * scale, points[0][1] * scale);
    for (let i = 1; i < points.length; ++i) {
        ctx.lineTo(points[i][0] * scale, points[i][1] * scale);
    }
    ctx.closePath();
    ctx.stroke();
}

function main() {
    const canvas = document.querySelector('canvas');
    canvas.width = window.innerWidth;
    canvas.height = window.innerHeight;
    let a = document.querySelector('#param').value;

    window.addEventListener('resize', function(event) {
        canvas.width = window.innerWidth;
        canvas.height = window.innerHeight;
        ctx.setTransform(1, 0, 0, -1, canvas.width / 2, canvas.height / 2);
        drawGraph(ctx, getPoints(a));
    });

    document.querySelector('#param').addEventListener('input', function() {
        a = this.value;
        document.querySelector('#slider>output').value = a;
        drawGraph(ctx, getPoints(a));
    });

    const ctx = canvas.getContext('2d');
    ctx.setTransform(1, 0, 0, -1, canvas.width / 2, canvas.height / 2);
    drawGraph(ctx, getPoints(a));
}

main();
