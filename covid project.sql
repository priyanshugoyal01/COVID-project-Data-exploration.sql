Select *
From PortfolioProject..CovidDeaths
Order by 3, 4

--Select *
--From PortfolioProject..CovidVaccinations
--Order by 3, 4

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Order by 1, 2

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%states%'
Order by 1, 2

Select Location, date, total_cases, Population, (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Where location like '%states%'
Order by 1, 2

Select Location, MAX(total_cases)as HighestInfectionCount , Population, max(total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
-- location like '%states%'
Group by location, population
Order by PercentPopulationInfected desc

Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount 
From PortfolioProject..CovidDeaths
-- location like '%states%'
where continent is not null
Group by location
Order by TotalDeathCount desc

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount 
From PortfolioProject..CovidDeaths
-- location like '%states%'
where continent is not null
Group by continent
Order by TotalDeathCount desc


Select sum(new_cases)as total_cases, sum(cast(new_deaths as int))as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)* 100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%states%'
where continent is not null
--group by date
Order by 1, 2


Select dea.date, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int, vac.new_vaccinations)) 
over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population) * 100
From PortfolioProject..CovidVaccinations vac
join PortfolioProject..CovidDeaths dea
     on dea.location = vac.location
	 and dea.date = vac.date
where dea.continent is NOT null
order by 2, 3



With PopvsVac ( date, location,continent, population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.date, dea.location, dea.continent, dea.population, vac.new_vaccinations, SUM(CONVERT(int, vac.new_vaccinations)) 
over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population) * 100
From PortfolioProject..CovidVaccinations vac
join PortfolioProject..CovidDeaths dea
     on dea.location = vac.location
	 and dea.date = vac.date
where dea.continent is NOT null
--order by 2, 3
)
Select * , (RollingPeopleVaccinated/population) * 100
From PopvsVac



DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated 




Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 