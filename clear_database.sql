DECLARE @sql NVARCHAR(max)=''

-- Drop constraints
SELECT @sql += 'ALTER TABLE ' + QUOTENAME(OBJECT_SCHEMA_NAME(parent_object_id))
    + '.' + QUOTENAME(OBJECT_NAME(parent_object_id)) +
    ' DROP CONSTRAINT ' + QUOTENAME(name) + ';'
FROM sys.foreign_keys;
PRINT 'Dropping Constraints';
PRINT @sql;
EXEC sp_executesql @sql;
SET @sql = '';

-- Drop tables
SELECT @sql += 'DROP TABLE ' + QUOTENAME(TABLE_SCHEMA) + '.'+ QUOTENAME(TABLE_NAME) + '; '
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_TYPE = 'BASE TABLE';
PRINT 'Dropping Tables';
PRINT @sql;
EXEC sp_executesql @sql;
SET @sql = '';

-- Drop views
SELECT @sql += 'DROP VIEW ' + QUOTENAME(SCHEMA_NAME(schema_id)) + '.' + QUOTENAME(name) + ';'
FROM sys.views;
PRINT 'Dropping Views';
PRINT @sql;
EXEC sp_executesql @sql;
SET @sql = '';

-- Drop procedures
SELECT @sql += 'DROP PROCEDURE ' + QUOTENAME(SCHEMA_NAME(schema_id)) + '.' + QUOTENAME(name) + ';'
FROM sys.procedures;
PRINT 'Dropping Procedures';
PRINT @sql;
EXEC sp_executesql @sql;
SET @sql = '';

-- Drop functions
SELECT @sql += 'DROP FUNCTION ' + QUOTENAME(SCHEMA_NAME(schema_id)) + '.' + QUOTENAME(name) + ';'
FROM sys.objects
WHERE type_desc LIKE '%FUNCTION%';
PRINT 'Dropping Functions';
PRINT @sql;
EXEC sp_executesql @sql;
SET @sql = '';

-- Drop triggers
SELECT @sql += 'DROP TRIGGER ' + QUOTENAME(OBJECT_SCHEMA_NAME(object_id)) + '.' + QUOTENAME(name) + ';'
FROM sys.triggers
WHERE is_ms_shipped = 0 AND parent_class_desc = 'OBJECT_OR_COLUMN';
PRINT 'Dropping Triggers';
PRINT @sql;
EXEC sp_executesql @sql;
SET @sql = '';
