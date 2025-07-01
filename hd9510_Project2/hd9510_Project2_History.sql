  /****************************************************************
    Author Name: nini ola
    Create Date: [11/29/23]
    Functionality: Copy current record value to the employee history table before update.
    Assumptions: None
    ****************************************************************/


CREATE TRIGGER trgEmployeeHistory
ON tblEmployee
AFTER UPDATE
AS
BEGIN
  

    SET NOCOUNT ON;

    INSERT INTO tblEmployeeHistory (
        EmployeeID, EmployeeLastName, EmployeeFirstName, EmployeeMiddleInitial,
        EmployeeDateOfBirth, EmployeeNumber, EmployeeGender, EmployeeSSN,
        EmployeeActiveFlag, CreateDate, CreatedBy, ModifyDate, ModifiedBy
    )
    SELECT
        d.EmployeeID, d.EmployeeLastName, d.EmployeeFirstName, d.EmployeeMiddleInitial,
        d.EmployeeDateOfBirth, d.EmployeeNumber, d.EmployeeGender, d.EmployeeSSN,
        d.EmployeeActiveFlag, d.CreateDate, d.CreatedBy, GETDATE() AS ModifyDate, 'Trigger' AS ModifiedBy
    FROM deleted d;
END;




 /*
    Author Name: nini ola
    Create Date: [11/29/23]
    Functionality: Replace physical delete with logical delete using EmployeeActiveFlag.
    Assumptions: None
    */

-- Drop the existing trigger if it exists
IF OBJECT_ID('trgEmployeeDelete', 'TR') IS NOT NULL
    DROP TRIGGER trgEmployeeDelete;
GO

-- Create TRIGGER
CREATE TRIGGER trgEmployeeDelete
ON tblEmployee
INSTEAD OF DELETE
AS
BEGIN
   

    SET NOCOUNT ON;

    UPDATE e
    SET e.EmployeeActiveFlag = 0, e.ModifyDate = GETDATE(), e.ModifiedBy = 'Trigger'
    FROM tblEmployee e
    INNER JOIN deleted d ON e.EmployeeID = d.EmployeeID;
END;
