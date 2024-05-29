# Formatters for timetable data
def format_datetime_for_input(dt):
    # Format datetime object as a string of the form 'YYYY-MM-DDTHH:MM'
    return dt.strftime('%Y-%m-%dT%H:%M')