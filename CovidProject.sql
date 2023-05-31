-- Simple query to look at all columns in Covid dataset
SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent is not null 
ORDER BY 3,4


-- Looking at selected columns within dataset
SELECT location, date, total_cases, new_cases, total_deaths, population 
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 1,2

-- Looking at Total Cases Vs Total Deaths
-- Shows likelihood of dying if you contact Covid in your Country
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage 
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 1,2

-- Looking at Total cases Vs Population
-- Shows percentage of population that got Covid
SELECT location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected 
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
And location like '%Ghana%'
ORDER BY 1,2

-- Looking at country with highest infection rate compared to population
SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY location, population
ORDER BY PercentPopulationInfected desc

SELECT location, population, date, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY location, population, date
ORDER BY PercentPopulationInfected desc

-- Looking at countries with highest death counts per population 
SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount desc


SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is null
and location not in ('World', 'European Union', 'International','High income', 'Upper middle income', 'Lower middle income', 'Low income')
GROUP BY location
ORDER BY TotalDeathCount desc

-- Looking at African Countries with most deaths
SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent like '%Africa%'
GROUP BY location
ORDER BY TotalDeathCount desc


-- Looking at African countries with most vaccinations
SELECT location, MAX(cast(total_vaccinations as int)) as TotalVaccinationCount
FROM PortfolioProject..CovidVaccinations
WHERE continent like '%Africa%'
GROUP BY location
ORDER BY TotalVaccinationCount desc

-- Looking at continents with highest death counts per population
SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc


-- Checking Global Numbers
-- Checking Death percentage by date
SELECT date, SUM(new_cases) as Total_Cases, SUM(cast(new_deaths as int)) as Total_Deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage 
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY date
ORDER BY 1,2

-- Checking Total death percentage worldwide
SELECT SUM(new_cases) as Total_Cases, SUM(cast(new_deaths as int)) as Total_Deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage 
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 1,2

-- Looking at Total African death percentage
SELECT SUM(new_cases) as Total_African_Cases, SUM(cast(new_deaths as int)) as Total_African_Deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as AfricanDeathPercentage 
FROM PortfolioProject..CovidDeaths
WHERE continent like '%Africa%'
ORDER BY 1,2

-- Doing a union of Deaths and Vaccinations
SELECT * 
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date

-- Looking at total population vs vaccinations
-- Daily vaccinations per country
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition By dea.location Order By dea.location,
dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3

-- Using a CTE to find percentage of people vaccinated per country by population

WITH PopuVsVacc (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition By dea.location Order By dea.location,
dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
)
SELECT *, (RollingPeopleVaccinated/population)*100 as PercentageVaccinated
FROM PopuVsVacc



-- Creating a View to store data to use later 
Create View PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition By dea.location Order By dea.location,
dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3