

/*Select * 
From PortoflioProjects..CovidVaccinations
order by 3,4 */

-- Select Data that we are going to be using

Select location, date, total_cases, new_cases, total_deaths, population
From PortoflioProjects..CovidDeaths
order by 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covind in your country
SELECT location, date,
    CAST(total_cases AS FLOAT) AS total_cases,
    CAST(total_deaths AS FLOAT) AS total_deaths,
    (CAST(total_deaths AS FLOAT) / CAST(total_cases AS FLOAT)) * 100 AS DeathPercentage
FROM PortoflioProjects..CovidDeaths
where total_cases is not null and total_deaths is not null and location like '%israel%' and continent is not null
ORDER BY 1, 2;

--Looking at Total Cases vs Population
-- Shows what percantage of population got covid

Select location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected 
From PortoflioProjects..CovidDeaths
where location like '%israel%' and continent is not null
order by 1,2

-- Looking at Countries with Highest Infection rate compared to population
Select location, population, MAX(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentPopulationInfected 
From PortoflioProjects..CovidDeaths
where continent is not null
group by location, population
order by PercentPopulationInfected desc

-- Showing Countries with Highest Death Count per Population
Select location, MAX(CAST(Total_deaths as int)) as TotalDeathCount 
From PortoflioProjects..CovidDeaths
where continent is not null
group by location
order by TotalDeathCount desc

 -- Showing Total Death count by kinds of locations
Select location, MAX(CAST(Total_deaths as int)) as TotalDeathCount 
From PortoflioProjects..CovidDeaths
where continent is null
group by location
order by TotalDeathCount desc

-- Break things down by continent

--Showing continents with the highest death count per population

Select continent,MAX(CAST(Total_deaths as int)) as TotalDeathCount 
From PortoflioProjects..CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc


-- Looking at continent with Highest Infection rate compared to population
Select continent, MAX(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentPopulationInfected 
From PortoflioProjects..CovidDeaths
where continent is not null
group by continent
order by PercentPopulationInfected desc

-- GLOBAL NUMBERS

-- across the world
SELECT SUM(new_cases) as total_cases, SUM(CAST(new_deaths as int)) as total_deaths, SUM(CAST(new_deaths as int)) / SUM(new_cases)*100 as DeathPercentage
FROM PortoflioProjects..CovidDeaths
where continent is not null 
--Group by date
HAVING SUM(new_Cases) != 0
ORDER BY 1, 2;


-- Looking at Total Population vs Vaccinations

-- CTE
With PopvsVac (Continent, Location,Date,Population,New_Vaccination,RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(float, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated --keep sum for kind of location,
--(RollingPeopleVaccinated/population)*100
From PortoflioProjects..CovidDeaths as dea
JOIN PortoflioProjects..CovidVaccinations as vac
On dea.location = vac.location and 
dea.date = vac.date
where dea.continent is not null
--order by 2,3
)

Select *, (RollingPeopleVaccinated/Population)*100
from PopvsVac


-- TEMP TABLE

DROP TABLE if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255), location nvarchar(255), Date datetime, Population numeric, new_vaccinations numeric, RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(float, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated --keep sum for kind of location,
--(RollingPeopleVaccinated/population)*100
From PortoflioProjects..CovidDeaths as dea
JOIN PortoflioProjects..CovidVaccinations as vac
On dea.location = vac.location and 
dea.date = vac.date
--where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated

--Creating View to store data for visualizations
Create View PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(float, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated --keep sum for kind of location,
--(RollingPeopleVaccinated/population)*100
From PortoflioProjects..CovidDeaths as dea
JOIN PortoflioProjects..CovidVaccinations as vac
On dea.location = vac.location and 
dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *
From PercentPopulationVaccinated