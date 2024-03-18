SELECT
  LOWER(
    TRIM(SPLIT_PART(name, ' ', 1)) || ' ' ||
    TRIM(SPLIT_PART(name, ' ', 2)) || ' ' ||
    TRIM(SPLIT_PART(name, ' ', 3))
  ) AS first_three_words,
  ARRAY_AGG(prospect_id) AS prospect_ids
FROM
  prospects
GROUP BY
  first_three_words
ORDER BY
  first_three_words;




