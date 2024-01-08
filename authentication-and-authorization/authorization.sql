/* Create User using Microsoft Entra ID*/

CREATE USER [dba@contoso.com] FROM EXTERNAL PROVIDER;
GO

/* Create Login and User using SQL Authentication*/
USE [master]

CREATE LOGIN demo WITH PASSWORD = 'Pa55.w.rd'

CREATE USER demo FROM LOGIN demo

/* List of permission in SQL Server

https://learn.microsoft.com/en-us/sql/relational-databases/security/permissions-database-engine?view=sql-server-ver16 */

/* Grant role at server level */

GRANT SELECT, EXECUTE ON SCHEMA::Sales TO [SalesReader]
/* Grant role at database level */
GRANT db_datareader TO demo

/* Grant permission at schema level */
GRANT <permission> ON SCHEMA::<schema_name> TO <user_name>

/* Grant permission at table level */
GRANT <permission> ON <table_name> TO <user_name>
