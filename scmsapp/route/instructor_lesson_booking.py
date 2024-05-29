from scmsapp import app
from flask import render_template, redirect, url_for, request, session, flash, abort, jsonify
from scmsapp.model.session import allow_role
from scmsapp.model import profile, booking, date_time_utils

# This module handles routes for instructor view lesson booking

# Route to view a list of upcoming lesson bookings of current instructor user
@app.route('/lesson-bookings')
def view_lesson_bookings():
    # Only insturctor can access
    allow_role(['instructor'])
    # Get currenct instrucotr id
    instructor_id = profile.get_profile_by_user_id(session['id'])['id']
    bookings = booking.get_lesson_booking_by_instructor(instructor_id)
    return render_template('instructor-view-booking/lesson-booking.html', bookings=bookings)

# Route to view a list of all lesson bookings of current instructor user
@app.route('/all-lesson-bookings')
def view_all_lesson_bookings():
    # Only insturctor can access
    allow_role(['instructor'])
    # Fetch date range
    date_from = request.args.get('date_from')
    date_to = request.args.get('date_to')
    if not (date_from and date_to):
        date_from, date_to = date_time_utils.get_current_month_date_range()
    # Get currenct instrucotr id
    instructor_id = profile.get_profile_by_user_id(session['id'])['id']
    bookings = booking.get_lesson_booking_by_instructor_by_date(instructor_id, date_from, date_to)
    return render_template('instructor-view-booking/all-lesson-booking.html', bookings=bookings, date_from=date_from, date_to=date_to)


# Route to view member profile from booking
@app.route('/lesson-booking/member/<int:member_id>')
def view_lesson_booking_member(member_id):
    # Only insturctor can access
    allow_role(['instructor'])
    member = profile.get_member_by_id(member_id)
    if member:
        return render_template('instructor-view-booking/lesson-booking-member.html', member=member)
    else:
        return jsonify({"error": "Member not found"}), 404