SET NOCOUNT ON
GO

USE master
GO
if exists (select * from sysdatabases where name='Joojle')
		drop database Joole
Go

DECLARE @device_directory NVARCHAR(520)
SELECT @device_directory = SUBSTRING(filename, 1, CHARINDEX(N'master.mdf', LOWER(filename)) - 1)
FROM master.dbo.sysaltfiles WHERE dbid = 1 AND fileid = 1

EXECUTE (N'CREATE DATABASE Joole
  ON PRIMARY (NAME = N''Joole'', FILENAME = N''' + @device_directory + N'joojlejl.mdf'')
  LOG ON (NAME = N''Joole_log'',  FILENAME = N''' + @device_directory + N'joojlejl.ldf'')')
Go



set quoted_identifier on
GO

SET DATEFORMAT mdy
GO

USE "Joojle"
GO

if exists (select * from sysobjects where id = object_id('dbo.User') and sysstat & 0xf = 4)
	drop table "dbo"."User"
GO
if exists (select * from sysobjects where id = object_id('dbo.UserRole') and sysstat & 0xf = 4)
	drop table "dbo"."UserRole"
GO
if exists (select * from sysobjects where id = object_id('dbo.Product') and sysstat & 0xf = 2)
	drop table "dbo"."Product"
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
if exists (select * from sysobjects where id = object_id('dbo.Manufacture') and sysstat & 0xf = 2)
	drop table "dbo"."Manufacture"
GO
if exists (select * from sysobjects where id = object_id('dbo.ModelDetails') and sysstat & 0xf = 2)
	drop table "dbo"."ModelTypeDetails"
GO


CREATE TABLE "User" (
	"UserID" int NOT NULL ,
	"UserName" nvarchar (20) NOT NULL ,
	"Password" nvarchar (50) NOT NULL,
	"Email" nvarchar (300) NOT NULL,
	"UserRoleId" tinyint NOT NULL,
	"Picture" varbinary(max),
	"RoleDescription" nvarchar(40) NOT NULL,
	CONSTRAINT "Joole_PK_User" PRIMARY KEY  CLUSTERED 
	("UserID"),
	)

GO


CREATE TABLE "ProductCategory" (
	"CategoryId" int NOT NULL,
	"CategoryName" nvarchar(30) NOT NULL,
	CONSTRAINT "Joole_PK_ProductCategory" PRIMARY KEY  CLUSTERED 
	("CategoryId")
	)
GO

CREATE TABLE "ProductSubCategory" (
	"SubCategoryId" int NOT NULL,
	"SubCategoryName" nvarchar(30) NOT NULL,
	"CategoryId" int NOT NULL,
	CONSTRAINT "Joole_PK_ProductSubCategory" PRIMARY KEY  CLUSTERED 
	("SubCategoryId"),

	CONSTRAINT "Joole_FK_Category_SubCategpry" FOREIGN KEY 
	("CategoryId") 
	REFERENCES "dbo"."ProductCategory" 
	("CategoryId")
	)
GO

CREATE TABLE "Manufacture" (
	"ManufactureId" int NOT NULL,
	"ManufactureIdName" nvarchar(30) NOT NULL,
	CONSTRAINT "Joole_PK_ManufactureId" PRIMARY KEY  CLUSTERED 
	("ManufactureId")
	)
GO

CREATE TABLE "Series" (
	"SeriesId" int NOT NULL,
	"SeriesName" nvarchar(30) NOT NULL,
	"SubCategoryId" int NOT NULL,
	"ManufactureId" int NOT NULL,
	CONSTRAINT "Joole_PK_Series" PRIMARY KEY  CLUSTERED 
	("SeriesId"),
	CONSTRAINT "Joole_FK_Subcategory_Series" FOREIGN KEY
	("SubCategoryId")
	REFERENCES "dbo"."ProductSubCategory"
	("SubCategoryId"),
	CONSTRAINT "Joole_FK_Manufacture_Series" FOREIGN KEY 
	("ManufactureId") 
	REFERENCES "dbo"."Manufacture" 
	("ManufactureId")
	)
GO

CREATE TABLE "Model" (
	"ModelId" int NOT NULL,
	"ModelName" nvarchar(30) NOT NULL,
	"SeriesId" int NOT NULL,
	"SubCategoryId" int NOT NULL,
	"ManufactureId" int NOT NULL,
	CONSTRAINT "Joole_PK_Model" PRIMARY KEY  CLUSTERED 
	("ModelId"),
	CONSTRAINT "Joole_FK_Model_Series" FOREIGN KEY 
	("SeriesId")
	REFERENCES "dbo"."Series" 
	("SeriesId"),
	CONSTRAINT "Joole_FK_Model_Subcatagory" FOREIGN KEY 
	("SubCategoryId") 
	REFERENCES "dbo"."ProductSubCategory" 
	("SubCategoryId")
	)
GO

CREATE TABLE "ModelType" (
	"ModelTypeId" int NOT NULL,
	"UseType" nvarchar(30) NOT NULL,
	"Application" nvarchar (20) NOT NULL,
	"MountingLocation" nvarchar (20) NOT NULL,
	"Accessories" nvarchar (20) NOT NULL,
	"ModelYear" smallint  NOT NULL,
	"ModelId" int NOT NULL,
	CONSTRAINT "Joole_PK_ModelTypeDetails" PRIMARY KEY  CLUSTERED 
	("ModelTypeId"),
	CONSTRAINT "Joole_FK_Model_ModelTypeDetails" FOREIGN KEY 
	("ModelId") 
	REFERENCES "dbo"."Model" 
	("ModelId")
	)
GO




CREATE TABLE "Product" (
	"ProductId" bigint NOT NULL,
	"ProductName" nvarchar(100) NOT NULL,
	"ModelTypeId" int NOT NULL,
	"ModelId" int NOT NULL,
	"SubCategoryId" int NOT NULL,
	CONSTRAINT "Joole_PK_Product" PRIMARY KEY  CLUSTERED 
	("ProductId"),
	CONSTRAINT "Joole_FK_Product_Model" FOREIGN KEY 
	("ModelId") 
	REFERENCES "dbo"."Model" 
	("ModelId"),
	CONSTRAINT "Joole_FK_Product_ModelType" FOREIGN KEY 
	("ModelTypeId") 
	REFERENCES "dbo"."ModelType" 
	("ModelTypeId"),
	CONSTRAINT "Joole_FK_ProductSubCategory_Model" FOREIGN KEY 
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
	CONSTRAINT "Joole_FK_FanDescription" FOREIGN KEY
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
	CONSTRAINT "Joole_FK_SubCatagory_Filter" FOREIGN KEY
	("SubCategoryId")
	REFERENCES "dbo"."ProductSubCategory"
	("SubCategoryId"),
)
GO



set quoted_identifier on
GO
ALTER TABLE "User" NOCHECK CONSTRAINT ALL
GO
INSERT "User"("UserID","UserName","Password","Email","UserRoleId","RoleDescription") VALUES(1,'Sam', '123123123', '123123123@gmail.com', 1,'Consumers')
INSERT "User"("UserID","UserName","Password","Email","UserRoleId","RoleDescription") VALUES(2,'Dean', '123123123', '111111111@gmail.com',1,'Consumers')
INSERT "User"("UserID","UserName","Password","Email","UserRoleId","RoleDescription") VALUES(3,'Cass', '123123123', '321321321@gmail.com',2,'Customer')
INSERT "User"("UserID","UserName","Password","Email","UserRoleId","RoleDescription") VALUES(4,'Sama', '123123123', '13434123@gmail.com', 3,'Admin')
INSERT "User"("UserID","UserName","Password","Email","UserRoleId","RoleDescription") VALUES(5,'Lana', '123123123', '55342344@gmail.com',3,'Admin')
INSERT "User"("UserID","UserName","Password","Email","UserRoleId","RoleDescription") VALUES(6,'Alex', '123123123', '34234232@gmail.com',3,'Admin')
INSERT "User"("UserID","UserName","Password","Email","UserRoleId","RoleDescription") VALUES(7,'Sakura', '123123123', '54231231@gmail.com', 2,'Customer')
INSERT "User"("UserID","UserName","Password","Email","UserRoleId","RoleDescription") VALUES(8,'Karma', '123123123', 'AAAAAAA@gmail.com',1,'Consumers')
INSERT "User"("UserID","UserName","Password","Email","UserRoleId","RoleDescription") VALUES(9,'Panda', '123123123', 'BBBBBBB@gmail.com',2,'Customer')
GO
ALTER TABLE "User" CHECK CONSTRAINT ALL
GO


set quoted_identifier on
GO
ALTER TABLE "ProductCategory" NOCHECK CONSTRAINT ALL
GO
INSERT "ProductCategory"("CategoryId","CategoryName")  VALUES(1,'Mechanical')
INSERT "ProductCategory"("CategoryId","CategoryName")  VALUES(2,'Electrical')
INSERT "ProductCategory"("CategoryId","CategoryName")  VALUES(3,'Stationary')
INSERT "ProductCategory"("CategoryId","CategoryName")  VALUES(4,'Furniture')
GO
ALTER TABLE "User" CHECK CONSTRAINT ALL
GO

set quoted_identifier on
GO
ALTER TABLE "ProductSubCategory" NOCHECK CONSTRAINT ALL
GO
INSERT "ProductSubCategory"("SubCategoryId","SubCategoryName","CategoryId")  VALUES(1,'Fans',2)
INSERT "ProductSubCategory"("SubCategoryId","SubCategoryName","CategoryId")  VALUES(2,'Vacuum',2)
INSERT "ProductSubCategory"("SubCategoryId","SubCategoryName","CategoryId")  VALUES(3,'Toaster',2)
GO
ALTER TABLE "User" CHECK CONSTRAINT ALL
GO

set quoted_identifier on
GO
ALTER TABLE "Manufacture" NOCHECK CONSTRAINT ALL
GO
INSERT "Manufacture"("ManufactureId","ManufactureIdName")  VALUES(1,'Bonesless')
INSERT "Manufacture"("ManufactureId","ManufactureIdName")  VALUES(2,'JC Stuff')
INSERT "Manufacture"("ManufactureId","ManufactureIdName")  VALUES(3,'Kyoto')
INSERT "Manufacture"("ManufactureId","ManufactureIdName")  VALUES(4,'Wit Studio')
INSERT "Manufacture"("ManufactureId","ManufactureIdName")  VALUES(5,'Mad House')
GO
ALTER TABLE "Manufacture" CHECK CONSTRAINT ALL
GO


set quoted_identifier on
GO
ALTER TABLE "Series" NOCHECK CONSTRAINT ALL
GO
INSERT "Series"("SeriesId","SeriesName", "SubCategoryId", "ManufactureId")  VALUES(1,'AAAA', 1 ,1)
INSERT "Series"("SeriesId","SeriesName", "SubCategoryId", "ManufactureId")  VALUES(2,'SSSS', 1 ,1)
INSERT "Series"("SeriesId","SeriesName", "SubCategoryId", "ManufactureId")  VALUES(3,'BBBB', 2 ,1)
INSERT "Series"("SeriesId","SeriesName", "SubCategoryId", "ManufactureId")  VALUES(4,'CCCC', 2 ,4)
INSERT "Series"("SeriesId","SeriesName", "SubCategoryId", "ManufactureId")  VALUES(5,'DDDD', 2 ,5)
INSERT "Series"("SeriesId","SeriesName", "SubCategoryId", "ManufactureId")  VALUES(6,'EEEE', 3 ,3)
INSERT "Series"("SeriesId","SeriesName", "SubCategoryId", "ManufactureId")  VALUES(7,'FFFF', 3 ,2)
INSERT "Series"("SeriesId","SeriesName", "SubCategoryId", "ManufactureId")  VALUES(8,'GGGG', 3 ,2)
GO
ALTER TABLE "Series" CHECK CONSTRAINT ALL
GO


set quoted_identifier on
GO
ALTER TABLE "Model" NOCHECK CONSTRAINT ALL
GO
INSERT "Model"("ModelId","ModelName","SeriesId","SubCategoryId","ManufactureId")  VALUES(1,'F1-1150',1,1,1)
INSERT "Model"("ModelId","ModelName","SeriesId","SubCategoryId","ManufactureId")  VALUES(2,'E9-1150',2,1,1)
INSERT "Model"("ModelId","ModelName","SeriesId","SubCategoryId","ManufactureId")  VALUES(3,'S3-1350',3,1,1)
INSERT "Model"("ModelId","ModelName","SeriesId","SubCategoryId","ManufactureId")  VALUES(4,'S4-1545',4,2,5)
INSERT "Model"("ModelId","ModelName","SeriesId","SubCategoryId","ManufactureId")  VALUES(5,'S5-3462',5,2,3)
INSERT "Model"("ModelId","ModelName","SeriesId","SubCategoryId","ManufactureId")  VALUES(6,'S1-1642',6,2,4)
INSERT "Model"("ModelId","ModelName","SeriesId","SubCategoryId","ManufactureId")  VALUES(7,'C4-1560',7,2,2)
INSERT "Model"("ModelId","ModelName","SeriesId","SubCategoryId","ManufactureId")  VALUES(8,'C3-1560',8,3,1)
GO
ALTER TABLE "Model" CHECK CONSTRAINT ALL
GO


set quoted_identifier on
GO
ALTER TABLE "ModelType" NOCHECK CONSTRAINT ALL
GO
INSERT "ModelType"("ModelTypeId","UseType","Application","MountingLocation","Accessories","ModelYear","ModelId")  
VALUES(1,'Commercial','Indoor','Roof','With Light',2019,1)
INSERT "ModelType"("ModelTypeId","UseType","Application","MountingLocation","Accessories","ModelYear","ModelId")  
VALUES(2,'Commercial','Outdoor','Floor','With Light',2018,1)
GO
ALTER TABLE "ModelType" CHECK CONSTRAINT ALL
GO


set quoted_identifier on
GO
ALTER TABLE "SpecFilter" NOCHECK CONSTRAINT ALL
GO

INSERT "SpecFilter"("SubCategoryId","PropertyName",	"MIN", "MAX")  
VALUES(2,'AirFlow',100,10000)
INSERT "SpecFilter"("SubCategoryId","PropertyName",	"MIN", "MAX")  
VALUES(2,'FanSpeed',1,1000)
INSERT "SpecFilter"("SubCategoryId","PropertyName",	"MIN", "MAX")  
VALUES(2,'Power',60,500)
INSERT "SpecFilter"("SubCategoryId","PropertyName",	"MIN", "MAX")  
VALUES(2,'OperatingVoltage',1,500)
INSERT "SpecFilter"("SubCategoryId","PropertyName",	"MIN", "MAX")  
VALUES(2,'NumOfFanSpeed',1,20)
INSERT "SpecFilter"("SubCategoryId","PropertyName",	"MIN", "MAX")  
VALUES(2,'SoundAtMaxSpeed',20,500)
INSERT "SpecFilter"("SubCategoryId","PropertyName",	"MIN", "MAX")  
VALUES(2,'FanSweepDiameter',18,500)
INSERT "SpecFilter"("SubCategoryId","PropertyName",	"MIN", "MAX")  
VALUES(2,'Weight',10,200)
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
INSERT "Product"("ProductId", "ProductName", "ModelTypeId","ModelId","SubCategoryId")
VALUES(1,'Honeywell HT-900 TurboForce Air Circulator Fan Black', 1, 1, 2)
INSERT "Product"("ProductId", "ProductName", "ModelTypeId","ModelId","SubCategoryId")
VALUES(2, 'Lasko 1843 Remote Control Cyclone Pedestal Fan with Built-in Timer', 2, 1, 2)
INSERT"Product"("ProductId", "ProductName", "ModelTypeId","ModelId","SubCategoryId")
VALUES(3,'Dyson V11 Torque Drive Cordless Vacuum Cleaner', 3, 3, 2)
INSERT"Product"("ProductId", "ProductName", "ModelTypeId","ModelId","SubCategoryId")
VALUES(4,'Eureka NES210 Blaze 3-in-1 Swivel Lightweight Stick Vacuum Cleaner Dark Black', 4, 4, 2)
INSERT"Product"("ProductId", "ProductName", "ModelTypeId","ModelId","SubCategoryId")
VALUES(5,'Calphalon Quartz Heat Countertop Toaster Oven', 5, 5, 2)
INSERT"Product"("ProductId", "ProductName", "ModelTypeId","ModelId","SubCategoryId")
VALUES(6,'Cuisinart CPT-180 Metal Classic 4-Slice toaster', 6, 6, 2)
GO
ALTER TABLE "Product" CHECK CONSTRAINT ALL
GO

