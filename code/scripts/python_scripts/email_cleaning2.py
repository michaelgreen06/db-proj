#!/usr/bin/env python3

import psycopg2
from validate_email import validate_email

# Database connection parameters
db_params = {
    'dbname': 'smokeshops',
    'user': 'postgres',
    # 'password': '',
    'host': 'localhost',
    'port': '5432'
}


def validate_and_delete_emails():
    try:
        # Connect to the database
        conn = psycopg2.connect(**db_params)
        cur = conn.cursor()

        # Select all email addresses from the table
        cur.execute("SELECT email_id, email_address FROM email_addresses")
        emails = cur.fetchall()

        for email_id, email_address in emails:
            # Validate the email address
            is_valid = validate_email(email_address, verify=True)

            if not is_valid:
                # If the email is invalid, delete the entry
                cur.execute(
                    "DELETE FROM email_addresses WHERE email_id = %s", (email_id,))
                print(f"Deleted invalid email: {email_address}")

        # Commit the changes to the database
        conn.commit()

    except Exception as e:
        print(f"An error occurred: {e}")
        # Rollback in case of error
        conn.rollback()
    finally:
        # Close the cursor and connection
        cur.close()
        conn.close()


# Execute the function
validate_and_delete_emails()
