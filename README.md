<div align="center">
 <h1> 🏊‍♂️ Swimming Club Management System (SCMS)</h1>
 <img src="https://img.shields.io/badge/Python-3.8+-blue.svg"/>
 <img src="https://img.shields.io/badge/Flask-3.0.2-brightgreen.svg"/>
 <img src="https://img.shields.io/badge/MySQL-8.3.0-orange.svg"/>
 <img src="https://img.shields.io/badge/Bootstrap-Latest-purple.svg"/>
 <img src="https://img.shields.io/badge/License-MIT-brightgreen.svg"/>
</div>
<br/>

<br/>

[![Ask DeepWiki](https://deepwiki.com/badge.svg)](https://deepwiki.com/ChanMeng666/countryside-community-swimming-club)

[![👉Try It Now!👈](https://gradient-svg-generator.vercel.app/api/svg?text=%F0%9F%91%89Try%20It%20Now!%F0%9F%91%88&color=000000&height=60&gradientType=radial&duration=6s&color0=ffffff&template=pride-rainbow)](https://countryside-community-sw-6wqr4e1.gamma.site/)

<br/>

# Overview
SCMS is a comprehensive web-based management system built with Flask and MySQL to streamline operations for community swimming clubs. The system handles membership management, class bookings, instructor scheduling, facility management, payments, and administrative reporting - providing an all-in-one solution for swimming club operations.

# ⭐ Key Features

### 👥 For Members
- Self-service membership registration and renewal
- Class and lesson booking capabilities 
- Personal dashboard with booking history
- Profile management with health information
- Customizable membership plans (Monthly/Annual)
- Online payment processing

### 🏅 For Instructors
- Personal schedule management 
- Class attendance tracking
- Student progress monitoring
- Profile and availability management
- Direct communication with members

### 👨‍💼 For Managers
- Comprehensive membership oversight
- Dynamic class scheduling and management 
- Facility and pool lane allocation
- Financial reporting and analytics
- Staff management tools
- News and announcement system

## 🛠️ Technology Stack

- **Backend:** Python Flask 3.0.2
- **Database:** MySQL 8.3.0
- **Frontend:** HTML5, CSS3, JavaScript, Bootstrap
- **Authentication:** Flask-Hashing
- **Template Engine:** Jinja2
- **Other Libraries:**
  - mysql-connector-python 8.3.0
  - werkzeug 3.0.1
  - blinker 1.7.0
  - click 8.1.7
  - colorama 0.4.6
  - itsdangerous 2.1.2

## 📋 Prerequisites

- Python 3.8+
- MySQL Server 8.3.0+
- Git

## ⚙️ Installation

1. Clone the repository
```bash
git clone https://github.com/ChanMeng666/countryside-community-swimming-club.git
cd countryside-community-swimming-club
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

## 🔑 Security Features

- Password hashing using Flask-Hashing
- Role-based access control
- Session management
- Input validation and sanitization
- Secure database operations

## ⚠️ Important Notes

- Adjust MySQL Workbench settings for handling large datasets (>1000 rows)
- Disable 'Safe Updates' mode for proper SQL script execution
- Ensure proper configuration of database credentials in connect.py

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📝 License

This project is licensed under the Apache-2.0 license - see the [Apache-2.0 license](LICENSE) file for details.

## 📧 Contact

For any queries or issues, please contact: ChanMeng666@outlook.com

## 🙋‍♀ Author

Created and maintained by [Chan Meng](https://github.com/ChanMeng666).
