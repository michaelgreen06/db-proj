--list prospect_ids that have names with matching 1st 3 words
SELECT
  LOWER(
    TRIM(SPLIT_PART(name, ' ', 1)) || ' ' ||
    TRIM(SPLIT_PART(name, ' ', 2)) || ' ' ||
    TRIM(SPLIT_PART(name, ' ', 3))
  ) AS first_three_words,
  ARRAY_AGG(prospect_id) AS prospect_ids
FROM
  prospects
GROUP BY
  first_three_words
ORDER BY
  first_three_words;

--create companies table and fill it based on email_id

-- Assuming the companies table has been created as follows:
CREATE TABLE companies (
    company_id SERIAL PRIMARY KEY,
    name VARCHAR(255),
    email_id INTEGER UNIQUE,
    CONSTRAINT fk_unique_email
        FOREIGN KEY(email_id) 
	        REFERENCES unique_emails(email_id)
);

-- Insert entries for email_ids associated with multiple prospect_ids
INSERT INTO companies (name, email_id)
SELECT LEFT(STRING_AGG(p.name, '; '), 100) AS company_name, pel.email_id
FROM prospect_email_link pel
JOIN prospects p ON pel.prospect_id = p.prospect_id
GROUP BY pel.email_id
HAVING COUNT(pel.prospect_id) > 1;

-- Insert entries for email_ids associated with a single prospect_id
--doing stuff
INSERT INTO companies (name, email_id)
SELECT p.name, pel.email_id
FROM prospect_email_link pel
JOIN prospects p ON pel.prospect_id = p.prospect_id
LEFT JOIN companies c ON c.email_id = pel.email_id
WHERE c.company_id IS NULL
GROUP BY pel.email_id, p.name
HAVING COUNT(pel.prospect_id) = 1;

--cypher code
--returns a list of prospect_id's associated with each email_id
MATCH (p:Prospect)-[:HAS_EMAIL]->(e:Email)
WITH e, COLLECT(p) AS prospects
WHERE SIZE(prospects) > 1
WITH e, prospects, SIZE(prospects) AS size
UNWIND prospects AS prospect
MATCH (prospect)-[:HAS_EMAIL]->(e2:Email)
WITH e, prospect, COLLECT(e2) AS emails, size
WHERE SIZE(emails) = 1
WITH e, COLLECT(prospect) AS uniqueProspects, size
WHERE SIZE(uniqueProspects) = size
RETURN e.id AS email_id, [p IN uniqueProspects | p.id] AS shared_prospects

--cypher code
--same as above but includes relationships so the visualizer can be used
MATCH (p:Prospect)-[r:HAS_EMAIL]->(e:Email)
WITH e, COLLECT(p) AS prospects, COLLECT(r) AS relationships
WHERE SIZE(prospects) > 1
WITH e, prospects, relationships, SIZE(prospects) AS size
UNWIND prospects AS prospect
MATCH (prospect)-[r2:HAS_EMAIL]->(e2:Email)
WITH e, prospect, COLLECT(e2) AS emails, size, relationships
WHERE SIZE(emails) = 1
WITH e, COLLECT(prospect) AS uniqueProspects, size, relationships
WHERE SIZE(uniqueProspects) = size
RETURN e, uniqueProspects, relationships



