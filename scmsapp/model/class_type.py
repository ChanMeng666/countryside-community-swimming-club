from scmsapp.model.db import get_cursor
from flask import jsonify, abort

# Modules to handle queries in relation to calss_type table

# Return class types by type
def get_class_type_by_type(class_type):
    connection = get_cursor()
    query = """
            SELECT * FROM class_type
            WHERE class_type = %(class_type)s;
            """
    connection.execute(
        query, 
        {
            'class_type': class_type
        },
        )
    return connection.fetchall()

# Return a class type by id
def get_class_type_by_id(id):
    connection = get_cursor()
    query = """
            SELECT * FROM class_type
            WHERE id = %(id)s;
            """
    connection.execute(
        query, 
        {
            'id': id
        },
        )
    return connection.fetchone()

# Update class tpye in database
def update_class_type_by_id(id, class_name, description):
    connection = get_cursor()
    query = """
            UPDATE class_type
            SET class_name = %(class_name)s,
            description = %(description)s
            WHERE id = %(id)s;
            """
    connection.execute(
        query, 
        {
            'id': id,
            'class_name': class_name,
            'description': description
        },
        )
    if connection.rowcount == 1:
        return jsonify({'message': 'success'})
    else:
        return jsonify({'error': 'Something went wrong'}), 500
    
# Add a new class tpye into database
def add_class_type(class_type, class_name, description):
    connection = get_cursor()
    query = """
            INSERT INTO class_type
            (class_type, 
            class_name,
            description)
            VALUES
            (%(class_type)s,
            %(class_name)s,
            %(description)s);
            """
    connection.execute(
        query, 
        {
            'class_type': class_type,
            'class_name': class_name,
            'description': description
        },
        )
    if connection.rowcount == 1:
        return jsonify({'message': 'success'})
    else:
        return jsonify({'error': 'Something went wrong'}), 500
    
# Delete a class type by id from database
def delete_class_type_by_id(id):
    connection = get_cursor()
    query = """
            DELETE FROM class_type
            WHERE id = %(id)s;
            """
    connection.execute(
        query, 
        {
            'id': id
        },
        )
    if connection.rowcount == 1:
        return jsonify({'message': 'success'})
    else:
        return jsonify({'error': 'Something went wrong'}), 500
    