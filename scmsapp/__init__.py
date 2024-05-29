from flask import Flask
from scmsapp.secret import SECRET_KEY
app = Flask(__name__)

app.secret_key = SECRET_KEY

# Routes
from scmsapp.route import home
from scmsapp.route import error
from scmsapp.route import attendance
from scmsapp.route import profile_r, manage_user
from scmsapp.route import login
from scmsapp.route import member_dashboard
from scmsapp.route import manage_class_type
from scmsapp.route.timetable import routes
from scmsapp.route import news
from scmsapp.route import manager_report
from scmsapp.route import visitor_timetable
from scmsapp.route import visitor_course_description
from scmsapp.route import manager_pool_lane
from scmsapp.route import membership

from scmsapp.route import instructor_lesson_booking