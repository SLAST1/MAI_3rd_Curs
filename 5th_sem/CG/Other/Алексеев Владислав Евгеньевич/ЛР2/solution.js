function main() {
    let canvas = document.getElementById("prism");
    let gl = canvas.getContext("webgl");
    let program = createProgram(gl);
    let positionLocation = gl.getAttribLocation(program, "a_position");
    let matrixLocation = gl.getUniformLocation(program, "u_matrix");
    let colorLocation = gl.getUniformLocation(program,'u_Color');

    gl.enable(gl.DEPTH_TEST);
    let positionBuffer = gl.createBuffer();
    let rotation = [-Math.PI/2, 0, 0];
    gl.bindBuffer(gl.ARRAY_BUFFER, positionBuffer);
    setVertex(gl);
    let triangleBuffer= gl.createBuffer();
    gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, triangleBuffer);
    setGeometry(gl);
    let drag = false;
    let old_x; let old_y;
    let rot_x = 45.; let rot_y = 12.;
    let scale = 1;

    let mouseDownHandler = function (e) { // Обработчик нажатия мыши
        drag = true;
        old_x = e.pageX;
        old_y = e.pageY;
        e.preventDefault();
    }
    let mouseUpHandler = function (e) { // Обработчик мыши вверх
        drag = false;
        e.preventDefault();
    }
    let mouseMoveHandler = function (e) { // Обработчик перемещения мыши
        if (!drag) {
            return false;
        };

        let newX = old_x - e.pageX;
        let newY = old_y - e.pageY;

        rot_x += newX * 2 * Math.PI / canvas.width;
        rot_y += newY * 2 * Math.PI / canvas.height;

        old_x = e.pageX;
        old_y = e.pageY;

        e.preventDefault();
    }
    let wheelHandler = function (e) { // Масштабирование
        scale += e.deltaY/1000;
        e.preventDefault();
    }

    canvas.addEventListener("mousedown", mouseDownHandler, false); // Мышь вниз
    canvas.addEventListener("mouseup", mouseUpHandler, false); // Мышь вверх
    canvas.addEventListener("mouseout", mouseUpHandler, false); // Вывод
    canvas.addEventListener("mousemove", mouseMoveHandler, false); // Движение мыши
    canvas.addEventListener('wheel',wheelHandler, false); // Колёсико
    
    let drawScene = function (time) { // Прорисовка
        rotation=[rot_y, rot_x, 0];
        let matrix = m4.identity();
        matrix = m4.scale(matrix, scale, scale, scale);
        matrix = m4.xRotate(matrix, rotation[0]);
        matrix = m4.yRotate(matrix, rotation[1]);
        matrix = m4.zRotate(matrix, rotation[2]);
        resize(gl.canvas);
        gl.viewport(0, 0, gl.canvas.width, gl.canvas.height);
        gl.clear(gl.COLOR_BUFFER_BIT);
        gl.useProgram(program);
        gl.enableVertexAttribArray(positionLocation);
        gl.vertexAttribPointer(positionLocation, 3, gl.FLOAT, false, 0, 0);
        gl.uniform3f(colorLocation, 1, 1, 1);
        gl.uniformMatrix4fv(matrixLocation, false, matrix);
        gl.drawElements(gl.TRIANGLES, 72, gl.UNSIGNED_SHORT, 0 );
        gl.uniform3f(colorLocation, 0.0, 0.0, 0.0);
        gl.drawElements(gl.LINE_STRIP, 72, gl.UNSIGNED_SHORT, 0);
        gl.flush();

        window.requestAnimationFrame(drawScene);
    }
    drawScene(0);
}

function createShader(gl, type, source) {
    let shader = gl.createShader(type);

    gl.shaderSource(shader, source);
    gl.compileShader(shader);

    let success = gl.getShaderParameter(shader, gl.COMPILE_STATUS);

    if (success) {
        return shader;
    }
    console.log(gl.getShaderInfoLog(shader));
    gl.deleteShader(shader);
    alert("Не удалось создать шейдер");
}

