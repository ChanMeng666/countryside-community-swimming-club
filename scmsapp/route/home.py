from scmsapp import app
from flask import render_template
from scmsapp.model import db
import random

# This is the route for the home page
@app.route('/')
def home():
    cursor = db.get_cursor()
    cursor.execute("""SELECT user_id, title, first_name, last_name, position, profile, image from instructor;""")
    instructorsinfo = cursor.fetchall()
    cursor.execute("""SELECT class_type, class_name, description from class_type;""")
    lessonsinfo = cursor.fetchall()
    # make random display
    random.shuffle(instructorsinfo)
    random.shuffle(lessonsinfo)
    return render_template('home/home.html',instructorsinfo = instructorsinfo, lessonsinfo = lessonsinfo)