

As Ledger Tables são uma funcionalidade introduzida no SQL Server 2022 que permitem criar tabelas imutáveis, proporcionando uma trilha de auditoria incorporada ao banco de dados. Essa funcionalidade é voltada para cenários em que a integridade e a autenticidade dos dados são críticas, como em sistemas financeiros, registros médicos e aplicações governamentais.
Como Funcionam as Ledger Tables?

    Imutabilidade dos Dados:
        Ledger Tables garantem que os registros inseridos ou atualizados em uma tabela não podem ser alterados ou excluídos. Isso é feito através do uso de hash criptográfico e de uma estrutura de dados baseada em Merkle trees, que permite verificar se os dados foram adulterados.

    Histórico Completo:
        Todas as mudanças feitas nos registros são automaticamente registradas, criando um histórico completo de todas as transações. Isso inclui operações de inserção, atualização e exclusão, garantindo a rastreabilidade total dos dados ao longo do tempo.

    Verificabilidade:
        A estrutura da Ledger Table permite verificar a integridade dos dados com facilidade. É possível provar que os dados não foram modificados após serem inseridos, algo crucial para auditorias e conformidade regulatória.

    Semelhante ao Blockchain:
        A funcionalidade é inspirada nos princípios de blockchain, onde cada mudança cria um "bloco" de informações que é ligado ao bloco anterior, criando uma cadeia imutável de transações.

Tipos de Ledger Tables

O SQL Server 2022 oferece dois tipos principais de Ledger Tables:

    Updatable Ledger Table:
        Permite inserções e atualizações regulares, mas todas as alterações são registradas para fins de auditoria. É possível visualizar o estado atual e todo o histórico dos dados.

    Append-Only Ledger Table:
        Permite apenas a inserção de novos registros; não é possível atualizar ou excluir dados existentes. Ideal para registros de log ou outras situações em que a imutabilidade absoluta é necessária.

Exemplo de Criação de uma Ledger Table

sql

CREATE LEDGER TABLE Clientes (
    ClienteID INT PRIMARY KEY,
    Nome NVARCHAR(100),
    DataNascimento DATE
)
WITH (LEDGER = ON);

Neste exemplo:

    A tabela Clientes é criada como uma Updatable Ledger Table com o recurso de ledger ativado.
    Qualquer alteração feita nos dados desta tabela será rastreada e armazenada, permitindo auditoria e verificação futura.

Consultando o Histórico de uma Ledger Table

sql

SELECT * FROM Clientes_FOR_LEDGER_AUDIT;

Neste exemplo:

    _FOR_LEDGER_AUDIT é uma visualização interna que fornece uma visão detalhada do histórico de transações na tabela Clientes, incluindo todas as mudanças ao longo do tempo.

Casos de Uso

    Financeiro: Ledger Tables podem ser usadas para garantir a integridade de registros financeiros, como transações bancárias, registros de auditoria, etc.
    Regulatório: São úteis para conformidade com normas que exigem trilhas de auditoria, como SOX (Sarbanes-Oxley) nos EUA.
    Setor de Saúde: Podem ser usadas para registros médicos, onde a integridade e rastreabilidade dos dados são essenciais.