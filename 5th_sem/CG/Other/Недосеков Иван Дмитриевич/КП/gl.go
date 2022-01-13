package main

import (
	"github.com/AllenDang/giu"
	m "github.com/chewxy/math32"
	"github.com/go-gl/gl/v3.3-core/gl"
	mgl "github.com/go-gl/mathgl/mgl32"
)

const (
	width          = 700
	height         = 700
	aspect float32 = float32(width) / height
)

var (
	vertex_v  []float32
	transform = mgl.Mat4{
		1, 0, 0, 0,
		0, 1, 0, 0,
		0, 0, 1, 0,
		0, 0, 0, 1,
	}

	view_matr    = mgl.LookAt(0, 0, 7, 0, 0, 0, 0, 1, 0)
	orto         = mgl.Ortho(-1, 1, -1*aspect, 1*aspect, 0.1, 100)
	to_up        = mgl.Rotate3DX(m.Pi / 6)
	to_down      = mgl.Rotate3DX(m.Pi / 6)
	to_right     = mgl.Rotate3DY(-m.Pi / 6)
	to_left      = mgl.Rotate3DY(m.Pi / 6)
	by_clock     = mgl.Rotate3DZ(-m.Pi / 6)
	by_neg_clock = mgl.Rotate3DZ(m.Pi / 6)

	vertex uint32

	program uint32
)

func register_key_callbacks(window *giu.MasterWindow) {
	window.RegisterKeyboardShortcuts(
		giu.WindowShortcut{
			Key:      giu.KeyA,
			Modifier: giu.ModNone,
			Callback: func() {
				transform = transform.Mul4(to_right.Mat4())
			},
		},
	)
	window.RegisterKeyboardShortcuts(
		giu.WindowShortcut{
			Key:      giu.KeyD,
			Modifier: giu.ModNone,
			Callback: func() {
				transform = transform.Mul4(to_left.Mat4())
			},
		},
	)
	window.RegisterKeyboardShortcuts(
		giu.WindowShortcut{
			Key:      giu.KeyW,
			Modifier: giu.ModNone,
			Callback: func() {
				transform = transform.Mul4(to_up.Mat4())
			},
		},
	)
	window.RegisterKeyboardShortcuts(
		giu.WindowShortcut{
			Key:      giu.KeyS,
			Modifier: giu.ModNone,
			Callback: func() {
				transform = transform.Mul4(to_down.Mat4())
			},
		},
	)
	window.RegisterKeyboardShortcuts(
		giu.WindowShortcut{
			Key:      giu.KeyQ,
			Modifier: giu.ModNone,
			Callback: func() {
				transform = transform.Mul4(by_clock.Mat4())
			},
		},
	)
	window.RegisterKeyboardShortcuts(
		giu.WindowShortcut{
			Key:      giu.KeyE,
			Modifier: giu.ModNone,
			Callback: func() {
				transform = transform.Mul4(by_neg_clock.Mat4())
			},
		},
	)
}

func count_points(m []float32) int32 {
	return int32(len(m) / 3)
}

func draw() {

	gl.ClearColor(0.2, 0.2, 0.2, 0.2)
	gl.Clear(gl.COLOR_BUFFER_BIT)
	var model, view, proj int32
	model = gl.GetUniformLocation(program, gl.Str("model\x00"))
	view = gl.GetUniformLocation(program, gl.Str("view\x00"))
	proj = gl.GetUniformLocation(program, gl.Str("projection\x00"))

	gl.UseProgram(program)
	gl.UniformMatrix4fv(model, 1, false, &transform[0])
	gl.UniformMatrix4fv(view, 1, false, &view_matr[0])
	gl.UniformMatrix4fv(proj, 1, false, &orto[0])

	gl.BindVertexArray(vertex)

	gl.DrawArrays(gl.LINES, 0, count_points(vertex_v))

	win := giu.Window("settings")
	win.Layout(dot_sliders[0],
		dot_sliders[1],
		dot_sliders[2],
		dot_sliders[3],
		dot_sliders[4],
		dot_sliders[5],
		dot_sliders[6],
		giu.SliderInt("count_dots", &count_dots, 10, 300),
		giu.SliderInt("count rotetes", &count_rot, 12, 360),
	)
	mesh = rotate(to_vec3(calculate_line(l, r, r_vec)))
	vertex_v = mess_to_vec(mesh)
	_, vertex = makeVao()

}

func initOpenGL() uint32 {

	vertexShader, err := compileShader(vertex_shader, gl.VERTEX_SHADER)
	if err != nil {
		panic(err)
	}
	fragment1, err := compileShader(shader1, gl.FRAGMENT_SHADER)
	if err != nil {
		panic(err)
	}

	prog := gl.CreateProgram()
	gl.AttachShader(prog, vertexShader)
	gl.AttachShader(prog, fragment1)
	gl.LinkProgram(prog)
	return prog
}
