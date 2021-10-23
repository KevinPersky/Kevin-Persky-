-- Scuba Experiences Database developed and written by Kevin Persky 
-- INFO 3240 Project
-- Peer Reviewed by Meijia Oltman
-- Originally Written: April 22, 2021 | Updated: April 28, 2021
-----------------------------------------------------------
IF NOT EXISTS(SELECT*FROM sys.databases
	WHERE NAME = N'ScubaExperiences')
	CREATE DATABASE ScubaExperiences
GO
USE ScubaExperiences 
--
-- Alter the path so the script can find the CSV files 
--
DECLARE @data_path NVARCHAR(256);
SELECT @data_path = 'C:\Users\persk\OneDrive\Documents\INFO3240\DB Builds\BuildScubaExperiences\';
--
-- Delete existing tables
--
IF EXISTS(
	SELECT *
	FROM sys.tables
	WHERE NAME = N'REGISTRATION'
       )
	DROP TABLE REGISTRATION;
--
IF EXISTS(
	SELECT *
	FROM sys.tables
	WHERE NAME = N'DIVER_CERT'
       )
	DROP TABLE DIVER_CERT;
--
IF EXISTS(
	SELECT *
	FROM sys.tables
	WHERE NAME = N'CLASS'
       )
	DROP TABLE CLASS;
--
IF EXISTS(
	SELECT *
	FROM sys.tables
	WHERE NAME = N'CERTIFICATION'
       )
	DROP TABLE CERTIFICATION;
--
IF EXISTS(
	SELECT *
	FROM sys.tables
	WHERE NAME = N'DIVE_LOG'
       )
	DROP TABLE DIVE_LOG;
--
IF EXISTS(
	SELECT *
	FROM sys.tables
	WHERE NAME = N'DIVER'
       )
	DROP TABLE DIVER;
--
IF EXISTS(
	SELECT *
	FROM sys.tables
	WHERE NAME = N'DIVEMASTER'
       )
	DROP TABLE DIVEMASTER;
--
IF EXISTS(
	SELECT *
	FROM sys.tables
	WHERE NAME = N'PRICE'
       )
	DROP TABLE PRICE;
--
IF EXISTS(
	SELECT *
	FROM sys.tables
	WHERE NAME = N'INVENTORY'
       )
	DROP TABLE INVENTORY;
--
IF EXISTS(
	SELECT *
	FROM sys.tables
	WHERE NAME = N'EXPERIENCE'
       )
	DROP TABLE EXPERIENCE;
--
-- Create tables
--
--Create Experience Table
CREATE TABLE EXPERIENCE
	(ExperienceID			INT CONSTRAINT pk_experience_id PRIMARY KEY,
	NAUICertID				NVARCHAR(10),
	PADICertID				NVARCHAR(10),
	DateAquired				DATE 
	);
--
--Create Inventory Table
CREATE TABLE INVENTORY
	(InventoryID			INT IDENTITY (1001,1) CONSTRAINT pk_Inventory_id PRIMARY KEY,
	InventorySupplies		NVARCHAR(12) CONSTRAINT ck_InventorySupplies CHECK ((InventorySupplies = 'Tank') OR (InventorySupplies = 'Respirator') OR (InventorySupplies = 'Goggles') OR (InventorySupplies = 'Flippers')),
	InventoryConditions		NVARCHAR(16) CONSTRAINT ck_InventoryConditions CHECK ((InventoryConditions = 'Good') OR (InventoryConditions = 'Worn') OR (InventoryConditions = 'Needs Replacing')),
	InventoryCheckoutDate	DATETIME CONSTRAINT nn_Inventory_Checkout_Date NOT NULL,
	InventoryCheckinDate	DATETIME CONSTRAINT nn_Inventory_Checkin_Date NOT NULL
	);
--
--Create Price Table
CREATE TABLE PRICE
	(PriceID				INT CONSTRAINT  pk_Price_id PRIMARY KEY,
	PriceSeason				NVARCHAR (1) CONSTRAINT ck_Price_Season CHECK ((PriceSeason = '1') OR (PriceSeason = '2')),
	Price					MONEY CONSTRAINT nn_Price NOT NULL,
	PriceDiscount			NUMERIC (4,4),
	);
--
--Create DiveMaster Table
CREATE TABLE DIVEMASTER
	(DiveMasterID			INT IDENTITY (1001,1) CONSTRAINT pk_DiverMaster_id PRIMARY KEY,
	DM_FName				NVARCHAR(15) CONSTRAINT nn_DM_FName NOT NULL,
	DM_LName				NVARCHAR(20) CONSTRAINT nn_DM_LName NOT NULL,
	DM_DOB					DATE CONSTRAINT nn_DM_DOB NOT NULL,
	Person_ID_Num			NVARCHAR(10) CONSTRAINT un_Person_ID_Num UNIQUE,
	DM_CellNum				NVARCHAR(10) CONSTRAINT un_DM_CellNum UNIQUE,
	);
