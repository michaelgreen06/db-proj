--my script
CREATE TABLE email_addresses (
    email_id SERIAL PRIMARY KEY,
    prospect_id INTEGER NOT NULL,
    email_address VARCHAR(255),
    email_validated boolean,
    email_validation_date DATE,
    email_validation_status VARCHAR(255),
    email_source VARCHAR(255),
    unsubscribed boolean,
);

--gpt4's script

CREATE TABLE email_addresses (
    email_id SERIAL PRIMARY KEY,
    prospect_id INTEGER NOT NULL,
    email_address VARCHAR(255),
    email_validated BOOLEAN,
    email_validation_date DATE,
    email_validation_status VARCHAR(255),
    email_source VARCHAR(255),
    unsubscribed BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (prospect_id) REFERENCES prospects(prospect_id)
);



