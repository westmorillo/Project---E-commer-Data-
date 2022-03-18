
--------------------------------------------------------------------------
--ECOMMERCE SQL DATA PROJECT
---------------------------------------------------------------------------

-- EXPLORE THE DATABASE

SELECT *
FROM dbo.data
ORDER BY 2,4


----------------------------------------------------------------------------------------
-- 1. Calculate total sales by country
----------------------------------------------------------------------------------------

WITH Total_sales_bycountry AS
(
SELECT SUM(Quantity*UnitPrice) AS Total_sales_Country, Country
FROM dbo.data
WHERE Quantity*UnitPrice>0
GROUP BY Country
),
Total_sales AS
(
SELECT SUM(Total_sales_Country) AS Total
FROM Total_sales_bycountry

)
SELECT	tst.Country,tst.Total_sales_Country, ts.Total AS Global_total,
		(tst.Total_sales_Country/ts.Total)*100 AS RATESALES
FROM Total_sales_bycountry tst
JOIN Total_sales ts
ON ts.Total>tst.Total_sales_Country
ORDER BY 4 DESC

----------------------------------------------------------------------------------------
--2. Calculate the number of orders and sales per month and country.
----------------------------------------------------------------------------------------

SELECT	DATEPART(MONTH,InvoiceDate) AS Month_number,COUNT(InvoiceNo) AS Count_Sales,
		SUM(Quantity*Unitprice) AS Total_Sales,
		DateName( month , DateAdd( month , DATEPART(MONTH,InvoiceDate) , 0 ) - 1 ) AS Month,
		Country
FROM dbo.data
WHERE Quantity>0 AND UnitPrice != 0 AND InvoiceDate IS NOT NULL
GROUP BY DATEPART(MONTH,InvoiceDate), Country
ORDER BY 1

----------------------------------------------------------------------------------------
-- 3. Calculate the average quantity of distinct products that each order has, grouped by country
----------------------------------------------------------------------------------------

WITH sum_product_byorder AS

	(
	select InvoiceNo,Description, stockCode, SUM(Quantity) as SumQuantity
	FROM dbo.data
	GROUP BY InvoiceNo,StockCode, Description
	)
SELECT Country, sumorder.Description, sumorder.StockCode, AVG(sumorder.SumQuantity)
FROM dbo.data
JOIN sum_product_byorder sumorder 
ON dbo.data.InvoiceNo=sumorder.InvoiceNo
GROUP BY country, sumorder.Description, sumorder.StockCode
ORDER BY sumorder.StockCode

-- FOUND INSIGHTS
-- WE FOUND MANY PRODUCT LOSSES 

-- FIRST WE FOUND ALL QUANTITY PRODUCT IN NEGATIVE 

SELECT stockcode, Description, SUM(Quantity*UnitPrice) as TotalLost_byproduct
FROM dbo.data
WHERE Quantity < 0
GROUP BY StockCode, Description
order by stockcode


-- THEN WE EXTRACTED ALL DATA FROM ALL THE LOSSES AND GROUP BY PRODUCT AND COUNTRY  

WITH totallost_byproduct AS
		(
		SELECT Country, InvoiceNo, stockcode, Description, Quantity, UnitPrice, Quantity*UnitPrice as TotalLost
		FROM dbo.data
		WHERE Quantity < 0 AND UnitPrice != 0
		-- WE CLEAN VALUES WITH PRICE 0
		)
SELECT tlost.Country, tlost.stockcode,tlost.Description, sum(tlost.Totallost) 
FROM dbo.data
JOIN totallost_byproduct tlost
ON dbo.data.InvoiceNo=tlost.InvoiceNo
GROUP BY tlost.Country,tlost.Description, tlost.stockcode

----------------------------------------------------------------------------------------
--4. Calculate user retention
----------------------------------------------------------------------------------------

-- Calculate FIRST PURCHASE for each user

SELECT CustomerID,min(InvoiceDate) as First_month
	FROM dbo.data
	GROUP BY CustomerID
	

-- Calculate PURCHASE MONTH for each user

