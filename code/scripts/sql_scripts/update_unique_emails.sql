INSERT INTO unique_emails (email_address)
SELECT DISTINCT email_address
FROM email_addresses
WHERE NOT EXISTS (
    SELECT 1
    FROM unique_emails
    WHERE unique_emails.email_address = email_addresses.email_address
);
