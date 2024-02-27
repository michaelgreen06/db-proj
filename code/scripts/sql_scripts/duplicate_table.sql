--using LIKE means that constraints, indexes etc are also copied to the new table
CREATE TABLE email_addresses_bu (LIKE email_addresses INCLUDING ALL);
--insert puts the data from the original table into the new table
INSERT INTO email_addresses_bu SELECT * FROM email_addresses;

--this command copies the table without constraints
CREATE TABLE prospects AS TABLE og_list_copy;

