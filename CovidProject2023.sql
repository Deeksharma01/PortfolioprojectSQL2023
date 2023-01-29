-- LOOKING AT TOTAL CASES VS TOTAL DEATHS
-- SUGGESTED LIKELIHOOF OF DEATH IN INDIA DUE TO COVID CONTRACTION

SELECT location,date,CAST (total_deaths AS FLOAT),total_cases, (CAST (total_deaths AS FLOAT)/total_cases)* 100 AS DeathPercentage
FROM coviddeaths
WHERE location LIKE '%India'
ORDER BY date DESC

-- LOOKING AT TOTAL CASES VS POPULATION
SELECT location,date,total_cases ,population, (total_cases/population)* 100 AS %Casesperpopulation
FROM coviddeaths
WHERE location LIKE '%India'
ORDER BY date DESC

--LOOKING FOR COUNTRIES WITH HIGHEST INFECTION RATE PER POPULATION
SELECT location,MAX(total_cases) AS HighestInfection ,population, MAX((total_cases/population))* 100 AS 
%Casesperpopulation
FROM coviddeaths
GROUP BY location, population
ORDER BY %Casesperpopulation DESC

-- LOOKING FOR HIGHEST DEATH COUNT IN WORLD
SELECT location,MAX(total_deaths) AS DeathCount
FROM coviddeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY DeathCount DESC



--BREAKING DOWN BY CONTINENTS
SELECT CONTINENT,MAX(total_deaths) AS DeathCount
FROM coviddeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY DeathCount DESC

--GLOBAL NUMBERS
SELECT date,SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, (SUM(new_deaths)/SUM(new_cases))* 100 AS DeathPercentage
FROM coviddeaths
--WHERE location LIKE '%India'
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY date DESC

--JOINING THE TWO TABLES
SELECT *
FROM coviddeaths AS  CD
JOIN covidvaccinations AS CV
ON CD.location = CV.location
AND CD.date = CV.date


-- TOTAL VACCINATIONS VS POPULATION
SELECT CD.continent, CD.location, CD.date, CD.population, CV.New_vaccinations
FROM coviddeaths AS  CD
JOIN covidvaccinations AS CV
ON CD.location = CV.location
AND CD.date = CV.date
WHERE CD.continent IS NOT NULL
AND new_vaccinations is NOT NULL
--SELECT * FROM covidvaccinations
--WHERE new_vaccinations is NOT NULL

--VACvsPOP

SELECT CD.continent, CD.location, CD.date, CD.population, CV.New_vaccinations
,SUM(CV.New_vaccinations) OVER (PARTITION BY CD.location ORDER BY CD.location,CD.date) AS RollingpeopleVac
FROM coviddeaths AS  CD
JOIN covidvaccinations AS CV
ON CD.location = CV.location
AND CD.date = CV.date
WHERE CD.continent IS NOT NULL
AND new_vaccinations is NOT NULL


--using CTE

 WITH PopvsVAC(continent,location,date,population,new_vaccination,RollingpeopleVac)
 AS(
SELECT CD.continent, CD.location, CD.date, CD.population, CV.New_vaccinations
,SUM(CV.New_vaccinations) OVER (PARTITION BY CD.location ORDER BY CD.location,CD.date) AS RollingpeopleVac
FROM coviddeaths AS  CD
JOIN covidvaccinations AS CV
ON CD.location = CV.location
AND CD.date = CV.date
WHERE CD.continent IS NOT NULL
AND new_vaccinations is NOT NULL
)
SELECT *,(RollingpeopleVac/Population)*100
FROM PopvsVAC


-- CREATING VIEW
Create view PercentPopulationVaccinated as
SELECT CD.continent, CD.location, CD.date, CD.population, CV.New_vaccinations
,SUM(CV.New_vaccinations) OVER (PARTITION BY CD.location ORDER BY CD.location,CD.date) AS RollingpeopleVac
FROM coviddeaths AS  CD
JOIN covidvaccinations AS CV
ON CD.location = CV.location
AND CD.date = CV.date
WHERE CD.continent IS NOT NULL
AND new_vaccinations is NOT NULL