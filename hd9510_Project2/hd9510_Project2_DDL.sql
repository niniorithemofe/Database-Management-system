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

  /****************************************************************
   create ans use humanresource database 
    ****************************************************************/


CREATE DATABASE HumanResources;
GO
USE HumanResources;



  /****************************************************************
    Author Name: Nini Ola 
    Create Date: [11/29/2023]
  
    Functionality: Create a new employee record, ensuring business rules are not violated. Log errors in tblLogErrors. Return EmployeeID.

    ****************************************************************/

CREATE TABLE tblEmployee (
    EmployeeID INT IDENTITY PRIMARY KEY,
    EmployeeLastName VARCHAR(200) NOT NULL,
    EmployeeFirstName VARCHAR(200) NOT NULL,
    EmployeeMiddleInitial CHAR(10),
    EmployeeDateOfBirth DATE,
    EmployeeNumber VARCHAR(50) NOT NULL,
    EmployeeGender CHAR(50),
    EmployeeSSN VARCHAR(50) NOT NULL,
    EmployeeActiveFlag BIT DEFAULT 1,
    CreateDate DATETIME DEFAULT GETDATE(),
    CreatedBy NVARCHAR(50),
    ModifyDate DATETIME DEFAULT GETDATE(),
    ModifiedBy NVARCHAR(50)
);

  /****************************************************************
    Author Name: Nini Ola 
    Create Date: [11/29/2023]
  
    Functionality: Create a new employee record, ensuring business rules are not violated. Log errors in tblLogErrors. Return EmployeeID.

    ****************************************************************/


	CREATE TABLE tblEmployeeHistory (
    EmployeeHistoryID INT IDENTITY PRIMARY KEY,
    EmployeeID INT,
    EmployeeLastName VARCHAR(50),
    EmployeeFirstName VARCHAR(50),
    EmployeeMiddleInitial CHAR(10),
    EmployeeDateOfBirth DATE,
    EmployeeNumber VARCHAR(20),
    EmployeeGender CHAR(10),
    EmployeeSSN VARCHAR(50),
    EmployeeActiveFlag BIT,
    CreateDate DATETIME,
    CreatedBy NVARCHAR(50),
    ModifyDate DATETIME,
    ModifiedBy NVARCHAR(50)
);




  /****************************************************************
    Author Name: Nini Ola 
    Create Date: [11/29/2023]
  
    Functionality: Create a new employee record, ensuring business rules are not violated. Log errors in tblLogErrors. Return EmployeeID.

    ****************************************************************/


	

/****** Object:  Table [dbo].[tblErrorLog]    Script Date: 11/29/2023 4:59:55 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[tblErrorLog](
	[LogID] [int] IDENTITY(1,1) NOT NULL,
	[ErrorNumber] [int] NULL,
	[ErrorSeverity] [int] NULL,
	[ErrorState] [int] NULL,
	[ErrorProcedure] [nvarchar](128) NULL,
	[ErrorLine] [int] NULL,
	[ErrorMessage] [nvarchar](max) NULL,
	[LogDateTime] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[LogID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

ALTER TABLE [dbo].[tblErrorLog] ADD  DEFAULT (getdate()) FOR [LogDateTime]
GO

