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
   */
  // eslint-disable-next-line no-undef
  handleRecursionConstraint = (req) => {
    // Filter all target.elements that have annoation @NX.assert.recursive set and that are a foreignKey
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
  };

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
   */
  // eslint-disable-next-line no-undef
  handleCheckAssocValueConstraint = async (req, srv) => {
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
  };

  /**
   * replaces $self.<propertyname> with the value of the property in the given
   * entity
   */
  // eslint-disable-next-line no-undef
  replace$self = (str, entity) => {
    const idx = str.indexOf("$self.");
    if (idx > -1) {
      const prefix = str.substr(0, idx);
      const tail = str.substr(idx + 6);
      const variableName = tail.split(" ")[0];
      if (!entity.hasOwnProperty(variableName)) {
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
  };

  this.before(["CREATE", "UPDATE"], "*", async (req) => {
    // eslint-disable-next-line no-undef
    //    handleRecursionConstraint(req);
    // eslint-disable-next-line no-undef
    //    handleCheckAssocValueConstraint(req, this);
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
        // eslint-disable-next-line no-undef
        valuehelpExpression = replace$self(valuehelpExpression, each);
        const entityName = req.target.name.match(/(.*)\.(.*)/)[2];
        const keyObj = getKeysForRequest(req.target.keys, each);

        //each.valueHelpDummy = "@NX.valuehelp:" + valuehelpExpression;
        const query = UPDATE(entityName, keyObj).with({
          valueHelpDummy: "@NX.valuehelp:" + valuehelpExpression,
        });
        const affectedRows = await this.run(query);
        console.log(`Number of updated rows: ${affectedRows}`);
      } catch (err) {
        console.log(err.message);
        console.log(err.stack);
      }
    }
  });

  getKeysForRequest = (keys, entity) => {
    const keyObj = {};
    const keyNames = Object.keys(keys);

    for (let key of keyNames) {
      if (key !== "IsActiveEntity") {
        keyObj[key] = entity[key];
      }
    }
    return keyObj;
  };

  /**
   * This before READ handler checks if a @NX.valuehelp where condition is available.
   * If so the content (CQX) of this where condition is parsed and added to the where
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
      }
    } catch (err) {
      console.log(err.message);
      console.log(err.stack);
    }
  });

  deleteNXValuehelpFromWhere = (arrWhere) => {
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
  };
};
