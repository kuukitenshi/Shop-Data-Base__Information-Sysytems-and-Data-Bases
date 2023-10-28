-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- SIBD - 2022/23
-- Etapa 4 do Projeto - Pacote PL/SQL - Módulo Package Body PKB
-- Grupo 22 - Turma LEI01 - TP 11
-- Catariana Oliveira fc58209, Joana Deus fc58197, Laura Cunha fc58188, Sara Vasques fc58163
-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--
-- ------------------------------------------------TABELAS---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--      Cliente (nif,                   nome, genero, nascimento, localidade)
--      Produto (ean13,                 nome, categoria, preco, stock)
--       Fatura (numero,                data, cliente)
--  LinhaFatura (fatura, produto,       unidades)
-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

CREATE OR REPLACE PACKAGE BODY pkg_loja IS

----------------------------------------------------EXCEÇÕES-------------------------------------------------------------------------------------------------------
 
 --Função auxliar para tratamento de exceções. Caso receba uma mensagem específica como parâmetro irá lançar uma exceção personalizada
 --de acordo com a mensagem recebida, caso contrário obtém a mensagem de exceção do SQLERRM e torna-a mais inteligível/ personalizada.
  PROCEDURE error_msg (
    msg_especifica VARCHAR := NULL)
  IS
    msg VARCHAR(150);
    nome_coluna VARCHAR(40);
    nome_tabela VARCHAR(40);
    max_size VARCHAR(40);
  BEGIN
    IF (msg_especifica IS NULL) THEN --se não tiver parâmetro
      msg := SQLERRM;
      IF (SQLCODE = -02290) THEN --CHECKS--e.g: ORA-02290: check constraint (SYS.CK_CLIENTE_GENERO) violated
        IF (msg LIKE UPPER('%ck_cliente_nif%')) THEN
          RAISE_APPLICATION_ERROR(-20000, 'O nif do cliente tem de ser positivo e ter 9 digitos.');
        ELSIF (msg LIKE UPPER('%ck_cliente_genero%')) THEN
          RAISE_APPLICATION_ERROR(-20001, 'O genero do cliente tem de correponder a letra M ou F.');
        ELSIF (msg LIKE UPPER('%ck_cliente_nascimento%')) THEN
          RAISE_APPLICATION_ERROR(-20002, 'O ano da data de nascimento do cliente tem de ser um valor razoavel.');
        ELSIF (msg LIKE UPPER('%ck_produto_ean13%')) THEN
          RAISE_APPLICATION_ERROR(-20003, 'O ean13 do produto tem de ser positivo e ter 13 digitos.');
        ELSIF (msg LIKE UPPER('%ck_produto_categoria%')) THEN
          RAISE_APPLICATION_ERROR(-20004, 'A categoria do cliente tem de pertencer a: Comida, Roupa, Beleza, Animais.');
        ELSIF (msg LIKE UPPER('%ck_produto_preco%')) THEN
          RAISE_APPLICATION_ERROR(-20005, 'O preço do produto tem de ser suprior a 0.');
        ELSIF (msg LIKE UPPER('%ck_produto_stock%')) THEN
          RAISE_APPLICATION_ERROR(-20006, 'O stock do produto tem de ser maior ou igual a 0.');
        ELSIF (msg LIKE UPPER('%ck_fatura_numero%')) THEN
          RAISE_APPLICATION_ERROR(-20007, 'O numero da fatura tem de ser maior ou igual a 1.');
        ELSIF (msg LIKE UPPER('%ck_linhafatura_unidades%')) THEN
          RAISE_APPLICATION_ERROR(-20008, 'O numero de unidades compradas de um produto tem de ser superior a 0.');
        END IF;
      ELSIF (SQLCODE = -01400) THEN --NULL--e.g: ORA-01400: cannot insert NULL into ("SYS"."CLIENTE"."NOME")
        nome_tabela := SUBSTR(msg, INSTR(msg, '.',1, 1)+2, INSTR(msg, '.',1, 2)-INSTR(msg, '.',1, 1)-3 );
        nome_coluna := SUBSTR(msg, INSTR(msg, '.',1, 2)+2, INSTR(msg, ')',1, 1)-INSTR(msg, '.',1, 2)-3 );
        RAISE_APPLICATION_ERROR(-20009, 'Insira um valor diferente de NULL em ' || LOWER(nome_coluna) || ' da tabela ' || LOWER(nome_tabela) || '.');
      ELSIF (SQLCODE = -02291) THEN --FOREIGN KEY--e.g: ORA-02291: inegrity constraint (SYS.FK_FATURA_CLIENTE) violated-parent key not found
        nome_tabela := SUBSTR(msg, INSTR(msg, '_',1, 1)+1, INSTR(msg, '_',1, 2)-INSTR(msg, '_',1, 1)-1 );
        nome_coluna := SUBSTR(msg, INSTR(msg, '_',1, 2)+1, INSTR(msg, ')',1, 1)-INSTR(msg, '_',1, 2)-1 );
        RAISE_APPLICATION_ERROR(-20010, 'Erro na foreign key ' || LOWER(nome_coluna) || ' da tabela ' || LOWER(nome_tabela) || '. ' || INITCAP(nome_coluna) || ' nao existe na tabela de ' || LOWER(nome_tabela) ||'.');
      ELSIF (SQLCODE = -12899) THEN --TOO LARGE VALUE--e.g: ORA-12899:value too large for column "SYS"."CLIENTE"."NOME" (actual:26, maximum:20)
        nome_tabela := SUBSTR(msg, INSTR(msg, '.',1, 1)+2, INSTR(msg, '.',1, 2)-INSTR(msg, '.',1, 1)-3 );
        nome_coluna := SUBSTR(msg, INSTR(msg, '.',1, 2)+2, INSTR(msg, '(',1, 1)-INSTR(msg, '.',1, 2)-4 );
        max_size := SUBSTR(msg, INSTR(msg, ':', 1, 3)+2, LENGTH(msg) - INSTR(msg, ':', 1, 3) - 2 );
        RAISE_APPLICATION_ERROR(-20011, 'Insira um valor em ' || LOWER(nome_coluna) || ' da tabela ' || LOWER(nome_tabela) || ' que tenha no maximo ' || max_size ||' carateres.');
      ELSIF (SQLCODE = -01438) THEN --PRECISÃO NUMÉRICA EXCEDIDA
        RAISE_APPLICATION_ERROR(-20012, 'Insira um numero de dígitos que esteja dentro da precisao determinada pela coluna.');
      END IF;
    ELSE -- se tiver parâmetro
      IF (msg_especifica LIKE 'RC_igual_num') THEN
        RAISE_APPLICATION_ERROR(-20013, 'Ja existe um cliente com esse numero.');
      ELSIF (msg_especifica LIKE 'RP_igual_num_dif_nc') THEN
        RAISE_APPLICATION_ERROR(-20014, 'Existe um produto com esse numero, mas o nome ou a categoria nao correspondem.');
      ELSIF (msg_especifica LIKE 'RCO_fat_dif_cliente') THEN
        RAISE_APPLICATION_ERROR(-20015, 'A fatura na qual se quer registar a compra nao pertence a esse cliente.');
      ELSIF (msg_especifica LIKE 'RCO_uni_stock') THEN
        RAISE_APPLICATION_ERROR(-20016, 'Unidades em stock insuficientes.');
      ELSIF (msg_especifica LIKE 'RCO_fat_duplicada') THEN
        RAISE_APPLICATION_ERROR(-20017, 'Ja existe essa fatura, para esse cliente, com esse produto.');
      ELSIF (msg_especifica LIKE 'RL_rowcount') THEN
        RAISE_APPLICATION_ERROR(-20018, 'Nao existe uma linha na fatura com esse produto.');
      ELSIF (msg_especifica LIKE 'RAL_fat_no_lines') THEN
        RAISE_APPLICATION_ERROR(-20019, 'Nao existem linhas na fatura.');
      ELSIF (msg_especifica LIKE 'RVCO_fat_null') THEN
        RAISE_APPLICATION_ERROR(-20020, 'Insira um numero de fatura diferente de NULL.');
      ELSIF (msg_especifica LIKE 'RVCO_fat_n_existe') THEN
        RAISE_APPLICATION_ERROR(-20021, 'A fatura nao existe.');
      ELSIF (msg_especifica LIKE 'RVCO_rowcount') THEN
        RAISE_APPLICATION_ERROR(-20022, 'A fatura a remover nao existe.');
      ELSIF (msg_especifica LIKE 'RVP_prod_null') THEN
        RAISE_APPLICATION_ERROR(-20023, 'Insira um numero de produto diferente de NULL.');
      ELSIF (msg_especifica LIKE 'RVP_rowcount') THEN
        RAISE_APPLICATION_ERROR(-20024, 'O produto a remover nao existe.');
      ELSIF (msg_especifica LIKE 'RVP_cursor_vazio') THEN
        RAISE_APPLICATION_ERROR(-20025, 'Nao existem linhas de fatura.');
      ELSIF (msg_especifica LIKE 'RVC_cliente_null') THEN
        RAISE_APPLICATION_ERROR(-20026, 'Insira um nif de cliente diferente de NULL.');
      ELSIF (msg_especifica LIKE 'RVC_rowcount') THEN
        RAISE_APPLICATION_ERROR(-20027, 'O cliente a remover nao existe.');
      ELSIF (msg_especifica LIKE 'LP_categoria') THEN
        RAISE_APPLICATION_ERROR(-20028, 'Insira uma categoria valida (Comida, Roupa, Beleza, Animais) para a lista de produtos mais comprados.');
      ELSIF (msg_especifica LIKE 'LP_categoria_null') THEN
        RAISE_APPLICATION_ERROR(-20029, 'Insira uma categoria diferente de NULL para a lista de produtos mais comprados.');
      END IF;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN RAISE;
  END error_msg;


