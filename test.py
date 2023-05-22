import numpy as np
import matplotlib.pyplot as plt
import matplotlib.animation as animation
from random import choices

n = 10  # Number of elements in vector v
R = 5  # Increment
v = np.random.randint(1, 10, n)  # Initializing v with random values
MEV = 3

fig, ax = plt.subplots()
ax.axis('equal')  # Equal aspect ratio ensures that pie is drawn as a circle.

def update(num):
    if num % 10 == 0:  # Print 1 every 10 frames
        ax.clear()  # Clear the previous pie chart
        idx = choices(range(n), weights=v/np.sum(v), k=1)[0]  # Select index according to probability distribution
        if idx==1:
            v[idx] += MEV # Update the selected index
        v[idx] += R  # Update the selected index
        ax.pie(v, labels=range(n), autopct='%1.1f%%')  # Draw the new pie chart

ani = animation.FuncAnimation(fig, update, frames=20000, repeat=True)  # Increase frames to 1000
ani.save('pie_chart_animation.mp4', writer=animation.FFMpegWriter(fps=1000))  # Save the animation as a mp4 video

