show databases;
create database covid_database;
use covid_database;
select count(*) as totalRows from coviddeaths;
select count(*) as totalRows from covidvaccinations;
select count(*) as totalRows from covid_staging_v1;

select * from coviddeaths limit 5;
select * from covidvaccinations limit 5;

-- data to be used
select location,date,total_cases,new_cases,total_deaths,population
from coviddeaths order by location,day(date);

-- totalCases vs totalDeaths
select location,date,total_cases,total_deaths,round((total_deaths/total_cases)*100,2) as death_percentage
from coviddeaths 
where location like 'India'
order by location,day(date);

-- totalcases vs population
select location,date,total_cases,population,round((total_cases/population)*100,2) as covid_percentage
from coviddeaths 
where location like 'India'
order by location,day(date);

-- highest infectionrate compared to the population
select location,population,round((max(total_cases)/population)*100,2) as covid_percentage
from coviddeaths 
group by location,population
order by covid_percentage desc;

-- highest death count per population
select location,Max(cast(total_deaths as signed)) as maxDeaths
from coviddeaths
where continent is not NULL and location not in ('Africa','Asia','Antartica','North America','South Amercia','Europe','Australia','European Union')
group by location
order by maxDeaths desc;

-- showing the continents with the highest death count
SELECT 
	date,
    SUM(new_cases) AS total_cases, 
    SUM(CAST(new_deaths AS SIGNED)) AS total_deaths, 
    (SUM(CAST(new_deaths AS SIGNED)) / SUM(new_cases)) * 100 AS DeathPercentage
FROM coviddeaths
WHERE continent IS NOT NULL
group by date
ORDER BY total_cases, total_deaths;

-- total population vs Vaccinations

SELECT 
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    SUM(CAST(vac.new_vaccinations as signed)) OVER (PARTITION BY dea.location order by dea.date) as RollingVaccination
FROM coviddeaths AS dea
INNER JOIN covidvaccinations AS vac
    ON dea.location = vac.location 
   AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY dea.location,dea.date;

WITH Vaccinations AS (
    SELECT
        dea.location,
        dea.date,
        dea.population,
        SUM(CAST(vac.new_vaccinations AS SIGNED))
            OVER (PARTITION BY dea.location ORDER BY dea.date)
            AS RollingPeopleVaccinated
    FROM CovidDeaths dea
    JOIN CovidVaccinations vac
        ON dea.location = vac.location
       AND dea.date = vac.date
    WHERE dea.continent IS NOT NULL
)
SELECT *,
       ROUND(RollingPeopleVaccinated / population * 100, 2) AS PercentVaccinated
FROM Vaccinations;

-- creating and using temp table
DROP TEMPORARY TABLE IF EXISTS PercentPopulationVaccinated;

CREATE TEMPORARY TABLE PercentPopulationVaccinated (
    Continent VARCHAR(255),
    Location VARCHAR(255),
    Date DATETIME,
    Population DECIMAL(20,0),
    New_vaccinations DECIMAL(20,0),
    RollingPeopleVaccinated DECIMAL(20,0)
);

INSERT INTO PercentPopulationVaccinated
SELECT
    dea.continent,
    dea.location,
    STR_TO_DATE(dea.date, '%d-%m-%Y') AS Date,
    dea.population,
    vac.new_vaccinations,
    SUM(CAST(vac.new_vaccinations AS SIGNED))
        OVER (PARTITION BY dea.location ORDER BY STR_TO_DATE(dea.date, '%d-%m-%Y'))
        AS RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
    ON dea.location = vac.location
   AND dea.date = vac.date;

SELECT *,
       (RollingPeopleVaccinated / Population) * 100 AS PercentVaccinated
FROM PercentPopulationVaccinated;

-- create view for later data visualizations

CREATE VIEW PercentPopulationVaccinated AS
SELECT
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    SUM(CAST(vac.new_vaccinations AS SIGNED))
        OVER (PARTITION BY dea.location ORDER BY dea.date)
        AS RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
    ON dea.location = vac.location
   AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;
