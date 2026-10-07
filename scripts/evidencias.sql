-- Execute após CADA operação na interface, no banco dimdimdb.
SELECT Id, Nome, Email, Cpf FROM dbo.Clientes ORDER BY Id;
SELECT Id, Numero, Tipo, Saldo, ClienteId FROM dbo.Contas ORDER BY Id;
SELECT c.Id AS ContaId, c.Numero, c.Tipo, c.Saldo, cl.Id AS ClienteId, cl.Nome
FROM dbo.Contas c JOIN dbo.Clientes cl ON cl.Id = c.ClienteId ORDER BY c.Id;
-- Use somente dados fictícios no vídeo. IDs não precisam começar em 1.
