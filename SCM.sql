CREATE DATABASE SCM_DB;
USE SCM_DB;

SELECT * FROM d_product;
SELECT * FROM d_store;
SELECT * FROM f_inventory_adjusted;
SELECT * FROM f_point_of_sales;
SELECT * FROM f_Sales;

# 1.Product Wise Sales 

SELECT 'Product Type', concat("$",'Sales Amount'), 'Sales Quantity'
FROM d_product JOIN f_point_of_sales ON d_product."Product Key" 
=  f_point_of_sales.'Product Key'
GROUP BY d_product.'Product Type';

# 2.State Wise Sales

SELECT d_store.'Store State', concat("$",ROUND(SUM(f_point_of_sales.'Sales.Amount')/1000000,2),"M") AS Sales_Amount  
FROM d_store JOIN f_sales ON d_store.'Store Key' = f_sales.'Store Key"'
 JOIN f_point_of_sales ON f_sales.'Order Number' = f_point_of_sales.'Order Number'
GROUP BY d_store.'Store State' ORDER BY SUM(f_point_of_sales.'Sales Amount')
 DESC;

# 3. Region Wise Sales
SELECT d_store.'Store Region', concat("$",ROUND(SUM(f_point_of_sales.'Sales Amount')/1000000,2),"M") AS Sales_Amount
FROM d_store JOIN f_sales ON d_store.'Store Key' = f_sales.'Store Key'
 JOIN f_point_of_sales ON f_sales.'Order Number' = f_point_of_sales.'Order Number'
GROUP BY d_store.'Store Region' ORDER BY SUM(f_point_of_sales.'Sales Amount')
 DESC;

#4. Top 5 Store Wise Sales
SELECT d_store.'Store Name', 
concat("$",ROUND(SUM(f_point_of_sales.'Sales.Amount')/1000000,2),"M") AS Sales_Amount
FROM d_store JOIN f_sales ON d_store.'Store Key' = f_sales.'Store Key' 
 JOIN f_point_of_sales ON f_sales.'Order Number' = f_point_of_sales.'Order Number' 
GROUP BY d_store.'Store Name' ORDER BY SUM(f_point_of_sales.'Sales Amount')
 DESC LIMIT 5;

#5. Total Inventory 
SELECT * FROM f_inventory_adjusted;
SELECT CONCAT("$",ROUND(SUM("Cost Amount" * "Quantity on Hand")/1000000,2),"M") AS Total_Inventory  
FROM f_inventory_adjusted;

#6. Inventory Value
SELECT 'Product Type', CONCAT("$",ROUND(SUM('Cost Amount' * 'Quantity on Hand')/1000000,2),"M") AS Total_Inventory_Value
FROM f_inventory_adjusted
GROUP BY 'Product Type';

SELECT "Product Family", CONCAT("$",ROUND(SUM("Cost Amount" * "Quantity on Hand")/1000000,2),"M") AS Total_Inventory_Value 
FROM f_inventory_adjusted
GROUP BY "Product Family";


#7. Year Wise Sales Growth
SELECT Year(Date) AS Year,
 Concat("$",ROUND(SUM('Sales Amount')/1000000),2),"M") AS Sales_Amount, 
Concat("$",ROUND((Lag(SUM('Sales Amount'),1) OVER (Order by Year(Date))/1000000),2),"M") AS 
Previous_Year_Sales_Amount,
Concat(ROUND((SUM('Sales Amount') – Lag(SUM('Sales Amount'),1) OVER (Order by Year(Date)))
/Lag(SUM('Sales Amount'),1) OVER (Order by Year(Date))*100,2),”%”) AS Sales_Growth
FROM f_sales JOIN f_point_of_sales ON f_sales.'Order Number' =  f_point_of_sales.'Order Number' 
Group BY YEAR(Date) ORDER BY YEAR(Date);

#8. Total Sales (MTD,QTD,YTD)
WITH s AS 
(SELECT Date, SUM('Sales Amount') AS Sales_Amount
FROM f_sales JOIN f_point_of_sales ON f_sales.'Order Number' = f_point_of_sales.'Order Number'
GROUP BY Date ORDER BY Date)
SELECT 
Date, 'Sales_Amount',
Concat("$",ROUND(SUM(Sales_Amount) OVER(PARTITION OF MONTH(Date), Year(Date) 
ORDER BY Date)/1000000,2),"M") AS MTD,
Concat("$",ROUND(SUM(“Sales_Amount”) OVER(PARTITION OF QUARTER(Date), YEAR(Date)
ORDER BY Date)/1000000,2),"M") AS QTD,
CONCAT("$",ROUND(SUM(“Sales_Amount”) OVER(PARTITION OF YEAR(Date), YEAR(Date)
ORDER BY Date)/1000000,2),"M") AS YTD
FROM s;

#9. Daily Sales Trend
SELECT DAY(Date),
CONCAT("$",ROUND((SUM('Cost Amount')/1000000),2),"M") AS Cost_Amount,
CONCAT("$",ROUND((SUM('Sales Amount')/1000000),2),"M") AS Sales_Amount,
CONCAT("$",ROUND(((SUM('Sales Amount')-('Cost Amount'))/1000000),2),"M") AS Profit_Amount
 
GROUP BY DAY(Date) ORDER BY DAY(Date);

# Weekday wise Sales Trend
SELECT WEEKDAY(Date),
CONCAT("$",ROUND((SUM(‘Cost Amount’)/1000000),2),"M") AS Cost_Amount,
CONCAT("$",ROUND((SUM(‘Sales Amount’)/1000000),2),"M") AS Sales_Amount,
CONCAT("$",ROUND(((SUM(‘Sales Amount’)-SUM(‘Cost Amount’))/1000000),2),"M") AS Profit_Amount
FROM f_sales JOIN f_point_of_sale ON 
f_sales.'Order Number' = f_point_of_sale.'Order Number'
 GROUP BY WEEKDAY(Date) ORDER BY WEEKDAY(Date);




# 10. Stock Status

SELECT i.‘Product Type’, i.’ProductFamily’, i.‘Product Group’ AS Company, i.‘Quantity on Hand’,
 ROUND(AVG(f_s.’Sales Quantity’)) as "Quantity Required",
CASE
WHEN ‘Quantity on Hand’ > ‘Quantity Required’ THEN ‘Over Stick’,
WHEN ‘Quantity on Hand’ = ‘Quantity Required’ THEN ‘In Stock’,
ELSE ‘Under Stock’
END AS ‘Stock Status’
FROM f_inventory_adjusted AS i LEFT JOIN f_point_of_sales AS f_s
ON i.’Product Key’ = f_s.’Product Key’ 
GROUP BY ‘Stock Status’;

