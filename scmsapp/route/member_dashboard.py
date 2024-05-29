from scmsapp import app
from flask import render_template, redirect, url_for, request, session, flash, abort, jsonify
from scmsapp.model.session import allow_role
from scmsapp.model.class_m import get_class_by_type_and_date
from scmsapp.model.booking import book_member_class, allBooking_class, cancel_booking, cancel_booking_by_classID_memberID
from scmsapp.model.profile import get_member_by_id,get_profiles_by_role
from scmsapp.model.membership import add_payment_data, update_payment_data, valid_member_membership
from scmsapp.model import auth, auth_error, upload, user, profile, booking
from scmsapp.model import db
from datetime import datetime
import json

@app.route('/instructor-profile/<int:id>')
def memebr_instructor_profile(id):
    allow_role(['member'])
    today_date = datetime.now().date()
    instructor = profile.get_instructor_by_id(id)
    connection = db.get_cursor()
    connection.execute("""SELECT c.id, create_time, t.class_type,class_name, description, start_time, end_time, c.open_slot,
                  (CASE WHEN b.member_id = %s THEN TRUE ELSE FALSE END) AS is_booked_by_user
                    FROM class c
                    left JOIN booking b ON b.class_id = c.id AND b.member_id = %s
                    Inner JOIN class_type t ON t.id = c.class_type
                    where c.instructor_id = %s
                    AND t.class_type = "class"
                    AND start_time > %s;""",(session["user_id"],session["user_id"],id,today_date,))
    groupClassList = connection.fetchall()  
    sorted_groupClassList = sorted(groupClassList, key=lambda x: x['start_time'])
    connection.execute("""SELECT c.id, create_time, t.class_type,class_name, description, start_time, end_time, c.open_slot,
                    (CASE WHEN b.member_id = %s THEN TRUE ELSE FALSE END) AS is_booked_by_user
                    FROM class c
                    left JOIN booking b ON b.class_id = c.id AND b.member_id = %s
                    Inner JOIN class_type t ON t.id = c.class_type
                    where c.instructor_id = %s
                    AND t.class_type = "1-on-1"
                    AND start_time > %s;""",(session["user_id"],session["user_id"],id,today_date,))
    oneOnOneList = connection.fetchall()
    sorted_oneOnOneList = sorted(oneOnOneList, key=lambda x: x['start_time'])
    member_id = session['id']
    user = get_member_by_id(member_id)
    return render_template('member/instructor-classInfo.html',  profile=instructor, groupClassList=sorted_groupClassList, oneOnOneList=sorted_oneOnOneList, user=user)

@app.route('/member/booking')
def member_booking():
    allow_role(['member'])
    member_id = session['id']
    bookingList = allBooking_class(member_id)
    user = get_member_by_id(member_id)
    return render_template('member/member-booking.html',  bookingList=bookingList, user=user)

@app.route('/member/instructors')
def member_instructors():

    allow_role(['member'])
    member_id = session['id']
    instructorsList = get_profiles_by_role('instructor')
    user = get_member_by_id(member_id)
    return render_template('member/instructors.html',  instructorsList=instructorsList, user=user)

@app.route('/member/book', methods=['GET', 'POST'])
def member_book_class():
    allow_role(['member'])
    member_id =  request.form.get('memberID')
    class_id =  request.form.get('classID')
    if valid_member_membership(member_id):
        return book_member_class(member_id, class_id)
    else:
        return jsonify({'success': False, 'error': 'Something went wrong'}), 500


@app.route('/member/payment', methods=['GET', 'POST'])
def class_payment():
    allow_role(['member'])
    member_id = session['id']
    connection = db.get_cursor()
    connection.execute("""SELECT * from product where product_name='1-on-1 Lesson' ;""")
    product = connection.fetchone()
    product_id = product['id']
    price = product['price']
    class_id = request.form.get('paymentClassID')
    book_result = book_member_class(member_id, class_id)
    print(book_result)
    book_result_data = json.loads(book_result.get_data(as_text=True))
    print(book_result_data)
    booking_id = book_result_data["booking_id"]
    print(booking_id)
    result = add_payment_data(member_id, product_id, price, booking_id)
    result_data = json.loads(result.get_data(as_text=True))
    payment_id = result_data["payment_id"]
    return update_payment_data(member_id, payment_id, product_id)
    


@app.route('/member/cancelBooking', methods=['GET', 'POST'])
def cancel_member_booking():
    allow_role(['member'])
    print(request.form)
    if request.form.get('bookID'):
        book_id = request.form.get('bookID')
        class_id = request.form.get('classID')
        return cancel_booking(book_id, class_id)
    elif request.form.get('cancelclassID'):
        class_id = request.form.get('cancelclassID')
        member_id = session['id']
        return cancel_booking_by_classID_memberID(class_id, member_id)