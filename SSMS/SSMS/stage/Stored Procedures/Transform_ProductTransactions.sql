
CREATE PROCEDURE [stage].[Transform_ProductTransactions] 


			
AS 
		
/**********************************************************************************************************************************************************************
1. Truncate Table
***********************************************************************************************************************************************************************/

TRUNCATE TABLE [stage].[ProductTransactions]

/**********************************************************************************************************************************************************************
2. Business Logik - Remember to use the input variable @JobIsIncremental to distinguish between full and incremental load. 
***********************************************************************************************************************************************************************/

/*Full Load pattern
	--Apply business logic for full load here
*/

	INSERT INTO stage.[ProductTransactions] WITH (TABLOCK)
	(
	ProductTransactionsIdentifier
	,CalendarKey
	,ProductKey
	,CustomerKey
	,ProductTransactionsQuantity
	,ProductTransactionsType
	,DWCreatedDate
	)

	SELECT 
	CONVERT(NVARCHAR(50), pin.id)								AS ProductTransactionsIdentifier
	,CONVERT(DATE, pin.active_from)								AS CalendarKey
	,CONVERT(NVARCHAR(50), REPLACE(pin.offering_id, '"', ''))	AS ProductKey
	,CONVERT(NVARCHAR(50), REPLACE(pin.customer_id, '"', ''))	AS CustomerKey
	,1															AS ProductTransactionsQuantity
	,CONVERT(NVARCHAR(10), 'Gross Add')							AS ProductTransactionsType
	,GETDATE()													AS DWCreatedDate
	--INTO stage.ProductTransactions
	FROM [sourceDataLakeNetcracker_interim].[product_instance] pin 

	/* We need to be able to link a specific product_instace transaction to a specific phone_number in order to determine
	   where the phone_number was ported in from so we can decide if the transaction (Gross Add) is external or internal.
	   Question in that regard forwarded to Netcracker, but no answer recieved yet

	--LEFT JOIN [sourceDataLakeNetcracker_interim].[phone_numbers] pn ON
	--	pn.customer_account_id = REPLACE(pin.customer_id, '"', '') 

	Joining on customer_id as above is not sufficient as a customer potentially can have several numbers.
	TODO: Investigate if the business activation dates in phone_numbers matches the activation dates in product_instance

	*/

	WHERE pin.state = 'ACTIVE' --Business activation 