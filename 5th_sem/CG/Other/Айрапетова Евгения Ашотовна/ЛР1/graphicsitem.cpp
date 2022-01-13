#include "graphicsitem.h"

Grid::Grid(QGraphicsItem *parent):
    QGraphicsItem(parent),
    m_space{30},
    m_scaleX{1},m_scaleY{1},
    m_angle{0}
{ }

QRectF Grid::boundingRect() const {
    return scene()->views().first()->rect();
}

void Grid::paint(QPainter *painter, const QStyleOptionGraphicsItem *option, QWidget *widget)
{
    Q_UNUSED(option); Q_UNUSED(widget);
    painter->setRenderHint(QPainter::Antialiasing);
    qreal w = boundingRect().width();
    qreal h = boundingRect().height();
    qreal start = -m_space*50; //чтобы при изменении масштаба сетка отрисовывалась

    //рисуем вспомогательные окружности
    for(auto chunk = start ; chunk <= w+qAbs(start) ; chunk+=m_space) {
        painter->save();
        painter->setPen(QPen(QBrush(QColor(Qt::gray)), 0.3, Qt::PenStyle::SolidLine));
        painter->drawEllipse(QPointF((int)(w/2), (int)(h/2)),chunk,chunk);
        painter->restore();
    }

    painter->save();
    //меняем начало координат
    painter->translate((int)(w/2), (int)(h/2));

    painter->rotate(m_angle);

    //Рисуем оси Оx и Оy
    painter->drawLine(QLineF(0,0, 0,-h));
    painter->drawLine(QLineF(0,0, 0, h));
    painter->drawLine(QLineF(0,0, w, 0));
    painter->drawLine(QLineF(0,0, -w, 0));

    //Рисуем разметку для осей Оx и Оy
    qreal scX = m_scaleX;
    for(auto chunk = m_space ; chunk <= w ; chunk+=m_space, scX+=m_scaleX) {
        painter->drawLine(chunk, -1, static_cast<qreal>(chunk),1);
        painter->drawText(chunk-7, 10, QString::number(scX, 'g', 3));

        painter->drawLine(-chunk, -1,(-1)* static_cast<qreal>(chunk),1);
        painter->drawText(-chunk-7, 10, QString::number(-scX, 'g', 3));
    }
    qreal scY = m_scaleY;
    for(auto chunk = -m_space ; chunk >= -w ; chunk-=m_space, scY+=m_scaleY) {
        painter->drawLine(-1, chunk,1, static_cast<qreal>(chunk));
        painter->drawText(-23, chunk, QString::number(scY, 'g', 3));

        painter->drawLine(-1,  -chunk,1,(-1)* static_cast<qreal>(chunk));
        painter->drawText(-23, -chunk, QString::number(-scY, 'g', 3));
    }

    painter->restore();
}

void Grid::setScaleX(qreal scaleX){
    m_scaleX = scaleX;
}

void Grid::setScaleY(qreal scaleY){
    m_scaleY = scaleY;
}

void Grid::setAngle(qreal angle){
    m_angle = (-1)*angle;
}


/////

Chart::Chart(QGraphicsItem* parent):
    QGraphicsItem(parent),
    m_a{5},m_b{200},
    m_approx{1000},
    m_space{30},
    m_scaleX{0.5},m_scaleY{0.5},
    m_angle{0}
{}

QRectF Chart::boundingRect() const
{
    return scene()->views().first()->rect();
}

void Chart::paint(QPainter *painter, const QStyleOptionGraphicsItem *option, QWidget *widget)
{
    Q_UNUSED(option); Q_UNUSED(widget);
    qreal w = boundingRect().width();
    qreal h = boundingRect().height();
    painter->setRenderHint(QPainter::Antialiasing);
    painter->save();

    //меняем точку начала координат
    painter->translate((int)(w/2), (int)(h/2));

    painter->rotate(m_angle);

    //ширина и цвет линии графика
    painter->setPen(QPen(QColor(Qt::blue), 1));
    //размечаем точки для графика
    QPainterPath path(QPointF(0.0, 0.0));
    qreal step = M_PI/m_approx;        //параметр апроксимации

    for(qreal phi = 0.0 ; phi <= 2*M_PI ; phi+=step) {
        qreal ro = f_phi(phi);
        path.lineTo(scaleX(ro*qCos(phi)), scaleY(ro*qSin(phi)));
    }
    //т. к. при некоторых параметрах аппроксимации последняя точка на графике
    //не будет получена, доопреденим последнюю точку
    qreal ro = f_phi(2*M_PI);
    path.lineTo(scaleX(ro*qCos(2*M_PI)), scaleY(ro*qSin(2*M_PI)));

    painter->drawPath(path);
    painter->restore();
}

qreal Chart::f_phi(qreal phi) const {
    return m_a*qSin(2*phi);
}

qreal Chart::scaleX(qreal x) const {
    return m_space * x / m_scaleX;
}

qreal Chart::scaleY(qreal y) const {
    return m_space * y / m_scaleY;
}

void Chart::setScaleX(qreal scaleX){
    m_scaleX = scaleX;
}

void Chart::setScaleY(qreal scaleY){
    m_scaleY = scaleY;
}

void Chart::setA(qreal a){
    m_a = a;
}

void Chart::setApprox(qreal approx){
    m_approx = approx;
}

void Chart::setAngle(qreal angle){
    m_angle = (-1)*angle;
}
