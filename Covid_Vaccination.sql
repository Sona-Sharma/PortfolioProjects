SELECT * 
FROM
[Portfolio Project].dbo.CovidDeaths
where continent is not null
order by 3,4

--SELECT * 
--FROM
--[Portfolio Project].dbo.CovidVaccinations
--order by 3,4

--Select data from table for usage

SELECT location,date,total_cases,new_cases,total_deaths,population
FROM
[Portfolio Project].dbo.CovidDeaths
where continent is not null
ORDER BY 1,2

--lOOKING AT TOTAL CASES VS TOTAL DEATHS
--Shows likelihood of dying if you contract covid in your Country

SELECT location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 AS DeathPercentage
FROM
[Portfolio Project].dbo.CovidDeaths
where location like '%states%'
and continent is not null
ORDER BY 1,2

--lOOKING AT TOTAL CASES VS POPULATION
--Shows what percentage of population get covid
SELECT location,date,population,total_cases,(total_cases/population)*100 AS PercentagePopulationInfected
FROM
[Portfolio Project].dbo.CovidDeaths
--where location like '%states%'
where continent is not null
ORDER BY 1,2


--Looking at Countries with highesr infection rate compared to population

SELECT location,population,MAX(total_cases) as HighestInfectionCount,MAX((total_cases/population))*100 AS PercentagePopulationInfected
FROM
[Portfolio Project].dbo.CovidDeaths
--where location like '%states%'
where continent is not null
GROUP BY location,population
ORDER BY PercentagePopulationInfected desc


--Looking Countries with highest Death Count per Population
SELECT location,MAX(cast(total_deaths as int)) as TotalDeathCount
FROM
[Portfolio Project].dbo.CovidDeaths
--where location like '%states%'
where continent is not null
GROUP BY location
ORDER BY TotalDeathCount desc

--Let's break down in Continent


--Showing Continents with Highest death counts

SELECT continent,MAX(cast(total_deaths as int)) as TotalDeathCount
FROM
[Portfolio Project].dbo.CovidDeaths
--where location like '%states%'
where continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc


--GLOBAL NUMBERS with date

SELECT date,SUM(new_cases) as total_cases,SUM(cast(new_deaths as int)) as total_deaths,SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM
[Portfolio Project].dbo.CovidDeaths
where continent is not null
group by date
ORDER BY 1,2


--GLOBAL NUMBERS without date
SELECT SUM(new_cases) as total_cases,SUM(cast(new_deaths as int)) as total_deaths,SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM
[Portfolio Project].dbo.CovidDeaths
where continent is not null
--group by date
ORDER BY 1,2


--Vaccination table
SELECT * 
FROM [Portfolio Project].dbo.CovidVaccinations


--JOIN TABLES
SELECT * 
FROM [Portfolio Project].dbo.CovidDeaths AS dea
JOIN
[Portfolio Project].dbO.CovidVaccinations AS vac
ON
dea.location=vac.location AND dea.date=vac.date


--Looking at Total Population vs Vaccinations 
---USE CTE
With PopvsVac(Continent,location,date,Population,new_vaccination,RollingPeopleVaccinated)
as
(
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) as RollingPeopleVaccinated
FROM [Portfolio Project].dbo.CovidDeaths AS dea
JOIN
[Portfolio Project].dbo.CovidVaccinations AS vac
ON
dea.location=vac.location AND dea.date=vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)
Select * ,(RollingPeopleVaccinated/Population)*100
from PopvsVac


--Temp Table
DROP TABLE IF EXISTS #PercentPopulationVaccinated

Create Table #PercentPopulationVaccinated
(
Continent varchar(255),
location varchar(255),
date datetime,
Population numeric,
new_vaccination numeric,
RollingPeopleVaccinated numeric
)


Insert into #PercentPopulationVaccinated
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) as RollingPeopleVaccinated
FROM [Portfolio Project].dbo.CovidDeaths AS dea
JOIN
[Portfolio Project].dbo.CovidVaccinations AS vac
ON
dea.location=vac.location AND dea.date=vac.date
WHERE dea.continent is not null
--ORDER BY 2,3

Select * ,(RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated


--Creating view to store data for later visualization

Create View PercentPopulationVaccinated as
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) as RollingPeopleVaccinated
FROM [Portfolio Project].dbo.CovidDeaths AS dea
JOIN
[Portfolio Project].dbO.CovidVaccinations AS vac
ON
dea.location=vac.location AND dea.date=vac.date
WHERE dea.continent is not null
--ORDER BY 2,3

Select * from PercentPopulationVaccinated

---Create view
Create view totalcasevstotaldeath as
SELECT location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 AS DeathPercentage
FROM
[Portfolio Project].dbo.CovidDeaths
where location like '%states%'
and continent is not null


Select * from totalcasevstotaldeath

--



