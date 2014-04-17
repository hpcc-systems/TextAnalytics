import indexer;
export wsEntityTypes := function
string insource_id  := '' : stored('source_id');
Unsigned8 ingoodsource_id:=(UNSIGNED8) insource_id;
ds:=table(indexer.datasets.dsEntityList(insource_id='' or ingoodsource_id=source_id),{entity_type},entity_type);
ds1:=project(ds,transform(recordof(ds),
SELF.entity_type:='<option value="' + LEFT.entity_type + '">' + TRIM((STRING)LEFT.entity_type) + '</option>';
SELF:=LEFT;));

set of unicode ret:=set(ds1,entity_type);
return output(ret,named('optionTypes'));
END;