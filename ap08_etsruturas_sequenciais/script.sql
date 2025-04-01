-- CREATE DATABASE "20251_fatec_ipi_pbdi_karolinap";

DO
$$
BEGIN 
     RAISE NOTICE ''Meu primeiro bloquinho anônimo'';
END;
$$


-- PLACEHOLDERS DE EXPRESSÕES EM STRING 
DO
$$
BEGIN
     RAISE NOTICE '% + % = %', 2, 2, 2 + 2;
END;
$$

-- VARIAVEIS 

DO
$$
DECLARE
     v_codigo INTEGER := 1;
     v_nome_completo VARCHAR(200) := 'João';
     v_salario NUMERIC(11, 2) := 20.5;
BEGIN
     RAISE NOTICE 'Meu código é %, me chamo % e meu salário é %.',v_codigo, v_nome_completo, v_salario;
END;
$$


-- 
DO $$
DECLARE 
     n1 NUMERIC(5, 2); 
     n2 INT;
     limite_inferior INT := 5;
     limite_superior INT := 17;
BEGIN
     -- 0 <= n1 < 1 [0, 1)
     n1 := random();
     RAISE NOTICE 'n1: %', n1;
     -- 1 <= n1 < 10 (real) [1, 10)
     n1 := 1 + random() * 9;
     RAISE NOTICE '%', n1;
     n2 := floor(random() * 10 + 1)::int;
     RAISE NOTICE 'n2: %', n2;
     -- limite de 5 a 17 
     n2 := floor(random() * (17 - 5 + 1) + 5)::int; -- (limite_superior - limite inferior + 1) + limite inferior
     RAISE NOTICE 'Intervalo qualquer: %', n2;

END;
$$
