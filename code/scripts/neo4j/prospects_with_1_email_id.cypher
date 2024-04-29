--produces a table of results of email_ids that are associated w/ only 1 prospect_id
--changing WHERE SIZE(prospects) > 0 defines how many prospects are associated w/ the email_id
MATCH (p:Prospect)-[:HAS_EMAIL]->(e:Email)
WITH e, COLLECT(p) AS prospects
WHERE SIZE(prospects) > 0
WITH e, prospects, SIZE(prospects) AS size
UNWIND prospects AS prospect
MATCH (prospect)-[:HAS_EMAIL]->(e2:Email)
WITH e, prospect, COLLECT(e2) AS emails, size
WHERE SIZE(emails) = 1
WITH e, COLLECT(prospect) AS uniqueProspects, size
WHERE SIZE(uniqueProspects) = size
RETURN e.id AS email_id, [p IN uniqueProspects | p.id] AS shared_prospects

--produces a visualization of results of email_ids that are associated w/ only 1 prospect_id
--changing WHERE SIZE(prospects) > 0 defines how many prospects are associated w/ the email_id
MATCH (p:Prospect)-[r:HAS_EMAIL]->(e:Email)
WITH e, COLLECT(p) AS prospects
WHERE SIZE(prospects) > 0
WITH e, prospects, SIZE(prospects) AS size
UNWIND prospects AS prospect
MATCH (prospect)-[r2:HAS_EMAIL]->(e2:Email)
WITH e, prospect, r2, COLLECT(e2) AS emails, size
WHERE SIZE(emails) = 1
WITH e, COLLECT(prospect) AS uniqueProspects, COLLECT(r2) AS uniqueRelations, size
WHERE SIZE(uniqueProspects) = size
RETURN e, uniqueProspects, uniqueRelations

--produces table & visualization of all relationships where 
--there is more than 1 prospect associated w/ an email_id
MATCH (e:Email)<-[:HAS_EMAIL]-(p:Prospect)
WITH e, collect(p) AS prospects
WHERE size(prospects) > 1
RETURN e.id AS EmailID, prospects

--I think this does the same as the code above but not really sure
MATCH (e:Email)<-[r:HAS_EMAIL]-(p:Prospect)
WITH e, collect(p) AS prospects, collect(r) AS relationships
WHERE size(prospects) > 1
RETURN e, prospects, relationships

