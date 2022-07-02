
--hologic

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
    (@DatabaseName = 'Hologic_SSDL' AND ColumnName IN ('GEP_NORM_INVOICE_QUANTITY','DEPARTMENT_DESCRIPTION','COMPANY_REGION','SOURCESYSTEM_3','CUSTOM_FIELD_47','CUSTOM_FIELD_61','CUSTOM_FIELD_63','CUSTOM_FIELD_64','CUSTOM_FIELD_70','CUSTOM_FIELD_75','CUSTOM_FIELD_76','CUSTOM_FIELD_77','CUSTOM_FIELD_78','CUSTOM_FIELD_79','CUSTOM_FIELD_80','CUSTOM_FIELD_81','CUSTOM_FIELD_83','CUSTOM_FIELD_84','CUSTOM_FIELD_85','CUSTOM_FIELD_243','CUSTOM_FIELD_244','CUSTOM_FIELD_245'))
    OR (@DatabaseName = 'Ranstad_SSDL' AND ColumnName IN ('PLANT_COUNTRY','SOURCESYSTEM_3','PLANT_STATE','PRODUCT','PROJECT_DESC','PLANT_CITY','PO_PLANT_ADDRESS','PO_COST_CENTER_CODE','GEP_NORM_DISCOUNT_DAYS','PO_COST_CENTER_NAME','GEP_NORM_DISCOUNT_PERCENTAGE','CONTRACT_LINE_NUMBER','PO_PLANT_TYPE','CONTRACT_OWNER','REQUISITION_NUMBER','GEP_NORM_PLANT_NAME','PLANT_REGION','PLANT_TYPE'))
    OR (@DatabaseName = 'RoyalLondon_SSDL' AND ColumnName IN ('BUSINESS_DIVISION','PO_SUPPLIER_NUMBER','PO_PURCHASING_ORG_NAME','SOURCESYSTEM_2','SOURCESYSTEM_3','CUSTOM_FIELD_86','CUSTOM_FIELD_242'))
);

--SELECT * FROM @InactiveColumnsList;

