# Swimming Club Management System (SCMS)

A comprehensive web-based management system built with Flask and MySQL to streamline operations for community swimming clubs. The system handles membership management, class bookings, instructor scheduling, facility management, and much more.

## 🌟 Key Features

### For Members
- Self-service membership registration and renewal
- Class and lesson booking capabilities 
- Personal dashboard with booking history
- Profile management with health information
- Customizable membership plans (Monthly/Annual)

### For Instructors
- Personal schedule management
- Class attendance tracking
- Student progress monitoring
- Profile and availability management
- Direct communication with members

### For Managers
- Comprehensive membership oversight
- Dynamic class scheduling and management
- Facility and pool lane allocation
- Financial reporting and analytics
- Staff management tools
- News and announcement system

## 🛠️ Technology Stack

- **Backend:** Python Flask
- **Database:** MySQL
- **Frontend:** HTML, CSS, JavaScript, Bootstrap
- **Authentication:** Flask-Hashing
- **Template Engine:** Jinja2

## 📋 Prerequisites

- Python 3.8+
- MySQL Server
- Git

## ⚙️ Installation

1. Clone the repository
```bash
git clone https://github.com/ChanMeng666/Countryside-Community-Swimming-Club.git
cd Countryside-Community-Swimming-Club
```

2. Create and activate virtual environment (Optional but recommended)
```bash
python -m venv venv
source venv/bin/activate  # On Windows use: .\venv\Scripts\activate
```

3. Install dependencies
```bash
pip install -r requirements.txt
```

4. Configure database connection
- Create `connect.py` file in the `scmsapp` directory
- Add your MySQL credentials

5. Initialize database
```bash
mysql -u your_username -p < scms.sql
```

## 🚀 Running the Application

1. Start the server
```bash
python run.py
```

2. Access the application at `http://localhost:5000`

## 👥 Default Login Credentials

- **Members:** member1 to member20 (Password: Test1234)
- **Instructors:** instructor1 to instructor5 (Password: Test1234)
- **Managers:** manager1 and manager2 (Password: Test1234)

## 📁 Project Structure

```
swimming-club-management/
├── scmsapp/
│   ├── model/          # Database models and business logic
│   ├── route/          # URL routing and view functions
│   ├── static/         # CSS, JavaScript, and images
│   └── templates/      # HTML templates
├── requirements.txt    # Project dependencies
├── run.py             # Application entry point
└── scms.sql          # Database schema and initial data
```

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## ⚠️ Important Notes

- Adjust MySQL Workbench settings for handling large datasets (>1000 rows)
- Disable 'Safe Updates' mode for proper SQL script execution
- Ensure proper configuration of database credentials in connect.py

## 🔑 Security Features

- Password hashing using Flask-Hashing
- Role-based access control
- Session management
- Input validation and sanitization

## 📄 License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details
