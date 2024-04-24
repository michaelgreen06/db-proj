--if bu table already exists will have to drop it before creating backup (I think*)
--using LIKE means that constraints, indexes etc are also copied to the new table
CREATE TABLE prospect_email_link_bu (LIKE prospect_email_link INCLUDING ALL);
--insert puts the data from the original table into the new table
INSERT INTO prospect_email_link_bu SELECT * FROM prospect_email_link;


--this command copies the table without constraints
CREATE TABLE prospects AS TABLE og_list_copy;

