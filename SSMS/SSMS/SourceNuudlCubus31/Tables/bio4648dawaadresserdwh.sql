CREATE TABLE [SourceNuudlCubus31].[bio4648dawaadresserdwh] (
    [KVHX]                            NVARCHAR (4000) NULL,
    [DAWA_KVHX]                       NVARCHAR (4000) NULL,
    [Id]                              NVARCHAR (50)   NULL,
    [Kommunekode]                     NVARCHAR (4000) NULL,
    [Vejkode]                         NVARCHAR (4000) NULL,
    [Vejnavn]                         NVARCHAR (4000) NULL,
    [Husnummer]                       NVARCHAR (4000) NULL,
    [Etage]                           NVARCHAR (4000) NULL,
    [Doer]                            NVARCHAR (4000) NULL,
    [Postnummer]                      NVARCHAR (4000) NULL,
    [Postnrnavn]                      NVARCHAR (4000) NULL,
    [Kommunenavn]                     NVARCHAR (4000) NULL,
    [Regionskode]                     NVARCHAR (4000) NULL,
    [Regionsnavn]                     NVARCHAR (4000) NULL,
    [MADID]                           NVARCHAR (50)   NULL,
    [Adgangsadresseid]                NVARCHAR (50)   NULL,
    [Etrs89koordinat_oest]            DECIMAL (17, 9) NULL,
    [Etrs89koordinat_nord]            DECIMAL (17, 9) NULL,
    [Supplerendebynavn]               NVARCHAR (4000) NULL,
    [Adgangspunkt_id]                 NVARCHAR (50)   NULL,
    [Esrejendomsnummer]               NVARCHAR (4000) NULL,
    [Noejagtighed]                    NVARCHAR (4000) NULL,
    [Hoejde]                          DECIMAL (5, 1)  NULL,
    [Ejerlavkode]                     INT             NULL,
    [Matrikelnummer]                  NVARCHAR (4000) NULL,
    [Status]                          INT             NULL,
    [Wgs84koordinat_bredde]           DECIMAL (11, 8) NULL,
    [Wgs84koordinat_laengde]          DECIMAL (11, 8) NULL,
    [Snapshot]                        NVARCHAR (4000) NULL,
    [NUUDL_CuratedBatchID]            INT             NULL,
    [NUUDL_CuratedProcessedTimestamp] NVARCHAR (4000) NULL,
    [DWCreatedDate]                   DATETIME2 (7)   DEFAULT (getdate()) NULL
);


GO
CREATE CLUSTERED COLUMNSTORE INDEX [CCI_bio4648dawaadresserdwh]
    ON [SourceNuudlCubus31].[bio4648dawaadresserdwh];