function createProgram(gl) {
    let program = gl.createProgram();
    let vertexShaderSource = document.querySelector("#vertex-shader-2d").text;
    let fragmentShaderSource = document.querySelector("#fragment-shader-2d").text;
    let vertexShader = createShader(gl, gl.VERTEX_SHADER, vertexShaderSource);
    let fragmentShader = createShader(gl, gl.FRAGMENT_SHADER, fragmentShaderSource);
    gl.attachShader(program, vertexShader);
    gl.attachShader(program, fragmentShader);
    gl.linkProgram(program);
    if (gl.getProgramParameter(program, gl.LINK_STATUS)) {
        return program;
    }

    console.log(gl.getProgramInfoLog(program));
    gl.deleteProgram(program);
    alert("Не удалось связать Шейдеры");
}

function setVertex(gl) { // Установление вершин
    let array = new Float32Array([
            0,-0.5, 0, // 0
            0.4, -0.5, 0, // 1
            0.4 * Math.cos(Math.PI/3), -0.5, 0.4 * Math.sin(Math.PI/3), // 2
            -0.4, -0.5, 0, // 3
            -0.4 * Math.cos(Math.PI/3), -0.5, 0.4 * Math.sin(Math.PI/3), // 4
            0.4 * Math.cos(Math.PI/3), -0.5, -0.4 * Math.sin(Math.PI/3), // 5
            -0.4 * Math.cos(Math.PI/3), -0.5, -0.4 * Math.sin(Math.PI/3), // 6
            0, 0.5, 0, // 7
            0.4, 0.5, 0, // 8
            0.4 * Math.cos(Math.PI/3), 0.5, 0.4 * Math.sin(Math.PI/3), // 9
            -0.4, 0.5, 0, // 10
            -0.4 * Math.cos(Math.PI/3), 0.5, 0.4 * Math.sin(Math.PI/3), // 11
            0.4 * Math.cos(Math.PI/3), 0.5, -0.4 * Math.sin(Math.PI/3), // 12
            -0.4 * Math.cos(Math.PI/3), 0.5, -0.4 * Math.sin(Math.PI/3), // 13
        ]);
    gl.bufferData(gl.ARRAY_BUFFER, array, gl.STATIC_DRAW);
}

function setGeometry(gl) {
    gl.bufferData(gl.ELEMENT_ARRAY_BUFFER, new Uint16Array([
        // Нижнее основание
        0, 2, 1,
        2, 4, 0,
        4, 3, 0,
        6, 3, 0,
        6, 5, 0,
        5, 1, 0,
        // Боковые грани
        1, 2, 8,
        8, 2, 9,
        2, 4, 9,
        9, 4, 11,
        4, 3, 11,
        11, 3, 10,
        3, 6, 10,
        10, 13, 6,
        6, 5, 13,
        13, 12, 5,
        5, 1, 12,
        12, 8, 1,
        // Верхняя грань
        9, 8, 7,
        9, 11, 7,
        11, 10, 7,
        13, 10, 7,
        13, 12, 7,
        12, 8, 7,
    ]), gl.STATIC_DRAW);
}

function resize(canvas) {
    // Получаем размер canvas
    let displayWidth  = canvas.clientWidth;
    let displayHeight = canvas.clientHeight;

    // Проверяем, отличается ли размер canvas
    if (canvas.width != displayWidth || canvas.height != displayHeight) {
        // Подгоняем размер буфера отрисовки под размер HTML-элемента
        canvas.width  = displayWidth;
        canvas.height = displayHeight;
    }
}

