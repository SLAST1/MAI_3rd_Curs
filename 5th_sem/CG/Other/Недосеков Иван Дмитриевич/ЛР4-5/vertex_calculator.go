package main

import (
	"log"
	"math"

	"github.com/go-gl/mathgl/mgl32"
)

const (
	R = 0.5
)

var (
	red                    = mgl32.Vec3{1, 0, 0}
	green                  = mgl32.Vec3{0, 1, 0}
	blue                   = mgl32.Vec3{0, 0, 1}
	dark                   = mgl32.Vec3{0, 0, 0}
	ccount_on_circle int32 = 4
	count_circle     int32 = 20
	top                    = DotRGB{mgl32.Vec3{0, 0, R}, dark}
	down                   = DotRGB{mgl32.Vec3{0, 0, -R}, red}
)

func r_sphere_cut_by_z(z float64) float64 {

	return math.Pow(math.Pow(R, 2)-math.Pow(z, 2), 1./2)
}

func find_points_on_circle(tmp_r float32, count int) []mgl32.Vec2 {
	r := mgl32.Vec2{0, tmp_r}
	rotate := mgl32.Rotate2D(2 * math.Pi / float32(count))
	res := make([]mgl32.Vec2, count)
	for i := 0; i < count; i++ {
		res[i] = r
		r = rotate.Mul2x1(r)
	}
	return res
}

func circle_rotate(circle []mgl32.Vec2, angel float32) {
	rotate := mgl32.Rotate2D(angel)
	for i := 0; i < len(circle); i++ {
		circle[i] = rotate.Mul2x1(circle[i])
	}
}

type DotRGB struct {
	d, c mgl32.Vec3
}

type Triangle struct {
	A, B, C DotRGB
}

func find_triangels(circle3D [][]DotRGB, top, down DotRGB) []Triangle {
	var res []Triangle
	count_on_circle := int(ccount_on_circle)

	for i := 0; i < count_on_circle; i++ {
		res = append(res, Triangle{down, circle3D[0][i], circle3D[0][(i+1)%count_on_circle]})
	}

	for i := 0; i < count_on_circle; i++ {
		res = append(res, Triangle{circle3D[len(circle3D)-1][i], top, circle3D[len(circle3D)-1][(i+1)%count_on_circle]})
	}

	for j := 0; j < len(circle3D)-1; j++ {
		tops := circle3D[j+1]
		downs := circle3D[j]
		var shift int
		if j%2 == 0 {
			shift = 0
		} else {
			shift = 1
		}
		for i := 0; i < count_on_circle; i++ {
			if true {
				res = append(res, Triangle{downs[i], downs[(i+1)%count_on_circle], tops[(i+shift)%count_on_circle]})
			} else {
				res = append(res, Triangle{downs[i], tops[(i+shift)%count_on_circle], downs[(i+1)%count_on_circle]})
			}
		}
		shift = (shift + 1) % 2
		for i := 0; i < count_on_circle; i++ {
			if true {
				res = append(res, Triangle{tops[(i+1)%count_on_circle], downs[(i+shift)%count_on_circle], tops[i]})
			} else {
				res = append(res, Triangle{tops[(i+1)%count_on_circle], tops[i], downs[(i+shift)%count_on_circle]})
			}
		}

	}
	return res

}

func normal_of_triangl(A, B, C DotRGB) (N mgl32.Vec3) {
	X := B.d.Sub(A.d)
	Y := C.d.Sub(A.d)
	N = Y.Cross(X).Normalize()
	return
}

func append_dot(m []float32, dots ...DotRGB) []float32 {
	for _, dot := range dots {
		m = append(m, dot.d[:]...)
		m = append(m, dot.c[:]...)
	}
	return m
}

