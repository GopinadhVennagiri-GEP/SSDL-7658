---1) Delete the inactive unused uncreated reserved custom columns
DECLARE @OpsMainTableId INT;
DECLARE @MainTableTypeId INT;
SELECT @MainTableTypeId = Table_TYP_ID FROM SSDL.SPEND_DCC_TABLE_TYP_MST where Table_TYP_code = 101
SELECT @OpsMainTableId = TableId FROM SSDL.SPEND_SSDL_TABLE WHERE TableTypeID = @MainTableTypeId AND TableName = 'OPS_MAIN';

select TableSchemaID, ColumnName, DisplayColumnName, FieldCategory, IsUsedInProject
from SSDL.SPEND_SSDL_TableSchema
where TableID = @OpsMainTableId and FieldCategory = 'ERP - Custom Fields' and DisplayColumnName like 'CUSTOM FIELD (%' AND IsUsedInProject = 0

DELETE from SSDL.SPEND_SSDL_TableSchema where TableID = @OpsMainTableId and FieldCategory = 'ERP - Custom Fields' and DisplayColumnName like 'CUSTOM FIELD (%' AND IsUsedInProject = 0

---2) 