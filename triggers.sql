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