---------------------------------------------------REGISTA CLIENTE--------------------------------------------------------------------------------------------------------
  
  PROCEDURE regista_cliente (
    nif_in          IN cliente.nif%TYPE,
    nome_in         IN cliente.nome%TYPE,
    genero_in       IN cliente.genero%TYPE,
    nascimento_in   IN cliente.nascimento%TYPE,
    localidade_in   IN cliente.localidade%TYPE)
  IS
  BEGIN
    INSERT INTO cliente (nif, nome, genero, nascimento, localidade) 
      VALUES (nif_in, nome_in, genero_in, nascimento_in, localidade_in);
  EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN 
      pkg_loja.error_msg('RC_igual_num');
    WHEN OTHERS THEN
      BEGIN
        pkg_loja.error_msg();
        RAISE;
      END;
  END regista_cliente;

---------------------------------------------------REGISTA PRODUTO--------------------------------------------------------------------------------------------------------

  --Função auxiliar que devolve o número de linhas da tabela produto que têm o produto, que possui o ean13, nome e categoria dados.
  --Caso seja 0 significa que esse produto não existe.
  FUNCTION existe_produto (
    ean13_in       IN produto.ean13%TYPE,
    nome_in        IN produto.nome%TYPE,
    categoria_in   IN produto.categoria%TYPE)
    RETURN NUMBER
  IS
    ean13_prod NUMBER;
  BEGIN
    SELECT COUNT(ean13) INTO ean13_prod
      FROM produto
     WHERE (ean13 = ean13_in)
       AND (nome = nome_in)
       AND (categoria = categoria_in);
    RETURN ean13_prod;
  EXCEPTION
    WHEN OTHERS THEN
      BEGIN
        pkg_loja.error_msg();
        RAISE;
      END;
  END existe_produto;

  --------
  PROCEDURE regista_produto (
    ean13_in       IN produto.ean13%TYPE,
    nome_in        IN produto.nome%TYPE,
    categoria_in   IN produto.categoria%TYPE,
    preco_in       IN produto.preco%TYPE,
    stock_in       IN produto.stock%TYPE)
  IS
    ean13_atual produto.ean13%TYPE;
  BEGIN
    INSERT INTO produto (ean13, nome, categoria, preco, stock)
      VALUES (ean13_in, nome_in, categoria_in, preco_in, stock_in);
  EXCEPTION   
    WHEN DUP_VAL_ON_INDEX THEN
      IF (pkg_loja.existe_produto(ean13_in, nome_in, categoria_in) <> 0) THEN --verifica se o produto existe
        UPDATE produto
           SET stock = stock_in
         WHERE (ean13 = ean13_in);
      ELSE
        pkg_loja.error_msg('RP_igual_num_dif_nc');
      END IF;
    WHEN OTHERS THEN
      BEGIN
        pkg_loja.error_msg();
        RAISE;
      END;
  END regista_produto;

