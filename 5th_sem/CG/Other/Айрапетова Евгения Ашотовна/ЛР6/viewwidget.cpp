#include "viewwidget.h"
#include <QLabel>

ViewWidget::ViewWidget()
{
    glw->Engine.addFigure(sph);
    hLayout->addWidget(glw, 1);
    hLayout->addLayout(vLayout);
        vLayout->addWidget(isHidingBack);
        vLayout->addWidget(isLigthing);
        vLayout->addWidget(isAnimate);
        vLayout->addWidget(new QLabel("Precision"));
        vLayout->addWidget(sliderPrecision);
        vLayout->addWidget(new QLabel("Rotations"));
        vLayout->addLayout(hLayoutRotations);
            hLayoutRotations->addWidget(sliderRotX);
            hLayoutRotations->addWidget(sliderRotY);
            hLayoutRotations->addWidget(sliderRotZ);
        vLayout->addWidget(ligthSettings);


    isHidingBack->setText("Hide back");
    isLigthing->setText("Enable Light");
    ligthSettings->setText("Light settings");
    isAnimate->setText("Animation");

    sliderPrecision->setRange(3, 150);
    sliderRotX->setRange(0,MAX_VALUE_SLIDER);
    sliderRotY->setRange(0,MAX_VALUE_SLIDER);
    sliderRotZ->setRange(0,MAX_VALUE_SLIDER);

    sliderPrecision->setSingleStep(1);
    sliderPrecision->setValue(10);
    sliderRotX->setSingleStep(1);
    sliderRotY->setSingleStep(1);
    sliderRotZ->setSingleStep(1);

    sliderRotX->setInvertedAppearance(true);
    sliderRotY->setInvertedAppearance(true);
    sliderRotZ->setInvertedAppearance(true);

    sliderPrecision->setEnabled(true);
    ligthSettings->setEnabled(false);
    isHidingBack->setEnabled(false);

    isAnimate->setChecked(false);           //!!!!!!!!!!!!!!!!!!!!!!!

    QObject::connect(sliderRotX, SIGNAL(valueChanged(int)),
                     this, SLOT(configChanged(int)));
    QObject::connect(sliderRotY, SIGNAL(valueChanged(int)),
                     this, SLOT(configChanged(int)));
    QObject::connect(sliderRotZ, SIGNAL(valueChanged(int)),
                     this, SLOT(configChanged(int)));
    QObject::connect(sliderPrecision, SIGNAL(valueChanged(int)),
                     this, SLOT(configChanged(int)));
    QObject::connect(isHidingBack, SIGNAL(stateChanged(int)),
                     this, SLOT(configChanged(int)));
    QObject::connect(isLigthing, SIGNAL(stateChanged(int)),
                     this, SLOT(configChanged(int)));

    QObject::connect(isAnimate, SIGNAL(stateChanged(int)),  //!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
                     this, SLOT(configChanged(int)));

    QObject::connect(ligthSettings, SIGNAL(clicked()),
                     this, SLOT(showLightSettings()));
    QObject::connect(lsw->sliderPositionX, SIGNAL(valueChanged(int)),
                     this, SLOT(configChanged(int)));
    QObject::connect(lsw->sliderPositionY, SIGNAL(valueChanged(int)),
                     this, SLOT(configChanged(int)));
    QObject::connect(lsw->sliderPositionZ, SIGNAL(valueChanged(int)),
                     this, SLOT(configChanged(int)));
    QObject::connect(lsw->sliderPositionW, SIGNAL(valueChanged(int)),
                     this, SLOT(configChanged(int)));
    QObject::connect(lsw, SIGNAL(lightColorChanged()),
                     this, SLOT(configChanged()));
    QObject::connect(&glw->Engine.timer, SIGNAL(timeout()),
                     this, SLOT(configChanged()));

    sph->setPrecision(sliderPrecision->value());
}

float f1(int v){
    return (float)v*360/MAX_VALUE_SLIDER;
}
float f2(int v){
    return (float)v;
}
float f3(int v){
    return (float) v/ (float)MAX_VALUE_SLIDER_LW;
}
void ViewWidget::configChanged(){   //!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    glw->Engine.setRotation(f1(sliderRotX->value()),
                             f1(sliderRotY->value()),
                             f1(sliderRotZ->value()));
    glw->Engine.setHidingBack(isHidingBack->isChecked());
    sph->setPrecision(sliderPrecision->value());

    ligthSettings->setEnabled(isLigthing->isChecked());

    if(isLigthing->isChecked()){
        sph->setMode(MATERIAL);
        glw->Engine.setLightEnabled(true);
        isHidingBack->setEnabled(false);
        isHidingBack->setChecked(true);
    } else{
        sph->setMode(FRAME);
        glw->Engine.setLightEnabled(false);
        isHidingBack->setEnabled(true);
    }
    glw->Engine.light.direction = QVector4D(f3(lsw->sliderPositionX->value()),
                                            f3(lsw->sliderPositionY->value()),
                                            f3(lsw->sliderPositionZ->value()),
                                            f3(lsw->sliderPositionW->value()));
    glw->Engine.light.ambient = lsw->ambient;
    glw->Engine.light.specular = lsw->specular;
    glw->Engine.light.diffuse = lsw->diffuse;

    glw->Engine.setAnimation(isAnimate->isChecked());   //!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    glw->updateGL();
}
void ViewWidget::configChanged(int){
    configChanged();
}
ViewWidget::~ViewWidget(){
    delete sph;
}


void ViewWidget::showLightSettings(){
    lsw->show();
}
