    /****************************************************************
    Author Name: Nini Ola 
    Create Date: [11/29/2023]
    Parameter 1: @EmployeeLastName
    Parameter 2: @EmployeeFirstName
    Parameter 3: @EmployeeMiddleInitial
    Parameter 4: @EmployeeDateOfBirth
    Parameter 5: @EmployeeNumber
    Parameter 6: @EmployeeGender
    Parameter 7: @EmployeeSSN
    Functionality: Create a new employee record, ensuring business rules are not violated. Log errors in tblLogErrors. Return EmployeeID.
    Assumptions: None
    ****************************************************************/


CREATE PROCEDURE usp_InsertEmployee
    @EmployeeLastName VARCHAR(50),
    @EmployeeFirstName VARCHAR(50),
    @EmployeeMiddleInitial CHAR(1),
    @EmployeeDateOfBirth DATE,
    @EmployeeNumber VARCHAR(20),
    @EmployeeGender CHAR(1),
    @EmployeeSSN VARCHAR(11)
AS
BEGIN
    BEGIN TRY
        -- Check business rules
        IF (LEN(@EmployeeMiddleInitial) > 1 OR (@EmployeeMiddleInitial IS NOT NULL AND LEN(@EmployeeMiddleInitial) = 0))
        BEGIN
            -- Business rule: Middle Initial can only be 1 character unless none provided, which is an empty string.
            THROW 50001, 'Middle Initial can only be 1 character unless none provided, which is an empty string.', 1;
        END;

        IF (NOT EXISTS(SELECT 1 FROM tblEmployee WHERE EmployeeSSN = @EmployeeSSN))
        BEGIN
            -- Business rule: Employee DOB must be a reasonable range (adjust the range as needed)
            IF (@EmployeeDateOfBirth < '1900-01-01' OR @EmployeeDateOfBirth > GETDATE())
                THROW 50002, 'Invalid Employee Date of Birth.', 1;

            -- Business rule: Employee Number starts with the first letter of the Employee Last Name followed by 6 digits
           IF (
    SUBSTRING(@EmployeeNumber, 1, 6) <> LEFT(@EmployeeSSN, 6)
    OR LEN(@EmployeeNumber) <> 7
    OR TRY_CONVERT(INT, SUBSTRING(@EmployeeNumber, 2, LEN(@EmployeeNumber))) IS NULL
)
THROW 50003, 'Invalid Employee Number.', 1;

            -- Insert employee record
            INSERT INTO tblEmployee (
                EmployeeLastName, EmployeeFirstName, EmployeeMiddleInitial, EmployeeDateOfBirth,
                EmployeeNumber, EmployeeGender, EmployeeSSN, CreatedBy
            )
            VALUES (
                @EmployeeLastName, @EmployeeFirstName, @EmployeeMiddleInitial, @EmployeeDateOfBirth,
                @EmployeeNumber, @EmployeeGender, @EmployeeSSN, 'nini'
            );

            -- Return EmployeeID
            SELECT SCOPE_IDENTITY() AS EmployeeID;
        END
        ELSE
        BEGIN
            -- Business rule: Employee with the provided SSN already exists
            THROW 50004, 'Employee with the provided SSN already exists.', 1;
        END
    END TRY
    BEGIN CATCH
        -- Log errors into tblLogErrors
        INSERT INTO tblLogErrors (ErrorMessage)
        VALUES (ERROR_MESSAGE());

        -- Rethrow the error
        THROW;
    END CATCH;
END;




    /****************************************************************
    Author Name: Your Name
    Create Date: [Current Date]
    Parameter 1: @EmployeeID
    Parameter 2: @EmployeeLastName
    Parameter 3: @EmployeeFirstName
    Parameter 4: @EmployeeMiddleInitial
    Parameter 5: @EmployeeDateOfBirth
    Parameter 6: @EmployeeNumber
    Parameter 7: @EmployeeGender
    Parameter 8: @EmployeeSSN
    Parameter 9: @EmployeeActiveFlag
    Functionality: Update employee record with provided information. Populate Modified Date and ModifiedBy.
    Assumptions: None
    ****************************************************************/

	CREATE PROCEDURE usp_UpdateEmployee
    @EmployeeID INT,
    @EmployeeLastName VARCHAR(50),
    @EmployeeFirstName VARCHAR(50),
    @EmployeeMiddleInitial CHAR(1),
    @EmployeeDateOfBirth DATE,
    @EmployeeNumber VARCHAR(20),
    @EmployeeGender CHAR(1),
    @EmployeeSSN VARCHAR(11),
    @EmployeeActiveFlag BIT
