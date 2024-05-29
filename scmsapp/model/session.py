from flask import session, abort

# Module to check if user is logged in 
# and if user has right permission to access the page

# Check if user is logged in, return True or False
def logged_in():
    # Check if session exists
    if 'loggedin' in session:
        return True
    else:
        session.clear()
        return False

# Check if user role is logged in and permitted to access the page
def allow_role(role_list: list):
    # Check if user is logged in
    # If not logged in, abort 403 and redirect to login
    if logged_in():
        # Check if user role is in the permitted role list
        # if not allowed, abort 401
        if session['role'] not in role_list:
            abort(403)
    else:
        abort(401)
