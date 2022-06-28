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
    function,
    formulaOrder,
    selection
} from './commonAspects';
using {Environments} from './environments';
using {Functions} from './functions';
using {Fields} from './fields';
using {Checks} from './checks';
using {Partitions} from './partitions';
using {
    GUID,
    Environment,
    Function
} from './commonTypes';

@cds.autoexpose
@cds.odata.valuelist
entity ResultFunctions                                                        as projection on Functions where(
    type.code = 'MT'
);


@cds.autoexpose
@cds.odata.valuelist
entity InputFunctions                                                         as projection on Functions as F where(
    type.code in (
        'MT', 'AL')
    );

@cds.autoexpose
@cds.odata.valuelist
entity inputFunctionsVH(environment_ID : Environment, function_ID : Function) as projection on Functions {
    environment.ID as environment_ID, ID, function, description,  type.code as type_code
}
where(
        environment.ID =  : environment_ID
    and ID             <> : function_ID
    and type.code      in (
        'MT', 'AL')
    );

entity InputFields : managed, function, formulaOrder {
    key ID         : GUID;
        field      : Association to one Fields @title : 'Field';
        selections : Composition of many InputFieldSelections
                         on selections.field = $self;
}

entity InputFieldSelections : managed, function, selection {
    key ID    : GUID;
        field : Association to one InputFields;
}

annotate sap.common.CodeList with @UI.TextArrangement : #TextOnly;
