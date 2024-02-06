WITH DuplicateRows AS (
    SELECT
        ROW_NUMBER() OVER(
            PARTITION BY name, fulladdress, street, municipality, categories, plus_code, price, note, amenities, hotel_class, phone, phones, claimed, email, social_medias, review_count, average_rating, review_url, google_maps_url, google_knowledge_url, latitude, longitude, website, domain, opening_hours, featured_image, cid, place_id, kgmid
            ORDER BY (SELECT 0) 
        ) AS row_num
    FROM
        og_list
)
DELETE FROM
    og_list
WHERE
    ctid IN ( 
        SELECT ctid
        FROM DuplicateRows
        WHERE row_num > 1
    );

OG table = 18532
Remove duplicates = 