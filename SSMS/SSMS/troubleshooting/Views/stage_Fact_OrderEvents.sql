CREATE VIEW troubleshooting.stage_Fact_OrderEvents
AS

SELECT oe.OrderEventName, pr.ProductName, pr.ProductType, f.*
FROM stage.Fact_OrderEvents f
LEFT JOIN dim.OrderEvent oe ON oe.OrderEventKey = f.OrderEventKey
LEFT JOIN dim.Product pr ON pr.ProductKey = f.ProductKey