## ABAP Toolkit
Utility Functions for S/4 Public Cloud, BTP ABAP Environment & ABAP OnPremise

#### Features:
* Simplified SAP APIs to class-based methods

#### Usage:

character operations
```abap

"strings
z2ui5_cl_util=>c_trim_upper( ` JsadfHHs  ` ). "->JSADFHHS
z2ui5_cl_util=>c_trim_lower( ` JsadfHHs  ` ). "->jsadfhhs

"json w ajson
z2ui5_cl_util=>json_stringify( data ). "{"selected":false,"title":"test","value":""}

"...
```

