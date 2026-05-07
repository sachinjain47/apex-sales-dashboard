-- ============================================================
-- Sample Data Deployment Script  (first-deploy only)
-- Usage:  sql -s USER/PASS@SERVICE @scripts/deploy_data.sql
-- ============================================================

SET FEEDBACK ON
SET ECHO ON
SET SERVEROUTPUT ON SIZE UNLIMITED

WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK

PROMPT Loading sample data ...
@@../sql/02_sample_data.sql

PROMPT Sample data loaded successfully.
EXIT 0
