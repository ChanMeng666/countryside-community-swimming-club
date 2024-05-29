import mysql.connector
from flask import render_template, request, redirect, url_for, flash, session, jsonify
from scmsapp import app
from scmsapp.model.db import get_cursor
from scmsapp.model import db
from .timetable_data import get_timetable_context
from .permissions import check_user_role_manager
from .permissions import check_user_role_instructor
from .permissions import check_user_role_member
from .search import search_classes
from .class_overlap import check_for_overlap


# Asynchronous checking of course conflicts
@app.route('/check_for_overlap', methods=['POST'])
def route_check_for_overlap():
    data = request.get_json()
    location_id = data.get('location_id')
    start_time = data.get('start_time')
    end_time = data.get('end_time')
    instructor_id = data.get('instructor_id', None)
    class_id = data.get('class_id', None)  # Extracting class_id from the request data

    # Call the modified check_for_overlap function from class_overlap.py
    conflict = check_for_overlap(location_id, start_time, end_time, instructor_id, class_id)

    if conflict:
        return jsonify({'error': conflict}), 400
    else:
        return jsonify({'overlap': False})


# =========== For Manager ===========
# View the timetable for all
@app.route('/timetable', methods=['GET', 'POST'])
def timetable():
    # Check user permission
    check_user_role_manager()

    context = get_timetable_context(request.form.get('date'))
    return render_template('timetable/timetable_manager.html', **context)

# Add class for the manager
@app.route('/add_class', methods=['GET', 'POST'])
def add_class():
    check_user_role_manager()

    if request.method == 'POST':
        instructor_id = request.form.get('add_class_instructor')
        location_id = request.form.get('add_class_location')
        class_type_id = request.form.get('add_class_type')
        open_slot = request.form.get('open_slot')
        start_time = request.form.get('start_time')
        end_time = request.form.get('end_time')

        # Before inserting, check for any overlap
        conflict = check_for_overlap(location_id, start_time, end_time, instructor_id)
        if conflict:
            flash(conflict, 'danger')
            return redirect(url_for('add_class'))

        cursor = get_cursor()
        add_class_query = """
        INSERT INTO class (instructor_id, location_id, class_type, start_time, end_time, open_slot, status)
        VALUES (%s, %s, %s, %s, %s, %s, 1)
        """

        try:
            cursor.execute(add_class_query, (instructor_id, location_id, class_type_id, start_time, end_time, open_slot))
            db.connection.commit()
            flash('Class added successfully!', 'success')
        except mysql.connector.Error as err:
            flash('Something went wrong: {}'.format(err), 'danger')
        finally:
            cursor.close()
        return redirect(url_for('add_class'))

    context = get_timetable_context()
    return render_template('timetable/timetable_manager.html', **context)

# Delete class from the timetable
@app.route('/delete_class/<int:class_id>', methods=['POST'])
def delete_class(class_id):
    check_user_role_manager()

    try:
        cursor = get_cursor()
        # First, delete payments related to the bookings of the class
        cursor.execute("DELETE FROM payment WHERE booking_id IN (SELECT id FROM booking WHERE class_id = %s)", (class_id,))
        # Then, delete related bookings
        cursor.execute("DELETE FROM booking WHERE class_id = %s", (class_id,))
        # Finally, delete the class
        cursor.execute("DELETE FROM class WHERE id = %s", (class_id,))
        db.connection.commit()
        flash('Class, related bookings and payments deleted successfully!', 'success')
    except mysql.connector.Error as err:
        db.connection.rollback()  # Roll back the transaction on error
        flash('Failed to delete class: {}'.format(err), 'danger')
    finally:
        cursor.close()

    return redirect(url_for('timetable'))

# Edit class in the timetable
@app.route('/edit_class/<int:class_id>', methods=['GET', 'POST'])
def edit_class(class_id):
    check_user_role_manager()

    if request.method == 'POST':
        instructor_id = request.form.get('edit_modal_instructor')
        location_id = request.form.get('edit_modal_location')
        class_type_id = request.form.get('edit_modal_class_type')
        open_slot = request.form.get('edit_modal_open_slot')
        start_time = request.form.get('edit_modal_start_time')
        end_time = request.form.get('edit_modal_end_time')

        # Check for overlap before updating the class
        conflict = check_for_overlap(location_id, start_time, end_time, instructor_id, class_id)
        if conflict:
            flash(conflict, 'danger')
            return redirect(url_for('timetable'))

        cursor = get_cursor()
        update_query = """
        UPDATE class
        SET instructor_id = %s, location_id = %s, class_type = %s, open_slot = %s, start_time = %s, end_time = %s
        WHERE id = %s
        """
        try:
            cursor.execute(update_query, (instructor_id, location_id, class_type_id, open_slot, start_time, end_time, class_id))
            db.connection.commit()
            flash('Class updated successfully!', 'success')
        except mysql.connector.Error as err:
            flash('Failed to update class: {}'.format(err), 'danger')
        finally:
            cursor.close()
        return redirect(url_for('timetable'))

    # For GET request
    cursor = get_cursor()
    cursor.execute("SELECT * FROM class WHERE id = %s", (class_id,))
    class_details = cursor.fetchone()

    cursor.close()

    context = get_timetable_context()
    return render_template('timetable/timetable_manager.html', **context, class_details=class_details)


# =========== Search for classes (Manager & Instructor) ===========
@app.route('/search_class', methods=['GET', 'POST'])
def search_class():
    if request.method == 'POST':
        results = search_classes()
        search_value = request.form.get('search_value', '')
        return render_template('timetable/search_class.html', results=results, search_value=search_value)
    else:
        return render_template('timetable/search_class.html', results=[], search_value='')


