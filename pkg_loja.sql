-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- SIBD - 2022/23
-- Etapa 4 do Projeto - Pacote PL/SQL - Modulo Script SQL
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

-- ------------------------------------------------SCRIPT----------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--Include das tabelas SQL.
@tabelas.sql

--Criacao de uma sequencia de numeros de fatura.
DROP SEQUENCE seq_numero_fatura;

CREATE SEQUENCE seq_numero_fatura
  START WITH     1
  INCREMENT BY   1
  MAXVALUE 999999
  NOCYCLE;

--Compilacao do pacote Loja.
@pkg_loja.pks
@pkg_loja.pkb

--------------------------------------------DECLARACAO DE VARIAVEIS------------------------------------------------------------------------------------------------------------------------------------------------------------------

--Variaveis para os numeros de fatura:
VARIABLE num_fat NUMBER;
VARIABLE fat_1 NUMBER;
VARIABLE fat_2 NUMBER;
VARIABLE fat_3 NUMBER;
VARIABLE fat_4 NUMBER;
VARIABLE fat_5 NUMBER;
VARIABLE fat_6 NUMBER;
VARIABLE fat_7 NUMBER;
VARIABLE fat_8 NUMBER;
VARIABLE fat_9 NUMBER;
VARIABLE fat_10 NUMBER;
VARIABLE fat_11 NUMBER;
VARIABLE fat_12 NUMBER;
VARIABLE fat_13 NUMBER;

--Variaveis para os cursores:
VARIABLE lista_roupa REFCURSOR;
VARIABLE lista_animais REFCURSOR;
VARIABLE lista_comida REFCURSOR;
VARIABLE lista_beleza REFCURSOR;
VARIABLE lista REFCURSOR;

-----------------------------------------------------------------------------------------------------------------
--Remocao de possiveis dados que possam estar nas tabelas.
DELETE FROM linhafatura;
DELETE FROM fatura;
DELETE FROM produto;
DELETE FROM cliente;

------------------------------------------REGISTA CLIENTE----------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--ASSINATURA DA FUNCAO: regista_cliente(nif_in, nome_in, genero_in, nascimento_in, localidade_in) 

--Registar clientes na loja.
BEGIN
pkg_loja.regista_cliente(111111111, 'Diogo Gaspar', 'M', 1931, 'Lisboa');
pkg_loja.regista_cliente(222222222, 'Bruno Nunes', 'M', 1992, 'Lisboa');
pkg_loja.regista_cliente(333333333, 'Carlos Dias', 'M', 1993, 'Lisboa');
pkg_loja.regista_cliente(444444444, 'Daniela Santos', 'F', 1994, 'Porto');
pkg_loja.regista_cliente(555555555, 'Eduarda Dias', 'F', 1995, 'Algarve');
pkg_loja.regista_cliente(666666666, 'Filipe Rocha', 'M', 1996, 'Porto');
pkg_loja.regista_cliente(777777777, 'Helena Dias', 'F', 1997, 'Coimbra');
pkg_loja.regista_cliente(888888888, 'Joaquim Soares', 'M', 1948, 'Lisboa');
pkg_loja.regista_cliente(999999999, 'Leonor Dias', 'F', 1949, 'Lisboa');
pkg_loja.regista_cliente(100000000, 'Carla Dias', 'F', 1943, 'Aveiro');
pkg_loja.regista_cliente(110000000, 'Rui Agostinho', 'M', 1967, 'Lisboa');
pkg_loja.regista_cliente(120000000, 'Antonio Ferreira', 'M', 1978, 'Lisboa');
END;
/
--Visualizacao da tabela cliente apos os registos/inserts.
SELECT * FROM cliente;

--Tentativa de registo de um cliente com numero repetido.
BEGIN pkg_loja.regista_cliente(111111111, 'Maria Silva', 'F', 1979, 'Algarve'); END;
/
--Tentativa de registo de um cliente com um nome com mais carateres dos permitidos.
BEGIN pkg_loja.regista_cliente(111111112, 'Antonio Luis Santos da Costa', 'M', 1961, 'Lisboa'); END;
/
--Tentativa de registo de um cliente com um genero diferente de 'M' ou 'F'.
BEGIN pkg_loja.regista_cliente(111111113, 'Mario Cardoso', 'B', 1991, 'Lisboa'); END;
/
--Tentativa de registo de um cliente sem localidade.
BEGIN pkg_loja.regista_cliente(111111114, 'Andreia Sonia', 'F', 1994, NULL); END;
/
--Visualizacao da tabela cliente apos as tentativas falhadas de registos/inserts (nao devem ter ocorrido alteracoes na tabela).
SELECT * FROM cliente;


-----------------------------------------REGISTA PRODUTO-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--ASSINATURA DA FUNCAO: regista_produto(ean13_in, nome_in, categoria_in, preco_in, stock_in) 

