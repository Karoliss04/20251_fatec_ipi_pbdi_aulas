-- DO $$
-- BEGIN
--     -- CRIAÇÃO DE UM LOOP INFINITO, NÃO EXECUTE!!
--     LOOP
--         RAISE NOTICE 'Um loop simples...';
--     END LOOP;

-- END;
-- $$

DO $$
DECLARE 
    contador INT := 1;
BEGIN
    LOOP
        RAISE NOTICE '%', contador;
        contador := contador + 1;
        IF contador > 10 THEN 
            EXIT;
        END IF; 
    END LOOP;
END;
$$

DO $$
DECLARE
    contador INT := 1;
BEGIN
    LOOP 
        RAISE NOTICE '%', contador;
        contador := contador + 1;
        EXIT WHEN contador > 10; -- mesma coisa do outro cod só que usando EXIT WHEN 
    END LOOP;
END;
$$

-- IGNORANDO ITERAÇÕES COM CONTINUE
-- multiplos de 1 a 100
DO $$
DECLARE
    contador INT := 0;
BEGIN
    LOOP
        contador := contador + 1;
        EXIT WHEN contador > 100;

        IF contador % 7 = 0 THEN -- ignorando os multiplos de 7 
            CONTINUE;
        END IF;

        CONTINUE WHEN contador % 11 = 0; -- ignorando os multiplos de 11 utilizando o CONTINUE

        RAISE NOTICE '%', contador;
    END LOOP;
END;
$$

-- LOOPS ANINHADOS E RÓTULOS - APOSTILA 10 - AULA 01 / 04

DO $$
DECLARE
    i INT;
    j INT;
BEGIN
    i := 0;
    <<externo>>
    LOOP
        i := i + 1;
        EXIT WHEN i > 10;
        j := 1;
        <<interno>>
        LOOP
            RAISE NOTICE '% %', i, j;
            j := j + 1;
            EXIT externo WHEN j > 5;
        END LOOP;
    END LOOP;
END;
$$


DO $$
DECLARE
    i INT;
    j INT;
BEGIN
    i := 0;
    <<externo>>
    LOOP
        i := i + 1;
        EXIT WHEN i > 10;
        j := 1;
        <<interno>>
        LOOP
            RAISE NOTICE '% %', i, j;
            j := j + 1;
            CONTINUE externo WHEN j > 5;
        END LOOP;
    END LOOP;
END;
$$

-- USANDO O WHILE (MÉDIA DE UMA SALA)
DO $$
DECLARE
    nota INT;
    media NUMERIC(10, 2) := 0;
    contador INT := 0;
BEGIN
    -- [n, m]
    -- queremos o intervalo [-1, 10]
    SELECT valor_aleatorio_entre(0, 11) - 1 INTO nota;
    WHILE nota >= 0 LOOP
        RAISE NOTICE 'a nota é: %', nota;
        media := media + nota;
        contador := contador + 1;
        SELECT valor_aleatorio_entre(0, 11) - 1 INTO nota;
    END LOOP;
    IF contador > 0 THEN
        RAISE NOTICE 'Média: %', media / contador;
    ELSE 
        RAISE NOTICE 'Nenhuma nota gerada';
    END IF;
END;$$

CREATE OR REPLACE FUNCTION valor_aleatorio_entre (lim_inferior INT, lim_superior
INT) RETURNS INT AS
$$
BEGIN
RETURN FLOOR(RANDOM() * (lim_superior - lim_inferior + 1) + lim_inferior)::INT;
END;
$$ LANGUAGE plpgsql;

-- UTILIZANDO O LIMITADOR DE ALUNOS (MÉDIA DE UMA SALA)
DO $$
DECLARE
    nota INT;
    media NUMERIC(10, 2) := 0;
    contador INT := 1;
    total_alunos INT := 5;
BEGIN
    WHILE contador <= total_alunos LOOP
        SELECT valor_aleatorio_entre(0, 10) INTO nota;
        RAISE NOTICE 'a nota é: %', nota;
        media := media + nota;
        contador := contador + 1;
    END LOOP;
    RAISE NOTICE 'Média: %', media / contador;
END;
$$

