USE rvv;
GO

DECLARE @competencia DATE = '2023-01-01',	-- INFORME A COMPETENCIA
        @matricula INT = 1000007,			-- CALCULO INDIVIDUAL SE INFORMADO, CALCULO GERAL SE NÃO INFORMADO
        @percent_faturamento FLOAT = 0.30,	-- INFORME O PERCENTUAL SOBRE BASE DE CALCULO = FATURAMENTO
        @percent_salario FLOAT = 0.10;		-- INFORME O PERCENTUAL SOBRE BASE DE CALCULO = SALARIO


IF @matricula > 0
BEGIN

	DELETE FROM dbo.Comissao
	WHERE Competencia = @competencia
	AND Matricula_do_Colaborador = @matricula;

    WITH temp
    AS (SELECT r.id_resultado,
               m.id_meta,
               r.Matricula_do_Colaborador,
               c.Nome_do_Colaborador,
               d.Codigo_do_Departamento,
               d.Nome_do_Departamento,
               c2.Codigo_do_Cargo,
               c2.Nome_do_Cargo,
               c2.Base_de_Calculo,
               c.Salario,
               r.Codigo_do_Indicador,
               i.Nome_do_Indicador,
               r.Competencia,
               r.Valor_do_Resultado,
               m.Valor_da_Meta,
               CASE
                   WHEN m.Valor_da_Meta > 0 THEN
                       r.Valor_do_Resultado / m.Valor_da_Meta
                   ELSE
                       0
               END AS atingimento,
               i.Peso_do_Indicador
        FROM dbo.Resultado AS r
            INNER JOIN dbo.Colaborador AS c
                ON c.Matricula_do_Colaborador = r.Matricula_do_Colaborador
            INNER JOIN dbo.Indicadores AS i
                ON i.Codigo_do_Indicador = r.Codigo_do_Indicador
                   AND i.Codigo_do_Cargo = c.Codigo_do_Cargo
                   AND i.Codigo_do_Departamento = c.Codigo_do_Departamento
                   AND r.Competencia
                   BETWEEN i.Inicio_Vigencia AND ISNULL(i.Final_Vigencia, GETDATE())
            INNER JOIN dbo.Meta AS m
                ON m.Codigo_do_Indicador = r.Codigo_do_Indicador
                   AND m.Matricula_do_Colaborador = r.Matricula_do_Colaborador
                   AND r.Competencia
                   BETWEEN m.Inicio_Vigencia AND ISNULL(m.Final_Vigencia, GETDATE())
            INNER JOIN dbo.Departamento AS d
                ON d.Codigo_do_Departamento = i.Codigo_do_Departamento
            INNER JOIN dbo.Cargo AS c2
                ON c2.Codigo_do_Cargo = i.Codigo_do_Cargo
        WHERE r.Competencia = @competencia
              AND r.Matricula_do_Colaborador = @matricula),
         temp_final
    AS (SELECT temp.id_resultado,
               temp.id_meta,
               temp.Matricula_do_Colaborador,
               temp.Nome_do_Colaborador,
               temp.Codigo_do_Departamento,
               temp.Nome_do_Departamento,
               temp.Codigo_do_Cargo,
               temp.Nome_do_Cargo,
               temp.Base_de_Calculo,
               temp.Salario,
               temp.Codigo_do_Indicador,
               temp.Nome_do_Indicador,
               temp.Competencia,
               temp.Valor_do_Resultado,
               temp.Valor_da_Meta,
               temp.atingimento,
               temp.Peso_do_Indicador,
               CASE
                   WHEN temp.Base_de_Calculo = 'Faturamento' THEN
               (
                   SELECT t.Valor_do_Resultado
                   FROM temp AS t
                   WHERE t.Matricula_do_Colaborador = temp.Matricula_do_Colaborador
                         AND t.Nome_do_Indicador = 'Faturamento'
               ) * @percent_faturamento
                   ELSE
                       temp.Salario * @percent_salario
               END AS Valor_Base_de_Calculo
        FROM temp)

	/*
    SELECT temp_final.id_resultado,
           temp_final.id_meta,
           temp_final.Matricula_do_Colaborador,
           temp_final.Nome_do_Colaborador,
           temp_final.Codigo_do_Departamento,
           temp_final.Nome_do_Departamento,
           temp_final.Codigo_do_Cargo,
           temp_final.Nome_do_Cargo,
           temp_final.Base_de_Calculo,
           temp_final.Salario,
           temp_final.Codigo_do_Indicador,
           temp_final.Nome_do_Indicador,
           temp_final.Competencia,
           temp_final.Valor_do_Resultado,
           temp_final.Valor_da_Meta,
           temp_final.atingimento,
           temp_final.Peso_do_Indicador,
           temp_final.Valor_Base_de_Calculo,
           temp_final.atingimento * temp_final.Peso_do_Indicador * temp_final.Valor_Base_de_Calculo AS comissao
    FROM temp_final
    ORDER BY temp_final.Matricula_do_Colaborador,
             temp_final.Codigo_do_Indicador;
	*/

    INSERT INTO dbo.Comissao
    (
        id_meta,
        id_resultado,
        Matricula_do_Colaborador,
        Codigo_do_Indicador,
        Competencia,
        Valor_do_Resultado,
        Valor_da_Meta,
        Atingimento,
        Peso_do_Indicador,
        Base_Calculo,
        Comissao
    )
    SELECT temp_final.id_meta,
           temp_final.id_resultado,
           temp_final.Matricula_do_Colaborador,
           temp_final.Codigo_do_Indicador,
           temp_final.Competencia,
           temp_final.Valor_do_Resultado,
           temp_final.Valor_da_Meta,
           temp_final.atingimento,
           temp_final.Peso_do_Indicador,
           temp_final.Valor_Base_de_Calculo,
           temp_final.atingimento * temp_final.Peso_do_Indicador * temp_final.Valor_Base_de_Calculo AS comissao
    FROM temp_final
    ORDER BY temp_final.Matricula_do_Colaborador,
             temp_final.Codigo_do_Indicador;

