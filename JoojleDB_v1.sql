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
	"Picture" varbinary(max),
	"RoleDescription" nvarchar(40) NOT NULL,
	CONSTRAINT "Joojle_PK_User" PRIMARY KEY  CLUSTERED 
	("UserID"),
	)

GO


CREATE TABLE "ProductCategory" (
	"CategoryId" int NOT NULL IDENTITY(1,1),
	"CategoryName" nvarchar(30) NOT NULL,
	CONSTRAINT "Joojle_PK_ProductCategory" PRIMARY KEY  CLUSTERED 
	("CategoryId")
	)
GO

CREATE TABLE "ProductSubCategory" (
	"SubCategoryId" int NOT NULL IDENTITY(1,1),
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
	"ManufactureId" int NOT NULL IDENTITY(1,1),
	"ManufactureIdName" nvarchar(30) NOT NULL,
	CONSTRAINT "Joojle_PK_ManufactureId" PRIMARY KEY  CLUSTERED 
	("ManufactureId")
	)
GO

CREATE TABLE "Series" (
	"SeriesId" int NOT NULL IDENTITY(1,1),
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
	"ModelId" int NOT NULL IDENTITY(1,1),
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
	"ModelTypeId" int NOT NULL IDENTITY(1,1),
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
INSERT "ProductSubCategory"("SubCategoryName","CategoryId")  VALUES('Fans',2)
INSERT "ProductSubCategory"("SubCategoryName","CategoryId")  VALUES('Vacuum',2)
INSERT "ProductSubCategory"("SubCategoryName","CategoryId")  VALUES('Toaster',2)
GO
ALTER TABLE "User" CHECK CONSTRAINT ALL
GO

set quoted_identifier on
GO
ALTER TABLE "Manufacture" NOCHECK CONSTRAINT ALL
GO
INSERT "Manufacture"("ManufactureIdName")  VALUES('Bonesless')
INSERT "Manufacture"("ManufactureIdName")  VALUES('JC Stuff')
INSERT "Manufacture"("ManufactureIdName")  VALUES('Kyoto')
INSERT "Manufacture"("ManufactureIdName")  VALUES('Wit Studio')
INSERT "Manufacture"("ManufactureIdName")  VALUES('Mad House')
GO
ALTER TABLE "Manufacture" CHECK CONSTRAINT ALL
GO


set quoted_identifier on
GO
ALTER TABLE "Series" NOCHECK CONSTRAINT ALL
GO
INSERT "Series"("SeriesName", "SubCategoryId", "ManufactureId")  VALUES('AAAA', 1 ,1)
INSERT "Series"("SeriesName", "SubCategoryId", "ManufactureId")  VALUES('SSSS', 1 ,1)
INSERT "Series"("SeriesName", "SubCategoryId", "ManufactureId")  VALUES('BBBB', 2 ,1)
INSERT "Series"("SeriesName", "SubCategoryId", "ManufactureId")  VALUES('CCCC', 2 ,4)
INSERT "Series"("SeriesName", "SubCategoryId", "ManufactureId")  VALUES('DDDD', 2 ,5)
INSERT "Series"("SeriesName", "SubCategoryId", "ManufactureId")  VALUES('EEEE', 3 ,3)
INSERT "Series"("SeriesName", "SubCategoryId", "ManufactureId")  VALUES('FFFF', 3 ,2)
INSERT "Series"("SeriesName", "SubCategoryId", "ManufactureId")  VALUES('GGGG', 3 ,2)
GO
ALTER TABLE "Series" CHECK CONSTRAINT ALL
GO


set quoted_identifier on
GO
ALTER TABLE "Model" NOCHECK CONSTRAINT ALL
GO
INSERT "Model"("ModelName","SeriesId","SubCategoryId","ManufactureId")  VALUES('F1-1150',1,1,1)
INSERT "Model"("ModelName","SeriesId","SubCategoryId","ManufactureId")  VALUES('E9-1150',2,1,1)
INSERT "Model"("ModelName","SeriesId","SubCategoryId","ManufactureId")  VALUES('S3-1350',3,1,1)
INSERT "Model"("ModelName","SeriesId","SubCategoryId","ManufactureId")  VALUES('S4-1545',4,2,5)
INSERT "Model"("ModelName","SeriesId","SubCategoryId","ManufactureId")  VALUES('S5-3462',5,2,3)
INSERT "Model"("ModelName","SeriesId","SubCategoryId","ManufactureId")  VALUES('S1-1642',6,2,4)
INSERT "Model"("ModelName","SeriesId","SubCategoryId","ManufactureId")  VALUES('C4-1560',7,2,2)
INSERT "Model"("ModelName","SeriesId","SubCategoryId","ManufactureId")  VALUES('C3-1560',8,3,1)
GO
ALTER TABLE "Model" CHECK CONSTRAINT ALL
GO


set quoted_identifier on
GO
ALTER TABLE "ModelType" NOCHECK CONSTRAINT ALL
GO
INSERT "ModelType"("UseType","Application","MountingLocation","Accessories","ModelYear","ModelId")  
VALUES('Commercial','Indoor','Roof','With Light',2019,1)
INSERT "ModelType"("UseType","Application","MountingLocation","Accessories","ModelYear","ModelId")  
VALUES('Commercial','Outdoor','Floor','With Light',2018,1)
GO
ALTER TABLE "ModelType" CHECK CONSTRAINT ALL
GO


set quoted_identifier on
GO
ALTER TABLE "SpecFilter" NOCHECK CONSTRAINT ALL
GO

INSERT "SpecFilter"("SubCategoryId","PropertyName",	"MIN", "MAX")  
VALUES(1,'AirFlow',100,10000)
INSERT "SpecFilter"("SubCategoryId","PropertyName",	"MIN", "MAX")  
VALUES(1,'FanSpeed',1,1000)
INSERT "SpecFilter"("SubCategoryId","PropertyName",	"MIN", "MAX")  
VALUES(1,'Power',60,500)
INSERT "SpecFilter"("SubCategoryId","PropertyName",	"MIN", "MAX")  
VALUES(1,'OperatingVoltage',1,500)
INSERT "SpecFilter"("SubCategoryId","PropertyName",	"MIN", "MAX")  
VALUES(1,'NumOfFanSpeed',1,20)
INSERT "SpecFilter"("SubCategoryId","PropertyName",	"MIN", "MAX")  
VALUES(1,'SoundAtMaxSpeed',20,500)
INSERT "SpecFilter"("SubCategoryId","PropertyName",	"MIN", "MAX")  
VALUES(1,'FanSweepDiameter',18,500)
INSERT "SpecFilter"("SubCategoryId","PropertyName",	"MIN", "MAX")  
VALUES(1,'Weight',10,200)
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
GO

ALTER TABLE "ProductTechSpec" CHECK CONSTRAINT ALL
GO

set quoted_identifier on
GO
ALTER TABLE "Product" NOCHECK CONSTRAINT ALL
GO
INSERT "Product"("ProductName", "ModelTypeId","ModelId","SubCategoryId")
VALUES('Honeywell HT-900 TurboForce Air Circulator Fan Black', 1, 1, 1)
INSERT "Product"("ProductName", "ModelTypeId","ModelId","SubCategoryId")
VALUES('Lasko 1843 Remote Control Cyclone Pedestal Fan with Built-in Timer', 2, 1, 1)
INSERT"Product"("ProductName", "ModelTypeId","ModelId","SubCategoryId")
VALUES('Dyson V11 Torque Drive Cordless Vacuum Cleaner', 3, 3, 2)
INSERT"Product"("ProductName", "ModelTypeId","ModelId","SubCategoryId")
VALUES('Eureka NES210 Blaze 3-in-1 Swivel Lightweight Stick Vacuum Cleaner Dark Black', 4, 4, 2)
INSERT"Product"("ProductName", "ModelTypeId","ModelId","SubCategoryId")
VALUES('Calphalon Quartz Heat Countertop Toaster Oven', 5, 5, 3)
INSERT"Product"("ProductName", "ModelTypeId","ModelId","SubCategoryId")
VALUES('Cuisinart CPT-180 Metal Classic 4-Slice toaster', 6, 6, 3)
GO
ALTER TABLE "Product" CHECK CONSTRAINT ALL
GO


