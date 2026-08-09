CLASS ltcl_unit_test DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    METHODS test_raise           FOR TESTING RAISING cx_static_check.
    METHODS test_raise_empty     FOR TESTING RAISING cx_static_check.
    METHODS test_raise_with_prev FOR TESTING RAISING cx_static_check.
    METHODS test_raise_with_cx   FOR TESTING RAISING cx_static_check.
    METHODS test_uuid_populated  FOR TESTING RAISING cx_static_check.
    METHODS test_chain_texts     FOR TESTING RAISING cx_static_check.
ENDCLASS.


CLASS ltcl_unit_test IMPLEMENTATION.
  METHOD test_raise.

    TRY.

        RAISE EXCEPTION TYPE zabaputil_cx_error
          EXPORTING val = `this is an error text`.

      CATCH zabaputil_cx_error INTO DATA(lx).
        cl_abap_unit_assert=>assert_equals( exp = `this is an error text`
                                            act = lx->get_text( ) ).
    ENDTRY.

  ENDMETHOD.

  METHOD test_raise_empty.

    TRY.
        RAISE EXCEPTION TYPE zabaputil_cx_error.
      CATCH zabaputil_cx_error INTO DATA(lx).
        cl_abap_unit_assert=>assert_bound( lx ).
        cl_abap_unit_assert=>assert_not_initial( lx->ms_error-uuid ).
    ENDTRY.

  ENDMETHOD.

  METHOD test_raise_with_prev.

    DATA(lx_prev) = NEW zabaputil_cx_error( val = `previous error` ).

    TRY.
        RAISE EXCEPTION TYPE zabaputil_cx_error
          EXPORTING val      = `current error`
                    previous = lx_prev.
      CATCH zabaputil_cx_error INTO DATA(lx).
        DATA(lv_text) = lx->get_text( ).
        cl_abap_unit_assert=>assert_true(
          xsdbool( lv_text CS `current error` ) ).
        cl_abap_unit_assert=>assert_true(
          xsdbool( lv_text CS `previous error` ) ).
    ENDTRY.

  ENDMETHOD.

  METHOD test_raise_with_cx.

    TRY.
        DATA(lv_val) = 1 / 0 ##NEEDED.
      CATCH cx_root INTO DATA(lx_root).
    ENDTRY.

    TRY.
        RAISE EXCEPTION TYPE zabaputil_cx_error
          EXPORTING val = lx_root.
      CATCH zabaputil_cx_error INTO DATA(lx).
        cl_abap_unit_assert=>assert_not_initial( lx->get_text( ) ).
        cl_abap_unit_assert=>assert_bound( lx->ms_error-x_root ).
    ENDTRY.

  ENDMETHOD.

  METHOD test_uuid_populated.

    TRY.
        RAISE EXCEPTION TYPE zabaputil_cx_error
          EXPORTING val = `test`.
      CATCH zabaputil_cx_error INTO DATA(lx).
        cl_abap_unit_assert=>assert_not_initial( lx->ms_error-uuid ).
        cl_abap_unit_assert=>assert_equals( exp = 32
                                            act = strlen( lx->ms_error-uuid ) ).
    ENDTRY.

  ENDMETHOD.

  METHOD test_chain_texts.

    DATA(lx_inner) = NEW zabaputil_cx_error( val = `inner` ).
    DATA(lx_middle) = NEW zabaputil_cx_error( val   = `middle`
                                                previous = lx_inner ).
    DATA(lx_outer) = NEW zabaputil_cx_error( val   = `outer`
                                               previous = lx_middle ).

    DATA(lv_text) = lx_outer->get_text( ).
    cl_abap_unit_assert=>assert_true( xsdbool( lv_text CS `outer` ) ).
    cl_abap_unit_assert=>assert_true( xsdbool( lv_text CS `middle` ) ).
    cl_abap_unit_assert=>assert_true( xsdbool( lv_text CS `inner` ) ).

  ENDMETHOD.
ENDCLASS.

"! ================================================================
"! Exception-chain rendering, synced back from the consumers
"! ================================================================
CLASS ltcl_chain DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.

    METHODS val_becomes_previous     FOR TESTING.
    METHODS cause_rendered_once      FOR TESTING.
    METHODS own_text_without_chain   FOR TESTING.
    METHODS own_text_by_x_foreign    FOR TESTING.
    METHODS own_text_by_x_unbound    FOR TESTING.
    METHODS bounded_chain_terminates FOR TESTING.
    METHODS empty_is_unknown_error   FOR TESTING.
    METHODS full_unbound             FOR TESTING.
    METHODS full_sections            FOR TESTING.
    METHODS full_lists_every_link    FOR TESTING.

ENDCLASS.

