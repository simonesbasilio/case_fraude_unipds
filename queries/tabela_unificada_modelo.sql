CREATE TABLE `unipdsaula-511801.capstone_fraude.abt_fraude` AS (
SELECT
  t.entrega_doc_1,
  t.entrega_doc_2,
  t.entrega_doc_3,
  t.data_compra,
  t.valor_compra,
  t.pais,
  t.produto,
  t.categoria_produto,
  mo.score_8,
  mo.score_fraude_modelo,
  mo.fraude,
  cb.score_1,
  cb.score_2,
  cb.score_4,
  cb.score_5,
  cb.score_7,
  fi.score_3,
  fi.score_6,
  fi.score_9,
  fi.score_10

FROM `unipdsaula-511801.capstone_fraude.transacoes` t
JOIN `unipdsaula-511801.capstone_fraude.scores_comportamentais` cb ON cb.id_transacao = t.id_transacao
JOIN `unipdsaula-511801.capstone_fraude.scores_financeiros` fi ON fi.id_transacao = t.id_transacao
JOIN `unipdsaula-511801.capstone_fraude.scores_modelo` mo ON mo.id_transacao = t.id_transacao
WHERE t.is_teste = 0);