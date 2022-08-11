DECLARE @MainTableTypeId INT, @MainTableID INT, @JobId INT, @MainTableName NVARCHAR(255);
SET @JobId = 33;
SELECT @MainTableTypeId = TABLE_TYP_ID FROM SSDL.SPEND_DCC_TABLE_TYP_MST where TABLE_TYP_CODE = 101
SELECT @MainTableName = JSON_VALUE(SettingValue, '$.MAIN_COLUMN') FROM SSDL.SPEND_SSDL_JOB_DETAILS where JobID = @JobId;
SELECT @MainTableId = TableId FROM SSDL.SPEND_SSDL_TABLE WHERE TableName = @MainTableName AND TableTypeID = @MainTableTypeId;

DECLARE @InsertConfigs AS TABLE
(
    ColumnsJson NVARCHAR(MAX),
    RowNumber BIGINT
);

DECLARE @InsertConfigMainTableColumns AS TABLE
(
    DisplayColumnName NVARCHAR(255),
    ColumnName NVARCHAR(255)
);
INSERT INTO @InsertConfigs
select JSON_QUERY(SettingValue, '$.eventUIDetail[0].columnList'),
    ROW_NUMBER() OVER(ORDER BY Id) AS RowNumber
from SSDL.WorkflowEventSetting
where JobID = @JobId and EventId = 2221

DECLARE @Iterator BIGINT = 1, @TotalRows BIGINT = 0;

SELECT @TotalRows = COUNT(1) FROM @InsertConfigs;

WHILE @Iterator <= @TotalRows
BEGIN

    INSERT INTO @InsertConfigMainTableColumns(DisplayColumnName, ColumnName)
    SELECT B.DisplayColumnName, JSON_VALUE(A.value, '$.mainTableColumn') AS ColumnName
    FROM OPENJSON((SELECT ColumnsJson FROM @InsertConfigs WHERE RowNumber = @Iterator)) A
    JOIN SSDL.SPEND_SSDL_TableSchema B ON JSON_VALUE(A.value, '$.mainTableColumn') = B.ColumnName AND B.TableId = @MainTableId
    LEFT JOIN @InsertConfigMainTableColumns C ON JSON_VALUE(A.value, '$.mainTableColumn') = C.ColumnName
    WHERE C.ColumnName IS NULL

    SET @Iterator = @Iterator + 1;
END

SELECT * FROM @InsertConfigMainTableColumns;