CREATE SCHEMA [martView_PRX]
    AUTHORIZATION [dbo];






GO
GRANT SELECT
    ON SCHEMA::[martView_PRX] TO [nuudw-acl01-sql-db-reader];


GO
GRANT SELECT
    ON SCHEMA::[martView_PRX] TO [nuudw-acl01-sql-schema-mart-prx-reader]
    WITH GRANT OPTION;
  

