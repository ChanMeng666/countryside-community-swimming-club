from scmsapp import app
from flask import render_template, redirect, url_for, request, session, flash, abort
from scmsapp.model.session import allow_role
from scmsapp.model import auth, auth_error, upload, user, profile

# This module handles routes for manager managing other user profiles

# Route to display all member profiles
@app.route('/member')
def all_members():
    allow_role(['manager'])
    members = profile.get_profiles_by_role('member')
    return render_template('user/all-members.html', members=members)

# Route to display all instructor profiles
@app.route('/instructor')
def all_instructors():
    allow_role(['manager'])
    instructors = profile.get_profiles_by_role('instructor')
    return render_template('user/all-instructors.html', instructors=instructors)

# Route to view member profile
@app.route('/member/<int:member_id>', methods=['GET', 'POST'])
def member_profile(member_id):
    # Only instructors and managers can view member profiles
    allow_role(['instructor', 'manager'])
    # Fetch member profile and member status
    member = profile.get_member_by_id(member_id)
    member_status = user.get_user_by_id(member['user_id'])['is_active']
    # If request method is POST, update member profile
    if request.method == 'POST':
        # Only manager can update member profile
        allow_role(['manager'])
        user_id = member['user_id']
        role = 'member'
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
        inactive_user = request.form.get('inactive_user')
        if inactive_user:
            new_status = 0
        else:
            new_status = 1
        # Send data to model function to update DB
        profile.update_profile_by_user_id(
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
        # Send data to model function to update user status if status is changed
        if new_status != member_status:
            user.set_user_status(user_id, new_status)
        # If image is uploaded, send to modeel function to update image
        if profile_image:
            upload.upload_image_by_user_id(user_id, role, profile_image)
        flash("Member details have been updated successfully!", "success")
        return redirect(url_for('member_profile', member_id=member_id))
    # If request is GET, display member profile
    return render_template('/user/manage-user.html', user=member, user_status=member_status, role='member')

# Route to view instructor profile
@app.route('/instructor/<int:instructor_id>', methods=['GET', 'POST'])
def instructor_profile(instructor_id):
    # Anyone can view any instructor profile
    # allow_role(['manager'])
    # Fetch instructor profile and status
    instructor = profile.get_instructor_by_id(instructor_id)
    instructor_status = user.get_user_by_id(instructor['user_id'])['is_active']
    # If request method is POST, update instructor profile
    if request.method == 'POST':
        # Only manager can update instructor profile
        allow_role(['manager'])
        user_id = instructor['user_id']
        role = 'instructor'
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
        inactive_user = request.form.get('inactive_user')
        if inactive_user:
            new_status = 0
        else:
            new_status = 1
        # Send data to model function to update DB
        profile.update_profile_by_user_id(
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
        # Send data to model function to update user status if status is changed
        if new_status != instructor_status:
            user.set_user_status(user_id, new_status)
        # If image is uploaded, send to modeel function to update image
        if profile_image:
            upload.upload_image_by_user_id(user_id, role, profile_image)
        flash("Instructor details have been updated successfully!", "success")
        return redirect(url_for('instructor_profile', instructor_id=instructor_id))
    # If request is GET, display member profile
    return render_template('/user/manage-user.html', user=instructor, user_status=instructor_status, role='instructor')

# Ruote to add a new member
@app.route('/member/new', methods=['GET', 'POST'])
def new_member():
    msg = ''
    # Only manager can access
    allow_role(['manager'])
    username = request.form.get('username')
    role = 'member'
    password = request.form.get('password')
    confirm_password = request.form.get('confirm_password')
    title = request.form.get('title')
    first_name = request.form.get('first_name')
    last_name = request.form.get('last_name')
    position = request.form.get('position')
    email = request.form.get('email')
    phone = request.form.get('phone')
    address = request.form.get('address')
    dob = request.form.get('dob')
    health_info = request.form.get('health_info')
    user = {
        'username': username,
        'title': title,
        'first_name': first_name,
        'last_name': last_name,
        'position': position,
        'email': email,
        'phone': phone,
        'address': address,
        'dob': dob,
        'health_info': health_info
    }
    # If request method is POST, add new menmber user and profile
    if request.method == 'POST':
        
        # Validate username and return error if any
        if auth_error.invalid_username_error(username):
            msg = auth_error.invalid_username_error(username)
            return render_template('user/add-member.html', user=user, msg=msg)
        # Validate password and return error if any
        elif auth_error.invalid_password_error(password, confirm_password):
            msg = auth_error.invalid_password_error(password, confirm_password)
            return render_template('user/add-member.html', user=user, msg=msg)
        # Attempt to add user and member profile
        else:
            user_id = auth.add_user(username, password)
            if user_id:
                profile.add_profile_by_user_id(user_id, role, title, first_name, last_name, position, email, phone, address=address, dob=dob, health_info=health_info)
                flash('New member added successfully!', 'success')
                return redirect(url_for('all_members'))
            else:
                abort(500, 'Something went wrong adding user')
    # If request is GET, render the empty form
    return render_template('user/add-member.html', user=user, msg=msg)

# Ruote to add a new instructor
@app.route('/instructor/new', methods=['GET', 'POST'])
def new_instructor():
    msg = ''
    # Only manager can access
    allow_role(['manager'])
    username = request.form.get('username')
    role = 'instructor'
    password = request.form.get('password')
    confirm_password = request.form.get('confirm_password')
    title = request.form.get('title')
    first_name = request.form.get('first_name')
    last_name = request.form.get('last_name')
    position = request.form.get('position')
    email = request.form.get('email')
    phone = request.form.get('phone')
    instructor_profile = request.form.get('instructor_profile')
    user = {
        'username': username,
        'title': title,
        'first_name': first_name,
        'last_name': last_name,
        'position': position,
        'email': email,
        'phone': phone,
        'instructor_profile': instructor_profile
    }
    # If request method is POST, add new instructor user and profile
    if request.method == 'POST':
        # Validate username and return error if any
        if auth_error.invalid_username_error(username):
            msg = auth_error.invalid_username_error(username)
            return render_template('user/add-instructor.html', user=user, msg=msg)
        # Validate password and return error if any
        elif auth_error.invalid_password_error(password, confirm_password):
            msg = auth_error.invalid_password_error(password, confirm_password)
            return render_template('user/add-instructor.html', user=user, msg=msg)
        # Attempt to add user and instructor profile
        else:
            user_id = auth.add_user(username, password, role)
            if user_id:
                profile.add_profile_by_user_id(user_id, role, title, first_name, last_name, position, email, phone, instructor_profile=instructor_profile)
                flash('New instructor added successfully!', 'success')
                return redirect(url_for('all_instructors'))
            else:
                abort(500, 'Something went wrong adding user')
    # If request is GET, render the empty form
    return render_template('user/add-instructor.html', user=user, msg=msg)