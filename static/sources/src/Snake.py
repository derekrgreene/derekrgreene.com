import turtle
import time
import random

delay = 0.1
score = 0
highScore = 0

wn = turtle.Screen()
wn.title("Snake Game by Derek Greene")
wn.bgcolor("light grey")
wn.setup(width=600, height=600)
wn.tracer(0)
colors = ["blue", "medium blue", "navy", "dark blue", "midnight blue", "deep sky blue", "cyan", "dark turquoise", "turquoise", "medium turquoise", "dark cyan", "teal","aquamarine", 
        "medium aquamarine", "gold", "pale green", "light green", "medium spring green", "spring green", "lime green", "green yellow", "chartreuse", "lawn green", "lime", 
        "yellow green","pink", "hot pink", "deep pink", "medium violet red", "purple", "dark magenta", "magenta", "dark orchid", "dark violet", "blue violet", "indigo"]
head = turtle.Turtle()
head.speed(0)
head.shape("circle")
head.color("black")
head.penup()
head.goto(0,0)
head.direction = "stop"
food = turtle.Turtle()
food.speed(0)
food.shape("turtle")
random.shuffle(colors)
food.color(colors[0])
food.penup()
food.goto(0,100)
segments = []
pen = turtle.Turtle()
pen.speed(0)
pen.shape("circle")
pen.color("grey")
pen.penup()
pen.hideturtle()
pen.goto(0, 260)
pen.write("Score: 0             High Score: 0", align="center", font=("Comic sans", 24, "normal"))

def up():
    if head.direction != "down":
        head.direction = "up"

def down():
    if head.direction != "up":
        head.direction = "down"

def left():
    if head.direction != "right":
        head.direction = "left"

def right():
    if head.direction != "left":
        head.direction = "right"

def move():
    if head.direction == "up":
        y = head.ycor()
        head.sety(y + 20)
    if head.direction == "down":
        y = head.ycor()
        head.sety(y - 20)
    if head.direction == "left":
        x = head.xcor()
        head.setx(x - 20)
    if head.direction == "right":
        x = head.xcor()
        head.setx(x + 20)
        
wn.listen()
wn.onkeypress(up, "Up")
wn.onkeypress(down, "Down")
wn.onkeypress(left, "Left")
wn.onkeypress(right, "Right")

while True:
    wn.update()
    if head.xcor()>290 or head.xcor()<-290 or head.ycor()>290 or head.ycor()<-290:
        time.sleep(1)
        head.goto(0,0)
        head.direction = "stop"
        for segment in segments:
            segment.goto(1000, 1000) 
        segments.clear()
        score = 0
        delay = 0.1
        pen.clear()
        pen.write("Score: {}               High Score: {}".format(score, highScore), align="center", font=("Comic sans", 24, "normal")) 
    if head.distance(food) < 20:
        x = random.randint(-270, 270)
        y = random.randint(-270, 270)
        new_segment = turtle.Turtle()
        new_segment.speed(0)
        new_segment.shape("circle")
        new_segment.color(colors[0])
        random.shuffle(colors)
        food.color(colors[0])
        food.goto(x,y) 
        new_segment.penup()
        segments.append(new_segment)
        delay -= 0.001
        score += 10
        if score > highScore:
            highScore = score
        pen.clear()
        pen.write("Score: {}            High Score: {}".format(score, highScore), align="center", font=("Comic sans", 24, "normal")) 
    for index in range(len(segments)-1, 0, -1):
        x = segments[index-1].xcor()
        y = segments[index-1].ycor()
        segments[index].goto(x, y)
    if len(segments) > 0:
        x = head.xcor()
        y = head.ycor()
        segments[0].goto(x,y)
    move()    
    for segment in segments:
        if segment.distance(head) < 20:
            time.sleep(1)
            head.goto(0,0)
            head.direction = "stop"
            for segment in segments:
                segment.goto(1000, 1000)
            segments.clear()
            score = 0
            delay = 0.1
            pen.clear()
            pen.write("Score: {}            High Score: {}".format(score, highScore), align="center", font=("Comic sans", 24, "normal"))
    time.sleep(delay)