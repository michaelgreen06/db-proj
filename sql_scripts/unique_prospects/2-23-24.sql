--adding prospect_count column to email_addresses table
ALTER TABLE email_addresses ADD COLUMN prospect_count INT;
--adding values to prospect_count column
UPDATE email_addresses
SET prospect_count = sub.prospect_count
FROM (
    SELECT email_address, COUNT(prospect_id) AS prospect_count
    FROM email_addresses
    GROUP BY email_address
) AS sub
WHERE email_addresses.email_address = sub.email_address;

--exporting a csv of email_address'es where prospect count=1
--if prospect_id is associated with mutliple email_address'es w/ prospect count=1
--it exports the first email address (in alphabetical order)
--to get 2nd email address change rn=2
COPY (
    WITH RankedEmails AS (
        SELECT 
            email_address, 
            prospect_id, 
            ROW_NUMBER() OVER (
                PARTITION BY prospect_id 
                ORDER BY email_address
            ) AS rn
        FROM email_addresses
        WHERE prospect_count = 1
    )
    SELECT 
        email_address, 
        prospect_id
    FROM RankedEmails
    WHERE rn = 4
) TO '/Users/michaelgreen/Desktop/DESKTOP-TAVS9M6/Michael Orig/1-9/@3GD/Marketing/Email Marketing/B2B/Email Lists/unique4.csv' WITH CSV HEADER;

--^^this above script works! Now I need to modify to export more of the prospect details that can be imported
--into snov so I can have more personalization information about the prospects