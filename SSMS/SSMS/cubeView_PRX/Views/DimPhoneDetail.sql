
CREATE VIEW [cubeView_PRX].[DimPhoneDetail]
AS
SELECT 	[PhoneDetailID],	[PhoneDetailkey],	[PhoneStatus],	[PhoneCategory],	[PortedIn],	[PortedOut]
FROM [dimView].[PhoneDetail]