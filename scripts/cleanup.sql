-- Limpar customers duplicados (mantém apenas o primeiro de cada email)
DELETE FROM customers
WHERE id NOT IN (
  SELECT MIN(id)
  FROM customers
  GROUP BY email
);

DELETE FROM email_logs;

-- Limpar arquivos do ActiveStorage
DELETE FROM active_storage_attachments;
DELETE FROM active_storage_blobs;

-- Reset sequences
SELECT setval('customers_id_seq', COALESCE((SELECT MAX(id) FROM customers), 1));
SELECT setval('email_logs_id_seq', 1);
