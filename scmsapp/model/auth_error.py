from scmsapp.model import user
import re

# This module handles username and password validation and error messages

# Validate username meets requirements and return error message if any
def invalid_username_error(username):
    # Check if username already exists
    if user.get_user_by_username(username):
        return 'Username already exists. Please choose a different username.'
    # Check if username contains only letters and digits
    elif not re.match(r'[A-Za-z0-9]+', username):
        return 'Username must contain only letters and digits.'
    else:
        return

# Validate password meets reuqirements and return error message if any
def invalid_password_error(password, confirm_password, current_password=None):
    # Check password length is at least 8 characters
    if len(password) < 8:
        return 'Password must be 8 characters long.'
    # Check if password contains digit
    if not re.search(r'\d', password):
        return 'Password must contain at least 1 digit.'
    # Check if password contains uppercase letter
    if not re.search(r'[A-Z]', password):
        return 'Password must contain at least 1 uppercase letter.'
    # Check if password contains lowercase letter
    if not re.search(r'[a-z]', password):
        return 'Password must contain at least 1 lowercase letter.'
    if password != confirm_password:
        return 'Passwords do not match. Please re-enter.'
    if current_password and current_password == password:
        return 'New passowrd cannot be the same as current password.'
    return None