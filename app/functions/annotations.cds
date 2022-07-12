using ModelingService as service from '../../srv/modeling/modelingService';
using from '../../db/functions';


annotate service.Functions with @(UI.LineItem : [
    /*
    {
        $Type : 'UI.DataField',
        Value : function,
    },
        */

    {
        $Type : 'UI.DataFieldWithUrl',
        Value : function,
        Url   : url,
    },
    {
        $Type : 'UI.DataField',
        Value : sequence,
    },
    {
        $Type : 'UI.DataField',
        Label : 'type_code',
        Value : type_code,
    },
    {
        $Type  : 'UI.DataFieldForAction',
        Action : 'ModelingService.activate',
        Label  : 'Activate',
    },
]);

annotate service.Functions with @(
    UI.FieldGroup #GeneratedGroup1 : {
        $Type : 'UI.FieldGroupType',
        Data  : [
            {
                $Type : 'UI.DataField',
                Value : function,
            },
            {
                $Type : 'UI.DataField',
                Value : sequence,
            },
            {
                $Type : 'UI.DataField',
                Label : 'type_code',
                Value : type_code,
            },
            {
                $Type : 'UI.DataField',
                Value : description,
            },
            {
                $Type : 'UI.DataField',
                Value : environment_ID,
            },
        ],
    },
    UI.Facets                      : [{
        $Type  : 'UI.ReferenceFacet',
        ID     : 'GeneratedFacet1',
        Label  : 'General Information',
        Target : '@UI.FieldGroup#GeneratedGroup1',
    }, ]
);

annotate service.Functions with @(UI.SelectionFields : [
    environment_ID,
    parent_ID,
]);

annotate service.Functions with {
    environment @Common.Text : environment.description
};

annotate service.Functions with {
    environment @(
        Common.ValueList                : {
            $Type          : 'Common.ValueListType',
            CollectionPath : 'Environments',
            Parameters     : [
                {
                    $Type             : 'Common.ValueListParameterInOut',
                    LocalDataProperty : environment_ID,
                    ValueListProperty : 'ID',
                },
                {
                    $Type             : 'Common.ValueListParameterDisplayOnly',
                    ValueListProperty : 'environment',
                },
                {
                    $Type             : 'Common.ValueListParameterDisplayOnly',
                    ValueListProperty : 'version',
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

annotate service.Functions with {
    parent @Common.Text : parent.description
};

annotate service.Functions with {
    parent @(
        Common.ValueList                : {
            $Type          : 'Common.ValueListType',
            CollectionPath : 'FunctionParentFunctionsVH',
            Parameters     : [
                {
                    $Type             : 'Common.ValueListParameterInOut',
                    LocalDataProperty : parent_ID,
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
        Common.ValueListWithFixedValues : true
    )
};
annotate service.Functions with {
    documentation @UI.MultiLineText : true
};
