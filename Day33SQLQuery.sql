SELECT * INTO perf_issue FROM Person.person;

SELECT ROW_NUMBER() OVER (ORDER BY BusinessEntityID) AS RowNumber, * FROM perf_issue;

-----------------------------------------------

SELECT
	so.name,
	ps.*
FROM
	sys.dm_db_partition_stats ps
INNER JOIN
	sysobjects so 
ON
	ps.object_id = so.id
WHERE
	so.xtype = 'U'

------------------------------------------------

SELECT
	so.name,
	ps.used_page_count
FROM
	sys.dm_db_partition_stats ps
INNER JOIN
	sysobjects so 
ON
	ps.object_id = so.id
WHERE
	so.xtype = 'U'
ORDER BY ps.used_page_count DESC

--------------------------------------------------------

USE AdventureWorks2025;
GO

DROP TABLE IF EXISTS dbo.SOH_Practice;
SELECT TOP (300000)
  SalesOrderID, CustomerID, OrderDate, SubTotal, TaxAmt, Freight, TotalDue
INTO dbo.SOH_Practice
FROM Sales.SalesOrderHeader
ORDER BY SalesOrderID;

-- Create a clustered index on SalesOrderID (common pattern)
-- This leaves our search columns (CustomerID, OrderDate) without a supporting index.
CREATE CLUSTERED INDEX CX_SOH_Practice_SalesOrderID
ON dbo.SOH_Practice(SalesOrderID);

DROP INDEX IF EXISTS CX_SOH_Practice_SalesOrderID ON dbo.SOH_Practice;

set statistics io on;
set statistics time on;
select SalesOrderID from dbo.SOH_Practice where SalesOrderID=44025;


---------------------------------------------------------------------------------------------
-- 04-02-2026----

SELECT name
FROM sys.databases
WHERE name LIKE 'AdventureWorks%';

SET STATISTICS IO ON; --(logical reads)
SET STATISTICS TIME ON; --(CPU/time)

---------------------------------------------------------------------------------------------

--Create Clustered Index (sample)
USE AdventureWorks2025;
GO

DROP TABLE IF EXISTS dbo.Product_Practice;
SELECT TOP (5000)
  ProductID, Name, ProductNumber, Color, ListPrice, ModifiedDate
INTO dbo.Product_Practice
FROM Production.Product
ORDER BY ProductID;

-- Create Clustered Index
CREATE CLUSTERED INDEX CX_Product_Practice_ProductID
ON dbo.Product_Practice(ProductID);

-- Verify indexes
SELECT i.index_id, i.name, i.type_desc
FROM sys.indexes i
WHERE i.object_id = OBJECT_ID('dbo.Product_Practice');

--------------------------------------------------------------------------------------------------------
--Create Nonclustered Index (single key)

USE AdventureWorks2025;
GO

CREATE NONCLUSTERED INDEX IX_Product_Practice_ProductNumber
ON dbo.Product_Practice(ProductNumber);

SELECT i.index_id, i.name, i.type_desc
FROM sys.indexes i
WHERE i.object_id = OBJECT_ID('dbo.Product_Practice');

---------------------------------------------------------------------------------------------------------

 --Single key vs Composite (multiple keys)

 Index on (Color, ListPrice)

Good:
WHERE Color='Black'
WHERE Color='Black' AND ListPrice>=1000

Not great:
WHERE ListPrice>=1000  -- Color missing


----------------------------------------------------------------------------------------------------

--Create composite index: (Color, ListPrice)

USE AdventureWorks2025;
GO

CREATE NONCLUSTERED INDEX IX_Product_Practice_Color_ListPrice
ON dbo.Product_Practice(Color, ListPrice);

SELECT ProductID, Name, Color, ListPrice
FROM dbo.Product_Practice
WHERE Color = 'Black' AND ListPrice >= 1000
ORDER BY ListPrice DESC;

-----------------------------------------------------------------------------------------------------

--INCLUDE (covering index)

USE AdventureWorks2025;
GO

DROP INDEX IF EXISTS IX_Product_Practice_ProductNumber ON dbo.Product_Practice;

CREATE NONCLUSTERED INDEX IX_Product_Practice_ProductNumber_Cover
ON dbo.Product_Practice(ProductNumber)
INCLUDE (Name, ListPrice);

-----------------------------------------------------------------------------------------------------

--How to see Index “Values” (real index entries)

USE AdventureWorks2025;
GO

-- If you created: IX_Product_Practice_ProductNumber_Cover
-- key = ProductNumber, include = Name, ListPrice

-- This shows the "index values" (key values in sorted order)
SELECT TOP 50
  ProductNumber,   -- index key column
  Name,            -- included column (stored at leaf)
  ListPrice        -- included column
FROM dbo.Product_Practice
ORDER BY ProductNumber;  -- aligns with index key order

------------------------------------------------------------------------------------------------------

--Demo 1 — Heap scan → Nonclustered seek

USE AdventureWorks2025;
GO

-- Create HEAP table
DROP TABLE IF EXISTS dbo.Person_Practice;
SELECT TOP (20000)
  BusinessEntityID, FirstName, LastName, ModifiedDate
INTO dbo.Person_Practice
FROM Person.Person
ORDER BY BusinessEntityID;

-- Without index
SET STATISTICS IO ON;
SET STATISTICS TIME ON;

SELECT TOP 200 BusinessEntityID, FirstName, LastName
FROM dbo.Person_Practice
WHERE LastName = 'Smith'
ORDER BY FirstName;

-- With index
CREATE NONCLUSTERED INDEX IX_Person_Practice_LastName
ON dbo.Person_Practice(LastName);

SELECT TOP 200 BusinessEntityID, FirstName, LastName
FROM dbo.Person_Practice
WHERE LastName = 'Smith'
ORDER BY FirstName;

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;

-----------------------------------------------------------------------------------
--Demo 2 — Composite + INCLUDE

USE AdventureWorks2019;
GO

DROP TABLE IF EXISTS dbo.SalesOrderHeader_Practice;
SELECT TOP (200000)
  SalesOrderID, CustomerID, OrderDate, TotalDue
INTO dbo.SalesOrderHeader_Practice
FROM Sales.SalesOrderHeader
ORDER BY SalesOrderID;

SET STATISTICS IO ON;
SET STATISTICS TIME ON;

-- Before index
SELECT TOP 200 SalesOrderID, CustomerID, OrderDate, TotalDue
FROM dbo.SalesOrderHeader_Practice
WHERE CustomerID = 11000
  AND OrderDate >= '2013-01-01' AND OrderDate < '2014-01-01'
ORDER BY OrderDate;

-- Create composite + covering index
CREATE NONCLUSTERED INDEX IX_SOH_Practice_Customer_OrderDate_Cover
ON dbo.SalesOrderHeader_Practice(CustomerID, OrderDate)
INCLUDE (TotalDue);

-- After index
SELECT TOP 200 SalesOrderID, CustomerID, OrderDate, TotalDue
FROM dbo.SalesOrderHeader_Practice
WHERE CustomerID = 11000
  AND OrderDate >= '2013-01-01' AND OrderDate < '2014-01-01'
ORDER BY OrderDate;

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;

