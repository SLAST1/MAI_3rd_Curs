'use strict';

let shaderSources = {
    vertexShader: `#version 300 es
    in vec4 a_position;
    in vec4 a_color;
    uniform mat4 u_matrix;
    out vec4 v_color;

    void main() {
        v_color = a_color;
        gl_Position = u_matrix * a_position;
    }
    `,

    fragmentShader: `#version 300 es
    precision highp float;

    in vec4 v_color;
    out vec4 outColor;

    void main() {
        outColor = v_color;
    }
    `
};

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
}

function createProgram(gl, shader1, shader2) {
    let program = gl.createProgram();
    gl.attachShader(program, shader1);
    gl.attachShader(program, shader2);
    gl.linkProgram(program);
    let success = gl.getProgramParameter(program, gl.LINK_STATUS);
    if (success) {
        return program;
    }
    console.log(gl.getProgramInfoLog(program));
    gl.deleteProgram(program);
}

let rand = Math.random;

let mode = 0;

function main() {
    let obj = {
        x: 0,
        y: 0,
        z: -2,
        rotX: 0,
        rotY: 0,
        rotZ: 0,
        scale: 0.25,
        vertices: [
            -1, -1, -1,
            1, -1, -1,
            0.5, 1, -0.5,
            -0.5, 1, -0.5,

            -1, -1, 1,
            1, -1, 1,
            0.5, 1, 0.5,
            -0.5, 1, 0.5,

            -1, -1, -1,
            -0.5, 1, -0.5,
            -0.5, 1, 0.5,
            -1, -1, 1,

            1, -1, -1,
            0.5, 1, -0.5,
            0.5, 1, 0.5,
            1, -1, 1,

            -0.5, 1, -0.5,
            0.5, 1, -0.5,
            0.5, 1, 0.5,
            -0.5, 1, 0.5,

            -1, -1, -1,
            1, -1, -1,
            1, -1, 1,
            -1, -1, 1,
        ],
        indices: [
            0, 2, 1,
            0, 3, 2,

            4, 5, 6,
            4, 6, 7,

            8, 10, 9,
            8, 11, 10,

            12, 13, 14,
            12, 14, 15,

            16, 18, 17,
            16, 19, 18,

            20, 21, 22,
            20, 22, 23
        ],
        colors: []
    };

    for (let i = 0; i < 6; ++i) {
        let rand_color1 = rand();
        let rand_color2 = rand();
        let rand_color3 = rand();
        for (let j = 0; j < 4; ++j) {
            obj.colors.push(rand_color1);
            obj.colors.push(rand_color2);
            obj.colors.push(rand_color3);
        }
    }

    /** @type {HTMLCanvasElement} */
    let canvas = document.querySelector('canvas');
    canvas.width = window.innerWidth;
    canvas.height = window.innerHeight;

    let gl = canvas.getContext('webgl2');
    gl.clearColor(1, 1, 1, 1);
    gl.viewport(0, 0, canvas.width, canvas.height);
    gl.enable(gl.DEPTH_TEST);
    gl.enable(gl.CULL_FACE);

    window.addEventListener('resize', function(event) {
        canvas.width = window.innerWidth;
        canvas.height = window.innerHeight;
        gl.viewport(0, 0, canvas.width, canvas.height);
        draw();
    });

    document.querySelector('#xt').addEventListener('input', function(event) {
        obj.x = this.value;
        draw();
    });
    document.querySelector('#yt').addEventListener('input', function(event) {
        obj.y = this.value;
        draw();
    });
    document.querySelector('#zt').addEventListener('input', function(event) {
        obj.z = this.value;
        draw();
    });
    addEventListener('wheel', function(event) {
        obj.scale -= event.deltaY * 0.0002;
        obj.scale = Math.max(obj.scale, 0);
        draw();
    });
    document.querySelector('#rotX').addEventListener('input', function(event) {
        obj.rotX = this.value/180 * Math.PI;
        draw();
    });
    document.querySelector('#rotY').addEventListener('input', function(event) {
        obj.rotY = this.value/180 * Math.PI;
        draw();
    });
    document.querySelector('#rotZ').addEventListener('input', function(event) {
        obj.rotZ = this.value/180 * Math.PI;
        draw();
    });

    let radios = document.querySelectorAll('input[type="radio"]');
    for (let i of radios) {
        i.addEventListener('click', function(event) {
            if (this.value === '0') {
                mode = 0;
                draw();
            }
            else {
                mode = 1;
                draw();
            }
        });
    }

    let vertexShader = createShader(gl, gl.VERTEX_SHADER, shaderSources.vertexShader);
    let fragmentShader = createShader(gl, gl.FRAGMENT_SHADER, shaderSources.fragmentShader);
    let program = createProgram(gl, vertexShader, fragmentShader);
    gl.useProgram(program);

    let positionLocation = gl.getAttribLocation(program, 'a_position');
    let colorLocation = gl.getAttribLocation(program, 'a_color');
    let matrixLocation = gl.getUniformLocation(program, 'u_matrix');

    let vao = gl.createVertexArray();
    gl.bindVertexArray(vao);

    let positionBuff = gl.createBuffer();
    gl.bindBuffer(gl.ARRAY_BUFFER, positionBuff);
    gl.bufferData(gl.ARRAY_BUFFER, new Float32Array(obj.vertices), gl.STATIC_DRAW);

    gl.enableVertexAttribArray(positionLocation);
    gl.vertexAttribPointer(positionLocation, 3, gl.FLOAT, false, 0, 0);

    let colorBuff = gl.createBuffer();
    gl.bindBuffer(gl.ARRAY_BUFFER, colorBuff);
    gl.bufferData(gl.ARRAY_BUFFER, new Float32Array(obj.colors), gl.STATIC_DRAW);

    gl.enableVertexAttribArray(colorLocation);
    gl.vertexAttribPointer(colorLocation, 3, gl.FLOAT, false, 0, 0);

    let indexBuff = gl.createBuffer();
    gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, indexBuff);
    gl.bufferData(gl.ELEMENT_ARRAY_BUFFER, new Uint16Array(obj.indices), gl.STATIC_DRAW);

    draw()

    function draw() {
        let zval;
        let normal = m4.identity;
        if (canvas.width > canvas.height) {
            normal = normal.scale(canvas.height/canvas.width, 1, 1);
        }
        else {
            normal = normal.scale(1, canvas.width/canvas.height, 1);
        }
        let matrix;
        if (mode === 0) {
            matrix = m4.perspective(45, canvas.width/canvas.height, 0.1, 100);
            zval = obj.z;
        }
        else {
            matrix = normal.multiply(new m4([1, 0, 0, 0,
                                             0, 1, 0, 0,
                                             0, 0,-1, 0,
                                             0, 0, 0, 1]));
            zval = 0;
        }
        matrix = matrix.translate(obj.x, obj.y, zval).rotate(obj.rotX, obj.rotY, obj.rotZ).scale(obj.scale, obj.scale, obj.scale);
        gl.uniformMatrix4fv(matrixLocation, false, matrix.array);
        gl.drawElements(gl.TRIANGLES, 36, gl.UNSIGNED_SHORT, 0);
    }
}

main();