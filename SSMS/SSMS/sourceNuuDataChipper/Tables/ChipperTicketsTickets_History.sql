CREATE TABLE [sourceNuuDataChipper].[ChipperTicketsTickets_History] (
    [appointment.id]                            NVARCHAR (500) NULL,
    [assignee]                                  NVARCHAR (500) NULL,
    [created]                                   NVARCHAR (500) NULL,
    [customer.contact.channels.email.address]   NVARCHAR (500) NULL,
    [customer.contact.channels.email.preferred] BIT            NULL,
    [customer.contact.channels.phone.number]    NVARCHAR (500) NULL,
    [customer.contact.channels.phone.preferred] BIT            NULL,
    [customer.contact.name]                     NVARCHAR (500) NULL,
    [customer.id]                               NVARCHAR (500) NULL,
    [id]                                        NVARCHAR (500) NOT NULL,
    [impact]                                    NVARCHAR (500) NULL,
    [issue.description]                         NVARCHAR (MAX) NULL,
    [issue.start]                               NVARCHAR (500) NULL,
    [issue.type]                                NVARCHAR (500) NULL,
    [item.lid]                                  NVARCHAR (500) NULL,
    [reported]                                  NVARCHAR (500) NULL,
    [resolved]                                  NVARCHAR (500) NULL,
    [sla.id]                                    NVARCHAR (500) NULL,
    [status]                                    NVARCHAR (500) NULL,
    [subject]                                   NVARCHAR (500) NULL,
    [updated]                                   NVARCHAR (500) NULL,
    [sourceFilename]                            NVARCHAR (500) NULL,
    [processedTimestamp]                        DATETIME       NULL,
    [hour]                                      INT            NULL,
    [quarterhour]                               BIGINT         NULL,
    [SRC_DWSourceFilePath]                      NVARCHAR (500) NULL,
    [SRC_DWIsCurrent]                           BIT            NULL,
    [SRC_DWValidFromDate]                       DATETIME2 (7)  NOT NULL,
    [SRC_DWValidToDate]                         DATETIME2 (7)  NULL,
    [SRC_DWCreatedDate]                         DATETIME2 (7)  NULL,
    [SRC_DWModifiedDate]                        DATETIME2 (7)  NULL,
    [SRC_DWIsDeletedInSource]                   BIT            NULL,
    [SRC_DWDeletedInSourceDate]                 DATETIME2 (7)  NULL,
    [product.id]                                NVARCHAR (500) NULL,
    [outageid]                                  NVARCHAR (50)  NULL,
    [DWIsCurrent]                               BIT            NULL,
    [DWValidFromDate]                           DATETIME2 (7)  NOT NULL,
    [DWValidToDate]                             DATETIME2 (7)  NULL,
    [DWCreatedDate]                             DATETIME2 (7)  NULL,
    [DWModifiedDate]                            DATETIME2 (7)  NULL,
    [DWIsDeletedInSource]                       BIT            NULL,
    [DWDeletedInSourceDate]                     DATETIME2 (7)  NULL,
    CONSTRAINT [PK_ChipperTicketsTickets_History] PRIMARY KEY NONCLUSTERED ([id] ASC, [SRC_DWValidFromDate] ASC, [DWValidFromDate] ASC)
);




GO
CREATE CLUSTERED COLUMNSTORE INDEX [CCI_ChipperTicketsTickets_History]
    ON [sourceNuuDataChipper].[ChipperTicketsTickets_History];