------------------------------------------------------REGISTA COMPRA-----------------------------------------------------------------------------------------------------

  --Função auxiliar que dado o produto e o número de unidades compradas ou devolvidas (consoante o caso),
  --atribui um novo stock (diminui ou aumenta, consoante se compre ou devolva, respetivamente) a esse produto.
  PROCEDURE set_stock (
    produto_in    IN linhafatura.produto%TYPE,
    unidades_in   IN linhafatura.unidades%TYPE)
  IS
  BEGIN
    UPDATE produto
       SET stock = (stock + unidades_in)--se o número de unidades entrar negativo no parâmetro irá reduzir o stock, caso contrário irá aumentar
     WHERE (ean13 = produto_in);
  EXCEPTION
    WHEN OTHERS THEN
      BEGIN
        pkg_loja.error_msg();
        RAISE;
      END;
  END set_stock;

  ----------
  --Função auxiliar que dado o produto devolve o seu stock atual.
  FUNCTION get_stock_atm (
    produto_in IN linhafatura.produto%TYPE)
    RETURN NUMBER
  IS
    stock_atual produto.ean13%TYPE;
  BEGIN
    SELECT stock INTO stock_atual
      FROM produto
     WHERE (ean13 = produto_in);
    RETURN stock_atual;
  EXCEPTION
    WHEN OTHERS THEN
      BEGIN
        pkg_loja.error_msg();
        RAISE;
      END;
  END get_stock_atm;

  ----------
  --Função auxiliar que verifica se uma dada fatura pertence a um dado cliente.
  FUNCTION cliente_associado_fat (
    cliente_in IN fatura.cliente%TYPE,
    fatura_in  IN linhafatura.fatura%TYPE)
    RETURN BOOLEAN
  IS
    nif_cliente_fat NUMBER;
  BEGIN
    SELECT cliente INTO nif_cliente_fat
      FROM fatura
     WHERE (numero = fatura_in);
    RETURN nif_cliente_fat = cliente_in;
  EXCEPTION
    WHEN OTHERS THEN
      BEGIN
        pkg_loja.error_msg();
        RAISE;
      END;
  END cliente_associado_fat;

  ----------
  FUNCTION regista_compra (
    cliente_in    IN fatura.cliente%TYPE,
    produto_in    IN linhafatura.produto%TYPE,
    unidades_in   IN linhafatura.unidades%TYPE,
    fatura_in     IN linhafatura.fatura%TYPE := NULL)
    RETURN NUMBER
    IS        
      num_fat fatura.numero%TYPE;
    BEGIN
      IF (fatura_in IS NULL) THEN --se não existir número de fatura, gera número e insere linha      
        num_fat := seq_numero_fatura.NEXTVAL;
        INSERT INTO fatura (numero, data, cliente) 
          VALUES (num_fat, SYSDATE, cliente_in);
        INSERT INTO linhafatura (fatura, produto, unidades) 
          VALUES (num_fat, produto_in, unidades_in);
        pkg_loja.set_stock(produto_in, -unidades_in); --reduz o stock da loja
      ELSE
        num_fat := fatura_in;
        INSERT INTO linhafatura (fatura, produto, unidades) --se existe número de fatura e pertence a esse cliente, insere linha
          VALUES (num_fat, produto_in, unidades_in);
        IF(NOT pkg_loja.cliente_associado_fat(cliente_in, num_fat)) THEN 
            pkg_loja.error_msg('RCO_fat_dif_cliente');
        ELSE
          pkg_loja.set_stock(produto_in, -unidades_in);
        END IF;
      END IF;
      IF (pkg_loja.get_stock_atm(produto_in) < unidades_in) THEN --verifica se existem produtos em stock 
        pkg_loja.error_msg('RCO_uni_stock'); --caso falhe, os inserts são revertidos automaticamente 
      END IF;
    RETURN num_fat;
  EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN 
      pkg_loja.error_msg('RCO_fat_duplicada');
    WHEN OTHERS THEN
      BEGIN
        pkg_loja.error_msg();
        RAISE;
      END;
  END regista_compra;

