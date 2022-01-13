'use strict';

class m4 {

    constructor(arr) {
        this.array = [...arr];
    }

    static get n() {
        return 4;
    }

    static get identity() {
        return new m4([1, 0, 0, 0,
                       0, 1, 0, 0,
                       0, 0, 1, 0,
                       0, 0, 0, 1]);
    }

    multiply(other) {
        let res = new m4(new Array(m4.n ** 2));
        for (let i = 0; i < m4.n; ++i) {
            for (let j = 0; j < m4.n; ++j) {
                res.array[m4.n * i + j] = 0;
                for (let k = 0; k < m4.n; ++k) {
                    res.array[m4.n * i + j] += other.array[m4.n * i + k] * this.array[m4.n * k + j];
                }
            }
        }
        return res;
    }

    translate(tx, ty, tz) {
        let res = new m4(this.array);
        let t_matrix = new m4([1,  0,  0, 0,
                               0,  1,  0, 0,
                               0,  0,  1, 0,
                               tx, ty, tz, 1]);
        return res.multiply(t_matrix);
    }

    rotateX(x) {
        let res = new m4(this.array);
        let c = Math.cos(x);
        let s = Math.sin(x);
        let rot_matrix = new m4([1, 0, 0, 0,
                                 0, c, s, 0,
                                 0,-s, c, 0,
                                 0, 0, 0, 1]);
        return res.multiply(rot_matrix);
    }

    rotateY(x) {
        let res = new m4(this.array);
        let c = Math.cos(x);
        let s = Math.sin(x);
        let rot_matrix = new m4([c, 0,-s, 0,
                                 0, 1, 0, 0,
                                 s, 0, c, 0,
                                 0, 0, 0, 1]);
        return res.multiply(rot_matrix);
    }

    rotateZ(x) {
        let res = new m4(this.array);
        let c = Math.cos(x);
        let s = Math.sin(x);
        let rot_matrix = new m4([c, s, 0, 0,
                                -s, c, 0, 0,
                                 0, 0, 1, 0,
                                 0, 0, 0, 1]);
        return res.multiply(rot_matrix);
    }

    rotate(x, y, z) {
        let res = new m4(this.array);
        return res.rotateX(x).rotateY(y).rotateZ(z);
    }

    scale(sx, sy, sz) {
        let res = new m4(this.array);
        let s_matrix = new m4([sx, 0, 0, 0,
                               0, sy, 0, 0,
                               0, 0, sz, 0,
                               0, 0, 0, 1]);
        return res.multiply(s_matrix);
    }

    static perspective(fov, aspect, near, far) {
        let f = 1 / Math.tan(fov/2);
        return new m4([f/aspect, 0, 0, 0,
                       0, f, 0, 0,
                       0, 0, -(far+near)/(far-near), -1,
                       0, 0, -2*(far*near)/(far-near), 0]);
    }
}
