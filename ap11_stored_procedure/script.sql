
 CREATE OR REPLACE PROCEDURE sp_ola_procedures()
 LANGUAGE plpgsql
 AS $$
 BEGIN
 RAISE NOTICE 'Olá, procedures';
 END;
 $$;

 CALL sp_ola_procedures( );

CREATE OR REPLACE PROCEDURE sp_ola_usuario (p_nome VARCHAR(200))
 LANGUAGE plpgsql
 AS $$
 BEGIN
 RAISE NOTICE 'Olá, %', p_nome;
 RAISE NOTICE 'Olá, %', $1;
 END;
 $$;

 CALL sp_ola_usuario('Pedro');
 
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

  DROP PROCEDURE IF EXISTS sp_acha_maior;

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

 DO $$
 DECLARE
 resultado INT;
 BEGIN
 CALL sp_acha_maior (resultado, 2, 3);
 RAISE NOTICE '% é o maior', resultado;
 END;
 $$

DROP PROCEDURE IF EXISTS sp_acha_maior;

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

