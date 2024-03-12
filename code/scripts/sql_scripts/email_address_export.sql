--PROGRESSIVE FILTERING W/ CTEs
--3/11/24 - this script works but the results don't work great because they don't acccount for the
--many to one relationship of prospect_id's to prospects

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
--Filter 4: filtered_interactions
-- Getting prospect_ids from sequence_interactions that need to be excluded
excluded_prospects AS (
    SELECT DISTINCT pel.prospect_id
    FROM sequence_interactions si
    JOIN prospect_email_link pel ON si.email_id = pel.email_id
),
-- Getting all email_ids associated with the excluded prospects
excluded_emails AS (
    SELECT email_id
    FROM prospect_email_link
    WHERE prospect_id IN (SELECT prospect_id FROM excluded_prospects)
),
-- Filtering out all email_id's associated with the same prospect_id from the email_id that 
--appeared in the sequence_interactions table
filtered_interactions AS (
    SELECT fl.email_id
    FROM filtered_locations fl
    WHERE fl.email_id NOT IN (SELECT email_id FROM excluded_emails)
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
-- Filter 6 filtered_prospects
-- Selects prospect_id's associated with only 1 email_id
filtered_prospects AS (
    SELECT pel.prospect_id, MIN(pel.email_id) AS email_id  -- Using MIN() to ensure one email_id per prospect_id
    FROM prospect_email_link pel
    WHERE pel.email_id IN (SELECT email_id FROM filtered_emails)  -- Ensures we're only considering filtered email_ids
    GROUP BY pel.prospect_id
    HAVING COUNT(DISTINCT pel.email_id) = 1  -- Ensures each prospect_id is associated with exactly one email_id
),
-- Final Select for CSV Output
final_output AS (
    SELECT 
        p.name, 
        p.email, 
        p.average_rating, 
        ea.email_address, 
        fp.prospect_id, 
        l.city, 
        l.state
    FROM filtered_prospects fp
    INNER JOIN prospects p ON fp.prospect_id = p.prospect_id
    INNER JOIN email_addresses ea ON fp.email_id = ea.email_id
    INNER JOIN locations l ON fp.prospect_id = l.prospect_id
)

-- SELECT * FROM final_output;

\copy (SELECT * FROM final_output) TO '/Users/michaelgreen/Desktop/DESKTOP-TAVS9M6/Michael Orig/1-9/@3GD/Marketing/Email Marketing/B2B/Email Lists/cocv1_emails.csv' WITH CSV HEADER;


--simple filters
--email_ids with only one prospect_id
SELECT email_id
FROM prospect_email_link
GROUP BY email_id
HAVING COUNT(DISTINCT prospect_id) = 1;

--prospect_ids with only 1 email_id
SELECT prospect_id
FROM test
GROUP BY prospect_id
HAVING COUNT(DISTINCT email_id) = 1;

--works to export results

\copy (
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
        SELECT fc.email_id 
        FROM filtered_categories fc
        INNER JOIN locations l ON fc.prospect_id = l.prospect_id 
        WHERE l.state NOT IN ('AZ', 'CO', 'FL', 'AR', 'IL', 'IO', 'ME', 'UT', 'VT', 'WA')
        AND l.state IS NOT NULL
    ),
    excluded_prospects AS (
        SELECT DISTINCT pel.prospect_id
        FROM sequence_interactions si
        JOIN prospect_email_link pel ON si.email_id = pel.email_id
    ),
    excluded_emails AS (
        SELECT email_id
        FROM prospect_email_link
        WHERE prospect_id IN (SELECT prospect_id FROM excluded_prospects)
    ),
    filtered_interactions AS (
        SELECT fl.email_id
        FROM filtered_locations fl
        WHERE fl.email_id NOT IN (SELECT email_id FROM excluded_emails)
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
        SELECT pel.prospect_id, MIN(pel.email_id) AS email_id
        FROM prospect_email_link pel
        WHERE pel.email_id IN (SELECT email_id FROM filtered_emails)
        GROUP BY pel.prospect_id
        HAVING COUNT(DISTINCT pel.email_id) = 1
    ),
    final_output AS (
        SELECT 
            p.name, 
            p.email, 
            p.average_rating, 
            ea.email_address, 
            fp.prospect_id, 
            l.city, 
            l.state
        FROM filtered_prospects fp
        INNER JOIN prospects p ON fp.prospect_id = p.prospect_id
        INNER JOIN email_addresses ea ON fp.email_id = ea.email_id
        INNER JOIN locations l ON fp.prospect_id = l.prospect_id
    )
    SELECT * FROM final_output
) TO '/Users/michaelgreen/Desktop/DESKTOP-TAVS9M6/Michael Orig/1-9/@3GD/Marketing/Email Marketing/B2B/Email Lists/cocv1_emails.csv' WITH CSV HEADER;
