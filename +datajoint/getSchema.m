function obj = getSchema
persistent schemaObject
if isempty(schemaObject)
    schemaObject = dj.Schema(dj.conn, 'datajoint', 'group_suite2p_1');
end
obj = schemaObject;
end
