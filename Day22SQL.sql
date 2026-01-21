use Customer_Orders;
-- Customers table
CREATE TABLE dbo.Customers
(
    CustomerId   INT PRIMARY KEY,
    FullName     VARCHAR(100) NOT NULL,
    City         VARCHAR(50)  NOT NULL,
    Segment      VARCHAR(20)  NOT NULL,   -- Retail / Corporate
    IsActive     BIT          NOT NULL,
    CreatedOn    DATE         NOT NULL
);

-- Orders table
CREATE TABLE dbo.Orders
(
    OrderId      INT PRIMARY KEY,
    CustomerId   INT NOT NULL,
    OrderDate    DATE NOT NULL,
    Amount       DECIMAL(10,2) NOT NULL,
    Status       VARCHAR(20) NOT NULL,    -- Delivered/Cancelled/Pending
    PaymentMode  VARCHAR(20) NOT NULL,    -- UPI/Card/Cash
    CONSTRAINT FK_Orders_Customers
        FOREIGN KEY (CustomerId) REFERENCES dbo.Customers(CustomerId)
);

-- Insert Customers
INSERT INTO dbo.Customers (CustomerId, FullName, City, Segment, IsActive, CreatedOn) VALUES
(101, 'Gopi Suresh',   'Coimbatore', 'Retail',    1, '2025-11-12'),
(102, 'Anita Ravi',    'Chennai',    'Corporate', 1, '2025-10-05'),
(103, 'Karthik Mohan', 'Bengaluru',  'Retail',    1, '2025-09-15'),
(104, 'Meena Kumar',   'Chennai',    'Retail',    0, '2024-12-20'),
(105, 'Suresh Babu',   'Hyderabad',  'Corporate', 1, '2025-01-10');

-- Insert Orders
INSERT INTO dbo.Orders (OrderId, CustomerId, OrderDate, Amount, Status, PaymentMode) VALUES
(5001, 101, '2026-01-10', 1200.00, 'Delivered', 'UPI'),
(5002, 101, '2026-01-15',  850.00, 'Pending',   'Card'),
(5003, 102, '2026-01-05', 5000.00, 'Delivered', 'Card'),
(5004, 103, '2025-12-30',  300.00, 'Cancelled', 'Cash'),
(5005, 105, '2026-01-18', 2500.00, 'Delivered', 'UPI'),
(5006, 102, '2026-01-20', 1500.00, 'Pending',   'UPI');

--A) SELECT * (All columns)
SELECT *
FROM dbo.Customers;

--B) SELECT specific columns
SELECT CustomerId, FullName, City
FROM dbo.Customers;

--C) SELECT DISTINCT
SELECT DISTINCT City
FROM dbo.Customers;

--D) Column Alias (AS)
SELECT FullName AS CustomerName, City AS CustomerCity
FROM dbo.Customers;

--E) WHERE (Filter rows)
SELECT *
FROM dbo.Customers
WHERE City = 'Chennai';

--F) WHERE with AND / OR
SELECT *
FROM dbo.Orders
WHERE Status = 'Delivered' AND PaymentMode = 'UPI';

--G) IN (Match a list)
SELECT *
FROM dbo.Customers
WHERE City IN ('Chennai', 'Coimbatore');

--H) BETWEEN (Range)
SELECT *
FROM dbo.Orders
WHERE Amount BETWEEN 800 AND 3000;

--I) LIKE (Pattern search)
SELECT *
FROM dbo.Customers
WHERE FullName LIKE 'S%';

--J) ORDER BY (Sorting)
SELECT *
FROM dbo.Orders
ORDER BY Amount DESC;

--K) TOP (Limit rows)
SELECT TOP 3 *
FROM dbo.Orders
ORDER BY Amount DESC;

