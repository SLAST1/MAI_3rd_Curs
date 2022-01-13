package main

import (
	"math"
	"runtime"

	"github.com/AllenDang/giu"

	"github.com/go-gl/gl/v3.3-core/gl"
	"github.com/go-gl/mathgl/mgl32"
)

const (
	width          = 700
	height         = 700
	aspect float32 = float32(width) / height
)

var (
	transform = mgl32.Mat4{
		1, 0, 0, 0,
		0, 1, 0, 0,
		0, 0, 1, 0,
		0, 0, 0, 1,
	}

	al float32 = 0.5

	shaders      []uint32
	view_matr            = mgl32.LookAt(0, 0, -3, 0, 0, 0, 0, 1, 0)
	orto                 = mgl32.Ortho(-1, 1, -1*aspect, 1*aspect, 0.1, 100)
	lightPos             = mgl32.Vec3{0, 0, -3}
	lightForce   float32 = 0.3
	to_up                = mgl32.Rotate3DX(math.Pi / 6)
	to_down              = mgl32.Rotate3DX(math.Pi / 6)
	to_right             = mgl32.Rotate3DY(-math.Pi / 6)
	to_left              = mgl32.Rotate3DY(math.Pi / 6)
	by_clock             = mgl32.Rotate3DZ(-math.Pi / 6)
	by_neg_clock         = mgl32.Rotate3DZ(math.Pi / 6)

	vertex_circles []float32
	vertex_down    []float32
	vertex_up      []float32

	vao_down, vao_center, vao_top, program uint32
)

func init() {
	runtime.LockOSThread()
	if err := gl.Init(); err != nil {
		panic(err)
	}
	calculate_points()
}

// initOpenGL initializes OpenGL and returns an intiialized program.
func initOpenGL() uint32 {

	vertexShader, err := compileShader(vertex_shader, gl.VERTEX_SHADER)
	if err != nil {
		panic(err)
	}
	fragment1, err := compileShader(shader1, gl.FRAGMENT_SHADER)
	if err != nil {
		panic(err)
	}

	shaders = []uint32{vertexShader, fragment1}

	prog := gl.CreateProgram()
	gl.AttachShader(prog, vertexShader)
	gl.AttachShader(prog, fragment1)
	gl.LinkProgram(prog)
	return prog
}

func main() {

	window := giu.NewMasterWindow("lab6 Nedosekov", width, height, 0)
	register_key_callbacks(window)

	gl.Disable(gl.CULL_FACE)
	gl.Enable(gl.BLEND)
	gl.BlendFunc(1, 1)
	program = initOpenGL()

	_, vao_top, _, vao_center, _, vao_down = makeVao()

	window.Run(draw)

}

