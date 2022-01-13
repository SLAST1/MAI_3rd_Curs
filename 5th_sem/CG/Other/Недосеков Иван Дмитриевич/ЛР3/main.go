package main

import (
	//"log"
	"math"
	"runtime"

	// "github.com/AllenDang/imgui-go"
	"github.com/go-gl/gl/v3.3-core/gl"
	"github.com/go-gl/glfw/v3.3/glfw"
	"github.com/go-gl/mathgl/mgl32"
	"github.com/inkyblackness/imgui-go/v4"
)

const (
	width          = 700
	height         = 700
	aspect float32 = float32(width) / height
)

var (
	vertex = []float32{
		-0.5, 0.0, 0.0, 1.0, 0.0, 0.0,
		0.5, 0.0, 0.0, 0.0, 1.0, 0.0,
		0.0, -0.5, 0.0, 0.0, 0.0, 1.0,
		0.0, 0.5, 0.0, 1.0, 1.0, 0.0,
		0.0, 0.0, -2.5, 1.0, 0.0, 1.0,
		0.0, 0.0, 2.5, 0.0, 1.0, 1.0,
	}

	indices = []uint32{
		0, 4, 2,
		0, 2, 5,
		0, 3, 4,
		0, 5, 3,
		1, 2, 4,
		1, 5, 2,
		1, 4, 3,
		1, 3, 5,
	}

	transform = mgl32.Mat4{
		1, 0, 0, 0,
		0, 1, 0, 0,
		0, 0, 1, 0,
		0, 0, 0, 1,
	}

	shaders   []uint32
	view_matr = mgl32.LookAt(0, 0, 1, 0, 0, 0, 0, 1, 0)
	orto      = mgl32.Ortho(-1, 1, -1*aspect, 1*aspect, 0.1, 100)

	to_up    = mgl32.Rotate3DY(math.Pi / 6)
	to_down  = mgl32.Rotate3DY(-math.Pi / 6)
	to_right = mgl32.Rotate3DZ(math.Pi / 6)
	to_left  = mgl32.Rotate3DY(-math.Pi / 6)
)

func init() {
	runtime.LockOSThread()
	if err := glfw.Init(); err != nil {
		panic(err)
	}
	if err := gl.Init(); err != nil {
		panic(err)
	}
	imgui.CreateContext(nil).SetCurrent()
	imgui.CurrentIO().SetDisplaySize(imgui.Vec2{width, height})
	imgui.CurrentIO().Fonts().Build()
	vertex = calculate_points()
	// version := gl.GoStr(gl.GetString(gl.VERSION))
	// log.Println("OpenGL version", version)
}

// initGlfw initializes glfw and returns a Window to use.
func initGlfw() *glfw.Window {

	glfw.WindowHint(glfw.Resizable, glfw.True)
	glfw.WindowHint(glfw.ContextVersionMajor, 4) // OR 2
	glfw.WindowHint(glfw.ContextVersionMinor, 1)
	glfw.WindowHint(glfw.OpenGLProfile, glfw.OpenGLCoreProfile)
	glfw.WindowHint(glfw.OpenGLForwardCompatible, glfw.True)

	window, err := glfw.CreateWindow(width, height, "Lab 3 Nedosekov Ivan", nil, nil)
	if err != nil {
		panic(err)
	}
	window.MakeContextCurrent()
	window.SetKeyCallback(key_callback)
	imgui.Version()
	imgui.CreateContext(nil)
	imgui.StyleColorsDark()

	return window
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
	fragment2, err := compileShader(shader2, gl.FRAGMENT_SHADER)
	if err != nil {
		panic(err)
	}

	shaders = []uint32{vertexShader, fragment1, fragment2}

	prog := gl.CreateProgram()
	gl.AttachShader(prog, vertexShader)
	gl.AttachShader(prog, fragment1)
	gl.LinkProgram(prog)
	return prog
}

