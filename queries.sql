
create DATABASE new1;
use new1;

-- looking at the data 
SELECT continent,location,date,total_cases,new_cases,total_deaths,population 
FROM coviddeaths
WHERE continent IS NOT NULL
Order BY 1,2;

-- looking at cases vs death
SELECT location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM coviddeaths
WHERE location like '%states%' AND continent IS NOT NULL
Order BY 1,2;

-- looking at cases vs population
SELECT location,date,total_cases,population, (total_deaths/population)*100 AS DeathPercentage
FROM coviddeaths
WHERE location like '%states%' AND continent IS NOT NULL
Order BY 1,2;

-- loooking at countries with highest infection rate
Select location,population,max(total_cases) as highest_Infection_Count, max((total_cases/population))*100 as percentage_infection_count
From coviddeaths
WHERE continent IS NOT NULL
group by location,population
order by percentage_infection_count desc;

-- showing countries with highest death count per population
SELECT location, MAX(cast(total_deaths as unsigned)) AS highest_death_count
FROM coviddeaths
WHERE continent not like ''
GROUP BY location
ORDER BY highest_death_count DESC;

-- showing continents with highest death count per population
SELECT continent, MAX(cast(total_deaths as unsigned)) AS highest_death_count
FROM coviddeaths
WHERE continent like '%'
GROUP BY continent
ORDER BY highest_death_count DESC;

-- global numbers
SELECT SUM(new_cases) as total_cases,SUM(new_deaths) as total_deaths,SUM(new_deaths)/SUM(new_cases)*100 as DeathPercentage -- total_cases,total_deaths, (total_deaths/population)*100 AS DeathPercentage
FROM coviddeaths
WHERE continent NOT LIKE ''
Order BY 1,2;

-- looking at total populatio vs vaccinations
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(vac.new_vaccinations) over (partition by dea.location Order by dea.location,dea.date) as RollingPeopleVaccinated
from coviddeaths dea
join covidvaccinations vac
on dea.date= vac.date
and dea.location = vac.location
where dea.continent not like ''
order by 2,3;

-- use CTE

with PopvsVac (continent,location,date,population,New_Vaccinations,RollingPeopleVaccinated)
as(
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(vac.new_vaccinations) over (partition by dea.location Order by dea.location,dea.date) as RollingPeopleVaccinated
from coviddeaths dea
join covidvaccinations vac
on dea.date= vac.date
and dea.location = vac.location
where dea.continent not like ''
-- order by 2,3
)
select *,(RollingPeopleVaccinated/population)*100
from PopvsVac
order by RollingPeopleVaccinated desc;

-- temp table

drop table if exists PercentPopulationVaccinated;
create temporary table PercentPopulationVaccinated(
	continent varchar(255),
    location nvarchar(255),
    date varchar(255),
    population BIGINT,
    new_vaccinations varchar(255),
    RollingPeopleVaccinated numeric
 );
Insert into PercentPopulationVaccinated
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(vac.new_vaccinations) over (partition by dea.location Order by dea.location,dea.date) as RollingPeopleVaccinated
from coviddeaths dea
join covidvaccinations vac
on dea.date= vac.date
and dea.location = vac.location
-- where dea.continent not like ''
order by 2,3;

select *,(RollingPeopleVaccinated/population)*100
from PercentPopulationVaccinated;

-- creating view

create view PercentPopulationVaccinated as
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(vac.new_vaccinations) over (partition by dea.location Order by dea.location,dea.date) as RollingPeopleVaccinated
from coviddeaths dea
join covidvaccinations vac
on dea.date= vac.date
and dea.location = vac.location
where dea.continent not like ''
order by 2,3;

select * from PercentPopulationVaccinated;
