WITH tb_transacoes AS (
    SELECT 
        IdTransacao,
        IdCliente,
        QtdePontos,
        datetime(substr(dtCriacao, 1, 19)) AS dtCriacao,
        julianday('now') - julianday(substr(dtCriacao, 1, 19)) AS diffDate
    FROM transacoes
),

tb_cliente AS (
    SELECT 
        IdCliente,
        QtdePontos,
        datetime(substr(dtCriacao, 1, 19)) AS dtCriacao,
        cast(julianday('now') - julianday(substr(dtCriacao, 1, 19)) AS integer) AS idadeBase
    FROM clientes
),

tb_sumario_transacoes AS (
    SELECT 
        IdCliente,
        count(IdTransacao) AS TransacoesVida,
        count(CASE WHEN diffDate <= 56 THEN IdTransacao END) AS Transacoes56,
        count(CASE WHEN diffDate <= 28 THEN IdTransacao END) AS Transacoes28,
        count(CASE WHEN diffDate <= 14 THEN IdTransacao END) AS Transacoes14,
        count(CASE WHEN diffDate <= 7 THEN IdTransacao END) AS Transacoes7,
        
        cast(min(diffDate) AS INTEGER) AS diasUltimaInteracao,
        sum(qtdePontos) AS SaldoPontos

    FROM tb_transacoes
    GROUP BY IdCliente
)

SELECT 
    t1.*,
    t2.idadeBase
FROM tb_sumario_transacoes AS t1
LEFT JOIN tb_cliente AS t2
ON t1.idCLiente = t2.idCliente