#!/usr/bin/env python3


# option 1: Delete Entries with Invalid Email Addresses
import psycopg2

# Database connection parameters
db_params = {
    'dbname': 'smokeshops',
    'user': 'postgres',
    # 'password': '',
    'host': 'localhost',
    'port': '5432',
}


def delete_invalid_emails():
    try:
        # Connect to your PostgreSQL database
        conn = psycopg2.connect(**db_params)
        cur = conn.cursor()

        # SQL query to delete entries with invalid email addresses
        delete_query = """
        DELETE FROM email_addresses
        WHERE email_address SIMILAR TO '%(@yourdomain\.com|@domain\.com|@yoursite\.com|\.gov|\.gov\.au|\.linktr\.ee|facebook\.com|instagram\.com)%'
        """
        cur.execute(delete_query)

        # Commit the changes
        conn.commit()
        print("Deleted invalid email addresses.")

    except Exception as e:
        print(f"An error occurred: {e}")
        conn.rollback()
    finally:
        cur.close()
        conn.close()


# Execute the function
delete_invalid_emails()
