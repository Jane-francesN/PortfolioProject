SELECT *
FROM PROJECT..CovidDeaths
ORDER BY 3,4

-- Selecting the columns to be used for this analysis 

SELECT location, date, total_cases, total_deaths, population, new_cases, 
FROM PROJECT..CovidDeaths
WHERE continent is not null
ORDER BY 1,2

-- Looking at the percentage of people who died due to covid19 in the United States
-- This shows the likelyhood of dying if infected by Covid19
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PROJECT..CovidDeaths
WHERE location like '%states%'
WHERE continent is not null
ORDER BY 1,2


-- Looking at the percentage of people who got invected by Covid19 in the United States

SELECT location, date, total_cases, population, (total_cases/population)*100 as PercentagePopulation
FROM PROJECT..CovidDeaths
WHERE location like '%states%'
WHERE continent is not null
ORDER BY 1,2

-- Looking at the Country with the Highest Infection rate

SELECT location, MAX(total_cases) as HighestInfectionCount, population, MAX((total_cases/population))*100 as PercentagePopulation
FROM PROJECT..CovidDeaths
WHERE continent is not null
GROUP BY Location, Population
ORDER BY PercentagePopulation desc


-- Showing the Counties with the Highest Death Count per Population


SELECT location, MAX(cast (total_deaths as int)) as TotalDeathCount
FROM PROJECT..CovidDeaths
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount desc

-- Looking at our data by Continent 

SELECT continent, MAX(cast (total_deaths as int)) as TotalDeathCount
FROM PROJECT..CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc

-- Showing the continents with the Highest Death Counts


SELECT continent, MAX(cast (total_deaths as int)) as TotalDeathCount
FROM PROJECT..CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc


-- Looking at the Global Numbers 

SELECT date, SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, (SUM(cast(new_deaths as int))/SUM(new_cases))*100 as DeathPercentage
FROM PROJECT..CovidDeaths
--WHERE location like '%states%'
WHERE continent is not null 
GROUP BY date
ORDER BY 1,2


-- Looking at the total number of Deaths across the world


SELECT SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, (SUM(cast(new_deaths as int))/SUM(new_cases))*100 as DeathPercentage
FROM PROJECT..CovidDeaths
--WHERE location like '%states%'
WHERE continent is not null 
ORDER BY 1,2

-- Looking at our Vaccination Data

SELECT *
FROM PROJECT..CovidVaccinations 


-- Joining both CovidDeaths and CovidVaccinatinon
-- Looking at Total Population Vs Vaccinations
with popVac (continent, location, date, population, new_vaccination, RollingPeopleVaccinated) as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations))
OVER (partition by dea.location ORDER BY dea.location, dea.date)as RollingPeopleVaccinated
FROM PROJECT..CovidDeaths dea
JOIN PROJECT..CovidVaccinations vac
	on dea.location = vac.location
	and
 dea.date = vac.date
WHERE dea.continent is not null
)
SELECT *, (RollingPeopleVaccinated/population)*100
FROM popVac

== Temp Table 


Drop Table if exists #PercentagePopulationVaccinated
CREATE TABLE #PercentagePopulationVaccinated
(Continent nvarchar (225),
Location nvarchar (255),
date datetime,
population numeric,
new_vaccinations numeric, 
RollingPeopleVaccinated numeric)

INSERT into #PercentagePopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations))
OVER (partition by dea.location ORDER BY dea.location, dea.date)as RollingPeopleVaccinated
FROM PROJECT..CovidDeaths dea
JOIN PROJECT..CovidVaccinations vac

	on dea.location = vac.location
	and
 dea.date = vac.date
WHERE dea.continent is not null

SELECT *, (RollingPeopleVaccinated/population)*100
FROM #PercentagePopulationVaccinated



-- Creating View to Store Data for Later

CREATE VIEW PercentagePopulationVaccinated as

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations))
OVER (partition by dea.location ORDER BY dea.location, dea.date)as RollingPeopleVaccinated
FROM PROJECT..CovidDeaths dea
JOIN PROJECT..CovidVaccinations vac
	on dea.location = vac.location
	and
 dea.date = vac.date
WHERE dea.continent is not null


SELECT *
FROM PercentagePopulationVaccinated