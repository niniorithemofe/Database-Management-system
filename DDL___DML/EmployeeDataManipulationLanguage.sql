/**********************************************************************************
    Author Name:	Nini Ola
    Create Date:	12/17/2023
	Parameters:		NONE
	Functionality:  Create database & tables for our Human Resources development and adding maintanance to it 
	Assumptions:	1) EmployeeID -> Internal SQL, EmployeeNum -> user facing
					2) ModifiedBy and ModifiedDate are NULL until record change
					3) Additional Business Rules (Per Subject Matter Expert)
				

***********************************************************************************/






	/****************************************************************
 Author Name:Nini Ola
 Create Date:12/16/2023
 Parameter 1:@EmployeeLastName
 Parameter 2:@EmployeeSSN
 Parameter 3:@EmployeeFirstName
 Parameter 4:@EmployeeMiddleInitial
 Parameter 5:@EmployeeDateOfBirth
 Parameter 6: @EmployeeGender
 Functionality: the function checks and see that there are no bussiness rule violations 
 Assumptions:
 ****************************************************************/
-- Drop the function if it exists
IF EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.ufn_EvaluateEmployeeBusinessRules') AND type IN (N'FN', N'IF', N'TF', N'FS', N'FT'))
    DROP FUNCTION dbo.ufn_EvaluateEmployeeBusinessRules;
GO

-- Create the function
CREATE FUNCTION dbo.ufn_EvaluateEmployeeBusinessRules
(
    @EmployeeLastName NVARCHAR(200),
    @EmployeeFirstName NVARCHAR(200),
    @EmployeeMiddleInitial NVARCHAR(10),
    @EmployeeDateOfBirth DATE,
    @EmployeeGender VARCHAR(5),
    @EmployeeSSN VARCHAR(50)
)
RETURNS TABLE
AS
RETURN
(
    SELECT
        ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS BRViolationID,
        ErrorNumber AS BRViolationErrorNumber,
        ErrorMessage AS BRViolationErrorDescription
    FROM
    (
        -- Check for gender violations
        SELECT
            50130 AS ErrorNumber,
            'GENDER CAN ONLY BE IN (M,F): ' + @EmployeeGender AS ErrorMessage
        WHERE
            @EmployeeGender NOT IN ('M', 'F')

        UNION ALL

        -- Check for DOB violations
        SELECT
            50100 AS ErrorNumber,
            'INVALID AGE (18-72): ' + CONVERT(NVARCHAR(10), @EmployeeDateOfBirth) +
            ' -> ' + CONVERT(NVARCHAR(10), DATEDIFF(YEAR, @EmployeeDateOfBirth, GETDATE())) +
            ' years' AS ErrorMessage
        WHERE
            DATEDIFF(YEAR, @EmployeeDateOfBirth, GETDATE()) NOT BETWEEN 18 AND 72

        UNION ALL

        -- Check for Middle Initial violations
        SELECT
            50120 AS ErrorNumber,
            'MIDDLE INITIAL LENGTH(1 MAX): ' + @EmployeeMiddleInitial +
            ' -> ' + CONVERT(NVARCHAR(10), LEN(@EmployeeMiddleInitial)) AS ErrorMessage
        WHERE
            LEN(@EmployeeMiddleInitial) > 1
    ) AS BusinessRuleViolations
);

GO



DROP PROCEDURE IF EXISTS usp_InsertEmployee
GO



	/****************************************************************
 Author Name:Nini Ola
 Create Date:12/16/2023
 Parameter 1:@EmployeeLastName
 Parameter 2:@EmployeeSSN
 Parameter 3:@EmployeeFirstName
 Parameter 4:@EmployeeMiddleInitial
 Parameter 5:@EmployeeDateOfBirth
 Parameter 6: @EmployeeGender
 Functionality: the procedure add a new employee
 Assumptions: there may be violations checks for it. there is a new employee to be added 
 ****************************************************************/

CREATE PROCEDURE usp_InsertEmployee 
	@EmployeeLastName NVARCHAR(200),
    @EmployeeFirstName NVARCHAR(200) ,
    @EmployeeMiddleInitial NVARCHAR(10),
    @EmployeeDateOfBirth DATE,
	@EmployeeGender VARCHAR(5) ,
    @EmployeeSSN VARCHAR(50)
AS
BEGIN
	-- SETUP
	SET NOCOUNT ON

		/**********************************************************************************
AUTHOR : NINI 
 Modify Date:12/16/2023
 Ticket Number: 1
change 1: REMOVE -- DECLARATIONS of variables for error checking: Any variables used for loops, calculations deleted
*************************************************************************/


/**********************************************************************************
AUTHOR : NINI 
 Modify Date:12/16/2023
 Ticket Number: 2
CHANGE 2: REMOVE CUSTOM ERROR MESSAGE FOR OUR BUSINESS RULES and added it all to the function
***********************************************************************************/


