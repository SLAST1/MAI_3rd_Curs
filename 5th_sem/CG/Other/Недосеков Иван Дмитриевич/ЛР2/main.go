// writed by Ivan Nedosekov
package main

import (
	"log"

	"github.com/gotk3/gotk3/gtk"
)

type Edge struct {
	u, v Point
}

type GlobalObj struct {
	figure                      []Edge
	figure_matr                 [][]float64
	figure_center, camera_point Point
}

var settings GlobalObj

func buildEdges(points []Point) (res []Edge) {
	for i, point := range points[:4] {
		res = append(res,
			Edge{point, points[i+4]},
			Edge{point, points[(i+1)%4]})
	}
	for i, point := range points[4:] {
		res = append(res, Edge{point, points[(i+1)%4+4]})
	}
	return
}

func matr2Points(matr [][]float64) (res []Point) {
	res = make([]Point, len(matr))
	for i, point := range matr {
		res[i] = Point{point[0], point[1], point[2]}
	}
	return
}

func calculateFigure(halfDist float64) ([]Edge, [][]float64, Point) {
	upperHalf := halfDist / 2
	points := []Point{
		{halfDist, halfDist, 1}, {-halfDist, halfDist, 1}, {-halfDist, -halfDist, 1}, {halfDist, -halfDist, 1},
		{upperHalf, upperHalf, upperHalf + 20}, {-upperHalf, upperHalf, upperHalf + 20}, {-upperHalf, -upperHalf, upperHalf + 20}, {upperHalf, -upperHalf, upperHalf + 20},
	}

	res := buildEdges(points)
	res_matr := fig2matr(points)
	center := getInnerPoint(res_matr)
	return res, res_matr, center

}

func fig2matr(fig []Point) (matr [][]float64) {
	matr = make([][]float64, len(fig))
	for i, p := range fig {
		matr[i] = []float64{p.x, p.y, p.z}
	}
	return
}

func rotateFig(matr [][]float64) {
	settings.figure_matr, _ = multiplayMatr(settings.figure_matr, matr)
	settings.figure = buildEdges(matr2Points(settings.figure_matr))
	log.Println("Figure rotated by", matr)
}

func init() {
	gtk.Init(nil)
	settings.figure, settings.figure_matr, settings.figure_center = calculateFigure(50)
	settings.camera_point = Point{0, 0, -5}
	log.Println("Init past, fig", settings.figure)
}

func bindButton(builder *gtk.Builder, name string, callback func()) {
	obj, err := builder.GetObject(name)
	if err != nil {
		log.Fatal(err)
	}
	button := obj.(*gtk.Button)
	button.Connect("clicked", func() {
		log.Println(name, "clicked")
		callback()
	})
}

func main() {

	builder, err := gtk.BuilderNew()
	if err != nil {
		log.Fatal(err)
	}

	err = builder.AddFromFile("main.glade")
	if err != nil {
		log.Fatal(err)
	}

	obj, err := builder.GetObject("draw_area")
	if err != nil {
		log.Fatal(err)
	}

	da := obj.(*gtk.DrawingArea)
	da.Connect("draw", drawCanwas)
	da.Connect("draw", draw_figure)

	bindButton(builder, "up_b", func() { rotateFig(rotateUp) })
	bindButton(builder, "down_b", func() { rotateFig(rotateDown) })
	bindButton(builder, "left_b", func() { rotateFig(rotateLeft) })
	bindButton(builder, "right_b", func() { rotateFig(rotateRight) })

	obj, err = builder.GetObject("main_window")
	if err != nil {
		log.Fatal(err)
	}

	win := obj.(*gtk.Window)
	win.Connect("destroy", func() {
		gtk.MainQuit()
	})
	win.SetTitle("LR 2 Ivan Nedosekov")

	win.ShowAll()
	gtk.Main()

}
