package main

import (
	"fmt"
	"github.com/go-gl/gl/v3.3-core/gl"
	"strings"
)

const (
	shader1 = `
	#version 330 core

	in vec4 vColor;
	in vec3 vertPos;
	out vec4 FragColor;

	void main() {
		FragColor = vColor;
	}` + "\x00"

	shader2 = `
	#version 330 core

	in vec4 vColor;
	in vec3 vertPos;
	out vec4 FragColor;

	void main() {
		switch (gl_PrimitiveID) {
		case 0:
			FragColor = vec4(1.0, 0.0, 0.0, 1.0);
			break;
		case 1:
			FragColor = vec4(0.0, 1.0, 0.0, 1.0);
			break;
		case 2:
			FragColor = vec4(0.0, 0.0, 1.0, 1.0);
			break;
		case 3:
			FragColor = vec4(1.0, 1.0, 0.0, 1.0);
			break;
		case 4:
			FragColor = vec4(1.0, 0.0, 1.0, 1.0);
			break;
		case 5:
			FragColor = vec4(0.0, 1.0, 1.0, 1.0);
			break;
		case 6:
			FragColor = vec4(1.0, 1.0, 1.0, 1.0);
			break;
		case 7:
			FragColor = vec4(0.0, 0.0, 0.0, 1.0);
			break;
		default:
			FragColor = vec4(0.5, 0.5, 0.5, 1.0);
		}
	}
	` + "\x00"

	vertex_shader = `
	#version 330 core

	uniform vec2 resolution;
	uniform mat4 model;
	uniform mat4 view;
	uniform mat4 projection;

	layout (location = 0) in vec3 aPos;
	layout (location = 1) in vec3 aColor;

	out vec4 vColor;

	void main() {
		vColor = vec4(aColor, 1.0f);
		gl_Position = projection * view * model * vec4(aPos, 1.0);
		// gl_Position = vec4(aPos, 1.0);
	}
	` + "\x00"
)

func compileShader(source string, shaderType uint32) (uint32, error) {
	shader := gl.CreateShader(shaderType)

	csources, free := gl.Strs(source)
	gl.ShaderSource(shader, 1, csources, nil)
	free()
	gl.CompileShader(shader)

	var status int32
	gl.GetShaderiv(shader, gl.COMPILE_STATUS, &status)
	if status == gl.FALSE {
		var logLength int32
		gl.GetShaderiv(shader, gl.INFO_LOG_LENGTH, &logLength)

		log := strings.Repeat("\x00", int(logLength+1))
		gl.GetShaderInfoLog(shader, logLength, nil, gl.Str(log))

		return 0, fmt.Errorf("failed to compile %v: %v", source, log)
	}

	return shader, nil
}

// vertexShaderSource = `
//     #version 410
//     in vec3 vp;
//     void main() {
//         gl_Position = vec4(vp, 1.0);
//     }
// ` + "\x00"

// fragmentShaderSource = `
//     #version 410
//     out vec4 frag_colour;
//     void main() {
//         frag_colour = vec4(1, 1, 1, 1);
//     }
// ` + "\x00"
