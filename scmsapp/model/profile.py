from scmsapp.model.db import get_cursor
from flask import jsonify, abort

# This module handles database interactions related to user profile

# Get the user profile by user id, retrun as a dictionary 
def get_profile_by_user_id(user_id):
    # Check user role first 
    query = """SELECT role 
            FROM user 
            WHERE id = %(user_id)s
            """
    connection = get_cursor()
    connection.execute(
        query, 
        {
            "user_id": user_id
        },
        )
    role = connection.fetchone()['role']
    user_profile = None
    if role == 'member':
        query = """SELECT * 
            FROM member 
            WHERE id = %(user_id)s
            """
        connection.execute(
        query, 
        {
            "user_id": user_id
        },
        )
        user_profile = connection.fetchone()
    elif role == 'instructor':
        query = """SELECT * 
            FROM instructor 
            WHERE id = %(user_id)s
            """
        connection.execute(
        query, 
        {
            "user_id": user_id
        },
        )
        user_profile = connection.fetchone()
    elif role == 'manager':
        query = """SELECT * 
            FROM manager 
            WHERE id = %(user_id)s
            """
        connection.execute(
        query, 
        {
            "user_id": user_id
        },
        )
        user_profile = connection.fetchone()
    return user_profile

# Get the user profile by user id and user role, retrun as a dictionary
def get_profile_by_user_id_role(user_id, role):
    connection = get_cursor()
    user_profile = None
    if role == 'member':
        query = """SELECT * 
            FROM member 
            WHERE user_id = %(user_id)s
            """
        connection.execute(
        query, 
        {
            "user_id": user_id
        },
        )
        user_profile = connection.fetchone()
    elif role == 'instructor':
        query = """SELECT * 
            FROM instructor 
            WHERE user_id = %(user_id)s
            """
        connection.execute(
        query, 
        {
            "user_id": user_id
        },
        )
        user_profile = connection.fetchone()
    elif role == 'manager':
        query = """SELECT * 
            FROM manager
            WHERE user_id = %(user_id)s
            """
        connection.execute(
        query, 
        {
            "user_id": user_id
        },
        )
        user_profile = connection.fetchone()
    return user_profile

# Get member profile by memeber id
def get_member_by_id(member_id):
    connection = get_cursor()
    query = """
            SELECT * FROM member
            WHERE id = %(member_id)s;"""
    connection.execute(
        query, 
        {
            "member_id": member_id
        },
        )
    return connection.fetchone()

# Get instructor profile by instructor id
def get_instructor_by_id(instructor_id):
    connection = get_cursor()
    query = """
            SELECT * FROM instructor
            WHERE id = %(instructor_id)s;"""
    connection.execute(
        query, 
        {
            "instructor_id": instructor_id
        },
        )
    return connection.fetchone()

# Get all user profiles including user status by role 
def get_profiles_by_role(role):
    connection = get_cursor()
    if role == 'member':
        query = """
                SELECT u.is_active, m.*
                FROM member AS m
                INNER JOIN user AS u ON m.user_id = u.id
                WHERE u.role = 'member'
                ORDER BY first_name, last_name;
                """
        connection.execute(query)
        return connection.fetchall()
    elif role == 'instructor':
        query = """
                SELECT u.is_active, i.*
                FROM instructor AS i
                INNER JOIN user AS u ON i.user_id = u.id
                WHERE u.role = 'instructor'
                ORDER BY first_name, last_name;
                """
        connection.execute(query)
        return connection.fetchall()
    else:
        abort(500)

