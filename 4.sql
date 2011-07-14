CREATE OR REPLACE FUNCTION isPalindromic (text) RETURNS boolean AS $$
    WITH RECURSIVE t(idx, flag) AS (
        SELECT
            1
            ,substr($1, 1, 1) = substr($1, length($1), 1)
        UNION ALL
        SELECT
            idx+1
            ,substr($1, idx+1, 1) = substr($1, length($1)-idx, 1)
        FROM
            t
        WHERE
            idx+1 <= (length($1) / 2)
    )
    SELECT
        bool_and(flag)
    FROM
        t
$$ LANGUAGE SQL IMMUTABLE STRICT
;

WITH series(n) AS (
    SELECT generate_series(1,999)
)
SELECT
    max(t1.n * t2.n) AS palindromic
FROM
    series AS t1, series AS t2
WHERE
    t1.n >= t2.n
    AND isPalindromic((t1.n * t2.n)::text)
;
