# Useful commands

Display all lecturers and their info.
```mysql
select user_id, institute, users.name FROM lecturers JOIN users ON lecturers.user_id = users.id
```


Display all students and their info
```mysql
SELECT * FROM students JOIN users ON students.user_id = users.id
```

Useful info for bookings
```mysql
SELECT room_id, start_time, description, users.name FROM bookings JOIN users ON bookings.user_id = users.id
```

# Delete all tables

```mysql
DROP TABLE bookings;
DROP TABLE students_courses;
DROP TABLE courses;
DROP TABLE rooms;
DROP TABLE lecturers;
DROP TABLE users;
```


# Some initial solutions

Task 2: "Show a list of all courses taught by a specific teacher in a given semester."
Switch out the ID with the lecturer ID in question.
```mysql
SELECT lecturer.name AS lecturer_name, courses.name AS course_name
FROM (
  SELECT * 
  FROM lecturers_simple 
  WHERE lecturers_simple.user_id = 1) AS lecturer
JOIN courses ON lecturer.user_id = lecturer_id
```