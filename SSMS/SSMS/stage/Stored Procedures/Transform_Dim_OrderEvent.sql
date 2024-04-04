
CREATE PROCEDURE [stage].[Transform_Dim_OrderEvent]
	@JobIsIncremental BIT			
AS 

TRUNCATE TABLE [stage].[Dim_OrderEvent]

INSERT INTO [stage].[Dim_OrderEvent] (OrderEventKey, OrderEventName, SourceEventName)
VALUES 
	('020','Migration From', 'N/A'),
	('021','Migration From Upgrade', 'N/A'),
	('022','Migration From Downgrade', 'N/A'),
	('023','Migration To', 'N/A'),
	('050','Offer Planned', 'PLANNED'),
	('060','Offer Cancelled', 'CANCELLED'),
	('070','Offer Completed', 'COMPLETED'),
	('080','Offer Activated', 'ACTIVE'),
	('085','Offer Commitment End', 'N/A'),
	('086','Hardware Commitment End', 'N/A'),
	('090','Offer Disconnected', 'DISCONNECTED'),
	('100','RGU Activated', 'N/A'),
	('101','RGU Disconnected', 'N/A')