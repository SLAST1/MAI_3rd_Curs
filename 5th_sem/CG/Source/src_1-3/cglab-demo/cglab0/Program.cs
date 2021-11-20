using System;
using System.Linq;
using System.Drawing;
using System.Drawing.Imaging;
using System.Windows.Forms;
using System.ComponentModel;
using System.Collections.Generic;
using System.Drawing.Text;
using cglab_demo;
using CGLabPlatform;


// Объявляем производный класс с любым именем от GFXApplicationTemplate<T>. Его реализация 
// находиться в сборке CGLabPlatform, следовательно надо добавить в Reference ссылку на  
// эту сборку (также нужны ссылки на сборки: Sysytem, System.Drawing и System.Windows.Forms) 
// и объявить, что используется простанство имен - using CGLabPlatform. И да верно, класс 
// является  абстрактным - дело в колдунстве, что происходит внутри базового класса - по факту
// он динамически объявляет новый класс производный от нашего класса и создает прокси объект.

public abstract partial class CGLab01 : GFXApplicationTemplate<CGLab01>
{
    // Точка входа приложения - просто передаем управление базовому классу
    // вызывая метод RunApplication(), дабы он сделал всю оставшуюся работу
    // Впринципе, одной этой строчки, в объявленном выше классе, вполне 
    // достаточно чтобы приложение можно было уже запустить
    [STAThread] static void Main() { RunApplication(); }

    // ---------------------------------------------------------------------------------
    // ---------------------------------------------------------------------------------
    // --- Часть 1: Объявление и работа со свойствами
    // ---------------------------------------------------------------------------------

    // Для добавления свойств и связанных с ними элементов управления на панели свойств
    // приложения нужно пометить открытое (public) свойство одним из следующих аттрибутов:
    //  * DisplayNumericProperty - численное значение, типа int, float, double? DVector2 и т.д.
    //  * DisplayCheckerProperty - переключатель для значения типа bool
    //  * DisplayTextBoxProperty - текстовое значение типа string
    //  * DisplayEnumListProperty - меню выбора для значения типа перечисления (Enum)
    //  У всех аттрибутов первый параметр задает начальное значение, затем значение 
    //  типа string - отображаемое название. Для численных значений дополнительно
    //  можно задать величину шага (инкремент) и граничные значение (мин, макс)
    //  Сами свойства можно определить несколькими способами:


    // 1 - Краткая форма: Просто объявляем свойства как абстрактное или виртуальное
    [DisplayNumericProperty(Default: new[] { 900d, 630d }, Increment: 10, Name: "Полуоси X/Y")]
    public abstract DVector2 _axis { get; set; }

    [DisplayNumericProperty(Default: 0, Increment: 1, Maximum: 360, Name: "Начальный угол")]
    public abstract double _angle_start { get; set; }

    [DisplayNumericProperty(Default: 360, Increment: 1, Minimum:-360, Maximum: 360, Name: "Размер угла")]
    public abstract double _angle_size { get; set; }

    [DisplayNumericProperty(Default: 6, Increment: 1, Maximum: 360, Name: "# Сторон")]
    public abstract int _aprox_param { get; set; }

    [DisplayNumericProperty(Default: new[] { -910d, 630d }, Increment: 10, Name: "Область по Х")]
    public abstract DVector2 _xlim { get; set; }

    [DisplayNumericProperty(Default: new[] { -640d, 430d }, Increment: 10, Name: "Область по Y")]
    public abstract DVector2 _ylim { get; set; }

    // 1 - Краткая форма: Просто объявляем свойства как абстрактное или виртуальное
    [DisplayNumericProperty(Default: new [] { 0d, 0d }, Increment: 1, Name: "Сдвиг по X/Y")]
    public abstract DVector2 Shift { get; set; }

   

    // ---------------------------------------------------------------------------------
    // ---------------------------------------------------------------------------------
    // --- Часть 2: Инициализация данных, управления и поведения приложения
    // ---------------------------------------------------------------------------------


