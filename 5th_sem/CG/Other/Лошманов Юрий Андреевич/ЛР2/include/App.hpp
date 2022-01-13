//
// Created by Yury Loshmanov on 30.09.2021.
// Group М8О-206Б-19
//

#ifndef LAB2_APP_HPP
#define LAB2_APP_HPP

#include <algorithm>
#include <iostream>
#include <fstream>
#include <sstream>
#include <string>
#include <vector>
#include <cstdio>

#include <glm/gtc/matrix_transform.hpp>
#include <glm/glm.hpp>

#include <GL/glew.h>

#include <GLFW/glfw3.h>


namespace kg {
    class App {
    public:
        static GLuint loadShaders(const std::string& vertexFilePath, const std::string& fragmentFilePath);
        void computeMatricesFromInputs();
        int run();

    protected:
        GLFWwindow *window;
        glm::mat4 viewMatrix;
        glm::mat4 projectionMatrix;

        glm::vec3 position = glm::vec3(0, 0, 5);
        float horizontalAngle = 3.14f;
        float verticalAngle = 0.0f;
        float initialFoV = 45.0f;

        float speed = 3.0f;
        float mouseSpeed = 0.005f;
    };
}

#endif //LAB2_APP_HPP
