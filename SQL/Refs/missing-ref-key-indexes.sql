select fk.name, OBJECT_NAME(fk.parent_object_id), 
  pc.name, OBJECT_NAME(fk.referenced_object_id), COL_NAME(fk.referenced_object_id, fkc.referenced_column_id)
from sys.foreign_keys fk 
  join sys.foreign_key_columns fkc on fk.object_id=fkc.constraint_object_id
  join sys.columns pc on pc.object_id=fkc.parent_object_id and pc.column_id = fkc.parent_column_id
where fk.referenced_object_id=object_id('tblAgent')
  and not exists(select * from sys.index_columns ic where ic.object_id = fk.parent_object_id and ic.column_id = fkc.parent_column_id)
order by fk.name, 2, pc.column_id
