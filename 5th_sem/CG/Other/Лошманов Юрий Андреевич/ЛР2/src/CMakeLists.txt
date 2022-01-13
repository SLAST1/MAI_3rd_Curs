cmake_minimum_required(VERSION 3.20)

set(CMAKE_CXX_STANDARD 23)

find_package(PkgConfig REQUIRED)
pkg_check_modules(GLEW REQUIRED glew)
pkg_check_modules(GLFW REQUIRED glfw3)
pkg_check_modules(GLM REQUIRED glm)

find_library(GLEW REQUIRED glew)
find_library(GLFW NAMES glfw)
find_library(OPENGL NAMES OpenGL)

add_library(APP App.cpp ../include/App.hpp)
add_executable(lab2 main.cpp)
add_executable(tmp tmp.cpp)

target_include_directories(APP PUBLIC ${GLFW_INCLUDE_DIRS} ${GLEW_INCLUDE_DIRS} ${GLM_INCLUDE_DIRS})
target_include_directories(lab2 PUBLIC ${GLFW_INCLUDE_DIRS} ${GLEW_INCLUDE_DIRS} ${GLM_INCLUDE_DIRS})

target_link_libraries(lab2 APP ${GLEW} ${GLFW} ${OPENGL})
