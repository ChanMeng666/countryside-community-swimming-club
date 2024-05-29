from scmsapp import app
from flask import render_template, redirect, url_for, request, session, flash, abort, jsonify
from scmsapp.model.session import allow_role
from scmsapp.model import class_type

# This module handles routes for manager managing class types

# Route to show all class types
@app.route('/setting/class-type')
def manage_class_type():
    # Only manager can access
    allow_role(['manager'])
    classes = class_type.get_class_type_by_type('class')
    lessons = class_type.get_class_type_by_type('1-on-1')
    return render_template('setting/class-type.html', classes=classes, lessons=lessons)

# Route to view and edit a class type
@app.route('/setting/class-type/<int:id>', methods=['GET', 'POST'])
def class_type_detail(id):
    # Only manager can access
    allow_role(['manager'])
    # Fetch class tpye
    the_class = class_type.get_class_type_by_id(id)
    # If request method is POST, update class type
    if request.method == 'POST':
        class_name = request.form.get('class_name')
        description = request.form.get('description')
        # Send data to model function to update DB
        class_type.update_class_type_by_id(id, class_name, description)
        flash("Details have been updated successfully!", "success")
        return redirect(url_for('manage_class_type'))
    # If request is GET, display class tpye detail
    return render_template('/setting/class-type-detail.html', the_class=the_class)

# Route to add a new class type
@app.route('/setting/class-type/new', methods=['GET', 'POST'])
def new_class_type():
    # Only manager can access
    allow_role(['manager'])
    # If request method is POST, add new class type into DB
    if request.method == 'POST':
        classtype = request.form.get('class_type')
        class_name = request.form.get('class_name')
        description = request.form.get('description')
        class_type.add_class_type(classtype, class_name, description)
        flash('New class type added successfully!', 'success')
        return redirect(url_for('manage_class_type'))
    # If request is GET, render the empty form
    return render_template('setting/add-class-type.html')

# Route to delete a class type
@app.route('/setting/class-type/<int:id>/delete', methods=['DELETE'])
def delete_class_type(id):
    # Only manager can access
    allow_role(['manager'])
    # Call mdoel function to perform deletion
    class_type.delete_class_type_by_id(id)
    flash('Class type deleted successfully!', 'success')
    return jsonify({'message': f'Class type ID_{id} deleted successfully'})