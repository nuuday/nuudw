
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
	('024','Migration Legacy', 'N/A'),
	('050','Offer Planned', 'PLANNED'),
	('055','Offer Cancelled', 'CANCELLED'),
	('060','Offer Completed', 'COMPLETED'),
	('064','Offer Changed Owner', 'N/A'),
	('065','Offer Activated', 'ACTIVE'),
	('070','Offer Commitment Start', 'N/A'),
	('075','Offer Commitment End', 'N/A'),
	('080','Offer Commitment Broken', 'N/A'),
	('090','Offer Disconnected Planned', 'N/A'),
	('091','Offer Disconnected Expected', 'N/A'),
	('092','Offer Disconnected Cancelled', 'N/A'),
	('093','Offer Disconnected', 'DISCONNECTED'),
	('100','RGU Activated', 'N/A'),
	('101','RGU Disconnected', 'N/A'),
	('110','Hardware Return', 'N/A')