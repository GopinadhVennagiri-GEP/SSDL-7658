
DECLARE @SourceTableWithDatetimeColumns Table
(
       TableType VARCHAR(500),
       TableName VARCHAR(500),
       ColumnName VARCHAR(500),
       DisplayColumnName VARCHAR(500),
       RowNumber BIGINT
)

INSERT INTO @SourceTableWithDatetimeColumns
select c.TABLE_TYP_NAME, b.TableName, a.ColumnName, a.DisplayColumnName, ROW_NUMBER() OVER(ORDER BY a.TableSchemaId) AS RowNumber
from SSDL.SPEND_SSDL_TableSchema a
join SSDL.SPEND_SSDL_Table b on a.TableID = b.TableID
join SSDL.SPEND_DCC_TABLE_TYP_MST c on c.TABLE_TYP_ID = b.TableTypeID AND c.TABLE_TYP_CODE = '102'
join SSDL.SPEND_DCC_TABLE_DATA_TYP_MST d ON a.DataTypeID = d.DATA_TYP_ID AND DATA_TYP_NAME = 'Datetime'

SELECT * FROM @SourceTableWithDatetimeColumns

DECLARE @JobsSourceMainDatetimeColumns Table
(
       JobId BIGINT,
       TableName VARCHAR(500),
       SettingName VARCHAR(500),
       ColumnName VARCHAR(500)
)

DECLARE @SourceTableIterator BIGINT = 1;
DECLARE @TotalSourceTableColumns BIGINT;

SELECT @TotalSourceTableColumns = COUNT(1) FROM @SourceTableWithDatetimeColumns

WHILE @SourceTableIterator <= @TotalSourceTableColumns
BEGIN
    --insert to main
    DECLARE @ConsolidationSettingsForSourceTables TABLE
    (
        JobId BIGINT,
        TableName VARCHAR(500),
        SettingName VARCHAR(500),
        SettingValue NVARCHAR(MAX),
        RowNumber BIGINT
    )
    INSERT INTO @ConsolidationSettingsForSourceTables
    select a.JobId, B.TableName, A.SettingName, a.SettingValue, ROW_NUMBER() OVER(ORDER BY a.Id) AS RowNumber
    from SSDL.WorkflowEventSetting a
    JOIN @SourceTableWithDatetimeColumns B ON B.TableName = JSON_VALUE(SettingValue, '$.eventUIDetail[0].sourceTable') AND EventID = 2221
        AND B.RowNumber = @SourceTableIterator

    DECLARE @SettingIterator BIGINT = 1;
    DECLARE @TotalSettingsPerTable BIGINT;

    SELECT @TotalSettingsPerTable = COUNT(1) FROM @ConsolidationSettingsForSourceTables
    WHILE @SettingIterator <= @TotalSettingsPerTable
    BEGIN
        DECLARE @JobId BIGINT, @TableName VARCHAR(500), @SettingName VARCHAR(500), @SettingValue NVARCHAR(MAX);

        SELECT @JobId = JobId, @TableName = TableName, @SettingName = SettingName
        FROM @ConsolidationSettingsForSourceTables
        WHERE RowNumber = @SettingIterator

        INSERT INTO @JobsSourceMainDatetimeColumns
        SELECT @JobId, @TableName, @SettingName, JSON_VALUE(value, '$.sourceTableColumn') AS ColumnName
        FROM OPENJSON((SELECT JSON_QUERY(SettingValue, '$.eventUIDetail[0].columnList') FROM @ConsolidationSettingsForSourceTables
        WHERE RowNumber = @SettingIterator))

        SET @SettingIterator = @SettingIterator + 1;
    END

    SET @SourceTableIterator = @SourceTableIterator + 1;
END

SELECT * FROM @JobsSourceMainDatetimeColumns