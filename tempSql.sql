
CREATE TABLE Environments (
  createdAt TIMESTAMP_TEXT,
  createdBy NVARCHAR(255),
  modifiedAt TIMESTAMP_TEXT,
  modifiedBy NVARCHAR(255),
  ID NVARCHAR(36) NOT NULL,
  environment NVARCHAR(5000),
  version NVARCHAR(5000),
  description NVARCHAR(5000),
  parent_ID NVARCHAR(36),
  type_code NVARCHAR(5000) DEFAULT 'ENV_VER',
  PRIMARY KEY(ID),
  CONSTRAINT c__Environments_type
  FOREIGN KEY(type_code)
  REFERENCES EnvironmentTypes(code)
  DEFERRABLE INITIALLY DEFERRED,
  CONSTRAINT Environments_environment UNIQUE (environment, version),
  CONSTRAINT Environments_description UNIQUE (description, version)
);

CREATE TABLE EnvironmentTypes (
  name NVARCHAR(255),
  descr NVARCHAR(1000),
  code NVARCHAR(5000) NOT NULL DEFAULT 'ENV_VER',
  PRIMARY KEY(code)
);

CREATE TABLE MessageTypes (
  name NVARCHAR(255),
  descr NVARCHAR(1000),
  code NVARCHAR(1) NOT NULL DEFAULT 'I',
  PRIMARY KEY(code)
);

CREATE TABLE "Groups" (
  name NVARCHAR(255),
  descr NVARCHAR(1000),
  code NVARCHAR(10) NOT NULL DEFAULT '',
  PRIMARY KEY(code)
);

CREATE TABLE Orders (
  name NVARCHAR(255),
  descr NVARCHAR(1000),
  code NVARCHAR(10) NOT NULL DEFAULT '',
  PRIMARY KEY(code)
);

CREATE TABLE Signs (
  name NVARCHAR(255),
  descr NVARCHAR(1000),
  code NVARCHAR(1) NOT NULL DEFAULT 'I',
  PRIMARY KEY(code)
);

CREATE TABLE Options (
  name NVARCHAR(255),
  descr NVARCHAR(1000),
  code NVARCHAR(2) NOT NULL DEFAULT 'EQ',
  PRIMARY KEY(code)
);

CREATE TABLE ResultHandlings (
  name NVARCHAR(255),
  descr NVARCHAR(1000),
  code NVARCHAR(10) NOT NULL DEFAULT 'ENRICHED',
  PRIMARY KEY(code)
);

CREATE TABLE Fields (
  createdAt TIMESTAMP_TEXT,
  createdBy NVARCHAR(255),
  modifiedAt TIMESTAMP_TEXT,
  modifiedBy NVARCHAR(255),
  environment_ID NVARCHAR(36),
  ID NVARCHAR(36) NOT NULL,
  field NVARCHAR(5000),
  class_code NVARCHAR(5000) DEFAULT '',
  type_code NVARCHAR(5000) DEFAULT 'CHA',
  hanaDataType_code NVARCHAR(5000) DEFAULT 'NVARCHAR',
  dataLength INTEGER DEFAULT 16,
  dataDecimals INTEGER DEFAULT 0,
  unitField_ID NVARCHAR(36),
  isLowercase BOOLEAN DEFAULT TRUE,
  hasMasterData BOOLEAN DEFAULT FALSE,
  hasHierarchies BOOLEAN DEFAULT FALSE,
  calculationHierarchy_ID NVARCHAR(36),
  masterDataQuery_ID NVARCHAR(36),
  description NVARCHAR(5000),
  documentation NCLOB,
  PRIMARY KEY(ID),
  CONSTRAINT c__Fields_environment
  FOREIGN KEY(environment_ID)
  REFERENCES Environments(ID)
  DEFERRABLE INITIALLY DEFERRED,
  CONSTRAINT c__Fields_class
  FOREIGN KEY(class_code)
  REFERENCES FieldClasses(code)
  DEFERRABLE INITIALLY DEFERRED,
  CONSTRAINT c__Fields_type
  FOREIGN KEY(type_code)
  REFERENCES FieldTypes(code)
  DEFERRABLE INITIALLY DEFERRED,
  CONSTRAINT c__Fields_hanaDataType
  FOREIGN KEY(hanaDataType_code)
  REFERENCES HanaDataTypes(code)
  DEFERRABLE INITIALLY DEFERRED,
  CONSTRAINT c__Fields_calculationHierarchy
  FOREIGN KEY(calculationHierarchy_ID)
  REFERENCES FieldHierarchies(ID)
  DEFERRABLE INITIALLY DEFERRED,
  CONSTRAINT Fields_field UNIQUE (environment_ID, field),
  CONSTRAINT Fields_description UNIQUE (environment_ID, description)
);

CREATE TABLE FieldValues (
  createdAt TIMESTAMP_TEXT,
  createdBy NVARCHAR(255),
  modifiedAt TIMESTAMP_TEXT,
  modifiedBy NVARCHAR(255),
  environment_ID NVARCHAR(36),
  field_ID NVARCHAR(36),
  ID NVARCHAR(36) NOT NULL,
  value NVARCHAR(5000),
  isNode BOOLEAN,
  description NVARCHAR(5000),
  PRIMARY KEY(ID),
  CONSTRAINT c__FieldValues_environment
  FOREIGN KEY(environment_ID)
  REFERENCES Environments(ID)
  DEFERRABLE INITIALLY DEFERRED,
  CONSTRAINT c__FieldValues_field
  FOREIGN KEY(field_ID)
  REFERENCES Fields(ID)
  ON DELETE CASCADE
  DEFERRABLE INITIALLY DEFERRED
);

CREATE TABLE FieldValueAuthorizations (
  createdAt TIMESTAMP_TEXT,
  createdBy NVARCHAR(255),
  modifiedAt TIMESTAMP_TEXT,
  modifiedBy NVARCHAR(255),
  environment_ID NVARCHAR(36),
  field_ID NVARCHAR(36),
  ID NVARCHAR(36) NOT NULL,
  value_ID NVARCHAR(36),
  userGrp NVARCHAR(5000),
  readAccess BOOLEAN,
  writeAccess BOOLEAN,
  PRIMARY KEY(ID),
  CONSTRAINT c__FieldValueAuthorizations_environment
  FOREIGN KEY(environment_ID)
  REFERENCES Environments(ID)
  DEFERRABLE INITIALLY DEFERRED,
  CONSTRAINT c__FieldValueAuthorizations_field
  FOREIGN KEY(field_ID)
  REFERENCES Fields(ID)
  DEFERRABLE INITIALLY DEFERRED,
  CONSTRAINT c__FieldValueAuthorizations_value
  FOREIGN KEY(value_ID)
  REFERENCES FieldValues(ID)
  ON DELETE CASCADE
  DEFERRABLE INITIALLY DEFERRED
);

CREATE TABLE FieldHierarchies (
  createdAt TIMESTAMP_TEXT,
  createdBy NVARCHAR(255),
  modifiedAt TIMESTAMP_TEXT,
  modifiedBy NVARCHAR(255),
  environment_ID NVARCHAR(36),
  field_ID NVARCHAR(36),
  ID NVARCHAR(36) NOT NULL,
  hierarchy NVARCHAR(5000),
  description NVARCHAR(5000),
  PRIMARY KEY(ID),
  CONSTRAINT c__FieldHierarchies_environment
  FOREIGN KEY(environment_ID)
  REFERENCES Environments(ID)
  DEFERRABLE INITIALLY DEFERRED,
  CONSTRAINT c__FieldHierarchies_field
  FOREIGN KEY(field_ID)
  REFERENCES Fields(ID)
  ON DELETE CASCADE
  DEFERRABLE INITIALLY DEFERRED
);

CREATE TABLE FieldHierarchyStructures (
  createdAt TIMESTAMP_TEXT,
  createdBy NVARCHAR(255),
  modifiedAt TIMESTAMP_TEXT,
  modifiedBy NVARCHAR(255),
  environment_ID NVARCHAR(36),
  field_ID NVARCHAR(36),
  ID NVARCHAR(36) NOT NULL,
  sequence INTEGER,
  hierarchy_ID NVARCHAR(36),
  value_ID NVARCHAR(36),
  parentValue_ID NVARCHAR(36),
  PRIMARY KEY(ID),
  CONSTRAINT c__FieldHierarchyStructures_environment
  FOREIGN KEY(environment_ID)
  REFERENCES Environments(ID)
  DEFERRABLE INITIALLY DEFERRED,
  CONSTRAINT c__FieldHierarchyStructures_field
  FOREIGN KEY(field_ID)
  REFERENCES Fields(ID)
  DEFERRABLE INITIALLY DEFERRED,
  CONSTRAINT c__FieldHierarchyStructures_hierarchy
  FOREIGN KEY(hierarchy_ID)
  REFERENCES FieldHierarchies(ID)
  ON DELETE CASCADE
  DEFERRABLE INITIALLY DEFERRED,
  CONSTRAINT c__FieldHierarchyStructures_value
  FOREIGN KEY(value_ID)
  REFERENCES FieldValues(ID)
  DEFERRABLE INITIALLY DEFERRED,
  CONSTRAINT c__FieldHierarchyStructures_parentValue
  FOREIGN KEY(parentValue_ID)
  REFERENCES FieldValues(ID)
  DEFERRABLE INITIALLY DEFERRED
);

CREATE TABLE FieldClasses (
  name NVARCHAR(255),
  descr NVARCHAR(1000),
  code NVARCHAR(5000) NOT NULL DEFAULT '',
  PRIMARY KEY(code)
);

CREATE TABLE FieldTypes (
  name NVARCHAR(255),
  descr NVARCHAR(1000),
  code NVARCHAR(5000) NOT NULL DEFAULT 'CHA',
  PRIMARY KEY(code)
);

CREATE TABLE HanaDataTypes (
  name NVARCHAR(255),
  descr NVARCHAR(1000),
  code NVARCHAR(5000) NOT NULL DEFAULT 'NVARCHAR',
  PRIMARY KEY(code)
);

CREATE TABLE Checks (
  createdAt TIMESTAMP_TEXT,
  createdBy NVARCHAR(255),
  modifiedAt TIMESTAMP_TEXT,
  modifiedBy NVARCHAR(255),
  environment_ID NVARCHAR(36),
  ID NVARCHAR(36) NOT NULL,
  "check" NVARCHAR(5000),
  messageType_code NVARCHAR(1) DEFAULT 'I',
  category_code NVARCHAR(10) DEFAULT '',
  description NVARCHAR(5000),
  PRIMARY KEY(ID),
  CONSTRAINT c__Checks_environment
  FOREIGN KEY(environment_ID)
  REFERENCES Environments(ID)
  DEFERRABLE INITIALLY DEFERRED,
  CONSTRAINT c__Checks_messageType
  FOREIGN KEY(messageType_code)
  REFERENCES MessageTypes(code)
  DEFERRABLE INITIALLY DEFERRED,
  CONSTRAINT c__Checks_category
  FOREIGN KEY(category_code)
  REFERENCES CheckCategories(code)
  DEFERRABLE INITIALLY DEFERRED,
  CONSTRAINT Checks_description UNIQUE (environment_ID, description)
);

CREATE TABLE CheckFields (
  createdAt TIMESTAMP_TEXT,
  createdBy NVARCHAR(255),
  modifiedAt TIMESTAMP_TEXT,
  modifiedBy NVARCHAR(255),
  ID NVARCHAR(36) NOT NULL,
  check_ID NVARCHAR(36),
  field_ID NVARCHAR(36),
  PRIMARY KEY(ID),
  CONSTRAINT c__CheckFields_check
  FOREIGN KEY(check_ID)
  REFERENCES Checks(ID)
  ON DELETE CASCADE
  DEFERRABLE INITIALLY DEFERRED,
  CONSTRAINT c__CheckFields_field
  FOREIGN KEY(field_ID)
  REFERENCES Fields(ID)
  DEFERRABLE INITIALLY DEFERRED
);

CREATE TABLE CheckSelections (
  createdAt TIMESTAMP_TEXT,
  createdBy NVARCHAR(255),
  modifiedAt TIMESTAMP_TEXT,
  modifiedBy NVARCHAR(255),
  seq INTEGER DEFAULT 0,
  sign_code NVARCHAR(1) DEFAULT 'I',
  opt_code NVARCHAR(2) DEFAULT 'EQ',
  low NVARCHAR(5000),
  high NVARCHAR(5000),
  ID NVARCHAR(36) NOT NULL,
  field_ID NVARCHAR(36),
  PRIMARY KEY(ID),
  CONSTRAINT c__CheckSelections_sign
  FOREIGN KEY(sign_code)
  REFERENCES Signs(code)
  DEFERRABLE INITIALLY DEFERRED,
  CONSTRAINT c__CheckSelections_opt
  FOREIGN KEY(opt_code)
  REFERENCES Options(code)
  DEFERRABLE INITIALLY DEFERRED,
  CONSTRAINT c__CheckSelections_field
  FOREIGN KEY(field_ID)
  REFERENCES CheckFields(ID)
  ON DELETE CASCADE
  DEFERRABLE INITIALLY DEFERRED
);

CREATE TABLE CheckCategories (
  name NVARCHAR(255),
  descr NVARCHAR(1000),
  code NVARCHAR(10) NOT NULL DEFAULT '',
  PRIMARY KEY(code)
);

CREATE TABLE CurrencyConversions (
  createdAt TIMESTAMP_TEXT,
  createdBy NVARCHAR(255),
  modifiedAt TIMESTAMP_TEXT,
  modifiedBy NVARCHAR(255),
  environment_ID NVARCHAR(36),
  ID NVARCHAR(36) NOT NULL,
  currencyConversion NVARCHAR(5000),
  description NVARCHAR(5000),
  category_code NVARCHAR(5000) DEFAULT 'CURRENCY',
  method_code NVARCHAR(5000) DEFAULT 'ERP',
  bidAskType_code NVARCHAR(5000) DEFAULT 'MID',
  marketDataArea NVARCHAR(5000),
  type NVARCHAR(5000),
  lookup_code NVARCHAR(5000) DEFAULT 'Regular',
  errorHandling_code NVARCHAR(5000) DEFAULT 'fail on error',
  accuracy_code NVARCHAR(5000) DEFAULT '',
  dateFormat_code NVARCHAR(5000) DEFAULT 'auto detect',
  steps_code NVARCHAR(5000) DEFAULT 'shift,convert',
  configurationConnection_ID NVARCHAR(36),
  rateConnection_ID NVARCHAR(36),
  prefactorConnection_ID NVARCHAR(36),
  PRIMARY KEY(ID),
  CONSTRAINT c__CurrencyConversions_environment
  FOREIGN KEY(environment_ID)
  REFERENCES Environments(ID)
  DEFERRABLE INITIALLY DEFERRED,
  CONSTRAINT c__CurrencyConversions_category
  FOREIGN KEY(category_code)
  REFERENCES ConversionCategories(code)
  DEFERRABLE INITIALLY DEFERRED,
  CONSTRAINT c__CurrencyConversions_method
  FOREIGN KEY(method_code)
  REFERENCES ConversionMethods(code)
  DEFERRABLE INITIALLY DEFERRED,
  CONSTRAINT c__CurrencyConversions_bidAskType
  FOREIGN KEY(bidAskType_code)
  REFERENCES ConversionBidAskTypes(code)
  DEFERRABLE INITIALLY DEFERRED,
  CONSTRAINT c__CurrencyConversions_lookup
  FOREIGN KEY(lookup_code)
  REFERENCES ConversionLookups(code)
  DEFERRABLE INITIALLY DEFERRED,
  CONSTRAINT c__CurrencyConversions_errorHandling
  FOREIGN KEY(errorHandling_code)
  REFERENCES ConversionErrorHandlings(code)
  DEFERRABLE INITIALLY DEFERRED,
  CONSTRAINT c__CurrencyConversions_accuracy
  FOREIGN KEY(accuracy_code)
  REFERENCES ConversionAccuracies(code)
  DEFERRABLE INITIALLY DEFERRED,
  CONSTRAINT c__CurrencyConversions_dateFormat
  FOREIGN KEY(dateFormat_code)
  REFERENCES ConversionDateFormats(code)
  DEFERRABLE INITIALLY DEFERRED,
  CONSTRAINT c__CurrencyConversions_steps
  FOREIGN KEY(steps_code)
  REFERENCES ConversionSteps(code)
  DEFERRABLE INITIALLY DEFERRED,
  CONSTRAINT c__CurrencyConversions_configurationConnection
  FOREIGN KEY(configurationConnection_ID)
  REFERENCES Connections(ID)
  DEFERRABLE INITIALLY DEFERRED,
  CONSTRAINT c__CurrencyConversions_rateConnection
  FOREIGN KEY(rateConnection_ID)
  REFERENCES Connections(ID)
  DEFERRABLE INITIALLY DEFERRED,
  CONSTRAINT c__CurrencyConversions_prefactorConnection
  FOREIGN KEY(prefactorConnection_ID)
  REFERENCES Connections(ID)
  DEFERRABLE INITIALLY DEFERRED,
  CONSTRAINT CurrencyConversions_currencyConversion UNIQUE (environment_ID, currencyConversion),
  CONSTRAINT CurrencyConversions_description UNIQUE (environment_ID, description)
);

CREATE TABLE UnitConversions (
  createdAt TIMESTAMP_TEXT,
  createdBy NVARCHAR(255),
  modifiedAt TIMESTAMP_TEXT,
  modifiedBy NVARCHAR(255),
  environment_ID NVARCHAR(36),
  ID NVARCHAR(36) NOT NULL,
  unitConversion NVARCHAR(5000),
  description NVARCHAR(5000),
  errorHandling_code NVARCHAR(5000) DEFAULT 'fail on error',
  rateConnection_ID NVARCHAR(36),
  dimensionConnection_ID NVARCHAR(36),
  PRIMARY KEY(ID),
  CONSTRAINT c__UnitConversions_environment
  FOREIGN KEY(environment_ID)
  REFERENCES Environments(ID)
  DEFERRABLE INITIALLY DEFERRED,
  CONSTRAINT c__UnitConversions_errorHandling
  FOREIGN KEY(errorHandling_code)
  REFERENCES ConversionErrorHandlings(code)
  DEFERRABLE INITIALLY DEFERRED,
  CONSTRAINT c__UnitConversions_rateConnection
  FOREIGN KEY(rateConnection_ID)
  REFERENCES Connections(ID)
  DEFERRABLE INITIALLY DEFERRED,
  CONSTRAINT c__UnitConversions_dimensionConnection
  FOREIGN KEY(dimensionConnection_ID)
  REFERENCES Connections(ID)
  DEFERRABLE INITIALLY DEFERRED,
  CONSTRAINT UnitConversions_unitConversion UNIQUE (environment_ID, unitConversion),
  CONSTRAINT UnitConversions_description UNIQUE (environment_ID, description)
);

CREATE TABLE ConversionCategories (
  createdAt TIMESTAMP_TEXT,
  createdBy NVARCHAR(255),
  modifiedAt TIMESTAMP_TEXT,
  modifiedBy NVARCHAR(255),
  code NVARCHAR(5000) NOT NULL DEFAULT 'CURRENCY',
  PRIMARY KEY(code)
);

CREATE TABLE ConversionMethods (
  createdAt TIMESTAMP_TEXT,
  createdBy NVARCHAR(255),
  modifiedAt TIMESTAMP_TEXT,
  modifiedBy NVARCHAR(255),
  code NVARCHAR(5000) NOT NULL DEFAULT 'ERP',
  PRIMARY KEY(code)
);

CREATE TABLE ConversionBidAskTypes (
  createdAt TIMESTAMP_TEXT,
  createdBy NVARCHAR(255),
  modifiedAt TIMESTAMP_TEXT,
  modifiedBy NVARCHAR(255),
  code NVARCHAR(5000) NOT NULL DEFAULT 'MID',
  PRIMARY KEY(code)
);

CREATE TABLE ConversionLookups (
  createdAt TIMESTAMP_TEXT,
  createdBy NVARCHAR(255),
  modifiedAt TIMESTAMP_TEXT,
  modifiedBy NVARCHAR(255),
  code NVARCHAR(5000) NOT NULL DEFAULT 'Regular',
  PRIMARY KEY(code)
);

CREATE TABLE ConversionErrorHandlings (
  createdAt TIMESTAMP_TEXT,
  createdBy NVARCHAR(255),
  modifiedAt TIMESTAMP_TEXT,
  modifiedBy NVARCHAR(255),
  code NVARCHAR(5000) NOT NULL DEFAULT 'fail on error',
  PRIMARY KEY(code)
);

CREATE TABLE ConversionAccuracies (
  createdAt TIMESTAMP_TEXT,
  createdBy NVARCHAR(255),
  modifiedAt TIMESTAMP_TEXT,
  modifiedBy NVARCHAR(255),
  code NVARCHAR(5000) NOT NULL DEFAULT '',
  PRIMARY KEY(code)
);

CREATE TABLE ConversionDateFormats (
  createdAt TIMESTAMP_TEXT,
  createdBy NVARCHAR(255),
  modifiedAt TIMESTAMP_TEXT,
  modifiedBy NVARCHAR(255),
  code NVARCHAR(5000) NOT NULL DEFAULT 'auto detect',
  PRIMARY KEY(code)
);

CREATE TABLE ConversionSteps (
  createdAt TIMESTAMP_TEXT,
  createdBy NVARCHAR(255),
  modifiedAt TIMESTAMP_TEXT,
  modifiedBy NVARCHAR(255),
  code NVARCHAR(5000) NOT NULL DEFAULT 'shift,convert',
  PRIMARY KEY(code)
);

CREATE TABLE Partitions (
  createdAt TIMESTAMP_TEXT,
  createdBy NVARCHAR(255),
  modifiedAt TIMESTAMP_TEXT,
  modifiedBy NVARCHAR(255),
  environment_ID NVARCHAR(36),
  ID NVARCHAR(36) NOT NULL,
  "partition" NVARCHAR(5000),
  description NVARCHAR(5000),
  field_ID NVARCHAR(36),
  PRIMARY KEY(ID),
  CONSTRAINT c__Partitions_environment
  FOREIGN KEY(environment_ID)
  REFERENCES Environments(ID)
  DEFERRABLE INITIALLY DEFERRED,
  CONSTRAINT c__Partitions_field
  FOREIGN KEY(field_ID)
  REFERENCES Fields(ID)
  DEFERRABLE INITIALLY DEFERRED,
  CONSTRAINT Partitions_partition UNIQUE (environment_ID, "partition"),
  CONSTRAINT Partitions_description UNIQUE (environment_ID, description)
);

CREATE TABLE PartitionRanges (
  createdAt TIMESTAMP_TEXT,
  createdBy NVARCHAR(255),
  modifiedAt TIMESTAMP_TEXT,
  modifiedBy NVARCHAR(255),
  environment_ID NVARCHAR(36),
  ID NVARCHAR(36) NOT NULL,
  partition_ID NVARCHAR(36),
  "range" NVARCHAR(5000),
  sequence INTEGER,
  level INTEGER DEFAULT 0,
  value NVARCHAR(5000),
  hanaVolumeId INTEGER DEFAULT 0,
  PRIMARY KEY(ID),
  CONSTRAINT c__PartitionRanges_environment
  FOREIGN KEY(environment_ID)
  REFERENCES Environments(ID)
  DEFERRABLE INITIALLY DEFERRED,
  CONSTRAINT c__PartitionRanges_partition
  FOREIGN KEY(partition_ID)
  REFERENCES Partitions(ID)
  ON DELETE CASCADE
  DEFERRABLE INITIALLY DEFERRED
);

