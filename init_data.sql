-- Initialize Course Table
INSERT INTO Course (Name, ECTS)
VALUES ('Mathematics', 6),
       ('Physics', 5),
       ('Chemistry', 4);

-- Initialize Professor Table
INSERT INTO Professor (FirstName, LastName, Email, Sex, PhoneNumber, DateOfBirth, DateOfJoin)
VALUES ('John', 'Doe', 'john.doe@email.com', 'M', '123456789', '1980-01-01', '2020-01-01'),
       ('Jane', 'Smith', 'jane.smith@email.com', 'F', '987654321', '1985-05-05', '2019-09-01');

-- Initialize ClassRoom Table
INSERT INTO ClassRoom (Name, NumberOfSeats)
VALUES ('Room 101', 30),
       ('Room 102', 25);

-- Initialize Semester Table
INSERT INTO Semester (Name, StartDate, EndDate)
VALUES ('Fall 2023', '2023-09-01', '2023-12-31'),
       ('Spring 2024', '2024-01-01', '2024-05-31');

-- Initialize SemesterCourse Table
INSERT INTO SemesterCourse (CourseID, SemesterID, ProfessorID, ClassRoomID, DayOfWeek, StartTime, EndTime)
VALUES (1, 1, 1, 1, 'Mon', '09:00:00', '11:00:00'),
       (2, 1, 2, 2, 'Wed', '14:00:00', '16:00:00');

-- Initialize Student Table
INSERT INTO Student (FirstName, LastName, Email, Sex, DateOfBirth, PhoneNumber, DateOfJoin)
VALUES ('Alice', 'Johnson', 'alice.johnson@email.com', 'F', '2000-06-15', '111222333', '2021-09-01'),
       ('Bob', 'Williams', 'bob.williams@email.com', 'M', '1999-11-30', '444555666', '2021-09-01');

-- Initialize Enrollments Table
INSERT INTO Enrollments (SemesterCourseID, StudentID)
VALUES (1, 1),
       (1, 2),
       (2, 1);

-- Initialize Exam Table
INSERT INTO Exam (SemesterCourseID, Name, Date)
VALUES (1, 'Midterm', '2023-10-15'),
       (1, 'Final', '2023-12-20'),
       (2, 'Midterm', '2023-10-10');

-- Initialize ExamResult Table
INSERT INTO ExamResult (StudentID, ExamID, Mark)
VALUES (1, 1, 4.0),
       (2, 1, 3.5),
       (1, 3, 4.5);
