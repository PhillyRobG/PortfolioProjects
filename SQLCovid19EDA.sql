-- Exploratory Data Analysis of Covid-19 data. Data set from Covid- 19 Data Explorer ourworldindata.org
-- Check Tables to be used

SELECT * 
FROM sqlprojectportfolio.dbo.CovidDeaths
ORDER BY 3,4

SELECT * 
FROM sqlprojectportfolio.dbo.CovidVaccinations
ORDER BY 3,4

-- Select Data to be used

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM sqlprojectportfolio.dbo.CovidDeaths
WHERE continent is not null
ORDER BY 1,2

-- Looking at Total Cases vs. Total Deaths
-- Shows likelihood of dying from Covid-19

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM sqlprojectportfolio.dbo.CovidDeaths
WHERE continent is not null
ORDER BY 1,2

-- Looking at Total Cases vs. Total Deaths in the United States

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM sqlprojectportfolio.dbo.CovidDeaths
WHERE Location like '%states%'
ORDER BY 1,2

-- Looking at Total Cases vs. Population in the U.S.
-- Shows what percentage of population got Covid-19

SELECT Location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
FROM sqlprojectportfolio.dbo.CovidDeaths
WHERE Location like '%states%'
ORDER BY 1,2

-- Looking at Countries with Highest Infection Rate compared to Population

SELECT Location, population, MAX(total_cases) as HighestInfectionCount,
MAX((total_cases/population))*100 as PercentPopulationInfected
FROM sqlprojectportfolio.dbo.CovidDeaths
WHERE continent is not null
GROUP BY location, population
ORDER BY PercentPopulationInfected desc

-- Looking at Countries with Highest Death Count

SELECT Location, population, MAX(total_deaths) as HighestDeathCount
FROM sqlprojectportfolio.dbo.CovidDeaths
WHERE continent is not null
GROUP BY location, population
ORDER BY HighestDeathCount desc

-- Looking at Continent with Highest Death Count

SELECT location, MAX(total_deaths) as HighestDeathCount
FROM sqlprojectportfolio.dbo.CovidDeaths
Where continent is null
GROUP BY location
ORDER BY HighestDeathCount desc

-- Looking at Countries with Highest Death Count compared to Population

SELECT Location, population, MAX(total_deaths) as HighestDeathCount,
MAX((total_deaths/population))*100 as PercentPopulationDead
FROM sqlprojectportfolio.dbo.CovidDeaths
WHERE continent is not null
GROUP BY location, population
ORDER BY PercentPopulationDead desc

-- Looking at Global Numbers

SELECT date, MAX(new_cases) as NewCases, MAX(total_deaths) as TotalDeaths
FROM sqlprojectportfolio.dbo.CovidDeaths
Where continent is null
GROUP BY date
Order BY 1,2

-- Total Global Deaths vs. New Cases By Date

SELECT date,SUM(new_cases) as TotalCases, SUM(total_deaths) as TotalDeaths,
SUM(new_deaths)/SUM(new_cases)*100 as GlobalDeathPercentage
FROM sqlprojectportfolio.dbo.CovidDeaths
Where continent is not null
GROUP BY date
Order BY 1,2

-- Total Global Deaths vs. New Cases

SELECT SUM(new_cases) as TotalCases, SUM(total_deaths) as TotalDeaths,
SUM(new_deaths)/SUM(new_cases)*100 as GlobalDeathPercentage
FROM sqlprojectportfolio.dbo.CovidDeaths
Where continent is not null
Order BY 1,2

-- Join Death and Vaccination Tables

SELECT *
FROM sqlprojectportfolio.dbo.CovidDeaths dea
JOIN sqlprojectportfolio.dbo.CovidVaccinations vac
ON dea.location = vac.location AND dea.date = vac.date

-- Looking at Total Population vs. New Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM sqlprojectportfolio.dbo.CovidDeaths dea
JOIN sqlprojectportfolio.dbo.CovidVaccinations vac
ON dea.location = vac.location AND dea.date = vac.date
Where dea.continent is not null
Order BY 2,3

-- Looking at Total Population vs. New Vaccinations Rolling Total

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM sqlprojectportfolio.dbo.CovidDeaths dea
JOIN sqlprojectportfolio.dbo.CovidVaccinations vac
ON dea.location = vac.location AND dea.date = vac.date
Where dea.continent is not null
Order BY 2,3

-- USE CTE

WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS
(SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM sqlprojectportfolio.dbo.CovidDeaths dea
JOIN sqlprojectportfolio.dbo.CovidVaccinations vac
ON dea.location = vac.location AND dea.date = vac.date
Where dea.continent is not null)
SELECT *, (RollingPeopleVaccinated/population)*100 as RollingPercentVaccinated
FROM PopvsVac

-- Creating View to store data for later visualizations

CREATE VIEW RollingPercentVaccinated as
WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS
(SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM sqlprojectportfolio.dbo.CovidDeaths dea
JOIN sqlprojectportfolio.dbo.CovidVaccinations vac
ON dea.location = vac.location AND dea.date = vac.date
Where dea.continent is not null)
SELECT *, (RollingPeopleVaccinated/population)*100 as RollingPercentVaccinated
FROM PopvsVac