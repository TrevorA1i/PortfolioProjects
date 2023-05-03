/*
Data Analysis using SQL

Sales Insights - Trevor Ali

*/

-- Customer Records

select * from customers


-- Total number of customers

select count(*) from customers

select *,
	case when currency = 'USD' then sales_amount*76 else sales_amount end,
	case when currency = 'USD' then profit_margin*76 else profit_margin end
from transactions
where currency = 'USD'

update transactions
set sales_amount = case when currency = 'USD' then sales_amount*76 else sales_amount end

update transactions
set profit = case when currency = 'USD' then profit*76 else profit end


-------------------------------------------------------------------------------------------------------
-- REVENUE ANALYSIS

--Revenue by QTY and YEAR
select 
	year(order_date) 'Year', 
	sum(sales_qty) 'SalesQTY', 
	round((sum(sales_amount)/1000000),2) 'SalesAMNT'
from transactions
	group by year(order_date)


--Revenue by markets
select 
	market_name, 
	concat(round((sum(sales_amount)/1000000),2), ' M') 'SalesByMil'
from transactions tra
join markets mar on
tra.market_code = mar.market_code
	group by market_name


--Sales Quantity by Markets
select 
	market_name, 
	round((sum(sales_qty)/1000),2) 'SalesQTY'
from transactions tra
join markets mar on
tra.market_code = mar.market_code
	group by market_name


--Revenue by Customers (Top 5 Customers)
select top 5 
	cus.custmer_name, 
	concat(round((sum(tra.sales_amount)/1000000),2),' M') as 'SalesByMil' 
from transactions tra
join customers cus on
tra.customer_code = cus.customer_code
	group by cus.custmer_name
	order by 2 desc


--Revenue by Products (Top 5 Products)
select top 5 
	pro.product_code, 
	concat(round((sum(sales_amount)/1000000),2), ' M') 'SalesByMil' 
from transactions tra
join products pro on
tra.product_code = pro.product_code
	group by pro.product_code
	order by 2 desc


-----------------------------------------------------------------------------------------------------
--PROFIT ANALYSIS

--Revenue by markets
select 
	market_name, 
	concat(round((sum(sales_amount)/1000000),2), ' M') 'SalesByMil'
from transactions tra
join markets mar on
tra.market_code = mar.market_code
	group by market_name

--Profit
select *
from transactions

select concat(round(sum(profit)/1000,2),' K')'Profit'
from transactions

--Profit Margin By Markets
select 
	mar.market_name,
	sum(tra.profit_margin)'TotalProfitMargin',
	round((sum(tra.profit)/sum(tra.sales_amount)*100),2) '%ProfitMargin'
from transactions tra 
join markets mar on
tra.market_code = mar.market_code
where mar.market_name <> 'bengaluru'
group by mar.market_name


--Profit by Customer Type
select 
	cus.customer_type, 
	sum(tra.sales_amount) 'Revenue',
	round((sum(tra.sales_amount)/sum(sum(tra.sales_amount)) over() * 100),2)'%Revenue'
from transactions tra
join customers cus on
tra.customer_code = cus.customer_code
group by cus.customer_type


select 
	year(order_date)'Year',
	sum(sales_amount)'Revenue',
	round((sum(profit)/sum(sales_amount)*100),2)'%ProfitMargin'
from transactions
group by year(order_date)

