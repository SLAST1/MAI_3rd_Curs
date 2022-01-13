import tkinter
import subprocess
from typing import Any


def update(ent1: Any = None, ent2: Any = None) -> None:
    subprocess.run(f'C:/Users/jenja/anaconda3/python.exe C:\\Users\\jenja\\Downloads\\VSC\\computer_graphics\\task_1\\draw.py {ent1.get()} {ent2.get()}')


def main() -> None:
    window = tkinter.Tk()
    window.title("Pishchik Evgenii task 1")
    window.geometry('200x200')

    panel = tkinter.Frame(window, width=200, height=200)
    panel.place(x=0, y=0, width=200, height=200)

    lab1 = tkinter.Label(panel, text='a')
    lab1.place(x=10, y=30, width=5)
    lab2 = tkinter.Label(panel, text='b')
    lab2.place(x=10, y=60, width=5)
    lab3 = tkinter.Label(panel, text='y^2 = x^3 / (a-x), 0<=x<=b')
    lab3.place(x=10, y=85, width=150)
    ent1 = tkinter.Entry(panel, bd=2)
    ent1.place(x=20, y=30, width=100)
    ent2 = tkinter.Entry(panel, bd=2)
    ent2.place(x=20, y=60, width=100)
    but = tkinter.Button(panel, text="отобразить", command=lambda: update(ent1=ent1, ent2=ent2))
    but.place(x=5, y=120, width=100, height=30)

    window.mainloop()


if __name__ == '__main__':
    main()
