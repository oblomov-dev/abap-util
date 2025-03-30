
CLASS ltcl_unit_test_msg_mapper DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.

    METHODS test_bal            FOR TESTING RAISING cx_static_check.
    METHODS test_cx            FOR TESTING RAISING cx_static_check.
    METHODS test_bapiret       FOR TESTING RAISING cx_static_check.
    METHODS test_bapirettab       FOR TESTING RAISING cx_static_check.
    METHODS test_sy       FOR TESTING RAISING cx_static_check.


ENDCLASS.

CLASS ltcl_unit_test_msg_mapper IMPLEMENTATION.

  METHOD test_sy.

    IF sy-sysid = 'ABC'.
      RETURN.
    ENDIF.

    DATA lv_dummy TYPE string.
    MESSAGE ID 'NET' TYPE 'I' NUMBER '001' INTO lv_dummy.
    DATA lt_result TYPE zoblomov_cl_util=>ty_t_msg.
    lt_result = zoblomov_cl_util_msg=>msg_get( sy ).

   DATA temp6 LIKE LINE OF lt_result.
   DATA temp7 LIKE sy-tabix.
   temp7 = sy-tabix.
   READ TABLE lt_result INDEX 1 INTO temp6.
   sy-tabix = temp7.
   IF sy-subrc <> 0.
     ASSERT 1 = 0.
   ENDIF.
   cl_abap_unit_assert=>assert_equals( exp = `NET`
                                        act = temp6-id ).

    DATA temp8 LIKE LINE OF lt_result.
    DATA temp9 LIKE sy-tabix.
    temp9 = sy-tabix.
    READ TABLE lt_result INDEX 1 INTO temp8.
    sy-tabix = temp9.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `001`
                                    act = temp8-no ).

    DATA temp10 LIKE LINE OF lt_result.
    DATA temp11 LIKE sy-tabix.
    temp11 = sy-tabix.
    READ TABLE lt_result INDEX 1 INTO temp10.
    sy-tabix = temp11.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `I`
                                        act = temp10-type ).

  ENDMETHOD.

  METHOD test_bapiret.

    IF sy-sysid = 'ABC'.
      RETURN.
    ENDIF.

    DATA temp12 TYPE bapirettab.
    CLEAR temp12.
    DATA temp13 LIKE LINE OF temp12.
    temp13-type = 'E'.
    temp13-id = 'MSG1'.
    temp13-number = '001'.
    temp13-message = 'An empty Report field causes an empty XML Message to be sent'.
    INSERT temp13 INTO TABLE temp12.
    DATA lt_msg LIKE temp12.
    lt_msg = temp12.

    DATA lt_result TYPE zoblomov_cl_util=>ty_t_msg.
    DATA temp1 LIKE LINE OF lt_msg.
    DATA temp2 LIKE sy-tabix.
    temp2 = sy-tabix.
    READ TABLE lt_msg INDEX 1 INTO temp1.
    sy-tabix = temp2.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    lt_result = zoblomov_cl_util_msg=>msg_get( temp1 ).

    DATA temp14 LIKE LINE OF lt_result.
    DATA temp15 LIKE sy-tabix.
    temp15 = sy-tabix.
    READ TABLE lt_result INDEX 1 INTO temp14.
    sy-tabix = temp15.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `MSG1`
                                        act = temp14-id ).

    DATA temp16 LIKE LINE OF lt_result.
    DATA temp17 LIKE sy-tabix.
    temp17 = sy-tabix.
    READ TABLE lt_result INDEX 1 INTO temp16.
    sy-tabix = temp17.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `001`
                                    act = temp16-no ).

    DATA temp18 LIKE LINE OF lt_result.
    DATA temp19 LIKE sy-tabix.
    temp19 = sy-tabix.
    READ TABLE lt_result INDEX 1 INTO temp18.
    sy-tabix = temp19.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `E`
                                        act = temp18-type ).

  ENDMETHOD.

  METHOD test_bapirettab.

    IF sy-sysid = 'ABC'.
      RETURN.
    ENDIF.

    DATA temp20 TYPE bapirettab.
    CLEAR temp20.
    DATA temp21 LIKE LINE OF temp20.
    temp21-type = 'E'.
    temp21-id = 'MSG1'.
    temp21-number = '001'.
    temp21-message = 'An empty Report field causes an empty XML Message to be sent'.
    INSERT temp21 INTO TABLE temp20.
    temp21-type = 'I'.
    temp21-id = 'MSG2'.
    temp21-number = '002'.
    temp21-message = 'Product already in use'.
    INSERT temp21 INTO TABLE temp20.
    DATA lt_msg LIKE temp20.
    lt_msg = temp20.

    DATA lt_result TYPE zoblomov_cl_util=>ty_t_msg.
    lt_result = zoblomov_cl_util_msg=>msg_get( lt_msg ).

   DATA temp22 LIKE LINE OF lt_result.
   DATA temp23 LIKE sy-tabix.
   temp23 = sy-tabix.
   READ TABLE lt_result INDEX 1 INTO temp22.
   sy-tabix = temp23.
   IF sy-subrc <> 0.
     ASSERT 1 = 0.
   ENDIF.
   cl_abap_unit_assert=>assert_equals( exp = `MSG1`
                                        act = temp22-id ).

    DATA temp24 LIKE LINE OF lt_result.
    DATA temp25 LIKE sy-tabix.
    temp25 = sy-tabix.
    READ TABLE lt_result INDEX 1 INTO temp24.
    sy-tabix = temp25.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `001`
                                    act = temp24-no ).

    DATA temp26 LIKE LINE OF lt_result.
    DATA temp27 LIKE sy-tabix.
    temp27 = sy-tabix.
    READ TABLE lt_result INDEX 1 INTO temp26.
    sy-tabix = temp27.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `E`
                                        act = temp26-type ).

  ENDMETHOD.

  METHOD test_cx.

    TRY.
        DATA lv_val TYPE i.
        lv_val = 1 / 0.
        DATA lx TYPE REF TO cx_root.
      CATCH cx_root INTO lx.
        DATA lt_result TYPE zoblomov_cl_util=>ty_t_msg.
        lt_result = zoblomov_cl_util_msg=>msg_get( lx ).
    ENDTRY.

    DATA temp28 LIKE LINE OF lt_result.
    DATA temp29 LIKE sy-tabix.
    temp29 = sy-tabix.
    READ TABLE lt_result INDEX 1 INTO temp28.
    sy-tabix = temp29.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `E`
                                        act = temp28-type ).


  ENDMETHOD.

  method test_bal.

  TYPES: BEGIN OF ty_log_entry,
         msgnumber   TYPE n LENGTH 6,      " Application Log: Internal Message Serial Number
         msgty       TYPE c LENGTH 1,      " Message Type
         msgid       TYPE c LENGTH 20,     " Message Class
         msgno       TYPE n LENGTH 3,      " Message Number
         msgv1       TYPE c LENGTH 50,     " Message Variable
         msgv2       TYPE c LENGTH 50,     " Message Variable
         msgv3       TYPE c LENGTH 50,     " Message Variable
         msgv4       TYPE c LENGTH 50,     " Message Variable
         msgv1_src   TYPE c LENGTH 15,     " Origin of a Message Variable
         msgv2_src   TYPE c LENGTH 15,     " Origin of a Message Variable
         msgv3_src   TYPE c LENGTH 15,     " Origin of a Message Variable
         msgv4_src   TYPE c LENGTH 15,     " Origin of a Message Variable
         detlevel    TYPE c LENGTH 1,      " Level of Detail
         probclass   TYPE c LENGTH 1,      " Problem Class
         alsort      TYPE c LENGTH 3,      " Sort Criterion/Grouping
         time_stmp   TYPE p LENGTH 8 DECIMALS 7, " Message Time Stamp
         msg_count   TYPE i,               " Cumulated Message Count
         context     TYPE c LENGTH 255,    " Context (Generic Placeholder)
         params      TYPE c LENGTH 255,    " Parameters (Generic Placeholder)
         msg_txt     TYPE string,          " Message Text
       END OF ty_log_entry.

  endmethod.

ENDCLASS.