CREATE TABLE Functions (
  createdAt TIMESTAMP_TEXT,
  createdBy NVARCHAR(255),
  modifiedAt TIMESTAMP_TEXT,
  modifiedBy NVARCHAR(255),
  environment_ID NVARCHAR(36),
  ID NVARCHAR(36) NOT NULL,
  function NVARCHAR(5000),
  sequence INTEGER DEFAULT 10,
  parent_ID NVARCHAR(36),
  type_code NVARCHAR(10) DEFAULT 'MT',
  description NVARCHAR(5000),
  documentation NCLOB,
  PRIMARY KEY(ID),
  CONSTRAINT c__Functions_environment
  FOREIGN KEY(environment_ID)
  REFERENCES Environments(ID)
  DEFERRABLE INITIALLY DEFERRED,
  CONSTRAINT c__Functions_type
  FOREIGN KEY(type_code)
  REFERENCES FunctionTypes(code)
  DEFERRABLE INITIALLY DEFERRED,
  CONSTRAINT Functions_function UNIQUE (environment_ID, function),
  CONSTRAINT Functions_description UNIQUE (environment_ID, description)
);

CREATE TABLE FunctionTypes (
  name NVARCHAR(255),
  descr NVARCHAR(1000),
  code NVARCHAR(10) NOT NULL DEFAULT 'MT',
  PRIMARY KEY(code)
);

CREATE TABLE FunctionProcessingTypes (
  name NVARCHAR(255),
  descr NVARCHAR(1000),
  code NVARCHAR(10) NOT NULL DEFAULT '',
  PRIMARY KEY(code)
);

CREATE TABLE FunctionBusinessEventTypes (
  name NVARCHAR(255),
  descr NVARCHAR(1000),
  code NVARCHAR(10) NOT NULL DEFAULT '',
  PRIMARY KEY(code)
);

CREATE TABLE Connections (
  createdAt TIMESTAMP_TEXT,
  createdBy NVARCHAR(255),
  modifiedAt TIMESTAMP_TEXT,
  modifiedBy NVARCHAR(255),
  environment_ID NVARCHAR(36),
  ID NVARCHAR(36) NOT NULL,
  connection NVARCHAR(5000),
  description NVARCHAR(5000),
  PRIMARY KEY(ID),
  CONSTRAINT c__Connections_environment
  FOREIGN KEY(environment_ID)
  REFERENCES Environments(ID)
  DEFERRABLE INITIALLY DEFERRED,
  CONSTRAINT Connections_description UNIQUE (environment_ID, description)
);

CREATE TABLE Allocations (
  createdAt TIMESTAMP_TEXT,
  createdBy NVARCHAR(255),
  modifiedAt TIMESTAMP_TEXT,
  modifiedBy NVARCHAR(255),
  environment_ID NVARCHAR(36),
  function_ID NVARCHAR(36),
  includeInputData BOOLEAN DEFAULT FALSE,
  resultHandling_code NVARCHAR(10) DEFAULT 'ENRICHED',
  includeInitialResult BOOLEAN DEFAULT FALSE,
  resultFunction_ID NVARCHAR(36),
  processingType_code NVARCHAR(10) DEFAULT '',
  businessEventType_code NVARCHAR(10) DEFAULT '',
  partition_ID NVARCHAR(36),
  ID NVARCHAR(36) NOT NULL,
  type_code NVARCHAR(10) DEFAULT 'ALLOC',
  valueAdjustment_code NVARCHAR(10) DEFAULT '',
  cycleFlag BOOLEAN DEFAULT FALSE,
  cycleMaximum NVARCHAR(5000) DEFAULT '',
  cycleIterationField_ID NVARCHAR(36),
  cycleAggregation_code NVARCHAR(10) DEFAULT '',
  termFlag BOOLEAN DEFAULT FALSE,
  termIterationField_ID NVARCHAR(36),
  termYearField_ID NVARCHAR(36),
  termField_ID NVARCHAR(36),
  termProcessing_code NVARCHAR(10) DEFAULT '',
  termYear NVARCHAR(5000),
  termMinimum NVARCHAR(5000),
  termMaximum NVARCHAR(5000),
  senderFunction_ID NVARCHAR(36),
  receiverFunction_ID NVARCHAR(36),
  earlyExitCheck_ID NVARCHAR(36),
  PRIMARY KEY(ID),
  CONSTRAINT c__Allocations_environment
  FOREIGN KEY(environment_ID)
  REFERENCES Environments(ID)
  DEFERRABLE INITIALLY DEFERRED,
  CONSTRAINT c__Allocations_function
  FOREIGN KEY(function_ID)
  REFERENCES Functions(ID)
  DEFERRABLE INITIALLY DEFERRED,
  CONSTRAINT c__Allocations_resultHandling
  FOREIGN KEY(resultHandling_code)
  REFERENCES ResultHandlings(code)
  DEFERRABLE INITIALLY DEFERRED,
  CONSTRAINT c__Allocations_processingType
  FOREIGN KEY(processingType_code)
  REFERENCES FunctionProcessingTypes(code)
  DEFERRABLE INITIALLY DEFERRED,
  CONSTRAINT c__Allocations_businessEventType
  FOREIGN KEY(businessEventType_code)
  REFERENCES FunctionBusinessEventTypes(code)
  DEFERRABLE INITIALLY DEFERRED,
  CONSTRAINT c__Allocations_partition
  FOREIGN KEY(partition_ID)
  REFERENCES Partitions(ID)
  DEFERRABLE INITIALLY DEFERRED,
  CONSTRAINT c__Allocations_type
  FOREIGN KEY(type_code)
  REFERENCES AllocationTypes(code)
  DEFERRABLE INITIALLY DEFERRED,
  CONSTRAINT c__Allocations_valueAdjustment
  FOREIGN KEY(valueAdjustment_code)
  REFERENCES AllocationValueAdjustments(code)
  DEFERRABLE INITIALLY DEFERRED,
  CONSTRAINT c__Allocations_cycleAggregation
  FOREIGN KEY(cycleAggregation_code)
  REFERENCES AllocationCycleAggregations(code)
  DEFERRABLE INITIALLY DEFERRED,
  CONSTRAINT c__Allocations_termProcessing
  FOREIGN KEY(termProcessing_code)
  REFERENCES AllocationTermProcessings(code)
  DEFERRABLE INITIALLY DEFERRED,
  CONSTRAINT c__Allocations_senderFunction
  FOREIGN KEY(senderFunction_ID)
  REFERENCES Functions(ID)
  DEFERRABLE INITIALLY DEFERRED
);

CREATE TABLE AllocationSenderViews (
  createdAt TIMESTAMP_TEXT,
  createdBy NVARCHAR(255),
  modifiedAt TIMESTAMP_TEXT,
  modifiedBy NVARCHAR(255),
  environment_ID NVARCHAR(36),
  function_ID NVARCHAR(36),
  formula NVARCHAR(5000),
  order_code NVARCHAR(10) DEFAULT '',
  ID NVARCHAR(36) NOT NULL,
  allocation_ID NVARCHAR(36),
  field_ID NVARCHAR(36),
  PRIMARY KEY(ID),
  CONSTRAINT c__AllocationSenderViews_environment
  FOREIGN KEY(environment_ID)
  REFERENCES Environments(ID)
  DEFERRABLE INITIALLY DEFERRED,
  CONSTRAINT c__AllocationSenderViews_function
  FOREIGN KEY(function_ID)
  REFERENCES Functions(ID)
  DEFERRABLE INITIALLY DEFERRED,
  CONSTRAINT c__AllocationSenderViews_order
  FOREIGN KEY(order_code)
  REFERENCES Orders(code)
  DEFERRABLE INITIALLY DEFERRED,
  CONSTRAINT c__AllocationSenderViews_allocation
  FOREIGN KEY(allocation_ID)
  REFERENCES Allocations(ID)
  ON DELETE CASCADE
  DEFERRABLE INITIALLY DEFERRED,
  CONSTRAINT c__AllocationSenderViews_field
  FOREIGN KEY(field_ID)
  REFERENCES Fields(ID)
  DEFERRABLE INITIALLY DEFERRED
);

CREATE TABLE AllocationSenderViewSelections (
  createdAt TIMESTAMP_TEXT,
  createdBy NVARCHAR(255),
  modifiedAt TIMESTAMP_TEXT,
  modifiedBy NVARCHAR(255),
  environment_ID NVARCHAR(36),
  function_ID NVARCHAR(36),
  seq INTEGER DEFAULT 0,
  sign_code NVARCHAR(1) DEFAULT 'I',
  opt_code NVARCHAR(2) DEFAULT 'EQ',
  low NVARCHAR(5000),
  high NVARCHAR(5000),
  ID NVARCHAR(36) NOT NULL,
  field_ID NVARCHAR(36),
  PRIMARY KEY(ID),
  CONSTRAINT c__AllocationSenderViewSelections_environment
  FOREIGN KEY(environment_ID)
  REFERENCES Environments(ID)
  DEFERRABLE INITIALLY DEFERRED,
  CONSTRAINT c__AllocationSenderViewSelections_function
  FOREIGN KEY(function_ID)
  REFERENCES Functions(ID)
  DEFERRABLE INITIALLY DEFERRED,
  CONSTRAINT c__AllocationSenderViewSelections_sign
  FOREIGN KEY(sign_code)
  REFERENCES Signs(code)
  DEFERRABLE INITIALLY DEFERRED,
  CONSTRAINT c__AllocationSenderViewSelections_opt
  FOREIGN KEY(opt_code)
  REFERENCES Options(code)
  DEFERRABLE INITIALLY DEFERRED,
  CONSTRAINT c__AllocationSenderViewSelections_field
  FOREIGN KEY(field_ID)
  REFERENCES AllocationSenderViews(ID)
  ON DELETE CASCADE
  DEFERRABLE INITIALLY DEFERRED
);

CREATE TABLE AllocationReceiverViews (
  createdAt TIMESTAMP_TEXT,
  createdBy NVARCHAR(255),
  modifiedAt TIMESTAMP_TEXT,
  modifiedBy NVARCHAR(255),
  environment_ID NVARCHAR(36),
  function_ID NVARCHAR(36),
  formula NVARCHAR(5000),
  order_code NVARCHAR(10) DEFAULT '',
  ID NVARCHAR(36) NOT NULL,
  allocation_ID NVARCHAR(36),
  field_ID NVARCHAR(36),
  PRIMARY KEY(ID),
  CONSTRAINT c__AllocationReceiverViews_environment
  FOREIGN KEY(environment_ID)
  REFERENCES Environments(ID)
  DEFERRABLE INITIALLY DEFERRED,
  CONSTRAINT c__AllocationReceiverViews_function
  FOREIGN KEY(function_ID)
  REFERENCES Functions(ID)
  DEFERRABLE INITIALLY DEFERRED,
  CONSTRAINT c__AllocationReceiverViews_order
  FOREIGN KEY(order_code)
  REFERENCES Orders(code)
  DEFERRABLE INITIALLY DEFERRED,
  CONSTRAINT c__AllocationReceiverViews_allocation
  FOREIGN KEY(allocation_ID)
  REFERENCES Allocations(ID)
  ON DELETE CASCADE
  DEFERRABLE INITIALLY DEFERRED,
  CONSTRAINT c__AllocationReceiverViews_field
  FOREIGN KEY(field_ID)
  REFERENCES Fields(ID)
  DEFERRABLE INITIALLY DEFERRED
);

CREATE TABLE AllocationReceiverViewSelections (
  createdAt TIMESTAMP_TEXT,
  createdBy NVARCHAR(255),
  modifiedAt TIMESTAMP_TEXT,
  modifiedBy NVARCHAR(255),
  environment_ID NVARCHAR(36),
  function_ID NVARCHAR(36),
  seq INTEGER DEFAULT 0,
  sign_code NVARCHAR(1) DEFAULT 'I',
  opt_code NVARCHAR(2) DEFAULT 'EQ',
  low NVARCHAR(5000),
  high NVARCHAR(5000),
  ID NVARCHAR(36) NOT NULL,
  field_ID NVARCHAR(36),
  PRIMARY KEY(ID),
  CONSTRAINT c__AllocationReceiverViewSelections_environment
  FOREIGN KEY(environment_ID)
  REFERENCES Environments(ID)
  DEFERRABLE INITIALLY DEFERRED,
  CONSTRAINT c__AllocationReceiverViewSelections_function
  FOREIGN KEY(function_ID)
  REFERENCES Functions(ID)
  DEFERRABLE INITIALLY DEFERRED,
  CONSTRAINT c__AllocationReceiverViewSelections_sign
  FOREIGN KEY(sign_code)
  REFERENCES Signs(code)
  DEFERRABLE INITIALLY DEFERRED,
  CONSTRAINT c__AllocationReceiverViewSelections_opt
  FOREIGN KEY(opt_code)
  REFERENCES Options(code)
  DEFERRABLE INITIALLY DEFERRED,
  CONSTRAINT c__AllocationReceiverViewSelections_field
  FOREIGN KEY(field_ID)
  REFERENCES AllocationReceiverViews(ID)
  ON DELETE CASCADE
  DEFERRABLE INITIALLY DEFERRED
);

CREATE TABLE AllocationOffsets (
  createdAt TIMESTAMP_TEXT,
  createdBy NVARCHAR(255),
  modifiedAt TIMESTAMP_TEXT,
  modifiedBy NVARCHAR(255),
  environment_ID NVARCHAR(36),
  function_ID NVARCHAR(36),
  ID NVARCHAR(36) NOT NULL,
  allocation_ID NVARCHAR(36),
  field_ID NVARCHAR(36),
  offsetField_ID NVARCHAR(36),
  PRIMARY KEY(ID),
  CONSTRAINT c__AllocationOffsets_environment
  FOREIGN KEY(environment_ID)
  REFERENCES Environments(ID)
  DEFERRABLE INITIALLY DEFERRED,
  CONSTRAINT c__AllocationOffsets_function
  FOREIGN KEY(function_ID)
  REFERENCES Functions(ID)
  DEFERRABLE INITIALLY DEFERRED,
  CONSTRAINT c__AllocationOffsets_allocation
  FOREIGN KEY(allocation_ID)
  REFERENCES Allocations(ID)
  ON DELETE CASCADE
  DEFERRABLE INITIALLY DEFERRED,
  CONSTRAINT c__AllocationOffsets_field
  FOREIGN KEY(field_ID)
  REFERENCES Fields(ID)
  DEFERRABLE INITIALLY DEFERRED,
  CONSTRAINT c__AllocationOffsets_offsetField
  FOREIGN KEY(offsetField_ID)
  REFERENCES Fields(ID)
  DEFERRABLE INITIALLY DEFERRED
);

CREATE TABLE AllocationDebitCredits (
  createdAt TIMESTAMP_TEXT,
  createdBy NVARCHAR(255),
  modifiedAt TIMESTAMP_TEXT,
  modifiedBy NVARCHAR(255),
  environment_ID NVARCHAR(36),
  function_ID NVARCHAR(36),
  ID NVARCHAR(36) NOT NULL,
  allocation_ID NVARCHAR(36),
  field_ID NVARCHAR(36),
  debitSign NVARCHAR(5000),
  creditSign NVARCHAR(5000),
  sequence INTEGER,
  PRIMARY KEY(ID),
  CONSTRAINT c__AllocationDebitCredits_environment
  FOREIGN KEY(environment_ID)
  REFERENCES Environments(ID)
  DEFERRABLE INITIALLY DEFERRED,
  CONSTRAINT c__AllocationDebitCredits_function
  FOREIGN KEY(function_ID)
  REFERENCES Functions(ID)
  DEFERRABLE INITIALLY DEFERRED,
  CONSTRAINT c__AllocationDebitCredits_allocation
  FOREIGN KEY(allocation_ID)
  REFERENCES Allocations(ID)
  ON DELETE CASCADE
  DEFERRABLE INITIALLY DEFERRED,
  CONSTRAINT c__AllocationDebitCredits_field
  FOREIGN KEY(field_ID)
  REFERENCES Fields(ID)
  DEFERRABLE INITIALLY DEFERRED
);

CREATE TABLE AllocationChecks (
  createdAt TIMESTAMP_TEXT,
  createdBy NVARCHAR(255),
  modifiedAt TIMESTAMP_TEXT,
  modifiedBy NVARCHAR(255),
  environment_ID NVARCHAR(36),
  function_ID NVARCHAR(36),
  ID NVARCHAR(36) NOT NULL,
  allocation_ID NVARCHAR(36),
  check_ID NVARCHAR(36),
  PRIMARY KEY(ID),
  CONSTRAINT c__AllocationChecks_environment
  FOREIGN KEY(environment_ID)
  REFERENCES Environments(ID)
  DEFERRABLE INITIALLY DEFERRED,
  CONSTRAINT c__AllocationChecks_function
  FOREIGN KEY(function_ID)
  REFERENCES Functions(ID)
  DEFERRABLE INITIALLY DEFERRED,
  CONSTRAINT c__AllocationChecks_allocation
  FOREIGN KEY(allocation_ID)
  REFERENCES Allocations(ID)
  ON DELETE CASCADE
  DEFERRABLE INITIALLY DEFERRED,
  CONSTRAINT c__AllocationChecks_check
  FOREIGN KEY(check_ID)
  REFERENCES Checks(ID)
  DEFERRABLE INITIALLY DEFERRED
);

CREATE TABLE AllocationTypes (
  name NVARCHAR(255),
  descr NVARCHAR(1000),
  code NVARCHAR(10) NOT NULL DEFAULT 'ALLOC',
  PRIMARY KEY(code)
);

CREATE TABLE AllocationValueAdjustments (
  name NVARCHAR(255),
  descr NVARCHAR(1000),
  code NVARCHAR(10) NOT NULL DEFAULT '',
  PRIMARY KEY(code)
);

CREATE TABLE AllocationTermProcessings (
  name NVARCHAR(255),
  descr NVARCHAR(1000),
  code NVARCHAR(10) NOT NULL DEFAULT '',
  PRIMARY KEY(code)
);

CREATE TABLE AllocationCycleAggregations (
  name NVARCHAR(255),
  descr NVARCHAR(1000),
  code NVARCHAR(10) NOT NULL DEFAULT '',
  PRIMARY KEY(code)
);

CREATE TABLE AllocationSelectionFields (
  createdAt TIMESTAMP_TEXT,
  createdBy NVARCHAR(255),
  modifiedAt TIMESTAMP_TEXT,
  modifiedBy NVARCHAR(255),
  environment_ID NVARCHAR(36),
  function_ID NVARCHAR(36),
  ID NVARCHAR(36) NOT NULL,
  allocation_ID NVARCHAR(36),
  field_ID NVARCHAR(36),
  PRIMARY KEY(ID),
  CONSTRAINT c__AllocationSelectionFields_environment
  FOREIGN KEY(environment_ID)
  REFERENCES Environments(ID)
  DEFERRABLE INITIALLY DEFERRED,
  CONSTRAINT c__AllocationSelectionFields_function
  FOREIGN KEY(function_ID)
  REFERENCES Functions(ID)
  DEFERRABLE INITIALLY DEFERRED,
  CONSTRAINT c__AllocationSelectionFields_allocation
  FOREIGN KEY(allocation_ID)
  REFERENCES Allocations(ID)
  ON DELETE CASCADE
  DEFERRABLE INITIALLY DEFERRED,
  CONSTRAINT c__AllocationSelectionFields_field
  FOREIGN KEY(field_ID)
  REFERENCES Fields(ID)
  DEFERRABLE INITIALLY DEFERRED
);

CREATE TABLE AllocationActionFields (
  createdAt TIMESTAMP_TEXT,
  createdBy NVARCHAR(255),
  modifiedAt TIMESTAMP_TEXT,
  modifiedBy NVARCHAR(255),
  environment_ID NVARCHAR(36),
  function_ID NVARCHAR(36),
  ID NVARCHAR(36) NOT NULL,
  allocation_ID NVARCHAR(36),
  field_ID NVARCHAR(36),
  PRIMARY KEY(ID),
  CONSTRAINT c__AllocationActionFields_environment
  FOREIGN KEY(environment_ID)
  REFERENCES Environments(ID)
  DEFERRABLE INITIALLY DEFERRED,
  CONSTRAINT c__AllocationActionFields_function
  FOREIGN KEY(function_ID)
  REFERENCES Functions(ID)
  DEFERRABLE INITIALLY DEFERRED,
  CONSTRAINT c__AllocationActionFields_allocation
  FOREIGN KEY(allocation_ID)
  REFERENCES Allocations(ID)
  ON DELETE CASCADE
  DEFERRABLE INITIALLY DEFERRED,
  CONSTRAINT c__AllocationActionFields_field
  FOREIGN KEY(field_ID)
  REFERENCES Fields(ID)
  DEFERRABLE INITIALLY DEFERRED
);

CREATE TABLE AllocationReceiverSelectionFields (
  createdAt TIMESTAMP_TEXT,
  createdBy NVARCHAR(255),
  modifiedAt TIMESTAMP_TEXT,
  modifiedBy NVARCHAR(255),
  environment_ID NVARCHAR(36),
  function_ID NVARCHAR(36),
  ID NVARCHAR(36) NOT NULL,
  allocation_ID NVARCHAR(36),
  field_ID NVARCHAR(36),
  PRIMARY KEY(ID),
  CONSTRAINT c__AllocationReceiverSelectionFields_environment
  FOREIGN KEY(environment_ID)
  REFERENCES Environments(ID)
  DEFERRABLE INITIALLY DEFERRED,
  CONSTRAINT c__AllocationReceiverSelectionFields_function
  FOREIGN KEY(function_ID)
  REFERENCES Functions(ID)
  DEFERRABLE INITIALLY DEFERRED,
  CONSTRAINT c__AllocationReceiverSelectionFields_allocation
  FOREIGN KEY(allocation_ID)
  REFERENCES Allocations(ID)
  ON DELETE CASCADE
  DEFERRABLE INITIALLY DEFERRED,
  CONSTRAINT c__AllocationReceiverSelectionFields_field
  FOREIGN KEY(field_ID)
  REFERENCES Fields(ID)
  DEFERRABLE INITIALLY DEFERRED
);

CREATE TABLE AllocationReceiverActionFields (
  createdAt TIMESTAMP_TEXT,
  createdBy NVARCHAR(255),
  modifiedAt TIMESTAMP_TEXT,
  modifiedBy NVARCHAR(255),
  environment_ID NVARCHAR(36),
  function_ID NVARCHAR(36),
  ID NVARCHAR(36) NOT NULL,
  allocation_ID NVARCHAR(36),
  field_ID NVARCHAR(36),
  PRIMARY KEY(ID),
  CONSTRAINT c__AllocationReceiverActionFields_environment
  FOREIGN KEY(environment_ID)
  REFERENCES Environments(ID)
  DEFERRABLE INITIALLY DEFERRED,
  CONSTRAINT c__AllocationReceiverActionFields_function
  FOREIGN KEY(function_ID)
  REFERENCES Functions(ID)
  DEFERRABLE INITIALLY DEFERRED,
  CONSTRAINT c__AllocationReceiverActionFields_allocation
  FOREIGN KEY(allocation_ID)
  REFERENCES Allocations(ID)
  ON DELETE CASCADE
  DEFERRABLE INITIALLY DEFERRED,
  CONSTRAINT c__AllocationReceiverActionFields_field
  FOREIGN KEY(field_ID)
  REFERENCES Fields(ID)
  DEFERRABLE INITIALLY DEFERRED
);

