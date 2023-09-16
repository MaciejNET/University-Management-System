-- Init Database
CREATE DATABASE UniversityDB;
GO

USE UniversityDB;
GO

-- Tables

-- Course Table
CREATE TABLE Course(
    ID INT NOT NULL IDENTITY(1,1),
    Name VARCHAR(64) NOT NULL UNIQUE,
    ECTS INT NOT NULL CHECK (ECTS > 0),
    CONSTRAINT PK_Course PRIMARY KEY (ID)
);

-- ExamResult Table
CREATE TABLE ExamResult(
    ID INT NOT NULL IDENTITY(1,1),
    StudentID INT NOT NULL,
    ExamID INT NOT NULL,
    Mark FLOAT NOT NULL CHECK (Mark IN (2.0, 3.0, 3.5, 4.0, 4.5, 5.0)),
    CONSTRAINT PK_ExamResult PRIMARY KEY (ID)
);

-- Semester Table
CREATE TABLE Semester(
    ID INT NOT NULL IDENTITY(1,1),
    Name VARCHAR(64) NOT NULL,
    StartDate DATE NOT NULL,
    EndDate DATE NOT NULL,
    CONSTRAINT CHK_Semester_Dates CHECK (StartDate < EndDate),
    CONSTRAINT PK_Semester PRIMARY KEY (ID)
);

-- Professor Table
CREATE TABLE Professor(
    ID INT NOT NULL IDENTITY(1,1),
    FirstName VARCHAR(64) NOT NULL CHECK (FirstName LIKE '[A-Z]%'),
    LastName VARCHAR(64) NOT NULL CHECK (LastName LIKE '[A-Z]%'),
    Email VARCHAR(64) NOT NULL UNIQUE,
    Sex CHAR(1) CHECK (Sex IN ('M', 'F', 'O')), -- M - male, F - female, O - other
    PhoneNumber CHAR(9) CHECK (PhoneNumber LIKE '[0-9]%'),
    DateOfBirth DATE NOT NULL,
    DateOfJoin DATE NOT NULL,
    CONSTRAINT PK_Professor PRIMARY KEY (ID)
);

-- Exam Table
CREATE TABLE Exam(
    ID INT NOT NULL IDENTITY(1,1),
    SemesterCourseID INT NOT NULL,
    Name VARCHAR(64) NOT NULL,
    Date DATE NOT NULL,
    CONSTRAINT PK_Exam PRIMARY KEY (ID)
);

-- SemesterCourse Table
CREATE TABLE SemesterCourse(
    ID INT NOT NULL IDENTITY(1,1),
    CourseID INT NOT NULL,
    SemesterID INT NOT NULL,
    ProfessorID INT NOT NULL,
    ClassRoomID INT NOT NULL,
    DayOfWeek VARCHAR(3) NOT NULL CHECK (DayOfWeek IN ('Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun')),
    StartTime TIME NOT NULL,
    EndTime TIME NOT NULL,
    CONSTRAINT CHK_SemesterCourse_Times CHECK (StartTime < EndTime),
    CONSTRAINT PK_SemesterCourse PRIMARY KEY (ID)
);

-- Student Table
CREATE TABLE Student(
    ID INT NOT NULL IDENTITY(1,1),
    FirstName VARCHAR(64) NOT NULL CHECK (FirstName LIKE '[A-Z]%'),
    LastName VARCHAR(64) NOT NULL CHECK (LastName LIKE '[A-Z]%'),
    Email VARCHAR(64) NOT NULL UNIQUE,
    Sex CHAR(1) CHECK (Sex IN ('M', 'F', 'O')), -- M - male, F - female, O - other
    DateOfBirth DATE NOT NULL,
    PhoneNumber CHAR(9) CHECK (PhoneNumber LIKE '[0-9]%'),
    DateOfJoin DATE NOT NULL,
    CONSTRAINT PK_Student PRIMARY KEY (ID)
);

-- ClassRoom Table
CREATE TABLE ClassRoom(
    ID INT NOT NULL IDENTITY(1,1),
    Name VARCHAR(64) NOT NULL,
    NumberOfSeats INT NOT NULL CHECK (NumberOfSeats > 0),
    CONSTRAINT PK_ClassRoom PRIMARY KEY (ID)
);

-- Enrollments Table
CREATE TABLE Enrollments(
    ID INT NOT NULL IDENTITY(1,1),
    SemesterCourseID INT NOT NULL,
    StudentID INT NOT NULL,
    Grade FLOAT CHECK (Grade IN (2.0, 3.0, 3.5, 4.0, 4.5, 5.0)),
    CONSTRAINT PK_Enrollments PRIMARY KEY (ID)
);

