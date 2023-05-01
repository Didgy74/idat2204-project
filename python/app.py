from flask import Flask, jsonify
import pymysql
from markupsafe import escape

app = Flask(__name__)


def create_connection(username):
    config = {
        'host': 'localhost',
        'user': username,
        'password': '',
        'db': 'project',
        'charset': 'utf8mb4',
        'cursorclass': pymysql.cursors.DictCursor

    }

    # Create a connection object
    return pymysql.connect(**config)


def run_query(username, query):
    connection = create_connection(username)
    with connection.cursor() as cursor:
        cursor.execute(query)
        data = cursor.fetchall()
        response = jsonify(data)
    return response


@app.route('/<username>/task01')
def task01(username):
    query = f"""
        CALL courses_for_lecturer(null);
    """
    return run_query(username, query)


@app.route('/<username>/task02/<lecturer_id>')
def task02(username, lecturer_id):
    query = f"""
        CALL courses_for_lecturer({lecturer_id});
    """
    return run_query(username, query)


@app.route('/<username>/task05')
def task05(username):
    query = f"""
        SELECT * FROM courses_info;
    """
    return run_query(username, query)


@app.route('/<username>/task06/<lecturer_id>')
def task06(username, lecturer_id):
    query = f"""
        CALL courses_for_lecturer({lecturer_id});
    """
    return run_query(username, query)


if __name__ == '__main__':
    app.run()
