﻿
CREATE VIEW [martView_PRX].[DimPhoneDetail]
AS
SELECT 	[PhoneDetailID],	[PhoneDetailkey],	[PhoneStatus],	[PhoneCategory],	[PortedIn],	[PortedOut]
FROM [dimView].[PhoneDetail]