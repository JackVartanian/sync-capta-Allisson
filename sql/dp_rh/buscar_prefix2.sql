SET NOCOUNT ON; -- Suprime mensagens "linhas afetadas"

DECLARE @SearchPrefix NVARCHAR(100) = 'W000%';
DECLARE @CurrentTable NVARCHAR(256);
DECLARE @CurrentColumn NVARCHAR(256);

-- Cria tabela temporária para armazenar tabelas/colunas
IF OBJECT_ID('tempdb..#TablesToSearch') IS NOT NULL
    DROP TABLE #TablesToSearch;

CREATE TABLE #TablesToSearch (
    TableName NVARCHAR(256),
    ColumnName NVARCHAR(256)
);

INSERT INTO #TablesToSearch
SELECT
    TABLE_NAME,
    COLUMN_NAME
FROM INFORMATION_SCHEMA.COLUMNS
WHERE
    TABLE_NAME LIKE 'sljp%'
    AND DATA_TYPE IN ('varchar', 'nvarchar', 'char', 'nchar', 'text');

-- Processa uma tabela/coluna por vez
WHILE EXISTS (SELECT 1 FROM #TablesToSearch)
BEGIN
    SELECT TOP 1
        @CurrentTable = TableName,
        @CurrentColumn = ColumnName
    FROM #TablesToSearch;

    DECLARE @SQL NVARCHAR(MAX) =
        'IF EXISTS (
            SELECT TOP 1 1
            FROM ' + QUOTENAME(@CurrentTable) +
            ' WHERE ' + QUOTENAME(@CurrentColumn) + ' LIKE ''' + @SearchPrefix + '''
        )
        BEGIN
            SELECT
                ''' + @CurrentTable + ''' AS TabelaEncontrada,
                ''' + @CurrentColumn + ''' AS ColunaEncontrada;
        END';

    BEGIN TRY
        EXEC sp_executesql @SQL; -- Exibe resultados diretamente
    END TRY
    BEGIN CATCH
        PRINT 'Erro na tabela ' + @CurrentTable + ': ' + ERROR_MESSAGE();
    END CATCH

    DELETE FROM #TablesToSearch
    WHERE TableName = @CurrentTable AND ColumnName = @CurrentColumn;
END

-- Limpeza
IF OBJECT_ID('tempdb..#TablesToSearch') IS NOT NULL
    DROP TABLE #TablesToSearch;

SET NOCOUNT OFF;