#pragma once
#include <iostream>
#include <vector>
#include <fstream>
#include <sstream>
#include "../glm/glm/glm.hpp"
#include "../glm/glm/gtc/matrix_transform.hpp"
#include "../glm/glm/gtc/type_ptr.hpp"

class Object{
    std::vector<float> verteces, allVerteces, VertexAndNorm;
    std::vector<long long> faces;
    float dx, dy, dz;
    float rotX, rotY, rotZ;
    float scaleX, scaleY, scaleZ;
    void LoadModel(std::string filename);
    void Triangles(std::stringstream& str);
    void IndecesToVerteces();
    void Normals();
    void AddPoint(std::vector<float>& tovec, std::vector<float>& fromvec, int ind, int k=0);
    public:
        Object(std::string filename, float x=0.0f, float y=0.0, float z=0.0, float rX=0.0, float rY=0.0, float rZ=0.0, float sX=1.0, float sY=1.0, float sZ=1.0);
        std::vector<float> getVerteces();
        std::vector<float> getAllVerteces();
        std::vector<float> getVAndN();
        std::vector<long long> getFaces();
        void ReloadModel(std::string filename);
        void Setdx(float a);
        void Setdy(float a);
        void Setdz(float a);
        void SetrotX(float a);
        void SetrotY(float a);
        void SetrotZ(float a);
        void SetscaleX(float a);
        void SetscaleY(float a);
        void SetscaleZ(float a);
        float Getdx();
        float Getdy();
        float Getdz();
        float GetrotX();
        float GetrotY();
        float GetrotZ();
        float GetscaleX();
        float GetscaleY();
        float GetscaleZ();
};