END;


ELSE
BEGIN

	DELETE FROM dbo.Comissao
	WHERE Competencia = @competencia;

    WITH temp
    AS (SELECT r.id_resultado,
               m.id_meta,
               r.Matricula_do_Colaborador,
               c.Nome_do_Colaborador,
               d.Codigo_do_Departamento,
               d.Nome_do_Departamento,
               c2.Codigo_do_Cargo,
               c2.Nome_do_Cargo,
               c2.Base_de_Calculo,
               c.Salario,
               r.Codigo_do_Indicador,
               i.Nome_do_Indicador,
               r.Competencia,
               r.Valor_do_Resultado,
               m.Valor_da_Meta,
               CASE
                   WHEN m.Valor_da_Meta > 0 THEN
                       r.Valor_do_Resultado / m.Valor_da_Meta
                   ELSE
                       0
               END AS atingimento,
               i.Peso_do_Indicador
        FROM dbo.Resultado AS r
            INNER JOIN dbo.Colaborador AS c
                ON c.Matricula_do_Colaborador = r.Matricula_do_Colaborador
            INNER JOIN dbo.Indicadores AS i
                ON i.Codigo_do_Indicador = r.Codigo_do_Indicador
                   AND i.Codigo_do_Cargo = c.Codigo_do_Cargo
                   AND i.Codigo_do_Departamento = c.Codigo_do_Departamento
                   AND r.Competencia
                   BETWEEN i.Inicio_Vigencia AND ISNULL(i.Final_Vigencia, GETDATE())
            INNER JOIN dbo.Meta AS m
                ON m.Codigo_do_Indicador = r.Codigo_do_Indicador
                   AND m.Matricula_do_Colaborador = r.Matricula_do_Colaborador
                   AND r.Competencia
                   BETWEEN m.Inicio_Vigencia AND ISNULL(m.Final_Vigencia, GETDATE())
            INNER JOIN dbo.Departamento AS d
                ON d.Codigo_do_Departamento = i.Codigo_do_Departamento
            INNER JOIN dbo.Cargo AS c2
                ON c2.Codigo_do_Cargo = i.Codigo_do_Cargo
        WHERE r.Competencia = @competencia),
         temp_final
    AS (SELECT temp.id_resultado,
               temp.id_meta,
               temp.Matricula_do_Colaborador,
               temp.Nome_do_Colaborador,
               temp.Codigo_do_Departamento,
               temp.Nome_do_Departamento,
               temp.Codigo_do_Cargo,
               temp.Nome_do_Cargo,
               temp.Base_de_Calculo,
               temp.Salario,
               temp.Codigo_do_Indicador,
               temp.Nome_do_Indicador,
               temp.Competencia,
               temp.Valor_do_Resultado,
               temp.Valor_da_Meta,
               temp.atingimento,
               temp.Peso_do_Indicador,
               CASE
                   WHEN temp.Base_de_Calculo = 'Faturamento' THEN
               (
                   SELECT t.Valor_do_Resultado
                   FROM temp AS t
                   WHERE t.Matricula_do_Colaborador = temp.Matricula_do_Colaborador
                         AND t.Nome_do_Indicador = 'Faturamento'
               ) * @percent_faturamento
                   ELSE
                       temp.Salario * @percent_salario
               END AS Valor_Base_de_Calculo
        FROM temp)

	/*
    SELECT temp_final.id_resultado,
           temp_final.id_meta,
           temp_final.Matricula_do_Colaborador,
           temp_final.Nome_do_Colaborador,
           temp_final.Codigo_do_Departamento,
           temp_final.Nome_do_Departamento,
           temp_final.Codigo_do_Cargo,
           temp_final.Nome_do_Cargo,
           temp_final.Base_de_Calculo,
           temp_final.Salario,
           temp_final.Codigo_do_Indicador,
           temp_final.Nome_do_Indicador,
           temp_final.Competencia,
           temp_final.Valor_do_Resultado,
           temp_final.Valor_da_Meta,
           temp_final.atingimento,
           temp_final.Peso_do_Indicador,
           temp_final.Valor_Base_de_Calculo,
           temp_final.atingimento * temp_final.Peso_do_Indicador * temp_final.Valor_Base_de_Calculo AS comissao
    FROM temp_final
    ORDER BY temp_final.Matricula_do_Colaborador,
             temp_final.Codigo_do_Indicador;
	*/
	   
    INSERT INTO dbo.Comissao
    (
        id_meta,
        id_resultado,
        Matricula_do_Colaborador,
        Codigo_do_Indicador,
        Competencia,
        Valor_do_Resultado,
        Valor_da_Meta,
        Atingimento,
        Peso_do_Indicador,
        Base_Calculo,
        Comissao
    )
    SELECT temp_final.id_meta,
           temp_final.id_resultado,
           temp_final.Matricula_do_Colaborador,
           temp_final.Codigo_do_Indicador,
           temp_final.Competencia,
           temp_final.Valor_do_Resultado,
           temp_final.Valor_da_Meta,
           temp_final.atingimento,
           temp_final.Peso_do_Indicador,
           temp_final.Valor_Base_de_Calculo,
           temp_final.atingimento * temp_final.Peso_do_Indicador * temp_final.Valor_Base_de_Calculo AS comissao
    FROM temp_final
    ORDER BY temp_final.Matricula_do_Colaborador,
             temp_final.Codigo_do_Indicador;

END;


SELECT * FROM dbo.Comissao
GO
