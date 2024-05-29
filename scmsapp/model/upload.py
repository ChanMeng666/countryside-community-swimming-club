from scmsapp import app
from scmsapp.model import profile
from scmsapp.model.db import get_cursor
from flask import jsonify
import os
from werkzeug.utils import secure_filename
# This module handles file uploading to server

# Config for file upload folder and allowed file format
UPLOAD_FOLDER = './scmsapp/static/images/profile_images'
ALLOWED_EXTENSIONS = {'png', 'jpg', 'jpeg', 'gif'}

app.config['UPLOAD_FOLDER'] = UPLOAD_FOLDER

def allowed_file(filename):
    return '.' in filename and filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS

def upload_image_by_user_id(user_id, role, image):
    # Set upload folder using user id 
    # Create the folder if not exist
    upload_folder = os.path.join(app.config['UPLOAD_FOLDER'], str(user_id))
    if not os.path.exists(upload_folder):
        os.makedirs(upload_folder)
    # Check if file exists and format meets requirement
    if image and allowed_file(image.filename):
        filename = secure_filename(image.filename)
        # Rename file namee using <first_name>-<last_name> format
        user = profile.get_profile_by_user_id_role(user_id, role)
        first_name = user['first_name']
        last_name = user['last_name']
        filename = f"{first_name.lower()}_{last_name.lower()}.{filename.split('.')[-1]}"
        # Save image file in new folder
        image.save(os.path.join(upload_folder, filename))
        filename = secure_filename(filename)
        # Add image record to db
        connection = get_cursor()
        if role == 'member':
            query = """UPDATE member
                    SET image = %(image)s
                    WHERE user_id = %(user_id)s;
                    """
            connection.execute(
                query,
                {
                    "user_id": user_id,
                    "image": filename
                }
            )
        elif role == 'instructor':
            query = """UPDATE instructor
                    SET image = %(image)s
                    WHERE user_id = %(user_id)s;
                    """
            connection.execute(
                query,
                {
                    "user_id": user_id,
                    "image": filename
                }
            )   
        if connection.rowcount == 1:
            return jsonify({'message': 'success'})
    else:
        return jsonify({'error': 'Something went wrong uploading image'}), 500