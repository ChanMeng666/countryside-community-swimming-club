from scmsapp.model.db import get_cursor
from flask import jsonify, abort

# Modules to handle queries in relation to location table

# Return all locations
def get_all_locations():
    connection = get_cursor()
    query = """
            SELECT * FROM location;
            """
    connection.execute(query)
    return connection.fetchall()