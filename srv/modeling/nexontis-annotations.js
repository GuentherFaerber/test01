const { SELECT } = cds.ql

module.exports = function () {

  /**
   * This function handles the @Nexontis.assert.recursion annotation.
   * if ths annoation is set to false for a property of an entity it checks if the value of the property is equal
   * to ID of the target and throws an error in that case.
   */
  handleRecursionConstraint = (req) => {
    // Filter all target.elements that have annoation @Nexontis.assert.recursive set and that are a foreignKey 
    const arrElementsWithAnnotation = Object.entries(req.target.elements).filter(entry => { return entry[1]['@Nexontis.assert.recursion'] === false && entry[1]['@odata.foreignKey4'] });
    for(let elementWithAnnotation of arrElementsWithAnnotation) {
      const requestDataEntry = Object.entries(req.query.UPDATE.data).filter(dataEntry => {return dataEntry[0] === elementWithAnnotation[0]})
      if(requestDataEntry) {
        // there can only be 1 requestDataEntry element 
        if(requestDataEntry[0][1] === req.query.UPDATE.data.ID) {
          req.error('recursion not allowed')
        }
      }
    }
  }

  /**
   * This function handles the @Nexontis.assert.checkAssocValues annotation
   * It checks if the value selected for a foreign key is one of the values this annotation allows.
   * The syntax of this annotation looks as follows:
   * ```js
   *    @(Nexontis.checkAssocValues : {
   *      association   : 'type',
   *      field         : 'code',
   *      allowedValues : [
   *          'MT',
   *          'AL'
   *      ]
   *    });
   * ```
   * where association is the association that has to be checked for the foreign key
   * field is the name of the field in the lookup entity and
   * allowedValues is an array of allowed values for the field in the lookup table
   */
  handleCheckAssocValueConstraint = async (req, srv) => {
    const arrElementsWithAnnotation = Object.entries(req.target.elements).filter(entry => { return entry[1]['@Nexontis.assert.checkAssocValues.association']  && entry[1].type === 'cds.Association'});
    for(let elementWithAnnotations of arrElementsWithAnnotation) {
      const elementWithAnnotation = elementWithAnnotations[1];
      const assocName = elementWithAnnotation['@Nexontis.assert.checkAssocValues.association']
      const assocField = elementWithAnnotation['@Nexontis.assert.checkAssocValues.field']
      const allowedValues = elementWithAnnotation['@Nexontis.assert.checkAssocValues.allowedValues']

      // read value from associated entity.
      // TODO: complex foreing key with more than one property need to be implemented.
      const fkEntitySet = elementWithAnnotation.target.match(/(.*)\.(.*)/)[2]; 
      const fkID = elementWithAnnotation.keys[0].ref[0];// cut of the preceeding model name
      const fkFieldName = elementWithAnnotation.keys[0].$generatedFieldName;
      const fkFieldValue = req.data[fkFieldName];
      const query = SELECT.one.from(fkEntitySet).columns(`${assocName}_${assocField}`).where(`${fkID} = ${fkFieldValue}`);

      const functions = await srv.run(query);

      const fkTargetFieldValue = functions[`${assocName}_${assocField}`];
      if(undefined === allowedValues.find(allowedValue => allowedValue === fkTargetFieldValue)) {
        req.error(`value ${fkTargetFieldValue} is not allowed. Use one of ${allowedValues.toString()}`);
      }
    }
  }

  this.before(['CREATE', 'UPDATE'], '*', async (req) => {
    handleRecursionConstraint(req)
    handleCheckAssocValueConstraint(req, this)
  });

  /**
   * When activating this functionality the following appears. The validation is done correctly while patching the
   * entity at the end of selecting a senderFunction e.g. 
   * If the user entered/selected one or more not allowed values for this association and then saves (UPDATE or CREATE) the the entity with
   * an allowed value all formerly wrong associations are replayed which leads to a lot of error messages and rejection of the fixed entity.
   */
  /*
  this.before('PATCH', '*', async (req) => {
    // handleRecursionConstraint(req, this)
    // handleCheckAssocValueConstraint(req, this)
  });
  */
};  


