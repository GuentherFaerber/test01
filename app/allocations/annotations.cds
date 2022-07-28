using ModelingService as service from '../../srv/modeling/modelingService';
using from '../../db/allocations';
using from '../../db/functions';
using from '../../db/commonTypes';
using from '../../db/fields';
using from '../../db/commonEntities';

annotate service.Allocations with @(
    UI.Facets                         : [
        {
            $Type  : 'UI.ReferenceFacet',
            Label  : 'General Information',
            ID     : 'GeneralInformation',
            Target : '@UI.FieldGroup#GeneralInformation',
        },
        {
            $Type  : 'UI.CollectionFacet',
            Label  : 'Sender',
            ID     : 'Sender',
            Facets : [
                {
                    $Type : 'UI.ReferenceFacet',
                    Label : 'Input',
                    ID : 'Input',
                    Target : '@UI.FieldGroup#Input2',
                },
                {
                    $Type : 'UI.ReferenceFacet',
                    Label : 'View',
                    ID : 'View',
                    Target : 'inputFields/@UI.LineItem#View',
                },],
        },
        {
            $Type  : 'UI.CollectionFacet',
            Label  : 'Receiver',
            ID     : 'Receiver',
            Facets : [
                {
                    $Type  : 'UI.ReferenceFacet',
                    Label  : 'Input',
                    ID     : 'Input1',
                    Target : '@UI.FieldGroup#Input1',
                },
                {
                    $Type  : 'UI.ReferenceFacet',
                    Label  : 'View',
                    ID     : 'View1',
                    Target : 'receiverViews/@UI.LineItem#View',
                },
            ],
        },
        {
            $Type  : 'UI.CollectionFacet',
            Label  : 'Signature',
            ID     : 'Signature',
            Facets : [
                {
                    $Type  : 'UI.ReferenceFacet',
                    Label  : 'Sender Selection Fields',
                    ID     : 'SenderSelectionFields',
                    Target : 'selectionFields/@UI.LineItem#SenderSelectionFields',
                },
                {
                    $Type  : 'UI.ReferenceFacet',
                    Label  : 'Sender Action Fields',
                    ID     : 'SenderActionFields',
                    Target : 'actionFields/@UI.LineItem#SenderActionFields',
                },
                {
                    $Type  : 'UI.ReferenceFacet',
                    Label  : 'Receiver Selection Fields',
                    ID     : 'ReceiverSelectionFields',
                    Target : 'receiverSelectionFields/@UI.LineItem#ReceiverSelectionFields',
                },
                {
                    $Type  : 'UI.ReferenceFacet',
                    Label  : 'Receiver Action Fields',
                    ID     : 'ReceiverActionFields',
                    Target : 'receiverActionFields/@UI.LineItem#ReceiverActionFields',
                },
            ],
        },
        {
            $Type  : 'UI.ReferenceFacet',
            Label  : 'Rules',
            ID     : 'Rules',
            Target : 'rules/@UI.LineItem#Rules1',
        },
        {
            $Type  : 'UI.ReferenceFacet',
            Label  : 'Checks',
            ID     : 'Checks',
            Target : 'checks/@UI.LineItem#Checks',
        },
        {
            $Type  : 'UI.CollectionFacet',
            Label  : 'Advanced',
            ID     : 'AdvancedCollection',
            Facets : [
                {
                    $Type  : 'UI.ReferenceFacet',
                    Label  : 'Term',
                    ID     : 'AdvancedTerm',
                    Target : '@UI.FieldGroup#AdvancedTerm',
                },
                {
                    $Type  : 'UI.ReferenceFacet',
                    Label  : 'Cycle',
                    ID     : 'AdvancedCycle',
                    Target : '@UI.FieldGroup#AdvancedCycle',
                },

            ],
        },
    ],
    UI.FieldGroup #GeneralInformation : {
        $Type : 'UI.FieldGroupType',
        Data  : [
            {
                $Type : 'UI.DataField',
                Value : type_code,
            },
            {
                $Type : 'UI.DataField',
                Value : valueAdjustment_code,
            },
            {
                $Type : 'UI.DataField',
                Value : includeInputData,
            },
            {
                $Type : 'UI.DataField',
                Value : resultHandling_code,
            },
            {
                $Type : 'UI.DataField',
                Value : includeInitialResult,
            },
            {
                $Type : 'UI.DataField',
                Value : environment_ID,
            },{
                $Type : 'UI.DataField',
                Value : function_ID,
            },],
    }
);