--Registar produtos na loja.
BEGIN
pkg_loja.regista_produto(1111111111111, 'Bolo', 'Comida', 1.11, 11);
pkg_loja.regista_produto(2222222222222, 'Ovos', 'Comida', 2.22, 22);
pkg_loja.regista_produto(3333333333333, 'Camisa', 'Roupa', 33.33, 33);
pkg_loja.regista_produto(4444444444444, 'Casaco', 'Roupa', 44.44, 44);
pkg_loja.regista_produto(5555555555555, 'Verniz', 'Beleza', 5.55, 55);
pkg_loja.regista_produto(6666666666666, 'Batom', 'Beleza', 6.66, 66);
pkg_loja.regista_produto(7777777777777, 'Trela', 'Animais', 7.77, 77);
pkg_loja.regista_produto(8888888888888, 'Alpista', 'Animais', 8.88, 88);
pkg_loja.regista_produto(9999999999999, 'T-shirt', 'Roupa', 99.99, 99);
pkg_loja.regista_produto(1000000000000, 'Perfume', 'Beleza', 10.10, 10);
END;
/
--Visualizacao da tabela produto apos os registos/inserts.
SELECT * FROM produto;

--Tentativa de registo de um produto com numero repetido, mas com nome diferente.
BEGIN pkg_loja.regista_produto(1111111111111, 'Azeitonas', 'Comida', 1.11, 13); END;
/
--Tentativa de registo de um produto ja existente (com numero e nome repetido).
BEGIN pkg_loja.regista_produto(1111111111111, 'Bolo', 'Comida', 1.11, 13); END;
/
--Observacao do stock atualizado do produto apos ser reinserido.
SELECT ean13, nome, stock FROM produto P WHERE (P.ean13 = 1111111111111);

--Tentativa de registo de um produto com um numero de digitos no stock superior a precisao permitida.
BEGIN pkg_loja.regista_produto(1111111111112, 'Calças', 'Roupa', 200.2, 444444); END;
/
--Tentativa de registo de um produto com uma categoria diferente das aceites.
BEGIN pkg_loja.regista_produto(1111111111113, 'Caneta', 'Escola', 0.1, 20); END;
/
--Tentativa de registo de um produto sem nome.
BEGIN pkg_loja.regista_produto(1111111111113, NULL, 'Animais', 10.1, 10); END;
/
--Visualizacao da tabela produto apos as tentativas falhadas de registos/inserts (nao devem ter ocorrido alteracoes na tabela).
SELECT * FROM produto;


------------------------------------------REGISTA COMPRA-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--ASSINATURA DA FUNCAO: regista_compra(cliente_in, produto_in, unidades_in, fatura_in := NULL) -> NUMBER

--Regista uma fatura e cria 3 linhas para a mesma.
BEGIN
:fat_1 := pkg_loja.regista_compra(111111111, 3333333333333, 1);          --fat 1.1
:fat_1 := pkg_loja.regista_compra(111111111, 4444444444444, 2, :fat_1); --fat 1.2
:fat_1 := pkg_loja.regista_compra(111111111, 5555555555555, 3, :fat_1);  --fat 1.3
END;
/
--Visualizacao do numero da fatura criada.
PRINT fat_1;

--Regista as faturas com uma ou mais linhas.
BEGIN
--Uma fatura com varias linhas para um cliente.
:fat_2 := pkg_loja.regista_compra(222222222, 3333333333333, 1);         --fat 2.1
:fat_2 := pkg_loja.regista_compra(222222222, 5555555555555, 8, :fat_2); --fat 2.2
:fat_2 := pkg_loja.regista_compra(222222222, 9999999999999, 4, :fat_2); --fat 2.3

--Uma fatura com varias linhas para um cliente.
:fat_3 := pkg_loja.regista_compra(333333333, 5555555555555, 2);         --fat 3.1
:fat_3 := pkg_loja.regista_compra(333333333, 6666666666666, 2, :fat_3); --fat 3.1

--Varias faturas de uma linha para varios clientes.
:fat_4 := pkg_loja.regista_compra(444444444, 1111111111111, 1); --fat 4.1
:fat_5 := pkg_loja.regista_compra(555555555, 3333333333333, 5); --fat 5.1
:fat_6 := pkg_loja.regista_compra(666666666, 9999999999999, 1); --fat 6.1

--Uma fatura com uma linha para um cliente.
:fat_7 := pkg_loja.regista_compra(777777777, 5555555555555, 2); --fat 7.1

--Uma fatura com uma linha para um cliente.
:fat_8 := pkg_loja.regista_compra(888888888, 4444444444444, 4); --fat 8.1

