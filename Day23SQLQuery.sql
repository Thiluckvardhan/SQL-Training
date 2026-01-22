-- =============================================
-- Author:		Thiluck
-- Create date: 22-01-2026
-- Description:	Customer Order
-- =============================================
use [Customer_Orders];

alter procedure MyPractice -- once use create then always use alter
--optional or parameters
@city varchar(50) -- asking for input of varchar type
as
Begin

Select * from [dbo].[Customers] where City=@city --selecting all the records with given city name.
End

go
Exec MyPractice 'Coimbatore' -- giving Coimbatore as input

--===========================================================================================================================================

alter PROCEDURE [dbo].[Sp_GetCustomerByNameAndCity]
	-- Add the parameters for the stored procedure here
	@Name varchar(100),
	@City varchar(50)
AS
BEGIN
	Select * from Customers where FullName=@Name And City=@City
END
GO
Exec Sp_GetCustomerByNameAndCity 'Gopi Suresh','Coimbatore'

--===========================================================================================================================================

--Stored Procedures for CRUD Operations
alter PROCEDURE [dbo].[Sp_CrudOperations]
AS
BEGIN
    -- READ
    SELECT *
    FROM tbl_Department;

    -- INSERT
    INSERT INTO tbl_Department (ID, Name)
    VALUES 
        (6, 'Dept6'),
        (7, 'Dept7');

    -- UPDATE
    UPDATE tbl_Department
    SET 
        ID = 55,
        Name = 'Heavy Department'
    WHERE ID = 5;

    -- DELETE
    DELETE FROM tbl_Department
    WHERE ID = 1;
END;
GO

EXEC Sp_CrudOperations;


