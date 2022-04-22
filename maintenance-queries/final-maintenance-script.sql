DECLARE @MainTableName VARCHAR(255);
DECLARE @DatabaseNamePattern VARCHAR(500);
DECLARE @DatabaseName VARCHAR(500);
DECLARE @OpsMainTableId INT;
DECLARE @MainTableTypeId INT;
SET @MainTableName = 'OPS_MAIN'
SELECT @MainTableTypeId = Table_TYP_ID FROM SSDL.SPEND_DCC_TABLE_TYP_MST where Table_TYP_code = 101
SELECT @OpsMainTableId = TableId FROM SSDL.SPEND_SSDL_TABLE WHERE TableTypeID = @MainTableTypeId AND TableName = @MainTableName;

SET @DatabaseNamePattern = 'UAT[_]%'
SET @DatabaseName = DB_NAME();

---1. Remove all inactive unconfigured uncreated custom columns.
IF @DatabaseName LIKE @DatabaseNamePattern AND ISNULL(@OpsMainTableId, 0) <> 0
BEGIN
    BEGIN TRY
        select TableSchemaID, ColumnName, DisplayColumnName, FieldCategory, IsUsedInProject
        from SSDL.SPEND_SSDL_TableSchema
        where TableID = @OpsMainTableId and FieldCategory = 'ERP - Custom Fields' and DisplayColumnName like 'CUSTOM FIELD (%' AND IsUsedInProject = 0

        DELETE from SSDL.SPEND_SSDL_TableSchema where TableID = @OpsMainTableId and FieldCategory = 'ERP - Custom Fields' and DisplayColumnName like 'CUSTOM FIELD (%' AND IsUsedInProject = 0
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(MAX)  
        DECLARE @ErrorSeverity NVARCHAR(20)  
        DECLARE @ErrorState NVARCHAR(20)  

        SELECT   
        @ErrorMessage = ERROR_MESSAGE(),   
        @ErrorSeverity = ERROR_SEVERITY(),   
        @ErrorState = ERROR_STATE();  

        -- return the error inside the CATCH block  
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState); 
        RETURN;
    END CATCH
END

