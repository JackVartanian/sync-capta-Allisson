-- Parâmetro de busca (o caractere % indica que pode haver qualquer coisa após 'W000')
DECLARE @SearchPrefix NVARCHAR(100) = 'W000%';

-- Tabela temporária para armazenar os resultados encontrados
CREATE TABLE #Results (
    TableName NVARCHAR(256),
    ColumnName NVARCHAR(256),
    SampleValue NVARCHAR(MAX)
);

-- Variáveis para armazenar os nomes das tabelas/colunas durante a iteração
DECLARE @TableName NVARCHAR(256);
DECLARE @ColumnName NVARCHAR(256);
DECLARE @SQL NVARCHAR(MAX);

-- Cursor que percorre as tabelas da empresa (aquelas que começam com 'sljd')
-- e somente as colunas de tipos textuais
DECLARE table_cursor CURSOR FAST_FORWARD FOR
    SELECT TABLE_NAME, COLUMN_NAME
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_NAME LIKE 'slje%'
      AND DATA_TYPE IN ('varchar', 'nvarchar', 'char', 'nchar', 'text');

OPEN table_cursor;
FETCH NEXT FROM table_cursor INTO @TableName, @ColumnName;

WHILE @@FETCH_STATUS = 0
BEGIN
    -- Monta a query dinâmica para cada tabela/coluna
    SET @SQL = N'
        IF EXISTS (
            SELECT 1
            FROM ' + QUOTENAME(@TableName) + '
            WHERE ' + QUOTENAME(@ColumnName) + ' LIKE @SearchPrefix
        )
        BEGIN
            INSERT INTO #Results (TableName, ColumnName, SampleValue)
            SELECT TOP 1 @TableNameParam, @ColumnNameParam, ' + QUOTENAME(@ColumnName) + '
            FROM ' + QUOTENAME(@TableName) + '
            WHERE ' + QUOTENAME(@ColumnName) + ' LIKE @SearchPrefix;
        END';

    -- Executa a query dinâmica utilizando parâmetros
    EXEC sp_executesql
         @SQL,
         N'@SearchPrefix NVARCHAR(100), @TableNameParam NVARCHAR(256), @ColumnNameParam NVARCHAR(256)',
         @SearchPrefix = @SearchPrefix,
         @TableNameParam = @TableName,
         @ColumnNameParam = @ColumnName;

    FETCH NEXT FROM table_cursor INTO @TableName, @ColumnName;
END

CLOSE table_cursor;
DEALLOCATE table_cursor;

-- Exibe os resultados encontrados
SELECT * FROM #Results;

-- Limpa a tabela temporária
DROP TABLE #Results;
