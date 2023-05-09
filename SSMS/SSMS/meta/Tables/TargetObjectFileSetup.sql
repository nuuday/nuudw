CREATE TABLE [meta].[TargetObjectFileSetup] (
    [ID]                             INT            IDENTITY (1, 1) NOT NULL,
    [TargetObjectID]                 INT            NOT NULL,
    [FileSystemName]                 NVARCHAR (250) CONSTRAINT [DF__TargetObj__FileS__531856C7] DEFAULT ('') NOT NULL,
    [FolderName]                     NVARCHAR (250) CONSTRAINT [DF__TargetObj__Folde__540C7B00] DEFAULT ('') NOT NULL,
    [FileDynamicExtensionDefinition] NVARCHAR (250) CONSTRAINT [DF__TargetObj__FileD__55F4C372] DEFAULT ('') NOT NULL,
    [AzureFileTypeName]              NVARCHAR (50)  NOT NULL,
    [AppendDataFlag]                 BIT            CONSTRAINT [DF_TargetObjectFileSetup_AppendDataFlag] DEFAULT ((0)) NOT NULL
);


GO
CREATE UNIQUE CLUSTERED INDEX [PK_TargetObjectFileSetup]
    ON [meta].[TargetObjectFileSetup]([TargetObjectID] ASC);

