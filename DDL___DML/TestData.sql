TRUNCATE TABLE tblEmployee
TRUNCATE TABLE tblEmployeeHistory

-- let's get some basic data in
INSERT INTO tblEmployee (
    EmployeeLastName ,
    EmployeeFirstName,
    EmployeeMiddleInitial,
    EmployeeDateOfBirth,
    EmployeeNumber,		-- this is calculated
    EmployeeGender,
    EmployeeSSN 
)
VALUES 
	('Colón','David','L','08/15/1968', 'COL000000', 'M', '123456789')
,	('Colón','Joseph','J','11/1/1969', 'COL000001', 'M', '135789111')
,	('Sanchez','Sandra','M','11/7/1970', 'SAN000001', 'F', '123456789')
,	('Mousa','Renee','A','8/31/1972', 'MOU000001', 'F', '123456789')
,	('Colón','Damian','M','12/26/1980', 'COL000004', 'M', '123456789')

-- let's use a stored procedure to do an insert


exec usp_InsertEmployee
	'Colon','Damian', 'M', '4/10/1948',  'M', '123456789'

exec usp_InsertEmployee
	'Colon','Judith', 'A', '3/06/1951',  'F', '123456789'

-- Show Results.
SELECT * FROM tblEmployee

-- let's try some updates
UPDATE tblEmployee
SET		EmployeeLastName = 'Colón'
WHERE	EmployeeID IN (6,7)

-- let's try some deletes
DELETE FROM tblEmployee
WHERE	EmployeeID = 5

SELECT * FROM tblEmployee
SELECT * FROM tblEmployeeHistory


exec usp_InsertEmployee
	'Colon','kimberly', 'Rf', '8/31/1979',  'G', '123456789'

SELECT * FROM tblErrorLog



  
exec usp_InsertEmployee
	'Colon','kimberly', 'R', '8/31/1909',  'F', '123456789'

SELECT * FROM tblErrorLog

exec usp_InsertEmployee
	'Colon','kimberly', 'RA', '8/31/2024',  'gh', NULL

SELECT * FROM tblErrorLog






