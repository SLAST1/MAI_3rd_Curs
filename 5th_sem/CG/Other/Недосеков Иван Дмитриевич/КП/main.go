package main

import (
	"log"

	"fmt"

	"runtime"

	g "github.com/AllenDang/giu"
	math "github.com/chewxy/math32"
	"github.com/go-gl/gl/v3.3-core/gl"
	mgl "github.com/go-gl/mathgl/mgl32"
)

var (
	count_dots  int32 = 10
	N           []func(float32) float32
	r_vec       func(z float32) mgl.Vec2
	l, r        float32
	nodes       []mgl.Vec2
	dot_sliders []g.Widget
	count_rot   int32 = 12

	mesh [][]mgl.Vec3
)

func FindMinMax(t []float32) (min_el, max_el float32) {
	if len(t) == 0 {
		log.Default().Print("Error zerro leght FindMinMax")
	}
	for _, el := range t {
		min_el = math.Min(el, min_el)
		max_el = math.Max(el, max_el)
	}
	return
}

func divided_difference(f func(float32) func(float32) float32, t ...float32) func(float32) float32 {

	if len(t) == 2 {

		res := func(z float32) float32 {
			if t[1]-t[0] == 0 {
				return 0
			}
			return (f(t[1])(z) - f(t[0])(z)) / (t[1] - t[0])

		}
		return res
	} else if len(t) < 2 {
		log.Fatal("len < 2")
	}
	n := len(t) - 1
	d1 := divided_difference(f, t[1:n]...)
	d2 := divided_difference(f, t[0:n-1]...)

	return func(z float32) float32 {
		return (d1(z) - d2(z)) / (t[n] - t[0])
	}
}

func truncated_power_function(n int, t float32) func(float32) float32 {
	n_float := float32(n)
	return func(z float32) float32 {
		if z <= t {
			return 0.
		}

		return math.Pow((z - t), n_float)
	}

}

func truncated_power_function_fixed_n(n int) func(float32) func(float32) float32 {

	return func(t float32) func(float32) float32 {
		return truncated_power_function(n, t)
	}
}

func calculate_N(n, k int) (float32, float32, []func(float32) float32) {

	t_max := n - k + 2
	var t []float32
	N := make([]func(float32) float32, n+1)

	for i := 1; i < k; i++ {
		t = append(t, 0)
	}

	for i := 0; i <= t_max; i++ {
		t = append(t, float32(i))
	}

	for i := 1; i < k; i++ {
		t = append(t, float32(t_max))
	}
	sigma := truncated_power_function_fixed_n(k - 1)
	norm := float32(t_max - 0)
	for i := range N {
		tmp_i := i
		d := divided_difference(sigma, t[tmp_i:tmp_i+k+1]...)
		N[i] = func(z float32) float32 {
			return norm * d(z)
		}
	}

	return 0, float32(t_max), N

}

func format_r(node []mgl.Vec2) func(z float32) mgl.Vec2 {

	res_f := func(z float32) mgl.Vec2 {
		res := mgl.Vec2{z, 0}
		for i, ri := range node {
			j := i
			tmp_ri := ri
			res = res.Add(tmp_ri.Mul(N[j](z)))
		}
		return res
	}

	return res_f

}

func calculate_line(l, r float32, f func(float32) mgl.Vec2) []mgl.Vec2 {
	res := make([]mgl.Vec2, count_dots)
	for i := range res {
		t := (r - l) * float32(i) / float32(count_dots)
		res[i] = f(t)
	}
	return res

}

func init() {
	nodes = []mgl.Vec2{
		{0, 1},
		{0, -1},
		{0, 1},
		{0, -1},
		{0, 1},
		{0, -1},
		{0, 1},
	}
	runtime.LockOSThread()
	if err := gl.Init(); err != nil {
		panic(err)
	}

}

func to_vec3(v []mgl.Vec2) []mgl.Vec3 {
	res := make([]mgl.Vec3, len(v))

	for i, el := range v {
		res[i] = el.Vec3(0)
	}

	return res

}

func rotate(v []mgl.Vec3) [][]mgl.Vec3 {

	res := make([][]mgl.Vec3, count_rot)
	for i := int32(0); i < count_rot; i++ {
		anggel := float32(i) / float32(count_rot) * 2 * math.Pi
		res[i] = make([]mgl.Vec3, len(v))
		rotate := mgl.Rotate3DY(anggel)
		for j, el := range v {

			res[i][j] = rotate.Mul3x1(el)
		}
	}
	return res
}

func makeVao() (uint32, uint32) {
	var vao_top uint32
	gl.GenVertexArrays(1, &vao_top)
	gl.BindVertexArray(vao_top)

	var vbo_top uint32
	gl.GenBuffers(1, &vbo_top)
	gl.BindBuffer(gl.ARRAY_BUFFER, vbo_top)
	gl.BufferData(gl.ARRAY_BUFFER, 4*len(vertex_v), gl.Ptr(vertex_v), gl.STATIC_DRAW)

	gl.VertexAttribPointer(0, 3, gl.FLOAT, false, 3*4, gl.PtrOffset(0))
	gl.EnableVertexAttribArray(0)
	gl.BindBuffer(gl.ARRAY_BUFFER, 0)

	return vbo_top, vao_top
}

func add_point(res []float32, e mgl.Vec3) []float32 {
	res = append(res, e.X()/26, e.Y()/26, e.Z()/26)
	return res
}

func mess_to_vec(m [][]mgl.Vec3) []float32 {
	var res []float32
	for _, el := range m {
		for i, e := range el[:len(el)-1] {
			res = add_point(res, e)
			res = add_point(res, el[i+1])
		}
	}
	for i := range m[0] {
		for j := 0; j < len(m); j++ {
			res = add_point(res, m[j][i])
			res = add_point(res, m[(j+1)%len(m)][i])
		}
	}
	log.Print("rec")

	return res
}

func main() {

	dot_sliders = make([]g.Widget, 7)
	for i := range nodes {
		dot_sliders[i] = g.SliderFloat(
			fmt.Sprintf("node %d", i),
			&nodes[i][1],
			-10,
			10,
		)

	}
	wnd := g.NewMasterWindow("KP Nedosekov ©", 1000, 800, 0)
	l, r, N = calculate_N(6, 3)
	r_vec = format_r(nodes)
	mesh = rotate(to_vec3(calculate_line(l, r, r_vec)))

	vertex_v = mess_to_vec(mesh)
	program = initOpenGL()
	log.Print(vertex_v)
	_, vertex = makeVao()

	register_key_callbacks(wnd)
	wnd.Run(draw)
}
