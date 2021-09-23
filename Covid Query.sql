SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
order by 3,4

--Initial data targets

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..coviddeaths
ORDER BY 1,2

-- total cases vs tot deaths
-- "you have a xx percentage of dying from covid"

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..coviddeaths
WHERE location Like '%States%'
ORDER BY 1,2

-- total cases vs pop
-- toggle between U.S and World

SELECT location, MAX(total_cases) AS HighestInfectionCount, population, ROUND(MAX((total_cases/population*100)),1) as PercentPopulationInfected
FROM PortfolioProject..coviddeaths
--WHERE location Like '%States%'
Group by location, population
ORDER By PercentPopulationInfected DESC

-- Showing Countries with Highest Death Count per Population

SELECT location, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount   --had to cast as INT due to data type issue
FROM PortfolioProject..coviddeaths
--WHERE location Like '%States%'
WHERE continent is not NULL
Group by location
ORDER By TotalDeathCount DESC

-- DRILL DOWN BY CONTINENT
-- accuracy issue from data discovered

SELECT continent, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount  
FROM PortfolioProject..coviddeaths
--WHERE location Like '%States%'
WHERE continent is not NULL
Group by continent
ORDER By TotalDeathCount DESC

--Therefore I will try location rather than cont

SELECT location, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount  
FROM PortfolioProject..coviddeaths
--WHERE location Like '%States%'
WHERE continent is NULL
Group by location 
ORDER By TotalDeathCount DESC

--GLOBAL NUMBERS

SELECT date, SUM(new_cases) AS Total_Cases, SUM(CAST(new_deaths AS INT)) AS TotalDeaths, ROUND(SUM(CAST
(new_deaths AS INT))/SUM(new_cases)*100,1) as DeathPercentage
FROM PortfolioProject..coviddeaths
--WHERE location Like '%States%'
WHERE continent is not NULL
GROUP BY date
ORDER BY 1,2

--Or total cases globally

SELECT SUM(new_cases) AS Total_Cases, SUM(CAST(new_deaths AS INT)) AS TotalDeaths, ROUND(SUM(CAST
(new_deaths AS INT))/SUM(new_cases)*100,1) as DeathPercentage
FROM PortfolioProject..coviddeaths
--WHERE location Like '%States%'
WHERE continent is not NULL
--GROUP BY date
ORDER BY 1,2

-- look at vac table
SELECT*
FROM PortfolioProject..CovidVaccinations

-- Join vac with deaths

SELECT *
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date

-- Look at TotPop vs Vac's

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3

-- Look at new vaccinations incrementing by location

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(INT,vac.new_vaccinations))
OVER (partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3

--With CTE

WITH PopvsVac (continent, location, date, population, new_vaccinations,RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(INT,vac.new_vaccinations))
OVER (partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopvsVac

-- With temp table

DROP TABLE if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(INT,vac.new_vaccinations))
OVER (partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated

-- CREATE VIEWS FOR VISUALIZATION

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(INT,vac.new_vaccinations))
OVER (partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null






















