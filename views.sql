-- Views

-- Get course average grade
CREATE VIEW CourseAverageGrade AS
SELECT
    c.ID AS CourseID,
    c.Name AS CourseName,
    AVG(e.Grade) AS AverageGrade
FROM
    Course c
JOIN
    SemesterCourse sc ON c.ID = sc.CourseID
JOIN
    Enrollments e on sc.ID = e.SemesterCourseID
WHERE
    e.Grade IS NOT NULL
GROUP BY
    c.ID, c.Name;

-- Get courses that take place in current semester
CREATE VIEW CourseInCurrentSemester AS
SELECT
    c.ID AS CourseID,
    c.Name AS CourseName,
    s.ID AS SemesterID,
    s.Name AS SemesterName,
    s.StartDate,
    s.EndDate
FROM
    Course c
JOIN
    SemesterCourse sc ON c.ID = sc.CourseID
JOIN
    Semester s ON sc.SemesterID = s.ID
WHERE
    GETDATE() BETWEEN s.StartDate AND s.EndDate;

-- Get top 10 students
CREATE VIEW GetTop10Students AS
SELECT TOP(10)
    s.ID AS StudentID,
    s.FirstName,
    s.LastName,
    AVG(e.Grade) AS AverageGrade
FROM
    Student s
JOIN
    Enrollments e ON s.ID = e.StudentID
WHERE
    e.Grade IS NOT NULL
GROUP BY
    s.ID, s.FirstName, s.LastName
ORDER BY AverageGrade DESC;

-- Get professor's current semester course count
CREATE VIEW ProfessorCourseCount AS
SELECT
    p.ID AS ProfessorID,
    p.FirstName,
    p.LastName,
    COUNT(sc.ID) AS CurrentSemesterCourseCount
FROM
    Professor p
JOIN
    SemesterCourse sc ON p.ID = sc.ProfessorID
JOIN
    Semester s ON sc.SemesterID = s.ID
WHERE
    GETDATE() BETWEEN s.StartDate AND s.EndDate
GROUP BY
    p.ID, p.FirstName, p.LastName;

-- Get students that didn't pass at least one semester course
CREATE VIEW StudentsWithIncompleteCourses AS
SELECT
    s.ID AS StudentID,
    s.FirstName,
    s.LastName,
    se.Name AS CourseName
FROM
    Student s
JOIN
    Enrollments e ON s.ID = e.StudentID
JOIN
    SemesterCourse sc ON e.SemesterCourseID = sc.ID
JOIN
    Semester se ON sc.SemesterID = se.ID
WHERE
    (GETDATE() BETWEEN se.StartDate AND se.EndDate)
    AND
    (e.Grade IS NULL OR e.Grade < 3.0);
