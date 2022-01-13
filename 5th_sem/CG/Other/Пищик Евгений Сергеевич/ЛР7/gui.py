import tkinter
import subprocess


def update(ent1, ent2, ent3, ent4, ent5, ent6, ent7, ent8, ent9, ent10, ent11, ent12):
    try:
        subprocess.run(f'C:/Users/jenja/anaconda3/python.exe C:\\Users\\jenja\\Downloads\\VSC\\computer_graphics\\task_7\\draw.py {ent1.get()} {ent2.get()} {ent3.get()} {ent4.get()} {ent5.get()} {ent6.get()} {ent7.get()} {ent8.get()} {ent9.get()} {ent10.get()} {ent11.get()} {ent12.get()}')
    except Exception as _:
        subprocess.run(f'C:\\Users\\SuperPC\\anaconda3\\envs\\p39\\python.exe C:\\Users\\SuperPC\\Downloads\\VSC\\CG\\cg_exercise_07\\draw.py {ent1.get()} {ent2.get()} {ent3.get()} {ent4.get()} {ent5.get()} {ent6.get()} {ent7.get()} {ent8.get()} {ent9.get()} {ent10.get()} {ent11.get()} {ent12.get()}')


def main():
    window = tkinter.Tk()
    window.title("task 7")
    window.geometry('200x500')

    HL0 = 30
    XL1 = 20
    WL1 = 15
    XL2 = 40
    WL2 = 100
    Y = [30 + i * 30 for i in range(13)]
    PARR = ((25, 50), (50, 145), (75, 128), (100, 250), (125, 375), (150, 250))

    panel = tkinter.Frame(window, width=200, height=500)
    panel.place(x=0, y=0, width=200, height=500)

    lab1 = tkinter.Label(panel, text='x1')
    lab1.place(x=XL1, y=Y[0], width=WL1)
    lab2 = tkinter.Label(panel, text='y1')
    lab2.place(x=XL1, y=Y[1], width=WL1)
    lab3 = tkinter.Label(panel, text='x2')
    lab3.place(x=XL1, y=Y[2], width=WL1)
    lab4 = tkinter.Label(panel, text='y2')
    lab4.place(x=XL1, y=Y[3], width=WL1)
    lab5 = tkinter.Label(panel, text='x3')
    lab5.place(x=XL1, y=Y[4], width=WL1)
    lab6 = tkinter.Label(panel, text='y3')
    lab6.place(x=XL1, y=Y[5], width=WL1)
    lab7 = tkinter.Label(panel, text='x4')
    lab7.place(x=XL1, y=Y[6], width=WL1)
    lab8 = tkinter.Label(panel, text='y4')
    lab8.place(x=XL1, y=Y[7], width=WL1)
    lab9 = tkinter.Label(panel, text='x5')
    lab9.place(x=XL1, y=Y[8], width=WL1)
    lab10 = tkinter.Label(panel, text='y5')
    lab10.place(x=XL1, y=Y[9], width=WL1)
    lab11 = tkinter.Label(panel, text='x6')
    lab11.place(x=XL1, y=Y[10], width=WL1)
    lab12 = tkinter.Label(panel, text='y6')
    lab12.place(x=XL1, y=Y[11], width=WL1)

    ent1 = tkinter.Entry(panel, bd=2)
    ent1.place(x=XL2, y=Y[0], width=WL2)
    ent1.insert(0, f'{PARR[0][0]}')
    ent2 = tkinter.Entry(panel, bd=2)
    ent2.place(x=XL2, y=Y[1], width=WL2)
    ent2.insert(0, f'{PARR[0][1]}')
    ent3 = tkinter.Entry(panel, bd=2)
    ent3.place(x=XL2, y=Y[2], width=WL2)
    ent3.insert(0, f'{PARR[1][0]}')
    ent4 = tkinter.Entry(panel, bd=2)
    ent4.place(x=XL2, y=Y[3], width=WL2)
    ent4.insert(0, f'{PARR[1][1]}')
    ent5 = tkinter.Entry(panel, bd=2)
    ent5.place(x=XL2, y=Y[4], width=WL2)
    ent5.insert(0, f'{PARR[2][0]}')
    ent6 = tkinter.Entry(panel, bd=2)
    ent6.place(x=XL2, y=Y[5], width=WL2)
    ent6.insert(0, f'{PARR[2][1]}')
    ent7 = tkinter.Entry(panel, bd=2)
    ent7.place(x=XL2, y=Y[6], width=WL2)
    ent7.insert(0, f'{PARR[3][0]}')
    ent8 = tkinter.Entry(panel, bd=2)
    ent8.place(x=XL2, y=Y[7], width=WL2)
    ent8.insert(0, f'{PARR[3][1]}')
    ent9 = tkinter.Entry(panel, bd=2)
    ent9.place(x=XL2, y=Y[8], width=WL2)
    ent9.insert(0, f'{PARR[4][0]}')
    ent10 = tkinter.Entry(panel, bd=2)
    ent10.place(x=XL2, y=Y[9], width=WL2)
    ent10.insert(0, f'{PARR[4][1]}')
    ent11 = tkinter.Entry(panel, bd=2)
    ent11.place(x=XL2, y=Y[10], width=WL2)
    ent11.insert(0, f'{PARR[5][0]}')
    ent12 = tkinter.Entry(panel, bd=2)
    ent12.place(x=XL2, y=Y[11], width=WL2)
    ent12.insert(0, f'{PARR[5][1]}')

    but = tkinter.Button(panel, text="отобразить", command=lambda: update(ent1=ent1, ent2=ent2, ent3=ent3, ent4=ent4, ent5=ent5, ent6=ent6, ent7=ent7, ent8=ent8, ent9=ent9, ent10=ent10, ent11=ent11, ent12=ent12))
    but.place(x=XL1, y=Y[12], width=WL2, height=HL0)

    window.mainloop()


if __name__ == '__main__':
    main()
