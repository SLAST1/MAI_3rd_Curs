package main

import (
	"fmt"
	"github.com/go-gl/gl/v3.3-core/gl"
	"strings"
)

const (
	shader1 = `
	#version 330 core

	uniform vec3 lightPos;
	
	in vec4 vColor;
	in vec3 vertPos;
	in vec3 Normal;
	in vec3 FragPos;

	uniform float ambientStrenth;
	out vec4 FragColor;
	vec3 lightColor = vec3(1.0,1.0,1.0);

	void main() {
		vec3 norm = normalize(Normal);
		vec3 lightDir = normalize(lightPos - FragPos);
		// vec3 lightDir = normalize(FragPos - lightPos);
		float diff = max(dot(norm, lightDir), 0.0);
		vec3 diffuse = diff * lightColor;

		// float ambientStrenth = 0.1f;
		vec3 ambient = ambientStrenth * lightColor;
		vec3 light = ambient + diffuse;
		FragColor = vec4(light, 1.0f) * vColor;
	}` + "\x00"

	// shader2 = `
	// #version 330 core

	// void main(){
	// 	float ambientStrenth = 0.1f;
	// 	vec3 ambient = ambientStrenth * lightColor;

	// 	vec3 res = ambient * objectColor;
	// 	color = vec4(res, 0.1f);
	// }
	// ` + "\x00"

	vertex_shader = `
	#version 330 core

	uniform vec2 resolution;
	uniform mat4 model;
	uniform mat4 view;
	uniform mat4 projection;

	layout (location = 0) in vec3 aPos;
	layout (location = 1) in vec3 aColor;
	layout (location = 2) in vec3 normal;

	out vec4 vColor;
	out vec3 Normal;
	out vec3 FragPos;

	void main() {
		vColor = vec4(aColor, 1.0f);
		Normal = normal;
		gl_Position = projection * view * model * vec4(aPos, 1.0);
		FragPos = vec3(model * vec4(aPos, 1.0));
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
