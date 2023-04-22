/*
Sales Analysis - Trevor Ali




*/
--create view salesanalysis as
select
	ord.order_id,
	concat(cus.first_name,' ',cus.last_name) as 'customers',
	cus.city,
	cus.state,
	ord.order_date,
	sum(ite.quantity) as 'total_units',
	sum(ite.quantity * ite.list_price) as 'revenue',
	pro.product_name,
	cat.category_name,
	bra.brand_name,
	sto.store_name,
	concat(sta.first_name,' ',sta.last_name) as 'sales_rep'
	
from sales.orders ord
join sales.customers cus
on ord.customer_id = cus.customer_id
join sales.order_items ite
on ord.order_id = ite.order_id
join production.products pro
on ite.product_id = pro.product_id
join production.categories cat
on pro.category_id = cat.category_id
join sales.stores sto
on ord.store_id = sto.store_id
join sales.staffs sta
on ord.staff_id = sta.staff_id
join production.brands bra
on pro.brand_id = bra.brand_id

group by
	ord.order_id,
	concat(cus.first_name,' ',cus.last_name),
	cus.city,
	cus.state,
	ord.order_date,
	pro.product_name,
	cat.category_name,
	bra.brand_name,
	sto.store_name,
	concat(sta.first_name,' ',sta.last_name)


/*
1. Total revenue by year:
2. Revenue per month: The revenue earned by the bike store each month, showing any seasonal trends in sales.
3. Revenue per store:
4. Revenue per state: The revenue earned by the bike store in each state, identifying which states are the most profitable for the business.
5. Revenue per brand: The revenue earned by the bike store for each brand they carry, identifying which brands are the most popular with customers.
6. Revenue per product: The revenue earned by the bike store for each product they sell, identifying which products are the most profitable for the business.
7. Revenue per salesrep: The revenue earned by each sales rep at the bike store, identifying which sales reps are the most successful.
8. Top 10 customers: The top 10 customers who have spent the most money at the bike store, identifying which customers are the most valuable to the business.

*/



select 
	year(order_date) 'Year', 
	sum(revenue) 'Total Revenue',
	count(distinct customers) 'No. of Customers',
	sum(total_units) 'Units Sold',
	count(distinct order_id) 'No. of Orders',
	count(distinct product_name) 'No. of Products' 
from salesanalysis
	group by year(order_date)
	order by year(order_date)

----------------------------------------------------------------------------------------------------------------------
-- Revenue per month: The revenue earned by the bike store each month, showing any seasonal trends in sales.

select year(order_date) 'Year', left(datename(month, order_date),3)'Month', sum(revenue)'Total Revenue'
from salesanalysis
	group by year(order_date), left(datename(month, order_date),3)
		order by 1, 3 desc

select datename(month, order_date)'Month', sum(revenue)'TotalRevenue'
from salesanalysis
	group by datename(month, order_date)
--------------------------------------------------------------------------------------------------------------------------
-- REVENUE PER STORE

select store_name, sum(revenue)'TotalRevenue'
from salesanalysis
	group by store_name
		order by TotalRevenue desc

select year(order_date)'Year', store_name, sum(revenue)'TotalRevenue'
from salesanalysis
	group by year(order_date), store_name
		order by 1, 3 desc

--------------------------------------------------------------------------------------
-- REVENUE PER STATE

select state, sum(revenue)'TotalRevenue'
from salesanalysis
	group by state
		order by TotalRevenue

select year(order_date)'Year', state, sum(revenue)'TotalRevenue'
from salesanalysis
	group by year(order_date), state
		order by 1, 3 desc

-------------------------------------------------------------------------------
-- REVENUE PER BRAND

select brand_name, sum(revenue)'TotalRevenue'
from salesanalysis
	group by brand_name
		order by 2 desc

select year(order_date)'Year', brand_name, sum(revenue)'TotalRevenue'
from salesanalysis
	group by year(order_date), brand_name
		order by 1, 3 desc

------------------------------------------------------------------------------------
-- REVENUE PER PRODUCT

select product_name, sum(revenue)'TotalRevenue'
from salesanalysis
	group by product_name
		order by 2 desc

select year(order_date)'Year', product_name, sum(revenue)'TotalRevenue'
from salesanalysis
	group by year(order_date), product_name
		order by 1, 3 desc

---------------------------------------------------------------------------------------
-- REVENUE PER SALES REP

select sales_rep, sum(revenue)'TotalRevenue'
from salesanalysis
	group by sales_rep
		order by 2 desc

select year(order_date)'Year', sales_rep, sum(revenue)'TotalRevenue'
from salesanalysis
	group by year(order_date), sales_rep
		order by 1, 3 desc

----------------------------------------------------------------------------------
-- TOP CUSTOMERS


select top 10 customers, sum(revenue)'TotalRevenue'
from salesanalysis
--where year(order_date) = 2016
where year(order_date) = 2017
--where year(order_date) = 2018
	group by customers
		order by TotalRevenue desc
			


















