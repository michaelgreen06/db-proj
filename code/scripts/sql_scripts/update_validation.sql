--Step 1 - Export a list of all DISTINCT email_address's from email_addresses table where validation_status=Null
COPY (
    SELECT DISTINCT email_address
    FROM email_addresses
    WHERE email_validation_status IS NULL
--change CSV file name to today's date
) TO '/Users/michaelgreen/Desktop/DESKTOP-TAVS9M6/Michael Orig/1-9/@3GD/Marketing/Email Marketing/B2B/email_validation/to_validate/3_7_24a.csv' WITH CSV HEADER;

--step_2 run results through snov or other email address validation service
--step_3 copy paste validation results into .../1-9/@3GD/Marketing/Email Marketing/B2B/Email-verification/Results/all_results.csv

CREATE TEMP TABLE email_validation_temp (
    email_address VARCHAR(255),
    email_validated BOOLEAN,
    email_validation_date DATE,
    email_validation_status VARCHAR(255),
    email_source VARCHAR(255)
);

--step_4 import validation results into ^above^ temp table
--must format CSV headers to match format. EG Email Address to email_address etc
\COPY email_validation_temp(email_address, email_validated, email_validation_date, email_validation_status, email_source) FROM '/Users/michaelgreen/Desktop/DESKTOP-TAVS9M6/Michael Orig/1-9/@3GD/Marketing/Email Marketing/B2B/email_validation/Results/all_results.csv' WITH CSV HEADER;

--import results into email_addresses table
UPDATE email_addresses ea
SET
    email_validated = evt.email_validated,
    email_validation_date = evt.email_validation_date,
    email_validation_status = evt.email_validation_status,
    email_source = evt.email_source
FROM
    email_validation_temp evt
WHERE
    ea.email_address = evt.email_address;

--delete temp table
DROP TABLE email_validation_temp;


--deleting duplicate entries from all_results then saving them as a CSV
--hopefully this isn't necessary moving forward! Since we are selectign DISTINCT email_address's above
--not sure whether or not this script is fully intact & working
--Saving JUST IN CASE

-- Create a temporary table to hold CSV data
CREATE TEMP TABLE dedup_temp (
    email_address VARCHAR(255),
    email_validated BOOLEAN,
    email_validation_date DATE,
    email_validation_status VARCHAR(255),
    email_source VARCHAR(255)
);

-- Import data from CSV into the temporary deduplication table
\COPY dedup_temp(email_address, email_validated, email_validation_date, email_validation_status, email_source) FROM '/Users/michaelgreen/Desktop/DESKTOP-TAVS9M6/Michael Orig/1-9/@3GD/Marketing/Email Marketing/B2B/email_validation/Results/all_results.csv' WITH CSV HEADER;

-- Create another temporary table for deduplicated data
CREATE TEMP TABLE email_validation_temp AS
    SELECT DISTINCT
        email_address,
        email_validated,
        email_validation_date,
        email_validation_status,
        email_source
    FROM dedup_temp;

--save deduped data as CSV
COPY email_validation_temp TO '/Users/michaelgreen/Desktop/DESKTOP-TAVS9M6/Michael Orig/1-9/@3GD/Marketing/Email Marketing/B2B/email_validation/Results/all_results2.csv' WITH CSV HEADER;

-- Drop the temporary tables after use
DROP TABLE dedup_temp;
DROP TABLE email_validation_temp;
