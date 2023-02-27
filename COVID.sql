SELECT * 
FROM CovidProject..CovidDeaths
order by 3, 4

--SELECT * 
--FROM CovidProject..CovidVaccinations
--order by 3, 4

-- Select data that we are going to use

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidProject..CovidDeaths
order by 1,2

-- Looking at the total Cases vs Total Deaths ( it shows likelihood of dying from covid in your country)

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM CovidProject..CovidDeaths
WHERE location like '%states%'
order by 1,2

--- Looking at Total Cases vs Population

SELECT location, date, Population, total_cases, (total_cases/population)*100 as InfectPercentage
FROM CovidProject..CovidDeaths
order by 1,2

-- Looking at Countries with Highest Infection Rate

SELECT location,Population, MAX(total_cases) as MaxInfection, MAX((total_cases/population)*100 )as InfectPercentage
FROM CovidProject..CovidDeaths
where continent is not null
Group By location, Population
order by InfectPercentage DESC

--- Showing Countries with Highest Death -Number
SELECT location,max(cast(total_deaths as int)) as TotalDeath --in this way we converted nvarchar into int to get more accurate result using aggregerate functions
FROM CovidProject..CovidDeaths
where continent is not null
Group By location
order by TotalDeath DESC



--- Showing Countries with Highest Death Rate per Population
SELECT location,Population,  MAX((total_deaths/population)*100 )as DeathRate
FROM CovidProject..CovidDeaths
where continent is not null -- to get rid of wrong location values like world or continent name
Group By location, Population
order by DeathRate DESC

-- Showing Total Death Number per Continent


SELECT continent, max(cast(total_deaths as int)) as TotalDeath
FROM CovidProject..CovidDeaths
where continent is not null -- to get rid of wrong location values like world or continent name
Group By continent
order by TotalDeath DESC

-- an error detected here which north america has only value of total death from USA, not including canada. Lets go on for now and care about this problem later on



--Global Numbers


SELECT sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, (sum(cast(new_deaths as int))/sum(new_cases))*100 as DeathPercentage
FROM CovidProject..CovidDeaths
where continent is not null
--GROUP BY date
order by 1,2


Select *
From CovidProject..CovidVaccinations


--Joining two table on date

Select *
From CovidProject..CovidDeaths dth
Join CovidProject..CovidVaccinations vac
on dth.date =vac.date
and dth.location=vac.location


-- Looking at Total Population vs Vaccination
-- CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccnations,  RollingPeopleVaccinated)
as
(
Select dth.continent, dth.location, dth.date, dth.population, vac.new_vaccinations, SUM(CONVERT(int, vac.new_vaccinations)) over (Partition by dth.Location order by dth.location,
    dth.Date) as RollingPeopleVaccinated
	--(RollingPeopleVaccinated/population)*100
From CovidProject..CovidDeaths dth
Join CovidProject..CovidVaccinations vac
    On dth.location = vac.location
	and dth.date = vac.date
WHERE dth.continent is not null
)

SELECT * ,(RollingPeopleVaccinated/Population)*100
FROM PopvsVac

-- TEMP TABLE
Drop Table if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
Select dth.continent, dth.location, dth.date, dth.population, vac.new_vaccinations, SUM(CONVERT(int, vac.new_vaccinations)) over (Partition by dth.Location order by dth.location,
    dth.Date) as RollingPeopleVaccinated
	--(RollingPeopleVaccinated/population)*100
From CovidProject..CovidDeaths dth
Join CovidProject..CovidVaccinations vac
    On dth.location = vac.location
	and dth.date = vac.date
--WHERE dth.continent is not null

SELECT * ,(RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated


-- Creating View 

Create View PercentPopulationVaccinated as
Select dth.continent, dth.location, dth.date, dth.population, vac.new_vaccinations, SUM(CONVERT(int, vac.new_vaccinations)) over (Partition by dth.Location order by dth.location,
    dth.Date) as RollingPeopleVaccinated
	--(RollingPeopleVaccinated/population)*100
From CovidProject..CovidDeaths dth
Join CovidProject..CovidVaccinations vac
    On dth.location = vac.location
	and dth.date = vac.date
WHERE dth.continent is not null

Select * 
from PercentPopulationVaccinated