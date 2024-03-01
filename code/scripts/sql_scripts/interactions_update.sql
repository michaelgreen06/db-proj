--temp table to store info from snov 
CREATE TEMP TABLE temp_sequence_interactions (
    email_address VARCHAR(255),
    sequence_id INTEGER NOT NULL,
    sent_emails SMALLINT,
    email_opens SMALLINT,
    link_clicks SMALLINT,
    email_replies SMALLINT
);

--import data from CSV into temp table
--must update CSV file name for each campaign. EG COCV0 etc
COPY temp_sequence_interactions FROM '/Users/michaelgreen/Desktop/DESKTOP-TAVS9M6/Michael Orig/1-9/@3GD/Marketing/Email Marketing/B2B/sequence_interactions/cocv0.csv' DELIMITER ',' CSV HEADER;

INSERT INTO sequence_interactions (email_id, sequence_id, sent_emails, email_opens, link_clicks, email_replies)
SELECT
    pel.email_id,
    tmp.sequence_id, 
    tmp.sent_emails,
    tmp.email_opens,
    tmp.link_clicks,
    tmp.email_replies
FROM
    temp_sequence_interactions tmp
JOIN
    unique_emails ue ON ue.email_address = tmp.email_address
JOIN
    prospect_email_link pel ON pel.email_id = ue.email_id;