--
--Create Diver Table
CREATE TABLE DIVER
	(DiverID				INT IDENTITY (1001,1) CONSTRAINT pk_Diver_id PRIMARY KEY,
	ExperienceID			INT CONSTRAINT fk_experience_id FOREIGN KEY 
		REFERENCES Experience(ExperienceID),
	D_DOB					DATE CONSTRAINT nn_D_DOB NOT NULL,
	E_Contact_Num			NVARCHAR(14) CONSTRAINT nn_E_Contact_Num NOT NULL,
	Diver_FName				NVARCHAR(15) CONSTRAINT nn_Diver_FName NOT NULL,
	Diver_LName				NVARCHAR(30) CONSTRAINT nn_Diver_LName NOT NULL,
	D_Email					NVARCHAR(45) CONSTRAINT nn_D_Email NOT NULL,
	);
--
--Create Dive_log Table
CREATE TABLE DIVE_LOG
	(DiveID					INT CONSTRAINT pk_Dive_id PRIMARY KEY,
	DiverID					INT CONSTRAINT fk_Diver_id FOREIGN KEY 
		REFERENCES Diver(DiverID),
	InventoryID				INT CONSTRAINT fk_Inventory_id FOREIGN KEY 
		REFERENCES Inventory(InventoryID),
	Dive_Duration			NUMERIC(3,0) CONSTRAINT nn_Dive_Duration NOT NULL,
	Dive_Depth				NUMERIC(3,0) CONSTRAINT nn_Dive_Depth NOT NULL,					
	Dive_Location			NVARCHAR (50) CONSTRAINT nn_Dive_Location NOT NULL, 
	);
--
----Create Certification Table
CREATE TABLE CERTIFICATION
	(CertificationID		INT CONSTRAINT pk_Certification_id PRIMARY KEY,
	Certification_Name		NVARCHAR(30) CONSTRAINT nn_Certification_Name NOT NULL
	);
--
--Create Class Table
CREATE TABLE CLASS
	(ClassID				INT CONSTRAINT pk_Class_id PRIMARY KEY,
	CertificationID			INT CONSTRAINT fk_Certification_id FOREIGN KEY 
		REFERENCES Certification(CertificationID),
	DiveMasterID			INT CONSTRAINT fk_DiveMaster_id FOREIGN KEY 
		REFERENCES DiveMaster(DiveMasterID),
	PriceID					INT CONSTRAINT fk_Price_id FOREIGN KEY 
		REFERENCES Price(PriceID),
	Class_Date				DATE CONSTRAINT nn_Class_Date NOT NULL,
	Class_Name				NVARCHAR (50) CONSTRAINT nn_Class_Name NOT NULL,
	);
--
--Create Diver Cert Table
CREATE TABLE DIVER_CERT
	(Diver_Cert_Date	DATE CONSTRAINT pk_Diver_Cert_Date PRIMARY KEY,
	DiverID			INT CONSTRAINT fk_Diver_Cert_id FOREIGN KEY 
		REFERENCES Diver(DiverID),
	CertificationID		INT CONSTRAINT fk_Diver_Certification_id FOREIGN KEY 
		REFERENCES Certification(CertificationID),
	Diver_Review		NVARCHAR(256),
	);
--
--Create Registration Table
CREATE TABLE REGISTRATION
	(Registration_Date	DATE CONSTRAINT pk_Registration_Date PRIMARY KEY,
	DiverID			INT CONSTRAINT fk_Diver_Registration_id FOREIGN KEY 
		REFERENCES Diver(DiverID),
	ClassID			INT CONSTRAINT fk_Class_Registration_id FOREIGN KEY 
		REFERENCES Class(ClassID),
	Dive_Review		NVARCHAR(256),
	);
