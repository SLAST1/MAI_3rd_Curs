#ifndef MAINWINDOW_H
#define MAINWINDOW_H

#include <QMainWindow>
#include <QtWidgets>

#include <QScrollArea>
#include <QAbstractScrollArea>

#include "graphicsitem.h"

QT_BEGIN_NAMESPACE
namespace Ui { class MainWindow; }
QT_END_NAMESPACE

class MainWindow : public QMainWindow
{
    Q_OBJECT

public:
    MainWindow(QWidget *parent = nullptr);
    bool eventFilter(QObject *watched, QEvent *event);
    ~MainWindow();

public slots:
    void ChangeScale();
    void ChangeA();
    void ChangeApprox();
    void Rotate();


private:
    Grid* grid;
    Chart* chart;
    Ui::MainWindow *ui;
    QGraphicsScene scene;
    QPoint curr_cursor_pos;
    QPoint cursor_pos;
    bool left_button_pressed;
};
#endif // MAINWINDOW_H
