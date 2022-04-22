DECLARE @DatabaseNamePattern VARCHAR(500);
DECLARE @DatabaseName VARCHAR(500);

SET @DatabaseNamePattern = 'UAT[_]%[_]SSDL'
SET @DatabaseName = DB_NAME(); --UAT_VONAGE_SSDL

DECLARE @MainTableName VARCHAR(255);
DECLARE @OpsMainTableId INT;
DECLARE @MainTableTypeId INT;

SET @MainTableName = 'OPS_MAIN'
SELECT @MainTableTypeId = Table_TYP_ID FROM SSDL.SPEND_DCC_TABLE_TYP_MST where Table_TYP_code = 101
SELECT @OpsMainTableId = TableId FROM SSDL.SPEND_SSDL_TABLE WHERE TableTypeID = @MainTableTypeId AND TableName = @MainTableName;

DECLARE @ErrorMessage NVARCHAR(MAX)
DECLARE @ErrorSeverity NVARCHAR(20)
DECLARE @ErrorState NVARCHAR(20)

DECLARE @MainTableColumnsMaster AS TABLE
(
   ColumnName VARCHAR(255) NOT NULL UNIQUE
  ,DisplayColumnName VARCHAR(255)
  ,FieldCategory VARCHAR(255)
  ,DataType VARCHAR(50)
  ,ColumnDataLength VARCHAR(50)
  ,IsInputField BIT
  ,IsPrimaryKey BIT
  ,ColumnVisibilityScopeEnumCode VARCHAR(255)
  ,IsSelectionMandatory BIT
  ,FieldDefinition VARCHAR (255)
  ,IsBasicColumn BIT
);

INSERT INTO @MainTableColumnsMaster(ColumnName,DisplayColumnName,FieldCategory,DataType,ColumnDataLength,IsInputField,IsPrimaryKey,ColumnVisibilityScopeEnumCode,IsSelectionMandatory,FieldDefinition,IsBasicColumn) VALUES
 ('GEP_DATAID','GEP DATA ID','GEP - Admin - ID','bigint',NULL,0,1,'ShowOnProjectSetupWorkflowUtilities',1,NULL,0)