/**********************************************************************************
AUTHOR : NINI 
 Modify Date:12/16/2023
 Ticket Number: 3
CHANGE 3: DECLARE NEW VARIABLES FOR ERROR MESSAGES from function and to be written in tblerror 
***********************************************************************************/
	  DECLARE @EmployeeNumber VARCHAR(50);  -- Holds calculated EmployeeNumber
	 DECLARE @errorNumber INT = 50500;
    DECLARE @errorMessage NVARCHAR(MAX) = '';





	/**********************************************************************************
AUTHOR : NINI 
 Modify Date:12/16/2023
 Ticket Number: 4
CHANGE 4:  -- DECLARE TABLE FOR ERROR MESSAGES from function and to be written in tblerror
***********************************************************************************/

    DECLARE @BusinessRuleViolations TABLE (
        BRViolationID INT,
        BRViolationErrorNumber INT,
        BRViolationErrorDescription NVARCHAR(1000)
    );



	/**********************************************************************************
AUTHOR : NINI 
 Modify Date:12/16/2023
 Ticket Number: 5
CHANGE 5:  -- INSERT ALL VIOLATIONS INTO TABLE
***********************************************************************************/
    INSERT INTO @BusinessRuleViolations
    SELECT *
    FROM dbo.ufn_EvaluateEmployeeBusinessRules(
        @EmployeeLastName, @EmployeeFirstName, @EmployeeMiddleInitial,
        @EmployeeDateOfBirth, @EmployeeGender, @EmployeeSSN
    );



	/**********************************************************************************
AUTHOR : NINI 
 Modify Date:12/16/2023
 Ticket Number: 6
change6: REMOVE CUSTOME ERROR MESSAGE FOR OUR BUSINESS RULES 
***********************************************************************************/






	/**********************************************************************************
AUTHOR : NINI
 Modify Date:12/16/2023
 Ticket Number: 7
Change 7 :  -- CONCAT BUSSINESS RULES 
***********************************************************************************/





	      -- CONCATENATE BUSINESS RULES INTO A SINGLE ERROR MESSAGE
IF EXISTS (SELECT 1 FROM @BusinessRuleViolations)
BEGIN
    -- Handle business rule violations
    SELECT
        @errorMessage = CONCAT(
            CAST((SELECT COUNT(*) FROM @BusinessRuleViolations) AS NVARCHAR(50)),
            ' Employee Business Rule Violation(s) encountered:', CHAR(13) + CHAR(10)
        );

    SELECT
        @errorMessage = @errorMessage +
            CAST(BRV.BRViolationErrorNumber AS NVARCHAR(50)) +
            CHAR(9) + CHAR(9) +
            ISNULL(BRV.BRViolationErrorDescription, 'NULL') + CHAR(13) + CHAR(10)
    FROM @BusinessRuleViolations BRV;

    -- Log the error
    INSERT INTO tblErrorLog (
        ErrorNumber,
        ErrorSeverity,
        ErrorState,
        ErrorProcedure,
        ErrorMessage,
        LogDateTime
    )
    VALUES (
        @errorNumber,
        ERROR_SEVERITY(),
        ERROR_STATE(),
        ERROR_PROCEDURE(),
        @errorMessage,
        GETDATE()
    );
END


/**********************************************************************************
AUTHOR : NINI 
 Modify Date:12/16/2023
 Ticket Number: 8
change 8: REMOVE CUSTOME ERROR MESSAGE FOR OUR BUSINESS RULES 
***********************************************************************************/
-- let's check for business rule validation.  Any violoations raise exception
-- we passed all business rule checks.  let's add the employee record





/**********************************************************************************
AUTHOR : NINI 
 Modify Date:12/16/2023
 Ticket Number: 9
chnage 9: REPLACES MANUAL CHECK FOR BUSINESS RULE VIOLATIONS 
***********************************************************************************/
-- let's check for business rule validation.  Any violoations raise exception
-- we passed all business rule checks.  let's add the employee record




ELSE 
BEGIN


		-- calculate EmployeeNumber.  Notice the UPPER function used.
		SELECT @EmployeeNumber = UPPER(SUBSTRING(@EmployeeLastName, 1,3))
		SELECT @EmployeeNumber = @EmployeeNumber + '000000'
		
	
	
		INSERT INTO tblEmployee (
        EmployeeLastName,
        EmployeeFirstName,
        EmployeeMiddleInitial,
        EmployeeDateOfBirth,
        EmployeeNumber,
        EmployeeGender,
        EmployeeSSN
    )

	
	
	VALUES (
    @EmployeeLastName,
    @EmployeeFirstName,
    @EmployeeMiddleInitial,
    @EmployeeDateOfBirth,
    @EmployeeNumber,
    @EmployeeGender,
    @EmployeeSSN
);

    -- Log the successful insertion


        -- Return the result set with the EmployeeID
   
    
