--change the c.category1 name to export lists for different types of stores
COPY (
    SELECT
        p.prospect_id,
        p.name,
        p.phone,
        p.municipality,
        p.review_count,
        p.average_rating,
        p.website,
        p.opening_hours
    FROM
        prospects p
    INNER JOIN
        categories c ON p.prospect_id = c.prospect_id
    WHERE
        p.email IS NULL
        AND c.category1 = 'Smoke shop'
) TO '/Users/michaelgreen/Desktop/DESKTOP-TAVS9M6/Michael Orig/1-9/@3GD/Marketing/Email Marketing/B2B/Call Lists/smoke_shops.csv' WITH CSV HEADER;

COPY (
    SELECT
        p.prospect_id,
        p.name,
        p.phone,
        l.city,
        l.state,
        l.zipcode,
        p.review_count,
        p.average_rating,
        p.website,
        p.opening_hours
    FROM
        prospects p
    INNER JOIN
        locations l ON p.prospect_id = l.prospect_id
    INNER JOIN
        categories c ON p.prospect_id = c.prospect_id
    WHERE
        p.email IS NULL
        AND p.phone IS NOT NULL
        AND c.category1 = 'Smoke shop'
) TO '/Users/michaelgreen/Desktop/DESKTOP-TAVS9M6/Michael Orig/1-9/@3GD/Marketing/Email Marketing/B2B/Call Lists/smoke_shops1.csv' WITH CSV HEADER ENCODING 'UTF8';
