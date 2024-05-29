import mysql.connector
from flask import render_template, request, redirect, url_for, flash, jsonify
from scmsapp import app
from datetime import datetime, timedelta
from scmsapp.model.db import get_cursor
# from scmsapp.route.timetable.timetable_data import get_timetable_context
from scmsapp.route.timetable.search import search_classes
from scmsapp.route.timetable.formatters import format_datetime_for_input


@app.route('/home/timetable', methods=['GET', 'POST'])
def v_timetable():
    # if request.method == 'POST':
    #     results = search_aqua_aerobics_classes()
    # else:
    results = []
    context = get_timetable_context(request.form.get('date'))
    context['results'] = results  # Adding search results to a context
    return render_template('visitor/timetable.html', **context)
# Search for classes


def get_timetable_context(selected_date_str=None):
    if selected_date_str is None:
        selected_date_str = datetime.today().strftime('%Y-%m-%d')
    selected_date = datetime.strptime(selected_date_str, '%Y-%m-%d')

    week_start = selected_date - timedelta(days=selected_date.weekday())
    week_end = week_start + timedelta(days=7)

    cursor = get_cursor()

    # Fetch instructors, locations, and class types for the dropdowns
    cursor.execute("SELECT id, title, first_name, last_name, position FROM instructor")
    instructors = cursor.fetchall()

    cursor.execute("SELECT id, pool_name, lane_name FROM location")
    locations = cursor.fetchall()

    cursor.execute("""
                        SELECT id, class_type, class_name FROM class_type 
                        WHERE class_type = 'class'""")
    class_types = cursor.fetchall()

    # Fetch classes with additional details
    classes_with_details = fetch_classes_for_week_with_details(week_start, week_end)

    # Format start_time and end_time for HTML datetime-local input
    for class_detail in classes_with_details:
        class_detail['formatted_start_time'] = format_datetime_for_input(class_detail['start_time'])
        class_detail['formatted_end_time'] = format_datetime_for_input(class_detail['end_time'])

    week_dates = [(week_start + timedelta(days=i)) for i in range(7)]


    return {
        'classes': classes_with_details,
        'week_dates': week_dates,
        'selected_date': selected_date,
        'instructors': instructors,
        'locations': locations,
        'class_types': class_types,
        'selected_week': selected_date_str
    }


def fetch_classes_for_week_with_details(start_date, end_date):
    cursor = get_cursor()
    cursor.execute("""
        SELECT class.id, class.instructor_id, class.location_id, class.class_type, class.start_time, class.end_time, class.open_slot,
               instructor.title AS instructor_title, instructor.first_name, instructor.last_name, instructor.position,
               location.pool_name, location.lane_name,
               class_type.class_type AS type, class_type.class_name
        FROM class
        INNER JOIN instructor ON class.instructor_id = instructor.id
        INNER JOIN location ON class.location_id = location.id
        INNER JOIN class_type ON class.class_type = class_type.id
        WHERE class.start_time >= %s AND class.start_time < %s AND class_type.class_type = %s
        ORDER BY class.start_time ASC;
    """, (start_date.strftime('%Y-%m-%d'), end_date.strftime('%Y-%m-%d'), "class"))
    classes_with_details = cursor.fetchall()
    print(classes_with_details)

    cursor.close()
    return classes_with_details
