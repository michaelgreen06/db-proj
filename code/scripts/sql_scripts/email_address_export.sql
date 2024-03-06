--PROGRESSIVE FILTERING W/ CTEs

--Filter 1 valid_emails
WITH valid_emails AS (
    SELECT email_id
    FROM email_addresses
    WHERE email_validation_status = 'valid'
),
--Filter 2 filtered_categories
filtered_categories AS (
    SELECT ve.email_id, pel.prospect_id  -- Include prospect_id in the selection
    FROM valid_emails ve
    JOIN prospect_email_link pel ON ve.email_id = pel.email_id
    JOIN categories c ON pel.prospect_id = c.prospect_id
    WHERE c.category1 = 'Smoke shop' OR c.category1 = 'Tobacco shop'
),
--Filter 3 filtered_locations
filtered_locations AS(
    SELECT fc.email_id  -- Select email_id instead of prospect_id
    FROM filtered_categories fc
    INNER JOIN locations l ON fc.prospect_id = l.prospect_id  -- Use prospect_id for joining
    WHERE l.state NOT IN ('AZ', 'CO', 'FL', 'AR', 'IL', 'IO', 'ME', 'UT', 'VT', 'WA')
    AND l.state IS NOT NULL
)
SELECT fl.email_id  -- Select email_id from the final CTE
FROM filtered_locations fl
JOIN email_addresses ea ON fl.email_id = ea.email_id;  -- Join with email_addresses to get the email_address

--Filter 4 filtered_interactions

--Filter 5 filtered_emails
--selects prospect_ids only associated with one email address

--Filter 6 filtered_prospects
--selects email_ids associated with only one prospect_id