from scmsapp.model.db import get_cursor
from datetime import datetime, timedelta

# Modules to handle queries in relation to generating reports

# Return total payments group by product type within given date range
# For reporting
def get_total_payment_by_date_range(date_from, date_to):
    # Add an extra day to include the date_to date
    date_to = datetime.strptime(date_to, '%Y-%m-%d') + timedelta(days=1)
    connection = get_cursor()
    query = """
            SELECT 
            p.id AS product_id,
            p.product_name,
            COALESCE(SUM(IFNULL(pm.total, 0)), 0) AS total
            FROM product p
            LEFT JOIN payment pm 
            ON p.id = pm.product_id 
            AND pm.pay_time >= %(date_from)s AND pm.pay_time < %(date_to)s AND pm.is_paid = 1
            GROUP BY p.id, p.product_name
            ORDER BY p.id;
            """
    connection.execute(
        query, 
        {
            'date_from': date_from,
            'date_to': date_to

        },
        )
    return connection.fetchall()

# For class popularity report
# Return a list of aqua class tpyes with their total bookings
def get_class_types_with_total_bookings_by_date_range(date_from, date_to):
    # Add an extra day to include the date_to date
    date_to = datetime.strptime(date_to, '%Y-%m-%d') + timedelta(days=1)
    connection = get_cursor()
    query = """
            SELECT ct.class_name,
            SUM((15 - c.open_slot)) AS total_bookings
            FROM class c
            INNER JOIN class_type ct 
            ON c.class_type = ct.id
            WHERE ct.class_type = 'class'
            AND c.start_time >= %(date_from)s
            AND c.start_time < %(date_to)s
            GROUP BY ct.class_name
            ORDER BY total_bookings DESC;
            """
    connection.execute(
        query, 
        {
            'date_from': date_from,
            'date_to': date_to
        },
        )
    return connection.fetchall()

# Return a list of members with their attendance
def get_members_with_attendance_by_date_range_and_class_type(date_from, date_to, class_type='all'):
    # Add an extra day to include the date_to date
    date_to = datetime.strptime(date_to, '%Y-%m-%d') + timedelta(days=1)
    connection = get_cursor()
    query = """
            (
                SELECT 
                    CONCAT(m.first_name, ' ', m.last_name) AS member_name,
                    SUM(CASE WHEN b.is_attended = 1 THEN 1 ELSE 0 END) AS total_attended,
                    SUM(CASE WHEN b.is_attended = 0 THEN 1 ELSE 0 END) AS total_not_attended,
                    COUNT(b.id) AS total_bookings,
                    ROUND((SUM(CASE WHEN b.is_attended = 1 THEN 1 ELSE 0 END) / COUNT(b.id)) * 100, 2) AS attendance_percentage
                FROM booking b
                INNER JOIN member m on b.member_id = m.id
                INNER JOIN class c ON c.id = b.class_id
                INNER JOIN class_type ct ON c.class_type = ct.id
                WHERE 
                    c.start_time >= %(date_from)s
                    AND c.start_time < %(date_to)s
                    AND ( 
                        %(class_type)s = 'all' OR 
                        (%(class_type)s = 'class' AND ct.class_type = 'class') OR 
                        (%(class_type)s = '1-on-1' AND ct.class_type = '1-on-1')
                    )
                GROUP BY member_name
                ORDER BY attendance_percentage DESC
            )
            UNION ALL
            (
                SELECT 
                    'Overall' AS member_name,
                    SUM(CASE WHEN b.is_attended = 1 THEN 1 ELSE 0 END) AS total_attended,
                    SUM(CASE WHEN b.is_attended = 0 THEN 1 ELSE 0 END) AS total_not_attended,
                    COUNT(b.id) AS total_bookings,
                    ROUND((SUM(CASE WHEN b.is_attended = 1 THEN 1 ELSE 0 END) / COUNT(b.id)) * 100, 2) AS attendance_percentage
                FROM booking b
                INNER JOIN class c ON c.id = b.class_id
                INNER JOIN class_type ct ON c.class_type = ct.id
                WHERE 
                    c.start_time >= %(date_from)s
                    AND c.start_time < %(date_to)s
                    AND ( 
                            %(class_type)s = 'all' OR 
                            (%(class_type)s = 'class' AND ct.class_type = 'class') OR 
                            (%(class_type)s = '1-on-1' AND ct.class_type = '1-on-1')
                        )
            )
            ORDER BY 
                CASE WHEN member_name = 'Overall' THEN 1 ELSE 0 END, 
                attendance_percentage DESC;
            """
    connection.execute(
        query, 
        {
            'date_from': date_from,
            'date_to': date_to,
            'class_type': class_type
        },
        )
    return connection.fetchall()