END;
	
	DECLARE @NewEmployeeID INT;
		SET @NewEmployeeID = SCOPE_IDENTITY();
		SELECT @NewEmployeeID AS EmployeeID;
	
END;








	/****************************************************************
 Author Name:Nini Ola
 Create Date:12/16/2023
 Parameter 1:@EmployeeLastName
 Parameter 2:@EmployeeSSN
 Parameter 3:@EmployeeFirstName
 Parameter 4:@EmployeeMiddleInitial
 Parameter 5:@EmployeeDateOfBirth
 Parameter 6: @EmployeeGender
 Functionality: the procedure updates an new employee hass all the same changes as insertemployerr
 Assumptions: there may be violations checks for it. there is a new employee to be added 
 ****************************************************************/

-- Drop the procedure if it exists
IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'usp_UpdateEmployee')
    DROP PROCEDURE usp_UpdateEmployee;
GO

-- Create the stored procedure
CREATE PROCEDURE usp_UpdateEmployee
    @EmployeeID INT,
    @NewEmployeeLastName NVARCHAR(200),
    @NewEmployeeFirstName NVARCHAR(200),
    @NewEmployeeMiddleInitial NVARCHAR(10),
    @NewEmployeeDateOfBirth DATE,
    @NewEmployeeGender VARCHAR(5),
    @NewEmployeeSSN VARCHAR(50)
AS
BEGIN
    -- SETUP
    SET NOCOUNT ON;

    -- Declare variables
    DECLARE @EmployeeNumber VARCHAR(50);
    DECLARE @errorNumber INT = 50500;
    DECLARE @errorMessage NVARCHAR(MAX) = '';

    -- Declare a table for error messages
    DECLARE @BusinessRuleViolations TABLE (
        BRViolationID INT,
        BRViolationErrorNumber INT,
        BRViolationErrorDescription NVARCHAR(1000)
    );

    -- Insert business rule violations into the table
    INSERT INTO @BusinessRuleViolations
    SELECT *
    FROM dbo.ufn_EvaluateEmployeeBusinessRules(
        @NewEmployeeLastName, @NewEmployeeFirstName, @NewEmployeeMiddleInitial,
        @NewEmployeeDateOfBirth, @NewEmployeeGender, @NewEmployeeSSN
    );

    -- Concatenate business rules into a single error message
    IF EXISTS (SELECT 1 FROM @BusinessRuleViolations)
    BEGIN
        -- Handle business rule violations
        SELECT
            @errorMessage = CONCAT(
                CAST((SELECT COUNT(*) FROM @BusinessRuleViolations) AS NVARCHAR(50)),
                ' Employee Business Rule Violation(s) encountered:', CHAR(13) + CHAR(10)
            );

        SELECT
            @errorMessage = @errorMessage +
                CAST(BRV.BRViolationErrorNumber AS NVARCHAR(50)) +
                CHAR(9) + CHAR(9) +
                ISNULL(BRV.BRViolationErrorDescription, 'NULL') + CHAR(13) + CHAR(10)
        FROM @BusinessRuleViolations BRV;

        -- Log the error
        INSERT INTO tblErrorLog (
            ErrorNumber,
            ErrorSeverity,
            ErrorState,
            ErrorProcedure,
            ErrorMessage,
            LogDateTime
        )
        VALUES (
            @errorNumber,
            ERROR_SEVERITY(),
            ERROR_STATE(),
            ERROR_PROCEDURE(),
            @errorMessage,
            GETDATE()
        );

        -- Return an error message or handle as needed
        -- For simplicity, let's just return an error message
        SELECT 'Business rule violations encountered. Employee not updated.' AS ErrorMessage;
    END
    ELSE
    BEGIN
        -- Calculate EmployeeNumber. Notice the UPPER function used.
        SELECT @EmployeeNumber = UPPER(SUBSTRING(@NewEmployeeLastName, 1, 3))
        SELECT @EmployeeNumber = @EmployeeNumber + '000000';

        -- Update the employee record
        UPDATE tblEmployee
        SET
            EmployeeLastName = @NewEmployeeLastName,
            EmployeeFirstName = @NewEmployeeFirstName,
            EmployeeMiddleInitial = @NewEmployeeMiddleInitial,
            EmployeeDateOfBirth = @NewEmployeeDateOfBirth,
            EmployeeNumber = @EmployeeNumber,
            EmployeeGender = @NewEmployeeGender,
            EmployeeSSN = @NewEmployeeSSN
        WHERE EmployeeID = @EmployeeID;

        -- Log the successful update
        -- Return the result set with the EmployeeID
        SELECT @EmployeeID AS EmployeeID;
    END;
END;