annotate service.Allocations with @(UI.LineItem : [
    {
        $Type  : 'UI.DataFieldForAction',
        Action : 'ModelingService.activate',
    },
    {
        $Type : 'UI.DataField',
        Value : function.function,
    },
    {
        $Type : 'UI.DataField',
        Value : function.description,
    },
    {
        $Type : 'UI.DataField',
        Value : type_code,
    },
    {
        $Type : 'UI.DataField',
        Value : environment_ID,
    },
]);

annotate service.Functions with {
    function @Common.Text : description
};

annotate service.Functions with {
    ID @Common.Text : description
};

annotate service.Allocations with {
    valueAdjustment @(
        Common.ValueList                : {
            $Type          : 'Common.ValueListType',
            CollectionPath : 'AllocationValueAdjustments',
            Parameters     : [{
                $Type             : 'Common.ValueListParameterInOut',
                LocalDataProperty : valueAdjustment_code,
                ValueListProperty : 'code',
            }, ],
        },
        Common.ValueListWithFixedValues : true
    )
};

annotate service.AllocationValueAdjustments with {
    code @Common.Text : name
};

annotate service.Allocations with {
    senderFunction @(
        Common.ValueList                : {
            $Type          : 'Common.ValueListType',
            CollectionPath : 'Functions',
            SelectionVariantQualifier: 'variant1',
            SearchSupported: false,
            Parameters     : [
                {
                    $Type             : 'Common.ValueListParameterIn',
                    LocalDataProperty : environment_ID,
                    ValueListProperty : 'environment_ID',
                },
                {
                    $Type             : 'Common.ValueListParameterInOut',
                    LocalDataProperty : senderFunction_ID,
                    ValueListProperty : 'ID',
                },
                {
                    $Type             : 'Common.ValueListParameterDisplayOnly',
                    ValueListProperty : 'function',
                },
                {
                    $Type             : 'Common.ValueListParameterDisplayOnly',
                    ValueListProperty : 'description',
                },
            ],
        },
        Common.ValueListWithFixedValues : false
    )
};
annotate service.Allocations with {
    type @Common.Text : type.name
};

annotate service.Allocations with {
    type @(
        Common.ValueList                : {
            $Type          : 'Common.ValueListType',
            CollectionPath : 'AllocationTypes',
            Parameters     : [{
                $Type             : 'Common.ValueListParameterInOut',
                LocalDataProperty : type_code,
                ValueListProperty : 'code',
            }, ],
        },
        Common.ValueListWithFixedValues : true
    )
};

annotate service.AllocationTypes with {
    code @Common.Text : name
};

annotate service.Allocations with {
    valueAdjustment @Common.Text : valueAdjustment.name
};

annotate service.Allocations with {
    resultHandling @Common.Text : resultHandling.name
};

annotate service.Allocations with {
    resultHandling @(
        Common.ValueList                : {
            $Type          : 'Common.ValueListType',
            CollectionPath : 'ResultHandlings',
            Parameters     : [{
                $Type             : 'Common.ValueListParameterInOut',
                LocalDataProperty : resultHandling_code,
                ValueListProperty : 'code',
            }, ],
        },
        Common.ValueListWithFixedValues : true
    )
};

annotate service.ResultHandlings with {
    code @Common.Text : name
};

annotate service.Allocations with {
    termField @Common.Text : termField.description
};

annotate service.AllocationTermFields with {
    ID @Common.Text : description
};

annotate service.Allocations with {
    termProcessing @Common.Text : termProcessing.name
};

annotate service.Allocations with {
    termProcessing @(
        Common.ValueList                : {
            $Type          : 'Common.ValueListType',
            CollectionPath : 'AllocationTermProcessings',
            Parameters     : [{
                $Type             : 'Common.ValueListParameterInOut',
                LocalDataProperty : termProcessing_code,
                ValueListProperty : 'code',
            }, ],
        },
        Common.ValueListWithFixedValues : true
    )
};

