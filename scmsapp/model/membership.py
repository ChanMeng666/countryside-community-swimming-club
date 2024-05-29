from flask import jsonify, abort
from datetime import datetime
import scmsapp.model.db as db
# Get member info by memeber id
def get_member_by_id(member_id):
    cursor = db.get_cursor()
    query = 'SELECT * FROM member WHERE id = %(member_id)s;'
    cursor.execute(
        query, 
        {
            "member_id": member_id
        }
        )
    return cursor.fetchone()

# Get payment info by memeber id
def get_payments_by_member_id(member_id):
    query = """SELECT * 
            FROM payment 
            WHERE member_id = %(member_id)s
            ORDER BY pay_time ASC;
            """
    cursor = db.get_cursor()
    cursor.execute(
        query,
        {
            'member_id': member_id
        }
    )
    return cursor.fetchall()
     


# Get product info and covert to dictionary
def get_product_dict():
    query = 'SELECT * FROM product;'
    cursor = db.get_cursor()
    cursor.execute(query)
    products = cursor.fetchall()
    result_dict = {product['id']: product for product in products}
    return result_dict

# Subscribe- add a payment record before payment
def add_payment_data(member_id, product_id, total, booking_id = None):
    query = '''INSERT INTO payment(product_id, member_id, total, booking_id) 
               VALUES(%(product_id)s,%(member_id)s, %(total)s, %(booking_id)s);'''
    cursor = db.get_cursor()
    cursor.execute(
            query,
            {
                "member_id": member_id,
                "product_id": product_id,
                "total": total,
                "booking_id": booking_id
            }
        )
   
    if cursor.rowcount == 1:
        payment_id = cursor.lastrowid
        response = {'success': True, 'payment_id': payment_id, 'product_id': product_id}
        return jsonify(response)
    else:
        return jsonify({'success': False, 'error': 'Something went wrong'}), 500 

# Update payment record - when finishing payment.  
def update_payment_data(member_id, payment_id, product_id):
    try:
        cursor = db.get_cursor()
        cursor.execute("START TRANSACTION")
        # Update payment record 
        query = '''UPDATE payment SET pay_time=%(pay_time)s, is_paid=1
                WHERE id=%(payment_id)s;'''
        cursor.execute(
                query,
                {
                    "pay_time": datetime.now(),
                    "payment_id": payment_id
                }
            )
        query = 'SELECT * FROM product WHERE id=%(product_id)s;'
        cursor.execute(
                    query,
                    {
                        "product_id": product_id
                    }
                )
        product = cursor.fetchone()
        
        day = 0
        type = 'Monthly'
        if 'monthly' in product['product_name'].lower():
            day = 30
        elif 'annual' in product['product_name'].lower():
            day = 365
            type = 'Annual'
        # Update membership detail 
        query = '''UPDATE member
                SET expired_date = DATE_ADD(COALESCE(expired_date, CURDATE()), INTERVAL %(day)s DAY),
                is_subscription = 1,
                membership_type = %(type)s
                WHERE id = %(member_id)s;'''
        cursor.execute(
                query,
                {
                    
                    "day": day,
                    "type": type,
                    "member_id": member_id
                }
            )
        db.connection.commit()
        return {'success': True}
    except Exception as e:
            db.connection.rollback()
    return {'success': False, 'error': 'Something went wrong'}

# Update membership as cancel subscription
def update_membership_as_cancel(payment_id):
    try:
        cursor = db.get_cursor()
        cursor.execute("START TRANSACTION")
        query = '''DELETE from payment 
                WHERE id=%(id)s;'''
        cursor = db.get_cursor()
        cursor.execute(
                query,
                {
                    "id": payment_id
                }
            )
        db.connection.commit()
        return {'success': True}
    except Exception as e:
            db.connection.rollback()
    return {'success': False, 'error': 'Something went wrong'}
 
# Valid membership 
def valid_member_membership(member_id):
    query = '''Select * from member
               WHERE id=%(member_id)s;'''
    cursor = db.get_cursor()
    cursor.execute(
            query,
            {
                "member_id": member_id
            }
        )
    user = cursor.fetchone() 
    print(member_id)
    print(user)
    
    # If user membership is active
    if user.get('is_subscription'):
            print(user.get('is_subscription'))
            print("HERE")
            return True
    else:
        return False
 