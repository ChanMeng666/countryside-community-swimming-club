import mysql.connector
from scmsapp import connect

# Module to connect to database

dbconn = None
connection = None

def get_cursor():
    global dbconn
    global connection
    connection = mysql.connector.connect(
        user=connect.dbuser,
        password=connect.dbpass, 
        host=connect.dbhost, 
        port=connect.dbport,
        auth_plugin='mysql_native_password',
        database=connect.dbname, 
        autocommit=True)
    # Return resuelts as Dictionaries rather than lists of tuples
    dbconn = connection.cursor(dictionary=True)
    return dbconn