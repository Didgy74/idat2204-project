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

#TODO: ADD EMAIL
@app.route('/<username>/task05')
def task05(username):
    query = """
        SELECT * FROM courses_info;
    """
    return run_query(username, query)

#TODO: ADD FACULTY
@app.route('/<username>/task06/<lecturer_id>')
def task06(username, lecturer_id):
    query = f"""
        SELECT * 
        FROM courses
        JOIN lecturers_info ON lecturer_id = lecturers_info.user_id
        WHERE courses.lecturer_id = {lecturer_id}; 
    """
    return run_query(username, query)


@app.route('/<username>/task07/<lecturer_id>')
def task07(username, lecturer_id):
    query = f"""
        SELECT room_id, building, course_name, description, booking_date, start_hour, end_hour, lecturer_id
        FROM bookings
        JOIN courses ON bookings.course_id = courses.id
        JOIN rooms ON rooms.id = bookings.room_id
        WHERE
            bookings.course_id IS NOT NULL AND
            courses.lecturer_id = {lecturer_id}        
        ORDER BY booking_date;
    """
    return run_query(username, query)

@app.route('/<username>/task08/<date>/<start>/<end>')
def task08(username, date, start, end):
    query = f"""
        SELECT 
            rooms.id AS room_id,
            rooms.size AS room_size,
            rooms.building
        FROM rooms
        LEFT OUTER JOIN (
            SELECT *
            FROM bookings 
            WHERE 
                booking_date = '{date}' AND (
                    (start_hour <= {start} AND end_hour > {start}) OR 
                    (start_hour >= {start} AND start_hour < {end})
                )
            ) AS t1 ON rooms.id = t1.room_id
            WHERE t1.room_id IS NULL
        ORDER BY rooms.id;
    """
    return run_query(username, query)


@app.route('/<username>/task09/<user_id>')
def task09(username, user_id):
    query = f"""
        SELECT 
            bookings.user_id, 
            users.real_name,
            bookings.room_id, 
            rooms.building, 
            booking_date, 
            start_hour, 
            end_hour,
            description
        FROM bookings
        JOIN rooms ON bookings.room_id = rooms.id
        JOIN users ON bookings.user_id = users.id
        WHERE bookings.user_id = {user_id};
    """
    return run_query(username, query)


@app.route('/<username>/task10')
def task10(username):
    query = f"""
        SELECT 
            rooms.id AS room_id, 
            rooms.size AS room_size, 
            rooms.building, 
            bookings.id AS booking_id,
            users.real_name AS user_realname,
            bookings.id AS course_id,
            booking_date,
            start_hour,
            end_hour
        FROM rooms
        LEFT JOIN bookings ON bookings.room_id = rooms.id
        LEFT JOIN users ON bookings.user_id = users.id
        ORDER BY rooms.id;
    """
    return run_query(username, query)

#TODO: ADD A BOOKING BOOKING TYPE ?
@app.route('/<username>/task11')
def task11(username):
    query = f"""
SELECT rooms.id                AS "room number",
       Count(bookings.room_id) AS bookings_count
FROM   rooms
       LEFT JOIN bookings
              ON rooms.id = bookings.room_id
GROUP  BY rooms.id; 
    """
    return run_query(username, query)

@app.route('/<username>/task12')
def task12(username):
    query = """
SELECT u.real_name          AS teacher_name,
       l.user_id            AS teacher_id,
       Count(c.lecturer_id) AS course_count
FROM   lecturers l
       LEFT JOIN courses c
              ON l.user_id = c.lecturer_id
       JOIN users u
         ON l.user_id = u.id
GROUP  BY l.user_id,
          u.real_name
ORDER  BY course_count DESC; 
    """
    return run_query(username, query)

@app.route('/<username>/task13')
def task13(username):
    query = """
SELECT l.user_id   AS lecturer_user_id,
       c.course_name,
       r.id        AS room_number,
       r.building,
       u.real_name AS teacher_name
FROM   lecturers l
       JOIN users u
         ON l.user_id = u.id
       JOIN bookings b
         ON l.user_id = b.user_id
       JOIN courses c
         ON b.course_id = c.id
       JOIN rooms r
         ON b.room_id = r.id; 
    """
    return run_query(username, query)

#GETS TOTAL HOURS IN THE WHOLE DATABASE, NOT EACH WEEK. NEED TO CHANGE THIS
#TODO: ADD WEEK NUMBER TO BOOKINGS?
@app.route('/<username>/task14')
def task14(username):
    query = """
SELECT lecturers.user_id,
       users.real_name                              AS lecturer,
       Sum(bookings.end_hour - bookings.start_hour) AS total_hours
FROM   lecturers
       INNER JOIN bookings
               ON lecturers.user_id = bookings.user_id
       INNER JOIN users
               ON lecturers.user_id = users.id
GROUP  BY lecturers.user_id,
          users.real_name;
    """
    return run_query(username, query)

#TODO: ADD WEEKDAYS TO BOOKINGS?
@app.route('/<username>/task15')
def task15(username):
    query = """
    """
    return run_query(username, query)

#TODO: ADD NUMBER OF STUDENTS FIELD IN COURSES
@app.route('/<username>/task16')
def task16(username):
    query = """
    """
    return run_query(username, query)

if __name__ == '__main__':
    app.run()
