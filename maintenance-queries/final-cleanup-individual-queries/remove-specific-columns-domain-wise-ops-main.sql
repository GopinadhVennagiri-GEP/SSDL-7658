DECLARE @MainTableName VARCHAR(255);
DECLARE @OpsMainTableId INT;
DECLARE @MainTableTypeId INT;
DECLARE @DatabaseName VARCHAR(500);
SET @DatabaseName = DB_NAME();

DECLARE @InactiveColumnsList TABLE
(
    TableSchemaID INT,
    ColumnName VARCHAR(255),
    DisplayColumnName VARCHAR(255),
    IsUsedInProject BIT
);
SET @MainTableName = 'OPS_MAIN'
SELECT @MainTableTypeId = Table_TYP_ID FROM SSDL.SPEND_DCC_TABLE_TYP_MST where Table_TYP_code = 101
SELECT @OpsMainTableId = TableId FROM SSDL.SPEND_SSDL_TABLE WHERE TableTypeID = @MainTableTypeId AND TableName = @MainTableName;

DECLARE @ConfiguredJobs AS TABLE
(
    JobId BIGINT,
    JobName VARCHAR(500)
)

INSERT INTO @ConfiguredJobs
SELECT JOB_ID, JOB_NAME
FROM SSDL.SPEND_DL_SA_ACIVITYWORKMASTER A
WHERE A.JOB_STATUS NOT IN ('D') AND ISNULL(A.IsDeleted, 0) = 0;

INSERT INTO @InactiveColumnsList
SELECT TableSchemaID, ColumnName, DisplayColumnName, IsUsedInProject
FROM SSDL.SPEND_SSDL_TableSchema
where TableID = @OpsMainTableId
AND (
    (@DatabaseName = 'MACYS_SSDL' AND ColumnName IN ('CUSTOM_FIELD_2', 'CUSTOM_FIELD_3', 'CUSTOM_FIELD_4', 'CUSTOM_FIELD_5', 'CUSTOM_FIELD_6', 'CUSTOM_FIELD_7', 'CUSTOM_FIELD_8', 'CUSTOM_FIELD_9', 'CUSTOM_FIELD_10', 'CUSTOM_FIELD_11', 'CUSTOM_FIELD_12', 'CUSTOM_FIELD_13', 'CUSTOM_FIELD_15', 'CUSTOM_FIELD_16', 'CUSTOM_FIELD_17', 'CUSTOM_FIELD_18', 'CUSTOM_FIELD_19', 'CUSTOM_FIELD_20', 'CUSTOM_FIELD_21', 'CUSTOM_FIELD_22', 'CUSTOM_FIELD_23', 'CUSTOM_FIELD_24', 'CUSTOM_FIELD_25', 'CUSTOM_FIELD_26', 'CUSTOM_FIELD_27', 'CUSTOM_FIELD_28', 'CUSTOM_FIELD_29', 'CUSTOM_FIELD_30', 'CUSTOM_FIELD_31', 'CUSTOM_FIELD_32', 'CUSTOM_FIELD_33', 'CUSTOM_FIELD_34', 'CUSTOM_FIELD_35', 'CUSTOM_FIELD_36', 'CUSTOM_FIELD_37', 'CUSTOM_FIELD_38', 'CUSTOM_FIELD_39', 'CUSTOM_FIELD_40', 'CUSTOM_FIELD_41', 'CUSTOM_FIELD_42', 'CUSTOM_FIELD_43', 'CUSTOM_FIELD_44', 'CUSTOM_FIELD_45', 'CUSTOM_FIELD_46', 'CUSTOM_FIELD_47', 'CUSTOM_FIELD_48', 'CUSTOM_FIELD_49', 'CUSTOM_FIELD_50', 'CUSTOM_FIELD_51', 'CUSTOM_FIELD_52', 'CUSTOM_FIELD_53', 'CUSTOM_FIELD_54', 'CUSTOM_FIELD_55', 'CUSTOM_FIELD_56', 'CUSTOM_FIELD_57', 'CUSTOM_FIELD_58', 'CUSTOM_FIELD_59', 'CUSTOM_FIELD_60', 'CUSTOM_FIELD_61', 'CUSTOM_FIELD_62', 'CUSTOM_FIELD_63', 'CUSTOM_FIELD_64', 'CUSTOM_FIELD_65', 'CUSTOM_FIELD_66', 'CUSTOM_FIELD_67', 'CUSTOM_FIELD_68', 'CUSTOM_FIELD_69', 'CUSTOM_FIELD_70', 'CUSTOM_FIELD_71', 'CUSTOM_FIELD_72', 'CUSTOM_FIELD_73', 'CUSTOM_FIELD_74', 'CUSTOM_FIELD_211', 'CUSTOM_FIELD_212', 'CUSTOM_FIELD_213'))
);

