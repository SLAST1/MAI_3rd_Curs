// writed by Ivan Nedosekov
package main

import (
	"log"
	"strconv"

	"github.com/gotk3/gotk3/gtk"
)

func parse_a(entry *gtk.Entry) {
	str, err := entry.GetText()
	if err != nil {
		log.Fatal("Cant get text grom entry", err)
	}
	tmp, err := strconv.ParseFloat(str, 64)
	if err != nil {
		log.Print("Cant parse float", err)
		return
	}
	if tmp >= vars.b {
		log.Printf("Logic error a (get %f) must be less b=%f", tmp, vars.b)
		return
	}
	recalculate_points()
	vars.a = tmp
}

func parse_A(entry *gtk.Entry) {
	str, err := entry.GetText()
	if err != nil {
		log.Fatal("Cant get text grom entry", err)
	}
	tmp, err := strconv.ParseFloat(str, 64)
	if err != nil {
		log.Print("Cant parse float", err)
		return
	}
	if tmp > vars.B {
		log.Printf("Logic error A (get %f) must be less or equal B=%f", tmp, vars.B)
		return
	}
	vars.A = tmp
	recalculate_points()
	log.Printf("A %f", vars.A)
}

func parse_b(entry *gtk.Entry) {
	str, err := entry.GetText()
	if err != nil {
		log.Fatal("Cant get text grom entry", err)
	}
	tmp, err := strconv.ParseFloat(str, 64)
	if err != nil {
		log.Print("Cant parse float", err)
		return
	}
	if vars.a > tmp {
		log.Printf("Logic error a=%f must be less or equal b (get %f)", vars.a, tmp)
		return
	}
	vars.b = tmp
	recalculate_points()
	log.Printf("b %f", vars.b)
}

func parse_B(entry *gtk.Entry) {
	str, err := entry.GetText()
	if err != nil {
		log.Fatal("Cant get text grom entry", err)
	}
	tmp, err := strconv.ParseFloat(str, 64)
	if err != nil {
		log.Print("Cant parse float", err)
		return
	}
	if vars.A > tmp {
		log.Printf("Logic error A=%f must be less or equal B (get %f)", vars.A, tmp)
		return
	}
	vars.B = tmp
	recalculate_points()
}
