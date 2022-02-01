import matplotlib.pyplot as plt
from matplotlib.widgets import TextBox
import numpy as np

def l_mal(n,j,x,list):
    l = 1
    for i in range(n):
        if(i == j):
            continue
        l*=(x - list[i])/(list[j] - list[i])
    return l

def l_big(n,x,listx,listy):
    ans = 0
    for i in range(n):
        ans+=listy[i]*l_mal(n,i,x,listx)
    return ans;

listx = [1,3,4,5.5]
listy = [2,7,1,10]

fig = plt.figure()
fig.subplots_adjust(right=0.7)

x = np.linspace(min(listx), max(listx), 100)
y = [l_big(4,xi,listx,listy) for xi in x]


def update_function(param_name, param_val):
    global listx,listy,x,y
    if param_name[0] == 'x':
        listx[int(param_name[1])] = param_val
    elif param_name[0] == 'y':
        listy[int(param_name[1])] = param_val
    x = np.linspace(min(listx), max(listx), 100)
    y = [l_big(4,xi,listx,listy) for xi in x]
    p.set_xdata(x)
    p.set_ydata(y)
    d.set_xdata(listx)
    d.set_ydata(listy)
    ax.relim()
    ax.autoscale_view()



ax = fig.add_subplot(111)
p, = ax.plot(x, y)
d, = ax.plot(listx,listy,"o")

def submit_fn_x0(value):
    update_function("x0",float(value))
    plt.draw()
axbox_x0 = fig.add_axes([0.75, 0.93, 0.1, 0.05])
text_box_x0 = TextBox(axbox_x0, "x1 ")
text_box_x0.on_submit(submit_fn_x0)
text_box_x0.set_val(listx[0])

def submit_fn_y0(value):
    update_function("y0",float(value))
    plt.draw()
axbox_y0 = fig.add_axes([0.89, 0.93, 0.1, 0.05])
text_box_y0 = TextBox(axbox_y0, "y1 ")
text_box_y0.on_submit(submit_fn_y0)
text_box_y0.set_val(listy[0])

def submit_fn_x1(value):
    update_function("x1",float(value))
    plt.draw()
axbox_x1 = fig.add_axes([0.75, 0.86, 0.1, 0.05])
text_box_x1 = TextBox(axbox_x1, "x2 ")
text_box_x1.on_submit(submit_fn_x1)
text_box_x1.set_val(listx[1])

def submit_fn_y1(value):
    update_function("y1",float(value))
    plt.draw()
axbox_y1 = fig.add_axes([0.89, 0.86, 0.1, 0.05])
text_box_y1 = TextBox(axbox_y1, "y2 ")
text_box_y1.on_submit(submit_fn_y1)
text_box_y1.set_val(listy[1])

def submit_fn_x2(value):
    update_function("x2",float(value))
    plt.draw()
axbox_x2 = fig.add_axes([0.75, 0.79, 0.1, 0.05])
text_box_x2 = TextBox(axbox_x2, "x3 ")
text_box_x2.on_submit(submit_fn_x2)
text_box_x2.set_val(listx[2])

def submit_fn_y2(value):
    update_function("y2",float(value))
    plt.draw()
axbox_y2 = fig.add_axes([0.89, 0.79, 0.1, 0.05])
text_box_y2 = TextBox(axbox_y2, "y3 ")
text_box_y2.on_submit(submit_fn_y2)
text_box_y2.set_val(listy[2])

def submit_fn_x3(value):
    update_function("x3",float(value))
    plt.draw()
axbox_x3 = fig.add_axes([0.75, 0.72, 0.1, 0.05])
text_box_x3 = TextBox(axbox_x3, "x4 ")
text_box_x3.on_submit(submit_fn_x3)
text_box_x3.set_val(listx[3])

def submit_fn_y3(value):
    update_function("y3",float(value))
    plt.draw()
axbox_y3 = fig.add_axes([0.89, 0.72, 0.1, 0.05])
text_box_y3 = TextBox(axbox_y3, "y4 ")
text_box_y3.on_submit(submit_fn_y3)
text_box_y3.set_val(listy[3])

plt.show()