-- Foreign Key Constraints

-- Enrollments Table
ALTER TABLE Enrollments
    ADD CONSTRAINT FK_Enrollments_SemesterCourse FOREIGN KEY(SemesterCourseID) REFERENCES SemesterCourse(ID);

ALTER TABLE Enrollments
    ADD CONSTRAINT FK_Enrollments_Student FOREIGN KEY(StudentID)REFERENCES Student(ID);

-- Exam Table
ALTER TABLE Exam
    ADD CONSTRAINT FK_Exam_SemesterCourse FOREIGN KEY(SemesterCourseID) REFERENCES SemesterCourse(ID);

-- ExamResult Table
ALTER TABLE ExamResult
    ADD CONSTRAINT FK_ExamResult_Student FOREIGN KEY(StudentID) REFERENCES Student(ID);

ALTER TABLE ExamResult
    ADD CONSTRAINT FK_ExamResult_Exam FOREIGN KEY(ExamID) REFERENCES Exam(ID);

-- SemesterCourse Table
ALTER TABLE SemesterCourse
    ADD CONSTRAINT FK_SemesterCourse_Course FOREIGN KEY(CourseID) REFERENCES Course(ID);

ALTER TABLE SemesterCourse
    ADD CONSTRAINT FK_SemesterCourse_Semester FOREIGN KEY(SemesterID) REFERENCES Semester(ID);

ALTER TABLE SemesterCourse
    ADD CONSTRAINT FK_SemesterCourse_Professor FOREIGN KEY(ProfessorID) REFERENCES Professor(ID);

ALTER TABLE SemesterCourse
    ADD CONSTRAINT FK_SemesterCourse_ClassRoom FOREIGN KEY(ClassRoomID) REFERENCES ClassRoom(ID);
GO
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
GO

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
GO

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
GO

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
GO

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
GO

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
GO

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
GO

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
GO

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
GO

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
GO

-- Procedures

-- Create Student
CREATE PROCEDURE CreateStudent
    @FirstName VARCHAR(64),
    @LastName VARCHAR(64),
    @Email VARCHAR(64),
    @Sex CHAR(1),
    @DateOfBirth DATE,
    @PhoneNumber CHAR(9),
    @DateOfJoin DATE
AS
BEGIN
    INSERT INTO Student(FirstName, LastName, Email, Sex, DateOfBirth, PhoneNumber, DateOfJoin)
    VALUES (@FirstName, @LastName, @Email, @Sex, @DateOfBirth, @PhoneNumber, @DateOfJoin);
END;
GO

-- Delete Student
CREATE PROCEDURE DeleteStudent
    @StudentID INT
AS
BEGIN
    IF EXISTS (SELECT 1 FROM Student WHERE ID = @StudentID)
    BEGIN
        DELETE FROM Student WHERE ID = @StudentID;
    END
    ELSE
    BEGIN
        PRINT 'Student with the given ID does not exist.';
    END
END;
GO

-- Enroll Student to course
CREATE PROCEDURE EnrollStudentToCourse
    @StudentID INT,
    @SemesterCourseID INT
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Enrollments WHERE StudentID = @StudentID AND SemesterCourseID = @SemesterCourseID)
    BEGIN
        INSERT INTO Enrollments(StudentID, SemesterCourseID)
        VALUES (@StudentID, @SemesterCourseID);
        PRINT 'Student successfully enrolled.';
    END
    ELSE
    BEGIN
        PRINT 'Student is already enrolled in this course.';
    END
END;
GO

-- Update Grade
CREATE PROCEDURE UpdateGrade
    @EnrollmentID INT,
    @NewGrade FLOAT
AS
BEGIN
    UPDATE Enrollments
    SET Grade = @NewGrade
    WHERE ID = @EnrollmentID;
END;
GO

-- Create Course
CREATE PROCEDURE CreateCourse
    @Name VARCHAR(64),
    @ECTS INT
AS
BEGIN
    INSERT INTO Course(Name, ECTS)
    VALUES (@Name, @ECTS);
END;
GO

-- Create Semester
CREATE PROCEDURE CreateSemester
    @Name VARCHAR(64),
    @StartDate DATE,
    @EndDate DATE
AS
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM Semester
        WHERE (@StartDate BETWEEN StartDate AND EndDate) OR
              (@EndDate BETWEEN StartDate AND EndDate) OR
              (StartDate BETWEEN @StartDate AND @EndDate) OR
              (EndDate BETWEEN @StartDate AND @EndDate)
    )
    BEGIN
        INSERT INTO Semester(Name, StartDate, EndDate)
        VALUES (@Name, @StartDate, @EndDate);
        PRINT 'Semester successfully created.';
    END
    ELSE
    BEGIN
        PRINT 'Another semester exists within the same time frame.';
    END
