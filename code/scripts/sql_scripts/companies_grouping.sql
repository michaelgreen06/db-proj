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