annotate service.AllocationTermProcessings with {
    code @Common.Text : name
};

annotate service.Allocations with {
    environment @Common.Text : environment.description
};

annotate service.Allocations with {
    function @Common.Text : function.description
};

annotate service.Allocations with @(UI.FieldGroup #AdvancedTerm : {
    $Type : 'UI.FieldGroupType',
    Data  : [
        {
            $Type : 'UI.DataField',
            Value : termIterationField_ID,
        },
        {
            $Type : 'UI.DataField',
            Value : termYearField_ID,
        },
        {
            $Type : 'UI.DataField',
            Value : termField_ID,
        },
        {
            $Type : 'UI.DataField',
            Value : termProcessing_code,
        },
        {
            $Type : 'UI.DataField',
            Value : termYear,
        },
        {
            $Type : 'UI.DataField',
            Value : termMinimum,
        },
        {
            $Type : 'UI.DataField',
            Value : termMaximum,
        },
        {
            $Type : 'UI.DataField',
            Value : termFlag,
        },
    ],

});

annotate service.Allocations with @(UI.FieldGroup #AdvancedCycle : {
    $Type : 'UI.FieldGroupType',
    Data  : [

        {
            $Type : 'UI.DataField',
            Value : cycleFlag,
        },
        {
            $Type : 'UI.DataField',
            Value : cycleIterationField_ID,
        },
        {
            $Type : 'UI.DataField',
            Value : cycleMaximum,
        },
        {
            $Type : 'UI.DataField',
            Value : cycleAggregation_code,
        },
    ],

});


annotate service.Allocations with @(UI.FieldGroup #Input1 : {
    $Type : 'UI.FieldGroupType',
    Data  : [{
        $Type : 'UI.DataField',
        Value : receiverFunction_ID,
    }, ],
});

annotate service.Allocations with {
    receiverFunction @(
        Common.ValueList                : {
            $Type          : 'Common.ValueListType',
            CollectionPath : 'Functions',
            Parameters     : [
                {
                    $Type             : 'Common.ValueListParameterIn',
                    LocalDataProperty : environment_ID,
                    ValueListProperty : 'environment_ID',
                },
                {
                    $Type             : 'Common.ValueListParameterInOut',
                    LocalDataProperty : receiverFunction_ID,
                    ValueListProperty : 'ID',
                },
                {
                    $Type             : 'Common.ValueListParameterDisplayOnly',
                    ValueListProperty : 'function',
                },
                {
                    $Type             : 'Common.ValueListParameterDisplayOnly',
                    ValueListProperty : 'description',
                },
                {
                    $Type: 'Common.ValueListParameterConstant',
                    Constant: 'Allocations.receiverFunction',
                    ValueListProperty : 'validateDummyField',
                },
            ],
        },
        Common.ValueListWithFixedValues : false
    )
};

annotate service.AllocationSelectionFields with @(UI.LineItem #SenderSelectionFields : [{
    $Type : 'UI.DataField',
    Value : field_ID,
}, ]);

annotate service.AllocationSelectionFields with {
    field @Common.Text : field.description
};

annotate service.AllocationSelectionFields with {
    field @(
        Common.ValueList                : {
            $Type          : 'Common.ValueListType',
            CollectionPath : 'Fields',
            Parameters     : [
                {
                    $Type             : 'Common.ValueListParameterInOut',
                    LocalDataProperty : field_ID,
                    ValueListProperty : 'ID',
                },
                {
                    $Type             : 'Common.ValueListParameterDisplayOnly',
                    ValueListProperty : 'field',
                },
                {
                    $Type             : 'Common.ValueListParameterDisplayOnly',
                    ValueListProperty : 'description',
                },
            ],
        },
        Common.ValueListWithFixedValues : false
    )
};

annotate service.AllocationActionFields with @(UI.LineItem #SenderActionFields : [{
    $Type : 'UI.DataField',
    Value : field_ID,
}, ]);

annotate service.AllocationActionFields with {
    field @Common.Text : field.description
};

