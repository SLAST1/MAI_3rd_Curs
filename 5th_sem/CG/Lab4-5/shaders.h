#pragma once
#include <iostream>
#include <GL/glew.h>
#include <string>
#include <fstream>
#include <cstring>

class Shader{
    GLchar *vertexShaderCode, *fragmentShaderCode;
    GLuint vertS, fragS;
    void LoadCodes();
    void VertexShader();
    void FragmentShader();
    void CreateShaderProgram();

    public:
        GLuint shaderProgram;
        Shader();
        void Use();
};