func find_new_triangl(circle3D [][]DotRGB, top, down DotRGB) {
	count_circle := int(ccount_on_circle)

	///////////////
	vertex_down = nil
	N := normal_of_triangl(down, circle3D[0][0], circle3D[0][1])

	for i := count_circle - 1; i >= 0; i-- {
		N = normal_of_triangl(down, circle3D[0][i], circle3D[0][(i+1)%count_circle])

		vertex_down = append_dot(vertex_down, down)
		vertex_down = append(vertex_down, N[:]...)
		vertex_down = append_dot(vertex_down, circle3D[0][i])
		vertex_down = append(vertex_down, N[:]...)
		vertex_down = append_dot(vertex_down, circle3D[0][(i+1)%count_circle])
		vertex_down = append(vertex_down, N[:]...)
	}
	vertex_down = append_dot(vertex_down, circle3D[0][0])
	N = normal_of_triangl(down, circle3D[0][0], circle3D[0][1])
	vertex_down = append(vertex_down, N[:]...)

	vertex_up = nil

	for i, _ := range circle3D[len(circle3D)-1] {
		N = normal_of_triangl(circle3D[len(circle3D)-1][i], top, circle3D[len(circle3D)-1][(i+1)%count_circle])
		vertex_up = append_dot(vertex_up, circle3D[len(circle3D)-1][i])
		vertex_up = append(vertex_up, N[:]...)
		vertex_up = append_dot(vertex_up, top)
		vertex_up = append(vertex_up, N[:]...)
		vertex_up = append_dot(vertex_up, circle3D[len(circle3D)-1][(i+1)%count_circle])
		vertex_up = append(vertex_up, N[:]...)

	}

	var shift int
	vertex_circles = make([]float32, 0)
	for i := 0; i < len(circle3D)-1; i++ {

		shift = 0

		for j, _ := range circle3D[i] {

			N = normal_of_triangl(circle3D[i][j], circle3D[i+1][(j+shift)%count_circle], circle3D[i][j])
			vertex_circles = append_dot(vertex_circles,
				circle3D[i][j],
			)
			vertex_circles = append(vertex_circles, N[:]...)
			vertex_circles = append_dot(vertex_circles,
				circle3D[i+1][(j+shift)%count_circle],
			)
			vertex_circles = append(vertex_circles, N[:]...)
			vertex_circles = append_dot(vertex_circles,
				circle3D[i+1][(j+shift+1)%count_circle],
			)
			vertex_circles = append(vertex_circles, N[:]...)

			N = normal_of_triangl(circle3D[i][j],
				circle3D[i+1][(j+shift+1)%count_circle],
				circle3D[i][(j+shift+1)%count_circle],
			)

			vertex_circles = append_dot(vertex_circles,
				circle3D[i][j],
			)
			vertex_circles = append(vertex_circles, N[:]...)
			vertex_circles = append_dot(vertex_circles,
				circle3D[i+1][(j+shift+1)%count_circle],
			)
			vertex_circles = append(vertex_circles, N[:]...)
			vertex_circles = append_dot(vertex_circles,
				circle3D[i][(j+shift+1)%count_circle],
			)
			vertex_circles = append(vertex_circles, N[:]...)

		}

	}

}

func calculate_points() []float32 {
	circles := make([][]mgl32.Vec2, count_circle)
	z := make([]float32, count_circle)
	count_on_circle := int(ccount_on_circle)
	ount_circle := int(count_circle)

	for i := 0; i < ount_circle; i++ {
		z[i] = R * float32(i) / float32(count_circle)
		tmp_r := float32(r_sphere_cut_by_z(float64(z[i])))
		log.Default().Print(R, i, count_circle)
		circles[i] = find_points_on_circle(tmp_r, count_on_circle)
	}

	circle3D := make([][]DotRGB, count_circle)
	var color mgl32.Vec3
	for i, c := range circles {
		circle3D[i] = make([]DotRGB, ccount_on_circle)
		for j, coord := range c {

			if i%2 == 1 {
				color = blue
			} else {
				color = green
			}
			circle3D[i][j] = DotRGB{mgl32.Vec3{coord.X(), coord.Y(), z[i]}, color}
		}
	}

	find_new_triangl(circle3D, top, down)
	return vertex_circles

}
