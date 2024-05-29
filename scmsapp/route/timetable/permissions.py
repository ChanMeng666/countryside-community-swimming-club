from flask import session, flash, abort

# Check if user is logged in
def check_user_role_manager():
    allowed_roles = ['manager']
    if 'loggedin' in session and session['role'] in allowed_roles:
        return True
    else:
        flash('You do not have permission to perform this action.', 'danger')
        abort(403)

def check_user_role_instructor():
    allowed_roles = ['instructor']
    if 'loggedin' in session and session['role'] in allowed_roles:
        return True
    else:
        flash('You do not have permission to perform this action.', 'danger')
        abort(403)

def check_user_role_member():
    allowed_roles = ['member']
    if 'loggedin' in session and session['role'] in allowed_roles:
        return True
    else:
        flash('You do not have permission to perform this action.', 'danger')
        abort(403)