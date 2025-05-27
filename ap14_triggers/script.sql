CREATE TABLE tb_teste_trigger(
    cod_teste_trigger SERIAL PRIMARY KEY,
    texto VARCHAR(200)
);

-- FUNCTION: tipo um procedure mas tem direito de falar return 
-- "fn_antes_de_um_insert()" não é uma boa pratica deixar esse nome, por que ela pode ter essa função em uma tabala e na outra ser diferente 
CREATE OR REPLACE FUNCTION fn_antes_de_um_insert()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    RAISE NOTICE 'Trigger foi chamado antes do INSERT!';
    RETURN NULL;
END;
$$

CREATE OR REPLACE TRIGGER tg_antes_do_insert
BEFORE INSERT ON tb_teste_trigger
FOR EACH STATEMENT 
-- AQUI PODE FALAR FUNCTION OU PROCEDURE (MAS NÃO ROUTINE)
EXECUTE FUNCTION fn_antes_de_um_insert();

-- retorna 'trigger foi chamado antes do insert' se estiver realmente vinculado
INSERT INTO tb_teste_trigger(texto) 
VALUES('testando trigger')

CREATE OR REPLACE FUNCTION fn_depois_de_um_insert()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    RAISE NOTICE 'Trigger foi chamado depois do INSERT!';
    RETURN NULL; 
END;
$$

CREATE OR REPLACE TRIGGER tg_depois_de_um_insert
AFTER INSERT ON tb_teste_trigger
FOR STATEMENT
EXECUTE FUNCTION fn_depois_de_um_insert();

INSERT INTO tb_teste_trigger
(texto) VALUES ('Testando trigger');

CREATE OR REPLACE TRIGGER tg_antes_do_insert2
BEFORE INSERT ON tb_teste_trigger
FOR EACH STATEMENT
EXECUTE PROCEDURE fn_antes_de_um_insert();

CREATE OR REPLACE TRIGGER tg_depois_de_um_insert2
AFTER INSERT ON tb_teste_trigger
FOR EACH STATEMENT
EXECUTE PROCEDURE fn_depois_de_um_insert();

INSERT INTO tb_teste_trigger
(texto) VALUES ('Testando trigger');

DELETE FROM tb_teste_trigger;

select * from tb_teste_trigger

select * from tb_teste_trigger_cod_teste_trigger_seq;

ALTER SEQUENCE tb_teste_trigger_cod_teste_trigger_seq
RESTART WITH 1;

DROP TRIGGER IF EXISTS tg_antes_do_insert2
ON tb_teste_trigger;

DROP TRIGGER IF EXISTS tg_depois_de_um_insert2
ON tb_teste_trigger;


CREATE OR REPLACE TRIGGER tg_antes_de_um_insert
BEFORE INSERT OR UPDATE ON tb_teste_trigger
FOR EACH ROW 
-- AQUI PODE FALAR FUNCTION OU PROCEDURE (MAS NÃO ROUTINE)
EXECUTE FUNCTION fn_antes_de_um_insert('Antes: V1', 'Antes: V2');

DROP TRIGGER IF EXISTS tg_antes_do_insert
ON tb_teste_trigger;

CREATE OR REPLACE TRIGGER tg_depois_de_um_insert
AFTER INSERT OR UPDATE ON tb_teste_trigger
FOR EACH ROW
EXECUTE FUNCTION fn_depois_de_um_insert(
    'Depois: V1', 'Depois: V2', 'Depois: V3'
);

CREATE OR REPLACE FUNCTION fn_antes_de_um_insert()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    RAISE NOTICE 'Estamos no trigger BEFORE';
    RAISE NOTICE 'OLD: %', OLD;
    RAISE NOTICE 'NEW: %', NEW;
    RAISE NOTICE 'OLD.texto: %', OLD.texto;
    RAISE NOTICE 'NEW.texto: %', NEW.texto;
    RAISE NOTICE 'TG_NAME: %', TG_NAME;
    RAISE NOTICE 'TG_LEVEL: %', TG_LEVEL;
    RAISE NOTICE 'TG_WHEN: %', TG_WHEN;
    RAISE NOTICE 'TG_TABLE_NAME: %', TG_TABLE_NAME;
    FOR i in 0..TG_NARGS - 1 LOOP
        RAISE NOTICE '%',TG_ARGV[i];
    END LOOP;
    RETURN NEW;
END;
$$

CREATE OR REPLACE FUNCTION fn_depois_de_um_insert()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    RAISE NOTICE 'Estamos no trigger AFTER';
    RAISE NOTICE 'OLD: %', OLD;
    RAISE NOTICE 'NEW: %', NEW;
    RAISE NOTICE 'OLD.texto: %', OLD.texto;
    RAISE NOTICE 'NEW.texto: %', NEW.texto;
    RAISE NOTICE 'TG_NAME: %', TG_NAME;
    RAISE NOTICE 'TG_LEVEL: %', TG_LEVEL;
    RAISE NOTICE 'TG_WHEN: %', TG_WHEN;
    RAISE NOTICE 'TG_TABLE_NAME: %', TG_TABLE_NAME;
    FOR i in 0..TG_NARGS - 1 LOOP
        RAISE NOTICE '%',TG_ARGV[i];
    END LOOP; 
    RETURN NEW;
END;
$$

INSERT INTO tb_teste_trigger
(texto) VALUES('oi de novo');

SELECT * FROM tb_teste_trigger;

UPDATE tb_teste_trigger SET texto='texto atualizado'
WHERE cod_teste_trigger IN (2,3);

