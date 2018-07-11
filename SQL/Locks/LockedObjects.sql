SELECT DTL.resource_type,  
   CASE   
       WHEN DTL.resource_type IN ('DATABASE', 'FILE', 'METADATA') THEN DTL.resource_type  
       WHEN DTL.resource_type = 'OBJECT' THEN OBJECT_NAME(DTL.resource_associated_entity_id, SP.[dbid])  
       WHEN DTL.resource_type IN ('KEY', 'PAGE', 'RID') THEN   
           (  
           SELECT OBJECT_NAME([object_id])  
           FROM sys.partitions  
           WHERE sys.partitions.hobt_id =   
             DTL.resource_associated_entity_id  
           )  
       ELSE DTL.resource_description
   END AS requested_object_name, DTL.request_mode, DTL.request_status,  
   DEST.TEXT,
   STMT = case when req.statement_end_offset > 0 then SUBSTRING(DEST.TEXT, req.statement_start_offset/2+1, (req.statement_end_offset - req.statement_start_offset)/2) else null end,
   SP.spid, SP.blocked, SP.status, SP.loginame,
   req.command,
   req.wait_time,
   req.total_elapsed_time
FROM sys.dm_tran_locks DTL  
   INNER JOIN sys.sysprocesses SP ON DTL.request_session_id = SP.spid   
   CROSS APPLY sys.dm_exec_sql_text(SP.sql_handle) AS DEST  
   LEFT OUTER JOIN sys.dm_exec_requests AS req ON SP.spid = req.session_id
WHERE DTL.[resource_type] <> 'DATABASE' -- and SP.dbid = DB_ID()
ORDER BY DTL.[request_session_id];
