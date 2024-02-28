-- Step 1: Create a Temporary Table for Distinct Email Addresses
CREATE TEMP TABLE emails AS
SELECT DISTINCT email_address
FROM email_addresses;

-- Step 2: (Automatically handled by Step 1)

-- Step 3: Create the `unique_emails` Table
CREATE TABLE unique_emails (
    email_id SERIAL PRIMARY KEY,
    email_address VARCHAR(255) NOT NULL
);

-- Step 4: Insert Data into `unique_emails` Table
INSERT INTO unique_emails (email_address)
SELECT email_address
FROM emails;
 
-- Step 5: Create the `prospect_email_link` Table
CREATE TABLE prospect_email_link (
    link_id SERIAL PRIMARY KEY,
    prospect_id INTEGER NOT NULL,
    email_id INTEGER NOT NULL,
    FOREIGN KEY (prospect_id) REFERENCES prospects(prospect_id),
    FOREIGN KEY (email_id) REFERENCES unique_emails(email_id)
);

-- Step 6: Populate the `prospect_email_link` Table
INSERT INTO prospect_email_link (prospect_id, email_id)
SELECT ea.prospect_id, ue.email_id
FROM email_addresses ea
JOIN unique_emails ue ON ea.email_address = ue.email_address;

--2-27-24 ^^^this above code could need fixing because I chnanged the table names and am not sure 
--I didn't miss any renaming. it should be an easy fix if there is a prob!
