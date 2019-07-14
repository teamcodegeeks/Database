SET NOCOUNT ON
GO

USE master
GO
if exists (select * from sysdatabases where name='Joojle')
		drop database Joojle
Go

DECLARE @device_directory NVARCHAR(520)
SELECT @device_directory = SUBSTRING(filename, 1, CHARINDEX(N'master.mdf', LOWER(filename)) - 1)
FROM master.dbo.sysaltfiles WHERE dbid = 1 AND fileid = 1
select @device_directory

EXECUTE (N'CREATE DATABASE Joojle
  ON PRIMARY (NAME = N''Joojle'', FILENAME = N''' + @device_directory + N'joojlejl.mdf'')
  LOG ON (NAME = N''Joojle_log'',  FILENAME = N''' + @device_directory + N'joojlejl.ldf'')')
Go



set quoted_identifier on
GO

SET DATEFORMAT mdy
GO

USE "Joojle"
GO

select * from sysobjects
if exists (select * from sysobjects where id = object_id('dbo.User') and sysstat & 0xf = 4)
	drop table "dbo"."User"
GO
if exists (select * from sysobjects where id = object_id('dbo.Product') and sysstat & 0xf = 2)
	drop table "dbo"."Product"
GO

if exists (select * from sysobjects where id = object_id('dbo.ProductTechSpec') and sysstat & 0xf = 2)
	drop table "dbo"."ProductTechSpec"
GO
if exists (select * from sysobjects where id = object_id('dbo.SpecFilter') and sysstat & 0xf = 2)
	drop table "dbo"."SpecFilter"
GO
if exists (select * from sysobjects where id = object_id('dbo.ProductSubCategory') and sysstat & 0xf = 2)
	drop table "dbo"."ProductSubCategory"
GO
if exists (select * from sysobjects where id = object_id('dbo.ProductCategory') and sysstat & 0xf = 4)
	drop table "dbo"."ProductCategory"
GO
if exists (select * from sysobjects where id = object_id('dbo.Model') and sysstat & 0xf = 2)
	drop table "dbo"."Model"
GO
if exists (select * from sysobjects where id = object_id('dbo.Series') and sysstat & 0xf = 2)
	drop table "dbo"."Series"
GO
if exists (select * from sysobjects where id = object_id('dbo.ModelType') and sysstat & 0xf = 2)
	drop table "dbo"."ModelType"
GO
if exists (select * from sysobjects where id = object_id('dbo.Manufacture') and sysstat & 0xf = 2)
	drop table "dbo"."Manufacture"
GO


CREATE TABLE "User" (
	"UserID" int NOT NULL IDENTITY(1,1),
	"UserName" nvarchar (20) NOT NULL ,
	"Password" nvarchar (50) NOT NULL,
	"Email" nvarchar (300) NOT NULL,
	"UserRoleId" tinyint NOT NULL,
	"Picture" varchar(1000),
	"RoleDescription" nvarchar(40) NOT NULL,
	CONSTRAINT "Joojle_PK_User" PRIMARY KEY  CLUSTERED 
	("UserID"),
	)

GO


CREATE TABLE "ProductCategory" (
	"CategoryId" int NOT NULL IDENTITY(11,1),
	"CategoryName" nvarchar(30) NOT NULL,
	CONSTRAINT "Joojle_PK_ProductCategory" PRIMARY KEY  CLUSTERED 
	("CategoryId")
	)
GO

CREATE TABLE "ProductSubCategory" (
	"SubCategoryId" int NOT NULL IDENTITY(21,1),
	"SubCategoryName" nvarchar(30) NOT NULL,
	"CategoryId" int NOT NULL,
	CONSTRAINT "Joojle_PK_ProductSubCategory" PRIMARY KEY  CLUSTERED 
	("SubCategoryId"),

	CONSTRAINT "Joojle_FK_Category_SubCategpry" FOREIGN KEY 
	("CategoryId") 
	REFERENCES "dbo"."ProductCategory" 
	("CategoryId")
	)
GO

CREATE TABLE "Manufacture" (
	"ManufactureId" int NOT NULL IDENTITY(101,1),
	"ManufactureIdName" nvarchar(30) NOT NULL,
	CONSTRAINT "Joojle_PK_ManufactureId" PRIMARY KEY  CLUSTERED 
	("ManufactureId")
	)
GO

CREATE TABLE "Series" (
	"SeriesId" int NOT NULL IDENTITY(301,1),
	"SeriesName" nvarchar(30) NOT NULL,
	"SubCategoryId" int NOT NULL,
	"ManufactureId" int NOT NULL,
	CONSTRAINT "Joojle_PK_Series" PRIMARY KEY  CLUSTERED 
	("SeriesId"),
	CONSTRAINT "Joojle_FK_Subcategory_Series" FOREIGN KEY
	("SubCategoryId")
	REFERENCES "dbo"."ProductSubCategory"
	("SubCategoryId"),
	CONSTRAINT "Joojle_FK_Manufacture_Series" FOREIGN KEY 
	("ManufactureId") 
	REFERENCES "dbo"."Manufacture" 
	("ManufactureId")
	)
GO

CREATE TABLE "Model" (
	"ModelId" int NOT NULL IDENTITY(201,1),
	"ModelName" nvarchar(30) NOT NULL,
	"SeriesId" int NOT NULL,
	"SubCategoryId" int NOT NULL,
	"ManufactureId" int NOT NULL,
	CONSTRAINT "Joojle_PK_Model" PRIMARY KEY  CLUSTERED 
	("ModelId"),
	CONSTRAINT "Joojle_FK_Model_Series" FOREIGN KEY 
	("SeriesId")
	REFERENCES "dbo"."Series" 
	("SeriesId"),
	CONSTRAINT "Joojle_FK_Model_Subcatagory" FOREIGN KEY 
	("SubCategoryId") 
	REFERENCES "dbo"."ProductSubCategory" 
	("SubCategoryId")
	)
GO

CREATE TABLE "ModelType" (
	"ModelTypeId" int NOT NULL IDENTITY(401,1),
	"UseType" nvarchar(30) NOT NULL,
	"Application" nvarchar (20) NOT NULL,
	"MountingLocation" nvarchar (20) NOT NULL,
	"Accessories" nvarchar (20) NOT NULL,
	"ModelYear" smallint  NOT NULL,
	"ModelId" int NOT NULL,
	CONSTRAINT "Joojle_PK_ModelTypeDetails" PRIMARY KEY  CLUSTERED 
	("ModelTypeId"),
	CONSTRAINT "Joojle_FK_Model_ModelTypeDetails" FOREIGN KEY 
	("ModelId") 
	REFERENCES "dbo"."Model" 
	("ModelId")
	)
GO



CREATE TABLE "Product" (
	"ProductId" bigint NOT NULL IDENTITY(1,1),
	"ProductName" nvarchar(100) NOT NULL,
	"ModelTypeId" int NOT NULL,
	"ModelId" int NOT NULL,
	"SubCategoryId" int NOT NULL,
	"ImageURL" varchar(1000), 
	CONSTRAINT "Joojle_PK_Product" PRIMARY KEY  CLUSTERED 
	("ProductId"),
	CONSTRAINT "Joojle_FK_Product_Model" FOREIGN KEY 
	("ModelId") 
	REFERENCES "dbo"."Model" 
	("ModelId"),
	CONSTRAINT "Joojle_FK_Product_ModelType" FOREIGN KEY 
	("ModelTypeId") 
	REFERENCES "dbo"."ModelType" 
	("ModelTypeId"),
	CONSTRAINT "Joojle_FK_ProductSubCategory_Model" FOREIGN KEY 
	("SubCategoryId") 
	REFERENCES "dbo"."ProductSubCategory" 
	("SubCategoryId"),
	)
GO




CREATE TABLE "ProductTechSpec" (
	"ProductId" bigint NOT NULL,
	"AirFlow" smallint ,
	"PowerMin" decimal(5,2) ,
	"PowerMax" decimal(5,2)  ,
	"OperatingVoltageMin" smallint ,
	"OperatingVoltageMax" smallint ,
	"FanSpeedMin" smallint ,
	"FanSpeedMax" smallint ,
	"NumOfFanSpeed" tinyint ,
	"SoundAtMaxSpeed" tinyint ,
	"FanSweepDiameter" decimal(5,2),
	"HeightMin" decimal(5,2),
	"HeightMax" decimal(5,2),
	"Weight" decimal(5,2),
	"LevelOfSuction" tinyint,
	"Height" decimal(5,2),
	"MaxRuntime" smallint,
	"LevelOfTemperature" tinyint,
	"Length" decimal(5,2),
	CONSTRAINT "Joojle_FK_ProductTechSpec" FOREIGN KEY
	("ProductId")
	REFERENCES "dbo"."Product"
	("ProductId"),
)
GO


Create TABLE "SpecFilter"(
	"SubCategoryId" int NOT NULL,
	"PropertyName" nvarchar(50) NOT NULL,
	"MIN" int NOT NULL,
	"MAX" int NOT NULL,
	CONSTRAINT "Joojle_FK_SubCatagory_Filter" FOREIGN KEY
	("SubCategoryId")
	REFERENCES "dbo"."ProductSubCategory"
	("SubCategoryId"),
)
GO

set quoted_identifier on
GO
ALTER TABLE "User" NOCHECK CONSTRAINT ALL
GO
INSERT "User"("UserName","Password","Email","UserRoleId","RoleDescription") VALUES('Dean', '123123123', '111111111@gmail.com',1,'Consumers')
INSERT "User"("UserName","Password","Email","UserRoleId","RoleDescription") VALUES('Cass', '123123123', '321321321@gmail.com',2,'Customer')
INSERT "User"("UserName","Password","Email","UserRoleId","RoleDescription") VALUES('Sam', '123123123', '123123123@gmail.com', 1,'Consumers')
INSERT "User"("UserName","Password","Email","UserRoleId","RoleDescription") VALUES('Sama', '123123123', '13434123@gmail.com', 3,'Admin')
INSERT "User"("UserName","Password","Email","UserRoleId","RoleDescription") VALUES('Lana', '123123123', '55342344@gmail.com',3,'Admin')
INSERT "User"("UserName","Password","Email","UserRoleId","RoleDescription") VALUES('Alex', '123123123', '34234232@gmail.com',3,'Admin')
INSERT "User"("UserName","Password","Email","UserRoleId","RoleDescription") VALUES('Sakura', '123123123', '54231231@gmail.com', 2,'Customer')
INSERT "User"("UserName","Password","Email","UserRoleId","RoleDescription") VALUES('Karma', '123123123', 'AAAAAAA@gmail.com',1,'Consumers')
INSERT "User"("UserName","Password","Email","UserRoleId","RoleDescription") VALUES('Panda', '123123123', 'BBBBBBB@gmail.com',2,'Customer')
GO
ALTER TABLE "User" CHECK CONSTRAINT ALL
GO


set quoted_identifier on
GO
ALTER TABLE "ProductCategory" NOCHECK CONSTRAINT ALL
GO
INSERT "ProductCategory"("CategoryName")  VALUES('Mechanical')
INSERT "ProductCategory"("CategoryName")  VALUES('Electrical')
INSERT "ProductCategory"("CategoryName")  VALUES('Stationary')
INSERT "ProductCategory"("CategoryName")  VALUES('Furniture')
GO
ALTER TABLE "User" CHECK CONSTRAINT ALL
GO

set quoted_identifier on
GO
ALTER TABLE "ProductSubCategory" NOCHECK CONSTRAINT ALL
GO
INSERT "ProductSubCategory"("SubCategoryName","CategoryId")  VALUES('Fans',12)
INSERT "ProductSubCategory"("SubCategoryName","CategoryId")  VALUES('Vacuum',12)
INSERT "ProductSubCategory"("SubCategoryName","CategoryId")  VALUES('Toaster',12)
GO
ALTER TABLE "User" CHECK CONSTRAINT ALL
GO

set quoted_identifier on
GO
ALTER TABLE "Manufacture" NOCHECK CONSTRAINT ALL
GO
INSERT "Manufacture"("ManufactureIdName")  VALUES('HoneyWell')
INSERT "Manufacture"("ManufactureIdName")  VALUES('Lasko')
INSERT "Manufacture"("ManufactureIdName")  VALUES('Dyson')
INSERT "Manufacture"("ManufactureIdName")  VALUES('Eureka')
INSERT "Manufacture"("ManufactureIdName")  VALUES('Caplhalon')
INSERT "Manufacture"("ManufactureIdName")  VALUES('Cuisinart')
GO
ALTER TABLE "Manufacture" CHECK CONSTRAINT ALL
GO


set quoted_identifier on
GO
ALTER TABLE "Series" NOCHECK CONSTRAINT ALL
GO
INSERT "Series"("SeriesName", "SubCategoryId", "ManufactureId")  VALUES('TurboForce', 21 ,101)
INSERT "Series"("SeriesName", "SubCategoryId", "ManufactureId")  VALUES('Cyclone', 21 ,102)
INSERT "Series"("SeriesName", "SubCategoryId", "ManufactureId")  VALUES('Table', 22 ,101)
INSERT "Series"("SeriesName", "SubCategoryId", "ManufactureId")  VALUES('Swivel', 22 ,104)
INSERT "Series"("SeriesName", "SubCategoryId", "ManufactureId")  VALUES('TorqueSQ', 22 ,103)
INSERT "Series"("SeriesName", "SubCategoryId", "ManufactureId")  VALUES('Quartz', 23 ,105)
INSERT "Series"("SeriesName", "SubCategoryId", "ManufactureId")  VALUES('Cyclone', 23 ,102)
INSERT "Series"("SeriesName", "SubCategoryId", "ManufactureId")  VALUES('CPT', 23 ,106)
GO
ALTER TABLE "Series" CHECK CONSTRAINT ALL
GO


set quoted_identifier on
GO
ALTER TABLE "Model" NOCHECK CONSTRAINT ALL
GO
INSERT "Model"("ModelName","SeriesId","SubCategoryId","ManufactureId")  VALUES('F1-1150',301,21,101)
INSERT "Model"("ModelName","SeriesId","SubCategoryId","ManufactureId")  VALUES('E9-1150',306,23,105)
INSERT "Model"("ModelName","SeriesId","SubCategoryId","ManufactureId")  VALUES('S3-1350',303,22,101)
INSERT "Model"("ModelName","SeriesId","SubCategoryId","ManufactureId")  VALUES('S4-1545',304,22,104)
INSERT "Model"("ModelName","SeriesId","SubCategoryId","ManufactureId")  VALUES('S5-3462',305,22,103)
INSERT "Model"("ModelName","SeriesId","SubCategoryId","ManufactureId")  VALUES('S1-1642',308,23,106)
INSERT "Model"("ModelName","SeriesId","SubCategoryId","ManufactureId")  VALUES('C4-1560',302,21,102)
INSERT "Model"("ModelName","SeriesId","SubCategoryId","ManufactureId")  VALUES('C3-1560',308,23,101)
GO
ALTER TABLE "Model" CHECK CONSTRAINT ALL
GO


set quoted_identifier on
GO
ALTER TABLE "ModelType" NOCHECK CONSTRAINT ALL
GO
INSERT "ModelType"("UseType","Application","MountingLocation","Accessories","ModelYear","ModelId")  
VALUES('Commercial','Indoor','Roof','With Light',2019,201)
INSERT "ModelType"("UseType","Application","MountingLocation","Accessories","ModelYear","ModelId")  
VALUES('Commercial','Outdoor','Floor','Remote',2018,201)
INSERT "ModelType"("UseType","Application","MountingLocation","Accessories","ModelYear","ModelId")  
VALUES('Commercial','Indoor','Floor','Cleaner Head',2017,205)
INSERT "ModelType"("UseType","Application","MountingLocation","Accessories","ModelYear","ModelId")  
VALUES('Commercial','Indoor','Floor','Charger',2016,204)
INSERT "ModelType"("UseType","Application","MountingLocation","Accessories","ModelYear","ModelId")  
VALUES('Kitchen','Indoor','','Sandwhich Cage',2019,202)
INSERT "ModelType"("UseType","Application","MountingLocation","Accessories","ModelYear","ModelId")  
VALUES('Kitchen','Indoor','','Toaster Lever',2016,206)
GO
ALTER TABLE "ModelType" CHECK CONSTRAINT ALL
GO


set quoted_identifier on
GO
ALTER TABLE "SpecFilter" NOCHECK CONSTRAINT ALL
GO

INSERT "SpecFilter"("SubCategoryId","PropertyName",	"MIN", "MAX")  
VALUES(21,'AirFlow',100,10000)
INSERT "SpecFilter"("SubCategoryId","PropertyName",	"MIN", "MAX")  
VALUES(21,'FanSpeed',1,1000)
INSERT "SpecFilter"("SubCategoryId","PropertyName",	"MIN", "MAX")  
VALUES(21,'Power',60,500)
INSERT "SpecFilter"("SubCategoryId","PropertyName",	"MIN", "MAX")  
VALUES(21,'OperatingVoltage',1,500)
INSERT "SpecFilter"("SubCategoryId","PropertyName",	"MIN", "MAX")  
VALUES(21,'NumOfFanSpeed',1,20)
INSERT "SpecFilter"("SubCategoryId","PropertyName",	"MIN", "MAX")  
VALUES(21,'SoundAtMaxSpeed',20,500)
INSERT "SpecFilter"("SubCategoryId","PropertyName",	"MIN", "MAX")  
VALUES(21,'FanSweepDiameter',18,500)
INSERT "SpecFilter"("SubCategoryId","PropertyName",	"MIN", "MAX")  
VALUES(21,'Weight',10,200)
INSERT "SpecFilter"("SubCategoryId","PropertyName",	"MIN", "MAX")  
VALUES(22,'OperatingVoltage',90,150)
INSERT "SpecFilter"("SubCategoryId","PropertyName",	"MIN", "MAX")  
VALUES(22,'LevelOfSuction',1,5)
INSERT "SpecFilter"("SubCategoryId","PropertyName",	"MIN", "MAX")  
VALUES(22,'Height',10,15)
INSERT "SpecFilter"("SubCategoryId","PropertyName",	"MIN", "MAX")  
VALUES(23,'OperatingVoltage',100,150)
INSERT "SpecFilter"("SubCategoryId","PropertyName",	"MIN", "MAX")  
VALUES(23,'Weight',30,90)
ALTER TABLE "SpecFilter" CHECK CONSTRAINT ALL
GO

set quoted_identifier on
GO
ALTER TABLE "ProductTechSpec" NOCHECK CONSTRAINT ALL
GO
INSERT "ProductTechSpec"("ProductId", "AirFlow", "PowerMin","PowerMax","OperatingVoltageMin","OperatingVoltageMax",
                 "FanSpeedMin","FanSpeedMax","NumOfFanSpeed","SoundAtMaxSpeed","FanSweepDiameter","HeightMin","HeightMax",
				 "Weight")
VALUES(1, 5467, 1.95, 21.14, 100, 240, 35, 200, 7, 35, 60, 12.3, 57, 13)
INSERT "ProductTechSpec"("ProductId", "AirFlow", "PowerMin","PowerMax","OperatingVoltageMin","OperatingVoltageMax",
                 "FanSpeedMin","FanSpeedMax","NumOfFanSpeed","SoundAtMaxSpeed","FanSweepDiameter","HeightMin","HeightMax",
				 "Weight")
VALUES(2, 4000, 1.45, 18.14, 100, 240, 35, 380, 3, 30, 50, 10.2, 53, 11)
INSERT "ProductTechSpec"("ProductId", "AirFlow", "PowerMin","PowerMax","OperatingVoltageMin","OperatingVoltageMax",
                 "FanSpeedMin","FanSpeedMax","NumOfFanSpeed","SoundAtMaxSpeed","FanSweepDiameter","HeightMin","HeightMax",
				 "Weight")
VALUES(3, 3000, 1.45, 18.14, 100, 240, 35, 380, 3, 30, 50, 10.2, 53, 11)
INSERT "ProductTechSpec"("ProductId", "AirFlow", "PowerMin","PowerMax","OperatingVoltageMin","OperatingVoltageMax"
						,"HeightMin","HeightMax", "Weight","LevelOfSuction","Height","MaxRuntime")
VALUES(3, 100, 1.45, 8.14, 100, 230, 10.2, 53, 11, 3, 12, 10)
INSERT "ProductTechSpec"("ProductId", "AirFlow", "PowerMin","PowerMax","OperatingVoltageMin","OperatingVoltageMax"
						,"HeightMin","HeightMax", "Weight","LevelOfSuction","Height","MaxRuntime")
VALUES(4, 500, 1.2, 17, 120, 220, 15, 20,20, 2, 13,12)
INSERT "ProductTechSpec"("ProductId", "PowerMin","PowerMax","OperatingVoltageMin","OperatingVoltageMax","Weight")
VALUES(5, 1, 15, 110, 120, 35)
INSERT "ProductTechSpec"("ProductId", "PowerMin","PowerMax","OperatingVoltageMin","OperatingVoltageMax","Weight")
VALUES(6, 1.5, 12, 100, 120, 40)

GO

ALTER TABLE "ProductTechSpec" CHECK CONSTRAINT ALL
GO

set quoted_identifier on
GO
ALTER TABLE "Product" NOCHECK CONSTRAINT ALL
GO
INSERT "Product"("ProductName", "ModelTypeId","ModelId","SubCategoryId")
VALUES('Honeywell HT-900 TurboForce Air Circulator Fan Black',401,201,21)
INSERT "Product"("ProductName", "ModelTypeId","ModelId","SubCategoryId")
VALUES('Lasko 1843 Remote Control Cyclone Pedestal Fan with Built-in Timer',402,207,21)
INSERT"Product"("ProductName", "ModelTypeId","ModelId","SubCategoryId")
VALUES('Dyson V11 Torque Drive Cordless Vacuum Cleaner',403,205, 22)
INSERT"Product"("ProductName", "ModelTypeId","ModelId","SubCategoryId")
VALUES('Eureka NES210 Blaze 3-in-1 Swivel Lightweight Stick Vacuum Cleaner Dark Black', 404,204,22)
INSERT"Product"("ProductName", "ModelTypeId","ModelId","SubCategoryId")
VALUES('Calphalon Quartz Heat Countertop Toaster Oven',405,202,23)
INSERT"Product"("ProductName", "ModelTypeId","ModelId","SubCategoryId")
VALUES('Cuisinart CPT-180 Metal Classic 4-Slice toaster',406,206, 23)
GO
ALTER TABLE "Product" CHECK CONSTRAINT ALL
GO
