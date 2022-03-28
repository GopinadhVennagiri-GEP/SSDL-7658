IF EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME ='MainTableColumnsMaster')
BEGIN
    DROP TABLE SSDL.MainTableColumnsMaster
END

CREATE TABLE SSDL.MainTableColumnsMaster
(
	Id BIGINT IDENTITY (1, 1) PRIMARY KEY,
	ColumnName varchar(255) UNIQUE NOT NULL,
	DisplayColumnName varchar(255),
	FieldCategory varchar(255),
	DataTypeID tinyint NOT NULL,
    ColumnDataLength varchar(50),
    IsInputField bit,
	IsPrimaryKey bit,
	ColumnVisibilityScopeEnumCode VARCHAR(255),
	IsSelectionMandatory BIT,
	FieldDefinition VARCHAR (255),
	IsBasicColumn bit,
    CreatedBy bigint NOT NULL,
	CreatedDate datetime NOT NULL,
	LastUpdatedBy bigint NOT NULL,
	LastUpdatedDate datetime NOT NULL
)
GO

CREATE OR ALTER PROCEDURE SSDL.MainTableColumns_GetByParams
(
	@TableName VARCHAR(255) = NULL,
	@AccessLevel VARCHAR(50) = 'ForUI'
)
AS
BEGIN
	DECLARE @MainTableTypeId INT;
	DECLARE @MainTableId INT;
	DECLARE @MainTableName VARCHAR(255);
	DECLARE @InternalAccessLevel VARCHAR(50);
	--AccessLevels are 1) ForProjectSetup 2) ForUI 3) ForProjectConfigJSON

	SET @InternalAccessLevel = @AccessLevel
	SELECT @MainTableTypeId = TABLE_TYP_ID from SSDL.SPEND_DCC_TABLE_TYP_MST WHERE TABLE_TYP_CODE = 101;

	SELECT
		@MainTableId = TableId,
		@MainTableName = TableName
	FROM SSDL.SPEND_SSDL_Table
	WHERE TableTypeID = @MainTableTypeId AND TableName = @TableName;

	IF ISNULL(@MainTableId, 0) = 0
	BEGIN
		SELECT
			@MainTableName AS TableName,
			@MainTableTypeId AS TableTypeId,
			NULL AS TableSchemaID,
			A.ColumnName,
			A.DisplayColumnName,
			A.FieldCategory,
			A.DataTypeID,
			C.DATA_TYP_NAME AS DataTypeName,
			A.ColumnVisibilityScopeEnumCode,
			A.IsSelectionMandatory,
            A.IsBasicColumn,
			cast(0 as BIT) as IsSelected,
			A.IsPrimaryKey,
			A.IsInputField,
			A.ColumnDataLength
		FROM SSDL.MainTableColumnsMaster A
		INNER JOIN SSDL.SPEND_DCC_TABLE_DATA_TYP_MST C ON C.DATA_TYP_ID = A.DataTypeID
		ORDER BY A.ColumnName
	END
	ELSE
	BEGIN
		WITH MasterTableColumns AS
		(
			SELECT
				A.ColumnName,
				A.DisplayColumnName,
				A.FieldCategory,
				C.DATA_TYP_ID AS DataTypeID,
				C.DATA_TYP_NAME AS DataTypeName
			FROM SSDL.MainTableColumnsMaster A
			INNER JOIN SSDL.SPEND_DCC_TABLE_DATA_TYP_MST C ON C.DATA_TYP_ID = A.DataTypeID
		),
		MainTableAndMasterTableColumnsCombined as 
		(
			SELECT * FROM MasterTableColumns WHERE @InternalAccessLevel = 'ForProjectSetup'
			UNION
			SELECT
				B.ColumnName,
				B.DisplayColumnName,
				B.FieldCategory,
				B.DataTypeID,
				D.DATA_TYP_NAME AS DataTypeName
			FROM SSDL.SPEND_SSDL_TableSchema B
			LEFT JOIN SSDL.SPEND_DCC_TABLE_DATA_TYP_MST D ON B.DataTypeID = D.DATA_TYP_ID
			WHERE B.TableID = @MainTableId
		)
		SELECT
			@TableName AS TableName,
			@MainTableTypeId AS TableTypeId,
			B.TableSchemaID,
			A.ColumnName,
			A.DisplayColumnName,
			A.FieldCategory,
			A.DataTypeID,
			A.DataTypeName,
			(CASE WHEN A.FieldCategory = 'ERP - Custom Fields' THEN 'ShowOnProjectSetupWorkflowUtilities' ELSE C.ColumnVisibilityScopeEnumCode END) AS ColumnVisibilityScopeEnumCode,
			C.IsSelectionMandatory,
			CAST((CASE WHEN A.FieldCategory = 'ERP - Custom Fields' THEN 0 ELSE C.IsBasicColumn END) AS BIT) AS IsBasicColumn,
			CAST((CASE WHEN B.TableSchemaID IS NULL THEN 0 ELSE 1 END) AS BIT) AS IsSelected,
			D.IsPrimaryKey,
			D.IsInputField,
			B.ColumnDataLength
		FROM MainTableAndMasterTableColumnsCombined A
		LEFT JOIN SSDL.SPEND_SSDL_TableSchema B ON A.ColumnName = B.ColumnName AND B.TableID = @MainTableId
		LEFT JOIN SSDL.MainTableColumnsMaster C ON A.ColumnName = C.ColumnName
		LEFT JOIN SSDL.MainTableColumnsMaster D ON B.ColumnName IS NOT NULL AND B.ColumnName = D.ColumnName
		WHERE
		(
			(@InternalAccessLevel = 'ForUI' AND B.ColumnName IS NOT NULL
				AND (
						(D.ColumnName IS NOT NULL AND D.ColumnVisibilityScopeEnumCode = 'ShowOnProjectSetupWorkflowUtilities')
						OR B.FieldCategory = 'ERP - Custom Fields'
				)
			)
			OR (@InternalAccessLevel = 'ForProjectSetup')
			OR (@InternalAccessLevel = 'ForProjectConfigJSON' AND B.ColumnName IS NOT NULL
				AND (
						(D.ColumnName IS NOT NULL)
						OR B.FieldCategory = 'ERP - Custom Fields'
				)
			)
		)
	END
END
GO

TRUNCATE TABLE SSDL.MainTableColumnsMaster

DECLARE @BigintDataTypeId INT = 0;
DECLARE @DatetimeDataTypeID INT = 0
DECLARE @BitDataTypeID INT = 0
DECLARE @NvarcharDataTypeID INT = 0
DECLARE @DateDataTypeID INT = 0;
DECLARE @FloatDataTypeID INT = 0;
DECLARE @intDataTypeID INT = 0;

SELECT @BigintDataTypeId = DATA_TYP_ID FROM SSDL.SPEND_DCC_TABLE_DATA_TYP_MST WHERE DATA_TYP_NAME = 'Bigint';
SELECT @DatetimeDataTypeID = DATA_TYP_ID from [SSDL].[SPEND_DCC_TABLE_DATA_TYP_MST]  WHERE DATA_TYP_NAME = 'Datetime';
SELECT @BitDataTypeID = DATA_TYP_ID  FROM [SSDL].[SPEND_DCC_TABLE_DATA_TYP_MST] WHERE DATA_TYP_NAME = 'Bit';
SELECT @NvarcharDataTypeID  = DATA_TYP_ID  FROM [SSDL].[SPEND_DCC_TABLE_DATA_TYP_MST] WHERE DATA_TYP_NAME = 'Nvarchar';
SELECT @DateDataTypeID = DATA_TYP_ID from [SSDL].[SPEND_DCC_TABLE_DATA_TYP_MST]  WHERE DATA_TYP_NAME = 'Date';
SELECT @FloatDataTypeID = DATA_TYP_ID from [SSDL].[SPEND_DCC_TABLE_DATA_TYP_MST]  WHERE DATA_TYP_NAME = 'Float';
SELECT @intDataTypeID = DATA_TYP_ID from [SSDL].[SPEND_DCC_TABLE_DATA_TYP_MST]  WHERE DATA_TYP_NAME = 'Int';

INSERT INTO SSDL.MainTableColumnsMaster(ColumnName,DisplayColumnName,FieldCategory,DataTypeID,ColumnDataLength,IsInputField,IsPrimaryKey,ColumnVisibilityScopeEnumCode,IsSelectionMandatory,FieldDefinition,IsBasicColumn,CreatedBy,CreatedDate,LastUpdatedBy,LastUpdatedDate) VALUES
 ('GEP_DATAID','GEP DATA ID','GEP - Admin - ID',@BigintDataTypeId,NULL,0,1,'ShowOnProjectSetupWorkflowUtilities',1,NULL,0,1,GETDATE(),1,GETDATE())
