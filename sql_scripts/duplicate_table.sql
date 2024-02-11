--using LIKE means that constraints, indexes etc are also copied to the new table
CREATE TABLE prospects (LIKE og_list_copy INCLUDING ALL);
--insert puts the data from the original table into the new table
INSERT INTO prospects SELECT * FROM og_list_copy;

--this command copies the table without constraints
CREATE TABLE prospects AS TABLE og_list_copy;

--rename id column to prospect_id
ALTER TABLE prospects RENAME COLUMN id TO prospect_id;

--clasissifying prospect_id as primary key
ALTER TABLE prospects
ADD CONSTRAINT prospect_id_pk PRIMARY KEY (prospect_id);

