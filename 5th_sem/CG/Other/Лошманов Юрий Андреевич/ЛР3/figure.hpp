//
// Yury Loshmanov
// 306
//

#pragma once

#include <array>
#include <vector>

#include <SFML/Graphics.hpp>

#include "matrices.hpp"
#include "conversion.hpp"


sf::Color operator*(float f, sf::Color c);
sf::Color operator/(sf::Color c, float f);


class Point;

class Triangle;

class Figure;


#include "figure.inl"