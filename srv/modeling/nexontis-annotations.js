const { SELECT, UPDATE } = cds.ql;

module.exports = function () {
  /* Store for all validate annotations */
  this.validateDummyStore = [];

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
   * This function handles the @NX.validate annotation
   * It pulls the CXN from this annotation of all elements that have it defined, parses it, runs a SELECT query with it and
   * checks if the foreign key of the property this annotation is defined for is in
   * the result set of the query. If not an error is thrown cause then the entered value
   * is not allowed by the assertion.
   * The CXN can contain $self. patterns, e.g. environment_ID = $self.environment_ID. This evaluates
   * the properties value, in this case environment_ID, at runtime from the current object.
   */
  this.handleNXValidation = async function (req) {
    try {
      const arrElementsWithAnnotation = Object.entries(
        req.target.elements
      ).filter((entry) => {
        return (
          !!entry[1]["@NX.validate"] && entry[1].type === "cds.Association"
        );
      });
      for (let elementWithAnnotations of arrElementsWithAnnotation) {
        const elementWithAnnotation = elementWithAnnotations[1];
        let validationExpression;
        // if string was escaped with ![...] there is an element with key =
        if (elementWithAnnotation["@NX.validate"]["="]) {
          validationExpression = elementWithAnnotation["@NX.validate"]["="];
        } else {
          validationExpression = elementWithAnnotation["@NX.validate"];
        }
        const validationExpressionObj = this.replace$self(
          validationExpression,
          req.data,
          []
        );
        const parsedCXN = cds.parse.expr(validationExpressionObj.str);
        const fkEntitySet = elementWithAnnotation.target.match(/(.*)\.(.*)/)[2];
        const fkFieldName = elementWithAnnotation.keys[0].$generatedFieldName;
        const fkKeyFieldName = Object.keys(
          elementWithAnnotation.foreignKeys
        )[0];
        const query = SELECT.from(fkEntitySet);
        query.SELECT.where = parsedCXN.xpr;
        // req.query.SELECT.where = req.query.SELECT.where.flat(1);

        const results = await this.run(query);
        if (
          undefined ===
          results.find(
            (resultItem) => resultItem[fkKeyFieldName] === req.data[fkFieldName]
          )
        ) {
          req.error(`value ${req.data[fkFieldName]} is not allowed.`);
        }
      }
    } catch (err) {
      req.error(err.message);
    }
  };

  /**
   * replaces $self.<propertyname> with the value of the property in the given
   * entity
   * @returns {Object} an object with the cxn string (property: str) in which the variables are replaced by
   * the current values of the entity are set and an array (property: varArray) with an object for each
   * parameter of the cxn string. The varArray objects have the properties variableName and variableValue
   */
  this.replace$self = function (str, entity, varArray) {
    const idx = str.indexOf("$self.");
    if (idx > -1) {
      const prefix = str.substr(0, idx);
      const tail = str.substr(idx + 6);
      const match = tail.match(/([^\s]+)/);
      if (!match || match.length < 2) {
        throw new VHExpressionParseError(
          `parsing expression ${str} failed. Did you use $self correctly?`
        );
      }

      const variableName = match[1];
      const value = _getValueOfVariable(variableName, entity);
      varArray.push({ variableName: variableName, variableValue: value });
      // if (!Object.prototype.hasOwnProperty.call(entity, variableName)) {
      //   throw new VHExpressionParseError(
      //     `variable name $self.${variableName} cannot be resolved in entity.`
      //   );
      // }
      // const value = entity[variableName];
      const newTail = tail.replace(variableName, value);
      const newStr = prefix + newTail;
      // eslint-disable-next-line no-undef
      return this.replace$self(newStr, entity, varArray);
    } else {
      return { str: str, varArray: varArray };
    }
  };

  /**
   * Retrieves the value of a variable from an entity. The varname can contain dots which means that
   * it's a variable of a complex variable/object.
   * This function works down to the lowest child variable/object.
   * @todo Implemenation is a bit too complex but I wanted an error in case something goes wrong wrong.
   * @param {string} varName name of variable, can contain "." separators
   * @param {object} entity entity to inspect
   */
  function _getValueOfVariable(varName, entity) {
    const varNameParts = varName.split(".");
    let value = varNameParts.reduce(
      (prevVal, curVal) => {
        const localVarPart = prevVal.varPart
          ? prevVal.varPart + "_" + curVal
          : curVal;
        if (!Object.prototype.hasOwnProperty.call(prevVal.obj, curVal)) {
          return { obj: prevVal.obj, varPart: localVarPart, value: null };
        } else {
          return {
            obj: prevVal.obj[curVal],
            varPart: null,
            value: prevVal.obj[localVarPart],
          };
        }
      },
      { obj: entity, varPart: null, value: null }
    );

    if (value.value) {
      return value.value;
    }
    throw new VHExpressionParseError(`variable ${varName} not available`);
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
   *
   * Note: You cannot use the $self pattern that is available with the @NX.validate annotation
   */
  this.handleNXValueListParameterConstantFilter = function (arrWhereClause) {
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
  };

  /**
   * deletes the artefacts from the where clause that were added by the @NX.validate annotation.
   * @param {string} arrWhere
   * @returns
   */
  this.deleteNXValidateFromWhere = function (arrWhere, fieldName) {
    let start = -1,
      deleteCount = -1;
    for (let i = 0; i < arrWhere.length; i++) {
      if (
        typeof arrWhere[i] === "object" &&
        arrWhere[i].hasOwnProperty("ref") &&
        arrWhere[i].ref[0] === fieldName
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
    // delete trailing and/or
    if (
      arrWhere[arrWhere.length - 1] &&
      ["and", "or"].indexOf(arrWhere[arrWhere.length - 1]) > -1
    ) {
      arrWhere = arrWhere.splice(arrWhere.length - 1, 1);
    }

    return arrWhere;
  };

  /**
   * Adds or updates a parameter definition in the array validateDummyStore.
   * @param {*} targetName target or entity name
   * @param {*} elementName element or field name
   * @param {*} cxnString cxn string with replaced $self parameters
   * @param {*} cxnStringOrigin original cxn string like defined in CDS file
   * @param {*} varArray array with variables/parameters used in the cxn string
   * @param {*} forceUpdate if true it will force an update of the entry.
   * Otherwise it will reject the given values if there is already a variable with targetName and elementName available
   * @returns
   */
  this.addValidateDummy = function (
    targetName,
    elementName,
    cxnString,
    cxnStringOrigin,
    varArray,
    forceUpdate
  ) {
    // don't need the servicename, only the entityname
    targetName = targetName.split(".")[1];
    // make sure there is only one target/element combination entry
    if (
      !this.validateDummyStore.find(
        (entry) => entry.target === targetName && entry.element === elementName
      )
    ) {
      this.validateDummyStore.push({
        // don't need the servicename, only the entityname
        target: targetName,
        element: elementName,
        cxn: cxnString,
        cxnOrigin: cxnStringOrigin,
        varArray: varArray,
      });
    } else if (forceUpdate) {
      this.validateDummyStore = this.validateDummyStore.map((entry) => {
        if (entry.target === targetName && entry.element === elementName) {
          entry.cxn = cxnString;
          entry.cxnOrigin = cxnStringOrigin;
          entry.varArray = varArray;
        }
        return entry;
      });
    }
    const dummyStoreArr = this.validateDummyStore.map((entry) => {
      return { t: entry.target, e: entry.element };
    });
    return `@NX.validate:` + JSON.stringify(dummyStoreArr);
  };

  this.intersect = function (a, b) {
    let t;
    if (b.length > a.length) (t = b), (b = a), (a = t); // indexOf to loop over shorter
    return a.filter(function (e) {
      return b.indexOf(e) > -1;
    });
  };

  /**
   * Replaces the values of variables stored in the validateDummyStore.
   * If a value of a parameter that is used in one of the dummies stored in this
   * array changes the cxn string of those dummies must be adjusted. Otherwise
   * validation and value help do not work correctly.
   *
   * @example
   * // You have a validate annotation that references the local environment_ID via
   * // $self.environment_ID
   * NX.validate : ![(type.code = 'AL') and environment_ID = $self.environment_ID])
   * // When the user starts editing the object the current value of the property environment_ID
   * // is merged into the cxn which leads e.g. to
   * (type.code = 'AL') and environment_ID = 4
   * // This cxn is used during validation and display of the value help of the annotated
   * // property
   * // If the user now changes the value of environment_ID via the UI to e.g. 7 this
   * // function updates the cxn to
   * (type.code = 'AL') and environment_ID = 7
   *
   * This function is called from the Before.PATCH event handler
   * @param {*} req
   */
  this.replaceVariablesInValidateDummyStore = function (req) {
    const targetName = req.target.name.split(".")[1];
    const arrEntityValidations = this.validateDummyStore.filter(
      (entry) => entry.target === targetName
    );
    if (arrEntityValidations.length > 0) {
      const arrSelfFields = arrEntityValidations
        .reduce((acc, curVal) => {
          const arrSelf = [
            ...curVal.cxnOrigin.matchAll(/.*?\$self\.([^\s]+)/g),
          ];
          acc = acc.concat(arrSelf.map((entry) => entry[1]));
          // remove duplicates and return the new array
          return [...new Set(acc)];
        }, [])
        .map((entry) => entry.replace(".", "_"));
      // find intersection between fields from request and the $self fields in cxn expressions
      const arrIntersect = this.intersect(Object.keys(req.data), arrSelfFields);
      if (arrIntersect.length > 0) {
        // replace the intersected properties with the values from the request
        for (const oEntityValidation of arrEntityValidations) {
          for (const oIntersect of arrIntersect) {
            // find oIntersect in oEntityValidation.cxnOrigin
            try {
              const oVar = oEntityValidation.varArray.find(
                (entry) => entry.variableName === oIntersect
              );
              oVar.variableValue = req.data[oIntersect];
            } catch (e) {
              // try the same as before but replace _ by .
              const oIntersectNew = oIntersect.replace("_", ".");
              const oVar = oEntityValidation.varArray.find(
                (entry) => entry.variableName === oIntersectNew
              );
              if (oVar) {
                oVar.variableValue = req.data[oIntersect];
              }
            }
          }
          // build the new cxn
          let cxn = oEntityValidation.cxnOrigin;
          for (const oVar of oEntityValidation.varArray) {
            cxn = cxn.replace(`$self.${oVar.variableName}`, oVar.variableValue);
          }
          oEntityValidation.cxn = cxn;
        }
      }
    }
  };

  /**
   * In every after READ handler all elements of the target are searched for @NX.validate annotation.
   * If an element has it this annotation is set at the virtual validateDummy element of the data record in use.
   * It is evaluated in the READ handler of the valuehelp collection.
   */
  this.after("READ", "*", async (each, req) => {
    // Filter all target.elements that have annoation @NX.validate
    const arrElementsWithAnnotation = Object.entries(
      req.target.elements
    ).filter((entry) => {
      return !!entry[1]["@NX.validate"] && entry[1].type === "cds.Association";
    });
    for (let elementWithAnnotation of arrElementsWithAnnotation) {
      let valuehelpExpression;
      // if string was escaped with ![...] there is an element with key =
      if (elementWithAnnotation[1]["@NX.validate"]["="]) {
        valuehelpExpression = elementWithAnnotation[1]["@NX.validate"]["="];
      } else {
        valuehelpExpression = elementWithAnnotation[1]["@NX.validate"];
      }
      try {
        const valuehelpExpressionReplaced = this.replace$self(
          valuehelpExpression,
          each,
          []
        );
        this.addValidateDummy(
          req.target.name,
          elementWithAnnotation[0],
          valuehelpExpressionReplaced.str,
          valuehelpExpression,
          valuehelpExpressionReplaced.varArray,
          false
        );
      } catch (err) {
        console.log(err.message);
        console.log(err.stack);
      }
    }
  });

  /**
   * This before READ handler checks if a @NX.validate where condition is available.
   * If so the content (CXN) of this where condition is parsed and added to the where
   * clause of the SELECT query.
   * The content of ths @NX.validate where condition is defined via an annotation of the
   * parent entity in a FK scenario.
   */
  this.before("READ", "*", (req) => {
    try {
      if (req.query.SELECT && req.query.SELECT.where) {
        const vhWhere = req.query.SELECT.where.reduce(
          (acc, curVal, idx, arrWhere) => {
            if (
              curVal.ref &&
              Array.isArray(curVal.ref) &&
              curVal.ref[0].startsWith("validateDummy")
            ) {
              // the value of filter is located +2 array elements from this one
              acc.push({
                element: curVal.ref[0],
                value: arrWhere[idx + 2].val,
              });
            }
            return acc;
          },
          []
        );
        if (vhWhere.length > 0) {
          req.query.SELECT.where = this.deleteNXValidateFromWhere(
            req.query.SELECT.where,
            "validateDummyField"
          );
          const filterEntity = vhWhere
            .find((elem) => elem.element === "validateDummyField")
            .value.split(".")[0];
          const filterField = vhWhere
            .find((elem) => elem.element === "validateDummyField")
            .value.split(".")[1];
          const filterExpression = cds.parse.expr(
            this.validateDummyStore.find(
              (elem) =>
                elem.target === filterEntity && elem.element === filterField
            ).cxn
          );
          if (req.query.SELECT.where.length > 0) {
            req.query.SELECT.where.push("and");
          }
          req.query.SELECT.where.push(filterExpression.xpr);
          req.query.SELECT.where = req.query.SELECT.where.flat(1);
        }
        // It's also possible to define a valuehelp filter as Common.ValueListParameterConstant in the ValueList annotation
        // In that case this is available in the where clause of the select statement.
        req.query.SELECT.where = this.handleNXValueListParameterConstantFilter(
          req.query.SELECT.where
        );
        console.log(req.query.SELECT.where);
      }
    } catch (err) {
      // just log errors, don't throw them. In some cases they are caused by how CAP sends events. In that cases
      // they are no real errors.
      console.log(err.message);
      console.log(err.stack);
    }
  });

  this.before(["CREATE", "UPDATE"], "*", async (req) => {
    await this.handleNXValidation(req, this);
  });

  this.before("PATCH", "*", async (req) => {
    this.replaceVariablesInValidateDummyStore(req);
  });
};
