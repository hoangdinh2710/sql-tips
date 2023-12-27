/* To find an active session */

-- Option 1
SELECT r.session_id, r.status, r.command, r.cpu_time, r.total_elapsed_time, t.text
FROM sys.dm_exec_requests AS r
CROSS APPLY sys.dm_exec_sql_text(r.sql_handle) AS t;

-- Option 2
SELECT *
FROM sys.dm_exec_requests
CROSS APPLY sys.dm_exec_sql_text(sql_handle);

/* To kill a session */
KILL @session_id; 
