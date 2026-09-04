CLASS ltcl_unit_test DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    METHODS test_raise           FOR TESTING RAISING cx_static_check.
    METHODS test_raise_empty     FOR TESTING RAISING cx_static_check.
    METHODS test_raise_with_prev FOR TESTING RAISING cx_static_check.
    METHODS test_raise_with_cx   FOR TESTING RAISING cx_static_check.
    METHODS test_uuid_populated  FOR TESTING RAISING cx_static_check.
    METHODS test_uuid_stable_over_renders FOR TESTING RAISING cx_static_check.
    METHODS test_chain_texts     FOR TESTING RAISING cx_static_check.
    METHODS test_raise_struct_val   FOR TESTING RAISING cx_static_check.
    METHODS test_raise_printable_val FOR TESTING RAISING cx_static_check.
ENDCLASS.


CLASS ltcl_unit_test IMPLEMENTATION.
  METHOD test_raise.
        DATA lx TYPE REF TO zabaputil_cx_error.

    TRY.

        RAISE EXCEPTION TYPE zabaputil_cx_error
          EXPORTING val = `this is an error text`.

        
      CATCH zabaputil_cx_error INTO lx.
        cl_abap_unit_assert=>assert_equals( exp = `this is an error text`
                                            act = lx->get_text( ) ).
    ENDTRY.

  ENDMETHOD.

  METHOD test_raise_empty.
        DATA lx TYPE REF TO zabaputil_cx_error.

    TRY.
        RAISE EXCEPTION TYPE zabaputil_cx_error.
        
      CATCH zabaputil_cx_error INTO lx.
        cl_abap_unit_assert=>assert_bound( lx ).
        " the id is filled on first render - see test_uuid_populated
        cl_abap_unit_assert=>assert_not_initial( zabaputil_cx_error=>get_text_full( lx ) ).
        cl_abap_unit_assert=>assert_not_initial( lx->ms_error-uuid ).
    ENDTRY.

  ENDMETHOD.

  METHOD test_raise_with_prev.

    DATA lx_prev TYPE REF TO zabaputil_cx_error.
        DATA lx TYPE REF TO zabaputil_cx_error.
        DATA lv_text TYPE string.
        DATA temp1 TYPE xsdboolean.
        DATA temp2 TYPE xsdboolean.
    CREATE OBJECT lx_prev TYPE zabaputil_cx_error EXPORTING val = `previous error`.

    TRY.
        RAISE EXCEPTION TYPE zabaputil_cx_error
          EXPORTING val      = `current error`
                    previous = lx_prev.
        
      CATCH zabaputil_cx_error INTO lx.
        
        lv_text = lx->get_text( ).
        
        temp1 = boolc( lv_text CS `current error` ).
        cl_abap_unit_assert=>assert_true(
          temp1 ).
        
        temp2 = boolc( lv_text CS `previous error` ).
        cl_abap_unit_assert=>assert_true(
          temp2 ).
    ENDTRY.

  ENDMETHOD.

  METHOD test_raise_with_cx.
        DATA lv_val TYPE i.
        DATA lx_root TYPE REF TO cx_root.
        DATA lx TYPE REF TO zabaputil_cx_error.

    TRY.
        
        lv_val = 1 / 0 ##NEEDED.
        
      CATCH cx_root INTO lx_root.
    ENDTRY.

    TRY.
        RAISE EXCEPTION TYPE zabaputil_cx_error
          EXPORTING val = lx_root.
        
      CATCH zabaputil_cx_error INTO lx.
        cl_abap_unit_assert=>assert_not_initial( lx->get_text( ) ).
        cl_abap_unit_assert=>assert_bound( lx->ms_error-x_root ).
    ENDTRY.

  ENDMETHOD.

  METHOD test_raise_struct_val.

    " a structured val made `lv_text = val` dump, and a runtime error
    " inside a CATCH block is not caught by that block's own TRY - so the
    " exception class became the crash instead of reporting one
    " (the table shape cannot be tested here: the transpiled `?=` throws a
    " raw runtime error the CATCH does not see, where ABAP raises a
    " catchable CX_SY_MOVE_CAST_ERROR)
    TYPES: BEGIN OF ty_s,
             alpha TYPE string,
             beta  TYPE i,
           END OF ty_s.
    DATA ls_val TYPE ty_s.
        DATA lx TYPE REF TO zabaputil_cx_error.

    ls_val-alpha = `whatever`.

    TRY.
        RAISE EXCEPTION TYPE zabaputil_cx_error
          EXPORTING val = ls_val.
        
      CATCH zabaputil_cx_error INTO lx.
        cl_abap_unit_assert=>assert_bound( lx ).
        cl_abap_unit_assert=>assert_initial( lx->ms_error-text ).
        cl_abap_unit_assert=>assert_not_initial( lx->get_text( ) ).
    ENDTRY.

  ENDMETHOD.

  METHOD test_raise_printable_val.
        DATA lx TYPE REF TO zabaputil_cx_error.

    " the guard must not cost the elementary values their text - a number
    " handed over as val still renders
    TRY.
        RAISE EXCEPTION TYPE zabaputil_cx_error
          EXPORTING val = 42.
        
      CATCH zabaputil_cx_error INTO lx.
        cl_abap_unit_assert=>assert_char_cp( act = lx->ms_error-text
                                             exp = `*42*` ).
    ENDTRY.

  ENDMETHOD.

  METHOD test_uuid_populated.
        DATA lx TYPE REF TO zabaputil_cx_error.
        DATA lv_report TYPE string.

    " the id is computed on first render, not in the constructor: a raise
    " that is caught and handled on the way up never pays for the dynamic
    " CL_SYSTEM_UUID call
    TRY.
        RAISE EXCEPTION TYPE zabaputil_cx_error
          EXPORTING val = `test`.
        
      CATCH zabaputil_cx_error INTO lx.
        cl_abap_unit_assert=>assert_initial( lx->ms_error-uuid ).

        
        lv_report = zabaputil_cx_error=>get_text_full( lx ).

        cl_abap_unit_assert=>assert_not_initial( lx->ms_error-uuid ).
        cl_abap_unit_assert=>assert_equals( exp = 32
                                            act = strlen( lx->ms_error-uuid ) ).
        " and the rendered report carries the id it just computed, rather
        " than the empty `id :` line an un-filled uuid used to produce
        cl_abap_unit_assert=>assert_char_cp( act = lv_report
                                             exp = |*id       : { lx->ms_error-uuid }*| ).
    ENDTRY.

  ENDMETHOD.

  METHOD test_uuid_stable_over_renders.
        DATA lx TYPE REF TO zabaputil_cx_error.
        DATA lv_first LIKE lx->ms_error-uuid.

    " filled once - a second render must not hand out a different id for
    " the same exception, or the id stops identifying anything
    TRY.
        RAISE EXCEPTION TYPE zabaputil_cx_error
          EXPORTING val = `test`.
        
      CATCH zabaputil_cx_error INTO lx.
        zabaputil_cx_error=>get_text_full( lx ).
        
        lv_first = lx->ms_error-uuid.

        zabaputil_cx_error=>get_text_full( lx ).

        cl_abap_unit_assert=>assert_equals( act = lx->ms_error-uuid
                                            exp = lv_first ).
    ENDTRY.

  ENDMETHOD.

  METHOD test_chain_texts.

    DATA lx_inner TYPE REF TO zabaputil_cx_error.
    DATA lx_middle TYPE REF TO zabaputil_cx_error.
    DATA lx_outer TYPE REF TO zabaputil_cx_error.
    DATA lv_text TYPE string.
    DATA temp3 TYPE xsdboolean.
    DATA temp4 TYPE xsdboolean.
    DATA temp5 TYPE xsdboolean.
    CREATE OBJECT lx_inner TYPE zabaputil_cx_error EXPORTING val = `inner`.
    
    CREATE OBJECT lx_middle TYPE zabaputil_cx_error EXPORTING val = `middle` previous = lx_inner.
    
    CREATE OBJECT lx_outer TYPE zabaputil_cx_error EXPORTING val = `outer` previous = lx_middle.

    
    lv_text = lx_outer->get_text( ).
    
    temp3 = boolc( lv_text CS `outer` ).
    cl_abap_unit_assert=>assert_true( temp3 ).
    
    temp4 = boolc( lv_text CS `middle` ).
    cl_abap_unit_assert=>assert_true( temp4 ).
    
    temp5 = boolc( lv_text CS `inner` ).
    cl_abap_unit_assert=>assert_true( temp5 ).

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
    METHODS full_context_discloses   FOR TESTING.

