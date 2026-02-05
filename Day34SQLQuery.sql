
--*******************************************************************************************************************
--*******************************************************************************************************************
----------------------------------------------CURSOR-------------------------------------------------------------
--*******************************************************************************************************************
--*******************************************************************************************************************

--1) Setup: Create Tables + Insert Records

--Step 1: Create Products table
IF OBJECT_ID('dbo.Products', 'U') IS NOT NULL
    DROP TABLE dbo.Products;
GO

CREATE TABLE dbo.Products
(
    ProductId     INT IDENTITY(1,1) PRIMARY KEY,
    ProductName   VARCHAR(100) NOT NULL,
    Category      VARCHAR(50)  NOT NULL,
    Price         DECIMAL(10,2) NOT NULL CHECK (Price > 0),
    StockQty      INT NOT NULL CHECK (StockQty >= 0),
    IsActive      BIT NOT NULL DEFAULT 1,
    CreatedAt     DATETIME2 NOT NULL DEFAULT SYSDATETIME()
);
GO
-----------------------------------------------------------------------------------------------------
--Step 2: Insert sample product records
INSERT INTO dbo.Products (ProductName, Category, Price, StockQty)
VALUES
('Wireless Mouse', 'Electronics', 799.00, 50),
('Mechanical Keyboard', 'Electronics', 2499.00, 25),
('Running Shoes', 'Fashion', 1899.00, 40),
('Water Bottle', 'Fitness', 399.00, 120),
('Laptop Backpack', 'Accessories', 1499.00, 35),
('USB-C Cable', 'Electronics', 299.00, 15),
('Gym Gloves', 'Fitness', 499.00, 28);
GO

SELECT * FROM dbo.Products ORDER BY ProductId;
GO
---------------------------------------------------------------------------------------------------
--Step 3: Create a ReorderLog table (for cursor practice)
IF OBJECT_ID('dbo.ReorderLog', 'U') IS NOT NULL
    DROP TABLE dbo.ReorderLog;
GO

CREATE TABLE dbo.ReorderLog
(
    LogId      INT IDENTITY(1,1) PRIMARY KEY,
    ProductId  INT NOT NULL,
    Message    VARCHAR(200) NOT NULL,
    CreatedAt  DATETIME2 NOT NULL DEFAULT SYSDATETIME()
);
GO
----------------------------------------------------------------------------------------------------
--2) Cursors
--2.1 Cursor (Beginner): Print each row
--Cursor Steps: DECLARE → OPEN → FETCH → LOOP → CLOSE → DEALLOCATE

DECLARE @ProductId INT;
DECLARE @ProductName VARCHAR(100);
DECLARE @Price DECIMAL(10,2);

-- 1) Declare cursor
DECLARE curProducts CURSOR FAST_FORWARD
FOR
    SELECT ProductId, ProductName, Price
    FROM dbo.Products
    ORDER BY ProductId;

-- 2) Open cursor
OPEN curProducts;

-- 3) Fetch first row
FETCH NEXT FROM curProducts INTO @ProductId, @ProductName, @Price;

-- 4) Loop until no more rows
WHILE @@FETCH_STATUS = 0
BEGIN
    PRINT 'ProductId=' + CAST(@ProductId AS VARCHAR(10))
        + ' | Name=' + @ProductName
        + ' | Price=' + CAST(@Price AS VARCHAR(20));

    -- fetch next row
    FETCH NEXT FROM curProducts INTO @ProductId, @ProductName, @Price;
END

-- 5) Close + Deallocate
CLOSE curProducts;
DEALLOCATE curProducts;
---------------------------------------------------------------------------------------------------
--2.2 Cursor (Intermediate): Insert log rows
--Goal: For low-stock products, insert messages into dbo.ReorderLog.

--created a stored procedure
CREATE PROCEDURE dbo.usp_LogLowStockReorders
AS
BEGIN
	TRUNCATE TABLE dbo.ReorderLog;

DECLARE @ProductId INT;
DECLARE @ProductName VARCHAR(100);
DECLARE @StockQty INT;

DECLARE curLowStock CURSOR FAST_FORWARD
FOR
    SELECT ProductId, ProductName, StockQty
    FROM dbo.Products
    WHERE StockQty < 30
    ORDER BY StockQty ASC;

OPEN curLowStock;
FETCH NEXT FROM curLowStock INTO @ProductId, @ProductName, @StockQty;

