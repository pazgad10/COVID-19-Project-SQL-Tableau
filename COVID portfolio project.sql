Select *
From PortfolioProject..CovidDeaths
Where continent is not null
Order by 3,4

Select *
From PortfolioProject..CovidVaccinations
Order by 3,4

-- Shows total cases vs death cases
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%states%'
and continent is not null
Order by 1,2

-- Shows what percentage of population got covid
Select location, date, total_cases, population, (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Where location like '%states%'
and continent is not null
Order by 1,2

-- Looking for countries with the highest infection rate compared to population
select location, MAX(total_cases) as highestInfectionCount , population, Max((total_cases/population))*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
where continent is not null
Group by location, population
Order by PercentPopulationInfected desc

-- Shows countries with the highest death count per population
Select location, max(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
Group by location
Order by TotalDeathCount desc


-- Shows continents with the highest death count per population
Select continent, max(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
Group by continent
Order by TotalDeathCount desc

-- Shows death percent in the whole world
Select sum(new_cases) as total_cases, sum(cast(total_deaths as int)) as total_deaths, sum(convert(int,New_deaths))/sum(New_cases)*100 as DeathPErcentage
From PortfolioProject..CovidDeaths
Where continent is not null
Order by 1,2


-- looking at total population vs vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as SumPeopleVaccinated
--, (SumPeopleVaccinated)/dea.population) * 100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
Order by 2,3

-- Use CTE

With PopVsVac (continent, location, date, population, New_vaccinations, SumPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as SumPeopleVaccinated
--, (SumPeopleVaccinated)/dea.population) * 100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3
)
Select *, (SumPeopleVaccinated/population)*100
From PopVsVac


-- TEMP TABLE


DROP Table if exists  #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
SumPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as SumPeopleVaccinated
--, (SumPeopleVaccinated)/dea.population) * 100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--Where dea.continent is not null
--Order by 2,3

Select *, (SumPeopleVaccinated/population)*100
From #PercentPopulationVaccinated


-- Creating view to store data for later visualization
Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as SumPeopleVaccinated
--, (SumPeopleVaccinated)/dea.population) * 100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3

Select *
From PercentPopulationVaccinated