--
-- Load table data
-- Load Data to Experience Table
EXECUTE (N'BULK INSERT Experience FROM ''' + @data_path + N'Experience.csv''
WITH (
	CHECK_CONSTRAINTS,
	CODEPAGE=''ACP'',
	DATAFILETYPE = ''char'',
	FIELDTERMINATOR= '','',
	ROWTERMINATOR = ''\n'',
	KEEPIDENTITY,
	TABLOCK
	);
');
-- Load Data to Inventory Table
EXECUTE (N'BULK INSERT Inventory FROM ''' + @data_path + N'Inventory.csv''
WITH (
	CHECK_CONSTRAINTS,
	CODEPAGE=''ACP'',
	DATAFILETYPE = ''char'',
	FIELDTERMINATOR= '','',
	ROWTERMINATOR = ''\n'',
	KEEPIDENTITY,
	TABLOCK
	);
');
-- Load Data to Price Table
EXECUTE (N'BULK INSERT PRICE FROM ''' + @data_path + N'PRICE.csv''
WITH (
	CHECK_CONSTRAINTS,
	CODEPAGE=''ACP'',
	DATAFILETYPE = ''char'',
	FIELDTERMINATOR= '','',
	ROWTERMINATOR = ''\n'',
	KEEPIDENTITY,
	TABLOCK
	);
');
-- Load Data to DiveMaster Table
EXECUTE (N'BULK INSERT DIVEMASTER FROM ''' + @data_path + N'DIVEMASTER.csv''
WITH (
	CHECK_CONSTRAINTS,
	CODEPAGE=''ACP'',
	DATAFILETYPE = ''char'',
	FIELDTERMINATOR= '','',
	ROWTERMINATOR = ''\n'',
	KEEPIDENTITY,
	TABLOCK
	);
');
-- Load Data to Diver Table
EXECUTE (N'BULK INSERT DIVER FROM ''' + @data_path + N'DIVER.csv''
WITH (
	CHECK_CONSTRAINTS,
	CODEPAGE=''ACP'',
	DATAFILETYPE = ''char'',
	FIELDTERMINATOR= '','',
	ROWTERMINATOR = ''\n'',
	KEEPIDENTITY,
	TABLOCK
	);
');
-- Load Data to Dive Log Table
EXECUTE (N'BULK INSERT DIVE_LOG FROM ''' + @data_path + N'DIVELOG.csv''
WITH (
	CHECK_CONSTRAINTS,
	CODEPAGE=''ACP'',
	DATAFILETYPE = ''char'',
	FIELDTERMINATOR= '','',
	ROWTERMINATOR = ''\n'',
	KEEPIDENTITY,
	TABLOCK
	);
');
-- Load Data to Certification Table
EXECUTE (N'BULK INSERT CERTIFICATION FROM ''' + @data_path + N'CERTIFICATION.csv''
WITH (
	CHECK_CONSTRAINTS,
	CODEPAGE=''ACP'',
	DATAFILETYPE = ''char'',
	FIELDTERMINATOR= '','',
	ROWTERMINATOR = ''\n'',
	KEEPIDENTITY,
	TABLOCK
	);
');
-- Load Data to Class Table
EXECUTE (N'BULK INSERT CLASS FROM ''' + @data_path + N'CLASS.csv''
WITH (
	CHECK_CONSTRAINTS,
	CODEPAGE=''ACP'',
	DATAFILETYPE = ''char'',
	FIELDTERMINATOR= '','',
	ROWTERMINATOR = ''\n'',
	KEEPIDENTITY,
	TABLOCK
	);
');
-- Load Data to Diver Cert Table
EXECUTE (N'BULK INSERT DIVER_CERT FROM ''' + @data_path + N'DIVERCERT.csv''
WITH (
	CHECK_CONSTRAINTS,
	CODEPAGE=''ACP'',
	DATAFILETYPE = ''char'',
	FIELDTERMINATOR= '','',
	ROWTERMINATOR = ''\n'',
	KEEPIDENTITY,
	TABLOCK
	);
');
-- Load Data to Registration Table
EXECUTE (N'BULK INSERT REGISTRATION FROM ''' + @data_path + N'REGISTRATION.csv''
WITH (
	CHECK_CONSTRAINTS,
	CODEPAGE=''ACP'',
	DATAFILETYPE = ''char'',
	FIELDTERMINATOR= '','',
	ROWTERMINATOR = ''\n'',
	KEEPIDENTITY,
	TABLOCK
	);
');
--
-- List table names and row counts for confirmation
--
GO
SET NOCOUNT ON
SELECT 'EXPERIENCE'	 AS "Table",	COUNT(*) AS "Rows"	FROM EXPERIENCE		UNION
SELECT 'INVENTORY',					COUNT(*)			FROM INVENTORY      UNION
SELECT 'PRICE',						COUNT(*)			FROM PRICE	        UNION
SELECT 'DIVEMASTER',				COUNT(*)			FROM DIVEMASTER     UNION
SELECT 'DIVER',						COUNT(*)			FROM DIVER	        UNION
SELECT 'DIVE_LOG',					COUNT(*)			FROM DIVE_LOG       UNION
SELECT 'CERTIFICATION',				COUNT(*)			FROM CERTIFICATION  UNION
SELECT 'CLASS',						COUNT(*)			FROM CLASS		    UNION
SELECT 'DIVER_CERT',				COUNT(*)			FROM DIVER_CERT     UNION
SELECT 'REGISTRATION',				COUNT(*)			FROM REGISTRATION
ORDER BY 1;
SET NOCOUNT OFF
GO
