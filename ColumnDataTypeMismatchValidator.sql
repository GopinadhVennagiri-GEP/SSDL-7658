DECLARE @OpsMainTableId INT;
DECLARE @MainTableTypeId INT;
SELECT @MainTableTypeId = Table_TYP_ID FROM SSDL.SPEND_DCC_TABLE_TYP_MST where Table_TYP_code = 101
SELECT @OpsMainTableId = TableId FROM SSDL.SPEND_SSDL_TABLE WHERE TableTypeID = @MainTableTypeId AND TableName = 'OPS_MAIN';


WITH CTE AS (
select A.ColumnName,M.DATA_TYP_NAME AS correctDataType,N.DATA_TYP_NAME AS IncorrectDataType 
from ssdl.MainTableColumnsMaster  A 
join ssdl.SPEND_SSDL_TableSchema B on A.ColumnName = B.ColumnName 
join ssdl.SPEND_DCC_TABLE_DATA_TYP_MST M on A.DataTypeID=M.DATA_TYP_ID 
join ssdl.SPEND_DCC_TABLE_DATA_TYP_MST N on B.DataTypeID=N.DATA_TYP_ID 
where A.DataTypeID !=b.DataTypeID and B.TABLEId=@OpsMainTableId) 
select * from cte


select distinct JobId,WM.JOB_NAME,CTE.ColumnName,CTE.IncorrectDataType as ExistingDataType,CTE.correctDataType from ssdl.WorkflowEventSetting AS A  JOIN CTE ON A.SettingValue like '%'+CTE.ColumnName+'%' 
join SSDL.SPEND_DL_SA_ACIVITYWORKMASTER WM on A.JobId = WM.JOB_ID 
where Eventid IN (2221,2222) and WM.JOB_STATUS not IN('SM','C','D') and isnull(WM.IsDeleted,0) =0



-----------------

DECLARE @OpsMainTableId INT;
DECLARE @MainTableTypeId INT;
SELECT @MainTableTypeId = Table_TYP_ID FROM SSDL.SPEND_DCC_TABLE_TYP_MST where Table_TYP_code = 101
SELECT @OpsMainTableId = TableId FROM SSDL.SPEND_SSDL_TABLE WHERE TableTypeID = @MainTableTypeId AND TableName = 'OPS_MAIN';

WITH CTE AS (
select A.ColumnName,M.DATA_TYP_ID AS correctDataType,N.DATA_TYP_ID AS IncorrectDataType 
from ssdl.MainTableColumnsMaster  A 
join ssdl.SPEND_SSDL_TableSchema B on A.ColumnName = B.ColumnName 
join ssdl.SPEND_DCC_TABLE_DATA_TYP_MST M on A.DataTypeID=M.DATA_TYP_ID 
join ssdl.SPEND_DCC_TABLE_DATA_TYP_MST N on B.DataTypeID=N.DATA_TYP_ID 
where A.DataTypeID !=b.DataTypeID and B.TABLEId=@OpsMainTableId) 
update TS 
set TS.DataTypeId=CTE.correctDataType 
-- select CTE.ColumnName,TS.DataTypeId,CTE.correctDataType  
from ssdl.SPEND_SSDL_TableSchema TS  
join CTE on TS.ColumnName=CTE.ColumnName AND TS.TableID = @OpsMainTableId 
