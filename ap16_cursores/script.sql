-- CREATE TABLE tb_top_youtubers(
-- 	cod_top_youtubers SERIAL PRIMARY KEY,
-- 	rank INT,
-- 	youtuber VARCHAR(200),
-- 	subscribers INT,
-- 	video_views INT,
-- 	video_count INT,
-- 	category VARCHAR(200),
-- 	started INT
-- );

-- ALTER TABLE tb_top_youtubers
-- ALTER COLUMN video_views TYPE BIGINT;
-- SELECT * FROM tb_top_youtubers;

-- MEXENDO NO PRIMEIRO CURSOR - CURSOR NÃO VINCULADO
DO $$
DECLARE
--1. declaração do cursor
-- esse cursor é não vinvulado(unbound), pois quando declaramos não especificamos o SELECT
cur_nomes_youtubers REFCURSOR;
v_youtuber VARCHAR(200);

BEGIN
-- 2. abertura do cursor
OPEN cur_nomes_youtubers FOR
	SELECT youtuber FROM tb_top_youtubers;
	LOOP
	-- 3. recuperação de dados de interesse
	FETCH cur_nomes_youtubers INTO v_youtuber;
	EXIT WHEN NOT FOUND;
	RAISE NOTICE '%', v_youtuber;
	END LOOP;

-- 4. fechamento do cursor
CLOSE cur_nomes_youtubers;
END;
$$

-- CURSOR NÃO VINCULADO COM QUERY DINAMICA (em tempo de execução vc decide qual comando executar - ex. quando há opções)
-- exibir os nomes dos youtubers que começaram a partir de um ano específico 
-- os cursores são melhores em questão de desempenho por não pegar toda a tabela, e sim, uma parte especifica
DO $$
DECLARE
	cur_nomes_a_partir_de REFCURSOR;
	v_youtuber VARCHAR(200);
	v_ano INT := 2008; -- serve para colocar o limite de "quero youtubers q começaram em 2008"
	v_nome_tabela VARCHAR(200) := 'tb_top_youtubers';
	
BEGIN
	-- fazer o select em função das variaveis
	-- 2. abertura do cursor
	OPEN cur_nomes_a_partir_de FOR EXECUTE -- usar quando a query for dinamica
	format(
		'SELECT youtuber 
		FROM %s  
		WHERE started >= $1' 
		, v_nome_tabela
	) 
	USING v_ano;
	LOOP
		-- 3. Recuperação de dados
		FETCH cur_nomes_a_partir_de INTO v_youtuber;
		EXIT WHEN NOT FOUND; 
		RAISE NOTICE '%', v_youtuber;
	END LOOP;
	-- 4. Fechar o cursor
	CLOSE cur_nomes_a_partir_de;
END;
$$

-- CURSOR VINCULADO(BOUND)
-- concatenar nome e número de inscritos
DO $$
DECLARE
	cur_nomes_e_inscritos CURSOR FOR
	SELECT youtuber, subscribers FROM tb_top_youtubers;
	tupla RECORD;
	resultado TEXT DEFAULT '';
BEGIN
	-- 2. abertura
	OPEN cur_nomes_e_inscritos;
	FETCH cur_nomes_e_inscritos INTO tupla;
	WHILE FOUND LOOP
		resultado := resultado || tupla.youtuber || ': ' || tupla.subscribers || ',';
		-- 3. recuperação dos dados
		FETCH cur_nomes_e_inscritos INTO tupla;
	END LOOP;
	-- 4. Fechamento
	CLOSE cur_nomes_e_inscritos;
	RAISE NOTICE '%', resultado;
END; 
$$

-- CURSORES COM PARAMETROS NOMEADOS E PELA ORDEM
-- começaram a partir de 2010 e tem pelo menos 60M de inscritos 
DO $$
DECLARE
	 v_ano INT := 2010;
	 v_inscritos INT := 60_000_000;
	 v_youtuber VARCHAR(200);
	 -- 1. declaração
	 cur_ano_inscritos CURSOR(ano INT, inscritos INT) 
	 FOR SELECT youtuber 
	 FROM tb_top_youtubers 
	 WHERE started >= ano AND subscribers >= inscritos;
BEGIN
	-- 2. abertura
	OPEN cur_ano_inscritos(
		ano := v_ano,
		inscritos := v_inscritos
	);
	LOOP 
		-- 3. recuperação de dados
		FETCH cur_ano_inscritos INTO v_youtuber;
		EXIT WHEN NOT FOUND;
		RAISE NOTICE '%', v_youtuber;
	END LOOP;
	-- 4. fechamento
	CLOSE cur_ano_inscritos;
END;
$$


-- UPDATE E DELETE COM RECURSORES 
-- remover tuplas em que video_count é desconhecido
-- exibir as tuplas remanescentes de baixo

-- tipo: SELECT * FROM tb_top_youtubers WHERE video_count IS NULL
DO $$
DECLARE
-- 1. Declaração 
	 cur_delete REFCURSOR;
	 tupla RECORD;

BEGIN 
    -- 2. abertura
	OPEN cur_delete SCROLL FOR
	SELECT * FROM tb_top_youtubers;
	LOOP 
		-- 3. Recuperação de dados
		FETCH cur_delete INTO tupla;
		EXIT WHEN NOT FOUND;
			IF tupla.video_count IS NULL THEN
				DELETE FROM tb_top_youtubers 
				WHERE CURRENT OF cur_delete;
			END IF;
	END LOOP;

	LOOP 
		-- 3.1 Recuperação de dados
		 FETCH BACKWARD FROM cur_delete INTO tupla;
		 EXIT WHEN NOT FOUND;
		 RAISE NOTICE '%', tupla; -- mostra todo mundo que 'sobrou', pois nao tinha ninguem para remover
	END LOOP;
	-- 4. fechamento
	CLOSE cur_delete;
END;
$$

-- EXECÍCIOS AP16
-- 1.1 Escreva um cursor que exiba as variáveis rank e youtuber de toda tupla que tiver video_count pelo menos igual a 1000 e cuja category seja igual a Sports ou Music.

DO $$
DECLARE
	-- 1 Declaração
	cur_sports_music_maior1000 CURSOR FOR SELECT rank, youtuber FROM tb_top_youtubers WHERE video_count >= 1000;
	tupla RECORD;
	resultado TEXT DEFAULT '';
BEGIN
	-- 2 abertura
	OPEN cur_sports_music_maior100;
		-- 3 recuperação de dados
	
	
END;
$$



	



