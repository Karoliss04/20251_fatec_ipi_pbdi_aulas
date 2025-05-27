-- CRIANDO 
 CREATE OR REPLACE PROCEDURE sp_ola_procedures()
 LANGUAGE plpgsql
 AS $$
 BEGIN
 RAISE NOTICE 'Olá, procedures';
 END;
 $$;

-- CHAMANDO
 CALL sp_ola_procedures( );

--
CREATE OR REPLACE PROCEDURE sp_ola_usuario (p_nome VARCHAR(200))
 LANGUAGE plpgsql
 AS $$
 BEGIN
 RAISE NOTICE 'Olá, %', p_nome;
 RAISE NOTICE 'Olá, %', $1;
 END;
 $$;

 CALL sp_ola_usuario('Pedro');
 
 --
CREATE OR REPLACE PROCEDURE sp_acha_maior (IN valor1 INT, valor2 INT)
 LANGUAGE plpgsql
 AS $$
 BEGIN
 IF valor1 > valor2 THEN
 RAISE NOTICE '% é o maior', $1;
 ELSE
 RAISE NOTICE '% é o maior', $2;
 END IF;
 END;
 $$

 CALL sp_acha_maior (2, 3);

--
  DROP PROCEDURE IF EXISTS sp_acha_maior;

--
   CREATE OR REPLACE PROCEDURE sp_acha_maior (OUT resultado INT, IN valor1 INT, IN valor2 INT)
 LANGUAGE plpgsql
 AS $$
 BEGIN
    CASE
        WHEN valor1 > valor2 THEN
        $1 := valor1;
        ELSE
        resultado := valor2;
    END CASE;
 END;
 $$

--
 DO $$
 DECLARE
 resultado INT;
 BEGIN
    CALL sp_acha_maior (resultado, 2, 3);
    RAISE NOTICE '% é o maior', resultado;
 END;
 $$

DROP PROCEDURE IF EXISTS sp_acha_maior;

--
CREATE OR REPLACE PROCEDURE sp_acha_maior (INOUT valor1 INT, IN valor2 INT)
 LANGUAGE plpgsql
 AS $$
 BEGIN
    IF valor2 > valor1 THEN
    valor1 := valor2;
    END IF;
 END;
 $$

 DO
 $$
 DECLARE
    valor1 INT := 2;
    valor2 INT := 3;
 BEGIN
    CALL sp_acha_maior(valor1, valor2);
    RAISE NOTICE '% é o maior', valor1;
END;
 $$

--
 CREATE OR REPLACE PROCEDURE sp_calcula_media ( VARIADIC  valores INT [])
 LANGUAGE plpgsql
 AS $$
 DECLARE
    media NUMERIC(10, 2) := 0;
    valor INT;
BEGIN
    FOREACH valor IN ARRAY valores LOOP
    media := media + valor;
    END LOOP;
 RAISE NOTICE 'A média é %', media / array_length(valores, 1);
 END;
 $$

 CALL sp_calcula_media(1);

-- CRIANDO O RESTAURANTE

 DROP TABLE tb_cliente;
 CREATE TABLE tb_cliente (
    cod_cliente SERIAL PRIMARY KEY,
    nome VARCHAR(200) NOT NULL
 );
DROP TABLE IF EXISTS tb_pedido;
CREATE TABLE IF NOT EXISTS tb_pedido(
    cod_pedido SERIAL PRIMARY KEY,
    data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    data_modificacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
status VARCHAR DEFAULT 'aberto',
cod_cliente INT NOT NULL,
CONSTRAINT fk_cliente FOREIGN KEY (cod_cliente) REFERENCES
tb_cliente(cod_cliente)
);

SELECT * FROM tb_pedido;

CREATE TABLE tb_tipo_item(
 cod_tipo SERIAL PRIMARY KEY,
 descricao VARCHAR(200) NOT NULL
);

  INSERT INTO tb_tipo_item (descricao) VALUES ('Bebida'), ('Comida');

CREATE TABLE IF NOT EXISTS tb_item(
    cod_item SERIAL PRIMARY KEY,
    descricao VARCHAR(200) NOT NULL,
    valor NUMERIC (10, 2) NOT NULL,
    cod_tipo INT NOT NULL,
    CONSTRAINT fk_tipo_item FOREIGN KEY (cod_tipo) REFERENCES
    tb_tipo_item(cod_tipo)
);

INSERT INTO tb_item (descricao, valor, cod_tipo) VALUES
('Refrigerante', 7, 1), ('Suco', 8, 1), ('Hamburguer', 12, 2), ('Batata frita', 9, 2);

 SELECT * FROM tb_item;

CREATE TABLE IF NOT EXISTS tb_item_pedido(
    cod_item_pedido SERIAL PRIMARY KEY,
    cod_item INT,
    cod_pedido INT,
    CONSTRAINT fk_item FOREIGN KEY (cod_item) REFERENCES tb_item (cod_item),
    CONSTRAINT fk_pedido FOREIGN KEY (cod_pedido) REFERENCES tb_pedido
    (cod_pedido)
);

