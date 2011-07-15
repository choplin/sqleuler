WITH
series(n) AS (
    SELECT generate_series(1, 100)
)
,square_of_sum(n) AS (
    SELECT
        sum(n) ^ 2
    FROM
        series
)
,sum_of_squares(n) AS (
    SELECT
        sum(n^2)
    FROM
        series
)
SELECT
    t1.n - t2.n 
FROM
    square_of_sum AS t1, sum_of_squares AS t2
