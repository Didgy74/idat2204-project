from flask import Flask, jsonify
import pymysql
from markupsafe import escape

app = Flask(__name__)


def create_connection():
    config = {
        'host': 'localhost',
        'user': 'root',
        'password': '',
        'db': 'project',
        'charset': 'utf8mb4',
        'cursorclass': pymysql.cursors.DictCursor
    }

    # Create a connection object
    return pymysql.connect(**config)


def run_query(username, query):
    connection = create_connection()
    with connection.cursor() as cursor:
        cursor.execute(query)
        data = cursor.fetchall()
        response = jsonify(data)
    return response


@app.route('/<username>/task01')
def task01(username):
    query = f"""
        SELECT room_id, building, course_name, description, booking_date, start_hour, end_hour, lecturer_id
        FROM bookings
        JOIN courses ON bookings.course_id = courses.id
        JOIN rooms ON rooms.id = bookings.room_id
        WHERE
            bookings.course_id IS NOT NULL AND
            courses.lecturer_id IS NULL        
        ORDER BY booking_date;
    """
    return run_query(username, query)


@app.route('/<username>/task02/<lecturer_id>')
def task02(username, lecturer_id):
    query = f"""
        SELECT lecturer_id, real_name, institute, course_name
        FROM SELECT * FROM courses 
        JOIN lecturers_info ON lecturers_info.user_id = T.lecturer_id;
        WHERE lecturer_id = {lecturer_id};
    """
    return run_query(username, query)


@app.route('/<username>/task03/<room>/<date>/<start_hour>/<end_hour>')
def task03(username, room, date, start_hour, end_hour):
    query = f"""
        SELECT *
        FROM bookings 
        WHERE 
            room_id = {room} AND 
            course_id IS NOT NULL AND
            booking_date = '{date}' AND (
                (start_hour <= {start_hour} AND end_hour > {start_hour}) OR 
                (start_hour >= {start_hour} AND start_hour < {end_hour})
            );
    """
    return run_query(username, query)


@app.route('/<username>/task04/<room>/<date>/<hour>')
def task04(username, room, date, hour):
    query = f"""
        SELECT *
        FROM bookings 
        WHERE 
            room_id = {room} AND 
            course_id IS NOT NULL AND
            booking_date = '{date}' AND
            start_hour <= {hour} AND 
            end_hour > {hour};
    """
    return run_query(username, query)


@app.route('/<username>/task05')
def task05(username):
    query = """
        SELECT * FROM courses_info;
    """
    return run_query(username, query)


@app.route('/<username>/task06/<lecturer_id>')
def task06(username, lecturer_id):
    query = f"""
        SELECT * 
        FROM courses
        JOIN lecturers_info ON lecturer_id = lecturers_info.user_id
        WHERE courses.lecturer_id = {lecturer_id}; 
    """
    return run_query(username, query)


if __name__ == '__main__':
    app.run()
