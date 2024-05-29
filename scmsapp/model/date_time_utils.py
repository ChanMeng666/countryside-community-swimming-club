import datetime

# This module handles dates generation

# Return the Monday of current week
def current_monday(date):
    return date - datetime.timedelta(days=date.weekday()) 

# Return a list of dates of current week starting from Monday
def current_week_dates(date):
    monday = current_monday(date)
    return [monday + datetime.timedelta(days=i) for i in range(7)]

# Set date from to Monday of the week by given date or today by default
def get_date_from(date_input):
    if date_input:
        date_input = datetime.datetime.strptime(date_input, '%Y-%m-%d')
    # By default show timetable of current week
    else:
        # Set date from as Monday of current week by default
        date_input = datetime.date.today()
    return current_monday(date_input)

# Return a list of time slots from 6AM to 8PM in half-hour interval
def get_time_slots():
    time_slots = []
    for hour in range(6, 21):  # Hours from 6 am to 8 pm
        for minute in ['00', '30']:  # Minutes: 00 and 30 for half-hour intervals
            formatted_hour = hour % 12 if hour % 12 != 0 else 12  # Convert 24-hour format to 12-hour format
            am_pm = 'AM' if hour < 12 else 'PM'  # Determine AM or PM
            time_slots.append(f"{formatted_hour}:{minute} {am_pm}")
    return time_slots

# Return from date and to date of the current month
def get_current_month_date_range():
    # Get the current date
    today = datetime.datetime.today()
    # Get the first day of the current month
    first_day_of_month = today.replace(day=1)
    # Get the last day of the current month
    last_day_of_month = first_day_of_month.replace(month=first_day_of_month.month+1) - datetime.timedelta(days=1)
    # Return in string format
    return first_day_of_month.strftime('%Y-%m-%d'), last_day_of_month.strftime('%Y-%m-%d')

# Return from date and to date of the last month
def get_last_month_date_range():
    # Get the current date
    today = datetime.datetime.today()
    # Get the first day of the current month
    first_day_of_current_month = today.replace(day=1)
    # Get the last day of the last month
    last_day_of_last_month = first_day_of_current_month - datetime.timedelta(days=1)
    # Get the first day of the last month
    first_day_of_last_month = last_day_of_last_month.replace(day=1)
    # Return in string format
    return first_day_of_last_month.strftime('%Y-%m-%d'), last_day_of_last_month.strftime('%Y-%m-%d')

# Return from date and to date of the current financial year
def get_this_finanial_year_date_range():
    # Get the current date, year, month
    today = datetime.datetime.today()
    current_year = today.year
    current_month = today.month
    # If current is April or after, current FY starts Apr 1 of current year
    if current_month >= 4:
        date_from = datetime.date(current_year, 4, 1)
        date_to = datetime.date(current_year + 1, 3, 31)
    # If current is March or before, current FY starts Apr 1 of last year
    else:
        date_from = datetime.date(current_year - 1, 4, 1)
        date_to = datetime.date(current_year, 3, 31)
    return date_from.strftime('%Y-%m-%d'), date_to.strftime('%Y-%m-%d')

# Return from date and to date of the last financial year
def get_last_finanial_year_date_range():
    # Get the current date, year, month
    today = datetime.datetime.today()
    current_year = today.year
    current_month = today.month
    # If current is April or after, current FY starts Apr 1 of current year
    # Last FY starts Apr of last year
    if current_month >= 4:
        date_from = datetime.date(current_year - 1, 4, 1)
        date_to = datetime.date(current_year, 3, 31)
    # If current is March or before, current FY starts Apr 1 of last year
    # Last FY starts Apr of year before last year
    else:
        date_from = datetime.date(current_year - 2, 4, 1)
        date_to = datetime.date(current_year - 1, 3, 31)
    return date_from.strftime('%Y-%m-%d'), date_to.strftime('%Y-%m-%d')