ENDCLASS.

CLASS ltcl_chain IMPLEMENTATION.

  METHOD val_becomes_previous.
    " the dominant raise pattern hands the cause over as `val` without a
    " `previous` - it must still become the cause, or everything below it is
    " dropped and only the outermost message survives
    DATA lx_cause TYPE REF TO zabaputil_cx_error.
    DATA lx TYPE REF TO zabaputil_cx_error.
    DATA temp6 TYPE xsdboolean.
    DATA temp7 TYPE xsdboolean.
    CREATE OBJECT lx_cause TYPE zabaputil_cx_error EXPORTING val = `the_cause`.
    
    CREATE OBJECT lx TYPE zabaputil_cx_error EXPORTING val = lx_cause.
    
    temp6 = boolc( lx->previous = lx_cause ).
    cl_abap_unit_assert=>assert_true( temp6 ).
    
    temp7 = boolc( lx->get_text( ) CS `the_cause` ).
    cl_abap_unit_assert=>assert_true( temp7 ).
  ENDMETHOD.

  METHOD cause_rendered_once.
    " x_root and previous are the same object here - rendering both would
    " print the cause twice
    DATA lx_cause TYPE REF TO zabaputil_cx_error.
    DATA lv_text TYPE string.
    DATA temp1 TYPE REF TO zabaputil_cx_error.
    CREATE OBJECT lx_cause TYPE zabaputil_cx_error EXPORTING val = `the_cause`.
    
    
    CREATE OBJECT temp1 TYPE zabaputil_cx_error EXPORTING val = lx_cause.
    lv_text = temp1->get_text( ).
    cl_abap_unit_assert=>assert_equals( act = lv_text
                                        exp = `the_cause` ).
  ENDMETHOD.

  METHOD own_text_without_chain.
    DATA lx_inner TYPE REF TO zabaputil_cx_error.
    DATA lx_outer TYPE REF TO zabaputil_cx_error.
    DATA temp8 TYPE xsdboolean.
    CREATE OBJECT lx_inner TYPE zabaputil_cx_error EXPORTING val = `inner`.
    
    CREATE OBJECT lx_outer TYPE zabaputil_cx_error EXPORTING val = `outer` previous = lx_inner.
    cl_abap_unit_assert=>assert_equals( act = lx_outer->get_text_own( )
                                        exp = `outer` ).
    
    temp8 = boolc( lx_outer->get_text( ) CS `inner` ).
    cl_abap_unit_assert=>assert_true( temp8 ).
  ENDMETHOD.

  METHOD own_text_by_x_foreign.
    " every other exception class has only its own text - get_text( ) there
    " never walks the chain
    DATA lx TYPE REF TO cx_sy_zerodivide.
    CREATE OBJECT lx TYPE cx_sy_zerodivide.
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
    DATA lx_a TYPE REF TO zabaputil_cx_error.
    DATA lx_b TYPE REF TO zabaputil_cx_error.
    CREATE OBJECT lx_a TYPE zabaputil_cx_error EXPORTING val = `a`.
    
    CREATE OBJECT lx_b TYPE zabaputil_cx_error EXPORTING val = `b` previous = lx_a.
    cl_abap_unit_assert=>assert_not_initial( lx_b->get_text( ) ).
    cl_abap_unit_assert=>assert_not_initial( zabaputil_cx_error=>get_text_full( lx_b ) ).
  ENDMETHOD.

  METHOD empty_is_unknown_error.
    " a raise without val/previous must never answer with a blank text
    DATA temp1 TYPE REF TO zabaputil_cx_error.
    CREATE OBJECT temp1 TYPE zabaputil_cx_error.
    cl_abap_unit_assert=>assert_equals( act = temp1->get_text( )
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
    DATA lv_full TYPE string.
    DATA temp2 TYPE REF TO zabaputil_cx_error.
    DATA temp9 TYPE xsdboolean.
    DATA temp10 TYPE xsdboolean.
    DATA temp11 TYPE xsdboolean.
    DATA temp12 TYPE xsdboolean.
    DATA temp13 TYPE xsdboolean.
    CREATE OBJECT temp2 TYPE zabaputil_cx_error EXPORTING val = `the_error`.
    lv_full = zabaputil_cx_error=>get_text_full( temp2 ).
    
    temp9 = boolc( lv_full CS `--- error ---` ).
    cl_abap_unit_assert=>assert_true( temp9 ).
    
    temp10 = boolc( lv_full CS `--- exception chain ---` ).
    cl_abap_unit_assert=>assert_true( temp10 ).
    
    temp11 = boolc( lv_full CS `--- context ---` ).
    cl_abap_unit_assert=>assert_true( temp11 ).
    
    temp12 = boolc( lv_full CS `the_error` ).
    cl_abap_unit_assert=>assert_true( temp12 ).
    " the message section comes first, everything else is detail
    
    temp13 = boolc( find( val = lv_full sub = `--- error ---` ) < find( val = lv_full sub = `--- exception chain ---` ) ).
    cl_abap_unit_assert=>assert_true( temp13 ).
  ENDMETHOD.

  METHOD full_context_discloses.
    " the rendered report reaches an end user in some consumers (abap2UI5
    " puts it in the body of a 500), so the context block names the system
    " and the release and stops there - client, host, user and language are
    " recon material with no place in a text a browser may show
    DATA lv_full TYPE string.
    DATA temp4 TYPE REF TO zabaputil_cx_error.
    DATA temp14 TYPE xsdboolean.
    DATA temp2 TYPE string.
    DATA temp15 TYPE xsdboolean.
    DATA temp3 TYPE string.
    DATA temp16 TYPE xsdboolean.
    DATA temp17 TYPE xsdboolean.
    DATA temp18 TYPE xsdboolean.
    DATA temp19 TYPE xsdboolean.
    DATA temp20 TYPE xsdboolean.
    CREATE OBJECT temp4 TYPE zabaputil_cx_error EXPORTING val = `the_error`.
    lv_full = zabaputil_cx_error=>get_text_full( temp4 ).

    
    temp14 = boolc( lv_full CS |release { sy-saprl }| ).
    cl_abap_unit_assert=>assert_true( temp14 ).
    
    temp2 = sy-sysid.
    
    temp15 = boolc( lv_full CS temp2 ).
    cl_abap_unit_assert=>assert_true( temp15 ).
    
    temp3 = sy-datum.
    
    temp16 = boolc( lv_full CS temp3 ).
    cl_abap_unit_assert=>assert_true( temp16 ).

    
    temp17 = boolc( lv_full CS `client` ).
    cl_abap_unit_assert=>assert_false( temp17 ).
    
    temp18 = boolc( lv_full CS `host` ).
    cl_abap_unit_assert=>assert_false( temp18 ).
    
    temp19 = boolc( lv_full CS `language` ).
    cl_abap_unit_assert=>assert_false( temp19 ).
    
    temp20 = boolc( lv_full CS |    user     : | ).
    cl_abap_unit_assert=>assert_false( temp20 ).
  ENDMETHOD.

  METHOD full_lists_every_link.
    DATA lx_inner TYPE REF TO zabaputil_cx_error.
    DATA lx_outer TYPE REF TO zabaputil_cx_error.
    DATA lv_full TYPE string.
    DATA temp21 TYPE xsdboolean.
    DATA temp22 TYPE xsdboolean.
    DATA temp23 TYPE xsdboolean.
    DATA temp24 TYPE xsdboolean.
    CREATE OBJECT lx_inner TYPE zabaputil_cx_error EXPORTING val = `inner`.
    
    CREATE OBJECT lx_outer TYPE zabaputil_cx_error EXPORTING val = `outer` previous = lx_inner.
    
    lv_full = zabaputil_cx_error=>get_text_full( lx_outer ).
    " one numbered block per link, each with the exception class and the id
    
    temp21 = boolc( lv_full CS `[1]` ).
    cl_abap_unit_assert=>assert_true( temp21 ).
    
    temp22 = boolc( lv_full CS `[2]` ).
    cl_abap_unit_assert=>assert_true( temp22 ).
    
    temp23 = boolc( lv_full CS lx_inner->ms_error-uuid ).
    cl_abap_unit_assert=>assert_true( temp23 ).
    
    temp24 = boolc( lv_full CS lx_outer->ms_error-uuid ).
    cl_abap_unit_assert=>assert_true( temp24 ).
  ENDMETHOD.

ENDCLASS.