With CTE2 AS
(
    select
    -- DISTINCT B.TableSchemaID
    distinct 'Basic Details' AS Activity, A.JobId,D.JobName, (CASE WHEN JSON_VALUE(SettingValue, '$.SPEND_FIELDS') = B.ColumnName THEN 'Spend Field' WHEN JSON_VALUE(SettingValue, '$.DATE_FIELDS') = B.ColumnName THEN 'Date Field' END) AS StepOrTaskName, B.DisplayColumnName, B.ColumnName, a.ModifiedOn--, A.SettingValue
    from SSDL.SPEND_SSDL_JOB_DETAILS A
    INNER JOIN @InactiveColumnsList B ON A.SettingValue IS NOT NULL
    AND (JSON_VALUE(SettingValue, '$.SPEND_FIELDS') = B.ColumnName OR JSON_VALUE(SettingValue, '$.DATE_FIELDS') = B.ColumnName)
    INNER JOIN @ConfiguredJobs D ON A.JobId = D.JobId
    UNION
    select
    -- DISTINCT B.TableSchemaID
    distinct 'Consolidation' AS Activity, A.JobId,D.JobName, A.SettingName AS StepOrTaskName, B.DisplayColumnName, B.ColumnName, a.ModifiedOn--, A.SettingValue
    FROM SSDL.WorkflowEventSetting a
    INNER JOIN @InactiveColumnsList B ON a.SettingValue IS NOT NULL AND a.SettingValue like '%"' + B.ColumnName + '"%' AND a.EventId IS NOT NULL
        AND a.EventId BETWEEN 2220 AND 2310
    INNER JOIN @ConfiguredJobs D ON A.JobId = D.JobId
    UNION
    select
    -- DISTINCT B.TableSchemaID
    distinct 'Profile to publish' AS Activity, A.JobId, D.JobName, A.SettingName AS StepOrTaskName, B.DisplayColumnName, B.ColumnName, A.ModifiedOn--, A.SettingValue
    from ssdl.JOB_DETAILS AS A
    INNER JOIN @InactiveColumnsList B ON A.SettingValue IS NOT NULL AND A.SettingValue like '%"' + B.ColumnName+'"%' AND A.SettingName NOT IN ('DataLakeMapping') AND A.JobID NOT IN (-1, 0)
    INNER JOIN @ConfiguredJobs D ON A.JobId = D.JobId
    UNION
    SELECT
    -- DISTINCT B.TableSchemaID
    DISTINCT 'Import Utility' AS Activity, A.ImportFileId AS JobId, '' AS JobName, '' AS StepOrTaskName, B.DisplayColumnName, B.ColumnName, A.ModifiedOn--, NULL
    FROM SSDL.ImportFileColumnMappingLink A
    INNER JOIN @InactiveColumnsList B ON A.TableSchemaId = B.TableSchemaID
    INNER JOIN SSDL.ImportFiles C ON A.ImportFileId = C.Id AND C.DestinationTableId = @OpsMainTableId
    UNION
    SELECT
    -- DISTINCT B.TableSchemaID
    DISTINCT 'Import Utility' AS Activity, A.ImportFileId AS JobId, '' AS JobName, '' AS StepOrTaskName, B.DisplayColumnName, B.ColumnName, A.ModifiedOn--, NULL
    FROM SSDL.ImportFileCriteria A
    INNER JOIN @InactiveColumnsList B ON A.AggregationTableSchemaId = B.TableSchemaID
    INNER JOIN SSDL.ImportFiles C ON A.ImportFileId = C.Id AND C.DestinationTableId = @OpsMainTableId
    UNION
    SELECT
    -- DISTINCT B.TableSchemaID
    DISTINCT 'Import Utility' AS Activity, C.ImportFileId AS JobId, '' AS JobName, '' AS StepOrTaskName, B.DisplayColumnName, B.ColumnName, A.ModifiedOn--, NULL
    FROM SSDL.ImportFileCriteriaConditions A
    INNER JOIN @InactiveColumnsList B ON A.DestinationColumnTableSchemaId = B.TableSchemaID
    INNER JOIN SSDL.ImportFileCriteria C ON A.ImportFileCriteriaId = C.Id
    INNER JOIN SSDL.ImportFiles d ON C.ImportFileId = D.Id AND D.DestinationTableId = @OpsMainTableId
    UNION
    SELECT
    -- DISTINCT B.TableSchemaID
    DISTINCT 'Export Utility' AS Activity, A.TemplateId AS JobId, A.TemplateName AS JobName, '' AS StepOrTaskName, B.DisplayColumnName, B.ColumnName, A.ModifiedOn--, A.TemplateJSON
    FROM SSDL.ExportTemplateMaster A
    INNER JOIN @InactiveColumnsList B ON JSON_VALUE(A.TemplateJSON, '$.tableName') = @MainTableName
        AND A.TemplateJSON LIKE '%"' + B.ColumnName + '"%'
    UNION
    select
    -- DISTINCT B.TableSchemaID
    DISTINCT 'Clustering', NULL as JobId, '' AS JobName, (Case when ClusterType = 1 THEN 'Supplier Clustering' WHEN ClusterType = 2 THEN 'Classify Clustering' ELSE NULL END) as StepOrTaskName, B.DisplayColumnName, B.ColumnName, A.ModifiedOn--, A.ColumnNames
    from SSDL.ClusterConfiguration A
    INNER JOIN @InactiveColumnsList B ON A.MainTableName = @MainTableName AND (A.ColumnNames LIKE '%"' + B.ColumnName + '"%' OR A.SpendColumn = B.ColumnName)
    UNION
    select
    -- DISTINCT B.TableSchemaID
    DISTINCT 'Data lake mapping', NULL as JobId, '' AS JobName, '' AS StepOrTaskName, B.DisplayColumnName, B.ColumnName, NULL AS ModifiedOn--, value
    FROM OPENJSON((select JSON_QUERY(value, '$.mainTableFields')
        from OPENJSON((select JSON_QUERY(SettingValue, '$.mainTableDetails')
        from SSDL.JOB_DETAILS A
        where SettingName = 'DataLakeMapping' and JobId = -1))
        WHERE JSON_VALUE(value, '$.mainTableName') = @MainTableName))
    INNER JOIN @InactiveColumnsList B ON JSON_VALUE(value, '$.mainTableColumnName') = B.ColumnName
    UNION
    select
    -- DISTINCT B.TableSchemaID
    DISTINCT 'Data lake mapping', NULL as JobId, '' AS JobName, '' AS StepOrTaskName, B.DisplayColumnName, B.ColumnName, NULL AS ModifiedOn--, value
    from OPENJSON((select JSON_QUERY(SettingValue, '$.exclusionFilter')
    from SSDL.JOB_DETAILS A
    where SettingName = 'DataLakeMapping' and JobId = -1))
    INNER JOIN @InactiveColumnsList B ON JSON_VALUE(value, '$.tableName') = @MainTableName
        AND JSON_VALUE(value, '$.selectField') = B.ColumnName
)
SELECT * FROM CTE2 B
-- UPDATE A
-- SET A.IsUsedInProject = 1
-- SELECT A.TableSchemaId, A.ColumnName
-- FROM SSDL.SPEND_SSDL_TableSchema A
-- INNER JOIN CTE2 B ON A.TableSchemaId = B.TableSchemaId
