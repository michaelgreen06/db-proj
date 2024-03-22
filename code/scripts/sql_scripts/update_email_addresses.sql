--use this to add email addresses to the email_addresses table after it has been created
COPY email_addresses(prospect_id, email_address)
FROM '/Users/michaelgreen/Desktop/DESKTOP-TAVS9M6/Michael Orig/1-9/@3GD/Marketing/Email Marketing/B2B/fb_scraping/results.csv' 
DELIMITER ',' CSV HEADER;

