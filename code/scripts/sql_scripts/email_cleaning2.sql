--deletes based on exacct criteria match
DELETE FROM email_addresses
WHERE email_address IN (
    'yourname@yoursite.com',
    'company-email@email.com',
    'email@email.com',
    'youremail@yourdomain.com',
    'contact@example.com',
    'your-email@domain.com',
    'yourname@email.com',
    'yourvoice@guitarcenter.com',
    'your.email@example.com',
    'joe@your-business.com',
    'hello@yourwebsite.com',
    'yourid@example.com',
    'example@example.com',
    'test@test.com',
    'admin@admin.com',
    'info@info.com',
    'noreply@domain.com',
    'user@domain.com',
    'contact@website.com',
    'dummy@dummy.com',
    'temp@temp.com',
    'fake@fake.com',
    'test@example.com',
    'username@domain.com',
    'webmaster@website.com',
    'mail@mail.com',
    'temp@email.com',
    'testuser@test.com',
    'anonymous@anonymous.com',
    'noemail@noemail.com',
    'placeholder@placeholder.com'
);

--creates a table of email addresses that will be deleted based on pattern matches of domain
--enables checking to ensure no proper emails are getting matched b4 deleting
CREATE TEMP TABLE temp_to_delete AS
SELECT email_address
FROM email_addresses
WHERE email_address SIMILAR TO '%(@yourdomain\.com|@domain\.com|@yoursite\.com|\.gov|\.gov\.au|\.linktr\.ee|facebook\.com|instagram\.com|kcmo\.org|\.edu|\.fda\.hhs|godaddy\.com)%';

--prints out email_addresses that will be deleted:
SELECT * FROM temp_to_delete;

--deletes email_addresses that appeared in print out
--!IMPORTANT! need to update the similar to string here if it's changed above
DELETE FROM email_addresses
WHERE email_address SIMILAR TO '%(@yourdomain\.com|@domain\.com|@yoursite\.com|\.gov|\.gov\.au|\.linktr\.ee|facebook\.com|instagram\.com|kcmo\.org|\.edu|\.fda\.hhs|godaddy\.com)%';
