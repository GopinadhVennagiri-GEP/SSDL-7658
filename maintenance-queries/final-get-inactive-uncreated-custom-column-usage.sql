IF 1=0
BEGIN
    DECLARE @MainTableName VARCHAR(255);
    DECLARE @OpsMainTableId INT;
    DECLARE @MainTableTypeId INT;
    
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
    WHERE ((A.JOB_TYPE_NAME = 1 AND A.JOB_STATUS IN ('M', 'E'))
    OR (A.JOB_TYPE_NAME = 2 AND A.JOB_STATUS IN ('M', 'N', 'E', 'SL', 'P', 'R', 'AW'))
    )
    AND EXISTS(SELECT 1 FROM SSDL.SPEND_DL_SA_ACTIVITYWORKTRANSACTIONS B WHERE B.JOB_ID = A.JOB_ID)
    AND ISNULL(A.IsDeleted, 0) = 0;

    INSERT INTO @InactiveColumnsList
    SELECT TableSchemaID, ColumnName, DisplayColumnName, IsUsedInProject
    FROM SSDL.SPEND_SSDL_TableSchema
    where TableID = @OpsMainTableId AND IsUsedInProject = 0
    and (ColumnName like 'CUSTOM[_]FIELD%' AND DisplayColumnName like 'Custom Field (%')

    -- SELECT * FROM @InactiveColumnsList;

    -- With CTE2 AS
    -- (
        select distinct 'Consolidation' AS Activity, A.JobId,D.JobName, A.SettingName AS StepOrTaskName, B.DisplayColumnName, B.ColumnName, a.ModifiedOn, B.IsUsedInProject
        FROM SSDL.WorkflowEventSetting a
        INNER JOIN @InactiveColumnsList B ON a.SettingValue IS NOT NULL AND a.SettingValue like '%"' + B.ColumnName + '"%' AND a.EventId IS NOT NULL
            AND a.EventId BETWEEN 2220 AND 2310
        INNER JOIN @ConfiguredJobs D ON A.JobId = D.JobId
        UNION
        select distinct 'Profile to publish' AS Activity, A.JobId, D.JobName, A.SettingName AS StepOrTaskName, B.DisplayColumnName, B.ColumnName, A.ModifiedOn, B.IsUsedInProject
        from ssdl.JOB_DETAILS AS A
        INNER JOIN @InactiveColumnsList B ON A.SettingValue IS NOT NULL AND A.SettingValue like '%"' + B.ColumnName+'"%' AND A.SettingName NOT IN ('DataLakeMapping') AND A.JobID NOT IN (-1, 0)
        INNER JOIN @ConfiguredJobs D ON A.JobId = D.JobId
        UNION
        SELECT DISTINCT 'Import Utility' AS Activity, A.ImportFileId AS JobId, '' AS JobName, '' AS StepOrTaskName, B.DisplayColumnName, B.ColumnName, A.ModifiedOn, B.IsUsedInProject
        FROM SSDL.ImportFileColumnMappingLink A
        INNER JOIN @InactiveColumnsList B ON A.TableSchemaId = B.TableSchemaID
        -- INNER JOIN SSDL.ImportFiles B ON A.ImportFileId = B.Id AND B.DestinationTableId = @OpsMainTableId
        UNION
        SELECT DISTINCT 'Import Utility' AS Activity, A.ImportFileId AS JobId, '' AS JobName, '' AS StepOrTaskName, B.DisplayColumnName, B.ColumnName, A.ModifiedOn, B.IsUsedInProject
        FROM SSDL.ImportFileCriteria A
        INNER JOIN @InactiveColumnsList B ON A.AggregationTableSchemaId = B.TableSchemaID
        -- INNER JOIN SSDL.ImportFiles B ON A.ImportFileId = B.Id AND B.DestinationTableId = @OpsMainTableId
        UNION
        SELECT DISTINCT 'Import Utility' AS Activity, C.ImportFileId AS JobId, '' AS JobName, '' AS StepOrTaskName, B.DisplayColumnName, B.ColumnName, A.ModifiedOn, B.IsUsedInProject
        FROM SSDL.ImportFileCriteriaConditions A
        INNER JOIN @InactiveColumnsList B ON A.DestinationColumnTableSchemaId = B.TableSchemaID
        INNER JOIN SSDL.ImportFileCriteria C ON A.ImportFileCriteriaId = C.Id
        -- INNER JOIN SSDL.ImportFiles d ON B.ImportFileId = C.Id AND C.DestinationTableId = @OpsMainTableId
        UNION
        SELECT DISTINCT 'Export Utility' AS Activity, A.TemplateId AS JobId, A.TemplateName AS JobName, '' AS StepOrTaskName, B.DisplayColumnName, B.ColumnName, A.ModifiedOn, B.IsUsedInProject
        FROM SSDL.ExportTemplateMaster A
        INNER JOIN @InactiveColumnsList B ON ISNULL(A.IsDeleted, 0) = 0 AND JSON_VALUE(A.TemplateJSON, '$.tableName') = @MainTableName
            AND A.TemplateJSON LIKE '%"' + B.ColumnName + '"%'
        UNION
        select DISTINCT 'Clustering', NULL as JobId, '' AS JobName, (Case when ClusterType = 1 THEN 'Supplier Clustering' WHEN ClusterType = 2 THEN 'Classify Clustering' ELSE NULL END) as StepOrTaskName, B.DisplayColumnName, B.ColumnName, A.ModifiedOn, B.IsUsedInProject
        from SSDL.ClusterConfiguration A
        INNER JOIN @InactiveColumnsList B ON A.MainTableName = @MainTableName AND (A.ColumnNames LIKE '%"' + B.ColumnName + '"%' OR A.SpendColumn = B.ColumnName)
        UNION
        select DISTINCT 'Data lake mapping', NULL as JobId, '' AS JobName, '' AS StepOrTaskName, B.DisplayColumnName, B.ColumnName, NULL AS ModifiedOn, B.IsUsedInProject
        FROM OPENJSON((select JSON_QUERY(value, '$.mainTableFields')
            from OPENJSON((select JSON_QUERY(SettingValue, '$.mainTableDetails')
            from SSDL.JOB_DETAILS A
            where SettingName = 'DataLakeMapping' and JobId = -1))
            WHERE JSON_VALUE(value, '$.mainTableName') = @MainTableName))
        INNER JOIN @InactiveColumnsList B ON JSON_VALUE(value, '$.mainTableColumnName') = B.ColumnName
        UNION
        select DISTINCT 'Data lake mapping', NULL as JobId, '' AS JobName, '' AS StepOrTaskName, B.DisplayColumnName, B.ColumnName, NULL AS ModifiedOn, B.IsUsedInProject
        from OPENJSON((select JSON_QUERY(SettingValue, '$.exclusionFilter')
        from SSDL.JOB_DETAILS A
        where SettingName = 'DataLakeMapping' and JobId = -1))
        INNER JOIN @InactiveColumnsList B ON JSON_VALUE(value, '$.tableName') = @MainTableName
            AND JSON_VALUE(value, '$.selectField') = B.ColumnName
    -- )
    -- SELECT * FROM CTE2 B
    -- UPDATE A
    -- SET A.IsUsedInProject = 1
    -- SELECT A.TableSchemaId, A.ColumnName
    -- FROM SSDL.SPEND_SSDL_TableSchema A
    -- INNER JOIN CTE2 B ON A.TableSchemaId = B.TableSchemaId
END