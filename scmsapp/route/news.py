from scmsapp import app
from flask import render_template,request, session, redirect, url_for, flash, jsonify
from scmsapp.model import db
import re
from datetime import datetime
from scmsapp.model.session import allow_role


@app.route("/news/list", methods=['GET', 'POST'])
def news_list():
    if 'loggedin' in session:
        connection = db.get_cursor()
        connection.execute('SELECT * FROM news ORDER BY date DESC;')
        news = connection.fetchall()
        return render_template ('news/news_list.html', news = news)
    return redirect(url_for('home'))


@app.route("/news/detail/<int:news_id>", methods=['GET', 'POST'])
def news_detail(news_id):

    cursor = db.get_cursor()
    cursor.execute('SELECT * FROM news WHERE id=%s;',(news_id,))
    news = cursor.fetchone()
    manager_id = news['author']

    cursor.execute('SELECT first_name, last_name FROM manager WHERE id=%s;',(manager_id,))
    result = cursor.fetchone()
    author = result['first_name'] + ' ' + result['last_name']

    return render_template ('news/news_detail.html', news = news, author = author)


@app.route("/news_manage", methods=['GET', 'POST'])
def news_manage():
    allow_role(['manager'])
    try:
        manager_id = session['id']
        if request.method == 'POST':
            news_id = request.form.get('news_id')
            title = request.form.get('newsTittle')
            content = request.form.get('content')
            cursor = db.get_cursor()
            if news_id:
                # update
                cursor.execute('UPDATE news SET title=%s, content=%s WHERE id=%s;',(title, content, news_id))
                flash('News updated successfully!', 'success')
            else:
                # add
                cursor = db.get_cursor()
                cursor.execute('INSERT INTO news (author, title, content, date) VALUES (%s, %s, %s, %s);', (manager_id, title, content, datetime.now()))
                flash('News added successfully!', 'success')
            return jsonify({'success': True})
                      
    except Exception as e:
        flash('Network error!Fail!' , 'error')
    return jsonify({'success': False, 'error': 'Something went wrong'}), 500 


@app.route("/news/delete", methods=['GET', 'POST'])
def news_delete():
    allow_role(['manager'])
    try:
        news_id = request.json.get('news_id')
        cursor = db.get_cursor()
        # Start a transaction
        cursor.execute("START TRANSACTION")
        cursor.execute("DELETE FROM news WHERE id = %s;", (news_id,))
        # Commit the transaction
        db.connection.commit()
        flash('News deleted successfully!', 'success')
        return jsonify({'success': True})
    except Exception as e:
        # Rollback
        db.connection.rollback()
        flash('Network error!Fail to delete!' , 'error')
        return jsonify({'success': False, 'error': str(e)})
    