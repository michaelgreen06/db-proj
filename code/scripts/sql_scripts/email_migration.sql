-- updates the emails_migrated column in prospects to true if prospect had an email listed
 
 ALTER TABLE prospects ADD COLUMN emails_migrated BOOLEAN DEFAULT FALSE;
 UPDATE prospects SET emails_migrated = TRUE WHERE email IS NOT NULL AND email <> '';
