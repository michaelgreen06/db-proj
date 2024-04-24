--Run this code if entries were added to email_addresses table
INSERT INTO prospect_email_link (prospect_id, email_id)
SELECT DISTINCT e.prospect_id, ue.email_id
FROM email_addresses e
JOIN unique_emails ue ON e.email_address = ue.email_address
WHERE NOT EXISTS (
    SELECT 1 FROM prospect_email_link pel
    WHERE pel.prospect_id = e.prospect_id AND pel.email_id = ue.email_id
);

--run this code if entries were removed from email_addresses table & should be removed from PEL table
--backup table 1st!
--this happened when entries were migrated to the questionable_emails table
DELETE FROM prospect_email_link
WHERE email_id NOT IN (
    SELECT email_id FROM email_addresses
);