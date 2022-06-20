
DECLARE @CorrectAndIncorrectDisplayColumnNames AS TABLE
(
    ColumnName NVARCHAR(500),
    OldDisplayColumnName VARCHAR(1000),
    NewDisplayColumnName VARCHAR(1000)
)
INSERT INTO @CorrectAndIncorrectDisplayColumnNames
VALUES ('EXCH_MONTH', 'GEP Curency Exchange Month', 'GEP Currency Exchange Month'),
('EXCH_YEAR', 'GEP Curency Exchange Year', 'GEP Currency Exchange Year'),
('EXCH_RATE', 'GEP Curency Exchange Rate', 'GEP Currency Exchange Rate'),
('MODIFIED_DATE', 'Record Modifed Date', 'Record Modified Date'),
('PO_QUANTITY_NORMALIZED', 'GEP Normalized PO Quanity', 'GEP Normalized PO Quantity'),
('ITEM_MATERIAL_REVISION_NUMBER', 'Maerial Revision Number', 'Material Revision Number'),
('GEP_DIVERSITY_TYPE', 'Gep Diversity Type', 'GEP Diversity Type'),
('GEP_DIVERSITY_OTHER_VETERAN_OWNED_INDICATOR', 'Gep Diversity Other', 'GEP Diversity Other'),
('SOURCESYSTEM_1', 'Source System', 'Source System 1'),
('GEP_CF_HISTORICAL_FLAG', 'GEP CF Historical Flag', 'GEP Classification Historical Flag');

-- SELECT * FROM @CorrectAndIncorrectDisplayColumnNames

DECLARE @DatabaseNamePattern VARCHAR(500);
DECLARE @DatabaseName VARCHAR(500);

SET @DatabaseNamePattern = '%[_]SSDL'
SET @DatabaseName = DB_NAME();

DECLARE @MainTableName VARCHAR(255);
DECLARE @OpsMainTableId INT;
DECLARE @MainTableTypeId INT;

SET @MainTableName = 'OPS_MAIN'
SELECT @MainTableTypeId = Table_TYP_ID FROM SSDL.SPEND_DCC_TABLE_TYP_MST where Table_TYP_code = 101
SELECT @OpsMainTableId = TableId FROM SSDL.SPEND_SSDL_TABLE WHERE TableTypeID = @MainTableTypeId AND TableName = @MainTableName;

DECLARE @ErrorMessage NVARCHAR(MAX)
DECLARE @ErrorSeverity NVARCHAR(20)
DECLARE @ErrorState NVARCHAR(20)

DECLARE @InactiveColumnsList TABLE
(
    TableSchemaID INT,
    ColumnName VARCHAR(255),
    OldDisplayColumnName VARCHAR(255),
    NewDisplayColumnName VARCHAR(255)
);

DECLARE @ConfiguredJobs AS TABLE
(
    JobId BIGINT,
    JobName VARCHAR(500)
)

INSERT INTO @ConfiguredJobs
SELECT JOB_ID, JOB_NAME
FROM SSDL.SPEND_DL_SA_ACIVITYWORKMASTER A
JOIN SSDL.SPEND_SSDL_JOB_DETAILS B ON A.JOB_ID = B.JobId AND JSON_VALUE(SettingValue, '$.MAIN_COLUMN') = @MainTableName
WHERE A.JOB_STATUS NOT IN ('D', 'SM', 'C') AND ISNULL(A.IsDeleted, 0) = 0;

INSERT INTO @InactiveColumnsList
SELECT TableSchemaID, B.ColumnName, B.OldDisplayColumnName, B.NewDisplayColumnName
FROM SSDL.SPEND_SSDL_TableSchema A
JOIN @CorrectAndIncorrectDisplayColumnNames B ON A.ColumnName = B.ColumnName AND TableID = @OpsMainTableId

-- SELECT * FROM @InactiveColumnsList;

