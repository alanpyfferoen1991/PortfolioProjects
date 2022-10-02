Select *
From PortfolioProject..CovidDeaths
order by 3,4

--Select *
--From PortfolioProject..CovidVaccinations
--order by 3,4

-- Select Data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
order by 1,2


-- Looking at the Total Cases vs Total Deaths
-- Show likeyhood of dying if you contract covid in your country
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%states%'
order by 1,2


-- Looking at the total cases vs the population

Select Location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Where location like '%states%'
order by 1,2


-- Looking at countries with highest infection Rate Compared to Population

Select Location, population, MAX(total_cases) as HightestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Group by Location, population
order by PercentPopulationInfected desc


-- Showing Countries with Highest Death Count per Population

Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is not null
Group by Location
order by TotalDeathCount desc


-- BREAKING IT DOWN BY CONTINENT

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is not null
Group by continent
order by TotalDeathCount desc


-- GLOBAL NUMBERS

-- Total Cases, Total Deaths and Death Percentage by Date

Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is not null
Group By date
order by 1,2


-- Total Cases, Total Deaths and Death Percentage

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is not null
order by 1,2


-- Looking at Total Population vs Vaccinations

Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, 
  SUM(CONVERT(bigint,cv.new_vaccinations)) OVER (Partition by cd.location Order by cd.location, cd.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths cd
JOIN PortfolioProject..CovidVaccinations cv
  On cd.location = cv.location
  and cd.date = cv.date
where cd.continent is not null
order by 1,2,3

-- USE CTE

With PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, 
  SUM(CONVERT(bigint,cv.new_vaccinations)) OVER (Partition by cd.location Order by cd.location, cd.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths cd
JOIN PortfolioProject..CovidVaccinations cv
  On cd.location = cv.location
  and cd.date = cv.date
where cd.continent is not null
--order by 1,2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


-- TEMP TABLE

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
	Continent				 nvarchar(255),
	Location				 nvarchar(255),
	Date					 datetime,
	Population				 numeric,
	New_vaccinations         numeric,
	RollingPeopleVaccinated  numeric
)
Insert into #PercentPopulationVaccinated
Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, 
  SUM(CONVERT(bigint,cv.new_vaccinations)) OVER (Partition by cd.location Order by cd.location, cd.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths cd
JOIN PortfolioProject..CovidVaccinations cv
  On cd.location = cv.location
  and cd.date = cv.date
where cd.continent is not null
--order by 1,2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


-- Creating View to Store data for later visualization

Create View PercentPopulationVaccinated as 
Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, 
  SUM(CONVERT(bigint,cv.new_vaccinations)) OVER (Partition by cd.location Order by cd.location, cd.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths cd
JOIN PortfolioProject..CovidVaccinations cv
  On cd.location = cv.location
  and cd.date = cv.date
where cd.continent is not null

Select *
From PercentPopulationVaccinated;