CREATE TABLE AllocationRules (
  createdAt TIMESTAMP_TEXT,
  createdBy NVARCHAR(255),
  modifiedAt TIMESTAMP_TEXT,
  modifiedBy NVARCHAR(255),
  environment_ID NVARCHAR(36),
  function_ID NVARCHAR(36),
  ID NVARCHAR(36) NOT NULL,
  allocation_ID NVARCHAR(36),
  sequence INTEGER,
  rule NVARCHAR(5000),
  description NVARCHAR(5000),
  isActive BOOLEAN DEFAULT TRUE,
  type_code NVARCHAR(10) DEFAULT 'DIRECT',
  senderRule_code NVARCHAR(10) DEFAULT 'POST_AM',
  senderShare DECIMAL DEFAULT 100,
  method_code NVARCHAR(10) DEFAULT 'PR',
  distributionBase NVARCHAR(5000),
  parentRule_ID NVARCHAR(36),
  receiverRule_code NVARCHAR(10) DEFAULT 'VAR_POR',
  scale_code NVARCHAR(10) DEFAULT '',
  driverResultField_ID NVARCHAR(36),
  PRIMARY KEY(ID),
  CONSTRAINT c__AllocationRules_environment
  FOREIGN KEY(environment_ID)
  REFERENCES Environments(ID)
  DEFERRABLE INITIALLY DEFERRED,
  CONSTRAINT c__AllocationRules_function
  FOREIGN KEY(function_ID)
  REFERENCES Functions(ID)
  DEFERRABLE INITIALLY DEFERRED,
  CONSTRAINT c__AllocationRules_allocation
  FOREIGN KEY(allocation_ID)
  REFERENCES Allocations(ID)
  ON DELETE CASCADE
  DEFERRABLE INITIALLY DEFERRED,
  CONSTRAINT c__AllocationRules_type
  FOREIGN KEY(type_code)
  REFERENCES AllocationRuleTypes(code)
  DEFERRABLE INITIALLY DEFERRED,
  CONSTRAINT c__AllocationRules_senderRule
  FOREIGN KEY(senderRule_code)
  REFERENCES AllocationSenderRules(code)
  DEFERRABLE INITIALLY DEFERRED,
  CONSTRAINT c__AllocationRules_method
  FOREIGN KEY(method_code)
  REFERENCES AllocationRuleMethods(code)
  DEFERRABLE INITIALLY DEFERRED,
  CONSTRAINT c__AllocationRules_parentRule
  FOREIGN KEY(parentRule_ID)
  REFERENCES AllocationRules(ID)
  DEFERRABLE INITIALLY DEFERRED,
  CONSTRAINT c__AllocationRules_receiverRule
  FOREIGN KEY(receiverRule_code)
  REFERENCES AllocationReceiverRules(code)
  DEFERRABLE INITIALLY DEFERRED,
  CONSTRAINT c__AllocationRules_scale
  FOREIGN KEY(scale_code)
  REFERENCES AllocationRuleScales(code)
  DEFERRABLE INITIALLY DEFERRED
);

CREATE TABLE AllocationRuleSenderValueFields (
  createdAt TIMESTAMP_TEXT,
  createdBy NVARCHAR(255),
  modifiedAt TIMESTAMP_TEXT,
  modifiedBy NVARCHAR(255),
  environment_ID NVARCHAR(36),
  function_ID NVARCHAR(36),
  ID NVARCHAR(36) NOT NULL,
  rule_ID NVARCHAR(36),
  field_ID NVARCHAR(36),
  PRIMARY KEY(ID),
  CONSTRAINT c__AllocationRuleSenderValueFields_environment
  FOREIGN KEY(environment_ID)
  REFERENCES Environments(ID)
  DEFERRABLE INITIALLY DEFERRED,
  CONSTRAINT c__AllocationRuleSenderValueFields_function
  FOREIGN KEY(function_ID)
  REFERENCES Functions(ID)
  DEFERRABLE INITIALLY DEFERRED,
  CONSTRAINT c__AllocationRuleSenderValueFields_rule
  FOREIGN KEY(rule_ID)
  REFERENCES AllocationRules(ID)
  ON DELETE CASCADE
  DEFERRABLE INITIALLY DEFERRED,
  CONSTRAINT c__AllocationRuleSenderValueFields_field
  FOREIGN KEY(field_ID)
  REFERENCES AllocationActionFields(ID)
  DEFERRABLE INITIALLY DEFERRED
);

CREATE TABLE AllocationRuleSenderViews (
  createdAt TIMESTAMP_TEXT,
  createdBy NVARCHAR(255),
  modifiedAt TIMESTAMP_TEXT,
  modifiedBy NVARCHAR(255),
  environment_ID NVARCHAR(36),
  function_ID NVARCHAR(36),
  formula NVARCHAR(5000),
  group_code NVARCHAR(10) DEFAULT '',
  order_code NVARCHAR(10) DEFAULT '',
  ID NVARCHAR(36) NOT NULL,
  rule_ID NVARCHAR(36),
  field_ID NVARCHAR(36),
  PRIMARY KEY(ID),
  CONSTRAINT c__AllocationRuleSenderViews_environment
  FOREIGN KEY(environment_ID)
  REFERENCES Environments(ID)
  DEFERRABLE INITIALLY DEFERRED,
  CONSTRAINT c__AllocationRuleSenderViews_function
  FOREIGN KEY(function_ID)
  REFERENCES Functions(ID)
  DEFERRABLE INITIALLY DEFERRED,
  CONSTRAINT c__AllocationRuleSenderViews_group
  FOREIGN KEY(group_code)
  REFERENCES "Groups"(code)
  DEFERRABLE INITIALLY DEFERRED,
  CONSTRAINT c__AllocationRuleSenderViews_order
  FOREIGN KEY(order_code)
  REFERENCES Orders(code)
  DEFERRABLE INITIALLY DEFERRED,
  CONSTRAINT c__AllocationRuleSenderViews_rule
  FOREIGN KEY(rule_ID)
  REFERENCES AllocationRules(ID)
  ON DELETE CASCADE
  DEFERRABLE INITIALLY DEFERRED,
  CONSTRAINT c__AllocationRuleSenderViews_field
  FOREIGN KEY(field_ID)
  REFERENCES Fields(ID)
  DEFERRABLE INITIALLY DEFERRED
);

CREATE TABLE AllocationRuleSenderFieldSelections (
  createdAt TIMESTAMP_TEXT,
  createdBy NVARCHAR(255),
  modifiedAt TIMESTAMP_TEXT,
  modifiedBy NVARCHAR(255),
  environment_ID NVARCHAR(36),
  function_ID NVARCHAR(36),
  seq INTEGER DEFAULT 0,
  sign_code NVARCHAR(1) DEFAULT 'I',
  opt_code NVARCHAR(2) DEFAULT 'EQ',
  low NVARCHAR(5000),
  high NVARCHAR(5000),
  ID NVARCHAR(36) NOT NULL,
  field_ID NVARCHAR(36),
  PRIMARY KEY(ID),
  CONSTRAINT c__AllocationRuleSenderFieldSelections_environment
  FOREIGN KEY(environment_ID)
  REFERENCES Environments(ID)
  DEFERRABLE INITIALLY DEFERRED,
  CONSTRAINT c__AllocationRuleSenderFieldSelections_function
  FOREIGN KEY(function_ID)
  REFERENCES Functions(ID)
  DEFERRABLE INITIALLY DEFERRED,
  CONSTRAINT c__AllocationRuleSenderFieldSelections_sign
  FOREIGN KEY(sign_code)
  REFERENCES Signs(code)
  DEFERRABLE INITIALLY DEFERRED,
  CONSTRAINT c__AllocationRuleSenderFieldSelections_opt
  FOREIGN KEY(opt_code)
  REFERENCES Options(code)
  DEFERRABLE INITIALLY DEFERRED,
  CONSTRAINT c__AllocationRuleSenderFieldSelections_field
  FOREIGN KEY(field_ID)
  REFERENCES AllocationRuleSenderViews(ID)
  ON DELETE CASCADE
  DEFERRABLE INITIALLY DEFERRED
);

CREATE TABLE AllocationRuleReceiverViews (
  createdAt TIMESTAMP_TEXT,
  createdBy NVARCHAR(255),
  modifiedAt TIMESTAMP_TEXT,
  modifiedBy NVARCHAR(255),
  environment_ID NVARCHAR(36),
  function_ID NVARCHAR(36),
  formula NVARCHAR(5000),
  group_code NVARCHAR(10) DEFAULT '',
  order_code NVARCHAR(10) DEFAULT '',
  ID NVARCHAR(36) NOT NULL,
  rule_ID NVARCHAR(36),
  field_ID NVARCHAR(36),
  PRIMARY KEY(ID),
  CONSTRAINT c__AllocationRuleReceiverViews_environment
  FOREIGN KEY(environment_ID)
  REFERENCES Environments(ID)
  DEFERRABLE INITIALLY DEFERRED,
  CONSTRAINT c__AllocationRuleReceiverViews_function
  FOREIGN KEY(function_ID)
  REFERENCES Functions(ID)
  DEFERRABLE INITIALLY DEFERRED,
  CONSTRAINT c__AllocationRuleReceiverViews_group
  FOREIGN KEY(group_code)
  REFERENCES "Groups"(code)
  DEFERRABLE INITIALLY DEFERRED,
  CONSTRAINT c__AllocationRuleReceiverViews_order
  FOREIGN KEY(order_code)
  REFERENCES Orders(code)
  DEFERRABLE INITIALLY DEFERRED,
  CONSTRAINT c__AllocationRuleReceiverViews_rule
  FOREIGN KEY(rule_ID)
  REFERENCES AllocationRules(ID)
  DEFERRABLE INITIALLY DEFERRED,
  CONSTRAINT c__AllocationRuleReceiverViews_field
  FOREIGN KEY(field_ID)
  REFERENCES Fields(ID)
  DEFERRABLE INITIALLY DEFERRED
);

CREATE TABLE AllocationRuleReceiverFieldSelections (
  createdAt TIMESTAMP_TEXT,
  createdBy NVARCHAR(255),
  modifiedAt TIMESTAMP_TEXT,
  modifiedBy NVARCHAR(255),
  environment_ID NVARCHAR(36),
  function_ID NVARCHAR(36),
  seq INTEGER DEFAULT 0,
  sign_code NVARCHAR(1) DEFAULT 'I',
  opt_code NVARCHAR(2) DEFAULT 'EQ',
  low NVARCHAR(5000),
  high NVARCHAR(5000),
  ID NVARCHAR(36) NOT NULL,
  field_ID NVARCHAR(36),
  PRIMARY KEY(ID),
  CONSTRAINT c__AllocationRuleReceiverFieldSelections_environment
  FOREIGN KEY(environment_ID)
  REFERENCES Environments(ID)
  DEFERRABLE INITIALLY DEFERRED,
  CONSTRAINT c__AllocationRuleReceiverFieldSelections_function
  FOREIGN KEY(function_ID)
  REFERENCES Functions(ID)
  DEFERRABLE INITIALLY DEFERRED,
  CONSTRAINT c__AllocationRuleReceiverFieldSelections_sign
  FOREIGN KEY(sign_code)
  REFERENCES Signs(code)
  DEFERRABLE INITIALLY DEFERRED,
  CONSTRAINT c__AllocationRuleReceiverFieldSelections_opt
  FOREIGN KEY(opt_code)
  REFERENCES Options(code)
  DEFERRABLE INITIALLY DEFERRED,
  CONSTRAINT c__AllocationRuleReceiverFieldSelections_field
  FOREIGN KEY(field_ID)
  REFERENCES AllocationRuleReceiverViews(ID)
  ON DELETE CASCADE
  DEFERRABLE INITIALLY DEFERRED
);

CREATE TABLE AllocationRuleTypes (
  name NVARCHAR(255),
  descr NVARCHAR(1000),
  code NVARCHAR(10) NOT NULL DEFAULT 'DIRECT',
  PRIMARY KEY(code)
);

CREATE TABLE AllocationRuleMethods (
  name NVARCHAR(255),
  descr NVARCHAR(1000),
  code NVARCHAR(10) NOT NULL DEFAULT 'PR',
  PRIMARY KEY(code)
);

CREATE TABLE AllocationSenderRules (
  name NVARCHAR(255),
  descr NVARCHAR(1000),
  code NVARCHAR(10) NOT NULL DEFAULT 'POST_AM',
  PRIMARY KEY(code)
);

CREATE TABLE AllocationReceiverRules (
  name NVARCHAR(255),
  descr NVARCHAR(1000),
  code NVARCHAR(10) NOT NULL DEFAULT 'VAR_POR',
  PRIMARY KEY(code)
);

CREATE TABLE AllocationRuleScales (
  name NVARCHAR(255),
  descr NVARCHAR(1000),
  code NVARCHAR(10) NOT NULL DEFAULT '',
  PRIMARY KEY(code)
);

CREATE TABLE CalculationUnits (
  createdAt TIMESTAMP_TEXT,
  createdBy NVARCHAR(255),
  modifiedAt TIMESTAMP_TEXT,
  modifiedBy NVARCHAR(255),
  environment_ID NVARCHAR(36),
  function_ID NVARCHAR(36),
  ID NVARCHAR(36) NOT NULL,
  dummy NVARCHAR(5000),
  PRIMARY KEY(ID),
  CONSTRAINT c__CalculationUnits_environment
  FOREIGN KEY(environment_ID)
  REFERENCES Environments(ID)
  DEFERRABLE INITIALLY DEFERRED,
  CONSTRAINT c__CalculationUnits_function
  FOREIGN KEY(function_ID)
  REFERENCES Functions(ID)
  DEFERRABLE INITIALLY DEFERRED
);

CREATE TABLE ModelTables (
  createdAt TIMESTAMP_TEXT,
  createdBy NVARCHAR(255),
  modifiedAt TIMESTAMP_TEXT,
  modifiedBy NVARCHAR(255),
  environment_ID NVARCHAR(36),
  function_ID NVARCHAR(36),
  ID NVARCHAR(36) NOT NULL,
  type_code NVARCHAR(10) DEFAULT 'ENV',
  transportData BOOLEAN DEFAULT FALSE,
  connection NVARCHAR(5000),
  PRIMARY KEY(ID),
  CONSTRAINT c__ModelTables_environment
  FOREIGN KEY(environment_ID)
  REFERENCES Environments(ID)
  DEFERRABLE INITIALLY DEFERRED,
  CONSTRAINT c__ModelTables_function
  FOREIGN KEY(function_ID)
  REFERENCES Functions(ID)
  DEFERRABLE INITIALLY DEFERRED,
  CONSTRAINT c__ModelTables_type
  FOREIGN KEY(type_code)
  REFERENCES ModelTableTypes(code)
  DEFERRABLE INITIALLY DEFERRED
);

CREATE TABLE ModelTableFields (
  createdAt TIMESTAMP_TEXT,
  createdBy NVARCHAR(255),
  modifiedAt TIMESTAMP_TEXT,
  modifiedBy NVARCHAR(255),
  environment_ID NVARCHAR(36),
  field_ID NVARCHAR(36),
  ID NVARCHAR(36) NOT NULL,
  modelTable_ID NVARCHAR(36),
  PRIMARY KEY(ID),
  CONSTRAINT c__ModelTableFields_environment
  FOREIGN KEY(environment_ID)
  REFERENCES Environments(ID)
  DEFERRABLE INITIALLY DEFERRED,
  CONSTRAINT c__ModelTableFields_field
  FOREIGN KEY(field_ID)
  REFERENCES Fields(ID)
  DEFERRABLE INITIALLY DEFERRED,
  CONSTRAINT c__ModelTableFields_modelTable
  FOREIGN KEY(modelTable_ID)
  REFERENCES ModelTables(ID)
  ON DELETE CASCADE
  DEFERRABLE INITIALLY DEFERRED
);

CREATE TABLE ModelTableTypes (
  name NVARCHAR(255),
  descr NVARCHAR(1000),
  code NVARCHAR(10) NOT NULL DEFAULT 'ENV',
  PRIMARY KEY(code)
);

CREATE TABLE ConnectionEnvironments (
  createdAt TIMESTAMP_TEXT,
  createdBy NVARCHAR(255),
  modifiedAt TIMESTAMP_TEXT,
  modifiedBy NVARCHAR(255),
  connection INTEGER NOT NULL,
  environment NVARCHAR(36),
  PRIMARY KEY(connection)
);

CREATE TABLE EnvironmentTypes_texts (
  locale NVARCHAR(14) NOT NULL,
  name NVARCHAR(255),
  descr NVARCHAR(1000),
  code NVARCHAR(5000) NOT NULL DEFAULT 'ENV_VER',
  PRIMARY KEY(locale, code)
);

CREATE TABLE MessageTypes_texts (
  locale NVARCHAR(14) NOT NULL,
  name NVARCHAR(255),
  descr NVARCHAR(1000),
  code NVARCHAR(1) NOT NULL DEFAULT 'I',
  PRIMARY KEY(locale, code)
);

CREATE TABLE Groups_texts (
  locale NVARCHAR(14) NOT NULL,
  name NVARCHAR(255),
  descr NVARCHAR(1000),
  code NVARCHAR(10) NOT NULL DEFAULT '',
  PRIMARY KEY(locale, code)
);

CREATE TABLE Orders_texts (
  locale NVARCHAR(14) NOT NULL,
  name NVARCHAR(255),
  descr NVARCHAR(1000),
  code NVARCHAR(10) NOT NULL DEFAULT '',
  PRIMARY KEY(locale, code)
);

CREATE TABLE Signs_texts (
  locale NVARCHAR(14) NOT NULL,
  name NVARCHAR(255),
  descr NVARCHAR(1000),
  code NVARCHAR(1) NOT NULL DEFAULT 'I',
  PRIMARY KEY(locale, code)
);

CREATE TABLE Options_texts (
  locale NVARCHAR(14) NOT NULL,
  name NVARCHAR(255),
  descr NVARCHAR(1000),
  code NVARCHAR(2) NOT NULL DEFAULT 'EQ',
  PRIMARY KEY(locale, code)
);

CREATE TABLE ResultHandlings_texts (
  locale NVARCHAR(14) NOT NULL,
  name NVARCHAR(255),
  descr NVARCHAR(1000),
  code NVARCHAR(10) NOT NULL DEFAULT 'ENRICHED',
  PRIMARY KEY(locale, code)
);

CREATE TABLE FieldClasses_texts (
  locale NVARCHAR(14) NOT NULL,
  name NVARCHAR(255),
  descr NVARCHAR(1000),
  code NVARCHAR(5000) NOT NULL DEFAULT '',
  PRIMARY KEY(locale, code)
);

CREATE TABLE FieldTypes_texts (
  locale NVARCHAR(14) NOT NULL,
  name NVARCHAR(255),
  descr NVARCHAR(1000),
  code NVARCHAR(5000) NOT NULL DEFAULT 'CHA',
  PRIMARY KEY(locale, code)
);

CREATE TABLE HanaDataTypes_texts (
  locale NVARCHAR(14) NOT NULL,
  name NVARCHAR(255),
  descr NVARCHAR(1000),
  code NVARCHAR(5000) NOT NULL DEFAULT 'NVARCHAR',
  PRIMARY KEY(locale, code)
);

CREATE TABLE CheckCategories_texts (
  locale NVARCHAR(14) NOT NULL,
  name NVARCHAR(255),
  descr NVARCHAR(1000),
  code NVARCHAR(10) NOT NULL DEFAULT '',
  PRIMARY KEY(locale, code)
);

CREATE TABLE FunctionTypes_texts (
  locale NVARCHAR(14) NOT NULL,
  name NVARCHAR(255),
  descr NVARCHAR(1000),
  code NVARCHAR(10) NOT NULL DEFAULT 'MT',
  PRIMARY KEY(locale, code)
);

CREATE TABLE FunctionProcessingTypes_texts (
  locale NVARCHAR(14) NOT NULL,
  name NVARCHAR(255),
  descr NVARCHAR(1000),
  code NVARCHAR(10) NOT NULL DEFAULT '',
  PRIMARY KEY(locale, code)
);

CREATE TABLE FunctionBusinessEventTypes_texts (
  locale NVARCHAR(14) NOT NULL,
  name NVARCHAR(255),
  descr NVARCHAR(1000),
  code NVARCHAR(10) NOT NULL DEFAULT '',
  PRIMARY KEY(locale, code)
);

CREATE TABLE AllocationTypes_texts (
  locale NVARCHAR(14) NOT NULL,
  name NVARCHAR(255),
  descr NVARCHAR(1000),
  code NVARCHAR(10) NOT NULL DEFAULT 'ALLOC',
  PRIMARY KEY(locale, code)
);

CREATE TABLE AllocationValueAdjustments_texts (
  locale NVARCHAR(14) NOT NULL,
  name NVARCHAR(255),
  descr NVARCHAR(1000),
  code NVARCHAR(10) NOT NULL DEFAULT '',
  PRIMARY KEY(locale, code)
);

CREATE TABLE AllocationTermProcessings_texts (
  locale NVARCHAR(14) NOT NULL,
  name NVARCHAR(255),
  descr NVARCHAR(1000),
  code NVARCHAR(10) NOT NULL DEFAULT '',
  PRIMARY KEY(locale, code)
);

CREATE TABLE AllocationCycleAggregations_texts (
  locale NVARCHAR(14) NOT NULL,
  name NVARCHAR(255),
  descr NVARCHAR(1000),
  code NVARCHAR(10) NOT NULL DEFAULT '',
  PRIMARY KEY(locale, code)
);

CREATE TABLE AllocationRuleTypes_texts (
  locale NVARCHAR(14) NOT NULL,
  name NVARCHAR(255),
  descr NVARCHAR(1000),
  code NVARCHAR(10) NOT NULL DEFAULT 'DIRECT',
  PRIMARY KEY(locale, code)
);

CREATE TABLE AllocationRuleMethods_texts (
  locale NVARCHAR(14) NOT NULL,
  name NVARCHAR(255),
  descr NVARCHAR(1000),
  code NVARCHAR(10) NOT NULL DEFAULT 'PR',
  PRIMARY KEY(locale, code)
);

CREATE TABLE AllocationSenderRules_texts (
  locale NVARCHAR(14) NOT NULL,
  name NVARCHAR(255),
  descr NVARCHAR(1000),
  code NVARCHAR(10) NOT NULL DEFAULT 'POST_AM',
  PRIMARY KEY(locale, code)
);

CREATE TABLE AllocationReceiverRules_texts (
  locale NVARCHAR(14) NOT NULL,
  name NVARCHAR(255),
  descr NVARCHAR(1000),
  code NVARCHAR(10) NOT NULL DEFAULT 'VAR_POR',
  PRIMARY KEY(locale, code)
);

CREATE TABLE AllocationRuleScales_texts (
  locale NVARCHAR(14) NOT NULL,
  name NVARCHAR(255),
  descr NVARCHAR(1000),
  code NVARCHAR(10) NOT NULL DEFAULT '',
  PRIMARY KEY(locale, code)
);

CREATE TABLE ModelTableTypes_texts (
  locale NVARCHAR(14) NOT NULL,
  name NVARCHAR(255),
  descr NVARCHAR(1000),
  code NVARCHAR(10) NOT NULL DEFAULT 'ENV',
  PRIMARY KEY(locale, code)
);

CREATE TABLE DRAFT_DraftAdministrativeData (
  DraftUUID NVARCHAR(36) NOT NULL,
  CreationDateTime TIMESTAMP_TEXT,
  CreatedByUser NVARCHAR(256),
  DraftIsCreatedByMe BOOLEAN,
  LastChangeDateTime TIMESTAMP_TEXT,
  LastChangedByUser NVARCHAR(256),
  InProcessByUser NVARCHAR(256),
  DraftIsProcessedByMe BOOLEAN,
  PRIMARY KEY(DraftUUID)
);

