/* eslint-disable no-undef */
sap.ui.define(
    [
        "sap/m/MessageToast",
        "sap/m/Dialog",
        "sap/m/Button",
        "allocations/ext/fragment/Tree",
        "sap/m/TableSelectDialog",
    ],
    function (MessageToast, Dialog, Button, Tree, TableSelectDialog) {
        "use strict";

        return {
            onPress1: function () {
                // example with tableSelectDialog
                var dialog = new TableSelectDialog("TableSelectDialog1", {
                    title: "Select values",
                    noDataText: "No data available",
                    columns: [
                        new sap.m.Column({
                            header: new sap.m.Text({
                                text: "Column1"
                            })
                        }),
                        new sap.m.Column({
                            header: new sap.m.Text({
                                text: "Column2"
                            })
                        })
                    ],
                    items: [
                        new sap.m.ColumnListItem({
                            cells: [
                                new sap.m.FlexBox({
                                    justifyContent: "SpaceBetween",
                                    alignItems: "Center",
                                    items: [
                                        new sap.m.Label({
                                            text: "foo"
                                        }),
                                        new sap.m.Select({
                                            items: [
                                                new sap.ui.core.Item({
                                                    text: "bar"
                                                })
                                            ]
                                        }),
                                    ]
                                })
                            ]
                        }),
                        new sap.m.ColumnListItem({
                            cells: [
                                new sap.m.FlexBox({
                                    justifyContent: "SpaceBetween",
                                    alignItems: "Center",
                                    items: [
                                        new sap.m.Label({
                                            text: "longerfoo"
                                        }),
                                        new sap.m.Select({
                                            items: [
                                                new sap.ui.core.Item({
                                                    text: "barfits"
                                                })
                                            ]
                                        }),
                                    ]
                                })
                            ]
                        })
                    ],
                    cancel: function () {
                        dialog.destroy();
                    },
                    confirm: function () {
                        dialog.destroy();
                    },
                });
                dialog.open();
            },
            onPress2: function (oEvent) {
                // example with react component
                const valueContainerId = "tree-value";
                const oContext = oEvent.getSource().getBindingContext();
                const selectionID = oEvent.getSource().getBindingContext().getObject().ID;
                console.log(selectionID);
                console.log(oContext);

                const currentValue = oContext.getObject().formula;

                var dialog = new Dialog({
                    contentWidth: "1000px",
                    contentHeight: "600px",
                    title: "Select values",
                    type: "Message",
                    content: new sap.ui.core.HTML({
                        content: `<div id="root"></div><input value="" type="hidden" id="${valueContainerId}" />`,
                    }),
                    afterOpen: function () {
                        const tree = new Tree();
                        const treeContainer = document.getElementById("root");
                        const valueContainer = document.getElementById(valueContainerId);
                        tree.render(treeContainer, valueContainer, currentValue);
                    },
                    beginButton: new Button({
                        text: "Submit",
                        press: function () {
                            const valueContainer = document.getElementById(valueContainerId);
                            const value = valueContainer.getAttribute("value");
                            const parsedJSON = JSON.parse(value);

                            let formulaValue = "";
                            let highValue = "placeholder";
                            let operation;
                            let lowValue;

                            for (let i = 0; i < parsedJSON.length; i++) {
                                if (parsedJSON[i].OP === 'Greater' || parsedJSON[i].OP === 'Less') {
                                    lowValue = parsedJSON[i].LOW;
                                    operation = parsedJSON[i].OP;
                                    formulaValue += parsedJSON[i].OP + " then " + parsedJSON[i].LOW + " ";
                                } else {
                                    lowValue = parsedJSON[i].LOW;
                                    operation = parsedJSON[i].OP;
                                    formulaValue += parsedJSON[i].OP + " " + parsedJSON[i].LOW + " ";
                                }

                                switch (operation) {
                                    case "Equals":
                                        operation = "EQ";
                                        break;
                                    case "Greater":
                                        operation = "GT";
                                        break;
                                    case "Less":
                                        operation = "LE";
                                        break;
                                    case "Contains":
                                        operation = "CP";
                                        break;
                                }

                                (async () => {
                                    const rawResponse = await fetch('/service/modeling/setSelections', {
                                        method: 'POST',
                                        headers: {
                                            'Accept': 'application/json',
                                            'Content-Type': 'application/json'
                                        },
                                        body: JSON.stringify({ selectionID: selectionID, operation: operation, lowValue: lowValue })
                                    });
                                    let content = await rawResponse.json();

                                    console.log(content);
                                })();
                            }

                            oContext.setProperty('formula', formulaValue);

                            dialog.close();
                        },
                    }),
                    endButton: new Button({
                        text: "Cancel",
                        press: function () {
                            dialog.close();
                        },
                    }),
                    afterClose: function () {
                        dialog.destroy();
                    },
                });

                dialog.open();
            },
            onViewSelections: function (oEvent) {
                const oContext = oEvent.getSource().getBindingContext();
                const selectionID = oEvent.getSource().getBindingContext().getObject().ID;
                const currentValue = oContext.getObject().formula;

                (async () => {
                    const rawResponse = await fetch('/service/modeling/getSelections', {
                        method: 'POST',
                        headers: {
                            'Accept': 'application/json',
                            'Content-Type': 'application/json'
                        },
                        body: JSON.stringify({ selectionID: selectionID })
                    });
                    let content = await rawResponse.json();

                    console.log(content.value);


                    var dialog = new TableSelectDialog({
                        title: "Selected Values",
                        noDataText: "No data available",
                        columns: [
                            new sap.m.Column({
                                header: new sap.m.Text({
                                    text: "Formula"
                                })
                            }),
                            new sap.m.Column({
                                header: new sap.m.Text({
                                    text: "Low Value"
                                })
                            }),
                            new sap.m.Column({
                                header: new sap.m.Text({
                                    text: "High Value"
                                })
                            })
                        ],
                        items: [
                            new sap.m.ColumnListItem({
                                cells: [
                                    new sap.m.FlexBox({
                                        justifyContent: "SpaceBetween",
                                        alignItems: "Center",
                                        items: [
                                            new sap.m.Label({
                                                text: content.value.opt_code
                                            })
                                        ]
                                    }),
                                    new sap.m.FlexBox({
                                        justifyContent: "SpaceBetween",
                                        alignItems: "Center",
                                        items: [
                                            new sap.m.Label({
                                                text: content.value.low
                                            })
                                        ]
                                    }),
                                    new sap.m.FlexBox({
                                        justifyContent: "SpaceBetween",
                                        alignItems: "Center",
                                        items: [
                                            new sap.m.Label({
                                                text: content.value.high
                                            })
                                        ]
                                    }),
                                ],
                                cells: [
                                    new sap.m.FlexBox({
                                        justifyContent: "SpaceBetween",
                                        alignItems: "Center",
                                        items: [
                                            new sap.m.Label({
                                                text: content.value.opt_code
                                            })
                                        ]
                                    }),
                                    new sap.m.FlexBox({
                                        justifyContent: "SpaceBetween",
                                        alignItems: "Center",
                                        items: [
                                            new sap.m.Label({
                                                text: content.value.low
                                            })
                                        ]
                                    }),
                                    new sap.m.FlexBox({
                                        justifyContent: "SpaceBetween",
                                        alignItems: "Center",
                                        items: [
                                            new sap.m.Label({
                                                text: content.value.high
                                            })
                                        ]
                                    }),
                                ],
                            })
                        ],
                        endButton: new Button({
                            text: "Cancel",
                            press: function () {
                                dialog.close();
                            },
                        }),
                        afterClose: function () {
                            dialog.destroy();
                        },
                    });
                    dialog.open();
                })();
            }
        };
    }
);