;With CTE2 AS
(
    select
    -- DISTINCT B.TableSchemaID
    distinct 'Basic Details' AS Activity, NULL AS ParentStepName,  A.JobId,D.JobName, (CASE WHEN JSON_VALUE(SettingValue, '$.SPEND_FIELDS') = B.OldDisplayColumnName THEN 'Spend Field' WHEN JSON_VALUE(SettingValue, '$.DATE_FIELDS') = B.OldDisplayColumnName THEN 'Date Field' END) AS StepOrTaskName, B.NewDisplayColumnName, B.OldDisplayColumnName
    from SSDL.SPEND_SSDL_JOB_DETAILS A
    INNER JOIN @InactiveColumnsList B ON A.SettingValue IS NOT NULL
    AND (JSON_VALUE(SettingValue, '$.SPEND_FIELDS') = B.OldDisplayColumnName OR JSON_VALUE(SettingValue, '$.DATE_FIELDS') = B.OldDisplayColumnName)
    INNER JOIN @ConfiguredJobs D ON A.JobId = D.JobId
    UNION
    select
    -- DISTINCT B.TableSchemaID
    distinct 'Consolidation' AS Activity, C.SettingName AS ParentStepName,  A.JobId,D.JobName, A.SettingName AS StepOrTaskName, B.NewDisplayColumnName, B.OldDisplayColumnName
    FROM SSDL.WorkflowEventSetting a
    INNER JOIN @InactiveColumnsList B ON a.SettingValue IS NOT NULL AND a.SettingValue like '%"' + B.OldDisplayColumnName + '"%' AND a.EventId IS NOT NULL
        AND a.EventId BETWEEN 2220 AND 2310
    INNER JOIN @ConfiguredJobs D ON A.JobId = D.JobId
    INNER JOIN SSDL.WorkflowEventSetting C ON C.ID = a.ParentID
    UNION
    select
    -- DISTINCT B.TableSchemaID
    distinct 'Profile to publish' AS Activity, NULL AS ParentStepName,  A.JobId, D.JobName, A.SettingName AS StepOrTaskName, B.NewDisplayColumnName, B.OldDisplayColumnName
    from ssdl.JOB_DETAILS AS A
    INNER JOIN @InactiveColumnsList B ON A.SettingValue IS NOT NULL AND A.SettingValue like '%"' + B.OldDisplayColumnName+'"%' AND A.SettingName NOT IN ('DataLakeMapping') AND A.JobID NOT IN (-1, 0)
    INNER JOIN @ConfiguredJobs D ON A.JobId = D.JobId
    UNION
    -- SELECT
    -- -- DISTINCT B.TableSchemaID
    -- DISTINCT 'Import Utility' AS Activity, NULL AS ParentStepName,  A.ImportFileId AS JobId, '' AS JobName, '' AS StepOrTaskName, B.NewDisplayColumnName, B.OldDisplayColumnName
    -- FROM SSDL.ImportFileColumnMappingLink A
    -- INNER JOIN @InactiveColumnsList B ON A.TableSchemaId = B.TableSchemaID
    -- UNION
    -- SELECT
    -- -- DISTINCT B.TableSchemaID
    -- DISTINCT 'Import Utility' AS Activity, NULL AS ParentStepName,  A.ImportFileId AS JobId, '' AS JobName, '' AS StepOrTaskName, B.NewDisplayColumnName, B.OldDisplayColumnName
    -- FROM SSDL.ImportFileCriteria A
    -- INNER JOIN @InactiveColumnsList B ON A.AggregationTableSchemaId = B.TableSchemaID
    -- UNION
    -- SELECT
    -- -- DISTINCT B.TableSchemaID
    -- DISTINCT 'Import Utility' AS Activity, NULL AS ParentStepName,  C.ImportFileId AS JobId, '' AS JobName, '' AS StepOrTaskName, B.NewDisplayColumnName, B.OldDisplayColumnName
    -- FROM SSDL.ImportFileCriteriaConditions A
    -- INNER JOIN @InactiveColumnsList B ON A.DestinationColumnTableSchemaId = B.TableSchemaID
    -- INNER JOIN SSDL.ImportFileCriteria C ON A.ImportFileCriteriaId = C.Id
    -- UNION
    SELECT
    -- DISTINCT B.TableSchemaID
    DISTINCT 'Export Utility' AS Activity, NULL AS ParentStepName,  A.TemplateId AS JobId, A.TemplateName AS JobName, '' AS StepOrTaskName, B.NewDisplayColumnName, B.OldDisplayColumnName
    FROM SSDL.ExportTemplateMaster A
    INNER JOIN @InactiveColumnsList B ON JSON_VALUE(A.TemplateJSON, '$.tableName') = @MainTableName
        AND A.TemplateJSON LIKE '%"' + B.OldDisplayColumnName + '"%'
    UNION
    select
    -- DISTINCT B.TableSchemaID
    DISTINCT 'Clustering' AS Activity, NULL AS ParentStepName,  NULL as JobId, '' AS JobName, (Case when ClusterType = 1 THEN 'Supplier Clustering' WHEN ClusterType = 2 THEN 'Classify Clustering' ELSE NULL END) as StepOrTaskName, B.NewDisplayColumnName, B.OldDisplayColumnName--, A.ColumnNames
    from SSDL.ClusterConfiguration A
    INNER JOIN @InactiveColumnsList B ON A.MainTableName = @MainTableName AND (A.ColumnNames LIKE '%"' + B.OldDisplayColumnName + '"%' OR A.SpendColumn = B.OldDisplayColumnName)
    UNION
    select
    -- DISTINCT B.TableSchemaID
    DISTINCT 'Data lake mapping' AS Activity, NULL AS ParentStepName,  NULL as JobId, '' AS JobName, '' AS StepOrTaskName, B.NewDisplayColumnName, B.OldDisplayColumnName
    FROM OPENJSON((select JSON_QUERY(value, '$.mainTableFields')
        from OPENJSON((select JSON_QUERY(SettingValue, '$.mainTableDetails')
        from SSDL.JOB_DETAILS A
        where SettingName = 'DataLakeMapping' and JobId = -1))
        WHERE JSON_VALUE(value, '$.mainTableName') = @MainTableName))
    INNER JOIN @InactiveColumnsList B ON JSON_VALUE(value, '$.mainTableColumnName') = B.OldDisplayColumnName
    UNION
    select
    -- DISTINCT B.TableSchemaID
    DISTINCT 'Data lake mapping' AS Activity, NULL AS ParentStepName,  NULL as JobId, '' AS JobName, '' AS StepOrTaskName, B.NewDisplayColumnName, B.OldDisplayColumnName
    from OPENJSON((select JSON_QUERY(SettingValue, '$.exclusionFilter')
    from SSDL.JOB_DETAILS A
    where SettingName = 'DataLakeMapping' and JobId = -1))
    INNER JOIN @InactiveColumnsList B ON JSON_VALUE(value, '$.tableName') = @MainTableName
        AND JSON_VALUE(value, '$.selectField') = B.OldDisplayColumnName
)
SELECT DISTINCT Activity, ParentStepName, StepOrTaskName FROM CTE2 B
-- UPDATE A
-- SET A.IsUsedInProject = 1
-- SELECT a.*
-- FROM SSDL.SPEND_SSDL_TableSchema A
-- INNER JOIN CTE2 B ON A.TableSchemaId = B.TableSchemaId
