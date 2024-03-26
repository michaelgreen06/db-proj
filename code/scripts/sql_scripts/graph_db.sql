--export PEL to CSV
COPY prospect_email_link TO '/Users/michaelgreen/Desktop/DESKTOP-TAVS9M6/Michael Orig/1-9/@3GD/Marketing/Email Marketing/B2B/prospect_email_link.csv' DELIMITER ',' CSV HEADER;

LOAD CSV WITH HEADERS FROM 'file:/Users/michaelgreen/prospect_email_link.csv' AS row
MERGE (p:Prospect {id: toInteger(row.prospect_id)})
MERGE (e:Email {id: toInteger(row.email_id)})
MERGE (p)-[:HAS_EMAIL]->(e);
