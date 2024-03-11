CREATE TABLE email_addresses (
    address_id SERIAL PRIMARY KEY,
    prospect_id INTEGER NOT NULL,
    email_id INTEGER NOT NULL,
    email_address VARCHAR(255),
    email_validated BOOLEAN,
    email_validation_date DATE,
    email_validation_status VARCHAR(255),
    email_source VARCHAR(255),
    unsubscribed BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (prospect_id) REFERENCES prospects(prospect_id),
    FOREIGN KEY (email_id) REFERENCES unique_emails(email_id)
);