--Uma fatura com varias linhas para um cliente.
:fat_9 := pkg_loja.regista_compra(100000000, 6666666666666, 2);         --fat 9.1
:fat_9 := pkg_loja.regista_compra(100000000, 2222222222222, 2, :fat_9); --fat 9.2

--Varias faturas para o mesmo cliente com 1 linha cada
:fat_10 := pkg_loja.regista_compra(110000000, 9999999999999, 1); --fat 10.1
:fat_11 := pkg_loja.regista_compra(110000000, 6666666666666, 1); --fat 11.1

--Varias faturas para o mesmo cliente com varias linhas cada
:fat_12 := pkg_loja.regista_compra(120000000, 9999999999999, 1);          --fat 12.1
:fat_12 := pkg_loja.regista_compra(120000000, 2222222222222, 2, :fat_12); --fat 12.2
:fat_13 := pkg_loja.regista_compra(120000000, 4444444444444, 1);          --fat 13.1
:fat_13 := pkg_loja.regista_compra(120000000, 6666666666666, 1, :fat_13); --fat 13.2
END;
/
-- Visualizacao das tabelas fatura e linhafatura apos os registos de compras/inserts.
SELECT * FROM fatura;
SELECT * FROM linhafatura;
-- Visualizacao da tabela produto, para verificacao da reducao dos respetivos stocks com as compras realizadas.
SELECT * FROM produto;

--Tentativa de registo de uma fatura sem cliente.
BEGIN :num_fat := pkg_loja.regista_compra(NULL, 3333333333333, 1); END;
/
--Tentativa de compra de mais unidades do que as disponiveis.
BEGIN :num_fat := pkg_loja.regista_compra(111111112, 3333333333333, 100); END;
/
--Tentativa de registar compra de um cliente que existe com 0 unidades.
BEGIN :num_fat := pkg_loja.regista_compra(111111111, 3333333333333, 0); END;
/
--Tentativa de registar compra de um cliente que nao existe.
BEGIN :num_fat := pkg_loja.regista_compra(111111113, 3333333333333, 1); END;
/
--Tentativa de registar a mesma compra 2 vezes (2 vezes a mesma linha de fatura).
BEGIN :num_fat := pkg_loja.regista_compra(111111111, 5555555555555, 3, :fat_1); END;
/
--Tentativa de inserir uma linha em uma fatura que ja existe mas com um cliente diferente do associado.
BEGIN :num_fat := pkg_loja.regista_compra(999999999, 6666666666666, 8, :fat_2); END;
/
--Tentativa de registar uma compra em uma fatura que nao existe na tabela fatura.
BEGIN :num_fat := pkg_loja.regista_compra(999999999, 5555555555555, 8, 55); END;
/
--Tentativa de registar uma compra de um produto a NULL.
BEGIN :num_fat := pkg_loja.regista_compra(999999999, NULL, 1); END;
/
--Tentativa de registar uma compra de um produto que nao existe na tabela produtos.
BEGIN :num_fat := pkg_loja.regista_compra(999999999, 1111111111112, 1); END;
/
-- Visualizacao das tabelas apos as excecoes (nao devem ter ocorrido alteracoes nas tabelas).
SELECT * FROM fatura;
SELECT * FROM linhafatura;
SELECT * FROM produto;


------------------------------------------REMOVE COMPRA------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--ASSINATURA DA FUNCAO: remove_compra(fatura_in, produto_in := NULL) -> NUMBER

--Remover uma compra de um produto da fatura 1 (tem 3 linhas, a fatura nao e removida).
BEGIN :num_fat := pkg_loja.remove_compra(:fat_1, 3333333333333); END;
/
--Visualizacao do numero restantes nessa fatura (devem restar 2 linhas).
PRINT num_fat;
--Verificacao do aumento do stock do porduto devolvido.
SELECT ean13, nome, stock FROM produto P WHERE (P.ean13 = 3333333333333);

--Remover todas as compras da fatura 2 (tem 2 linhas, a fatura e removida).
BEGIN :num_fat := pkg_loja.remove_compra(:fat_2); END;
/
--Remover uma compra de um produto de uma fatura que apenas tem uma linha (a fatura sera removida).
BEGIN :num_fat := pkg_loja.remove_compra(:fat_7, 5555555555555); END;
/
-- Visualizacao das tabelas apos serem removidas as compras.
SELECT * FROM fatura;
SELECT * FROM linhafatura;
SELECT * FROM produto;

--Tentativa de remover todas as compras de uma fatura que nao existe.
BEGIN :num_fat := pkg_loja.remove_compra(55); END;
/
--Tentativa de remover a compra de um produto de uma fatura NULL.
BEGIN :num_fat := pkg_loja.remove_compra(NULL, 5555555555555); END;
/
--Tentativa de remover todas as compras de uma fatura NULL.
BEGIN :num_fat := pkg_loja.remove_compra(NULL); END;
/
-- Visualizacao das tabelas apos as tentativas de remocao falhadas (as tabelas nao devem ter sofrido alteracoes).
SELECT * FROM fatura;
SELECT * FROM linhafatura;
SELECT * FROM produto;


