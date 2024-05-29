from scmsapp import app
from flask import render_template, redirect, url_for, request, session, flash, abort, jsonify
from scmsapp.model.session import allow_role
from scmsapp.model import report, date_time_utils

# This module handles routes for manager reports

# Route to view the list of reports
@app.route('/reports')
def all_reports():
    # Only manager can access
    allow_role(['manager'])
    return render_template('report/all-reports.html')

# Route to view the financial report
@app.route('/report/financial-report')
def view_financial_report():
    # Only manager can access
    allow_role(['manager'])
    # Fetch date range
    date_from = request.args.get('date_from')
    date_to = request.args.get('date_to')
    date_range = request.args.get('date_range')
    # If date range is selected, set date_from and date_to accordingly
    if date_range == 'this_month':
        date_from, date_to = date_time_utils.get_current_month_date_range()
    elif date_range == 'last_month':
        date_from, date_to = date_time_utils.get_last_month_date_range()
    elif date_range == 'this_fy':
        date_from, date_to = date_time_utils.get_this_finanial_year_date_range()
    elif date_range == 'last_fy':
        date_from, date_to = date_time_utils.get_last_finanial_year_date_range()
    # If no date range is selcted Set default date range as current month
    elif not (date_from and date_to):
        date_from, date_to = date_time_utils.get_current_month_date_range()
    financial_report = report.get_total_payment_by_date_range(date_from, date_to)
    # Caluldate total of all products and add to dictionary
    financial_report.append({'product_id': 999,
                   'product_name': 'Total', 
                   'total': sum(product['total'] for product in financial_report)
                   })
    return render_template('report/financial-report.html', report=financial_report, date_from=date_from, date_to=date_to, date_range=date_range)

# Route to view the popular classes report
@app.route('/report/popular-classes')
def view_class_report():
    # Only manager can access
    allow_role(['manager'])
    # Fetch date range
    date_from = request.args.get('date_from')
    date_to = request.args.get('date_to')
    # Set default date range as current month
    if not (date_from and date_to):
        date_from, date_to = date_time_utils.get_current_month_date_range()
    class_report = report.get_class_types_with_total_bookings_by_date_range(date_from, date_to)
    return render_template('report/class-report.html', report=class_report, date_from=date_from, date_to=date_to)


# Route to view member attedance report
@app.route('/report/member-attendance')
def view_attendance_report():
    # Only manager can access
    allow_role(['manager'])
    # Fetch date range
    date_from = request.args.get('date_from')
    date_to = request.args.get('date_to')
    class_type = request.args.get('class_type')
    # Set default date range as current month
    if not (date_from and date_to and class_type):
        date_from, date_to = date_time_utils.get_current_month_date_range()
        class_type = 'all'
    attendance_report = report.get_members_with_attendance_by_date_range_and_class_type(date_from, date_to, class_type)
    return render_template('report/attendance-report.html', report=attendance_report, date_from=date_from, date_to=date_to, class_type=class_type)