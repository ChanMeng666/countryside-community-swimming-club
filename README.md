# Countryside Community Swimming Club Management System

The Countryside Community Swimming Club Management System is a comprehensive solution designed to streamline the operations of a community-based swimming club. The system automates membership management, class bookings, instructor scheduling, payments tracking, and much more, empowering members, instructors, and managers with role-based access to various functionalities.

## Getting Started

These instructions will get you a copy of the project up and running on your local machine for development and testing purposes.

### Prerequisites

Ensure you have the following installed:
- Python 3.8 or above
- MySQL
- Git

### Installation

1. **Clone the repository:**

   ```bash
   git clone https://github.com/LUMasterOfAppliedComputing2024S1/COMP639S1_Group_AQ.git
   cd COMP639S1_Group_AQ
   ```

2. **Set up a virtual environment (Optional but recommended):**

```bash
python -m venv venv
source venv/bin/activate  # On Windows use `.\venv\Scripts\activate`
```

3. **Install the dependencies:**
```bash
pip install -r requirements.txt
```

4. **Configure database settings:**

Create a `connect.py` file under the `scmsapp` directory with your MySQL database credentials.

5.**Initialize the database:**

Run the `scms.sql` script in your MySQL workbench to set up the database schema and populate it with initial data.


### Configuration Tips
- To handle more than 1000 rows in MySQL Workbench, adjust the settings as described [here](https://superuser.com/questions/240291/how-to-remove-1000-row-limit-in-mysql-workbench-queries).
- Disable `Safe Updates` in MySQL Workbench for the SQL scripts to run properly.

### Usage
1. Start the server:

```bash
python run.py
```
Access the web application by navigating to http://localhost:5000 in your web browser.

2. Default Login Credentials:

- Members: member1 to member20 (Password: Test1234)
- Instructors: instructor1 to instructor5 (Password: Test1234)
- Managers: manager1 and manager2 (Password: Test1234)


### Contributing
Please create a branch for each new feature or improvement, commit your changes, and submit a pull request for review.

### Project Structure
- `scmsapp`: Main application directory containing Flask setups, configurations, and blueprints.
- `model/`: Includes Python models for database interactions.
- `route/`: Flask routes that handle all the endpoint requests.
- `static/`: Contains CSS, JS, and image files.
- `templates/`: HTML templates for the application.

### Licence
This project is licensed under the MIT License - see the LICENSE.md file for details.








