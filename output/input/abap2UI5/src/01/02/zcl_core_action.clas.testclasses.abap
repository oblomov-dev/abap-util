CLASS ltcl_test DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    METHODS
      first_test FOR TESTING RAISING cx_static_check.
ENDCLASS.

CLASS zcl_core_action DEFINITION LOCAL FRIENDS ltcl_test.

CLASS ltcl_test IMPLEMENTATION.

  METHOD first_test.

    DATA(lo_http) = NEW zcl_core_http_post( `` ).
    DATA(lo_action) = NEW zcl_core_action( lo_http ) ##NEEDED.

  ENDMETHOD.

ENDCLASS.