---2. Identify and mark used but inactive columns as active.
IF @DatabaseName LIKE @DatabaseNamePattern AND ISNULL(@OpsMainTableId, 0) <> 0
BEGIN
    BEGIN TRY
        DECLARE @InactiveColumnsList TABLE
        (
            TableSchemaID INT,
            ColumnName VARCHAR(255),
            DisplayColumnName VARCHAR(255),
            IsUsedInProject BIT
        );

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
        where TableID = @OpsMainTableId and IsUsedInProject = 0
            AND (ColumnName not like 'CUSTOM[_]FIELD%'
                OR (ColumnName like 'CUSTOM[_]FIELD%' AND DisplayColumnName not like 'Custom Field (%')
            );

        --SELECT * FROM @InactiveColumnsList;

        With CTE2 AS
        (
            select
            DISTINCT B.TableSchemaID
            -- distinct 'Basic Details' AS Activity, A.JobId,D.JobName, (CASE WHEN JSON_VALUE(SettingValue, '$.SPEND_FIELDS') = B.ColumnName THEN 'Spend Field' WHEN JSON_VALUE(SettingValue, '$.DATE_FIELDS') = B.ColumnName THEN 'Date Field' END) AS StepOrTaskName, B.DisplayColumnName, B.ColumnName, a.ModifiedOn
            from SSDL.SPEND_SSDL_JOB_DETAILS A
            INNER JOIN @InactiveColumnsList B ON A.SettingValue IS NOT NULL
            AND (JSON_VALUE(SettingValue, '$.SPEND_FIELDS') = B.ColumnName OR JSON_VALUE(SettingValue, '$.DATE_FIELDS') = B.ColumnName)
            INNER JOIN @ConfiguredJobs D ON A.JobId = D.JobId
            UNION
            select
            DISTINCT B.TableSchemaID
            -- distinct 'Consolidation' AS Activity, A.JobId,D.JobName, A.SettingName AS StepOrTaskName, B.DisplayColumnName, B.ColumnName, a.ModifiedOn
            FROM SSDL.WorkflowEventSetting a
            INNER JOIN @InactiveColumnsList B ON a.SettingValue IS NOT NULL AND a.SettingValue like '%"' + B.ColumnName + '"%' AND a.EventId IS NOT NULL
                AND a.EventId BETWEEN 2220 AND 2310
            INNER JOIN @ConfiguredJobs D ON A.JobId = D.JobId
            UNION
            select
            DISTINCT B.TableSchemaID
            -- distinct 'Profile to publish' AS Activity, A.JobId, D.JobName, A.SettingName AS StepOrTaskName, B.DisplayColumnName, B.ColumnName, A.ModifiedOn
            from ssdl.JOB_DETAILS AS A
            INNER JOIN @InactiveColumnsList B ON A.SettingValue IS NOT NULL AND A.SettingValue like '%"' + B.ColumnName+'"%' AND A.SettingName NOT IN ('DataLakeMapping') AND A.JobID NOT IN (-1, 0)
            INNER JOIN @ConfiguredJobs D ON A.JobId = D.JobId
            UNION
            SELECT
            DISTINCT B.TableSchemaID
            -- DISTINCT 'Import Utility' AS Activity, A.ImportFileId AS JobId, '' AS JobName, '' AS StepOrTaskName, B.DisplayColumnName, B.ColumnName, A.ModifiedOn
            FROM SSDL.ImportFileColumnMappingLink A
            INNER JOIN @InactiveColumnsList B ON A.TableSchemaId = B.TableSchemaID
            UNION
            SELECT
            DISTINCT B.TableSchemaID
            -- DISTINCT 'Import Utility' AS Activity, A.ImportFileId AS JobId, '' AS JobName, '' AS StepOrTaskName, B.DisplayColumnName, B.ColumnName, A.ModifiedOn
            FROM SSDL.ImportFileCriteria A
            INNER JOIN @InactiveColumnsList B ON A.AggregationTableSchemaId = B.TableSchemaID
            UNION
            SELECT
            DISTINCT B.TableSchemaID
            -- DISTINCT 'Import Utility' AS Activity, C.ImportFileId AS JobId, '' AS JobName, '' AS StepOrTaskName, B.DisplayColumnName, B.ColumnName, A.ModifiedOn
            FROM SSDL.ImportFileCriteriaConditions A
            INNER JOIN @InactiveColumnsList B ON A.DestinationColumnTableSchemaId = B.TableSchemaID
            INNER JOIN SSDL.ImportFileCriteria C ON A.ImportFileCriteriaId = C.Id
            UNION
            SELECT
            DISTINCT B.TableSchemaID
            -- DISTINCT 'Export Utility' AS Activity, A.TemplateId AS JobId, A.TemplateName AS JobName, '' AS StepOrTaskName, B.DisplayColumnName, B.ColumnName, A.ModifiedOn
            FROM SSDL.ExportTemplateMaster A
            INNER JOIN @InactiveColumnsList B ON JSON_VALUE(A.TemplateJSON, '$.tableName') = @MainTableName
                AND A.TemplateJSON LIKE '%"' + B.ColumnName + '"%'
            UNION
            select
            DISTINCT B.TableSchemaID
            -- DISTINCT 'Clustering', NULL as JobId, '' AS JobName, (Case when ClusterType = 1 THEN 'Supplier Clustering' WHEN ClusterType = 2 THEN 'Classify Clustering' ELSE NULL END) as StepOrTaskName, B.DisplayColumnName, B.ColumnName, A.ModifiedOn--, A.ColumnNames
            from SSDL.ClusterConfiguration A
            INNER JOIN @InactiveColumnsList B ON A.MainTableName = @MainTableName AND (A.ColumnNames LIKE '%"' + B.ColumnName + '"%' OR A.SpendColumn = B.ColumnName)
            UNION
            select
            DISTINCT B.TableSchemaID
            -- DISTINCT 'Data lake mapping', NULL as JobId, '' AS JobName, '' AS StepOrTaskName, B.DisplayColumnName, B.ColumnName, NULL AS ModifiedOn
            FROM OPENJSON((select JSON_QUERY(value, '$.mainTableFields')
                from OPENJSON((select JSON_QUERY(SettingValue, '$.mainTableDetails')
                from SSDL.JOB_DETAILS A
                where SettingName = 'DataLakeMapping' and JobId = -1))
                WHERE JSON_VALUE(value, '$.mainTableName') = @MainTableName))
            INNER JOIN @InactiveColumnsList B ON JSON_VALUE(value, '$.mainTableColumnName') = B.ColumnName
            UNION
            select
            DISTINCT B.TableSchemaID
            -- DISTINCT 'Data lake mapping', NULL as JobId, '' AS JobName, '' AS StepOrTaskName, B.DisplayColumnName, B.ColumnName, NULL AS ModifiedOn
            from OPENJSON((select JSON_QUERY(SettingValue, '$.exclusionFilter')
            from SSDL.JOB_DETAILS A
            where SettingName = 'DataLakeMapping' and JobId = -1))
            INNER JOIN @InactiveColumnsList B ON JSON_VALUE(value, '$.tableName') = @MainTableName
                AND JSON_VALUE(value, '$.selectField') = B.ColumnName
        )
        -- SELECT * FROM CTE2 B
        UPDATE A
        SET A.IsUsedInProject = 1
        -- SELECT A.TableSchemaId, A.ColumnName
        FROM SSDL.SPEND_SSDL_TableSchema A
        INNER JOIN CTE2 B ON A.TableSchemaId = B.TableSchemaIdEND
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(MAX)  
        DECLARE @ErrorSeverity NVARCHAR(20)  
        DECLARE @ErrorState NVARCHAR(20)  

        SELECT   
        @ErrorMessage = ERROR_MESSAGE(),   
        @ErrorSeverity = ERROR_SEVERITY(),   
        @ErrorState = ERROR_STATE();  

        -- return the error inside the CATCH block  
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState); 
        RETURN;
    END CATCH
