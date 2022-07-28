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
  function : Association to one Functions @title : 'Function'  @mandatory
                                                      @(NX.validate : ![environment_ID = $self.environment_ID])
}

aspect field : environment {
  field : Association to one Fields @mandatory;
}

aspect check : environment {
  check : Association to one Checks @mandatory;
}

aspect functionExecutable : function, nxValidate {
  includeInputData     : IncludeInputData default false;
  resultHandling       : Association to one ResultHandlings            @title : 'Result Handling';
  includeInitialResult : IncludeInitialResult default false;
  resultFunction       : Association to one ResultFunctions            @title : 'Result Model Table';
  processingType       : Association to one FunctionProcessingTypes    @title : 'Processing Type';
  businessEventType    : Association to one FunctionBusinessEventTypes @title : 'Business Event Type';
  partition            : Association to one Partitions                 @title : 'Partition';
  inputFunction        : Association to one Functions @title               :    'Sender Input'
                                                      //@NX.assert.recursion :    false
                                                      @(NX.validate : ![(type.code = 'MT' or type.code = 'AL') and ID <> $self.function.ID and environment_ID = $self.environment_ID])
                                                      // @(NX.assert.checkAssocValues : {
                                                      //    association   : 'type',
                                                      //    field         : 'code',
                                                      //    allowedValues : [
                                                      //      'MT',
                                                      //      'AL'
                                                      //    ]
                                                      // })
                                                      // this enhances the the filters of the ValueList. The fields in the CXN refer to
                                                      // the CollectionPath of the ValueList
                                                      // you can define $self. followed by a parameter of the annotated entity. This is replaced by the
                                                      // value of that entity at runtime.
                                                      // @NX.valuehelp : ![(type.code = 'MT' or type.code = 'AL') and ID <> '$self.ID' and environment_ID = $self.environment_ID]
                                                      ;
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

/**
 * nxValidateAnnotions are used within value help dialogs for foreign keys as 
 * well as in before save handler to validate the value defined for foreign keys.
 * They are defined using the @NX.validate annotation
 */
type nxValidateAnnotation: {
  target : String;
  element : String;
  cxn     : String;
}
/**
 * entities which define nexontis validate need to use this aspect. The field in this aspect
 * transports the data of the declaratively defined valuehelp from the using entity to the valuehelp 
 * entity defined via the collectionpath in the valuelist annotation.  
 * It is also used during validation of foreign keys.
 */
aspect nxValidate: {
  //virtual validateDummy : String;
  virtual validateDummyField : String @title : ' ' // @UI.Hidden this annotation does not hide the field from the valuelist but hides it from the resulting SELECT  
}