annotate service.AllocationActionFields with {
    field @(
        Common.ValueList                : {
            $Type          : 'Common.ValueListType',
            CollectionPath : 'Fields',
            Parameters     : [
                {
                    $Type             : 'Common.ValueListParameterInOut',
                    LocalDataProperty : field_ID,
                    ValueListProperty : 'ID',
                },
                {
                    $Type             : 'Common.ValueListParameterDisplayOnly',
                    ValueListProperty : 'field',
                },
                {
                    $Type             : 'Common.ValueListParameterDisplayOnly',
                    ValueListProperty : 'description',
                },
            ],
        },
        Common.ValueListWithFixedValues : false
    )
};

annotate service.AllocationReceiverSelectionFields with @(UI.LineItem #ReceiverSelectionFields : [{
    $Type : 'UI.DataField',
    Value : field_ID,
}, ]);

annotate service.AllocationReceiverSelectionFields with {
    field @(
        Common.ValueList                : {
            $Type          : 'Common.ValueListType',
            CollectionPath : 'Fields',
            Parameters     : [
                {
                    $Type             : 'Common.ValueListParameterInOut',
                    LocalDataProperty : field_ID,
                    ValueListProperty : 'ID',
                },
                {
                    $Type             : 'Common.ValueListParameterDisplayOnly',
                    ValueListProperty : 'field',
                },
                {
                    $Type             : 'Common.ValueListParameterDisplayOnly',
                    ValueListProperty : 'description',
                },
            ],
        },
        Common.ValueListWithFixedValues : false
    )
};

annotate service.Allocations with @(UI.FieldGroup #ReceiverActionFields : {
    $Type : 'UI.FieldGroupType',
    Data  : [],
});

annotate service.AllocationReceiverActionFields with @(UI.LineItem #ReceiverActionFields : [{
    $Type : 'UI.DataField',
    Value : field_ID,
}, ]);

annotate service.AllocationReceiverActionFields with {
    field @(
        Common.ValueList                : {
            $Type          : 'Common.ValueListType',
            CollectionPath : 'Fields',
            Parameters     : [
                {
                    $Type             : 'Common.ValueListParameterInOut',
                    LocalDataProperty : field_ID,
                    ValueListProperty : 'ID',
                },
                {
                    $Type             : 'Common.ValueListParameterDisplayOnly',
                    ValueListProperty : 'field',
                },
                {
                    $Type             : 'Common.ValueListParameterDisplayOnly',
                    ValueListProperty : 'description',
                },
            ],
        },
        Common.ValueListWithFixedValues : false
    )
};

annotate service.AllocationRules with @(UI.LineItem #Rules : []);

annotate service.AllocationChecks with @(UI.LineItem #Checks : [{
    $Type : 'UI.DataField',
    Value : check_ID,
}, ]);

annotate service.AllocationChecks with {
    check @Common.Text : check.description
};

annotate service.AllocationChecks with {
    check @(
        Common.ValueList                : {
            $Type          : 'Common.ValueListType',
            CollectionPath : 'Checks',
            Parameters     : [
                {
                    $Type             : 'Common.ValueListParameterInOut',
                    LocalDataProperty : check_ID,
                    ValueListProperty : 'ID',
                },
                {
                    $Type             : 'Common.ValueListParameterDisplayOnly',
                    ValueListProperty : 'check',
                },
                {
                    $Type             : 'Common.ValueListParameterDisplayOnly',
                    ValueListProperty : 'description',
                },
            ],
        },
        Common.ValueListWithFixedValues : false
    )
};

annotate service.AllocationRules with @(UI.LineItem #Rules1 : [
    {
        $Type : 'UI.DataField',
        Value : rule,
    },
    {
        $Type : 'UI.DataField',
        Value : description,
    },
    {
        $Type : 'UI.DataField',
        Value : isActive,
    },
    {
        $Type : 'UI.DataField',
        Value : type_code,
        Label : 'type_code',
    },
    {
        $Type : 'UI.DataField',
        Value : distributionBase,
    },
]);

annotate service.AllocationSenderViews with @(UI.LineItem #View : [
    {
        $Type : 'UI.DataField',
        Value : field_ID,
    },
    {
        $Type : 'UI.DataField',
        Value : formula,
    },
    {
        $Type : 'UI.DataField',
        Value : order_code,
    },
]);

