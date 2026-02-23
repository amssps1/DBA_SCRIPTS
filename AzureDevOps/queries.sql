---


SELECT ci.ContainerId,
c.ArtifactUri,
c.Name,
c.DateCreated,
SUM(fm.FileLength) as Filelength
FROM tbl_ContainerItem ci
JOIN tbl_FileReference f
ON f.FileId = ci.FileId
JOIN tbl_FileMetadata fm
ON fm.PartitionId = 1
AND fm.ResourceId = f.ResourceId 
LEFT JOIN tbl_Container c 
ON c.ContainerId = ci.ContainerId 
AND c.PartitionId = 1 
WHERE f.PartitionId = 1 
AND ci.PartitionId = 1 
GROUP BY ci.ContainerId, c.ArtifactUri, c.Name, c.DateCreated

