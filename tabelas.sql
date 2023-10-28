
-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- SIBD - 2022/23
-- Etapa 4 do Projeto - Pacote PL/SQL - Tabelas
-- Grupo 22 - Turma LEI01 - TP 11
-- Catariana Oliveira fc58209, Joana Deus fc58197, Laura Cunha fc58188, Sara Vasques fc58163
-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--
-- ------------------------------------------------------TABELAS---------------------------------------------------------------------------------------------------------------------------------------------------------------------
--      Cliente (nif,                   nome, genero, nascimento, localidade)
--      Produto (ean13,                 nome, categoria, preco, stock)
--       Fatura (numero,                data, cliente)
--  LinhaFatura (fatura, produto,       unidades)
-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- ------------------------------------------------TABELAS---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
DROP TABLE linhafatura;
DROP TABLE fatura;
DROP TABLE produto;
DROP TABLE cliente;
-- -------------------------------------------------CLIENTE--------------------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE TABLE cliente (
  nif        NUMBER  (9),
  nome       VARCHAR (20) CONSTRAINT nn_cliente_nome       NOT NULL,
  genero     CHAR    (1)  CONSTRAINT nn_cliente_genero     NOT NULL,
  nascimento NUMBER  (4)  CONSTRAINT nn_cliente_nascimento NOT NULL,  -- Ano.
  localidade VARCHAR (20) CONSTRAINT nn_cliente_localidade NOT NULL,
--
  CONSTRAINT pk_cliente
    PRIMARY KEY (nif),
--
  CONSTRAINT ck_cliente_nif  -- RIA 16.
    CHECK (nif BETWEEN 100000000 AND 999999999),
--
  CONSTRAINT ck_cliente_genero  -- RIA 17.
    CHECK (genero IN ('F', 'M')),
--
  CONSTRAINT ck_cliente_nascimento
    CHECK (nascimento >= 1900)  -- Valor razoável.
);
-- -------------------------------------------------PRODUTO--------------------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE TABLE produto (
  ean13      NUMBER  (13),
  nome       VARCHAR (20)  CONSTRAINT nn_produto_nome      NOT NULL,
  categoria  CHAR    (7)   CONSTRAINT nn_produto_categoria NOT NULL,
  preco      NUMBER  (6,2) CONSTRAINT nn_produto_preco     NOT NULL,
  stock      NUMBER  (4)   CONSTRAINT nn_produto_stock     NOT NULL,
--
  CONSTRAINT pk_produto
    PRIMARY KEY (ean13),
--
  CONSTRAINT ck_produto_ean13  -- RIA 11.
    CHECK (ean13 BETWEEN 1000000000000 AND 9999999999999),
--
  CONSTRAINT ck_produto_categoria  -- RIA 13.
    CHECK (categoria IN ('Comida', 'Roupa', 'Beleza', 'Animais')),
--
  CONSTRAINT ck_produto_preco  -- RIA 14.
    CHECK (preco > 0.0),
--
  CONSTRAINT ck_produto_stock
    CHECK (stock >= 0)
);
-- -------------------------------------------------FATURA---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE TABLE fatura (
  numero  NUMBER (6),
  data    DATE        CONSTRAINT nn_fatura_data    NOT NULL,
  cliente             CONSTRAINT nn_fatura_cliente NOT NULL,
--
  CONSTRAINT pk_fatura
    PRIMARY KEY (numero),
--
  CONSTRAINT fk_fatura_cliente
    FOREIGN KEY (cliente)
    REFERENCES cliente (nif),
--
  CONSTRAINT ck_fatura_numero  -- RIA 18.
    CHECK (numero >= 1)
);
-- -------------------------------------------------LINHA FATURA---------------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE TABLE linhafatura (
  fatura,
  produto,
  unidades NUMBER (4) CONSTRAINT nn_linhafatura_unidades NOT NULL,
--
  CONSTRAINT pk_linhafatura
    PRIMARY KEY (fatura, produto),
--
  CONSTRAINT fk_linhafatura_fatura
    FOREIGN KEY (fatura)
    REFERENCES fatura (numero),
--
  CONSTRAINT fk_linhafatura_produto
    FOREIGN KEY (produto)
    REFERENCES produto (ean13),
--
  CONSTRAINT ck_linhafatura_unidades  -- RIA 19.
    CHECK (unidades > 0)
);
-- ----------------------------------------------------------------------------