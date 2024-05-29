from flask import current_app

from scmsapp.model.db import get_cursor

def check_for_overlap(location_id, start_time, end_time, instructor_id=None, class_id=None):
    cursor = get_cursor()

    try:
        # Use a dummy class_id if not provided to prevent SQL errors
        class_id = class_id if class_id is not None else -1

        # Check for location overlap ( exclude courses currently being edited )
        location_overlap_query = """
        SELECT * FROM class
        WHERE id != %s AND location_id = %s AND NOT (end_time <= %s OR start_time >= %s)
        """
        cursor.execute(location_overlap_query, (class_id, location_id, start_time, end_time))

        location_conflict = cursor.fetchone()
        # Ensure all results are read from the cursor for this query
        cursor.fetchall()

        if location_conflict:
            cursor.close()
            return 'Location overlap. * Two or more courses cannot be scheduled at the same location during the same time period. *'

        # Check for instructor overlap
        if instructor_id:
            instructor_overlap_query = """
            SELECT * FROM class
            WHERE id != %s AND instructor_id = %s AND NOT (end_time <= %s OR start_time >= %s)
            """
            cursor.execute(instructor_overlap_query, (class_id, instructor_id, start_time, end_time))

            instructor_conflict = cursor.fetchone()
            # Ensure all results are read from the cursor for this query
            cursor.fetchall()

            if instructor_conflict:
                cursor.close()
                return 'Instructor overlap. * The same instructor cannot teach two or more courses in the same time period. *'

    except Exception as e:
        current_app.logger.error(f'Error checking for overlap: {e}')
        raise e

    finally:
        cursor.close()

    return None