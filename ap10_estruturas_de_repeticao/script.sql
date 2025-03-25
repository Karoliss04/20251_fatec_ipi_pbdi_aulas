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
