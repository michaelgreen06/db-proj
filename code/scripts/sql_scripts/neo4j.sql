--copy values from neo4j then put into excel & use find & replace to change [] to {}
--save as csv then open the csv in vs code, copy the content and save as a new csv file
--use the csv file saved from vscode to import into postgress because excel file causes errors

-- create table
CREATE TABLE neo4j (
    neo4j_id SERIAL PRIMARY KEY,
    company_id INTEGER,
    email_id INTEGER,
    prospect_id INTEGER,
    FOREIGN KEY (email_id) REFERENCES unique_emails(email_id),
    FOREIGN KEY (prospect_id) REFERENCES prospects(prospect_id)
);

--create temp table to intake data from neo4j
--when copying data from neo4j [] need to be replaced w/ {} using excel find & replace function
CREATE TEMP TABLE temp_data_load (
    company_id INTEGER,
    email_id INTEGER,
    prospect_ids INTEGER[]
);

--insert neo4j results w/ array values into temp table
COPY temp_data_load(company_id, email_id, prospect_ids)
FROM '/Users/michaelgreen/udemy/db-proj/scripts/code/scripts/sql_scripts/neo4j.csv' WITH (FORMAT csv, DELIMITER ',', ENCODING 'UTF8');

--insert flattened data into neo4j table
INSERT INTO neo4j (company_id, email_id, prospect_id)
SELECT
    company_id,
    email_id,
    unnest(prospect_ids)
FROM
    temp_data_load;

--return email_ids of companies w/ 2 or 3 prospects
SELECT email_id
FROM neo4j
GROUP BY email_id
HAVING COUNT(*) BETWEEN 2 AND 3;

--exports email_addresses of email_ids that appear 2 or 3 times to CSV
\COPY (
    SELECT ue.email_address
    FROM (
        SELECT email_id
        FROM neo4j
        GROUP BY email_id
        HAVING COUNT(*) BETWEEN 2 AND 3
    ) AS filtered_emails
    JOIN unique_emails ue ON filtered_emails.email_id = ue.email_id
) TO '/Users/michaelgreen/Desktop/DESKTOP-TAVS9M6/Michael Orig/1-9/@3GD/Marketing/Email Marketing/B2B/graph_db/email_addresses.csv' WITH CSV HEADER;