END;
GO

-- Create Class Room
CREATE PROCEDURE CreateClassRoom
    @Name VARCHAR(64),
    @NumberOfSeats INT
AS
BEGIN
    INSERT INTO ClassRoom(Name, NumberOfSeats)
    VALUES (@Name, @NumberOfSeats);
END;
GO

-- Create Professor
CREATE PROCEDURE CreateProfessor
    @FirstName VARCHAR(64),
    @LastName VARCHAR(64),
    @Email VARCHAR(64),
    @Sex CHAR(1),
    @DateOfBirth DATE,
    @PhoneNumber CHAR(9),
    @DateOfJoin DATE
AS
BEGIN
    INSERT INTO Professor(FirstName, LastName, Email, Sex, DateOfBirth, PhoneNumber, DateOfJoin)
    VALUES (@FirstName, @LastName, @Email, @Sex, @DateOfBirth, @PhoneNumber, @DateOfJoin);
END;
GO

-- Delete Professor
CREATE PROCEDURE DeleteProfessor
    @ProfessorID INT
AS
BEGIN
    IF EXISTS (SELECT 1 FROM Professor WHERE ID = @ProfessorID)
    BEGIN
        DELETE FROM Professor WHERE ID = @ProfessorID;
        PRINT 'Professor successfully deleted.';
    END
    ELSE
    BEGIN
        PRINT 'Professor with the given ID does not exist.';
    END
END;
GO

-- Create Exam
CREATE PROCEDURE CreateExam
    @SemesterCourseID INT,
    @Name VARCHAR(64),
    @Date DATE
AS
BEGIN
    INSERT INTO Exam(SemesterCourseID, Name, Date)
    VALUES (@SemesterCourseID, @Name, @Date);
END;
GO

-- Create Exam Result
CREATE PROCEDURE CreateExamResult
    @StudentID INT,
    @ExamID INT,
    @Mark FLOAT
AS
BEGIN
    INSERT INTO ExamResult(StudentID, ExamID, Mark)
    VALUES (@StudentID, @ExamID, @Mark);
END;
GO

-- Update Exam Result
CREATE PROCEDURE UpdateExamResult
    @ExamResultID INT,
    @NewMark FLOAT
AS
BEGIN
    IF EXISTS (SELECT 1 FROM ExamResult WHERE ID = @ExamResultID)
    BEGIN
        UPDATE ExamResult
        SET Mark = @NewMark
        WHERE ID = @ExamResultID;
        PRINT 'Exam result successfully updated.';
    END
    ELSE
    BEGIN
        PRINT 'Exam result with the given ID does not exist.';
    END
END;
GO

-- Create SemesterCourse
CREATE PROCEDURE CreateSemesterCourse
    @CourseID INT,
    @SemesterID INT,
    @ProfessorID INT,
    @ClassRoomID INT,
    @StartTime TIME,
    @EndTime TIME,
    @DayOfWeek VARCHAR(3)
AS
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM SemesterCourse
        WHERE ClassRoomID = @ClassRoomID
          AND DayOfWeek = @DayOfWeek
          AND (
              (@StartTime BETWEEN StartTime AND EndTime) OR
              (@EndTime BETWEEN StartTime AND EndTime) OR
              (StartTime BETWEEN @StartTime AND @EndTime) OR
              (EndTime BETWEEN @StartTime AND @EndTime)
          )
    )
    BEGIN
        INSERT INTO SemesterCourse(CourseID, SemesterID, ProfessorID, ClassRoomID, StartTime, EndTime, DayOfWeek)
        VALUES (@CourseID, @SemesterID, @ProfessorID, @ClassRoomID, @StartTime, @EndTime, @DayOfWeek);
        PRINT 'Semester course successfully created.';
    END
    ELSE
    BEGIN
        PRINT 'Another course exists in the same classroom at the same time on the same day.';
    END
END;
GO

-- Triggers

-- Delete Related Records When Deleting Student
CREATE TRIGGER DeleteStudentRecordsTrigger
ON Student
AFTER DELETE
AS
BEGIN
    DELETE e
    FROM Enrollments e
    INNER JOIN deleted d ON e.StudentID = d.ID;

    DELETE er
    FROM ExamResult er
    INNER JOIN deleted d ON er.StudentID = d.ID;
END;
GO