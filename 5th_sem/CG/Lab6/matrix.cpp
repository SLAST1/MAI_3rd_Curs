#include "matrix.h"

glm::mat4 mtx::ModelMatrix(Object& obj){
    glm::mat4 matrix = glm::mat4(1.0f);
    if(obj.Getdx() || obj.Getdy() || obj.Getdz()){
        matrix = glm::translate(matrix, glm::vec3(obj.Getdx(), obj.Getdy(), obj.Getdz()));
    }
    if(obj.GetrotX()){
        matrix = glm::rotate(matrix, glm::radians(obj.GetrotX()), glm::vec3(1.0, 0.0, 0.0));
    }
    if(obj.GetrotY()){
        matrix = glm::rotate(matrix, glm::radians(obj.GetrotY()), glm::vec3(0.0, 1.0, 0.0));
    }
    if(obj.GetrotZ()){
        matrix = glm::rotate(matrix, glm::radians(obj.GetrotZ()), glm::vec3(0.0, 0.0, 1.0));        
    }
    if(obj.GetscaleX() || obj.GetscaleY() || obj.GetscaleZ()){
        matrix = glm::scale(matrix, glm::vec3(obj.GetscaleX(), obj.GetscaleY(), obj.GetscaleZ()));
    }
    return matrix;
}

glm::mat4 mtx::ProjectMatrix(){
    return glm::ortho(-10.0f, 10.0f, -10.0f, 10.0f, 0.1f, 100.0f );
}