annotate service.AllocationSenderViews with {
    field @Common.Text : field.description
};

annotate service.AllocationSenderViews with {
    order @Common.Text : order.name
};

annotate service.AllocationReceiverViews with @(UI.LineItem #View : [
    {
        $Type : 'UI.DataField',
        Value : field_ID,
    },
    {
        $Type : 'UI.DataField',
        Value : formula,
    },
    {
        $Type : 'UI.DataField',
        Value : order_code,
    },
]);

annotate service.AllocationReceiverViews with {
    field @Common.Text : field.description
};

annotate service.AllocationReceiverViews with {
    order @Common.Text : order.name
};

annotate service.AllocationInputFunctions with {
    ID @Common.Text : description
};

annotate service.AllocationSenderViews with {
    field @(
        Common.ValueList                : {
            $Type          : 'Common.ValueListType',
            CollectionPath : 'Fields',
            Parameters     : [
                {
                    $Type             : 'Common.ValueListParameterIn',
                    LocalDataProperty : environment.ID,
                    ValueListProperty : 'environment_ID',
                },
                {
                    $Type             : 'Common.ValueListParameterInOut',
                    LocalDataProperty : field_ID,
                    ValueListProperty : 'ID',
                },
                {
                    $Type             : 'Common.ValueListParameterDisplayOnly',
                    ValueListProperty : 'field',
                },
                {
                    $Type             : 'Common.ValueListParameterDisplayOnly',
                    ValueListProperty : 'description',
                },
            ],
        },
        Common.ValueListWithFixedValues : false
    )
};

annotate service.Fields with {
    ID @Common.Text : description
};

annotate service.Allocations with {
    receiverFunction @Common.Text : receiverFunction.description
};

annotate service.Allocations with {
    senderFunction @Common.Text : senderFunction.description
};

annotate service.AllocationReceiverViews with {
    field @(
        Common.ValueList                : {
            $Type          : 'Common.ValueListType',
            CollectionPath : 'Fields',
            Parameters     : [
                {
                    $Type             : 'Common.ValueListParameterIn',
                    LocalDataProperty : environment.ID,
                    ValueListProperty : 'environment_ID',
                },
                {
                    $Type             : 'Common.ValueListParameterInOut',
                    LocalDataProperty : field_ID,
                    ValueListProperty : 'ID',
                },
                {
                    $Type             : 'Common.ValueListParameterDisplayOnly',
                    ValueListProperty : 'field',
                },
                {
                    $Type             : 'Common.ValueListParameterDisplayOnly',
                    ValueListProperty : 'description',
                },
            ],
        },
        Common.ValueListWithFixedValues : false
    )
};

annotate service.AllocationReceiverSelectionFields with {
    field @Common.Text : field.description
};

annotate service.AllocationReceiverActionFields with {
    field @Common.Text : field.description
};

annotate service.AllocationRules with {
    rule @Common.Text : description
};

annotate service.AllocationRules with {
    type @Common.Text : type.name
};

annotate service.AllocationRules with @(UI.Facets : [
    {
        $Type  : 'UI.CollectionFacet',
        Label  : 'Sender Rule',
        ID     : 'SenderRule',
        Facets : [
            {
                $Type  : 'UI.ReferenceFacet',
                Label  : 'Settings',
                ID     : 'Settings',
                Target : '@UI.FieldGroup#Settings',
            },
            {
                $Type  : 'UI.ReferenceFacet',
                Label  : 'Value Fields',
                ID     : 'ValueFields',
                Target : 'senderValueFields/@UI.LineItem#ValueFields',
            },
            {
                $Type  : 'UI.ReferenceFacet',
                Label  : 'View',
                ID     : 'View',
                Target : 'senderViews/@UI.LineItem#View',
            },
        ],
    },
    {
        $Type  : 'UI.CollectionFacet',
        Label  : 'Receiver Rule',
        ID     : 'ReceiverRule',
        Facets : [{
            $Type  : 'UI.ReferenceFacet',
            Label  : 'Settings',
            ID     : 'Settings1',
            Target : '@UI.FieldGroup#Settings1',
        }, ],
    },
]);

