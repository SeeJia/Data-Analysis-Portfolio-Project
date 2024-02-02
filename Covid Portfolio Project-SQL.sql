SELECT *
FROM CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2

SELECT [location], [date], total_cases, new_cases, total_deaths, population
FROM CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2

--looking at total cases vs total deaths
SELECT [location], [date], total_cases, total_deaths, (total_deaths / total_cases) * 100 AS DeathPercentage
FROM CovidDeaths
WHERE [location] LIKE '%States%'
    AND continent IS NOT NULL
ORDER BY 1,2

--looking at total cases vs population
--show what percentage of population got covid
SELECT [location], [date], population, total_cases, (total_cases / population) * 100 AS PercentagePopulationInfected
FROM CovidDeaths
-- WHERE [location] LIKE '%States%'
-- AND continent IS NOT NULL
WHERE continent IS NOT NULL
ORDER BY 1,2

--looking at countries with highest infection rate compared to population
SELECT [location], population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases / population)) * 100 AS PercentagePopulationInfected
FROM CovidDeaths
-- WHERE [location] LIKE '%States%'
WHERE continent IS NOT NULL
GROUP BY [location], population
ORDER BY PercentagePopulationInfected DESC


--Showing Countries with Highest Death Count per Population
SELECT [location], MAX(total_deaths) AS TotalDeathCount
FROM CovidDeaths
-- WHERE [location] LIKE '%States%'
WHERE continent IS NOT NULL
GROUP BY [location]
ORDER BY TotalDeathCount DESC

-- show continent with Highest Death Count per Population
SELECT [continent], MAX(total_deaths) AS TotalDeathCount
FROM CovidDeaths
-- WHERE [location] LIKE '%States%'
WHERE continent IS NOT NULL
GROUP BY [continent]
ORDER BY TotalDeathCount DESC

--global numbers
SELECT SUM(new_cases) AS TotalCases, SUM(new_deaths) AS TotalDeaths, SUM(new_deaths)/SUM(new_cases) *100 AS DeathPercentage
FROM CovidDeaths
-- WHERE [location] LIKE '%States%'
WHERE continent IS NOT NULL
-- GROUP BY [date]
ORDER BY 1,2

--Looking at Total Population VS Vaccinations

--Use CTE
WITH
    PopvsVac (Continent, Location, Date, Population, New_Vaccinations, TotalPeopleVaccinated)
    AS
    (
        SELECT death.continent, death.[location], death.[date], death.population, vaccinations.new_vaccinations
, SUM(vaccinations.new_vaccinations) OVER (PARTITION BY death.location ORDER BY death.location, death.date) AS TotalPeopleVaccinated
        -- , MAX(TotalPeopleVaccinated/population) * 100 
        FROM CovidDeaths AS death
            JOIN CovidVaccinations AS vaccinations
            ON death.[location] = vaccinations.[location] AND death.[date] = vaccinations.[date]
        WHERE death.continent IS NOT NULL
        -- ORDER BY 2,3
    )

SELECT *, (TotalPeopleVaccinated/Population) * 100 AS PercentagePopvsVac
FROM PopvsVac

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
    Continent NVARCHAR (255),
    Location NVARCHAR (255),
    Date DATETIME,
    Population NUMERIC,
    New_vaccinations NUMERIC,
    TotalPeopleVaccinated NUMERIC
)

INSERT INTO #PercentPopulationVaccinated 
SELECT death.continent, death.[location], death.[date], death.population, vaccinations.new_vaccinations
, SUM(vaccinations.new_vaccinations) OVER (PARTITION BY death.location ORDER BY death.location, death.date) AS TotalPeopleVaccinated
-- , MAX(TotalPeopleVaccinated/population) * 100 
FROM CovidDeaths AS death
    JOIN CovidVaccinations AS vaccinations
    ON death.[location] = vaccinations.[location] AND death.[date] = vaccinations.[date]
-- WHERE death.continent IS NOT NULL
-- ORDER BY 2,3

SELECT *, (TotalPeopleVaccinated/Population) * 100 AS PercentagePopvsVac
FROM #PercentPopulationVaccinated

--creating view to store for later visualizations
DROP VIEW PercentPopulationVaccinated

CREATE VIEW PercentPopulationVaccinated AS  
SELECT 
    death.continent, 
    death.[location], 
    death.[date], 
    death.population, 
    vaccinations.new_vaccinations, 
    SUM(vaccinations.new_vaccinations) OVER (PARTITION BY death.location ORDER BY death.location, death.date) AS TotalPeopleVaccinated
--  , MAX(TotalPeopleVaccinated/population) * 100 
FROM 
    CovidDeaths AS death
    JOIN CovidVaccinations AS vaccinations
    ON death.[location] = vaccinations.[location] AND death.[date] = vaccinations.[date]
WHERE death.continent IS NOT NULL
-- ORDER BY 2,3

SELECT * FROM PercentPopulationVaccinated