-----------------------------------------------------REMOVE COMPRA------------------------------------------------------------------------------------------------------

  --Função auxiliar que obtem o número de unidades que foram compradas de um dado produto (unidades a devolver).
  FUNCTION num_unidades (
    produto_in    IN linhafatura.produto%TYPE,
    fatura_in     IN linhafatura.fatura%TYPE)
    RETURN NUMBER
  IS
    num_uni_prod NUMBER;
  BEGIN
    SELECT unidades INTO num_uni_prod
      FROM linhafatura
     WHERE (fatura = fatura_in)
       AND (produto = produto_in);
    RETURN num_uni_prod;
  EXCEPTION
    WHEN OTHERS THEN
      BEGIN
        pkg_loja.error_msg();
        RAISE;
      END;
  END num_unidades;

  ----------
  --Função auxiliar que remove uma linha da fatura.
  PROCEDURE remove_linha (
    produto_in    IN linhafatura.produto%TYPE,
    fatura_in     IN linhafatura.fatura%TYPE)
  IS
  BEGIN
    DELETE FROM linhafatura 
     WHERE (fatura = fatura_in) 
       AND (produto = produto_in);
    IF (SQL%ROWCOUNT = 0) THEN -- Verifica se houve linhas afetadas pelo comando DELETE.
      pkg_loja.error_msg('RL_rowcount');
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      BEGIN
        pkg_loja.error_msg();
        RAISE;
      END;
  END remove_linha;

  ----------
  --Função auxiliar que conta o número de linhas existentes numa fatura.
  FUNCTION fatura_num_linhas (
    fatura_in     IN fatura.numero%TYPE)
    RETURN NUMBER
  IS
    num_linhas_fat NUMBER;
  BEGIN
    SELECT COUNT(*) INTO num_linhas_fat
      FROM linhafatura
     WHERE (fatura = fatura_in);
    RETURN num_linhas_fat;
  EXCEPTION
    WHEN OTHERS THEN
      BEGIN
        pkg_loja.error_msg();
        RAISE;
      END;
  END fatura_num_linhas;

  ------------------------
  --Função auxiliar que conta o número de linhas da tabela fatura que possuem o número de fatura dado.
  --Caso seja 0 significa que essa fatura não existe.
  FUNCTION existe_fatura (
    fatura_in IN linhafatura.fatura%TYPE)
    RETURN NUMBER
  IS
    fat_num NUMBER;
  BEGIN
    SELECT COUNT(numero) INTO fat_num
      FROM fatura
     WHERE (numero = fatura_in);
    RETURN fat_num;
  EXCEPTION
    WHEN OTHERS THEN
      BEGIN
        pkg_loja.error_msg();
        RAISE;
      END;
  END existe_fatura;

  ----------
  --Função auxiliar que remove todas as linhas de uma dada fatura, fazendo uso do remove_compra.
  PROCEDURE remove_all_lines (
    fatura_in IN linhafatura.fatura%TYPE)
  IS
    CURSOR cursor_linhas IS SELECT fatura, produto FROM linhafatura FOR UPDATE;
    TYPE tabela_local_linhas IS TABLE OF cursor_linhas%ROWTYPE;
    linhafaturas tabela_local_linhas;
    linhas_fat NUMBER;
  BEGIN
    OPEN cursor_linhas;
    FETCH cursor_linhas BULK COLLECT INTO linhafaturas; --contém todas as linhas selecionadas da tabela linhafatura
    CLOSE cursor_linhas;
    IF (linhafaturas.COUNT > 0) THEN
      FOR posicao_atual IN linhafaturas.FIRST .. linhafaturas.LAST LOOP
        IF (linhafaturas(posicao_atual).fatura = fatura_in) THEN
          linhas_fat := pkg_loja.remove_compra(fatura_in, linhafaturas(posicao_atual).produto);
        END IF;
      END LOOP;
    ELSE
      pkg_loja.error_msg('RAL_fat_no_lines');
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      BEGIN
        IF (cursor_linhas%ISOPEN) THEN
          CLOSE cursor_linhas;
        END IF;
        pkg_loja.error_msg();
        RAISE;
      END;
  END remove_all_lines;

  ----------
  FUNCTION remove_compra (
    fatura_in     IN linhafatura.fatura%TYPE,
    produto_in    IN linhafatura.produto%TYPE := NULL)
    RETURN NUMBER
    IS
      num_linhas_fatura NUMBER;
    BEGIN
      IF(fatura_in IS NULL) THEN --se o parâmetro for NULL, lança exceção
        pkg_loja.error_msg('RVCO_fat_null');
      ELSIF(pkg_loja.existe_fatura(fatura_in) = 0) THEN --verifica se a fatura existe
        pkg_loja.error_msg('RVCO_fat_n_existe');
      ELSE
        IF (produto_in IS NULL) THEN
          pkg_loja.remove_all_lines(fatura_in);
          RETURN 0;
        ELSE
          pkg_loja.set_stock(produto_in, pkg_loja.num_unidades(produto_in,fatura_in)); --update do stock loja com as unidades devolvidas
          pkg_loja.remove_linha(produto_in, fatura_in);                                --remove a linha de fatura com esse produto
          num_linhas_fatura := pkg_loja.fatura_num_linhas(fatura_in);                  --número de linhas da fatura após remover a linha
          IF (num_linhas_fatura = 0) THEN                                              --se a fatura não tiver mais linhas, é removida
              DELETE FROM fatura WHERE (numero = fatura_in);
              IF (SQL%ROWCOUNT = 0) THEN
                pkg_loja.error_msg('RVCO_rowcount');
              END IF;
          END IF; 
        RETURN num_linhas_fatura;
        END IF;
      END IF;
  EXCEPTION
    WHEN OTHERS THEN
      BEGIN
        pkg_loja.error_msg();
        RAISE;
      END;
  END remove_compra;


