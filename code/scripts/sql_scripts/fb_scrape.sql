--export a list of facebooke urls for prospects w/ no value in the email column
--works but returns each URL in {} which can be removed by running find & replace in excel
\COPY (
  SELECT 
    prospect_id,
    REGEXP_MATCHES(social_medias, '(https?://www.facebook.com/[^\s,]+)') AS facebook_url
  FROM 
    prospects
  WHERE 
    social_medias ILIKE '%facebook%' 
    AND (email = '' OR email IS NULL)
) TO '/Users/michaelgreen/Desktop/DESKTOP-TAVS9M6/Michael Orig/1-9/@3GD/Marketing/Email Marketing/B2B/fb_scraping/test_scrape1.csv' WITH CSV HEADER;



-- counting how many prospects w/no email_address have facebook url in social_medias column
-- it was 3913
  SELECT COUNT(*)
FROM prospects
WHERE 
  social_medias ILIKE '%facebook%' AND
  (email = '' OR email IS NULL);
