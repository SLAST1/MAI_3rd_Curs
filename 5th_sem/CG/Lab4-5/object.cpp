#include "object.h"

Object::Object(std::string filename, float x, float y, float z, float rX, float rY, float rZ, float sX, float sY, float sZ):
                                    dx(x), dy(y), dz(z), rotX(rX), rotY(rY), rotZ(rZ), scaleX(sX), scaleY(sY), scaleZ(sZ){
    LoadModel(filename);
    IndecesToVerteces();
    Normals();
}

void Object::LoadModel(std::string filename){
    std::ifstream file(filename);
    if(!file.is_open()){
        std::cout << "Can't open file!\n";
    }
    else{
        std::string number, word;
        while(file >> word){
            std::getline(file, number);
            number.erase(number.begin());
            std::stringstream line;
            line << number;
            if(word=="v"){
                while(line >> number){
                    verteces.push_back(std::stof(number));
                }
            }
            else{
                Triangles(line);
            }
        }
    }
    file.close();
}

void Object::Triangles(std::stringstream& str){
    std::string first, second, last;
    str >> first;
    str >> second;
    while(str >> last){
        faces.push_back(std::stoll(last));
        faces.push_back(std::stoll(second));
        faces.push_back(std::stoll(first));
        second = last;
    }
}

std::vector<float> Object::getVerteces(){
    return verteces;
}

std::vector<float> Object::getAllVerteces(){
    return allVerteces;
}

std::vector<long long> Object::getFaces(){
    return faces;
}

std::vector<float> Object::getVAndN(){
    return VertexAndNorm;
}

void Object::IndecesToVerteces(){
    for(long long i = 0; i < faces.size(); i++){
        AddPoint(allVerteces, verteces, faces[i]);
    }
}

void Object::AddPoint(std::vector<float>& tovec, std::vector<float>& fromvec, int ind, int k){
    tovec.push_back(fromvec[ind*3 + k]);
    tovec.push_back(fromvec[ind*3 + 1 + k]);
    tovec.push_back(fromvec[ind*3 + 2 + k]);
}

void Object::Normals(){
    for(long long i = 0; i < allVerteces.size(); i=i+9){
        glm::vec3 first(allVerteces[i]-allVerteces[i+3], allVerteces[i+1]-allVerteces[i+4], allVerteces[i+2]-allVerteces[i+5]);
        glm::vec3 second(allVerteces[i+6]-allVerteces[i+3], allVerteces[i+7]-allVerteces[i+4], allVerteces[i+8]-allVerteces[i+5]);
        first = glm::cross(first, second);
        for(int j=0; j < 3; j++){
            AddPoint(VertexAndNorm, allVerteces, j, i);
            VertexAndNorm.push_back(first.x);
            VertexAndNorm.push_back(first.y);
            VertexAndNorm.push_back(first.z);
        }
    }
}

void Object::ReloadModel(std::string filename){
    verteces.clear();
    allVerteces.clear();
    VertexAndNorm.clear();
    LoadModel(filename);
    IndecesToVerteces();
    Normals();
}

void Object::Setdx(float a){
    dx = a;
}

void Object::Setdy(float a){
    dy = a;
}

void Object::Setdz(float a){
    dz = a;
}

void Object::SetrotX(float a){
    rotX = a;
}

void Object::SetrotY(float a){
    rotY = a;
}

void Object::SetrotZ(float a){
    rotZ = a;
}

void Object::SetscaleX(float a){
    scaleX = a;
}

void Object::SetscaleY(float a){
    scaleY = a;
}

void Object::SetscaleZ(float a){
    scaleZ = a;
}

float Object::Getdx(){
    return dx;
}

float Object::Getdy(){
    return dy;
}

float Object::Getdz(){
    return dz;
}

float Object::GetrotX(){
    return rotX;
}

float Object::GetrotY(){
    return rotY;
}

float Object::GetrotZ(){
    return rotZ;
}

float Object::GetscaleX(){
    return scaleX;
}

float Object::GetscaleY(){
    return scaleY;
}

float Object::GetscaleZ(){
    return scaleZ;
}