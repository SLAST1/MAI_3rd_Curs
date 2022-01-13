// writed by Ivan Nedosekov
package main

import (
	"log"
	"math"

	"github.com/gotk3/gotk3/cairo"
	"github.com/gotk3/gotk3/gtk"
)

func drawCanwas(da *gtk.DrawingArea, cr *cairo.Context) {
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

func rotatePoint(angle, cx, cy, x, y float64) (float64, float64) {
	s := math.Sin(angle)
	c := math.Cos(angle)

	// translate point back to origin:
	x -= cx
	y -= cy

	// rotate point
	xnew := x*c - y*s
	ynew := x*s + y*c

	// translate point back:
	x = xnew + cx
	y = ynew + cy
	return x, y
}

func drawAxis(da *gtk.DrawingArea, cr *cairo.Context) {
	cr.SetSourceRGB(0, 0, 0)
	cr.SetLineWidth(1)
	w, h := float64(da.GetAllocatedWidth()), float64(da.GetAllocatedHeight())

	horizontalPadding := w * 0.02
	verticalPadding := h * 0.05

	startX, startY := horizontalPadding, h-verticalPadding
	endX, endY := w-horizontalPadding, h-verticalPadding

	drawArrows(cr, startX, startY, endX, endY)

	startX, startY = horizontalPadding, h-verticalPadding
	endX, endY = horizontalPadding, verticalPadding

	drawArrows(cr, startX, startY, endX, endY)

	startX, startY = horizontalPadding, h-verticalPadding
	endX, endY = rotatePoint(-math.Pi/600, horizontalPadding, h-verticalPadding, (w-horizontalPadding)*1/7, (h-verticalPadding)*1/7)

	drawArrows(cr, startX, startY, endX, endY)

	log.Printf("Axis rendered: w=%f h=%f hpad=%f\n", w, h, horizontalPadding)
}

type Point struct {
	x, y, z float64
}

func draw_figure(da *gtk.DrawingArea, cr *cairo.Context) {

	cr.SetSourceRGB(0, 0, 0)
	cr.SetLineWidth(1)
	w, h := float64(da.GetAllocatedWidth()), float64(da.GetAllocatedHeight())
	cX, cY := w/2, h/2

	//tmp_fig := make([]Edge, len(settings.figure))
	//copy(tmp_fig, settings.figure)

	type args struct{ a, b Edge }
	var planes []args
	for i := 0; i < 8; i += 2 {
		planes = append(planes, args{settings.figure[i], settings.figure[i+1]})
	}
	// donw plane
	planes = append(planes, args{settings.figure[1], settings.figure[5]})
	// upper plane
	planes = append(planes, args{settings.figure[8], settings.figure[9]})
	//log.Println("given figure", settings.figure)

	log.Println("constructed plane by edges")
	for i, p := range planes {
		log.Println("plane", i, p)
	}

	var A, B, C, D float64
	visible_edge := make(map[Edge]struct{})

	for i, plane := range planes {
		A, B, C, D = findPlane(plane.a, plane.b, settings.figure_center)

		if !is_visible(A, B, C, D, settings.figure_center, settings.camera_point) {
			log.Println("Plane", i, A, B, C, D, "skipped")
			continue
		}
		switch i {
		case 5:
			log.Println("Upper visible")
			for j := 8; j < 12; j++ {
				visible_edge[settings.figure[j]] = struct{}{}
			}
		case 4:
			log.Println("Down visible")
			for j := 1; j < 8; j += 2 {
				visible_edge[settings.figure[j]] = struct{}{}
			}
		default:
			log.Println(i, "plane visible")
			j := i * 2
			visible_edge[settings.figure[j]] = struct{}{}
			visible_edge[settings.figure[j+1]] = struct{}{}
			visible_edge[settings.figure[(j+2)%8]] = struct{}{}
			visible_edge[settings.figure[i+8]] = struct{}{}

		}
	}

	tmp_fig := make(map[Edge]Edge)
	for edge := range visible_edge {
		u := edge.u
		v := edge.v
		tmp_fig[edge] = Edge{Point{cX + u.x, cY + u.y, -1}, Point{cX + v.x, cY + v.y, -1}}
	}
	log.Println("Pased norming", tmp_fig)

	for _, edge := range tmp_fig {
		log.Println("Draw edge", edge)
		cr.MoveTo(edge.u.x, edge.u.y)
		cr.LineTo(edge.v.x, edge.v.y)
	}
	cr.Stroke()

}
