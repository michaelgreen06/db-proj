CREATE TABLE og_list_dedup (LIKE og_list_copy INCLUDING ALL);

ALTER TABLE og_list_copy
ADD CONSTRAINT id PRIMARY KEY (id);