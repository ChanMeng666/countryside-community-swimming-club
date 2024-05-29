from scmsapp.model.db import get_cursor

def fetch_all_group_class_with_details(start_date, end_date):
    cursor = get_cursor()
    cursor.execute("""
        SELECT class.id, class.instructor_id, class.location_id, class.class_type, class.start_time, class.end_time, class.open_slot,
               instructor.title AS instructor_title, instructor.first_name, instructor.last_name, instructor.position,
               location.pool_name, location.lane_name,
               class_type.class_type AS type, class_type.class_name
        FROM class
        INNER JOIN instructor ON class.instructor_id = instructor.id
        INNER JOIN location ON class.location_id = location.id
        INNER JOIN class_type ON class.class_type = class_type.id
        WHERE class.start_time >= %s AND class.start_time < %s AND class_type.class_type = 'class'
        ORDER BY class.start_time ASC;
    """, (start_date.strftime('%Y-%m-%d'), end_date.strftime('%Y-%m-%d')))
    classes_with_details = cursor.fetchall()
    cursor.close()
    return classes_with_details

# Fetch classes for a week
def fetch_classes_for_week_with_details(start_date, end_date):
    cursor = get_cursor()
    cursor.execute("""
        SELECT class.id, class.instructor_id, class.location_id, class.class_type, class.start_time, class.end_time, class.open_slot,
               instructor.title AS instructor_title, instructor.first_name, instructor.last_name, instructor.position,
               location.pool_name, location.lane_name,
               class_type.class_type AS type, class_type.class_name
        FROM class
        INNER JOIN instructor ON class.instructor_id = instructor.id
        INNER JOIN location ON class.location_id = location.id
        INNER JOIN class_type ON class.class_type = class_type.id
        WHERE class.start_time >= %s AND class.start_time < %s
        ORDER BY class.start_time ASC;
    """, (start_date.strftime('%Y-%m-%d'), end_date.strftime('%Y-%m-%d')))
    classes_with_details = cursor.fetchall()
    cursor.close()
    return classes_with_details

# Fetch classes for a week for a specific instructor
def fetch_classes_for_week_with_details_for_instructor(start_date, end_date, instructor_id):
    cursor = get_cursor()
    cursor.execute("""
        SELECT class.id, class.instructor_id, class.location_id, class.class_type, class.start_time, class.end_time, class.open_slot,
               instructor.title AS instructor_title, instructor.first_name, instructor.last_name, instructor.position,
               location.pool_name, location.lane_name,
               class_type.class_type AS type, class_type.class_name
        FROM class
        INNER JOIN instructor ON class.instructor_id = instructor.id
        INNER JOIN location ON class.location_id = location.id
        INNER JOIN class_type ON class.class_type = class_type.id
        WHERE class.start_time >= %s AND class.start_time < %s
        AND instructor.id = %s
        ORDER BY class.start_time ASC;
    """, (start_date.strftime('%Y-%m-%d'), end_date.strftime('%Y-%m-%d'), instructor_id))
    classes_with_details = cursor.fetchall()
    cursor.close()

    print(classes_with_details)

    return classes_with_details
