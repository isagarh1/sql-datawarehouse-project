-- **Create Store Procedured**--

CREATE OR ALTER PROCEDURE silver.load_silver AS
BEGIN
		PRINT'>> Truncate table: silver.crm_cust_info';
		TRUNCATE TABLE  silver.crm_cust_info;
		PRINT'>> Inserting data into : silver.crm_cust_info';
		INSERT INTO silver.crm_cust_info(
		cst_id,
		cst_key,
		cst_firstname,
		cst_lastname,
		cst_marital_status,
		cst_gndr,
		cst_create_date
		)
		SELECT
		cst_id,
		cst_key,
		TRIM(cst_firstname) AS cst_firstname ,
		TRIM(cst_lastname) AS cst_lastname ,
		CASE WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
				 WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
				 ELSE 'n/a'
		END AS cst_marital_status,	
		CASE WHEN UPPER(TRIM(cst_gndr)) ='M' THEN 'Male'
				 WHEN UPPER(TRIM(cst_gndr)) ='F' THEN 'Female'
				 ELSE 'n/a'
		END AS cst_gndr,
		cst_create_date
		FROM	
			(SELECT *,
				ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date desc) AS FLAG 
				FROM bronze.crm_cust_info) T
		WHERE FLAG = 1 AND cst_id IS NOT NULL;

		PRINT'>> Truncate table : silver.crm_prd_info';
		TRUNCATE TABLE silver.crm_prd_info;
		PRINT'>> Inserting data into : silver.crm_prd_info';
		INSERT INTO silver.crm_prd_info(
			prd_id,     
			cat_id ,
			prd_key,      
			prd_nm ,     
			prd_cost,     
			prd_line  ,   
			prd_start_dt, 
			prd_end_dt  
			)
		SELECT 
		prd_id,
		REPLACE(SUBSTRING(prd_key,1,5),'-','_') AS cat_id,
		SUBSTRING(prd_key,7,LEN(prd_key)) AS prd_key,
		prd_nm,
		ISNULL(prd_cost,0) AS prd_cost,
		CASE WHEN prd_line ='R' THEN 'Road'
				WHEN prd_line = 'M' THEN 'Mountain'
				WHEN prd_line = 'S' THEN 'Sports'
				WHEN prd_line = 'T' THEN 'Touring'
				ELSE 'n/a'
				END AS prd_line,
		prd_start_dt,
		--prd_end_dt,
		DATEADD(DAY, -1, LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt))AS prd_end_dt
		FROM bronze.crm_prd_info;

		PRINT'>> Truncate table : silver.crm_sales_details';
		TRUNCATE TABLE  silver.crm_sales_details;
		PRINT'>> Inserting data into : silver.crm_sales_details';
		INSERT INTO silver.crm_sales_details (
			sls_ord_num,
			sls_prd_key,
			sls_cust_id,
			sls_order_dt,
			sls_ship_dt,
			sls_due_dt,
			sls_sales,
			sls_quantity,
			sls_price
		)
		SELECT 
			sls_ord_num,
			sls_prd_key,
			sls_cust_id,
			CASE WHEN sls_order_dt = 0 OR LEN(sls_order_dt) != 8  THEN NULL
			ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE) 
			END AS sls_order_dt,
			--sls_ship_dt,
			CASE WHEN sls_ship_dt = 0 OR LEN(sls_ship_dt) != 8  THEN NULL
			ELSE CAST(CAST(sls_ship_dt AS VARCHAR) AS DATE) 
			END AS sls_ship_dt,
			--sls_due_dt,
			CASE WHEN sls_due_dt = 0 OR LEN(sls_due_dt) != 8  THEN NULL
			ELSE CAST(CAST(sls_due_dt AS VARCHAR) AS DATE) 
			END AS sls_due_dt,
				CASE WHEN sls_sales <=0 OR sls_sales IS NULL OR sls_sales != sls_quantity * ABS(sls_price)
					 THEN sls_quantity * ABS(sls_price)
					 ELSE sls_sales
				END AS sls_sales,
					sls_quantity,
			CASE WHEN sls_price <=0 OR sls_price IS NULL 
					THEN sls_price / NULLIF(sls_quantity,0) 
					ELSE sls_price
			END AS sls_price
		FROM bronze.crm_sales_details;

		PRINT'>> Truncate table : silver.erp_cust_az12';
		TRUNCATE TABLE silver.erp_cust_az12;
		PRINT'>> Inserting data into : silver.erp_cust_az12';
		INSERT INTO silver.erp_cust_az12(
			cid,
			bdate,
			gen
		)
		SELECT 
			CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid,4,LEN(cid))
			ELSE cid
			END AS cid,
			CASE WHEN bdate > GETDATE() THEN NULL 
			ELSE bdate
			END AS bdate,
			CASE WHEN  UPPER(TRIM(gen)) IN ('F' ,'FEMALE') THEN 'Female'
					 WHEN  UPPER(TRIM(gen)) IN ('M' ,'MALE') THEN 'Male'
					 ELSE 'n/a'
			END AS gen
		FROM bronze.erp_cust_az12;

		PRINT'>>Truncate tables : silver.erp_loc_a101';
		TRUNCATE TABLE silver.erp_loc_a101;
		PRINT'>>Inserting data into : silver.erp_loc_a101';
		INSERT INTO silver.erp_loc_a101(
			cid,
			cntry
		)
		SELECT 
		REPLACE(cid,'-','') AS cid,
		CASE WHEN TRIM(cntry) IN('US','USA') THEN 'United States'
					WHEN TRIM(cntry) = 'DE' THEN 'Germany'
					WHEN TRIM(cntry)= ' 'OR  cntry  IS NULL THEN 'n/a'
					ELSE TRIM(cntry)
					END AS cntry
		FROM BRONZE.erp_loc_a101;

		PRINT'>> Truncate table : silver.erp_px_cat_g1v2';
		TRUNCATE TABLE  silver.erp_px_cat_g1v2;
		PRINT'>> Inserting data into :  silver.erp_px_cat_g1v2';
		INSERT INTO silver.erp_px_cat_g1v2(
			id,
			cat,
			subcat,
			maintenance
		)	
		SELECT 
			id,
			cat,
			subcat,
			maintenance
		FROM bronze.erp_px_cat_g1v2;
END

