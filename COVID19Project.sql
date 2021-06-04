-- shows what percentage of population got Covid
SELECT 
	location,
	date,
	population,
	total_cases,
	CASE WHEN total_deaths IS NOT NULL THEN CONCAT(ROUND((total_deaths/population) * 100,5),'%')
		ELSE NULL END AS PercentPopulationInfected
FROM 
	coviddeaths
WHERE LOWER(location) LIKE '%states' AND continent IS NOT NULL
ORDER BY location, date;

-- Looking at countries with highest infection rate compared to population
SELECT 
	location,
	population,
	MAX(total_cases) AS HigestInfectionCount,
	CONCAT(ROUND(MAX(total_cases/population) * 100,5),'%') AS PercentPopulationInfected
FROM coviddeaths
-- WHERE LOWER(location) LIKE '%states'
WHERE date BETWEEN '2020-01-28' AND '2021-04-30' AND continent IS NOT NULL
GROUP BY location, population
HAVING MAX(total_cases/population) IS NOT NULL
ORDER BY MAX(total_cases/population)  DESC;



--Showing countries with Highest Death Count per Population
SELECT 
    location,
    MAX(total_deaths) AS TotalDeathCount
FROM coviddeaths
WHERE continent IS NOT NULL AND (date BETWEEN '2020-01-28' AND '2021-04-30')
GROUP BY location
HAVING MAX(total_deaths) IS NOT NULL
ORDER BY TotalDeathCount DESC;


--Showing continents wit the highest death count per population
SELECT 
    continent,
    MAX(total_deaths) AS TotalDeathCount
FROM coviddeaths
WHERE continent IS NOT NULL AND (date BETWEEN '2020-01-28' AND '2021-04-30')
GROUP BY continent
HAVING MAX(total_deaths) IS NOT NULL
ORDER BY TotalDeathCount DESC;

-- TotalDeathCount by Location
SELECT 
    location,
    MAX(total_deaths) AS TotalDeathCount
FROM coviddeaths
WHERE continent IS NULL AND (date BETWEEN '2020-01-28' AND '2021-04-30')
GROUP BY location
HAVING MAX(total_deaths) IS NOT NULL
ORDER BY TotalDeathCount DESC;



-- Global numbers 
SELECT 
	date,
	SUM(new_cases) AS total_cases,
	SUM(CAST(new_deaths AS INT)) AS total_deaths,
	SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS DeathPercentage
FROM coviddeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY date, total_cases;





-- Looking at Total Cases vs Total Deaths
-- likelihood of deathrate of certain countries
SELECT location, date, total_cases, total_deaths, ROUND((total_deaths/total_cases) * 100, 5) AS DeathPercentage
FROM coviddeaths
WHERE LOWER(location) LIKE '%states' AND continent IS NOT NULL
GROUP BY location, date, total_cases, total_deaths
ORDER BY 2;


-- Looking at the total cases vs population
SELECT location, date, total_cases, population, ROUND((total_cases/population) * 100, 5) AS PercentageofPopulationInfected
FROM coviddeaths
WHERE LOWER(location) LIKE '%states' AND continent IS NOT NULL
GROUP BY location, date, total_cases, population
ORDER BY 1,2;
--2447

-- Looking at Countries with Highest Infection compared to reaction to population
SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population)) *100 AS PercentPopulationInfected
FROM coviddeaths
GROUP BY location, population
HAVING (MAX((total_cases/population)) *100) IS NOT NULL
ORDER BY  PercentPopulationInfected DESC;



WITH PopulatonVSVaccinations AS
(SELECT dea.continent,
	   dea.location, 
	   dea.date, 
	   population, 
	   CAST (vac.new_vaccinations AS INT),
	   SUM(CAST(vac.new_vaccinations AS INT)) OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeropleVaccinated
FROM public.Coviddeaths dea
INNER JOIN public.Covidvaccinations vac
ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL 
ORDER BY 2, 3)
-- Inside CTE "PopulatonVSVaccinations"
SELECT *,ROUND((RollingPeropleVaccinated/population)*100, 5) AS hjhk
FROM PopulatonVSVaccinations;


-- TEMP TABLE PercentPopulationVaccinated


DROP TABLE IF EXISTS PercentPopulationVaccinated;
CREATE TABLE  PercentPopulationVaccinated(
continent VARCHAR(225),
location VARCHAR(225),
DATE date,
population NUMERIC,
new_vaccinations NUMERIC,
RollingPeropleVaccinated NUMERIC
);

INSERT INTO PercentPopulationVaccinated
(SELECT dea.continent,
	   dea.location, 
	   dea.date, 
	   population, 
	   CAST (vac.new_vaccinations AS INT),
	   SUM(CAST(vac.new_vaccinations AS INT)) OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeropleVaccinated
FROM public.Coviddeaths dea
INNER JOIN public.Covidvaccinations vac
ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL);
-- ORDER BY 2, 3

SELECT *,ROUND((RollingPeropleVaccinated/population)*100, 5) AS hjhk
FROM PercentPopulationVaccinated;

-- Creating View to store for later visualization

DROP VIEW IF EXISTS Percent_Population_Vaccinated_View;
CREATE VIEW Percent_Population_Vaccinated_View AS
(
SELECT dea.continent,
	   dea.location, 
	   dea.date, 
	   population, 
	   CAST (vac.new_vaccinations AS INT),
	   SUM(CAST(vac.new_vaccinations AS INT)) OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeropleVaccinated
FROM public.Coviddeaths dea
INNER JOIN public.Covidvaccinations vac
ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL);