CLASS ltcl_chain IMPLEMENTATION.

  METHOD val_becomes_previous.
    " the dominant raise pattern hands the cause over as `val` without a
    " `previous` - it must still become the cause, or everything below it is
    " dropped and only the outermost message survives
    DATA(lx_cause) = NEW zabaputil_cx_error( val = `the_cause` ).
    DATA(lx) = NEW zabaputil_cx_error( val = lx_cause ).
    cl_abap_unit_assert=>assert_true( xsdbool( lx->previous = lx_cause ) ).
    cl_abap_unit_assert=>assert_true( xsdbool( lx->get_text( ) CS `the_cause` ) ).
  ENDMETHOD.

  METHOD cause_rendered_once.
    " x_root and previous are the same object here - rendering both would
    " print the cause twice
    DATA(lx_cause) = NEW zabaputil_cx_error( val = `the_cause` ).
    DATA(lv_text) = NEW zabaputil_cx_error( val = lx_cause )->get_text( ).
    cl_abap_unit_assert=>assert_equals( act = lv_text
                                        exp = `the_cause` ).
  ENDMETHOD.

  METHOD own_text_without_chain.
    DATA(lx_inner) = NEW zabaputil_cx_error( val = `inner` ).
    DATA(lx_outer) = NEW zabaputil_cx_error( val      = `outer`
                                             previous = lx_inner ).
    cl_abap_unit_assert=>assert_equals( act = lx_outer->get_text_own( )
                                        exp = `outer` ).
    cl_abap_unit_assert=>assert_true( xsdbool( lx_outer->get_text( ) CS `inner` ) ).
  ENDMETHOD.

  METHOD own_text_by_x_foreign.
    " every other exception class has only its own text - get_text( ) there
    " never walks the chain
    DATA(lx) = NEW cx_sy_zerodivide( ).
    cl_abap_unit_assert=>assert_equals( act = zabaputil_cx_error=>get_text_own_by_x( lx )
                                        exp = lx->get_text( ) ).
  ENDMETHOD.

  METHOD own_text_by_x_unbound.
    DATA lx TYPE REF TO cx_root.
    cl_abap_unit_assert=>assert_initial( zabaputil_cx_error=>get_text_own_by_x( lx ) ).
  ENDMETHOD.

  METHOD bounded_chain_terminates.
    " chain walks are bounded (cv_chain_max) so a cyclic `previous` cannot
    " hang the error renderer - the one place that has to stay responsive.
    " A cycle cannot be built through the constructor, so this covers that a
    " normal chain terminates and both renderers answer.
    DATA(lx_a) = NEW zabaputil_cx_error( val = `a` ).
    DATA(lx_b) = NEW zabaputil_cx_error( val      = `b`
                                         previous = lx_a ).
    cl_abap_unit_assert=>assert_not_initial( lx_b->get_text( ) ).
    cl_abap_unit_assert=>assert_not_initial( zabaputil_cx_error=>get_text_full( lx_b ) ).
  ENDMETHOD.

  METHOD empty_is_unknown_error.
    " a raise without val/previous must never answer with a blank text
    cl_abap_unit_assert=>assert_equals( act = NEW zabaputil_cx_error( )->get_text( )
                                        exp = `UNKNOWN_ERROR` ).
  ENDMETHOD.

  METHOD full_unbound.
    DATA lx TYPE REF TO cx_root.
    cl_abap_unit_assert=>assert_equals( act = zabaputil_cx_error=>get_text_full( lx )
                                        exp = `UNKNOWN_ERROR` ).
  ENDMETHOD.

  METHOD full_sections.
    " consumers split the dump on these headers (abap2UI5's ErrorView.js
    " shows the error section and hides the rest behind Details) - the
    " spelling is part of the contract
    DATA(lv_full) = zabaputil_cx_error=>get_text_full( NEW zabaputil_cx_error( val = `the_error` ) ).
    cl_abap_unit_assert=>assert_true( xsdbool( lv_full CS `--- error ---` ) ).
    cl_abap_unit_assert=>assert_true( xsdbool( lv_full CS `--- exception chain ---` ) ).
    cl_abap_unit_assert=>assert_true( xsdbool( lv_full CS `--- context ---` ) ).
    cl_abap_unit_assert=>assert_true( xsdbool( lv_full CS `the_error` ) ).
    " the message section comes first, everything else is detail
    cl_abap_unit_assert=>assert_true( xsdbool( find( val = lv_full sub = `--- error ---` ) <
                                               find( val = lv_full sub = `--- exception chain ---` ) ) ).
  ENDMETHOD.

  METHOD full_lists_every_link.
    DATA(lx_inner) = NEW zabaputil_cx_error( val = `inner` ).
    DATA(lx_outer) = NEW zabaputil_cx_error( val      = `outer`
                                             previous = lx_inner ).
    DATA(lv_full) = zabaputil_cx_error=>get_text_full( lx_outer ).
    " one numbered block per link, each with the exception class and the id
    cl_abap_unit_assert=>assert_true( xsdbool( lv_full CS `[1]` ) ).
    cl_abap_unit_assert=>assert_true( xsdbool( lv_full CS `[2]` ) ).
    cl_abap_unit_assert=>assert_true( xsdbool( lv_full CS lx_inner->ms_error-uuid ) ).
    cl_abap_unit_assert=>assert_true( xsdbool( lv_full CS lx_outer->ms_error-uuid ) ).
  ENDMETHOD.

ENDCLASS.
