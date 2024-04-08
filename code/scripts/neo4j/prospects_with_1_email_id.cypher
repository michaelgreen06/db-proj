--produces a table of results of email_ids that are associated w/ only 1 prospect_id
MATCH (p:Prospect)-[:HAS_EMAIL]->(e:Email)
WITH e, COLLECT(p) AS prospects
WHERE SIZE(prospects) > 1
WITH e, prospects, SIZE(prospects) AS size
UNWIND prospects AS prospect
MATCH (prospect)-[:HAS_EMAIL]->(e2:Email)
WITH e, prospect, COLLECT(e2) AS emails, size
WHERE SIZE(emails) = 1
WITH e, COLLECT(prospect) AS uniqueProspects, size
WHERE SIZE(uniqueProspects) = size
RETURN e.id AS email_id, [p IN uniqueProspects | p.id] AS shared_prospects

--produces a visualization of results of email_ids that are associated w/ only 1 prospect_id
MATCH (p:Prospect)-[r:HAS_EMAIL]->(e:Email)
WITH e, COLLECT(p) AS prospects, COLLECT(r) AS relationships
WHERE SIZE(prospects) > 1
WITH e, prospects, relationships, SIZE(prospects) AS size
UNWIND prospects AS prospect
MATCH (prospect)-[r2:HAS_EMAIL]->(e2:Email)
WITH e, prospect, relationships + COLLECT(r2) AS allRelationships, e2, size
WHERE SIZE(COLLECT(e2)) = 1
WITH e, COLLECT(prospect) AS uniqueProspects, allRelationships, size
WHERE SIZE(uniqueProspects) = size
RETURN e, uniqueProspects, allRelationships

