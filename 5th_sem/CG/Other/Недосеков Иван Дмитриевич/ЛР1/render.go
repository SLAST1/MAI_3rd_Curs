// Writed by Ivan Nedosekov
package main

import (
	"log"
	"math"
	"strconv"

	"github.com/gotk3/gotk3/cairo"
	"github.com/gotk3/gotk3/gtk"
)

func drawWhiteCanvas(da *gtk.DrawingArea, cr *cairo.Context) {
	cr.SetSourceRGB(255, 255, 255)

	w, h := da.GetAllocatedWidth(), da.GetAllocatedHeight()

	cr.Rectangle(0, 0, float64(w), float64(h))
	cr.Fill()
	log.Printf("Draw Canvas w=%d, h=%d", w, h)
}

func calculateArrowPoints(startX, startY, endX, endY, legth float64) (x1, y1, x2, y2 float64) {
	const wingsAngel = math.Pi / 10
	angle := math.Atan2(endY-startY, endX-startX) + math.Pi
	x1 = endX + legth*math.Cos(angle-wingsAngel)
	y1 = endY + legth*math.Sin(angle-wingsAngel)
	x2 = endX + legth*math.Cos(angle+wingsAngel)
	y2 = endY + legth*math.Sin(angle+wingsAngel)
	log.Printf("Calculated x1=%f, y1=%f, x2=%f, y2=%f, ang1=%f, ang2=%f", x1, y1, x2, y2, math.Cos(angle-wingsAngel), math.Cos(angle+wingsAngel))
	return
}

func drawArrows(cr *cairo.Context, startX, startY, endX, endY float64) {
	cr.MoveTo(startX, startY)
	cr.LineTo(endX, endY)

	x1, y1, x2, y2 := calculateArrowPoints(startX, startY, endX, endY, 10)
	cr.MoveTo(endX, endY)
	cr.LineTo(x1, y1)
	cr.MoveTo(endX, endY)
	cr.LineTo(x2, y2)
	cr.Stroke()
}

func drawNumirate(cr *cairo.Context, startX, startY, endX, endY float64) {

	cr.SetSourceRGB(0, 0, 0)

	dx, dy := (endX-startX)/float64(vars.count), (endY-startY)/float64(vars.count)
	for posX, posY, i := startX+dx, startY+dy, vars.start_i; i < vars.count/2; posX, posY, i = posX+dx, posY+dy, i+1 {
		cr.MoveTo(posX-float64(vars.segLen), posY)
		cr.LineTo(posX+float64(vars.segLen), posY)
		cr.MoveTo(posX, posY-float64(vars.segLen))
		cr.LineTo(posX, posY+float64(vars.segLen))
		cr.MoveTo(posX-7*float64(vars.segLen), posY+7*float64(vars.segLen))

		if i%10 == 0 {
			tmp_str_i := strconv.Itoa(i)
			cr.ShowText(tmp_str_i)
		}
	}
	log.Println("Axis enumerated")
	cr.Stroke()

}

func drawAxis(da *gtk.DrawingArea, cr *cairo.Context) {
	cr.SetSourceRGB(0, 0, 0)
	cr.SetLineWidth(1)
	w, h := float64(da.GetAllocatedWidth()), float64(da.GetAllocatedHeight())

	horizontalPadding := w * 0.02
	startX, startY := horizontalPadding, h/2
	endX, endY := w-horizontalPadding, h/2

	drawArrows(cr, startX, startY, endX, endY)
	drawNumirate(cr, startX, startY, endX, endY)

	verticalPadding := h * 0.05
	startX, startY = w/2, h-verticalPadding
	endX, endY = w/2, verticalPadding

	drawArrows(cr, startX, startY, endX, endY)
	drawNumirate(cr, startX, startY, endX, endY)

	log.Printf("Axis rendered: w=%f h=%f hpad=%f\n", w, h, horizontalPadding)
}

func renderGraphic(da *gtk.DrawingArea, cr *cairo.Context) {
	cr.SetSourceRGB(255, 0, 0)
	cr.SetLineWidth(1)
	w, h := float64(da.GetAllocatedWidth()), float64(da.GetAllocatedHeight())

	horizontalPadding := w * 0.02
	verticalPadding := h * 0.05
	startX, endX := horizontalPadding, w-horizontalPadding
	startY, endY := h-verticalPadding, horizontalPadding
	dx, dy := (endX-startX)/float64(vars.count), (endY-startY)/float64(vars.count)

	var x, y float64
	cx, cy := float64(da.GetAllocatedWidth()/2), float64(da.GetAllocatedHeight()/2)
	cr.MoveTo(cx+vars.calculated_points[0].x*dx, cy+vars.calculated_points[0].y*dy)
	for i := 0; i < 100; i++ {
		x, y = vars.calculated_points[i].x, vars.calculated_points[i].y
		x, y = cx+x*dx, cy+y*dy
		cr.LineTo(x, y)
	}
	cr.Stroke()

}

func recalculate_points() {
	if vars.calculated_points == nil {
		vars.calculated_points = make([]struct{ x, y float64 }, 100)
	}
	var phi_value float64
	dist := vars.B - vars.A
	for i := 0; i < 100; i++ {
		phi_value = vars.A + float64(i)/100*dist
		vars.calculated_points[i].x, vars.calculated_points[i].y = vars.f(vars.A, vars.B, vars.a, vars.b, phi_value)
	}
	log.Printf("points recalculated")
}
