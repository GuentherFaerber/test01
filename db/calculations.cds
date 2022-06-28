using {
    managed,
    Currency,
    temporal,
    Country,
    extensible,
    sap.common.CodeList
} from '@sap/cds/common';

using {
    GUID,
    Description,
    Check,
    Field,
    Function,
    Sequence,
    IncludeInputData,
    IncludeInitialResult,
    ResultHandlings,
    Rule,
    IsActive,
    ParentRule,
} from './commonTypes';
using {
    function,
    functionExecutable,
    field,
    formulaOrder,
    selection,
    formulaGroupOrder,
    signatureGSA,
} from './commonAspects';
using {
    Functions,
    FunctionChecks
} from './functions';
using {
    Fields,
    FieldType,
    FieldClass,
} from './fields';
using {Checks} from './checks';

entity Calculations : managed, functionExecutable {
    key ID              : GUID                                @Common.Text : function.description  @Common.TextArrangement : #TextOnly;
        type            : Association to one CalculationTypes @title       : 'Type';
        signatureFields : Composition of many CalculationSignatureFields
                              on signatureFields.calculation = $self;
}

entity CalculationRules: managed, function {
    key ID: GUID                              @Common.Text : description  @Common.TextArrangement : #TextOnly;
    description: Description;
}
entity CalculationSignatureFields : managed, function, signatureGSA {
    key ID          : GUID;
        calculation : Association to one Calculations;
}

type CalculationType @(assert.range) : String(10) @title : 'Type' enum {
    Relative = 'RELATIVE';
    Absolute = 'ABSOLUTE';
    Workbook = 'WORKBOOK';
}

entity CalculationTypes : CodeList {
    key code : CalculationType default 'RELATIVE';
}
