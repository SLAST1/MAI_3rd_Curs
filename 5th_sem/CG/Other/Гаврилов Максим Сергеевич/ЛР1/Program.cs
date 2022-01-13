//Гаврилов М.С.М8О-306Б-19
using System;
using System.Linq;
using System.Drawing;
using System.Drawing.Imaging;
using System.Windows.Forms;
using System.ComponentModel;
using System.Collections.Generic;
using CGLabPlatform;

public abstract class CGLab01 : GFXApplicationTemplate<CGLab01>
{
    #region Инициализация

    [STAThread] static void Main() { RunApplication(); }


    protected override void OnMainWindowLoad(object sender, EventArgs args)
    {
        base.RenderDevice.BufferBackCol = 0x20;
        base.RenderDevice.MouseMoveWithLeftBtnDown += (s, e) => 
                  FirstPoint += new DVector2(e.MovDeltaX, e.MovDeltaY);

        RenderDevice.HotkeyRegister(Keys.Up,   (s, e) => ++B);
        RenderDevice.HotkeyRegister(Keys.Down, (s, e) => --B);

        RenderDevice.HotkeyRegister(Keys.Left, (s, e) => ++A);
        RenderDevice.HotkeyRegister(Keys.Right, (s, e) => --A);
    }

    #endregion

    #region Свойства
    
    [DisplayTextBoxProperty("x = A*sin(t); y = B*cos(t)", "Гаврилов М.С.")]
    public abstract string Name { get; set; }

    [DisplayNumericProperty(
        Default: 100,
        Increment: 10,
        Name: "A",
        Minimum: 0
    )]
    public abstract int A { get; set; }

    [DisplayNumericProperty(
        Default: 100,
        Increment: 10,
        Name: "B",
        Minimum: 0
    )]
    public abstract int B { get; set; }

    [DisplayNumericProperty(
        Default: new[] { 300d, 200d }, 
        Increment: 1, 
        Name: "Центр", 
        Minimum: -1000
    )]
    public abstract DVector2 FirstPoint { get; set; }
    #endregion

    double Ffx(double x)
    {
        return x * x;
    }

    double PastHeigth = 0;
    double PastWidth = 0;

    double mult = 1;

    protected override void OnDeviceUpdate(object s, GDIDeviceUpdateArgs e)
    {
        var SlidePointA = new DVector2(0, 0);
        var PrevPointA = SlidePointA;

        //оси
        e.Surface.DrawLine(Color.Gray.ToArgb(), FirstPoint - new DVector2(1000, 0), FirstPoint + new DVector2(1000, 0));
        e.Surface.DrawLine(Color.Gray.ToArgb(), FirstPoint - new DVector2(0, 1000), FirstPoint + new DVector2(0, 1000));

        //отрисовка графика
        for (double t=0;t<100;t+=0.1)
        {
            SlidePointA *= mult;

            if (t > 1)
            e.Surface.DrawLine(Color.Red.ToArgb(), FirstPoint + PrevPointA, FirstPoint + SlidePointA);

            PrevPointA = SlidePointA;
            SlidePointA = new DVector2(A*Math.Sin(t), B*Math.Cos(t));

        }

        if(PastHeigth != e.Heigh || PastWidth != e.Width)
        {
            //автоцентрирование
            FirstPoint = new DVector2(e.Width / 2, e.Heigh / 2);

            if (PastHeigth != 0)
            {
                mult = e.Heigh / PastHeigth;
            }

            PastHeigth = e.Heigh;
            PastWidth = e.Width;
        }
    }
}
