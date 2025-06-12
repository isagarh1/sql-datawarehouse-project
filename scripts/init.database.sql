
--CREATE DATABASE AND SCHEMAS
/*Script Purpose : Create new DB name 'DataWarehouse' Checking if already exists.
							if the DB exists , it is dropped and recreated.
							and also setup three schemas within DB : 'bronze','silver','gold'.
WARNING : Running this script will drop entire DB if it exists.
					All data will be deleted permanently.  Proceed with caution ensure have backup
					before running scripts
*/


CREATE DATABASE DataWarehouse;
USE DataWarehouse;
 Go

 -- Create Schemas
 CREATE SCHEMA bronze;
 GO
 CREATE SCHEMA silver;
 GO
 CREATE SCHEMA gold;
 GO


DDL Script: Create Bronze Tables
===============================================================================
Script Purpose:
    This script creates tables in the 'bronze' schema, dropping existing tables 
    if they already exist.
	  Run this script to re-define the DDL structure of 'bronze' Tables
===============================================================================
*/
IF OBJECT_ID ('bronze.crm_cust_info', 'U') IS NOT NULL
	DROP TABLE bronze.crm_cust_info;

CREATE TABLE bronze.crm_cust_info (
    cst_id              INT,
    cst_key             VARCHAR(50),
    cst_firstname       VARCHAR(50),
    cst_lastname        VARCHAR(50),
    cst_marital_status  VARCHAR(50),
    cst_gndr            VARCHAR(50),
    cst_create_date     DATE
);
IF OBJECT_ID ('bronze.crm_prd_info', 'U') IS NOT NULL
	DROP TABLE bronze.crm_prd_info;

CREATE TABLE bronze.crm_prd_info (
    prd_id       INT,
    prd_key      VARCHAR(50),
    prd_nm       VARCHAR(50),
    prd_cost     INT,
    prd_line     VARCHAR(50),
    prd_start_dt DATE,
    prd_end_dt   DATE
);

IF OBJECT_ID ('bronze.crm_sales_details', 'U') IS NOT NULL
	DROP TABLE bronze.crm_sales_details;

CREATE TABLE bronze.crm_sales_details (
    sls_ord_num  VARCHAR(50),
    sls_prd_key  VARCHAR(50),
    sls_cust_id  INT,
    sls_order_dt INT,
    sls_ship_dt  INT,
    sls_due_dt   INT,
    sls_sales    INT,
    sls_quantity INT,
    sls_price    INT
);

IF OBJECT_ID ('bronze.erp_loc_a101', 'U') IS NOT NULL
	DROP TABLE bronze.erp_loc_a101;

CREATE TABLE bronze.erp_loc_a101 (
    cid    VARCHAR(50),
    cntry  VARCHAR(50)
);

IF OBJECT_ID ('bronze.erp_cust_az12', 'U') IS NOT NULL
	DROP TABLE bronze.erp_cust_az12;

CREATE TABLE bronze.erp_cust_az12 (
    cid    VARCHAR(50),
    bdate  DATE,
    gen    VARCHAR(50)
);


IF OBJECT_ID ('bronze.erp_px_cat_g1v2', 'U') IS NOT NULL
	DROP TABLE bronze.erp_px_cat_g1v2;

CREATE TABLE bronze.erp_px_cat_g1v2 (
    id           VARCHAR(50),
    cat          VARCHAR(50),
    subcat       VARCHAR(50),
    maintenance  VARCHAR(50)
);

===================================================================
/* BUL K INSERT DATA*/ 

--BRONZE CRM LOAD--
EXEC bronze.load_bronze

CREATE OR ALTER PROCEDURE bronze.load_bronze AS
BEGIN

		TRUNCATE TABLE  bronze.crm_cust_info
		BULK INSERT bronze.crm_cust_info
		FROM 'F:\Sql Projects\Sql_Data\sql-data-warehouse-project\datasets\source_crm\cust_info.csv'
		WITH(
				FIRSTROW = 2,
				FIELDTERMINATOR = ',',
				TABLOCK
		);

		TRUNCATE TABLE  bronze.crm_prd_info
		BULK INSERT bronze.crm_prd_info
		FROM 'F:\Sql Projects\Sql_Data\sql-data-warehouse-project\datasets\source_crm\prd_info.csv'
		WITH(
				FIRSTROW = 2,
				FIELDTERMINATOR = ',',
				TABLOCK
		);

		TRUNCATE TABLE bronze.crm_sales_details
		BULK INSERT bronze.crm_sales_details
		FROM 'F:\Sql Projects\Sql_Data\sql-data-warehouse-project\datasets\source_crm\sales_details.csv'
		WITH(
				FIRSTROW = 2,
				FIELDTERMINATOR = ',',
				TABLOCK
		);

		---BRONZE ERP LOAD---

		TRUNCATE TABLE bronze.erp_cust_az12
		BULK INSERT bronze.erp_cust_az12
		FROM 'F:\Sql Projects\Sql_Data\sql-data-warehouse-project\datasets\source_erp\CUST_AZ12.csv'
		WITH(
				FIRSTROW = 2,
				FIELDTERMINATOR = ',',
				TABLOCK
		);

		TRUNCATE TABLE bronze.erp_loc_a101
		BULK INSERT bronze.erp_loc_a101
		FROM 'F:\Sql Projects\Sql_Data\sql-data-warehouse-project\datasets\source_erp\loc_a101.csv'
		WITH(
				FIRSTROW = 2,
				FIELDTERMINATOR = ',',
				TABLOCK
		);
 
		TRUNCATE TABLE bronze.erp_px_cat_g1v2
		BULK INSERT bronze.erp_px_cat_g1v2
		FROM 'F:\Sql Projects\Sql_Data\sql-data-warehouse-project\datasets\source_erp\px_cat_g1v2.csv'
		WITH(
				FIRSTROW = 2,
				FIELDTERMINATOR = ',',
				TABLOCK
		);
END









