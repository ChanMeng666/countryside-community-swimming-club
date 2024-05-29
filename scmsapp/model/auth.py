from scmsapp import app
from flask import session
from flask_hashing import Hashing
from scmsapp.model.db import get_cursor
import secrets

# This module handles user authentication, i.e. login
# and any function in realation to password hashinng, i.e. register, change password

hashing = Hashing(app)

# Login function
# Authenciate username ans passwor, attempt to log user in
# Return True if both username and password pass authentication
# Otherwise return False
def login_user(username, password):
    # Query username in db user table
    query = """SELECT *
            FROM user
            WHERE username = %(username)s;
            """
    connection = get_cursor()
    connection.execute(
        query,
        {
            "username": username
        },
        )
    user = connection.fetchone()
    # If user exists and is active
    if user and user.get('is_active'):
        if hashing.check_value(user['password'], password, salt=user['salt']):
            session['loggedin'] = True
            session['user_id'] = user['id']
            session['username'] = user['username']
            session['role'] = user['role']
            return True
    else:
        return False


# Add a user to db, default role is member
def add_user(username, password, role='member'):
    # Generate a random salt of 8 characters long
    # salt = secrets.token_hex(4)
    salt = 'abcd'
    # Hash password 
    hash = hashing.hash_value(password, salt=salt)
    query = """INSERT INTO user (`username`, `password`, `salt`, `role`) 
            VALUES  (%(username)s, %(password)s, %(salt)s, %(role)s);
            """
    connection = get_cursor()
    connection.execute(
        query,
        {
            'username': username,
            'password': hash,
            'salt': salt,
            'role': role
        }
    )
    # Check if intert is successful
    # Return new user_id if successful
    # Otherwise return False
    if connection.rowcount == 1:
        return connection.lastrowid
    else:
        return False

# Validate password function
def validate_password_by_user_id(user_id, password):
     # Query user id in db user table
    query = """SELECT * 
            FROM user 
            WHERE id = %(user_id)s;
            """
    connection = get_cursor()
    connection.execute(
        query, 
        {
            "user_id": user_id
        },
        )
    user = connection.fetchone()
    # If user exists and is active
    if user:
        if hashing.check_value(user['password'], password, salt='abcd'):
            return True
    else:
        return False

# Change password function
def update_password_by_user_id(user_id, password):
    # Generate a random salt of 8 characters long
    # salt = secrets.token_hex(4)
    salt = 'abcd'
    # Hash password using salt
    hash = hashing.hash_value(password, salt=salt)
    query = """
            UPDATE user 
            SET password = %(password)s
            WHERE id = %(user_id)s;
            """
    connection = get_cursor()
    connection.execute(
        query,
        {
            'user_id': user_id,
            'password': hash
        }
    )
    # Check if query is successful
    # Return new user_id if successful
    # Otherwise return False
    if connection.rowcount == 1:
        return True
    else:
        return False