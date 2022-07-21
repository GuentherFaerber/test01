const { SELECT, UPDATE } = cds.ql;

module.exports = function () {
  /**
   * Our own error type for expression parsing errors
   * @param {*} message
   */
  function VHExpressionParseError(message = "") {
    this.name = "VHExpressionParseError";
    this.message = message;
  }
  VHExpressionParseError.prototype = Error.prototype;

  /**
   * This function handles the @NX.assert.recursion annotation.
   * if ths annoation is set to false for a property of an entity it checks if the value of the property is equal
   * to ID of the target and throws an error in that case.
   * @deprecated use annotation \@NX.assert.validate
   */
  function handleRecursionConstraint(req) {
    // Filter all target.elements that have annotation @NX.assert.recursive set and that are a foreignKey
    const arrElementsWithAnnotation = Object.entries(
      req.target.elements
    ).filter((entry) => {
      return (
        entry[1]["@NX.assert.recursion"] === false &&
        entry[1]["@odata.foreignKey4"]
      );
    });
    for (let elementWithAnnotation of arrElementsWithAnnotation) {
      const requestDataEntry = Object.entries(req.query.UPDATE.data).filter(
        (dataEntry) => {
          return dataEntry[0] === elementWithAnnotation[0];
        }
      );
      if (requestDataEntry) {
        // there can only be 1 requestDataEntry element
        if (requestDataEntry[0][1] === req.query.UPDATE.data.ID) {
          req.error("recursion not allowed");
        }
      }
    }
  }

  /**
   * This function handles the @NX.assert.checkAssocValues annotation
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
   *
   * @deprecated use annotation \@NX.assert.validate
   */
  async function handleCheckAssocValueConstraint(req, srv) {
    const arrElementsWithAnnotation = Object.entries(
      req.target.elements
    ).filter((entry) => {
      return (
        entry[1]["@NX.assert.checkAssocValues.association"] &&
        entry[1].type === "cds.Association"
      );
    });
    for (let elementWithAnnotations of arrElementsWithAnnotation) {
      const elementWithAnnotation = elementWithAnnotations[1];
      const assocName =
        elementWithAnnotation["@NX.assert.checkAssocValues.association"];
      const assocField =
        elementWithAnnotation["@NX.assert.checkAssocValues.field"];
      const allowedValues =
        elementWithAnnotation["@NX.assert.checkAssocValues.allowedValues"];

      // read value from associated entity.
      // TODO: complex foreing key with more than one property need to be implemented.
      const fkEntitySet = elementWithAnnotation.target.match(/(.*)\.(.*)/)[2];
      const fkID = elementWithAnnotation.keys[0].ref[0]; // cut of the preceeding model name
      const fkFieldName = elementWithAnnotation.keys[0].$generatedFieldName;
      const fkFieldValue = req.data[fkFieldName];
      const query = SELECT.one
        .from(fkEntitySet)
        .columns(`${assocName}_${assocField}`)
        .where(`${fkID} = ${fkFieldValue}`);

      const functions = await srv.run(query);

      const fkTargetFieldValue = functions[`${assocName}_${assocField}`];
      if (
        undefined ===
        allowedValues.find(
          (allowedValue) => allowedValue === fkTargetFieldValue
        )
      ) {
        req.error(
          `value ${fkTargetFieldValue} is not allowed. Use one of ${allowedValues.toString()}`
        );
      }
    }
  }

  /**
   * This function handles the @NX.assert.validate annotation
   * It pulls the CXN from this annotation, parses it, runs a SELECT query with it and
   * checks if the foreign key of the property this annotation is defined for is in
   * the result set of the query. If not an error is thrown cause then the entered value
   * is not allowed by the assertion.
   * The CXN can contain $self. patterns, e.g. environment_ID = $self.environment_ID. This evaluates
   * the properties value, in this case environment_ID, at runtime from the current object.
   */
  async function handleNXValidation(req, srv) {
    const arrElementsWithAnnotation = Object.entries(
      req.target.elements
    ).filter((entry) => {
      return (
        !!entry[1]["@NX.assert.validate"] && entry[1].type === "cds.Association"
      );
    });
    for (let elementWithAnnotations of arrElementsWithAnnotation) {
      const elementWithAnnotation = elementWithAnnotations[1];
      let validationExpression;
      // if string was escaped with ![...] there is an element with key =
      if (elementWithAnnotation["@NX.assert.validate"]["="]) {
        validationExpression =
          elementWithAnnotation["@NX.assert.validate"]["="];
      } else {
        validationExpression = elementWithAnnotation["@NX.assert.validate"];
      }
      validationExpression = replace$self(validationExpression, req.data);
      const parsedCXN = cds.parse.expr(validationExpression);
      const fkEntitySet = elementWithAnnotation.target.match(/(.*)\.(.*)/)[2];
      const fkFieldName = elementWithAnnotation.keys[0].$generatedFieldName;
      const fkKeyFieldName = Object.keys(elementWithAnnotation.foreignKeys)[0];
      const query = SELECT.from(fkEntitySet);
      query.SELECT.where = parsedCXN.xpr;
      // req.query.SELECT.where = req.query.SELECT.where.flat(1);

      const results = await srv.run(query);
      console.log(parsedCXN);
      if (
        undefined ===
        results.find(
          (resultItem) => resultItem[fkKeyFieldName] === req.data[fkFieldName]
        )
      ) {
        req.error(`value ${req.data[fkFieldName]} is not allowed.`);
      }
    }
  }

  /**
   * replaces $self.<propertyname> with the value of the property in the given
   * entity
   */
  function replace$self(str, entity) {
    const idx = str.indexOf("$self.");
    if (idx > -1) {
      const prefix = str.substr(0, idx);
      const tail = str.substr(idx + 6);
      const match = tail.match(/(\w+)/);
      if (!match || match.length < 2) {
        throw new VHExpressionParseError(
          `parsing expression ${str} failed. Did you use $self correctly?`
        );
      }

      // const variableName = tail.split(" ")[0];
      const variableName = match[1];
      //if (!entity.hasOwnProperty(variableName)) {
      if (!Object.prototype.hasOwnProperty.call(entity, variableName)) {
        throw new VHExpressionParseError(
          `variable name $self.${variableName} cannot be resolved in entity.`
        );
      }
      const value = entity[variableName];
      const newTail = tail.replace(variableName, value);
      const newStr = prefix + newTail;
      // eslint-disable-next-line no-undef
      return replace$self(newStr, entity);
    } else {
      return str;
    }
  }

  /**
   *
   * @param {*} keys
   * @param {*} entity
   * @returns
   * @deprecated not used any longer
   */
  function getKeysForRequest(keys, entity) {
    const keyObj = {};
    const keyNames = Object.keys(keys);

    for (let key of keyNames) {
      if (key !== "IsActiveEntity") {
        keyObj[key] = entity[key];
      }
    }
    return keyObj;
  }

  /** It's possible to define a valuehelp filter as Common.ValueListParameterConstant in the ValueList annotation
   * via CXN with a prefix of @NX:
   * In that case this is available in the where clause of the select statement.
   * This function converts this temporary filter definition into a definition for the service/db request.
   */
  function handleNXValueListParameterConstantFilter(arrWhereClause) {
    const arrElemsToDelete = [];
    const arrElemsToAdd = [];
    for (let i = 0; i < arrWhereClause.length; i++) {
      const curArrElem = arrWhereClause[i];
      if (
        curArrElem.val &&
        typeof curArrElem.val === "string" &&
        curArrElem.val.match(/^@NX:/)
      ) {
        // mark this element and the two before (ref to property, operator) as deletable
        arrElemsToDelete.push(i - 2);
        // pull CXN expression from the val string
        const cxnString = curArrElem.val.match(/^@NX:(.*)/)[1];
        const parsedCXN = cds.parse.expr(cxnString.replace(/"/g, "'"));
        arrElemsToAdd.push(parsedCXN);
      }
    }
    // delete temporary elements from arrWhereClause
    for (let i = arrElemsToDelete.length - 1; i > -1; i--) {
      // if there is a preceeding 'and' it has to be deleted as well.
      if (
        arrWhereClause[arrElemsToDelete[i] - 1] &&
        arrWhereClause[arrElemsToDelete[i] - 1] === "and"
      ) {
        arrWhereClause.splice(arrElemsToDelete[i] - 1, 4);
      } else {
        arrWhereClause.splice(arrElemsToDelete[i], 3);
      }
    }
    if (arrWhereClause[0] === "and") {
      arrWhereClause.splice(0, 1);
    }
    // add the parsed CXN(s) to the where clause array
    for (const oElemToAdd of arrElemsToAdd) {
      arrWhereClause.push("and");
      arrWhereClause.push(oElemToAdd);
    }
    if (arrWhereClause[0] === "and") {
      arrWhereClause.splice(0, 1);
    }
    return arrWhereClause;
  }

  /**
   * deletes the artefacts from the where clause that were added by the @NX.valuehelp annotation.
   * @param {string} arrWhere
   * @returns
   */
  function deleteNXValuehelpFromWhere(arrWhere) {
    let start = -1,
      deleteCount = -1;
    for (let i = 0; i < arrWhere.length; i++) {
      if (
        typeof arrWhere[i] === "object" &&
        arrWhere[i].hasOwnProperty("ref") &&
        arrWhere[i].ref[0] === "valueHelpDummy"
      ) {
        start = i;
        deleteCount = 3;
      }
    }
    if (
      start > -1 &&
      deleteCount > -1 &&
      ["and", "or"].indexOf(arrWhere[start + 3]) > -1
    ) {
      deleteCount = deleteCount + 1;
    }
    if (start > -1 && deleteCount > -1) {
      arrWhere.splice(start, deleteCount);
    }
    return arrWhere;
  }

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

  /**
   * In every after READ handler all elements of the target are searched for @NX.valuehelp annotation.
   * If an element has it this annotation is set at the virtual valueHelpDummy element of the data record in use.
   * It is evaluated in the READ handler of the valuehelp collection.
   */
  this.after("READ", "*", async (each, req) => {
    // Filter all target.elements that have annoation @NX.valuehelp
    const arrElementsWithAnnotation = Object.entries(
      req.target.elements
    ).filter((entry) => {
      return !!entry[1]["@NX.valuehelp"] && entry[1].type === "cds.Association";
    });
    for (let elementWithAnnotation of arrElementsWithAnnotation) {
      let valuehelpExpression;
      // if string was escaped with ![...] there is an element with key =
      if (elementWithAnnotation[1]["@NX.valuehelp"]["="]) {
        valuehelpExpression = elementWithAnnotation[1]["@NX.valuehelp"]["="];
      } else {
        valuehelpExpression = elementWithAnnotation[1]["@NX.valuehelp"];
      }
      try {
        valuehelpExpression = replace$self(valuehelpExpression, each);
        // before cds 6.x.x this was necessary
        // const entityName = req.target.name.match(/(.*)\.(.*)/)[2];
        // eslint-disable-next-line no-undef
        // const keyObj = getKeysForRequest(req.target.keys, each);
        // const query = UPDATE(entityName, keyObj).with({
        //   valueHelpDummy: "@NX.valuehelp:" + valuehelpExpression,
        // });
        // const affectedRows = await this.run(query);
        // console.log(`Number of updated rows: ${affectedRows}`);
        each.valueHelpDummy = "@NX.valuehelp:" + valuehelpExpression;
      } catch (err) {
        console.log(err.message);
        console.log(err.stack);
      }
    }
  });

  /**
   * This before READ handler checks if a @NX.valuehelp where condition is available.
   * If so the content (CXN) of this where condition is parsed and added to the where
   * clause of the SELECT query.
   * The content of ths @NX.valuehelp where condition is defined via an annotation of the
   * parent entity in a FK scenario.
   */
  this.before("READ", "*", (req) => {
    try {
      if (req.query.SELECT && req.query.SELECT.where) {
        const vhWhere = req.query.SELECT.where.filter((whereCond) => {
          return (
            whereCond.val &&
            typeof whereCond.val === "string" &&
            whereCond.val.match(/^@NX\.valuehelp/)
          );
        });
        if (vhWhere.length > 0) {
          req.query.SELECT.where = deleteNXValuehelpFromWhere(
            req.query.SELECT.where
          );
          const customFilterMap = vhWhere.map((filterExpressionComplete) => {
            const filterExpression = filterExpressionComplete.val.split(":")[1];
            return cds.parse.expr(filterExpression);
          });
          if (req.query.SELECT.where.length > 0) {
            req.query.SELECT.where.push("and");
          }
          req.query.SELECT.where.push(customFilterMap[0].xpr);
          req.query.SELECT.where = req.query.SELECT.where.flat(1);
        }
        // It's also possible to define a valuehelp filter as Common.ValueListParameterConstant in the ValueList annotation
        // In that case this is available in the where clause of the select statement.
        req.query.SELECT.where = handleNXValueListParameterConstantFilter(
          req.query.SELECT.where
        );
        console.log(req.query.SELECT.where);
      }
    } catch (err) {
      console.log(err.message);
      console.log(err.stack);
    }
  });

  this.before(["CREATE", "UPDATE"], "*", async (req) => {
    // eslint-disable-next-line no-undef
    //    handleRecursionConstraint(req);
    // eslint-disable-next-line no-undef
    //    handleCheckAssocValueConstraint(req, this);
    handleNXValidation(req, this);
  });

};
