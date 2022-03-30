DECLARE @OpsMainTableId INT;
DECLARE @MainTableTypeId INT;
SELECT @MainTableTypeId = Table_TYP_ID FROM SSDL.SPEND_DCC_TABLE_TYP_MST where Table_TYP_code = 101
SELECT @OpsMainTableId = TableId FROM SSDL.SPEND_SSDL_TABLE WHERE TableTypeID = @MainTableTypeId AND TableName = 'OPS_MAIN';

SELECT ColumnName, DisplayColumnName, B.DATA_TYP_NAME, A.ColumnDataLength FROM SSDL.SPEND_SSDL_TableSchema A INNER JOIN SSDL.SPEND_DCC_TABLE_DATA_TYP_MST B ON A.DAtaTypeId = B.DATA_TYP_ID and A.ColumnName = 'PO_UNIT_PRICE_LOCAL' AND A.TableID = @OpsMainTableId
AND A.ColumnDataLength IS NOT NULL AND A.ColumnDataLength <> 0

IF EXISTS(SELECT ColumnName, DisplayColumnName, B.DATA_TYP_NAME, A.ColumnDataLength FROM SSDL.SPEND_SSDL_TableSchema A INNER JOIN SSDL.SPEND_DCC_TABLE_DATA_TYP_MST B ON A.DAtaTypeId = B.DATA_TYP_ID and A.ColumnName = 'PO_UNIT_PRICE_LOCAL' AND A.TableID = @OpsMainTableId
AND A.ColumnDataLength IS NOT NULL AND A.ColumnDataLength <> 0)
BEGIN
    UPDATE SSDL.SPEND_SSDL_TableSchema
    SET
        ColumnDataLength = NULL
    WHERE TableID = @OpsMainTableId AND ColumnName = 'PO_UNIT_PRICE_LOCAL'
END
