SELECT LOWER(
  TRIM(SPLIT_PART(name, ' ', 1)) || ' ' ||
  TRIM(SPLIT_PART(name, ' ', 2)) || ' ' ||
  TRIM(SPLIT_PART(name, ' ', 3)) AS first_three_words,
  ARRAY_AGG(prospect_id) AS prospect_ids
)

FROM
  prospects
GROUP BY
  first_three_words
ORDER BY
  first_three_words;


-- counting how many prospects w/no email_address have facebook url in social_medias column
-- it was 3913
  SELECT COUNT(*)
FROM prospects
WHERE 
  social_medias ILIKE '%facebook%' AND
  (email = '' OR email IS NULL);

--export a list of facebooke urls for prospects w/ no value in the email column
\COPY (
  SELECT 
    prospect_id,
    REGEXP_MATCHES(social_medias, '(https?://www.facebook.com/[^\s,]+)') AS facebook_url
  FROM 
    prospects
  WHERE 
    social_medias ILIKE '%facebook%' 
    AND (email = '' OR email IS NULL)
) TO '/Users/michaelgreen/Desktop/DESKTOP-TAVS9M6/Michael Orig/1-9/@3GD/Marketing/Email Marketing/B2B/fb_scraping/test_scrape.csv' WITH CSV HEADER;