SELECT 
  req.session_id,
  db_name = DB_NAME(req.database_id),
  use_rname = USER_NAME(user_id), 
  req.status,
  req.command,
  req.cpu_time,
  req.start_time,
  req.total_elapsed_time,
  blocked_by = req.blocking_session_id,
  req.wait_type,
  req.wait_time,
  sql_text = sqltext.TEXT,
  sql_statement = case when req.statement_end_offset > 0 then SUBSTRING(sqltext.TEXT, req.statement_start_offset/2+1, (req.statement_end_offset - req.statement_start_offset)/2) else null end
FROM sys.dm_exec_requests req CROSS APPLY sys.dm_exec_sql_text(sql_handle) AS sqltext
where req.session_id <> @@spid

select
  p.spid,
  dbname = DB_NAME(p.dbid), 
  username = USER_NAME(uid), 
  p.status,
  hostname, loginame, program_name,
  login_time, last_batch,
  sql_text = t.text,
  sql_statement = case when p.stmt_end > 0 then SUBSTRING(t.TEXT, p.stmt_start/2+1, (p.stmt_end - p.stmt_start)/2) else null end
from sys.sysprocesses p CROSS APPLY sys.dm_exec_sql_text(sql_handle) t
where p.spid <> @@spid
order by last_batch
