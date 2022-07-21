<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**  *generated with [DocToc](https://github.com/thlorenz/doctoc)*

- [Getting Started](#getting-started)
  - [Next Steps](#next-steps)
  - [Learn More](#learn-more)
  - [Ticket solutions](#ticket-solutions)
    - [FHC-570 Complex value help and validations in one](#fhc-570-complex-value-help-and-validations-in-one)
      - [Declarative Value Help filter](#declarative-value-help-filter)
        - [Evaluated standard solution](#evaluated-standard-solution)
        - [Realized Nexontis solution](#realized-nexontis-solution)
          - [ValueListParameterConstant solution](#valuelistparameterconstant-solution)
          - [Virtual properties solution](#virtual-properties-solution)
      - [Declarative Validation](#declarative-validation)
      - [Declarative Validation (deprecated, not used any longer)](#declarative-validation-deprecated-not-used-any-longer)
        - [@Nexontis.assert.recursion](#nexontisassertrecursion)
        - [@Nexontis.assert.checkAssocValues](#nexontisassertcheckassocvalues)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

# Getting Started

Welcome to your new project.

It contains these folders and files, following our recommended project layout:

File or Folder | Purpose
---------|----------
`app/` | content for UI frontends goes here
`db/` | your domain models and data go here
`srv/` | your service models and code go here
`package.json` | project metadata and configuration
`readme.md` | this getting started guide


## Next Steps

- Open a new terminal and run `cds watch` 
- (in VS Code simply choose _**Terminal** > Run Task > cds watch_)
- Start adding content, for example, a [db/schema.cds](db/schema.cds).


## Learn More

Learn more at https://cap.cloud.sap/docs/get-started/.

## Ticket solutions

### FHC-570 Complex value help and validations in one

This ticket consists of two parts

- Declarative Value Help filter
- Declarative validation

#### Declarative Value Help filter

In addition to the declarative ValueList annotation with its various parameters it should be possible to restrict the values of the value help with some indiviual filters declaratively.  
The ValueList parameters are combined with **and** operators. This is not sufficient for many use cases. Hence another solution needs to be found. 

In general it should be possible to achieve this with a selection variant that is applied to the 
value help dialog.

##### Evaluated standard solution

This (currently) does not work (see this [SAP community question](https://answers.sap.com/questions/13666191/selectionvariant-to-filter-valuelist-in-fiori-elem.html) 
for details.

In addition to the mentioned question it needs to be evaluated if and how it is possible to adjust the selection variant by means of declaration in the ValueList annotation.
The idea is to do this e.g. as follows:

``` 
<PropertyValue Property="SelectionVariantQualifier" String="variant1" SelectionRangeType="Function eq MT1" />
```
Cause this is not forseen in the respective OData vocabulary the solution would probably be to define a selection variant for each indiviual filter.

##### Realized Nexontis solution

Because of the issues with the "standard solution" the requirement is realized in this repository 

1. with a modification of Common.ValueListParameterConstant annotation,
2. by means of **virtual properties**, **annotations**, **CXN** and indiviual event handlers.

*CXN*

Both solutions use [CXN](https://cap.cloud.sap/docs/cds/cxn) as expression language to define the filters.

*Generic event handlers*

The event handlers don't have to be implemented by the application developer. They are implemented in [nexontis-annotations.js](./srv/modeling/nexontis-annotations.js). Have a look at it for
more details.

###### ValueListParameterConstant solution

The valueList annotation ValueListParameterConstant can be used to define value help filters declaratively.  
This solution uses a special @NX syntax in the constant definition.
```
  {
      $Type: 'Common.ValueListParameterConstant',
      Constant: '@NX:(type.code = "MT" or type.code = "AL")',
      ValueListProperty : 'type_code',
  },
```
To use this function the value of the constant property of this annotation needs to start with **@NX:**.  
After the colon a CXN expression follows that defines the filter restrictions. In this filter expression you can
define filters for all properties of the entity given in the collectionPath of the the ValueList annotation.

**Important note**  
Although this is deprecated by CAP strings in the CXN expression have to be surrounded by `" (double quotes)` as you can see
in the above example ("MT"). These double quotes are replaced by single quotes at runtime to avoid a CXN parse error.  
This is necessarry cause the recommended way by using `![]` does not work for ValueListParameterConstant.

**Disadvantage**  
With this solution it is not possible to filter the value list by dynamic values of the parents entity. That said you cannot
define a filter expression `environment_ID = $self.environment_ID` which is possible with the [Virtual properties solution](#virtual-properties-solution).  
To filter on such values the standard ValueList parameter `ValueListParameterIn` can be used. 

This approach uses the generic before read handler in [nexontis-annotations.js](./srv/modeling/nexontis-annotations.js).  
See function `handleNXValueListParameterConstantFilter` for the implementation.

###### Virtual properties solution

**Note:**  
This solution is not finally implemented yet. It currently shows an approach that is more flexible than [ValueListParameterConstant solution](#valuelistparameterconstant-solution) but comes
with a higher implementation effort and an additional virtual property, resp. an aspect, and an additional @NX annotation. See the TODOs section for more details on open issues.

The entities that are involved in the value help process need to have a virtual property **valueHelpDummy**. This can be added to such entities 
by using the aspect **nxValuehelp**. 
This aspect needs to be added to the value help entity as well as to the using entity (the entity that defines the property for which the value help should
be used).

These properties are the glue between the using and the valuehelp entities. They are used in the ValueList annotation. In this annotaion you define a IN parameter that refers to 
both entity properties (in the example and by default they have the same name).

```
annotate service.Allocations with {
    inputFunction @(Common.ValueList : {
            $Type : 'Common.ValueListType',
            CollectionPath : 'Functions',
            Parameters : [
                {
                    $Type : 'Common.ValueListParameterIn',
                    LocalDataProperty : valueHelpDummy,
                    ValueListProperty : 'valueHelpDummy',
                },
                {
                    $Type : 'Common.ValueListParameterInOut',
                    LocalDataProperty : inputFunction_ID,
                    ...
```

The aspect is defined in [commonAspects.cds](./db/commonAspects.cds).

```
aspect nxValuehelp: {
  virtual valueHelpDummy : String;
}
```

**Annotations** 

The property that is supposed to display the value help and that already has the ValueList annotation additionally needs the annotaion **NX.valuehelp**.
This annotation defines the additional query clauses leveraging the CXN expression language like shown in the example below.
```
NX.valuehelp : ![(type.code = 'MT' or type.code = 'AL') and environment_ID = $self.environment_ID]
```
You can use fields of the valuehelp entity that is defined in the collectionPath of the ValueList annotation to add additional filters.
The values of these fields can be static ones (type.code = 'MT') or they can refer to properties of the using entity (environment_ID = $self.environment_ID). 
The latter ones are defines with the syntax **$self.<any fieldname of the using entiy>**.  
Those references are resolved at runtime. This gives a higher level of flexibility.

**TODOs**
For a complete implementation of this solution the following topics have to be implemented. This is currently postponed cause this solution may be not further pursued.

*Change valueHelpDummy property to array*

The valueHelpDummy property of aspect `nxValuehelp` is currently defined as string. Hence it is only possible to define a valueHelp extension for one property. 
To make it usable for an arbitrary amount of properties the type of this property should be changed to a map with the property name as key and the CXN expression as
value.

*Implement Draft Mode event handlers*
Currently the evaluation of the dynamic parts of the CXN expression ($self...) is only implemented in the generic AFTER READ handler. Hence it does not work for
new objects of if values of the object change at runtime.  
To support this it should be sufficient to also implement it in teh Draft Mode event handlers (PATCH, NEW, EDIT, ...).

#### Declarative Validation 

The validation part of ticket [FHC-570](https://nexontis.atlassian.net/browse/FHC-570) is implemented using an @NX.assert annotation.  
We are using assertions cause this is the standard way in CAP for validation annotations. 

This validation is implemented in the before-CREATE and before-UPDATE handler in [nexontis-annotations.js](./srv/modeling/nexontis-annotations.js).  
To see implementation details have a look at the function `handleNXValidation`.

To use this validation you simply add a **@NX.assert.validate** annotation to the property that should be validated.
```
  @(NX.assert.validate : ![(type.code = 'MT' or type.code = 'AL') and ID <> $self.function_ID and environment_ID = $self.environment_ID])
```
After the colon you define a CXN expression that defines the validation rules. The validate function runs a SELECT on the association entity with
this filter and checks if the value the user selected/entered for the (foreign-key) field is part of the result set. If not a validation error is thrown.
As described in [Virtual property solution](#virtual-properties-solution) it is possible to use the **$self** keyword to replace the string by the current value 
of the parents property at runtime.

**TODOs (???)**  
This solution currently only works for to-one associations. If other use cases that can't be handled by standard CAP validations are needed they
must be implemented.

#### Declarative Validation (deprecated, not used any longer)

**Note**  
This solution is not used any longer as of 07/21/2022

The solution for the validation part of ticket [FHC-570](https://nexontis.atlassian.net/browse/FHC-570) looks like this:

Define a @Nexontis.assert annotation at an element (currently only associations are supported). Those annotations will be evaluated at runtime and rejects
to store the entity to the database if the assertion is not fullfilled.

Have a look at the file [nexontis-annotations.js](./srv/modeling/nexontis-annotations.js) for implementation details.

The following annotations are currently implemented.

##### @Nexontis.assert.recursion
```
@Nexontis.assert.recursion : false
```
When set to false this annotation ensures that no recurcive assiociation can be made.
E.g. If the user edits Functions 4 which has an assiociation senderFunction the senderFunction
cannot be set to 4

##### @Nexontis.assert.checkAssocValues

```
@(Nexontis.assert.checkAssocValues : {
  association   : 'type',
  field         : 'code',
  allowedValues : [
      'MT',
      'AL'
  ]
});
```
This annotation checks that only allowedValues (MT,AL in this case) can be set for an association of
the associated property.

E.g:

```
entity Allocations : managed, function {
    ...
    senderFunction          : Association to one Functions                      @title       : 'Sender Input' 
                                @(Nexontis.assert.checkAssocValues : {
                                  association   : 'type',
                                  field         : 'code',
                                  allowedValues : [
                                      'MT',
                                      'AL'
                                  ]
                                });
```
The entity Allocations has an association senderFunction to Functions. The annotaion defines that the field code of the association type
of Functions may only have the values MT and AL. If the user selects an association with a type CU for example the association rejects
to write the Allocations entity to the db.
