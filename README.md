# Swimming Club Management System
* Update 277/3/2024 New single SQL file now available with loads of sample data, please check Step 5
## Getting started
### 1. Clone the repo

#### 1.1 Using GitHub Desktop
Simply click `Code` and `Open with GitHub Desktop`, and save repo to your preferred location.

#### 1.2 Using command line
1. Nagivate to where you would like to save the repo by using `cd your/path/`
2. `git clone https://github.com/LUMasterOfAppliedComputing2024S1/COMP639S1_Group_AQ.git`

### 2. Config `connect.py`
Create `connect.py` under `scmsapp` folder with your database configuration. (sql script to create database will be provided later)

### 3. (Optional) create virtual environment
1. Open your local repo folder with VS Code
2. Open Command Pellete by pressing `Ctrl+Shift+P`
3. Tpye in and select `Python: Create Environment`
4. Select `Venv` and the Python version you want to use

### 4. Install dependancies
1. After creating the environment, run Terminal: Create New Terminal or press `` Ctrl+Shift+` ``
2. Enter command `pip install -r requirements.txt`
3. All required dependancies should be installed one by one.

### 5. Create database
All database related files are under `database` folder.
* _New_ Run `scms.sql` in MySQL workbench. This drops existing database and create new database with all tables and over 6000 rows of data. 
* You might need to remove the 1000-row limit in MySQL workbench > https://superuser.com/questions/240291/how-to-remove-1000-row-limit-in-mysql-workbench-queries
* _20240408 Update_ Updated SQL with procedure and event to update membership status automatically. `Safe Updates` mode needs to be tunred of in MySQL workbench: Go to `Eidt` > `Peferences` > `SQL Editor` > Uncheck `Safe Updates` > Go to `Query` > `Reconnect to server`.
* Below is old steps 

~~1. Run `scmsdb.sql` in MySQL workbench. This will create the databse and all tables for you.~~
~~For PythonAnywhere, run `scmsdb_pa.sql` after creating database using web UI~~
~~2. Run `data.sql` in MySQL workbench. This will populate 27 sample users in the database.~~
~~3. Run `data_step2.sql` in MySQL workbench. This will populate all other data.~~


### 6. Create a New Branch and start coding
* In GitHub Desktop, simply click Current branch and New branch
* Commland line `git branch new-branch-name`

### 7. Test user accounts
* Member: `member1` - `member20`
* Instructor: `instructor1` - `instructor5`
* Manager: `manager1` - `manager2`
* All passwords are `Test1234` by default

## Overall structure 2024-03-12
This is the overall structure of the webapp. 
`run.py` is the entry point, and the package is sotred in `scmsapp` folder. 

### `scmsapp` folder
* `__init__.py` is where the flask instance is created and all routes are imported
* `secret.py` stores the app secret key
* `connect.py` is also located here but added in .gitignore so you can setup your own db config

### `model` folder
* All `py` files that handle interactions with the database, i.e. excuting sql queries.
* As defined in `db.py`, query results are returned as dicintonaries rather than lists of tuples
* `session.py` `allow_role(role_list: list)` is a simple utility to check if user is logged in and user role can access the page 

Other `py` files that handles non-routing functions, e.g. db connection, user authentication

### `route` folder
`py` files that only handle the routes of the app. For readablity and modulasation, it should have not any SQL queru and complex function 

### `static` folder
For `javascript`, `css`, and images

### `templates` folder
For `HTML` files. Subfolders should be created for pages in the same functionality  
