
CREATE PROCEDURE [stage].[Transform_Dim_Dummy]
	@JobIsIncremental BIT			
AS 

TRUNCATE TABLE [stage].[Dim_Dummy]

INSERT INTO stage.[Dim_Dummy] WITH (TABLOCK) (DummyKey, SomeAttribute)
SELECT 'MyKey123','A value'