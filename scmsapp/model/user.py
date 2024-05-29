from scmsapp.model.db import get_cursor
from flask import jsonify
# This module handles queries interaction with user table

# Return a user by given user id
def get_user_by_id(user_id):
    query = """SELECT * 
            FROM user 
            WHERE id = %(user_id)s;
            """
    connection = get_cursor()
    connection.execute(
        query,
        {
            'user_id': user_id
        }
    )
    user = connection.fetchone()
    return user

# Return a user by given username
def get_user_by_username(username):
    query = """SELECT * 
            FROM user 
            WHERE username = %(username)s;
            """
    connection = get_cursor()
    connection.execute(
        query,
        {
            'username': username
        }
    )
    user = connection.fetchone()
    return user

# Set user status by user id
def set_user_status(user_id, status):
    if status:
        status = 1
    else:
        status = 0
    connection = get_cursor()
    query = """
            UPDATE user
            SET is_active = %(status)s
            WHERE id = %(user_id)s;
            """
    connection.execute(
        query,
        {
            'user_id': user_id,
            'status': status
        }
    )
    if connection.rowcount == 1:
        return jsonify({'message': 'success'})
    else:
        return jsonify({'message': 'Something went wrong updating user.'}), 500