SELECT
    sum(num)
FROM
    generate_series(1, 999) AS t(num)
WHERE
    (num % 3) = 0
    OR (num % 5) = 0
;
