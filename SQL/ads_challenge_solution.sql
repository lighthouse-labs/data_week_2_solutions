-- We will reuse the script from the ADS Introduction tutorial.


DROP TABLE if exists end_obs_dates;
CREATE TABLE end_obs_dates 
AS
SELECT GENERATE_SERIES AS end_obs_date
FROM GENERATE_SERIES(CAST('1996-08-01' AS DATE),CAST('1998-06-01' AS DATE),'1 month');


-- ADS_POPULATION_HIST
DROP TABLE if exists ads_population_hist;
CREATE TABLE ads_population_hist 
AS
SELECT A.*,
       B.*
FROM end_obs_dates AS A
CROSS JOIN (
  SELECT DISTINCT customerid FROM customers
) AS B;

SELECT *
FROM ads_population_hist LIMIT 10;


-- ADS_ORDERS_HIST
DROP TABLE if exists ads_orders_hist;
CREATE TABLE ads_orders_hist 
AS
SELECT A.orderid,
       A.customerid,
       A.end_obs_date,
       B.no_of_distinct_products,
       B.no_of_items,
       B.total_price,
       B.total_discount
FROM (
  SELECT orderid,
      customerid,
      orderdate,
      CAST(DATE_TRUNC('month',orderdate) +INTERVAL '1 month' AS DATE) AS end_obs_date
  FROM orders
) AS A
LEFT OUTER JOIN (
  SELECT A.orderid,
      COUNT(DISTINCT A.productid) AS no_of_distinct_products,
      SUM(A.quantity) AS no_of_items,
      SUM(A.totalprice_for_product) AS total_price,
      -- ADDING NEW VARIABLE HERE
      SUM(A.discount) AS total_discount
  FROM (
    SELECT *,
        unitprice*quantity AS totalprice_for_product
    FROM order_details) AS A
    GROUP BY 1
  ) AS B 
ON A.orderid = B.orderid;


-- ADS_OBSERVATION_HIST
DROP TABLE if exists ads_observation_hist;
CREATE TABLE ads_observation_hist 
AS
SELECT A.*,
       COALESCE(B.no_of_distinct_orders_1M,0) AS no_of_distinct_orders_1M,
       COALESCE(B.no_of_items_1M,0) AS no_of_items_1M,
       COALESCE(B.total_price_1M,0) AS total_price_1M,
       -- ADDING NEW VARIABLES HERE
       COALESCE(B.total_discount_1M,0) AS total_discount_1M,
       COALESCE(B.avg_discount_1M,0) AS avg_discount_1M
FROM ads_population_hist AS A
LEFT OUTER JOIN (
    SELECT customerid,
        end_obs_date,
        COUNT (DISTINCT orderid) AS no_of_distinct_orders_1M,
        SUM (no_of_items) AS no_of_items_1M,
        SUM (total_price) AS total_price_1M,
        -- ADDING NEW VARIABLES HERE
        SUM (total_discount) AS total_discount_1M,
        AVG (total_discount) AS avg_discount_1M
    FROM ads_orders_hist
    GROUP BY 1,2
) AS B 
ON A.customerid = B.customerid 
  AND A.end_obs_date = B.end_obs_date
;


SELECT customerid,
       end_obs_date,
       COUNT(*)
FROM ads_observation_hist
GROUP BY 1,
         2
ORDER BY 3 DESC LIMIT 5;


SELECT *
FROM ads_observation_hist 
ORDER BY customerid, end_obs_date
LIMIT 100;


--=================================================
-- 3 months aggregates
-- ADS_OBSERVATION_HIST_3M
DROP TABLE if exists ADS_OBSERVATION_HIST_3M;
CREATE TABLE ADS_OBSERVATION_HIST_3M 
AS
SELECT end_obs_date,
    customerid,
    no_of_distinct_orders_1M,
    no_of_items_1M,
    total_price_1M,
    total_discount_1M,
    avg_discount_1M,
    SUM(no_of_items_1M) OVER (PARTITION BY customerid ORDER BY end_obs_date DESC ROWS BETWEEN CURRENT ROW AND 2 FOLLOWING) as no_of_items_3M,
    SUM(total_price_1M) OVER (PARTITION BY customerid ORDER BY end_obs_date DESC ROWS BETWEEN CURRENT ROW AND 2 FOLLOWING) as total_price_3M,
    MAX(total_price_1M) OVER (PARTITION BY customerid ORDER BY end_obs_date DESC ROWS BETWEEN CURRENT ROW AND 2 FOLLOWING) as max_monthly_total_price_3M,
    MIN(total_price_1M) OVER (PARTITION BY customerid ORDER BY end_obs_date DESC ROWS BETWEEN CURRENT ROW AND 2 FOLLOWING) as min_monthly_total_price_3M,
    AVG(no_of_items_1M) OVER (PARTITION BY customerid ORDER BY end_obs_date DESC ROWS BETWEEN CURRENT ROW AND 2 FOLLOWING) as avg_no_of_items_3M
FROM ADS_OBSERVATION_HIST;


SELECT * FROM ADS_OBSERVATION_HIST_3M LIMIT 100;

