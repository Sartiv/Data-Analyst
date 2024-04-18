-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

SELECT Location, date, total_cases, total_deaths, (CAST(total_deaths AS float) / CAST(total_cases AS float))*100 AS DeathPercentage
FROM Practice..CovidDeaths
where location like '%greece%'
--where continent is null
order by 1, 2

-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid

SELECT Location, date, population, total_cases,  (CAST(total_cases AS float) / CAST(population AS float))*100 AS PercentPopulationInfected
FROM Practice..CovidDeaths
where continent is not null
order by 1, 2

-- Looking at Countries with Highest Infection Rate compared to Population
SELECT Location, population, MAX(CAST(total_cases as int)) as HighestInfectionCount,  MAX(CAST(total_cases as float) / CAST(population AS float))*100 AS PercentPopulationInfected
FROM Practice..CovidDeaths
where continent is not null
group by location, population
order by PercentPopulationInfected DESC

-- Showing Countries with Highest Death Count per Population
SELECT Location, population, MAX(CAST(total_deaths AS int)) as HighestDeathsCount,  MAX(( CAST(total_deaths AS float) / CAST(population AS float) )*100) AS PercentPopulationDeaths
FROM Practice..CovidDeaths
where continent is not null
group by location, population
order by PercentPopulationDeaths DESC

-- Showing Continent with Total Death Count
SELECT location, MAX(CAST(total_deaths AS int)) as totalDeathCount
FROM Practice..CovidDeaths
where continent is null AND location NOT IN ('High income', 'Low income', 'Upper middle income', 'Lower middle income')
group by location
order by totalDeathCount DESC

-- Showing continents with the highest death count per population
SELECT continent, MAX(Cast(Total_deaths as int)) as TotalDeathCount
FROM Practice..CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount DESC

-- GLOBAL NUMBERS
SELECT SUM(new_cases) as total_cases, SUM(CAST(new_deaths as float)) as total_deaths, Nullif(sum(new_deaths), 0)/nullif(sum(new_cases), 0)*100 as deathpercentage
FROM Practice..CovidDeaths
where continent is not null
--GROUP BY date
order by 1, 2

-- VACCINATIONS
SELECT * 
From Practice..CovidDeaths dea
JOIN Practice..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date

-- Looking at Total Population vs Vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/dea.population)*100
From Practice..CovidDeaths dea
JOIN Practice..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
	order by 2,3

-- USE CTE
With PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/dea.population)*100
From Practice..CovidDeaths dea
JOIN Practice..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
)
Select *, (RollingPeopleVaccinated/Population)*100 
from PopvsVac

-- TEMP TABLE
DROP Table if exists #PercentPopulationVaccinated
CREATE table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/dea.population)*100
From Practice..CovidDeaths dea
JOIN Practice..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
	--where dea.continent is not null
	Select * , (RollingPeopleVaccinated/Population)*100
	From #PercentPopulationVaccinated

-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/dea.population)*100
From Practice..CovidDeaths dea
JOIN Practice..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
	--order by 2, 3

	Select *
	from PercentPopulationVaccinated


