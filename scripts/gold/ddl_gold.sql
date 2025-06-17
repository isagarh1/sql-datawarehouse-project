

/* Create Gold Views:
Usage: This views can be queried directly for analytics and reporting.*/

--** views created gold_dim_customers**--
CREATE  VIEW gold_dim_customers AS
SELECT 
	ROW_NUMBER() OVER(ORDER BY cst_id) AS customer_key,
	CI.cst_id AS customer_id,
	CI.cst_key AS customer_number,
	CI.cst_firstname AS first_name,
	CI.cst_lastname AS last_name,
	CL.cntry AS country,
	CI.cst_marital_status AS marital_status,
CASE WHEN CI.cst_gndr != 'n/a' THEN CI.cst_gndr
	ELSE COALESCE (CI.cst_gndr, 'n/a')
END AS gender,
	CI.cst_create_date AS create_date,
	CA.bdate AS birthdate
FROM silver.crm_cust_info CI
LEFT JOIN silver.erp_cust_az12 CA
ON
CI.cst_key = CA.cid
LEFT JOIN silver.erp_loc_a101 CL
ON 
CI.cst_key = CL.cid
===============================================================================

--**views gold_dim_products**--
CREATE VIEW gold_dim_products AS
SELECT 
ROW_NUMBER() OVER(ORDER BY prd_start_dt,prd_key) AS product_key,
	PD.prd_id AS product_id,
	PD.prd_key AS product_number,
	PD.prd_nm AS product_name,
	PD.cat_id AS category_id,
	CT.cat AS category,
	CT.subcat AS subcategory,
	CT.maintenance,
	PD.prd_cost AS cost,
	PD.prd_line AS product_line,
	PD.prd_start_dt AS start_date	
FROM silver.crm_prd_info PD
LEFT JOIN silver.erp_px_cat_g1v2 CT 
ON PD.cat_id = CT.id
WHERE PD.prd_end_dt IS NULL -- Filter current data
===============================================================================
--** views gold_facts_sales**--
CREATE VIEW gold_facts_sales AS
SELECT 
	SD.sls_ord_num AS order_number,
	GP.product_key,
	GC.customer_key,
	SD.sls_order_dt AS order_date,
	SD.sls_ship_dt AS ship_date,
	SD.sls_due_dt AS due_date,
	SD.sls_sales AS sales_amount,
	SD.sls_quantity AS quantity,
	SD.sls_price AS price
FROM silver.crm_sales_details SD
LEFT JOIN gold_dim_products  GP
ON
SD.sls_prd_key = GP.product_number
LEFT JOIN gold_dim_customers GC
ON 
SD.sls_cust_id = GC.customer_id 