-- FOR
DO $$ -- não precisa declarar variavel
BEGIN
    -- contar de 10, de 1 em 1
    -- intervalo fechado (1 e o 10 estao incluidos) [1, 10]
    FOR i IN 1..10 LOOP
        RAISE NOTICE '%', i;
    END LOOP;

    FOR i IN 10..1 LOOP -- LOOP INFINITO, POIS ELE FAZ A CONTA DA ESQUERDA PRA DIREITA
                            -- INFINITOS NUMEROS APÓS O 10, NUNCA CHEGARA NO 1
        RAISE NOTICE '%', i;
    END LOOP;

    -- CONTAGEM REGRESSIVA
    FOR i IN REVERSE 10..1 LOOP
        RAISE NOTICE '%', i;
    END LOOP;

    -- DE 1 A 50 DE 2 EM 2 
    FOR i IN 1..50 BY 2 LOOP -- por começar do 1, não mostrara o 50, e sim o 49
        RAISE NOTICE '%', i;
    END LOOP;

    
    FOR i IN REVERSE 50..1 BY 2 LOOP 
        RAISE NOTICE '%', i;
    END LOOP;
END; 
$$

-- CRIANDO A TABLESAMPLE
CREATE TABLE tb_aluno(
    cod_aluno SERIAL PRIMARY KEY, -- serial: autoincremento 1, 2, 3...
    nota INT
);

-- PREENCHENDO A TABELA 
DO $$
BEGIN
    FOR i IN 1..10 LOOP
        INSERT INTO tb_aluno
        (nota)
        VALUES
        (valor_aleatorio_entre(0, 10));
    END LOOP;
END; $$

-- VER A TABELA
SELECT * FROM tb_aluno;

DO $$
DECLARE 
    aluno RECORD; -- representa a linha da tabela (guarda seus valores para que possa consultar depois)
    media NUMERIC(10, 2) := 0;
    total_alunos INT;
BEGIN
    FOR aluno IN 
        SELECT * FROM tb_aluno -- para cada aluno gera uma linha
    LOOP
        RAISE NOTICE 'Nota do aluno %: %', 
        aluno.cod_aluno, aluno.nota; -- a cada iteração do loop pega uma linha 
        media := media + aluno.nota;
    END LOOP;
    SELECT COUNT(*) FROM tb_aluno INTO total_alunos;
    RAISE NOTICE 'média: %', media / total_alunos;
END; 
$$

DO $$
DECLARE
    valores INT[] := ARRAY[
        valor_aleatorio_entre(1, 10),
        valor_aleatorio_entre(1, 10),
        valor_aleatorio_entre(1, 10),
        valor_aleatorio_entre(1, 10),
        valor_aleatorio_entre(1, 10)
    ]; -- vetor de uma unica dimensão 
    valor INT;
    soma INT := 0;

BEGIN
    FOREACH valor IN ARRAY valores LOOP
        RAISE NOTICE 'Valor da vez: %', valor;
        soma := soma + valor;
    END LOOP;
    RAISE NOTICE 'Soma: %', soma;
END;
$$

-- FOREACH COM FATIAS (SLICE)
DO $$
DECLARE
     vetor INT[] := ARRAY[1, 2, 3];
     matriz INT[] := ARRAY[
        [1, 2, 3],
        [4, 5, 6],
        [7, 8, 9]
     ];
     var_aux INT; -- auxilia no vetor
     vet_aux INT[]; -- auxilia a matriz

BEGIN
    RAISE NOTICE 'SLICE %, vetor', 0;
    FOREACH var_aux IN ARRAY vetor LOOP
        RAISE NOTICE '%', var_aux;
    END LOOP;

    RAISE NOTICE 'SLICE %, vetor', 1;
    FOREACH vet_aux SLICE 1 IN ARRAY vetor LOOP
        RAISE NOTICE '%', vet_aux;
    END LOOP;

    RAISE NOTICE 'SLICE %, matriz', 0;
    FOREACH var_aux IN ARRAY matriz LOOP
        RAISE NOTICE '%', var_aux;
    END LOOP;

    RAISE NOTICE 'SLICE %, matriz', 1;
    FOREACH vet_aux SLICE 1 IN ARRAY matriz LOOP
        RAISE NOTICE '%', vet_aux;
    END LOOP;

    RAISE NOTICE 'SLICE %, matriz', 2;
    FOREACH vet_aux SLICE 2 IN ARRAY matriz LOOP
        RAISE NOTICE '%', vet_aux;
    END LOOP;
END; $$

DO $$
BEGIN
    RAISE NOTICE '%', 1 / 0;
    RAISE NOTICE 'acabou...';
EXCEPTION
    WHEN division_by_zero THEN
        RAISE NOTICE 'Não divida por zero';
END; $$