annotate service.AllocationRules with @(UI.FieldGroup #Settings : {
    $Type : 'UI.FieldGroupType',
    Data  : [
        {
            $Type : 'UI.DataField',
            Value : senderRule_code,
        },
        {
            $Type : 'UI.DataField',
            Value : senderShare,
        },
        {
            $Type : 'UI.DataField',
            Value : method_code,
        },
    ],
});

annotate service.AllocationRules with {
    senderRule @(
        Common.ValueList                : {
            $Type          : 'Common.ValueListType',
            CollectionPath : 'AllocationSenderRules',
            Parameters     : [{
                $Type             : 'Common.ValueListParameterInOut',
                LocalDataProperty : senderRule_code,
                ValueListProperty : 'code',
            }, ],
        },
        Common.ValueListWithFixedValues : true
    )
};

annotate service.AllocationSenderRules with {
    code @Common.Text : name
};

annotate service.AllocationRules with {
    method @(
        Common.ValueList                : {
            $Type          : 'Common.ValueListType',
            CollectionPath : 'AllocationRuleMethods',
            Parameters     : [{
                $Type             : 'Common.ValueListParameterInOut',
                LocalDataProperty : method_code,
                ValueListProperty : 'code',
            }, ],
        },
        Common.ValueListWithFixedValues : true
    )
};

annotate service.AllocationRuleMethods with {
    code @Common.Text : name
};

annotate service.AllocationRuleSenderValueFields with @(UI.LineItem #ValueFields : [{
    $Type : 'UI.DataField',
    Value : field_ID,
    Label : 'field_ID',
}, ]);

annotate service.AllocationRuleSenderViews with @(UI.LineItem #View : []);

annotate service.AllocationRules with @(UI.FieldGroup #Settings1 : {
    $Type : 'UI.FieldGroupType',
    Data  : [
        {
            $Type : 'UI.DataField',
            Value : receiverRule_code,
        },
        {
            $Type : 'UI.DataField',
            Value : scale_code,
        },
        {
            $Type : 'UI.DataField',
            Value : driverResultField_ID,
        },
        {
            $Type : 'UI.DataField',
            Value : distributionBase,
        },
    ],
});

annotate service.AllocationRules with {
    receiverRule @(
        Common.ValueList                : {
            $Type          : 'Common.ValueListType',
            CollectionPath : 'AllocationReceiverRules',
            Parameters     : [{
                $Type             : 'Common.ValueListParameterInOut',
                LocalDataProperty : receiverRule_code,
                ValueListProperty : 'code',
            }, ],
        },
        Common.ValueListWithFixedValues : true
    )
};

annotate service.AllocationReceiverRules with {
    code @Common.Text : name
};

annotate service.AllocationRules with {
    scale @(
        Common.ValueList                : {
            $Type          : 'Common.ValueListType',
            CollectionPath : 'AllocationRuleScales',
            Parameters     : [{
                $Type             : 'Common.ValueListParameterInOut',
                LocalDataProperty : scale_code,
                ValueListProperty : 'code',
            }, ],
        },
        Common.ValueListWithFixedValues : true
    )
};

annotate service.AllocationRuleScales with {
    code @Common.Text : name
};

annotate service.Allocations with {
    termIterationField @Common.Text : termIterationField.description
};

annotate service.Allocations with {
    termIterationField @(
        Common.ValueList                : {
            $Type          : 'Common.ValueListType',
            CollectionPath : 'AllocationTermIterationFields',
            Parameters     : [
                {
                    $Type             : 'Common.ValueListParameterInOut',
                    LocalDataProperty : termIterationField_ID,
                    ValueListProperty : 'ID',
                },
                {
                    $Type             : 'Common.ValueListParameterDisplayOnly',
                    ValueListProperty : 'field',
                },
                {
                    $Type             : 'Common.ValueListParameterDisplayOnly',
                    ValueListProperty : 'description',
                },
            ],
        },
        Common.ValueListWithFixedValues : false
    )
};

annotate service.Allocations with {
    termYearField @Common.Text : termYearField.description
};

