CREATE TABLE categories (
    categories_id SERIAL PRIMARY KEY,
    prospect_id INTEGER NOT NULL,
    category1 VARCHAR(255),
    category2 VARCHAR(255),
    category3 VARCHAR(255),
    FOREIGN KEY (prospect_id) REFERENCES prospects(prospect_id)
);

--copy first 3 categories from the prospects table to the categories table
INSERT INTO categories (prospect_id, category1, category2, category3)
SELECT
    prospect_id,
    SPLIT_PART(categories, ',', 1) AS category1,
    SPLIT_PART(categories, ',', 2) AS category2,
    SPLIT_PART(categories, ',', 3) AS category3
FROM
    prospects;

