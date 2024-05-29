from scmsapp.model.db import get_cursor
from flask import jsonify, abort
from datetime import datetime

# Modules to handle queries in relation to calss table

# Return classes of a class type within given date range
def get_class_by_type_and_date(class_type, date_from, date_to):
    connection = get_cursor()
    query = """
            SELECT c.*, 
            ct.class_type as type,
            ct.class_name,
            ct.description
            FROM class AS c
            INNER JOIN class_type as ct
            ON c.class_type = ct.id
            WHERE ct.class_type = %(class_type)s 
            AND c.start_time >= %(date_from)s AND c.start_time <= %(date_to)s;
            """
    connection.execute(
        query, 
        {
            'date_from': date_from,
            'date_to': date_to,
            'class_type': class_type

        },
        )
    return connection.fetchall()

# Return classes of a class type by an instructor within given date range
def get_class_by_type_instructor_and_date(class_type, instrcutor_id, date_from, date_to):
    connection = get_cursor()
    query = """
            SELECT c.*, 
            ct.class_type as type,
            ct.class_name,
            ct.description
            FROM class AS c
            INNER JOIN class_type as ct
            ON c.class_type = ct.id
            WHERE c.instructor_id = %(instructor_id)s 
            AND ct.class_type = %(class_type)s
            AND c.start_time >= %(date_from)s 
            AND c.start_time <= %(date_to)s;
            """
    connection.execute(
        query, 
        {
            'date_from': date_from,
            'date_to': date_to,
            'instrcutor_id': instrcutor_id,
            'class_type': class_type
        },
        )
    return connection.fetchall()

# Return a class by class id, can be any type of classes/lessons
def get_class_by_id(class_id):
    connection = get_cursor()
    query = """
            SELECT c.*, 
            ct.class_type as type,
            ct.class_name,
            ct.description,
            CONCAT (i.first_name, ' ', i.last_name) as instructor,
            CONCAT (IFNULL(l.pool_name, ''), ' ', IFNULL(l.lane_name, '')) as location
            FROM class AS c
            INNER JOIN class_type AS ct ON c.class_type = ct.id
            INNER JOIN instructor AS i on c.instructor_id = i.id
            INNER JOIN location AS l on c.location_id = l.id
            WHERE c.id=%(class_id)s;
            """
    connection.execute(
        query, 
        {
            'class_id': class_id

        },
        )
    return connection.fetchone()

# Update a class by id, can be any type of classes/lessons
def update_class_by_id(
        id, 
        instructor_id, 
        location_id, 
        class_type, 
        start_time, 
        end_time, 
        open_slot, 
        status
):
    connection = get_cursor()
    query = """
            UPDATE class
            SET instructor_id = %(instructor_id)s,
            location_id = %(location_id)s,
            class_type = %(class_type)s,
            start_time = %(start_time)s,
            end_time = %(end_time)s,
            open_slot = %(open_slot)s,
            status = %(status)s
            WHERE id = %(id)s;
            """
    connection.execute(
        query, 
        {
            'id': id, 
            'instructor_id': instructor_id, 
            'location_id': location_id, 
            'class_type': class_type, 
            'start_time': start_time, 
            'end_time': end_time, 
            'open_slot': open_slot, 
            'status': status
        },
        )
    if connection.rowcount == 1:
        return jsonify({'message': 'success'})
    else:
        return jsonify({'error': 'Something went wrong'}), 500

# Add a class, can be any type of classes/lessons
def add_class(
        instructor_id, 
        location_id, 
        class_type, 
        start_time, 
        end_time, 
        open_slot
):
    connection = get_cursor()
    query = """
            INSERT INTO class
            (instructor_id,
            location_id,
            class_type,
            start_time,
            end_time,
            open_slot)
            VALUES
            (%(instructor_id)s,
            %(location_id)s,
            %(class_type)s,
            %(start_time)s,
            %(end_time)s,
            %(open_slot)s);
            """
    connection.execute(
        query, 
        {
            'instructor_id': instructor_id, 
            'location_id': location_id, 
            'class_type': class_type, 
            'start_time': start_time, 
            'end_time': end_time, 
            'open_slot': open_slot
        },
        )
    if connection.rowcount == 1:
        return jsonify({'message': 'success'})
    else:
        return jsonify({'error': 'Something went wrong'}), 500 
    

def all_booking_class_by_instructorID(id):
    today_date = datetime.now().date()
    query = '''SELECT t.class_name,c.id,c.start_time,c.end_time,l.pool_name,c.open_slot, i.first_name, i.last_name, t.class_type
                    FROM class c
                    INNER JOIN class_type t ON t.id = c.class_type
                    INNER JOIN location l ON l.id = c.location_id
                    INNER JOIN instructor i on c.instructor_id = i.id
                    WHERE start_time > %(today_date)s and c.instructor_id = %(id)s
                    ORDER BY start_time;'''
    cursor = get_cursor()
    cursor.execute(
            query,
            {
                "id": id,
                "today_date": today_date,
            }
        )
    return cursor.fetchall()

def all_member_booked_in_class(class_id):
    query = '''SELECT *
                    FROM booking b
                    INNER JOIN member m ON m.user_id = b.member_id
                    WHERE class_id = %(class_id)s;'''
    cursor = get_cursor()
    cursor.execute(
            query,
            {
                "class_id": class_id,
            }
        )
    return cursor.fetchall()


def full_booking_class():
    query = '''SELECT t.class_name,c.id,c.start_time,c.end_time,l.pool_name,c.open_slot, i.first_name, i.last_name, t.class_type
                    FROM class c
                    INNER JOIN class_type t ON t.id = c.class_type
                    INNER JOIN location l ON l.id = c.location_id
                    INNER JOIN instructor i on c.instructor_id = i.id
                    ORDER BY start_time;'''
    cursor = get_cursor()
    cursor.execute(
            query,
        )
    return cursor.fetchall()

def  booking_class_Upcomming():
    today_date = datetime.now().date()
    query = '''SELECT t.class_name,c.id,c.start_time,c.end_time,l.pool_name,c.open_slot, i.first_name, i.last_name, t.class_type
                    FROM class c
                    INNER JOIN class_type t ON t.id = c.class_type
                    INNER JOIN location l ON l.id = c.location_id
                    INNER JOIN instructor i on c.instructor_id = i.id
                    AND c.start_time >= %(today_date)s 
                    ORDER BY start_time;'''
    cursor = get_cursor()
    cursor.execute(
            query,
            {
            "today_date":today_date,
            }
        )
    return cursor.fetchall()