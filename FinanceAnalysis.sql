
/*

Finance Analysis - Trevor Ali

Analyzing financial incomes

*/

select * from FinancialStatistics

select round(sum(income),0)
from FinancialStatistics

select round(sum([Target Income]),0)
from FinancialStatistics

select 
	Month, 
	sum(income)
from FinancialStatistics
group by month


select 
	[Income sources], 
	round(sum(income),0)
from FinancialStatistics
group by [Income sources]


select 
	[Income sources] ,
	[Income Breakdowns], 
	round(sum(income),0)
from FinancialStatistics
group by [Income Breakdowns], [Income sources]


select 
	[Marketing Strategies], 
	sum(income),
	round((sum(income)/sum(sum(income)) over () * 100),2)
from FinancialStatistics
group by [Marketing Strategies]



select 
	[Income sources],
	sum(counts),
	round((sum(counts)/sum(sum(counts)) over() * 100),0)
from FinancialStatistics
group by [Income sources]
order by 3 desc


select 
	country, 
	round(sum(income),0)
from FinancialStatistics
group by country


with avgmonth as (
select 
	Month, 
	sum(income) 'MonthlyIncome'
from FinancialStatistics
group by month
)
select round(avg(MonthlyIncome),0)
from avgmonth