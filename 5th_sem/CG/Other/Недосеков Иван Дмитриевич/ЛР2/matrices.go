// writed by Ivan Nedosekov
package main

import (
	"errors"
	"log"
	"math"
)

func multiplayMatr(a, b [][]float64) ([][]float64, error) {
	if len(a[0]) != len(b) {
		return nil, errors.New("not multiplicatable martcies")
	}
	res := make([][]float64, len(a))
	for i := 0; i < len(a); i++ {
		res[i] = make([]float64, len(b[0]))
		for j := 0; j < len(b); j++ {
			for r := 0; r < len(a[0]); r++ {
				res[i][j] += a[i][r] * b[r][j]
			}
		}
	}
	return res, nil

}

const alpha = math.Pi / 6

var rotateUp = [][]float64{
	{1, 0, 0},
	{0, math.Cos(alpha), -math.Sin(alpha)},
	{0, math.Sin(alpha), math.Cos(alpha)}}

var rotateDown = [][]float64{
	{1, 0, 0},
	{0, math.Cos(-alpha), -math.Sin(-alpha)},
	{0, math.Sin(-alpha), math.Cos(-alpha)}}

var rotateLeft = [][]float64{
	{math.Cos(alpha), -math.Sin(alpha), 0},
	{math.Sin(alpha), math.Cos(alpha), 0},
	{0, 0, 1}}

var rotateRight = [][]float64{
	{math.Cos(-alpha), -math.Sin(-alpha), 0},
	{math.Sin(-alpha), math.Cos(-alpha), 0},
	{0, 0, 1}}

func is_inner_dot(A, B, C, D float64, p Point) bool {
	return A*p.x+B*p.y+C*p.z+D >= 0
}
func findPlane(a, b Edge, innerPoint Point) (A, B, C, D float64) {

	p := []Point{a.u, a.v, b.v}
	log.Println("find plane to points", p)

	det := [3][3]float64{
		{},
		{p[1].x - p[0].x, p[1].y - p[0].y, p[1].z - p[0].z},
		{p[2].x - p[0].x, p[2].y - p[0].y, p[2].z - p[0].z}}

	det1 := det[1][1]*det[2][2] - (det[1][2] * det[2][1])
	det2 := det[1][0]*det[2][2] - (det[1][2] * det[2][0])
	det3 := det[1][0]*det[2][1] - (det[1][1] * det[2][0])

	// log.Printf("de1 %f\n det2 %f\n det3 %f\n", det1, det2, det3)

	A = det1
	D = -p[0].x * det1
	B = -det2
	D -= -p[0].y * det2
	C = det3
	D += -p[0].z * det3
	log.Println("Finded coefs", A, B, C, D)
	if is_inner_dot(A, B, C, D, innerPoint) {
		log.Print("Calculated positive normal to dot")
		return A, B, C, D
	} else {
		log.Print("Calculated negative normal to dot")
		return -A, -B, -C, -D
	}
}

type Vector struct{ i, j, k float64 }

func dotProduct(a, b Vector) float64 {
	res := a.i*b.i + a.j*b.j + a.k*b.k
	log.Println("Product of", a, b, "is", res)
	return res
}

func is_visible(A, B, C, D float64, innerPoint, cameraPoint Point) bool {
	N := Vector{A, B, C}
	Cam := Vector{innerPoint.x - cameraPoint.x, innerPoint.y - cameraPoint.y, innerPoint.z - cameraPoint.z}
	log.Println("Checking visible N", N, "Cam", Cam, "camPoint", cameraPoint, "inner", innerPoint, "D", D)
	return dotProduct(N, Cam) > 0
}

func getInnerPoint(figure [][]float64) Point {
	var res Point
	for _, point := range figure {
		res.x += point[0]
		res.y += point[1]
		res.z += point[2]
	}
	count := float64(len(figure))
	res.x, res.y, res.z = res.x/count, res.y/count, res.z/count
	return res
}