let m4 = {
    xRotate: function(m, angleInRadians) {
        return m4.multiply(m, m4.xRotation(angleInRadians));
    },

    yRotate: function(m, angleInRadians) {
        return m4.multiply(m, m4.yRotation(angleInRadians));
    },

    zRotate: function(m, angleInRadians) {
        return m4.multiply(m, m4.zRotation(angleInRadians));
    },

    translate: function(m, tx, ty, tz) {
        return m4.multiply(m, m4.translation(tx, ty, tz));
    },

    scale: function(m, sx, sy, sz) {
        return m4.multiply(m, m4.scaling(sx, sy, sz));
    },

    xRotation: function(angleInRadians) {
        let c = Math.cos(angleInRadians);
        let s = Math.sin(angleInRadians);
        return [
            1, 0, 0, 0,
            0, c, s, 0,
            0, -s, c, 0,
            0, 0, 0, 1,
        ];
    },

    scaling: function(sx, sy, sz) {
        return [
            sx, 0,  0,  0,
            0, sy,  0,  0,
            0,  0, sz,  0,
            0,  0,  0,  1,
        ];
    },

    translation: function(tx, ty, tz) {
        return [
            1,  0,  0,  0,
            0,  1,  0,  0,
            0,  0,  1,  0,
            tx, ty, tz, 1,
        ];
    },

    yRotation: function(angleInRadians) {
        var c = Math.cos(angleInRadians);
        var s = Math.sin(angleInRadians);
        return [
            c, 0, -s, 0,
            0, 1, 0, 0,
            s, 0, c, 0,
            0, 0, 0, 1,
        ];
    },

    zRotation: function(angleInRadians) {
        var c = Math.cos(angleInRadians);
        var s = Math.sin(angleInRadians);
        return [
            c, s, 0, 0,
            -s, c, 0, 0,
            0, 0, 1, 0,
            0, 0, 0, 1,
        ];
    },

    multiply: function(a, b) {
        let a00 = a[0 * 4 + 0];
        let a01 = a[0 * 4 + 1];
        let a02 = a[0 * 4 + 2];
        let a03 = a[0 * 4 + 3];
        let a10 = a[1 * 4 + 0];
        let a11 = a[1 * 4 + 1];
        let a12 = a[1 * 4 + 2];
        let a13 = a[1 * 4 + 3];
        let a20 = a[2 * 4 + 0];
        let a21 = a[2 * 4 + 1];
        let a22 = a[2 * 4 + 2];
        let a23 = a[2 * 4 + 3];
        let a30 = a[3 * 4 + 0];
        let a31 = a[3 * 4 + 1];
        let a32 = a[3 * 4 + 2];
        let a33 = a[3 * 4 + 3];
        let b00 = b[0 * 4 + 0];
        let b01 = b[0 * 4 + 1];
        let b02 = b[0 * 4 + 2];
        let b03 = b[0 * 4 + 3];
        let b10 = b[1 * 4 + 0];
        let b11 = b[1 * 4 + 1];
        let b12 = b[1 * 4 + 2];
        let b13 = b[1 * 4 + 3];
        let b20 = b[2 * 4 + 0];
        let b21 = b[2 * 4 + 1];
        let b22 = b[2 * 4 + 2];
        let b23 = b[2 * 4 + 3];
        let b30 = b[3 * 4 + 0];
        let b31 = b[3 * 4 + 1];
        let b32 = b[3 * 4 + 2];
        let b33 = b[3 * 4 + 3];
        return [
            b00 * a00 + b01 * a10 + b02 * a20 + b03 * a30,
            b00 * a01 + b01 * a11 + b02 * a21 + b03 * a31,
            b00 * a02 + b01 * a12 + b02 * a22 + b03 * a32,
            b00 * a03 + b01 * a13 + b02 * a23 + b03 * a33,
            b10 * a00 + b11 * a10 + b12 * a20 + b13 * a30,
            b10 * a01 + b11 * a11 + b12 * a21 + b13 * a31,
            b10 * a02 + b11 * a12 + b12 * a22 + b13 * a32,
            b10 * a03 + b11 * a13 + b12 * a23 + b13 * a33,
            b20 * a00 + b21 * a10 + b22 * a20 + b23 * a30,
            b20 * a01 + b21 * a11 + b22 * a21 + b23 * a31,
            b20 * a02 + b21 * a12 + b22 * a22 + b23 * a32,
            b20 * a03 + b21 * a13 + b22 * a23 + b23 * a33,
            b30 * a00 + b31 * a10 + b32 * a20 + b33 * a30,
            b30 * a01 + b31 * a11 + b32 * a21 + b33 * a31,
            b30 * a02 + b31 * a12 + b32 * a22 + b33 * a32,
            b30 * a03 + b31 * a13 + b32 * a23 + b33 * a33,
        ];
    },
    identity: function () {
        return [
            1, 0,  0,  0,
            0, 1,  0,  0,
            0,  0, 1,  0,
            0,  0,  0,  1,
        ]
    }
};

main()