# Roteiro de evidências

Grave no mínimo 720p, com sua explicação falada. Use uma cópia limpa do projeto e um grupo novo se precisar mostrar a criação desde o início. A gravação deve mostrar execução real, sem inventar resultados.

1. Apresente nome/RM e diga: "Este é o DimDim, um site .NET MVC com clientes e contas relacionadas, hospedado no App Service e usando Azure SQL PaaS."
2. Mostre README e desenho da arquitetura. Explique a relação 1:N.
3. Mostre pasta `scripts`, DDL e código. Execute a validação da compilação.
4. Mostre assinatura/região escolhida. Execute `01-provisionar.ps1`; interrompa ou oculte a captura durante entrada de credenciais. Não rode comandos com `--debug` ou que exibam segredos.
5. Mostre os recursos criados no portal: App Service, banco SQL, workspace e Application Insights.
6. Execute `02-deploy.ps1`, mostre resultado e abra a URL Azure. Mostre a barra de endereço, sem usar localhost como evidência final.
7. Abra o editor SQL já autenticado. Mostre banco `dimdimdb` e as duas tabelas vazias.
8. Crie cliente fictício → SELECT Clientes. Leia/lista/detalhe → SELECT. Edite → SELECT.
9. Crie conta ligada ao cliente → SELECT Contas e JOIN. Leia → SELECT. Edite tipo/saldo → SELECT. Exclua → SELECT mostrando ausência.
10. Exclua cliente → SELECT mostrando ausência. Explique que a conta deve ser excluída primeiro devido à chave estrangeira.
11. Mostre Application Insights com requisições, dependências SQL e logs CRUD. Mostre gráficos de métricas do Azure SQL no mesmo período.
12. Mostre README com links atualizados e repositório acessível. Termine explicando que o PDF contém grupo, integrantes e links.

Use a tabela de testes do README como checklist durante a gravação. Não pule SELECT após leitura, edição ou exclusão. Confira a gravação antes de publicar: áudio claro, texto legível, acesso aos links e nenhuma credencial visível.
