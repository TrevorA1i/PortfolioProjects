select * from AdHocAnalysis.dim_customer;
select * from AdHocAnalysis.dim_product;
select * from AdHocAnalysis.fact_gross_price;
select * from AdHocAnalysis.fact_manufacturing_cost;
select * from AdHocAnalysis.fact_pre_invoice_deductions;
select * from AdHocAnalysis.fact_sales_monthly;


-- 1. Provide the list of markets in which customer "Atliq Exclusive" operates its business in the APAC region.
select distinct market
from AdHocAnalysis.dim_customer
where customer = 'Atliq Exclusive' and region = 'APAC'
order by market asc;


-- 2. What is the percentage of unique product increase in 2021 vs. 2020?
SELECT  
count(distinct case when year(date) = 2020 then product_code end) as '2020',
count(distinct case when year(date) = 2021 then product_code end) as '2021'
FROM AdHocAnalysis.fact_sales_monthly;

with cte as 
(SELECT  
count(distinct case when fiscal_year = 2020 then product_code end) as 'UniqueProducts2020',
count(distinct case when fiscal_year = 2021 then product_code end) as 'UniqueProducts2021'
FROM AdHocAnalysis.fact_sales_monthly)

select 
	round((UniqueProducts2021-UniqueProducts2020)*100/(UniqueProducts2020),2) as PercentageChng,
    UniqueProducts2020, 
	UniqueProducts2021
from cte;


-- 3. Provide a report with all the unique product counts for each segment and sort them in descending order of product counts.
select Segment, count(distinct product_code) as 'ProductCount'
from AdHocAnalysis.dim_product
group by segment
order by 2 desc;


-- 4. Follow-up: Which segment had the most increase in unique products in 2021 vs 2020?
with cte as 
(select 
	dp.segment, 
	count(distinct case when fiscal_year = 2020 then dp.product_code end) as 'ProductCount2020',
    count(distinct case when fiscal_year = 2021 then dp.product_code end) as 'ProductCount2021'
from AdHocAnalysis.dim_product dp
join AdHocAnalysis.fact_sales_monthly fsm on
dp.product_code = fsm.product_code
group by dp.segment)

select 
	segment,
    ProductCount2020,
    ProductCount2021,
    (ProductCount2021)-(ProductCount2020) as Difference
from cte;


-- 5. Get the products that have the highest and lowest manufacturing costs. 
-- The final output should contain these fields, product_code, product, manufacturing_cost
select max(manufacturing_cost)
from AdHocAnalysis.fact_manufacturing_cost;

SELECT pro.product_code, pro.product, fmc.manufacturing_cost
FROM AdHocAnalysis.fact_manufacturing_cost fmc
join AdHocAnalysis.dim_product pro on
fmc.product_code = pro.product_code
WHERE manufacturing_cost IN (SELECT MAX(manufacturing_cost) FROM AdHocAnalysis.fact_manufacturing_cost 
                             UNION 
                             SELECT MIN(manufacturing_cost) FROM AdHocAnalysis.fact_manufacturing_cost)
group by pro.product_code, pro.product, fmc.manufacturing_cost
order by 3 desc;



-- 6. Generate a report which contains the top 5 customers who received an average high pre_invoice_discount_pct 
-- for the fiscal year 2021 and in the Indian market. The final output contains these fields, 
-- customer_code, customer, average_discount_percentage

select fpi.customer_code, dc.customer, round(avg(pre_invoice_discount_pct),4) as 'AvgDiscount%'
from AdHocAnalysis.dim_customer dc
join AdHocAnalysis.fact_pre_invoice_deductions fpi on
dc.customer_code = fpi.customer_code
where fiscal_year = 2021 and market = 'India'
group by customer_code, customer
order by 3 desc
limit 5;


-- 7. Get the complete report of the Gross sales amount for the customer “Atliq Exclusive” for each month . 
-- This analysis helps to get an idea of low and high-performing months and take strategic decisions. 
-- The final report contains these columns: Month, Year, Gross sales Amount

select 
	monthname(sal.date) as 'Month',
    sal.fiscal_year as 'Year',
    sum(gro.gross_price*sold_quantity) as 'GrossSalesAmount'
from AdHocAnalysis.fact_gross_price gro
join AdHocAnalysis.fact_sales_monthly sal on
gro.product_code = sal.product_code
join AdHocAnalysis.dim_customer cus on
sal.customer_code = cus.customer_code
where cus.customer = 'Atliq Exclusive'
group by Month, sal.fiscal_year
order by 2
;


-- 8. In which quarter of 2020, got the maximum total_sold_quantity? 
-- The final output contains these fields sorted by the total_sold_quantity, Quarter total_sold_quantity

select 
case
    when date between '2019-09-01' and '2019-11-01' then 'First Quater'
    when date between '2019-12-01' and '2020-02-01' then 'Second Quater'
    when date between '2020-03-01' and '2020-05-01' then 'Third Quater'
    when date between '2020-06-01' and '2020-08-01' then 'Fourth Quater'
    end as Quarters,
    SUM(sold_quantity) as total_sold_quantity
from AdHocAnalysis.fact_sales_monthly
where fiscal_year = 2020
group by Quarters
order by total_sold_quantity desc;


-- 9. Which channel helped to bring more gross sales in the fiscal year 2021 and the percentage of contribution? 
-- The final output contains these fields, channel, gross_sales_mln, percentage


with cte as
(select cus.channel, round(sum(gro.gross_price*sal.sold_quantity/1000000),2) as 'GrossSales'
from AdHocAnalysis.fact_gross_price gro
join AdHocAnalysis.fact_sales_monthly sal on
gro.product_code = sal.product_code
join AdHocAnalysis.dim_customer cus on
sal.customer_code = cus.customer_code
where sal.fiscal_year = 2021
group by cus.channel)

select Channel, concat(GrossSales,' M') as GrossMln, round(grosssales*100/sum(grosssales) over (),2) as Percentage
from cte
group by channel, grosssales
order by 3 desc;



-- 10. Get the Top 3 products in each division that have a high total_sold_quantity in the fiscal_year 2021? 
-- The final output contains these fields: division, product_code

with cte as
(select 
	sal.product_code, pro.division, pro.product, sum(sal.sold_quantity) as 'total'
from AdHocAnalysis.dim_product pro
join AdHocAnalysis.fact_sales_monthly sal on
pro.product_code = sal.product_code
where sal.fiscal_year = 2021
group by sal.product_code, pro.division, pro.product),
 cte2 as
 ( select product_code, total,
	RANK() OVER(PARTITION BY division ORDER BY total DESC) AS 'Ranking' 
    from cte)

select cte.product_code, cte.product, cte.division, cte2.ranking 
from cte join cte2 on cte.product_code = cte2.product_code
where cte2.ranking in (1,2,3);


