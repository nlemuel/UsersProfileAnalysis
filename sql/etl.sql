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
        sum(qtdePontos) AS SaldoPontos,

        sum(CASE WHEN qtdePontos > 0 THEN qtdePontos ELSE 0 END) AS qtdePontosNegVida,

        sum(CASE WHEN qtdePontos > 0 AND diffDate <= 56 THEN qtdePontos ELSE 0 END) AS qtdePontosPos56,
        sum(CASE WHEN qtdePontos > 0 AND diffDate <= 28 THEN qtdePontos ELSE 0 END) AS qtdePontosPos28,
        sum(CASE WHEN qtdePontos > 0 AND diffDate <= 14 THEN qtdePontos ELSE 0 END) AS qtdePontosPos14,
        sum(CASE WHEN qtdePontos > 0 AND diffDate <= 7 THEN qtdePontos ELSE 0 END) AS qtdePontosPos7,

        sum(CASE WHEN qtdePontos < 0 AND diffDate <= 56 THEN qtdePontos ELSE 0 END) AS qtdePontosNeg56,
        sum(CASE WHEN qtdePontos < 0 AND diffDate <= 28 THEN qtdePontos ELSE 0 END) AS qtdePontosNeg28,
        sum(CASE WHEN qtdePontos < 0 AND diffDate <= 14 THEN qtdePontos ELSE 0 END) AS qtdePontosNeg14,
        sum(CASE WHEN qtdePontos < 0 AND diffDate <= 7 THEN qtdePontos ELSE 0 END) AS qtdePontosNeg7

    FROM tb_transacoes
    GROUP BY IdCliente
),

tb_transacao_produto AS (

SELECT 
    t1.*,
    t3.DescCategoriaProduto,
    t3.DescNomeProduto

FROM tb_transacoes AS t1
LEFT JOIN transacao_produto as t2
ON t1.IdTransacao = t2.IdTransacao

LEFT JOIN produtos AS t3
ON t2.IdProduto = t3.IdProduto
),

tb_cliente_produto AS (
    SELECT 
        IdCliente,
        DescNomeProduto,
        count(*) AS qtdeVida,
        count(CASE WHEN diffDate <= 56 THEN IdTransacao END) AS qtde56,
        count(CASE WHEN diffDate <= 28 THEN IdTransacao END) AS qtde28,
        count(CASE WHEN diffDate <= 14 THEN IdTransacao END) AS qtde14,
        count(CASE WHEN diffDate <= 7 THEN IdTransacao END) AS qtde7
    FROM tb_transacao_produto
    GROUP BY idCliente, DescNomeProduto
),

tb_cliente_produto_rn AS (
    SELECT 
        *,
        row_number() OVER (PARTITION BY IdCliente ORDER BY qtdeVida DESC) AS rnVida,
        row_number() OVER (PARTITION BY IdCliente ORDER BY qtde56 DESC) AS rn56,
        row_number() OVER (PARTITION BY IdCliente ORDER BY qtde28 DESC) AS rn28,
        row_number() OVER (PARTITION BY IdCliente ORDER BY qtde14 DESC) AS rn14,
        row_number() OVER (PARTITION BY IdCliente ORDER BY qtde7 DESC) AS rn7
    FROM tb_cliente_produto
),

tb_join AS (
    SELECT 
        t1.*,
        t2.idadeBase,
        t3.DescNomeProduto AS produtoVida,
        t4.DescNomeProduto AS produto56,
        t5.DescNomeProduto AS produto28,
        t6.DescNomeProduto AS produto14,
        t7.DescNomeProduto AS produto7
        
    FROM tb_sumario_transacoes AS t1
    LEFT JOIN tb_cliente AS t2
    ON t1.idCLiente = t2.idCliente

    LEFT JOIN tb_cliente_produto_rn AS t3
    ON t1.IdCliente = t3.idCliente
    AND t3.rnVida = 1

    LEFT JOIN tb_cliente_produto_rn AS t4
    ON t1.IdCliente = t4.idCliente
    AND t4.rn56 = 1

    LEFT JOIN tb_cliente_produto_rn AS t5
    ON t1.IdCliente = t5.idCliente
    AND t5.rn28 = 1

    LEFT JOIN tb_cliente_produto_rn AS t6
    ON t1.IdCliente = t6.idCliente
    AND t6.rn14 = 1

    LEFT JOIN tb_cliente_produto_rn AS t7
    ON t1.IdCliente = t7.idCliente
    AND t7.rn7 = 1
)

SELECT * FROM tb_join
ORDER BY idCliente