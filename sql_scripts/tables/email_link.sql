--table to create relationship between email string and prospect_id
CREATE TABLE prospect_email_links (
    link_id SERIAL PRIMARY KEY,
    prospect_id INTEGER NOT NULL,
    email_address VARCHAR(255) NOT NULL,
    CONSTRAINT fk_prospect
        FOREIGN KEY (prospect_id) 
        REFERENCES prospects(prospect_id),
    CONSTRAINT unique_prospects_email UNIQUE (prospect_id, email_address)
);

--population script
DO $$
DECLARE
    record RECORD;
BEGIN
    -- Iterate through unique email addresses in the email_addresses table
    FOR record IN
        SELECT DISTINCT email_address, prospect_id
        FROM email_addresses
    LOOP
        -- Insert a new entry into the prospect_email_links table for each email_address and prospect_id pairing
        INSERT INTO prospect_email_link (prospect_id, email_address)
        VALUES (record.prospect_id, record.email_address)
        ON CONFLICT (prospect_id, email_address) DO NOTHING; -- Skip duplicates
    END LOOP;
END $$;

--query the email_addresses table directly to find email addresses that are only associated w/ 1 prospect_id
--only exports the email addresses
COPY (
    SELECT email_address
    FROM email_addresses
    GROUP BY email_address
    HAVING COUNT(DISTINCT prospect_id) = 1
) TO '/Users/michaelgreen/Desktop/DESKTOP-TAVS9M6/Michael Orig/1-9/@3GD/Marketing/Email Marketing/B2B/Email Lists/1_store_prospects.csv' WITH CSV HEADER;

--exports more info about the emails with one associated prospect_id.
--problem is it is exporting ALL email addresses
COPY (
    SELECT e.email_address, e.prospect_id, p.name, p.municipality, p.categories, p.average_rating, p.website
    FROM email_addresses e
    JOIN prospects p ON e.prospect_id = p.prospect_id
    GROUP BY e.email_address, e.prospect_id, p.name, p.municipality, p.categories, p.average_rating, p.website
    HAVING COUNT(DISTINCT e.prospect_id) = 1
) TO '/Users/michaelgreen/Desktop/DESKTOP-TAVS9M6/Michael Orig/1-9/@3GD/Marketing/Email Marketing/B2B/Email Lists/1_store_prospects.csv' WITH CSV HEADER;


--export code using email_address as filter criteria
COPY (
    WITH UniqueEmails AS (
        SELECT email_address, MIN(prospect_id) AS unique_prospect_id
        FROM email_addresses
        GROUP BY email_address
        HAVING COUNT(DISTINCT prospect_id) = 1
    )
    SELECT ue.email_address, ue.unique_prospect_id, p.name, p.municipality, p.categories, p.average_rating, p.website
    FROM UniqueEmails ue
    JOIN prospects p ON ue.unique_prospect_id = p.prospect_id
) TO '/Users/michaelgreen/Desktop/DESKTOP-TAVS9M6/Michael Orig/1-9/@3GD/Marketing/Email Marketing/B2B/Email Lists/1_store_prospects.csv' WITH CSV HEADER;

--same as above but only exporting valid email addresses
--may contain multiple email addresses for 1 prospect_id
--exported 1146
--works the best so far
COPY (
    WITH UniqueValidEmails AS (
        SELECT email_address, MIN(prospect_id) AS unique_prospect_id
        FROM email_addresses
        WHERE email_validation_status = 'valid'
        GROUP BY email_address
        HAVING COUNT(DISTINCT prospect_id) = 1
    )
    SELECT uve.email_address, uve.unique_prospect_id, p.name, p.municipality, p.categories, p.average_rating, p.website
    FROM UniqueValidEmails uve
    JOIN prospects p ON uve.unique_prospect_id = p.prospect_id
) TO '/Users/michaelgreen/Desktop/DESKTOP-TAVS9M6/Michael Orig/1-9/@3GD/Marketing/Email Marketing/B2B/Email Lists/1a_store_prospects.csv' WITH CSV HEADER;

--same as above but only exports the 1st email_address associated with a prospect_id
exported 2079
COPY (
    WITH FirstValidEmailPerProspect AS (
        SELECT DISTINCT ON (e.prospect_id) e.prospect_id, e.email_address
        FROM email_addresses e
        JOIN prospects p ON e.prospect_id = p.prospect_id
        WHERE e.email_validation_status = 'valid'
        ORDER BY e.prospect_id, e.email_id -- or e.email_validation_date, if you prefer
    )
    SELECT fvepp.email_address, fvepp.prospect_id, p.name, p.municipality, p.categories, p.average_rating, p.website
    FROM FirstValidEmailPerProspect fvepp
    JOIN prospects p ON fvepp.prospect_id = p.prospect_id
) TO '/Users/michaelgreen/Desktop/DESKTOP-TAVS9M6/Michael Orig/1-9/@3GD/Marketing/Email Marketing/B2B/Email Lists/1_store_prospects.csv' WITH CSV HEADER;

--exports 2079 email_address's the same email addresss appears multiple times
COPY (
    WITH FirstValidEmailPerProspect AS (
        SELECT DISTINCT ON (prospect_id) prospect_id, email_address
        FROM email_addresses
        WHERE email_validation_status = 'valid'
        ORDER BY prospect_id, email_address -- or any other column to determine the "first" email
    )
    SELECT fvepp.email_address, fvepp.prospect_id, p.name, p.municipality, p.categories, p.average_rating, p.website
    FROM FirstValidEmailPerProspect fvepp
    JOIN prospects p ON fvepp.prospect_id = p.prospect_id
) TO '/Users/michaelgreen/Desktop/DESKTOP-TAVS9M6/Michael Orig/1-9/@3GD/Marketing/Email Marketing/B2B/Email Lists/1_store_prospects.csv' WITH CSV HEADER;

--
COPY (
    WITH FirstValidEmailPerProspect AS (
        SELECT DISTINCT ON (prospect_id) prospect_id, email_address
        FROM email_addresses
        WHERE email_validation_status = 'valid'
        ORDER BY prospect_id, email_address -- Orders alphabetically to pick the first email
    )
    SELECT fvepp.email_address, fvepp.prospect_id, p.name, p.municipality, p.categories, p.average_rating, p.website
    FROM FirstValidEmailPerProspect fvepp
    JOIN prospects p ON fvepp.prospect_id = p.prospect_id
) TO '/Users/michaelgreen/Desktop/DESKTOP-TAVS9M6/Michael Orig/1-9/@3GD/Marketing/Email Marketing/B2B/Email Lists/unique1/unique1.csv' WITH CSV HEADER;
