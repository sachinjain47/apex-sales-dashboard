-- ============================================================
-- Master SQLcl Deployment Script
-- Usage:  sql -s USER/PASS@SERVICE @scripts/deploy.sql
-- ============================================================

SET FEEDBACK ON
SET ECHO ON
SET SERVEROUTPUT ON SIZE UNLIMITED

PROMPT ============================================================
PROMPT  Sales Dashboard - Schema Deployment
PROMPT ============================================================

-- Continue on errors during DDL (tables may already exist on re-run)
WHENEVER SQLERROR CONTINUE

PROMPT [1/2] Running DDL: tables and views ...
@@../sql/01_create_tables.sql

-- From here: fail hard on any error
WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK

PROMPT [2/2] Schema deployment complete.

PROMPT
PROMPT Verifying objects ...
SELECT object_name, object_type, status
FROM   user_objects
WHERE  object_name LIKE 'SD_%'
ORDER  BY object_type, object_name;

EXIT 0
