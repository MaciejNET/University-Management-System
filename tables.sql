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
