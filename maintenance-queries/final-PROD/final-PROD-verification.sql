
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

;WITH CTE AS (
select a.ColumnName, a.DisplayColumnName, a.IsUsedInProject, b.SettingName, b.SettingValue
from SSDL.SPEND_SSDL_TableSchema a
join SSDL.WorkflowEventSetting b ON EventID = 2301 AND SettingValue like '%' + a.ColumnName + '%'
    AND ISNULL(a.IsUsedInProject, 0) = 0 AND a.TableId = @OpsMainTableId
)
SELECT * FROM CTE
-----------------------------------------------------------

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

---(-1). Make columns active if they are used in Publish Pre-defined steps
IF @DatabaseName LIKE @DatabaseNamePattern AND ISNULL(@OpsMainTableId, 0) <> 0
BEGIN
    BEGIN TRY
        ;WITH CTE AS (
        select DISTINCT a.ColumnName --, a.DisplayColumnName, a.IsUsedInProject, b.SettingName, b.SettingValue
        from SSDL.SPEND_SSDL_TableSchema a
        join SSDL.JOB_DETAILS b ON SettingName = 'PreDefinedSteps' AND SettingValue like '%' + a.ColumnName + '%'
            AND ISNULL(a.IsUsedInProject, 0) = 0 AND a.TableId = @OpsMainTableId
        )
        SELECT * FROM CTE
        -- UPDATE A
        -- SET A.IsUsedInProject = 1
        -- FROM SSDL.SPEND_SSDL_TableSchema A
        -- JOIN CTE B ON A.TableID = @OpsMainTableId AND A.ColumnName = B.ColumnName
    END TRY
    BEGIN CATCH
        SELECT
        @ErrorMessage = 'Failed - (-1)' + ERROR_MESSAGE(),   
        @ErrorSeverity = ERROR_SEVERITY(),   
        @ErrorState = ERROR_STATE();  

        -- return the error inside the CATCH block  
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
        RETURN;
    END CATCH
    PRINT 'Complete - (-1)';
END

--------------------------------------------

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

---1. Add missing mandatory columns to OPS_MAIN
IF @DatabaseName LIKE @DatabaseNamePattern AND ISNULL(@OpsMainTableId, 0) <> 0
BEGIN
    BEGIN TRY
        SELECT
        -- A.*
        @OpsMainTableId,A.ColumnName,A.DisplayColumnName,A.FieldCategory,C.DATA_TYP_ID,A.ColumnDataLength,1 AS CreatedBy,GETDATE() AS CreatedDate,1 AS LastUpdatedBy,GETDATE() AS LastUpdatedDate,A.IsInputField,A.IsPrimaryKey,NULL AS DataFormatID,NULL AS ColumnScopeRefEnumValueId,CAST(1 AS BIT) AS IsUsedInProject
        FROM SSDL.MainTableColumnsMaster A
        join ssdl.SPEND_DCC_TABLE_DATA_TYP_MST C on A.DataTypeId = C.DATA_TYP_ID
        LEFT JOIN SSDL.SPEND_SSDL_TableSchema B ON A.ColumnName = B.ColumnName AND B.TableID = @OpsMainTableId
        WHERE B.ColumnName IS NULL AND A.IsSelectionMandatory = 1
    END TRY
    BEGIN CATCH
        SELECT
        @ErrorMessage = 'Failed - 1' + ERROR_MESSAGE(),   
        @ErrorSeverity = ERROR_SEVERITY(),   
        @ErrorState = ERROR_STATE();  

        -- return the error inside the CATCH block  
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
        RETURN;
    END CATCH
    PRINT 'Complete - 1';
END

--------------------------------

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

