
select * from PortfolioProject..CovidDeaths
select * from PortfolioProject..['Covid Vaccinations$']



Select Location,date,total_cases,new_cases,total_deaths,population
from PortfolioProject..CovidDeaths
order by 1,2

--Total cases v/s Totaldeaths

Select Location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where Location Like '%States%'
order by 1,2

---Total cases v/s population

Select Location,date,Population,total_cases,(total_cases/Population)*100 as Percentpopulationinfected
from PortfolioProject..CovidDeaths
where Location Like '%States%'
order by 1,2

--Countries with highest Infection Rates

Select Location,Population,Max(total_cases)as HighestinfectionCount,max(total_cases/Population)*100 as Percentpopulationinfected
from PortfolioProject..CovidDeaths
--where Location Like '%States%'
group by Location,population
order by Percentpopulationinfected desc

--Highest death count per population

Select Location,Max(cast (total_deaths as int))as TotalDeathcount
from PortfolioProject..CovidDeaths
--where Location Like '%States%'
where continent is not null
group by Location
order by TotalDeathcount desc

--now Break things according to Continent


--Continent with highest death count per population
Select continent,Max(cast (total_deaths as int))as TotalDeathcount
from PortfolioProject..CovidDeaths
--where Location Like '%States%'
where continent is not null
group by continent
order by TotalDeathcount desc

--Global Numbers

Select sum(new_cases)as Total_cases,sum(cast(new_deaths as int))as Total_Deaths,sum(cast(new_deaths as int))/Sum(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
--where Location Like '%States%'
where continent is not null
--group by date

order by 1,2

--Total Population v/s vaccination

Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations))over(partition by dea.location order by dea.location ,dea.date)
from PortfolioProject..CovidDeaths dea
join PortfolioProject..['Covid Vaccinations$'] vac
on dea.location=vac.location and dea.date=vac.date
where dea.continent is not null
order by 2,3

----CTE

with Popvsvac (continent,location,date,population,new_vaccinations,RollingPeopleVaccinated)
as
(
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations))over(partition by dea.location order by dea.location ,dea.date)as RollingPeoplevaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..['Covid Vaccinations$'] vac
on dea.location=vac.location and dea.date=vac.date
where dea.continent is not null
--order by 2,3
)
select *,(RollingPeoplevaccinated/Population)*100
from Popvsvac

---Temp Table
drop table if exists #percentPopulationvaccinated
create table #percentPopulationvaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)
insert into #percentPopulationvaccinated
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations))over(partition by dea.location order by dea.location ,dea.date)as RollingPeoplevaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..['Covid Vaccinations$'] vac
on dea.location=vac.location and dea.date=vac.date
where dea.continent is not null
--order by 2,3

select *,(RollingPeoplevaccinated/Population)*100
from #percentPopulationvaccinated

---create view for data Visualization

create view PercentPopulationVaccinated1 as
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations))over(partition by dea.location order by dea.location ,dea.date)as RollingPeoplevaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..['Covid Vaccinations$'] vac
on dea.location=vac.location and dea.date=vac.date
where dea.continent is not null
--order by 2,3

select * from PercentPopulationVaccinated1