# Update user profile in db
def update_profile_by_user_id(
        user_id,
        role,
        title,
        first_name,
        last_name,
        position,
        email,
        phone,
        address,
        dob,
        health_info,
        instructor_profile
):
    connection = get_cursor()
    if role == 'member':
        query = """UPDATE member
                SET title = %(title)s, 
                first_name = %(first_name)s, 
                last_name = %(last_name)s, 
                position = %(position)s, 
                phone = %(phone)s, 
                email = %(email)s, 
                address = %(address)s, 
                dob = %(dob)s, 
                health_info = %(health_info)s
                WHERE user_id = %(user_id)s;
                """
        connection.execute(
            query,
            {
                "user_id": user_id,
                "title": title,
                "first_name": first_name,
                "last_name": last_name,
                "position": position,
                "phone": phone,
                "email": email,
                "address": address,
                "dob": dob,
                "health_info": health_info
            }
        )
    if role == 'instructor':
        query = """UPDATE instructor
                SET title = %(title)s, 
                first_name = %(first_name)s, 
                last_name = %(last_name)s, 
                position = %(position)s, 
                phone = %(phone)s, 
                email = %(email)s, 
                profile = %(instructor_profile)s
                WHERE user_id = %(user_id)s;
                """
        connection.execute(
            query,
            {
                "user_id": user_id,
                "title": title,
                "first_name": first_name,
                "last_name": last_name,
                "position": position,
                "phone": phone,
                "email": email,
                "instructor_profile": instructor_profile
            }
        )
    if role == 'manager':
        query = """UPDATE manager
                SET title = %(title)s, 
                first_name = %(first_name)s, 
                last_name = %(last_name)s, 
                position = %(position)s, 
                phone = %(phone)s, 
                email = %(email)s
                WHERE user_id = %(user_id)s;
                """
        connection.execute(
            query,
            {
                "user_id": user_id,
                "title": title,
                "first_name": first_name,
                "last_name": last_name,
                "position": position,
                "phone": phone,
                "email": email
            }
        )
    if connection.rowcount == 1:
        return jsonify({'message': 'success'})
    else:
        return jsonify({'error': 'Something went wrong'}), 500
    
# Add new user profile by user id and role
def add_profile_by_user_id(
        user_id,
        role,
        title,
        first_name,
        last_name,
        position,
        email,
        phone,
        **kwargs
):
    connection = get_cursor()
    if role == 'member':
        address = kwargs.get('address')
        dob = kwargs.get('dob')
        health_info = kwargs.get('health_info')
        query = """
                INSERT INTO `member` 
                (`user_id`, 
                `title`, 
                `first_name`, 
                `last_name`, 
                `position`, 
                `phone`, 
                `email`, 
                `address`, 
                `dob`,
                `health_info`,
                `image`) 
                VALUES 
                (%(user_id)s,
                %(title)s, 
                %(first_name)s, 
                %(last_name)s, 
                %(position)s, 
                %(phone)s, 
                %(email)s, 
                %(address)s, 
                %(dob)s, 
                %(health_info)s,
                'default.jpg');
                """
        connection.execute(
            query,
            {
                "user_id": user_id,
                "title": title,
                "first_name": first_name,
                "last_name": last_name,
                "position": position,
                "phone": phone,
                "email": email,
                "address": address,
                "dob": dob,
                "health_info": health_info
            }
        )
    if role == 'instructor':
        instructor_profile = kwargs.get('instructor_profile')
        query = """
                INSERT INTO `instructor` 
                (`user_id`, 
                `title`, 
                `first_name`, 
                `last_name`, 
                `position`, 
                `phone`, 
                `email`, 
                `profile`,
                `image`) 
                VALUES 
                (%(user_id)s,
                %(title)s, 
                %(first_name)s, 
                %(last_name)s, 
                %(position)s, 
                %(phone)s, 
                %(email)s, 
                %(profile)s,
                'default.jpg');
                """
        connection.execute(
            query,
            {
                "user_id": user_id,
                "title": title,
                "first_name": first_name,
                "last_name": last_name,
                "position": position,
                "phone": phone,
                "email": email,
                "profile": instructor_profile
            }
        )
    if connection.rowcount == 1:
        return jsonify({'message': 'success'})
    else:
        return jsonify({'error': 'Something went wrong'}), 500 