---2. Make mandatory columns Active in OPS_MAIN if inactive
IF @DatabaseName LIKE @DatabaseNamePattern AND ISNULL(@OpsMainTableId, 0) <> 0
BEGIN
    BEGIN TRY
        SELECT A.ColumnName, B.IsUsedInProject
        FROM SSDL.MainTableColumnsMaster A
        JOIN SSDL.SPEND_SSDL_TableSchema B ON A.ColumnName = B.ColumnName AND B.TableID = @OpsMainTableId AND ISNULL(B.IsUsedInProject, 0) = 0 AND A.IsSelectionMandatory = 1
    END TRY
    BEGIN CATCH
        SELECT
        @ErrorMessage = 'Failed - 2' + ERROR_MESSAGE(),   
        @ErrorSeverity = ERROR_SEVERITY(),   
        @ErrorState = ERROR_STATE();  

        -- return the error inside the CATCH block  
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
        RETURN;
    END CATCH
    PRINT 'Complete - 2';
END

----------------------------------------

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

---3. Remove all inactive unconfigured uncreated custom columns.
IF @DatabaseName LIKE @DatabaseNamePattern AND ISNULL(@OpsMainTableId, 0) <> 0
BEGIN
    BEGIN TRY
        SELECT ColumnName from SSDL.SPEND_SSDL_TableSchema
        where TableID = @OpsMainTableId and FieldCategory = 'ERP - Custom Fields'
        and DisplayColumnName like 'CUSTOM FIELD (%' AND IsUsedInProject = 0
    END TRY
    BEGIN CATCH

        SELECT
        @ErrorMessage = 'Failed - 3' + ERROR_MESSAGE(),   
        @ErrorSeverity = ERROR_SEVERITY(),   
        @ErrorState = ERROR_STATE();  

        -- return the error inside the CATCH block  
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
        RETURN;
    END CATCH
    PRINT 'Complete - 3';
END

-----------------------------------------------

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

---4. Identify and mark "used but inactive" columns as active.
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
                OR
                (ColumnName like 'CUSTOM[_]FIELD%' AND DisplayColumnName not like 'Custom Field (%')
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
        -- UPDATE A
        -- SET A.IsUsedInProject = 1
        SELECT A.TableSchemaId, A.ColumnName, A.IsUsedInProject
        FROM SSDL.SPEND_SSDL_TableSchema A
        INNER JOIN CTE2 B ON A.TableSchemaId = B.TableSchemaId
    END TRY
    BEGIN CATCH
        SELECT
        @ErrorMessage = 'Failed - 4' + ERROR_MESSAGE(),   
        @ErrorSeverity = ERROR_SEVERITY(),   
        @ErrorState = ERROR_STATE();  

        -- return the error inside the CATCH block  
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
        RETURN;
    END CATCH
    PRINT 'Complete - 4';
END

-----------------------------------------------

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

---5. Remove all remaining inactive columns and also remove active but uncreated custom columns.
IF @DatabaseName LIKE @DatabaseNamePattern AND ISNULL(@OpsMainTableId, 0) <> 0
BEGIN
    BEGIN TRY
        SELECT ColumnName FROM SSDL.SPEND_SSDL_TableSchema where TableID = @OpsMainTableId and IsUsedInProject = 0

        -- SELECT ColumnName FROM SSDL.SPEND_SSDL_TableSchema where TableID = @OpsMainTableId and IsUsedInProject = 1 and (ColumnName like 'CUSTOM[_]FIELD%' AND DisplayColumnName like 'Custom Field (%')
    END TRY
    BEGIN CATCH
        SELECT
        @ErrorMessage = 'Failed - 5' + ERROR_MESSAGE(),   
        @ErrorSeverity = ERROR_SEVERITY(),   
        @ErrorState = ERROR_STATE();  

        -- return the error inside the CATCH block  
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
        RETURN;
    END CATCH
    PRINT 'Complete - 5';
END

-----------------------------------------------

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

