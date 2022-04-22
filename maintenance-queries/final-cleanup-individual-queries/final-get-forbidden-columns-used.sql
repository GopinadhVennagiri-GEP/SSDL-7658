DECLARE @MainTableName VARCHAR(255);
DECLARE @OpsMainTableId INT;
DECLARE @MainTableTypeId INT;
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
OR (A.JOB_TYPE_NAME = 2 AND A.JOB_STATUS IN ('M', 'N') AND A.PARENT_JOB_ID IS NULL))
AND EXISTS(SELECT 1 FROM SSDL.SPEND_DL_SA_ACTIVITYWORKTRANSACTIONS B WHERE B.JOB_ID = A.JOB_ID)
AND ISNULL(A.IsDeleted, 0) = 0;

With CTE AS
(
    select B.TableSchemaID, B.DisplayColumnName, B.ColumnName
    from ssdl.SPEND_SSDL_TableSchema B
    WHERE B.TableId =@OpsMainTableId AND B.ColumnName IN ('UNIQUEID','MODIFIED_DATE','GEP_JOB_ID','GEP_JOB_NAME','GEP_RULE_ID','IS_EXCLUDE',
    'SOURCE_INDEX_ID','SOURCETABLE_NAME','AUDIT_COLUMN','DATALAKE_MIGRATION_DATE', 'GEP_DATAID', 'IMPORTEXPORTUID1','IMPORTEXPORTUID2','IMPORTEXPORTUID3','IMPORTEXPORTUID4','IMPORTEXPORTUID5','IMPORTEXPORTUID6',
    'IMPORTEXPORTUID7','IMPORTEXPORTUID8','IMPORTEXPORTUID9','IMPORTEXPORTUID10')
)
select distinct 'Consolidation' AS Activity, A.JobId,D.JobName, A.SettingName AS StepOrTaskName, B.DisplayColumnName, B.ColumnName--, A.SettingValue
from ssdl.WorkflowEventSetting AS A
INNER JOIN CTE B ON A.SettingValue like '%'+ B.ColumnName+'%' AND EventId IS NOT NULL
INNER JOIN @ConfiguredJobs D ON A.JobId = D.JobId
UNION
select distinct 'Profile to publish' AS Activity, A.JobId, D.JobName, A.SettingName AS StepOrTaskName, B.DisplayColumnName, B.ColumnName--, A.SettingValue
from ssdl.JOB_DETAILS AS A
INNER JOIN CTE B ON A.SettingValue like '%'+B.ColumnName+'%' AND A.SettingName NOT IN ('DataLakeMapping') AND A.JobID NOT IN (-1, 0)
INNER JOIN @ConfiguredJobs D ON A.JobId = D.JobId
UNION
SELECT DISTINCT 'Import Utility' AS Activity, A.ImportFileId AS JobId, '' AS JobName, '' AS StepOrTaskName, B.DisplayColumnName, B.ColumnName
FROM SSDL.ImportFileColumnMappingLink A
INNER JOIN CTE B ON A.TableSchemaId = B.TableSchemaID
UNION
SELECT DISTINCT 'Import Utility' AS Activity, A.ImportFileId AS JobId, '' AS JobName, '' AS StepOrTaskName, B.DisplayColumnName, B.ColumnName
FROM SSDL.ImportFileCriteria A
INNER JOIN CTE B ON A.AggregationTableSchemaId = B.TableSchemaID
UNION
SELECT DISTINCT 'Import Utility' AS Activity, C.ImportFileId AS JobId, '' AS JobName, '' AS StepOrTaskName, B.DisplayColumnName, B.ColumnName
FROM SSDL.ImportFileCriteriaConditions A
INNER JOIN CTE B ON A.DestinationColumnTableSchemaId = B.TableSchemaID
INNER JOIN SSDL.ImportFileCriteria C ON A.ImportFileCriteriaId = C.Id
UNION
SELECT DISTINCT 'Export Utility' AS Activity, A.TemplateId AS JobId, A.TemplateName AS JobName, '' AS StepOrTaskName, B.DisplayColumnName, B.ColumnName--, A.TemplateJSON
FROM SSDL.ExportTemplateMaster A
INNER JOIN CTE B ON JSON_VALUE(A.TemplateJSON, '$.tableName') = @MainTableName
    AND A.TemplateJSON LIKE '%' + B.ColumnName + '%'
UNION
select DISTINCT 'Clustering', NULL as JobId, '' AS JobName, (Case when ClusterType = 1 THEN 'Supplier Clustering' WHEN ClusterType = 2 THEN 'Classify Clustering' ELSE NULL END) as StepOrTaskName, B.DisplayColumnName, B.ColumnName--, A.ColumnNames
from SSDL.ClusterConfiguration A
INNER JOIN CTE B ON A.MainTableName = @MainTableName AND (A.ColumnNames LIKE '%' + B.ColumnName + '%' OR A.SpendColumn = B.ColumnName)
UNION
select DISTINCT 'Data lake mapping', NULL as JobId, '' AS JobName, '' AS StepOrTaskName, B.DisplayColumnName, B.ColumnName--, JSON_QUERY(value, '$.mainTableFields')
FROM OPENJSON((select JSON_QUERY(SettingValue, '$.mainTableDetails')
from SSDL.JOB_DETAILS A
where SettingName = 'DataLakeMapping' and JobId = -1))
INNER JOIN CTE B ON JSON_VALUE(value, '$.mainTableName') = 'OPS_MAIN' AND JSON_QUERY(value, '$.mainTableFields') LIKE '%' + B.ColumnName +'%'
