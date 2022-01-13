#ifndef GRAPHICSITEM_H
#define GRAPHICSITEM_H

#include <QAbstractGraphicsShapeItem>

#include <QtWidgets>

#include <math.h>


class Grid : public QGraphicsItem
{
public:
    Grid(QGraphicsItem* parent = nullptr);
    QRectF boundingRect() const;
    void paint(QPainter *painter, const QStyleOptionGraphicsItem *option, QWidget *widget);

    void setScaleX(qreal scaleX);
    void setScaleY(qreal scaleY);
    void setAngle(qreal angle);

private:
    qreal m_space;  //размер клетки
    qreal m_scaleX; //масштаб по Ох, для рисования разметки
    qreal m_scaleY; //масштаб по Оу, для рисования разметки
    qreal m_angle; //угол поворота
};



class Chart : public QGraphicsItem
{
public:
    Chart(QGraphicsItem* parent = nullptr);
    QRectF boundingRect() const;
    void paint(QPainter *painter, const QStyleOptionGraphicsItem *option, QWidget *widget);

    void setScaleX(qreal scaleX);
    void setScaleY(qreal scaleY);
    void setA(qreal a);
    void setApprox(qreal approx);
    void setAngle(qreal angle);
protected:
    qreal f_phi(qreal phi) const;      //реализация функции
    qreal scaleX(qreal x) const;   //масштабирование относительно клетки по Ох
    qreal scaleY(qreal y) const;   //масштабирование относительно клетки по Оу

private:
    qreal m_a;      //параметр а
    qreal m_b;      //параметр b
    qreal m_approx;   //параметр аппроксимации
    qreal m_space;  //радиус окружностей для масштабирования(размер клетки, для масштабирования)
    qreal m_scaleX; //масштаб по Ох, для масштабирования
    qreal m_scaleY; //масштаб по Оу, для масштабирования
    qreal m_angle; //угол поворота
};


#endif // GRAPHICSITEM_H
