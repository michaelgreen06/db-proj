--chatgpt ccode:

CREATE TABLE email_addresses (
    email_id SERIAL PRIMARY KEY,
    prospect_id INTEGER NOT NULL,
    email_address VARCHAR(255),
    email_sequence INTEGER,
    CONSTRAINT fk_prospect
        FOREIGN KEY (prospect_id)
        REFERENCES prospects (prospect_id)
        ON DELETE CASCADE
);

--my modifications

CREATE TABLE email_addresses (
    email_id SERIAL PRIMARY KEY,
    prospect_id INTEGER NOT NULL,
    email_address VARCHAR(255),
    contacted boolean,
    contacted_date date,
    email_sequence INTEGER,
    opened_email boolean,
    CONSTRAINT fk_prospect
        FOREIGN KEY (prospect_id)
        REFERENCES prospects (prospect_id)
        ON DELETE CASCADE
);



