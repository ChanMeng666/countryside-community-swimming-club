from scmsapp import app
from flask import render_template, redirect, url_for, request, session, flash, abort, jsonify
from scmsapp.model.profile import update_profile_by_user_id
from scmsapp.model.profile import get_profile_by_user_id_role
from scmsapp.model.session import allow_role
from scmsapp.model import upload
from scmsapp.model import auth, auth_error

# This module handles routes for user managing their own profile

# Route to view and update current user profile
@app.route('/profile', methods=['GET', 'POST'])
def profile():
    # All user group can access
    allow_role(['member', 'instructor', 'manager'])
    # Retreive current user id and role from session
    user_id = session['user_id']
    role = session['role']
    # When user submites the form, update user profile
    if request.method == 'POST':
        title = request.form.get('title')
        first_name = request.form.get('first_name')
        last_name = request.form.get('last_name')
        position = request.form.get('position')
        email = request.form.get('email')
        phone = request.form.get('phone')
        address = request.form.get('address')
        dob = request.form.get('dob')
        health_info = request.form.get('health_info')
        instructor_profile = request.form.get('instructor_profile')
        profile_image = request.files.get('upload_image')
        update_profile_by_user_id(
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
        )
        if profile_image:
            upload.upload_image_by_user_id(user_id, role, profile_image)
        flash("Your details have been updated successfully!", "success")
        return redirect(url_for('profile'))
    user_profile = get_profile_by_user_id_role(user_id, role)
    # Check role in HTML instead of here
    # if role == 'member':
    #     return render_template('member/member-profile.html',  profile=user_profile, role=role)
    # elif role in ['instructor', 'manager']:
    return render_template('user/profile.html', profile=user_profile, role=role )

@app.route('/profile/change-password', methods=['GET', 'POST'])
def change_password():
    # All user group can access
    allow_role(['member', 'instructor', 'manager'])
    # Retreive current user id and role from session
    msg = ''
    user_id = session['user_id']
    role = session['role']
    # When user submites the form, update user password
    if request.method == 'POST':
        current_password = request.form.get('current_password')
        new_password = request.form.get('password')
        new_confirm_password = request.form.get('confirm_password')
        # Validate password and return error if any
        if auth.validate_password_by_user_id(user_id, current_password):
            if auth_error.invalid_password_error(new_password, new_confirm_password, current_password):
                msg = auth_error.invalid_password_error(new_password, new_confirm_password, current_password)
                return render_template('user/change_password.html', msg=msg, role=role)
            # Attempt to add user
            else:
                if auth.update_password_by_user_id(user_id, new_password):
                    # Add function to add member profile
                    flash('Your password has been updated succesfully!', 'success')
                    return redirect(url_for('profile'))
                else:
                    abort(500, 'Something went wrong')
        else:
            msg = 'Current password is incorrect'
    # Check role in HTML instead of here
    # if role == 'member':
    #     return render_template('member/member-change-password.html', msg=msg, role=role)
    # elif role in ['instructor', 'manager']:
    user_profile = get_profile_by_user_id_role(user_id, role)
    return render_template('user/change_password.html', msg=msg, role=role, user = user_profile )

