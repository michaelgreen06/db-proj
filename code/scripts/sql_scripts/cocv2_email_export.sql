--New Approach
--returns list of email_ids that ARE IN specific states
--This code is for all applicable stores that aren't Tobacco Shops or Smoke shops

WITH state_filtered AS (
    SELECT prospect_id
    FROM locations
    WHERE state IN ('AZ', 'CO', 'FL', 'AR', 'IL', 'IA', 'ME', 'UT', 'VT', 'WA')
), --2995
category_filtered AS (
    SELECT sf.prospect_id
    FROM state_filtered sf
    INNER JOIN categories c ON sf.prospect_id = c.prospect_id
    WHERE c.category1 IN ('Cigar shop', 'Hookah store', 'Vaporizer store', 'Glass shop','Cannabis store','Hydroponics equipment supplier','Herbal medicine store','Tobacco supplier','Adult entertainment store','Record store','Beer store','Glassware store','Hookah bar')
),--358
email_linked AS (
    SELECT DISTINCT pel.email_id
    FROM category_filtered cf
    INNER JOIN prospect_email_link pel ON cf.prospect_id = pel.prospect_id
),--23
email_count_filtered AS (
    SELECT DISTINCT el.email_id
    FROM email_linked el
    INNER JOIN neo4j n ON el.email_id = n.email_id
    GROUP BY el.email_id
    HAVING COUNT(n.prospect_id) BETWEEN 2 AND 5
),
validated_emails AS (
    SELECT DISTINCT ecf.email_id
    FROM email_count_filtered ecf
    INNER JOIN email_addresses ea ON ecf.email_id = ea.email_id
    WHERE ea.email_validation_status = 'valid'
),
email_addresses_resolved AS (
    SELECT vm.email_id, ue.email_address
    FROM validated_emails vm
    INNER JOIN unique_emails ue ON vm.email_id = ue.email_id
)
SELECT * FROM email_addresses_resolved;

--This code shows how to get a count from the above code instead of the actual email_ids
SELECT COUNT (*) AS validated_emails_count 
FROM validated_emails;

--returns list of valid email_ids that ARE NOT IN specific states
WITH state_filtered AS (
    SELECT prospect_id
    FROM locations
    WHERE state NOT IN ('AZ', 'CO', 'FL', 'AR', 'IL', 'IA', 'ME', 'UT', 'VT', 'WA')
), --2995
category_filtered AS (
    SELECT sf.prospect_id
    FROM state_filtered sf
    INNER JOIN categories c ON sf.prospect_id = c.prospect_id
    WHERE c.category1 IN ('Cigar shop', 'Hookah store', 'Vaporizer store', 'Glass shop','Cannabis store','Hydroponics equipment supplier','Herbal medicine store','Tobacco supplier','Adult entertainment store','Record store','Beer store','Glassware store','Hookah bar')
),--358
email_linked AS (
    SELECT DISTINCT pel.email_id
    FROM category_filtered cf
    INNER JOIN prospect_email_link pel ON cf.prospect_id = pel.prospect_id
),--23
email_count_filtered AS (
    SELECT DISTINCT el.email_id
    FROM email_linked el
    INNER JOIN neo4j n ON el.email_id = n.email_id
    GROUP BY el.email_id
    HAVING COUNT(n.prospect_id) BETWEEN 2 AND 5
),
validated_emails AS (
    SELECT DISTINCT ecf.email_id
    FROM email_count_filtered ecf
    INNER JOIN email_addresses ea ON ecf.email_id = ea.email_id
    WHERE ea.email_validation_status = 'valid'
),
email_addresses_resolved AS (
    SELECT vm.email_id, ue.email_address
    FROM validated_emails vm
    INNER JOIN unique_emails ue ON vm.email_id = ue.email_id
)
SELECT * FROM email_addresses_resolved;



-- CTE's with a progressive filter that focuses on prospect_id instead of email_id
-- 3/11/24 - used this script to export COCV1

--filter1: only include valid emails
--filter2: filter by category
--filter3: filter by location
--filter4: ensure they weren't in COCV0
--filter5: email_ids that are associated with 2 or 3 prospect_id's
--output email_address instead of email_id

--this code returns a count of all prospect_ids that don't show up in the neo4j table
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
filtered_locations AS (
    SELECT fc.prospect_id 
    FROM filtered_categories fc
    INNER JOIN locations l ON fc.prospect_id = l.prospect_id
    WHERE l.state NOT IN ('AZ', 'CO', 'FL', 'AR', 'IL', 'IA', 'ME', 'UT', 'VT', 'WA')
    AND l.state IS NOT NULL
)
SELECT COUNT(fl.prospect_id) AS missing_prospect_count
FROM filtered_locations fl
WHERE NOT EXISTS (
    SELECT 1
    FROM neo4j nt
    WHERE fl.prospect_id = nt.prospect_id
);



--new code:
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
    WHERE c.category1 = 'Cigar shop' OR c.category1 = 'Hookah store' OR c.category1 = 'Vaporizer store' OR c.category1 = 'Glass shop'
),
filtered_locations AS (
    SELECT fc.prospect_id 
    FROM filtered_categories fc
    INNER JOIN locations l ON fc.prospect_id = l.prospect_id
    WHERE l.state NOT IN ('AZ', 'CO', 'FL', 'AR', 'IL', 'IA', 'ME', 'UT', 'VT', 'WA')
    AND l.state IS NOT NULL
),
-- Adjusted Filter 4: filtered_email_ids using neo4j
filtered_email_ids AS (
    SELECT n.email_id
    FROM neo4j n
    INNER JOIN filtered_locations fl ON n.prospect_id = fl.prospect_id
    GROUP BY n.email_id
    HAVING COUNT(n.prospect_id) BETWEEN 2 AND 5
)
SELECT * FROM filtered_email_ids;



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
