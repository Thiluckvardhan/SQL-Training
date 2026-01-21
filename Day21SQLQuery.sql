use MyDataBase;
 
INSERT INTO Sales_stores (store_id, store_name, phone, email, street, city, state, zip_code)
VALUES
(1, 'Hyderabad Store', '9876543210', 'hydstore@gmail.com', 'Ameerpet Road', 'Hyderabad', 'TS', '500016'),
(2, 'Patna Store', '9123456780', 'patnastore@gmail.com', 'Boring Road', 'Patna', 'BR', '800001');

INSERT INTO Sales_staff (staff_id, first_name, last_name, email, phone, active, store_id, manager_id)
VALUES
(1, 'Ravi', 'Kumar', 'ravi@gmail.com', '9000000001', 1, 1, NULL),
(2, 'Sita', 'Sharma', 'sita@gmail.com', '9000000002', 1, 1, 1),
(3, 'Amit', 'Verma', 'amit@gmail.com', '9000000003', 1, 2, NULL),
(4, 'Neha', 'Singh', 'neha@gmail.com', '9000000004', 1, 2, 3);

INSERT INTO Sales_Customer (Customer_Id, first_name, last_name, phone, email, street, city, state, zip_code)
VALUES
(101, 'Thiluck', 'Vardhan', '9999999991', 'thiluck@gmail.com', 'KPHB', 'Hyderabad', 'TS', '500072'),
(102, 'Divyansh', 'Raj', '9999999992', 'divyansh@gmail.com', 'Boring Road', 'Patna', 'BR', '800001'),
(103, 'Rahul', 'Mehta', '9999999993', 'rahul@gmail.com', 'Gachibowli', 'Hyderabad', 'TS', '500032');

INSERT INTO Sales_orders (Order_id, customer_id, order_status, order_date, required_date, shipped_date, store_id, staff_id)
VALUES
(5001, 101, 1, '2026-01-10', '2026-01-15', '2026-01-12', 1, 2),
(5002, 102, 2, '2026-01-11', '2026-01-16', '2026-01-13', 2, 4),
(5003, 103, 1, '2026-01-12', '2026-01-17', NULL,         1, 1);

INSERT INTO Sales_orderItems (order_id, item_id, product_id, quantity, list_price, discount)
VALUES
(5001, 1, 201, 2, 50000, 0.10),
(5001, 2, 202, 1, 15000, 0.05),
(5002, 1, 203, 3, 1000,  0.00),
(5002, 2, 204, 2, 2500,  0.10),
(5003, 1, 205, 1, 20000, 0.15);


select * from Sales_stores;
select * from Sales_staff;
select * from Sales_Customer;
select * from Sales_orderItems;
select * from Sales_orders;

SELECT 
    o.Order_id,
    c.first_name + ' ' + c.last_name AS customer_name,
    s.store_name,
    st.first_name + ' ' + st.last_name AS staff_name,
    oi.item_id,
    oi.product_id,
    oi.quantity,
    oi.list_price,
    oi.discount
FROM Sales_orders o
JOIN Sales_Customer c ON o.customer_id = c.Customer_Id
JOIN Sales_stores s ON o.store_id = s.store_id
JOIN Sales_staff st ON o.staff_id = st.staff_id
JOIN Sales_orderItems oi ON o.Order_id = oi.order_id
ORDER BY o.Order_id, oi.item_id;

select c.first_name,c.last_name,sum(oi.quantity) as total_items_purchased 
from Sales_Customer c
Join Sales_orders o
on c.Customer_Id =o.customer_id
join Sales_orderItems oi
on o.Order_id=oi.order_id
group by
c.first_name,c.last_name;