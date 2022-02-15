create table SSDL.MainTableColumnsMaster
(
	ID  INT IDENTITY (1, 1)  PRIMARY KEY,
	ColumnName varchar(255) NOT NULL,
	DisplayColumnName varchar(255),
	FieldCategory varchar(255),
	DataTypeID tinyint NOT NULL,
    ColumnDataLength varchar(50),
    IsInputField bit,
	ColumnScopeEnum varchar (255),
	FieldDefinition VARCHAR (255),
	IsBasicColumn  bit,
    CreatedBy bigint NOT NULL,
	CreatedDate datetime NOT NULL,
	LastUpdatedBy bigint NOT NULL,
	LastUpdatedDate datetime NOT NULL,
)


alter table SSDL.SPEND_SSDL_TableSchema 
Add ColumnScopeEnum varchar(255)

alter table SSDL.SPEND_SSDL_TableSchema 
Alter Column ColumnName varchar(255) NOT NULL

alter table SSDL.SPEND_SSDL_TableSchema 
Alter Column DisplayColumnName varchar(255) NULL