﻿CREATE TABLE [meta].[SourceObjectFileSetup] (
    [ID]                INT            IDENTITY (1, 1) NOT NULL,
    [SourceObjectID]    INT            NOT NULL,
    [LoopFileFlag]      TINYINT        CONSTRAINT [DF_SourceObjectFileSetup_LoopFileFlag] DEFAULT ((0)) NOT NULL,
    [FileSystem]        NVARCHAR (250) CONSTRAINT [DF_SourceObjectFileSetup_FileSystemName] DEFAULT ('') NOT NULL,
    [Folder]            NVARCHAR (250) CONSTRAINT [DF_SourceObjectFileSetup_Folder] DEFAULT ('') NOT NULL,
    [FileName]          NVARCHAR (250) CONSTRAINT [DF_SourceObjectFileSetup_FileName] DEFAULT ('') NOT NULL,
    [FileExtension]     NVARCHAR (250) CONSTRAINT [DF_SourceObjectFileSetup_FileExtension] DEFAULT ('') NOT NULL,
    [FileSpecification] NVARCHAR (250) CONSTRAINT [DF_SourceObjectFileSetup_FileSpecification] DEFAULT ('') NOT NULL,
    [RowSeparator]      NVARCHAR (250) NOT NULL,
    [ColumnDelimiter]   NVARCHAR (250) NOT NULL,
    [TextQualifier]     NVARCHAR (250) NOT NULL,
    [IsHeaderPresent]   BIT            NOT NULL,
    [CompressionCodec]  NVARCHAR (250) NULL,
    [EscapeCharacter]   NVARCHAR (250) NULL,
    [Encoding]			NVARCHAR (250) NULL
);