------------------------------------------REMOVE PRODUTO-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--ASSINATURA DA FUNCAO: remove_produto(ean13_in) 

--Remover um produto (este esta na fatura 1 e 3, como todas tem 2 linhas, nenhuma fatura sera removida).
BEGIN pkg_loja.remove_produto(5555555555555); END;
/
--Remover um produto (este esta na fatura 4 que apenas tem 1 linha, a fatura sera tambem removida).
BEGIN pkg_loja.remove_produto(1111111111111); END;
/
--Remover um produto que nunca foi comprado.
BEGIN pkg_loja.remove_produto(8888888888888); END;
/
--Visualizacao das tabela apos as remocoes.
SELECT * FROM produto;
SELECT * FROM fatura;
SELECT * FROM linhafatura;

--Tentativa de remover um produto NULL.
BEGIN pkg_loja.remove_produto(NULL); END;
/
--Tentativa de remover um produto que nao existe.
BEGIN pkg_loja.remove_produto(1111111111112); END;
/
-- Visualizacao das tabelas apos as tentativas de remocao falhadas (as tabelas nao devem ter sofrido alteracoes).
SELECT * FROM produto;
SELECT * FROM fatura;
SELECT * FROM linhafatura;


------------------------------------------REMOVE CLIENTE-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--ASSINATURA DA FUNCAO: remove_cliente(nif_in) 

--Visualizacao da tabela dos clientes antes de remover algum.
SELECT * FROM cliente;

--Remover um cliente que tem apenas uma fatura com uma linha (a fatura e a linha sao removidas).
BEGIN pkg_loja.remove_cliente(111111111); END;
/
--Remover um cliente que tem apenas uma fatura com varias linhas (a fatura e as linhas sao removidas).
BEGIN pkg_loja.remove_cliente(100000000); END;
/
--Remover um cliente que tem varias faturas com apenas uma linha cada (as faturas e as linhas sao removidas).
BEGIN pkg_loja.remove_cliente(110000000); END;
/
--Remover um cliente que tem varias faturas com várias linha cada (as faturas e as linhas sao removidas).
BEGIN pkg_loja.remove_cliente(120000000); END;
/
--Remover um cliente que nunca realizou uma compra (nao tem nenhuma fatura associada).
BEGIN pkg_loja.remove_cliente(999999999); END;
/
--Visualizacao das tabelas apos as remocoes.
SELECT * FROM cliente;
SELECT * FROM fatura;
SELECT * FROM linhafatura;
SELECT * FROM produto;

--Tentativa de remover um cliente que nao existe.
BEGIN pkg_loja.remove_cliente(999999991); END;
/
--Tentativa de remover um cliente NULL.
BEGIN pkg_loja.remove_cliente(NULL); END;
/
-- Visualizacao das tabelas apos as tentativas de remocao falhadas (as tabelas nao devem ter sofrido alteracoes).
SELECT * FROM cliente;
SELECT * FROM fatura;
SELECT * FROM linhafatura;
SELECT * FROM produto;


------------------------------------------LISTA PRODUTOS-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--ASSINATURA DA FUNCAO: lista_produtos(categoria_in) -> CURSOR 

--Tentativa de obter a lista dos produtos mais comprados de uma categoria que nao existe.
BEGIN :lista := pkg_loja.lista_produtos('Jogos'); END;
/
--Tentativa de obter a lista dos produtos mais comprados de uma categoria NULL.
BEGIN :lista := pkg_loja.lista_produtos(NULL); END;
/

--Cursor com os produtos mais comprados da categoria Roupa.
BEGIN :lista_roupa := pkg_loja.lista_produtos('Roupa'); END;
/
--Visualizacao dos produtos mais comprados da categoria Roupa.
PRINT lista_roupa;

--Cursor com os produtos mais comprados da categoria Beleza.
BEGIN :lista_beleza := pkg_loja.lista_produtos('Beleza'); END;
/
--Visualizacao dos produtos mais comprados da categoria Beleza.
PRINT lista_beleza;

--Cursor com os produtos mais comprados da categoria Comida.
BEGIN :lista_comida := pkg_loja.lista_produtos('Comida'); END;
/
--Visualizacao dos produtos mais comprados da categoria Comida.
PRINT lista_comida;

--Cursor com os produtos mais comprados da categoria Animais.
BEGIN :lista_animais := pkg_loja.lista_produtos('Animais'); END;
/
--Visualizacao dos produtos mais comprados da categoria Animais.
PRINT lista_animais;


-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------