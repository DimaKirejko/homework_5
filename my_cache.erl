-module(my_cache).
-export([create/1, insert/3, insert/4, lookup/2, delete_obsolete/1]).


create(TableName) ->
    ets:new(TableName, [named_table, set, private]).

insert(TableName, Key, Value) ->
    ets:insert(TableName, {Key, Value}).

insert(TableName, Key, Value, TTL) ->
    ets:insert(TableName, {Key, Value}),
    timer:apply_after(TTL * 1000, my_cache, delete_obsolete, [TableName, Key]).

lookup(TableName, Key) ->
    case ets:lookup(TableName, Key) of
        [] -> undefined;
        [{_, Value}] -> Value
    end.

delete_obsolete(TableName) ->
    Now = calendar:now_to_universal_time_sec(),
    ObsoleteKeys = [Key || {Key, _} <- ets:tab2list(TableName),
                             Now >= calendar:datetime_to_gregorian_seconds(Key + 1)],
    [ets:delete(TableName, Key) || Key <- ObsoleteKeys],
    ok.
