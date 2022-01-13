//
// Yury Loshmanov
// 306
//

#pragma once

#include <iostream>
#include <array>
#include <initializer_list>
#include <cmath>

namespace mm {

    const double pi = 3.14159265358979f;

    const double comparePrecision = 1e-10f;

    typedef size_t length_t;
    typedef size_t pos_t;

    template<typename T, length_t L>
    class vec;

    template<typename T, length_t L>
    class mat;


    double radians(double degrees);


    template <typename T, length_t L>
    mat<T, L> translate(const mat<T, L> &identityMatrix, const vec<T, L-1> &translationVector);


    template <typename T, length_t L>
    mat<T, L> scale(const mat<T, L> &identityMatrix, const vec<T, L-1> &scalingVector);


    template <typename T>
    mat<T, 4> rotate(const mat<T, 4> &identityMatrix, T angle, const vec<T, 3> &R);

    mat<double, 4> makeOrthoMatrix(double l, double r, double b, double t, double n, double f);


    mat<double, 4> makePerspectiveMatrix(double l, double r, double b, double t, double n, double f);

    mat<double, 4> ortho(double left, double right, double bottom, double top, double front, double back);


    mat<double, 4> perspective(double fovY, double aspectRatio, double front, double back);


    template <typename T, length_t L>
    T cosBetween(const vec<T, L> &v1, const vec<T, L> &v2);

    template <typename T, length_t L>
    T dotProduct(const vec<T, L> &v1, const vec<T, L> &v2);

    template <typename T>
    vec<T, 3> crossProduct(const vec<T, 3> &v1, const vec<T, 3> &v2);

    template <typename T, length_t L>
    bool isPerpendicular(const vec<T, L> &v1, const vec<T, L> &v2);

    bool floatEqual(double f1, double f2);


    template <typename T, length_t L>
    vec<T, L> reflect(const vec<T, L> &v1, const vec<T, L> &v2);


    typedef vec<double, 2> vec2;
    typedef vec<double, 3> vec3;
    typedef vec<double, 4> vec4;

    typedef mat<double, 2> mat2;
    typedef mat<double, 3> mat3;
    typedef mat<double, 4> mat4;

} // namespace mm

#include "matrices.inl"