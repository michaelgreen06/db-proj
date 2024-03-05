COPY (
    SELECT u.email_address
    FROM unique_emails u
    INNER JOIN email_addresses e ON u.email_id = e.email_id
    LEFT JOIN sequence_interactions si ON u.email_id = si.email_id
    INNER JOIN prospect_email_link pel ON u.email_id = pel.email_id
    INNER JOIN prospects p ON pel.prospect_id = p.prospect_id
    INNER JOIN categories c ON p.prospect_id = c.prospect_id
    INNER JOIN locations l ON p.prospect_id = l.prospect_id
    WHERE e.email_validation_status = 'valid'
    AND si.email_id IS NULL
    AND (c.category1 = 'smoke shop' OR c.category1 = 'tobacco shop')
    AND l.state NOT IN ('AZ', 'CO', 'FL', 'AR', 'Il', 'IO', 'ME', 'UT', 'VT', 'WA') AND l.state IS NOT NULL
    GROUP BY u.email_address
    HAVING COUNT(DISTINCT pel.prospect_id) = 1
) TO '/Users/michaelgreen/Desktop/DESKTOP-TAVS9M6/Michael Orig/1-9/@3GD/Marketing/Email Marketing/B2B/Email Lists/exported_file.csv' WITH CSV HEADER;