# =========== For Instructor ===========
# View the timetable for all
@app.route('/timetable_instructor', methods=['GET', 'POST'])
def timetable_instructor():
    # Check user permission
    check_user_role_instructor()

    # Get the current instructor's information
    instructor_id = session.get('instructor_id')

    cursor = get_cursor()
    cursor.execute("SELECT * FROM instructor WHERE id = %s", (instructor_id,))
    instructor_info = cursor.fetchone()
    cursor.close()

    context = get_timetable_context(request.form.get('date'))
    context['instructor_info'] = instructor_info
    return render_template('timetable/timetable_instructor.html', **context)

# Add class for the instructor
@app.route('/add_class_instructor', methods=['GET', 'POST'])
def add_class_instructor():
    # Check user permission
    check_user_role_instructor()

    # Get the instructor_id from the session. It should match an id in the instructor table.
    instructor_id = session.get('instructor_id')

    if request.method == 'POST':
        location_id = request.form.get('add_class_location')
        class_type_id = request.form.get('add_class_type')
        open_slot = request.form.get('open_slot')
        start_time = request.form.get('start_time')
        end_time = request.form.get('end_time')

        # Before inserting, check for any overlap
        conflict = check_for_overlap(location_id, start_time, end_time, instructor_id)
        if conflict:
            flash(conflict, 'danger')
            return redirect(url_for('timetable_instructor'))

        cursor = get_cursor()
        add_class_query = """
        INSERT INTO class (instructor_id, location_id, class_type, open_slot, start_time, end_time, status)
        VALUES (%s, %s, %s, %s, %s, %s, 1)
        """

        try:
            cursor.execute(add_class_query, (instructor_id, location_id, class_type_id, open_slot, start_time, end_time))
            db.connection.commit()
            flash('Class added successfully!', 'success')
        except mysql.connector.Error as err:
            db.connection.rollback()
            flash(f'Failed to add class: {err}', 'danger')
        finally:
            cursor.close()

        return redirect(url_for('timetable_instructor'))

# View the Personal Schedule for the instructor
@app.route('/timetable_instructor/myschedule', methods=['GET', 'POST'])
def timetable_instructor_myschedule():
    # Check user permission
    check_user_role_instructor()

    # Assuming instructor_id is stored in session when instructor logs in
    instructor_id = session.get('instructor_id')

    # Fetch only the instructor's classes
    context = get_timetable_context(request.form.get('date'), instructor_id=instructor_id)

    return render_template('timetable/timetable_instructor_personal.html', **context)

# Delete class for the instructor
@app.route('/delete_class_instructor/<int:class_id>', methods=['POST'])
def delete_class_instructor(class_id):
    check_user_role_instructor()

    try:
        cursor = get_cursor()
        # First, delete payments related to the bookings of the class
        cursor.execute("DELETE FROM payment WHERE booking_id IN (SELECT id FROM booking WHERE class_id = %s)", (class_id,))
        # Then, delete related bookings
        cursor.execute("DELETE FROM booking WHERE class_id = %s", (class_id,))
        # Finally, delete the class
        cursor.execute("DELETE FROM class WHERE id = %s", (class_id,))
        db.connection.commit()
        flash('Class, related bookings and payments deleted successfully!', 'success')
    except mysql.connector.Error as err:
        db.connection.rollback()  # Roll back the transaction on error
        flash('Failed to delete class: {}'.format(err), 'danger')
    finally:
        cursor.close()

    return redirect(url_for('timetable_instructor_myschedule'))

# Edit class in the timetable
@app.route('/edit_class_instructor/<int:class_id>', methods=['GET', 'POST'])
def edit_class_instructor(class_id):
    check_user_role_instructor()

    if request.method == 'POST':
        instructor_id = session.get('instructor_id')
        location_id = request.form.get('edit_modal_location')
        class_type_id = request.form.get('edit_modal_class_type')
        open_slot = request.form.get('edit_modal_open_slot')
        start_time = request.form.get('edit_modal_start_time')
        end_time = request.form.get('edit_modal_end_time')

        # Check for overlap before updating the class
        conflict = check_for_overlap(location_id, start_time, end_time, instructor_id, class_id)
        if conflict:
            flash(conflict, 'danger')
            return redirect(url_for('timetable_instructor_myschedule'))

        cursor = get_cursor()
        update_query = """
        UPDATE class
        SET instructor_id = %s, location_id = %s, class_type = %s, start_time = %s, end_time = %s, open_slot = %s
        WHERE id = %s
        """
        try:
            cursor.execute(update_query, (instructor_id, location_id, class_type_id, start_time, end_time, open_slot, class_id))
            db.connection.commit()
            flash('Class updated successfully!', 'success')
        except mysql.connector.Error as err:
            flash('Failed to update class: {}'.format(err), 'danger')
        finally:
            cursor.close()
        return redirect(url_for('timetable_instructor_myschedule'))

    # For GET request
    cursor = get_cursor()
    cursor.execute("SELECT * FROM class WHERE id = %s", (class_id,))
    class_details = cursor.fetchone()

    cursor.close()

    context = get_timetable_context()
    return render_template('timetable/timetable_instructor_personal.html', **context, class_details=class_details)


# =========== For member ===========
# View the timetable for all
@app.route('/timetable_member', methods=['GET', 'POST'])
def member_timetable():
    # Check user permission
    check_user_role_member()

    context = get_timetable_context(request.form.get('date'))
    return render_template('timetable/timetable_member.html', **context)