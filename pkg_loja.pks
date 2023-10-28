-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- SIBD - 2022/23
-- Etapa 4 do Projeto - Pacote PL/SQL - Módulo Package Especificação PKS
-- Grupo 22 - Turma LEI01 - TP 11
-- Catariana Oliveira fc58209, Joana Deus fc58197, Laura Cunha fc58188, Sara Vasques fc58163
-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--
-- ---------------------------------TABELAS------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--      Cliente (nif,                   nome, genero, nascimento, localidade)
--      Produto (ean13,                 nome, categoria, preco, stock)
--       Fatura (numero,                data, cliente)
--  LinhaFatura (fatura, produto,       unidades)
-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

CREATE OR REPLACE PACKAGE pkg_loja IS

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  -- Todas as operações lançam exceções para sinalizar casos de erro.
  --
  -- Exceção Mensagem:
  --
  --  -20000 O nif do cliente tem de ser positivo e ter 9 digitos.
  --  -20001 O genero do cliente tem de correponder a letra M ou F.
  --  -20002 O ano da data de nascimento do cliente tem de ser um valor razoavel.
  --  -20003 O ean13 do produto tem de ser positivo e ter 13 digitos.
  --  -20004 A categoria do cliente tem de pertencer a: Comida, Roupa, Beleza, Animais.
  --  -20005 O preço do produto tem de ser suprior a 0.
  --  -20006 O stock do produto tem de ser maior ou igual a 0.
  --  -20007 O numero da fatura tem de ser maior ou igual a 1.
  --  -20008 O numero de unidades compradas de um produto tem de ser superior a 0.
  --  -20009 Insira um valor diferente de NULL em (nome_coluna) da tabela (nome_tabela).
  --  -20010 Erro na foreign key (nome_coluna) da tabela (nome_tabela). (nome_coluna) nao existe na tabela de (nome_tabela).
  --  -20011 Insira um valor em (nome_coluna) da tabela (nome_tabela) que tenha no maximo (max_size) carateres.
  --  -20012 Insira um numero de dígitos que esteja dentro da precisao determinada pela coluna.
  --  -20013 Ja existe um cliente com esse numero.
  --  -20014 Existe um produto com esse numero, mas o nome ou a categoria nao correspondem.
  --  -20015 A fatura na qual se quer inserir nao pertence a esse cliente.
  --  -20016 Unidades em stock insuficientes.
  --  -20017 Ja existe essa fatura, para esse cliente, com esse produto.
  --  -20018 Nao existe uma linha na fatura com esse produto.
  --  -20019 Nao existem linhas na fatura.
  --  -20020 Insira um numero de fatura diferente de NULL.
  --  -20021 A fatura nao existe.
  --  -20022 A fatura a remover nao existe.
  --  -20023 Insira um numero de produto diferente de NULL.
  --  -20024 O produto a remover nao existe.
  --  -20025 Nao existem linhas de fatura.
  --  -20026 Insira um nif de cliente diferente de NULL.
  --  -20027 O cliente a remover nao existe.
  --  -20028 Insira uma categoria valida (Comida, Roupa, Beleza, Animais) para a lista de produtos mais comprados.
  --  -20029 Insira uma categoria diferente de NULL para a lista de produtos mais comprados.
  --
  -------------------------------------------------------------------------------------------------------------------------------
  --Cria um novo registo de um cliente com NIF, nome, género, ano de nascimento, e localidade.
  PROCEDURE regista_cliente (
    nif_in          IN cliente.nif%TYPE,
    nome_in         IN cliente.nome%TYPE,
    genero_in       IN cliente.genero%TYPE,
    nascimento_in   IN cliente.nascimento%TYPE,
    localidade_in   IN cliente.localidade%TYPE);

  --Cria um novo registo de um produto com EAN-13, nome, categoria, preço, e unidades em stock. 
  --Se o produto já existir, o seu stock passa a ser o do valor em stock_in.
  PROCEDURE regista_produto (
    ean13_in       IN produto.ean13%TYPE,
    nome_in        IN produto.nome%TYPE,
    categoria_in   IN produto.categoria%TYPE,
    preco_in       IN produto.preco%TYPE,
    stock_in       IN produto.stock%TYPE);

  --Regista a compra de uma ou mais unidades de um produto por um cliente, no âmbito de uma fatura, 
  --(acrescenta uma linha à fatura). Se o número de fatura não for fornecido, é criada uma nova fatura
  --para o cliente, com um número gerado automaticamente e com a data atual, ficando a compra associada
  --a essa fatura. Cada compra faz diminuir o stock do respetivo produto na loja, e pode falhar se esse
  --stock for insuficiente. A função devolve o número da fatura onde foi registada a compra.
  FUNCTION regista_compra (
    cliente_in    IN fatura.cliente%TYPE,
    produto_in    IN linhafatura.produto%TYPE,
    unidades_in   IN linhafatura.unidades%TYPE,
    fatura_in     IN linhafatura.fatura%TYPE := NULL)
    RETURN NUMBER;

  --Remove a compra de um produto no âmbito de uma fatura, ou seja, retira uma linha do talão da fatura.
  --Se a fatura ficar sem produtos, também é removida. O número de unidades compradas é transferido para 
  --o stock desse produto na loja. Se o EAN-13 do produto não for fornecido, são removidas todas as compras 
  --de produtos no âmbito da fatura, sendo a fatura também removida. A função devolve o número de linhas que 
  --ainda constam no talão da fatura, ou zero se a fatura tiver sido removida.
  FUNCTION remove_compra (
    fatura_in     IN linhafatura.fatura%TYPE,
    produto_in    IN linhafatura.produto%TYPE := NULL)
    RETURN NUMBER;

  --Remove um produto, bem como todas as compras desse produto pelos clientes.
  PROCEDURE remove_produto (
    ean13_in IN linhafatura.produto%TYPE);

  --Remove um cliente, bem como todas as compras de produtos que fizeram.
  PROCEDURE remove_cliente (
    nif_in IN cliente.nif%TYPE);

  --Devolve um cursor com os produtos da categoria indicada mais comprados pelos clientes, 
  --por ordem descendente do número de unidades. Cada linha do cursor tem o EAN-13, 
  --nome, e preço de um produto, e o total de unidades vendidas (que pode ser zero).
  FUNCTION lista_produtos (
    categoria_in IN produto.categoria%TYPE)
    RETURN SYS_REFCURSOR;

-------------------------------------------------------------------------------------------------------------------------------
END pkg_loja;
/
-------------------------------------------------------------------------------------------------------------------------------