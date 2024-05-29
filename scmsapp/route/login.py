from scmsapp import app
from flask import render_template,request, session, redirect, url_for, flash, jsonify
from scmsapp.model import db
from flask_hashing import Hashing
from datetime import datetime
import re


hashing = Hashing(app)  

@app.route('/login/', methods=['GET', 'POST'])
def login():
    # Output message if something goes wrong...
    msg = ''
    # Check if "username" and "password" POST requests exist (user submitted form)
    if request.method == 'POST' and 'sign_in_username' in request.form and 'sign_in_password' in request.form:
        username = request.form['sign_in_username']
        user_password = request.form['sign_in_password']
        # Check if account exists using MySQL
        cursor = db.get_cursor()
        cursor.execute('SELECT * FROM user WHERE username = %s', (username,))
        # Fetch one record and return result
        account = cursor.fetchone()
        if account is not None:
            password = account['password']
            if hashing.check_value(password, user_password, salt='abcd'):
            # If account exists in accounts table 
            # Create session data, we can access this data in other routes
                session['loggedin'] = True
                session['user_id'] = account['id']
                session['username'] = account['username']
                session['role'] = account['role']

                if account['role'] == 'instructor':
                    cursor.execute('SELECT id FROM instructor WHERE user_id = %s', (account['id'],))
                    result = cursor.fetchone()
                    session['instructor_id'] = result['id']

                flash('Login Successfully!', 'success')
                return redirect(url_for('dashboard')) 
            else:
                #password incorrect
                msg = 'Incorrect password!'
        else:
            # Account doesnt exist or username incorrect
            msg = 'Incorrect username'
    # Show the login form with message (if any)
    return render_template('login.html', sign_in_msg=msg)




@app.route('/register', methods=['GET', 'POST'])
def register():
    msg = ''
    response = None
    # Check if "username", "password" and "email" POST requests exist (user submitted form)
    if request.method == 'POST' and 'sign_up_username' in request.form and 'sign_up_password' in request.form and 'email' in request.form and 'phone' in request.form and 'lastname' in request.form and 'address' in request.form:
        # Create variables for easy access
        username = request.form.get('sign_up_username')
        password = request.form.get('sign_up_password')
        email = request.form.get('email')
        phone = request.form.get('phone')
        firstname = request.form.get('firstname')
        lastname = request.form.get('lastname')
        address = request.form.get('address')
        # Check if account exists using MySQL
        try:
            cursor = db.get_cursor()
            cursor.execute('SELECT * FROM user WHERE username = %s', (username,))
            account = cursor.fetchone()
            # If account exists show error and validation checks
            if account:
                msg = 'Account already exists!'
            elif not re.match(r'[^@]+@[^@]+\.[^@]+', email):
                msg = 'Invalid email address!'
            elif not re.match(r'[A-Za-z0-9]+', username):
                msg = 'Username must contain only characters and numbers!'
            elif not re.match(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[a-zA-Z\d@$!%*?&]{8,}$', password):
                msg = 'Password must be at least 8 characters long and have a mix of character types!'
            elif not re.match(r'[0-9]{10}', phone):
                msg = 'Please enter a phone number consisting of 10-11 digits!'
            elif not re.match(r'^[\w\.-]+@[\w\.-]+\.\w+$', email):
                msg = 'Please enter a valid email!'
            elif not re.match(r'[a-zA-Z]+', lastname):
                msg = 'Please enter a valid last name!' 

            elif not username or not password or not email or not lastname:
                msg = 'Please fill out the form!'
            else:
                # Account doesnt exists and the form data is valid, now insert new account into user table
                hashed = hashing.hash_value(password, salt='abcd')

                # Start a transaction
                cursor.execute("START TRANSACTION")

                cursor.execute('SELECT MAX(id) as id FROM user;')
                result = cursor.fetchone()
                user_id = result['id']+1
                
                sql='INSERT INTO user (id, username, password, salt, role, is_active) VALUES(%s,%s,%s,%s,%s,%s);'
                cursor.execute(sql,(user_id, username, hashed,'abcd','member',1))
                sql='INSERT INTO member (user_id, first_name, last_name, phone, email, address) VALUES(%s,%s,%s,%s,%s,%s);' 
                cursor.execute(sql,(user_id, firstname, lastname, phone, email, address))    
                db.connection.commit()
                response = {'success': True, 'message': 'Registration successful'}
                return jsonify(response)
        except Exception as e:
            # Rollback the transaction if an error occurs
            db.connection.rollback()
            msg = 'Network error!'
    elif request.method == 'POST':
        msg = 'Please fill out the form!'
    response = {'success': False, 'message': msg }
    return jsonify(response)



@app.route("/dashboard")
def dashboard():
    if 'loggedin' in session:
        connection = db.get_cursor()
        if session['role'] == 'member':
            connection.execute('SELECT id, first_name, last_name, expired_date FROM member WHERE user_id=%s;',(session['user_id'],))
        elif session['role'] == 'instructor':
            connection.execute('SELECT id, first_name, last_name FROM instructor WHERE user_id=%s;',(session['user_id'],))
        else:
            connection.execute('SELECT id, first_name, last_name FROM manager WHERE user_id=%s;',(session['user_id'],))
        result = connection.fetchone()
        session['id'] = result['id']
        fullname = result['first_name']+ ' '+ result['last_name']

        if session['role'] == 'member':
            
            today_date = datetime.now().date()
            # Check the membership expired date and show the tips 
            expired_date = result['expired_date']
            if expired_date:
                date_difference = expired_date - today_date
                if date_difference.days <= 0:
                    flash('Your Membership is expired! Please subscribe!', 'danger')
                elif date_difference.days < 7:
                    flash(f'Your Membership will be expired in {date_difference.days} days! Please subscribe!', 'warning')

            connection.execute('SELECT * FROM instructor;')
            instructorList = connection.fetchall()
            connection.execute("""SELECT create_time, t.class_type,class_name, description, start_time, end_time, i.last_name, i.first_name
                    FROM booking b
                    JOIN class c ON b.class_id = c.id
                    JOIN class_type t ON t.id = c.class_type
                    JOIN instructor i on i.id = c.instructor_id
                    WHERE b.member_id = %s
                    AND start_time > %s;""",(session['id'],today_date,))
            bookingList = connection.fetchall()
            connection.execute('SELECT * FROM news')
            newsList = connection.fetchall()
            return render_template('/member/dashboard.html', user = result, instructorList = instructorList, bookingList = bookingList,newsList = newsList)
        else:
            return render_template ('dashboard.html', Fullname = fullname)
    return redirect(url_for('login'))


# http://localhost:5000/logout - this will be the logout page
@app.route('/logout')
def logout():
    # Remove session data, this will log the user out
   session.pop('loggedin', None)
   session.pop('user_id', None)
   session.pop('username', None)
   session.pop('id', None)
   # Redirect to login page
   return redirect(url_for('login')) 