-- 6. Correct data type.
IF @DatabaseName LIKE @DatabaseNamePattern AND ISNULL(@OpsMainTableId, 0) <> 0 AND EXISTS(SELECT TOP 1 1 FROM SSDL.MainTableColumnsMaster)
BEGIN
    BEGIN TRY
        SELECT A.ColumnName, C.DATA_TYP_NAME AS correctDataType, N.DATA_TYP_NAME AS IncorrectDataType, B.TableSchemaID, C.DATA_TYP_ID AS CorrectDataTypeID, N.DATA_TYP_ID AS IncorrectDataTypeId
        FROM SSDL.SPEND_SSDL_TableSchema B
        JOIN SSDL.MainTableColumnsMaster A ON A.ColumnName = B.ColumnName
        join ssdl.SPEND_DCC_TABLE_DATA_TYP_MST N on B.DataTypeID = N.DATA_TYP_ID
        join ssdl.SPEND_DCC_TABLE_DATA_TYP_MST C on A.DataTypeID = C.DATA_TYP_ID
        where C.DATA_TYP_NAME != N.DATA_TYP_NAME and B.TABLEId=@OpsMainTableId
        AND NOT(N.DATA_TYP_NAME = 'bit' AND C.DATA_TYP_NAME = 'boolean')
    END TRY
    BEGIN CATCH
        SELECT
        @ErrorMessage = 'Failed - 6' + ERROR_MESSAGE(),   
        @ErrorSeverity = ERROR_SEVERITY(),   
        @ErrorState = ERROR_STATE();  

        -- return the error inside the CATCH block  
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
        RETURN;
    END CATCH
    PRINT 'Complete - 6';
END

-----------------------------------------------

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

-- 7. Correct data length.
IF @DatabaseName LIKE @DatabaseNamePattern AND ISNULL(@OpsMainTableId, 0) <> 0 AND EXISTS(SELECT TOP 1 1 FROM SSDL.MainTableColumnsMaster)
BEGIN
    BEGIN TRY
        -- UPDATE B
        -- SET
        SELECT B.ColumnName, B.ColumnDataLength, A.ColumnDataLength, C.DATA_TYP_NAME
        from ssdl.SPEND_SSDL_TableSchema B
        join SSDL.SPEND_DCC_TABLE_DATA_TYP_MST C ON C.Data_TYP_ID = B.DataTypeID
        JOIN SSDL.MainTableColumnsMaster A on A.ColumnName = B.ColumnName AND B.TableId = @OpsMainTableId
        WHERE
            (B.ColumnDataLength IS NOT NULL AND B.ColumnDataLength <> 0 AND B.ColumnDataLength <> (CASE WHEN A.ColumnDataLength IS NULL
                THEN 0 ELSE A.ColumnDataLength END))
            OR
            (
                B.ColumnDataLength = 0 AND B.ColumnDataLength <> (CASE WHEN A.ColumnDataLength IS NULL
                THEN -1
                ELSE A.ColumnDataLength END)
            )
    END TRY
    BEGIN CATCH
        SELECT
        @ErrorMessage = 'Failed - 7' + ERROR_MESSAGE(),   
        @ErrorSeverity = ERROR_SEVERITY(),   
        @ErrorState = ERROR_STATE();  

        -- return the error inside the CATCH block  
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
        RETURN;
    END CATCH
    PRINT 'Complete - 7';
END

-----------------------------------------------

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

-- 8. Correct display name.
IF @DatabaseName LIKE @DatabaseNamePattern AND ISNULL(@OpsMainTableId, 0) <> 0 AND EXISTS(SELECT TOP 1 1 FROM SSDL.MainTableColumnsMaster)
BEGIN
    BEGIN TRY
        -- UPDATE B
        -- SET B.DisplayColumnName = A.DisplayColumnName
        SELECT B.ColumnName, B.DisplayColumnName, A.DisplayColumnName
        from ssdl.SPEND_SSDL_TableSchema B
        JOIN SSDL.MainTableColumnsMaster A on A.ColumnName = B.ColumnName
        AND B.FieldCategory <> 'ERP - Custom Fields' AND B.TableId = @OpsMainTableId
        WHERE B.DisplayColumnName <> A.DisplayColumnName
    END TRY
    BEGIN CATCH
        SELECT
        @ErrorMessage = 'Failed - 8' + ERROR_MESSAGE(),   
        @ErrorSeverity = ERROR_SEVERITY(),   
        @ErrorState = ERROR_STATE();  

        -- return the error inside the CATCH block  
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
        RETURN;
    END CATCH
    PRINT 'Complete - 8';
END