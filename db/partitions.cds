using {
    managed,
    Currency,
    temporal,
    Country,
    extensible,
    cuid,
    sap.common.CodeList
} from '@sap/cds/common';

using {
    GUID,
    Value,
    Sequence,
    Partition,
    Description
} from './commonTypes';
using {environment} from './commonAspects';
using {Fields} from './fields';

@assert.unique : {
    partition   : [
        environment,
        partition
    ],
    partitionDescription : [
        environment,
        description
    ]
}
@cds.odata.valuelist
@UI.Identification : [{Value : partition}]
entity Partitions : managed, environment {
    key ID          : GUID @Common.Text : description  @Common.TextArrangement : #TextOnly;
        partition   : Partition;
        description : Description;
        field       : Association to one Fields;
        ranges      : Composition of many PartitionRanges
                          on ranges.partition = $self;
}

entity PartitionRanges : managed, environment {
    key ID           : GUID;
        partition    : Association to one Partitions @mandatory;
        range        : Range;
        sequence     : Sequence;
        level        : Level default 0;
        value        : Value;
}

type Range : String @title : 'Range'  @assert.format : '[A-Z,0-9,_]{1,5}';
type Level : Integer @title : 'Level';
