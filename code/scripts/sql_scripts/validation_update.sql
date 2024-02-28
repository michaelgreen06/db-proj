CREATE TEMP TABLE email_validation_temp (
    email_address VARCHAR(255),
    email_validated BOOLEAN,
    email_validation_date DATE,
    email_validation_status VARCHAR(255),
    email_source VARCHAR(255)
);

--import validation results into temp table
\COPY email_validation_temp(email_address, email_validated, email_validation_date, email_validation_status, email_source) FROM '/Users/michaelgreen/Desktop/DESKTOP-TAVS9M6/Michael Orig/1-9/@3GD/Marketing/Email Marketing/B2B/Email-verification/Results/email_validation1.csv' WITH CSV HEADER;

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