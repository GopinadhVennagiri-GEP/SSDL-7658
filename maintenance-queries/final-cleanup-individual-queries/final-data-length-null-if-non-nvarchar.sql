-- select * from SSDL.SPEND_DL_SA_ACIVITYWORKMASTER where JOB_NAME = 'E_2_E_2022 004'

DECLARE @OpsMainTableId INT;
DECLARE @MainTableTypeId INT;
SELECT @MainTableTypeId = Table_TYP_ID FROM SSDL.SPEND_DCC_TABLE_TYP_MST where Table_TYP_code = 101
SELECT @OpsMainTableId = TableId FROM SSDL.SPEND_SSDL_TABLE WHERE TableTypeID = @MainTableTypeId AND TableName = 'OPS_MAIN';

select A.ColumnName, B.DATA_TYP_NAME, A.ColumnDataLength
from SSDL.SPEND_SSDL_TableSchema A
JOIN SSDL.SPEND_DCC_TABLE_DATA_TYP_MST B ON A.DataTypeID = B.DATA_TYP_ID AND A.TAbleID = @OpsMainTableId
    AND B.Data_TYP_NAME NOT IN ('Nvarchar', 'varchar') AND ISNULL(A.ColumnDataLength, '') <> ''

-- UPDATE A
-- SET A.ColumnDataLength = NULL
-- from SSDL.SPEND_SSDL_TableSchema A
-- JOIN SSDL.SPEND_DCC_TABLE_DATA_TYP_MST B ON A.DataTypeID = B.DATA_TYP_ID AND A.TAbleID = @OpsMainTableId
--     AND B.Data_TYP_NAME NOT IN ('Nvarchar', 'varchar') AND ISNULL(A.ColumnDataLength, '') <> ''
