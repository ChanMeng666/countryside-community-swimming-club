from scmsapp.model.db import get_cursor
from flask import jsonify, abort
import scmsapp.model.db as db
from datetime import datetime, timedelta


# Modules to handle queries in relation to booking table

# Get all booking class by member id for member
def allBooking_class(member_id):
    today_date = datetime.now().date()
    query = '''SELECT b.id, member_id, class_id, class_name, start_time, t.class_type, i.last_name, i.first_name, b.is_attended
                    FROM booking b
                    INNER JOIN class c ON b.class_id = c.id AND b.member_id = %(member_id)s
                    INNER JOIN class_type t ON t.id = c.class_type
                    INNER JOIN instructor i on i.id = c.instructor_id
                    WHERE start_time > %(today_date)s
                    ORDER BY start_time;'''
    cursor = db.get_cursor()
    cursor.execute(
            query,
            {
                "member_id": member_id,
                "today_date": today_date,
            }
        )
    return cursor.fetchall()

# Update booking class by class id for member
def book_member_class(member_id, class_id):
    today_date = datetime.now().date()
    query = '''INSERT INTO booking(member_id, class_id, create_time, is_attended) 
               VALUES(%(member_id)s,%(class_id)s, %(create_time)s, %(is_attended)s);'''
    class_query = '''UPDATE class SET open_slot = open_slot - 1 WHERE id = %(class_id)s;'''           
    cursor = db.get_cursor()
    cursor.execute(
            class_query,
            {
                "class_id": class_id,
            }
        )
    cursor.execute(
            query,
            {
                "member_id": member_id,
                "class_id": class_id,
                "create_time": today_date,
                "is_attended": "0"
            }
        )
   
    if cursor.rowcount == 1:
        booking_id = cursor.lastrowid
        return jsonify({'success': True, 'member_id': member_id, 'booking_id': booking_id})
    else:
        return jsonify({'success': False, 'error': 'Something went wrong'}), 500 
    
    # Cancel booking class by booking id for member
def cancel_booking(booking_id, class_id):
    query = '''DELETE FROM payment WHERE booking_id = %(booking_id)s;'''
    cursor = db.get_cursor()
    cursor.execute(
            query,
            {
                "booking_id": booking_id,
            }
        )
    query = '''UPDATE class SET open_slot = open_slot + 1 WHERE id = %(class_id)s;'''
    cursor = db.get_cursor()
    cursor.execute(
            query,
            {
                "class_id": class_id,
            }
        )
    query = '''DELETE FROM booking WHERE id = %(booking_id)s;'''
    cursor = db.get_cursor()
    cursor.execute(
            query,
            {
                "booking_id": booking_id,
            }
        )
   
    if cursor.rowcount == 1:
        booking_id = cursor.lastrowid
        return jsonify({'success': True,})
    else:
        return jsonify({'success': False, 'error': 'Something went wrong'}), 500 
    
def cancel_booking_by_classID_memberID(class_id, member_id):
    query = '''UPDATE class SET open_slot = open_slot + 1 WHERE id = %(class_id)s;'''
    cursor = db.get_cursor()
    cursor.execute(
            query,
            {
                "class_id": class_id,
            }
        )
    query = '''DELETE FROM booking WHERE class_id = %(class_id)s and member_id = %(member_id)s;'''
    cursor = db.get_cursor()
    cursor.execute(
            query,
            {
                "member_id": member_id,
                "class_id": class_id
            }
        )
   
    if cursor.rowcount == 1:
        class_id = cursor.lastrowid
        return jsonify({'success': True,})
    else:
        return jsonify({'success': False, 'error': 'Something went wrong'}), 500 
    
# Return a list of bookings of lessons of a given instructor id
# Only return upcoming active bookings 
def get_lesson_booking_by_instructor(instructor_id):
    connection = get_cursor()
    query = """
            SELECT ct.class_name,
            c.start_time,
            c.end_time,
            CONCAT (l.pool_name, ' ', l.lane_name) as location,
            CONCAT (m.first_name, ' ', m.last_name) as member_name,
            b.member_id,
            b.status
            FROM class c
            INNER JOIN class_type ct ON c.class_type = ct.id
            INNER JOIN location l ON c.location_id = l.id
            INNER JOIN booking b ON c.id = b.class_id
            INNER JOIN member m on b.member_id = m.id
            WHERE ct.class_type = %(class_type)s
            AND c.start_time >= %(current_time)s 
            AND c.instructor_id = %(instuctor_id)s
            AND b.status = %(booking_stauts)s
            ORDER BY c.start_time;
            """
    connection.execute(
        query, 
        {
            'class_type': '1-on-1',
            'current_time': datetime.now(),
            'instuctor_id': instructor_id,
            'booking_stauts': 1
        },
        )
    return connection.fetchall()

# Return a list of bookings of lessons of a given instructor id 
# within the given date range.
# All bookings are returned.
def get_lesson_booking_by_instructor_by_date(instructor_id, date_from, date_to):
    # Add an extra day to include the date_to date
    date_to = datetime.strptime(date_to, '%Y-%m-%d') + timedelta(days=1)
    connection = get_cursor()
    query = """
            SELECT ct.class_name,
            c.start_time,
            c.end_time,
            CONCAT (l.pool_name, ' ', l.lane_name) as location,
            CONCAT (m.first_name, ' ', m.last_name) as member_name,
            b.member_id,
            b.status
            FROM class c
            INNER JOIN class_type ct ON c.class_type = ct.id
            INNER JOIN location l ON c.location_id = l.id
            INNER JOIN booking b ON c.id = b.class_id
            INNER JOIN member m on b.member_id = m.id
            WHERE ct.class_type = %(class_type)s
            AND c.start_time >= %(date_from)s
            AND c.start_time < %(date_to)s 
            AND c.instructor_id = %(instuctor_id)s
            ORDER BY c.start_time DESC;
            """
    connection.execute(
        query, 
        {
            'class_type': '1-on-1',
            'instuctor_id': instructor_id,
            'date_from': date_from,
            'date_to': date_to
        },
        )
    return connection.fetchall()

def mark_attendance(member_id,attendance,class_id):
    query = '''UPDATE booking SET is_attended = %(attendance)s WHERE member_id = %(member_id)s and class_id = %(class_id)s;'''
    cursor = db.get_cursor()
    cursor.execute(
            query,
            {
                "attendance": attendance,
                "member_id": member_id,
                "class_id" : class_id
            }
        )
    
    if cursor.rowcount == 1:
        return jsonify({'success': True,})
    else:
        return jsonify({'success': False, 'error': 'Something went wrong'}), 500 