CREATE TABLE EnvironmentService_Environments_drafts (
  createdAt TIMESTAMP_TEXT NULL,
  createdBy NVARCHAR(255) NULL,
  modifiedAt TIMESTAMP_TEXT NULL,
  modifiedBy NVARCHAR(255) NULL,
  ID NVARCHAR(36) NOT NULL,
  environment NVARCHAR(5000) NULL,
  version NVARCHAR(5000) NULL,
  description NVARCHAR(5000) NULL,
  parent_ID NVARCHAR(36) NULL,
  type_code NVARCHAR(5000) NULL DEFAULT 'ENV_VER',
  IsActiveEntity BOOLEAN,
  HasActiveEntity BOOLEAN,
  HasDraftEntity BOOLEAN,
  DraftAdministrativeData_DraftUUID NVARCHAR(36) NOT NULL,
  PRIMARY KEY(ID)
);

CREATE VIEW EnvironmentService_Environments AS SELECT
  environments_0.createdAt,
  environments_0.createdBy,
  environments_0.modifiedAt,
  environments_0.modifiedBy,
  environments_0.ID,
  environments_0.environment,
  environments_0.version,
  environments_0.description,
  environments_0.parent_ID,
  environments_0.type_code
FROM Environments AS environments_0
ORDER BY environment, version;

CREATE VIEW EnvironmentFolders AS SELECT
  Environments_0.createdAt,
  Environments_0.createdBy,
  Environments_0.modifiedAt,
  Environments_0.modifiedBy,
  Environments_0.ID,
  Environments_0.environment,
  Environments_0.version,
  Environments_0.description,
  Environments_0.parent_ID,
  Environments_0.type_code
FROM Environments AS Environments_0
WHERE Environments_0.type_code = 'NODE';

CREATE VIEW UnitFields AS SELECT
  Fields_0.createdAt,
  Fields_0.createdBy,
  Fields_0.modifiedAt,
  Fields_0.modifiedBy,
  Fields_0.environment_ID,
  Fields_0.ID,
  Fields_0.field,
  Fields_0.class_code,
  Fields_0.type_code,
  Fields_0.hanaDataType_code,
  Fields_0.dataLength,
  Fields_0.dataDecimals,
  Fields_0.unitField_ID,
  Fields_0.isLowercase,
  Fields_0.hasMasterData,
  Fields_0.hasHierarchies,
  Fields_0.calculationHierarchy_ID,
  Fields_0.masterDataQuery_ID,
  Fields_0.description,
  Fields_0.documentation
FROM Fields AS Fields_0
WHERE Fields_0.type_code = 'UNI';

CREATE VIEW MasterDataQueries AS SELECT
  Functions_0.createdAt,
  Functions_0.createdBy,
  Functions_0.modifiedAt,
  Functions_0.modifiedBy,
  Functions_0.environment_ID,
  Functions_0.ID,
  Functions_0.function,
  Functions_0.sequence,
  Functions_0.parent_ID,
  Functions_0.type_code,
  Functions_0.description,
  Functions_0.documentation
FROM Functions AS Functions_0
WHERE Functions_0.type_code = 'MT';

CREATE VIEW FunctionParents AS SELECT
  Functions_0.createdAt,
  Functions_0.createdBy,
  Functions_0.modifiedAt,
  Functions_0.modifiedBy,
  Functions_0.environment_ID,
  Functions_0.ID,
  Functions_0.function,
  Functions_0.sequence,
  Functions_0.parent_ID,
  Functions_0.type_code,
  Functions_0.description,
  Functions_0.documentation
FROM Functions AS Functions_0
WHERE Functions_0.type_code = 'CU' OR Functions_0.type_code = 'DS';

CREATE VIEW ResultModelTables AS SELECT
  Functions_0.createdAt,
  Functions_0.createdBy,
  Functions_0.modifiedAt,
  Functions_0.modifiedBy,
  Functions_0.environment_ID,
  Functions_0.ID,
  Functions_0.function,
  Functions_0.sequence,
  Functions_0.parent_ID,
  Functions_0.type_code,
  Functions_0.description,
  Functions_0.documentation
FROM Functions AS Functions_0
WHERE Functions_0.type_code = 'MT';

CREATE VIEW FunctionParentCalculationUnits AS SELECT
  Functions_0.createdAt,
  Functions_0.createdBy,
  Functions_0.modifiedAt,
  Functions_0.modifiedBy,
  Functions_0.environment_ID,
  Functions_0.ID,
  Functions_0.function,
  Functions_0.sequence,
  Functions_0.parent_ID,
  Functions_0.type_code,
  Functions_0.description,
  Functions_0.documentation
FROM Functions AS Functions_0
WHERE Functions_0.type_code = 'CU';

CREATE VIEW OffsetAllocation AS SELECT
  Allocations_0.environment_ID,
  Allocations_0.function_ID,
  Allocations_0.ID,
  Allocations_0.type_code,
  Allocations_0.valueAdjustment_code,
  Allocations_0.includeInputData,
  Allocations_0.resultHandling_code,
  Allocations_0.includeInitialResult,
  Allocations_0.senderFunction_ID,
  Allocations_0.receiverFunction_ID,
  Allocations_0.resultFunction_ID
FROM Allocations AS Allocations_0;

CREATE VIEW AllocationInputFunctions AS SELECT
  F_0.createdAt,
  F_0.createdBy,
  F_0.modifiedAt,
  F_0.modifiedBy,
  F_0.environment_ID,
  F_0.ID,
  F_0.function,
  F_0.sequence,
  F_0.parent_ID,
  F_0.type_code,
  F_0.description,
  F_0.documentation
FROM Functions AS F_0
WHERE F_0.type_code IN ('MT', 'AL');

CREATE VIEW AllocationTermIterationFields AS SELECT
  Fields_0.createdAt,
  Fields_0.createdBy,
  Fields_0.modifiedAt,
  Fields_0.modifiedBy,
  Fields_0.environment_ID,
  Fields_0.ID,
  Fields_0.field,
  Fields_0.class_code,
  Fields_0.type_code,
  Fields_0.hanaDataType_code,
  Fields_0.dataLength,
  Fields_0.dataDecimals,
  Fields_0.unitField_ID,
  Fields_0.isLowercase,
  Fields_0.hasMasterData,
  Fields_0.hasHierarchies,
  Fields_0.calculationHierarchy_ID,
  Fields_0.masterDataQuery_ID,
  Fields_0.description,
  Fields_0.documentation
FROM Fields AS Fields_0
WHERE Fields_0.class_code = '' AND Fields_0.type_code = 'KYF';

CREATE VIEW AllocationTermYearFields AS SELECT
  Fields_0.createdAt,
  Fields_0.createdBy,
  Fields_0.modifiedAt,
  Fields_0.modifiedBy,
  Fields_0.environment_ID,
  Fields_0.ID,
  Fields_0.field,
  Fields_0.class_code,
  Fields_0.type_code,
  Fields_0.hanaDataType_code,
  Fields_0.dataLength,
  Fields_0.dataDecimals,
  Fields_0.unitField_ID,
  Fields_0.isLowercase,
  Fields_0.hasMasterData,
  Fields_0.hasHierarchies,
  Fields_0.calculationHierarchy_ID,
  Fields_0.masterDataQuery_ID,
  Fields_0.description,
  Fields_0.documentation
FROM Fields AS Fields_0
WHERE Fields_0.class_code = '' AND Fields_0.type_code = 'CHA' AND Fields_0.dataLength >= 4;

CREATE VIEW AllocationTermFields AS SELECT
  Fields_0.createdAt,
  Fields_0.createdBy,
  Fields_0.modifiedAt,
  Fields_0.modifiedBy,
  Fields_0.environment_ID,
  Fields_0.ID,
  Fields_0.field,
  Fields_0.class_code,
  Fields_0.type_code,
  Fields_0.hanaDataType_code,
  Fields_0.dataLength,
  Fields_0.dataDecimals,
  Fields_0.unitField_ID,
  Fields_0.isLowercase,
  Fields_0.hasMasterData,
  Fields_0.hasHierarchies,
  Fields_0.calculationHierarchy_ID,
  Fields_0.masterDataQuery_ID,
  Fields_0.description,
  Fields_0.documentation
FROM Fields AS Fields_0
WHERE Fields_0.class_code = '' AND Fields_0.type_code = 'CHA' AND Fields_0.dataLength >= 4;

CREATE VIEW AllocationEarlyExitChecks AS SELECT
  Checks_0.createdAt,
  Checks_0.createdBy,
  Checks_0.modifiedAt,
  Checks_0.modifiedBy,
  Checks_0.environment_ID,
  Checks_0.ID,
  Checks_0."check",
  Checks_0.messageType_code,
  Checks_0.category_code,
  Checks_0.description
FROM Checks AS Checks_0;

CREATE VIEW AllocationRuleDriverResultFields AS SELECT
  F_0.createdAt,
  F_0.createdBy,
  F_0.modifiedAt,
  F_0.modifiedBy,
  F_0.environment_ID,
  F_0.ID,
  F_0.field,
  F_0.class_code,
  F_0.type_code,
  F_0.hanaDataType_code,
  F_0.dataLength,
  F_0.dataDecimals,
  F_0.unitField_ID,
  F_0.isLowercase,
  F_0.hasMasterData,
  F_0.hasHierarchies,
  F_0.calculationHierarchy_ID,
  F_0.masterDataQuery_ID,
  F_0.description,
  F_0.documentation
FROM Fields AS F_0
WHERE F_0.class_code = '' AND F_0.type_code = 'KYF' AND F_0.ID IN (SELECT
    L_1.field_ID AS ID
  FROM ((AllocationActionFields AS L_1 LEFT JOIN Allocations AS allocation_2 ON L_1.allocation_ID = allocation_2.ID) LEFT JOIN Functions AS function_3 ON allocation_2.function_ID = function_3.ID)
  WHERE F_0.environment_ID = function_3.environment_ID);

CREATE VIEW AllocationCycleIterationFields AS SELECT
  F_0.createdAt,
  F_0.createdBy,
  F_0.modifiedAt,
  F_0.modifiedBy,
  F_0.environment_ID,
  F_0.ID,
  F_0.field,
  F_0.class_code,
  F_0.type_code,
  F_0.hanaDataType_code,
  F_0.dataLength,
  F_0.dataDecimals,
  F_0.unitField_ID,
  F_0.isLowercase,
  F_0.hasMasterData,
  F_0.hasHierarchies,
  F_0.calculationHierarchy_ID,
  F_0.masterDataQuery_ID,
  F_0.description,
  F_0.documentation
FROM Fields AS F_0
WHERE F_0.class_code = '' AND F_0.type_code = 'KYF' AND F_0.ID IN (SELECT
    L_1.field_ID AS ID
  FROM ((AllocationActionFields AS L_1 LEFT JOIN Allocations AS allocation_2 ON L_1.allocation_ID = allocation_2.ID) LEFT JOIN Functions AS function_3 ON allocation_2.function_ID = function_3.ID)
  WHERE F_0.environment_ID = function_3.environment_ID);

CREATE VIEW ResultFunctions AS SELECT
  Functions_0.createdAt,
  Functions_0.createdBy,
  Functions_0.modifiedAt,
  Functions_0.modifiedBy,
  Functions_0.environment_ID,
  Functions_0.ID,
  Functions_0.function,
  Functions_0.sequence,
  Functions_0.parent_ID,
  Functions_0.type_code,
  Functions_0.description,
  Functions_0.documentation
FROM Functions AS Functions_0
WHERE Functions_0.type_code = 'MT';

CREATE VIEW EnvironmentService_EnvironmentTypes AS SELECT
  EnvironmentTypes_0.name,
  EnvironmentTypes_0.descr,
  EnvironmentTypes_0.code
FROM EnvironmentTypes AS EnvironmentTypes_0;

CREATE VIEW EnvironmentService_EnvironmentTypes_texts AS SELECT
  texts_0.locale,
  texts_0.name,
  texts_0.descr,
  texts_0.code
FROM EnvironmentTypes_texts AS texts_0;

CREATE VIEW localized_EnvironmentTypes AS SELECT
  coalesce(localized_1.name, L_0.name) AS name,
  coalesce(localized_1.descr, L_0.descr) AS descr,
  L_0.code
FROM (EnvironmentTypes AS L_0 LEFT JOIN EnvironmentTypes_texts AS localized_1 ON localized_1.code = L_0.code AND localized_1.locale = 'en');

CREATE VIEW localized_MessageTypes AS SELECT
  coalesce(localized_1.name, L_0.name) AS name,
  coalesce(localized_1.descr, L_0.descr) AS descr,
  L_0.code
FROM (MessageTypes AS L_0 LEFT JOIN MessageTypes_texts AS localized_1 ON localized_1.code = L_0.code AND localized_1.locale = 'en');

CREATE VIEW localized_Groups AS SELECT
  coalesce(localized_1.name, L_0.name) AS name,
  coalesce(localized_1.descr, L_0.descr) AS descr,
  L_0.code
FROM ("Groups" AS L_0 LEFT JOIN Groups_texts AS localized_1 ON localized_1.code = L_0.code AND localized_1.locale = 'en');

CREATE VIEW localized_Orders AS SELECT
  coalesce(localized_1.name, L_0.name) AS name,
  coalesce(localized_1.descr, L_0.descr) AS descr,
  L_0.code
FROM (Orders AS L_0 LEFT JOIN Orders_texts AS localized_1 ON localized_1.code = L_0.code AND localized_1.locale = 'en');

CREATE VIEW localized_Signs AS SELECT
  coalesce(localized_1.name, L_0.name) AS name,
  coalesce(localized_1.descr, L_0.descr) AS descr,
  L_0.code
FROM (Signs AS L_0 LEFT JOIN Signs_texts AS localized_1 ON localized_1.code = L_0.code AND localized_1.locale = 'en');

CREATE VIEW localized_Options AS SELECT
  coalesce(localized_1.name, L_0.name) AS name,
  coalesce(localized_1.descr, L_0.descr) AS descr,
  L_0.code
FROM (Options AS L_0 LEFT JOIN Options_texts AS localized_1 ON localized_1.code = L_0.code AND localized_1.locale = 'en');

CREATE VIEW localized_ResultHandlings AS SELECT
  coalesce(localized_1.name, L_0.name) AS name,
  coalesce(localized_1.descr, L_0.descr) AS descr,
  L_0.code
FROM (ResultHandlings AS L_0 LEFT JOIN ResultHandlings_texts AS localized_1 ON localized_1.code = L_0.code AND localized_1.locale = 'en');

CREATE VIEW localized_FieldClasses AS SELECT
  coalesce(localized_1.name, L_0.name) AS name,
  coalesce(localized_1.descr, L_0.descr) AS descr,
  L_0.code
FROM (FieldClasses AS L_0 LEFT JOIN FieldClasses_texts AS localized_1 ON localized_1.code = L_0.code AND localized_1.locale = 'en');

CREATE VIEW localized_FieldTypes AS SELECT
  coalesce(localized_1.name, L_0.name) AS name,
  coalesce(localized_1.descr, L_0.descr) AS descr,
  L_0.code
FROM (FieldTypes AS L_0 LEFT JOIN FieldTypes_texts AS localized_1 ON localized_1.code = L_0.code AND localized_1.locale = 'en');

CREATE VIEW localized_HanaDataTypes AS SELECT
  coalesce(localized_1.name, L_0.name) AS name,
  coalesce(localized_1.descr, L_0.descr) AS descr,
  L_0.code
FROM (HanaDataTypes AS L_0 LEFT JOIN HanaDataTypes_texts AS localized_1 ON localized_1.code = L_0.code AND localized_1.locale = 'en');

CREATE VIEW localized_CheckCategories AS SELECT
  coalesce(localized_1.name, L_0.name) AS name,
  coalesce(localized_1.descr, L_0.descr) AS descr,
  L_0.code
FROM (CheckCategories AS L_0 LEFT JOIN CheckCategories_texts AS localized_1 ON localized_1.code = L_0.code AND localized_1.locale = 'en');

CREATE VIEW localized_FunctionTypes AS SELECT
  coalesce(localized_1.name, L_0.name) AS name,
  coalesce(localized_1.descr, L_0.descr) AS descr,
  L_0.code
FROM (FunctionTypes AS L_0 LEFT JOIN FunctionTypes_texts AS localized_1 ON localized_1.code = L_0.code AND localized_1.locale = 'en');

CREATE VIEW localized_FunctionProcessingTypes AS SELECT
  coalesce(localized_1.name, L_0.name) AS name,
  coalesce(localized_1.descr, L_0.descr) AS descr,
  L_0.code
FROM (FunctionProcessingTypes AS L_0 LEFT JOIN FunctionProcessingTypes_texts AS localized_1 ON localized_1.code = L_0.code AND localized_1.locale = 'en');

CREATE VIEW localized_FunctionBusinessEventTypes AS SELECT
  coalesce(localized_1.name, L_0.name) AS name,
  coalesce(localized_1.descr, L_0.descr) AS descr,
  L_0.code
FROM (FunctionBusinessEventTypes AS L_0 LEFT JOIN FunctionBusinessEventTypes_texts AS localized_1 ON localized_1.code = L_0.code AND localized_1.locale = 'en');

CREATE VIEW localized_AllocationTypes AS SELECT
  coalesce(localized_1.name, L_0.name) AS name,
  coalesce(localized_1.descr, L_0.descr) AS descr,
  L_0.code
FROM (AllocationTypes AS L_0 LEFT JOIN AllocationTypes_texts AS localized_1 ON localized_1.code = L_0.code AND localized_1.locale = 'en');

CREATE VIEW localized_AllocationValueAdjustments AS SELECT
  coalesce(localized_1.name, L_0.name) AS name,
  coalesce(localized_1.descr, L_0.descr) AS descr,
  L_0.code
FROM (AllocationValueAdjustments AS L_0 LEFT JOIN AllocationValueAdjustments_texts AS localized_1 ON localized_1.code = L_0.code AND localized_1.locale = 'en');

CREATE VIEW localized_AllocationTermProcessings AS SELECT
  coalesce(localized_1.name, L_0.name) AS name,
  coalesce(localized_1.descr, L_0.descr) AS descr,
  L_0.code
FROM (AllocationTermProcessings AS L_0 LEFT JOIN AllocationTermProcessings_texts AS localized_1 ON localized_1.code = L_0.code AND localized_1.locale = 'en');

CREATE VIEW localized_AllocationCycleAggregations AS SELECT
  coalesce(localized_1.name, L_0.name) AS name,
  coalesce(localized_1.descr, L_0.descr) AS descr,
  L_0.code
FROM (AllocationCycleAggregations AS L_0 LEFT JOIN AllocationCycleAggregations_texts AS localized_1 ON localized_1.code = L_0.code AND localized_1.locale = 'en');

CREATE VIEW localized_AllocationRuleTypes AS SELECT
  coalesce(localized_1.name, L_0.name) AS name,
  coalesce(localized_1.descr, L_0.descr) AS descr,
  L_0.code
FROM (AllocationRuleTypes AS L_0 LEFT JOIN AllocationRuleTypes_texts AS localized_1 ON localized_1.code = L_0.code AND localized_1.locale = 'en');

CREATE VIEW localized_AllocationRuleMethods AS SELECT
  coalesce(localized_1.name, L_0.name) AS name,
  coalesce(localized_1.descr, L_0.descr) AS descr,
  L_0.code
FROM (AllocationRuleMethods AS L_0 LEFT JOIN AllocationRuleMethods_texts AS localized_1 ON localized_1.code = L_0.code AND localized_1.locale = 'en');

CREATE VIEW localized_AllocationSenderRules AS SELECT
  coalesce(localized_1.name, L_0.name) AS name,
  coalesce(localized_1.descr, L_0.descr) AS descr,
  L_0.code
FROM (AllocationSenderRules AS L_0 LEFT JOIN AllocationSenderRules_texts AS localized_1 ON localized_1.code = L_0.code AND localized_1.locale = 'en');

CREATE VIEW localized_AllocationReceiverRules AS SELECT
  coalesce(localized_1.name, L_0.name) AS name,
  coalesce(localized_1.descr, L_0.descr) AS descr,
  L_0.code
FROM (AllocationReceiverRules AS L_0 LEFT JOIN AllocationReceiverRules_texts AS localized_1 ON localized_1.code = L_0.code AND localized_1.locale = 'en');

CREATE VIEW localized_AllocationRuleScales AS SELECT
  coalesce(localized_1.name, L_0.name) AS name,
  coalesce(localized_1.descr, L_0.descr) AS descr,
  L_0.code
FROM (AllocationRuleScales AS L_0 LEFT JOIN AllocationRuleScales_texts AS localized_1 ON localized_1.code = L_0.code AND localized_1.locale = 'en');

CREATE VIEW localized_ModelTableTypes AS SELECT
  coalesce(localized_1.name, L_0.name) AS name,
  coalesce(localized_1.descr, L_0.descr) AS descr,
  L_0.code
FROM (ModelTableTypes AS L_0 LEFT JOIN ModelTableTypes_texts AS localized_1 ON localized_1.code = L_0.code AND localized_1.locale = 'en');

CREATE VIEW localized_Environments AS SELECT
  L.createdAt,
  L.createdBy,
  L.modifiedAt,
  L.modifiedBy,
  L.ID,
  L.environment,
  L.version,
  L.description,
  L.parent_ID,
  L.type_code
FROM Environments AS L;

CREATE VIEW localized_Fields AS SELECT
  L.createdAt,
  L.createdBy,
  L.modifiedAt,
  L.modifiedBy,
  L.environment_ID,
  L.ID,
  L.field,
  L.class_code,
  L.type_code,
  L.hanaDataType_code,
  L.dataLength,
  L.dataDecimals,
  L.unitField_ID,
  L.isLowercase,
  L.hasMasterData,
  L.hasHierarchies,
  L.calculationHierarchy_ID,
  L.masterDataQuery_ID,
  L.description,
  L.documentation
FROM Fields AS L;

CREATE VIEW localized_Checks AS SELECT
  L.createdAt,
  L.createdBy,
  L.modifiedAt,
  L.modifiedBy,
  L.environment_ID,
  L.ID,
  L."check",
  L.messageType_code,
  L.category_code,
  L.description
FROM Checks AS L;

CREATE VIEW localized_CheckSelections AS SELECT
  L.createdAt,
  L.createdBy,
  L.modifiedAt,
  L.modifiedBy,
  L.seq,
  L.sign_code,
  L.opt_code,
  L.low,
  L.high,
  L.ID,
  L.field_ID
FROM CheckSelections AS L;

CREATE VIEW localized_Functions AS SELECT
  L.createdAt,
  L.createdBy,
  L.modifiedAt,
  L.modifiedBy,
  L.environment_ID,
  L.ID,
  L.function,
  L.sequence,
  L.parent_ID,
  L.type_code,
  L.description,
  L.documentation
FROM Functions AS L;

CREATE VIEW localized_Allocations AS SELECT
  L.createdAt,
  L.createdBy,
  L.modifiedAt,
  L.modifiedBy,
  L.environment_ID,
  L.function_ID,
  L.includeInputData,
  L.resultHandling_code,
  L.includeInitialResult,
  L.resultFunction_ID,
  L.processingType_code,
  L.businessEventType_code,
  L.partition_ID,
  L.ID,
  L.type_code,
  L.valueAdjustment_code,
  L.cycleFlag,
  L.cycleMaximum,
  L.cycleIterationField_ID,
  L.cycleAggregation_code,
  L.termFlag,
  L.termIterationField_ID,
  L.termYearField_ID,
  L.termField_ID,
  L.termProcessing_code,
  L.termYear,
  L.termMinimum,
  L.termMaximum,
  L.senderFunction_ID,
  L.receiverFunction_ID,
  L.earlyExitCheck_ID
FROM Allocations AS L;

