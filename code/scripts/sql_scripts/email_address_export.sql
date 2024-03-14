-- CTE's with a progressive filter that focuses on prospect_id instead of email_id
-- 3/11/24 - used this script to export COCV2

--Filter 1 valid_emails
CREATE TEMP TABLE test AS 
WITH valid_prospect_ids AS (
    SELECT prospect_id
    FROM email_addresses
    WHERE email_validation_status = 'valid'
),
--Filter 2 filtered_categories
filtered_categories AS (
    SELECT vpi.prospect_id
    FROM valid_prospect_ids vpi
    INNER JOIN categories c ON vpi.prospect_id = c.prospect_id
    WHERE c.category1 = 'Smoke shop' OR c.category1 = 'Tobacco shop'
),
--Filter 3 filtered_locations
filtered_locations AS(
    SELECT fc.prospect_id 
    FROM filtered_categories fc
    INNER JOIN locations l ON fc.prospect_id = l.prospect_id
    WHERE l.state NOT IN ('AZ', 'CO', 'FL', 'AR', 'IL', 'IA', 'ME', 'UT', 'VT', 'WA')
    AND l.state IS NOT NULL
),
--Filter 4 unemailed_prospects
unemailed_prospects AS (
    SELECT fl.prospect_id
    FROM filtered_locations fl
    WHERE NOT EXISTS (
        SELECT 1
        FROM prospect_email_link pel
        INNER JOIN sequence_interactions si ON pel.email_id = si.email_id
        WHERE pel.prospect_id = fl.prospect_id
    )
),
--Filter 5 exclude_shared_emails
exclude_shared_emails AS (
    SELECT up.prospect_id
    FROM unemailed_prospects up
    WHERE NOT EXISTS (
        SELECT 1
        FROM prospect_email_link pel
        WHERE pel.email_id IN (
            -- Subquery to find email_ids associated with more than one prospect_id
            SELECT email_id
            FROM prospect_email_link
            GROUP BY email_id
            HAVING COUNT(DISTINCT prospect_id) > 1
        )
        AND pel.prospect_id = up.prospect_id
    )
),
--Filter 6 single_email_prospects
single_email_prospects AS (
    SELECT eep.prospect_id
    FROM exclude_shared_emails eep
    WHERE EXISTS (
        SELECT 1
        FROM (
            SELECT prospect_id
            FROM prospect_email_link
            GROUP BY prospect_id
            HAVING COUNT(DISTINCT email_id) = 1
        ) AS single_email
        WHERE single_email.prospect_id = eep.prospect_id
    )
)

SELECT p.name, p.email, p.average_rating, p.prospect_id, ea.email_address, l.city, l.state
FROM single_email_prospects sep
INNER JOIN prospects p ON sep.prospect_id = p.prospect_id
INNER JOIN email_addresses ea ON p.prospect_id = ea.prospect_id
INNER JOIN locations l ON p.prospect_id = l.prospect_id;

--change CSV name to correspond w/ campaign
\COPY test
 TO '/Users/michaelgreen/Desktop/DESKTOP-TAVS9M6/Michael Orig/1-9/@3GD/Marketing/Email Marketing/B2B/Email Lists/cocv2.csv' WITH CSV HEADER;


