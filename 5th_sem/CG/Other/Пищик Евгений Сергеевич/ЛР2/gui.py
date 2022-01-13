import tkinter
import subprocess
from typing import NewType, Dict, Any, Tuple, List, Union, Set


def update(ent4, ent5, ent6, ent7, ent8, ent9, ent10, ent11, ent12, ent13) -> None:
    try:
        subprocess.run(f'C:/Users/jenja/anaconda3/python.exe C:\\Users\\jenja\\Downloads\\VSC\\computer_graphics\\cg_exercise_02\\draw.py {ent4.get()} {ent5.get()} {ent6.get()} {ent7.get()} {ent8.get()} {ent9.get()} {ent10.get()} {ent11.get()} {ent12.get()} {ent13.get()}')
    except Exception as _:
        subprocess.run(f'C:/Users/SuperPC/Anaconda3/python.exe C:\\Users\\SuperPC\\Downloads\\VSC\\CG\\cg_exercise_02\\draw.py {ent4.get()} {ent5.get()} {ent6.get()} {ent7.get()} {ent8.get()} {ent9.get()} {ent10.get()} {ent11.get()} {ent12.get()} {ent13.get()}')


def main() -> None:
    WINDOWW = 375
    WINDOWH = 165
    BUTX = 20
    BUTY = 300
    BUTWIDTH = 100
    BUTHEIGHT = 30
    LABX = [(20 + i * 40) for i in range(3)]
    Y = [(20 + i * 40) for i in range(9)]
    LABWIDTH = 25
    ENTWIDTH = 25

    window = tkinter.Tk()
    window.title("task 2")
    window.geometry(f'{WINDOWH}x{WINDOWW}')

    panel = tkinter.Frame(window, width=WINDOWH, height=WINDOWW)
    panel.place(x=0, y=0, width=WINDOWH, height=WINDOWW)

    lab4 = tkinter.Label(panel, text='h')
    lab4.place(x=LABX[0], y=Y[0], width=LABWIDTH)
    lab5 = tkinter.Label(panel, text='n')
    lab5.place(x=LABX[1], y=Y[0], width=LABWIDTH)
    lab6 = tkinter.Label(panel, text='l')
    lab6.place(x=LABX[2], y=Y[0], width=LABWIDTH)
    lab7 = tkinter.Label(panel, text='prjs')
    lab7.place(x=LABX[0], y=Y[2], width=LABWIDTH + 15)
    lab8 = tkinter.Label(panel, text='xs')
    lab8.place(x=LABX[0], y=Y[3], width=LABWIDTH)
    lab9 = tkinter.Label(panel, text='ys')
    lab9.place(x=LABX[1], y=Y[3], width=LABWIDTH)
    lab10 = tkinter.Label(panel, text='zs')
    lab10.place(x=LABX[2], y=Y[3], width=LABWIDTH)
    lab11 = tkinter.Label(panel, text='xa')
    lab11.place(x=LABX[0], y=Y[5], width=LABWIDTH)
    lab12 = tkinter.Label(panel, text='ya')
    lab12.place(x=LABX[1], y=Y[5], width=LABWIDTH)
    lab13 = tkinter.Label(panel, text='za')
    lab13.place(x=LABX[2], y=Y[5], width=LABWIDTH)

    ent4 = tkinter.Entry(panel, bd=2)
    ent4.place(x=LABX[0], y=Y[1], width=ENTWIDTH)
    ent5 = tkinter.Entry(panel, bd=2)
    ent5.place(x=LABX[1], y=Y[1], width=ENTWIDTH)
    ent6 = tkinter.Entry(panel, bd=2)
    ent6.place(x=LABX[2], y=Y[1], width=ENTWIDTH)
    ent7 = tkinter.Entry(panel, bd=2)
    ent7.place(x=LABX[1] + 10, y=Y[2], width=ENTWIDTH)
    ent8 = tkinter.Entry(panel, bd=2)
    ent8.place(x=LABX[0], y=Y[4], width=ENTWIDTH)
    ent9 = tkinter.Entry(panel, bd=2)
    ent9.place(x=LABX[1], y=Y[4], width=ENTWIDTH)
    ent10 = tkinter.Entry(panel, bd=2)
    ent10.place(x=LABX[2], y=Y[4], width=ENTWIDTH)
    ent11 = tkinter.Entry(panel, bd=2)
    ent11.place(x=LABX[0], y=Y[6], width=ENTWIDTH)
    ent12 = tkinter.Entry(panel, bd=2)
    ent12.place(x=LABX[1], y=Y[6], width=ENTWIDTH)
    ent13 = tkinter.Entry(panel, bd=2)
    ent13.place(x=LABX[2], y=Y[6], width=ENTWIDTH)

    ent4.insert(0, "0.5")
    ent5.insert(0, "5")
    ent6.insert(0, "0.5")
    ent7.insert(0, "n")
    ent8.insert(0, "0.8")
    ent9.insert(0, "0.8")
    ent10.insert(0, "0.8")
    ent11.insert(0, "45")
    ent12.insert(0, "30")
    ent13.insert(0, "0")

    but = tkinter.Button(panel, text="отобразить", command=lambda: update(ent4, ent5, ent6, ent7, ent8, ent9, ent10, ent11, ent12, ent13))
    but.place(x=BUTX, y=BUTY, width=BUTWIDTH, height=BUTHEIGHT)

    window.mainloop()


if __name__ == '__main__':
    main()
