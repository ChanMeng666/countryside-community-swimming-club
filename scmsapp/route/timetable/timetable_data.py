from datetime import datetime, timedelta
from .database_utils import get_cursor, fetch_classes_for_week_with_details
from .formatters import format_datetime_for_input
from scmsapp.model.db import get_cursor
from .database_utils import fetch_classes_for_week_with_details_for_instructor,fetch_all_group_class_with_details
from scmsapp.model.booking import allBooking_class
from scmsapp.model.profile import get_member_by_id
from flask import session


# Fetches the data needed to render the timetable page
def get_timetable_context(selected_date_str=None, instructor_id=None):
    if selected_date_str is None:
        selected_date_str = datetime.today().strftime('%Y-%m-%d')
    selected_date = datetime.strptime(selected_date_str, '%Y-%m-%d')

    # week_start = selected_date - timedelta(days=selected_date.weekday())
    # week_end = week_start + timedelta(days=7)

    # member timetable
    week_start = selected_date 
    week_end = week_start + timedelta(days=7)

    cursor = get_cursor()

    # Fetch instructors, locations, and class types for the dropdowns
    cursor.execute("SELECT id, title, first_name, last_name, position FROM instructor")
    instructors = cursor.fetchall()

    cursor.execute("SELECT id, pool_name, lane_name FROM location")
    locations = cursor.fetchall()

    cursor.execute("SELECT id, class_type, class_name FROM class_type")
    class_types = cursor.fetchall()

    # Fetch classes with additional details
    # classes_with_details = fetch_classes_for_week_with_details(week_start, week_end)
    if instructor_id:
        classes_with_details = fetch_classes_for_week_with_details_for_instructor(week_start, week_end, instructor_id)
    elif session['role'] == 'member':
        classes_with_details = fetch_all_group_class_with_details (week_start, week_end)
    else:
        classes_with_details = fetch_classes_for_week_with_details(week_start, week_end)

    # Format start_time and end_time for HTML datetime-local input
    for class_detail in classes_with_details:
        class_detail['formatted_start_time'] = format_datetime_for_input(class_detail['start_time'])
        class_detail['formatted_end_time'] = format_datetime_for_input(class_detail['end_time'])

    week_dates = [(week_start + timedelta(days=i)) for i in range(7)]

    today_date = datetime.now()

    if session['role'] == 'member':
        member_id=session['id']
        booking = allBooking_class(member_id)
        user = get_member_by_id(member_id)
        class_booking_status = {}
        for c in classes_with_details:
            class_booking_status[c['id']] = any(b.get('class_id')  == c['id'] for b in booking)
        return {
        'classes': classes_with_details,
        'week_dates': week_dates,
        'booking': booking,
        'selected_week': selected_date_str,
        'selected_date': selected_date,
        'class_booking_status': class_booking_status,
        'today_date' : today_date,
        'user':user
        }
    else:
        return {
            'classes': classes_with_details,
            'week_dates': week_dates,
            'selected_date': selected_date,
            'instructors': instructors,
            'locations': locations,
            'class_types': class_types,
            'selected_week': selected_date_str
        }