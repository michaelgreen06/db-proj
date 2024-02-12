# sql code to update the email column in prospects to migrated after this code is run
# ALTER TABLE prospects ADD COLUMN emails_migrated BOOLEAN DEFAULT FALSE;
# UPDATE prospects SET emails_migrated = TRUE WHERE email IS NOT NULL AND email <> '';


#!/usr/bin/env python3

import psycopg2

# Database connection parameters
db_params = {
    'dbname': 'smokeshops',
    'user': 'postgres',
    # 'password': '',
    'host': 'localhost',
    'port': '5432',
}


def migrate_emails():
    try:
        # Connect to your PostgreSQL database
        conn = psycopg2.connect(**db_params)
        cur = conn.cursor()

        # Select prospect_id and email column from prospects table
        cur.execute("SELECT prospect_id, email FROM prospects")

        # Fetch all rows
        prospects = cur.fetchall()

        for prospect in prospects:
            prospect_id, emails = prospect
            if emails:  # Check if the email column is not empty
                # Split the emails string into a list
                email_list = emails.split(',')

                for email in email_list:
                    email = email.strip()  # Remove any leading/trailing whitespace
                    # Insert each email into the email_addresses table
                    cur.execute(
                        "INSERT INTO email_addresses (prospect_id, email_address) VALUES (%s, %s)",
                        (prospect_id, email)
                    )

        # Commit the transaction
        conn.commit()

    except Exception as e:
        print(f"An error occurred: {e}")
        # Optionally, roll back any changes if an error occurs
        conn.rollback()
    finally:
        # Close the cursor and connection
        cur.close()
        conn.close()


# Execute the migration function
migrate_emails()
