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
	ccount_on_circle int32 = 4
	count_circle     int32 = 20
	top                    = DotRGB{mgl32.Vec3{0, 0, R}, red}
	down                   = DotRGB{mgl32.Vec3{0, 0, -R}, red}
)

func r_sphere_cut_by_z(z float64) float64 {

	return math.Pow(math.Pow(R, 3)-math.Pow(z, 3), 1./3)
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

type NDOT struct {
	DotRGB,
	p float32
}

type Triangle struct {
	A, B, C DotRGB
}

func find_triangels(circle3D [][]DotRGB, top, down DotRGB) []Triangle {
	var res []Triangle
	count_on_circle := int(ccount_on_circle)

	for i := 0; i < count_on_circle; i++ {
		res = append(res, Triangle{circle3D[0][i], down, circle3D[0][(i+1)%count_on_circle]})
	}

	for i := 0; i < count_on_circle; i++ {
		res = append(res, Triangle{circle3D[len(circle3D)-1][i], circle3D[len(circle3D)-1][(i+1)%count_on_circle], top})
	}

	for j := 0; j < len(circle3D)-1; j++ {
		tops := circle3D[j+1]
		downs := circle3D[j]
		for i := 0; i < count_on_circle; i++ {
			res = append(res, Triangle{downs[i], downs[(i+1)%count_on_circle], tops[i]})
		}
		// tops, downs = downs, tops
		for i := 0; i < count_on_circle; i++ {
			res = append(res, Triangle{downs[(i+1)%count_on_circle], tops[(i+1)%count_on_circle], tops[i]})
		}

	}
	return res

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
	log.Default().Print("z", z, "aaaaa", len(z))

	angel := (2 * math.Pi / float32(ccount_on_circle)) / 2
	for i := 2; i < ount_circle; i += 2 {
		circle_rotate(circles[i], angel)
	}
	log.Default().Print(circles[0])
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

	triang := find_triangels(circle3D, top, down)
	var res []float32
	for i, tr := range triang {
		log.Default().Print("Triangle", i, tr)
		res = append(res, tr.A.d[:]...)
		res = append(res, tr.A.c[:]...)

		res = append(res, tr.B.d[:]...)
		res = append(res, tr.B.c[:]...)

		res = append(res, tr.C.d[:]...)
		res = append(res, tr.C.c[:]...)

	}
	log.Default().Print(res[0:19])
	return res
}
