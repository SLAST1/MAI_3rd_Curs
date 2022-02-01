#version 330 core
layout (location=0) in vec3 position;
layout (location=1) in vec3 norms;

uniform mat4 transform;
uniform mat4 projection;
out vec3 Normals;
out vec3 pointPos;

void main(){
    gl_Position = projection * transform * vec4(position, 1.0f);
    pointPos = vec3(transform*vec4(position, 1.0f));
    Normals = normalize(mat3(transpose(inverse(transform)))*norms);
}