,('UNIQUEID','Unique ID','GEP - Admin - ID','nvarchar','1000',0,0,'ShowOnProjectSetupWorkflowUtilities',1,'Source Table DataID + Source File Name + Source Record Entry Date',0)
,('INVOICE_DOCUMENT_TYPE','Invoice Document Type','ERP - Invoice - Document','nvarchar','255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,'SAP Doc Type',0)
,('INVOICE_POSTING_KEY','Invoice Posting Key','ERP - Invoice - Document','nvarchar','255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,'SAP Pos Key',0)
,('INVOICE_DOCUMENT_NUMBER','Invoice Document Number','ERP - Invoice - Document','nvarchar','255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,'ERP Invoice Number',0)
,('INVOICE_NUMBER','Invoice Number','ERP - Invoice - Document','nvarchar','255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,'Vendor Invoice Number',1)
,('INVOICE_LINE_NUMBER','Invoice Line Number','ERP - Invoice - Document','nvarchar','255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,1)
,('INVOICE_DISTRIBUTION_LINE_NUMBER','Invoice Line Distribution number','ERP - Invoice - Document','nvarchar','255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('INVOICE_NUMBER_2','Invoice Number 2','ERP - Invoice - Document','nvarchar','255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('INVOICE_NUMBER_3','Invoice Number 3','ERP - Invoice - Document','nvarchar','255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('INVOICE_VOUCHER_NUMBER','Invoice Voucher Number','ERP - Invoice - Document','nvarchar','255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,'Journal ID',0)
,('INVOICE_VOUCHER_LINE_NUMBER','Invoice Voucher Line Number','ERP - Invoice - Document','nvarchar','255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('INVOICE_JOURNAL_NUMBER','Invoice Journal Number','ERP - Invoice - Document','nvarchar','255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('INVOICE_LINE_TYPE','Invoice Line Type','ERP - Invoice - Document','nvarchar','255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,'Tax, VAT,',0)
,('INVOICE_PAYMENT_METHOD','Invoice Payment Method','ERP - Invoice - Document','nvarchar','255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,'WireTr, EFT,',0)
,('INVOICE_CREATION_DATE','Invoice Creation Date','ERP - Invoice - Period','date',NULL,1,0,'ShowOnProjectSetupWorkflowUtilities',0,'By Supplier, Billed Dt',0)
,('INVOICE_RECEIPT_DATE','Invoice Receipt Date','ERP - Invoice - Period','date',NULL,1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('INVOICE_PERIOD_ID','Invoice Period ID','ERP - Invoice - Period','nvarchar','255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('INVOICE_POSTING_DATE','Invoice Posted Date','ERP - Invoice - Period','date',NULL,1,0,'ShowOnProjectSetupWorkflowUtilities',0,'Entered in ERP',0)
,('INVOICE_ACCOUNTING_DATE','Invoice Accounting Date','ERP - Invoice - Period','date',NULL,1,0,'ShowOnProjectSetupWorkflowUtilities',0,'GL Date',0)
,('INVOICE_PAID_DATE','Invoice Paid Date','ERP - Invoice - Period','date',NULL,1,0,'ShowOnProjectSetupWorkflowUtilities',0,'Card Pymt Dt',1)
,('INVOICE_LINE_AMOUNT_NORMALIZED','Invoice Line Amount Normalized','ERP - Invoice - Amount','float',NULL,1,0,'ShowOnProjectSetupWorkflowUtilities',0,'USD or EUR',1)
,('PO_UNIT_PRICE_LOCAL','PO Unit Price Local','ERP - PO','float',NULL,1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('INVOICE_LINE_AMOUNT_CURRENCY','Invoice Line Amount Currency','ERP - Invoice - Amount','nvarchar','255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,'Currency',0)
,('INVOICE_DEBIT_CREDIT_INDICATOR','Invoice Debit Credit Indicator','ERP - Invoice - Amount','nvarchar','255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('INVOICE_UNIT_PRICE_NORMALIZED','Invoice Unit Price Normalized','ERP - Invoice - Amount','float',NULL,1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('INVOICE_LINE_AMOUNT_LOCAL','Invoice Line Amount Local','ERP - Invoice - Amount','float',NULL,1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('INVOICE_UNIT_PRICE_CURRENCY','Invoice Unit Price Currency','ERP - Invoice - Amount','nvarchar','255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('INVOICE_QUANTITY','Invoice Quantity','ERP - Invoice - Amount','float',NULL,1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('INVOICE_UOM','Invoice UOM','ERP - Invoice - Amount','nvarchar','255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('INVOICE_LINE_DESCRIPTION','Invoice Description','ERP - Invoice - Document','nvarchar','255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,1)
,('INVOICE_LINE_DESCRIPTION_2','Invoice Description 2','ERP - Invoice - Document','nvarchar','255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('INVOICE_CREATED_BY','Invoice Created By','ERP - Invoice - Document','nvarchar','255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,'Keyer',0)
,('INVOICE_APPROVED_BY','Invoice Approved By','ERP - Invoice - Document','nvarchar','255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,'Approver',0)
,('INVOICE_LANGUAGE_KEY','Invoice Language','ERP - Invoice - Document','nvarchar','255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,'If in SAP',0)
,('INVOICE_STATUS','Invoice Status','ERP - Invoice - Document','nvarchar','255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('INVOICE_TYPE','Invoice Type','ERP - Invoice - Document','nvarchar','255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,'Credit Memo, Void Payments',0)
,('SHIPPING_CODE','Shipping Code','ERP - Miscellaneous','nvarchar','255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('SHIPPING_MODE_TYPE','Shipping Mode Type','ERP - Miscellaneous','nvarchar','255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,'Air, Ocean',0)
,('SHIPPING_TYPE','Shipping Type','ERP - Miscellaneous','nvarchar','255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,'Inbound, Outbound',0)
,('INVOICE_DIRECT_INDIRECT_INDICATOR','Direct Indirect Indicator','ERP - Miscellaneous','nvarchar','255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('CAPEX_OPEX_INDICATOR','Capex Opex Indicator','ERP - Miscellaneous','nvarchar','255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('DOMESTIC_INTERNALTIONAL_INDICATOR','Domestic International Indicator','ERP - Miscellaneous','nvarchar','255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('GEP_NORM_INVOICE_UNIT_PRICE_USD','GEP Normalized Invoice Unit Price (USD)','GEP - Amount','float',NULL,0,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('GEP_NORM_INVOICE_UNIT_PRICE_EUR','GEP Normalized Invoice Unit Price (EUR)','GEP - Amount','float',NULL,0,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('GEP_NORM_INVOICE_QUANTITY','GEP Normalized Invoice Quanity','GEP - Amount','float',NULL,0,0,'ShowOnProjectSetupWorkflowUtilities',0,'Convert to Standard UOM',0)
,('GEP_NORM_INVOICE_UOM','GEP Normalized Invoice UOM','GEP - Amount','nvarchar','255',0,0,'ShowOnProjectSetupWorkflowUtilities',0,'Convert to Standard UOM',0)
,('EXCH_MONTH','GEP Currency Exchange Month','GEP - Amount','nvarchar','255',0,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('EXCH_YEAR','GEP Currency Exchange Year','GEP - Amount','nvarchar','255',0,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('EXCH_RATE','GEP Currency Exchange Rate','GEP - Amount','float',NULL,0,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('GEP_NORM_SPEND_USD','GEP Normalized Spend (USD)','GEP - Amount','float',NULL,0,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,1)
,('GEP_NORM_SPEND_USD_WITHOUT_TAX','GEP Normalized Spend (USD) Without Tax','GEP - Amount','float',NULL,0,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('GEP_NORM_SPEND_EUR','GEP Normalized Spend (EUR)','GEP - Amount','float',NULL,0,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('GEP_NORM_SPEND_EUR_WITHOUT_TAX','GEP Normalized Spend (EUR) Without Tax','GEP - Amount','float',NULL,0,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('GEP_NORM_SPEND_GBP','GEP Normalized Spend (GBP)','GEP - Amount','float',NULL,0,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('GEP_NORM_SPEND_AUD','GEP Normalized Spend (AUD)','GEP - Amount','float',NULL,0,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('GEP_NORM_SPEND_CAD','GEP Normalized Spend (CAD)','GEP - Amount','float',NULL,0,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('GEP_NORM_SPEND_CNY','GEP Normalized Spend (CNY)','GEP - Amount','float',NULL,0,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('GEP_NORM_SPEND_JPY','GEP Normalized Spend (JPY)','GEP - Amount','float',NULL,0,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('GEP_NORM_SPEND_CHF','GEP Normalized Spend (CHF)','GEP - Amount','float',NULL,0,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('GEP_NORM_SPEND_MXN','GEP Normalized Spend (MXN)','GEP - Amount','float',NULL,0,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('GEP_NORM_SPEND_NOK','GEP Normalized Spend (NOK)','GEP - Amount','float',NULL,0,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('GEP_NORMALIZED_PO_UNIT_PRICE_USD','GEP Normalized PO Unit Price (USD)','GEP - Amount','float',NULL,0,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('GEP_NORMALIZED_PO_UNIT_PRICE_EUR','GEP Normalized PO Unit Price (EUR)','GEP - Amount','float',NULL,0,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('GEP_NORM_DATE','GEP Normalized Date','GEP - Period','date',NULL,0,0,'ShowOnProjectSetupWorkflowUtilities',1,NULL,0)
,('CREATED_DATE','Record Entry Date','GEP - Admin - ID','datetime',NULL,0,0,'ShowOnProjectSetupWorkflowUtilities',1,NULL,0)
,('MODIFIED_DATE','Record Modified Date','GEP - Admin - ID','datetime',NULL,0,0,'ShowOnProjectSetupWorkflowUtilities',1,NULL,0)
,('GEP_SUPP_CLUSTER','GEP Vendor Normalization Cluster ID','GEP - Admin - Maintenance','bigint',NULL,0,0,'ShowOnProjectSetupWorkflowUtilities',1,NULL,0)
,('GEP_CLN_CLUSTER','GEP Classification Cluster ID','GEP - Admin - Maintenance','bigint',NULL,0,0,'ShowOnProjectSetupWorkflowUtilities',1,NULL,0)
,('GEP_BU_CLUSTER','GEP BU Cluster ID','GEP - Admin - Maintenance','bigint',NULL,0,0,'ShowOnProjectSetupWorkflowUtilities',1,NULL,0)
,('GEP_EXCLUDE','GEP Exclude','GEP - Admin - Maintenance','boolean',NULL,0,0,'ShowOnProjectSetupWorkflowUtilities',1,NULL,0)
,('GEP_EXCLUSION_COMMENTS','GEP Exclusion Comments','GEP - Admin - Maintenance','nvarchar','500',0,0,'ShowOnProjectSetupWorkflowUtilities',1,NULL,0)
,('GEP_EXCLUSION_CRITERIA','GEP Exclusion Criteria','GEP - Admin - Maintenance','nvarchar','255',0,0,'ShowOnProjectSetupWorkflowUtilities',1,'OOR date, Intercompany',0)
,('GEP_TRANSLATED_SUPP_NAME','GEP Translated Supplier Name','GEP - Admin - Maintenance','nvarchar','255',0,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('GEP_TRANSLATED_INVOICE_LINE_DESCRIPTION','GEP Translated Invoice Description','GEP - Admin - Maintenance','nvarchar','255',0,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('GEP_TRANSLATED_PO_DESCRIPTION','GEP Translated PO Description','GEP - Admin - Maintenance','nvarchar','255',0,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('GEP_TRANSLATED_MATERIAL_DESCRIPTION','GEP Translated Material Description','GEP - Admin - Maintenance','nvarchar','255',0,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('GEP_TRANSLATED_DESCRIPTION_2','GEP Translated Description 2','GEP - Admin - Maintenance','nvarchar','255',0,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('GEP_ACTUAL_PAYMENT_TERM_DAYS','GEP Actual Payment Term Days','GEP - Payment Term','float',NULL,0,0,'ShowOnProjectSetupWorkflowUtilities',0,'Paid Date - Posted Date',0)
,('GEP_PO_AVG_UNIT_PRICE','GEP PO Average Unit Price','GEP - Miscellaneous','float',NULL,0,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('GEP_ONE_TIME_SUPP_FLAG','GEP One Time Vendor Flag','GEP - Miscellaneous','nvarchar','255',0,0,'ShowOnProjectSetupWorkflowUtilities',1,NULL,0)
,('GEP_ONE_ITEM_MULTI_SUPP_FLAG','GEP One Item Multiple Supplier Flag','GEP - Miscellaneous','nvarchar','255',0,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('GEP_ONE_SUPP_MULTI_BU_FLAG','GEP One Supplier Multiple BU Flag','GEP - Miscellaneous','nvarchar','255',0,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('GEP_ONE_SUPP_MULTI_PAYTERM_FLAG','GEP One Supplier Multiple Payment Term Flag','GEP - Miscellaneous','nvarchar','255',0,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('GEP_SUPP_SPEND_TOP_BUCKET','GEP Supplier Spend Top Bucket','GEP - Miscellaneous','nvarchar','255',0,0,'ShowOnProjectSetupWorkflowUtilities',1,'Top 80, 80-95',0)
,('GEP_SUPP_SPEND_BUCKET','GEP Supplier Spend Bucket','GEP - Miscellaneous','nvarchar','255',0,0,'ShowOnProjectSetupWorkflowUtilities',1,'>1M, 500K-1M,�',0)
,('GEP_INV_SPEND_BUCKET','GEP Invoice Spend Bucket','GEP - Miscellaneous','nvarchar','255',0,0,'ShowOnProjectSetupWorkflowUtilities',0,'Top 80, 80-95',0)
,('GEP_PO_SPEND_BUCKET','GEP PO Spend Bucket','GEP - Miscellaneous','nvarchar','255',0,0,'ShowOnProjectSetupWorkflowUtilities',0,'Top 80, 80-95',0)
,('GEP_PAYTERM_BUCKET','GEP Invoice Payment Term Days Bucket','GEP - Payment Term','nvarchar','255',0,0,'ShowOnProjectSetupWorkflowUtilities',0,'0-10, 10-30, 30-60',0)
,('GEP_TRANS_BUCKET','GEP Transaction Spend Bucket','GEP - Miscellaneous','nvarchar','255',0,0,'ShowOnProjectSetupWorkflowUtilities',1,'Top 80, 80-95',0)
,('GEP_PRIORITY','GEP CF Priority Bucket','GEP - Admin - Maintenance','nvarchar','255',0,0,'ShowOnProjectSetupWorkflowUtilities',1,'CF priority bucket',0)
,('GEP_QA_FLAG_VNE','GEP VNE QA Flag','GEP - Admin - Maintenance','nvarchar','255',0,0,'ShowOnProjectSetupWorkflowUtilities',0,'QA Completed, QA Pending',0)
,('GEP_QA_FLAG_CF','GEP CF QA Flag','GEP - Admin - Maintenance','nvarchar','255',0,0,'ShowOnProjectSetupWorkflowUtilities',1,'QA Completed, QA Pending',0)
,('GEP_QA_FLAG_OTH','GEP QA Flag Other','GEP - Admin - Maintenance','nvarchar','255',0,0,'ShowOnProjectSetupWorkflowUtilities',0,'QA for other than CF and VNE, like BU',0)
,('GEP_SLA_FLAG_VNE','GEP VNE SLA Flag','GEP - Admin - Maintenance','nvarchar','255',0,0,'ShowOnProjectSetupWorkflowUtilities',0,'SLA sampling pass, SLA sampling fail, Not part of SLA sample',0)
,('GEP_SLA_FLAG_CF','GEP CF SLA Flag','GEP - Admin - Maintenance','nvarchar','255',0,0,'ShowOnProjectSetupWorkflowUtilities',0,'SLA sampling pass, SLA sampling fail, Not part of SLA sample',0)
,('GEP_AI_SOURCE_CF','GEP Classification Source','GEP - Admin - Maintenance','nvarchar','255',0,0,'ShowOnProjectSetupWorkflowUtilities',1,'RULE - CLIENT, RULE - GEP, AI- DATA LAKE, AI - PROJECT',0)
,('GEP_AI_ALGO_VNE','GEP VNE AI Algorithm','GEP - Admin - Maintenance','nvarchar','255',0,0,'ShowOnProjectSetupWorkflowUtilities',0,'ML1, ML2, etc.',0)
,('GEP_AI_ALGO_CF','GEP CF AI Algorithm','GEP - Admin - Maintenance','nvarchar','255',0,0,'ShowOnProjectSetupWorkflowUtilities',0,'ML1, ML2, etc.',0)
,('GEP_FEEDBACK_FLAG','GEP CF Feedback Flag','GEP - Admin - Maintenance','nvarchar','255',0,0,'ShowOnProjectSetupWorkflowUtilities',0,'If Part of CF Feedbacks',0)
,('GEP_VNE_FEEDBACK_FLAG','GEP VNE Feedback Flag','GEP - Admin - Maintenance','nvarchar','255',0,0,'ShowOnProjectSetupWorkflowUtilities',0,'If Part of VNE Feedbacks',0)
,('GEP_VNE_SOURCE','GEP Supplier Normalization Method L1','GEP - Admin - Maintenance','nvarchar','255',0,0,'ShowOnProjectSetupWorkflowUtilities',1,'Manual, QA, AI, Rules, Historical',0)
,('GEP_VNE_SOURCE_2','GEP Supplier Normalization Method L2','GEP - Admin - Maintenance','nvarchar','255',0,0,'ShowOnProjectSetupWorkflowUtilities',1,'RULE - NEW, RULE - OLD, AI- HIGH , AI - MEDIUM, AI - LOW',0)
,('GEP_VNE_HISTORICAL_FLAG','GEP Supplier Normalization Historical Flag','GEP - Admin - Maintenance','nvarchar','255',0,0,'ShowOnProjectSetupWorkflowUtilities',1,'HISTORICAL, NOT HISTORICAL',0)
,('GEP_UP_STATUS_FLAG','GEP Parent Linkage Status Flag','GEP - Admin - Maintenance','nvarchar','255',0,0,'ShowOnProjectSetupWorkflowUtilities',1,'COMPLETED, TO REVIEW, TO PROCESS',0)
,('GEP_UP_SOURCE','GEP Parent Linkage Method L1','GEP - Admin - Maintenance','nvarchar','255',0,0,'ShowOnProjectSetupWorkflowUtilities',1,'Rules, AI, Manual',0)
,('GEP_UP_SOURCE_2','GEP Parent Linkage Method L2','GEP - Admin - Maintenance','nvarchar','255',0,0,'ShowOnProjectSetupWorkflowUtilities',1,'RULE - NEW, RULE - OLD, AI- HIGH , AI - MEDIUM, AI - LOW',0)
,('GEP_UP_HISTORICAL_FLAG','GEP Parent Linkage Historical Flag','GEP - Admin - Maintenance','nvarchar','255',0,0,'ShowOnProjectSetupWorkflowUtilities',1,'HISTORICAL, NOT HISTORICAL',0)
,('GEP_CF_SOURCE','GEP Classification Method L1','GEP - Admin - Maintenance','nvarchar','255',0,0,'ShowOnProjectSetupWorkflowUtilities',1,'Rules, AI, Manual',0)
,('GEP_CF_SOURCE_2','GEP Classification Method L2','GEP - Admin - Maintenance','nvarchar','255',0,0,'ShowOnProjectSetupWorkflowUtilities',1,'RULE - NEW, RULE - OLD, AI- HIGH , AI - MEDIUM, AI - LOW',0)
,('GEP_CF_HISTORICAL_FLAG','GEP Classification Historical Flag','GEP - Admin - Maintenance','nvarchar','255',0,0,'ShowOnProjectSetupWorkflowUtilities',1,'HISTORICAL, NOT HISTORICAL',0)
,('GEP_JOB_ID','GEP Job ID','GEP - Admin - Maintenance','bigint',NULL,0,0,'ShowOnProjectSetupWorkflowUtilities',1,'ID of the Job',0)
,('GEP_JOB_NAME','GEP Job Name','GEP - Admin - Maintenance','nvarchar','255',0,0,'ShowOnProjectSetupWorkflowUtilities',1,'Name of the Job in the UI',0)
,('GEP_COMMENTS','GEP Comments','GEP - Miscellaneous','nvarchar','255',0,0,'ShowOnProjectSetupWorkflowUtilities',1,NULL,0)
,('GEP_DUPLICATE_KEY_FLAG','GEP Duplicate (Key) Flag','GEP - Admin - Maintenance','nvarchar','255',0,0,'ShowOnProjectSetupWorkflowUtilities',1,NULL,0)
,('GEP_DUPLICATE_KEY_ID','GEP Duplicate (key) ID','GEP - Admin - Maintenance','nvarchar','255',0,0,'ShowOnProjectSetupWorkflowUtilities',1,NULL,0)
,('GEP_DUPLICATE_ALL_FLAG','GEP Duplicate (All) Flag','GEP - Admin - Maintenance','nvarchar','255',0,0,'ShowOnProjectSetupWorkflowUtilities',1,NULL,0)
,('GEP_DUPLICATE_ALL_ID','GEP Duplicate (All) ID','GEP - Admin - Maintenance','nvarchar','255',0,0,'ShowOnProjectSetupWorkflowUtilities',1,NULL,0)
,('GEP_RULE_ID','GEP Rule ID (Classification)','GEP - Admin - Maintenance','bigint',NULL,0,0,'ShowOnProjectSetupWorkflowUtilities',1,NULL,0)
,('GEP_RULE_ID_VNE','GEP Rule ID (Vendor Normalization)','GEP - Admin - Maintenance','nvarchar','255',0,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('GEP_RULE_ID_OTHER','GEP Rule ID (Other)','GEP - Admin - Maintenance','bigint',NULL,0,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('RULE_PROVIDER','GEP Rule Provider (Classification)','GEP - Admin - Maintenance','nvarchar','255',0,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('RULE_SOURCE','GEP Rule Source (Classification)','GEP - Admin - Maintenance','nvarchar','255',0,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('RULE_TYPE_NAME','GEP Rule Type','GEP - Admin - Maintenance','nvarchar','255',0,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('GEP_CF_STATUS_FLAG','GEP Classification Status Flag','GEP - Admin - Maintenance','nvarchar','255',0,0,'ShowOnProjectSetupWorkflowUtilities',1,'COMPLETED, TO REVIEW, TO PROCESS',0)
,('GEP_VNE_STATUS_FLAG','GEP Supplier Normalization Status Flag','GEP - Admin - Maintenance','nvarchar','255',0,0,'ShowOnProjectSetupWorkflowUtilities',1,'All Steps Completed. VNE Delivery Status - COMPLETED, TO REVIEW, TO PROCESS',0)
,('GEP_CONFIDENCE_FLAG','GEP Confidence Flag','GEP - Admin - Maintenance','nvarchar','255',0,0,'ShowOnProjectSetupWorkflowUtilities',0,'Both CF and VNE Completed Status',0)
,('GEP_DELIVERY_STATUS','GEP Delivery Status Flag','GEP - Admin - Maintenance','nvarchar','255',0,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('GEP_CF_USER','GEP CF User','GEP - Admin - Maintenance','nvarchar','255',0,0,'ShowOnProjectSetupWorkflowUtilities',1,'User who processed Manual or CF QA',0)
,('GEP_VNE_USER','GEP VNE User','GEP - Admin - Maintenance','nvarchar','255',0,0,'ShowOnProjectSetupWorkflowUtilities',0,'User who processed Manual or VNE QA',0)
,('GEP_AI_DL_CATEGORY_L1','GEP AI DL Category L1','GEP - Admin - Data Lake','nvarchar','255',0,0,'ShowOnProjectSetupWorkflowUtilities',1,'Cold Start Run 1',0)
,('GEP_AI_DL_CATEGORY_L2','GEP AI DL Category L2','GEP - Admin - Data Lake','nvarchar','255',0,0,'ShowOnProjectSetupWorkflowUtilities',1,'Cold Start Run 1',0)
,('GEP_AI_DL_CATEGORY_L3','GEP AI DL Category L3','GEP - Admin - Data Lake','nvarchar','255',0,0,'ShowOnProjectSetupWorkflowUtilities',1,'Cold Start Run 1',0)
,('GEP_AI_DL_CATEGORY_L4','GEP AI DL Category L4','GEP - Admin - Data Lake','nvarchar','255',0,0,'ShowOnProjectSetupWorkflowUtilities',1,'Cold Start Run 1',0)
,('GEP_AI_DL_SUPPLIER_SIC_NAICS','GEP AI DL Supplier SIC NAICS','GEP - Admin - Data Lake','nvarchar','255',0,0,'ShowOnProjectSetupWorkflowUtilities',0,'Cold Start Future Plan',0)
,('GEP_MANAGED_CATEGORY_FLAG','GEP Managed Category','GEP - Miscellaneous','nvarchar','255',0,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('GEP_SOURCING_SCOPE_FLAG','GEP Sourcing Scope','GEP - Miscellaneous','nvarchar','255',0,0,'ShowOnProjectSetupWorkflowUtilities',0,'Global, Nationalized, Local',0)
,('GEP_SOLE_SOURCING_FLAG','GEP Sole Sourcing','GEP - Miscellaneous','nvarchar','255',0,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('GEP_BUYING_CHANNEL','GEP Buying Channel','GEP - Miscellaneous','nvarchar','255',0,0,'ShowOnProjectSetupWorkflowUtilities',0,'Catalog, Card, PO Spot, PO Release',1)
,('GEP_PAYMENT_CHANNEL','GEP Payment Channel','GEP - Miscellaneous','nvarchar','255',0,0,'ShowOnProjectSetupWorkflowUtilities',0,'Card, Wire Transfer, etc',0)
,('GEP_SOURCING_REGION','GEP Sourcing Region','GEP - Miscellaneous','nvarchar','255',0,0,'ShowOnProjectSetupWorkflowUtilities',0,'Domestic, LCCS, HCCS',0)
,('GEP_PO_NON_PO_FLAG','GEP PO Flag','GEP - Miscellaneous','nvarchar','255',0,0,'ShowOnProjectSetupWorkflowUtilities',0,'Off PO, On PO',1)
,('GEP_CONTRACT_FLAG','GEP Contract Flag','GEP - Miscellaneous','nvarchar','255',0,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('GEP_CONFIDENTIAL_FLAG','GEP Confidential Flag','GEP - Miscellaneous','nvarchar','255',0,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('GEP_INTERCOMPANY_FLAG','GEP Intercompany Flag','GEP - Miscellaneous','nvarchar','255',0,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('GEP_DISCONTINUED_FLAG','GEP Discontinued Flag','GEP - Miscellaneous','nvarchar','255',0,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('GEP_CATEGORY_MANAGER_GLOBAL','GEP Category Manager Global','GEP - Miscellaneous','nvarchar','255',0,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('GEP_CATEGORY_MANAGER_REGION','GEP Category Manager Region','GEP - Miscellaneous','nvarchar','255',0,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('INVOICE_UNIT_PRICE_IN_LOCAL_CURRENCY','Invoice Unit Price Local','ERP - Invoice - Amount','float',NULL,1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('BUSINESS_DIVISION','Business Division','ERP - Invoice - BU','nvarchar','255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,'Division',0)
,('DEPARTMENT_CODE','Department Code','ERP - Invoice - BU','nvarchar','255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,'Department',0)
,('DEPARTMENT_DESCRIPTION','Department Description','ERP - Invoice - BU','nvarchar','255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,'Department',0)
,('BUSINESS_UNIT_CODE','Business Unit Code','ERP - Invoice - BU','nvarchar','255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,'Division',1)
,('BUSINESS_UNIT_DESC','Business Unit','ERP - Invoice - BU','nvarchar','255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,'Org Unit, Operating Unit',1)
,('BUSINESS_GROUP_DESC','BU Group','ERP - Invoice - BU','nvarchar','255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,'BU Hierarchy 1',1)
,('BUSINESS_GROUP_DESC_2','BU Group 2','ERP - Invoice - BU','nvarchar','255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,'BU Hierarchy 2',0)
,('BUSINESS_GROUP_DESC_3','BU Group 3','ERP - Invoice - BU','nvarchar','255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,'BU Hierarchy 3',0)
,('BUSINESS_GROUP_DESC_4','BU Group 4','ERP - Invoice - BU','nvarchar','255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,'BU Hierarchy 4',0)
,('BUSINESS_GROUP_DESC_5','BU Group 5','ERP - Invoice - BU','nvarchar','255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,'BU Hierarchy 5',0)
,('BUSINESS_GROUP_DESC_6','BU Group 6','ERP - Invoice - BU','nvarchar','255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,'BU Hierarchy 6',0)
,('GEP_NORM_BUSINESS_UNIT','GEP Normalized Business Unit','GEP - BU','nvarchar','255',0,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('GEP_NORM_BU_LEVEL1','GEP Normalized Business Group Level 1','GEP - BU','nvarchar','255',0,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('GEP_NORM_BU_LEVEL2','GEP Normalized Business Group Level 2','GEP - BU','nvarchar','255',0,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('GEP_NORM_BU_LEVEL3','GEP Normalized Business Group Level 3','GEP - BU','nvarchar','255',0,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('GEP_NORM_BU_LEVEL4','GEP Normalized Business Group Level 4','GEP - BU','nvarchar','255',0,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('COMPANY_CODE','Company Code','ERP - Invoice - BU','nvarchar','255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,1)
,('COMPANY_NAME','Company Name','ERP - Invoice - BU','nvarchar','255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,1)
,('COMPANY_COUNTRY','Company Country','ERP - Invoice - BU','nvarchar','255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,1)
,('COMPANY_REGION','Company Region','ERP - Invoice - BU','nvarchar','255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('GEP_NORM_COMPANY','GEP Normalized Company','GEP - BU','nvarchar','255',0,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('GEP_NORM_COMPANY_COUNTRY','GEP Business Country','GEP - BU Geography','nvarchar','255',0,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('GEP_NORM_COMPANY_SUB_REGION','GEP Business Sub Region','GEP - BU Geography','nvarchar','255',0,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('GEP_NORM_COMPANY_REGION','GEP Business Region','GEP - BU Geography','nvarchar','255',0,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('PLANT_TYPE','Facility Type','ERP - Invoice - BU','nvarchar','255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,'Office, Plant, Store',0)
,('PLANT_CODE','Facility Code','ERP - Invoice - BU','nvarchar','255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,'Plant Code, Ship to Plant',1)
,('PLANT_NAME','Facility Name','ERP - Invoice - BU','nvarchar','255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,'Plant Name',1)
,('PLANT_ADDRESS','Facility Address','ERP - Invoice - BU','nvarchar','255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,'Plant Address',0)
,('PLANT_CITY','Facility City','ERP - Invoice - BU','nvarchar','255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,'Plant City',1)
,('PLANT_STATE','Facility State','ERP - Invoice - BU','nvarchar','255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,'Plant State',0)
,('PLANT_ZIP_CODE','Facility Zip','ERP - Invoice - BU','nvarchar','255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,'Plant Zip',0)
,('PLANT_COUNTRY','Facility Country','ERP - Invoice - BU','nvarchar','255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,'Plant Country',1)
,('PLANT_REGION','Facility Region','ERP - Invoice - BU','nvarchar','255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,'Plant Region',0)
,('GEP_NORM_PLANT_NAME','GEP Normalized Facility','GEP - BU','nvarchar','255',0,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('SUPPLIER_NUMBER','Invoice Supplier Number','ERP - Invoice - Supplier','nvarchar','255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,1)
,('SUPPLIER_NAME','Invoice Supplier Name','ERP - Invoice - Supplier','nvarchar','255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,1)
,('SUPPLIER_ADDRESS','Invoice Supplier Address','ERP - Invoice - Supplier','nvarchar','255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,1)
,('SUPPLIER_CITY','Invoice Supplier City','ERP - Invoice - Supplier','nvarchar','255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,1)
,('SUPPLIER_ZIP_CODE','Invoice Supplier Zip Postal Code','ERP - Invoice - Supplier','nvarchar','255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,1)
,('SUPPLIER_STATE','Invoice Supplier State','ERP - Invoice - Supplier','nvarchar','255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,1)
,('SUPPLIER_COUNTRY','Invoice Supplier Country','ERP - Invoice - Supplier','nvarchar','255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,1)
,('SUPPLIER_PAYTERM_CODE','Supplier Payment Term Code','ERP - Invoice - Supplier','nvarchar','255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('SUPPLIER_PAYTERM_DESC','Supplier Payment Term Desc','ERP - Invoice - Supplier','nvarchar','255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('SUPPLIER_TYPE','Supplier Type','ERP - Invoice - Supplier','nvarchar','255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('SUPPLIER_DIVERSITY_CODE','Supplier Diversity Code','ERP - Invoice - Supplier','nvarchar','255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('SUPPLIER_DUNS_NUMBER','Supplier DUNS Number','ERP - Invoice - Supplier','nvarchar','255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('SUPPLIER_ORIGIN_COUNTRY','Supplier Country of Origin','ERP - Invoice - Supplier','nvarchar','255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('SUPPLIER_DUNS_SSI','Supplier DUNS SSI','ERP - Invoice - Supplier','nvarchar','255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('SUPPLIER_DUNS_SER','Supplier DUNS SER','ERP - Invoice - Supplier','nvarchar','255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('SUPPLIER_DUNS_PAYDEX','Supplier DUNS PAYDEX','ERP - Invoice - Supplier','nvarchar','255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('SUPPLIER_DUNS_GLOBAL_ULTIMATE_COMPANY_NAME','Supplier DUNS Global Ultimate Company','ERP - Invoice - Supplier','nvarchar','255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('SUPPLIER_DUNS_GLOBAL_ULTIMATE_COUNTRY','Supplier DUNS Global Ultimate Country','ERP - Invoice - Supplier','nvarchar','255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('SUPPLIER_PREFERRED_STATUS','Supplier Preferred status','ERP - Miscellaneous','nvarchar','255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('CUSTOMER_SUPPLIER_STATUS','Customer Supplier Status','ERP - Miscellaneous','nvarchar','255',1,0,'ShowOnProjectSetupWorkflowUtilities',1,NULL,0)
,('GEP_DELTAFLAG','GEP CF Delta Flag','GEP - Admin - Maintenance','nvarchar','255',0,0,'ShowOnProjectSetupWorkflowUtilities',0,'Flag new vendors in the latest refresh batch for QA',0)
,('GEP_ENRICHFLAG','GEP VNE Enrich Flag','GEP - Admin - Maintenance','nvarchar','255',0,0,'ShowOnProjectSetupWorkflowUtilities',0,'Parent Enriched through DL, through Web, through D&B Hoovers',0)
,('GEP_NEW_VENDOR_FLAG','GEP New Vendor Flag','GEP - Miscellaneous','nvarchar','255',0,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('GEP_NORM_SUPP_NUMBER','GEP Supplier Number','GEP - Supplier','nvarchar','255',0,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('GEP_NORM_SUPP_NAME','GEP Normalized Supplier','GEP - Supplier','nvarchar','255',0,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,1)
,('GEP_ULT_PARENT','GEP Ultimate Parent','GEP - Supplier','nvarchar','255',0,0,'ShowOnProjectSetupWorkflowUtilities',1,NULL,1)
,('GEP_NORM_SUPP_CITY','GEP Supplier City','GEP - Supplier','nvarchar','255',0,0,'ShowOnProjectSetupWorkflowUtilities',1,NULL,0)
,('GEP_NORM_SUPP_STATE','GEP Supplier State','GEP - Supplier','nvarchar','255',0,0,'ShowOnProjectSetupWorkflowUtilities',1,NULL,0)
,('GEP_NORM_SUPP_COUNTRY','GEP Supplier Country','GEP - Supplier','nvarchar','255',0,0,'ShowOnProjectSetupWorkflowUtilities',1,NULL,0)
,('GEP_NORM_SUPP_SUB_REGION','GEP Supplier Sub Region','GEP - Supplier','nvarchar','255',0,0,'ShowOnProjectSetupWorkflowUtilities',1,NULL,0)
,('GEP_NORM_SUPP_REGION','GEP Supplier Region','GEP - Supplier','nvarchar','255',0,0,'ShowOnProjectSetupWorkflowUtilities',1,NULL,0)
,('GEP_PREFERRED_SUPPLIER_STATUS','GEP Preferred Supplier','GEP - Miscellaneous','nvarchar','255',0,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('GEP_CUSTOMER_SUPPLIER_STATUS','GEP Customer Supplier Flag','GEP - Miscellaneous','nvarchar','255',0,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('GEP_AI_SUPPLIER_LOB','GEP AI DL Supplier LOB','GEP - Admin - Data Lake','nvarchar','255',0,0,'ShowOnProjectSetupWorkflowUtilities',0,'Cold Start Run 1',0)
,('GEP_SUPPLIER_PAYMENT_TERM','GEP Normalized Supplier Payment Term','GEP - Payment Term','nvarchar','255',0,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('GEP_SUPPLIER_NET_DAYS','GEP Supplier Payment Term Net Days','GEP - Payment Term','float',NULL,0,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('GEP_SUPPLIER_DISCOUNT_PERCENTAGE','GEP Supplier Payment Term Discount Percentage','GEP - Payment Term','float',NULL,0,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('GEP_SUPPLIER_DISCOUNT_DAYS','GEP Supplier Payment Term Net Days Discount Adjusted','GEP - Payment Term','float',NULL,0,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('PAYMENT_TERM_CODE','Invoice Payment Term Code','ERP - Invoice - Payment Term','nvarchar','255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('PAYMENT_TERM_DESCRIPTION','Invoice Payment Term Desc','ERP - Invoice - Payment Term','nvarchar','255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,1)
,('GEP_NORM_PAYMENT_TERM','GEP Normalized Invoice Payment Term','GEP - Payment Term','nvarchar','255',0,0,'ShowOnProjectSetupWorkflowUtilities',0,'NET 35 10%',1)
,('GEP_NORM_NET_DAYS','GEP Invoice Payment Term Net Days','GEP - Payment Term','float',NULL,0,0,'ShowOnProjectSetupWorkflowUtilities',0,'35',0)
,('GEP_NORM_DISCOUNT_PERCENTAGE','GEP Invoice Payment Term Discount Percentage','GEP - Payment Term','float',NULL,0,0,'ShowOnProjectSetupWorkflowUtilities',0,'0.1',0)
,('GEP_NORM_DISCOUNT_DAYS','GEP Invoice Payment Term Net Days Discount Adjusted','GEP - Payment Term','float',NULL,0,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('GL_ACCOUNT_CODE','GL Account Code','ERP - Invoice - GL','nvarchar','255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,1)
,('GL_ACCOUNT_NAME','GL Account Name','ERP - Invoice - GL','nvarchar','255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,1)
,('GL_ACCOUNT_HIERARCHY_L1','GL Hierarchy 1','ERP - Invoice - GL','nvarchar','255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('GL_ACCOUNT_HIERARCHY_L2','GL Hierarchy 2','ERP - Invoice - GL','nvarchar','255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('CHART_OF_ACCOUNT_CODE','Chart of Account Code','ERP - Invoice - GL','nvarchar','255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('CHART_OF_ACCOUNT_NAME','Chart of Account Name','ERP - Invoice - GL','nvarchar','255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('COST_CENTER_CODE','Cost Center Code','ERP - Invoice - Cost Center','nvarchar','255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,1)
,('COST_CENTER_DESCRIPTION','Cost Center Name','ERP - Invoice - Cost Center','nvarchar','255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,1)
,('COST_CENTER_HIERARCHY_L1','Cost Center Hierarchy 1','ERP - Invoice - Cost Center','nvarchar','255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('COST_CENTER_HIERARCHY_L2','Cost Center Hierarchy 2','ERP - Invoice - Cost Center','nvarchar','255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('COST_CENTER_HIERARCHY_L3','Cost Center Hierarchy 3','ERP - Invoice - Cost Center','nvarchar','255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('COST_CENTER_HIERARCHY_L4','Cost Center Hierarchy 4','ERP - Invoice - Cost Center','nvarchar','255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('COST_CENTER_HIERARCHY_L5','Cost Center Hierarchy 5','ERP - Invoice - Cost Center','nvarchar','255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('CONTRACT_SOURCE_SYSTEM','Contract Source System','ERP - Contract','nvarchar','255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,'SbG, Ariba',0)
,('CONTRACT_NUMBER','Contract Number','ERP - Contract','nvarchar','255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,1)
,('CONTRACT_LINE_NUMBER','Contract Line Number','ERP - Contract','nvarchar','255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('CONTRACT_AMOUNT','Contract Amount','ERP - Contract','float',NULL,1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,1)
,('CONTRACT_START_DATE','Contract Start Date','ERP - Contract','date',NULL,1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,1)
,('CONTRACT_END_DATE','Contract End Date','ERP - Contract','date',NULL,1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,1)
,('CONTRACT_SUPPLIER_NUMBER','Contract Supplier Number','ERP - Contract','nvarchar','255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('CONTRACT_SUPPLIER_NAME','Contract Supplier Name','ERP - Contract','nvarchar','255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,1)
,('CONTRACT_DESCRIPTION','Contract Description','ERP - Contract','nvarchar','2000',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,1)
,('CONTRACT_DESCRIPTION_2','Contract Description 2','ERP - Contract','nvarchar','2000',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('CONTRACT_CATEGORY_CODE','Contract Category Code','ERP - Contract','nvarchar','255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('CONTRACT_CATEGORY_1','Contract Category 1','ERP - Contract','nvarchar','255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('CONTRACT_CATEGORY_2','Contract Category 2','ERP - Contract','nvarchar','255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('CONTRACT_CATEGORY_3','Contract Category 3','ERP - Contract','nvarchar','255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('CONTRACT_CATEGORY_4','Contract Category 4','ERP - Contract','nvarchar','255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('CONTRACT_OWNER','Contract Owner','ERP - Contract','nvarchar','255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('CONTRACT_STATUS','Contract Status','ERP - Contract','nvarchar','255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('CONTRACT_TYPE','Contract Type','ERP - Contract','nvarchar','255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('CONTRACT_BUSINESS_UNIT','Contract Business Unit','ERP - Contract','nvarchar','255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('CONTRACT_COMPANY','Contract Company','ERP - Contract','nvarchar','255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('CONTRACT_BU_COUNTRY','Contract BU Country','ERP - Contract','nvarchar','255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('CONTRACT_BU_REGION','Contract BU Region','ERP - Contract','nvarchar','255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('CONTRACT_RENEWAL_TYPE','Contract Renewal Type','ERP - Contract','nvarchar','255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('CLIENT_CHILD_SUPPLIER','Client Child Supplier','ERP - Existing Enrichment','nvarchar','255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('CLIENT_PARENT_SUPPLIER','Client Parent Supplier','ERP - Existing Enrichment','nvarchar','255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('CLIENT_CATEGORY_CODE','Client Category Code','ERP - Existing Enrichment','nvarchar','255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('CLIENT_CATEGORY_1','Client Category 1','ERP - Existing Enrichment','nvarchar','255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('CLIENT_CATEGORY_2','Client Category 2','ERP - Existing Enrichment','nvarchar','255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('CLIENT_CATEGORY_3','Client Category 3','ERP - Existing Enrichment','nvarchar','255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('CLIENT_CATEGORY_4','Client Category 4','ERP - Existing Enrichment','nvarchar','255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('GEP_CATEGORY_KEY','GEP Category Key','GEP - Category','nvarchar','255',0,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('GEP_CATEGORY_CODE','GEP Category Code','GEP - Category','nvarchar','255',0,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('GEP_CATEGORY_LEVEL_1','GEP Category Level 1','GEP - Category','nvarchar','255',0,0,'ShowOnProjectSetupWorkflowUtilities',1,NULL,1)
,('GEP_CATEGORY_LEVEL_2','GEP Category Level 2','GEP - Category','nvarchar','255',0,0,'ShowOnProjectSetupWorkflowUtilities',1,NULL,1)
,('GEP_CATEGORY_LEVEL_3','GEP Category Level 3','GEP - Category','nvarchar','255',0,0,'ShowOnProjectSetupWorkflowUtilities',1,NULL,1)
,('GEP_CATEGORY_LEVEL_4','GEP Category Level 4','GEP - Category','nvarchar','255',0,0,'ShowOnProjectSetupWorkflowUtilities',1,NULL,1)
,('GEP_CATEGORY_LEVEL_5','GEP Category Level 5','GEP - Category','nvarchar','255',0,0,'ShowOnProjectSetupWorkflowUtilities',1,NULL,0)
,('GEP_CATEGORY_LEVEL_6','GEP Category Level 6','GEP - Category','nvarchar','255',0,0,'ShowOnProjectSetupWorkflowUtilities',1,NULL,0)
,('GEP_CATEGORY_LEVEL_7','GEP Category Level 7','GEP - Category','nvarchar','255',0,0,'ShowOnProjectSetupWorkflowUtilities',1,NULL,0)
,('GEP_CATEGORY_VERSION','GEP Category Version','GEP - Category','nvarchar','255',0,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('GEP_PRODUCT_SERVICE_FLAG','GEP Product Service Flag','GEP - Category','nvarchar','255',0,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('GEP_DIRECT_INDIRECT_FLAG','GEP Direct Indirect Flag','GEP - Category','nvarchar','255',0,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('GEP_SOURCING_CATEGORY','GEP Sourcing Category','GEP - Category','nvarchar','255',0,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('GEP_MRO_CAPITAL_FLAG','GEP MRO Capital Flag','GEP - Category','nvarchar','255',0,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('GEP_UNSPSC_KEY','GEP UNSPSC Key','GEP - Category','nvarchar','255',0,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('GEP_UNSPSC_CODE','GEP UNSPSC Code','GEP - Category','nvarchar','255',0,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('GEP_UNSPSC_L1_SEGMENT','GEP UNSPSC L1 Segment','GEP - Category','nvarchar','255',0,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('GEP_UNSPSC_L2_FAMILY','GEP UNSPSC L2 Family','GEP - Category','nvarchar','255',0,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('GEP_UNSPSC_L3_CATEGORY','GEP UNSPSC L3 Category','GEP - Category','nvarchar','255',0,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('GEP_UNSPSC_L4_COMMODITY','GEP UNSPSC L4 Commodity','GEP - Category','nvarchar','255',0,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('GEP_UNSPSC_VERSION','GEP UNSPSC Version','GEP - Category','nvarchar','255',0,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('GEP_UNSPSC_STATUS','GEP UNSPSC Status','GEP - Category','nvarchar','255',0,0,'ShowOnProjectSetupWorkflowUtilities',0,'Active',0)
,('PO_SOURCE_SYSTEM','PO Source System','ERP - PO','nvarchar','255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,'SbG, Ariba',0)
,('PO_STATUS','PO Status','ERP - PO','nvarchar','255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,'Draft, Open, Closed',0)
,('PO_TYPE','PO Type','ERP - PO','nvarchar','255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,'Catalog, Blanket',0)
,('PO_DOCUMENT_TYPE','PO Document Type','ERP - PO','nvarchar','255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,'SAP Doc Type',0)
,('PO_NUMBER','PO Number','ERP - Invoice','nvarchar','255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,1)
,('PO_LINE_NUMBER','PO Line Number','ERP - Invoice','nvarchar','255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,1)
,('PO_EXTRA_PO_KEY','PO Number 2','ERP - PO','nvarchar','255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,'Extra PO Key',0)
,('PO_EXTRA_PO_LINE_KEY','PO Number 3','ERP - PO','nvarchar','255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,'Extra PO Line Key',0)
,('PO_DOCUMENT_DATE','PO Date','ERP - PO','date',NULL,1,0,'ShowOnProjectSetupWorkflowUtilities',0,'Order Date',0)
,('PO_COMPANY_CODE','PO Company Code','ERP - PO','nvarchar','255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('PO_COMPANY_NAME','PO Company Name','ERP - PO','nvarchar','255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('PO_LINE_AMOUNT_NORMALIZED','PO Line Amount Normalized','ERP - PO','float',NULL,1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('GEP_CATEGORY_MANAGER_LOCAL','GEP Category Manager Local','GEP - Miscellaneous','nvarchar','255',0,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('PO_LINE_AMOUNT_CURRENCY','PO Line Amount Currency','ERP - PO','nvarchar','255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('PO_OPEN_LINE_AMOUNT_NORMALIZED','PO Open Line Amount Normalized','ERP - PO','float',NULL,1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('PO_LINE_AMOUNT_LOCAL','PO Line Amount Local','ERP - PO','float',NULL,1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('PO_OPEN_LINE_AMOUNT_CURRENCY','PO Open Line Amount Currency','ERP - PO','nvarchar','255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('PO_UNIT_PRICE_NORMALIZED','PO Unit Price Normalized','ERP - PO','float',NULL,1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,1)
,('PO_OPEN_LINE_AMOUNT_LOCAL','PO Open Line Amount Local','ERP - PO','float',NULL,1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('PO_UNIT_PRICE_CURRENCY','PO Unit Price Currency','ERP - PO','nvarchar','255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('PO_PAYMENT_TERM','PO Payment Term','ERP - PO','nvarchar','255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('GEP_NORM_PO_PAYMENT_TERM','GEP Normalized PO Payment Term','GEP - Payment Term','nvarchar','255',0,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('PO_QUANTITY','PO Quantity','ERP - PO','float',NULL,1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,1)
,('PO_QUANTITY_NORMALIZED','GEP Normalized PO Quantity','GEP - Amount','float',NULL,0,0,'ShowOnProjectSetupWorkflowUtilities',0,'Convert to Standard UOM',0)
,('PO_UOM','PO UOM','ERP - PO','nvarchar','255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,1)
,('PO_UOM_NORMALIZED','GEP Normalized PO UOM','GEP - Amount','nvarchar','255',0,0,'ShowOnProjectSetupWorkflowUtilities',0,'Convert to Standard UOM',0)
,('PO_DESCRIPTION_1','PO Description','ERP - PO','nvarchar','2000',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,1)
,('PO_DESCRIPTION_2','PO Description 2','ERP - PO','nvarchar','2000',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('PO_PLANT_CODE','PO Plant Code','ERP - PO','nvarchar','255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,'Plant Code, Ship to Plant',0)
,('PO_PLANT_NAME','PO Plant Name','ERP - PO','nvarchar','255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,'Plant Name',0)
,('PO_PLANT_ADDRESS','PO Plant Address','ERP - PO','nvarchar','255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,'Plant Address',0)
,('PO_PLANT_CITY','PO Plant City','ERP - PO','nvarchar','255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,'Plant City',0)
,('PO_PLANT_STATE','PO Plant State','ERP - PO','nvarchar','255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,'Plant State',0)
,('PO_PLANT_ZIP','PO Plant Zip','ERP - PO','nvarchar','255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,'Plant Zip',0)
,('PO_PLANT_COUNTRY','PO Plant Country','ERP - PO','nvarchar','255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,'Plant Country',0)
,('PO_PLANT_REGION','PO Plant Region','ERP - PO','nvarchar','255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,'Plant Region',0)
,('PO_PLANT_TYPE','PO Plant Type','ERP - PO','nvarchar','255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,'Office, Plant, Store',0)
,('PO_CATALOG_STATUS','PO Catalog','ERP - PO','nvarchar','255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,'Catalog name',0)
,('PO_SUPPLIER_NUMBER','PO Supplier Number','ERP - PO','nvarchar','255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('PO_SUPPLIER_NAME','PO Supplier Name','ERP - PO','nvarchar','255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('PO_BUYER_CODE','PO Buyer Code','ERP - PO','nvarchar','255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('PO_BUYER_NAME','PO Buyer Name','ERP - PO','nvarchar','255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,'Buyer Name',1)
,('PO_PURCHASING_GROUP_CODE','PO Purchasing Group Code','ERP - PO','nvarchar','255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('PO_PURCHASING_GROUP_NAME','PO Purchasing Group Name','ERP - PO','nvarchar','255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,'Cat Mgr',0)
,('PO_PURCHASING_GROUP_NAME_2','PO Purchasing Group Name 2','ERP - PO','nvarchar','255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,'Tower/ Director',0)
,('PO_PURCHASING_ORG_CODE','PO Purchasing Org Code','ERP - PO','nvarchar','255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('PO_PURCHASING_ORG_NAME','PO Purchasing Org Name','ERP - PO','nvarchar','255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('PO_CREATED_BY','PO Created By','ERP - PO','nvarchar','255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('PO_APPROVER','PO Approver','ERP - PO','nvarchar','255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('PO_GL_CODE','PO GL Code','ERP - PO','nvarchar','255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('PO_GL_NAME','PO GL Name','ERP - PO','nvarchar','255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('PO_COST_CENTER_CODE','PO Cost Center Code','ERP - PO','nvarchar','255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('PO_COST_CENTER_NAME','PO Cost Center Name','ERP - PO','nvarchar','255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('PO_LANGUAGE','PO Language','ERP - PO','nvarchar','255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('PO_CATEGORY_CODE','PO Category Code','ERP - PO','nvarchar','255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('PO_CATEGORY_1','PO Category 1','ERP - PO','nvarchar','255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('PO_CATEGORY_2','PO Category 2','ERP - PO','nvarchar','255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('PO_CATEGORY_3','PO Category 3','ERP - PO','nvarchar','255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('PO_CATEGORY_4','PO Category 4','ERP - PO','nvarchar','255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('ITEM_MATERIAL_NUMBER','Material Number','ERP - Item Master','nvarchar','255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,1)
,('ITEM_MATERIAL_REVISION_NUMBER','Material Revision Number','ERP - Item Master','nvarchar','255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('ITEM_MATERIAL_DESCRIPTION','Material Description','ERP - Item Master','nvarchar','255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,1)
,('ITEM_MATERIAL_GROUP_CODE','Material Group Code','ERP - Item Master','nvarchar','255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('ITEM_MATERIAL_GROUP_DESCRIPTION','Material Group Description','ERP - Item Master','nvarchar','255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,1)
,('ITEM_MATERIAL_TYPE','Material Type','ERP - Item Master','nvarchar','255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,'Direct, Indirect',0)
,('ITEM_MANUFACTURER_NAME','Manufacturer Name','ERP - Item Master','nvarchar','255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('ITEM_MANUFACTURER_PART_NUMBER','Manufacturer Part No','ERP - Item Master','nvarchar','255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('ITEM_SUPPLIER_PART_NUMBER','Supplier Part No','ERP - Item Master','nvarchar','255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('ITEM_MATERIAL_CATEGORY_CODE','Material Category Code','ERP - Item Master','nvarchar','255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,'UNSPSC, eClass',0)
,('ITEM_MATERIAL_CATEGORY_1','Material Category L1','ERP - Item Master','nvarchar','255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,'UNSPSC, eClass',0)
,('ITEM_MATERIAL_CATEGORY_2','Material Category L2','ERP - Item Master','nvarchar','255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,'UNSPSC, eClass',0)
,('ITEM_MATERIAL_CATEGORY_3','Material Category L3','ERP - Item Master','nvarchar','255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,'UNSPSC, eClass',0)
,('ITEM_MATERIAL_CATEGORY_4','Material Category L4','ERP - Item Master','nvarchar','255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,'UNSPSC, eClass',0)
,('ITEM_MATERIAL_NAME','Material Name','ERP - Item Master','nvarchar','255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,'Noun, Modifier',0)
,('ITEM_MATERIAL_STOCK_INDICATOR','Material Stock Indicator','ERP - Item Master','nvarchar','255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,'Stocked, Obsolete',0)
,('ITEM_MATERIAL_CRITICALITY','Material Criticality','ERP - Item Master','nvarchar','255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('ITEM_MATERIAL_LEAD_TIME','Material Lead Time','ERP - Item Master','float',NULL,1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('ITEM_MATERIAL_STANDARD_COST','Material Standard Cost','ERP - Item Master','float',NULL,1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('ITEM_MATERIAL_STANDARD_COST_CURRENCY','Material Standard Cost Currency','ERP - Item Master','nvarchar','255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('ITEM_MATERIAL_STANDARD_UOM','Material Standard UOM','ERP - Item Master','nvarchar','255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('ITEM_MATERIAL_STANDARD_COST_DATE','Material Standard Cost Date','ERP - Item Master','date',NULL,1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('ITEM_MATERIAL_BOM_EQUIPMENT','Material BOM Equipment','ERP - Item Master','nvarchar','255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,'Parent Equipment of Part',0)
,('ITEM_MATERIAL_ORIGIN_COUNTRY','Material Origin Country','ERP - Item Master','nvarchar','255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('SOURCESYSTEM_1','Source System 1','ERP - Invoice - Source System','nvarchar','255',1,0,'ShowOnProjectSetupWorkflowUtilities',1,NULL,1)
,('SOURCESYSTEM_2','Source System 2','ERP - Invoice - Source System','nvarchar','255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('SOURCESYSTEM_3','Source System 3','ERP - Invoice - Source System','nvarchar','255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('GEP_NORM_SOURCESYSTEM_1','GEP Source System','GEP - Source System','nvarchar','255',0,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('GEP_NORM_SOURCESYSTEM_2','GEP Source System Level 2','GEP - Source System','nvarchar','255',0,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('GEP_NORM_SOURCESYSTEM_3','GEP Source System Level 3','GEP - Source System','nvarchar','255',0,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('PROFIT_CENTER_CODE','Profit Center Code','ERP - Invoice - Cost Center','nvarchar','255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,'RC code',0)
,('PROFIT_CENTER_NAME','Profit Center Name','ERP - Invoice - Cost Center','nvarchar','255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('PROFIT_CENTER_HIERARCHY_1','Profit Center Hierarchy 1','ERP - Invoice - Cost Center','nvarchar','255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('PROFIT_CENTER_HIERARCHY_2','Profit Center Hierarchy 2','ERP - Invoice - Cost Center','nvarchar','255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('PROFIT_CENTER_HIERARCHY_3','Profit Center Hierarchy 3','ERP - Invoice - Cost Center','nvarchar','255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('PROFIT_CENTER_HIERARCHY_4','Profit Center Hierarchy 4','ERP - Invoice - Cost Center','nvarchar','255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('PROFIT_CENTER_HIERARCHY_5','Profit Center Hierarchy 5','ERP - Invoice - Cost Center','nvarchar','255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('PROFIT_CENTER_HIERARCHY_6','Profit Center Hierarchy 6','ERP - Invoice - Cost Center','nvarchar','255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('INCOTERMS_CODE','Inco Terms Code','ERP - Miscellaneous','nvarchar','255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,'Approver Hier.',0)
,('INCOTERMS_DESCRIPTION','Inco Terms Description','ERP - Miscellaneous','nvarchar','255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,'If in SAP',0)
,('GEP_DIVERSITY_FLAG','GEP Diversity Flag','GEP - Diversity','nvarchar','255',0,0,'ShowOnProjectSetupWorkflowUtilities',0,'Y, N',0)
,('GEP_DIVERSITY_TYPE','GEP Diversity Type','GEP - Diversity','nvarchar','255',0,0,'ShowOnProjectSetupWorkflowUtilities',0,'Combo',0)
,('GEP_DIVERSITY_8A_CERTIFICATION_INDICATOR','GEP Diversity 8a Certification Indicator','GEP - Diversity','nvarchar','255',0,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('GEP_DIVERSITY_AIRPORT_CONCESSION_DISADVANTAGED_BUSINESS_ENTERPRISE_INDICATOR','GEP Diversity Airport Concession Disadvantaged Business Enterprise Indicator','GEP - Diversity','nvarchar','255',0,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('GEP_DIVERSITY_ALASKAN_NATIVE_CORPORATION_INDICATOR','GEP Diversity Alaskan Native Corporation Indicator','GEP - Diversity','nvarchar','255',0,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('GEP_DIVERSITY_CERTIFIED_SMALL_BUSINESS_INDICATOR','GEP Diversity Certified Small Business Indicator','GEP - Diversity','nvarchar','255',0,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('GEP_DIVERSITY_DISABLED_VETERAN_BUSINESS_ENTERPRISE_INDICATOR','GEP Diversity Disabled Veteran Business Enterprise Indicator','GEP - Diversity','nvarchar','255',0,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('GEP_DIVERSITY_DISABLED_OWNED_BUSINESS_INDICATOR','GEP Diversity Disabled Owned Business Indicator','GEP - Diversity','nvarchar','255',0,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('GEP_DIVERSITY_DISADVANTAGED_BUSINESS_ENTERPRISE_INDICATOR','GEP Diversity Disadvantaged Business Enterprise Indicator','GEP - Diversity','nvarchar','255',0,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('GEP_DIVERSITY_DISADVANTAGED_VETERAN_ENTERPRISE_INDICATOR','GEP Diversity Disadvantaged Veteran Enterprise Indicator','GEP - Diversity','nvarchar','255',0,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('GEP_DIVERSITY_HUB_ZONE_CERTIFIED_BUSINESS_INDICATOR','GEP Diversity Hub Zone Certified Business Indicator','GEP - Diversity','nvarchar','255',0,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('GEP_DIVERSITY_LABOR_SURPLUS_AREA_INDICATOR','GEP Diversity Labor Surplus Area Indicator','GEP - Diversity','nvarchar','255',0,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('GEP_DIVERSITY_MINORITY_BUSINESS_ENTERPRISE_INDICATOR','GEP Diversity Minority Business Enterprise Indicator','GEP - Diversity','nvarchar','255',0,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('GEP_DIVERSITY_MINORITY_COLLEGE_INDICATOR','GEP Diversity Minority College Indicator','GEP - Diversity','nvarchar','255',0,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('GEP_DIVERSITY_MINORITY_OWNED_INDICATOR','GEP Diversity Minority Owned Indicator','GEP - Diversity','nvarchar','255',0,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('GEP_DIVERSITY_OUT_OF_BUSINESS_INDICATOR','GEP Diversity Out Of Business Indicator','GEP - Diversity','nvarchar','255',0,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('GEP_DIVERSITY_POLITICAL_DISTRICT','GEP Diversity Political District','GEP - Diversity','nvarchar','255',0,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('GEP_DIVERSITY_SERVICE_DISABLED_VETERAN_OWNED_INDICATOR','GEP Diversity Service Disabled Veteran Owned Indicator','GEP - Diversity','nvarchar','255',0,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('GEP_DIVERSITY_SMALL_BUSINESS_INDICATOR','GEP Diversity Small Business Indicator','GEP - Diversity','nvarchar','255',0,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('GEP_DIVERSITY_SMALL_DISADVANTAGED_BUSINESS_INDICATOR','GEP Diversity Small Disadvantaged Business Indicator','GEP - Diversity','nvarchar','255',0,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('GEP_DIVERSITY_VETERAN_BUSINESS_ENTERPRISE_INDICATOR','GEP Diversity Veteran Business Enterprise Indicator','GEP - Diversity','nvarchar','255',0,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('GEP_DIVERSITY_VETERAN_OWNED_INDICATOR','GEP Diversity Veteran Owned Indicator','GEP - Diversity','nvarchar','255',0,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('GEP_DIVERSITY_VIETNAM_VETERAN_OWNED_INDICATOR','GEP Diversity Vietnam Veteran Owned Indicator','GEP - Diversity','nvarchar','255',0,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('GEP_DIVERSITY_OTHER_VETERAN_OWNED_INDICATOR','GEP Diversity Other Veteran Owned Indicator','GEP - Diversity','nvarchar','255',0,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('GEP_DIVERSITY_WOMAN_OWNED_BUSINESS_ENTERPRISE_INDICATOR','GEP Diversity Woman Owned Business Enterprise Indicator','GEP - Diversity','nvarchar','255',0,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('GEP_DIVERSITY_WOMAN_OWNED_INDICATOR','GEP Diversity Woman Owned Indicator','GEP - Diversity','nvarchar','255',0,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('GEP_DIVERSITY_AFRICAN_AMERICAN_OWNED_INDICATOR','GEP Diversity African American Owned Indicator','GEP - Diversity','nvarchar','255',0,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('GEP_DIVERSITY_ASIAN_PACIFIC_AMERICAN_OWNED_INDICATOR','GEP Diversity Asian Pacific American Owned Indicator','GEP - Diversity','nvarchar','255',0,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('GEP_DIVERSITY_HISPANIC_AMERICAN_OWNED_INDICATOR','GEP Diversity Hispanic American Owned Indicator','GEP - Diversity','nvarchar','255',0,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('GEP_DIVERSITY_NATIVE_AMERICAN_OWNED_INDICATOR','GEP Diversity Native American Owned Indicator','GEP - Diversity','nvarchar','255',0,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('GEP_DIVERSITY_SUBCONTINENT_ASIAN_AMERICAN_OWNED_INDICATOR','GEP Diversity Subcontinent Asian American Owned Indicator','GEP - Diversity','nvarchar','255',0,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('GEP_OTHER_DIVERSITY','GEP Diversity Other','GEP - Diversity','nvarchar','255',0,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('SOURCEFILENAME','Source File Name','GEP - Admin - ID','nvarchar','1000',0,0,'ShowOnProjectSetupWorkflowUtilities',1,'Includes FTP Folder Path, New Tool logic will maintian folder names maintained within Pickup folder',0)
,('GEP_YEAR','GEP Calendar Year','GEP - Period','bigint',NULL,0,0,'ShowOnProjectSetupWorkflowUtilities',1,NULL,0)
,('GEP_QTR','GEP Calendar Quarter','GEP - Period','nvarchar','20',0,0,'ShowOnProjectSetupWorkflowUtilities',1,NULL,0)
,('GEP_MONTH','GEP Calendar Month','GEP - Period','nvarchar','255',0,0,'ShowOnProjectSetupWorkflowUtilities',1,NULL,0)
,('GEP_FISCAL_ID','GEP Fiscal Period ID','GEP - Period','nvarchar','255',0,0,'ShowOnProjectSetupWorkflowUtilities',0,'P1, P2',0)
,('GEP_FISCAL_YEAR','GEP Fiscal Year','GEP - Period','nvarchar','255',0,0,'ShowOnProjectSetupWorkflowUtilities',1,NULL,1)
,('GEP_FISCAL_QTR','GEP Fiscal Quarter','GEP - Period','nvarchar','20',0,0,'ShowOnProjectSetupWorkflowUtilities',1,NULL,1)
,('GEP_FISCAL_MONTH','GEP Fiscal Month','GEP - Period','nvarchar','255',0,0,'ShowOnProjectSetupWorkflowUtilities',1,NULL,1)
,('CARD_HOLDER_ID','Card holder ID','ERP - Corp Card','nvarchar','255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('CARD_HOLDER_NAME','Card holder Name','ERP - Corp Card','nvarchar','255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('MERCHANT_CATEGORY_CODE','Merchant Category Code','ERP - Corp Card','nvarchar','255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('MERCHANT_CATEGORY_CODE_TITLE','Merchant Category Code Title','ERP - Corp Card','nvarchar','255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,1)
,('MERCHANT_CATEGORY_GROUP_CODE','Merchant Category Group Code','ERP - Corp Card','nvarchar','255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('MERCHANT_CATEGORY_GROUP_TITLE','Merchant Category Group Title','ERP - Corp Card','nvarchar','255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('EXPENSE_TYPE','Expense Type','ERP - Corp Card','nvarchar','255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,1)
,('SIC_CODE','SIC Code','ERP - Corp Card','nvarchar','255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('SIC_TITLE','SIC Title','ERP - Corp Card','nvarchar','255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('NAICS_CODE','NAICS Code','ERP - Corp Card','nvarchar','255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('NAICS_TITLE','NAICS Title','ERP - Corp Card','nvarchar','255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('PROJECT_CODE','Project Code','ERP - Miscellaneous','nvarchar','255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('PROJECT_NAME','Project Name','ERP - Miscellaneous','nvarchar','255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('PROJECT_DESC','Project Description','ERP - Miscellaneous','nvarchar','255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('WORK_ORDER_NUMBER','Work Order Number','ERP - Miscellaneous','nvarchar','255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('WORK_ORDER_DESC','Work Order Description','ERP - Miscellaneous','nvarchar','255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('WBS_CODE','WBS Code','ERP - Miscellaneous','nvarchar','255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('WBS_DESC','WBS Description','ERP - Miscellaneous','nvarchar','255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('PRODUCT','Product','ERP - Miscellaneous','nvarchar','255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('PRODUCT_CATEGORY','Product Category','ERP - Miscellaneous','nvarchar','255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('GEP_CONSOLIDATION_DESCRIPTION','GEP Consolidated Description','GEP - Miscellaneous','nvarchar','2000',0,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('REQUISITION_SOURCE_SYSTEM','Requisition Source System','ERP - Requisition','nvarchar','255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('REQUISITION_NUMBER','Requisition Number','ERP - Requisition','nvarchar','255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('REQUISITION_LINE_NUMBER','Requisition Line Number','ERP - Requisition','nvarchar','255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('REQUISITION_SUPPLIER_NUMBER','Requisition Supplier Number','ERP - Requisition','nvarchar','255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('REQUISITION_SUPPLIER_NAME','Requisition Supplier Name','ERP - Requisition','nvarchar','255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('REQUISITION_CREATION_DATE','Requisition Creation Date','ERP - Requisition','date',NULL,1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('REQUISITION_APPROVED_DATE','Requisition Approved Date','ERP - Requisition','date',NULL,1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('REQUISITION_OWNER','Requisition Owner','ERP - Requisition','nvarchar','255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('REQUISITION_AMOUNT','Requisition Amount','ERP - Requisition','float',NULL,1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('REQUISITION_LINE_DESCRIPTION','Requisition Line Description','ERP - Requisition','nvarchar','255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('GR_SOURCE_SYSTEM','Goods Receipt Source System','ERP - Goods Receipt','nvarchar','255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('GR_NUMBER','Goods Receipt Number','ERP - Goods Receipt','nvarchar','255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('GR_LINE_NUMBER','Goods Receipt Line Number','ERP - Goods Receipt','nvarchar','255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('GR_SUPPLIER_NUMBER','Goods Receipt Supplier Number','ERP - Goods Receipt','nvarchar','255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('GR_SUPPLIER_NAME','Goods Receipt Supplier Name','ERP - Goods Receipt','nvarchar','255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('GR_DATE','Goods Receipt Date','ERP - Goods Receipt','date',NULL,1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('GR_LINE_AMOUNT','Goods Receipt Line Amount','ERP - Goods Receipt','float',NULL,1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('GR_UNIT_PRICE','Goods Receipt Unit Price','ERP - Goods Receipt','float',NULL,1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('GR_QUANTITY','Goods Receipt Quantity','ERP - Goods Receipt','float',NULL,1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('GR_UOM','Goods Receipt UoM','ERP - Goods Receipt','nvarchar','255',1,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('IMPORTEXPORTUID1','Import Export Unique ID 1','GEP - System','bigint',NULL,0,0,'HideEverywhere',1,'System Internal field',0)
,('IMPORTEXPORTUID2','Import Export Unique ID 2','GEP - System','bigint',NULL,0,0,'HideEverywhere',1,'System Internal field',0)
,('IMPORTEXPORTUID3','Import Export Unique ID 3','GEP - System','bigint',NULL,0,0,'HideEverywhere',1,'System Internal field',0)
,('IMPORTEXPORTUID4','Import Export Unique ID 4','GEP - System','bigint',NULL,0,0,'HideEverywhere',1,'System Internal field',0)
,('IMPORTEXPORTUID5','Import Export Unique ID 5','GEP - System','bigint',NULL,0,0,'HideEverywhere',1,'System Internal field',0)
,('IMPORTEXPORTUID6','Import Export Unique ID 6','GEP - System','bigint',NULL,0,0,'HideEverywhere',1,'System Internal field',0)
,('IMPORTEXPORTUID7','Import Export Unique ID 7','GEP - System','bigint',NULL,0,0,'HideEverywhere',1,'System Internal field',0)
,('IMPORTEXPORTUID8','Import Export Unique ID 8','GEP - System','bigint',NULL,0,0,'HideEverywhere',1,'System Internal field',0)
,('IMPORTEXPORTUID9','Import Export Unique ID 9','GEP - System','bigint',NULL,0,0,'HideEverywhere',1,'System Internal field',0)
,('IMPORTEXPORTUID10','Import Export Unique ID 10','GEP - System','bigint',NULL,0,0,'HideEverywhere',1,'System Internal field',0)
,('GEP_AI_SOURCE_VNE','GEP Supplier Normalization Source','GEP - Admin - Maintenance','nvarchar','255',0,0,'ShowOnProjectSetupWorkflowUtilities',1,'GEP_SUPP_SPEND_BUCKET',0)
,('GEP_AI_SOURCE_UP','GEP Parent Linkage Source','GEP - Admin - Maintenance','nvarchar','255',0,0,'ShowOnProjectSetupWorkflowUtilities',1,'RULE - CLIENT, RULE - GEP, AI- DATA LAKE, AI - PROJECT',0)
,('GEP_AI_DL_CATEGORY_L5','GEP AI DL Category L5','GEP - Admin - Data Lake','nvarchar','255',0,0,'ShowOnProjectSetupWorkflowUtilities',1,NULL,0)
,('GEP_AI_DL_CATEGORY_L6','GEP AI DL Category L6','GEP - Admin - Data Lake','nvarchar','255',0,0,'ShowOnProjectSetupWorkflowUtilities',1,NULL,0)
,('GEP_AI_DL_CATEGORY_L7','GEP AI DL Category L7','GEP - Admin - Data Lake','nvarchar','255',0,0,'ShowOnProjectSetupWorkflowUtilities',1,NULL,0)
,('GEP_NORM_SPEND_AED','GEP Normalized Spend (AED)','GEP - Amount','float',NULL,0,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0)
,('GEP_NORM_SPEND_INR','GEP Normalized Spend (INR)','GEP - Amount','float',NULL,0,0,'ShowOnProjectSetupWorkflowUtilities',0,NULL,0);

---1. Add missing mandatory columns to OPS_MAIN
IF @DatabaseName LIKE @DatabaseNamePattern AND ISNULL(@OpsMainTableId, 0) <> 0
BEGIN
    BEGIN TRY
        INSERT INTO SSDL.SPEND_SSDL_TableSchema(TableID,ColumnName,DisplayColumnName,FieldCategory,DataTypeID,ColumnDataLength,CreatedBy,CreatedDate,LastUpdatedBy,LastUpdatedDate,IsInputField,IsPrimaryKey,DataFormatID,ColumnScopeRefEnumValueId,IsUsedInProject)
        SELECT
        -- A.*
        @OpsMainTableId,A.ColumnName,A.DisplayColumnName,A.FieldCategory,C.DATA_TYP_ID,A.ColumnDataLength,1 AS CreatedBy,GETDATE() AS CreatedDate,1 AS LastUpdatedBy,GETDATE() AS LastUpdatedDate,A.IsInputField,A.IsPrimaryKey,NULL AS DataFormatID,NULL AS ColumnScopeRefEnumValueId,CAST(1 AS BIT) AS IsUsedInProject
        FROM @MainTableColumnsMaster A
        join ssdl.SPEND_DCC_TABLE_DATA_TYP_MST C on A.DataType = C.DATA_TYP_NAME
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

---2. Make mandatory columns Active in OPS_MAIN if inactive
IF @DatabaseName LIKE @DatabaseNamePattern AND ISNULL(@OpsMainTableId, 0) <> 0
BEGIN
    BEGIN TRY
        UPDATE B
        SET B.IsUsedInProject = CAST(1 AS BIT)
        -- SELECT A.ColumnName, B.IsUsedInProject
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

---3. Remove all inactive unconfigured uncreated custom columns.
IF @DatabaseName LIKE @DatabaseNamePattern AND ISNULL(@OpsMainTableId, 0) <> 0
BEGIN
    BEGIN TRY
        DELETE from SSDL.SPEND_SSDL_TableSchema
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
        UPDATE A
        SET A.IsUsedInProject = 1
        -- SELECT A.TableSchemaId, A.ColumnName
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

---5. Remove all remaining inactive columns and also remove active but uncreated custom columns.
IF @DatabaseName LIKE @DatabaseNamePattern AND ISNULL(@OpsMainTableId, 0) <> 0
BEGIN
    BEGIN TRY
        DELETE FROM SSDL.SPEND_SSDL_TableSchema where TableID = @OpsMainTableId and IsUsedInProject = 0

        DELETE FROM SSDL.SPEND_SSDL_TableSchema where TableID = @OpsMainTableId and IsUsedInProject = 1 and (ColumnName like 'CUSTOM[_]FIELD%' AND DisplayColumnName like 'Custom Field (%')
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

-- 6. Correct data type.
IF @DatabaseName LIKE @DatabaseNamePattern AND ISNULL(@OpsMainTableId, 0) <> 0 AND EXISTS(SELECT TOP 1 1 FROM @MainTableColumnsMaster)
BEGIN
    BEGIN TRY
        UPDATE B
        SET B.DataTypeID = C.DATA_TYP_ID
        -- SELECT A.ColumnName, A.DataType AS correctDataType, N.DATA_TYP_NAME AS IncorrectDataType, B.TableSchemaID, C.DATA_TYP_ID AS CorrectDataTypeID, N.DATA_TYP_ID AS IncorrectDataTypeId
        FROM SSDL.SPEND_SSDL_TableSchema B
        JOIN @MainTableColumnsMaster A ON A.ColumnName = B.ColumnName
        join ssdl.SPEND_DCC_TABLE_DATA_TYP_MST N on B.DataTypeID = N.DATA_TYP_ID
        join ssdl.SPEND_DCC_TABLE_DATA_TYP_MST C on A.DataType = C.DATA_TYP_NAME
        where A.DataType != N.DATA_TYP_NAME and B.TABLEId=@OpsMainTableId
        AND NOT(N.DATA_TYP_NAME = 'bit' AND A.DataType = 'boolean')
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

-- 7. Correct data length.
IF @DatabaseName LIKE @DatabaseNamePattern AND ISNULL(@OpsMainTableId, 0) <> 0 AND EXISTS(SELECT TOP 1 1 FROM @MainTableColumnsMaster)
BEGIN
    BEGIN TRY
        UPDATE B
        SET B.ColumnDataLength = A.ColumnDataLength
        from ssdl.SPEND_SSDL_TableSchema B
        JOIN @MainTableColumnsMaster A on A.ColumnName = B.ColumnName AND B.TableId = @OpsMainTableId
        WHERE B.ColumnDataLength <> A.ColumnDataLength
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

-- 8. Correct display name.
IF @DatabaseName LIKE @DatabaseNamePattern AND ISNULL(@OpsMainTableId, 0) <> 0 AND EXISTS(SELECT TOP 1 1 FROM @MainTableColumnsMaster)
BEGIN
    BEGIN TRY
        UPDATE B
        SET B.DisplayColumnName = A.DisplayColumnName
        from ssdl.SPEND_SSDL_TableSchema B
        JOIN @MainTableColumnsMaster A on A.ColumnName = B.ColumnName
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