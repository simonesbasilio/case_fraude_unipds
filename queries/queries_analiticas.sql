select * from unipdsaula-511801.capstone_fraude.abt_fraude

SELECT
    COUNT(*)                                                  AS total,
    SUM(fraude)                                               AS fraudes,
    ROUND(100.0*AVG(fraude), 3)                               AS taxa_fraude_pct,
    ROUND(SUM(CASE WHEN fraude = 1 THEN valor_compra ELSE 0 END), 2) AS valor_exposto,
    ROUND(AVG(CASE WHEN fraude = 1 THEN valor_compra END), 2)        AS ticket_medio_fraude,
    ROUND(AVG(valor_compra), 2)                               AS ticket_medio_geral
FROM `unipdsaula-511801.capstone_fraude.abt_fraude`;



SELECT
    p.nome_pais,
    p.regiao,
    COUNT(*)                  AS transacoes,
    ROUND(100.0*AVG(a.fraude), 2) AS taxa_fraude_pct
FROM `unipdsaula-511801.capstone_fraude.abt_fraude` a
JOIN `unipdsaula-511801.capstone_fraude.dim_paises` p ON p.sigla_pais = a.pais
GROUP BY p.nome_pais, p.regiao
HAVING COUNT(*) >= 1000
ORDER BY taxa_fraude_pct DESC;

SELECT
    c.nivel_risco_categoria,
    COUNT(*)                  AS transacoes,
    ROUND(100.0*AVG(a.fraude), 2) AS taxa_fraude_pct
FROM `unipdsaula-511801.capstone_fraude.abt_fraude` a
JOIN `unipdsaula-511801.capstone_fraude.dim_categorias` c ON c.id_categoria = a.categoria_produto
GROUP BY c.nivel_risco_categoria
ORDER BY taxa_fraude_pct DESC;


SELECT
    CASE
        WHEN valor_compra < 100 THEN '1) ate 100'
        WHEN valor_compra < 500 THEN '2) 100-500'
        ELSE                         '3) acima de 500'
    END                         AS faixa_valor,
    COUNT(*)                    AS transacoes,
    ROUND(100.0*AVG(fraude), 2) AS taxa_fraude_pct
FROM `unipdsaula-511801.capstone_fraude.abt_fraude`
GROUP BY faixa_valor
ORDER BY faixa_valor;

WITH base AS (
    SELECT
        CASE
            WHEN valor_compra < 100  THEN '1) ate 100'
            WHEN valor_compra < 500  THEN '2) 100-500'
            WHEN valor_compra >= 500 THEN '3) acima de 500'
            ELSE                          '4) valor NULL' -- separa nulos em vez de escondê-los na faixa 3
        END AS faixa_valor,
        fraude,
        valor_compra
    FROM `unipdsaula-511801.capstone_fraude.abt_fraude`
)


SELECT
    faixa_valor,
    COUNT(*)    AS transacoes,
    SUM(fraude) AS fraudes,
    ROUND(100.0 * SUM(fraude) / COUNT(*), 2) AS taxa_fraude_pct,
    ROUND(100.0 * SUM(fraude) / SUM(SUM(fraude)) OVER (), 1) AS pct_dos_casos, -- % das fraudes daquela faixa sobre o total de fraudes.
    ROUND(SUM(CASE WHEN fraude = 1 THEN valor_compra ELSE 0 END), 2) AS valor_exposto,
    ROUND(100.0 * SUM(CASE WHEN fraude = 1 THEN valor_compra ELSE 0 END)
        / SUM(SUM(CASE WHEN fraude = 1 THEN valor_compra ELSE 0 END)) OVER (), 1) AS pct_do_valor,
    ROUND(SAFE_DIVIDE(
        SUM(CASE WHEN fraude = 1 THEN valor_compra ELSE 0 END),
        SUM(fraude)
    ), 2) AS perda_media_por_fraude
FROM base
GROUP BY faixa_valor
ORDER BY faixa_valor;

WITH faixas AS (
    SELECT
        fraude,
        NTILE(10) OVER (ORDER BY score_fraude_modelo) AS decil
    FROM `unipdsaula-511801.capstone_fraude.abt_fraude`
)
SELECT
    decil,
    COUNT(*)                    AS transacoes,
    ROUND(100.0*AVG(fraude), 2) AS taxa_fraude_pct
FROM faixas
GROUP BY decil
ORDER BY decil;