// makeVao initializes and returns a vertex array from the points provided.
func makeVao() (uint32, uint32, uint32, uint32, uint32, uint32) {
	var vao_top uint32
	gl.GenVertexArrays(1, &vao_top)
	gl.BindVertexArray(vao_top)

	var vbo_top uint32
	gl.GenBuffers(1, &vbo_top)
	gl.BindBuffer(gl.ARRAY_BUFFER, vbo_top)
	gl.BufferData(gl.ARRAY_BUFFER, 4*len(vertex_up), gl.Ptr(vertex_up), gl.STATIC_DRAW)

	gl.VertexAttribPointer(0, 3, gl.FLOAT, false, 9*4, gl.PtrOffset(0))
	gl.EnableVertexAttribArray(0)
	gl.VertexAttribPointer(1, 3, gl.FLOAT, false, 9*4, gl.PtrOffset(4*3))
	gl.VertexAttribPointer(2, 3, gl.FLOAT, false, 9*4, gl.PtrOffset(4*6))
	gl.EnableVertexAttribArray(1)

	gl.BindVertexArray(0)
	gl.BindBuffer(gl.ARRAY_BUFFER, 0)

	var vao_center uint32
	gl.GenVertexArrays(1, &vao_center)
	gl.BindVertexArray(vao_center)

	var vbo_center uint32
	gl.GenBuffers(1, &vbo_center)
	gl.BindBuffer(gl.ARRAY_BUFFER, vbo_center)
	gl.BufferData(gl.ARRAY_BUFFER, 4*len(vertex_circles), gl.Ptr(vertex_circles), gl.STATIC_DRAW)

	gl.VertexAttribPointer(0, 3, gl.FLOAT, false, 9*4, gl.PtrOffset(0))
	gl.EnableVertexAttribArray(0)
	gl.VertexAttribPointer(1, 3, gl.FLOAT, false, 9*4, gl.PtrOffset(4*3))
	gl.VertexAttribPointer(2, 3, gl.FLOAT, false, 9*4, gl.PtrOffset(4*6))
	gl.EnableVertexAttribArray(1)

	gl.BindVertexArray(0)
	gl.BindBuffer(gl.ARRAY_BUFFER, 0)

	var vao_down uint32
	gl.GenVertexArrays(1, &vao_down)
	gl.BindVertexArray(vao_down)

	var vbo_down uint32
	gl.GenBuffers(1, &vbo_down)
	gl.BindBuffer(gl.ARRAY_BUFFER, vbo_down)
	gl.BufferData(gl.ARRAY_BUFFER, 4*len(vertex_down), gl.Ptr(vertex_down), gl.STATIC_DRAW)

	gl.VertexAttribPointer(0, 3, gl.FLOAT, false, 9*4, gl.PtrOffset(0))
	gl.EnableVertexAttribArray(0)
	gl.VertexAttribPointer(1, 3, gl.FLOAT, false, 9*4, gl.PtrOffset(4*3))
	gl.VertexAttribPointer(2, 3, gl.FLOAT, false, 9*4, gl.PtrOffset(4*6))

	gl.EnableVertexAttribArray(1)

	gl.BindVertexArray(0)
	gl.BindBuffer(gl.ARRAY_BUFFER, 0)

	return vbo_top, vao_top, vbo_center, vao_center, vbo_down, vao_down
}

func count_points(m []float32) int32 {
	return int32(len(m) / (3 * 3))
}

func draw() {

	// rendedr_imgui()

	gl.ClearColor(0.2, 0.2, 0.2, 0.2)
	gl.Clear(gl.COLOR_BUFFER_BIT)
	var res, model, view, proj, lpos, lf, a int32
	res = gl.GetUniformLocation(program, gl.Str("resolution\x00"))
	model = gl.GetUniformLocation(program, gl.Str("model\x00"))
	view = gl.GetUniformLocation(program, gl.Str("view\x00"))
	proj = gl.GetUniformLocation(program, gl.Str("projection\x00"))
	lpos = gl.GetUniformLocation(program, gl.Str("lightPos\x00"))
	lf = gl.GetUniformLocation(program, gl.Str("ambientStrenth\x00"))
	a = gl.GetUniformLocation(program, gl.Str("al\x00"))

	gl.UseProgram(program)
	gl.Uniform2f(res, width, height)
	gl.UniformMatrix4fv(model, 1, false, &transform[0])
	gl.UniformMatrix4fv(view, 1, false, &view_matr[0])
	gl.UniformMatrix4fv(proj, 1, false, &orto[0])
	gl.Uniform3f(lpos, lightPos[0], lightPos[1], lightPos[2])
	gl.Uniform1f(lf, lightForce)
	gl.Uniform1f(a, al)

	gl.BindVertexArray(vao_top)

	gl.DrawArrays(gl.TRIANGLES, 0, count_points(vertex_up))

	gl.BindVertexArray(vao_down)
	gl.DrawArrays(gl.TRIANGLES, 0, count_points(vertex_down))

	gl.BindVertexArray(vao_center)
	gl.DrawArrays(gl.TRIANGLES, 0, count_points(vertex_circles))
	win := giu.Window("settings")
	win.Layout(
		giu.SliderInt("Count circles", &count_circle, 5, 150),
		giu.SliderInt("coun on circle", &ccount_on_circle, 3, 100),
		//giu.SliderFloat("light", &lightForce, 0, 1),
		//giu.SliderFloat("alpha", &al, 0, 1),
		giu.SliderFloat("pos x", &lightPos[0], -10, 10),
		giu.SliderFloat("pos y", &lightPos[1], -10, 10),
		giu.SliderFloat("pos z", &lightPos[2], -10, 10),
		giu.SliderFloat("R", &R, 0, 10),
	)
	calculate_points()
	_, vao_top, _, vao_center, _, vao_down = makeVao()

}

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
