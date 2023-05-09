CREATE TABLE [meta].[BusinessMatrix] (
    [ID]                           INT            IDENTITY (1, 1) NOT NULL,
    [DestinationSchema]            NVARCHAR (20)  NULL,
    [TableName]                    NVARCHAR (250) NULL,
    [LoadPattern]                  NVARCHAR (100) CONSTRAINT [DF_BusinessMatrix_LoadPattern] DEFAULT (N'Standard') NULL,
    [FactAndBridgeIncrementalFlag] BIT            CONSTRAINT [DF_BusinessMatrix_FactAndBridgeIncrementalFlag] DEFAULT ((0)) NULL,
    [SCD2DimensionFlag]            BIT            CONSTRAINT [DF_BusinessMatrix_SCD2DimensionFlag] DEFAULT ((0)) NULL,
    [PackageDependencyFlag]        BIT            CONSTRAINT [DF_BusinessMatrix_PackageDependencyFlag] DEFAULT ((0)) NULL,
    [TruncateBeforeDeployFlag]     BIT            CONSTRAINT [DF_BusinessMatrix_TruncateBeforeDeployFlag] DEFAULT ((0)) NULL,
    [TransformExcludeFlag]         BIT            CONSTRAINT [DF__BusinessM__Enabl__5CD6CB2B] DEFAULT ((0)) NULL,
    [DWExcludeFlag]                BIT            CONSTRAINT [DF_BusinessMatrix_DWExcludeFlag] DEFAULT ((0)) NULL,
    [ControllerExcludeFlag]        BIT            CONSTRAINT [DF_BusinessMatrix_ControllerExcludeFlag] DEFAULT ((0)) NULL,
    CONSTRAINT [PK_BusinessMatrix] PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [chk_DWTableType] CHECK ([DestinationSchema]='bridge' OR [DestinationSchema]='fact' OR [DestinationSchema]='dim' OR [DestinationSchema]='temp')
);