END

---3. Remove all remaining inactive columns.
IF @DatabaseName LIKE @DatabaseNamePattern AND ISNULL(@OpsMainTableId, 0) <> 0
BEGIN
    BEGIN TRY
        DELETE FROM SSDL.SPEND_SSDL_TableSchema where TableID = @OpsMainTableId and IsUsedInProject = 0
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(MAX)  
        DECLARE @ErrorSeverity NVARCHAR(20)  
        DECLARE @ErrorState NVARCHAR(20)  

        SELECT   
        @ErrorMessage = ERROR_MESSAGE(),   
        @ErrorSeverity = ERROR_SEVERITY(),   
        @ErrorState = ERROR_STATE();  

        -- return the error inside the CATCH block  
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState); 
        RETURN;
    END CATCH
END

-- 4. Correct data type.
IF @DatabaseName LIKE @DatabaseNamePattern AND ISNULL(@OpsMainTableId, 0) <> 0
BEGIN
    BEGIN TRY
        DELETE FROM SSDL.SPEND_SSDL_TableSchema where TableID = @OpsMainTableId and IsUsedInProject = 0
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(MAX)  
        DECLARE @ErrorSeverity NVARCHAR(20)  
        DECLARE @ErrorState NVARCHAR(20)  

        SELECT   
        @ErrorMessage = ERROR_MESSAGE(),   
        @ErrorSeverity = ERROR_SEVERITY(),   
        @ErrorState = ERROR_STATE();  

        -- return the error inside the CATCH block  
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState); 
        RETURN;
    END CATCH
END