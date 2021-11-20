//#define UseOpenGL // Раскомментировать для использования OpenGL
#if (!UseOpenGL)
using Device     = CGLabPlatform.GDIDevice;
using DeviceArgs = CGLabPlatform.GDIDeviceUpdateArgs;
#else
using Device     = CGLabPlatform.OGLDevice;
using DeviceArgs = CGLabPlatform.OGLDeviceUpdateArgs;
using SharpGL;
#endif

using System;
using System.Linq;
using System.Drawing;
using System.Windows.Forms;
using System.Drawing.Imaging;
using System.Collections.Generic;
using CGLabPlatform;
// ==================================================================================


using CGApplication = MyApp;
public abstract class MyApp: CGApplicationTemplate<CGApplication, Device, DeviceArgs>
{

    // TODO: Добавить свойства, поля


    protected override void OnMainWindowLoad(object sender, EventArgs args)
    {
        // TODO: Инициализация данных
    }


    protected override void OnDeviceUpdate(object s, DeviceArgs e)
    {
        // TODO: Отрисовка и обновление
    }

}


// ==================================================================================
public abstract class AppMain : CGApplication
{ [STAThread] static void Main() { RunApplication(); } }