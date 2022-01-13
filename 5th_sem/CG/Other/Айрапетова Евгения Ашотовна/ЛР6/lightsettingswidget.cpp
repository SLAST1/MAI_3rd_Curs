#include "lightsettingswidget.h"
#include <QLabel>
LightSettingsWidget::LightSettingsWidget()
{
    setMinimumSize(250, 180);
    setMaximumSize(minimumSize());
    cD->setModal(true);
    setWindowTitle("Light settings");
    cD->setCurrentColor(Qt::white);
    vLayout->addWidget(new QLabel("Position"));
    vLayout->addWidget(sliderPositionX);
    vLayout->addWidget(sliderPositionY);
    vLayout->addWidget(sliderPositionZ);
    //vLayout->addWidget(sliderPositionW);
    //vLayout->addLayout(hLayout);
        //hLayout->addWidget(pushButtonAmbient);
      //  hLayout->addWidget(pushButtonDiffuse);
      //  hLayout->addWidget(pushButtonSpecular);

    sliderPositionX->setRange(-MAX_VALUE_SLIDER_LW, MAX_VALUE_SLIDER_LW);
    sliderPositionY->setRange(-MAX_VALUE_SLIDER_LW, MAX_VALUE_SLIDER_LW);
    sliderPositionZ->setRange(-MAX_VALUE_SLIDER_LW, MAX_VALUE_SLIDER_LW);
    //sliderPositionW->setRange(0, MAX_VALUE_SLIDER_LW);

    sliderPositionX->setSingleStep(1);
    sliderPositionY->setSingleStep(1);
    sliderPositionZ->setSingleStep(1);
    //sliderPositionW->setSingleStep(1);

    sliderPositionX->setValue(MAX_VALUE_SLIDER_LW);
    sliderPositionY->setValue(MAX_VALUE_SLIDER_LW);
    sliderPositionZ->setValue(MAX_VALUE_SLIDER_LW);


}
void LightSettingsWidget::getColorDialogA(){
    cD->show();
    isAmbient = true;
}
void LightSettingsWidget::getColorDialogS(){
    cD->show();
    isSpecular = true;
}
void LightSettingsWidget::getColorDialogD(){
    cD->show();
    isDiffuse = true;
}

void LightSettingsWidget::lightChanged(const QColor&){
    if(isDiffuse){
        diffuse = cD->selectedColor();
        isDiffuse = false;
        pushButtonDiffuse->setText("Diffuse:"+cD->selectedColor().name());
    }
    if(isSpecular){
        specular = cD->selectedColor();
        isSpecular = false;
        pushButtonSpecular->setText("Specular:"+cD->selectedColor().name());
    }
    if(isAmbient){
        ambient = cD->selectedColor();
        isAmbient = false;
        pushButtonAmbient->setText("Ambient:"+cD->selectedColor().name());
    }
    emit lightColorChanged();
}