CREATE OR REPLACE PROCEDURE sp_cadastrar_cliente (IN nome VARCHAR(200), IN
 p_cod_cliente INT DEFAULT NULL)
 LANGUAGE plpgsql
 AS $$
 BEGIN
    IF p_cod_cliente IS NULL THEN
    INSERT INTO tb_cliente (nome) VALUES (p_nome);
    ELSE
    INSERT INTO tb_cliente (cod_cliente, nome) VALUES (p_cod_cliente, p_nome);
    END IF;
 END;
 $$

 -- Inserção de um pedido sem itens

CREATE OR REPLACE PROCEDURE sp_criar_pedido(
    OUT p_cod_pedido INT, IN p_cod_cliente INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO tb_pedido(cod_cliente) VALUES (p_cod_cliente);
    SELECT LASTVAL() INTO p_cod_pedido;
END;
$$

INSERT INTO tb_cliente (nome) VALUES ('Ana Silva');
SELECT * FROM tb_cliente;

DO $$
DECLARE
    v_cod_pedido INT;
    v_cod_cliente INT;
BEGIN
    SELECT c.cod_cliente FROM tb_cliente c 
     WHERE nome LIKE 'Ana Silva' INTO v_cod_cliente;
    CALL sp_criar_pedido(v_cod_pedido, v_cod_cliente); -- parametro que roda no modo OUT
    RAISE NOTICE 'Código do pedido recém criado: %', v_cod_pedido; 
END;
$$

SELECT * FROM tb_pedido;

-- ADICIONA ITEM AO PEDIDO 
-- liga o item ao pedido

CREATE OR REPLACE PROCEDURE sp_adicionar_item_a_pedido(
    IN p_cod_item INT, IN p_cod_pedido INT
    )
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO tb_item_pedido(cod_item, cod_pedido)
    VALUES($1, $2);
    UPDATE tb_pedido p SET
        data_modificacao = current_timestamp
        WHERE p.cod_pedido = $2;
END;
$$

CALL sp_adicionar_item_a_pedido(1, 8);
select * from tb_item;

CREATE OR REPLACE PROCEDURE sp_calcular_valor_de_um_pedido(
    IN p_cod_pedido INT, OUT p_valor_total INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    SELECT SUM(i.valor) FROM 
    tb_pedido p
    INNER JOIN tb_item_pedido ip 
    ON p.cod_pedido = ip.cod_pedido
    INNER JOIN tb_item i 
    ON ip.cod_item = i.cod_item
    WHERE p.cod_pedido = p_cod_pedido
    INTO $2;
END;
$$


-- COD DA AULA QUE FALTEI -- 20 / 05

-- CREATE OR REPLACE PROCEDURE sp_calcular_troco(
--     OUT p_troco INT,
--     IN p_valor_a_pagar INT,
--     IN p_valor_total INT
-- ) LANGUAGE plpgsql
-- AS $$
-- BEGIN
--     p_troco := p_valor_a_pagar - p_valor_total;
-- END;
-- $$

-- CREATE OR REPLACE PROCEDURE sp_fechar_pedido(
--     IN p_valor_a_pagar INT,
--     IN p_cod_pedido INT
-- )   LANGUAGE plpgsql
-- AS $$
-- DECLARE
--     v_valor_total INT;
-- BEGIN
--     CALL sp_calcular_valor_de_um_pedido(
--         p_cod_pedido,
--         v_valor_total
--     );
--     IF p_valor_a_pagar < v_valor_total THEN
--         RAISE NOTICE 'R$% insuficiente para pagar a conta de R$%',
--         p_valor_a_pagar,
--         v_valor_total;
--     ELSE
--         UPDATE tb_pedido p SET
--         data_modificacao = CURRENT_TIMESTAMP,
--         status = 'fechado'
--         WHERE p.cod_pedido = p_cod_pedido;

--     END IF;
-- END;
-- $$

-- CONFERIR VALOR DO V_COD_PEDIDO 
SELECT * FROM tb_item_pedido -- 8

DO $$
DECLARE
    v_troco INT;
    v_valor_total INT;
    v_valor_a_pagar INT := 100;
    v_cod_pedido INT := 8; -- o de todo mundo esta 1, mas o meu é 8
BEGIN
    CALL sp_calcular_valor_de_um_pedido(
        v_cod_pedido, 
        v_valor_total
    );
    CALL sp_calcular_troco(
        v_troco,
        v_valor_a_pagar,
        v_valor_total
    );
    RAISE NOTICE
        'A conta foi de R$% e você pagou R$%. Troco: R$%',
        v_valor_total, v_valor_a_pagar, v_troco;
END;
$$

DO $$
DECLARE
    v_cod_pedido INT := 8;
BEGIN
    CALL sp_fechar_pedido(200, v_cod_pedido);
END;
$$

DO $$
DECLARE
    v_valor_total INT;
    v_cod_pedido INT := 8;
BEGIN 
    CALL sp_calcular_valor_de_um_pedido(8, v_valor_total);
    RAISE NOTICE 'Total do pedido %: R$%', v_cod_pedido, v_valor_total;
END;
$$

