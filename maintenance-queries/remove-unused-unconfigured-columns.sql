
SP_HELP 'SSDL.SPEND_SSDL_TableSchema'

ALTER TABLE SSDL.ImportFileCriteria DROP CONSTRAINT FK_ImportFileCriteria_AggregationTableSchemaId
ALTER TABLE SSDL.SPEND_SSDL_MAIN_INS DROP CONSTRAINT FK_MAIN_INS_MAIN_TABLE_COLUMN_ID
ALTER TABLE SSDL.SPEND_SSDL_MAIN_INS DROP CONSTRAINT FK_MAIN_INS_SOURCE_TABLE_COLUMN_ID
ALTER TABLE SSDL.SPEND_SSDL_MAIN_UPD DROP CONSTRAINT FK_MAIN_UPD_MAIN_TABLE_COLUMN_ID
ALTER TABLE SSDL.SPEND_SSDL_MAIN_UPD DROP CONSTRAINT FK_MAIN_UPD_SOURCE_TABLE_COLUMN_ID
ALTER TABLE SSDL.SPEND_SSDL_MAIN_UPD_FILTER DROP CONSTRAINT FK_MAIN_UPD_FILTER_MAIN_TABLE_COLUMN_ID
ALTER TABLE SSDL.SPEND_SSDL_MAIN_UPD_FILTER DROP CONSTRAINT FK_MAIN_UPD_FILTER_SOURCE_TABLE_COLUMN_ID

--get unused columns
IF 1=0
BEGIN
    DECLARE @OpsMainTableId INT;
    DECLARE @MainTableTypeId INT;
    DECLARE @InactiveColumnsList TABLE
    (
        TableSchemaID INT,
        ColumnName VARCHAR(255),
        DisplayColumnName VARCHAR(255)
    );
    SELECT @MainTableTypeId = Table_TYP_ID FROM SSDL.SPEND_DCC_TABLE_TYP_MST where Table_TYP_code = 101
    SELECT @OpsMainTableId = TableId FROM SSDL.SPEND_SSDL_TABLE WHERE TableTypeID = @MainTableTypeId AND TableName = 'OPS_MAIN';

    INSERT INTO @InactiveColumnsList
    SELECT TableSchemaID, ColumnName, DisplayColumnName
    FROM SSDL.SPEND_SSDL_TableSchema where TableID = @OpsMainTableId and IsUsedInProject = 0 AND (ColumnName not like 'CUSTOM_FIELD%' OR (ColumnName like 'CUSTOM_FIELD%' AND DisplayColumnName not like 'Custom Field (%'))

    SELECT * FROM @InactiveColumnsList

    With CTE2 AS
    (
        SELECT DISTINCT
        c.TableSchemaID
        -- ,
        -- c.ColumnName
        FROM SSDL.WorkflowEventSetting a
        INNER JOIN @InactiveColumnsList c ON a.SettingValue IS NOT NULL AND a.SettingValue like '%' + c.ColumnName + '%' AND a.EventId IS NOT NULL
            AND a.EventId BETWEEN 2220 AND 2310
            AND (a.EventId NOT IN (2252) OR (a.EventId = 2252 AND JSON_VALUE(a.SettingValue, '$.eventUIDetail[0].currencyColumnMainTable') = c.ColumnName))
        UNION
        SELECT DISTINCT A.TableSchemaId
        FROM SSDL.ImportFileColumnMappingLink A
        INNER JOIN @InactiveColumnsList B ON A.TableSchemaId = B.TableSchemaID
        -- INNER JOIN SSDL.ImportFiles B ON A.ImportFileId = B.Id AND B.DestinationTableId = @OpsMainTableId
        UNION
        SELECT DISTINCT AggregationTableSchemaId
        FROM SSDL.ImportFileCriteria A
        INNER JOIN @InactiveColumnsList B ON A.AggregationTableSchemaId = B.TableSchemaID
        -- INNER JOIN SSDL.ImportFiles B ON A.ImportFileId = B.Id AND B.DestinationTableId = @OpsMainTableId
        UNION
        SELECT DISTINCT DestinationColumnTableSchemaId
        FROM SSDL.ImportFileCriteriaConditions A
        INNER JOIN @InactiveColumnsList B ON A.DestinationColumnTableSchemaId = B.TableSchemaID
        -- INNER JOIN SSDL.ImportFileCriteria B ON A.ImportFileCriteriaId = B.Id
        -- INNER JOIN SSDL.ImportFiles C ON B.ImportFileId = C.Id AND C.DestinationTableId = @OpsMainTableId
        UNION
        SELECT TableSchemaID
        FROM SSDL.ExportTemplateMaster A
        INNER JOIN @InactiveColumnsList B ON JSON_VALUE(A.TemplateJSON, '$.tableName') = 'OPS_MAIN'
            AND A.TemplateJSON LIKE '%' + B.ColumnName + '%'
        -- SELECT DISTINCT
        -- -- c.TableSchemaID
        -- -- ,
        -- c.ColumnName
        -- FROM SSDL.JOB_DETAILS a
        -- INNER JOIN @InactiveColumnsList c ON a.SettingValue IS NOT NULL AND a.SettingValue like '%' + c.ColumnName + '%'
        --     AND SettingName IN ('RangeBucket','NewOldFlag','OnetimeFlag','OneToMany')
    )
    -- SELECT * FROM CTE2 B
    -- UPDATE A
    -- SET A.IsUsedInProject = 1
    SELECT A.ColumnName
    FROM SSDL.SPEND_SSDL_TableSchema A
    INNER JOIN CTE2 B ON A.TableSchemaId = B.TableSchemaId
