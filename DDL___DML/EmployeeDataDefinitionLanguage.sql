/**********************************************************************************
    Author Name:	David L. Colón
    Create Date:	12/1/2023
	Parameters:		NONE
	Functionality:  Create database & tables for our Human Resources development.
	Assumptions:	1) EmployeeID -> Internal SQL, EmployeeNum -> user facing
					2) ModifiedBy and ModifiedDate are NULL until record change
					3) Additional Business Rules (Per Subject Matter Expert)
					•	Employee DOB must be a reasonable range
					•	All Required fields are accounted for and present.
					•	Middle Initial can only be 1 character unless none provided, 
						which is empty string.
					•	Employee Gender possible values are M (i.e. Male, Female)
					•	Employee Number starts with first letter of Employee 
						Last Name followed by 6 digits
					•	Only LOGICAL deletes are allowed.
					•	We must track ALL employee record changes over time.  

***********************************************************************************/

--SETUP
SET NOCOUNT ON				-- sometimes messages interfere with applications calls

/**********************************************************************************

                             CREATE HumanResources Database

***********************************************************************************/
IF NOT EXISTS (SELECT * FROM sys.databases WHERE [Name] = 'HumanResources')
BEGIN
	CREATE DATABASE HumanResources;			-- we can't delete this DB is in use	
END
go

USE [HumanResources];
go

/**********************************************************************************

                             CREATE Employee Tables

***********************************************************************************/
DROP TABLE IF EXISTS tblEmployee

CREATE TABLE tblEmployee (
    EmployeeID INT IDENTITY PRIMARY KEY,
    EmployeeLastName NVARCHAR(200) NOT NULL,
    EmployeeFirstName NVARCHAR(200) NOT NULL,
    EmployeeMiddleInitial NVARCHAR(10),
    EmployeeDateOfBirth DATE,
    EmployeeNumber VARCHAR(50) NOT NULL,		-- this is calculated
    EmployeeGender VARCHAR(5) NOT NULL,
    EmployeeSSN VARCHAR(50) NOT NULL,
    EmployeeActiveFlag INT DEFAULT 1,			-- doing logical deletes; Default 1
    CreateDate DATETIME DEFAULT GetDate(),		-- Default is Current Date Time
    CreatedBy NVARCHAR(50) DEFAULT SUSER_NAME(),-- default CURRENT LOGGED IN USER
    ModifyDate DATETIME ,						-- NULL until record modified.
    ModifiedBy NVARCHAR(50)						-- NULL until record modified.
);


/**********************************************************************************

                             CREATE Employee History

***********************************************************************************/
DROP TABLE IF EXISTS tblEmployeeHistory

CREATE TABLE tblEmployeeHistory (
    EmployeeHistoryID INT IDENTITY,			-- PK
    EmployeeID INT,							-- PK
    EmployeeLastName NVARCHAR(50),			-- NEVER MODIFIED
    EmployeeFirstName NVARCHAR(50),			-- NEVER MODIFIED
    EmployeeMiddleInitial CHAR(10),			-- NEVER MODIFIED
    EmployeeDateOfBirth DATE,				-- NEVER MODIFIED
    EmployeeNumber VARCHAR(20),				-- NEVER MODIFIED
    EmployeeGender VARCHAR(10),				-- NEVER MODIFIED
    EmployeeSSN VARCHAR(50),				-- NEVER MODIFIED
    EmployeeActiveFlag BIT,					-- NEVER MODIFIED
    CreateDate DATETIME,					-- NEVER MODIFIED
    CreatedBy NVARCHAR(50),					-- NEVER MODIFIED
    ModifyDate DATETIME,					-- NEVER MODIFIED
    ModifiedBy NVARCHAR(50)					-- NEVER MODIFIED
);

/**********************************************************************************

                             CREATE Error Log Tables

***********************************************************************************/
DROP TABLE IF EXISTS tblErrorLog

CREATE TABLE [dbo].[tblErrorLog](
	[LogID] [int] IDENTITY(1,1) NOT NULL,
	[ErrorUser] nvarchar(100) default SUSER_NAME(),
	[ErrorNumber] int NULL,
	[ErrorSeverity] int NULL,
	[ErrorState] int NULL,
	[ErrorProcedure] nvarchar(4000) NULL,
	[ErrorLine] Int NULL,
	[ErrorMessage] nvarchar(max) NULL,
	[LogDateTime] datetime NULL,
)

