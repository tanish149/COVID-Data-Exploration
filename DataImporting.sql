USE covid_database;
-- Step 1: Environment Setup
SET GLOBAL local_infile = 1;
SET autocommit = 0;
SET unique_checks = 0;
SET foreign_key_checks = 0;

-- Step 2: Create Table with Original CSV Column Names
CREATE TABLE IF NOT EXISTS covid_staging_v1 (
    iso_code VARCHAR(10),
    continent VARCHAR(50),
    location VARCHAR(100),
    date TEXT, -- Keeping original name, using TEXT for safety during import
    new_tests TEXT,
    total_tests TEXT,
    total_tests_per_thousand TEXT,
    new_tests_per_thousand TEXT,
    new_tests_smoothed TEXT,
    new_tests_smoothed_per_thousand TEXT,
    positive_rate TEXT,
    tests_per_case TEXT,
    tests_units VARCHAR(50),
    total_vaccinations TEXT,
    people_vaccinated TEXT,
    people_fully_vaccinated TEXT,
    new_vaccinations TEXT,
    new_vaccinations_smoothed TEXT,
    total_vaccinations_per_hundred TEXT,
    people_vaccinated_per_hundred TEXT,
    people_fully_vaccinated_per_hundred TEXT,
    new_vaccinations_smoothed_per_million TEXT,
    stringency_index TEXT,
    population_density TEXT,
    median_age TEXT,
    aged_65_older TEXT,
    aged_70_older TEXT,
    gdp_per_capita TEXT,
    extreme_poverty TEXT,
    cardiovasc_death_rate TEXT,
    diabetes_prevalence TEXT,
    female_smokers TEXT,
    male_smokers TEXT,
    handwashing_facilities TEXT,
    hospital_beds_per_thousand TEXT,
    life_expectancy TEXT,
    human_development_index TEXT,
    -- Custom helper column for proper SQL dates
    date_converted DATE
);

-- Step 3: Perform Bulk Load
LOAD DATA LOCAL INFILE "C:/Users/therestofthepath"
INTO TABLE covid_staging_v1
FIELDS TERMINATED BY ',' 
OPTIONALLY ENCLOSED BY '"' 
LINES TERMINATED BY '\r\n' 
IGNORE 1 ROWS
(iso_code, continent, location, date, @new_tests, @total_tests, @total_tests_per_thousand, 
 @new_tests_per_thousand, @new_tests_smoothed, @new_tests_smoothed_per_thousand, @positive_rate, 
 @tests_per_case, tests_units, @total_vaccinations, @people_vaccinated, @people_fully_vaccinated, 
 @new_vaccinations, @new_vaccinations_smoothed, @total_vaccinations_per_hundred, 
 @people_vaccinated_per_hundred, @people_fully_vaccinated_per_hundred, 
 @new_vaccinations_smoothed_per_million, @stringency_index, @population_density, @median_age, 
 @aged_65_older, @aged_70_older, @gdp_per_capita, @extreme_poverty, @cardiovasc_death_rate, 
 @diabetes_prevalence, @female_smokers, @male_smokers, @handwashing_facilities, 
 @hospital_beds_per_thousand, @life_expectancy, @human_development_index)
SET 
    new_tests = NULLIF(@new_tests, ''),
    total_tests = NULLIF(@total_tests, ''),
    total_tests_per_thousand = NULLIF(@total_tests_per_thousand, ''),
    new_tests_per_thousand = NULLIF(@new_tests_per_thousand, ''),
    new_tests_smoothed = NULLIF(@new_tests_smoothed, ''),
    new_tests_smoothed_per_thousand = NULLIF(@new_tests_smoothed_per_thousand, ''),
    positive_rate = NULLIF(@positive_rate, ''),
    tests_per_case = NULLIF(@tests_per_case, ''),
    total_vaccinations = NULLIF(@total_vaccinations, ''),
    people_vaccinated = NULLIF(@people_vaccinated, ''),
    people_fully_vaccinated = NULLIF(@people_fully_vaccinated, ''),
    new_vaccinations = NULLIF(@new_vaccinations, ''),
    new_vaccinations_smoothed = NULLIF(@new_vaccinations_smoothed, ''),
    total_vaccinations_per_hundred = NULLIF(@total_vaccinations_per_hundred, ''),
    people_vaccinated_per_hundred = NULLIF(@people_vaccinated_per_hundred, ''),
    people_fully_vaccinated_per_hundred = NULLIF(@people_fully_vaccinated_per_hundred, ''),
    new_vaccinations_smoothed_per_million = NULLIF(@new_vaccinations_smoothed_per_million, ''),
    stringency_index = NULLIF(@stringency_index, ''),
    population_density = NULLIF(@population_density, ''),
    median_age = NULLIF(@median_age, ''),
    aged_65_older = NULLIF(@aged_65_older, ''),
    aged_70_older = NULLIF(@aged_70_older, ''),
    gdp_per_capita = NULLIF(@gdp_per_capita, ''),
    extreme_poverty = NULLIF(@extreme_poverty, ''),
    cardiovasc_death_rate = NULLIF(@cardiovasc_death_rate, ''),
    diabetes_prevalence = NULLIF(@diabetes_prevalence, ''),
    female_smokers = NULLIF(@female_smokers, ''),
    male_smokers = NULLIF(@male_smokers, ''),
    handwashing_facilities = NULLIF(@handwashing_facilities, ''),
    hospital_beds_per_thousand = NULLIF(@hospital_beds_per_thousand, ''),
    life_expectancy = NULLIF(@life_expectancy, ''),
    human_development_index = NULLIF(@human_development_index, '');

-- Step 4: Finalize and Convert Dates
SET SQL_SAFE_UPDATES = 0;

-- This takes the clean DATE and turns it back into a specifically formatted string
UPDATE covid_staging_v1 
SET date = DATE_FORMAT(date_converted, '%d-%m-%Y');

SET SQL_SAFE_UPDATES = 1;

COMMIT;
SET autocommit = 1;
SET foreign_key_checks = 1;

-- Verification
SELECT location, date, date_converted FROM covid_staging_v1 LIMIT 10;
