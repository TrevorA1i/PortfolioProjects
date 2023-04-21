
/*
Covid Project - Trevor ALI

COVID19 DATA EXPLORATION - Trevor Ali

Data extracted from https://ourworldindata.org/
Dates: 3/01/2020 to 12/04/2021

*/


--Checking All Data
SELECT * 
FROM PortfolioProject..CovidDeaths
SELECT *
FROM PortfolioProject..CovidVaccinations


--EXPLORING DATA TO BE USED
SELECT location, date, total_cases, new_cases, Total_deaths, population
FROM PortfolioProject..CovidDeaths
order by 1,2


--TOTAL CASES vs TOTAL DEATHS in PAPUA NEW GUINEA
--Likelihood of Deaths
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathRateofInfected
FROM PortfolioProject..CovidDeaths
where location like '%papua new guinea%'
order by 1,2


--TOTAL CASES vs TOTAL DEATHS in PAPUA NEW GUINEA
--Likelihood of Deaths
SELECT location, date, total_cases, new_cases, sum(new_cases) over (partition by location order by location, date) as DeathRate
FROM PortfolioProject..CovidDeaths
where location like '%papua new guinea%'
order by 1,2

--TOTAL CASES vs POPULATION in PAPUA NEW GUINEA
--Percentage of population has got covid in Papua New Guinea
SELECT location, date,  population, total_cases, (total_cases/population)*100
FROM PortfolioProject..CovidDeaths
where location like '%papua new guinea%'
order by 1,2 


--EXPLORATION BY COUNTRY
--HIGHEST INFECTION RATE COMPARED TO POPULATION
SELECT location, population, max(total_cases) as maxcases, max((total_cases/population))*100 as percentinfected
FROM PortfolioProject..CovidDeaths
group by location, population
order by percentinfected desc


--HIGHEST DEATHCOUNT BY POPULATION
--By Country
SELECT location, max(cast(total_deaths as int)) as DeathCount
FROM PortfolioProject..CovidDeaths
where continent is not null --filters the data to exclude continent
group by location
order by DeathCount desc


--BREAKDOWN By CONTINENT
--Countries with Highest DeathCount
SELECT location, max(cast(total_deaths as int)) as DeathCount
FROM PortfolioProject..CovidDeaths
where continent is NULL
group by location
order by DeathCount desc


--Breakdown by Continent (Demo Purposes)
--Countries with Highest DeathCount
SELECT continent, max(cast(total_deaths as int)) as DeathCount
FROM PortfolioProject..CovidDeaths
where continent is NOT NULL
group by continent
order by DeathCount desc


--GLOBAL NUMBERS
--by dates
SELECT date, sum(new_cases) TotalCases, sum(cast(new_deaths as int)) TotalDeaths, 
sum(cast(new_deaths as int))/sum(new_cases)*100 TotalDeathRate
FROM PortfolioProject..CovidDeaths
where continent is NOT NULL
group by date
order by 1 desc



---COVID VACCINATIONS
--Number of vaccinated people in the world
SELECT cd.Continent, cd.Location, cd.Date, cd.Population, cv.New_Vaccinations,
sum(convert(int, cv.new_vaccinations)) over (partition by cd.location order by cd.location, cd.date) RollingTotalVaccinated
FROM PortfolioProject..CovidDeaths cd
join PortfolioProject..CovidVaccinations cv
on cd.location = cv.location
and cd.date = cv.date
where cd.continent is NOT NULL



--USING CTEs
--Using CTEs to get the Percentage Vaccinated over Population
WITH PopulationVsVaccinations (continent, location, date, population, New_Vaccinations, RollingTotalVaccinated)
AS (
SELECT cd.Continent, cd.Location, cd.Date, cd.Population, cv.New_Vaccinations,
sum(convert(int, cv.new_vaccinations)) over (partition by cd.location order by cd.location, cd.date) RollingTotalVaccinated
FROM PortfolioProject..CovidDeaths cd
join PortfolioProject..CovidVaccinations cv
on cd.location = cv.location
and cd.date = cv.date
where cd.continent is NOT NULL
)
SELECT Continent, Location, Population, New_Vaccinations, RollingTotalVaccinated, 
max((RollingTotalVaccinated/population)*100) over (partition by location) PercentageVaccinatedOverPopulation
FROM PopulationVsVaccinations



---USING TEMP TABLE
--Using TEMP TABLES to get the Percentage Vaccinated over Population
DROP TABLE IF EXISTS #PopulationVsVaccinations
Create Table #PopulationVsVaccinations
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingTotalVaccinated numeric
)

insert into #PopulationVsVaccinations
select cd.Continent, cd.Location, cd.Date, cd.Population, cv.New_Vaccinations,
sum(convert(int, cv.new_vaccinations)) over (partition by cd.location order by cd.location, cd.date) as RollingTotalVaccinated
from PortfolioProject..CovidDeaths cd
join PortfolioProject..CovidVaccinations cv
on cd.location = cv.location
and cd.date = cv.date
where cd.continent is NOT NULL

Select Continent, Location, Population, New_Vaccinations, RollingTotalVaccinated, 
max((RollingTotalVaccinated/population)*100) over (partition by location) PercentageVaccinatedOverPopulation
from #PopulationVsVaccinations



--CREATING VIEWS FOR VISUALIZATOINS

CREATE VIEW PopulationVsVaccinations as
