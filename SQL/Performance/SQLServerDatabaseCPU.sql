/*****	Script: Database Wise CPU Utilization report *****/
/*****	Support: SQL Server 2008 and Above *****/
/*****	TestedOn: SQL Server 2008 R2 and 2014 *****/
/*****	Output: 
SNO: Serial Number
DBName: Databse Name 
CPU_Time(Ms): CPU Time in Milliseconds
CPUPercent: Let’s say this instance is using 50% CPU and one of the database is      using 80%. It means the actual CPU usage from the database is calculated as: (80 / 100) * 50 = 40 %
*****/
WITH DB_CPU AS
(SELECT	DatabaseID, 
		DB_Name(DatabaseID)AS [DatabaseName], 
		SUM(total_worker_time)AS [CPU_Time(Ms)] 
FROM	sys.dm_exec_query_stats AS qs 
CROSS APPLY(SELECT	CONVERT(int, value)AS [DatabaseID]  
			FROM	sys.dm_exec_plan_attributes(qs.plan_handle)  
			WHERE	attribute =N'dbid')AS epa GROUP BY DatabaseID) 
SELECT	ROW_NUMBER()OVER(ORDER BY [CPU_Time(Ms)] DESC)AS [SNO], 
	DatabaseName AS [DBName], [CPU_Time(Ms)], 
	CAST([CPU_Time(Ms)] * 1.0 /SUM([CPU_Time(Ms)]) OVER()* 100.0 AS DECIMAL(5, 2))AS [CPUPercent] 
FROM	DB_CPU 
WHERE	DatabaseID > 4 -- system databases 
	AND DatabaseID <> 32767 -- ResourceDB 
ORDER BY SNO OPTION(RECOMPILE); 
