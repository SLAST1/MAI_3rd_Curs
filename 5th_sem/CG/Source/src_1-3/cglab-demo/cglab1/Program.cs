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

        RenderDevice.HotkeyRegister(Keys.PageUp,   (s, e) => ++Length);
        RenderDevice.HotkeyRegister(Keys.PageDown, (s, e) => --Length);

        //return;
        MainWindow.Shown += (s, e) =>
        {
            var btn = new Button() { Text = "Press me!" };
            btn.Click += (cs, ce) => MessageBox.Show("Ok, it's works!");
            //AddControll(btn, 130);

            AddControl(btn, 130, "Angle");
        };

        


    }

    #endregion

    #region Свойства

    [DisplayNumericProperty(Default: 50, Increment: 1, Name: "Длинна", Minimum: 1)]
    public abstract int  Length { get; set; }

    [DisplayNumericProperty(
        Default: new[] { 300d, 200d }, 
        Increment: 1, 
        Name: "Точка", 
        Minimum: -1000
    )]
    public abstract DVector2 FirstPoint { get; set; }

    [DisplayNumericProperty(Default: 0, Increment: 0.1, Name: "Угол")]
    public double Angle {
        get { return Get<double>(); }
        set { while (value <    0) value += 360;
              while (value >= 360) value -= 360;
              Set<double>(value);
        }
    }

    #endregion



    protected override void OnDeviceUpdate(object s, GDIDeviceUpdateArgs e)
    {
        Angle += 0.0360*e.Delta;

        var SecondPoint = FirstPoint + Length * new DVector2(
            Math.Cos(Angle * Math.PI / 180),
            Math.Sin(Angle * Math.PI / 180)
        );

        e.Surface.DrawLine( Color.LawnGreen.ToArgb(),  FirstPoint,  SecondPoint );
    }


    private void AddControll(Control ctrl, int heigh)
    {
        var layout = ValueStorage.Controls[0].Controls[0] as TableLayoutPanel;

        layout.SuspendLayout();
        ctrl.Dock = DockStyle.Fill;
        layout.Parent.Height += heigh;
        layout.RowStyles.Insert(layout.RowCount - 1, new RowStyle(SizeType.Absolute, heigh));
        layout.Controls.Add(ctrl, 0, layout.RowCount - 1);
        layout.SetColumnSpan(ctrl, 2);
        layout.RowCount++;
        layout.ResumeLayout(true);
    }

    private void AddControl(Control ctrl, int heigh, string InsertBeforeProperty)
    {
        var layout = ValueStorage.Controls[0].Controls[0] as TableLayoutPanel;
        layout.SuspendLayout();
        ctrl.Dock = DockStyle.Fill;
        layout.Parent.Height += heigh;
        var beforectrl = ValueStorage.GetControlForProperty(InsertBeforeProperty);
        var position = layout.GetPositionFromControl(beforectrl).Row + 1;
        for (int r = layout.RowCount; position <= r--; ) {
            for (int c = layout.ColumnCount; 0 != c--; ) {
                var control = layout.GetControlFromPosition(c, r);
                if (control != null) layout.SetRow(control, r + 1);
            }
        }
        layout.RowStyles.Insert(position-1, new RowStyle(SizeType.Absolute, heigh));
        layout.Controls.Add(ctrl, 0, position-1);
        layout.SetColumnSpan(ctrl, 2);
        layout.RowCount++;
        layout.ResumeLayout(true);

    }

}