--SELECT * FROM @InactiveColumnsList;

With CTE2 AS
(
    select
    -- DISTINCT B.TableSchemaID
    distinct A.JobId,D.JobName, 'Basic Details' AS Activity, (CASE WHEN JSON_VALUE(SettingValue, '$.SPEND_FIELDS') = B.ColumnName THEN 'Spend Field' WHEN JSON_VALUE(SettingValue, '$.DATE_FIELDS') = B.ColumnName THEN 'Date Field' END) AS StepOrTaskName, B.DisplayColumnName, B.ColumnName, a.ModifiedOn--, A.SettingValue
    from SSDL.SPEND_SSDL_JOB_DETAILS A
    INNER JOIN @InactiveColumnsList B ON A.SettingValue IS NOT NULL
    AND (JSON_VALUE(SettingValue, '$.SPEND_FIELDS') = B.ColumnName OR JSON_VALUE(SettingValue, '$.DATE_FIELDS') = B.ColumnName)
    INNER JOIN @ConfiguredJobs D ON A.JobId = D.JobId
    UNION
    select
    -- DISTINCT B.TableSchemaID
    distinct A.JobId,D.JobName, 'Consolidation' AS Activity, A.SettingName AS StepOrTaskName, B.DisplayColumnName, B.ColumnName, a.ModifiedOn--, A.SettingValue
    FROM SSDL.WorkflowEventSetting a
    INNER JOIN @InactiveColumnsList B ON a.SettingValue IS NOT NULL AND a.SettingValue like '%"' + B.ColumnName + '"%' AND a.EventId IS NOT NULL
        AND a.EventId BETWEEN 2220 AND 2310
    INNER JOIN @ConfiguredJobs D ON A.JobId = D.JobId
    UNION
    select
    -- DISTINCT B.TableSchemaID
    distinct A.JobId, D.JobName, 'Profile to publish' AS Activity, A.SettingName AS StepOrTaskName, B.DisplayColumnName, B.ColumnName, A.ModifiedOn--, A.SettingValue
    from ssdl.JOB_DETAILS AS A
    INNER JOIN @InactiveColumnsList B ON A.SettingValue IS NOT NULL AND A.SettingValue like '%"' + B.ColumnName+'"%' AND A.SettingName NOT IN ('DataLakeMapping') AND A.JobID NOT IN (-1, 0)
    INNER JOIN @ConfiguredJobs D ON A.JobId = D.JobId
    UNION
    SELECT
    -- DISTINCT B.TableSchemaID
    DISTINCT A.ImportFileId AS JobId, '' AS JobName, 'Import Utility' AS Activity, '' AS StepOrTaskName, B.DisplayColumnName, B.ColumnName, A.ModifiedOn--, NULL
    FROM SSDL.ImportFileColumnMappingLink A
    INNER JOIN @InactiveColumnsList B ON A.TableSchemaId = B.TableSchemaID
    INNER JOIN SSDL.ImportFiles C ON A.ImportFileId = C.Id AND C.DestinationTableId = @OpsMainTableId
    UNION
    SELECT
    -- DISTINCT B.TableSchemaID
    DISTINCT A.ImportFileId AS JobId, '' AS JobName, 'Import Utility' AS Activity, '' AS StepOrTaskName, B.DisplayColumnName, B.ColumnName, A.ModifiedOn--, NULL
    FROM SSDL.ImportFileCriteria A
    INNER JOIN @InactiveColumnsList B ON A.AggregationTableSchemaId = B.TableSchemaID
    INNER JOIN SSDL.ImportFiles C ON A.ImportFileId = C.Id AND C.DestinationTableId = @OpsMainTableId
    UNION
    SELECT
    -- DISTINCT B.TableSchemaID
    DISTINCT C.ImportFileId AS JobId, '' AS JobName, 'Import Utility' AS Activity, '' AS StepOrTaskName, B.DisplayColumnName, B.ColumnName, A.ModifiedOn--, NULL
    FROM SSDL.ImportFileCriteriaConditions A
    INNER JOIN @InactiveColumnsList B ON A.DestinationColumnTableSchemaId = B.TableSchemaID
    INNER JOIN SSDL.ImportFileCriteria C ON A.ImportFileCriteriaId = C.Id
    INNER JOIN SSDL.ImportFiles d ON C.ImportFileId = D.Id AND D.DestinationTableId = @OpsMainTableId
    UNION
    SELECT
    -- DISTINCT B.TableSchemaID
    DISTINCT A.TemplateId AS JobId, A.TemplateName AS JobName, 'Export Utility' AS Activity, '' AS StepOrTaskName, B.DisplayColumnName, B.ColumnName, A.ModifiedOn--, A.TemplateJSON
    FROM SSDL.ExportTemplateMaster A
    INNER JOIN @InactiveColumnsList B ON JSON_VALUE(A.TemplateJSON, '$.tableName') = @MainTableName
        AND A.TemplateJSON LIKE '%"' + B.ColumnName + '"%'
    UNION
    select
    -- DISTINCT B.TableSchemaID
    DISTINCT NULL as JobId, '' AS JobName, 'Clustering', (Case when ClusterType = 1 THEN 'Supplier Clustering' WHEN ClusterType = 2 THEN 'Classify Clustering' ELSE NULL END) as StepOrTaskName, B.DisplayColumnName, B.ColumnName, A.ModifiedOn--, A.ColumnNames
    from SSDL.ClusterConfiguration A
    INNER JOIN @InactiveColumnsList B ON A.MainTableName = @MainTableName AND (A.ColumnNames LIKE '%"' + B.ColumnName + '"%' OR A.SpendColumn = B.ColumnName)
    UNION
    select
    -- DISTINCT B.TableSchemaID
    DISTINCT NULL as JobId, '' AS JobName, 'Data lake mapping', '' AS StepOrTaskName, B.DisplayColumnName, B.ColumnName, NULL AS ModifiedOn--, value
    FROM OPENJSON((select JSON_QUERY(value, '$.mainTableFields')
        from OPENJSON((select JSON_QUERY(SettingValue, '$.mainTableDetails')
        from SSDL.JOB_DETAILS A
        where SettingName = 'DataLakeMapping' and JobId = -1))
        WHERE JSON_VALUE(value, '$.mainTableName') = @MainTableName))
    INNER JOIN @InactiveColumnsList B ON JSON_VALUE(value, '$.mainTableColumnName') = B.ColumnName
    UNION
    select
    -- DISTINCT B.TableSchemaID
    DISTINCT NULL as JobId, '' AS JobName, 'Data lake mapping', '' AS StepOrTaskName, B.DisplayColumnName, B.ColumnName, NULL AS ModifiedOn--, value
    from OPENJSON((select JSON_QUERY(SettingValue, '$.exclusionFilter')
    from SSDL.JOB_DETAILS A
    where SettingName = 'DataLakeMapping' and JobId = -1))
    INNER JOIN @InactiveColumnsList B ON JSON_VALUE(value, '$.tableName') = @MainTableName
        AND JSON_VALUE(value, '$.selectField') = B.ColumnName
)
SELECT * FROM CTE2 B
ORDER BY JobName, JobId, Activity, StepOrTaskName, DisplayColumnName
-- UPDATE A
-- SET A.IsUsedInProject = 1
-- SELECT A.TableSchemaId, A.ColumnName
-- FROM SSDL.SPEND_SSDL_TableSchema A
-- INNER JOIN CTE2 B ON A.TableSchemaId = B.TableSchemaId
