from flask import request, render_template, flash, redirect, url_for
from scmsapp.model.db import get_cursor

# Search for classes
def search_classes():
    search_type = request.form.get('search_type')
    search_value = request.form.get('search_value')
    cursor = get_cursor()
    results = []

    try:
        if search_type and search_value:
            search_value = f"%{search_value}%"  # Prepare for a LIKE query
            if search_type == 'instructor_name':
                cursor.execute("""
                    SELECT class.*, instructor.first_name, instructor.last_name, instructor.position,
                    location.pool_name, location.lane_name, class_type.class_name
                    FROM class
                    INNER JOIN instructor ON class.instructor_id = instructor.id
                    INNER JOIN location ON class.location_id = location.id
                    INNER JOIN class_type ON class.class_type = class_type.id
                    WHERE CONCAT(instructor.first_name, ' ', instructor.last_name) LIKE %s
                """, (search_value,))

            elif search_type == 'instructor_position':
                cursor.execute("""
                    SELECT class.*, instructor.first_name, instructor.last_name, instructor.position,
                    location.pool_name, location.lane_name, class_type.class_name
                    FROM class
                    INNER JOIN instructor ON class.instructor_id = instructor.id
                    INNER JOIN location ON class.location_id = location.id
                    INNER JOIN class_type ON class.class_type = class_type.id
                    WHERE instructor.position LIKE %s
                """, (search_value,))
            elif search_type == 'pool_name':
                cursor.execute("""
                    SELECT class.*, instructor.first_name, instructor.last_name, instructor.position,
                    location.pool_name, location.lane_name, class_type.class_name
                    FROM class
                    INNER JOIN instructor ON class.instructor_id = instructor.id
                    INNER JOIN location ON class.location_id = location.id
                    INNER JOIN class_type ON class.class_type = class_type.id
                    WHERE location.pool_name LIKE %s
                """, (search_value,))
            elif search_type == 'lane_name':
                cursor.execute("""
                    SELECT class.*, instructor.first_name, instructor.last_name, instructor.position,
                    location.pool_name, location.lane_name, class_type.class_name
                    FROM class
                    INNER JOIN instructor ON class.instructor_id = instructor.id
                    INNER JOIN location ON class.location_id = location.id
                    INNER JOIN class_type ON class.class_type = class_type.id
                    WHERE location.lane_name LIKE %s
                """, (search_value,))
            elif search_type == 'class_type':
                cursor.execute("""
                    SELECT class.*, instructor.first_name, instructor.last_name, instructor.position,
                    location.pool_name, location.lane_name, class_type.class_name
                    FROM class
                    INNER JOIN instructor ON class.instructor_id = instructor.id
                    INNER JOIN location ON class.location_id = location.id
                    INNER JOIN class_type ON class.class_type = class_type.id
                    WHERE class_type.class_type LIKE %s
                """, (search_value,))
            elif search_type == 'class_name':
                cursor.execute("""
                    SELECT class.*, instructor.first_name, instructor.last_name, instructor.position,
                    location.pool_name, location.lane_name, class_type.class_name
                    FROM class
                    INNER JOIN instructor ON class.instructor_id = instructor.id
                    INNER JOIN location ON class.location_id = location.id
                    INNER JOIN class_type ON class.class_type = class_type.id
                    WHERE class_type.class_name LIKE %s
                """, (search_value,))
            results = cursor.fetchall()
    except Exception as e:
        flash(f'An error occurred: {e}', 'danger')
    finally:
        cursor.close()

    return results

