--check columns of OPS_MAIN against a data type
select 'Main', b.TableName, A.ColumnName, A.DisplayColumnName
from SSDL.SPEND_SSDL_TableSchema A
join SSDL.SPEND_SSDL_Table b on a.TableID = b.TableID AND b.TableName = 'OPS_MAIN'
join SSDL.SPEND_DCC_TABLE_DATA_TYP_MST d ON a.DataTypeID = d.DATA_TYP_ID AND DATA_TYP_NAME = 'Datetime' AND A.ColumnName like 'CUSTOM_FIELD%'