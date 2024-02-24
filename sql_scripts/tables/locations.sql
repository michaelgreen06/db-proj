CREATE TABLE locations (
    location_id SERIAL PRIMARY KEY,
    city VARCHAR(255),
    state CHAR(2),
    zipcode VARCHAR(10),
    prospect_id INTEGER,
    CONSTRAINT fk_prospect_id FOREIGN KEY (prospect_id) REFERENCES prospects(prospect_id)
);

--copy data from prospects table and exclude prospect_id's that have improperly formatted municipality fields
WITH excluded_prospects AS (
    SELECT unnest(ARRAY[
        4123, 5132, 6247, 16044, 12980, 12515, 13977, 18166, 16626, 12610, 
        7918, 6478, 8538, 12309, 6147, 14956, 7083, 6734, 11701, 6410, 
        7137, 13900, 3525, 8922, 6874, 1473, 3165, 2560, 1245, 3101, 
        4229, 10191, 11852, 14833, 14844, 11451, 2883, 18255, 5733, 13958, 
        3618, 6158, 15736, 9770, 13896, 8148, 1295, 8293, 8367, 7274, 
        6246, 7523, 18170, 5422, 6174, 6145, 3509, 6219, 5504, 4261, 
        5444, 13584, 13393, 1687, 4293, 13914, 7941, 17086, 3594, 8219, 
        3114, 15952, 2327, 8899, 7338, 7239, 2494, 7008, 5518, 14576, 
        2764, 735, 2782, 4748, 15770, 9031, 11294, 1420, 11792, 10663, 
        12670, 5199, 12870, 11049, 1952, 11288, 678, 16528, 1217, 13200, 
        1617, 5172, 10405, 15805, 8181, 11876, 16944, 13563, 18213, 4765, 
        8637, 630, 2468, 5237, 411, 3622, 11944, 5426, 12735, 18198, 
        81, 1205, 952, 991, 3131, 7063, 7667, 10885, 17140, 8399, 
        17855, 1600, 17903, 6459, 853, 14512, 17980, 6366, 10160, 4458, 
        11381, 16877, 16407, 4856, 4721, 16104
    ]) AS prospect_id
)
INSERT INTO locations (city, state, zipcode, prospect_id)
SELECT
    TRIM(SPLIT_PART(municipality, ',', 1)) AS city,
    TRIM(SPLIT_PART(SPLIT_PART(municipality, ',', 2), ' ', 1)) AS state,
    TRIM(SPLIT_PART(municipality, ' ', -1)) AS zipcode,
    p.prospect_id
FROM
    prospects p
WHERE
    p.prospect_id NOT IN (SELECT prospect_id FROM excluded_prospects);

