sap.ui.define(
  ["sap/ui/core/mvc/ControllerExtension"],
  function (ControllerExtension) {
    "use strict";

    return ControllerExtension.extend(
      "environments.ext.controller.ListReportExtension",
      {
        // this section allows to extend lifecycle hooks or override public methods of the base controller
        override: {
          routing: {
            onBeforeNavigation: function (oContextInfo) {
              var oLineContextData = oContextInfo.sourceBindingContext,
                oNav = this.base.getExtensionAPI().intentBasedNavigation,
                oRouting = this.base.getExtensionAPI().routing;
              // for salesOrder 2919431 navigate to CustomMaterialDetailsPage
              if (oLineContextData.type.code === "NODE") {
                oNav.navigateOutbound("environments-outbound", {
                  parent_ID: oLineContextData.ID,
                });
              } else if (oLineContextData.type.code === "ENV_VER") {
                oNav.navigateOutbound("functions-outbound", {
                  environment_ID: oLineContextData.ID,
                });
              } else {
                // return false to trigger the default internal navigation
                return false;
              }
              // return true is necessary to prevent further default navigation
              return true;
            },
          },
        },
      }
    );
  }
);