WHILE @@FETCH_STATUS = 0
BEGIN
    INSERT INTO dbo.ReorderLog(ProductId, Message)
    VALUES
    (
        @ProductId,
        'Reorder needed for ' + @ProductName + ' (Stock=' + CAST(@StockQty AS VARCHAR(10)) + ')'
    );

    FETCH NEXT FROM curLowStock INTO @ProductId, @ProductName, @StockQty;
END

CLOSE curLowStock;
DEALLOCATE curLowStock;
END;
GO

EXEC dbo.usp_LogLowStockReorders; -- just run this the stored procedure will execute
-----------------------------------------------------------------------------------------------------------
--2.3 Cursor (Advanced): Transaction + TRY...CATCH
--Scenario: Increase price by 5% for Fashion products, log each change, and rollback on error.

CREATE OR ALTER PROCEDURE dbo.usp_UpdateFashionPrices --created a stored procedure
AS
BEGIN
    SET NOCOUNT ON;

    -- Drop & recreate log table (as per given script)
    IF OBJECT_ID('dbo.PriceChangeLog', 'U') IS NOT NULL
        DROP TABLE dbo.PriceChangeLog;

    CREATE TABLE dbo.PriceChangeLog
    (
        LogId       INT IDENTITY(1,1) PRIMARY KEY,
        ProductId   INT NOT NULL,
        OldPrice    DECIMAL(10,2) NOT NULL,
        NewPrice    DECIMAL(10,2) NOT NULL,
        ChangedAt   DATETIME2 NOT NULL DEFAULT SYSDATETIME()
    );

    DECLARE @ProductId INT;
    DECLARE @OldPrice DECIMAL(10,2);
    DECLARE @NewPrice DECIMAL(10,2);

    DECLARE curFashion CURSOR FAST_FORWARD
    FOR
        SELECT ProductId, Price
        FROM dbo.Products
        WHERE Category = 'Fashion';

    BEGIN TRY
        BEGIN TRAN;

        OPEN curFashion;
        FETCH NEXT FROM curFashion INTO @ProductId, @OldPrice;

        WHILE @@FETCH_STATUS = 0
        BEGIN
            SET @NewPrice = ROUND(@OldPrice * 1.05, 2);

            UPDATE dbo.Products
            SET Price = @NewPrice
            WHERE ProductId = @ProductId;

            INSERT INTO dbo.PriceChangeLog (ProductId, OldPrice, NewPrice)
            VALUES (@ProductId, @OldPrice, @NewPrice);

            FETCH NEXT FROM curFashion INTO @ProductId, @OldPrice;
        END

        CLOSE curFashion;
        DEALLOCATE curFashion;

        COMMIT TRAN;
    END TRY
    BEGIN CATCH
        IF CURSOR_STATUS('global', 'curFashion') >= -1
        BEGIN
            CLOSE curFashion;
            DEALLOCATE curFashion;
        END

        IF @@TRANCOUNT > 0
            ROLLBACK TRAN;

        THROW;
    END CATCH;

    -- Output results
    SELECT * FROM dbo.Products WHERE Category = 'Fashion';
    SELECT * FROM dbo.PriceChangeLog ORDER BY LogId;
END;
GO


EXEC dbo.usp_UpdateFashionPrices; -- just run this the stored procedure will execute

--------------------------------------------------------------------------------------------------------------
--*******************************************************************************************************************
--*******************************************************************************************************************
----------------------------------------------TRIGGERS-------------------------------------------------------------
--*******************************************************************************************************************
--*******************************************************************************************************************


-- =============================================
-- Author: Thiluck
-- Create date: 05-02-2926
-- Description:	sample
-- =============================================
DROP TRIGGER IF EXISTS sales.Inserting_Trigger_Customer;
GO


CREATE or ALTER TRIGGER sales.Inserting_Trigger_Customer
ON sales.customers
AFTER INSERT
AS
BEGIN
    set nocount on;
    declare @name varchar(max)
    set @name=(select last_name from inserted)
    insert into LogTable(Id,Logtext)
    values(
    NEWID(),@name + ' is inserted'+ convert(varchar(30),getdate(),120)
    )
    --SET NOCOUNT ON;

    --INSERT INTO LogTable (Id, Logtext)
    --SELECT
      --  NEWID(),
        --first_name + ' added on date ' +
        --CONVERT(VARCHAR(30), GETDATE(), 120)
    --FROM inserted;
END;
GO



----------------------------------------------------------------------------------------------------------------------


INSERT INTO sales.customers
(first_name, last_name, phone, email, street, city, state, zip_code)
VALUES
('Vemula', 'Thiluck Vardhan', '8885619995', 'thiluck@gmail.com',
 'MG Road', 'Hyderabad', 'Telangana', '5000');

select * from LogTable;