
/*

Finance Analysis - Trevor Ali

Analyzing financial incomes

*/

select * from FinancialStatistics

-- The Total Income
select round(sum(income),0) 'Total Income'
from FinancialStatistics


-- Target Income
select round(sum([Target Income]),0) 'Target Income'
from FinancialStatistics;


-- Total Income by Target Income and Percentage Difference
with Income as (
select 
	round(sum(income),0)'Total Income', 
	round(sum([Target Income]),0) 'Target Income'
from FinancialStatistics
where year = 2021
)
select 
	[Target Income], 
	[Total Income],
	round((([Target Income]-[Total Income])*100/[Target Income]),2)'%Difference'
from income


-- Overall month with the highest income in 3 years
select 
	Month, 
	sum(income)
from FinancialStatistics
group by month
order by 2 desc

-- Top monthly income per year
with monthlyincome as (
select top 1 Month,	year, sum(income)'Income'
from FinancialStatistics where year=2020 group by month, year order by 3 desc
union all
select top 1 Month,	year, sum(income)'Income'
from FinancialStatistics where year=2021 group by month, year order by 3 desc
union all
select top 1 Month,	year, sum(income)'Income' 
from FinancialStatistics where year=2022 group by month, year order by 3 desc
union all
select top 1 Month,	year, sum(income)'Income'
from FinancialStatistics where year=2023 group by month, year order by 3 desc
union all
select top 1 Month,	year, sum(income)'Income'
from FinancialStatistics where year=2024 group by month, year order by 3 desc
)
select * from monthlyincome

-- Income Sources Analysis
select 
	[Income sources], 
	round(sum(income),0)'Income'
from FinancialStatistics
where year = 2022
group by [Income sources];

with incomes as (
    select [Income sources], [Income Breakdowns], SUM(income) as Income
    from FinancialStatistics
    where year = 2021
    group by [Income sources], [Income Breakdowns]
), total_income as (
    select SUM(income) as TotalIncome
    from FinancialStatistics
    where year = 2021
)
select 
    [Income sources], [Income Breakdowns],
    Income,
    round((Income / TotalIncome) * 100, 2) as IncomePercentage
from incomes
CROSS JOIN total_income
order by 3 desc;


-- Marketing Strategies
select 
	[Marketing Strategies], 
	sum(income)'Income',
	round((sum(income)/sum(sum(income)) over () * 100),2)'%of Total'
from FinancialStatistics
group by [Marketing Strategies]


--- QTY
select 
	[Income sources],
	sum(counts)'QTY',
	round((sum(counts)/sum(sum(counts)) over() * 100),0)'%of Total'
from FinancialStatistics
group by [Income sources]
order by 3 desc

-- Income by Country
select 
	Country, 
	round(sum(income),0)'Income'
from FinancialStatistics
group by country;

-- Average monthly income
with avgmonth as (
select 
	Month, 
	sum(income) 'MonthlyIncome'
from FinancialStatistics
group by month
)
select round(avg(MonthlyIncome),0)
from avgmonth
