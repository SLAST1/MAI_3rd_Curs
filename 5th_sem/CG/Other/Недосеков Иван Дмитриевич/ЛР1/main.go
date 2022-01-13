// write by Ivan Nedosekov
package main

import (
	"log"
	"math"

	"github.com/gotk3/gotk3/gtk"
)

func f(A, B, a, b, phi float64) (x, y float64) {
	x = a*phi - b*math.Sin(phi)
	y = a - b*math.Cos(phi)
	return
}

type globals struct {
	A, B, a, b             float64
	w                      *gtk.Window
	f                      func(A, B, a, b, phi float64) (x, y float64)
	count, start_i, segLen int
	calculated_points      []struct{ x, y float64 }
}

var vars globals

func main() {
	vars.f = f
	vars.count = 102
	vars.start_i = -50
	vars.segLen = 2

	// Инициализируем GTK.
	gtk.Init(nil)

	// Создаём билдер
	builder, err := gtk.BuilderNew()
	if err != nil {
		log.Fatal("Ошибка:", err)
	}

	// Загружаем в билдер окно из файла Glade
	err = builder.AddFromFile("main.glade")
	if err != nil {
		log.Fatal("Ошибка:", err)
	}

	// Получаем объект главного окна по ID
	obj, err := builder.GetObject("window_main")
	if err != nil {
		log.Fatal("Ошибка:", err)
	}

	// Преобразуем из объекта именно окно типа gtk.Window
	// и соединяем с сигналом "destroy" чтобы можно было закрыть
	// приложение при закрытии окна
	win := obj.(*gtk.Window)
	win.Connect("destroy", func() {
		gtk.MainQuit()
	})
	win.SetTitle("LR 1 Ivan Nedosekov")
	vars.w = win

	obj, err = builder.GetObject("A_input")
	if err != nil {
		log.Fatal(err)
	}
	input := obj.(*gtk.Entry)
	parse_A(input)
	input.Connect("changed", parse_A)

	obj, err = builder.GetObject("B_input")
	if err != nil {
		log.Fatal(err)
	}
	input = obj.(*gtk.Entry)
	parse_B(input)
	input.Connect("changed", parse_B)

	obj, err = builder.GetObject("a_input")
	if err != nil {
		log.Fatal(err)
	}
	input = obj.(*gtk.Entry)
	parse_a(input)
	input.Connect("changed", parse_a)

	obj, err = builder.GetObject("b_input")
	if err != nil {
		log.Fatal(err)
	}
	input = obj.(*gtk.Entry)
	parse_b(input)
	input.Connect("changed", parse_b)

	obj, err = builder.GetObject("canvas")
	if err != nil {
		log.Fatal(err)
	}
	canvas := obj.(*gtk.DrawingArea)
	canvas.Connect("draw", drawWhiteCanvas)
	canvas.Connect("draw", drawAxis)
	canvas.Connect("draw", renderGraphic)

	// Отображаем все виджеты в окне
	win.ShowAll()

	// Выполняем главный цикл GTK (для отрисовки). Он остановится когда
	// выполнится gtk.MainQuit()
	gtk.Main()
}
