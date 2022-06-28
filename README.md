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

#### Value Help restriction

It should be possible to restrict the values of the value help with some indiviual filters. 
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

The requirement is realized by means of **virtual properties**, **annotations**, **CXN** and indiviual event handlers.

###### Virtual properties 

The entities that are involved in the value help process need to have a (virtual) property **valueHelpDummy**. This can be added to such entities 
by using the aspect **nxValuehelp**.  
This aspect needs to be added to the value help entity as well as to the using entity (the entity that defines the property for which the value help should
be used).

The aspect is defined in `commonAspects.cds`.

```
aspect nxValuehelp: {
  virtual valueHelpDummy : String;
}
```

###### Annotations 

The property that should display the value help and that already has the ValueList annotation additionally needs the annotaion **NX.valuehelp**.
This annotation defines the additional query clauses like shown in the example below.

You can use field of the valuehelp entity that is defined in the collectionPath of the ValueList annotation to add additional filters.
The values can be statich ones or those of the properties of the using entity. The latter are defines with the syntax **$self.<any fieldname of the using entiy>**.
Those references are resolved at runtime.

```
NX.valuehelp : ![(type.code = 'MT' or type.code = 'AL') and environment_ID = $self.environment_ID]
```

###### CXN

The filter expression for the additional filters are defined with [CXN](https://cap.cloud.sap/docs/cds/cxn).

###### Generic event handlers

The generic event handlers don't have to be implemented by the application developer. If you are interested in the implementation details have a look in `nexontis-annotations.js`.

#### Declarative Validation 

The solution for the validation part of ticket [FHC-570](https://nexontis.atlassian.net/browse/FHC-570) looks like this:

Define a @Nexontis.assert annotation at an element (currently only associations are supported). Those annotations will be evaluated at runtime and rejects
to store the entity to the database if the assertion is not fullfilled.

Have a look at the file `srv/modeling/nexontis-annotations.js` for implementation details.

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
