#include "shaders.h"

Shader::Shader(){
    LoadCodes();
    GLint success;
    GLchar infoLog[512];
    VertexShader();    
    glGetShaderiv(vertS, GL_COMPILE_STATUS, &success);
    if(!success){
        glGetShaderInfoLog(vertS, 512, NULL, infoLog);
        std::cout << "ERROR::SHADER::VERTEX::COMPILATION_FAILED\n" << infoLog << std::endl;
    };

    FragmentShader();
    glGetShaderiv(fragS, GL_COMPILE_STATUS, &success);
    if(!success){
        glGetShaderInfoLog(fragS, 512, NULL, infoLog);
        std::cout << "ERROR::SHADER::FRAGMENTS::COMPILATION_FAILED\n" << infoLog << std::endl;
    };
    
    CreateShaderProgram();
    glGetProgramiv(shaderProgram, GL_LINK_STATUS, &success);
    if(!success){
        glGetProgramInfoLog(shaderProgram, 512, NULL, infoLog);
        std::cout << "ERROR::SHADER::PROGRAM::LINKING_FAILED\n" << infoLog << std::endl;
    }

    glDeleteShader(vertS);
    glDeleteShader(fragS);
}

void Shader::Use(){
    glUseProgram(shaderProgram);
}

void Shader::LoadCodes(){
    std::string shaderText, buff;
    std::ifstream fin("shaders/vertShader.vert");
    if(!fin.is_open()){
        std::cout << "ERROR: Can't open vertex shader text file" << std::endl;
        return;
    }

    while(std::getline(fin, buff)){
        shaderText.append('\n' + buff);
    }
    shaderText.append("\n\0");
    fin.close();

    vertexShaderCode = new char[shaderText.size()+1];
    memcpy(vertexShaderCode, shaderText.data(), (shaderText.size()+1)*sizeof(char));

    shaderText.clear();
    fin.open("shaders/fragShader.frag");
    if(!fin.is_open()){
        std::cout << "ERROR: Can't open fragment shader text file" << std::endl;
        return;
    }

    while(std::getline(fin, buff)){
        shaderText.append('\n' + buff);
    }
    shaderText.append("\n\0");
    fin.close();
    fragmentShaderCode = new char[shaderText.size()+1];
    memcpy(fragmentShaderCode, shaderText.data(), (shaderText.size()+1)*sizeof(char));
}

void Shader::VertexShader(){
    vertS = glCreateShader(GL_VERTEX_SHADER);
    glShaderSource(vertS, 1, &vertexShaderCode, NULL);
    glCompileShader(vertS);
}

void Shader::FragmentShader(){
    fragS = glCreateShader(GL_FRAGMENT_SHADER);
    glShaderSource(fragS, 1, &fragmentShaderCode, NULL);
    glCompileShader(fragS);
}

void Shader::CreateShaderProgram(){
    shaderProgram = glCreateProgram();
    glAttachShader(shaderProgram, vertS);
    glAttachShader(shaderProgram, fragS);
    glLinkProgram(shaderProgram);
}