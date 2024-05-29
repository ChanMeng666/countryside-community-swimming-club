from scmsapp import app
from flask import render_template, redirect, url_for, request, session, flash, abort, jsonify
from scmsapp.model.session import allow_role
from scmsapp.model.class_m import get_class_by_type_and_date, all_booking_class_by_instructorID, all_member_booked_in_class,full_booking_class ,booking_class_Upcomming
from scmsapp.model.booking import book_member_class, allBooking_class, mark_attendance
from scmsapp.model.profile import get_member_by_id,get_profiles_by_role

from scmsapp.model import upload
from scmsapp.model import auth, auth_error, upload, user, profile, booking
from scmsapp.model import db
from datetime import datetime


@app.route('/attendance_manager')
def attendance_manager():
    allow_role(['manager'])
    bookingList = booking_class_Upcomming()
    return render_template('attendance/attendance_manager.html',  bookingList=bookingList)

@app.route('/attendance_instructor')
def attendance_instructor():
    allow_role(['instructor'])
    user_id = session['id']
    bookingList = all_booking_class_by_instructorID(user_id)
    return render_template('attendance/attendance_instructor.html',  bookingList=bookingList)


@app.route('/attendance/class/<int:class_id>', methods=['GET', 'POST'])
def attendance_class(class_id):
    allow_role(['instructor','manager'])    
    memberList = all_member_booked_in_class(class_id)
    return render_template('attendance/class_all_members.html',  memberList=memberList)


@app.route('/save_attendance', methods=['POST'])
def save_attendance():
    allow_role(['instructor','manager'])
    attendance_data = request.form
    class_id = request.form.get('classID')
    for member_id, attendance in attendance_data.items():
        if member_id.isdigit():
            mark_attendance(member_id, attendance,class_id )
    role = session['role']
    if role =="instructor":
        return redirect("/attendance_instructor")
    elif role =="manager":
        return redirect("/attendance_manager")
    

@app.route('/lesson-bookings/all')
def view_all_bookings_attendance():
    allow_role(['manager'])
    bookingList = full_booking_class()
    return render_template('attendance/attendance_manager.html',  bookingList=bookingList)