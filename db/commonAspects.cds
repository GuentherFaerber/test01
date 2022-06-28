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
  Function,
  Sequence,
  Field,
  Groups,
  Orders,
  Signs,
  Options,
  IncludeInputData,
  IncludeInitialResult,
  ResultHandlings,
} from './commonTypes';

using {
  ResultFunctions,
  InputFields
} from './commonEntities';
using {Environments} from './environments';
using {
  Functions,
  FunctionProcessingTypes,
  FunctionBusinessEventTypes
} from './functions';
using {Fields} from './fields';
using {Checks} from './checks';
using {Partitions} from './partitions';

// aspect myCodeList @(
//   cds.autoexpose,
//   cds.persistence.skip : 'if-unused',
//   cds.odata.valuelist,
// // UI.Identification    : [{Value : name}],
// ) {
//   name  : String(255)  @title : '{i18n>Name}';
//   descr : String(1000) @title : '{i18n>Description}';
// }

// @cds.persistence.journal // Enable schema evolution for all environment configuration tables
aspect environment : {
  environment : Association to one Environments @title : 'Environment'  @mandatory;
}

aspect function : environment {
  function : Association to one Functions @title : 'Function'  @mandatory;
}

aspect field : environment {
  field : Association to one Fields @mandatory;
}

aspect check : environment {
  check : Association to one Checks @mandatory;
}

aspect functionExecutable : function {
  includeInputData     : IncludeInputData default false;
  resultHandling       : Association to one ResultHandlings            @title : 'Result Handling';
  includeInitialResult : IncludeInitialResult default false;
  resultFunction       : Association to one ResultFunctions            @title : 'Result Model Table';
  processingType       : Association to one FunctionProcessingTypes    @title : 'Processing Type';
  businessEventType    : Association to one FunctionBusinessEventTypes @title : 'Business Event Type';
  partition            : Association to one Partitions                 @title : 'Partition';
  inputFunction        : Association to one Functions                  @title : 'Sender Input';
  inputFields          : Composition of many InputFields
                           on inputFields.function.ID = function.ID       @title : 'Sender Fields';
}

aspect signatureSA : field {
  selection : Boolean @title : 'Selection Field';
  action    : Boolean @title : 'Action Field';
}

aspect signatureGSA : signatureSA {
  granularity : Boolean @title : 'Granularity Field';
}

aspect formula {
  formula : String @title : 'Formula';
}

aspect formulaGroup : formula {
  ![group] : Association to one Groups @title : 'Group';
}

aspect formulaOrder : formula {
  ![order] : Association to one Orders @title : 'Order';
}

aspect formulaGroupOrder : formulaGroup {
  ![order] : Association to one Orders;
}

aspect selection : {
  seq  : Sequence default 0;
  sign : Association to one Signs   @title : 'Sign'  @mandatory;
  opt  : Association to one Options @title : 'Option'  @mandatory;
  low  : String                     @title : 'Value';
  high : String                     @title : 'High Value';
}
