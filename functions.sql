-- Functions

-- Get user's enrollments for semester
CREATE FUNCTION GetUserEnrollmentsForSemester(@StudentID INT, @SemesterID INT)
RETURNS TABLE
AS
RETURN (
    SELECT
        e.ID AS EnrollmentID,
        c.Name AS CourseName,
        sc.StartTime,
        sc.EndTime,
        p.FirstName + ' ' + p.LastName AS ProfessorName,
        e.Grade
    FROM
        Enrollments e
    JOIN
        SemesterCourse sc ON e.SemesterCourseID = sc.ID
    JOIN
        Course c ON sc.CourseID = c.ID
    JOIN
        Professor p ON sc.ProfessorID = p.ID
    WHERE
        e.StudentID = @StudentID AND sc.SemesterID = @SemesterID
);

-- Get exam results stats
CREATE FUNCTION GetExamResultsStats(@ExamID INT)
RETURNS TABLE
AS
RETURN (
    SELECT
        Mark,
        COUNT(*) AS MarkCount
    FROM
        ExamResult
    WHERE
        ExamID = @ExamID
    GROUP BY
        Mark
);

-- Get student GPA
CREATE FUNCTION GetStudentGPA(@StudentID INT)
RETURNS FLOAT
AS
BEGIN
    DECLARE @GPA FLOAT;
    SELECT @GPA = AVG(e.Grade)
    FROM Enrollments e
    WHERE e.StudentID = @StudentID AND e.Grade IS NOT NULL;
    RETURN @GPA;
END;

-- Get user exam result
CREATE FUNCTION GetUserExamResults(@StudentID INT)
RETURNS TABLE
AS
RETURN (
    SELECT
        er.ID AS ExamResultID,
        c.Name AS CourseName,
        er.Mark,
        ex.Name AS ExamName,
        ex.Date AS ExamDate,
        p.FirstName + ' ' + p.LastName AS ProfessorName
    FROM
        ExamResult er
    JOIN
        Exam ex ON er.ExamID = ex.ID
    JOIN
        SemesterCourse sc ON ex.SemesterCourseID = sc.ID
    JOIN
        Course c ON sc.CourseID = c.ID
    JOIN
        Professor p ON sc.ProfessorID = p.ID
    WHERE
        er.StudentID = @StudentID
);

-- Get details of semester course
CREATE FUNCTION GetSemesterCourseDetails(@SemesterCourseID INT)
RETURNS TABLE
AS
RETURN (
    SELECT
        sc.ID AS SemesterCourseID,
        c.Name AS CourseName,
        c.ECTS,
        s.Name AS SemesterName,
        s.StartDate AS SemesterStartDate,
        s.EndDate AS SemesterEndDate,
        p.FirstName + ' ' + p.LastName AS ProfessorName,
        cr.Name AS ClassroomName,
        cr.NumberOfSeats,
        sc.DayOfWeek,
        sc.StartTime,
        sc.EndTime
    FROM
        SemesterCourse sc
    JOIN
        Course c ON sc.CourseID = c.ID
    JOIN
        Semester s ON sc.SemesterID = s.ID
    JOIN
        Professor p ON sc.ProfessorID = p.ID
    JOIN
        ClassRoom cr ON sc.ClassRoomID = cr.ID
    WHERE
        sc.ID = @SemesterCourseID
);
