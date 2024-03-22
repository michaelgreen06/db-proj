INSERT INTO prospect_email_link (prospect_id, email_id)
SELECT DISTINCT e.prospect_id, ue.email_id
FROM email_addresses e
JOIN unique_emails ue ON e.email_address = ue.email_address
WHERE NOT EXISTS (
    SELECT 1 FROM prospect_email_link pel
    WHERE pel.prospect_id = e.prospect_id AND pel.email_id = ue.email_id
);
