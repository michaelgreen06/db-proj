#original code
#!/bin/bash

# DIRECTORY="/Users/michaelgreen/udemy/db-proj/data/us smoke shops/csv"
# DB_NAME="smokeshops"
# TABLE_NAME="og_list"

# COLUMNS="name, fulladdress, street, municipality, categories, plus_code, price, note, amenities, hotel_class, phone, phones, claimed, email, social_medias, review_count, average_rating, review_url, google_maps_url, google_knowledge_url, latitude, longitude, website, domain, opening_hours, featured_image, cid, place_id, kgmid"

# for filename in "$DIRECTORY"/*.csv; do
#     psql -d "$DB_NAME" -c "\copy $TABLE_NAME($COLUMNS) FROM '$filename' WITH DELIMITER ',' CSV HEADER;"
# done

# 2 new code that converts empty cells into Null
#!/bin/bash

# DIRECTORY="/Users/michaelgreen/udemy/db-proj/data/us smoke shops/csv"
# DB_NAME="smokeshops"
# TABLE_NAME="og_list"
# TMP_FILE="/tmp/csv_with_nulls.csv"  # Temporary file for processed CSV

# COLUMNS="name, fulladdress, street, municipality, categories, plus_code, price, note, amenities, hotel_class, phone, phones, claimed, email, social_medias, review_count, average_rating, review_url, google_maps_url, google_knowledge_url, latitude, longitude, website, domain, opening_hours, featured_image, cid, place_id, kgmid"

# for filename in "$DIRECTORY"/*.csv; do
#     # Replace empty fields with NULL
#     gawk 'BEGIN{FS=OFS=","} {for(i=1; i<=NF; i++) if($i=="") $i="NULL"} 1' "$filename" > "$TMP_FILE"

#     # Import the processed file
#     psql -d "$DB_NAME" -c "\copy $TABLE_NAME($COLUMNS) FROM '$TMP_FILE' WITH DELIMITER ',' CSV HEADER;"
# done

# # Cleanup temporary file
# rm "$TMP_FILE"


#3 New code to account for some cells have a space instead of being entirely empty

#!/bin/bash

# DIRECTORY="/Users/michaelgreen/udemy/db-proj/data/us smoke shops/csv"
# DB_NAME="smokeshops"
# TABLE_NAME="og_list"
# TMP_FILE="/tmp/csv_with_nulls.csv"  # Temporary file for processed CSV

# COLUMNS="name, fulladdress, street, municipality, categories, plus_code, price, note, amenities, hotel_class, phone, phones, claimed, email, social_medias, review_count, average_rating, review_url, google_maps_url, google_knowledge_url, latitude, longitude, website, domain, opening_hours, featured_image, cid, place_id, kgmid"

# for filename in "$DIRECTORY"/*.csv; do
#     # Replace empty fields and fields with only spaces with NULL
#     gawk 'BEGIN{FS=OFS=","} {for(i=1; i<=NF; i++) if($i=="" || $i~/^ +$/) $i="NULL"} 1' "$filename" > "$TMP_FILE"

#     # Import the processed file
#     psql -d "$DB_NAME" -c "\copy $TABLE_NAME($COLUMNS) FROM '$TMP_FILE' WITH DELIMITER ',' CSV HEADER;"
# done

# # Cleanup temporary file
# rm "$TMP_FILE"

#4
#!/bin/bash

# DIRECTORY="/Users/michaelgreen/udemy/db-proj/data/us smoke shops/csv"
# DB_NAME="smokeshops"
# TABLE_NAME="og_list"
# TMP_FILE="/tmp/csv_with_nulls.csv"  # Temporary file for processed CSV

# COLUMNS="name, fulladdress, street, municipality, categories, plus_code, price, note, amenities, hotel_class, phone, phones, claimed, email, social_medias, review_count, average_rating, review_url, google_maps_url, google_knowledge_url, latitude, longitude, website, domain, opening_hours, featured_image, cid, place_id, kgmid"

# for filename in "$DIRECTORY"/*.csv; do
#     # Replace empty fields and fields with only spaces with NULL
#     gawk 'BEGIN{FS=OFS=","} {for(i=1; i<=NF; i++) if($i=="" || $i~/^ +$/) $i=""} 1' "$filename" > "$TMP_FILE"


#     # Import the processed file
#     psql -d "$DB_NAME" -c "\copy $TABLE_NAME($COLUMNS) FROM '$TMP_FILE' WITH DELIMITER ',' CSV HEADER;"
# done

# # Cleanup temporary file
# rm "$TMP_FILE"


# 5 includes a log file that specifies which sheets are causing issues:

#!/bin/bash

DIRECTORY="/Users/michaelgreen/udemy/db-proj/data/us smoke shops/csv"
DB_NAME="smokeshops"
TABLE_NAME="og_list"
TMP_FILE="/tmp/csv_with_nulls.csv"  # Temporary file for processed CSV
LOG_FILE="/tmp/import_errors.log"  # File to log the errors

# Clear the log file at the beginning of the script run
> "$LOG_FILE"

COLUMNS="name, fulladdress, street, municipality, categories, plus_code, price, note, amenities, hotel_class, phone, phones, claimed, email, social_medias, review_count, average_rating, review_url, google_maps_url, google_knowledge_url, latitude, longitude, website, domain, opening_hours, featured_image, cid, place_id, kgmid"

for filename in "$DIRECTORY"/*.csv; do
    # Replace empty fields and fields with only spaces with NULL
    gawk 'BEGIN{FS=OFS=","} {for(i=1; i<=NF; i++) if($i=="" || $i~/^ +$/) $i=""} 1' "$filename" > "$TMP_FILE"

    # Import the processed file and capture errors
    if ! psql -d "$DB_NAME" -c "\copy $TABLE_NAME($COLUMNS) FROM '$TMP_FILE' WITH DELIMITER ',' CSV HEADER;" 2>>"$LOG_FILE"; then
        echo "Error importing file: $filename" >> "$LOG_FILE"
    fi
done

# Cleanup temporary file
rm "$TMP_FILE"

# Check if the log file is not empty and print a message
if [ -s "$LOG_FILE" ]; then
    echo "There were errors during the import. Please check the log file at $LOG_FILE"
else
    echo "All files were imported successfully."
fi