CREATE VIEW localized_AllocationSenderViews AS SELECT
  L.createdAt,
  L.createdBy,
  L.modifiedAt,
  L.modifiedBy,
  L.environment_ID,
  L.function_ID,
  L.formula,
  L.order_code,
  L.ID,
  L.allocation_ID,
  L.field_ID
FROM AllocationSenderViews AS L;

CREATE VIEW localized_AllocationSenderViewSelections AS SELECT
  L.createdAt,
  L.createdBy,
  L.modifiedAt,
  L.modifiedBy,
  L.environment_ID,
  L.function_ID,
  L.seq,
  L.sign_code,
  L.opt_code,
  L.low,
  L.high,
  L.ID,
  L.field_ID
FROM AllocationSenderViewSelections AS L;

CREATE VIEW localized_AllocationReceiverViews AS SELECT
  L.createdAt,
  L.createdBy,
  L.modifiedAt,
  L.modifiedBy,
  L.environment_ID,
  L.function_ID,
  L.formula,
  L.order_code,
  L.ID,
  L.allocation_ID,
  L.field_ID
FROM AllocationReceiverViews AS L;

CREATE VIEW localized_AllocationReceiverViewSelections AS SELECT
  L.createdAt,
  L.createdBy,
  L.modifiedAt,
  L.modifiedBy,
  L.environment_ID,
  L.function_ID,
  L.seq,
  L.sign_code,
  L.opt_code,
  L.low,
  L.high,
  L.ID,
  L.field_ID
FROM AllocationReceiverViewSelections AS L;

CREATE VIEW localized_AllocationRules AS SELECT
  L.createdAt,
  L.createdBy,
  L.modifiedAt,
  L.modifiedBy,
  L.environment_ID,
  L.function_ID,
  L.ID,
  L.allocation_ID,
  L.sequence,
  L.rule,
  L.description,
  L.isActive,
  L.type_code,
  L.senderRule_code,
  L.senderShare,
  L.method_code,
  L.distributionBase,
  L.parentRule_ID,
  L.receiverRule_code,
  L.scale_code,
  L.driverResultField_ID
FROM AllocationRules AS L;

CREATE VIEW localized_AllocationRuleSenderViews AS SELECT
  L.createdAt,
  L.createdBy,
  L.modifiedAt,
  L.modifiedBy,
  L.environment_ID,
  L.function_ID,
  L.formula,
  L.group_code,
  L.order_code,
  L.ID,
  L.rule_ID,
  L.field_ID
FROM AllocationRuleSenderViews AS L;

CREATE VIEW localized_AllocationRuleSenderFieldSelections AS SELECT
  L.createdAt,
  L.createdBy,
  L.modifiedAt,
  L.modifiedBy,
  L.environment_ID,
  L.function_ID,
  L.seq,
  L.sign_code,
  L.opt_code,
  L.low,
  L.high,
  L.ID,
  L.field_ID
FROM AllocationRuleSenderFieldSelections AS L;

CREATE VIEW localized_AllocationRuleReceiverViews AS SELECT
  L.createdAt,
  L.createdBy,
  L.modifiedAt,
  L.modifiedBy,
  L.environment_ID,
  L.function_ID,
  L.formula,
  L.group_code,
  L.order_code,
  L.ID,
  L.rule_ID,
  L.field_ID
FROM AllocationRuleReceiverViews AS L;

CREATE VIEW localized_AllocationRuleReceiverFieldSelections AS SELECT
  L.createdAt,
  L.createdBy,
  L.modifiedAt,
  L.modifiedBy,
  L.environment_ID,
  L.function_ID,
  L.seq,
  L.sign_code,
  L.opt_code,
  L.low,
  L.high,
  L.ID,
  L.field_ID
FROM AllocationRuleReceiverFieldSelections AS L;

CREATE VIEW localized_ModelTables AS SELECT
  L.createdAt,
  L.createdBy,
  L.modifiedAt,
  L.modifiedBy,
  L.environment_ID,
  L.function_ID,
  L.ID,
  L.type_code,
  L.transportData,
  L.connection
FROM ModelTables AS L;

CREATE VIEW localized_FieldValues AS SELECT
  L.createdAt,
  L.createdBy,
  L.modifiedAt,
  L.modifiedBy,
  L.environment_ID,
  L.field_ID,
  L.ID,
  L.value,
  L.isNode,
  L.description
FROM FieldValues AS L;

CREATE VIEW localized_FieldValueAuthorizations AS SELECT
  L.createdAt,
  L.createdBy,
  L.modifiedAt,
  L.modifiedBy,
  L.environment_ID,
  L.field_ID,
  L.ID,
  L.value_ID,
  L.userGrp,
  L.readAccess,
  L.writeAccess
FROM FieldValueAuthorizations AS L;

CREATE VIEW localized_FieldHierarchies AS SELECT
  L.createdAt,
  L.createdBy,
  L.modifiedAt,
  L.modifiedBy,
  L.environment_ID,
  L.field_ID,
  L.ID,
  L.hierarchy,
  L.description
FROM FieldHierarchies AS L;

CREATE VIEW localized_FieldHierarchyStructures AS SELECT
  L.createdAt,
  L.createdBy,
  L.modifiedAt,
  L.modifiedBy,
  L.environment_ID,
  L.field_ID,
  L.ID,
  L.sequence,
  L.hierarchy_ID,
  L.value_ID,
  L.parentValue_ID
FROM FieldHierarchyStructures AS L;

CREATE VIEW localized_CurrencyConversions AS SELECT
  L.createdAt,
  L.createdBy,
  L.modifiedAt,
  L.modifiedBy,
  L.environment_ID,
  L.ID,
  L.currencyConversion,
  L.description,
  L.category_code,
  L.method_code,
  L.bidAskType_code,
  L.marketDataArea,
  L.type,
  L.lookup_code,
  L.errorHandling_code,
  L.accuracy_code,
  L.dateFormat_code,
  L.steps_code,
  L.configurationConnection_ID,
  L.rateConnection_ID,
  L.prefactorConnection_ID
FROM CurrencyConversions AS L;

CREATE VIEW localized_UnitConversions AS SELECT
  L.createdAt,
  L.createdBy,
  L.modifiedAt,
  L.modifiedBy,
  L.environment_ID,
  L.ID,
  L.unitConversion,
  L.description,
  L.errorHandling_code,
  L.rateConnection_ID,
  L.dimensionConnection_ID
FROM UnitConversions AS L;

CREATE VIEW localized_Partitions AS SELECT
  L.createdAt,
  L.createdBy,
  L.modifiedAt,
  L.modifiedBy,
  L.environment_ID,
  L.ID,
  L."partition",
  L.description,
  L.field_ID
FROM Partitions AS L;

CREATE VIEW localized_PartitionRanges AS SELECT
  L.createdAt,
  L.createdBy,
  L.modifiedAt,
  L.modifiedBy,
  L.environment_ID,
  L.ID,
  L.partition_ID,
  L."range",
  L.sequence,
  L.level,
  L.value,
  L.hanaVolumeId
FROM PartitionRanges AS L;

CREATE VIEW localized_Connections AS SELECT
  L.createdAt,
  L.createdBy,
  L.modifiedAt,
  L.modifiedBy,
  L.environment_ID,
  L.ID,
  L.connection,
  L.description
FROM Connections AS L;

CREATE VIEW localized_AllocationOffsets AS SELECT
  L.createdAt,
  L.createdBy,
  L.modifiedAt,
  L.modifiedBy,
  L.environment_ID,
  L.function_ID,
  L.ID,
  L.allocation_ID,
  L.field_ID,
  L.offsetField_ID
FROM AllocationOffsets AS L;

CREATE VIEW localized_AllocationDebitCredits AS SELECT
  L.createdAt,
  L.createdBy,
  L.modifiedAt,
  L.modifiedBy,
  L.environment_ID,
  L.function_ID,
  L.ID,
  L.allocation_ID,
  L.field_ID,
  L.debitSign,
  L.creditSign,
  L.sequence
FROM AllocationDebitCredits AS L;

CREATE VIEW localized_AllocationChecks AS SELECT
  L.createdAt,
  L.createdBy,
  L.modifiedAt,
  L.modifiedBy,
  L.environment_ID,
  L.function_ID,
  L.ID,
  L.allocation_ID,
  L.check_ID
FROM AllocationChecks AS L;

CREATE VIEW localized_AllocationSelectionFields AS SELECT
  L.createdAt,
  L.createdBy,
  L.modifiedAt,
  L.modifiedBy,
  L.environment_ID,
  L.function_ID,
  L.ID,
  L.allocation_ID,
  L.field_ID
FROM AllocationSelectionFields AS L;

CREATE VIEW localized_AllocationActionFields AS SELECT
  L.createdAt,
  L.createdBy,
  L.modifiedAt,
  L.modifiedBy,
  L.environment_ID,
  L.function_ID,
  L.ID,
  L.allocation_ID,
  L.field_ID
FROM AllocationActionFields AS L;

CREATE VIEW localized_AllocationReceiverSelectionFields AS SELECT
  L.createdAt,
  L.createdBy,
  L.modifiedAt,
  L.modifiedBy,
  L.environment_ID,
  L.function_ID,
  L.ID,
  L.allocation_ID,
  L.field_ID
FROM AllocationReceiverSelectionFields AS L;

CREATE VIEW localized_AllocationReceiverActionFields AS SELECT
  L.createdAt,
  L.createdBy,
  L.modifiedAt,
  L.modifiedBy,
  L.environment_ID,
  L.function_ID,
  L.ID,
  L.allocation_ID,
  L.field_ID
FROM AllocationReceiverActionFields AS L;

CREATE VIEW localized_AllocationRuleSenderValueFields AS SELECT
  L.createdAt,
  L.createdBy,
  L.modifiedAt,
  L.modifiedBy,
  L.environment_ID,
  L.function_ID,
  L.ID,
  L.rule_ID,
  L.field_ID
FROM AllocationRuleSenderValueFields AS L;

CREATE VIEW localized_CalculationUnits AS SELECT
  L.createdAt,
  L.createdBy,
  L.modifiedAt,
  L.modifiedBy,
  L.environment_ID,
  L.function_ID,
  L.ID,
  L.dummy
FROM CalculationUnits AS L;

CREATE VIEW localized_ModelTableFields AS SELECT
  L.createdAt,
  L.createdBy,
  L.modifiedAt,
  L.modifiedBy,
  L.environment_ID,
  L.field_ID,
  L.ID,
  L.modelTable_ID
FROM ModelTableFields AS L;

CREATE VIEW localized_CheckFields AS SELECT
  L.createdAt,
  L.createdBy,
  L.modifiedAt,
  L.modifiedBy,
  L.ID,
  L.check_ID,
  L.field_ID
FROM CheckFields AS L;

CREATE VIEW EnvironmentService_DraftAdministrativeData AS SELECT
  DraftAdministrativeData.DraftUUID,
  DraftAdministrativeData.CreationDateTime,
  DraftAdministrativeData.CreatedByUser,
  DraftAdministrativeData.DraftIsCreatedByMe,
  DraftAdministrativeData.LastChangeDateTime,
  DraftAdministrativeData.LastChangedByUser,
  DraftAdministrativeData.InProcessByUser,
  DraftAdministrativeData.DraftIsProcessedByMe
FROM DRAFT_DraftAdministrativeData AS DraftAdministrativeData;

CREATE VIEW EnvironmentService_EnvironmentFolders AS SELECT
  EnvironmentFolders_0.createdAt,
  EnvironmentFolders_0.createdBy,
  EnvironmentFolders_0.modifiedAt,
  EnvironmentFolders_0.modifiedBy,
  EnvironmentFolders_0.ID,
  EnvironmentFolders_0.environment,
  EnvironmentFolders_0.version,
  EnvironmentFolders_0.description,
  EnvironmentFolders_0.parent_ID,
  EnvironmentFolders_0.type_code
FROM EnvironmentFolders AS EnvironmentFolders_0;

CREATE VIEW localized_EnvironmentFolders AS SELECT
  Environments_0.createdAt,
  Environments_0.createdBy,
  Environments_0.modifiedAt,
  Environments_0.modifiedBy,
  Environments_0.ID,
  Environments_0.environment,
  Environments_0.version,
  Environments_0.description,
  Environments_0.parent_ID,
  Environments_0.type_code
FROM localized_Environments AS Environments_0
WHERE Environments_0.type_code = 'NODE';

CREATE VIEW localized_UnitFields AS SELECT
  Fields_0.createdAt,
  Fields_0.createdBy,
  Fields_0.modifiedAt,
  Fields_0.modifiedBy,
  Fields_0.environment_ID,
  Fields_0.ID,
  Fields_0.field,
  Fields_0.class_code,
  Fields_0.type_code,
  Fields_0.hanaDataType_code,
  Fields_0.dataLength,
  Fields_0.dataDecimals,
  Fields_0.unitField_ID,
  Fields_0.isLowercase,
  Fields_0.hasMasterData,
  Fields_0.hasHierarchies,
  Fields_0.calculationHierarchy_ID,
  Fields_0.masterDataQuery_ID,
  Fields_0.description,
  Fields_0.documentation
FROM localized_Fields AS Fields_0
WHERE Fields_0.type_code = 'UNI';

CREATE VIEW localized_MasterDataQueries AS SELECT
  Functions_0.createdAt,
  Functions_0.createdBy,
  Functions_0.modifiedAt,
  Functions_0.modifiedBy,
  Functions_0.environment_ID,
  Functions_0.ID,
  Functions_0.function,
  Functions_0.sequence,
  Functions_0.parent_ID,
  Functions_0.type_code,
  Functions_0.description,
  Functions_0.documentation
FROM localized_Functions AS Functions_0
WHERE Functions_0.type_code = 'MT';

CREATE VIEW localized_FunctionParents AS SELECT
  Functions_0.createdAt,
  Functions_0.createdBy,
  Functions_0.modifiedAt,
  Functions_0.modifiedBy,
  Functions_0.environment_ID,
  Functions_0.ID,
  Functions_0.function,
  Functions_0.sequence,
  Functions_0.parent_ID,
  Functions_0.type_code,
  Functions_0.description,
  Functions_0.documentation
FROM localized_Functions AS Functions_0
WHERE Functions_0.type_code = 'CU' OR Functions_0.type_code = 'DS';

CREATE VIEW localized_ResultModelTables AS SELECT
  Functions_0.createdAt,
  Functions_0.createdBy,
  Functions_0.modifiedAt,
  Functions_0.modifiedBy,
  Functions_0.environment_ID,
  Functions_0.ID,
  Functions_0.function,
  Functions_0.sequence,
  Functions_0.parent_ID,
  Functions_0.type_code,
  Functions_0.description,
  Functions_0.documentation
FROM localized_Functions AS Functions_0
WHERE Functions_0.type_code = 'MT';

CREATE VIEW localized_FunctionParentCalculationUnits AS SELECT
  Functions_0.createdAt,
  Functions_0.createdBy,
  Functions_0.modifiedAt,
  Functions_0.modifiedBy,
  Functions_0.environment_ID,
  Functions_0.ID,
  Functions_0.function,
  Functions_0.sequence,
  Functions_0.parent_ID,
  Functions_0.type_code,
  Functions_0.description,
  Functions_0.documentation
FROM localized_Functions AS Functions_0
WHERE Functions_0.type_code = 'CU';

CREATE VIEW localized_OffsetAllocation AS SELECT
  Allocations_0.environment_ID,
  Allocations_0.function_ID,
  Allocations_0.ID,
  Allocations_0.type_code,
  Allocations_0.valueAdjustment_code,
  Allocations_0.includeInputData,
  Allocations_0.resultHandling_code,
  Allocations_0.includeInitialResult,
  Allocations_0.senderFunction_ID,
  Allocations_0.receiverFunction_ID,
  Allocations_0.resultFunction_ID
FROM localized_Allocations AS Allocations_0;

CREATE VIEW localized_AllocationInputFunctions AS SELECT
  F_0.createdAt,
  F_0.createdBy,
  F_0.modifiedAt,
  F_0.modifiedBy,
  F_0.environment_ID,
  F_0.ID,
  F_0.function,
  F_0.sequence,
  F_0.parent_ID,
  F_0.type_code,
  F_0.description,
  F_0.documentation
FROM localized_Functions AS F_0
WHERE F_0.type_code IN ('MT', 'AL');

CREATE VIEW localized_AllocationTermIterationFields AS SELECT
  Fields_0.createdAt,
  Fields_0.createdBy,
  Fields_0.modifiedAt,
  Fields_0.modifiedBy,
  Fields_0.environment_ID,
  Fields_0.ID,
  Fields_0.field,
  Fields_0.class_code,
  Fields_0.type_code,
  Fields_0.hanaDataType_code,
  Fields_0.dataLength,
  Fields_0.dataDecimals,
  Fields_0.unitField_ID,
  Fields_0.isLowercase,
  Fields_0.hasMasterData,
  Fields_0.hasHierarchies,
  Fields_0.calculationHierarchy_ID,
  Fields_0.masterDataQuery_ID,
  Fields_0.description,
  Fields_0.documentation
FROM localized_Fields AS Fields_0
WHERE Fields_0.class_code = '' AND Fields_0.type_code = 'KYF';

CREATE VIEW localized_AllocationTermYearFields AS SELECT
  Fields_0.createdAt,
  Fields_0.createdBy,
  Fields_0.modifiedAt,
  Fields_0.modifiedBy,
  Fields_0.environment_ID,
  Fields_0.ID,
  Fields_0.field,
  Fields_0.class_code,
  Fields_0.type_code,
  Fields_0.hanaDataType_code,
  Fields_0.dataLength,
  Fields_0.dataDecimals,
  Fields_0.unitField_ID,
  Fields_0.isLowercase,
  Fields_0.hasMasterData,
  Fields_0.hasHierarchies,
  Fields_0.calculationHierarchy_ID,
  Fields_0.masterDataQuery_ID,
  Fields_0.description,
  Fields_0.documentation
FROM localized_Fields AS Fields_0
WHERE Fields_0.class_code = '' AND Fields_0.type_code = 'CHA' AND Fields_0.dataLength >= 4;

CREATE VIEW localized_AllocationTermFields AS SELECT
  Fields_0.createdAt,
  Fields_0.createdBy,
  Fields_0.modifiedAt,
  Fields_0.modifiedBy,
  Fields_0.environment_ID,
  Fields_0.ID,
  Fields_0.field,
  Fields_0.class_code,
  Fields_0.type_code,
  Fields_0.hanaDataType_code,
  Fields_0.dataLength,
  Fields_0.dataDecimals,
  Fields_0.unitField_ID,
  Fields_0.isLowercase,
  Fields_0.hasMasterData,
  Fields_0.hasHierarchies,
  Fields_0.calculationHierarchy_ID,
  Fields_0.masterDataQuery_ID,
  Fields_0.description,
  Fields_0.documentation
FROM localized_Fields AS Fields_0
WHERE Fields_0.class_code = '' AND Fields_0.type_code = 'CHA' AND Fields_0.dataLength >= 4;

CREATE VIEW localized_AllocationEarlyExitChecks AS SELECT
  Checks_0.createdAt,
  Checks_0.createdBy,
  Checks_0.modifiedAt,
  Checks_0.modifiedBy,
  Checks_0.environment_ID,
  Checks_0.ID,
  Checks_0."check",
  Checks_0.messageType_code,
  Checks_0.category_code,
  Checks_0.description
FROM localized_Checks AS Checks_0;

CREATE VIEW localized_AllocationRuleDriverResultFields AS SELECT
  F_0.createdAt,
  F_0.createdBy,
  F_0.modifiedAt,
  F_0.modifiedBy,
  F_0.environment_ID,
  F_0.ID,
  F_0.field,
  F_0.class_code,
  F_0.type_code,
  F_0.hanaDataType_code,
  F_0.dataLength,
  F_0.dataDecimals,
  F_0.unitField_ID,
  F_0.isLowercase,
  F_0.hasMasterData,
  F_0.hasHierarchies,
  F_0.calculationHierarchy_ID,
  F_0.masterDataQuery_ID,
  F_0.description,
  F_0.documentation
FROM localized_Fields AS F_0
WHERE F_0.class_code = '' AND F_0.type_code = 'KYF' AND F_0.ID IN (SELECT
    L_1.field_ID AS ID
  FROM ((localized_AllocationActionFields AS L_1 LEFT JOIN localized_Allocations AS allocation_2 ON L_1.allocation_ID = allocation_2.ID) LEFT JOIN localized_Functions AS function_3 ON allocation_2.function_ID = function_3.ID)
  WHERE F_0.environment_ID = function_3.environment_ID);

CREATE VIEW localized_AllocationCycleIterationFields AS SELECT
  F_0.createdAt,
  F_0.createdBy,
  F_0.modifiedAt,
  F_0.modifiedBy,
  F_0.environment_ID,
  F_0.ID,
  F_0.field,
  F_0.class_code,
  F_0.type_code,
  F_0.hanaDataType_code,
  F_0.dataLength,
  F_0.dataDecimals,
  F_0.unitField_ID,
  F_0.isLowercase,
  F_0.hasMasterData,
  F_0.hasHierarchies,
  F_0.calculationHierarchy_ID,
  F_0.masterDataQuery_ID,
  F_0.description,
  F_0.documentation
FROM localized_Fields AS F_0
WHERE F_0.class_code = '' AND F_0.type_code = 'KYF' AND F_0.ID IN (SELECT
    L_1.field_ID AS ID
  FROM ((localized_AllocationActionFields AS L_1 LEFT JOIN localized_Allocations AS allocation_2 ON L_1.allocation_ID = allocation_2.ID) LEFT JOIN localized_Functions AS function_3 ON allocation_2.function_ID = function_3.ID)
  WHERE F_0.environment_ID = function_3.environment_ID);

CREATE VIEW localized_ResultFunctions AS SELECT
  Functions_0.createdAt,
  Functions_0.createdBy,
  Functions_0.modifiedAt,
  Functions_0.modifiedBy,
  Functions_0.environment_ID,
  Functions_0.ID,
  Functions_0.function,
  Functions_0.sequence,
  Functions_0.parent_ID,
  Functions_0.type_code,
  Functions_0.description,
  Functions_0.documentation
FROM localized_Functions AS Functions_0
WHERE Functions_0.type_code = 'MT';

CREATE VIEW localized_EnvironmentService_EnvironmentTypes AS SELECT
  EnvironmentTypes_0.name,
  EnvironmentTypes_0.descr,
  EnvironmentTypes_0.code
FROM localized_EnvironmentTypes AS EnvironmentTypes_0;

CREATE VIEW localized_EnvironmentService_Environments AS SELECT
  environments_0.createdAt,
  environments_0.createdBy,
  environments_0.modifiedAt,
  environments_0.modifiedBy,
  environments_0.ID,
  environments_0.environment,
  environments_0.version,
  environments_0.description,
  environments_0.parent_ID,
  environments_0.type_code
FROM localized_Environments AS environments_0
ORDER BY environment, version;

CREATE VIEW localized_EnvironmentService_EnvironmentFolders AS SELECT
  EnvironmentFolders_0.createdAt,
  EnvironmentFolders_0.createdBy,
  EnvironmentFolders_0.modifiedAt,
  EnvironmentFolders_0.modifiedBy,
  EnvironmentFolders_0.ID,
  EnvironmentFolders_0.environment,
  EnvironmentFolders_0.version,
  EnvironmentFolders_0.description,
  EnvironmentFolders_0.parent_ID,
  EnvironmentFolders_0.type_code
FROM localized_EnvironmentFolders AS EnvironmentFolders_0;

CREATE VIEW localized_de_EnvironmentTypes AS SELECT
  coalesce(localized_de_1.name, L_0.name) AS name,
  coalesce(localized_de_1.descr, L_0.descr) AS descr,
  L_0.code
