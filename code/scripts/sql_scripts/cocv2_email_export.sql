-- CTE's with a progressive filter that focuses on prospect_id instead of email_id
-- 3/11/24 - used this script to export COCV1

--filter1: only include valid emails
--filter2: filter by category
--filter3: filter by location
--filter4: ensure they weren't in COCV0
--filter5: email_ids that are associated with 2 or 3 prospect_id's
--output email_address instead of email_id




--Previous code:--

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
    WHERE c.category1 = 'Cigar shop' OR c.category1 = 'Hookah store' OR c.category1 = 'Vaporizer store' OR c.category1 = 'Glass shop'
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
--needs to use email_id at a min & should ideally use company_id (when it exists)
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
--filter 5 - needs to be finalized
--return email_ids of companies w/ 2 or 3 prospects
SELECT email_id
FROM neo4j
GROUP BY email_id
HAVING COUNT(*) BETWEEN 2 AND 3;

--filter6 - convert email_ids to email_addresses

SELECT p.name, p.email, p.average_rating, p.prospect_id, ea.email_address, l.city, l.state
FROM single_email_prospects sep
INNER JOIN prospects p ON sep.prospect_id = p.prospect_id
INNER JOIN email_addresses ea ON p.prospect_id = ea.prospect_id
INNER JOIN locations l ON p.prospect_id = l.prospect_id;

--change CSV name to correspond w/ campaign
\COPY test
 TO '/Users/michaelgreen/Desktop/DESKTOP-TAVS9M6/Michael Orig/1-9/@3GD/Marketing/Email Marketing/B2B/Email Lists/cocv2.csv' WITH CSV HEADER;

--test2
CREATE TEMP TABLE test AS 
WITH valid_prospect_ids AS (
    SELECT prospect_id
    FROM email_addresses
    WHERE email_validation_status = 'valid'
),
filtered_categories AS (
    SELECT vpi.prospect_id
    FROM valid_prospect_ids vpi
    INNER JOIN categories c ON vpi.prospect_id = c.prospect_id
    WHERE c.category1 IN ('Cigar shop', 'Hookah store', 'Vaporizer store', 'Glass shop')
),
filtered_locations AS(
    SELECT fc.prospect_id 
    FROM filtered_categories fc
    INNER JOIN locations l ON fc.prospect_id = l.prospect_id
    WHERE l.state NOT IN ('AZ', 'CO', 'FL', 'AR', 'IL', 'IA', 'ME', 'UT', 'VT', 'WA')
    AND l.state IS NOT NULL
),
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
-- Adjusted Filter 5 to use neo4j table
filtered_email_ids AS (
    SELECT nj.email_id
    FROM neo4j nj
    INNER JOIN unemailed_prospects up ON nj.prospect_id = up.prospect_id
    GROUP BY nj.email_id
    HAVING COUNT(nj.prospect_id) BETWEEN 2 AND 3
),
final_selection AS (
    SELECT 
        p.name, 
        p.email, 
        p.average_rating, 
        p.prospect_id, 
        ue.email_address, 
        ue.email_id,
        l.city, 
        l.state
    FROM 
        filtered_email_ids fei
        INNER JOIN neo4j nj ON fei.email_id = nj.email_id
        INNER JOIN prospects p ON nj.prospect_id = p.prospect_id
        INNER JOIN unique_emails ue ON nj.email_id = ue.email_id
        INNER JOIN locations l ON p.prospect_id = l.prospect_id
)
SELECT * FROM final_selection;


\COPY test
 TO '/Users/michaelgreen/Desktop/DESKTOP-TAVS9M6/Michael Orig/1-9/@3GD/Marketing/Email Marketing/B2B/Email Lists/cocv2a.csv' WITH CSV HEADER;
