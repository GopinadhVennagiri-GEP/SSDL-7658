
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
    DECLARE @BackupInactiveColumnsList TABLE
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

    INSERT INTO @InactiveColumnsList
    SELECT A.TableSchemaID, A.ColumnName, A.DisplayColumnName, A.IsUsedInProject
    FROM SSDL.SPEND_SSDL_TableSchema A
    INNER JOIN SSDL.MainTableColumnsMaster B ON A.ColumnName = B.ColumnName
    where A.TableID = @OpsMainTableId AND A.IsUsedInProject = 1 AND B.IsSelectionMandatory = 0 and A.ColumnName not like 'CUSTOM[_]FIELD%'

    -- SELECT * FROM @InactiveColumnsList

    -- SELECT * FROM @InactiveColumnsList;

    -- With CTE2 AS
    -- (
        INSERT INTO @BackupInactiveColumnsList
        select B.TableSchemaID, B.ColumnName, B.DisplayColumnName, B.IsUsedInProject
        -- distinct 'Basic Details' AS Activity, A.JobId,D.JobName, (CASE WHEN JSON_VALUE(SettingValue, '$.SPEND_FIELDS') = B.ColumnName THEN 'Spend Field' WHEN JSON_VALUE(SettingValue, '$.DATE_FIELDS') = B.ColumnName THEN 'Date Field' END) AS StepOrTaskName, B.DisplayColumnName, B.ColumnName, a.ModifiedOn
        from SSDL.SPEND_SSDL_JOB_DETAILS A
        INNER JOIN @InactiveColumnsList B ON A.SettingValue IS NOT NULL
        AND (JSON_VALUE(SettingValue, '$.SPEND_FIELDS') = B.ColumnName OR JSON_VALUE(SettingValue, '$.DATE_FIELDS') = B.ColumnName)
        INNER JOIN @ConfiguredJobs D ON A.JobId = D.JobId

        INSERT INTO @BackupInactiveColumnsList
        select B.TableSchemaID, B.ColumnName, B.DisplayColumnName, B.IsUsedInProject
        FROM SSDL.WorkflowEventSetting a
        INNER JOIN @InactiveColumnsList B ON a.SettingValue IS NOT NULL AND a.SettingValue like '%"' + B.ColumnName + '"%' AND a.EventId IS NOT NULL
            AND a.EventId BETWEEN 2220 AND 2310
        INNER JOIN @ConfiguredJobs D ON A.JobId = D.JobId

        INSERT INTO @BackupInactiveColumnsList
        select B.TableSchemaID, B.ColumnName, B.DisplayColumnName, B.IsUsedInProject
        from ssdl.JOB_DETAILS AS A
        INNER JOIN @InactiveColumnsList B ON A.SettingValue IS NOT NULL AND A.SettingValue like '%"' + B.ColumnName+'"%' AND A.SettingName NOT IN ('DataLakeMapping') AND A.JobID NOT IN (-1, 0)
        INNER JOIN @ConfiguredJobs D ON A.JobId = D.JobId

        INSERT INTO @BackupInactiveColumnsList
        select B.TableSchemaID, B.ColumnName, B.DisplayColumnName, B.IsUsedInProject
        FROM SSDL.ImportFileColumnMappingLink A
        INNER JOIN @InactiveColumnsList B ON A.TableSchemaId = B.TableSchemaID
        -- INNER JOIN SSDL.ImportFiles B ON A.ImportFileId = B.Id AND B.DestinationTableId = @OpsMainTableId

        INSERT INTO @BackupInactiveColumnsList
        select B.TableSchemaID, B.ColumnName, B.DisplayColumnName, B.IsUsedInProject
        FROM SSDL.ImportFileCriteria A
        INNER JOIN @InactiveColumnsList B ON A.AggregationTableSchemaId = B.TableSchemaID
        -- INNER JOIN SSDL.ImportFiles B ON A.ImportFileId = B.Id AND B.DestinationTableId = @OpsMainTableId

        INSERT INTO @BackupInactiveColumnsList
        select B.TableSchemaID, B.ColumnName, B.DisplayColumnName, B.IsUsedInProject
        FROM SSDL.ImportFileCriteriaConditions A
        INNER JOIN @InactiveColumnsList B ON A.DestinationColumnTableSchemaId = B.TableSchemaID
        INNER JOIN SSDL.ImportFileCriteria C ON A.ImportFileCriteriaId = C.Id
        -- INNER JOIN SSDL.ImportFiles d ON B.ImportFileId = C.Id AND C.DestinationTableId = @OpsMainTableId

        INSERT INTO @BackupInactiveColumnsList
        select B.TableSchemaID, B.ColumnName, B.DisplayColumnName, B.IsUsedInProject
        FROM SSDL.ExportTemplateMaster A
        INNER JOIN @InactiveColumnsList B ON JSON_VALUE(A.TemplateJSON, '$.tableName') = @MainTableName
            AND A.TemplateJSON LIKE '%"' + B.ColumnName + '"%'

        INSERT INTO @BackupInactiveColumnsList
        select B.TableSchemaID, B.ColumnName, B.DisplayColumnName, B.IsUsedInProject
        from SSDL.ClusterConfiguration A
        INNER JOIN @InactiveColumnsList B ON A.MainTableName = @MainTableName AND (A.ColumnNames LIKE '%"' + B.ColumnName + '"%' OR A.SpendColumn = B.ColumnName)

        INSERT INTO @BackupInactiveColumnsList
        select B.TableSchemaID, B.ColumnName, B.DisplayColumnName, B.IsUsedInProject
        FROM OPENJSON((select JSON_QUERY(value, '$.mainTableFields')
            from OPENJSON((select JSON_QUERY(SettingValue, '$.mainTableDetails')
            from SSDL.JOB_DETAILS A
            where SettingName = 'DataLakeMapping' and JobId = -1))
            WHERE JSON_VALUE(value, '$.mainTableName') = @MainTableName))
        INNER JOIN @InactiveColumnsList B ON JSON_VALUE(value, '$.mainTableColumnName') = B.ColumnName

        INSERT INTO @BackupInactiveColumnsList
        select B.TableSchemaID, B.ColumnName, B.DisplayColumnName, B.IsUsedInProject
        from OPENJSON((select JSON_QUERY(SettingValue, '$.exclusionFilter')
        from SSDL.JOB_DETAILS A
        where SettingName = 'DataLakeMapping' and JobId = -1))
        INNER JOIN @InactiveColumnsList B ON JSON_VALUE(value, '$.tableName') = @MainTableName
            AND JSON_VALUE(value, '$.selectField') = B.ColumnName
    -- )
    -- SELECT * FROM CTE2 B

    SELECT A.*
    FROM @InactiveColumnsList A
    LEFT JOIN @BackupInactiveColumnsList B ON A.ColumnName = B.ColumnName
    WHERE B.ColumnName IS NULL
END