FROM (EnvironmentTypes AS L_0 LEFT JOIN EnvironmentTypes_texts AS localized_de_1 ON localized_de_1.code = L_0.code AND localized_de_1.locale = 'de');

CREATE VIEW localized_fr_EnvironmentTypes AS SELECT
  coalesce(localized_fr_1.name, L_0.name) AS name,
  coalesce(localized_fr_1.descr, L_0.descr) AS descr,
  L_0.code
FROM (EnvironmentTypes AS L_0 LEFT JOIN EnvironmentTypes_texts AS localized_fr_1 ON localized_fr_1.code = L_0.code AND localized_fr_1.locale = 'fr');

CREATE VIEW localized_de_MessageTypes AS SELECT
  coalesce(localized_de_1.name, L_0.name) AS name,
  coalesce(localized_de_1.descr, L_0.descr) AS descr,
  L_0.code
FROM (MessageTypes AS L_0 LEFT JOIN MessageTypes_texts AS localized_de_1 ON localized_de_1.code = L_0.code AND localized_de_1.locale = 'de');

CREATE VIEW localized_fr_MessageTypes AS SELECT
  coalesce(localized_fr_1.name, L_0.name) AS name,
  coalesce(localized_fr_1.descr, L_0.descr) AS descr,
  L_0.code
FROM (MessageTypes AS L_0 LEFT JOIN MessageTypes_texts AS localized_fr_1 ON localized_fr_1.code = L_0.code AND localized_fr_1.locale = 'fr');

CREATE VIEW localized_de_Groups AS SELECT
  coalesce(localized_de_1.name, L_0.name) AS name,
  coalesce(localized_de_1.descr, L_0.descr) AS descr,
  L_0.code
FROM ("Groups" AS L_0 LEFT JOIN Groups_texts AS localized_de_1 ON localized_de_1.code = L_0.code AND localized_de_1.locale = 'de');

CREATE VIEW localized_fr_Groups AS SELECT
  coalesce(localized_fr_1.name, L_0.name) AS name,
  coalesce(localized_fr_1.descr, L_0.descr) AS descr,
  L_0.code
FROM ("Groups" AS L_0 LEFT JOIN Groups_texts AS localized_fr_1 ON localized_fr_1.code = L_0.code AND localized_fr_1.locale = 'fr');

CREATE VIEW localized_de_Orders AS SELECT
  coalesce(localized_de_1.name, L_0.name) AS name,
  coalesce(localized_de_1.descr, L_0.descr) AS descr,
  L_0.code
FROM (Orders AS L_0 LEFT JOIN Orders_texts AS localized_de_1 ON localized_de_1.code = L_0.code AND localized_de_1.locale = 'de');

CREATE VIEW localized_fr_Orders AS SELECT
  coalesce(localized_fr_1.name, L_0.name) AS name,
  coalesce(localized_fr_1.descr, L_0.descr) AS descr,
  L_0.code
FROM (Orders AS L_0 LEFT JOIN Orders_texts AS localized_fr_1 ON localized_fr_1.code = L_0.code AND localized_fr_1.locale = 'fr');

CREATE VIEW localized_de_Signs AS SELECT
  coalesce(localized_de_1.name, L_0.name) AS name,
  coalesce(localized_de_1.descr, L_0.descr) AS descr,
  L_0.code
FROM (Signs AS L_0 LEFT JOIN Signs_texts AS localized_de_1 ON localized_de_1.code = L_0.code AND localized_de_1.locale = 'de');

CREATE VIEW localized_fr_Signs AS SELECT
  coalesce(localized_fr_1.name, L_0.name) AS name,
  coalesce(localized_fr_1.descr, L_0.descr) AS descr,
  L_0.code
FROM (Signs AS L_0 LEFT JOIN Signs_texts AS localized_fr_1 ON localized_fr_1.code = L_0.code AND localized_fr_1.locale = 'fr');

CREATE VIEW localized_de_Options AS SELECT
  coalesce(localized_de_1.name, L_0.name) AS name,
  coalesce(localized_de_1.descr, L_0.descr) AS descr,
  L_0.code
FROM (Options AS L_0 LEFT JOIN Options_texts AS localized_de_1 ON localized_de_1.code = L_0.code AND localized_de_1.locale = 'de');

CREATE VIEW localized_fr_Options AS SELECT
  coalesce(localized_fr_1.name, L_0.name) AS name,
  coalesce(localized_fr_1.descr, L_0.descr) AS descr,
  L_0.code
FROM (Options AS L_0 LEFT JOIN Options_texts AS localized_fr_1 ON localized_fr_1.code = L_0.code AND localized_fr_1.locale = 'fr');

CREATE VIEW localized_de_ResultHandlings AS SELECT
  coalesce(localized_de_1.name, L_0.name) AS name,
  coalesce(localized_de_1.descr, L_0.descr) AS descr,
  L_0.code
FROM (ResultHandlings AS L_0 LEFT JOIN ResultHandlings_texts AS localized_de_1 ON localized_de_1.code = L_0.code AND localized_de_1.locale = 'de');

CREATE VIEW localized_fr_ResultHandlings AS SELECT
  coalesce(localized_fr_1.name, L_0.name) AS name,
  coalesce(localized_fr_1.descr, L_0.descr) AS descr,
  L_0.code
FROM (ResultHandlings AS L_0 LEFT JOIN ResultHandlings_texts AS localized_fr_1 ON localized_fr_1.code = L_0.code AND localized_fr_1.locale = 'fr');

CREATE VIEW localized_de_FieldClasses AS SELECT
  coalesce(localized_de_1.name, L_0.name) AS name,
  coalesce(localized_de_1.descr, L_0.descr) AS descr,
  L_0.code
FROM (FieldClasses AS L_0 LEFT JOIN FieldClasses_texts AS localized_de_1 ON localized_de_1.code = L_0.code AND localized_de_1.locale = 'de');

CREATE VIEW localized_fr_FieldClasses AS SELECT
  coalesce(localized_fr_1.name, L_0.name) AS name,
  coalesce(localized_fr_1.descr, L_0.descr) AS descr,
  L_0.code
FROM (FieldClasses AS L_0 LEFT JOIN FieldClasses_texts AS localized_fr_1 ON localized_fr_1.code = L_0.code AND localized_fr_1.locale = 'fr');

CREATE VIEW localized_de_FieldTypes AS SELECT
  coalesce(localized_de_1.name, L_0.name) AS name,
  coalesce(localized_de_1.descr, L_0.descr) AS descr,
  L_0.code
FROM (FieldTypes AS L_0 LEFT JOIN FieldTypes_texts AS localized_de_1 ON localized_de_1.code = L_0.code AND localized_de_1.locale = 'de');

CREATE VIEW localized_fr_FieldTypes AS SELECT
  coalesce(localized_fr_1.name, L_0.name) AS name,
  coalesce(localized_fr_1.descr, L_0.descr) AS descr,
  L_0.code
FROM (FieldTypes AS L_0 LEFT JOIN FieldTypes_texts AS localized_fr_1 ON localized_fr_1.code = L_0.code AND localized_fr_1.locale = 'fr');

CREATE VIEW localized_de_HanaDataTypes AS SELECT
  coalesce(localized_de_1.name, L_0.name) AS name,
  coalesce(localized_de_1.descr, L_0.descr) AS descr,
  L_0.code
FROM (HanaDataTypes AS L_0 LEFT JOIN HanaDataTypes_texts AS localized_de_1 ON localized_de_1.code = L_0.code AND localized_de_1.locale = 'de');

CREATE VIEW localized_fr_HanaDataTypes AS SELECT
  coalesce(localized_fr_1.name, L_0.name) AS name,
  coalesce(localized_fr_1.descr, L_0.descr) AS descr,
  L_0.code
FROM (HanaDataTypes AS L_0 LEFT JOIN HanaDataTypes_texts AS localized_fr_1 ON localized_fr_1.code = L_0.code AND localized_fr_1.locale = 'fr');

CREATE VIEW localized_de_CheckCategories AS SELECT
  coalesce(localized_de_1.name, L_0.name) AS name,
  coalesce(localized_de_1.descr, L_0.descr) AS descr,
  L_0.code
FROM (CheckCategories AS L_0 LEFT JOIN CheckCategories_texts AS localized_de_1 ON localized_de_1.code = L_0.code AND localized_de_1.locale = 'de');

CREATE VIEW localized_fr_CheckCategories AS SELECT
  coalesce(localized_fr_1.name, L_0.name) AS name,
  coalesce(localized_fr_1.descr, L_0.descr) AS descr,
  L_0.code
FROM (CheckCategories AS L_0 LEFT JOIN CheckCategories_texts AS localized_fr_1 ON localized_fr_1.code = L_0.code AND localized_fr_1.locale = 'fr');

CREATE VIEW localized_de_FunctionTypes AS SELECT
  coalesce(localized_de_1.name, L_0.name) AS name,
  coalesce(localized_de_1.descr, L_0.descr) AS descr,
  L_0.code
FROM (FunctionTypes AS L_0 LEFT JOIN FunctionTypes_texts AS localized_de_1 ON localized_de_1.code = L_0.code AND localized_de_1.locale = 'de');

CREATE VIEW localized_fr_FunctionTypes AS SELECT
  coalesce(localized_fr_1.name, L_0.name) AS name,
  coalesce(localized_fr_1.descr, L_0.descr) AS descr,
  L_0.code
FROM (FunctionTypes AS L_0 LEFT JOIN FunctionTypes_texts AS localized_fr_1 ON localized_fr_1.code = L_0.code AND localized_fr_1.locale = 'fr');

CREATE VIEW localized_de_FunctionProcessingTypes AS SELECT
  coalesce(localized_de_1.name, L_0.name) AS name,
  coalesce(localized_de_1.descr, L_0.descr) AS descr,
  L_0.code
FROM (FunctionProcessingTypes AS L_0 LEFT JOIN FunctionProcessingTypes_texts AS localized_de_1 ON localized_de_1.code = L_0.code AND localized_de_1.locale = 'de');

CREATE VIEW localized_fr_FunctionProcessingTypes AS SELECT
  coalesce(localized_fr_1.name, L_0.name) AS name,
  coalesce(localized_fr_1.descr, L_0.descr) AS descr,
  L_0.code
FROM (FunctionProcessingTypes AS L_0 LEFT JOIN FunctionProcessingTypes_texts AS localized_fr_1 ON localized_fr_1.code = L_0.code AND localized_fr_1.locale = 'fr');

CREATE VIEW localized_de_FunctionBusinessEventTypes AS SELECT
  coalesce(localized_de_1.name, L_0.name) AS name,
  coalesce(localized_de_1.descr, L_0.descr) AS descr,
  L_0.code
FROM (FunctionBusinessEventTypes AS L_0 LEFT JOIN FunctionBusinessEventTypes_texts AS localized_de_1 ON localized_de_1.code = L_0.code AND localized_de_1.locale = 'de');

CREATE VIEW localized_fr_FunctionBusinessEventTypes AS SELECT
  coalesce(localized_fr_1.name, L_0.name) AS name,
  coalesce(localized_fr_1.descr, L_0.descr) AS descr,
  L_0.code
FROM (FunctionBusinessEventTypes AS L_0 LEFT JOIN FunctionBusinessEventTypes_texts AS localized_fr_1 ON localized_fr_1.code = L_0.code AND localized_fr_1.locale = 'fr');

CREATE VIEW localized_de_AllocationTypes AS SELECT
  coalesce(localized_de_1.name, L_0.name) AS name,
  coalesce(localized_de_1.descr, L_0.descr) AS descr,
  L_0.code
FROM (AllocationTypes AS L_0 LEFT JOIN AllocationTypes_texts AS localized_de_1 ON localized_de_1.code = L_0.code AND localized_de_1.locale = 'de');

CREATE VIEW localized_fr_AllocationTypes AS SELECT
  coalesce(localized_fr_1.name, L_0.name) AS name,
  coalesce(localized_fr_1.descr, L_0.descr) AS descr,
  L_0.code
FROM (AllocationTypes AS L_0 LEFT JOIN AllocationTypes_texts AS localized_fr_1 ON localized_fr_1.code = L_0.code AND localized_fr_1.locale = 'fr');

CREATE VIEW localized_de_AllocationValueAdjustments AS SELECT
  coalesce(localized_de_1.name, L_0.name) AS name,
  coalesce(localized_de_1.descr, L_0.descr) AS descr,
  L_0.code
FROM (AllocationValueAdjustments AS L_0 LEFT JOIN AllocationValueAdjustments_texts AS localized_de_1 ON localized_de_1.code = L_0.code AND localized_de_1.locale = 'de');

CREATE VIEW localized_fr_AllocationValueAdjustments AS SELECT
  coalesce(localized_fr_1.name, L_0.name) AS name,
  coalesce(localized_fr_1.descr, L_0.descr) AS descr,
  L_0.code
FROM (AllocationValueAdjustments AS L_0 LEFT JOIN AllocationValueAdjustments_texts AS localized_fr_1 ON localized_fr_1.code = L_0.code AND localized_fr_1.locale = 'fr');

CREATE VIEW localized_de_AllocationTermProcessings AS SELECT
  coalesce(localized_de_1.name, L_0.name) AS name,
  coalesce(localized_de_1.descr, L_0.descr) AS descr,
  L_0.code
FROM (AllocationTermProcessings AS L_0 LEFT JOIN AllocationTermProcessings_texts AS localized_de_1 ON localized_de_1.code = L_0.code AND localized_de_1.locale = 'de');

CREATE VIEW localized_fr_AllocationTermProcessings AS SELECT
  coalesce(localized_fr_1.name, L_0.name) AS name,
  coalesce(localized_fr_1.descr, L_0.descr) AS descr,
  L_0.code
FROM (AllocationTermProcessings AS L_0 LEFT JOIN AllocationTermProcessings_texts AS localized_fr_1 ON localized_fr_1.code = L_0.code AND localized_fr_1.locale = 'fr');

CREATE VIEW localized_de_AllocationCycleAggregations AS SELECT
  coalesce(localized_de_1.name, L_0.name) AS name,
  coalesce(localized_de_1.descr, L_0.descr) AS descr,
  L_0.code
FROM (AllocationCycleAggregations AS L_0 LEFT JOIN AllocationCycleAggregations_texts AS localized_de_1 ON localized_de_1.code = L_0.code AND localized_de_1.locale = 'de');

CREATE VIEW localized_fr_AllocationCycleAggregations AS SELECT
  coalesce(localized_fr_1.name, L_0.name) AS name,
  coalesce(localized_fr_1.descr, L_0.descr) AS descr,
  L_0.code
FROM (AllocationCycleAggregations AS L_0 LEFT JOIN AllocationCycleAggregations_texts AS localized_fr_1 ON localized_fr_1.code = L_0.code AND localized_fr_1.locale = 'fr');

CREATE VIEW localized_de_AllocationRuleTypes AS SELECT
  coalesce(localized_de_1.name, L_0.name) AS name,
  coalesce(localized_de_1.descr, L_0.descr) AS descr,
  L_0.code
FROM (AllocationRuleTypes AS L_0 LEFT JOIN AllocationRuleTypes_texts AS localized_de_1 ON localized_de_1.code = L_0.code AND localized_de_1.locale = 'de');

CREATE VIEW localized_fr_AllocationRuleTypes AS SELECT
  coalesce(localized_fr_1.name, L_0.name) AS name,
  coalesce(localized_fr_1.descr, L_0.descr) AS descr,
  L_0.code
FROM (AllocationRuleTypes AS L_0 LEFT JOIN AllocationRuleTypes_texts AS localized_fr_1 ON localized_fr_1.code = L_0.code AND localized_fr_1.locale = 'fr');

CREATE VIEW localized_de_AllocationRuleMethods AS SELECT
  coalesce(localized_de_1.name, L_0.name) AS name,
  coalesce(localized_de_1.descr, L_0.descr) AS descr,
  L_0.code
FROM (AllocationRuleMethods AS L_0 LEFT JOIN AllocationRuleMethods_texts AS localized_de_1 ON localized_de_1.code = L_0.code AND localized_de_1.locale = 'de');

CREATE VIEW localized_fr_AllocationRuleMethods AS SELECT
  coalesce(localized_fr_1.name, L_0.name) AS name,
  coalesce(localized_fr_1.descr, L_0.descr) AS descr,
  L_0.code
FROM (AllocationRuleMethods AS L_0 LEFT JOIN AllocationRuleMethods_texts AS localized_fr_1 ON localized_fr_1.code = L_0.code AND localized_fr_1.locale = 'fr');

CREATE VIEW localized_de_AllocationSenderRules AS SELECT
  coalesce(localized_de_1.name, L_0.name) AS name,
  coalesce(localized_de_1.descr, L_0.descr) AS descr,
  L_0.code
FROM (AllocationSenderRules AS L_0 LEFT JOIN AllocationSenderRules_texts AS localized_de_1 ON localized_de_1.code = L_0.code AND localized_de_1.locale = 'de');

CREATE VIEW localized_fr_AllocationSenderRules AS SELECT
  coalesce(localized_fr_1.name, L_0.name) AS name,
  coalesce(localized_fr_1.descr, L_0.descr) AS descr,
  L_0.code
FROM (AllocationSenderRules AS L_0 LEFT JOIN AllocationSenderRules_texts AS localized_fr_1 ON localized_fr_1.code = L_0.code AND localized_fr_1.locale = 'fr');

CREATE VIEW localized_de_AllocationReceiverRules AS SELECT
  coalesce(localized_de_1.name, L_0.name) AS name,
  coalesce(localized_de_1.descr, L_0.descr) AS descr,
  L_0.code
FROM (AllocationReceiverRules AS L_0 LEFT JOIN AllocationReceiverRules_texts AS localized_de_1 ON localized_de_1.code = L_0.code AND localized_de_1.locale = 'de');

CREATE VIEW localized_fr_AllocationReceiverRules AS SELECT
  coalesce(localized_fr_1.name, L_0.name) AS name,
  coalesce(localized_fr_1.descr, L_0.descr) AS descr,
  L_0.code
FROM (AllocationReceiverRules AS L_0 LEFT JOIN AllocationReceiverRules_texts AS localized_fr_1 ON localized_fr_1.code = L_0.code AND localized_fr_1.locale = 'fr');

CREATE VIEW localized_de_AllocationRuleScales AS SELECT
  coalesce(localized_de_1.name, L_0.name) AS name,
  coalesce(localized_de_1.descr, L_0.descr) AS descr,
  L_0.code
FROM (AllocationRuleScales AS L_0 LEFT JOIN AllocationRuleScales_texts AS localized_de_1 ON localized_de_1.code = L_0.code AND localized_de_1.locale = 'de');

CREATE VIEW localized_fr_AllocationRuleScales AS SELECT
  coalesce(localized_fr_1.name, L_0.name) AS name,
  coalesce(localized_fr_1.descr, L_0.descr) AS descr,
  L_0.code
FROM (AllocationRuleScales AS L_0 LEFT JOIN AllocationRuleScales_texts AS localized_fr_1 ON localized_fr_1.code = L_0.code AND localized_fr_1.locale = 'fr');

CREATE VIEW localized_de_ModelTableTypes AS SELECT
  coalesce(localized_de_1.name, L_0.name) AS name,
  coalesce(localized_de_1.descr, L_0.descr) AS descr,
  L_0.code
FROM (ModelTableTypes AS L_0 LEFT JOIN ModelTableTypes_texts AS localized_de_1 ON localized_de_1.code = L_0.code AND localized_de_1.locale = 'de');

CREATE VIEW localized_fr_ModelTableTypes AS SELECT
  coalesce(localized_fr_1.name, L_0.name) AS name,
  coalesce(localized_fr_1.descr, L_0.descr) AS descr,
  L_0.code
FROM (ModelTableTypes AS L_0 LEFT JOIN ModelTableTypes_texts AS localized_fr_1 ON localized_fr_1.code = L_0.code AND localized_fr_1.locale = 'fr');

CREATE VIEW localized_de_Environments AS SELECT
  L.createdAt,
  L.createdBy,
  L.modifiedAt,
  L.modifiedBy,
  L.ID,
  L.environment,
  L.version,
  L.description,
  L.parent_ID,
  L.type_code
FROM Environments AS L;

CREATE VIEW localized_fr_Environments AS SELECT
  L.createdAt,
  L.createdBy,
  L.modifiedAt,
  L.modifiedBy,
  L.ID,
  L.environment,
  L.version,
  L.description,
  L.parent_ID,
  L.type_code
FROM Environments AS L;

CREATE VIEW localized_de_Fields AS SELECT
  L.createdAt,
  L.createdBy,
  L.modifiedAt,
  L.modifiedBy,
  L.environment_ID,
  L.ID,
  L.field,
  L.class_code,
  L.type_code,
  L.hanaDataType_code,
  L.dataLength,
  L.dataDecimals,
  L.unitField_ID,
  L.isLowercase,
  L.hasMasterData,
  L.hasHierarchies,
  L.calculationHierarchy_ID,
  L.masterDataQuery_ID,
  L.description,
  L.documentation
FROM Fields AS L;

CREATE VIEW localized_fr_Fields AS SELECT
  L.createdAt,
  L.createdBy,
  L.modifiedAt,
  L.modifiedBy,
  L.environment_ID,
  L.ID,
  L.field,
  L.class_code,
  L.type_code,
  L.hanaDataType_code,
  L.dataLength,
  L.dataDecimals,
  L.unitField_ID,
  L.isLowercase,
  L.hasMasterData,
  L.hasHierarchies,
  L.calculationHierarchy_ID,
  L.masterDataQuery_ID,
  L.description,
  L.documentation
FROM Fields AS L;

CREATE VIEW localized_de_Checks AS SELECT
  L.createdAt,
  L.createdBy,
  L.modifiedAt,
  L.modifiedBy,
  L.environment_ID,
  L.ID,
  L."check",
  L.messageType_code,
  L.category_code,
  L.description
FROM Checks AS L;

CREATE VIEW localized_fr_Checks AS SELECT
  L.createdAt,
  L.createdBy,
  L.modifiedAt,
  L.modifiedBy,
  L.environment_ID,
  L.ID,
  L."check",
  L.messageType_code,
  L.category_code,
  L.description
FROM Checks AS L;

CREATE VIEW localized_de_CheckSelections AS SELECT
  L.createdAt,
  L.createdBy,
  L.modifiedAt,
  L.modifiedBy,
  L.seq,
  L.sign_code,
  L.opt_code,
  L.low,
  L.high,
  L.ID,
  L.field_ID
FROM CheckSelections AS L;

CREATE VIEW localized_fr_CheckSelections AS SELECT
  L.createdAt,
  L.createdBy,
  L.modifiedAt,
  L.modifiedBy,
  L.seq,
  L.sign_code,
  L.opt_code,
  L.low,
  L.high,
  L.ID,
  L.field_ID
FROM CheckSelections AS L;

CREATE VIEW localized_de_Functions AS SELECT
  L.createdAt,
  L.createdBy,
  L.modifiedAt,
  L.modifiedBy,
  L.environment_ID,
  L.ID,
  L.function,
  L.sequence,
  L.parent_ID,
  L.type_code,
  L.description,
  L.documentation
FROM Functions AS L;

CREATE VIEW localized_fr_Functions AS SELECT
  L.createdAt,
  L.createdBy,
  L.modifiedAt,
  L.modifiedBy,
  L.environment_ID,
  L.ID,
  L.function,
  L.sequence,
  L.parent_ID,
  L.type_code,
  L.description,
  L.documentation
FROM Functions AS L;