END
GO

----UPDATE
IF 1 = 0
BEGIN
    DECLARE @OpsMainTableId INT;
    DECLARE @MainTableTypeId INT;
    DECLARE @InactiveColumnsList TABLE
    (
        TableSchemaID INT,
        ColumnName VARCHAR(255),
        DisplayColumnName VARCHAR(255)
    );
    SELECT @MainTableTypeId = Table_TYP_ID FROM SSDL.SPEND_DCC_TABLE_TYP_MST where Table_TYP_code = 101
    SELECT @OpsMainTableId = TableId FROM SSDL.SPEND_SSDL_TABLE WHERE TableTypeID = @MainTableTypeId AND TableName = 'OPS_MAIN';

    INSERT INTO @InactiveColumnsList
    SELECT TableSchemaID, ColumnName, DisplayColumnName
    FROM SSDL.SPEND_SSDL_TableSchema where TableID = @OpsMainTableId and IsUsedInProject = 0 AND (ColumnName not like 'CUSTOM_FIELD%' OR (ColumnName like 'CUSTOM_FIELD%' AND DisplayColumnName not like 'Custom Field (%'))

    SELECT * FROM @InactiveColumnsList

    With CTE2 AS
    (
        SELECT DISTINCT
        c.TableSchemaID
        -- ,
        -- c.ColumnName
        FROM SSDL.WorkflowEventSetting a
        INNER JOIN @InactiveColumnsList c ON a.SettingValue IS NOT NULL AND a.SettingValue like '%' + c.ColumnName + '%' AND a.EventId IS NOT NULL
            AND a.EventId BETWEEN 2220 AND 2310
            AND (a.EventId NOT IN (2252) OR (a.EventId = 2252 AND JSON_VALUE(a.SettingValue, '$.eventUIDetail[0].currencyColumnMainTable') = c.ColumnName))
        UNION
        SELECT DISTINCT A.TableSchemaId
        FROM SSDL.ImportFileColumnMappingLink A
        INNER JOIN @InactiveColumnsList B ON A.TableSchemaId = B.TableSchemaID
        -- INNER JOIN SSDL.ImportFiles B ON A.ImportFileId = B.Id AND B.DestinationTableId = @OpsMainTableId
        UNION
        SELECT DISTINCT AggregationTableSchemaId
        FROM SSDL.ImportFileCriteria A
        INNER JOIN @InactiveColumnsList B ON A.AggregationTableSchemaId = B.TableSchemaID
        -- INNER JOIN SSDL.ImportFiles B ON A.ImportFileId = B.Id AND B.DestinationTableId = @OpsMainTableId
        UNION
        SELECT DISTINCT DestinationColumnTableSchemaId
        FROM SSDL.ImportFileCriteriaConditions A
        INNER JOIN @InactiveColumnsList B ON A.DestinationColumnTableSchemaId = B.TableSchemaID
        -- INNER JOIN SSDL.ImportFileCriteria B ON A.ImportFileCriteriaId = B.Id
        -- INNER JOIN SSDL.ImportFiles C ON B.ImportFileId = C.Id AND C.DestinationTableId = @OpsMainTableId
        UNION
        SELECT TableSchemaID
        FROM SSDL.ExportTemplateMaster A
        INNER JOIN @InactiveColumnsList B ON JSON_VALUE(A.TemplateJSON, '$.tableName') = 'OPS_MAIN'
            AND A.TemplateJSON LIKE '%' + B.ColumnName + '%'
        -- SELECT DISTINCT
        -- -- c.TableSchemaID
        -- -- ,
        -- c.ColumnName
        -- FROM SSDL.JOB_DETAILS a
        -- INNER JOIN @InactiveColumnsList c ON a.SettingValue IS NOT NULL AND a.SettingValue like '%' + c.ColumnName + '%'
        --     AND SettingName IN ('RangeBucket','NewOldFlag','OnetimeFlag','OneToMany')
    )
    -- INSERT INTO @InactiveColumnsList
    -- SELECT A.TableSchemaID
    -- FROM CTE2 A
    -- LEFT JOIN @InactiveColumnsList B ON A.TableSchemaID = B.TableSchemaID
    -- WHERE B.TableSchemaID IS NULL
    
    -- DECLARE @ExportRowIterator BIGINT = 1;
    -- DECLARE @TotalExportRows BIGINT = 0;

    -- SELECT A.TemplateJSON, ROW_NUMBER() OVER(ORDER BY Id) AS RowNumber
    -- INTO #OpsMainExportJSON
    -- FROM SSDL.ExportTemplateMaster A
    -- WHERE JSON_VALUE(A.TemplateJSON, '$.tableName') = 'OPS_MAIN'

    -- SELECT @TotalExportRows = COUNT(1) FROM #OpsMainExportJSON

    -- WHILE @ExportRowIterator <= @TotalExportRows
    -- BEGIN
    --     DECLARE @IteratorTemplateJSON NVARCHAR(MAX);
    --     SELECT @IteratorTemplateJSON = TemplateJSON FROM #OpsMainExportJSON WHERE RowNumber = @ExportRowIterator;

    --     SELECT *
    --     FROM OPENJSON(@IteratorTemplateJSON)

    --     SET @ExportRowIterator = @ExportRowIterator + 1;
    -- END

    UPDATE A
    SET A.IsUsedInProject = 1
    -- SELECT B.ColumnName
    FROM SSDL.SPEND_SSDL_TableSchema A
    INNER JOIN CTE2 B ON A.TableSchemaID = B.TableSchemaID
    -- SELECT * FROM CTE2 B
