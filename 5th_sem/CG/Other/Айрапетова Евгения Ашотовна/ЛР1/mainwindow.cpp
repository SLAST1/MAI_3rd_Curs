#include "mainwindow.h"
#include "ui_mainwindow.h"

#include <QDebug>

MainWindow::MainWindow(QWidget *parent)
    : QMainWindow(parent)
    , ui(new Ui::MainWindow)
{
    ui->setupUi(this);

    left_button_pressed = false;
    setWindowTitle("2d graphic.exe");
    scene.setObjectName("scene"); //scene объявлен в MainWindow
    ui->gv->setScene(&scene);     //QGraphicsView на ui
    grid = new Grid;
    chart = new Chart;
    scene.addItem(grid);
    scene.addItem(chart);
    // устанавливаем фильтр событий для перехвата событий колёсика
    scene.installEventFilter(this);
}

void MainWindow::ChangeScale(){

     grid->setScaleX(ui->ScaleX->value());
     grid->setScaleY(ui->ScaleY->value());
     chart->setScaleX(ui->ScaleX->value());
     chart->setScaleY(ui->ScaleY->value());
     scene.update();
}

void MainWindow::ChangeA(){
    chart->setA(ui->param_a->value());
    scene.update();
}

void MainWindow::ChangeApprox(){
    chart->setApprox(ui->Approx->value());
    scene.update();
}

void MainWindow::Rotate(){
    grid->setAngle(ui->angle->value());
    chart->setAngle(ui->angle->value());
    scene.update();
}

bool MainWindow::eventFilter(QObject *watched, QEvent *event) {
    if(watched->objectName() == "scene") {
        if(event->type() == QEvent::GraphicsSceneWheel) {
            QGraphicsSceneWheelEvent* wevent = static_cast<QGraphicsSceneWheelEvent*>(event);

            //изменяем масштаб
            ui->gv->scale(wevent->delta() < 0 ? 0.9 : 1.1, wevent->delta() < 0 ? 0.9 : 1.1);

            //центрируем в точке позиции мыши на сцене
            if(wevent->delta() < 0) ui->gv->centerOn(wevent->scenePos());
            scene.update();
            event->accept();
            return true;
        }

    }
    /*if (event->type() == QEvent::GraphicsSceneMousePress) {
            //QMouseEvent * pe = (QMouseEvent*) event;
           QTouchEvent* pe = static_cast<QTouchEvent*>(event);
            qDebug() << pe->type();

            left_button_pressed =true;
                //cursor_pos = pe->touchPoints()
            QApplication::setOverrideCursor(Qt::ClosedHandCursor);
            scene.update();
            event->accept();

                qDebug() <<  "Ok";

            return true;
        }
        if (event->type() == QEvent::GraphicsSceneMouseRelease) {
            //QMouseEvent * pe = (QMouseEvent*) event;
            //QTouchEvent* pe = static_cast<QTouchEvent*>(event);
            left_button_pressed = true;
            cursor_pos = QPoint(0,0);
            QApplication::restoreOverrideCursor();

            return true;
        }
        else if (event->type() == QEvent::GraphicsSceneMouseMove) {
                QTouchEvent* pe = static_cast<QTouchEvent*>(event);
                //QGraphicsSceneMouseEvent* pe = static_cast<QGraphicsSceneMouseEvent*>(event);
               // QMouseEvent * pe = (QMouseEvent*) event;

                QPoint curr_cursor_pos =  pe->scenePos();
                QPoint d_coord = curr_cursor_pos - cursor_pos;

                int x = ui->gv->horizontalScrollBar()->value() - d_coord.x();
                int y = ui->gv->verticalScrollBar()->value() - d_coord.y();

                if (x < 0)
                  x = 0;
                if (y < 0)
                  y = 0;

                ui->gv->horizontalScrollBar()->setValue(x);
                ui->gv->verticalScrollBar()->setValue(y);

                cursor_pos = curr_cursor_pos - d_coord;
                scene.update();
                event->accept();
                return true;
            }*/
    return false;
}

MainWindow::~MainWindow()
{
    delete ui;
}
