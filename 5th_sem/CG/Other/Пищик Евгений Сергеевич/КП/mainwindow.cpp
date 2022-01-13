#include "mainwindow.h"
#include "ui_mainwindow.h"

MainWindow::MainWindow(QWidget *parent): QMainWindow(parent), ui(new Ui::MainWindow)
{
    ui->setupUi(this);
    connect(ui->x_rot, SIGNAL(valueChanged(int)), ui->widget, SLOT(setXRot(int)));
    connect(ui->y_rot, SIGNAL(valueChanged(int)), ui->widget, SLOT(setYRot(int)));
    connect(ui->z_rot, SIGNAL(valueChanged(int)), ui->widget, SLOT(setZRot(int)));
    connect(ui->size, SIGNAL(valueChanged(int)), ui->widget, SLOT(setParam(int)));
    connect(ui->apro, SIGNAL(valueChanged(int)), ui->widget, SLOT(setApro(int)));
}

MainWindow::~MainWindow() { delete ui; }
