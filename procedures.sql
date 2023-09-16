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

-- Create Course
CREATE PROCEDURE CreateCourse
    @Name VARCHAR(64),
    @ECTS INT
AS
BEGIN
    INSERT INTO Course(Name, ECTS)
    VALUES (@Name, @ECTS);
END;

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

-- Create Class Room
CREATE PROCEDURE CreateClassRoom
    @Name VARCHAR(64),
    @NumberOfSeats INT
AS
BEGIN
    INSERT INTO ClassRoom(Name, NumberOfSeats)
    VALUES (@Name, @NumberOfSeats);
END;

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
