from scmsapp.model.db import get_cursor
from flask import jsonify, abort
from datetime import datetime, timedelta

# Modules to handle queries in relation to payment table

# Return payments within given date range
def get_payment_by_date_range(date_from, date_to):
    # Add an extra day to include the date_to date
    date_to = date_to + timedelta(days=1)
    connection = get_cursor()
    query = """
            SELECT *
            FROM payment
            WHERE pay_time >= %(date_from)s AND pay_time < %(date_to)s;
            """
    connection.execute(
        query, 
        {
            'date_from': date_from,
            'date_to': date_to

        },
        )
    return connection.fetchall()
