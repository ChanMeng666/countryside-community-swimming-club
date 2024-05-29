from scmsapp import app
from flask import render_template, redirect, url_for, request, session, flash, jsonify
from scmsapp.model.session import allow_role
from scmsapp.model.membership import get_member_by_id
from scmsapp.model.membership import get_payments_by_member_id
from scmsapp.model.membership import get_product_dict
from scmsapp.model.membership import add_payment_data
from scmsapp.model.membership import update_payment_data
from scmsapp.model.membership import update_membership_as_cancel


# This module handles routes for membership

@app.route('/membership', methods=['GET', 'POST'])
def membership():
    allow_role(['member'])
    member_id = session['id']
    member_info = get_member_by_id(member_id)
    member_payment_history = get_payments_by_member_id(member_id)
    product_dict = get_product_dict()
    user = get_member_by_id(member_id)
    return render_template('/member/membership.html', 
                           member = member_info,
                           payments = member_payment_history,
                           products = product_dict,
                           user=user)

@app.route('/subscribe', methods=['GET', 'POST'])
def subscribe():
    allow_role(['member'])
    member_id = session['id']
    product_id = request.form.get('product')
    total = request.form.get('price')
    return add_payment_data(member_id, product_id, total)


@app.route('/payment', methods=['GET', 'POST'])
def payment():
    allow_role(['member'])
    member_id = session['id']
    payment_id = request.form.get('paymentId')
    product_id = request.form.get('productId')
    response =  update_payment_data(member_id, payment_id, product_id)
    if response['success']:
        flash('Payment successful!', 'success')
    else:
        flash('Payment failed!', 'danger')

    return jsonify(response)


@app.route('/membershipcancel', methods=['GET', 'POST'])
def membershipcancel():
    allow_role(['member'])
    paymentId = request.form['delpaymentId']
    response = update_membership_as_cancel(paymentId)
    if response['success']:
        flash('Cancel subscription successful!', 'success')
    else:
        flash('Cancel failed!', 'danger')

    return redirect(url_for('membership'))