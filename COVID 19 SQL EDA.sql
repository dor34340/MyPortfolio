--Let's have a look at the data

select *
From CovidDeaths
order by 3,4

select *
From CovidVaccinations
order by 3,4


-- Select Data that we are going to be starting with
select Location, date, total_cases, new_cases, total_deaths, population
from CovidDeaths
where continent is not null
order by 1,2

-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country
select Location, date, total_cases, total_deaths, population,(total_deaths/total_cases)*100 AS DeathPrecentage
from CovidDeaths
where location like '%states%' 
order by 1,2


-- Total Cases vs Population
-- Shows what percentage of population infected with Covid
select Location, date, total_cases, total_deaths, population,(total_cases/population)*100 AS InfectedPrecentage
from CovidDeaths
where continent is not null
order by 1,2

--Now let's look for every Country
-- option 1
select Location, avg((total_cases/population)*100) AS InfectedPrecentage
from CovidDeaths
where continent is not null
group by Location
order by InfectedPrecentage desc

-- option 2
select Location,population, max(total_cases) as HighestInfectedCount, max((total_cases/population)*100) AS InfectedPrecentage
from CovidDeaths
where continent is not null
group by Location, population
order by InfectedPrecentage desc

-- Countries with Highest Death Count per Population
select Location, max(cast(total_deaths as int)) as HighestDeathsCount
from CovidDeaths
where continent is not null
group by Location
order by HighestDeathsCount desc


-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population - the right answer

select continent, max(cast(total_deaths as int)) as HighestDeathsCount
from CovidDeaths
where continent is not null
group by continent
order by HighestDeathsCount desc

-- Global numbers:

select date, sum(new_cases) as TotalCases, sum(cast(new_deaths as int)) as TotalDeaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPrecentage
from CovidDeaths
where continent is not null
group by date
order by 1,2

--without group by date:
select sum(new_cases) as TotalCases, sum(cast(new_deaths as int)) as TotalDeaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPrecentage
from CovidDeaths
where continent is not null
order by 1,2


-- Looking at total Population VS total vaccination
select A.continent, A.Location, A.date, A.population, B.new_vaccinations,
SUM(CONVERT(INT, B.new_vaccinations)) OVER (
	PARTITION BY A.Location ORDER BY A.LOCATION, A.date) AS	RollingPeopleVaccinated
from CovidDeaths A
JOIN CovidVaccinations B
ON A.Location = B.location
and
A.date = B.date
where A.continent is not null
order by 2,3


-- USE CTE:

WITH PopvsVac 
as
(select A.continent, A.Location, A.date, A.population, B.new_vaccinations,
SUM(CONVERT(INT, B.new_vaccinations)) OVER (
	PARTITION BY A.Location ORDER BY A.LOCATION, A.date) AS	RollingPeopleVaccinated
from CovidDeaths A
JOIN CovidVaccinations B
ON A.Location = B.location
and
A.date = B.date
where A.continent is not null
)
select *, (RollingPeopleVaccinated/population)*100 as i
from PopvsVac


--TEMP TABLE
DROP TABLE IF EXISTS #PercentPopulationVaccination
CREATE TABLE #PercentPopulationVaccination
(
Continent nvarchar (255),
Location nvarchar (255),
date datetime,
Population numeric,
New_Vaccination numeric, 
RollingPeopleVaccinated numeric
)
INSERT INTO #PercentPopulationVaccination
select A.continent, A.Location, A.date, A.population, B.new_vaccinations,
SUM(CONVERT(INT, B.new_vaccinations)) OVER (
	PARTITION BY A.Location ORDER BY A.LOCATION, A.date) AS	RollingPeopleVaccinated
from CovidDeaths A
JOIN CovidVaccinations B
ON A.Location = B.location
and
A.date = B.date
where A.continent is not null

select *, (RollingPeopleVaccinated/population)*100 as i
from #PercentPopulationVaccination


--Creating View to store data for later visualization 

CREATE VIEW PercentPopulationVaccinated AS
select A.continent, A.Location, A.date, A.population, B.new_vaccinations,
SUM(CONVERT(INT, B.new_vaccinations)) OVER (
	PARTITION BY A.Location ORDER BY A.LOCATION, A.date) AS	RollingPeopleVaccinated
from CovidDeaths A
JOIN CovidVaccinations B
ON A.Location = B.location
and
A.date = B.date
where A.continent is not null


select *
FROM PercentPopulationVaccinated
