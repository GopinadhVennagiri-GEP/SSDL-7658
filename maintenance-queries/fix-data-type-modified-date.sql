DECLARE @OpsMainTableId INT;
DECLARE @MainTableTypeId INT;
SELECT @MainTableTypeId = Table_TYP_ID FROM SSDL.SPEND_DCC_TABLE_TYP_MST where Table_TYP_code = 101
SELECT @OpsMainTableId = TableId FROM SSDL.SPEND_SSDL_TABLE WHERE TableTypeID = @MainTableTypeId AND TableName = 'OPS_MAIN';
SELECT ColumnName, DisplayColumnName, B.DATA_TYP_NAME FROM SSDL.SPEND_SSDL_TableSchema A INNER JOIN SSDL.SPEND_DCC_TABLE_DATA_TYP_MST B ON A.DAtaTypeId = B.DATA_TYP_ID and A.ColumnName = 'MODIFIED_DATE' AND A.TableID = @OpsMainTableId AND B.DATA_TYP_NAME = 'datetime'

SELECT ColumnName, DisplayColumnName, B.DATA_TYP_NAME FROM SSDL.SPEND_SSDL_TableSchema A INNER JOIN SSDL.SPEND_DCC_TABLE_DATA_TYP_MST B ON A.DAtaTypeId = B.DATA_TYP_ID and A.ColumnName = 'MODIFIED_DATE' AND A.TableID = @OpsMainTableId AND B.DATA_TYP_NAME <> 'datetime'

IF EXISTS(SELECT ColumnName, DisplayColumnName, B.DATA_TYP_NAME FROM SSDL.SPEND_SSDL_TableSchema A INNER JOIN SSDL.SPEND_DCC_TABLE_DATA_TYP_MST B ON A.DAtaTypeId = B.DATA_TYP_ID and A.ColumnName = 'MODIFIED_DATE' AND A.TableID = @OpsMainTableId AND B.DATA_TYP_NAME <> 'datetime')
BEGIN
    DECLARE @DatetimeDataTypeID INT = 0
    SELECT @DatetimeDataTypeID = DATA_TYP_ID from [SSDL].[SPEND_DCC_TABLE_DATA_TYP_MST] WHERE DATA_TYP_NAME = 'Datetime';
    UPDATE SSDL.SPEND_SSDL_TableSchema
    SET
        DataTypeId = @DatetimeDataTypeID
    WHERE TableID = @OpsMainTableId AND ColumnName = 'MODIFIED_DATE'
END