SELECT CustomerID, InvoiceDate,MONTH(InvoiceDate) as Purchase_Month
	FROM dbo.data
	WHERE InvoiceDate IS NOT NULL
	GROUP BY CustomerID,InvoiceDate, MONTH(InvoiceDate)


--Merge 2 table and calculate MONTH NUMBER from first purchase 

SELECT a.CustomerID , a.InvoiceDate, b.First_month as First_month,
		DATEDIFF(MONTH,b.First_month,a.InvoiceDate) as Month_number,
		DATEPART(MONTH,a.InvoiceDate) AS First_month_number
FROM 
	(SELECT CustomerID, InvoiceDate,MONTH(InvoiceDate) as Purchase_Month
	FROM dbo.data
	WHERE InvoiceDate IS NOT NULL
	GROUP BY CustomerID,InvoiceDate, MONTH(InvoiceDate)) a,
	(SELECT CustomerID,min(InvoiceDate) as First_month
	FROM dbo.data
	GROUP BY CustomerID) b
WHERE a.CustomerID=b.CustomerID 
ORDER BY 1, Month_number


--Create Cohort analisys retention 

select First_month_number,
	   SUM(CASE WHEN Month_number = 0 THEN 1 ELSE 0 END) AS Month_0,
       SUM(CASE WHEN Month_number = 1 THEN 1 ELSE 0 END) AS Month_1,
       SUM(CASE WHEN Month_number = 2 THEN 1 ELSE 0 END) AS Month_2,
       SUM(CASE WHEN Month_number = 3 THEN 1 ELSE 0 END) AS Month_3,
       SUM(CASE WHEN Month_number = 4 THEN 1 ELSE 0 END) AS Month_4,
       SUM(CASE WHEN Month_number = 5 THEN 1 ELSE 0 END) AS Month_5,
       SUM(CASE WHEN Month_number = 6 THEN 1 ELSE 0 END) AS Month_6,
       SUM(CASE WHEN Month_number = 7 THEN 1 ELSE 0 END) AS Month_7,
       SUM(CASE WHEN Month_number = 8 THEN 1 ELSE 0 END) AS Month_8,
       SUM(CASE WHEN Month_number = 9 THEN 1 ELSE 0 END) AS Month_9,
	   SUM(CASE WHEN Month_number = 10 THEN 1 ELSE 0 END) AS Month_10,
	   SUM(CASE WHEN Month_number = 11 THEN 1 ELSE 0 END) AS Month_11,
	   SUM(CASE WHEN Month_number = 12 THEN 1 ELSE 0 END) AS Month_12
    
 from  (

		SELECT a.CustomerID , a.InvoiceDate, b.First_month as First_month,
				DATEDIFF(MONTH,b.First_month,a.InvoiceDate) as Month_number,
				DATEPART(MONTH,a.InvoiceDate) AS First_month_number
		FROM 
			(SELECT CustomerID, InvoiceDate,MONTH(InvoiceDate) as Purchase_Month
			FROM dbo.data
			WHERE InvoiceDate IS NOT NULL
			GROUP BY CustomerID,InvoiceDate, MONTH(InvoiceDate)) a,
			(SELECT CustomerID,min(InvoiceDate) as First_month
			FROM dbo.data
			GROUP BY CustomerID) b
		WHERE a.CustomerID=b.CustomerID 

) As month_number_total
GROUP BY First_month_number
ORDER BY 1


----------------------------------------------------------------------------------------
--5. Calculate product sales by month
----------------------------------------------------------------------------------------

SELECT	DATEPART(MONTH,InvoiceDate) AS Month_number,COUNT(InvoiceNo) AS Count_Sales,
		SUM(Quantity*Unitprice) AS Total_Sales,
		DateName( month , DateAdd( month , DATEPART(MONTH,InvoiceDate) , 0 ) - 1 ) AS Month,
		Description
FROM dbo.data
WHERE Quantity>0 AND UnitPrice != 0 AND InvoiceDate IS NOT NULL
GROUP BY DATEPART(MONTH,InvoiceDate), Description
ORDER BY 1


