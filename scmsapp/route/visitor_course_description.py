from flask import render_template, request, redirect, url_for, flash, jsonify
from scmsapp import app
from scmsapp.model.db import get_cursor
from scmsapp.model import auth, auth_error, upload, user, profile


@app.route('/home/description', methods=['GET', 'POST'])
def course_description():
    cursor = get_cursor()
    cursor.execute("""  SELECT DISTINCT class_type.id, class_type.class_type, class_type.class_name,class_type.description,class.class_type, instructor.id, instructor.last_name, instructor.first_name 
                        FROM class_type
                        LEFT JOIN class ON class_type.id = class.class_type
                        LEFT JOIN instructor ON class.instructor_id = instructor.id
                        WHERE class_type.class_type = %s;""",('class',))
    description = cursor.fetchall()
    cursor.close()
    return render_template('visitor/course_description.html', description=description)


@app.route('/instructor_profile/<int:id>')
def visitor_instructor_profile(id):
    instructor = profile.get_instructor_by_id(id)
    return render_template('visitor/instructor_profile.html', profile=instructor)