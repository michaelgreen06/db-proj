--my script
CREATE TABLE email_sequences(
    interaction_id SERIAL PRIMARY KEY,
    email_id INTEGER NOT NULL,
    sequence_id INTEGER NOT NULL,
    sent_date date,
    opened boolean,
    link_clicked boolean,
)

--gpt4's script
CREATE TABLE sequence_interactions (
    interaction_id SERIAL PRIMARY KEY,
    email_id INTEGER NOT NULL,
    sequence_id INTEGER NOT NULL,
    sent_date DATE,
    opened BOOLEAN,
    link_clicked BOOLEAN,
    FOREIGN KEY (email_id) REFERENCES email_addresses(email_id),
    FOREIGN KEY (sequence_id) REFERENCES email_sequences(sequence_id)
);

