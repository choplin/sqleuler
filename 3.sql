CREATE OR REPLACE FUNCTION sieve_of_eratosthenes(int) RETURNS SETOF int AS $$
    WITH RECURSIVE
    --数列を用意
    t1(n) AS (
        SELECT generate_series(2, $1)
    ),
    t2 (n, i) AS (
        --初期化
        SELECT
            n
            ,1
        FROM
            t1
        --再起:再起集合内の最小値で割り切れる値を除いた集合を新たに再起集合とする
        UNION ALL(
            --再起集合をコピー（再起集合は再起部で一度しか呼び出せないため）
            WITH s1 (n) AS(
                SELECT
                    n
                FROM
                    t2
            )
            --再起集合内の最小値を取得
            ,s2 (k) AS(
                SELECT
                    min(n)
                FROM
                    s1
            )
            --最小値で割り切れる値を除外して集合を作成
            SELECT
                n
                ,k
            FROM
                s1,s2
            WHERE
                (n%k) <> 0
                AND k*k < $1 --√nで再起を終了
        )
    )
    --除数に用いた数は素数(1以外)
    SELECT DISTINCT
        i AS n
    FROM
        t2
    WHERE
        i <> 1
    UNION
    --最後に残った集合も素数
    SELECT
        n
    FROM
        t2
    WHERE
        i = (SELECT max(i) FROM t2)
    ORDER BY
        n
$$ LANGUAGE SQL IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION prime_factorization (int) RETURNS int[] AS $$
WITH RECURSIVE prime(ary) AS (
    SELECT
        array_agg(num) AS ary
    FROM
        sieve_of_eratosthenes(trunc(sqrt($1))::int) AS t(num) 
)
,factorization AS(
    SELECT
        1 AS prime
        ,$1 AS quotient
        ,1 AS idx
        ,FALSE AS flag
    UNION ALL
    SELECT
        ary[idx]
        ,CASE 
            WHEN (quotient % ary[idx]) = 0 THEN quotient / ary[idx]
            ELSE quotient
        END
        ,CASE
            WHEN (quotient % ary[idx]) = 0 THEN idx
            ELSE idx + 1
        END
        ,CASE
            WHEN (quotient % ary[idx]) = 0 THEN TRUE
            ELSE FALSE
        END
    FROM
        factorization, prime
    WHERE
        idx <= array_length(ary, 1)
)
,agg AS (
SELECT
    array_agg(prime) AS result
    ,min(quotient) AS min
FROM
    factorization
WHERE
    flag
)
SELECT
    CASE
        WHEN result[1] IS NULL THEN ARRAY[$1]
        WHEN min = 1 THEN result
        ELSE array_append(result, min)
    END
FROM
    agg
;
$$ LANGUAGE SQL IMMUTABLE STRICT;
SELECT prime_factorization(600851475143);