AS
BEGIN
 

    BEGIN TRY
        -- Check if the employee exists
        IF EXISTS(SELECT 1 FROM tblEmployee WHERE EmployeeID = @EmployeeID)
        BEGIN
            -- Check business rules
            IF (LEN(@EmployeeMiddleInitial) > 1 OR (LEN(@EmployeeMiddleInitial) = 0 AND @EmployeeMiddleInitial IS NOT NULL))
                THROW 50001, 'Middle Initial can only be 1 character unless none provided, which is an empty string.', 1;

            -- Business rule: Employee DOB must be a reasonable range (adjust the range as needed)
            IF (@EmployeeDateOfBirth < '1900-01-01' OR @EmployeeDateOfBirth > GETDATE())
                THROW 50002, 'Invalid Employee Date of Birth.', 1;

            -- Business rule: Employee Number starts with the first letter of the Employee Last Name followed by 6 digits
            IF (
                SUBSTRING(@EmployeeNumber, 1, 1) <> SUBSTRING(@EmployeeLastName, 1, 1) COLLATE Latin1_General_CS_AS
                OR LEN(@EmployeeNumber) <> 7
                OR TRY_CONVERT(INT, SUBSTRING(@EmployeeNumber, 2, LEN(@EmployeeNumber))) IS NULL
            )
            THROW 50003, 'Invalid Employee Number.', 1;

            -- Truncate values that exceed the specified lengths
            SET @EmployeeLastName = LEFT(@EmployeeLastName, 50);
            SET @EmployeeFirstName = LEFT(@EmployeeFirstName, 50);
            SET @EmployeeMiddleInitial = LEFT(@EmployeeMiddleInitial, 1);
            SET @EmployeeNumber = LEFT(@EmployeeNumber, 20);
            SET @EmployeeGender = LEFT(@EmployeeGender, 1);
            SET @EmployeeSSN = LEFT(@EmployeeSSN, 11);

            -- Update employee record
            UPDATE tblEmployee
            SET
                EmployeeLastName = @EmployeeLastName,
                EmployeeFirstName = @EmployeeFirstName,
                EmployeeMiddleInitial = @EmployeeMiddleInitial,
                EmployeeDateOfBirth = @EmployeeDateOfBirth,
                EmployeeNumber = @EmployeeNumber,
                EmployeeGender = @EmployeeGender,
                EmployeeSSN = @EmployeeSSN,
                EmployeeActiveFlag = @EmployeeActiveFlag,
                ModifyDate = GETDATE(),
                ModifiedBy = 'System'
            WHERE EmployeeID = @EmployeeID;
        END
        ELSE
        BEGIN
            THROW 50004, 'Employee does not exist.', 1;
        END
    END TRY
    BEGIN CATCH
        -- Log errors into tblLogErrors
        INSERT INTO tblLogError (ErrorMessage)
        VALUES (ERROR_MESSAGE());

        -- Rethrow the error
        THROW;
    END CATCH;
END;







/****************************************************************
Author Name: Nini Ola
Create Date: [11/29/23]
Parameter 1: @EmployeeID
Functionality: Perform a logical delete on the employee record. Trigger trgEmployeeDelete will handle physical delete.
Assumptions: The delete functionality uses the active flag.
****************************************************************/

CREATE PROCEDURE usp_DeleteEmployee
    @EmployeeID INT
AS
BEGIN
    BEGIN TRY
        -- Logical Delete (update active flag)
        UPDATE tblEmployee
        SET EmployeeActiveFlag = 0, ModifyDate = GETDATE(), ModifiedBy = 'System'
        WHERE EmployeeID = @EmployeeID;

        -- Check if any rows were affected
        IF @@ROWCOUNT = 0
        BEGIN
            THROW 50005, 'Employee does not exist.', 1;
        END
    END TRY
    BEGIN CATCH
        -- Log errors into tblLogErrors
        INSERT INTO tblLogErrors (ErrorMessage)
        VALUES (ERROR_MESSAGE());

        -- Rethrow the error
        THROW;
    END CATCH;
END;
