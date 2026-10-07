-- Azure SQL Database: esquema equivalente ao modelo EF Core.
-- Executar no BANCO dimdimdb, nunca no master. Pode rodar novamente.
IF OBJECT_ID(N'dbo.Clientes', N'U') IS NULL
BEGIN
 CREATE TABLE dbo.Clientes (
  Id int IDENTITY(1,1) NOT NULL CONSTRAINT PK_Clientes PRIMARY KEY,
  Nome nvarchar(100) NOT NULL,
  Email nvarchar(150) NOT NULL,
  Cpf nvarchar(11) NOT NULL
 );
 CREATE UNIQUE INDEX IX_Clientes_Cpf ON dbo.Clientes(Cpf);
END;
IF OBJECT_ID(N'dbo.Contas', N'U') IS NULL
BEGIN
 CREATE TABLE dbo.Contas (
  Id int IDENTITY(1,1) NOT NULL CONSTRAINT PK_Contas PRIMARY KEY,
  Numero nvarchar(20) NOT NULL,
  Tipo nvarchar(max) NOT NULL,
  Saldo decimal(18,2) NOT NULL,
  ClienteId int NOT NULL,
  CONSTRAINT FK_Contas_Clientes_ClienteId FOREIGN KEY (ClienteId) REFERENCES dbo.Clientes(Id) ON DELETE NO ACTION
 );
 CREATE UNIQUE INDEX IX_Contas_Numero ON dbo.Contas(Numero);
 CREATE INDEX IX_Contas_ClienteId ON dbo.Contas(ClienteId);
END;