CREATE VIEW localized_de_Allocations AS SELECT
  L.createdAt,
  L.createdBy,
  L.modifiedAt,
  L.modifiedBy,
  L.environment_ID,
  L.function_ID,
  L.includeInputData,
  L.resultHandling_code,
  L.includeInitialResult,
  L.resultFunction_ID,
  L.processingType_code,
  L.businessEventType_code,
  L.partition_ID,
  L.ID,
  L.type_code,
  L.valueAdjustment_code,
  L.cycleFlag,
  L.cycleMaximum,
  L.cycleIterationField_ID,
  L.cycleAggregation_code,
  L.termFlag,
  L.termIterationField_ID,
  L.termYearField_ID,
  L.termField_ID,
  L.termProcessing_code,
  L.termYear,
  L.termMinimum,
  L.termMaximum,
  L.senderFunction_ID,
  L.receiverFunction_ID,
  L.earlyExitCheck_ID
FROM Allocations AS L;

CREATE VIEW localized_fr_Allocations AS SELECT
  L.createdAt,
  L.createdBy,
  L.modifiedAt,
  L.modifiedBy,
  L.environment_ID,
  L.function_ID,
  L.includeInputData,
  L.resultHandling_code,
  L.includeInitialResult,
  L.resultFunction_ID,
  L.processingType_code,
  L.businessEventType_code,
  L.partition_ID,
  L.ID,
  L.type_code,
  L.valueAdjustment_code,
  L.cycleFlag,
  L.cycleMaximum,
  L.cycleIterationField_ID,
  L.cycleAggregation_code,
  L.termFlag,
  L.termIterationField_ID,
  L.termYearField_ID,
  L.termField_ID,
  L.termProcessing_code,
  L.termYear,
  L.termMinimum,
  L.termMaximum,
  L.senderFunction_ID,
  L.receiverFunction_ID,
  L.earlyExitCheck_ID
FROM Allocations AS L;

CREATE VIEW localized_de_AllocationSenderViews AS SELECT
  L.createdAt,
  L.createdBy,
  L.modifiedAt,
  L.modifiedBy,
  L.environment_ID,
  L.function_ID,
  L.formula,
  L.order_code,
  L.ID,
  L.allocation_ID,
  L.field_ID
FROM AllocationSenderViews AS L;

CREATE VIEW localized_fr_AllocationSenderViews AS SELECT
  L.createdAt,
  L.createdBy,
  L.modifiedAt,
  L.modifiedBy,
  L.environment_ID,
  L.function_ID,
  L.formula,
  L.order_code,
  L.ID,
  L.allocation_ID,
  L.field_ID
FROM AllocationSenderViews AS L;

CREATE VIEW localized_de_AllocationSenderViewSelections AS SELECT
  L.createdAt,
  L.createdBy,
  L.modifiedAt,
  L.modifiedBy,
  L.environment_ID,
  L.function_ID,
  L.seq,
  L.sign_code,
  L.opt_code,
  L.low,
  L.high,
  L.ID,
  L.field_ID
FROM AllocationSenderViewSelections AS L;

CREATE VIEW localized_fr_AllocationSenderViewSelections AS SELECT
  L.createdAt,
  L.createdBy,
  L.modifiedAt,
  L.modifiedBy,
  L.environment_ID,
  L.function_ID,
  L.seq,
  L.sign_code,
  L.opt_code,
  L.low,
  L.high,
  L.ID,
  L.field_ID
FROM AllocationSenderViewSelections AS L;

CREATE VIEW localized_de_AllocationReceiverViews AS SELECT
  L.createdAt,
  L.createdBy,
  L.modifiedAt,
  L.modifiedBy,
  L.environment_ID,
  L.function_ID,
  L.formula,
  L.order_code,
  L.ID,
  L.allocation_ID,
  L.field_ID
FROM AllocationReceiverViews AS L;

CREATE VIEW localized_fr_AllocationReceiverViews AS SELECT
  L.createdAt,
  L.createdBy,
  L.modifiedAt,
  L.modifiedBy,
  L.environment_ID,
  L.function_ID,
  L.formula,
  L.order_code,
  L.ID,
  L.allocation_ID,
  L.field_ID
FROM AllocationReceiverViews AS L;

CREATE VIEW localized_de_AllocationReceiverViewSelections AS SELECT
  L.createdAt,
  L.createdBy,
  L.modifiedAt,
  L.modifiedBy,
  L.environment_ID,
  L.function_ID,
  L.seq,
  L.sign_code,
  L.opt_code,
  L.low,
  L.high,
  L.ID,
  L.field_ID
FROM AllocationReceiverViewSelections AS L;

CREATE VIEW localized_fr_AllocationReceiverViewSelections AS SELECT
  L.createdAt,
  L.createdBy,
  L.modifiedAt,
  L.modifiedBy,
  L.environment_ID,
  L.function_ID,
  L.seq,
  L.sign_code,
  L.opt_code,
  L.low,
  L.high,
  L.ID,
  L.field_ID
FROM AllocationReceiverViewSelections AS L;

CREATE VIEW localized_de_AllocationRules AS SELECT
  L.createdAt,
  L.createdBy,
  L.modifiedAt,
  L.modifiedBy,
  L.environment_ID,
  L.function_ID,
  L.ID,
  L.allocation_ID,
  L.sequence,
  L.rule,
  L.description,
  L.isActive,
  L.type_code,
  L.senderRule_code,
  L.senderShare,
  L.method_code,
  L.distributionBase,
  L.parentRule_ID,
  L.receiverRule_code,
  L.scale_code,
  L.driverResultField_ID
FROM AllocationRules AS L;

CREATE VIEW localized_fr_AllocationRules AS SELECT
  L.createdAt,
  L.createdBy,
  L.modifiedAt,
  L.modifiedBy,
  L.environment_ID,
  L.function_ID,
  L.ID,
  L.allocation_ID,
  L.sequence,
  L.rule,
  L.description,
  L.isActive,
  L.type_code,
  L.senderRule_code,
  L.senderShare,
  L.method_code,
  L.distributionBase,
  L.parentRule_ID,
  L.receiverRule_code,
  L.scale_code,
  L.driverResultField_ID
FROM AllocationRules AS L;

CREATE VIEW localized_de_AllocationRuleSenderViews AS SELECT
  L.createdAt,
  L.createdBy,
  L.modifiedAt,
  L.modifiedBy,
  L.environment_ID,
  L.function_ID,
  L.formula,
  L.group_code,
  L.order_code,
  L.ID,
  L.rule_ID,
  L.field_ID
FROM AllocationRuleSenderViews AS L;

CREATE VIEW localized_fr_AllocationRuleSenderViews AS SELECT
  L.createdAt,
  L.createdBy,
  L.modifiedAt,
  L.modifiedBy,
  L.environment_ID,
  L.function_ID,
  L.formula,
  L.group_code,
  L.order_code,
  L.ID,
  L.rule_ID,
  L.field_ID
FROM AllocationRuleSenderViews AS L;

CREATE VIEW localized_de_AllocationRuleSenderFieldSelections AS SELECT
  L.createdAt,
  L.createdBy,
  L.modifiedAt,
  L.modifiedBy,
  L.environment_ID,
  L.function_ID,
  L.seq,
  L.sign_code,
  L.opt_code,
  L.low,
  L.high,
  L.ID,
  L.field_ID
FROM AllocationRuleSenderFieldSelections AS L;

CREATE VIEW localized_fr_AllocationRuleSenderFieldSelections AS SELECT
  L.createdAt,
  L.createdBy,
  L.modifiedAt,
  L.modifiedBy,
  L.environment_ID,
  L.function_ID,
  L.seq,
  L.sign_code,
  L.opt_code,
  L.low,
  L.high,
  L.ID,
  L.field_ID
FROM AllocationRuleSenderFieldSelections AS L;

CREATE VIEW localized_de_AllocationRuleReceiverViews AS SELECT
  L.createdAt,
  L.createdBy,
  L.modifiedAt,
  L.modifiedBy,
  L.environment_ID,
  L.function_ID,
  L.formula,
  L.group_code,
  L.order_code,
  L.ID,
  L.rule_ID,
  L.field_ID
FROM AllocationRuleReceiverViews AS L;

CREATE VIEW localized_fr_AllocationRuleReceiverViews AS SELECT
  L.createdAt,
  L.createdBy,
  L.modifiedAt,
  L.modifiedBy,
  L.environment_ID,
  L.function_ID,
  L.formula,
  L.group_code,
  L.order_code,
  L.ID,
  L.rule_ID,
  L.field_ID
FROM AllocationRuleReceiverViews AS L;

CREATE VIEW localized_de_AllocationRuleReceiverFieldSelections AS SELECT
  L.createdAt,
  L.createdBy,
  L.modifiedAt,
  L.modifiedBy,
  L.environment_ID,
  L.function_ID,
  L.seq,
  L.sign_code,
  L.opt_code,
  L.low,
  L.high,
  L.ID,
  L.field_ID
FROM AllocationRuleReceiverFieldSelections AS L;

CREATE VIEW localized_fr_AllocationRuleReceiverFieldSelections AS SELECT
  L.createdAt,
  L.createdBy,
  L.modifiedAt,
  L.modifiedBy,
  L.environment_ID,
  L.function_ID,
  L.seq,
  L.sign_code,
  L.opt_code,
  L.low,
  L.high,
  L.ID,
  L.field_ID
FROM AllocationRuleReceiverFieldSelections AS L;

CREATE VIEW localized_de_ModelTables AS SELECT
  L.createdAt,
  L.createdBy,
  L.modifiedAt,
  L.modifiedBy,
  L.environment_ID,
  L.function_ID,
  L.ID,
  L.type_code,
  L.transportData,
  L.connection
FROM ModelTables AS L;

CREATE VIEW localized_fr_ModelTables AS SELECT
  L.createdAt,
  L.createdBy,
  L.modifiedAt,
  L.modifiedBy,
  L.environment_ID,
  L.function_ID,
  L.ID,
  L.type_code,
  L.transportData,
  L.connection
FROM ModelTables AS L;

CREATE VIEW localized_de_FieldValues AS SELECT
  L.createdAt,
  L.createdBy,
  L.modifiedAt,
  L.modifiedBy,
  L.environment_ID,
  L.field_ID,
  L.ID,
  L.value,
  L.isNode,
  L.description
FROM FieldValues AS L;

CREATE VIEW localized_fr_FieldValues AS SELECT
  L.createdAt,
  L.createdBy,
  L.modifiedAt,
  L.modifiedBy,
  L.environment_ID,
  L.field_ID,
  L.ID,
  L.value,
  L.isNode,
  L.description
FROM FieldValues AS L;

CREATE VIEW localized_de_FieldValueAuthorizations AS SELECT
  L.createdAt,
  L.createdBy,
  L.modifiedAt,
  L.modifiedBy,
  L.environment_ID,
  L.field_ID,
  L.ID,
  L.value_ID,
  L.userGrp,
  L.readAccess,
  L.writeAccess
FROM FieldValueAuthorizations AS L;

CREATE VIEW localized_fr_FieldValueAuthorizations AS SELECT
  L.createdAt,
  L.createdBy,
  L.modifiedAt,
  L.modifiedBy,
  L.environment_ID,
  L.field_ID,
  L.ID,
  L.value_ID,
  L.userGrp,
  L.readAccess,
  L.writeAccess
FROM FieldValueAuthorizations AS L;

CREATE VIEW localized_de_FieldHierarchies AS SELECT
  L.createdAt,
  L.createdBy,
  L.modifiedAt,
  L.modifiedBy,
  L.environment_ID,
  L.field_ID,
  L.ID,
  L.hierarchy,
  L.description
FROM FieldHierarchies AS L;

CREATE VIEW localized_fr_FieldHierarchies AS SELECT
  L.createdAt,
  L.createdBy,
  L.modifiedAt,
  L.modifiedBy,
  L.environment_ID,
  L.field_ID,
  L.ID,
  L.hierarchy,
  L.description
FROM FieldHierarchies AS L;

CREATE VIEW localized_de_FieldHierarchyStructures AS SELECT
  L.createdAt,
  L.createdBy,
  L.modifiedAt,
  L.modifiedBy,
  L.environment_ID,
  L.field_ID,
  L.ID,
  L.sequence,
  L.hierarchy_ID,
  L.value_ID,
  L.parentValue_ID
FROM FieldHierarchyStructures AS L;

CREATE VIEW localized_fr_FieldHierarchyStructures AS SELECT
  L.createdAt,
  L.createdBy,
  L.modifiedAt,
  L.modifiedBy,
  L.environment_ID,
  L.field_ID,
  L.ID,
  L.sequence,
  L.hierarchy_ID,
  L.value_ID,
  L.parentValue_ID
FROM FieldHierarchyStructures AS L;

CREATE VIEW localized_de_CurrencyConversions AS SELECT
  L.createdAt,
  L.createdBy,
  L.modifiedAt,
  L.modifiedBy,
  L.environment_ID,
  L.ID,
  L.currencyConversion,
  L.description,
  L.category_code,
  L.method_code,
  L.bidAskType_code,
  L.marketDataArea,
  L.type,
  L.lookup_code,
  L.errorHandling_code,
  L.accuracy_code,
  L.dateFormat_code,
  L.steps_code,
  L.configurationConnection_ID,
  L.rateConnection_ID,
  L.prefactorConnection_ID
FROM CurrencyConversions AS L;

CREATE VIEW localized_fr_CurrencyConversions AS SELECT
  L.createdAt,
  L.createdBy,
  L.modifiedAt,
  L.modifiedBy,
  L.environment_ID,
  L.ID,
  L.currencyConversion,
  L.description,
  L.category_code,
  L.method_code,
  L.bidAskType_code,
  L.marketDataArea,
  L.type,
  L.lookup_code,
  L.errorHandling_code,
  L.accuracy_code,
  L.dateFormat_code,
  L.steps_code,
  L.configurationConnection_ID,
  L.rateConnection_ID,
  L.prefactorConnection_ID
FROM CurrencyConversions AS L;

CREATE VIEW localized_de_UnitConversions AS SELECT
  L.createdAt,
  L.createdBy,
  L.modifiedAt,
  L.modifiedBy,
  L.environment_ID,
  L.ID,
  L.unitConversion,
  L.description,
  L.errorHandling_code,
  L.rateConnection_ID,
  L.dimensionConnection_ID
FROM UnitConversions AS L;

CREATE VIEW localized_fr_UnitConversions AS SELECT
  L.createdAt,
  L.createdBy,
  L.modifiedAt,
  L.modifiedBy,
  L.environment_ID,
  L.ID,
  L.unitConversion,
  L.description,
  L.errorHandling_code,
  L.rateConnection_ID,
  L.dimensionConnection_ID
FROM UnitConversions AS L;

CREATE VIEW localized_de_Partitions AS SELECT
  L.createdAt,
  L.createdBy,
  L.modifiedAt,
  L.modifiedBy,
  L.environment_ID,
  L.ID,
  L."partition",
  L.description,
  L.field_ID
FROM Partitions AS L;

CREATE VIEW localized_fr_Partitions AS SELECT
  L.createdAt,
  L.createdBy,
  L.modifiedAt,
  L.modifiedBy,
  L.environment_ID,
  L.ID,
  L."partition",
  L.description,
  L.field_ID
FROM Partitions AS L;

CREATE VIEW localized_de_PartitionRanges AS SELECT
  L.createdAt,
  L.createdBy,
  L.modifiedAt,
  L.modifiedBy,
  L.environment_ID,
  L.ID,
  L.partition_ID,
  L."range",
  L.sequence,
  L.level,
  L.value,
  L.hanaVolumeId
FROM PartitionRanges AS L;

CREATE VIEW localized_fr_PartitionRanges AS SELECT
  L.createdAt,
  L.createdBy,
  L.modifiedAt,
  L.modifiedBy,
  L.environment_ID,
  L.ID,
  L.partition_ID,
  L."range",
  L.sequence,
  L.level,
  L.value,
  L.hanaVolumeId
FROM PartitionRanges AS L;

CREATE VIEW localized_de_Connections AS SELECT
  L.createdAt,
  L.createdBy,
  L.modifiedAt,
  L.modifiedBy,
  L.environment_ID,
  L.ID,
  L.connection,
  L.description
FROM Connections AS L;

CREATE VIEW localized_fr_Connections AS SELECT
  L.createdAt,
  L.createdBy,
  L.modifiedAt,
  L.modifiedBy,
  L.environment_ID,
  L.ID,
  L.connection,
  L.description
FROM Connections AS L;

CREATE VIEW localized_de_AllocationOffsets AS SELECT
  L.createdAt,
  L.createdBy,
  L.modifiedAt,
  L.modifiedBy,
  L.environment_ID,
  L.function_ID,
  L.ID,
  L.allocation_ID,
  L.field_ID,
  L.offsetField_ID
FROM AllocationOffsets AS L;

CREATE VIEW localized_fr_AllocationOffsets AS SELECT
  L.createdAt,
  L.createdBy,
  L.modifiedAt,
  L.modifiedBy,
  L.environment_ID,
  L.function_ID,
  L.ID,
  L.allocation_ID,
  L.field_ID,
  L.offsetField_ID
FROM AllocationOffsets AS L;

CREATE VIEW localized_de_AllocationDebitCredits AS SELECT
  L.createdAt,
  L.createdBy,
  L.modifiedAt,
  L.modifiedBy,
  L.environment_ID,
  L.function_ID,
  L.ID,
  L.allocation_ID,
  L.field_ID,
  L.debitSign,
  L.creditSign,
  L.sequence
FROM AllocationDebitCredits AS L;

CREATE VIEW localized_fr_AllocationDebitCredits AS SELECT
  L.createdAt,
  L.createdBy,
  L.modifiedAt,
  L.modifiedBy,
  L.environment_ID,
  L.function_ID,
  L.ID,
  L.allocation_ID,
  L.field_ID,
  L.debitSign,
  L.creditSign,
  L.sequence
FROM AllocationDebitCredits AS L;

CREATE VIEW localized_de_AllocationChecks AS SELECT
  L.createdAt,
  L.createdBy,
  L.modifiedAt,
  L.modifiedBy,
  L.environment_ID,
  L.function_ID,
  L.ID,
  L.allocation_ID,
  L.check_ID
FROM AllocationChecks AS L;

CREATE VIEW localized_fr_AllocationChecks AS SELECT
  L.createdAt,
  L.createdBy,
  L.modifiedAt,
  L.modifiedBy,
  L.environment_ID,
  L.function_ID,
  L.ID,
  L.allocation_ID,
  L.check_ID
FROM AllocationChecks AS L;

CREATE VIEW localized_de_AllocationSelectionFields AS SELECT
  L.createdAt,
  L.createdBy,
  L.modifiedAt,
  L.modifiedBy,
  L.environment_ID,
  L.function_ID,
  L.ID,
  L.allocation_ID,
  L.field_ID
FROM AllocationSelectionFields AS L;

CREATE VIEW localized_fr_AllocationSelectionFields AS SELECT
  L.createdAt,
  L.createdBy,
  L.modifiedAt,
  L.modifiedBy,
  L.environment_ID,
  L.function_ID,
  L.ID,
  L.allocation_ID,
  L.field_ID
FROM AllocationSelectionFields AS L;

CREATE VIEW localized_de_AllocationActionFields AS SELECT
  L.createdAt,
  L.createdBy,
  L.modifiedAt,
  L.modifiedBy,
  L.environment_ID,
  L.function_ID,
  L.ID,
  L.allocation_ID,
  L.field_ID
FROM AllocationActionFields AS L;

CREATE VIEW localized_fr_AllocationActionFields AS SELECT
  L.createdAt,
  L.createdBy,
  L.modifiedAt,
  L.modifiedBy,
  L.environment_ID,
  L.function_ID,
  L.ID,
  L.allocation_ID,
  L.field_ID
FROM AllocationActionFields AS L;

CREATE VIEW localized_de_AllocationReceiverSelectionFields AS SELECT
  L.createdAt,
  L.createdBy,
  L.modifiedAt,
  L.modifiedBy,
  L.environment_ID,
  L.function_ID,
  L.ID,
  L.allocation_ID,
  L.field_ID
FROM AllocationReceiverSelectionFields AS L;

CREATE VIEW localized_fr_AllocationReceiverSelectionFields AS SELECT
  L.createdAt,
  L.createdBy,
  L.modifiedAt,
  L.modifiedBy,
  L.environment_ID,
  L.function_ID,
  L.ID,
  L.allocation_ID,
  L.field_ID
FROM AllocationReceiverSelectionFields AS L;

CREATE VIEW localized_de_AllocationReceiverActionFields AS SELECT
  L.createdAt,
  L.createdBy,
  L.modifiedAt,
  L.modifiedBy,
  L.environment_ID,
  L.function_ID,
  L.ID,
  L.allocation_ID,
  L.field_ID
FROM AllocationReceiverActionFields AS L;

CREATE VIEW localized_fr_AllocationReceiverActionFields AS SELECT
  L.createdAt,
  L.createdBy,
  L.modifiedAt,
  L.modifiedBy,
  L.environment_ID,
  L.function_ID,
  L.ID,
  L.allocation_ID,
  L.field_ID
FROM AllocationReceiverActionFields AS L;

CREATE VIEW localized_de_AllocationRuleSenderValueFields AS SELECT
  L.createdAt,
  L.createdBy,
  L.modifiedAt,
  L.modifiedBy,
  L.environment_ID,
  L.function_ID,
  L.ID,
  L.rule_ID,
  L.field_ID
FROM AllocationRuleSenderValueFields AS L;

CREATE VIEW localized_fr_AllocationRuleSenderValueFields AS SELECT
  L.createdAt,
  L.createdBy,
  L.modifiedAt,
  L.modifiedBy,
  L.environment_ID,
  L.function_ID,
  L.ID,
  L.rule_ID,
  L.field_ID
FROM AllocationRuleSenderValueFields AS L;

CREATE VIEW localized_de_CalculationUnits AS SELECT
  L.createdAt,
  L.createdBy,
  L.modifiedAt,
  L.modifiedBy,
  L.environment_ID,
  L.function_ID,
  L.ID,
  L.dummy
FROM CalculationUnits AS L;

CREATE VIEW localized_fr_CalculationUnits AS SELECT
  L.createdAt,
  L.createdBy,
  L.modifiedAt,
  L.modifiedBy,
  L.environment_ID,
  L.function_ID,
  L.ID,
  L.dummy
FROM CalculationUnits AS L;

CREATE VIEW localized_de_ModelTableFields AS SELECT
  L.createdAt,
  L.createdBy,
  L.modifiedAt,
  L.modifiedBy,
  L.environment_ID,
  L.field_ID,
  L.ID,
  L.modelTable_ID
FROM ModelTableFields AS L;

CREATE VIEW localized_fr_ModelTableFields AS SELECT
  L.createdAt,
  L.createdBy,
  L.modifiedAt,
  L.modifiedBy,
  L.environment_ID,
  L.field_ID,
  L.ID,
  L.modelTable_ID
FROM ModelTableFields AS L;

CREATE VIEW localized_de_CheckFields AS SELECT
  L.createdAt,
  L.createdBy,
  L.modifiedAt,
  L.modifiedBy,
  L.ID,
  L.check_ID,
  L.field_ID
FROM CheckFields AS L;

CREATE VIEW localized_fr_CheckFields AS SELECT
  L.createdAt,
  L.createdBy,
  L.modifiedAt,
  L.modifiedBy,
  L.ID,
  L.check_ID,
  L.field_ID
FROM CheckFields AS L;

CREATE VIEW localized_de_EnvironmentFolders AS SELECT
  Environments_0.createdAt,
  Environments_0.createdBy,
  Environments_0.modifiedAt,
  Environments_0.modifiedBy,
  Environments_0.ID,
  Environments_0.environment,
  Environments_0.version,
  Environments_0.description,
  Environments_0.parent_ID,
  Environments_0.type_code
