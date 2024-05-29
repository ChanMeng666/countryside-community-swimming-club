from scmsapp import app
from flask import render_template, redirect, url_for

# This modules handles routes for errors

# 401 Unauthorized access
# User is not logged in, redirect to login page
@app.errorhandler(401)
def unauthorized(e):
    return redirect(url_for("login"))

# 403 Forbidden access
# User does not have the right level of permission to access
@app.errorhandler(403)
def forbidden(e):
    return render_template("error/403.html"), 403

# 404 Page not found
# User accesses a page that does not exist
@app.errorhandler(404)
def page_not_found(e):
    return render_template("error/404.html"), 404

# 500 Interal Server Error
# Looks like we have a bug
@app.errorhandler(500)
def internal_server_error(error):
    return render_template("error/500.html", error=error), 500