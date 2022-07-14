const cds = require("@sap/cds");
const activationService = require("./activationService");
const functionService = require("./functionService");

module.exports = function () {
    this.on("activate", async (req) => {
        await activationService.activate(req);
    });
    this.on("CREATE", "Functions", async (req, next) => {
        await functionService.onCreate(req);
        return next();
    });

    //   this.on("PATCH", "AllocationSenderViews", async (data) => { 
    //     console.log("patch!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
    //     console.log(data.data);
    //   });

    this.on("setSelections", async (req) => {
        console.log(req.data.selectionID);

        await cds.run(
            INSERT
                .into('AllocationSenderViewSelections')
                .entries(
                    {
                        seq: 0,
                        sign_code: 'I',
                        low: req.data.lowValue,
                        opt_code: req.data.operation,
                        high: 'placeholder',
                        environment_ID: '3',
                        function_ID: '4',
                        field_ID: req.data.selectionID,
                        ID: req.data.ID
                    }
                )
        );

        return req.data;
    });

    this.on("getSelections", async (req) => {
        const selectionID = req.data.selectionID;
        const getSelectionsByID = await cds.run(SELECT`*`.from('AllocationSenderViewSelections').where(`field_ID='${selectionID}'`));

        console.log(selectionID);
        console.log(getSelectionsByID);

        return getSelectionsByID;
    });

    //   this.on("POST", "Allocations", async (data) => { 
    //     console.log("al!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
    //     console.log(data.data);
    //   });

    //   this.before("*", async (req) => {
    // if (cds) {
    //   if (req.target.elements.environment_ID) console.log(req.target.elements.environment_ID);
    // 
    //   });

    // this.before("NEW", "*", async (req) => {
    //     if (cds) {
    //         // if (req.target.elements.environment_ID) req.data.environment_ID = "1";
    //         // if (req.target.elements.function_ID) req.data.function_ID = "4";
    //         // if (req.target.elements.sequence) req.data.sequence = 10;
    //     }
    // });
    // this.before("READ", "*", async (req) => {
    //   if (req.target.elements.environment_ID) {
    //     const cql = cds.parse.expr(`1 = 1 AND (environment_ID = '1')`);
    //     if (req.query.SELECT.where) {
    //       req.query.SELECT.where.push(cql.xpr[3]);
    //       req.query.SELECT.where.push(cql.xpr[4]);
    //     } else {
    //       req.query.SELECT.where = [cql.xpr[4]];
    //     }
    //     console.log(req.query.SELECT.where);
    //   }
    // });
    this.after("READ", "Functions", (each) => {
        if (each.IsActiveEntity) {
            switch (each.type_code) {
                case "AL":
                    each.url = `#Allocations-manage&/Allocations(ID='${each.ID}',IsActiveEntity=true)`;
                    break;
                case "MT":
                    each.url = `#Modeltable-manage&/ModelTables(ID='${each.ID}',IsActiveEntity=true)`;
                    break;
                case "CU":
                    each.url = `#Calculationunits-manage&/CalculationUnits(ID='${each.ID}',IsActiveEntity=true)`;
                    break;
            }
        } else each.url = undefined;
    });
};
