import mysql.connector
from scmsapp.model.db import get_cursor
from scmsapp import app
from flask import render_template, redirect, url_for, request, session, flash, abort, jsonify
from scmsapp.model.session import allow_role
from scmsapp.model import db



# This module handles routes for manager managing pool or lane status
# Route to show all pool or lanes status
@app.route('/setting/pool', methods=['GET', 'POST'])
def manage_pool_and_lane():
    allow_role(['manager'])
    cursor = get_cursor()
    cursor.execute("  SELECT * FROM location;")
    pool_name = cursor.fetchall()
    cursor.close()
    return render_template('setting/manage_pool_and_lane.html', pool_name = pool_name)



# Route to view and edit a pool or lane status
@app.route('/setting/pool/<int:id>', methods=['GET', 'POST'])
def change_lane_status(id):
    allow_role(['manager'])
    pool_status = request.form.get("edit_modal_status")
    cursor = get_cursor()
    update_query = """
                UPDATE location
                SET status = %s
                WHERE id = %s;
                """
    try:
        cursor.execute(update_query, (pool_status, id))
        db.connection.commit()
        flash('Pool or lane status updated successfully!', 'success')
    except mysql.connector.Error as err:
        flash('Failed to update pool or lane status: {}'.format(err), 'danger')
    finally:
        cursor.close()
    cursor = get_cursor()
    cursor.execute("  SELECT * FROM location;")
    pool_name = cursor.fetchall()

    return render_template('setting/manage_pool_and_lane.html', pool_name = pool_name)


# This module handles routes for manager managing products price

# Route to show all products price
@app.route('/setting/manage-price')
def manage_price():
    # Only manager can access
    allow_role(['manager'])
    cursor = get_cursor()
    cursor.execute("  SELECT * FROM product;")
    product = cursor.fetchall()
    cursor.close()
    return render_template('setting/manage_price.html', product = product)



 # Route to view and edit a class price
@app.route('/setting/manage-product-price/<int:id>', methods=['GET', 'POST'])
def manage_product_price(id):
    # Only manager can access
    allow_role(['manager'])
    print(id)
    # Fetch product type
    product_price = request.form.get('new_price')
    cursor = get_cursor()
    update_query = """
            UPDATE product
            SET price = %s
            WHERE id = %s;
            """
    try:
        cursor.execute(update_query, (product_price, id))
        db.connection.commit()
        flash('Product price updated successfully!', 'success')
    except mysql.connector.Error as err:
        flash('Failed to update product price: {}'.format(err), 'danger')
    finally:
        cursor.close()

    cursor = get_cursor()
    cursor.execute("SELECT * FROM product")
    product = cursor.fetchall()
    return render_template('setting/manage_price.html', product = product)