END
GO

select * from SSDL.WorkflowEventSetting where EventID = 2252 and JobID = 1828


----Delete inactive columns - check for import/export
--for import, if we delete inactive columns from .net side
    ---- even on Prod currently, User anyway cannot re-run past Import Utility requests.
    ---- BUT for any past Import runs, user won't be able to see past configurations because of missing columns.
--for Export, currently user is able to re-run saved templates.
    -- so after deleting un-used columns if they were also used in Export Utility then user won't be able to view and re-run saved templates.
IF 1 = 0
BEGIN
    DECLARE @OpsMainTableId INT;
    DECLARE @MainTableTypeId INT;
    SELECT @MainTableTypeId = Table_TYP_ID FROM SSDL.SPEND_DCC_TABLE_TYP_MST where Table_TYP_code = 101
    SELECT @OpsMainTableId = TableId FROM SSDL.SPEND_SSDL_TABLE WHERE TableTypeID = @MainTableTypeId AND TableName = 'OPS_MAIN';

    SELECT ColumnName, DisplayColumnName FROM SSDL.SPEND_SSDL_TableSchema where TableID = @OpsMainTableId and IsUsedInProject = 0 AND (ColumnName not like 'CUSTOM_FIELD%' OR (ColumnName like 'CUSTOM_FIELD%' AND DisplayColumnName not like 'Custom Field (%'));

    DELETE FROM SSDL.SPEND_SSDL_TableSchema where TableID = @OpsMainTableId and IsUsedInProject = 0 AND (ColumnName not like 'CUSTOM_FIELD%' OR (ColumnName like 'CUSTOM_FIELD%' AND DisplayColumnName not like 'Custom Field (%'))
