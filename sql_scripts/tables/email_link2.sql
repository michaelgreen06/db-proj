--table links email_id & prospect_id
CREATE TABLE prospect_email_association (
    association_id SERIAL PRIMARY KEY,
    email_id INTEGER NOT NULL,
    prospect_id INTEGER NOT NULL,
    CONSTRAINT fk_email_id FOREIGN KEY (email_id) REFERENCES email_addresses(email_id),
    CONSTRAINT fk_prospect_id FOREIGN KEY (prospect_id) REFERENCES prospects(prospect_id),
    UNIQUE(email_id, prospect_id) -- Ensures unique combinations of email_id and prospect_id
);