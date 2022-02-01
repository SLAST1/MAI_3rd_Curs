#pragma once
#include<iostream>
#include "../glm/glm/glm.hpp"
#include "../glm/glm/gtc/matrix_transform.hpp"
#include "../glm/glm/gtc/type_ptr.hpp"
#include "object.h"

namespace mtx{
    glm::mat4 ModelMatrix(Object& obj);
    glm::mat4 ProjectMatrix();
}