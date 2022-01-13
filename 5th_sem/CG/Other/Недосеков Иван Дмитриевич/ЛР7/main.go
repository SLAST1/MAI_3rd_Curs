package main

import (
	"log"

	"fmt"

	g "github.com/AllenDang/giu"
	math "github.com/chewxy/math32"
	"github.com/go-gl/mathgl/mgl32"
)

var (
	count_dots  = 100
	N           []func(float32) float32
	r_vec       func(z float32) mgl32.Vec2
	l, r        float32
	nodes       []mgl32.Vec2
	linedata    []float64
	n_lines     [][]float32
	kek_lines   [][]float64
	n_plots     []g.PlotWidget
	dot_sliders []g.Widget
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

func format_r(node []mgl32.Vec2) func(z float32) mgl32.Vec2 {

	res_f := func(z float32) mgl32.Vec2 {
		var res mgl32.Vec2
		for i, ri := range node {
			j := i
			tmp_ri := ri
			res = res.Add(tmp_ri.Mul(N[j](z)))
		}
		return res
	}

	return res_f

}

func calculate_line(l, r float32, f func(float32) mgl32.Vec2) []mgl32.Vec2 {
	res := make([]mgl32.Vec2, count_dots)
	for i := range res {
		t := (r - l) * float32(i) / float32(count_dots)
		res[i] = f(t)
	}
	return res
}

func kekw(a []mgl32.Vec2) []float64 {
	res := make([]float64, len(a))
	for i, el := range a {
		res[i] = float64(el.Y())
	}
	return res
}

func calculateNLines() [][]float32 {
	res := make([][]float32, len(N))
	for j := range N {
		res[j] = make([]float32, count_dots)
	}
	for i := range res[0] {
		t := (r - l) * float32(i) / float32(count_dots)
		for j, f := range N {
			res[j][i] = f(t)

		}
	}
	return res
}

func init() {
	nodes = []mgl32.Vec2{
		{0, 1},
		{0, -1},
		{0, 1},
		{0, -1},
		{0, 1},
		{0, -1},
		{0, 1},
	}
	l, r, N = calculate_N(6, 3)
	r_vec = format_r(nodes)
	linedata = kekw(calculate_line(l, r, r_vec))
	n_lines = calculateNLines()
}

func loop() {
	dot_sliders = make([]g.Widget, len(nodes))
	for i := range nodes {
		dot_sliders[i] = g.SliderFloat(
			fmt.Sprintf("node %d", i),
			&nodes[i][1],
			-10,
			10,
		)

	}
	linedata = kekw(calculate_line(l, r, r_vec))
	dotsX := make([]float64, len(nodes))
	dotsy := make([]float64, len(nodes))

	for i, n := range nodes {
		dotsX[i] = float64(n.X())
		dotsy[i] = float64(n.Y())
	}
	g.SingleWindow().Layout(
		g.Plot("β-spline η = 6, K = 3, σ = (z - τ)ⁿ  ☠ ").AxisLimits(-0.5, 5.5, -10, 10, g.ConditionOnce).Plots(
			g.PlotLine("spline", linedata).XScale(float64(r-l)/100),
			g.PlotScatterXY("Nodes", dotsX, dotsy),
		),

		g.Plot("☭ ℕ basis").AxisLimits(-0.5, 5.5, -10, 10, g.ConditionOnce).Plots(n_plots...),
		dot_sliders[0],
		dot_sliders[1],
		dot_sliders[2],
		dot_sliders[3],
		dot_sliders[4],
		dot_sliders[5],
		dot_sliders[6],
	)
}

func main() {
	kek_lines = make([][]float64, len(N))
	for i := range kek_lines {
		kek_lines[i] = make([]float64, count_dots)
	}
	for i := range nodes {
		nodes[i][0] = float32(i) / float32(len(nodes)) * (r - l)
	}
	for i, line := range n_lines {
		for j, el := range line {
			kek_lines[i][j] = float64(el)
		}
		n_plots = append(n_plots, g.PlotLine(fmt.Sprintf("N³[%d]", i), kek_lines[i]).XScale(float64(r-l)/100))
	}

	wnd := g.NewMasterWindow("Lab 7 Nedosekov ©", 1000, 800, 0)
	wnd.Run(loop)
}