---------------------------------------------------REMOVE PRODUTO-------------------------------------------------------------------------------------------

  PROCEDURE remove_produto (
    ean13_in IN linhafatura.produto%TYPE)
  IS
    CURSOR cursor_linhasPro IS SELECT fatura, produto FROM linhafatura FOR UPDATE;
    TYPE tabela_local_linhasPro IS TABLE OF cursor_linhasPro%ROWTYPE;
    linhafaturas tabela_local_linhasPro;
    remov_compra_var NUMBER;
  BEGIN
    IF(ean13_in IS NULL) THEN
      pkg_loja.error_msg('RVP_prod_null');
    END IF;
    OPEN cursor_linhasPro;
    FETCH cursor_linhasPro BULK COLLECT INTO linhafaturas;
    CLOSE cursor_linhasPro;
    IF (linhafaturas.COUNT > 0) THEN --caso tenha linhas de fatura
      FOR posicao_atual IN linhafaturas.FIRST .. linhafaturas.LAST LOOP
        IF (linhafaturas(posicao_atual).produto = ean13_in) THEN
          remov_compra_var := pkg_loja.remove_compra(linhafaturas(posicao_atual).fatura, ean13_in); --remove todas as compras desse produto
        END IF;
      END LOOP;
      DELETE FROM produto WHERE (ean13 = ean13_in); --remove o produto
      IF (SQL%ROWCOUNT = 0) THEN
        pkg_loja.error_msg('RVP_rowcount');
      END IF;
    ELSE
      pkg_loja.error_msg('RVP_cursor_vazio');
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      BEGIN
        IF (cursor_linhasPro%ISOPEN) THEN
          CLOSE cursor_linhasPro;
        END IF;
        pkg_loja.error_msg();
        RAISE;
      END;
  END remove_produto;

