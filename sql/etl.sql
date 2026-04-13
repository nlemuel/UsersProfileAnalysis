WITH tb_transacoes AS (
    SELECT 
        IdTransacao,
        IdCliente,
        QtdePontos,
        datetime(substr(dtCriacao, 1, 19)) AS dtCriacao,
        julianday('now') - julianday(substr(dtCriacao, 1, 19)) AS diffDate
    FROM transacoes
)

SELECT 
    IdCliente,
    count(IdTransacao) AS TransacoesVida,
    count(CASE WHEN diffDate <= 56 THEN IdTransacao END) AS Transacoes56,
    count(CASE WHEN diffDate <= 28 THEN IdTransacao END) AS Transacoes28,
    count(CASE WHEN diffDate <= 14 THEN IdTransacao END) AS Transacoes14,
    count(CASE WHEN diffDate <= 7 THEN IdTransacao END) AS Transacoes7

FROM tb_transacoes
GROUP BY IdCliente