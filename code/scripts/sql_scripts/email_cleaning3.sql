--I will use a summarizer to get summaries of each email TLD and then will delete the ones that are releveant from the CSV
--the emails that stay on the CSV are irrelevant & I will use that CSV to upload to psql to say delete all entries w/ this 
--email_address from the email_addresses table
COPY (
    SELECT DISTINCT email_address
    FROM email_addresses
    WHERE
        email_validation_status = 'valid' AND
        LOWER(email_address) NOT LIKE '%smoke%' AND
        LOWER(email_address) NOT LIKE '%vape%' AND
        LOWER(email_address) NOT LIKE '%tobacco%' AND
        LOWER(email_address) NOT LIKE '%smoking%' AND
        LOWER(email_address) NOT LIKE '%gmail%' AND
        LOWER(email_address) NOT LIKE '%yahoo%' AND
        LOWER(email_address) NOT LIKE '%outlook%' AND
        LOWER(email_address) NOT LIKE '%aol%' AND
        LOWER(email_address) NOT LIKE '%hotmail%' AND
        LOWER(email_address) NOT LIKE '%live%' AND
        LOWER(email_address) NOT LIKE '%icloud%' AND
        LOWER(email_address) NOT LIKE '%toke%' AND
        LOWER(email_address) NOT LIKE '%cigar%' AND
        LOWER(email_address) NOT LIKE '%hookah%' AND
        LOWER(email_address) NOT LIKE '%dispensary%' AND
        LOWER(email_address) NOT LIKE '%dispensaries%' AND
        LOWER(email_address) NOT LIKE '%me.com%' AND
        LOWER(email_address) NOT LIKE '%comcast%' AND
        LOWER(email_address) NOT LIKE '%420%' AND
        LOWER(email_address) NOT LIKE '%cannabis%' AND
        LOWER(email_address) NOT LIKE '%hemp%' AND
        LOWER(email_address) NOT LIKE '%vapor%' AND
        LOWER(email_address) NOT LIKE '%puff%' AND
        LOWER(email_address) NOT LIKE '%pipe%' AND
        LOWER(email_address) NOT LIKE '%msn%' AND
        LOWER(email_address) NOT LIKE '%joint%' AND
        LOWER(email_address) NOT LIKE '%cbd%' AND
        LOWER(email_address) NOT LIKE '%glass%'
) TO '/Users/michaelgreen/Desktop/DESKTOP-TAVS9M6/Michael Orig/1-9/@3GD/Marketing/Email Marketing/B2B/email_enrichment/4-17-24A.csv' WITH CSV HEADER;