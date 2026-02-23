USE Tfs_COFIDIS_TFSSC2010; -- Replace with your Azure DevOps database name

SELECT 
    b.BuildId,
    b.BuildNumber,
    b.StartTime,
    b.FinishTime,
    b.BuildStatus,
	b.LabelName,
    b.Reason,
	b.DeletionStatus
FROM 
    tbl_Build b
WHERE 
    b.FinishTime < DATEADD(MONTH, -12, GETDATE()) -- Older than 12 months
ORDER BY 
    b.FinishTime ASC;
-----


--DELETE FROM tbl_Build
--WHERE 
--    FinishTime < DATEADD(MONTH, -12, GETDATE()); -- Older than 12 months
