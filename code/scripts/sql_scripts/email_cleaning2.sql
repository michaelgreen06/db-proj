CREATE TEMP TABLE temp_deleted_emails AS
SELECT email_address
FROM email_addresses
WHERE email_address SIMILAR TO '%(@yourdomain\.com|@domain\.com|@yoursite\.com|\.gov|\.gov\.au|\.linktr\.ee|facebook\.com|instagram\.com|email\.com|\.us|kcmo\.org|\.edu|\.fda\.hhs|godaddy\.com)%';

-- Step 2: Delete the 