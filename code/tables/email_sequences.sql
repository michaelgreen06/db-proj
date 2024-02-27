--gpt4's script

CREATE TABLE email_sequences (
    sequence_id SERIAL PRIMARY KEY,
    sequence_name VARCHAR(255),
    description TEXT,
    target_segment VARCHAR(255),
    first_send_date DATE
);
