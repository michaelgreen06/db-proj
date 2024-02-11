-- #1 deleted all data in my table 

-- WITH DuplicateRows AS (
--     SELECT
--         ROW_NUMBER() OVER(
--             PARTITION BY name, fulladdress, street, municipality, categories, plus_code, price, note, amenities, hotel_class, phone, phones, claimed, email, social_medias, review_count, average_rating, review_url, google_maps_url, google_knowledge_url, latitude, longitude, website, domain, opening_hours, featured_image, cid, place_id, kgmid
--             ORDER BY (SELECT 0) 
--         ) AS row_num
--     FROM
--         og_list
-- )
-- DELETE FROM
--     og_list
-- WHERE
--     ctid IN ( 
--         SELECT ctid
--         FROM DuplicateRows
--         WHERE row_num > 1
--     );

--#2 didn't delete anything!
-- BEGIN;
-- WITH cte AS (
--   SELECT DISTINCT ON (name, fulladdress, street, municipality, categories, plus_code, price, note, amenities, hotel_class, phone, phones, claimed, email, social_medias, review_count, average_rating, review_url, google_maps_url, google_knowledge_url, latitude, longitude, website, domain, opening_hours, featured_image, cid, place_id, kgmid)
--     *
--   FROM
--     og_list_copy
--   ORDER BY
--     name, fulladdress, street, municipality, categories, plus_code, price, note, amenities, hotel_class, phone, phones, claimed, email, social_medias, review_count, average_rating, review_url, google_maps_url, google_knowledge_url, latitude, longitude, website, domain, opening_hours, featured_image, cid, place_id, kgmid, ctid
-- )
-- DELETE FROM og_list_copy
-- WHERE ctid NOT IN (SELECT ctid FROM cte);

--#3 didn't work because NULL values are considered unique in postgres
-- WITH DuplicateRows AS (
--     SELECT MIN(id) as keep_id
--     FROM og_list_copy
--     GROUP BY name, fulladdress, street, municipality, categories, plus_code, price, note, amenities, hotel_class, phone, phones, claimed, email, social_medias, review_count, average_rating, review_url, google_maps_url, google_knowledge_url, latitude, longitude, website, domain, opening_hours, featured_image, cid, place_id, kgmid
--     HAVING COUNT(*) > 1
-- )
-- DELETE FROM og_list_copy
-- WHERE id NOT IN (SELECT keep_id FROM DuplicateRows) AND (name, fulladdress, street, municipality, categories, plus_code, price, note, amenities, hotel_class, phone, phones, claimed, email, social_medias, review_count, average_rating, review_url, google_maps_url, google_knowledge_url, latitude, longitude, website, domain, opening_hours, featured_image, cid, place_id, kgmid) IN (
--     SELECT name, fulladdress, street, municipality, categories, plus_code, price, note, amenities, hotel_class, phone, phones, claimed, email, social_medias, review_count, average_rating, review_url, google_maps_url, google_knowledge_url, latitude, longitude, website, domain, opening_hours, featured_image, cid, place_id, kgmid
--     FROM og_list_copy
--     GROUP BY name, fulladdress, street, municipality, categories, plus_code, price, note, amenities, hotel_class, phone, phones, claimed, email, social_medias, review_count, average_rating, review_url, google_maps_url, google_knowledge_url, latitude, longitude, website, domain, opening_hours, featured_image, cid, place_id, kgmid
--     HAVING COUNT(*) > 1
-- );

--#4 might work! Haven't tried yet!
-- WITH DuplicateRows AS (
--     SELECT MIN(id) as keep_id
--     FROM og_list_copy
--     GROUP BY name, fulladdress, street, municipality, categories, plus_code, price, note, amenities, hotel_class, phone, phones, claimed, email, social_medias, review_count, average_rating, review_url, google_maps_url, google_knowledge_url, latitude, longitude, website, domain, opening_hours, featured_image, cid, place_id, kgmid
--     HAVING COUNT(*) > 1

-- DELETE FROM og_list_copy
-- WHERE id NOT IN (
--     SELECT MIN(id)
--     FROM og_list_copy
--     GROUP BY COALESCE(name, 'NULL'), COALESCE(fulladdress, 'NULL'), COALESCE(street, 'NULL'), COALESCE(municipality, 'NULL'), COALESCE(categories, 'NULL'), COALESCE(plus_code, 'NULL'), COALESCE(price, 'NULL'), COALESCE(note, 'NULL'), COALESCE(amenities, 'NULL'), COALESCE(hotel_class, 'NULL'), COALESCE(phone, 'NULL'), COALESCE(phones, 'NULL'), COALESCE(claimed, 'NULL'), COALESCE(email, 'NULL'), COALESCE(social_medias, 'NULL'), COALESCE(review_count, 'NULL'), COALESCE(average_rating, 'NULL'), COALESCE(review_url, 'NULL'), COALESCE(google_maps_url, 'NULL'), COALESCE(google_knowledge_url, 'NULL'), COALESCE(latitude, 'NULL'), COALESCE(longitude, 'NULL'), COALESCE(website, 'NULL'), COALESCE(domain, 'NULL'), COALESCE(opening_hours, 'NULL'), COALESCE(featured_image, 'NULL'), COALESCE(cid, 'NULL'), COALESCE(place_id, 'NULL'), COALESCE(kgmid, 'NULL')
-- );

--#5 removed 3015 duplicates but many still remain

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


--#6 modified to compare by fewer characteristics (I think these scripts work!)

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

--TESTING RESULTS
SELECT * FROM og_list_copy WHERE name = 'Wild Bill''s Tobacco';
SELECT * FROM og_list_copy WHERE name = 'Powered by G Maps Extractor';

-- OG table = 18532
-- Remove duplicates = 3015