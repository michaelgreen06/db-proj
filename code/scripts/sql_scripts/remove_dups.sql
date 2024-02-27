--#5 removes duplicates based on a full match of all columns

WITH RankedDuplicates AS (
    SELECT
        prospect_id,
        ROW_NUMBER() OVER (
            PARTITION BY name, fulladdress, street, municipality, categories, plus_code, price, note, amenities, hotel_class, phone, phones, claimed, email, social_medias, review_count, average_rating, review_url, google_maps_url, google_knowledge_url, latitude, longitude, website, domain, opening_hours, featured_image, cid, place_id, kgmid
            ORDER BY prospect_id
        ) AS rn
    FROM
        og_list_copy
)
DELETE FROM
    og_list_copy
WHERE
    prospect_id IN (
        SELECT prospect_id FROM RankedDuplicates WHERE rn > 1
    );


--#6 removes duplicates based on name, fulladdress, phone, email & website

WITH RankedDuplicates AS (
    SELECT
        prospect_id,
        ROW_NUMBER() OVER (
            PARTITION BY name, fulladdress, phone, email, website
            ORDER BY prospect_id
        ) AS rn
    FROM
        og_list_copy
)
DELETE FROM
    og_list_copy
WHERE
    id IN (
        SELECT prospect_id FROM RankedDuplicates WHERE rn > 1
    );re

--TEST RESULTS
SELECT * FROM og_list_copy WHERE name = 'Wild Bill''s Tobacco';
SELECT * FROM og_list_copy WHERE name = 'Powered by G Maps Extractor';
