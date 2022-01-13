'use strict';

class Vector {
    constructor(x, y, z) {
        this[0] = x;
        this[1] = y;
        this[2] = z;
    }

    cross(other) {
        return new Vector(this[1] * other[2] - this[2] * other[1],
                          this[0] * other[2] - this[2] * other[0],
                          this[0] * other [1] - this[1] * other[0]);
    }

    add(other) {
        return new Vector(this[0] + other[0], this[1] + other[1], this[2] + other[2]);
    }

    scale(par) {
        return new Vector( par * this[0], par * this[1], par * this[2]);
    }

    subtract(other) {
        return this.add(other.scale(-1));
    }

    rotateY(fi) {
        var x = this[0], y = this[1], z = this[2];
        return new Vector( Math.cos(fi) * x - Math.sin(fi) * z, y,
                           Math.sin(fi) * x + Math.cos(fi) * z);
    }

    rotateX(fi) {
        var x = this[0], y = this[1], z = this[2];
        return new Vector(x, Math.cos(fi) * y + Math.sin(fi) * z,
                             Math.cos(fi) * z - Math.sin(fi) * y);
    }

    scalar(obser) {
        return (obser[0] * this[0] + obser[1] * this[1] + obser[2] * this[2]);
    }
}