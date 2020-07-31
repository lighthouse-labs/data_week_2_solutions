-- Q1. Write a query to get Product name and quantity/unit.
SELECT ProductName, QuantityPerUnit 
FROM Products;

-- Q2. Write a query to get most expense and least expensive Product list (name and unit price)
SELECT ProductName, UnitPrice 
FROM Products 
ORDER BY UnitPrice DESC 
LIMIT 1;

SELECT ProductName, UnitPrice 
FROM Products 
ORDER BY UnitPrice ASC 
LIMIT 1;


-- Q3. Write a query to count current and discontinued products.
SELECT Discontinued, Count(ProductName)
FROM Products
GROUP BY Discontinued;

-- Q4. Select all product names and their category names (77 rows)
SELECT productname, categoryname 
From products 
inner join categories 
  on products.categoryID=categories.categoryID;

-- Q5. Select all product names, unit price and the supplier region that don't have suppliers from USA region. (26 rows)
SELECT productname, unitprice, suppliers.region
From products 
inner join suppliers 
  on products.supplierID=suppliers.supplierID 
 where suppliers.region <>'USA'

-- Q6. Get the total quantity of orders sold.( 51317)
select sum(quantity) from order_details

-- Q7. Get the total quantity of orders sold for each order.(830 rows)
select sum(quantity), orderID from order_details group by orderID

-- Q8. Get the number of employees who have been working more than 5 year in the company. (9 rows)
select count(*) 
from (
  select firstname, lastname, current_date, hiredate from employees where (current_date - hiredate) > 5
) as subquery;


