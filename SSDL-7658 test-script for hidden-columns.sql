CREATE TABLE SSDL.MainTableColumnsMasterAccessControlLink
(
	Id BIGINT IDENTITY (1, 1) PRIMARY KEY,
	ColumnName varchar(255) NOT NULL,
    ActivityId INT,
    StageId INT,
    EventId INT,
	AccessControlEnumCode VARCHAR(255) NOT NULL,
	ScreenName VARCHAR(1000) NOT NULL,
    CreatedBy bigint NOT NULL,
	CreatedDate datetime NOT NULL,
	LastUpdatedBy bigint NOT NULL,
	LastUpdatedDate datetime NOT NULL,
    CONSTRAINT UK_MainTableColumnsMasterAccessControlLink UNIQUE(ColumnName, ActivityId, StageId, EventId, AccessControlEnumCode, ScreenName)
)

TRUNCATE TABLE SSDL.MainTableColumnsMasterAccessControlLink

INSERT INTO SSDL.MainTableColumnsMasterAccessControlLink(ColumnName, ActivityId, StageId, EventId, AccessControlEnumCode, ScreenName, CreatedBy, CreatedDate, LastUpdatedBy, LastUpdatedDate)
VALUES
('UNIQUEID', 2200, 2220, NULL, 'HideOnUI', 'MovingToMainStep', 1, GETDATE(), 1, GETDATE()),
('UNIQUEID', 7700, NULL, NULL, 'HideOnUI', 'MapFieldsToUpdate', 1, GETDATE(), 1, GETDATE()),
('MODIFIED_DATE', 2200, 2220, NULL, 'HideOnUI', 'MovingToMainStep', 1, GETDATE(), 1, GETDATE()),
('MODIFIED_DATE', 7700, NULL, NULL, 'HideOnUI', 'MapFieldsToUpdate', 1, GETDATE(), 1, GETDATE()),
('GEP_JOB_ID', 2200, 2220, NULL, 'HideOnUI', 'MovingToMainStep', 1, GETDATE(), 1, GETDATE()),
('GEP_JOB_ID', 7700, NULL, NULL, 'HideOnUI', 'MapFieldsToUpdate', 1, GETDATE(), 1, GETDATE()),
('GEP_JOB_NAME', 2200, 2220, NULL, 'HideOnUI', 'MovingToMainStep', 1, GETDATE(), 1, GETDATE()),
('GEP_JOB_NAME', 7700, NULL, NULL, 'HideOnUI', 'MapFieldsToUpdate', 1, GETDATE(), 1, GETDATE()),
('GEP_RULE_ID', 2200, 2220, NULL, 'HideOnUI', 'MovingToMainStep', 1, GETDATE(), 1, GETDATE()),
('GEP_RULE_ID', 7700, NULL, NULL, 'HideOnUI', 'MapFieldsToUpdate', 1, GETDATE(), 1, GETDATE()),
('CREATED_DATE', 2200, 2220, NULL, 'HideOnUI', 'MovingToMainStep', 1, GETDATE(), 1, GETDATE()),
('CREATED_DATE', 7700, NULL, NULL, 'HideOnUI', 'MapFieldsToUpdate', 1, GETDATE(), 1, GETDATE()),
('GEP_DATAID', 2200, 2220, NULL, 'HideOnUI', 'MovingToMainStep', 1, GETDATE(), 1, GETDATE()),
('GEP_DATAID', 7700, NULL, NULL, 'HideOnUI', 'MapFieldsToUpdate', 1, GETDATE(), 1, GETDATE());

GO

EXEC SSDL.TableSchema_GetByTableId 1

GO

alter PROCEDURE SSDL.MainTableColumns_GetByParams
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

	SELECT A.ColumnName, A.ActivityId, A.StageId, A.EventId, A.AccessControlEnumCode, A.ScreenName
	FROM SSDL.MainTableColumnsMasterAccessControlLink A
	JOIN SSDL.MainTableColumnsMaster B ON A.ColumnName = B.ColumnName
END

GO

alter PROCEDURE SSDL.TableSchema_GetByTableId
(  
	@TableId INT  
)  
AS  
BEGIN  
	--API 2  
	--Get the table columns along  
	DECLARE @InternalTableId INT;
	DECLARE @TableTypeCode TINYINT;

	SET @InternalTableId = @TableId;

	SELECT @TableTypeCode = TABLE_TYP_CODE
	FROM SSDL.SPEND_DCC_TABLE_TYP_MST
	WHERE TABLE_TYP_ID = (SELECT TableTypeId FROM SSDL.SPEND_SSDL_Table WHERE TableID = @TableId);

	IF @TableTypeCode IN (102, 103)
	BEGIN
		SELECT
		 T2.TableId,
		 T3.TableSchemaId,
		 T3.ColumnName,
		 T3.DisplayColumnName,
		 T4.DATA_TYP_ID AS DataTypeId,
		 categ.Name AS DataTypeCategory
		FROM SSDL.SPEND_SSDL_TABLE T2
		INNER JOIN SSDL.SPEND_SSDL_TABLESCHEMA T3 ON T2.TABLEID = T3.TABLEID AND T2.ISACTIVE = 1
		INNER JOIN SSDL.SPEND_DCC_TABLE_DATA_TYP_MST T4 ON T3.DATATYPEID = T4.DATA_TYP_ID
		INNER JOIN SSDL.SPEND_SSDL_DataTypeCategory categ ON categ.DataTypeCategoryId = T4.Data_Type_Category_Id
		LEFT JOIN SSDL.RefEnumValue REVCS ON REVCS.Id = T3.ColumnScopeRefEnumValueId
		WHERE T2.TableId = @InternalTableId AND (REVCS.Id IS NULL OR (REVCS.Code = 'General' OR REVCS.Code = 'ImportExportOnly')) AND T3.IsUsedInProject = 1;
	END
	ELSE
	BEGIN
		SELECT
			@InternalTableId AS TableId,
			A.TableSchemaID,
			A.ColumnName,
			A.DisplayColumnName,
			A.DataTypeID,
			categ.Name AS DataTypeCategory
		FROM SSDL.SPEND_SSDL_TableSchema A
		INNER JOIN SSDL.SPEND_DCC_TABLE_DATA_TYP_MST T4 ON A.DATATYPEID = T4.DATA_TYP_ID AND A.TableID = @InternalTableId
		INNER JOIN SSDL.SPEND_SSDL_DataTypeCategory categ ON categ.DataTypeCategoryId = T4.Data_Type_Category_Id
		LEFT JOIN SSDL.MainTableColumnsMaster D ON A.ColumnName IS NOT NULL AND A.ColumnName = D.ColumnName
		WHERE (A.ColumnName IS NOT NULL
			AND (
				(D.ColumnName IS NOT NULL AND D.ColumnVisibilityScopeEnumCode = 'ShowOnProjectSetupWorkflowUtilities')
				OR A.FieldCategory = 'ERP - Custom Fields'
			)
		)
		
		SELECT A.ColumnName, A.ActivityId, A.StageId, A.EventId, A.AccessControlEnumCode, A.ScreenName
		FROM SSDL.MainTableColumnsMasterAccessControlLink A
		JOIN SSDL.MainTableColumnsMaster B ON A.ColumnName = B.ColumnName
	END
END