annotate service.Allocations with {
    termYearField @(
        Common.ValueList                : {
            $Type          : 'Common.ValueListType',
            CollectionPath : 'AllocationTermYearFields',
            Parameters     : [
                {
                    $Type             : 'Common.ValueListParameterInOut',
                    LocalDataProperty : termYearField_ID,
                    ValueListProperty : 'ID',
                },
                {
                    $Type             : 'Common.ValueListParameterDisplayOnly',
                    ValueListProperty : 'field',
                },
                {
                    $Type             : 'Common.ValueListParameterDisplayOnly',
                    ValueListProperty : 'description',
                },
            ],
        },
        Common.ValueListWithFixedValues : false
    )
};

annotate service.Allocations with {
    termField @(
        Common.ValueList                : {
            $Type          : 'Common.ValueListType',
            CollectionPath : 'AllocationTermFields',
            Parameters     : [
                {
                    $Type             : 'Common.ValueListParameterInOut',
                    LocalDataProperty : termField_ID,
                    ValueListProperty : 'ID',
                },
                {
                    $Type             : 'Common.ValueListParameterDisplayOnly',
                    ValueListProperty : 'field',
                },
                {
                    $Type             : 'Common.ValueListParameterDisplayOnly',
                    ValueListProperty : 'description',
                },
            ],
        },
        Common.ValueListWithFixedValues : false
    )
};

annotate service.Allocations with {
    cycleIterationField @Common.Text : cycleIterationField.description
};

annotate service.Allocations with {
    cycleIterationField @(
        Common.ValueList                : {
            $Type          : 'Common.ValueListType',
            CollectionPath : 'AllocationCycleIterationFields',
            Parameters     : [
                {
                    $Type             : 'Common.ValueListParameterInOut',
                    LocalDataProperty : cycleIterationField_ID,
                    ValueListProperty : 'ID',
                },
                {
                    $Type             : 'Common.ValueListParameterDisplayOnly',
                    ValueListProperty : 'field',
                },
                {
                    $Type             : 'Common.ValueListParameterDisplayOnly',
                    ValueListProperty : 'description',
                },
            ],
        },
        Common.ValueListWithFixedValues : false
    )
};
annotate service.Allocations with @(
    UI.SelectionFields : [
        environment_ID,
        function_ID,
    ]
);
annotate service.AllocationInputFunctions with {
    function @Common.Text : {
        $value : description,
        ![@UI.TextArrangement] : #TextOnly,
    }
};

annotate service.Allocations with @(
    UI.FieldGroup #Input2 : {
        $Type : 'UI.FieldGroupType',
        Data : [
            {
                $Type : 'UI.DataField',
                Value : inputFunction_ID,
            }],
    }
);
annotate service.InputFields with @(
    UI.LineItem #View : [
        {
            $Type : 'UI.DataField',
            Value : field_ID,
        },{
            $Type : 'UI.DataField',
            Value : formula,
        },{
            $Type : 'UI.DataField',
            Value : order_code,
        },]
);
annotate service.InputFields with {
    field @Common.Text : {
            $value : field.description,
            ![@UI.TextArrangement] : #TextOnly,
        }
};
annotate service.Allocations with {
    inputFunction @Common.Text : inputFunction.description
};
annotate service.Allocations with {
    inputFunction @(Common.ValueList : {
            $Type : 'Common.ValueListType',
            CollectionPath : 'Functions',
            Parameters : [
                // {
                //     $Type : 'Common.ValueListParameterIn',
                //     LocalDataProperty : environment_ID,
                //     ValueListProperty : 'environment_ID',
                // },
                {
                    $Type : 'Common.ValueListParameterInOut',
                    LocalDataProperty : inputFunction_ID,
                    ValueListProperty : 'ID',
                },
                {
                    $Type : 'Common.ValueListParameterDisplayOnly',
                    ValueListProperty : 'function',
                },
                {
                    $Type : 'Common.ValueListParameterDisplayOnly',
                    ValueListProperty : 'description',
                },
                // {
                //     $Type : 'Common.ValueListParameterIn',
                //     LocalDataProperty : validateDummy,
                //     ValueListProperty : 'validateDummy',
                // },
                {
                    $Type: 'Common.ValueListParameterConstant',
                    Constant: 'Allocations.inputFunction',
                    ValueListProperty : 'validateDummyField',
                },
            ],
        },
        Common.ValueListWithFixedValues : false
)};