--------------------------------------------------------REMOVE CLIENTE-------------------------------------------------------------------------------------------
  
  PROCEDURE remove_cliente (
    nif_in IN cliente.nif%TYPE)
  IS
    CURSOR cursor_faturas_do_cliente IS SELECT cliente, numero FROM fatura FOR UPDATE; -- obtém todas as faturas com o cliente dado
    TYPE tabela_local_faturas_cl IS TABLE OF cursor_faturas_do_cliente%ROWTYPE;
    faturas tabela_local_faturas_cl;
    faturas_cliente NUMBER;
  BEGIN
    IF(nif_in IS NULL) THEN
      pkg_loja.error_msg('RVC_cliente_null');
    END IF;
    OPEN cursor_faturas_do_cliente;
    FETCH cursor_faturas_do_cliente BULK COLLECT INTO faturas;
    CLOSE cursor_faturas_do_cliente;
    IF (faturas.COUNT > 0) THEN 
      FOR fatura_atual IN faturas.FIRST .. faturas.LAST LOOP --se o cliente compras remove todas as compras deste
        IF (faturas(fatura_atual).cliente = nif_in) THEN
          faturas_cliente := pkg_loja.remove_compra(faturas(fatura_atual).numero);
        END IF;
      END LOOP;
    END IF;
    DELETE FROM cliente WHERE (nif = nif_in); --remove o cliente
    IF (SQL%ROWCOUNT = 0) THEN
      pkg_loja.error_msg('RVC_rowcount');
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      BEGIN
        IF (cursor_faturas_do_cliente%ISOPEN) THEN
          CLOSE cursor_faturas_do_cliente;
        END IF;
        pkg_loja.error_msg();
        RAISE;
      END;
  END remove_cliente;

