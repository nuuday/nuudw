CREATE SCHEMA [masterdata]
    AUTHORIZATION [dbo];


GO
GRANT UPDATE
    ON SCHEMA::[masterdata] TO [nuudw-acl01-sql-schema-masterdata-contributor];


GO
GRANT SELECT
    ON SCHEMA::[masterdata] TO [nuudw-acl01-sql-schema-masterdata-contributor];


GO
GRANT INSERT
    ON SCHEMA::[masterdata] TO [nuudw-acl01-sql-schema-masterdata-contributor];


GO
GRANT DELETE
    ON SCHEMA::[masterdata] TO [nuudw-acl01-sql-schema-masterdata-contributor];