func main() {
	window := initGlfw()
	defer glfw.Terminate()
	imgui.StyleColorsDark()

	tmp := mgl32.Rotate3DY(math.Pi / 2)
	tmp4 := tmp.Mat4()
	transform = transform.Mul4(tmp4)
	// tmp = mgl32.Rotate3DZ(math.Pi / 2)
	// tmp4 = tmp.Mat4()
	// transform = transform.Mul4(tmp4)
	gl.Enable(gl.CULL_FACE)
	gl.CullFace(gl.BACK)

	program := initOpenGL()

	_, vao, _ := makeVao()

	for !window.ShouldClose() {
		draw(vao, window, program)
	}
}

// makeVao initializes and returns a vertex array from the points provided.
func makeVao() (uint32, uint32, uint32) {
	var vao uint32
	gl.GenVertexArrays(1, &vao)
	gl.BindVertexArray(vao)

	var vbo uint32
	gl.GenBuffers(1, &vbo)
	gl.BindBuffer(gl.ARRAY_BUFFER, vbo)
	gl.BufferData(gl.ARRAY_BUFFER, 4*len(vertex), gl.Ptr(vertex), gl.STATIC_DRAW)

	var ebo uint32
	gl.GenBuffers(1, &ebo)
	gl.BindBuffer(gl.ELEMENT_ARRAY_BUFFER, ebo)
	gl.BufferData(gl.ELEMENT_ARRAY_BUFFER, 4*len(indices), gl.Ptr(indices), gl.STATIC_DRAW)

	gl.VertexAttribPointer(0, 3, gl.FLOAT, false, 6*4, gl.PtrOffset(0))
	gl.EnableVertexAttribArray(0)
	gl.VertexAttribPointer(1, 3, gl.FLOAT, false, 6*4, gl.PtrOffset(4*3))
	gl.EnableVertexAttribArray(1)

	gl.BindVertexArray(0)
	gl.BindBuffer(gl.ARRAY_BUFFER, 0)
	gl.BindBuffer(gl.ELEMENT_ARRAY_BUFFER, 0)
	return vbo, vao, ebo
}

func draw(vao uint32, window *glfw.Window, program uint32) {

	rendedr_imgui()
	gl.ClearColor(0.5, 0.5, 0.5, 1.0)
	gl.Clear(gl.COLOR_BUFFER_BIT)
	var res, model, view, proj int32
	res = gl.GetUniformLocation(program, gl.Str("resolution\x00"))
	model = gl.GetUniformLocation(program, gl.Str("model\x00"))
	view = gl.GetUniformLocation(program, gl.Str("view\x00"))
	proj = gl.GetUniformLocation(program, gl.Str("projection\x00"))

	gl.UseProgram(program)
	gl.Uniform2f(res, width, height)
	gl.UniformMatrix4fv(model, 1, false, &transform[0])
	gl.UniformMatrix4fv(view, 1, false, &view_matr[0])
	gl.UniformMatrix4fv(proj, 1, false, &orto[0])
	gl.BindVertexArray(vao)

	// gl.DrawElements(gl.TRIANGLES, int32(len(indices)), gl.UNSIGNED_INT, gl.PtrOffset(0))
	gl.DrawArrays(gl.TRIANGLES, 0, int32(len(vertex)))
	// gl.A

	glfw.PollEvents()
	window.SwapBuffers()
}

func rendedr_imgui() {
	imgui.NewFrame()
	imgui.BeginChild("sl")
	imgui.SliderInt("Круги", &count_circle, 3, 100)
	imgui.EndChild()
	imgui.Render()

}

func key_callback(w *glfw.Window, key glfw.Key, scancode int, action glfw.Action, mods glfw.ModifierKey) {
	rotate := mgl32.Rotate3DX(0)
	switch key {
	case glfw.KeyW:
		rotate = to_up
	case glfw.KeyS:
		rotate = to_down
	case glfw.KeyD:
		rotate = to_right
	case glfw.KeyA:
		rotate = to_left
	default:
		rotate = mgl32.Rotate3DX(0)
	}
	transform = rotate.Mat4().Mul4(transform)

}