-----------------------------------------------------LISTA PRODUTOS-------------------------------------------------------------------------------------------
  
  FUNCTION lista_produtos (
    categoria_in IN produto.categoria%TYPE)
    RETURN SYS_REFCURSOR
  IS
    cursor_produtos SYS_REFCURSOR;
  BEGIN
    IF (categoria_in NOT IN ('Beleza', 'Animais', 'Roupa', 'Comida')) THEN
      pkg_loja.error_msg('LP_categoria');
    ElSIF (categoria_in IS NULL) THEN
      pkg_loja.error_msg('LP_categoria_null');
    ELSE
      OPEN cursor_produtos FOR
        SELECT P.ean13, P.nome, P.preco, NVL(SUM(L.unidades), 0) AS total_vendido
          FROM produto P LEFT JOIN linhafatura L ON L.produto = P.ean13
        WHERE (P.categoria = categoria_in)
        GROUP BY P.ean13, P.nome, P.preco
        ORDER BY total_vendido DESC;
      RETURN cursor_produtos;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      BEGIN
        pkg_loja.error_msg();
        RAISE;
      END;
  END lista_produtos;

--------------------------------------------------------------------------------------------------------------------------------------------------
END pkg_loja;
/
--------------------------------------------------------------------------------------------------------------------------------------------------