FROM localized_de_Environments AS Environments_0
WHERE Environments_0.type_code = 'NODE';

CREATE VIEW localized_fr_EnvironmentFolders AS SELECT
  Environments_0.createdAt,
  Environments_0.createdBy,
  Environments_0.modifiedAt,
  Environments_0.modifiedBy,
  Environments_0.ID,
  Environments_0.environment,
  Environments_0.version,
  Environments_0.description,
  Environments_0.parent_ID,
  Environments_0.type_code
FROM localized_fr_Environments AS Environments_0
WHERE Environments_0.type_code = 'NODE';

CREATE VIEW localized_de_UnitFields AS SELECT
  Fields_0.createdAt,
  Fields_0.createdBy,
  Fields_0.modifiedAt,
  Fields_0.modifiedBy,
  Fields_0.environment_ID,
  Fields_0.ID,
  Fields_0.field,
  Fields_0.class_code,
  Fields_0.type_code,
  Fields_0.hanaDataType_code,
  Fields_0.dataLength,
  Fields_0.dataDecimals,
  Fields_0.unitField_ID,
  Fields_0.isLowercase,
  Fields_0.hasMasterData,
  Fields_0.hasHierarchies,
  Fields_0.calculationHierarchy_ID,
  Fields_0.masterDataQuery_ID,
  Fields_0.description,
  Fields_0.documentation
FROM localized_de_Fields AS Fields_0
WHERE Fields_0.type_code = 'UNI';

CREATE VIEW localized_fr_UnitFields AS SELECT
  Fields_0.createdAt,
  Fields_0.createdBy,
  Fields_0.modifiedAt,
  Fields_0.modifiedBy,
  Fields_0.environment_ID,
  Fields_0.ID,
  Fields_0.field,
  Fields_0.class_code,
  Fields_0.type_code,
  Fields_0.hanaDataType_code,
  Fields_0.dataLength,
  Fields_0.dataDecimals,
  Fields_0.unitField_ID,
  Fields_0.isLowercase,
  Fields_0.hasMasterData,
  Fields_0.hasHierarchies,
  Fields_0.calculationHierarchy_ID,
  Fields_0.masterDataQuery_ID,
  Fields_0.description,
  Fields_0.documentation
FROM localized_fr_Fields AS Fields_0
WHERE Fields_0.type_code = 'UNI';

CREATE VIEW localized_de_MasterDataQueries AS SELECT
  Functions_0.createdAt,
  Functions_0.createdBy,
  Functions_0.modifiedAt,
  Functions_0.modifiedBy,
  Functions_0.environment_ID,
  Functions_0.ID,
  Functions_0.function,
  Functions_0.sequence,
  Functions_0.parent_ID,
  Functions_0.type_code,
  Functions_0.description,
  Functions_0.documentation
FROM localized_de_Functions AS Functions_0
WHERE Functions_0.type_code = 'MT';

CREATE VIEW localized_fr_MasterDataQueries AS SELECT
  Functions_0.createdAt,
  Functions_0.createdBy,
  Functions_0.modifiedAt,
  Functions_0.modifiedBy,
  Functions_0.environment_ID,
  Functions_0.ID,
  Functions_0.function,
  Functions_0.sequence,
  Functions_0.parent_ID,
  Functions_0.type_code,
  Functions_0.description,
  Functions_0.documentation
FROM localized_fr_Functions AS Functions_0
WHERE Functions_0.type_code = 'MT';

CREATE VIEW localized_de_FunctionParents AS SELECT
  Functions_0.createdAt,
  Functions_0.createdBy,
  Functions_0.modifiedAt,
  Functions_0.modifiedBy,
  Functions_0.environment_ID,
  Functions_0.ID,
  Functions_0.function,
  Functions_0.sequence,
  Functions_0.parent_ID,
  Functions_0.type_code,
  Functions_0.description,
  Functions_0.documentation
FROM localized_de_Functions AS Functions_0
WHERE Functions_0.type_code = 'CU' OR Functions_0.type_code = 'DS';

CREATE VIEW localized_fr_FunctionParents AS SELECT
  Functions_0.createdAt,
  Functions_0.createdBy,
  Functions_0.modifiedAt,
  Functions_0.modifiedBy,
  Functions_0.environment_ID,
  Functions_0.ID,
  Functions_0.function,
  Functions_0.sequence,
  Functions_0.parent_ID,
  Functions_0.type_code,
  Functions_0.description,
  Functions_0.documentation
FROM localized_fr_Functions AS Functions_0
WHERE Functions_0.type_code = 'CU' OR Functions_0.type_code = 'DS';

CREATE VIEW localized_de_ResultModelTables AS SELECT
  Functions_0.createdAt,
  Functions_0.createdBy,
  Functions_0.modifiedAt,
  Functions_0.modifiedBy,
  Functions_0.environment_ID,
  Functions_0.ID,
  Functions_0.function,
  Functions_0.sequence,
  Functions_0.parent_ID,
  Functions_0.type_code,
  Functions_0.description,
  Functions_0.documentation
FROM localized_de_Functions AS Functions_0
WHERE Functions_0.type_code = 'MT';

CREATE VIEW localized_fr_ResultModelTables AS SELECT
  Functions_0.createdAt,
  Functions_0.createdBy,
  Functions_0.modifiedAt,
  Functions_0.modifiedBy,
  Functions_0.environment_ID,
  Functions_0.ID,
  Functions_0.function,
  Functions_0.sequence,
  Functions_0.parent_ID,
  Functions_0.type_code,
  Functions_0.description,
  Functions_0.documentation
FROM localized_fr_Functions AS Functions_0
WHERE Functions_0.type_code = 'MT';

CREATE VIEW localized_de_FunctionParentCalculationUnits AS SELECT
  Functions_0.createdAt,
  Functions_0.createdBy,
  Functions_0.modifiedAt,
  Functions_0.modifiedBy,
  Functions_0.environment_ID,
  Functions_0.ID,
  Functions_0.function,
  Functions_0.sequence,
  Functions_0.parent_ID,
  Functions_0.type_code,
  Functions_0.description,
  Functions_0.documentation
FROM localized_de_Functions AS Functions_0
WHERE Functions_0.type_code = 'CU';

CREATE VIEW localized_fr_FunctionParentCalculationUnits AS SELECT
  Functions_0.createdAt,
  Functions_0.createdBy,
  Functions_0.modifiedAt,
  Functions_0.modifiedBy,
  Functions_0.environment_ID,
  Functions_0.ID,
  Functions_0.function,
  Functions_0.sequence,
  Functions_0.parent_ID,
  Functions_0.type_code,
  Functions_0.description,
  Functions_0.documentation
FROM localized_fr_Functions AS Functions_0
WHERE Functions_0.type_code = 'CU';

CREATE VIEW localized_de_OffsetAllocation AS SELECT
  Allocations_0.environment_ID,
  Allocations_0.function_ID,
  Allocations_0.ID,
  Allocations_0.type_code,
  Allocations_0.valueAdjustment_code,
  Allocations_0.includeInputData,
  Allocations_0.resultHandling_code,
  Allocations_0.includeInitialResult,
  Allocations_0.senderFunction_ID,
  Allocations_0.receiverFunction_ID,
  Allocations_0.resultFunction_ID
FROM localized_de_Allocations AS Allocations_0;

CREATE VIEW localized_fr_OffsetAllocation AS SELECT
  Allocations_0.environment_ID,
  Allocations_0.function_ID,
  Allocations_0.ID,
  Allocations_0.type_code,
  Allocations_0.valueAdjustment_code,
  Allocations_0.includeInputData,
  Allocations_0.resultHandling_code,
  Allocations_0.includeInitialResult,
  Allocations_0.senderFunction_ID,
  Allocations_0.receiverFunction_ID,
  Allocations_0.resultFunction_ID
FROM localized_fr_Allocations AS Allocations_0;

CREATE VIEW localized_de_AllocationInputFunctions AS SELECT
  F_0.createdAt,
  F_0.createdBy,
  F_0.modifiedAt,
  F_0.modifiedBy,
  F_0.environment_ID,
  F_0.ID,
  F_0.function,
  F_0.sequence,
  F_0.parent_ID,
  F_0.type_code,
  F_0.description,
  F_0.documentation
FROM localized_de_Functions AS F_0
WHERE F_0.type_code IN ('MT', 'AL');

CREATE VIEW localized_fr_AllocationInputFunctions AS SELECT
  F_0.createdAt,
  F_0.createdBy,
  F_0.modifiedAt,
  F_0.modifiedBy,
  F_0.environment_ID,
  F_0.ID,
  F_0.function,
  F_0.sequence,
  F_0.parent_ID,
  F_0.type_code,
  F_0.description,
  F_0.documentation
FROM localized_fr_Functions AS F_0
WHERE F_0.type_code IN ('MT', 'AL');

CREATE VIEW localized_de_AllocationTermIterationFields AS SELECT
  Fields_0.createdAt,
  Fields_0.createdBy,
  Fields_0.modifiedAt,
  Fields_0.modifiedBy,
  Fields_0.environment_ID,
  Fields_0.ID,
  Fields_0.field,
  Fields_0.class_code,
  Fields_0.type_code,
  Fields_0.hanaDataType_code,
  Fields_0.dataLength,
  Fields_0.dataDecimals,
  Fields_0.unitField_ID,
  Fields_0.isLowercase,
  Fields_0.hasMasterData,
  Fields_0.hasHierarchies,
  Fields_0.calculationHierarchy_ID,
  Fields_0.masterDataQuery_ID,
  Fields_0.description,
  Fields_0.documentation
FROM localized_de_Fields AS Fields_0
WHERE Fields_0.class_code = '' AND Fields_0.type_code = 'KYF';

CREATE VIEW localized_fr_AllocationTermIterationFields AS SELECT
  Fields_0.createdAt,
  Fields_0.createdBy,
  Fields_0.modifiedAt,
  Fields_0.modifiedBy,
  Fields_0.environment_ID,
  Fields_0.ID,
  Fields_0.field,
  Fields_0.class_code,
  Fields_0.type_code,
  Fields_0.hanaDataType_code,
  Fields_0.dataLength,
  Fields_0.dataDecimals,
  Fields_0.unitField_ID,
  Fields_0.isLowercase,
  Fields_0.hasMasterData,
  Fields_0.hasHierarchies,
  Fields_0.calculationHierarchy_ID,
  Fields_0.masterDataQuery_ID,
  Fields_0.description,
  Fields_0.documentation
FROM localized_fr_Fields AS Fields_0
WHERE Fields_0.class_code = '' AND Fields_0.type_code = 'KYF';

CREATE VIEW localized_de_AllocationTermYearFields AS SELECT
  Fields_0.createdAt,
  Fields_0.createdBy,
  Fields_0.modifiedAt,
  Fields_0.modifiedBy,
  Fields_0.environment_ID,
  Fields_0.ID,
  Fields_0.field,
  Fields_0.class_code,
  Fields_0.type_code,
  Fields_0.hanaDataType_code,
  Fields_0.dataLength,
  Fields_0.dataDecimals,
  Fields_0.unitField_ID,
  Fields_0.isLowercase,
  Fields_0.hasMasterData,
  Fields_0.hasHierarchies,
  Fields_0.calculationHierarchy_ID,
  Fields_0.masterDataQuery_ID,
  Fields_0.description,
  Fields_0.documentation
FROM localized_de_Fields AS Fields_0
WHERE Fields_0.class_code = '' AND Fields_0.type_code = 'CHA' AND Fields_0.dataLength >= 4;

CREATE VIEW localized_fr_AllocationTermYearFields AS SELECT
  Fields_0.createdAt,
  Fields_0.createdBy,
  Fields_0.modifiedAt,
  Fields_0.modifiedBy,
  Fields_0.environment_ID,
  Fields_0.ID,
  Fields_0.field,
  Fields_0.class_code,
  Fields_0.type_code,
  Fields_0.hanaDataType_code,
  Fields_0.dataLength,
  Fields_0.dataDecimals,
  Fields_0.unitField_ID,
  Fields_0.isLowercase,
  Fields_0.hasMasterData,
  Fields_0.hasHierarchies,
  Fields_0.calculationHierarchy_ID,
  Fields_0.masterDataQuery_ID,
  Fields_0.description,
  Fields_0.documentation
FROM localized_fr_Fields AS Fields_0
WHERE Fields_0.class_code = '' AND Fields_0.type_code = 'CHA' AND Fields_0.dataLength >= 4;

CREATE VIEW localized_de_AllocationTermFields AS SELECT
  Fields_0.createdAt,
  Fields_0.createdBy,
  Fields_0.modifiedAt,
  Fields_0.modifiedBy,
  Fields_0.environment_ID,
  Fields_0.ID,
  Fields_0.field,
  Fields_0.class_code,
  Fields_0.type_code,
  Fields_0.hanaDataType_code,
  Fields_0.dataLength,
  Fields_0.dataDecimals,
  Fields_0.unitField_ID,
  Fields_0.isLowercase,
  Fields_0.hasMasterData,
  Fields_0.hasHierarchies,
  Fields_0.calculationHierarchy_ID,
  Fields_0.masterDataQuery_ID,
  Fields_0.description,
  Fields_0.documentation
FROM localized_de_Fields AS Fields_0
WHERE Fields_0.class_code = '' AND Fields_0.type_code = 'CHA' AND Fields_0.dataLength >= 4;

CREATE VIEW localized_fr_AllocationTermFields AS SELECT
  Fields_0.createdAt,
  Fields_0.createdBy,
  Fields_0.modifiedAt,
  Fields_0.modifiedBy,
  Fields_0.environment_ID,
  Fields_0.ID,
  Fields_0.field,
  Fields_0.class_code,
  Fields_0.type_code,
  Fields_0.hanaDataType_code,
  Fields_0.dataLength,
  Fields_0.dataDecimals,
  Fields_0.unitField_ID,
  Fields_0.isLowercase,
  Fields_0.hasMasterData,
  Fields_0.hasHierarchies,
  Fields_0.calculationHierarchy_ID,
  Fields_0.masterDataQuery_ID,
  Fields_0.description,
  Fields_0.documentation
FROM localized_fr_Fields AS Fields_0
WHERE Fields_0.class_code = '' AND Fields_0.type_code = 'CHA' AND Fields_0.dataLength >= 4;

CREATE VIEW localized_de_AllocationEarlyExitChecks AS SELECT
  Checks_0.createdAt,
  Checks_0.createdBy,
  Checks_0.modifiedAt,
  Checks_0.modifiedBy,
  Checks_0.environment_ID,
  Checks_0.ID,
  Checks_0."check",
  Checks_0.messageType_code,
  Checks_0.category_code,
  Checks_0.description
FROM localized_de_Checks AS Checks_0;

CREATE VIEW localized_fr_AllocationEarlyExitChecks AS SELECT
  Checks_0.createdAt,
  Checks_0.createdBy,
  Checks_0.modifiedAt,
  Checks_0.modifiedBy,
  Checks_0.environment_ID,
  Checks_0.ID,
  Checks_0."check",
  Checks_0.messageType_code,
  Checks_0.category_code,
  Checks_0.description
FROM localized_fr_Checks AS Checks_0;

CREATE VIEW localized_de_AllocationRuleDriverResultFields AS SELECT
  F_0.createdAt,
  F_0.createdBy,
  F_0.modifiedAt,
  F_0.modifiedBy,
  F_0.environment_ID,
  F_0.ID,
  F_0.field,
  F_0.class_code,
  F_0.type_code,
  F_0.hanaDataType_code,
  F_0.dataLength,
  F_0.dataDecimals,
  F_0.unitField_ID,
  F_0.isLowercase,
  F_0.hasMasterData,
  F_0.hasHierarchies,
  F_0.calculationHierarchy_ID,
  F_0.masterDataQuery_ID,
  F_0.description,
  F_0.documentation
FROM localized_de_Fields AS F_0
WHERE F_0.class_code = '' AND F_0.type_code = 'KYF' AND F_0.ID IN (SELECT
    L_1.field_ID AS ID
  FROM ((localized_de_AllocationActionFields AS L_1 LEFT JOIN localized_de_Allocations AS allocation_2 ON L_1.allocation_ID = allocation_2.ID) LEFT JOIN localized_de_Functions AS function_3 ON allocation_2.function_ID = function_3.ID)
  WHERE F_0.environment_ID = function_3.environment_ID);

CREATE VIEW localized_fr_AllocationRuleDriverResultFields AS SELECT
  F_0.createdAt,
  F_0.createdBy,
  F_0.modifiedAt,
  F_0.modifiedBy,
  F_0.environment_ID,
  F_0.ID,
  F_0.field,
  F_0.class_code,
  F_0.type_code,
  F_0.hanaDataType_code,
  F_0.dataLength,
  F_0.dataDecimals,
  F_0.unitField_ID,
  F_0.isLowercase,
  F_0.hasMasterData,
  F_0.hasHierarchies,
  F_0.calculationHierarchy_ID,
  F_0.masterDataQuery_ID,
  F_0.description,
  F_0.documentation
FROM localized_fr_Fields AS F_0
WHERE F_0.class_code = '' AND F_0.type_code = 'KYF' AND F_0.ID IN (SELECT
    L_1.field_ID AS ID
  FROM ((localized_fr_AllocationActionFields AS L_1 LEFT JOIN localized_fr_Allocations AS allocation_2 ON L_1.allocation_ID = allocation_2.ID) LEFT JOIN localized_fr_Functions AS function_3 ON allocation_2.function_ID = function_3.ID)
  WHERE F_0.environment_ID = function_3.environment_ID);

CREATE VIEW localized_de_AllocationCycleIterationFields AS SELECT
  F_0.createdAt,
  F_0.createdBy,
  F_0.modifiedAt,
  F_0.modifiedBy,
  F_0.environment_ID,
  F_0.ID,
  F_0.field,
  F_0.class_code,
  F_0.type_code,
  F_0.hanaDataType_code,
  F_0.dataLength,
  F_0.dataDecimals,
  F_0.unitField_ID,
  F_0.isLowercase,
  F_0.hasMasterData,
  F_0.hasHierarchies,
  F_0.calculationHierarchy_ID,
  F_0.masterDataQuery_ID,
  F_0.description,
  F_0.documentation
FROM localized_de_Fields AS F_0
WHERE F_0.class_code = '' AND F_0.type_code = 'KYF' AND F_0.ID IN (SELECT
    L_1.field_ID AS ID
  FROM ((localized_de_AllocationActionFields AS L_1 LEFT JOIN localized_de_Allocations AS allocation_2 ON L_1.allocation_ID = allocation_2.ID) LEFT JOIN localized_de_Functions AS function_3 ON allocation_2.function_ID = function_3.ID)
  WHERE F_0.environment_ID = function_3.environment_ID);

CREATE VIEW localized_fr_AllocationCycleIterationFields AS SELECT
  F_0.createdAt,
  F_0.createdBy,
  F_0.modifiedAt,
  F_0.modifiedBy,
  F_0.environment_ID,
  F_0.ID,
  F_0.field,
  F_0.class_code,
  F_0.type_code,
  F_0.hanaDataType_code,
  F_0.dataLength,
  F_0.dataDecimals,
  F_0.unitField_ID,
  F_0.isLowercase,
  F_0.hasMasterData,
  F_0.hasHierarchies,
  F_0.calculationHierarchy_ID,
  F_0.masterDataQuery_ID,
  F_0.description,
  F_0.documentation
FROM localized_fr_Fields AS F_0
WHERE F_0.class_code = '' AND F_0.type_code = 'KYF' AND F_0.ID IN (SELECT
    L_1.field_ID AS ID
  FROM ((localized_fr_AllocationActionFields AS L_1 LEFT JOIN localized_fr_Allocations AS allocation_2 ON L_1.allocation_ID = allocation_2.ID) LEFT JOIN localized_fr_Functions AS function_3 ON allocation_2.function_ID = function_3.ID)
  WHERE F_0.environment_ID = function_3.environment_ID);

CREATE VIEW localized_de_ResultFunctions AS SELECT
  Functions_0.createdAt,
  Functions_0.createdBy,
  Functions_0.modifiedAt,
  Functions_0.modifiedBy,
  Functions_0.environment_ID,
  Functions_0.ID,
  Functions_0.function,
  Functions_0.sequence,
  Functions_0.parent_ID,
  Functions_0.type_code,
  Functions_0.description,
  Functions_0.documentation
FROM localized_de_Functions AS Functions_0
WHERE Functions_0.type_code = 'MT';

CREATE VIEW localized_fr_ResultFunctions AS SELECT
  Functions_0.createdAt,
  Functions_0.createdBy,
  Functions_0.modifiedAt,
  Functions_0.modifiedBy,
  Functions_0.environment_ID,
  Functions_0.ID,
  Functions_0.function,
  Functions_0.sequence,
  Functions_0.parent_ID,
  Functions_0.type_code,
  Functions_0.description,
  Functions_0.documentation
FROM localized_fr_Functions AS Functions_0
WHERE Functions_0.type_code = 'MT';

CREATE VIEW localized_de_EnvironmentService_EnvironmentTypes AS SELECT
  EnvironmentTypes_0.name,
  EnvironmentTypes_0.descr,
  EnvironmentTypes_0.code
FROM localized_de_EnvironmentTypes AS EnvironmentTypes_0;

CREATE VIEW localized_fr_EnvironmentService_EnvironmentTypes AS SELECT
  EnvironmentTypes_0.name,
  EnvironmentTypes_0.descr,
  EnvironmentTypes_0.code
FROM localized_fr_EnvironmentTypes AS EnvironmentTypes_0;

CREATE VIEW localized_de_EnvironmentService_Environments AS SELECT
  environments_0.createdAt,
  environments_0.createdBy,
  environments_0.modifiedAt,
  environments_0.modifiedBy,
  environments_0.ID,
  environments_0.environment,
  environments_0.version,
  environments_0.description,
  environments_0.parent_ID,
  environments_0.type_code
FROM localized_de_Environments AS environments_0
ORDER BY environment, version;

CREATE VIEW localized_fr_EnvironmentService_Environments AS SELECT
  environments_0.createdAt,
  environments_0.createdBy,
  environments_0.modifiedAt,
  environments_0.modifiedBy,
  environments_0.ID,
  environments_0.environment,
  environments_0.version,
  environments_0.description,
  environments_0.parent_ID,
  environments_0.type_code
FROM localized_fr_Environments AS environments_0
ORDER BY environment, version;

CREATE VIEW localized_de_EnvironmentService_EnvironmentFolders AS SELECT
  EnvironmentFolders_0.createdAt,
  EnvironmentFolders_0.createdBy,
  EnvironmentFolders_0.modifiedAt,
  EnvironmentFolders_0.modifiedBy,
  EnvironmentFolders_0.ID,
  EnvironmentFolders_0.environment,
  EnvironmentFolders_0.version,
  EnvironmentFolders_0.description,
  EnvironmentFolders_0.parent_ID,
  EnvironmentFolders_0.type_code
FROM localized_de_EnvironmentFolders AS EnvironmentFolders_0;

CREATE VIEW localized_fr_EnvironmentService_EnvironmentFolders AS SELECT
  EnvironmentFolders_0.createdAt,
  EnvironmentFolders_0.createdBy,
  EnvironmentFolders_0.modifiedAt,
  EnvironmentFolders_0.modifiedBy,
  EnvironmentFolders_0.ID,
  EnvironmentFolders_0.environment,
  EnvironmentFolders_0.version,
  EnvironmentFolders_0.description,
  EnvironmentFolders_0.parent_ID,
  EnvironmentFolders_0.type_code
FROM localized_fr_EnvironmentFolders AS EnvironmentFolders_0;
