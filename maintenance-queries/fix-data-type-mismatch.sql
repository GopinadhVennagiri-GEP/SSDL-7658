GEP_CLN_CLUSTER - int to bigint
'IMPORTEXPORTUID%' 10 columsn - int to bigint
PO_UNIT_PRICE_LOCAL -- string to float, make length 255 to 0

DECLARE @OpsMainTableId INT;
DECLARE @MainTableTypeId INT;
SELECT @MainTableTypeId = Table_TYP_ID FROM SSDL.SPEND_DCC_TABLE_TYP_MST where Table_TYP_code = 101
SELECT @OpsMainTableId = TableId FROM SSDL.SPEND_SSDL_TABLE WHERE TableTypeID = @MainTableTypeId AND TableName = 'OPS_MAIN';
SELECT ColumnName, DisplayColumnName FROM SSDL.SPEND_SSDL_TableSchema
where TableID = @OpsMainTableId

select * from SSDL.WorkflowEventSetting where SettingValue like '%PO_UNIT_PRICE_LOCAL%'
select * from SSDL.JOB_DETAILS WHERE SettingName = 'RangeBucket' and SettingValue like targetBucketDisplayName = '%PO_UNIT_PRICE_LOCAL%'
select * from SSDL.JOB_DETAILS WHERE SettingName = 'NewOldFlag' and SettingValue like targetDisplayName = '%PO_UNIT_PRICE_LOCAL%'
select * from SSDL.JOB_DETAILS WHERE SettingName = 'OnetimeFlag' and SettingValue like unUsedFieldDisplayName = '%PO_UNIT_PRICE_LOCAL%'
select * from SSDL.JOB_DETAILS WHERE SettingName = 'OneToMany' and SettingValue like fieldName = '%PO_UNIT_PRICE_LOCAL%'

Special settings to check:
1. Publish - 4 standard screens display only Nvarchar data type while creating custom columns
    So check if PO_UNIT_PRICE_LOCAL is being used in Publish - one time flag step.
2. Consolidation - moving to main - because it matches columns based on data types.
    so check if GEP_CLN_CLUSTER, IMPORTEXPORTUID, PO_UNIT_PRICE_LOCAL are being used.

select * from SSDL.JOB_DETAILS WHERE SettingName = 'RangeBucket'
select * from SSDL.JOB_DETAILS WHERE SettingName = 'NewOldFlag'
select * from SSDL.JOB_DETAILS WHERE SettingName = 'OnetimeFlag'
select * from SSDL.JOB_DETAILS WHERE SettingName = 'OneToMany'