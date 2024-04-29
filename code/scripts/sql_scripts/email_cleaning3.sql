--1). export a CSV of email_addresses to be evaluated. 
--next time include all email_addresses to be evaluated
COPY (
    SELECT DISTINCT email_address
    FROM email_addresses
    WHERE
        LOWER(email_address) NOT LIKE '%smoke%' AND
        LOWER(email_address) NOT LIKE '%vape%' AND
        LOWER(email_address) NOT LIKE '%tobacco%' AND
        LOWER(email_address) NOT LIKE '%smoking%' AND
        LOWER(email_address) NOT LIKE '%gmail%' AND
        LOWER(email_address) NOT LIKE '%yahoo%' AND
        LOWER(email_address) NOT LIKE '%outlook%' AND
        LOWER(email_address) NOT LIKE '%aol%' AND
        LOWER(email_address) NOT LIKE '%hotmail%' AND
        LOWER(email_address) NOT LIKE '%live%' AND
        LOWER(email_address) NOT LIKE '%icloud%' AND
        LOWER(email_address) NOT LIKE '%toke%' AND
        LOWER(email_address) NOT LIKE '%cigar%' AND
        LOWER(email_address) NOT LIKE '%hookah%' AND
        LOWER(email_address) NOT LIKE '%dispensary%' AND
        LOWER(email_address) NOT LIKE '%dispensaries%' AND
        LOWER(email_address) NOT LIKE '%me.com%' AND
        LOWER(email_address) NOT LIKE '%comcast%' AND
        LOWER(email_address) NOT LIKE '%420%' AND
        LOWER(email_address) NOT LIKE '%cannabis%' AND
        LOWER(email_address) NOT LIKE '%hemp%' AND
        LOWER(email_address) NOT LIKE '%vapor%' AND
        LOWER(email_address) NOT LIKE '%puff%' AND
        LOWER(email_address) NOT LIKE '%pipe%' AND
        LOWER(email_address) NOT LIKE '%msn%' AND
        LOWER(email_address) NOT LIKE '%joint%' AND
        LOWER(email_address) NOT LIKE '%cbd%' AND
        LOWER(email_address) NOT LIKE '%email.com%' AND
        LOWER(email_address) NOT LIKE '%protonmail.com%' AND
        LOWER(email_address) NOT LIKE '%att.com%' AND
        LOWER(email_address) NOT LIKE '%email.com%' AND
        LOWER(email_address) NOT LIKE '%foxmail.com%' AND
        LOWER(email_address) NOT LIKE '%bellsouth.net%' AND
        LOWER(email_address) NOT LIKE '%sbcglobal.net%' AND
        LOWER(email_address) NOT LIKE '%verizon.net%' AND
        LOWER(email_address) NOT LIKE '%att.net%' AND
        LOWER(email_address) NOT LIKE '%glass%'
) TO '/Users/michaelgreen/Desktop/DESKTOP-TAVS9M6/Michael Orig/1-9/@3GD/Marketing/Email Marketing/B2B/email_enrichment/4-17-24A.csv' WITH CSV HEADER;

--2). open the csv & save it as .xlsm and isolate the domain URLs by entering the following into Cell B2
-- =RIGHT(A2, LEN(A2) - FIND("@", A2))

--3). copy the domains & paste the values into a new sheet
--delete all duplicates

--4). copy domains & use ai to summarize them & provide keywords in CSV format. I used GPT4 & the results weren't perfect, but were good enough. I have a list of alternative summarizer options in the notion doc
--use this prompt:
-- Analyze the following list of URLs and return the URL and the associated keywords in CSV format. Return xxx (use however many URLs there are) results at a time
-- The results should look like this:
-- wawa.com, Convenience store chain, East Coast USA, fresh food, fuel services, coffee
-- cloud9dc.com, Cannabis dispensary, Washington D.C., recreational marijuana, delivery services
-- here is the list of URLS:

--5). paste the results into VSCode & save them as a txt file

--6). upload the results into the .xlsm file using the "get data" function under the data tab

--7). Run the below macro which leaves a list of irrelevant URLs whose associated email_addresses need to be Moved
    -- Sub DeleteRowsBasedOnKeywords()
    -- Dim ws As Worksheet
    -- Set ws = ActiveSheet ' Use your specific sheet name if necessary
    -- Dim LastRow As Long
    -- LastRow = ws.Cells(ws.Rows.Count, "B").End(xlUp).Row ' Check the last row based on column B

    -- Dim keywords As String
    -- keywords = "smoke, tobacco, pipe, headshop, cannabis, cbd, hemp, cigar, cigars, pipes, vape, smoking, email, dispensary, marijuana, vapes, vaping"

    -- Dim keywordArray As Variant
    -- keywordArray = Split(keywords, ", ")

    -- Dim cell As Range
    -- Dim found As Boolean
    -- Dim col As Long

    -- Application.ScreenUpdating = False
    -- Application.Calculation = xlCalculationManual

    -- For i = LastRow To 1 Step -1
    --     found = False
    --     For col = 2 To 9 ' Columns B to I
    --         For Each keyword In keywordArray
    --             If InStr(1, ws.Cells(i, col).Value, keyword, vbTextCompare) > 0 Then
    --                 found = True
    --                 Exit For
    --             End If
    --         Next keyword
    --         If found Then
    --             ws.Rows(i).Delete
    --             Exit For
    --         End If
    --     Next col
    -- Next i

    -- Application.ScreenUpdating = True
    -- Application.Calculation = xlCalculationAutomatic
    -- End Sub

--8). Move the email_addresses to the questionable_email_addresses table
--alternative approach would be to add a new status column in email_addresses table which IDs emails as questionable
--create the questionable_emails table
CREATE TABLE questionable_emails AS
SELECT *
FROM email_addresses
WHERE 1 = 0;

--create the temp table to store the list of domains
CREATE TEMP TABLE domain_list (
    domain_name VARCHAR(255)
);

--populate the domain_list temp table with domains from the CSV
\copy domain_list(domain_name) FROM '/Users/michaelgreen/Desktop/DESKTOP-TAVS9M6/Michael Orig/1-9/@3GD/Marketing/Email Marketing/B2B/email_enrichment/domains2delete.csv' CSV HEADER;

--move email_address's from email_addresses table that match the domains from the domain_list temp table
--then delete the transferred email_addresss from the original email_addresses table
BEGIN;

-- Insert into questionable_emails
INSERT INTO questionable_emails
SELECT *
FROM email_addresses
WHERE RIGHT(email_address, LENGTH(email_address) - POSITION('@' IN email_address)) IN (
    SELECT domain_name FROM domain_list
);

-- Delete from email_addresses
DELETE FROM email_addresses
WHERE RIGHT(email_address, LENGTH(email_address) - POSITION('@' IN email_address)) IN (
    SELECT domain_name FROM domain_list
);

COMMIT; --only use if successfull. if there is an error use ROLLBACK;

DROP TABLE domain_list; --cleans up temp table