,('UNIQUEID','Unique ID','GEP - Admin - ID',@NvarcharDataTypeID,'1000',0,0,'HideEverywhere',1,'Source Table DataID + Source File Name + Source Record Entry Date',0,1,GETDATE(),1,GETDATE())
,('INVOICE_DOCUMENT_TYPE','Invoice Document Type','ERP - Invoice - Document',@NvarcharDataTypeID,'255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,'SAP Doc Type',0,1,GETDATE(),1,GETDATE())
,('INVOICE_POSTING_KEY','Invoice Posting Key','ERP - Invoice - Document',@NvarcharDataTypeID,'255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,'SAP Pos Key',0,1,GETDATE(),1,GETDATE())
,('INVOICE_DOCUMENT_NUMBER','Invoice Document Number','ERP - Invoice - Document',@NvarcharDataTypeID,'255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,'ERP Invoice Number',0,1,GETDATE(),1,GETDATE())
,('INVOICE_NUMBER','Invoice Number','ERP - Invoice - Document',@NvarcharDataTypeID,'255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,'Vendor Invoice Number',1,1,GETDATE(),1,GETDATE())
,('INVOICE_LINE_NUMBER','Invoice Line Number','ERP - Invoice - Document',@NvarcharDataTypeID,'255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,1,1,GETDATE(),1,GETDATE())
,('INVOICE_DISTRIBUTION_LINE_NUMBER','Invoice Line Distribution number','ERP - Invoice - Document',@NvarcharDataTypeID,'255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('INVOICE_NUMBER_2','Invoice Number 2','ERP - Invoice - Document',@NvarcharDataTypeID,'255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('INVOICE_NUMBER_3','Invoice Number 3','ERP - Invoice - Document',@NvarcharDataTypeID,'255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('INVOICE_VOUCHER_NUMBER','Invoice Voucher Number','ERP - Invoice - Document',@NvarcharDataTypeID,'255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,'Journal ID',0,1,GETDATE(),1,GETDATE())
,('INVOICE_VOUCHER_LINE_NUMBER','Invoice Voucher Line Number','ERP - Invoice - Document',@NvarcharDataTypeID,'255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('INVOICE_JOURNAL_NUMBER','Invoice Journal Number','ERP - Invoice - Document',@NvarcharDataTypeID,'255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('INVOICE_LINE_TYPE','Invoice Line Type','ERP - Invoice - Document',@NvarcharDataTypeID,'255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,'Tax, VAT,',0,1,GETDATE(),1,GETDATE())
,('INVOICE_PAYMENT_METHOD','Invoice Payment Method','ERP - Invoice - Document',@NvarcharDataTypeID,'255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,'WireTr, EFT,',0,1,GETDATE(),1,GETDATE())
,('INVOICE_CREATION_DATE','Invoice Creation Date','ERP - Invoice - Period',@DateDataTypeID,NULL,1,0,'ShowOnProjectSetupWorkflowUtilities',0,'By Supplier, Billed Dt',0,1,GETDATE(),1,GETDATE())
,('INVOICE_RECEIPT_DATE','Invoice Receipt Date','ERP - Invoice - Period',@DateDataTypeID,NULL,1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('INVOICE_PERIOD_ID','Invoice Period ID','ERP - Invoice - Period',@NvarcharDataTypeID,'255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('INVOICE_POSTING_DATE','Invoice Posted Date','ERP - Invoice - Period',@DateDataTypeID,NULL,1,0,'ShowOnProjectSetupWorkflowUtilities',0,'Entered in ERP',0,1,GETDATE(),1,GETDATE())
,('INVOICE_ACCOUNTING_DATE','Invoice Accounting Date','ERP - Invoice - Period',@DateDataTypeID,NULL,1,0,'ShowOnProjectSetupWorkflowUtilities',0,'GL Date',0,1,GETDATE(),1,GETDATE())
,('INVOICE_PAID_DATE','Invoice Paid Date','ERP - Invoice - Period',@DateDataTypeID,NULL,1,0,'ShowOnProjectSetupWorkflowUtilities',0,'Card Pymt Dt',1,1,GETDATE(),1,GETDATE())
,('INVOICE_LINE_AMOUNT_NORMALIZED','Invoice Line Amount Normalized','ERP - Invoice - Amount',@FloatDataTypeID,NULL,1,0,'ShowOnProjectSetupWorkflowUtilities',0,'USD or EUR',1,1,GETDATE(),1,GETDATE())
,('PO_UNIT_PRICE_LOCAL','PO Unit Price Local','ERP - PO',@FloatDataTypeID,NULL,1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('INVOICE_LINE_AMOUNT_CURRENCY','Invoice Line Amount Currency','ERP - Invoice - Amount',@NvarcharDataTypeID,'255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,'Currency',0,1,GETDATE(),1,GETDATE())
,('INVOICE_DEBIT_CREDIT_INDICATOR','Invoice Debit Credit Indicator','ERP - Invoice - Amount',@NvarcharDataTypeID,'255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('INVOICE_UNIT_PRICE_NORMALIZED','Invoice Unit Price Normalized','ERP - Invoice - Amount',@FloatDataTypeID,NULL,1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('INVOICE_LINE_AMOUNT_LOCAL','Invoice Line Amount Local','ERP - Invoice - Amount',@FloatDataTypeID,NULL,1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('INVOICE_UNIT_PRICE_CURRENCY','Invoice Unit Price Currency','ERP - Invoice - Amount',@NvarcharDataTypeID,'255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('INVOICE_QUANTITY','Invoice Quantity','ERP - Invoice - Amount',@FloatDataTypeID,NULL,1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('INVOICE_UOM','Invoice UOM','ERP - Invoice - Amount',@NvarcharDataTypeID,'255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('INVOICE_LINE_DESCRIPTION','Invoice Description','ERP - Invoice - Document',@NvarcharDataTypeID,'255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,1,1,GETDATE(),1,GETDATE())
,('INVOICE_LINE_DESCRIPTION_2','Invoice Description 2','ERP - Invoice - Document',@NvarcharDataTypeID,'255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('INVOICE_CREATED_BY','Invoice Created By','ERP - Invoice - Document',@NvarcharDataTypeID,'255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,'Keyer',0,1,GETDATE(),1,GETDATE())
,('INVOICE_APPROVED_BY','Invoice Approved By','ERP - Invoice - Document',@NvarcharDataTypeID,'255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,'Approver',0,1,GETDATE(),1,GETDATE())
,('INVOICE_LANGUAGE_KEY','Invoice Language','ERP - Invoice - Document',@NvarcharDataTypeID,'255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,'If in SAP',0,1,GETDATE(),1,GETDATE())
,('INVOICE_STATUS','Invoice Status','ERP - Invoice - Document',@NvarcharDataTypeID,'255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('INVOICE_TYPE','Invoice Type','ERP - Invoice - Document',@NvarcharDataTypeID,'255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,'Credit Memo, Void Payments',0,1,GETDATE(),1,GETDATE())
,('SHIPPING_CODE','Shipping Code','ERP - Miscellaneous',@NvarcharDataTypeID,'255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('SHIPPING_MODE_TYPE','Shipping Mode Type','ERP - Miscellaneous',@NvarcharDataTypeID,'255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,'Air, Ocean',0,1,GETDATE(),1,GETDATE())
,('SHIPPING_TYPE','Shipping Type','ERP - Miscellaneous',@NvarcharDataTypeID,'255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,'Inbound, Outbound',0,1,GETDATE(),1,GETDATE())
,('INVOICE_DIRECT_INDIRECT_INDICATOR','Direct Indirect Indicator','ERP - Miscellaneous',@NvarcharDataTypeID,'255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('CAPEX_OPEX_INDICATOR','Capex Opex Indicator','ERP - Miscellaneous',@NvarcharDataTypeID,'255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('DOMESTIC_INTERNALTIONAL_INDICATOR','Domestic International Indicator','ERP - Miscellaneous',@NvarcharDataTypeID,'255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('GEP_NORM_INVOICE_UNIT_PRICE_USD','GEP Normalized Invoice Unit Price (USD)','GEP - Amount',@FloatDataTypeID,NULL,0,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('GEP_NORM_INVOICE_UNIT_PRICE_EUR','GEP Normalized Invoice Unit Price (EUR)','GEP - Amount',@FloatDataTypeID,NULL,0,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('GEP_NORM_INVOICE_QUANTITY','GEP Normalized Invoice Quanity','GEP - Amount',@FloatDataTypeID,NULL,0,0,'ShowOnProjectSetupWorkflowUtilities',0,'Convert to Standard UOM',0,1,GETDATE(),1,GETDATE())
,('GEP_NORM_INVOICE_UOM','GEP Normalized Invoice UOM','GEP - Amount',@NvarcharDataTypeID,'255',0,0,'ShowOnProjectSetupWorkflowUtilities',0,'Convert to Standard UOM',0,1,GETDATE(),1,GETDATE())
,('EXCH_MONTH','GEP Currecy Exchange Month','GEP - Amount',@NvarcharDataTypeID,'255',0,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('EXCH_YEAR','GEP Currecy Exchange Year','GEP - Amount',@NvarcharDataTypeID,'255',0,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('EXCH_RATE','GEP Currecy Exchange Rate','GEP - Amount',@FloatDataTypeID,NULL,0,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('GEP_NORM_SPEND_USD','GEP Normalized Spend (USD)','GEP - Amount',@FloatDataTypeID,NULL,0,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,1,1,GETDATE(),1,GETDATE())
,('GEP_NORM_SPEND_USD_WITHOUT_TAX','GEP Normalized Spend (USD) Without Tax','GEP - Amount',@FloatDataTypeID,NULL,0,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('GEP_NORM_SPEND_EUR','GEP Normalized Spend (EUR)','GEP - Amount',@FloatDataTypeID,NULL,0,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('GEP_NORM_SPEND_EUR_WITHOUT_TAX','GEP Normalized Spend (EUR) Without Tax','GEP - Amount',@FloatDataTypeID,NULL,0,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('GEP_NORM_SPEND_GBP','GEP Normalized Spend (GBP)','GEP - Amount',@FloatDataTypeID,NULL,0,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('GEP_NORM_SPEND_AUD','GEP Normalized Spend (AUD)','GEP - Amount',@FloatDataTypeID,NULL,0,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('GEP_NORM_SPEND_CAD','GEP Normalized Spend (CAD)','GEP - Amount',@FloatDataTypeID,NULL,0,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('GEP_NORM_SPEND_CNY','GEP Normalized Spend (CNY)','GEP - Amount',@FloatDataTypeID,NULL,0,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('GEP_NORM_SPEND_JPY','GEP Normalized Spend (JPY)','GEP - Amount',@FloatDataTypeID,NULL,0,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('GEP_NORM_SPEND_CHF','GEP Normalized Spend (CHF)','GEP - Amount',@FloatDataTypeID,NULL,0,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('GEP_NORM_SPEND_MXN','GEP Normalized Spend (MXN)','GEP - Amount',@FloatDataTypeID,NULL,0,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('GEP_NORM_SPEND_NOK','GEP Normalized Spend (NOK)','GEP - Amount',@FloatDataTypeID,NULL,0,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('GEP_NORMALIZED_PO_UNIT_PRICE_USD','GEP Normalized PO Unit Price (USD)','GEP - Amount',@FloatDataTypeID,NULL,0,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('GEP_NORMALIZED_PO_UNIT_PRICE_EUR','GEP Normalized PO Unit Price (EUR)','GEP - Amount',@FloatDataTypeID,NULL,0,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('GEP_NORM_DATE','GEP Normalized Date','GEP - Period',@DateDataTypeID,NULL,0,0,'ShowOnProjectSetupWorkflowUtilities',1,NULL,0,1,GETDATE(),1,GETDATE())
,('CREATED_DATE','Record Entry Date','GEP - Admin - ID',@DatetimeDataTypeID,NULL,0,0,'ShowOnProjectSetupWorkflowUtilities',1,NULL,0,1,GETDATE(),1,GETDATE())
,('MODIFIED_DATE','Record Modifed Date','GEP - Admin - ID',@DatetimeDataTypeID,NULL,0,0,'HideEverywhere',1,NULL,0,1,GETDATE(),1,GETDATE())
,('GEP_SUPP_CLUSTER','GEP Vendor Normalization Cluster ID','GEP - Admin - Maintenance',@intDataTypeID,NULL,0,0,'ShowOnProjectSetupWorkflowUtilities',1,NULL,0,1,GETDATE(),1,GETDATE())
,('GEP_CLN_CLUSTER','GEP Classification Cluster ID','GEP - Admin - Maintenance',@BigintDataTypeId,NULL,0,0,'ShowOnProjectSetupWorkflowUtilities',1,NULL,0,1,GETDATE(),1,GETDATE())
,('GEP_BU_CLUSTER','GEP BU Cluster ID','GEP - Admin - Maintenance',@intDataTypeID,NULL,0,0,'ShowOnProjectSetupWorkflowUtilities',1,NULL,0,1,GETDATE(),1,GETDATE())
,('GEP_EXCLUDE','GEP Exclude','GEP - Admin - Maintenance',@BitDataTypeID,NULL,0,0,'ShowOnProjectSetupWorkflowUtilities',1,NULL,0,1,GETDATE(),1,GETDATE())
,('GEP_EXCLUSION_COMMENTS','GEP Exclusion Comments','GEP - Admin - Maintenance',@NvarcharDataTypeID,'500',0,0,'ShowOnProjectSetupWorkflowUtilities',1,NULL,0,1,GETDATE(),1,GETDATE())
,('GEP_EXCLUSION_CRITERIA','GEP Exclusion Criteria','GEP - Admin - Maintenance',@NvarcharDataTypeID,'255',0,0,'ShowOnProjectSetupWorkflowUtilities',1,'OOR date, Intercompany',0,1,GETDATE(),1,GETDATE())
,('GEP_TRANSLATED_SUPP_NAME','GEP Translated Supplier Name','GEP - Admin - Maintenance',@NvarcharDataTypeID,'255',0,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('GEP_TRANSLATED_INVOICE_LINE_DESCRIPTION','GEP Translated Invoice Description','GEP - Admin - Maintenance',@NvarcharDataTypeID,'255',0,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('GEP_TRANSLATED_PO_DESCRIPTION','GEP Translated PO Description','GEP - Admin - Maintenance',@NvarcharDataTypeID,'255',0,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('GEP_TRANSLATED_MATERIAL_DESCRIPTION','GEP Translated Material Description','GEP - Admin - Maintenance',@NvarcharDataTypeID,'255',0,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('GEP_TRANSLATED_DESCRIPTION_2','GEP Translated Description 2','GEP - Admin - Maintenance',@NvarcharDataTypeID,'255',0,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('GEP_ACTUAL_PAYMENT_TERM_DAYS','GEP Actual Payment Term Days','GEP - Payment Term',@FloatDataTypeID,NULL,0,0,'ShowOnProjectSetupWorkflowUtilities',0,'Paid Date - Posted Date',0,1,GETDATE(),1,GETDATE())
,('GEP_PO_AVG_UNIT_PRICE','GEP PO Average Unit Price','GEP - Miscellaneous',@FloatDataTypeID,NULL,0,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('GEP_ONE_TIME_SUPP_FLAG','GEP One Time Vendor Flag','GEP - Miscellaneous',@NvarcharDataTypeID,'255',0,0,'ShowOnProjectSetupWorkflowUtilities',1,NULL,0,1,GETDATE(),1,GETDATE())
,('GEP_ONE_ITEM_MULTI_SUPP_FLAG','GEP One Item Multiple Supplier Flag','GEP - Miscellaneous',@NvarcharDataTypeID,'255',0,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('GEP_ONE_SUPP_MULTI_BU_FLAG','GEP One Supplier Multiple BU Flag','GEP - Miscellaneous',@NvarcharDataTypeID,'255',0,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('GEP_ONE_SUPP_MULTI_PAYTERM_FLAG','GEP One Supplier Multiple Payment Term Flag','GEP - Miscellaneous',@NvarcharDataTypeID,'255',0,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('GEP_SUPP_SPEND_TOP_BUCKET','GEP Supplier Spend Top Bucket','GEP - Miscellaneous',@NvarcharDataTypeID,'255',0,0,'ShowOnProjectSetupWorkflowUtilities',1,'Top 80, 80-95',0,1,GETDATE(),1,GETDATE())
,('GEP_SUPP_SPEND_BUCKET','GEP Supplier Spend Bucket','GEP - Miscellaneous',@NvarcharDataTypeID,'255',0,0,'ShowOnProjectSetupWorkflowUtilities',1,'>1M, 500K-1M,�',0,1,GETDATE(),1,GETDATE())
,('GEP_INV_SPEND_BUCKET','GEP Invoice Spend Bucket','GEP - Miscellaneous',@NvarcharDataTypeID,'255',0,0,'ShowOnProjectSetupWorkflowUtilities',0,'Top 80, 80-95',0,1,GETDATE(),1,GETDATE())
,('GEP_PO_SPEND_BUCKET','GEP PO Spend Bucket','GEP - Miscellaneous',@NvarcharDataTypeID,'255',0,0,'ShowOnProjectSetupWorkflowUtilities',0,'Top 80, 80-95',0,1,GETDATE(),1,GETDATE())
,('GEP_PAYTERM_BUCKET','GEP Invoice Payment Term Days Bucket','GEP - Payment Term',@NvarcharDataTypeID,'255',0,0,'ShowOnProjectSetupWorkflowUtilities',0,'0-10, 10-30, 30-60',0,1,GETDATE(),1,GETDATE())
,('GEP_TRANS_BUCKET','GEP Transaction Spend Bucket','GEP - Miscellaneous',@NvarcharDataTypeID,'255',0,0,'ShowOnProjectSetupWorkflowUtilities',1,'Top 80, 80-95',0,1,GETDATE(),1,GETDATE())
,('GEP_PRIORITY','GEP CF Priority Bucket','GEP - Admin - Maintenance',@NvarcharDataTypeID,'255',0,0,'ShowOnProjectSetupWorkflowUtilities',1,'CF priority bucket',0,1,GETDATE(),1,GETDATE())
,('GEP_QA_FLAG_VNE','GEP VNE QA Flag','GEP - Admin - Maintenance',@NvarcharDataTypeID,'255',0,0,'ShowOnProjectSetupWorkflowUtilities',0,'QA Completed, QA Pending',0,1,GETDATE(),1,GETDATE())
,('GEP_QA_FLAG_CF','GEP CF QA Flag','GEP - Admin - Maintenance',@NvarcharDataTypeID,'255',0,0,'ShowOnProjectSetupWorkflowUtilities',1,'QA Completed, QA Pending',0,1,GETDATE(),1,GETDATE())
,('GEP_QA_FLAG_OTH','GEP QA Flag Other','GEP - Admin - Maintenance',@NvarcharDataTypeID,'255',0,0,'ShowOnProjectSetupWorkflowUtilities',0,'QA for other than CF and VNE, like BU',0,1,GETDATE(),1,GETDATE())
,('GEP_SLA_FLAG_VNE','GEP VNE SLA Flag','GEP - Admin - Maintenance',@NvarcharDataTypeID,'255',0,0,'ShowOnProjectSetupWorkflowUtilities',0,'SLA sampling pass, SLA sampling fail, Not part of SLA sample',0,1,GETDATE(),1,GETDATE())
,('GEP_SLA_FLAG_CF','GEP CF SLA Flag','GEP - Admin - Maintenance',@NvarcharDataTypeID,'255',0,0,'ShowOnProjectSetupWorkflowUtilities',0,'SLA sampling pass, SLA sampling fail, Not part of SLA sample',0,1,GETDATE(),1,GETDATE())
,('GEP_AI_SOURCE_CF','GEP Classification Source','GEP - Admin - Maintenance',@NvarcharDataTypeID,'255',0,0,'ShowOnProjectSetupWorkflowUtilities',1,'RULE - CLIENT, RULE - GEP, AI- DATA LAKE, AI - PROJECT',0,1,GETDATE(),1,GETDATE())
,('GEP_AI_ALGO_VNE','GEP VNE AI Algorithm','GEP - Admin - Maintenance',@NvarcharDataTypeID,'255',0,0,'ShowOnProjectSetupWorkflowUtilities',0,'ML1, ML2, etc.',0,1,GETDATE(),1,GETDATE())
,('GEP_AI_ALGO_CF','GEP CF AI Algorithm','GEP - Admin - Maintenance',@NvarcharDataTypeID,'255',0,0,'ShowOnProjectSetupWorkflowUtilities',0,'ML1, ML2, etc.',0,1,GETDATE(),1,GETDATE())
,('GEP_FEEDBACK_FLAG','GEP CF Feedback Flag','GEP - Admin - Maintenance',@NvarcharDataTypeID,'255',0,0,'ShowOnProjectSetupWorkflowUtilities',0,'If Part of CF Feedbacks',0,1,GETDATE(),1,GETDATE())
,('GEP_VNE_FEEDBACK_FLAG','GEP VNE Feedback Flag','GEP - Admin - Maintenance',@NvarcharDataTypeID,'255',0,0,'ShowOnProjectSetupWorkflowUtilities',0,'If Part of VNE Feedbacks',0,1,GETDATE(),1,GETDATE())
,('GEP_VNE_SOURCE','GEP Supplier Normalization Method L1','GEP - Admin - Maintenance',@NvarcharDataTypeID,'255',0,0,'ShowOnProjectSetupWorkflowUtilities',1,'Manual, QA, AI, Rules, Historical',0,1,GETDATE(),1,GETDATE())
,('GEP_VNE_SOURCE_2','GEP Supplier Normalization Method L2','GEP - Admin - Maintenance',@NvarcharDataTypeID,'255',0,0,'ShowOnProjectSetupWorkflowUtilities',1,'RULE - NEW, RULE - OLD, AI- HIGH , AI - MEDIUM, AI - LOW',0,1,GETDATE(),1,GETDATE())
,('GEP_VNE_HISTORICAL_FLAG','GEP Supplier Normalization Historical Flag','GEP - Admin - Maintenance',@NvarcharDataTypeID,'255',0,0,'ShowOnProjectSetupWorkflowUtilities',1,'HISTORICAL, NOT HISTORICAL',0,1,GETDATE(),1,GETDATE())
,('GEP_UP_STATUS_FLAG','GEP Parent Linkage Status Flag','GEP - Admin - Maintenance',@NvarcharDataTypeID,'255',0,0,'ShowOnProjectSetupWorkflowUtilities',1,'COMPLETED, TO REVIEW, TO PROCESS',0,1,GETDATE(),1,GETDATE())
,('GEP_UP_SOURCE','GEP Parent Linkage Method L1','GEP - Admin - Maintenance',@NvarcharDataTypeID,'255',0,0,'ShowOnProjectSetupWorkflowUtilities',1,'Rules, AI, Manual',0,1,GETDATE(),1,GETDATE())
,('GEP_UP_SOURCE_2','GEP Parent Linkage Method L2','GEP - Admin - Maintenance',@NvarcharDataTypeID,'255',0,0,'ShowOnProjectSetupWorkflowUtilities',1,'RULE - NEW, RULE - OLD, AI- HIGH , AI - MEDIUM, AI - LOW',0,1,GETDATE(),1,GETDATE())
,('GEP_UP_HISTORICAL_FLAG','GEP Parent Linkage Historical Flag','GEP - Admin - Maintenance',@NvarcharDataTypeID,'255',0,0,'ShowOnProjectSetupWorkflowUtilities',1,'HISTORICAL, NOT HISTORICAL',0,1,GETDATE(),1,GETDATE())
,('GEP_CF_SOURCE','GEP Classification Method L1','GEP - Admin - Maintenance',@NvarcharDataTypeID,'255',0,0,'ShowOnProjectSetupWorkflowUtilities',1,'Rules, AI, Manual',0,1,GETDATE(),1,GETDATE())
,('GEP_CF_SOURCE_2','GEP Classification Method L2','GEP - Admin - Maintenance',@NvarcharDataTypeID,'255',0,0,'ShowOnProjectSetupWorkflowUtilities',1,'RULE - NEW, RULE - OLD, AI- HIGH , AI - MEDIUM, AI - LOW',0,1,GETDATE(),1,GETDATE())
,('GEP_CF_HISTORICAL_FLAG','GEP Classification Historical Flag','GEP - Admin - Maintenance',@NvarcharDataTypeID,'255',0,0,'ShowOnProjectSetupWorkflowUtilities',1,'HISTORICAL, NOT HISTORICAL',0,1,GETDATE(),1,GETDATE())
,('GEP_JOB_ID','GEP Job ID','GEP - Admin - Maintenance',@BigintDataTypeId,NULL,0,0,'HideEverywhere',1,'ID of the Job',0,1,GETDATE(),1,GETDATE())
,('GEP_JOB_NAME','GEP Job Name','GEP - Admin - Maintenance',@NvarcharDataTypeID,'255',0,0,'HideEverywhere',1,'Name of the Job in the UI',0,1,GETDATE(),1,GETDATE())
,('GEP_COMMENTS','GEP Comments','GEP - Miscellaneous',@NvarcharDataTypeID,'255',0,0,'ShowOnProjectSetupWorkflowUtilities',1,NULL,0,1,GETDATE(),1,GETDATE())
,('GEP_DUPLICATE_KEY_FLAG','GEP Duplicate (Key) Flag','GEP - Admin - Maintenance',@NvarcharDataTypeID,'255',0,0,'ShowOnProjectSetupWorkflowUtilities',1,NULL,0,1,GETDATE(),1,GETDATE())
,('GEP_DUPLICATE_KEY_ID','GEP Duplicate (key) ID','GEP - Admin - Maintenance',@NvarcharDataTypeID,'255',0,0,'ShowOnProjectSetupWorkflowUtilities',1,NULL,0,1,GETDATE(),1,GETDATE())
,('GEP_DUPLICATE_ALL_FLAG','GEP Duplicate (All) Flag','GEP - Admin - Maintenance',@NvarcharDataTypeID,'255',0,0,'ShowOnProjectSetupWorkflowUtilities',1,NULL,0,1,GETDATE(),1,GETDATE())
,('GEP_DUPLICATE_ALL_ID','GEP Duplicate (All) ID','GEP - Admin - Maintenance',@NvarcharDataTypeID,'255',0,0,'ShowOnProjectSetupWorkflowUtilities',1,NULL,0,1,GETDATE(),1,GETDATE())
,('GEP_RULE_ID','GEP Rule ID (Classification)','GEP - Admin - Maintenance',@intDataTypeID,NULL,0,0,'HideEverywhere',1,NULL,0,1,GETDATE(),1,GETDATE())
,('GEP_RULE_ID_VNE','GEP Rule ID (Vendor Normalization)','GEP - Admin - Maintenance',@NvarcharDataTypeID,'255',0,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('GEP_RULE_ID_OTHER','GEP Rule ID (Other)','GEP - Admin - Maintenance',@intDataTypeID,NULL,0,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('RULE_PROVIDER','GEP Rule Provider (Classification)','GEP - Admin - Maintenance',@NvarcharDataTypeID,'255',0,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('RULE_SOURCE','GEP Rule Source (Classification)','GEP - Admin - Maintenance',@NvarcharDataTypeID,'255',0,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('RULE_TYPE_NAME','GEP Rule Type','GEP - Admin - Maintenance',@NvarcharDataTypeID,'255',0,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('GEP_CF_STATUS_FLAG','GEP Classification Status Flag','GEP - Admin - Maintenance',@NvarcharDataTypeID,'255',0,0,'ShowOnProjectSetupWorkflowUtilities',1,'COMPLETED, TO REVIEW, TO PROCESS',0,1,GETDATE(),1,GETDATE())
,('GEP_VNE_STATUS_FLAG','GEP Supplier Normalization Status Flag','GEP - Admin - Maintenance',@NvarcharDataTypeID,'255',0,0,'ShowOnProjectSetupWorkflowUtilities',1,'All Steps Completed. VNE Delivery Status - COMPLETED, TO REVIEW, TO PROCESS',0,1,GETDATE(),1,GETDATE())
,('GEP_CONFIDENCE_FLAG','GEP Confidence Flag','GEP - Admin - Maintenance',@NvarcharDataTypeID,'255',0,0,'ShowOnProjectSetupWorkflowUtilities',0,'Both CF and VNE Completed Status',0,1,GETDATE(),1,GETDATE())
,('GEP_DELIVERY_STATUS','GEP Delivery Status Flag','GEP - Admin - Maintenance',@NvarcharDataTypeID,'255',0,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('GEP_CF_USER','GEP CF User','GEP - Admin - Maintenance',@NvarcharDataTypeID,'255',0,0,'ShowOnProjectSetupWorkflowUtilities',1,'User who processed Manual or CF QA',0,1,GETDATE(),1,GETDATE())
,('GEP_VNE_USER','GEP VNE User','GEP - Admin - Maintenance',@NvarcharDataTypeID,'255',0,0,'ShowOnProjectSetupWorkflowUtilities',0,'User who processed Manual or VNE QA',0,1,GETDATE(),1,GETDATE())
,('GEP_AI_DL_CATEGORY_L1','GEP AI DL Category L1','GEP - Admin - Data Lake',@NvarcharDataTypeID,'255',0,0,'ShowOnProjectSetupWorkflowUtilities',1,'Cold Start Run 1',0,1,GETDATE(),1,GETDATE())
,('GEP_AI_DL_CATEGORY_L2','GEP AI DL Category L2','GEP - Admin - Data Lake',@NvarcharDataTypeID,'255',0,0,'ShowOnProjectSetupWorkflowUtilities',1,'Cold Start Run 1',0,1,GETDATE(),1,GETDATE())
,('GEP_AI_DL_CATEGORY_L3','GEP AI DL Category L3','GEP - Admin - Data Lake',@NvarcharDataTypeID,'255',0,0,'ShowOnProjectSetupWorkflowUtilities',1,'Cold Start Run 1',0,1,GETDATE(),1,GETDATE())
,('GEP_AI_DL_CATEGORY_L4','GEP AI DL Category L4','GEP - Admin - Data Lake',@NvarcharDataTypeID,'255',0,0,'ShowOnProjectSetupWorkflowUtilities',1,'Cold Start Run 1',0,1,GETDATE(),1,GETDATE())
,('GEP_AI_DL_SUPPLIER_SIC_NAICS','GEP AI DL Supplier SIC NAICS','GEP - Admin - Data Lake',@NvarcharDataTypeID,'255',0,0,'ShowOnProjectSetupWorkflowUtilities',0,'Cold Start Future Plan',0,1,GETDATE(),1,GETDATE())
,('GEP_MANAGED_CATEGORY_FLAG','GEP Managed Category','GEP - Miscellaneous',@NvarcharDataTypeID,'255',0,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('GEP_SOURCING_SCOPE_FLAG','GEP Sourcing Scope','GEP - Miscellaneous',@NvarcharDataTypeID,'255',0,0,'ShowOnProjectSetupWorkflowUtilities',0,'Global, Nationalized, Local',0,1,GETDATE(),1,GETDATE())
,('GEP_SOLE_SOURCING_FLAG','GEP Sole Sourcing','GEP - Miscellaneous',@NvarcharDataTypeID,'255',0,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('GEP_BUYING_CHANNEL','GEP Buying Channel','GEP - Miscellaneous',@NvarcharDataTypeID,'255',0,0,'ShowOnProjectSetupWorkflowUtilities',0,'Catalog, Card, PO Spot, PO Release',1,1,GETDATE(),1,GETDATE())
,('GEP_PAYMENT_CHANNEL','GEP Payment Channel','GEP - Miscellaneous',@NvarcharDataTypeID,'255',0,0,'ShowOnProjectSetupWorkflowUtilities',0,'Card, Wire Transfer, etc',0,1,GETDATE(),1,GETDATE())
,('GEP_SOURCING_REGION','GEP Sourcing Region','GEP - Miscellaneous',@NvarcharDataTypeID,'255',0,0,'ShowOnProjectSetupWorkflowUtilities',0,'Domestic, LCCS, HCCS',0,1,GETDATE(),1,GETDATE())
,('GEP_PO_NON_PO_FLAG','GEP PO Flag','GEP - Miscellaneous',@NvarcharDataTypeID,'255',0,0,'ShowOnProjectSetupWorkflowUtilities',0,'Off PO, On PO',1,1,GETDATE(),1,GETDATE())
,('GEP_CONTRACT_FLAG','GEP Contract Flag','GEP - Miscellaneous',@NvarcharDataTypeID,'255',0,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('GEP_CONFIDENTIAL_FLAG','GEP Confidential Flag','GEP - Miscellaneous',@NvarcharDataTypeID,'255',0,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('GEP_INTERCOMPANY_FLAG','GEP Intercompany Flag','GEP - Miscellaneous',@NvarcharDataTypeID,'255',0,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('GEP_DISCONTINUED_FLAG','GEP Discontinued Flag','GEP - Miscellaneous',@NvarcharDataTypeID,'255',0,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('GEP_CATEGORY_MANAGER_GLOBAL','GEP Category Manager Global','GEP - Miscellaneous',@NvarcharDataTypeID,'255',0,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('GEP_CATEGORY_MANAGER_REGION','GEP Category Manager Region','GEP - Miscellaneous',@NvarcharDataTypeID,'255',0,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('INVOICE_UNIT_PRICE_IN_LOCAL_CURRENCY','Invoice Unit Price Local','ERP - Invoice - Amount',@FloatDataTypeID,NULL,1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('BUSINESS_DIVISION','Business Division','ERP - Invoice - BU',@NvarcharDataTypeID,'255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,'Division',0,1,GETDATE(),1,GETDATE())
,('DEPARTMENT_CODE','Department Code','ERP - Invoice - BU',@NvarcharDataTypeID,'255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,'Department',0,1,GETDATE(),1,GETDATE())
,('DEPARTMENT_DESCRIPTION','Department Description','ERP - Invoice - BU',@NvarcharDataTypeID,'255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,'Department',0,1,GETDATE(),1,GETDATE())
,('BUSINESS_UNIT_CODE','Business Unit Code','ERP - Invoice - BU',@NvarcharDataTypeID,'255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,'Division',1,1,GETDATE(),1,GETDATE())
,('BUSINESS_UNIT_DESC','Business Unit','ERP - Invoice - BU',@NvarcharDataTypeID,'255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,'Org Unit, Operating Unit',1,1,GETDATE(),1,GETDATE())
,('BUSINESS_GROUP_DESC','BU Group','ERP - Invoice - BU',@NvarcharDataTypeID,'255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,'BU Hierarchy 1',1,1,GETDATE(),1,GETDATE())
,('BUSINESS_GROUP_DESC_2','BU Group 2','ERP - Invoice - BU',@NvarcharDataTypeID,'255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,'BU Hierarchy 2',0,1,GETDATE(),1,GETDATE())
,('BUSINESS_GROUP_DESC_3','BU Group 3','ERP - Invoice - BU',@NvarcharDataTypeID,'255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,'BU Hierarchy 3',0,1,GETDATE(),1,GETDATE())
,('BUSINESS_GROUP_DESC_4','BU Group 4','ERP - Invoice - BU',@NvarcharDataTypeID,'255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,'BU Hierarchy 4',0,1,GETDATE(),1,GETDATE())
,('BUSINESS_GROUP_DESC_5','BU Group 5','ERP - Invoice - BU',@NvarcharDataTypeID,'255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,'BU Hierarchy 5',0,1,GETDATE(),1,GETDATE())
,('BUSINESS_GROUP_DESC_6','BU Group 6','ERP - Invoice - BU',@NvarcharDataTypeID,'255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,'BU Hierarchy 6',0,1,GETDATE(),1,GETDATE())
,('GEP_NORM_BUSINESS_UNIT','GEP Normalized Business Unit','GEP - BU',@NvarcharDataTypeID,'255',0,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('GEP_NORM_BU_LEVEL1','GEP Normalized Business Group Level 1','GEP - BU',@NvarcharDataTypeID,'255',0,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('GEP_NORM_BU_LEVEL2','GEP Normalized Business Group Level 2','GEP - BU',@NvarcharDataTypeID,'255',0,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('GEP_NORM_BU_LEVEL3','GEP Normalized Business Group Level 3','GEP - BU',@NvarcharDataTypeID,'255',0,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('GEP_NORM_BU_LEVEL4','GEP Normalized Business Group Level 4','GEP - BU',@NvarcharDataTypeID,'255',0,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('COMPANY_CODE','Company Code','ERP - Invoice - BU',@NvarcharDataTypeID,'255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,1,1,GETDATE(),1,GETDATE())
,('COMPANY_NAME','Company Name','ERP - Invoice - BU',@NvarcharDataTypeID,'255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,1,1,GETDATE(),1,GETDATE())
,('COMPANY_COUNTRY','Company Country','ERP - Invoice - BU',@NvarcharDataTypeID,'255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,1,1,GETDATE(),1,GETDATE())
,('COMPANY_REGION','Company Region','ERP - Invoice - BU',@NvarcharDataTypeID,'255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('GEP_NORM_COMPANY','GEP Normalized Company','GEP - BU',@NvarcharDataTypeID,'255',0,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('GEP_NORM_COMPANY_COUNTRY','GEP Business Country','GEP - BU Geography',@NvarcharDataTypeID,'255',0,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('GEP_NORM_COMPANY_SUB_REGION','GEP Business Sub Region','GEP - BU Geography',@NvarcharDataTypeID,'255',0,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('GEP_NORM_COMPANY_REGION','GEP Business Region','GEP - BU Geography',@NvarcharDataTypeID,'255',0,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('PLANT_TYPE','Facility Type','ERP - Invoice - BU',@NvarcharDataTypeID,'255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,'Office, Plant, Store',0,1,GETDATE(),1,GETDATE())
,('PLANT_CODE','Facility Code','ERP - Invoice - BU',@NvarcharDataTypeID,'255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,'Plant Code, Ship to Plant',1,1,GETDATE(),1,GETDATE())
,('PLANT_NAME','Facility Name','ERP - Invoice - BU',@NvarcharDataTypeID,'255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,'Plant Name',1,1,GETDATE(),1,GETDATE())
,('PLANT_ADDRESS','Facility Address','ERP - Invoice - BU',@NvarcharDataTypeID,'255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,'Plant Address',0,1,GETDATE(),1,GETDATE())
,('PLANT_CITY','Facility City','ERP - Invoice - BU',@NvarcharDataTypeID,'255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,'Plant City',1,1,GETDATE(),1,GETDATE())
,('PLANT_STATE','Facility State','ERP - Invoice - BU',@NvarcharDataTypeID,'255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,'Plant State',0,1,GETDATE(),1,GETDATE())
,('PLANT_ZIP_CODE','Facility Zip','ERP - Invoice - BU',@NvarcharDataTypeID,'255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,'Plant Zip',0,1,GETDATE(),1,GETDATE())
,('PLANT_COUNTRY','Facility Country','ERP - Invoice - BU',@NvarcharDataTypeID,'255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,'Plant Country',1,1,GETDATE(),1,GETDATE())
,('PLANT_REGION','Facility Region','ERP - Invoice - BU',@NvarcharDataTypeID,'255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,'Plant Region',0,1,GETDATE(),1,GETDATE())
,('GEP_NORM_PLANT_NAME','GEP Normalized Facility','GEP - BU',@NvarcharDataTypeID,'255',0,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('SUPPLIER_NUMBER','Invoice Supplier Number','ERP - Invoice - Supplier',@NvarcharDataTypeID,'255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,1,1,GETDATE(),1,GETDATE())
,('SUPPLIER_NAME','Invoice Supplier Name','ERP - Invoice - Supplier',@NvarcharDataTypeID,'255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,1,1,GETDATE(),1,GETDATE())
,('SUPPLIER_ADDRESS','Invoice Supplier Address','ERP - Invoice - Supplier',@NvarcharDataTypeID,'255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,1,1,GETDATE(),1,GETDATE())
,('SUPPLIER_CITY','Invoice Supplier City','ERP - Invoice - Supplier',@NvarcharDataTypeID,'255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,1,1,GETDATE(),1,GETDATE())
,('SUPPLIER_ZIP_CODE','Invoice Supplier Zip Postal Code','ERP - Invoice - Supplier',@NvarcharDataTypeID,'255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,1,1,GETDATE(),1,GETDATE())
,('SUPPLIER_STATE','Invoice Supplier State','ERP - Invoice - Supplier',@NvarcharDataTypeID,'255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,1,1,GETDATE(),1,GETDATE())
,('SUPPLIER_COUNTRY','Invoice Supplier Country','ERP - Invoice - Supplier',@NvarcharDataTypeID,'255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,1,1,GETDATE(),1,GETDATE())
,('SUPPLIER_PAYTERM_CODE','Supplier Payment Term Code','ERP - Invoice - Supplier',@NvarcharDataTypeID,'255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('SUPPLIER_PAYTERM_DESC','Supplier Payment Term Desc','ERP - Invoice - Supplier',@NvarcharDataTypeID,'255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('SUPPLIER_TYPE','Supplier Type','ERP - Invoice - Supplier',@NvarcharDataTypeID,'255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('SUPPLIER_DIVERSITY_CODE','Supplier Diversity Code','ERP - Invoice - Supplier',@NvarcharDataTypeID,'255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('SUPPLIER_DUNS_NUMBER','Supplier DUNS Number','ERP - Invoice - Supplier',@NvarcharDataTypeID,'255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('SUPPLIER_ORIGIN_COUNTRY','Supplier Country of Origin','ERP - Invoice - Supplier',@NvarcharDataTypeID,'255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('SUPPLIER_DUNS_SSI','Supplier DUNS SSI','ERP - Invoice - Supplier',@NvarcharDataTypeID,'255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('SUPPLIER_DUNS_SER','Supplier DUNS SER','ERP - Invoice - Supplier',@NvarcharDataTypeID,'255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('SUPPLIER_DUNS_PAYDEX','Supplier DUNS PAYDEX','ERP - Invoice - Supplier',@NvarcharDataTypeID,'255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('SUPPLIER_DUNS_GLOBAL_ULTIMATE_COMPANY_NAME','Supplier DUNS Global Ultimate Company','ERP - Invoice - Supplier',@NvarcharDataTypeID,'255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('SUPPLIER_DUNS_GLOBAL_ULTIMATE_COUNTRY','Supplier DUNS Global Ultimate Country','ERP - Invoice - Supplier',@NvarcharDataTypeID,'255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('SUPPLIER_PREFERRED_STATUS','Supplier Preferred status','ERP - Miscellaneous',@NvarcharDataTypeID,'255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('CUSTOMER_SUPPLIER_STATUS','Customer Supplier Status','ERP - Miscellaneous',@NvarcharDataTypeID,'255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('GEP_DELTAFLAG','GEP CF Delta Flag','GEP - Admin - Maintenance',@NvarcharDataTypeID,'255',0,0,'ShowOnProjectSetupWorkflowUtilities',0,'Flag new vendors in the latest refresh batch for QA',0,1,GETDATE(),1,GETDATE())
,('GEP_ENRICHFLAG','GEP VNE Enrich Flag','GEP - Admin - Maintenance',@NvarcharDataTypeID,'255',0,0,'ShowOnProjectSetupWorkflowUtilities',0,'Parent Enriched through DL, through Web, through D&B Hoovers',0,1,GETDATE(),1,GETDATE())
,('GEP_NEW_VENDOR_FLAG','GEP New Vendor Flag','GEP - Miscellaneous',@NvarcharDataTypeID,'255',0,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('GEP_NORM_SUPP_NUMBER','GEP Supplier Number','GEP - Supplier',@NvarcharDataTypeID,'255',0,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('GEP_NORM_SUPP_NAME','GEP Normalized Supplier','GEP - Supplier',@NvarcharDataTypeID,'255',0,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,1,1,GETDATE(),1,GETDATE())
,('GEP_ULT_PARENT','GEP Ultimate Parent','GEP - Supplier',@NvarcharDataTypeID,'255',0,0,'ShowOnProjectSetupWorkflowUtilities',1,NULL,1,1,GETDATE(),1,GETDATE())
,('GEP_NORM_SUPP_CITY','GEP Supplier City','GEP - Supplier',@NvarcharDataTypeID,'255',0,0,'ShowOnProjectSetupWorkflowUtilities',1,NULL,0,1,GETDATE(),1,GETDATE())
,('GEP_NORM_SUPP_STATE','GEP Supplier State','GEP - Supplier',@NvarcharDataTypeID,'255',0,0,'ShowOnProjectSetupWorkflowUtilities',1,NULL,0,1,GETDATE(),1,GETDATE())
,('GEP_NORM_SUPP_COUNTRY','GEP Supplier Country','GEP - Supplier',@NvarcharDataTypeID,'255',0,0,'ShowOnProjectSetupWorkflowUtilities',1,NULL,0,1,GETDATE(),1,GETDATE())
,('GEP_NORM_SUPP_SUB_REGION','GEP Supplier Sub Region','GEP - Supplier',@NvarcharDataTypeID,'255',0,0,'ShowOnProjectSetupWorkflowUtilities',1,NULL,0,1,GETDATE(),1,GETDATE())
,('GEP_NORM_SUPP_REGION','GEP Supplier Region','GEP - Supplier',@NvarcharDataTypeID,'255',0,0,'ShowOnProjectSetupWorkflowUtilities',1,NULL,0,1,GETDATE(),1,GETDATE())
,('GEP_PREFERRED_SUPPLIER_STATUS','GEP Preferred Supplier','GEP - Miscellaneous',@NvarcharDataTypeID,'255',0,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('GEP_CUSTOMER_SUPPLIER_STATUS','GEP Customer Supplier Flag','GEP - Miscellaneous',@NvarcharDataTypeID,'255',0,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('GEP_AI_SUPPLIER_LOB','GEP AI DL Supplier LOB','GEP - Admin - Data Lake',@NvarcharDataTypeID,'255',0,0,'ShowOnProjectSetupWorkflowUtilities',0,'Cold Start Run 1',0,1,GETDATE(),1,GETDATE())
,('GEP_SUPPLIER_PAYMENT_TERM','GEP Normalized Supplier Payment Term','GEP - Payment Term',@NvarcharDataTypeID,'255',0,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('GEP_SUPPLIER_NET_DAYS','GEP Supplier Payment Term Net Days','GEP - Payment Term',@FloatDataTypeID,NULL,0,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('GEP_SUPPLIER_DISCOUNT_PERCENTAGE','GEP Supplier Payment Term Discount Percentage','GEP - Payment Term',@FloatDataTypeID,NULL,0,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('GEP_SUPPLIER_DISCOUNT_DAYS','GEP Supplier Payment Term Net Days Discount Adjusted','GEP - Payment Term',@FloatDataTypeID,NULL,0,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('PAYMENT_TERM_CODE','Invoice Payment Term Code','ERP - Invoice - Payment Term',@NvarcharDataTypeID,'255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('PAYMENT_TERM_DESCRIPTION','Invoice Payment Term Desc','ERP - Invoice - Payment Term',@NvarcharDataTypeID,'255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,1,1,GETDATE(),1,GETDATE())
,('GEP_NORM_PAYMENT_TERM','GEP Normalized Invoice Payment Term','GEP - Payment Term',@NvarcharDataTypeID,'255',0,0,'ShowOnProjectSetupWorkflowUtilities',0,'NET 35 10%',1,1,GETDATE(),1,GETDATE())
,('GEP_NORM_NET_DAYS','GEP Invoice Payment Term Net Days','GEP - Payment Term',@FloatDataTypeID,NULL,0,0,'ShowOnProjectSetupWorkflowUtilities',0,'35',0,1,GETDATE(),1,GETDATE())
,('GEP_NORM_DISCOUNT_PERCENTAGE','GEP Invoice Payment Term Discount Percentage','GEP - Payment Term',@FloatDataTypeID,NULL,0,0,'ShowOnProjectSetupWorkflowUtilities',0,'0.1',0,1,GETDATE(),1,GETDATE())
,('GEP_NORM_DISCOUNT_DAYS','GEP Invoice Payment Term Net Days Discount Adjusted','GEP - Payment Term',@FloatDataTypeID,NULL,0,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('GL_ACCOUNT_CODE','GL Account Code','ERP - Invoice - GL',@NvarcharDataTypeID,'255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,1,1,GETDATE(),1,GETDATE())
,('GL_ACCOUNT_NAME','GL Account Name','ERP - Invoice - GL',@NvarcharDataTypeID,'255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,1,1,GETDATE(),1,GETDATE())
,('GL_ACCOUNT_HIERARCHY_L1','GL Hierarchy 1','ERP - Invoice - GL',@NvarcharDataTypeID,'255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('GL_ACCOUNT_HIERARCHY_L2','GL Hierarchy 2','ERP - Invoice - GL',@NvarcharDataTypeID,'255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('CHART_OF_ACCOUNT_CODE','Chart of Account Code','ERP - Invoice - GL',@NvarcharDataTypeID,'255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('CHART_OF_ACCOUNT_NAME','Chart of Account Name','ERP - Invoice - GL',@NvarcharDataTypeID,'255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('COST_CENTER_CODE','Cost Center Code','ERP - Invoice - Cost Center',@NvarcharDataTypeID,'255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,1,1,GETDATE(),1,GETDATE())
,('COST_CENTER_DESCRIPTION','Cost Center Name','ERP - Invoice - Cost Center',@NvarcharDataTypeID,'255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,1,1,GETDATE(),1,GETDATE())
,('COST_CENTER_HIERARCHY_L1','Cost Center Hierarchy 1','ERP - Invoice - Cost Center',@NvarcharDataTypeID,'255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('COST_CENTER_HIERARCHY_L2','Cost Center Hierarchy 2','ERP - Invoice - Cost Center',@NvarcharDataTypeID,'255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('COST_CENTER_HIERARCHY_L3','Cost Center Hierarchy 3','ERP - Invoice - Cost Center',@NvarcharDataTypeID,'255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('COST_CENTER_HIERARCHY_L4','Cost Center Hierarchy 4','ERP - Invoice - Cost Center',@NvarcharDataTypeID,'255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('COST_CENTER_HIERARCHY_L5','Cost Center Hierarchy 5','ERP - Invoice - Cost Center',@NvarcharDataTypeID,'255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('CONTRACT_SOURCE_SYSTEM','Contract Source System','ERP - Contract',@NvarcharDataTypeID,'255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,'SbG, Ariba',0,1,GETDATE(),1,GETDATE())
,('CONTRACT_NUMBER','Contract Number','ERP - Contract',@NvarcharDataTypeID,'255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,1,1,GETDATE(),1,GETDATE())
,('CONTRACT_LINE_NUMBER','Contract Line Number','ERP - Contract',@NvarcharDataTypeID,'255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('CONTRACT_AMOUNT','Contract Amount','ERP - Contract',@FloatDataTypeID,NULL,1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,1,1,GETDATE(),1,GETDATE())
,('CONTRACT_START_DATE','Contract Start Date','ERP - Contract',@DateDataTypeID,NULL,1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,1,1,GETDATE(),1,GETDATE())
,('CONTRACT_END_DATE','Contract End Date','ERP - Contract',@DateDataTypeID,NULL,1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,1,1,GETDATE(),1,GETDATE())
,('CONTRACT_SUPPLIER_NUMBER','Contract Supplier Number','ERP - Contract',@NvarcharDataTypeID,'255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('CONTRACT_SUPPLIER_NAME','Contract Supplier Name','ERP - Contract',@NvarcharDataTypeID,'255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,1,1,GETDATE(),1,GETDATE())
,('CONTRACT_DESCRIPTION','Contract Description','ERP - Contract',@NvarcharDataTypeID,'2000',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,1,1,GETDATE(),1,GETDATE())
,('CONTRACT_DESCRIPTION_2','Contract Description 2','ERP - Contract',@NvarcharDataTypeID,'2000',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('CONTRACT_CATEGORY_CODE','Contract Category Code','ERP - Contract',@NvarcharDataTypeID,'255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('CONTRACT_CATEGORY_1','Contract Category 1','ERP - Contract',@NvarcharDataTypeID,'255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('CONTRACT_CATEGORY_2','Contract Category 2','ERP - Contract',@NvarcharDataTypeID,'255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('CONTRACT_CATEGORY_3','Contract Category 3','ERP - Contract',@NvarcharDataTypeID,'255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('CONTRACT_CATEGORY_4','Contract Category 4','ERP - Contract',@NvarcharDataTypeID,'255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('CONTRACT_OWNER','Contract Owner','ERP - Contract',@NvarcharDataTypeID,'255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('CONTRACT_STATUS','Contract Status','ERP - Contract',@NvarcharDataTypeID,'255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('CONTRACT_TYPE','Contract Type','ERP - Contract',@NvarcharDataTypeID,'255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('CONTRACT_BUSINESS_UNIT','Contract Business Unit','ERP - Contract',@NvarcharDataTypeID,'255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('CONTRACT_COMPANY','Contract Company','ERP - Contract',@NvarcharDataTypeID,'255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('CONTRACT_BU_COUNTRY','Contract BU Country','ERP - Contract',@NvarcharDataTypeID,'255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('CONTRACT_BU_REGION','Contract BU Region','ERP - Contract',@NvarcharDataTypeID,'255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('CONTRACT_RENEWAL_TYPE','Contract Renewal Type','ERP - Contract',@NvarcharDataTypeID,'255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('CLIENT_CHILD_SUPPLIER','Client Child Supplier','ERP - Existing Enrichment',@NvarcharDataTypeID,'255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('CLIENT_PARENT_SUPPLIER','Client Parent Supplier','ERP - Existing Enrichment',@NvarcharDataTypeID,'255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('CLIENT_CATEGORY_CODE','Client Category Code','ERP - Existing Enrichment',@NvarcharDataTypeID,'255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('CLIENT_CATEGORY_1','Client Category 1','ERP - Existing Enrichment',@NvarcharDataTypeID,'255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('CLIENT_CATEGORY_2','Client Category 2','ERP - Existing Enrichment',@NvarcharDataTypeID,'255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('CLIENT_CATEGORY_3','Client Category 3','ERP - Existing Enrichment',@NvarcharDataTypeID,'255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('CLIENT_CATEGORY_4','Client Category 4','ERP - Existing Enrichment',@NvarcharDataTypeID,'255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('GEP_CATEGORY_KEY','GEP Category Key','GEP - Category',@NvarcharDataTypeID,'255',0,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('GEP_CATEGORY_CODE','GEP Category Code','GEP - Category',@NvarcharDataTypeID,'255',0,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('GEP_CATEGORY_LEVEL_1','GEP Category Level 1','GEP - Category',@NvarcharDataTypeID,'255',0,0,'ShowOnProjectSetupWorkflowUtilities',1,NULL,1,1,GETDATE(),1,GETDATE())
,('GEP_CATEGORY_LEVEL_2','GEP Category Level 2','GEP - Category',@NvarcharDataTypeID,'255',0,0,'ShowOnProjectSetupWorkflowUtilities',1,NULL,1,1,GETDATE(),1,GETDATE())
,('GEP_CATEGORY_LEVEL_3','GEP Category Level 3','GEP - Category',@NvarcharDataTypeID,'255',0,0,'ShowOnProjectSetupWorkflowUtilities',1,NULL,1,1,GETDATE(),1,GETDATE())
,('GEP_CATEGORY_LEVEL_4','GEP Category Level 4','GEP - Category',@NvarcharDataTypeID,'255',0,0,'ShowOnProjectSetupWorkflowUtilities',1,NULL,1,1,GETDATE(),1,GETDATE())
,('GEP_CATEGORY_LEVEL_5','GEP Category Level 5','GEP - Category',@NvarcharDataTypeID,'255',0,0,'ShowOnProjectSetupWorkflowUtilities',1,NULL,0,1,GETDATE(),1,GETDATE())
,('GEP_CATEGORY_LEVEL_6','GEP Category Level 6','GEP - Category',@NvarcharDataTypeID,'255',0,0,'ShowOnProjectSetupWorkflowUtilities',1,NULL,0,1,GETDATE(),1,GETDATE())
,('GEP_CATEGORY_LEVEL_7','GEP Category Level 7','GEP - Category',@NvarcharDataTypeID,'255',0,0,'ShowOnProjectSetupWorkflowUtilities',1,NULL,0,1,GETDATE(),1,GETDATE())
,('GEP_CATEGORY_VERSION','GEP Category Version','GEP - Category',@NvarcharDataTypeID,'255',0,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('GEP_PRODUCT_SERVICE_FLAG','GEP Product Service Flag','GEP - Category',@NvarcharDataTypeID,'255',0,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('GEP_DIRECT_INDIRECT_FLAG','GEP Direct Indirect Flag','GEP - Category',@NvarcharDataTypeID,'255',0,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('GEP_SOURCING_CATEGORY','GEP Sourcing Category','GEP - Category',@NvarcharDataTypeID,'255',0,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('GEP_MRO_CAPITAL_FLAG','GEP MRO Capital Flag','GEP - Category',@NvarcharDataTypeID,'255',0,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('GEP_UNSPSC_KEY','GEP UNSPSC Key','GEP - Category',@NvarcharDataTypeID,'255',0,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('GEP_UNSPSC_CODE','GEP UNSPSC Code','GEP - Category',@NvarcharDataTypeID,'255',0,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('GEP_UNSPSC_L1_SEGMENT','GEP UNSPSC L1 Segment','GEP - Category',@NvarcharDataTypeID,'255',0,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('GEP_UNSPSC_L2_FAMILY','GEP UNSPSC L2 Family','GEP - Category',@NvarcharDataTypeID,'255',0,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('GEP_UNSPSC_L3_CATEGORY','GEP UNSPSC L3 Category','GEP - Category',@NvarcharDataTypeID,'255',0,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('GEP_UNSPSC_L4_COMMODITY','GEP UNSPSC L4 Commodity','GEP - Category',@NvarcharDataTypeID,'255',0,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('GEP_UNSPSC_VERSION','GEP UNSPSC Version','GEP - Category',@NvarcharDataTypeID,'255',0,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('GEP_UNSPSC_STATUS','GEP UNSPSC Status','GEP - Category',@NvarcharDataTypeID,'255',0,0,'ShowOnProjectSetupWorkflowUtilities',0,'Active',0,1,GETDATE(),1,GETDATE())
,('PO_SOURCE_SYSTEM','PO Source System','ERP - PO',@NvarcharDataTypeID,'255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,'SbG, Ariba',0,1,GETDATE(),1,GETDATE())
,('PO_STATUS','PO Status','ERP - PO',@NvarcharDataTypeID,'255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,'Draft, Open, Closed',0,1,GETDATE(),1,GETDATE())
,('PO_TYPE','PO Type','ERP - PO',@NvarcharDataTypeID,'255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,'Catalog, Blanket',0,1,GETDATE(),1,GETDATE())
,('PO_DOCUMENT_TYPE','PO Document Type','ERP - PO',@NvarcharDataTypeID,'255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,'SAP Doc Type',0,1,GETDATE(),1,GETDATE())
,('PO_NUMBER','PO Number','ERP - Invoice',@NvarcharDataTypeID,'255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,1,1,GETDATE(),1,GETDATE())
,('PO_LINE_NUMBER','PO Line Number','ERP - Invoice',@NvarcharDataTypeID,'255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,1,1,GETDATE(),1,GETDATE())
,('PO_EXTRA_PO_KEY','PO Number 2','ERP - PO',@NvarcharDataTypeID,'255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,'Extra PO Key',0,1,GETDATE(),1,GETDATE())
,('PO_EXTRA_PO_LINE_KEY','PO Number 3','ERP - PO',@NvarcharDataTypeID,'255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,'Extra PO Line Key',0,1,GETDATE(),1,GETDATE())
,('PO_DOCUMENT_DATE','PO Date','ERP - PO',@DateDataTypeID,NULL,1,0,'ShowOnProjectSetupWorkflowUtilities',0,'Order Date',0,1,GETDATE(),1,GETDATE())
,('PO_COMPANY_CODE','PO Company Code','ERP - PO',@NvarcharDataTypeID,'255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('PO_COMPANY_NAME','PO Company Name','ERP - PO',@NvarcharDataTypeID,'255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('PO_LINE_AMOUNT_NORMALIZED','PO Line Amount Normalized','ERP - PO',@FloatDataTypeID,NULL,1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('GEP_CATEGORY_MANAGER_LOCAL','GEP Category Manager Local','GEP - Miscellaneous',@NvarcharDataTypeID,'255',0,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('PO_LINE_AMOUNT_CURRENCY','PO Line Amount Currency','ERP - PO',@NvarcharDataTypeID,'255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('PO_OPEN_LINE_AMOUNT_NORMALIZED','PO Open Line Amount Normalized','ERP - PO',@FloatDataTypeID,NULL,1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('PO_LINE_AMOUNT_LOCAL','PO Line Amount Local','ERP - PO',@FloatDataTypeID,NULL,1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('PO_OPEN_LINE_AMOUNT_CURRENCY','PO Open Line Amount Currency','ERP - PO',@NvarcharDataTypeID,'255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('PO_UNIT_PRICE_NORMALIZED','PO Unit Price Normalized','ERP - PO',@FloatDataTypeID,NULL,1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,1,1,GETDATE(),1,GETDATE())
,('PO_OPEN_LINE_AMOUNT_LOCAL','PO Open Line Amount Local','ERP - PO',@FloatDataTypeID,NULL,1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('PO_UNIT_PRICE_CURRENCY','PO Unit Price Currency','ERP - PO',@NvarcharDataTypeID,'255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('PO_PAYMENT_TERM','PO Payment Term','ERP - PO',@NvarcharDataTypeID,'255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('GEP_NORM_PO_PAYMENT_TERM','GEP Normalized PO Payment Term','GEP - Payment Term',@NvarcharDataTypeID,'255',0,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('PO_QUANTITY','PO Quantity','ERP - PO',@FloatDataTypeID,NULL,1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,1,1,GETDATE(),1,GETDATE())
,('PO_QUANTITY_NORMALIZED','GEP Normalized PO Quanity','GEP - Amount',@FloatDataTypeID,NULL,0,0,'ShowOnProjectSetupWorkflowUtilities',0,'Convert to Standard UOM',0,1,GETDATE(),1,GETDATE())
,('PO_UOM','PO UOM','ERP - PO',@NvarcharDataTypeID,'255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,1,1,GETDATE(),1,GETDATE())
,('PO_UOM_NORMALIZED','GEP Normalized PO UOM','GEP - Amount',@NvarcharDataTypeID,'255',0,0,'ShowOnProjectSetupWorkflowUtilities',0,'Convert to Standard UOM',0,1,GETDATE(),1,GETDATE())
,('PO_DESCRIPTION_1','PO Description','ERP - PO',@NvarcharDataTypeID,'2000',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,1,1,GETDATE(),1,GETDATE())
,('PO_DESCRIPTION_2','PO Description 2','ERP - PO',@NvarcharDataTypeID,'2000',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('PO_PLANT_CODE','PO Plant Code','ERP - PO',@NvarcharDataTypeID,'255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,'Plant Code, Ship to Plant',0,1,GETDATE(),1,GETDATE())
,('PO_PLANT_NAME','PO Plant Name','ERP - PO',@NvarcharDataTypeID,'255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,'Plant Name',0,1,GETDATE(),1,GETDATE())
,('PO_PLANT_ADDRESS','PO Plant Address','ERP - PO',@NvarcharDataTypeID,'255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,'Plant Address',0,1,GETDATE(),1,GETDATE())
,('PO_PLANT_CITY','PO Plant City','ERP - PO',@NvarcharDataTypeID,'255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,'Plant City',0,1,GETDATE(),1,GETDATE())
,('PO_PLANT_STATE','PO Plant State','ERP - PO',@NvarcharDataTypeID,'255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,'Plant State',0,1,GETDATE(),1,GETDATE())
,('PO_PLANT_ZIP','PO Plant Zip','ERP - PO',@NvarcharDataTypeID,'255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,'Plant Zip',0,1,GETDATE(),1,GETDATE())
,('PO_PLANT_COUNTRY','PO Plant Country','ERP - PO',@NvarcharDataTypeID,'255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,'Plant Country',0,1,GETDATE(),1,GETDATE())
,('PO_PLANT_REGION','PO Plant Region','ERP - PO',@NvarcharDataTypeID,'255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,'Plant Region',0,1,GETDATE(),1,GETDATE())
,('PO_PLANT_TYPE','PO Plant Type','ERP - PO',@NvarcharDataTypeID,'255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,'Office, Plant, Store',0,1,GETDATE(),1,GETDATE())
,('PO_CATALOG_STATUS','PO Catalog','ERP - PO',@NvarcharDataTypeID,'255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,'Catalog name',0,1,GETDATE(),1,GETDATE())
,('PO_SUPPLIER_NUMBER','PO Supplier Number','ERP - PO',@NvarcharDataTypeID,'255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('PO_SUPPLIER_NAME','PO Supplier Name','ERP - PO',@NvarcharDataTypeID,'255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('PO_BUYER_CODE','PO Buyer Code','ERP - PO',@NvarcharDataTypeID,'255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('PO_BUYER_NAME','PO Buyer Name','ERP - PO',@NvarcharDataTypeID,'255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,'Buyer Name',1,1,GETDATE(),1,GETDATE())
,('PO_PURCHASING_GROUP_CODE','PO Purchasing Group Code','ERP - PO',@NvarcharDataTypeID,'255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('PO_PURCHASING_GROUP_NAME','PO Purchasing Group Name','ERP - PO',@NvarcharDataTypeID,'255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,'Cat Mgr',0,1,GETDATE(),1,GETDATE())
,('PO_PURCHASING_GROUP_NAME_2','PO Purchasing Group Name 2','ERP - PO',@NvarcharDataTypeID,'255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,'Tower/ Director',0,1,GETDATE(),1,GETDATE())
,('PO_PURCHASING_ORG_CODE','PO Purchasing Org Code','ERP - PO',@NvarcharDataTypeID,'255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('PO_PURCHASING_ORG_NAME','PO Purchasing Org Name','ERP - PO',@NvarcharDataTypeID,'255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('PO_CREATED_BY','PO Created By','ERP - PO',@NvarcharDataTypeID,'255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('PO_APPROVER','PO Approver','ERP - PO',@NvarcharDataTypeID,'255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('PO_GL_CODE','PO GL Code','ERP - PO',@NvarcharDataTypeID,'255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('PO_GL_NAME','PO GL Name','ERP - PO',@NvarcharDataTypeID,'255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('PO_COST_CENTER_CODE','PO Cost Center Code','ERP - PO',@NvarcharDataTypeID,'255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('PO_COST_CENTER_NAME','PO Cost Center Name','ERP - PO',@NvarcharDataTypeID,'255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('PO_LANGUAGE','PO Language','ERP - PO',@NvarcharDataTypeID,'255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('PO_CATEGORY_CODE','PO Category Code','ERP - PO',@NvarcharDataTypeID,'255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('PO_CATEGORY_1','PO Category 1','ERP - PO',@NvarcharDataTypeID,'255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('PO_CATEGORY_2','PO Category 2','ERP - PO',@NvarcharDataTypeID,'255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('PO_CATEGORY_3','PO Category 3','ERP - PO',@NvarcharDataTypeID,'255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('PO_CATEGORY_4','PO Category 4','ERP - PO',@NvarcharDataTypeID,'255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('ITEM_MATERIAL_NUMBER','Material Number','ERP - Item Master',@NvarcharDataTypeID,'255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,1,1,GETDATE(),1,GETDATE())
,('ITEM_MATERIAL_REVISION_NUMBER','Maerial Revision Number','ERP - Item Master',@NvarcharDataTypeID,'255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('ITEM_MATERIAL_DESCRIPTION','Material Description','ERP - Item Master',@NvarcharDataTypeID,'255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,1,1,GETDATE(),1,GETDATE())
,('ITEM_MATERIAL_GROUP_CODE','Material Group Code','ERP - Item Master',@NvarcharDataTypeID,'255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('ITEM_MATERIAL_GROUP_DESCRIPTION','Material Group Description','ERP - Item Master',@NvarcharDataTypeID,'255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,1,1,GETDATE(),1,GETDATE())
,('ITEM_MATERIAL_TYPE','Material Type','ERP - Item Master',@NvarcharDataTypeID,'255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,'Direct, Indirect',0,1,GETDATE(),1,GETDATE())
,('ITEM_MANUFACTURER_NAME','Manufacturer Name','ERP - Item Master',@NvarcharDataTypeID,'255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('ITEM_MANUFACTURER_PART_NUMBER','Manufacturer Part No','ERP - Item Master',@NvarcharDataTypeID,'255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('ITEM_SUPPLIER_PART_NUMBER','Supplier Part No','ERP - Item Master',@NvarcharDataTypeID,'255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('ITEM_MATERIAL_CATEGORY_CODE','Material Category Code','ERP - Item Master',@NvarcharDataTypeID,'255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,'UNSPSC, eClass',0,1,GETDATE(),1,GETDATE())
,('ITEM_MATERIAL_CATEGORY_1','Material Category L1','ERP - Item Master',@NvarcharDataTypeID,'255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,'UNSPSC, eClass',0,1,GETDATE(),1,GETDATE())
,('ITEM_MATERIAL_CATEGORY_2','Material Category L2','ERP - Item Master',@NvarcharDataTypeID,'255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,'UNSPSC, eClass',0,1,GETDATE(),1,GETDATE())
,('ITEM_MATERIAL_CATEGORY_3','Material Category L3','ERP - Item Master',@NvarcharDataTypeID,'255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,'UNSPSC, eClass',0,1,GETDATE(),1,GETDATE())
,('ITEM_MATERIAL_CATEGORY_4','Material Category L4','ERP - Item Master',@NvarcharDataTypeID,'255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,'UNSPSC, eClass',0,1,GETDATE(),1,GETDATE())
,('ITEM_MATERIAL_NAME','Material Name','ERP - Item Master',@NvarcharDataTypeID,'255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,'Noun, Modifier',0,1,GETDATE(),1,GETDATE())
,('ITEM_MATERIAL_STOCK_INDICATOR','Material Stock Indicator','ERP - Item Master',@NvarcharDataTypeID,'255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,'Stocked, Obsolete',0,1,GETDATE(),1,GETDATE())
,('ITEM_MATERIAL_CRITICALITY','Material Criticality','ERP - Item Master',@NvarcharDataTypeID,'255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('ITEM_MATERIAL_LEAD_TIME','Material Lead Time','ERP - Item Master',@FloatDataTypeID,NULL,1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('ITEM_MATERIAL_STANDARD_COST','Material Standard Cost','ERP - Item Master',@FloatDataTypeID,NULL,1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('ITEM_MATERIAL_STANDARD_COST_CURRENCY','Material Standard Cost Currency','ERP - Item Master',@NvarcharDataTypeID,'255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('ITEM_MATERIAL_STANDARD_UOM','Material Standard UOM','ERP - Item Master',@NvarcharDataTypeID,'255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('ITEM_MATERIAL_STANDARD_COST_DATE','Material Standard Cost Date','ERP - Item Master',@DateDataTypeID,NULL,1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('ITEM_MATERIAL_BOM_EQUIPMENT','Material BOM Equipment','ERP - Item Master',@NvarcharDataTypeID,'255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,'Parent Equipment of Part',0,1,GETDATE(),1,GETDATE())
,('ITEM_MATERIAL_ORIGIN_COUNTRY','Material Origin Country','ERP - Item Master',@NvarcharDataTypeID,'255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('SOURCESYSTEM_1','Source System 1','ERP - Invoice - Source System',@NvarcharDataTypeID,'255',1,0,'ShowOnProjectSetupWorkflowUtilities',1,NULL,1,1,GETDATE(),1,GETDATE())
,('SOURCESYSTEM_2','Source System 2','ERP - Invoice - Source System',@NvarcharDataTypeID,'255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('SOURCESYSTEM_3','Source System 3','ERP - Invoice - Source System',@NvarcharDataTypeID,'255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('GEP_NORM_SOURCESYSTEM_1','GEP Source System','GEP - Source System',@NvarcharDataTypeID,'255',0,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('GEP_NORM_SOURCESYSTEM_2','GEP Source System Level 2','GEP - Source System',@NvarcharDataTypeID,'255',0,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('GEP_NORM_SOURCESYSTEM_3','GEP Source System Level 3','GEP - Source System',@NvarcharDataTypeID,'255',0,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('PROFIT_CENTER_CODE','Profit Center Code','ERP - Invoice - Cost Center',@NvarcharDataTypeID,'255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,'RC code',0,1,GETDATE(),1,GETDATE())
,('PROFIT_CENTER_NAME','Profit Center Name','ERP - Invoice - Cost Center',@NvarcharDataTypeID,'255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('PROFIT_CENTER_HIERARCHY_1','Profit Center Hierarchy 1','ERP - Invoice - Cost Center',@NvarcharDataTypeID,'255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('PROFIT_CENTER_HIERARCHY_2','Profit Center Hierarchy 2','ERP - Invoice - Cost Center',@NvarcharDataTypeID,'255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('PROFIT_CENTER_HIERARCHY_3','Profit Center Hierarchy 3','ERP - Invoice - Cost Center',@NvarcharDataTypeID,'255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('PROFIT_CENTER_HIERARCHY_4','Profit Center Hierarchy 4','ERP - Invoice - Cost Center',@NvarcharDataTypeID,'255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('PROFIT_CENTER_HIERARCHY_5','Profit Center Hierarchy 5','ERP - Invoice - Cost Center',@NvarcharDataTypeID,'255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('PROFIT_CENTER_HIERARCHY_6','Profit Center Hierarchy 6','ERP - Invoice - Cost Center',@NvarcharDataTypeID,'255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('INCOTERMS_CODE','Inco Terms Code','ERP - Miscellaneous',@NvarcharDataTypeID,'255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,'Approver Hier.',0,1,GETDATE(),1,GETDATE())
,('INCOTERMS_DESCRIPTION','Inco Terms Description','ERP - Miscellaneous',@NvarcharDataTypeID,'255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,'If in SAP',0,1,GETDATE(),1,GETDATE())
,('GEP_DIVERSITY_FLAG','GEP Diversity Flag','GEP - Diversity',@NvarcharDataTypeID,'255',0,0,'ShowOnProjectSetupWorkflowUtilities',0,'Y, N',0,1,GETDATE(),1,GETDATE())
,('GEP_DIVERSITY_TYPE','Gep Diversity Type','GEP - Diversity',@NvarcharDataTypeID,'255',0,0,'ShowOnProjectSetupWorkflowUtilities',0,'Combo',0,1,GETDATE(),1,GETDATE())
,('GEP_DIVERSITY_8A_CERTIFICATION_INDICATOR','GEP Diversity 8a Certification Indicator','GEP - Diversity',@NvarcharDataTypeID,'255',0,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('GEP_DIVERSITY_AIRPORT_CONCESSION_DISADVANTAGED_BUSINESS_ENTERPRISE_INDICATOR','GEP Diversity Airport Concession Disadvantaged Business Enterprise Indicator','GEP - Diversity',@NvarcharDataTypeID,'255',0,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('GEP_DIVERSITY_ALASKAN_NATIVE_CORPORATION_INDICATOR','GEP Diversity Alaskan Native Corporation Indicator','GEP - Diversity',@NvarcharDataTypeID,'255',0,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('GEP_DIVERSITY_CERTIFIED_SMALL_BUSINESS_INDICATOR','GEP Diversity Certified Small Business Indicator','GEP - Diversity',@NvarcharDataTypeID,'255',0,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('GEP_DIVERSITY_DISABLED_VETERAN_BUSINESS_ENTERPRISE_INDICATOR','GEP Diversity Disabled Veteran Business Enterprise Indicator','GEP - Diversity',@NvarcharDataTypeID,'255',0,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('GEP_DIVERSITY_DISABLED_OWNED_BUSINESS_INDICATOR','GEP Diversity Disabled Owned Business Indicator','GEP - Diversity',@NvarcharDataTypeID,'255',0,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('GEP_DIVERSITY_DISADVANTAGED_BUSINESS_ENTERPRISE_INDICATOR','GEP Diversity Disadvantaged Business Enterprise Indicator','GEP - Diversity',@NvarcharDataTypeID,'255',0,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('GEP_DIVERSITY_DISADVANTAGED_VETERAN_ENTERPRISE_INDICATOR','GEP Diversity Disadvantaged Veteran Enterprise Indicator','GEP - Diversity',@NvarcharDataTypeID,'255',0,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('GEP_DIVERSITY_HUB_ZONE_CERTIFIED_BUSINESS_INDICATOR','GEP Diversity Hub Zone Certified Business Indicator','GEP - Diversity',@NvarcharDataTypeID,'255',0,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('GEP_DIVERSITY_LABOR_SURPLUS_AREA_INDICATOR','GEP Diversity Labor Surplus Area Indicator','GEP - Diversity',@NvarcharDataTypeID,'255',0,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('GEP_DIVERSITY_MINORITY_BUSINESS_ENTERPRISE_INDICATOR','GEP Diversity Minority Business Enterprise Indicator','GEP - Diversity',@NvarcharDataTypeID,'255',0,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('GEP_DIVERSITY_MINORITY_COLLEGE_INDICATOR','GEP Diversity Minority College Indicator','GEP - Diversity',@NvarcharDataTypeID,'255',0,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('GEP_DIVERSITY_MINORITY_OWNED_INDICATOR','GEP Diversity Minority Owned Indicator','GEP - Diversity',@NvarcharDataTypeID,'255',0,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('GEP_DIVERSITY_OUT_OF_BUSINESS_INDICATOR','GEP Diversity Out Of Business Indicator','GEP - Diversity',@NvarcharDataTypeID,'255',0,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('GEP_DIVERSITY_POLITICAL_DISTRICT','GEP Diversity Political District','GEP - Diversity',@NvarcharDataTypeID,'255',0,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('GEP_DIVERSITY_SERVICE_DISABLED_VETERAN_OWNED_INDICATOR','GEP Diversity Service Disabled Veteran Owned Indicator','GEP - Diversity',@NvarcharDataTypeID,'255',0,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('GEP_DIVERSITY_SMALL_BUSINESS_INDICATOR','GEP Diversity Small Business Indicator','GEP - Diversity',@NvarcharDataTypeID,'255',0,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('GEP_DIVERSITY_SMALL_DISADVANTAGED_BUSINESS_INDICATOR','GEP Diversity Small Disadvantaged Business Indicator','GEP - Diversity',@NvarcharDataTypeID,'255',0,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('GEP_DIVERSITY_VETERAN_BUSINESS_ENTERPRISE_INDICATOR','GEP Diversity Veteran Business Enterprise Indicator','GEP - Diversity',@NvarcharDataTypeID,'255',0,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('GEP_DIVERSITY_VETERAN_OWNED_INDICATOR','GEP Diversity Veteran Owned Indicator','GEP - Diversity',@NvarcharDataTypeID,'255',0,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('GEP_DIVERSITY_VIETNAM_VETERAN_OWNED_INDICATOR','GEP Diversity Vietnam Veteran Owned Indicator','GEP - Diversity',@NvarcharDataTypeID,'255',0,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('GEP_DIVERSITY_OTHER_VETERAN_OWNED_INDICATOR','GEP Diversity Other Veteran Owned Indicator','GEP - Diversity',@NvarcharDataTypeID,'255',0,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('GEP_DIVERSITY_WOMAN_OWNED_BUSINESS_ENTERPRISE_INDICATOR','GEP Diversity Woman Owned Business Enterprise Indicator','GEP - Diversity',@NvarcharDataTypeID,'255',0,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('GEP_DIVERSITY_WOMAN_OWNED_INDICATOR','GEP Diversity Woman Owned Indicator','GEP - Diversity',@NvarcharDataTypeID,'255',0,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('GEP_DIVERSITY_AFRICAN_AMERICAN_OWNED_INDICATOR','GEP Diversity African American Owned Indicator','GEP - Diversity',@NvarcharDataTypeID,'255',0,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('GEP_DIVERSITY_ASIAN_PACIFIC_AMERICAN_OWNED_INDICATOR','GEP Diversity Asian Pacific American Owned Indicator','GEP - Diversity',@NvarcharDataTypeID,'255',0,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('GEP_DIVERSITY_HISPANIC_AMERICAN_OWNED_INDICATOR','GEP Diversity Hispanic American Owned Indicator','GEP - Diversity',@NvarcharDataTypeID,'255',0,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('GEP_DIVERSITY_NATIVE_AMERICAN_OWNED_INDICATOR','GEP Diversity Native American Owned Indicator','GEP - Diversity',@NvarcharDataTypeID,'255',0,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('GEP_DIVERSITY_SUBCONTINENT_ASIAN_AMERICAN_OWNED_INDICATOR','GEP Diversity Subcontinent Asian American Owned Indicator','GEP - Diversity',@NvarcharDataTypeID,'255',0,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('GEP_OTHER_DIVERSITY','Gep Diversity Other','GEP - Diversity',@NvarcharDataTypeID,'255',0,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('SOURCEFILENAME','Source File Name','GEP - Admin - ID',@NvarcharDataTypeID,'1000',0,0,'ShowOnProjectSetupWorkflowUtilities',1,'Includes FTP Folder Path, New Tool logic will maintian folder names maintained within Pickup folder',0,1,GETDATE(),1,GETDATE())
,('GEP_YEAR','GEP Calendar Year','GEP - Period',@intDataTypeID,NULL,0,0,'ShowOnProjectSetupWorkflowUtilities',1,NULL,0,1,GETDATE(),1,GETDATE())
,('GEP_QTR','GEP Calendar Quarter','GEP - Period',@NvarcharDataTypeID,'20',0,0,'ShowOnProjectSetupWorkflowUtilities',1,NULL,0,1,GETDATE(),1,GETDATE())
,('GEP_MONTH','GEP Calendar Month','GEP - Period',@NvarcharDataTypeID,'255',0,0,'ShowOnProjectSetupWorkflowUtilities',1,NULL,0,1,GETDATE(),1,GETDATE())
,('GEP_FISCAL_ID','GEP Fiscal Period ID','GEP - Period',@NvarcharDataTypeID,'255',0,0,'ShowOnProjectSetupWorkflowUtilities',0,'P1, P2',0,1,GETDATE(),1,GETDATE())
,('GEP_FISCAL_YEAR','GEP Fiscal Year','GEP - Period',@NvarcharDataTypeID,'255',0,0,'ShowOnProjectSetupWorkflowUtilities',1,NULL,1,1,GETDATE(),1,GETDATE())
,('GEP_FISCAL_QTR','GEP Fiscal Quarter','GEP - Period',@NvarcharDataTypeID,'20',0,0,'ShowOnProjectSetupWorkflowUtilities',1,NULL,1,1,GETDATE(),1,GETDATE())
,('GEP_FISCAL_MONTH','GEP Fiscal Month','GEP - Period',@NvarcharDataTypeID,'255',0,0,'ShowOnProjectSetupWorkflowUtilities',1,NULL,1,1,GETDATE(),1,GETDATE())
,('CARD_HOLDER_ID','Card holder ID','ERP - Corp Card',@NvarcharDataTypeID,'255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('CARD_HOLDER_NAME','Card holder Name','ERP - Corp Card',@NvarcharDataTypeID,'255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('MERCHANT_CATEGORY_CODE','Merchant Category Code','ERP - Corp Card',@NvarcharDataTypeID,'255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('MERCHANT_CATEGORY_CODE_TITLE','Merchant Category Code Title','ERP - Corp Card',@NvarcharDataTypeID,'255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,1,1,GETDATE(),1,GETDATE())
,('MERCHANT_CATEGORY_GROUP_CODE','Merchant Category Group Code','ERP - Corp Card',@NvarcharDataTypeID,'255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('MERCHANT_CATEGORY_GROUP_TITLE','Merchant Category Group Title','ERP - Corp Card',@NvarcharDataTypeID,'255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('EXPENSE_TYPE','Expense Type','ERP - Corp Card',@NvarcharDataTypeID,'255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,1,1,GETDATE(),1,GETDATE())
,('SIC_CODE','SIC Code','ERP - Corp Card',@NvarcharDataTypeID,'255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('SIC_TITLE','SIC Title','ERP - Corp Card',@NvarcharDataTypeID,'255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('NAICS_CODE','NAICS Code','ERP - Corp Card',@NvarcharDataTypeID,'255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('NAICS_TITLE','NAICS Title','ERP - Corp Card',@NvarcharDataTypeID,'255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('PROJECT_CODE','Project Code','ERP - Miscellaneous',@NvarcharDataTypeID,'255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('PROJECT_NAME','Project Name','ERP - Miscellaneous',@NvarcharDataTypeID,'255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('PROJECT_DESC','Project Description','ERP - Miscellaneous',@NvarcharDataTypeID,'255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('WORK_ORDER_NUMBER','Work Order Number','ERP - Miscellaneous',@NvarcharDataTypeID,'255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('WORK_ORDER_DESC','Work Order Description','ERP - Miscellaneous',@NvarcharDataTypeID,'255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('WBS_CODE','WBS Code','ERP - Miscellaneous',@NvarcharDataTypeID,'255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('WBS_DESC','WBS Description','ERP - Miscellaneous',@NvarcharDataTypeID,'255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('PRODUCT','Product','ERP - Miscellaneous',@NvarcharDataTypeID,'255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('PRODUCT_CATEGORY','Product Category','ERP - Miscellaneous',@NvarcharDataTypeID,'255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('GEP_CONSOLIDATION_DESCRIPTION','GEP Consolidated Description','GEP - Miscellaneous',@NvarcharDataTypeID,'2000',0,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('REQUISITION_SOURCE_SYSTEM','Requisition Source System','ERP - Requisition',@NvarcharDataTypeID,'255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('REQUISITION_NUMBER','Requisition Number','ERP - Requisition',@NvarcharDataTypeID,'255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('REQUISITION_LINE_NUMBER','Requisition Line Number','ERP - Requisition',@NvarcharDataTypeID,'255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('REQUISITION_SUPPLIER_NUMBER','Requisition Supplier Number','ERP - Requisition',@NvarcharDataTypeID,'255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('REQUISITION_SUPPLIER_NAME','Requisition Supplier Name','ERP - Requisition',@NvarcharDataTypeID,'255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('REQUISITION_CREATION_DATE','Requisition Creation Date','ERP - Requisition',@DateDataTypeID,NULL,1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('REQUISITION_APPROVED_DATE','Requisition Approved Date','ERP - Requisition',@DateDataTypeID,NULL,1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('REQUISITION_OWNER','Requisition Owner','ERP - Requisition',@NvarcharDataTypeID,'255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('REQUISITION_AMOUNT','Requisition Amount','ERP - Requisition',@FloatDataTypeID,NULL,1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('REQUISITION_LINE_DESCRIPTION','Requisition Line Description','ERP - Requisition',@NvarcharDataTypeID,'255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('GR_SOURCE_SYSTEM','Goods Receipt Source System','ERP - Goods Receipt',@NvarcharDataTypeID,'255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('GR_NUMBER','Goods Receipt Number','ERP - Goods Receipt',@NvarcharDataTypeID,'255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('GR_LINE_NUMBER','Goods Receipt Line Number','ERP - Goods Receipt',@NvarcharDataTypeID,'255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('GR_SUPPLIER_NUMBER','Goods Receipt Supplier Number','ERP - Goods Receipt',@NvarcharDataTypeID,'255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('GR_SUPPLIER_NAME','Goods Receipt Supplier Name','ERP - Goods Receipt',@NvarcharDataTypeID,'255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('GR_DATE','Goods Receipt Date','ERP - Goods Receipt',@DateDataTypeID,NULL,1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('GR_LINE_AMOUNT','Goods Receipt Line Amount','ERP - Goods Receipt',@FloatDataTypeID,NULL,1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('GR_UNIT_PRICE','Goods Receipt Unit Price','ERP - Goods Receipt',@FloatDataTypeID,NULL,1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('GR_QUANTITY','Goods Receipt Quantity','ERP - Goods Receipt',@FloatDataTypeID,NULL,1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('GR_UOM','Goods Receipt UoM','ERP - Goods Receipt',@NvarcharDataTypeID,'255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('IMPORTEXPORTUID1','Import Export UID 1','GEP - System',@BigintDataTypeId,NULL,0,0,'HideEverywhere',1,'System Internal field',0,1,GETDATE(),1,GETDATE())
,('IMPORTEXPORTUID2','Import Export UID 2','GEP - System',@BigintDataTypeId,NULL,0,0,'HideEverywhere',1,'System Internal field',0,1,GETDATE(),1,GETDATE())
,('IMPORTEXPORTUID3','Import Export UID 3','GEP - System',@BigintDataTypeId,NULL,0,0,'HideEverywhere',1,'System Internal field',0,1,GETDATE(),1,GETDATE())
,('IMPORTEXPORTUID4','Import Export UID 4','GEP - System',@BigintDataTypeId,NULL,0,0,'HideEverywhere',1,'System Internal field',0,1,GETDATE(),1,GETDATE())
,('IMPORTEXPORTUID5','Import Export UID 5','GEP - System',@BigintDataTypeId,NULL,0,0,'HideEverywhere',1,'System Internal field',0,1,GETDATE(),1,GETDATE())
,('IMPORTEXPORTUID6','Import Export UID 6','GEP - System',@BigintDataTypeId,NULL,0,0,'HideEverywhere',1,'System Internal field',0,1,GETDATE(),1,GETDATE())
,('IMPORTEXPORTUID7','Import Export UID 7','GEP - System',@BigintDataTypeId,NULL,0,0,'HideEverywhere',1,'System Internal field',0,1,GETDATE(),1,GETDATE())
,('IMPORTEXPORTUID8','Import Export UID 8','GEP - System',@BigintDataTypeId,NULL,0,0,'HideEverywhere',1,'System Internal field',0,1,GETDATE(),1,GETDATE())
,('IMPORTEXPORTUID9','Import Export UID 9','GEP - System',@BigintDataTypeId,NULL,0,0,'HideEverywhere',1,'System Internal field',0,1,GETDATE(),1,GETDATE())
,('IMPORTEXPORTUID10','Import Export UID 10','GEP - System',@BigintDataTypeId,NULL,0,0,'HideEverywhere',1,'System Internal field',0,1,GETDATE(),1,GETDATE())
,('GEP_AI_SOURCE_VNE','GEP Supplier Normalization Source','GEP - Admin - Maintenance',@NvarcharDataTypeID,'255',0,0,'ShowOnProjectSetupWorkflowUtilities',1,'GEP_SUPP_SPEND_BUCKET',0,1,GETDATE(),1,GETDATE())
,('GEP_AI_SOURCE_UP','GEP Parent Linkage Source','GEP - Admin - Maintenance',@NvarcharDataTypeID,'255',0,0,'ShowOnProjectSetupWorkflowUtilities',1,'RULE - CLIENT, RULE - GEP, AI- DATA LAKE, AI - PROJECT',0,1,GETDATE(),1,GETDATE())
,('GEP_AI_DL_CATEGORY_L5','GEP AI DL Category L5','GEP - Admin - Data Lake',@NvarcharDataTypeID,'255',0,0,'ShowOnProjectSetupWorkflowUtilities',1,NULL,0,1,GETDATE(),1,GETDATE())
,('GEP_AI_DL_CATEGORY_L6','GEP AI DL Category L6','GEP - Admin - Data Lake',@NvarcharDataTypeID,'255',0,0,'ShowOnProjectSetupWorkflowUtilities',1,NULL,0,1,GETDATE(),1,GETDATE())
,('GEP_AI_DL_CATEGORY_L7','GEP AI DL Category L7','GEP - Admin - Data Lake',@NvarcharDataTypeID,'255',0,0,'ShowOnProjectSetupWorkflowUtilities',1,NULL,0,1,GETDATE(),1,GETDATE())
,('GEP_NORM_SPEND_AED','GEP Normalized Spend (AED)','GEP - Amount',@FloatDataTypeID,NULL,0,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE())
,('GEP_NORM_SPEND_INR','GEP Normalized Spend (INR)','GEP - Amount',@FloatDataTypeID,NULL,0,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0,1,GETDATE(),1,GETDATE());
GO

DECLARE @MainTableTypeId INT;
SELECT @MainTableTypeId = Table_Typ_Id FROM SSDL.SPEND_DCC_TABLE_TYP_MST WHERE TABLE_TYP_CODE = '101'

IF NOT EXISTS(SELECT 1 FROM SSDL.SPEND_SSDL_TABLE WHERE TableTypeID = @MainTableTypeId AND TableName = 'Main2')
BEGIN
    insert into SSDL.SPEND_SSDL_TABLE(TableTypeID, TableName, IsActive, CreatedBy, CreatedDate, LastUpdatedBy, LastUpdatedDate)
    values(@MainTableTypeId, 'Main2', 1, 1, GETDATE(), 1, GETDATE())
END

DECLARE @TableId INT;
SELECT @TableId = TableId FROM SSDL.SPEND_SSDL_TABLE WHERE TableName = 'Main2' AND TableTypeId = @MainTableTypeId

DECLARE @intDataTypeID INT = 0;
SELECT @intDataTypeID = DATA_TYP_ID from [SSDL].[SPEND_DCC_TABLE_DATA_TYP_MST]  WHERE DATA_TYP_NAME = 'Int';

DECLARE @floatDataTypeID INT = 0;
SELECT @floatDataTypeID = DATA_TYP_ID from [SSDL].[SPEND_DCC_TABLE_DATA_TYP_MST]  WHERE DATA_TYP_NAME = 'float';

IF NOT EXISTS(SELECT 1 FROM SSDL.SPEND_SSDL_TableSchema WHERE TableID = @TableId AND ColumnName = 'Custom_Col_A')
BEGIN
    INSERT INTO SSDL.SPEND_SSDL_TableSchema(TableId, ColumnName, DisplayColumnName, FieldCategory, DataTypeID, ColumnDataLength, CreatedBy, CreatedDate, LastUpdatedBy, LastUpdatedDate, IsInputField)
    VALUES (@TableId, 'Custom_Col_A', 'Custom Col A', 'ERP - Custom Fields', @intDataTypeID, 0, 1, GETDATE(), 1, GETDATE(), 0);
END
IF NOT EXISTS(SELECT 1 FROM SSDL.SPEND_SSDL_TableSchema WHERE TableID = @TableId AND ColumnName = 'GEP_YEAR')
BEGIN
    INSERT INTO SSDL.SPEND_SSDL_TableSchema(TableId, ColumnName, DisplayColumnName, FieldCategory, DataTypeID, ColumnDataLength, CreatedBy, CreatedDate, LastUpdatedBy, LastUpdatedDate, IsInputField)
    VALUES(@TableId, 'GEP_YEAR', 'GEP Calendar Year', 'GEP - Period', @intDataTypeID, 0, 1, GETDATE(), 1, GETDATE(), 0);
END
IF NOT EXISTS(SELECT 1 FROM SSDL.SPEND_SSDL_TableSchema WHERE TableID = @TableId AND ColumnName = 'GEP_RULE_ID')
BEGIN
    INSERT INTO SSDL.SPEND_SSDL_TableSchema(TableId, ColumnName, DisplayColumnName, FieldCategory, DataTypeID, ColumnDataLength, CreatedBy, CreatedDate, LastUpdatedBy, LastUpdatedDate, IsInputField)
    VALUES(@TableId, 'GEP_RULE_ID', 'GEP Rule ID (Classification)', 'GEP - Admin - Maintenance', @intDataTypeID, 0, 1, GETDATE(), 1, GETDATE(), 0);
END
IF NOT EXISTS(SELECT 1 FROM SSDL.SPEND_SSDL_TableSchema WHERE TableID = @TableId AND ColumnName = 'GEP_RULE_ID')
BEGIN
    INSERT INTO SSDL.SPEND_SSDL_TableSchema(TableId, ColumnName, DisplayColumnName, FieldCategory, DataTypeID, ColumnDataLength, CreatedBy, CreatedDate, LastUpdatedBy, LastUpdatedDate, IsInputField)
    VALUES(@TableId, 'GEP_NORM_INVOICE_UNIT_PRICE_USD', 'GEP Normalized Invoice Unit Price (USD)', 'GEP - Amount', @floatDataTypeID, 0, 1, GETDATE(), 1, GETDATE(), 1);
END
GO

/*
=======================================================================================================================================
Date			| Author				| JIRA ID			| Change Description
=======================================================================================================================================

13-10-2020       Pradeep Kumar Yadav     SSDL-2032         Main Column fields added
=======================================================================================================================================

*/
ALTER PROCEDURE SSDL.SPEND_DL_GET_JOB_DETAIL_BY_JOBID   
	@JobId INT  
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @bin VARBINARY(128) = (CAST(OBJECT_NAME(@@PROCID) AS VARBINARY(128)))
	SET CONTEXT_INFO @bin
	
	DECLARE @main_column VARCHAR(MAX), @spend_fields VARCHAR(MAX), @date_fields VARCHAR(MAX),
	@spend_displayname VARCHAR(MAX), @date_displayname VARCHAR(MAX);
	DECLARE @HasStepForMainTable BIT = 0;

	SELECT
		@main_column = JSON_VALUE(settingValue,'$.MAIN_COLUMN'),  
		@date_fields = JSON_VALUE(settingValue,'$.DATE_FIELDS'),  
		@spend_fields = JSON_VALUE(settingValue,'$.SPEND_FIELDS'),
		@spend_displayname = JSON_VALUE(settingValue,'$.DISPLAY_SPEND_FIELDS'),
		@date_displayname = JSON_VALUE(settingValue,'$.DISPLAY_DATE_FIELDS')
	FROM SPEND_SSDL_JOB_DETAILS WHERE jobId = @JobId

	IF EXISTS(SELECT 1 FROM SSDL.JOB_DETAILS WHERE JobId = @JobId) OR EXISTS(SELECT 1 FROM SSDL.WorkflowEventSetting WHERE JobId = @JobId)
	BEGIN
		SELECT @HasStepForMainTable = 1
	END

	SELECT  
		A.JOB_ID,  
		A.JOB_NAME,  
		A.JOB_STATUS,  
		A.PARTNERCODE,  
		A.CREATED_BY,   
		--U.FirstName + ' ' + U.LastName    AS CREATED_USER_NAME,    
		' ' AS CREATED_USER_NAME,    
		A.START_DATE,   
		A.END_DATE,     
		A.ISSCHEDULE,  
		A.SCHEDULED_DATE,   
		A.REQUEST_DATE,     
		A.IsEndBy,       
		A.REQUEST_TYPE,   
		A.JOB_TYPE_NAME,   
		A.JOB_RUN_TYPE,  
		A.JOB_FREQUENCY,  
		A.JOB_PERIOD_SCOPE,   
		A.RecurrencePatternOption,   
		A.TimeZone,   
		A.ScheduledHours,  
		A.ScheduledMinutes,   
		A.ScheduledAMPM,    
		A.IsConfiguredJob,    
		A.IsAllData,       
		A.TotalOccurence,  
		A.PeriodScopeStartDate,    
		A.PeriodScopeEndDate ,  
		A.JOB_VALID_FROM,    
		A.JOB_VALID_THRU, 
		A.ALLOW_END_TO_END_RUN,
		ISNULL(@main_column,'') as Main_Column, ISNULL(@spend_fields,'') as Spend_Field, ISNULL(@date_fields,'') as Date_Field,   
		ISNULL(@spend_displayname,'') as Spend_DisplayName , ISNULL(@date_displayname,'') as Date_DisplayName,
		A.PARENT_JOB_ID,
		CAST((CASE WHEN @JobId IS NOT NULL THEN @HasStepForMainTable ELSE 0 END) AS BIT) AS HasStepForMainTable
	FROM [SPEND_DL_SA_ACIVITYWORKMASTER]   A       
	--full JOIN SSDL.UM_UserPartnerMapping UPM     ON A.CREATED_BY = UPM.CONTACTCODE       
	--full JOIN SSDL.UM_Users U                    ON UPM.UserId = U.UserId                  
	WHERE A.JOB_ID = @JobId and A.isdeleted = 0
END
GO
--Save Main Table SP--
DROP Procedure SSDL.MainTable_Save
DROP TYPE SSDL.SPEND_SSDL_TableSchemaTableType

CREATE TYPE SSDL.SPEND_SSDL_TableSchemaTableType AS TABLE
(
ColumnName			varchar(255) UNIQUE NOT NULL,
DisplayColumnName		varchar(255),
FieldCategory				varchar(255),
DataTypeId			tinyint NOT NULL,
ColumnDataLength		varchar(255),
IsInputField    BIT,
IsPrimaryKey    BIT
)
GO

CREATE PROCEDURE SSDL.MainTable_Save
    (

    @MainTableColumnsDetails  SSDL.SPEND_SSDL_TableSchemaTableType READONLY,
    @TableName VARCHAR(255) = NULL,
    @PartnerCode BIGINT
)
AS
BEGIN
    DECLARE @MainTableId INT;
    DECLARE @MainTableName VARCHAR(255);
    DECLARE @TableTypeId INT;
    DECLARE @TableId INT;
    
    SELECT @TableTypeId = Table_Typ_Id
    FROM SSDL.SPEND_DCC_TABLE_TYP_MST
    WHERE TABLE_TYP_CODE = '101'
    SELECT @MainTableName = TABLENAME
    FROM SSDL.SPEND_SSDL_Table
    WHERE TABLENAME = @TableName
    
    IF NOT EXISTS (SELECT TABLENAME
    FROM SSDL.SPEND_SSDL_Table
    WHERE TABLENAME = @TableName )
        BEGIN
        INSERT INTO SSDL.SPEND_SSDL_TABLE
            (TableTypeID, TableName, IsActive, CreatedBy, CreatedDate, LastUpdatedBy, LastUpdatedDate)
        VALUES(@TableTypeId, @TableName, 1, @PartnerCode, GETDATE(), @PartnerCode, GETDATE())
    END
    

     IF  EXISTS (SELECT TABLENAME
    FROM SSDL.SPEND_SSDL_Table
    WHERE TABLENAME = @TableName )
    BEGIN
        SELECT @TableId = TableId
        FROM SSDL.SPEND_SSDL_Table
        WHERE TABLENAME = @TableName and TableTypeID = @TableTypeId
    END
    IF @TableId is not null
    BEGIN
        INSERT INTO 
        SSDL.SPEND_SSDL_TableSchema
            (TableID,ColumnName,DisplayColumnName,FieldCategory,
            DataTypeID,CreatedBy,CreatedDate,LastUpdatedBy,
            LastUpdatedDate,IsInputField,IsPrimaryKey)
        (SELECT @TableId, T1.ColumnName, T1.DisplayColumnName, T1.FieldCategory,
            T1.DataTypeID, @PartnerCode, GETDATE(), @PartnerCode, GETDATE(), T1.IsInputField,T1.IsPrimaryKey
        FROM @MainTableColumnsDetails T1
        LEFT JOIN SSDL.SPEND_SSDL_TableSchema T2 ON T1.ColumnName = T2.ColumnName and T2.TableID = @TableId
        WHERE T2.TableSchemaID is null
        )
    END

END
