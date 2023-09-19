Select Location, date, total_cases, new_cases,total_deaths, population
From [Portfolio Project].dbo.CovidDeaths
Order by 1,2
;

--Looking at Total Cases vs Total Deaths
--Shows likelihood of dying if you contract covid in your country
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage 
From [Portfolio Project].dbo.CovidDeaths
Where location like '%states%' and continent is not null
Order by 1,2
;

--Looking at Total Cases vs Population
--Shows what Percentage of Population got Covid
Select Location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected 
From [Portfolio Project].dbo.CovidDeaths
--Where location like '%states%'
Order by 1,2
;

--Looking at Countries with Highest infection rate compared to Population
Select Location, population, Max(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentPopulationInfected 
From [Portfolio Project].dbo.CovidDeaths
Where date <= '2021-04-30 00:00:00:000'
Group by location, population
Order by PercentPopulationInfected desc

--Show Countries with the Highest Death Count per Population
Select Location, Max(total_deaths) as TotalDeathCount
From [Portfolio Project].dbo.CovidDeaths
Where date <= '2021-04-30 00:00:00:000' and continent is not null
Group by location
Order by TotalDeathCount desc

--Show by Continent the Highest Death Count per Population
Select location, Max(total_deaths) as TotalDeathCount
From [Portfolio Project].dbo.CovidDeaths
Where date <= '2021-04-30 00:00:00:000' and continent is null
Group by location
Order by TotalDeathCount desc

--Showing continents with the highest death count per population
Select continent, Max(total_deaths) as TotalDeathCount
From [Portfolio Project].dbo.CovidDeaths
Where date <= '2021-04-30 00:00:00:000' and continent is not null
Group by continent
Order by TotalDeathCount desc

--Global Numbers
Select sum(new_cases) as TotalCases, sum(new_deaths) as TotalDeaths, (SUM(new_deaths)/Sum(New_cases))*100 as DeathPercentage
From [Portfolio Project].dbo.CovidDeaths
Where continent is not null and date <= '2021-04-30 00:00:00:000'
--Group By date
Having SUM(new_cases) <> 0
Order by 1,

--Looking at Total Population vs Vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(vac.new_vaccinations) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From [Portfolio Project].dbo.CovidDeaths dea Join  
[Portfolio Project].dbo.CovidVaccinations vac on dea.location =vac.location and dea.date = vac.date
Where dea.continent is not null and date <= '2021-04-30 00:00:00:000' and dea.location = 'Albania'
Order by 2,3

--Using CTE
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as (
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(vac.new_vaccinations) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From [Portfolio Project].dbo.CovidDeaths dea Join  
[Portfolio Project].dbo.CovidVaccinations vac on dea.location =vac.location and dea.date = vac.date
Where dea.continent is not null and dea.date <= '2021-04-30 00:00:00:000' and dea.location = 'Albania'
--Order by 2,3
	)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


--Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(vac.new_vaccinations) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From [Portfolio Project].dbo.CovidDeaths dea Join  
[Portfolio Project].dbo.CovidVaccinations vac on dea.location =vac.location and dea.date = vac.date
Where dea.continent is not null and dea.date <= '2021-04-30 00:00:00:000'

Select *
From PercentPopulationVaccinated