END
GO

----Delete inactive columns - check for import/export
--for import, if we delete inactive columns from .net side
    ---- even on Prod currently, User anyway cannot re-run past Import Utility requests.
    ---- BUT for any past Import runs, user won't be able to see past configurations because of missing columns.
--for Export, currently user is able to re-run saved templates.
    -- so after deleting un-used columns if they were also used in Export Utility then user won't be able to view and re-run saved templates.

--Even if we agree
-- 1) we have to first drop following constraints:
-- 2) we have to mark IsUsedInProject=1 if they are IsUsedInProject=0 and used in (Consolidation, maybe Import/Export confirm with Avinash Gatty).
-- 3) Then we have to delete all columns where IsUsedInProject = 0

select * from SSDL.SPEND_SSDL_TableSchema where ColumnName in ('CUSTOM_FIELD_124', 'CUSTOM_FIELD_125')
select * from SSDL.WorkflowEventSetting where EventId IS NOT NULL and SettingValue like '%CUSTOM_FIELD_123%'
select * from SSDL.WorkflowEventSetting where EventId IS NOT NULL and SettingValue like '%CUSTOM_FIELD_124%'
select * from SSDL.WorkflowEventSetting where EventId IS NOT NULL and SettingValue like '%CUSTOM_FIELD_125%'

-- SELECT *
-- FROM OPENJSON((select SettingValue from SSDL.JOB_DETAILS WHERE SettingName = 'RangeBucket' and ID = 14517)) a
-- WHERE JSON_VALUE(A.value, '$.bucket.targetBucketColumnName') = 'BUSINESS_GROUP_DESC_6'

-- SELECT *
-- FROM OPENJSON((select SettingValue from SSDL.JOB_DETAILS WHERE SettingName = 'NewOldFlag' and ID = 14517)) a
-- WHERE JSON_VALUE(A.value, '$.bucket.targetColumnName') = 'BUSINESS_GROUP_DESC_6'

-- SELECT *
-- FROM OPENJSON((select SettingValue from SSDL.JOB_DETAILS WHERE SettingName = 'OnetimeFlag' and ID = 11325)) a
-- WHERE JSON_VALUE(A.value, '$.bucket.targetColumnName') = 'BUSINESS_GROUP_DESC_6'

-- SELECT *
-- FROM OPENJSON((select SettingValue from SSDL.JOB_DETAILS WHERE SettingName = 'OneToMany' and ID = 11951)) a
-- WHERE JSON_VALUE(A.value, '$.bucket.targetFieldColumnName') = 'BUSINESS_GROUP_DESC_6'

select * from SSDL.WorkflowEventSetting where EventId is not null and SettingValue like '%IMPORTEXPORTUID1%'
select * from SSDL.JOB_DETAILS WHERE SettingName = 'RangeBucket' and SettingValue like '%IMPORTEXPORTUID1%'
select * from SSDL.JOB_DETAILS WHERE SettingName = 'NewOldFlag' and SettingValue like '%IMPORTEXPORTUID1%'
select * from SSDL.JOB_DETAILS WHERE SettingName = 'OnetimeFlag' and SettingValue like '%IMPORTEXPORTUID1%'
select * from SSDL.JOB_DETAILS WHERE SettingName = 'OneToMany' and SettingValue like '%IMPORTEXPORTUID1%'

select * from SSDL.JOB_DETAILS WHERE SettingName = 'RangeBucket' and SettingValue like targetBucketDisplayName = '%PO_UNIT_PRICE_LOCAL%'
select * from SSDL.JOB_DETAILS WHERE SettingName = 'NewOldFlag' and SettingValue like targetDisplayName = '%PO_UNIT_PRICE_LOCAL%'
select * from SSDL.JOB_DETAILS WHERE SettingName = 'OnetimeFlag' and SettingValue like unUsedFieldDisplayName = '%PO_UNIT_PRICE_LOCAL%'
select * from SSDL.JOB_DETAILS WHERE SettingName = 'OneToMany' and SettingValue like fieldName = '%PO_UNIT_PRICE_LOCAL%'
