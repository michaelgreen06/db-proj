CREATE TABLE sequence_interactions (
    interaction_id SERIAL PRIMARY KEY,
    email_id INTEGER NOT NULL,
    sequence_id INTEGER NOT NULL,
    sent_emails SMALLINT,
    email_opens SMALLINT,
    link_clicks SMALLINT,
    email_replies SMALLINT,
    FOREIGN KEY (email_id) REFERENCES unique_emails(email_id),
    FOREIGN KEY (sequence_id) REFERENCES email_sequences(sequence_id)
);