--PROGRESSIVE FILTERING W/ CTEs

--Filter 1 valid_emails
CREATE TEMP TABLE test AS 
WITH valid_emails AS (
    SELECT email_id
    FROM email_addresses
    WHERE email_validation_status = 'valid'
),
--Filter 2 filtered_categories
filtered_categories AS (
    SELECT ve.email_id, pel.prospect_id 
    FROM valid_emails ve
    JOIN prospect_email_link pel ON ve.email_id = pel.email_id
    JOIN categories c ON pel.prospect_id = c.prospect_id
    WHERE c.category1 = 'Smoke shop' OR c.category1 = 'Tobacco shop'
),
--Filter 3 filtered_locations
filtered_locations AS(
    SELECT fc.email_id 
    FROM filtered_categories fc
    INNER JOIN locations l ON fc.prospect_id = l.prospect_id 
    WHERE l.state NOT IN ('AZ', 'CO', 'FL', 'AR', 'IL', 'IO', 'ME', 'UT', 'VT', 'WA')
    AND l.state IS NOT NULL
),
--Filter 4 filtered_interactions
filtered_interactions AS (
    SELECT fl.email_id
    FROM filtered_locations fl
    LEFT JOIN sequence_interactions si ON fl.email_id = si.email_id
    WHERE si.email_id IS NULL
),
-- Filter 5 filtered_emails
-- selects email_ids associated with only one prospect_id
filtered_emails AS (
    SELECT fi.email_id
    FROM filtered_interactions fi
    JOIN (
        SELECT pel.email_id, COUNT(pel.prospect_id) AS prospect_count
        FROM prospect_email_link pel
        GROUP BY pel.email_id
        HAVING COUNT(pel.prospect_id) = 1
    ) pc ON fi.email_id = pc.email_id
),
--Filter 6 filtered_prospects
--selects prospect_ids associated with only one email_id
filtered_prospects AS (
    SELECT pel.prospect_id
    FROM prospect_email_link pel
    JOIN filtered_emails fe ON pel.email_id = fe.email_id
    GROUP BY pel.prospect_id
    HAVING COUNT(pel.email_id) = 1
)
SELECT fe.email_id,
       ea.email_address,
       p.email,
       p.name,
       p.average_rating,
       CONCAT(l.city, ', ', l.state, ' ', l.zipcode) AS location  -- Assuming you want a concatenated location string
FROM filtered_emails fe
JOIN email_addresses ea ON fe.email_id = ea.email_id
JOIN prospect_email_link pel ON ea.email_id = pel.email_id
JOIN prospects p ON pel.prospect_id = p.prospect_id
JOIN locations l ON p.prospect_id = l.prospect_id
ORDER BY fe.email_id ASC;

\COPY test TO '/Users/michaelgreen/Desktop/DESKTOP-TAVS9M6/Michael Orig/1-9/@3GD/Marketing/Email Marketing/B2B/Email Lists/test_output.csv' WITH CSV HEADER;


--simple filters
--email_ids with only one prospect_id
SELECT email_id
FROM prospect_email_link
GROUP BY email_id
HAVING COUNT(DISTINCT prospect_id) = 1;

--prospect_ids with only 1 email_id
SELECT prospect_id
FROM prospect_email_link
GROUP BY prospect_id
HAVING COUNT(DISTINCT email_id) = 1;


--updated attempt
CREATE TEMP TABLE test1 AS 
WITH valid_emails AS (
    SELECT email_id
    FROM email_addresses
    WHERE email_validation_status = 'valid'
),
filtered_categories AS (
    SELECT ve.email_id, pel.prospect_id 
    FROM valid_emails ve
    JOIN prospect_email_link pel ON ve.email_id = pel.email_id
    JOIN categories c ON pel.prospect_id = c.prospect_id
    WHERE c.category1 = 'Smoke shop' OR c.category1 = 'Tobacco shop'
),
filtered_locations AS(
    SELECT fc.email_id, fc.prospect_id
    FROM filtered_categories fc
    INNER JOIN locations l ON fc.prospect_id = l.prospect_id 
    WHERE l.state NOT IN ('AZ', 'CO', 'FL', 'AR', 'IL', 'IO', 'ME', 'UT', 'VT', 'WA')
    AND l.state IS NOT NULL
),
filtered_interactions AS (
    SELECT fl.email_id, fl.prospect_id
    FROM filtered_locations fl
    LEFT JOIN sequence_interactions si ON fl.email_id = si.email_id
    WHERE si.email_id IS NULL
),
filtered_emails AS (
    SELECT fi.email_id
    FROM filtered_interactions fi
    JOIN (
        SELECT pel.email_id, COUNT(pel.prospect_id) AS prospect_count
        FROM prospect_email_link pel
        GROUP BY pel.email_id
        HAVING COUNT(pel.prospect_id) = 1
    ) pc ON fi.email_id = pc.email_id
),
filtered_prospects AS (
    SELECT pel.prospect_id, pel.email_id
    FROM prospect_email_link pel
    JOIN filtered_emails fe ON pel.email_id = fe.email_id
    GROUP BY pel.prospect_id, pel.email_id
    HAVING COUNT(DISTINCT pel.email_id) = 1
)
SELECT fp.prospect_id, 
       fp.email_id,  -- Correctly reference the email_id from filtered_prospects
       p.email  -- Include the email column from the prospects table
FROM filtered_prospects fp
JOIN prospects p ON fp.prospect_id = p.prospect_id  -- Join with the prospects table to get the email
ORDER BY fp.prospect_id ASC;
