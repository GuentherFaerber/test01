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

This currently does not work (see this [SAP community question](https://answers.sap.com/questions/13666191/selectionvariant-to-filter-valuelist-in-fiori-elem.html) 
for details.

In addition to the mentioned question it needs to be evaluated if and how it is possible to adjust the selection variant by means of declaration in the ValueList annotation.
The idea is to do this e.g. as follows:

``` 
<PropertyValue Property="SelectionVariantQualifier" String="variant1" SelectionRangeType="Function eq MT1" />
```
Cause this is not forseen in the respective OData vocabulary the solution would probably be to define a selection variant for each indiviual filter.

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
