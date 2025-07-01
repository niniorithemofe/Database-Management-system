

-- Create TRIGGER

DROP TRIGGER IF EXISTS trgEmployeeDelete
GO

CREATE TRIGGER trgEmployeeDelete
ON tblEmployee  INSTEAD OF DELETE
AS
BEGIN
   

    SET NOCOUNT ON;

	
    UPDATE e
    SET e.EmployeeActiveFlag = 0, 
		e.ModifyDate = GETDATE(), 
		e.ModifiedBy = SUSER_NAME()
    FROM tblEmployee e
    INNER JOIN deleted d ON e.EmployeeID = d.EmployeeID;
END;
go

DROP TRIGGER IF EXISTS trgEmployeeUpdate
GO

CREATE TRIGGER trgEmployeeUpdate
ON tblEmployee  FOR UPDATE
AS
BEGIN
	INSERT INTO tblEmployeeHistory (
		EmployeeID,
		EmployeeLastName,
		EmployeeFirstName,
		EmployeeMiddleInitial,
		EmployeeDateOfBirth,
		EmployeeNumber,
		EmployeeSSN,
		EmployeeActiveFlag,
		CreateDate,
		CreatedBy,
		ModifyDate,
		ModifiedBy
	)
	SELECT	h.EmployeeID,
			h.EmployeeLastName,
			h.EmployeeFirstName,
			h.EmployeeMiddleInitial,
			h.EmployeeDateOfBirth,
			h.EmployeeNumber,
			h.EmployeeSSN,
			h.EmployeeActiveFlag,
			h.CreateDate,
			h.CreatedBy,
			h.ModifyDate,
			h.ModifiedBy
	FROM	tblEmployee h 
	INNER JOIN inserted i ON
		h.EmployeeID = i.EmployeeID

    UPDATE e
	SET		e.ModifyDate = GETDATE(), 
			e.ModifiedBy = SUSER_NAME()
    FROM	tblEmployee e 
	INNER JOIN inserted i ON
		e.EmployeeID = i.EmployeeID
   
END;