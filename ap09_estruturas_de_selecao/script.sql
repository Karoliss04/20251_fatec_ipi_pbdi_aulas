-- CREATE OR REPLACE FUNCTION valor_aleatorio_entre (lim_inferior INT, lim_superior
-- INT) RETURNS INT AS
-- $$
-- BEGIN
-- RETURN FLOOR(RANDOM() * (lim_superior - lim_inferior + 1) + lim_inferior)::INT;
-- END;
-- $$ LANGUAGE plpgsql;

DO $$
DECLARE
     v_valor INT;
BEGIN
     v_valor := valor_aleatorio_entre(1, 50);
     IF v_valor <= 20 THEN 
          RAISE NOTICE 'A metade de % é %', v_valor, v_valor / 2::FLOAT;
     END IF;
END;
$$

-- CREATE OR REPLACE FUNCTION valor_aleatorio_entre (lim_inferior INT, lim_superior
-- INT) RETURNS INT AS
-- $$
-- BEGIN
-- RETURN FLOOR(RANDOM() * (lim_superior - lim_inferior + 1) + lim_inferior)::INT;
-- END;
-- $$ LANGUAGE plpgsql;

DO $$
DECLARE 
     a INT := valor_aleatorio_entre(0,20);
     b INT := valor_aleatorio_entre(0,20);
     c INT := valor_aleatorio_entre(0,20);
     delta NUMERIC(10,2);
     raizUm NUMERIC(10,2);
     raizDois NUMERIC(10,2);
     -- ax^2 + bx + c = 0
BEGIN
     RAISE NOTICE '%x% + %x + %', a, U&'\00B2', b, c; -- U&'\00B2' = 'elevado a 2' = usado quando não conseguimos declarar um icone
     IF a = 0 THEN                                       -- Codigo Unicode (da pra pesquisar a tabela)
          RAISE NOTICE 'Não é equação do segundo grau';
     ELSE
          delta := b ^ 2 - 4 * a * c; -- no python seria =
          RAISE NOTICE 'Delta: %', delta;
          IF delta < 0 THEN
               RAISE NOTICE 'Não teve muita graça, não tem raiz';
          ELSEIF delta = 0 THEN -- no python seria ==
               raizUm := -1 * b / (2 * a);
               RAISE NOTICE 'Teve uma raiz. essa aqui: %', raizUm;
          ELSE
               raizUm := (-b + |/delta) / (2 * a);
               raizDois := (-b - |/delta) / (2 * a); -- |/ = Raiz quadrada
               RAISE NOTICE 'Duas raizes. Observe: % e %', raizUm, raizDois;
          END IF;
     END IF;
END;
$$

DO $$
DECLARE
     valor INT := valor_aleatorio_entre(1, 12);
     mensagem VARCHAR(200);
BEGIN
     RAISE NOTICE 'O valor da vez é %', valor;
     CASE valor
          WHEN 1, 3, 5, 7, 9 THEN
               mensagem := 'Ímpar'; -- essa mensagem poderia ser um RAISE NOTICE 
          WHEN 2, 4, 6, 8, 10 THEN
               mensagem := 'Par';
          ELSE 
               mensagem := 'Fora do intervalo';
     END CASE;
     RAISE NOTICE '%', mensagem; -- mostrar as mensagens 
END;
$$

-- OBJETIVO:  O USUARIO IRA DIGITAR UMA DATA 
-- ddmmaaa - e vamos verificar se é uma data valida
DO $$
DECLARE
     -- testar
     -- 22/10/2022: válido
     -- 29/02/2020: válido
     -- 29/02/2021: inválido
     -- 28/02/2021: válido 
     -- 31/09/2025: inválido
     -- 31/06/2025: inválido
     data INT := 31012006; -- pensar que é um valor inteiro 22.102.022
     dia INT;
     mes INT;
     ano INT;
     data_valida BOOL := TRUE; -- ja considerantdo que a data é válida, vamos espor ela a situações para saber mesmo
BEGIN
     dia := data / 1000000;
     mes := data % 1000000 / 10000;
     ano := data % 10000;
     RAISE NOTICE '%/%/%', dia, mes, ano;

     IF ano>= 1 THEN
          CASE
               WHEN mes > 12 OR mes < 1 OR dia < 1 OR dia > 31 THEN 
                    data_valida := FALSE;
               ELSE 
                    IF (mes IN (4, 6, 9, 11)) AND dia > 30 THEN
                         data_valida := FALSE;
                    ELSE
                         IF mes = 2 THEN -- caso estajamos em fevereiro
                              CASE
                                   WHEN (ano % 4 = 0 AND ano % 100 <> 0) OR ano % 400 = 0 THEN 
                                        IF dia > 29 THEN 
                                             data_valida := FALSE ;
                                        END IF;
                                   ELSE 
                                        IF dia > 28 THEN
                                             data_valida := FALSE;
                                        END IF; 
                              END CASE;

                         END IF;

                    END IF;
          END CASE;
     ELSE
          data_valida := FALSE;
     END IF;
     CASE 
          WHEN data_valida THEN
               RAISE NOTICE 'Data válida!!!';
          ELSE
               RAISE NOTICE 'Data inválida';
     END CASE;
END;
$$