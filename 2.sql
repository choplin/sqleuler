WITH RECURSIVE r AS (
    SELECT
        1 AS a
        ,1 AS b
    UNION ALL
    SELECT
        b AS a
        ,a + b AS b
    FROM
        r
    WHERE
        b <= 4000000
)
SELECT
    sum(b)
FROM
    r
WHERE
    (b % 2) = 0
;