    // Если нужна какая-то инициализация данных при запуске приложения, можно реализовать ее
    // в перегрузке данного события, вызываемого единожды перед отображением окна приложения
    protected override void OnMainWindowLoad(object sender, EventArgs args)
    {
        // Созданное приложение имеет два основных элемента управления:
        // base.RenderDevice - левая часть экрана для рисования
        // base.ValueStorage - правая панель для отображения и редактирования свойств

        // Пример изменения внешниго вида элементов управления (необязательный код)
        base.RenderDevice.BufferBackCol = 0x20;
        base.ValueStorage.Font = new Font("Arial", 12f);
        base.ValueStorage.ForeColor = Color.Firebrick;
        base.ValueStorage.RowHeight = 30;
        base.ValueStorage.BackColor = Color.BlanchedAlmond;
        base.MainWindow.BackColor = Color.DarkGoldenrod;
        base.ValueStorage.RightColWidth = 50;
        base.VSPanelWidth = 300;
        base.VSPanelLeft = true;
        base.MainWindow.Size = new Size(2500, 1380);
        base.MainWindow.StartPosition = FormStartPosition.Manual;
        base.MainWindow.Location = Point.Empty;

        base.RenderDevice.GraphicsHighSpeed = false;
        
        
        // Реализация управления мышкой с зажатыми левой и правой кнопкой мыши
        base.RenderDevice.MouseMoveWithRightBtnDown += (s, e)
            => Shift += new DVector2(e.MovDeltaX, -e.MovDeltaY);
        base.RenderDevice.MouseMoveWithLeftBtnDown += (s, e)
            => Shift += 10 * new DVector2(e.MovDeltaX, -e.MovDeltaY);

        // Реализация управления клавиатурой
        RenderDevice.HotkeyRegister(Keys.Up,    (s, e) => Shift += DVector2.UnitY);
        RenderDevice.HotkeyRegister(Keys.Down,  (s, e) => Shift -= DVector2.UnitY);
        RenderDevice.HotkeyRegister(Keys.Left,  (s, e) => Shift -= DVector2.UnitX);
        RenderDevice.HotkeyRegister(Keys.Right, (s, e) => Shift += DVector2.UnitX);
        RenderDevice.HotkeyRegister(KeyMod.Shift, Keys.Up,    (s, e) => Shift +=10*DVector2.UnitY);
        RenderDevice.HotkeyRegister(KeyMod.Shift, Keys.Down,  (s, e) => Shift -=10*DVector2.UnitY);
        RenderDevice.HotkeyRegister(KeyMod.Shift, Keys.Left,  (s, e) => Shift -=10*DVector2.UnitX);
        RenderDevice.HotkeyRegister(KeyMod.Shift, Keys.Right, (s, e) => Shift +=10*DVector2.UnitX);

        // ... расчет каких-то параметров или инициализация ещё чего-то, если нужно
    }


    // ---------------------------------------------------------------------------------
    // ---------------------------------------------------------------------------------
    // --- Часть 3: Формирование изображение и его отрисовка на экране
    // ---------------------------------------------------------------------------------


    // При надобности добавляем нужные поля, методы, классы и тд и тп.
    private double angle = 0;


    // Перегружаем главный метод. По назначению он анологичен методу OnPaint() и предназначен
    // для формирования изображения. Однако в отличии от оного он выполняется паралелльно в
    // другом потоке и вызывается непрерывно. О текущей частоте вызовов можно судить по 
    // счетчику числа кадров в заголовке окна (конечно в режиме отладки скорость падает).
    // Помимо прочего он обеспечивает более высокую скорость рисования и не мерцает.
    protected override unsafe void OnDeviceUpdate(object s, GDIDeviceUpdateArgs e)
    {
        e.Surface.DrawLine(0, 0, Color.Brown.ToArgb(), 1000, 1000);
    }
}
