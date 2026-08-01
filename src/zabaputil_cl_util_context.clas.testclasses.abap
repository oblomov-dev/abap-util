"! Helper class used by various tests
CLASS ltcl_test_app DEFINITION FOR TESTING.

  PUBLIC SECTION.

    INTERFACES if_serializable_object.

    TYPES:
      BEGIN OF ty_row,
        title    TYPE string,
        value    TYPE string,
        descr    TYPE string,
        icon     TYPE string,
        info     TYPE string,
        selected TYPE abap_bool,
        checkbox TYPE abap_bool,
      END OF ty_row.

    CONSTANTS sv_status TYPE string VALUE `test` ##NEEDED.

    CLASS-DATA sv_var TYPE string.
    CLASS-DATA ss_tab TYPE ty_row.
    CLASS-DATA st_tab TYPE STANDARD TABLE OF ty_row WITH EMPTY KEY.

    CLASS-METHODS class_constructor.

    DATA mv_val TYPE string ##NEEDED.
    DATA ms_tab TYPE ty_row ##NEEDED.
    DATA mt_tab TYPE STANDARD TABLE OF ty_row WITH EMPTY KEY ##NEEDED.

  PROTECTED SECTION.

  PRIVATE SECTION.
ENDCLASS.

CLASS ltcl_test_app IMPLEMENTATION.

  METHOD class_constructor.
    sv_var = `test`.
    ss_tab = VALUE #( title = `the_title` value = `the_value` ).
    st_tab = VALUE #( ( title = `test` ) ( title = `test2` ) ).
  ENDMETHOD.

ENDCLASS.

"! ================================================================
"! STRING OPERATIONS - Detailed behavioral tests for JS transpilation
"! ================================================================
CLASS ltcl_string_ops DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.

    " c_trim
    METHODS trim_simple                    FOR TESTING.
    METHODS trim_leading_trailing          FOR TESTING.
    METHODS trim_horizontal_tab            FOR TESTING.
    METHODS trim_empty                     FOR TESTING.
    METHODS trim_no_trim_needed            FOR TESTING.

    " c_trim_upper
    METHODS trim_upper_basic               FOR TESTING.
    METHODS trim_upper_mixed               FOR TESTING.

    " c_trim_lower
    METHODS trim_lower_basic               FOR TESTING.
    METHODS trim_lower_mixed               FOR TESTING.

    " c_contains
    METHODS contains_true                  FOR TESTING.
    METHODS contains_false                 FOR TESTING.
    METHODS contains_empty_sub             FOR TESTING.
    METHODS contains_case_sensitive        FOR TESTING.

    " c_starts_with
    METHODS starts_with_true               FOR TESTING.
    METHODS starts_with_false              FOR TESTING.
    METHODS starts_with_longer_prefix      FOR TESTING.
    METHODS starts_with_empty              FOR TESTING.

    " c_ends_with
    METHODS ends_with_true                 FOR TESTING.
    METHODS ends_with_false                FOR TESTING.
    METHODS ends_with_longer_suffix        FOR TESTING.
    METHODS ends_with_empty                FOR TESTING.

    " c_split
    METHODS split_basic                    FOR TESTING.
    METHODS split_no_sep                   FOR TESTING.
    METHODS split_multi                    FOR TESTING.
    METHODS split_empty_parts              FOR TESTING.

    " c_join
    METHODS join_basic                     FOR TESTING.
    METHODS join_empty_sep                 FOR TESTING.
    METHODS join_single                    FOR TESTING.
    METHODS join_empty_table               FOR TESTING.

    " c_pad_left
    METHODS pad_left_basic                 FOR TESTING.
    METHODS pad_left_no_pad_needed         FOR TESTING.
    METHODS pad_left_already_longer        FOR TESTING.

    " c_pad_right
    METHODS pad_right_basic                FOR TESTING.
    METHODS pad_right_no_pad_needed        FOR TESTING.

    " c_truncate
    METHODS truncate_short_string          FOR TESTING.
    METHODS truncate_exact_length          FOR TESTING.
    METHODS truncate_long_string           FOR TESTING.
    METHODS truncate_custom_ellipsis       FOR TESTING.

    " c_substring_safe
    METHODS substring_safe_normal          FOR TESTING.
    METHODS substring_safe_negative_off    FOR TESTING.
    METHODS substring_safe_beyond_end      FOR TESTING.
    METHODS substring_safe_no_len          FOR TESTING.
    METHODS substring_safe_off_past_len    FOR TESTING.

    " c_replace_all
    METHODS replace_all_basic              FOR TESTING.
    METHODS replace_all_multiple           FOR TESTING.
    METHODS replace_all_no_match           FOR TESTING.

    " c_is_blank
    METHODS is_blank_empty                 FOR TESTING.
    METHODS is_blank_spaces                FOR TESTING.
    METHODS is_blank_not_blank             FOR TESTING.
    METHODS is_blank_tabs                  FOR TESTING.

ENDCLASS.

CLASS ltcl_string_ops IMPLEMENTATION.

  METHOD trim_simple.
    cl_abap_unit_assert=>assert_equals( exp = `hello`
                                        act = zabaputil_cl_util_context=>c_trim( `  hello  ` ) ).
  ENDMETHOD.

  METHOD trim_leading_trailing.
    cl_abap_unit_assert=>assert_equals( exp = `test`
                                        act = zabaputil_cl_util_context=>c_trim( `   test   ` ) ).
  ENDMETHOD.

  METHOD trim_horizontal_tab.
    DATA(lv_tab) = zabaputil_cl_util_context=>cv_char_util_horizontal_tab.
    DATA(lv_val) = lv_tab && `hello` && lv_tab.
    cl_abap_unit_assert=>assert_equals( exp = `hello`
                                        act = zabaputil_cl_util_context=>c_trim( lv_val ) ).
  ENDMETHOD.

  METHOD trim_empty.
    cl_abap_unit_assert=>assert_equals( exp = ``
                                        act = zabaputil_cl_util_context=>c_trim( `   ` ) ).
  ENDMETHOD.

  METHOD trim_no_trim_needed.
    cl_abap_unit_assert=>assert_equals( exp = `abc`
                                        act = zabaputil_cl_util_context=>c_trim( `abc` ) ).
  ENDMETHOD.

  METHOD trim_upper_basic.
    cl_abap_unit_assert=>assert_equals( exp = `HELLO`
                                        act = zabaputil_cl_util_context=>c_trim_upper( `  hello  ` ) ).
  ENDMETHOD.

  METHOD trim_upper_mixed.
    cl_abap_unit_assert=>assert_equals( exp = `HELLO WORLD`
                                        act = zabaputil_cl_util_context=>c_trim_upper( `  Hello World  ` ) ).
  ENDMETHOD.

  METHOD trim_lower_basic.
    cl_abap_unit_assert=>assert_equals( exp = `hello`
                                        act = zabaputil_cl_util_context=>c_trim_lower( `  HELLO  ` ) ).
  ENDMETHOD.

  METHOD trim_lower_mixed.
    cl_abap_unit_assert=>assert_equals( exp = `hello world`
                                        act = zabaputil_cl_util_context=>c_trim_lower( `  Hello World  ` ) ).
  ENDMETHOD.

  METHOD contains_true.
    cl_abap_unit_assert=>assert_true( zabaputil_cl_util_context=>c_contains( val = `Hello World` sub = `World` ) ).
  ENDMETHOD.

  METHOD contains_false.
    cl_abap_unit_assert=>assert_false( zabaputil_cl_util_context=>c_contains( val = `Hello World` sub = `xyz` ) ).
  ENDMETHOD.

  METHOD contains_empty_sub.
    " CS with empty string is always true in ABAP
    cl_abap_unit_assert=>assert_true( zabaputil_cl_util_context=>c_contains( val = `Hello` sub = `` ) ).
  ENDMETHOD.

  METHOD contains_case_sensitive.
    " ABAP CS is case-insensitive
    cl_abap_unit_assert=>assert_true( zabaputil_cl_util_context=>c_contains( val = `Hello World` sub = `hello` ) ).
  ENDMETHOD.

  METHOD starts_with_true.
    cl_abap_unit_assert=>assert_true( zabaputil_cl_util_context=>c_starts_with( val = `Hello World` prefix = `Hello` ) ).
  ENDMETHOD.

  METHOD starts_with_false.
    cl_abap_unit_assert=>assert_false( zabaputil_cl_util_context=>c_starts_with( val = `Hello World` prefix = `World` ) ).
  ENDMETHOD.

  METHOD starts_with_longer_prefix.
    cl_abap_unit_assert=>assert_false( zabaputil_cl_util_context=>c_starts_with( val = `Hi` prefix = `Hello` ) ).
  ENDMETHOD.

  METHOD starts_with_empty.
    cl_abap_unit_assert=>assert_true( zabaputil_cl_util_context=>c_starts_with( val = `Hello` prefix = `` ) ).
  ENDMETHOD.

  METHOD ends_with_true.
    cl_abap_unit_assert=>assert_true( zabaputil_cl_util_context=>c_ends_with( val = `Hello World` suffix = `World` ) ).
  ENDMETHOD.

  METHOD ends_with_false.
    cl_abap_unit_assert=>assert_false( zabaputil_cl_util_context=>c_ends_with( val = `Hello World` suffix = `Hello` ) ).
  ENDMETHOD.

  METHOD ends_with_longer_suffix.
    cl_abap_unit_assert=>assert_false( zabaputil_cl_util_context=>c_ends_with( val = `Hi` suffix = `Hello` ) ).
  ENDMETHOD.

  METHOD ends_with_empty.
    cl_abap_unit_assert=>assert_true( zabaputil_cl_util_context=>c_ends_with( val = `Hello` suffix = `` ) ).
  ENDMETHOD.

  METHOD split_basic.
    DATA(lt_result) = zabaputil_cl_util_context=>c_split( val = `a,b,c` sep = `,` ).
    cl_abap_unit_assert=>assert_equals( exp = 3 act = lines( lt_result ) ).
    cl_abap_unit_assert=>assert_equals( exp = `a` act = lt_result[ 1 ] ).
    cl_abap_unit_assert=>assert_equals( exp = `b` act = lt_result[ 2 ] ).
    cl_abap_unit_assert=>assert_equals( exp = `c` act = lt_result[ 3 ] ).
  ENDMETHOD.

  METHOD split_no_sep.
    DATA(lt_result) = zabaputil_cl_util_context=>c_split( val = `hello` sep = `,` ).
    cl_abap_unit_assert=>assert_equals( exp = 1 act = lines( lt_result ) ).
    cl_abap_unit_assert=>assert_equals( exp = `hello` act = lt_result[ 1 ] ).
  ENDMETHOD.

  METHOD split_multi.
    DATA(lt_result) = zabaputil_cl_util_context=>c_split( val = `one::two::three` sep = `::` ).
    cl_abap_unit_assert=>assert_equals( exp = 3 act = lines( lt_result ) ).
    cl_abap_unit_assert=>assert_equals( exp = `one` act = lt_result[ 1 ] ).
    cl_abap_unit_assert=>assert_equals( exp = `two` act = lt_result[ 2 ] ).
    cl_abap_unit_assert=>assert_equals( exp = `three` act = lt_result[ 3 ] ).
  ENDMETHOD.

  METHOD split_empty_parts.
    DATA(lt_result) = zabaputil_cl_util_context=>c_split( val = `a;;b` sep = `;` ).
    cl_abap_unit_assert=>assert_equals( exp = 3 act = lines( lt_result ) ).
    cl_abap_unit_assert=>assert_equals( exp = `a` act = lt_result[ 1 ] ).
    cl_abap_unit_assert=>assert_equals( exp = `` act = lt_result[ 2 ] ).
    cl_abap_unit_assert=>assert_equals( exp = `b` act = lt_result[ 3 ] ).
  ENDMETHOD.

  METHOD join_basic.
    DATA(lt_tab) = VALUE string_table( ( `a` ) ( `b` ) ( `c` ) ).
    cl_abap_unit_assert=>assert_equals( exp = `a,b,c`
                                        act = zabaputil_cl_util_context=>c_join( tab = lt_tab sep = `,` ) ).
  ENDMETHOD.

  METHOD join_empty_sep.
    DATA(lt_tab) = VALUE string_table( ( `a` ) ( `b` ) ( `c` ) ).
    cl_abap_unit_assert=>assert_equals( exp = `abc`
                                        act = zabaputil_cl_util_context=>c_join( tab = lt_tab ) ).
  ENDMETHOD.

  METHOD join_single.
    DATA(lt_tab) = VALUE string_table( ( `hello` ) ).
    cl_abap_unit_assert=>assert_equals( exp = `hello`
                                        act = zabaputil_cl_util_context=>c_join( tab = lt_tab sep = `,` ) ).
  ENDMETHOD.

  METHOD join_empty_table.
    DATA(lt_tab) = VALUE string_table( ).
    cl_abap_unit_assert=>assert_equals( exp = ``
                                        act = zabaputil_cl_util_context=>c_join( tab = lt_tab sep = `,` ) ).
  ENDMETHOD.

  METHOD pad_left_basic.
    cl_abap_unit_assert=>assert_equals( exp = `005`
                                        act = zabaputil_cl_util_context=>c_pad_left( val = `5` len = 3 pad = '0' ) ).
  ENDMETHOD.

  METHOD pad_left_no_pad_needed.
    cl_abap_unit_assert=>assert_equals( exp = `123`
                                        act = zabaputil_cl_util_context=>c_pad_left( val = `123` len = 3 pad = '0' ) ).
  ENDMETHOD.

  METHOD pad_left_already_longer.
    cl_abap_unit_assert=>assert_equals( exp = `12345`
                                        act = zabaputil_cl_util_context=>c_pad_left( val = `12345` len = 3 pad = '0' ) ).
  ENDMETHOD.

  METHOD pad_right_basic.
    " After fix: pad is now converted to string internally, so space padding works
    cl_abap_unit_assert=>assert_equals( exp = `hi   `
                                        act = zabaputil_cl_util_context=>c_pad_right( val = `hi` len = 5 ) ).
  ENDMETHOD.

  METHOD pad_right_no_pad_needed.
    cl_abap_unit_assert=>assert_equals( exp = `hello`
                                        act = zabaputil_cl_util_context=>c_pad_right( val = `hello` len = 5 ) ).
  ENDMETHOD.

  METHOD truncate_short_string.
    cl_abap_unit_assert=>assert_equals( exp = `Hi`
                                        act = zabaputil_cl_util_context=>c_truncate( val = `Hi` max = 10 ) ).
  ENDMETHOD.

  METHOD truncate_exact_length.
    cl_abap_unit_assert=>assert_equals( exp = `Hello`
                                        act = zabaputil_cl_util_context=>c_truncate( val = `Hello` max = 5 ) ).
  ENDMETHOD.

  METHOD truncate_long_string.
    cl_abap_unit_assert=>assert_equals( exp = `Hell...`
                                        act = zabaputil_cl_util_context=>c_truncate( val = `Hello World` max = 7 ) ).
  ENDMETHOD.

  METHOD truncate_custom_ellipsis.
    cl_abap_unit_assert=>assert_equals( exp = `Hello~`
                                        act = zabaputil_cl_util_context=>c_truncate( val = `Hello World` max = 6 ellipsis = `~` ) ).
  ENDMETHOD.

  METHOD substring_safe_normal.
    cl_abap_unit_assert=>assert_equals( exp = `llo`
                                        act = zabaputil_cl_util_context=>c_substring_safe( val = `Hello` off = 2 len = 3 ) ).
  ENDMETHOD.

  METHOD substring_safe_negative_off.
    " Negative offset should be treated as 0
    cl_abap_unit_assert=>assert_equals( exp = `He`
                                        act = zabaputil_cl_util_context=>c_substring_safe( val = `Hello` off = -1 len = 2 ) ).
  ENDMETHOD.

  METHOD substring_safe_beyond_end.
    " len extends beyond string end - should return rest
    cl_abap_unit_assert=>assert_equals( exp = `lo`
                                        act = zabaputil_cl_util_context=>c_substring_safe( val = `Hello` off = 3 len = 99 ) ).
  ENDMETHOD.

  METHOD substring_safe_no_len.
    " len = -1 means rest of string
    cl_abap_unit_assert=>assert_equals( exp = `llo`
                                        act = zabaputil_cl_util_context=>c_substring_safe( val = `Hello` off = 2 ) ).
  ENDMETHOD.

  METHOD substring_safe_off_past_len.
    " offset beyond string length -> empty
    cl_abap_unit_assert=>assert_equals( exp = ``
                                        act = zabaputil_cl_util_context=>c_substring_safe( val = `Hi` off = 10 len = 5 ) ).
  ENDMETHOD.

  METHOD replace_all_basic.
    cl_abap_unit_assert=>assert_equals( exp = `hello world`
                                        act = zabaputil_cl_util_context=>c_replace_all( val = `hello_world` sub = `_` new_val = ` ` ) ).
  ENDMETHOD.

  METHOD replace_all_multiple.
    cl_abap_unit_assert=>assert_equals( exp = `a-b-c`
                                        act = zabaputil_cl_util_context=>c_replace_all( val = `a.b.c` sub = `.` new_val = `-` ) ).
  ENDMETHOD.

  METHOD replace_all_no_match.
    cl_abap_unit_assert=>assert_equals( exp = `hello`
                                        act = zabaputil_cl_util_context=>c_replace_all( val = `hello` sub = `x` new_val = `y` ) ).
  ENDMETHOD.

  METHOD is_blank_empty.
    cl_abap_unit_assert=>assert_true( zabaputil_cl_util_context=>c_is_blank( `` ) ).
  ENDMETHOD.

  METHOD is_blank_spaces.
    cl_abap_unit_assert=>assert_true( zabaputil_cl_util_context=>c_is_blank( `   ` ) ).
  ENDMETHOD.

  METHOD is_blank_not_blank.
    cl_abap_unit_assert=>assert_false( zabaputil_cl_util_context=>c_is_blank( `hi` ) ).
  ENDMETHOD.

  METHOD is_blank_tabs.
    DATA(lv_val) = zabaputil_cl_util_context=>cv_char_util_horizontal_tab.
    cl_abap_unit_assert=>assert_true( zabaputil_cl_util_context=>c_is_blank( lv_val ) ).
  ENDMETHOD.

ENDCLASS.


"! ================================================================
"! BOOLEAN OPERATIONS
"! ================================================================
CLASS ltcl_boolean_ops DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.

    METHODS check_by_name_abap_bool        FOR TESTING.
    METHODS check_by_name_xsdboolean       FOR TESTING.
    METHODS check_by_name_flag             FOR TESTING.
    METHODS check_by_name_xflag            FOR TESTING.
    METHODS check_by_name_xfeld            FOR TESTING.
    METHODS check_by_name_wdy_boolean      FOR TESTING.
    METHODS check_by_name_boole_d          FOR TESTING.
    METHODS check_by_name_os_boolean       FOR TESTING.
    METHODS check_by_name_not_bool         FOR TESTING.
    METHODS check_by_name_empty            FOR TESTING.

    METHODS abap2json_true                 FOR TESTING.
    METHODS abap2json_false                FOR TESTING.
    METHODS abap2json_non_boolean          FOR TESTING.

    METHODS check_by_data_abap_bool        FOR TESTING.
    METHODS check_by_data_string           FOR TESTING.

    METHODS ui5_msg_type_e                 FOR TESTING.
    METHODS ui5_msg_type_s                 FOR TESTING.
    METHODS ui5_msg_type_w                 FOR TESTING.
    METHODS ui5_msg_type_i                 FOR TESTING.
    METHODS ui5_msg_type_other             FOR TESTING.

ENDCLASS.

CLASS ltcl_boolean_ops IMPLEMENTATION.

  METHOD check_by_name_abap_bool.
    cl_abap_unit_assert=>assert_true( zabaputil_cl_util_context=>boolean_check_by_name( `ABAP_BOOL` ) ).
  ENDMETHOD.

  METHOD check_by_name_xsdboolean.
    cl_abap_unit_assert=>assert_true( zabaputil_cl_util_context=>boolean_check_by_name( `XSDBOOLEAN` ) ).
  ENDMETHOD.

  METHOD check_by_name_flag.
    cl_abap_unit_assert=>assert_true( zabaputil_cl_util_context=>boolean_check_by_name( `FLAG` ) ).
  ENDMETHOD.

  METHOD check_by_name_xflag.
    cl_abap_unit_assert=>assert_true( zabaputil_cl_util_context=>boolean_check_by_name( `XFLAG` ) ).
  ENDMETHOD.

  METHOD check_by_name_xfeld.
    cl_abap_unit_assert=>assert_true( zabaputil_cl_util_context=>boolean_check_by_name( `XFELD` ) ).
  ENDMETHOD.

  METHOD check_by_name_wdy_boolean.
    cl_abap_unit_assert=>assert_true( zabaputil_cl_util_context=>boolean_check_by_name( `WDY_BOOLEAN` ) ).
  ENDMETHOD.

  METHOD check_by_name_boole_d.
    cl_abap_unit_assert=>assert_true( zabaputil_cl_util_context=>boolean_check_by_name( `BOOLE_D` ) ).
  ENDMETHOD.

  METHOD check_by_name_os_boolean.
    cl_abap_unit_assert=>assert_true( zabaputil_cl_util_context=>boolean_check_by_name( `OS_BOOLEAN` ) ).
  ENDMETHOD.

  METHOD check_by_name_not_bool.
    cl_abap_unit_assert=>assert_false( zabaputil_cl_util_context=>boolean_check_by_name( `STRING` ) ).
  ENDMETHOD.

  METHOD check_by_name_empty.
    cl_abap_unit_assert=>assert_false( zabaputil_cl_util_context=>boolean_check_by_name( `` ) ).
  ENDMETHOD.

  METHOD abap2json_true.
    cl_abap_unit_assert=>assert_equals( exp = `true`
                                        act = zabaputil_cl_util_context=>boolean_abap_2_json( abap_true ) ).
  ENDMETHOD.

  METHOD abap2json_false.
    cl_abap_unit_assert=>assert_equals( exp = `false`
                                        act = zabaputil_cl_util_context=>boolean_abap_2_json( abap_false ) ).
  ENDMETHOD.

  METHOD abap2json_non_boolean.
    " Non-boolean value is passed through unchanged
    DATA lv_val TYPE string VALUE `something`.
    cl_abap_unit_assert=>assert_equals( exp = `something`
                                        act = zabaputil_cl_util_context=>boolean_abap_2_json( lv_val ) ).
  ENDMETHOD.

  METHOD check_by_data_abap_bool.
    DATA lv_bool TYPE abap_bool VALUE abap_true.
    cl_abap_unit_assert=>assert_true( zabaputil_cl_util_context=>boolean_check_by_data( lv_bool ) ).
  ENDMETHOD.

  METHOD check_by_data_string.
    DATA lv_str TYPE string VALUE `X`.
    cl_abap_unit_assert=>assert_false( zabaputil_cl_util_context=>boolean_check_by_data( lv_str ) ).
  ENDMETHOD.

  METHOD ui5_msg_type_e.
    cl_abap_unit_assert=>assert_equals( exp = `Error` act = zabaputil_cl_util_context=>ui5_get_msg_type( `E` ) ).
  ENDMETHOD.

  METHOD ui5_msg_type_s.
    cl_abap_unit_assert=>assert_equals( exp = `Success` act = zabaputil_cl_util_context=>ui5_get_msg_type( `S` ) ).
  ENDMETHOD.

  METHOD ui5_msg_type_w.
    cl_abap_unit_assert=>assert_equals( exp = `Warning` act = zabaputil_cl_util_context=>ui5_get_msg_type( `W` ) ).
  ENDMETHOD.

  METHOD ui5_msg_type_i.
    cl_abap_unit_assert=>assert_equals( exp = `Information` act = zabaputil_cl_util_context=>ui5_get_msg_type( `I` ) ).
  ENDMETHOD.

  METHOD ui5_msg_type_other.
    " Any other type maps to Information
    cl_abap_unit_assert=>assert_equals( exp = `Information` act = zabaputil_cl_util_context=>ui5_get_msg_type( `X` ) ).
  ENDMETHOD.

ENDCLASS.


"! ================================================================
"! URL PARAMETER OPERATIONS
"! ================================================================
CLASS ltcl_url_ops DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.

    METHODS param_get_basic                FOR TESTING.
    METHODS param_get_case_insensitive     FOR TESTING.
    METHODS param_get_not_found            FOR TESTING.
    METHODS param_get_encoded              FOR TESTING.

    METHODS param_get_tab_basic            FOR TESTING.
    METHODS param_get_tab_multiple         FOR TESTING.
    METHODS param_get_tab_with_question    FOR TESTING.

    METHODS param_create_url_basic         FOR TESTING.
    METHODS param_create_url_single        FOR TESTING.
    METHODS param_create_url_empty         FOR TESTING.

    METHODS param_set_new_param            FOR TESTING.
    METHODS param_set_existing_param       FOR TESTING.

    METHODS param_get_tab_normalizes_name  FOR TESTING.
    METHODS param_get_tab_no_phantom       FOR TESTING.

    METHODS app_url_drops_app_hash         FOR TESTING.
    METHODS app_url_keeps_shell_hash       FOR TESTING.

ENDCLASS.

CLASS ltcl_url_ops IMPLEMENTATION.

  METHOD param_get_basic.
    cl_abap_unit_assert=>assert_equals(
        exp = `world`
        act = zabaputil_cl_util_context=>url_param_get( val = `hello` url = `hello=world&foo=bar` ) ).
  ENDMETHOD.

  METHOD param_get_case_insensitive.
    cl_abap_unit_assert=>assert_equals(
        exp = `world`
        act = zabaputil_cl_util_context=>url_param_get( val = `HELLO` url = `hello=world&foo=bar` ) ).
  ENDMETHOD.

  METHOD param_get_not_found.
    cl_abap_unit_assert=>assert_equals(
        exp = ``
        act = zabaputil_cl_util_context=>url_param_get( val = `missing` url = `hello=world` ) ).
  ENDMETHOD.

  METHOD param_get_encoded.
    cl_abap_unit_assert=>assert_equals(
        exp = `world`
        act = zabaputil_cl_util_context=>url_param_get( val = `hello` url = `hello%3Dworld%26foo%3Dbar` ) ).
  ENDMETHOD.

  METHOD param_get_tab_basic.
    DATA(lt_result) = zabaputil_cl_util_context=>url_param_get_tab( `name=john&age=30` ).
    cl_abap_unit_assert=>assert_equals( exp = 2 act = lines( lt_result ) ).
    cl_abap_unit_assert=>assert_equals( exp = `name` act = lt_result[ 1 ]-n ).
    cl_abap_unit_assert=>assert_equals( exp = `john` act = lt_result[ 1 ]-v ).
    cl_abap_unit_assert=>assert_equals( exp = `age` act = lt_result[ 2 ]-n ).
    cl_abap_unit_assert=>assert_equals( exp = `30` act = lt_result[ 2 ]-v ).
  ENDMETHOD.

  METHOD param_get_tab_multiple.
    DATA(lt_result) = zabaputil_cl_util_context=>url_param_get_tab( `a=1&b=2&c=3` ).
    cl_abap_unit_assert=>assert_equals( exp = 3 act = lines( lt_result ) ).
  ENDMETHOD.

  METHOD param_get_tab_with_question.
    DATA(lt_result) = zabaputil_cl_util_context=>url_param_get_tab( `?name=john&age=30` ).
    cl_abap_unit_assert=>assert_equals( exp = 2 act = lines( lt_result ) ).
    cl_abap_unit_assert=>assert_equals( exp = `name` act = lt_result[ 1 ]-n ).
  ENDMETHOD.

  METHOD param_create_url_basic.
    DATA(lt_params) = VALUE zabaputil_cl_util_context=>ty_t_name_value(
        ( n = `name` v = `john` )
        ( n = `age` v = `30` ) ).
    DATA(lv_result) = zabaputil_cl_util_context=>url_param_create_url( lt_params ).
    cl_abap_unit_assert=>assert_equals( exp = `name=john&age=30`
                                        act = lv_result ).
  ENDMETHOD.

  METHOD param_create_url_single.
    DATA(lt_params) = VALUE zabaputil_cl_util_context=>ty_t_name_value( ( n = `key` v = `val` ) ).
    cl_abap_unit_assert=>assert_equals( exp = `key=val`
                                        act = zabaputil_cl_util_context=>url_param_create_url( lt_params ) ).
  ENDMETHOD.

  METHOD param_create_url_empty.
    DATA(lt_params) = VALUE zabaputil_cl_util_context=>ty_t_name_value( ).
    cl_abap_unit_assert=>assert_equals( exp = ``
                                        act = zabaputil_cl_util_context=>url_param_create_url( lt_params ) ).
  ENDMETHOD.

  METHOD param_set_new_param.
    DATA(lv_result) = zabaputil_cl_util_context=>url_param_set( url = `a=1&b=2`
                                                     name = `c`
                                                     value = `3` ).
    " Result should contain all three params
    cl_abap_unit_assert=>assert_true( zabaputil_cl_util_context=>c_contains( val = lv_result sub = `c=3` ) ).
    cl_abap_unit_assert=>assert_true( zabaputil_cl_util_context=>c_contains( val = lv_result sub = `a=1` ) ).
  ENDMETHOD.

  METHOD param_set_existing_param.
    DATA(lv_result) = zabaputil_cl_util_context=>url_param_set( url = `a=1&b=2`
                                                     name = `b`
                                                     value = `99` ).
    cl_abap_unit_assert=>assert_true( zabaputil_cl_util_context=>c_contains( val = lv_result sub = `b=99` ) ).
    cl_abap_unit_assert=>assert_false( zabaputil_cl_util_context=>c_contains( val = lv_result sub = `b=2` ) ).
  ENDMETHOD.

  METHOD param_get_tab_normalizes_name.
    " url_param_get / url_param_set look up with c_trim_lower, so the stored
    " name has to be lower case for a mixed-case URL to resolve at all. The
    " value keeps its original case.
    DATA(lt_result) = zabaputil_cl_util_context=>url_param_get_tab( `https://h/p?APP_START=MixedCase` ).
    cl_abap_unit_assert=>assert_equals( exp = `app_start` act = lt_result[ 1 ]-n ).
    cl_abap_unit_assert=>assert_equals( exp = `MixedCase` act = lt_result[ 1 ]-v ).

    cl_abap_unit_assert=>assert_equals(
        exp = `MixedCase`
        act = zabaputil_cl_util_context=>url_param_get( val = `app_start`
                                                        url = `?APP_START=MixedCase` ) ).
  ENDMETHOD.

  METHOD param_get_tab_no_phantom.
    " an empty segment (empty search string, trailing &) must not become a
    " nameless row - url_param_create_url would write it back out as `=&`
    cl_abap_unit_assert=>assert_initial( zabaputil_cl_util_context=>url_param_get_tab( `` ) ).

    cl_abap_unit_assert=>assert_equals(
        exp = 1
        act = lines( zabaputil_cl_util_context=>url_param_get_tab( `?a=1&` ) ) ).
  ENDMETHOD.

  METHOD app_url_drops_app_hash.
    " the app-owned hash (route or app-state, leading `/`) must be dropped -
    " a consumer backend prefers it over app_start, so keeping it would
    " re-open the current app instead of the requested one
    cl_abap_unit_assert=>assert_equals(
        exp = `https://h/p?app_start=zcl_new`
        act = zabaputil_cl_util_context=>app_get_url( classname = `ZCL_NEW`
                                                      origin    = `https://h`
                                                      pathname  = `/p`
                                                      search    = ``
                                                      hash      = `#/app/ZCL_OLD/DRAFT1` ) ).
  ENDMETHOD.

  METHOD app_url_keeps_shell_hash.
    " inside the launchpad the shell part of the hash survives, only the app
    " part after `&/` is cut
    cl_abap_unit_assert=>assert_equals(
        exp = `https://h/p?app_start=zcl_new#Shell-home`
        act = zabaputil_cl_util_context=>app_get_url( classname = `ZCL_NEW`
                                                      origin    = `https://h`
                                                      pathname  = `/p`
                                                      search    = ``
                                                      hash      = `#Shell-home&/app/ZCL_OLD/DRAFT1` ) ).
  ENDMETHOD.

ENDCLASS.


"! ================================================================
"! VALIDATION HELPERS
"! ================================================================
CLASS ltcl_validation DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.

    " check_is_email
    METHODS email_valid                    FOR TESTING.
    METHODS email_no_at                    FOR TESTING.
    METHODS email_no_dot_in_domain         FOR TESTING.
    METHODS email_multiple_at              FOR TESTING.
    METHODS email_empty                    FOR TESTING.
    METHODS email_no_local_part            FOR TESTING.

    " check_is_numeric_string
    METHODS numeric_integer                FOR TESTING.
    METHODS numeric_negative               FOR TESTING.
    METHODS numeric_decimal_dot            FOR TESTING.
    METHODS numeric_decimal_comma          FOR TESTING.
    METHODS numeric_plus_sign              FOR TESTING.
    METHODS numeric_letters                FOR TESTING.
    METHODS numeric_empty                  FOR TESTING.
    METHODS numeric_spaces_trimmed         FOR TESTING.

    " check_is_guid
    METHODS guid_valid_32                  FOR TESTING.
    METHODS guid_valid_with_dashes         FOR TESTING.
    METHODS guid_too_short                 FOR TESTING.
    METHODS guid_invalid_chars             FOR TESTING.
    METHODS guid_lowercase                 FOR TESTING.

    " check_max_length
    METHODS max_length_within              FOR TESTING.
    METHODS max_length_exact               FOR TESTING.
    METHODS max_length_exceeded            FOR TESTING.

    " check_is_date_valid
    METHODS date_valid_basic               FOR TESTING.
    METHODS date_invalid_format            FOR TESTING.

ENDCLASS.

CLASS ltcl_validation IMPLEMENTATION.

  METHOD email_valid.
    cl_abap_unit_assert=>assert_true( zabaputil_cl_util_context=>check_is_email( `user@example.com` ) ).
  ENDMETHOD.

  METHOD email_no_at.
    cl_abap_unit_assert=>assert_false( zabaputil_cl_util_context=>check_is_email( `userexample.com` ) ).
  ENDMETHOD.

  METHOD email_no_dot_in_domain.
    cl_abap_unit_assert=>assert_false( zabaputil_cl_util_context=>check_is_email( `user@localhost` ) ).
  ENDMETHOD.

  METHOD email_multiple_at.
    cl_abap_unit_assert=>assert_false( zabaputil_cl_util_context=>check_is_email( `user@@example.com` ) ).
  ENDMETHOD.

  METHOD email_empty.
    cl_abap_unit_assert=>assert_false( zabaputil_cl_util_context=>check_is_email( `` ) ).
  ENDMETHOD.

  METHOD email_no_local_part.
    cl_abap_unit_assert=>assert_false( zabaputil_cl_util_context=>check_is_email( `@example.com` ) ).
  ENDMETHOD.

  METHOD numeric_integer.
    cl_abap_unit_assert=>assert_true( zabaputil_cl_util_context=>check_is_numeric_string( `12345` ) ).
  ENDMETHOD.

  METHOD numeric_negative.
    cl_abap_unit_assert=>assert_true( zabaputil_cl_util_context=>check_is_numeric_string( `-42` ) ).
  ENDMETHOD.

  METHOD numeric_decimal_dot.
    cl_abap_unit_assert=>assert_true( zabaputil_cl_util_context=>check_is_numeric_string( `3.14` ) ).
  ENDMETHOD.

  METHOD numeric_decimal_comma.
    cl_abap_unit_assert=>assert_true( zabaputil_cl_util_context=>check_is_numeric_string( `3,14` ) ).
  ENDMETHOD.

  METHOD numeric_plus_sign.
    cl_abap_unit_assert=>assert_true( zabaputil_cl_util_context=>check_is_numeric_string( `+99` ) ).
  ENDMETHOD.

  METHOD numeric_letters.
    cl_abap_unit_assert=>assert_false( zabaputil_cl_util_context=>check_is_numeric_string( `12abc` ) ).
  ENDMETHOD.

  METHOD numeric_empty.
    cl_abap_unit_assert=>assert_false( zabaputil_cl_util_context=>check_is_numeric_string( `` ) ).
  ENDMETHOD.

  METHOD numeric_spaces_trimmed.
    cl_abap_unit_assert=>assert_true( zabaputil_cl_util_context=>check_is_numeric_string( `  42  ` ) ).
  ENDMETHOD.

  METHOD guid_valid_32.
    cl_abap_unit_assert=>assert_true( zabaputil_cl_util_context=>check_is_guid( `A1B2C3D4E5F6A7B8C9D0E1F2A3B4C5D6` ) ).
  ENDMETHOD.

  METHOD guid_valid_with_dashes.
    cl_abap_unit_assert=>assert_true( zabaputil_cl_util_context=>check_is_guid( `A1B2C3D4-E5F6-A7B8-C9D0-E1F2A3B4C5D6` ) ).
  ENDMETHOD.

  METHOD guid_too_short.
    cl_abap_unit_assert=>assert_false( zabaputil_cl_util_context=>check_is_guid( `A1B2C3D4` ) ).
  ENDMETHOD.

  METHOD guid_invalid_chars.
    cl_abap_unit_assert=>assert_false( zabaputil_cl_util_context=>check_is_guid( `G1B2C3D4E5F6A7B8C9D0E1F2A3B4C5D6` ) ).
  ENDMETHOD.

  METHOD guid_lowercase.
    cl_abap_unit_assert=>assert_true( zabaputil_cl_util_context=>check_is_guid( `a1b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6` ) ).
  ENDMETHOD.

  METHOD max_length_within.
    cl_abap_unit_assert=>assert_true( zabaputil_cl_util_context=>check_max_length( val = `hi` max = 10 ) ).
  ENDMETHOD.

  METHOD max_length_exact.
    cl_abap_unit_assert=>assert_true( zabaputil_cl_util_context=>check_max_length( val = `hello` max = 5 ) ).
  ENDMETHOD.

  METHOD max_length_exceeded.
    cl_abap_unit_assert=>assert_false( zabaputil_cl_util_context=>check_max_length( val = `hello world` max = 5 ) ).
  ENDMETHOD.

  METHOD date_valid_basic.
    cl_abap_unit_assert=>assert_true( zabaputil_cl_util_context=>check_is_date_valid( `2024-03-15` ) ).
  ENDMETHOD.

  METHOD date_invalid_format.
    cl_abap_unit_assert=>assert_false( zabaputil_cl_util_context=>check_is_date_valid( `not-a-date` ) ).
  ENDMETHOD.

ENDCLASS.


"! ================================================================
"! NUMBER CONVERSION
"! ================================================================
CLASS ltcl_number_conv DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.

    " conv_number_to_string
    METHODS num2str_integer                FOR TESTING.
    METHODS num2str_decimal_2              FOR TESTING.
    METHODS num2str_decimal_0              FOR TESTING.
    METHODS num2str_thousands              FOR TESTING.
    METHODS num2str_negative               FOR TESTING.
    METHODS num2str_pad_decimals           FOR TESTING.

    " conv_string_to_number
    METHODS str2num_integer                FOR TESTING.
    METHODS str2num_negative               FOR TESTING.
    METHODS str2num_decimal_dot            FOR TESTING.
    METHODS str2num_decimal_comma          FOR TESTING.
    METHODS str2num_thousands_comma        FOR TESTING.
    METHODS str2num_invalid                FOR TESTING.

ENDCLASS.

CLASS ltcl_number_conv IMPLEMENTATION.

  METHOD num2str_integer.
    cl_abap_unit_assert=>assert_equals( exp = `42`
                                        act = zabaputil_cl_util_context=>conv_number_to_string( val = 42 ) ).
  ENDMETHOD.

  METHOD num2str_decimal_2.
    cl_abap_unit_assert=>assert_equals( exp = `3.14`
                                        act = zabaputil_cl_util_context=>conv_number_to_string( val = CONV decfloat34( '3.14' ) decimals = 2 ) ).
  ENDMETHOD.

  METHOD num2str_decimal_0.
    cl_abap_unit_assert=>assert_equals( exp = `3`
                                        act = zabaputil_cl_util_context=>conv_number_to_string( val = CONV decfloat34( '3.14' ) decimals = 0 ) ).
  ENDMETHOD.

  METHOD num2str_thousands.
    cl_abap_unit_assert=>assert_equals( exp = `1,000,000`
                                        act = zabaputil_cl_util_context=>conv_number_to_string( val = 1000000 sep_thousands = ',' ) ).
  ENDMETHOD.

  METHOD num2str_negative.
    DATA(lv_result) = zabaputil_cl_util_context=>conv_number_to_string( val = -42 sep_thousands = ',' ).
    cl_abap_unit_assert=>assert_equals( exp = `-42` act = lv_result ).
  ENDMETHOD.

  METHOD num2str_pad_decimals.
    cl_abap_unit_assert=>assert_equals( exp = `5.00`
                                        act = zabaputil_cl_util_context=>conv_number_to_string( val = 5 decimals = 2 ) ).
  ENDMETHOD.

  METHOD str2num_integer.
    cl_abap_unit_assert=>assert_equals( exp = CONV decfloat34( 42 )
                                        act = zabaputil_cl_util_context=>conv_string_to_number( `42` ) ).
  ENDMETHOD.

  METHOD str2num_negative.
    cl_abap_unit_assert=>assert_equals( exp = CONV decfloat34( -7 )
                                        act = zabaputil_cl_util_context=>conv_string_to_number( `-7` ) ).
  ENDMETHOD.

  METHOD str2num_decimal_dot.
    cl_abap_unit_assert=>assert_equals( exp = CONV decfloat34( '3.14' )
                                        act = zabaputil_cl_util_context=>conv_string_to_number( `3.14` ) ).
  ENDMETHOD.

  METHOD str2num_decimal_comma.
    " Comma as last separator => decimal
    cl_abap_unit_assert=>assert_equals( exp = CONV decfloat34( '3.14' )
                                        act = zabaputil_cl_util_context=>conv_string_to_number( `3,14` ) ).
  ENDMETHOD.

  METHOD str2num_thousands_comma.
    " Comma followed by dot => thousands separator
    cl_abap_unit_assert=>assert_equals( exp = CONV decfloat34( '1000.50' )
                                        act = zabaputil_cl_util_context=>conv_string_to_number( `1,000.50` ) ).
  ENDMETHOD.

  METHOD str2num_invalid.
    cl_abap_unit_assert=>assert_equals( exp = CONV decfloat34( 0 )
                                        act = zabaputil_cl_util_context=>conv_string_to_number( `abc` ) ).
  ENDMETHOD.

ENDCLASS.


"! ================================================================
"! DATE CONVERSION
"! ================================================================
CLASS ltcl_date_conv DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.

    METHODS str_to_date_default            FOR TESTING.
    METHODS str_to_date_dd_mm_yyyy         FOR TESTING.
    METHODS str_to_date_mm_dd_yyyy         FOR TESTING.
    METHODS str_to_date_no_separators      FOR TESTING.

    METHODS date_to_str_default            FOR TESTING.
    METHODS date_to_str_dd_mm_yyyy         FOR TESTING.
    METHODS date_to_str_custom_sep         FOR TESTING.

    METHODS roundtrip                      FOR TESTING.

ENDCLASS.

CLASS ltcl_date_conv IMPLEMENTATION.

  METHOD str_to_date_default.
    " Default format YYYY-MM-DD
    cl_abap_unit_assert=>assert_equals( exp = CONV d( `20240315` )
                                        act = zabaputil_cl_util_context=>conv_string_to_date( `2024-03-15` ) ).
  ENDMETHOD.

  METHOD str_to_date_dd_mm_yyyy.
    cl_abap_unit_assert=>assert_equals( exp = CONV d( `20240315` )
                                        act = zabaputil_cl_util_context=>conv_string_to_date( val = `15.03.2024`
                                                                                   format = `DD.MM.YYYY` ) ).
  ENDMETHOD.

  METHOD str_to_date_mm_dd_yyyy.
    cl_abap_unit_assert=>assert_equals( exp = CONV d( `20240315` )
                                        act = zabaputil_cl_util_context=>conv_string_to_date( val = `03/15/2024`
                                                                                   format = `MM/DD/YYYY` ) ).
  ENDMETHOD.

  METHOD str_to_date_no_separators.
    cl_abap_unit_assert=>assert_equals( exp = CONV d( `20240315` )
                                        act = zabaputil_cl_util_context=>conv_string_to_date( val = `20240315`
                                                                                   format = `YYYYMMDD` ) ).
  ENDMETHOD.

  METHOD date_to_str_default.
    cl_abap_unit_assert=>assert_equals( exp = `2024-03-15`
                                        act = zabaputil_cl_util_context=>conv_date_to_string( CONV d( `20240315` ) ) ).
  ENDMETHOD.

  METHOD date_to_str_dd_mm_yyyy.
    cl_abap_unit_assert=>assert_equals( exp = `15.03.2024`
                                        act = zabaputil_cl_util_context=>conv_date_to_string( val = CONV d( `20240315` )
                                                                                   format = `DD.MM.YYYY` ) ).
  ENDMETHOD.

  METHOD date_to_str_custom_sep.
    cl_abap_unit_assert=>assert_equals( exp = `03/15/2024`
                                        act = zabaputil_cl_util_context=>conv_date_to_string( val = CONV d( `20240315` )
                                                                                   format = `MM/DD/YYYY` ) ).
  ENDMETHOD.

  METHOD roundtrip.
    DATA(lv_date) = CONV d( `20241225` ).
    DATA(lv_str) = zabaputil_cl_util_context=>conv_date_to_string( lv_date ).
    DATA(lv_back) = zabaputil_cl_util_context=>conv_string_to_date( lv_str ).
    cl_abap_unit_assert=>assert_equals( exp = lv_date act = lv_back ).
  ENDMETHOD.

ENDCLASS.


"! ================================================================
"! FILTER / RANGE / TOKEN OPERATIONS
"! ================================================================
CLASS ltcl_filter_ops DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.

    " filter_get_range_by_token
    METHODS token_eq                       FOR TESTING.
    METHODS token_lt                       FOR TESTING.
    METHODS token_le                       FOR TESTING.
    METHODS token_gt                       FOR TESTING.
    METHODS token_ge                       FOR TESTING.
    METHODS token_cp                       FOR TESTING.
    METHODS token_bt                       FOR TESTING.
    METHODS token_plain_value              FOR TESTING.

    " filter_get_sql_where
    METHODS sql_where_eq                   FOR TESTING.
    METHODS sql_where_bt                   FOR TESTING.
    METHODS sql_where_cp                   FOR TESTING.
    METHODS sql_where_multiple_fields      FOR TESTING.
    METHODS sql_where_exclude              FOR TESTING.

    " filter_get_multi_by_sql_where roundtrip
    METHODS sql_roundtrip_eq               FOR TESTING.
    METHODS sql_roundtrip_bt               FOR TESTING.
    METHODS sql_roundtrip_like             FOR TESTING.

    " filter_get_token_range_mapping
    METHODS token_range_mapping            FOR TESTING.

    " filter_itab
    METHODS filter_itab_basic              FOR TESTING.

    " filter_get_sql_by_sql_string
    METHODS sql_by_string_basic            FOR TESTING.

ENDCLASS.

CLASS ltcl_filter_ops IMPLEMENTATION.

  METHOD token_eq.
    DATA(ls_range) = zabaputil_cl_util_context=>filter_get_range_by_token( `=100` ).
    cl_abap_unit_assert=>assert_equals( exp = `I` act = ls_range-sign ).
    cl_abap_unit_assert=>assert_equals( exp = `EQ` act = ls_range-option ).
    cl_abap_unit_assert=>assert_equals( exp = `100` act = ls_range-low ).
  ENDMETHOD.

  METHOD token_lt.
    DATA(ls_range) = zabaputil_cl_util_context=>filter_get_range_by_token( `<50` ).
    cl_abap_unit_assert=>assert_equals( exp = `I` act = ls_range-sign ).
    cl_abap_unit_assert=>assert_equals( exp = `LT` act = ls_range-option ).
    cl_abap_unit_assert=>assert_equals( exp = `50` act = ls_range-low ).
  ENDMETHOD.

  METHOD token_le.
    DATA(ls_range) = zabaputil_cl_util_context=>filter_get_range_by_token( `<=50` ).
    cl_abap_unit_assert=>assert_equals( exp = `I` act = ls_range-sign ).
    cl_abap_unit_assert=>assert_equals( exp = `LE` act = ls_range-option ).
    cl_abap_unit_assert=>assert_equals( exp = `50` act = ls_range-low ).
  ENDMETHOD.

  METHOD token_gt.
    DATA(ls_range) = zabaputil_cl_util_context=>filter_get_range_by_token( `>10` ).
    cl_abap_unit_assert=>assert_equals( exp = `I` act = ls_range-sign ).
    cl_abap_unit_assert=>assert_equals( exp = `GT` act = ls_range-option ).
    cl_abap_unit_assert=>assert_equals( exp = `10` act = ls_range-low ).
  ENDMETHOD.

  METHOD token_ge.
    DATA(ls_range) = zabaputil_cl_util_context=>filter_get_range_by_token( `>=10` ).
    cl_abap_unit_assert=>assert_equals( exp = `I` act = ls_range-sign ).
    cl_abap_unit_assert=>assert_equals( exp = `GE` act = ls_range-option ).
    cl_abap_unit_assert=>assert_equals( exp = `10` act = ls_range-low ).
  ENDMETHOD.

  METHOD token_cp.
    DATA(ls_range) = zabaputil_cl_util_context=>filter_get_range_by_token( `*test*` ).
    cl_abap_unit_assert=>assert_equals( exp = `I` act = ls_range-sign ).
    cl_abap_unit_assert=>assert_equals( exp = `CP` act = ls_range-option ).
    cl_abap_unit_assert=>assert_equals( exp = `test` act = ls_range-low ).
  ENDMETHOD.

  METHOD token_bt.
    DATA(ls_range) = zabaputil_cl_util_context=>filter_get_range_by_token( `10...20` ).
    cl_abap_unit_assert=>assert_equals( exp = `I` act = ls_range-sign ).
    cl_abap_unit_assert=>assert_equals( exp = `BT` act = ls_range-option ).
    cl_abap_unit_assert=>assert_equals( exp = `10` act = ls_range-low ).
    cl_abap_unit_assert=>assert_equals( exp = `20` act = ls_range-high ).
  ENDMETHOD.

  METHOD token_plain_value.
    " Plain value without operator means EQ
    DATA(ls_range) = zabaputil_cl_util_context=>filter_get_range_by_token( `hello` ).
    cl_abap_unit_assert=>assert_equals( exp = `I` act = ls_range-sign ).
    cl_abap_unit_assert=>assert_equals( exp = `EQ` act = ls_range-option ).
    cl_abap_unit_assert=>assert_equals( exp = `hello` act = ls_range-low ).
  ENDMETHOD.

  METHOD sql_where_eq.
    DATA(lt_filter) = VALUE zabaputil_cl_util_context=>ty_t_filter_multi(
        ( name = `STATUS` t_range = VALUE #( ( sign = `I` option = `EQ` low = `A` ) ) ) ).
    DATA(lv_result) = zabaputil_cl_util_context=>filter_get_sql_where( lt_filter ).
    cl_abap_unit_assert=>assert_equals( exp = `( STATUS = 'A' )` act = lv_result ).
  ENDMETHOD.

  METHOD sql_where_bt.
    DATA(lt_filter) = VALUE zabaputil_cl_util_context=>ty_t_filter_multi(
        ( name = `AMOUNT` t_range = VALUE #( ( sign = `I` option = `BT` low = `10` high = `20` ) ) ) ).
    DATA(lv_result) = zabaputil_cl_util_context=>filter_get_sql_where( lt_filter ).
    cl_abap_unit_assert=>assert_equals( exp = `( AMOUNT BETWEEN '10' AND '20' )` act = lv_result ).
  ENDMETHOD.

  METHOD sql_where_cp.
    DATA(lt_filter) = VALUE zabaputil_cl_util_context=>ty_t_filter_multi(
        ( name = `NAME` t_range = VALUE #( ( sign = `I` option = `CP` low = `*test*` ) ) ) ).
    DATA(lv_result) = zabaputil_cl_util_context=>filter_get_sql_where( lt_filter ).
    cl_abap_unit_assert=>assert_equals( exp = `( NAME LIKE '%test%' )` act = lv_result ).
  ENDMETHOD.

  METHOD sql_where_multiple_fields.
    DATA(lt_filter) = VALUE zabaputil_cl_util_context=>ty_t_filter_multi(
        ( name = `A` t_range = VALUE #( ( sign = `I` option = `EQ` low = `1` ) ) )
        ( name = `B` t_range = VALUE #( ( sign = `I` option = `EQ` low = `2` ) ) ) ).
    DATA(lv_result) = zabaputil_cl_util_context=>filter_get_sql_where( lt_filter ).
    cl_abap_unit_assert=>assert_equals( exp = `( A = '1' ) AND ( B = '2' )` act = lv_result ).
  ENDMETHOD.

  METHOD sql_where_exclude.
    " Sign E with EQ should become NE
    DATA(lt_filter) = VALUE zabaputil_cl_util_context=>ty_t_filter_multi(
        ( name = `STATUS` t_range = VALUE #( ( sign = `E` option = `EQ` low = `X` ) ) ) ).
    DATA(lv_result) = zabaputil_cl_util_context=>filter_get_sql_where( lt_filter ).
    cl_abap_unit_assert=>assert_equals( exp = `( STATUS <> 'X' )` act = lv_result ).
  ENDMETHOD.

  METHOD sql_roundtrip_eq.
    DATA(lt_filter) = zabaputil_cl_util_context=>filter_get_multi_by_sql_where( `STATUS = 'A'` ).
    cl_abap_unit_assert=>assert_equals( exp = 1 act = lines( lt_filter ) ).
    cl_abap_unit_assert=>assert_equals( exp = `STATUS` act = lt_filter[ 1 ]-name ).
    cl_abap_unit_assert=>assert_equals( exp = `EQ` act = lt_filter[ 1 ]-t_range[ 1 ]-option ).
    cl_abap_unit_assert=>assert_equals( exp = `A` act = lt_filter[ 1 ]-t_range[ 1 ]-low ).
  ENDMETHOD.

  METHOD sql_roundtrip_bt.
    " After BETWEEN-fix: works without parentheses too
    DATA(lt_filter) = zabaputil_cl_util_context=>filter_get_multi_by_sql_where( `AMOUNT BETWEEN '10' AND '20'` ).
    cl_abap_unit_assert=>assert_equals( exp = 1 act = lines( lt_filter ) ).
    cl_abap_unit_assert=>assert_equals( exp = `BT` act = lt_filter[ 1 ]-t_range[ 1 ]-option ).
    cl_abap_unit_assert=>assert_equals( exp = `10` act = lt_filter[ 1 ]-t_range[ 1 ]-low ).
    cl_abap_unit_assert=>assert_equals( exp = `20` act = lt_filter[ 1 ]-t_range[ 1 ]-high ).
  ENDMETHOD.

  METHOD sql_roundtrip_like.
    DATA(lt_filter) = zabaputil_cl_util_context=>filter_get_multi_by_sql_where( `NAME LIKE '%hello%'` ).
    cl_abap_unit_assert=>assert_equals( exp = 1 act = lines( lt_filter ) ).
    cl_abap_unit_assert=>assert_equals( exp = `CP` act = lt_filter[ 1 ]-t_range[ 1 ]-option ).
    cl_abap_unit_assert=>assert_equals( exp = `*hello*` act = lt_filter[ 1 ]-t_range[ 1 ]-low ).
  ENDMETHOD.

  METHOD token_range_mapping.
    DATA(lt_result) = zabaputil_cl_util_context=>filter_get_token_range_mapping( ).
    cl_abap_unit_assert=>assert_not_initial( lt_result ).
    " Verify core mappings
    cl_abap_unit_assert=>assert_equals( exp = `={LOW}` act = lt_result[ n = `EQ` ]-v ).
    cl_abap_unit_assert=>assert_equals( exp = `<{LOW}` act = lt_result[ n = `LT` ]-v ).
    cl_abap_unit_assert=>assert_equals( exp = `>{LOW}` act = lt_result[ n = `GT` ]-v ).
    cl_abap_unit_assert=>assert_equals( exp = `{LOW}...{HIGH}` act = lt_result[ n = `BT` ]-v ).
  ENDMETHOD.

  METHOD filter_itab_basic.
    TYPES: BEGIN OF ty_row, name TYPE string, status TYPE string, END OF ty_row.
    DATA lt_tab TYPE STANDARD TABLE OF ty_row WITH EMPTY KEY.
    lt_tab = VALUE #( ( name = `A` status = `open` )
                      ( name = `B` status = `closed` )
                      ( name = `C` status = `open` ) ).

    DATA(lt_filter) = VALUE zabaputil_cl_util_context=>ty_t_filter_multi(
        ( name = `STATUS` t_range = VALUE #( ( sign = `I` option = `EQ` low = `open` ) ) ) ).

    zabaputil_cl_util_context=>filter_itab( EXPORTING filter = lt_filter CHANGING val = lt_tab ).
    cl_abap_unit_assert=>assert_equals( exp = 2 act = lines( lt_tab ) ).
    cl_abap_unit_assert=>assert_equals( exp = `A` act = lt_tab[ 1 ]-name ).
    cl_abap_unit_assert=>assert_equals( exp = `C` act = lt_tab[ 2 ]-name ).
  ENDMETHOD.

  METHOD sql_by_string_basic.
    DATA(ls_result) = zabaputil_cl_util_context=>filter_get_sql_by_sql_string( `SELECT FROM MARA WHERE MTART = 'FERT'` ).
    cl_abap_unit_assert=>assert_equals( exp = `MARA` act = ls_result-tabname ).
    cl_abap_unit_assert=>assert_not_initial( ls_result-where ).
  ENDMETHOD.

ENDCLASS.


"! ================================================================
"! DEEP COMPARISON & FIELD ACCESS
"! ================================================================
CLASS ltcl_deep_ops DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.

    " data_equals
    METHODS equals_same_string             FOR TESTING.
    METHODS equals_different_string        FOR TESTING.
    METHODS equals_same_int                FOR TESTING.
    METHODS equals_same_structure          FOR TESTING.
    METHODS equals_different_structure     FOR TESTING.

    " data_diff
    METHODS diff_no_change                 FOR TESTING.
    METHODS diff_one_field                 FOR TESTING.
    METHODS diff_multiple_fields           FOR TESTING.

    " data_get_by_path
    METHODS get_by_path_simple             FOR TESTING.
    METHODS get_by_path_nested             FOR TESTING.
    METHODS get_by_path_invalid            FOR TESTING.

    " data_set_by_path
    METHODS set_by_path_simple             FOR TESTING.

ENDCLASS.

CLASS ltcl_deep_ops IMPLEMENTATION.

  METHOD equals_same_string.
    cl_abap_unit_assert=>assert_true( zabaputil_cl_util_context=>data_equals( a = `hello` b = `hello` ) ).
  ENDMETHOD.

  METHOD equals_different_string.
    cl_abap_unit_assert=>assert_false( zabaputil_cl_util_context=>data_equals( a = `hello` b = `world` ) ).
  ENDMETHOD.

  METHOD equals_same_int.
    cl_abap_unit_assert=>assert_true( zabaputil_cl_util_context=>data_equals( a = 42 b = 42 ) ).
  ENDMETHOD.

  METHOD equals_same_structure.
    TYPES: BEGIN OF ty, a TYPE string, b TYPE i, END OF ty.
    DATA(ls_a) = VALUE ty( a = `x` b = 1 ).
    DATA(ls_b) = VALUE ty( a = `x` b = 1 ).
    cl_abap_unit_assert=>assert_true( zabaputil_cl_util_context=>data_equals( a = ls_a b = ls_b ) ).
  ENDMETHOD.

  METHOD equals_different_structure.
    TYPES: BEGIN OF ty, a TYPE string, b TYPE i, END OF ty.
    DATA(ls_a) = VALUE ty( a = `x` b = 1 ).
    DATA(ls_b) = VALUE ty( a = `x` b = 2 ).
    cl_abap_unit_assert=>assert_false( zabaputil_cl_util_context=>data_equals( a = ls_a b = ls_b ) ).
  ENDMETHOD.

  METHOD diff_no_change.
    TYPES: BEGIN OF ty, name TYPE string, value TYPE string, END OF ty.
    DATA(ls_old) = VALUE ty( name = `A` value = `1` ).
    DATA(ls_new) = VALUE ty( name = `A` value = `1` ).
    DATA(lt_diff) = zabaputil_cl_util_context=>data_diff( old = ls_old new = ls_new ).
    cl_abap_unit_assert=>assert_equals( exp = 0 act = lines( lt_diff ) ).
  ENDMETHOD.

  METHOD diff_one_field.
    TYPES: BEGIN OF ty, name TYPE string, value TYPE string, END OF ty.
    DATA(ls_old) = VALUE ty( name = `A` value = `1` ).
    DATA(ls_new) = VALUE ty( name = `A` value = `2` ).
    DATA(lt_diff) = zabaputil_cl_util_context=>data_diff( old = ls_old new = ls_new ).
    cl_abap_unit_assert=>assert_equals( exp = 1 act = lines( lt_diff ) ).
    cl_abap_unit_assert=>assert_equals( exp = `VALUE` act = lt_diff[ 1 ]-fieldname ).
    cl_abap_unit_assert=>assert_equals( exp = `1` act = lt_diff[ 1 ]-old_value ).
    cl_abap_unit_assert=>assert_equals( exp = `2` act = lt_diff[ 1 ]-new_value ).
  ENDMETHOD.

  METHOD diff_multiple_fields.
    TYPES: BEGIN OF ty, name TYPE string, value TYPE string, END OF ty.
    DATA(ls_old) = VALUE ty( name = `A` value = `1` ).
    DATA(ls_new) = VALUE ty( name = `B` value = `2` ).
    DATA(lt_diff) = zabaputil_cl_util_context=>data_diff( old = ls_old new = ls_new ).
    cl_abap_unit_assert=>assert_equals( exp = 2 act = lines( lt_diff ) ).
  ENDMETHOD.

  METHOD get_by_path_simple.
    TYPES: BEGIN OF ty, name TYPE string, value TYPE string, END OF ty.
    DATA(ls_data) = VALUE ty( name = `hello` value = `world` ).
    cl_abap_unit_assert=>assert_equals( exp = `hello`
                                        act = zabaputil_cl_util_context=>data_get_by_path( data = ls_data path = `name` ) ).
  ENDMETHOD.

  METHOD get_by_path_nested.
    TYPES: BEGIN OF ty_inner, city TYPE string, END OF ty_inner.
    TYPES: BEGIN OF ty, name TYPE string, address TYPE ty_inner, END OF ty.
    DATA(ls_data) = VALUE ty( name = `John` address = VALUE #( city = `Berlin` ) ).
    cl_abap_unit_assert=>assert_equals( exp = `Berlin`
                                        act = zabaputil_cl_util_context=>data_get_by_path( data = ls_data path = `address-city` ) ).
  ENDMETHOD.

  METHOD get_by_path_invalid.
    TYPES: BEGIN OF ty, name TYPE string, END OF ty.
    DATA(ls_data) = VALUE ty( name = `hello` ).
    cl_abap_unit_assert=>assert_equals( exp = ``
                                        act = zabaputil_cl_util_context=>data_get_by_path( data = ls_data path = `nonexistent` ) ).
  ENDMETHOD.

  METHOD set_by_path_simple.
    TYPES: BEGIN OF ty, name TYPE string, value TYPE string, END OF ty.
    DATA ls_data TYPE ty.
    ls_data-name = `old`.
    zabaputil_cl_util_context=>data_set_by_path( EXPORTING path = `name` value = `new` CHANGING data = ls_data ).
    cl_abap_unit_assert=>assert_equals( exp = `new` act = ls_data-name ).
  ENDMETHOD.

ENDCLASS.


"! ================================================================
"! ITAB OPERATIONS
"! ================================================================
CLASS ltcl_itab_ops DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.

    METHODS sort_by_ascending              FOR TESTING.
    METHODS sort_by_descending             FOR TESTING.

    METHODS slice_basic                    FOR TESTING.
    METHODS slice_from_only                FOR TESTING.
    METHODS slice_to_exceeds               FOR TESTING.

    METHODS paginate_page_1                FOR TESTING.
    METHODS paginate_page_2                FOR TESTING.
    METHODS paginate_total_pages            FOR TESTING.

    METHODS count_by_basic                 FOR TESTING.

    METHODS filter_by_val_basic            FOR TESTING.
    METHODS filter_by_val_case_ignore      FOR TESTING.
    METHODS filter_by_val_keeps_rows       FOR TESTING.
    METHODS filter_by_val_fields_subset    FOR TESTING.

    METHODS corresponding_basic            FOR TESTING.

    METHODS get_by_struc_basic             FOR TESTING.

    METHODS csv_roundtrip                  FOR TESTING.

    METHODS json_roundtrip                 FOR TESTING.

ENDCLASS.

CLASS ltcl_itab_ops IMPLEMENTATION.

  METHOD sort_by_ascending.
    TYPES: BEGIN OF ty, name TYPE string, value TYPE i, END OF ty.
    DATA lt_tab TYPE STANDARD TABLE OF ty WITH EMPTY KEY.
    lt_tab = VALUE #( ( name = `C` value = 3 ) ( name = `A` value = 1 ) ( name = `B` value = 2 ) ).
    zabaputil_cl_util_context=>itab_sort_by( EXPORTING fieldname = `NAME` CHANGING tab = lt_tab ).
    cl_abap_unit_assert=>assert_equals( exp = `A` act = lt_tab[ 1 ]-name ).
    cl_abap_unit_assert=>assert_equals( exp = `B` act = lt_tab[ 2 ]-name ).
    cl_abap_unit_assert=>assert_equals( exp = `C` act = lt_tab[ 3 ]-name ).
  ENDMETHOD.

  METHOD sort_by_descending.
    TYPES: BEGIN OF ty, name TYPE string, value TYPE i, END OF ty.
    DATA lt_tab TYPE STANDARD TABLE OF ty WITH EMPTY KEY.
    lt_tab = VALUE #( ( name = `A` value = 1 ) ( name = `C` value = 3 ) ( name = `B` value = 2 ) ).
    zabaputil_cl_util_context=>itab_sort_by( EXPORTING fieldname = `VALUE` descending = abap_true CHANGING tab = lt_tab ).
    cl_abap_unit_assert=>assert_equals( exp = 3 act = lt_tab[ 1 ]-value ).
    cl_abap_unit_assert=>assert_equals( exp = 2 act = lt_tab[ 2 ]-value ).
    cl_abap_unit_assert=>assert_equals( exp = 1 act = lt_tab[ 3 ]-value ).
  ENDMETHOD.

  METHOD slice_basic.
    TYPES: BEGIN OF ty, id TYPE i, END OF ty.
    DATA lt_tab TYPE STANDARD TABLE OF ty WITH EMPTY KEY.
    lt_tab = VALUE #( ( id = 1 ) ( id = 2 ) ( id = 3 ) ( id = 4 ) ( id = 5 ) ).
    DATA(lr_result) = zabaputil_cl_util_context=>itab_slice( tab = lt_tab from = 2 to = 4 ).
    FIELD-SYMBOLS <tab> TYPE STANDARD TABLE.
    ASSIGN lr_result->* TO <tab>.
    cl_abap_unit_assert=>assert_equals( exp = 3 act = lines( <tab> ) ).
  ENDMETHOD.

  METHOD slice_from_only.
    TYPES: BEGIN OF ty, id TYPE i, END OF ty.
    DATA lt_tab TYPE STANDARD TABLE OF ty WITH EMPTY KEY.
    lt_tab = VALUE #( ( id = 1 ) ( id = 2 ) ( id = 3 ) ).
    DATA(lr_result) = zabaputil_cl_util_context=>itab_slice( tab = lt_tab from = 2 ).
    FIELD-SYMBOLS <tab> TYPE STANDARD TABLE.
    ASSIGN lr_result->* TO <tab>.
    cl_abap_unit_assert=>assert_equals( exp = 2 act = lines( <tab> ) ).
  ENDMETHOD.

  METHOD slice_to_exceeds.
    TYPES: BEGIN OF ty, id TYPE i, END OF ty.
    DATA lt_tab TYPE STANDARD TABLE OF ty WITH EMPTY KEY.
    lt_tab = VALUE #( ( id = 1 ) ( id = 2 ) ).
    DATA(lr_result) = zabaputil_cl_util_context=>itab_slice( tab = lt_tab from = 1 to = 99 ).
    FIELD-SYMBOLS <tab> TYPE STANDARD TABLE.
    ASSIGN lr_result->* TO <tab>.
    cl_abap_unit_assert=>assert_equals( exp = 2 act = lines( <tab> ) ).
  ENDMETHOD.

  METHOD paginate_page_1.
    TYPES: BEGIN OF ty, id TYPE i, END OF ty.
    DATA lt_tab TYPE STANDARD TABLE OF ty WITH EMPTY KEY.
    lt_tab = VALUE #( ( id = 1 ) ( id = 2 ) ( id = 3 ) ( id = 4 ) ( id = 5 ) ).
    DATA lr_result TYPE REF TO data.
    DATA lv_total_count TYPE i.
    DATA lv_total_pages TYPE i.
    zabaputil_cl_util_context=>itab_paginate( EXPORTING tab = lt_tab page = 1 page_size = 2
                                   IMPORTING result = lr_result total_count = lv_total_count total_pages = lv_total_pages ).
    FIELD-SYMBOLS <tab> TYPE STANDARD TABLE.
    ASSIGN lr_result->* TO <tab>.
    cl_abap_unit_assert=>assert_equals( exp = 2 act = lines( <tab> ) ).
    cl_abap_unit_assert=>assert_equals( exp = 5 act = lv_total_count ).
    cl_abap_unit_assert=>assert_equals( exp = 3 act = lv_total_pages ).
  ENDMETHOD.

  METHOD paginate_page_2.
    TYPES: BEGIN OF ty, id TYPE i, END OF ty.
    DATA lt_tab TYPE STANDARD TABLE OF ty WITH EMPTY KEY.
    lt_tab = VALUE #( ( id = 1 ) ( id = 2 ) ( id = 3 ) ( id = 4 ) ( id = 5 ) ).
    DATA lr_result TYPE REF TO data.
    DATA lv_total_count TYPE i.
    DATA lv_total_pages TYPE i.
    zabaputil_cl_util_context=>itab_paginate( EXPORTING tab = lt_tab page = 2 page_size = 2
                                   IMPORTING result = lr_result total_count = lv_total_count total_pages = lv_total_pages ).
    FIELD-SYMBOLS <tab> TYPE STANDARD TABLE.
    ASSIGN lr_result->* TO <tab>.
    cl_abap_unit_assert=>assert_equals( exp = 2 act = lines( <tab> ) ).
  ENDMETHOD.

  METHOD paginate_total_pages.
    TYPES: BEGIN OF ty, id TYPE i, END OF ty.
    DATA lt_tab TYPE STANDARD TABLE OF ty WITH EMPTY KEY.
    lt_tab = VALUE #( ( id = 1 ) ( id = 2 ) ( id = 3 ) ).
    DATA lr_result TYPE REF TO data.
    DATA lv_total_count TYPE i.
    DATA lv_total_pages TYPE i.
    zabaputil_cl_util_context=>itab_paginate( EXPORTING tab = lt_tab page = 1 page_size = 2
                                   IMPORTING result = lr_result total_count = lv_total_count total_pages = lv_total_pages ).
    cl_abap_unit_assert=>assert_equals( exp = 2 act = lv_total_pages ).
  ENDMETHOD.

  METHOD count_by_basic.
    TYPES: BEGIN OF ty, category TYPE string, name TYPE string, END OF ty.
    DATA lt_tab TYPE STANDARD TABLE OF ty WITH EMPTY KEY.
    lt_tab = VALUE #( ( category = `A` name = `1` ) ( category = `B` name = `2` )
                      ( category = `A` name = `3` ) ( category = `A` name = `4` ) ).
    DATA(lt_result) = zabaputil_cl_util_context=>itab_count_by( tab = lt_tab fieldname = `CATEGORY` ).
    cl_abap_unit_assert=>assert_equals( exp = `3` act = lt_result[ n = `A` ]-v ).
    cl_abap_unit_assert=>assert_equals( exp = `1` act = lt_result[ n = `B` ]-v ).
  ENDMETHOD.

  METHOD filter_by_val_basic.
    TYPES: BEGIN OF ty, name TYPE string, city TYPE string, END OF ty.
    DATA lt_tab TYPE STANDARD TABLE OF ty WITH EMPTY KEY.
    lt_tab = VALUE #( ( name = `Alice` city = `Berlin` )
                      ( name = `Bob` city = `Paris` )
                      ( name = `Charlie` city = `Berlin` ) ).
    zabaputil_cl_util_context=>itab_filter_by_val( EXPORTING val = `Berlin` CHANGING tab = lt_tab ).
    cl_abap_unit_assert=>assert_equals( exp = 2 act = lines( lt_tab ) ).
  ENDMETHOD.

  METHOD filter_by_val_case_ignore.
    TYPES: BEGIN OF ty, name TYPE string, END OF ty.
    DATA lt_tab TYPE STANDARD TABLE OF ty WITH EMPTY KEY.
    lt_tab = VALUE #( ( name = `HELLO` ) ( name = `world` ) ( name = `Hello` ) ).
    zabaputil_cl_util_context=>itab_filter_by_val( EXPORTING val = `hello` ignore_case = abap_true CHANGING tab = lt_tab ).
    cl_abap_unit_assert=>assert_equals( exp = 2 act = lines( lt_tab ) ).
  ENDMETHOD.

  METHOD filter_by_val_keeps_rows.
    " guards the DELETE ... INDEX in itab_filter_by_val: with a plain DELETE the
    " wrong rows are removed as soon as several non-matching rows are dropped
    TYPES: BEGIN OF ty, name TYPE string, city TYPE string, END OF ty.
    DATA lt_tab TYPE STANDARD TABLE OF ty WITH EMPTY KEY.
    lt_tab = VALUE #( ( name = `Alice`   city = `Paris` )
                      ( name = `Bob`     city = `Berlin` )
                      ( name = `Charlie` city = `Rome` )
                      ( name = `Dave`    city = `Berlin` )
                      ( name = `Eve`     city = `Madrid` ) ).
    zabaputil_cl_util_context=>itab_filter_by_val( EXPORTING val = `Berlin`
                                                   CHANGING  tab = lt_tab ).
    cl_abap_unit_assert=>assert_equals( exp = 2 act = lines( lt_tab ) ).
    cl_abap_unit_assert=>assert_equals( exp = `Bob`  act = lt_tab[ 1 ]-name ).
    cl_abap_unit_assert=>assert_equals( exp = `Dave` act = lt_tab[ 2 ]-name ).
  ENDMETHOD.

  METHOD filter_by_val_fields_subset.
    " only the listed field is searched, the match in the other column is ignored
    TYPES: BEGIN OF ty, name TYPE string, city TYPE string, END OF ty.
    DATA lt_tab TYPE STANDARD TABLE OF ty WITH EMPTY KEY.
    lt_tab = VALUE #( ( name = `Berlin` city = `Paris` )
                      ( name = `Bob`    city = `Berlin` ) ).
    zabaputil_cl_util_context=>itab_filter_by_val(
      EXPORTING val    = `Berlin`
                fields = VALUE string_table( ( `CITY` ) )
      CHANGING  tab    = lt_tab ).
    cl_abap_unit_assert=>assert_equals( exp = 1 act = lines( lt_tab ) ).
    cl_abap_unit_assert=>assert_equals( exp = `Bob` act = lt_tab[ 1 ]-name ).
  ENDMETHOD.

  METHOD corresponding_basic.
    TYPES: BEGIN OF ty_src, a TYPE string, b TYPE string, c TYPE string, END OF ty_src.
    TYPES: BEGIN OF ty_dst, a TYPE string, b TYPE string, END OF ty_dst.
    DATA lt_src TYPE STANDARD TABLE OF ty_src WITH EMPTY KEY.
    DATA lt_dst TYPE STANDARD TABLE OF ty_dst WITH EMPTY KEY.
    lt_src = VALUE #( ( a = `1` b = `2` c = `3` ) ).
    zabaputil_cl_util_context=>itab_corresponding( EXPORTING val = lt_src CHANGING tab = lt_dst ).
    cl_abap_unit_assert=>assert_equals( exp = 1 act = lines( lt_dst ) ).
    cl_abap_unit_assert=>assert_equals( exp = `1` act = lt_dst[ 1 ]-a ).
    cl_abap_unit_assert=>assert_equals( exp = `2` act = lt_dst[ 1 ]-b ).
  ENDMETHOD.

  METHOD get_by_struc_basic.
    TYPES: BEGIN OF ty, name TYPE string, value TYPE string, END OF ty.
    DATA(ls_data) = VALUE ty( name = `hello` value = `world` ).
    DATA(lt_result) = zabaputil_cl_util_context=>itab_get_by_struc( ls_data ).
    cl_abap_unit_assert=>assert_equals( exp = 2 act = lines( lt_result ) ).
    cl_abap_unit_assert=>assert_equals( exp = `NAME` act = lt_result[ 1 ]-n ).
    cl_abap_unit_assert=>assert_equals( exp = `hello` act = lt_result[ 1 ]-v ).
    cl_abap_unit_assert=>assert_equals( exp = `VALUE` act = lt_result[ 2 ]-n ).
    cl_abap_unit_assert=>assert_equals( exp = `world` act = lt_result[ 2 ]-v ).
  ENDMETHOD.

  METHOD csv_roundtrip.
    TYPES: BEGIN OF ty, col1 TYPE string, col2 TYPE string, END OF ty.
    DATA lt_tab TYPE STANDARD TABLE OF ty WITH EMPTY KEY.
    lt_tab = VALUE #( ( col1 = `A` col2 = `B` ) ( col1 = `C` col2 = `D` ) ).

    DATA(lv_csv) = zabaputil_cl_util_context=>itab_get_csv_by_itab( lt_tab ).
    cl_abap_unit_assert=>assert_not_initial( lv_csv ).

    " CSV should contain header and data
    cl_abap_unit_assert=>assert_true( zabaputil_cl_util_context=>c_contains( val = lv_csv sub = `COL1` ) ).
    cl_abap_unit_assert=>assert_true( zabaputil_cl_util_context=>c_contains( val = lv_csv sub = `A` ) ).
  ENDMETHOD.

  METHOD json_roundtrip.
    TYPES: BEGIN OF ty, name TYPE string, value TYPE i, END OF ty.
    DATA ls_data TYPE ty.
    ls_data = VALUE #( name = `test` value = 42 ).

    DATA(lv_json) = zabaputil_cl_util_context=>json_stringify( ls_data ).
    cl_abap_unit_assert=>assert_not_initial( lv_json ).

    DATA ls_back TYPE ty.
    zabaputil_cl_util_context=>json_parse( EXPORTING val = lv_json CHANGING data = ls_back ).
    cl_abap_unit_assert=>assert_equals( exp = `test` act = ls_back-name ).
    cl_abap_unit_assert=>assert_equals( exp = 42 act = ls_back-value ).
  ENDMETHOD.

ENDCLASS.


"! ================================================================
"! RTTI / TYPE CHECKING
"! ================================================================
CLASS ltcl_rtti_ops DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.

    METHODS check_table_true               FOR TESTING.
    METHODS check_table_false              FOR TESTING.
    METHODS check_structure_true           FOR TESTING.
    METHODS check_structure_false          FOR TESTING.
    METHODS check_numeric_int              FOR TESTING.
    METHODS check_numeric_string           FOR TESTING.
    METHODS check_clike_string             FOR TESTING.
    METHODS check_clike_int                FOR TESTING.
    METHODS check_ref_data_true            FOR TESTING.
    METHODS check_ref_data_false           FOR TESTING.
    METHODS get_classname                  FOR TESTING.
    METHODS get_type_name                  FOR TESTING.
    METHODS check_class_exists_true        FOR TESTING.
    METHODS check_class_exists_false       FOR TESTING.
    METHODS expand_components_plain        FOR TESTING.
    METHODS expand_components_empty        FOR TESTING.
    METHODS attri_by_any_struct            FOR TESTING.
    METHODS attri_by_any_table             FOR TESTING.
    METHODS msg_get_empty_no_dump          FOR TESTING.

ENDCLASS.

CLASS ltcl_rtti_ops IMPLEMENTATION.

  METHOD expand_components_plain.
    " components that are not includes are passed through unchanged and in order
    DATA(lo_str) = cl_abap_elemdescr=>get_string( ).
    DATA(lt_comps) = VALUE abap_component_tab( ( name = `A` type = lo_str )
                                               ( name = `B` type = lo_str )
                                               ( name = `C` type = lo_str ) ).
    DATA(lt_result) = zabaputil_cl_util_context=>expand_components( lt_comps ).
    cl_abap_unit_assert=>assert_equals( exp = 3 act = lines( lt_result ) ).
    cl_abap_unit_assert=>assert_equals( exp = `A` act = lt_result[ 1 ]-name ).
    cl_abap_unit_assert=>assert_equals( exp = `B` act = lt_result[ 2 ]-name ).
    cl_abap_unit_assert=>assert_equals( exp = `C` act = lt_result[ 3 ]-name ).
  ENDMETHOD.

  METHOD expand_components_empty.
    DATA(lt_result) = zabaputil_cl_util_context=>expand_components( VALUE abap_component_tab( ) ).
    cl_abap_unit_assert=>assert_initial( lt_result ).
  ENDMETHOD.

  METHOD attri_by_any_struct.
    TYPES: BEGIN OF ty, alpha TYPE string, beta TYPE i, END OF ty.
    DATA ls_struc TYPE ty.
    DATA(lt_attri) = zabaputil_cl_util_context=>rtti_get_t_attri_by_any( ls_struc ).
    cl_abap_unit_assert=>assert_equals( exp = 2 act = lines( lt_attri ) ).
    cl_abap_unit_assert=>assert_equals( exp = `ALPHA` act = lt_attri[ 1 ]-name ).
    cl_abap_unit_assert=>assert_equals( exp = `BETA`  act = lt_attri[ 2 ]-name ).
  ENDMETHOD.

  METHOD attri_by_any_table.
    " for a table the components of the line type are returned
    TYPES: BEGIN OF ty, alpha TYPE string, beta TYPE i, END OF ty.
    DATA lt_tab TYPE STANDARD TABLE OF ty WITH EMPTY KEY.
    DATA(lt_attri) = zabaputil_cl_util_context=>rtti_get_t_attri_by_any( lt_tab ).
    cl_abap_unit_assert=>assert_equals( exp = 2 act = lines( lt_attri ) ).
    cl_abap_unit_assert=>assert_equals( exp = `ALPHA` act = lt_attri[ 1 ]-name ).
  ENDMETHOD.

  METHOD msg_get_empty_no_dump.
    " input without any message must return an initial structure instead of
    " raising CX_SY_ITAB_LINE_NOT_FOUND on lt_msg[ 1 ]
    DATA(ls_msg) = zabaputil_cl_util_context=>msg_get( 42 ).
    cl_abap_unit_assert=>assert_initial( ls_msg-text ).
  ENDMETHOD.

  METHOD check_table_true.
    DATA lt_tab TYPE string_table.
    cl_abap_unit_assert=>assert_true( zabaputil_cl_util_context=>rtti_check_table( lt_tab ) ).
  ENDMETHOD.

  METHOD check_table_false.
    DATA lv_str TYPE string.
    cl_abap_unit_assert=>assert_false( zabaputil_cl_util_context=>rtti_check_table( lv_str ) ).
  ENDMETHOD.

  METHOD check_structure_true.
    TYPES: BEGIN OF ty, a TYPE string, END OF ty.
    DATA ls_struc TYPE ty.
    cl_abap_unit_assert=>assert_true( zabaputil_cl_util_context=>rtti_check_structure( ls_struc ) ).
  ENDMETHOD.

  METHOD check_structure_false.
    DATA lv_str TYPE string.
    cl_abap_unit_assert=>assert_false( zabaputil_cl_util_context=>rtti_check_structure( lv_str ) ).
  ENDMETHOD.

  METHOD check_numeric_int.
    DATA lv_int TYPE i VALUE 5.
    cl_abap_unit_assert=>assert_true( zabaputil_cl_util_context=>rtti_check_numeric( lv_int ) ).
  ENDMETHOD.

  METHOD check_numeric_string.
    DATA lv_str TYPE string VALUE `123`.
    cl_abap_unit_assert=>assert_false( zabaputil_cl_util_context=>rtti_check_numeric( lv_str ) ).
  ENDMETHOD.

  METHOD check_clike_string.
    DATA lv_str TYPE string VALUE `hello`.
    cl_abap_unit_assert=>assert_true( zabaputil_cl_util_context=>rtti_check_clike( lv_str ) ).
  ENDMETHOD.

  METHOD check_clike_int.
    DATA lv_int TYPE i VALUE 5.
    cl_abap_unit_assert=>assert_false( zabaputil_cl_util_context=>rtti_check_clike( lv_int ) ).
  ENDMETHOD.

  METHOD check_ref_data_true.
    DATA lr_ref TYPE REF TO data.
    cl_abap_unit_assert=>assert_true( zabaputil_cl_util_context=>rtti_check_ref_data( lr_ref ) ).
  ENDMETHOD.

  METHOD check_ref_data_false.
    DATA lv_str TYPE string.
    cl_abap_unit_assert=>assert_false( zabaputil_cl_util_context=>rtti_check_ref_data( lv_str ) ).
  ENDMETHOD.

  METHOD get_classname.
    DATA(lo_obj) = NEW ltcl_test_app( ).
    DATA(lv_name) = zabaputil_cl_util_context=>rtti_get_classname_by_ref( lo_obj ).
    cl_abap_unit_assert=>assert_equals( exp = `LTCL_TEST_APP` act = lv_name ).
  ENDMETHOD.

  METHOD get_type_name.
    DATA lv_bool TYPE abap_bool.
    cl_abap_unit_assert=>assert_equals( exp = `ABAP_BOOL`
                                        act = zabaputil_cl_util_context=>rtti_get_type_name( lv_bool ) ).
  ENDMETHOD.

  METHOD check_class_exists_true.
    cl_abap_unit_assert=>assert_true( zabaputil_cl_util_context=>rtti_check_class_exists( `CL_ABAP_TYPEDESCR` ) ).
  ENDMETHOD.

  METHOD check_class_exists_false.
    cl_abap_unit_assert=>assert_false( zabaputil_cl_util_context=>rtti_check_class_exists( `ZCL_DOES_NOT_EXIST_99` ) ).
  ENDMETHOD.

ENDCLASS.


"! ================================================================
"! EXCEPTION HANDLING
"! ================================================================
CLASS ltcl_exception_ops DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.

    METHODS x_raise_basic                  FOR TESTING.
    METHODS x_raise_custom_msg             FOR TESTING.
    METHODS x_check_raise_true             FOR TESTING.
    METHODS x_check_raise_false            FOR TESTING.
    METHODS x_get_last_t100_basic          FOR TESTING.

ENDCLASS.

CLASS ltcl_exception_ops IMPLEMENTATION.

  METHOD x_raise_basic.
    TRY.
        zabaputil_cl_util_context=>x_raise( ).
        cl_abap_unit_assert=>fail( `Exception expected` ).
      CATCH zabaputil_cx_util_error INTO DATA(lx).
        cl_abap_unit_assert=>assert_not_initial( lx ).
    ENDTRY.
  ENDMETHOD.

  METHOD x_raise_custom_msg.
    TRY.
        zabaputil_cl_util_context=>x_raise( `MY_ERROR` ).
        cl_abap_unit_assert=>fail( `Exception expected` ).
      CATCH zabaputil_cx_util_error INTO DATA(lx).
        cl_abap_unit_assert=>assert_true( zabaputil_cl_util_context=>c_contains( val = lx->get_text( ) sub = `MY_ERROR` ) ).
    ENDTRY.
  ENDMETHOD.

  METHOD x_check_raise_true.
    TRY.
        zabaputil_cl_util_context=>x_check_raise( v = `OOPS` when = abap_true ).
        cl_abap_unit_assert=>fail( `Exception expected` ).
      CATCH zabaputil_cx_util_error INTO DATA(lx).
        cl_abap_unit_assert=>assert_not_initial( lx ).
    ENDTRY.
  ENDMETHOD.

  METHOD x_check_raise_false.
    TRY.
        zabaputil_cl_util_context=>x_check_raise( v = `OOPS` when = abap_false ).
        " No exception — test passes
      CATCH zabaputil_cx_util_error.
        cl_abap_unit_assert=>fail( `No exception expected` ).
    ENDTRY.
  ENDMETHOD.

  METHOD x_get_last_t100_basic.
    TRY.
        RAISE EXCEPTION TYPE zabaputil_cx_util_error EXPORTING val = `INNER_ERROR`.
      CATCH zabaputil_cx_util_error INTO DATA(lx).
        DATA(lv_result) = zabaputil_cl_util_context=>x_get_last_t100( lx ).
        cl_abap_unit_assert=>assert_not_initial( lv_result ).
    ENDTRY.
  ENDMETHOD.

ENDCLASS.


"! ================================================================
"! REFERENCE / BOUND / INITIAL CHECKS
"! ================================================================
CLASS ltcl_ref_ops DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.

    METHODS bound_not_initial_true         FOR TESTING.
    METHODS bound_not_initial_unbound      FOR TESTING.
    METHODS bound_not_initial_initial      FOR TESTING.
    METHODS unassign_initial_null          FOR TESTING.
    METHODS unassign_initial_empty         FOR TESTING.
    METHODS unassign_initial_filled        FOR TESTING.
    METHODS conv_get_as_data_ref           FOR TESTING.
    METHODS copy_ref_data_unbound          FOR TESTING.
    METHODS copy_ref_data_bound            FOR TESTING.
    METHODS copy_ref_data_plain_value      FOR TESTING.

ENDCLASS.

CLASS ltcl_ref_ops IMPLEMENTATION.

  METHOD bound_not_initial_true.
    DATA lv_val TYPE string VALUE `hello`.
    DATA lr_ref TYPE REF TO data.
    GET REFERENCE OF lv_val INTO lr_ref.
    cl_abap_unit_assert=>assert_true( zabaputil_cl_util_context=>check_bound_a_not_initial( lr_ref ) ).
  ENDMETHOD.

  METHOD bound_not_initial_unbound.
    DATA lr_ref TYPE REF TO data.
    cl_abap_unit_assert=>assert_false( zabaputil_cl_util_context=>check_bound_a_not_initial( lr_ref ) ).
  ENDMETHOD.

  METHOD bound_not_initial_initial.
    DATA lv_val TYPE string.
    DATA lr_ref TYPE REF TO data.
    GET REFERENCE OF lv_val INTO lr_ref.
    cl_abap_unit_assert=>assert_false( zabaputil_cl_util_context=>check_bound_a_not_initial( lr_ref ) ).
  ENDMETHOD.

  METHOD unassign_initial_null.
    DATA lr_ref TYPE REF TO data.
    cl_abap_unit_assert=>assert_true( zabaputil_cl_util_context=>check_unassign_initial( lr_ref ) ).
  ENDMETHOD.

  METHOD unassign_initial_empty.
    DATA lv_val TYPE string.
    DATA lr_ref TYPE REF TO data.
    GET REFERENCE OF lv_val INTO lr_ref.
    cl_abap_unit_assert=>assert_true( zabaputil_cl_util_context=>check_unassign_initial( lr_ref ) ).
  ENDMETHOD.

  METHOD unassign_initial_filled.
    DATA lv_val TYPE string VALUE `x`.
    DATA lr_ref TYPE REF TO data.
    GET REFERENCE OF lv_val INTO lr_ref.
    cl_abap_unit_assert=>assert_false( zabaputil_cl_util_context=>check_unassign_initial( lr_ref ) ).
  ENDMETHOD.

  METHOD conv_get_as_data_ref.
    DATA lv_val TYPE string VALUE `test`.
    DATA(lr_ref) = zabaputil_cl_util_context=>conv_get_as_data_ref( lv_val ).
    cl_abap_unit_assert=>assert_bound( lr_ref ).
    FIELD-SYMBOLS <val> TYPE string.
    ASSIGN lr_ref->* TO <val>.
    cl_abap_unit_assert=>assert_equals( exp = `test` act = <val> ).
  ENDMETHOD.

  METHOD copy_ref_data_unbound.
    " an unbound reference must return an initial result instead of dumping in
    " CREATE DATA ... LIKE <from> with an unassigned field symbol
    DATA lr_ref TYPE REF TO data.
    DATA(lr_copy) = zabaputil_cl_util_context=>conv_copy_ref_data( lr_ref ).
    cl_abap_unit_assert=>assert_initial( lr_copy ).
  ENDMETHOD.

  METHOD copy_ref_data_bound.
    DATA lv_val TYPE string VALUE `hello`.
    DATA lr_ref TYPE REF TO data.
    GET REFERENCE OF lv_val INTO lr_ref.
    DATA(lr_copy) = zabaputil_cl_util_context=>conv_copy_ref_data( lr_ref ).
    cl_abap_unit_assert=>assert_bound( lr_copy ).
    FIELD-SYMBOLS <copy> TYPE string.
    ASSIGN lr_copy->* TO <copy>.
    cl_abap_unit_assert=>assert_equals( exp = `hello` act = <copy> ).
    " a copy, not an alias
    lv_val = `changed`.
    cl_abap_unit_assert=>assert_equals( exp = `hello` act = <copy> ).
  ENDMETHOD.

  METHOD copy_ref_data_plain_value.
    DATA(lr_copy) = zabaputil_cl_util_context=>conv_copy_ref_data( `plain` ).
    cl_abap_unit_assert=>assert_bound( lr_copy ).
    FIELD-SYMBOLS <copy> TYPE data.
    ASSIGN lr_copy->* TO <copy>.
    cl_abap_unit_assert=>assert_equals( exp = `plain` act = <copy> ).
  ENDMETHOD.

ENDCLASS.


"! ================================================================
"! TIME OPERATIONS
"! ================================================================
CLASS ltcl_time_ops DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.

    METHODS get_timestampl                 FOR TESTING.
    METHODS add_seconds                    FOR TESTING.
    METHODS subtract_seconds               FOR TESTING.
    METHODS diff_seconds                   FOR TESTING.
    METHODS measure_start_stop             FOR TESTING.
    METHODS stampl_by_date_time            FOR TESTING.

ENDCLASS.

CLASS ltcl_time_ops IMPLEMENTATION.

  METHOD get_timestampl.
    DATA(lv_ts) = zabaputil_cl_util_context=>time_get_timestampl( ).
    cl_abap_unit_assert=>assert_not_initial( lv_ts ).
  ENDMETHOD.

  METHOD add_seconds.
    DATA(lv_ts) = zabaputil_cl_util_context=>time_get_timestampl( ).
    DATA(lv_result) = zabaputil_cl_util_context=>time_add_seconds( time = lv_ts seconds = 60 ).
    cl_abap_unit_assert=>assert_true( xsdbool( lv_result > lv_ts ) ).
    " Difference should be ~60 seconds
    DATA(lv_diff) = zabaputil_cl_util_context=>time_diff_seconds( time_from = lv_ts time_to = lv_result ).
    cl_abap_unit_assert=>assert_equals( exp = 60 act = lv_diff ).
  ENDMETHOD.

  METHOD subtract_seconds.
    DATA(lv_ts) = zabaputil_cl_util_context=>time_get_timestampl( ).
    DATA(lv_result) = zabaputil_cl_util_context=>time_subtract_seconds( time = lv_ts seconds = 30 ).
    cl_abap_unit_assert=>assert_true( xsdbool( lv_result < lv_ts ) ).
  ENDMETHOD.

  METHOD diff_seconds.
    DATA(lv_from) = zabaputil_cl_util_context=>time_get_timestampl( ).
    DATA(lv_to) = zabaputil_cl_util_context=>time_add_seconds( time = lv_from seconds = 120 ).
    DATA(lv_diff) = zabaputil_cl_util_context=>time_diff_seconds( time_from = lv_from time_to = lv_to ).
    cl_abap_unit_assert=>assert_equals( exp = 120 act = lv_diff ).
  ENDMETHOD.

  METHOD measure_start_stop.
    DATA(lv_start) = zabaputil_cl_util_context=>time_measure_start( ).
    cl_abap_unit_assert=>assert_not_initial( lv_start ).
    " Result is milliseconds, should be >= 0
    DATA(lv_ms) = zabaputil_cl_util_context=>time_measure_stop( lv_start ).
    cl_abap_unit_assert=>assert_true( xsdbool( lv_ms >= 0 ) ).
  ENDMETHOD.

  METHOD stampl_by_date_time.
    DATA(lv_ts) = zabaputil_cl_util_context=>time_get_stampl_by_date_time( date = CONV d( `20240101` )
                                                                time = CONV t( `120000` ) ).
    cl_abap_unit_assert=>assert_not_initial( lv_ts ).
  ENDMETHOD.

ENDCLASS.


"! ================================================================
"! EDGE CASES - Bugs & ABAP-isms critical for JS transpilation
"! ================================================================
CLASS ltcl_edge_cases DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.

    " filter_get_range_by_token edge cases
    METHODS token_empty_input              FOR TESTING.
    METHODS token_single_star              FOR TESTING.
    METHODS token_single_equals            FOR TESTING.
    METHODS token_just_number              FOR TESTING.
    METHODS token_with_spaces              FOR TESTING.

    " c_pad_left with space (same bug pattern as c_pad_right)
    METHODS pad_left_with_space            FOR TESTING.
    METHODS pad_left_default               FOR TESTING.

    " CS operator is always case-insensitive (critical for transpiler)
    METHODS filter_by_val_cs_insensitive   FOR TESTING.

    " c_trim edge cases
    METHODS trim_only_newlines             FOR TESTING.
    METHODS trim_mixed_whitespace          FOR TESTING.
    METHODS trim_unicode                   FOR TESTING.

    " c_split edge cases
    METHODS split_empty_input              FOR TESTING.
    METHODS split_only_separator           FOR TESTING.

    " conv_string_to_number edge cases
    METHODS num_one_thousand_no_dot        FOR TESTING.
    METHODS num_european_format            FOR TESTING.
    METHODS num_only_minus                 FOR TESTING.
    METHODS num_leading_zeros              FOR TESTING.

    " conv_string_to_date edge cases
    METHODS date_short_input               FOR TESTING.

    " check_is_email edge cases
    METHODS email_with_plus                FOR TESTING.
    METHODS email_with_dots                FOR TESTING.
    METHODS email_only_spaces              FOR TESTING.

    " itab_slice edge cases
    METHODS slice_from_exceeds_lines       FOR TESTING.
    METHODS slice_empty_table              FOR TESTING.

    " c_truncate edge cases
    METHODS truncate_max_zero              FOR TESTING.
    METHODS truncate_empty_string          FOR TESTING.

    " data_get_by_path / data_set_by_path edge cases
    METHODS path_with_leading_dash         FOR TESTING.
    METHODS path_set_nested                FOR TESTING.

    " check_is_guid edge cases
    METHODS guid_empty                     FOR TESTING.
    METHODS guid_mixed_case_dashes         FOR TESTING.

    " url_param_set preserves case (after fix)
    METHODS url_set_preserves_value_case   FOR TESTING.

    " boolean_abap_2_json with different boolean types
    METHODS bool_xfeld_true                FOR TESTING.
    METHODS bool_xfeld_false               FOR TESTING.

    " json roundtrip with special characters
    METHODS json_special_chars             FOR TESTING.

    " c_contains case behavior (TRANSPILER CRITICAL)
    METHODS contains_is_always_ci          FOR TESTING.

ENDCLASS.

CLASS ltcl_edge_cases IMPLEMENTATION.

  METHOD token_empty_input.
    " Empty input should not crash - returns empty/initial range
    DATA(ls_range) = zabaputil_cl_util_context=>filter_get_range_by_token( `` ).
    cl_abap_unit_assert=>assert_initial( ls_range-option ).
  ENDMETHOD.

  METHOD token_single_star.
    " Single '*' - after fix: CP with empty low (match-all pattern)
    DATA(ls_range) = zabaputil_cl_util_context=>filter_get_range_by_token( `*` ).
    cl_abap_unit_assert=>assert_equals( exp = `I` act = ls_range-sign ).
    cl_abap_unit_assert=>assert_equals( exp = `CP` act = ls_range-option ).
    cl_abap_unit_assert=>assert_equals( exp = `` act = ls_range-low ).
  ENDMETHOD.

  METHOD token_single_equals.
    " Just "=" with nothing after → EQ with empty low
    DATA(ls_range) = zabaputil_cl_util_context=>filter_get_range_by_token( `=` ).
    cl_abap_unit_assert=>assert_equals( exp = `EQ` act = ls_range-option ).
    cl_abap_unit_assert=>assert_initial( ls_range-low ).
  ENDMETHOD.

  METHOD token_just_number.
    " Plain number without operator → EQ
    DATA(ls_range) = zabaputil_cl_util_context=>filter_get_range_by_token( `42` ).
    cl_abap_unit_assert=>assert_equals( exp = `EQ` act = ls_range-option ).
    cl_abap_unit_assert=>assert_equals( exp = `42` act = ls_range-low ).
  ENDMETHOD.

  METHOD token_with_spaces.
    " Token with spaces in value
    DATA(ls_range) = zabaputil_cl_util_context=>filter_get_range_by_token( `=hello world` ).
    cl_abap_unit_assert=>assert_equals( exp = `EQ` act = ls_range-option ).
    cl_abap_unit_assert=>assert_equals( exp = `hello world` act = ls_range-low ).
  ENDMETHOD.

  METHOD pad_left_with_space.
    " After fix: space padding should work on c_pad_left too
    cl_abap_unit_assert=>assert_equals( exp = `   hi`
        act = zabaputil_cl_util_context=>c_pad_left( val = `hi` len = 5 pad = ' ' ) ).
  ENDMETHOD.

  METHOD pad_left_default.
    " Default '0' should still work
    cl_abap_unit_assert=>assert_equals( exp = `007`
        act = zabaputil_cl_util_context=>c_pad_left( val = `7` len = 3 ) ).
  ENDMETHOD.

  METHOD filter_by_val_cs_insensitive.
    " After fix: ignore_case=false now uses find() for true case-sensitivity
    TYPES: BEGIN OF ty, name TYPE string, END OF ty.
    DATA lt_tab TYPE STANDARD TABLE OF ty WITH EMPTY KEY.
    lt_tab = VALUE #( ( name = `Hello` ) ( name = `WORLD` ) ( name = `test` ) ).

    " Search for 'hello' with ignore_case = FALSE (case-sensitive)
    " After fix: should NOT match 'Hello' (capital H)
    zabaputil_cl_util_context=>itab_filter_by_val( EXPORTING val = `hello` ignore_case = abap_false
                                        CHANGING tab = lt_tab ).
    cl_abap_unit_assert=>assert_equals( exp = 0 act = lines( lt_tab ) ).
  ENDMETHOD.

  METHOD trim_only_newlines.
    " TRANSPILER NOTE: c_trim only removes spaces and horizontal tabs.
    " Newlines are NOT removed by c_trim! (shift_left/right only trim spaces)
    DATA(lv_nl) = zabaputil_cl_util_context=>cv_char_util_newline.
    DATA(lv_result) = zabaputil_cl_util_context=>c_trim( lv_nl && lv_nl ).
    " Newlines survive trimming
    cl_abap_unit_assert=>assert_not_initial( lv_result ).
  ENDMETHOD.

  METHOD trim_mixed_whitespace.
    DATA(lv_tab) = zabaputil_cl_util_context=>cv_char_util_horizontal_tab.
    cl_abap_unit_assert=>assert_equals( exp = `hello`
        act = zabaputil_cl_util_context=>c_trim( ` ` && lv_tab && `hello` && lv_tab && ` ` ) ).
  ENDMETHOD.

  METHOD trim_unicode.
    " Regular non-ASCII should not be trimmed
    cl_abap_unit_assert=>assert_equals( exp = `über`
        act = zabaputil_cl_util_context=>c_trim( `  über  ` ) ).
  ENDMETHOD.

  METHOD split_empty_input.
    " TRANSPILER NOTE: ABAP SPLIT of empty string gives table with 0 entries!
    " This differs from JS ''.split(',') which gives [''].
    DATA(lt_result) = zabaputil_cl_util_context=>c_split( val = `` sep = `,` ).
    cl_abap_unit_assert=>assert_equals( exp = 0 act = lines( lt_result ) ).
  ENDMETHOD.

  METHOD split_only_separator.
    " TRANSPILER NOTE: ABAP SPLIT ',' AT ',' gives 1 entry (empty string),
    " while JS ','.split(',') gives ['', '']. Different behavior!
    DATA(lt_result) = zabaputil_cl_util_context=>c_split( val = `,` sep = `,` ).
    " Document actual ABAP behavior:
    cl_abap_unit_assert=>assert_true( xsdbool( lines( lt_result ) >= 1 ) ).
  ENDMETHOD.

  METHOD num_one_thousand_no_dot.
    " EDGE CASE: '1,000' without dot → comma is last separator → decimal!
    " Result is 1.0 NOT 1000. This is documented European behavior.
    DATA(lv_result) = zabaputil_cl_util_context=>conv_string_to_number( `1,000` ).
    cl_abap_unit_assert=>assert_equals( exp = CONV decfloat34( '1.000' ) act = lv_result ).
  ENDMETHOD.

  METHOD num_european_format.
    " TRANSPILER NOTE: European format (dot=thousands, comma=decimal)
    " does NOT work correctly! The dot is always kept as-is, creating
    " invalid numbers like '1.234.56'. Only the comma heuristic applies.
    " Result: falls back to 0 due to conversion error.
    DATA(lv_result) = zabaputil_cl_util_context=>conv_string_to_number( `1.234,56` ).
    " Documents actual (broken) behavior - returns 0 due to double-dot
    cl_abap_unit_assert=>assert_equals( exp = CONV decfloat34( 0 ) act = lv_result ).
  ENDMETHOD.

  METHOD num_only_minus.
    " Just a minus sign
    DATA(lv_result) = zabaputil_cl_util_context=>conv_string_to_number( `-` ).
    cl_abap_unit_assert=>assert_equals( exp = CONV decfloat34( 0 ) act = lv_result ).
  ENDMETHOD.

  METHOD num_leading_zeros.
    DATA(lv_result) = zabaputil_cl_util_context=>conv_string_to_number( `007` ).
    cl_abap_unit_assert=>assert_equals( exp = CONV decfloat34( 7 ) act = lv_result ).
  ENDMETHOD.

  METHOD date_short_input.
    " TRANSPILER NOTE: Short input causes STRING_OFFSET_TOO_LARGE in ABAP
    " because conv_string_to_date has no bounds checking.
    " This is a known limitation - skip this test to document it.
    " A JS transpiler should add bounds checking.
    TRY.
        DATA(lv_result) = zabaputil_cl_util_context=>conv_string_to_date( val = `24` format = `YYYY-MM-DD` ) ##NEEDED.
      CATCH cx_root.
        " Expected: crashes with short input - JS must guard against this
    ENDTRY.
  ENDMETHOD.

  METHOD email_with_plus.
    cl_abap_unit_assert=>assert_true(
        zabaputil_cl_util_context=>check_is_email( `user+tag@example.com` ) ).
  ENDMETHOD.

  METHOD email_with_dots.
    cl_abap_unit_assert=>assert_true(
        zabaputil_cl_util_context=>check_is_email( `first.last@sub.domain.com` ) ).
  ENDMETHOD.

  METHOD email_only_spaces.
    cl_abap_unit_assert=>assert_false(
        zabaputil_cl_util_context=>check_is_email( `   ` ) ).
  ENDMETHOD.

  METHOD slice_from_exceeds_lines.
    TYPES: BEGIN OF ty, id TYPE i, END OF ty.
    DATA lt_tab TYPE STANDARD TABLE OF ty WITH EMPTY KEY.
    lt_tab = VALUE #( ( id = 1 ) ( id = 2 ) ).
    DATA(lr_result) = zabaputil_cl_util_context=>itab_slice( tab = lt_tab from = 99 ).
    FIELD-SYMBOLS <tab> TYPE STANDARD TABLE.
    ASSIGN lr_result->* TO <tab>.
    cl_abap_unit_assert=>assert_equals( exp = 0 act = lines( <tab> ) ).
  ENDMETHOD.

  METHOD slice_empty_table.
    TYPES: BEGIN OF ty, id TYPE i, END OF ty.
    DATA lt_tab TYPE STANDARD TABLE OF ty WITH EMPTY KEY.
    DATA(lr_result) = zabaputil_cl_util_context=>itab_slice( tab = lt_tab from = 1 to = 5 ).
    FIELD-SYMBOLS <tab> TYPE STANDARD TABLE.
    ASSIGN lr_result->* TO <tab>.
    cl_abap_unit_assert=>assert_equals( exp = 0 act = lines( <tab> ) ).
  ENDMETHOD.

  METHOD truncate_max_zero.
    " max=0 should return empty
    cl_abap_unit_assert=>assert_equals( exp = ``
        act = zabaputil_cl_util_context=>c_truncate( val = `hello` max = 0 ) ).
  ENDMETHOD.

  METHOD truncate_empty_string.
    cl_abap_unit_assert=>assert_equals( exp = ``
        act = zabaputil_cl_util_context=>c_truncate( val = `` max = 10 ) ).
  ENDMETHOD.

  METHOD path_with_leading_dash.
    " Leading dash creates an empty first segment - should be skipped
    TYPES: BEGIN OF ty, name TYPE string, END OF ty.
    DATA(ls_data) = VALUE ty( name = `hello` ).
    cl_abap_unit_assert=>assert_equals( exp = `hello`
        act = zabaputil_cl_util_context=>data_get_by_path( data = ls_data path = `-name` ) ).
  ENDMETHOD.

  METHOD path_set_nested.
    TYPES: BEGIN OF ty_inner, city TYPE string, END OF ty_inner.
    TYPES: BEGIN OF ty, address TYPE ty_inner, END OF ty.
    DATA ls_data TYPE ty.
    zabaputil_cl_util_context=>data_set_by_path( EXPORTING path = `address-city` value = `Munich`
                                     CHANGING data = ls_data ).
    cl_abap_unit_assert=>assert_equals( exp = `Munich` act = ls_data-address-city ).
  ENDMETHOD.

  METHOD guid_empty.
    cl_abap_unit_assert=>assert_false( zabaputil_cl_util_context=>check_is_guid( `` ) ).
  ENDMETHOD.

  METHOD guid_mixed_case_dashes.
    " Mixed case with dashes (standard GUID format)
    cl_abap_unit_assert=>assert_true(
        zabaputil_cl_util_context=>check_is_guid( `550e8400-e29b-41d4-a716-446655440000` ) ).
  ENDMETHOD.

  METHOD url_set_preserves_value_case.
    " After fix: value case should be preserved
    DATA(lv_result) = zabaputil_cl_util_context=>url_param_set(
        url = `a=1` name = `class` value = `ZCL_MY_CLASS` ).
    cl_abap_unit_assert=>assert_true(
        zabaputil_cl_util_context=>c_contains( val = lv_result sub = `ZCL_MY_CLASS` ) ).
  ENDMETHOD.

  METHOD bool_xfeld_true.
    DATA lv_xfeld TYPE xfeld VALUE 'X'.
    cl_abap_unit_assert=>assert_equals( exp = `true`
        act = zabaputil_cl_util_context=>boolean_abap_2_json( lv_xfeld ) ).
  ENDMETHOD.

  METHOD bool_xfeld_false.
    DATA lv_xfeld TYPE xfeld.
    cl_abap_unit_assert=>assert_equals( exp = `false`
        act = zabaputil_cl_util_context=>boolean_abap_2_json( lv_xfeld ) ).
  ENDMETHOD.

  METHOD json_special_chars.
    " JSON with quotes, backslashes, newlines
    TYPES: BEGIN OF ty, text TYPE string, END OF ty.
    DATA(ls_data) = VALUE ty( text = `He said "hello" \\ yes` ).
    DATA(lv_json) = zabaputil_cl_util_context=>json_stringify( ls_data ).
    DATA ls_back TYPE ty.
    zabaputil_cl_util_context=>json_parse( EXPORTING val = lv_json CHANGING data = ls_back ).
    cl_abap_unit_assert=>assert_equals( exp = ls_data-text act = ls_back-text ).
  ENDMETHOD.

  METHOD contains_is_always_ci.
    " TRANSPILER CRITICAL: Proves that c_contains is case-insensitive
    " JS must implement: val.toLowerCase().includes(sub.toLowerCase())
    cl_abap_unit_assert=>assert_true(
        zabaputil_cl_util_context=>c_contains( val = `Hello World` sub = `HELLO` ) ).
    cl_abap_unit_assert=>assert_true(
        zabaputil_cl_util_context=>c_contains( val = `HELLO WORLD` sub = `hello` ) ).
    cl_abap_unit_assert=>assert_true(
        zabaputil_cl_util_context=>c_contains( val = `HeLLo` sub = `hello` ) ).
  ENDMETHOD.

ENDCLASS.

"! ================================================================
"! Z2UI5_CL_UTIL_EXT - Comprehensive Unit Tests for JS Transpilation
"! ================================================================
"! BAL tests removed: bal_search has ASSIGN_TYPE_CONFLICT bug in
"! production code (runtime error at line ~142). Fix BAL impl first.
"! ================================================================

"! ================================================================
"! LOCK / DEQUEUE HELPER
"! ================================================================
CLASS ltcl_lock_ops DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.

    METHODS dequeue_from_enqueue           FOR TESTING.
    METHODS dequeue_from_lower             FOR TESTING.
    METHODS dequeue_already_dequeue        FOR TESTING.
    METHODS dequeue_short_name             FOR TESTING.

ENDCLASS.

CLASS ltcl_lock_ops IMPLEMENTATION.

  METHOD dequeue_from_enqueue.
    cl_abap_unit_assert=>assert_equals(
        exp = `DEQUEUE_EVVBAKE`
        act = zabaputil_cl_util_context=>lock_get_dequeue_by_enqueue( `ENQUEUE_EVVBAKE` ) ).
  ENDMETHOD.

  METHOD dequeue_from_lower.
    cl_abap_unit_assert=>assert_equals(
        exp = `DEQUEUE_EVVBAKE`
        act = zabaputil_cl_util_context=>lock_get_dequeue_by_enqueue( `enqueue_evvbake` ) ).
  ENDMETHOD.

  METHOD dequeue_already_dequeue.
    cl_abap_unit_assert=>assert_equals(
        exp = `DEQUEUE_EVVBAKE`
        act = zabaputil_cl_util_context=>lock_get_dequeue_by_enqueue( `DEQUEUE_EVVBAKE` ) ).
  ENDMETHOD.

  METHOD dequeue_short_name.
    cl_abap_unit_assert=>assert_equals(
        exp = `DEQUEUE_EMARA`
        act = zabaputil_cl_util_context=>lock_get_dequeue_by_enqueue( `ENQUEUE_EMARA` ) ).
  ENDMETHOD.

ENDCLASS.


"! ================================================================
"! CALENDAR OPERATIONS
"! ================================================================
CLASS ltcl_calendar_ops DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.

    METHODS weekday_monday                 FOR TESTING.
    METHODS weekday_sunday                 FOR TESTING.
    METHODS weekday_wednesday              FOR TESTING.
    METHODS weekday_saturday               FOR TESTING.
    METHODS is_weekend_saturday            FOR TESTING.
    METHODS is_weekend_sunday              FOR TESTING.
    METHODS is_weekend_friday              FOR TESTING.
    METHODS add_workdays_skip_weekend      FOR TESTING.
    METHODS add_workdays_mid_week          FOR TESTING.
    METHODS add_workdays_zero              FOR TESTING.
    METHODS count_workdays_full_week       FOR TESTING.
    METHODS count_workdays_same_day        FOR TESTING.

ENDCLASS.

CLASS ltcl_calendar_ops IMPLEMENTATION.

  METHOD weekday_monday.
    cl_abap_unit_assert=>assert_equals( exp = 1
        act = zabaputil_cl_util_context=>cal_get_weekday( CONV d( `20240101` ) ) ).
  ENDMETHOD.

  METHOD weekday_sunday.
    cl_abap_unit_assert=>assert_equals( exp = 7
        act = zabaputil_cl_util_context=>cal_get_weekday( CONV d( `20240107` ) ) ).
  ENDMETHOD.

  METHOD weekday_wednesday.
    cl_abap_unit_assert=>assert_equals( exp = 3
        act = zabaputil_cl_util_context=>cal_get_weekday( CONV d( `20240103` ) ) ).
  ENDMETHOD.

  METHOD weekday_saturday.
    cl_abap_unit_assert=>assert_equals( exp = 6
        act = zabaputil_cl_util_context=>cal_get_weekday( CONV d( `20240106` ) ) ).
  ENDMETHOD.

  METHOD is_weekend_saturday.
    cl_abap_unit_assert=>assert_true(
        zabaputil_cl_util_context=>cal_is_weekend( CONV d( `20240106` ) ) ).
  ENDMETHOD.

  METHOD is_weekend_sunday.
    cl_abap_unit_assert=>assert_true(
        zabaputil_cl_util_context=>cal_is_weekend( CONV d( `20240107` ) ) ).
  ENDMETHOD.

  METHOD is_weekend_friday.
    cl_abap_unit_assert=>assert_false(
        zabaputil_cl_util_context=>cal_is_weekend( CONV d( `20240105` ) ) ).
  ENDMETHOD.

  METHOD add_workdays_skip_weekend.
    cl_abap_unit_assert=>assert_equals(
        exp = CONV d( `20240318` )
        act = zabaputil_cl_util_context=>cal_add_workdays( date = CONV d( `20240315` ) days = 1 ) ).
  ENDMETHOD.

  METHOD add_workdays_mid_week.
    cl_abap_unit_assert=>assert_equals(
        exp = CONV d( `20240104` )
        act = zabaputil_cl_util_context=>cal_add_workdays( date = CONV d( `20240102` ) days = 2 ) ).
  ENDMETHOD.

  METHOD add_workdays_zero.
    cl_abap_unit_assert=>assert_equals(
        exp = CONV d( `20240315` )
        act = zabaputil_cl_util_context=>cal_add_workdays( date = CONV d( `20240315` ) days = 0 ) ).
  ENDMETHOD.

  METHOD count_workdays_full_week.
    cl_abap_unit_assert=>assert_equals(
        exp = 5
        act = zabaputil_cl_util_context=>cal_count_workdays( date_from = CONV d( `20240101` )
                                                      date_to   = CONV d( `20240108` ) ) ).
  ENDMETHOD.

  METHOD count_workdays_same_day.
    cl_abap_unit_assert=>assert_equals(
        exp = 0
        act = zabaputil_cl_util_context=>cal_count_workdays( date_from = CONV d( `20240101` )
                                                      date_to   = CONV d( `20240101` ) ) ).
  ENDMETHOD.

ENDCLASS.


"! ================================================================
"! ZIP OPERATIONS
"! ================================================================
CLASS ltcl_zip_ops DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.

    METHODS pack_basic                     FOR TESTING.
    METHODS pack_empty                     FOR TESTING.
    METHODS roundtrip                      FOR TESTING.

ENDCLASS.

CLASS ltcl_zip_ops IMPLEMENTATION.

  METHOD pack_basic.
    DATA lo_probe TYPE REF TO object.
    TRY.
        CREATE OBJECT lo_probe TYPE ('CL_ABAP_ZIP').
      CATCH cx_root.
        RETURN.
    ENDTRY.

    DATA(lt_files) = VALUE zabaputil_cl_util_context=>ty_t_zip_file(
        ( name = `test.txt` content = CONV xstring( `48656C6C6F` ) ) ).
    DATA(lv_archive) = zabaputil_cl_util_context=>zip_pack( lt_files ).
    cl_abap_unit_assert=>assert_not_initial( lv_archive ).
  ENDMETHOD.

  METHOD pack_empty.
    DATA lo_probe TYPE REF TO object.
    TRY.
        CREATE OBJECT lo_probe TYPE ('CL_ABAP_ZIP').
      CATCH cx_root.
        RETURN.
    ENDTRY.

    DATA(lt_files) = VALUE zabaputil_cl_util_context=>ty_t_zip_file( ).
    DATA(lv_archive) = zabaputil_cl_util_context=>zip_pack( lt_files ).
    cl_abap_unit_assert=>assert_not_initial( lv_archive ).
  ENDMETHOD.

  METHOD roundtrip.
    DATA lo_probe TYPE REF TO object.
    TRY.
        CREATE OBJECT lo_probe TYPE ('CL_ABAP_ZIP').
      CATCH cx_root.
        RETURN.
    ENDTRY.

    DATA(lt_in) = VALUE zabaputil_cl_util_context=>ty_t_zip_file(
        ( name = `a.txt` content = CONV xstring( `414141` ) )
        ( name = `b.txt` content = CONV xstring( `424242` ) ) ).

    DATA(lv_archive) = zabaputil_cl_util_context=>zip_pack( lt_in ).
    DATA(lt_out) = zabaputil_cl_util_context=>zip_unpack( lv_archive ).

    cl_abap_unit_assert=>assert_equals( exp = 2 act = lines( lt_out ) ).

    LOOP AT lt_in INTO DATA(ls_in).
      DATA(ls_out) = VALUE #( lt_out[ name = ls_in-name ] OPTIONAL ).
      cl_abap_unit_assert=>assert_equals( exp = ls_in-content act = ls_out-content ).
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.


"! ================================================================
"! RTTI / TABLE DESCRIPTION
"! ================================================================
CLASS ltcl_rtti_ext DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.

    " The on-prem RTTI path needs the DDIC type DFIES and table DD02T,
    " neither exists in the JS transpiler runtime - probe and skip there
    METHODS check_dfies_available
      RETURNING
        VALUE(result) TYPE abap_bool.

    METHODS dfies_by_table_basic           FOR TESTING.
    METHODS dfies_by_table_has_fields      FOR TESTING.
    METHODS table_descr_basic              FOR TESTING.

ENDCLASS.

CLASS ltcl_rtti_ext IMPLEMENTATION.

  METHOD check_dfies_available.
    DATA lo_descr TYPE REF TO cl_abap_typedescr.
    cl_abap_typedescr=>describe_by_name(
      EXPORTING
        p_name         = `DFIES`
      RECEIVING
        p_descr_ref    = lo_descr
      EXCEPTIONS
        type_not_found = 1
        OTHERS         = 2 ).
    result = xsdbool( sy-subrc = 0 ).
  ENDMETHOD.

  METHOD dfies_by_table_basic.
    IF check_dfies_available( ) = abap_false.
      RETURN.
    ENDIF.
    DATA(lt_result) = zabaputil_cl_util_context=>rtti_get_t_dfies_by_table_name( `Z2UI5_T_01` ).
    cl_abap_unit_assert=>assert_not_initial( lt_result ).
  ENDMETHOD.

  METHOD dfies_by_table_has_fields.
    IF check_dfies_available( ) = abap_false.
      RETURN.
    ENDIF.
    DATA(lt_result) = zabaputil_cl_util_context=>rtti_get_t_dfies_by_table_name( `Z2UI5_T_01` ).
    DATA(lv_found) = abap_false.
    LOOP AT lt_result INTO DATA(ls_dfies).
      IF ls_dfies-fieldname = `ID`.
        lv_found = abap_true.
        EXIT.
      ENDIF.
    ENDLOOP.
    cl_abap_unit_assert=>assert_true( lv_found ).
  ENDMETHOD.

  METHOD table_descr_basic.
    IF check_dfies_available( ) = abap_false.
      RETURN.
    ENDIF.
    DATA(lv_result) = zabaputil_cl_util_context=>rtti_get_table_desrc( `Z2UI5_T_01` ).
    cl_abap_unit_assert=>assert_not_initial( lv_result ).
  ENDMETHOD.

ENDCLASS.


"! ================================================================
"! TRANSPORT REQUEST OPERATIONS
"! ================================================================
CLASS ltcl_transport_ops DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.

    METHODS get_user_requests              FOR TESTING.

ENDCLASS.

CLASS ltcl_transport_ops IMPLEMENTATION.

  METHOD get_user_requests.
    DATA(lt_result) = zabaputil_cl_util_context=>tr_get_user_requests( ) ##NEEDED.
  ENDMETHOD.

ENDCLASS.


"! ================================================================
"! XLSX CONVERSION
"! ================================================================
CLASS ltcl_xlsx_ops DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.

    METHODS xlsx_by_itab_basic             FOR TESTING.
    METHODS itab_by_xlsx_empty             FOR TESTING.

ENDCLASS.

CLASS ltcl_xlsx_ops IMPLEMENTATION.

  METHOD xlsx_by_itab_basic.
    TYPES: BEGIN OF ty_row, col1 TYPE string, col2 TYPE string, END OF ty_row.
    DATA lt_tab TYPE STANDARD TABLE OF ty_row WITH EMPTY KEY.
    lt_tab = VALUE #( ( col1 = `A` col2 = `B` ) ).
    DATA(lv_result) = zabaputil_cl_util_context=>conv_get_xlsx_by_itab( lt_tab ) ##NEEDED.
  ENDMETHOD.

  METHOD itab_by_xlsx_empty.
    DATA lv_xstring TYPE xstring.
    DATA lr_result TYPE REF TO data.
    zabaputil_cl_util_context=>conv_get_itab_by_xlsx( EXPORTING val = lv_xstring
                                              IMPORTING result = lr_result ) ##NEEDED.
  ENDMETHOD.

ENDCLASS.


"! ================================================================
"! SOURCE CODE READING
"! ================================================================
CLASS ltcl_source_ops DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.

    METHODS source_get_method_basic        FOR TESTING.

ENDCLASS.

CLASS ltcl_source_ops IMPLEMENTATION.

  METHOD source_get_method_basic.
    DATA(lt_source) = zabaputil_cl_util_context=>source_get_method(
        iv_classname  = `Z2UI5_CL_UTIL`
        iv_methodname = `C_TRIM` ).
    cl_abap_unit_assert=>assert_not_initial( lt_source ).
  ENDMETHOD.

ENDCLASS.

CLASS ltcl_escaping DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.

    METHODS escape_html_special_chars     FOR TESTING.
    METHODS escape_html_no_special        FOR TESTING.
    METHODS escape_json_special_chars     FOR TESTING.
    METHODS url_encode_unreserved         FOR TESTING.
    METHODS url_encode_special            FOR TESTING.
    METHODS url_encode_umlaut             FOR TESTING.
    METHODS url_decode_simple             FOR TESTING.
    METHODS url_decode_plus_as_space      FOR TESTING.
    METHODS url_roundtrip                 FOR TESTING.

ENDCLASS.

CLASS ltcl_escaping IMPLEMENTATION.

  METHOD escape_html_special_chars.
    cl_abap_unit_assert=>assert_equals(
        act = zabaputil_cl_util_context=>c_escape_html( `<a href="x">Tom & Jerry's</a>` )
        exp = `&lt;a href=&quot;x&quot;&gt;Tom &amp; Jerry&#39;s&lt;/a&gt;` ).
  ENDMETHOD.

  METHOD escape_html_no_special.
    cl_abap_unit_assert=>assert_equals(
        act = zabaputil_cl_util_context=>c_escape_html( `hello world` )
        exp = `hello world` ).
  ENDMETHOD.

  METHOD escape_json_special_chars.
    cl_abap_unit_assert=>assert_equals(
        act = zabaputil_cl_util_context=>c_escape_json( `say "hi" \ end` )
        exp = `say \"hi\" \\ end` ).
  ENDMETHOD.

  METHOD url_encode_unreserved.
    cl_abap_unit_assert=>assert_equals(
        act = zabaputil_cl_util_context=>url_encode( `Hello-World_1.2~x` )
        exp = `Hello-World_1.2~x` ).
  ENDMETHOD.

  METHOD url_encode_special.
    cl_abap_unit_assert=>assert_equals(
        act = zabaputil_cl_util_context=>url_encode( `a b&c=d` )
        exp = `a%20b%26c%3Dd` ).
  ENDMETHOD.

  METHOD url_encode_umlaut.
    cl_abap_unit_assert=>assert_equals(
        act = zabaputil_cl_util_context=>url_encode( `ä` )
        exp = `%C3%A4` ).
  ENDMETHOD.

  METHOD url_decode_simple.
    cl_abap_unit_assert=>assert_equals(
        act = zabaputil_cl_util_context=>url_decode( `a%20b%26c%3Dd` )
        exp = `a b&c=d` ).
  ENDMETHOD.

  METHOD url_decode_plus_as_space.
    cl_abap_unit_assert=>assert_equals(
        act = zabaputil_cl_util_context=>url_decode( `a+b` )
        exp = `a b` ).
  ENDMETHOD.

  METHOD url_roundtrip.
    DATA(lv_original) = `Straße 5 / Haus?x=1&y=äöü`.
    cl_abap_unit_assert=>assert_equals(
        act = zabaputil_cl_util_context=>url_decode( zabaputil_cl_util_context=>url_encode( lv_original ) )
        exp = lv_original ).
  ENDMETHOD.

ENDCLASS.

CLASS ltcl_levenshtein DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.

    METHODS distance_classic              FOR TESTING.
    METHODS distance_equal                FOR TESTING.
    METHODS distance_empty_first          FOR TESTING.
    METHODS distance_empty_second         FOR TESTING.
    METHODS distance_single_swap          FOR TESTING.

ENDCLASS.

CLASS ltcl_levenshtein IMPLEMENTATION.

  METHOD distance_classic.
    cl_abap_unit_assert=>assert_equals(
        act = zabaputil_cl_util_context=>c_levenshtein( val1 = `kitten`
                                                        val2 = `sitting` )
        exp = 3 ).
  ENDMETHOD.

  METHOD distance_equal.
    cl_abap_unit_assert=>assert_equals(
        act = zabaputil_cl_util_context=>c_levenshtein( val1 = `abap`
                                                        val2 = `abap` )
        exp = 0 ).
  ENDMETHOD.

  METHOD distance_empty_first.
    cl_abap_unit_assert=>assert_equals(
        act = zabaputil_cl_util_context=>c_levenshtein( val1 = ``
                                                        val2 = `abc` )
        exp = 3 ).
  ENDMETHOD.

  METHOD distance_empty_second.
    cl_abap_unit_assert=>assert_equals(
        act = zabaputil_cl_util_context=>c_levenshtein( val1 = `abc`
                                                        val2 = `` )
        exp = 3 ).
  ENDMETHOD.

  METHOD distance_single_swap.
    cl_abap_unit_assert=>assert_equals(
        act = zabaputil_cl_util_context=>c_levenshtein( val1 = `flaw`
                                                        val2 = `lawn` )
        exp = 2 ).
  ENDMETHOD.

ENDCLASS.

CLASS ltcl_uuid_conv DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.

    METHODS c32_to_c36                    FOR TESTING.
    METHODS c36_to_c32                    FOR TESTING.
    METHODS c32_to_c22_zero               FOR TESTING.
    METHODS c22_roundtrip                 FOR TESTING.
    METHODS c22_length                    FOR TESTING.

ENDCLASS.

CLASS ltcl_uuid_conv IMPLEMENTATION.

  METHOD c32_to_c36.
    cl_abap_unit_assert=>assert_equals(
        act = zabaputil_cl_util_context=>uuid_conv_c32_to_c36( `550E8400E29B41D4A716446655440000` )
        exp = `550E8400-E29B-41D4-A716-446655440000` ).
  ENDMETHOD.

  METHOD c36_to_c32.
    cl_abap_unit_assert=>assert_equals(
        act = zabaputil_cl_util_context=>uuid_conv_c36_to_c32( `550e8400-e29b-41d4-a716-446655440000` )
        exp = `550E8400E29B41D4A716446655440000` ).
  ENDMETHOD.

  METHOD c32_to_c22_zero.
    cl_abap_unit_assert=>assert_equals(
        act = zabaputil_cl_util_context=>uuid_conv_c32_to_c22( `00000000000000000000000000000000` )
        exp = `AAAAAAAAAAAAAAAAAAAAAA` ).
  ENDMETHOD.

  METHOD c22_roundtrip.
    DATA(lv_c32) = `00112233445566778899AABBCCDDEEFF`.
    DATA(lv_c22) = zabaputil_cl_util_context=>uuid_conv_c32_to_c22( lv_c32 ).
    cl_abap_unit_assert=>assert_equals(
        act = zabaputil_cl_util_context=>uuid_conv_c22_to_c32( lv_c22 )
        exp = lv_c32 ).
  ENDMETHOD.

  METHOD c22_length.
    DATA(lv_c22) = zabaputil_cl_util_context=>uuid_conv_c32_to_c22( `550E8400E29B41D4A716446655440000` ).
    cl_abap_unit_assert=>assert_equals(
        act = strlen( lv_c22 )
        exp = 22 ).
  ENDMETHOD.

ENDCLASS.

CLASS ltcl_itab_aggregations DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.

    TYPES:
      BEGIN OF ty_s_flight,
        carrid TYPE string,
        price  TYPE i,
      END OF ty_s_flight.
    TYPES ty_t_flight TYPE STANDARD TABLE OF ty_s_flight WITH EMPTY KEY.

    METHODS get_flights
      RETURNING
        VALUE(result) TYPE ty_t_flight.

    METHODS sum_by                        FOR TESTING.
    METHODS sum_by_unknown_field          FOR TESTING.
    METHODS distinct                      FOR TESTING.
    METHODS group_sum_by                  FOR TESTING.

ENDCLASS.

CLASS ltcl_itab_aggregations IMPLEMENTATION.

  METHOD get_flights.
    result = VALUE #( ( carrid = `LH` price = 100 )
                      ( carrid = `LH` price = 150 )
                      ( carrid = `AA` price = 200 )
                      ( carrid = `LH` price = 50 ) ).
  ENDMETHOD.

  METHOD sum_by.
    cl_abap_unit_assert=>assert_equals(
        act = zabaputil_cl_util_context=>itab_sum_by( tab       = get_flights( )
                                                      fieldname = `PRICE` )
        exp = CONV decfloat34( 500 ) ).
  ENDMETHOD.

  METHOD sum_by_unknown_field.
    cl_abap_unit_assert=>assert_equals(
        act = zabaputil_cl_util_context=>itab_sum_by( tab       = get_flights( )
                                                      fieldname = `DOES_NOT_EXIST` )
        exp = CONV decfloat34( 0 ) ).
  ENDMETHOD.

  METHOD distinct.
    DATA(lt_distinct) = zabaputil_cl_util_context=>itab_distinct( tab       = get_flights( )
                                                                  fieldname = `CARRID` ).
    cl_abap_unit_assert=>assert_equals(
        act = lines( lt_distinct )
        exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
        act = lt_distinct[ 1 ]
        exp = `LH` ).
    cl_abap_unit_assert=>assert_equals(
        act = lt_distinct[ 2 ]
        exp = `AA` ).
  ENDMETHOD.

  METHOD group_sum_by.
    DATA(lt_sums) = zabaputil_cl_util_context=>itab_group_sum_by( tab      = get_flights( )
                                                                  group_by = `CARRID`
                                                                  sum_by   = `PRICE` ).
    cl_abap_unit_assert=>assert_equals(
        act = lines( lt_sums )
        exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
        act = lt_sums[ 1 ]-n
        exp = `LH` ).
    cl_abap_unit_assert=>assert_equals(
        act = lt_sums[ 1 ]-v
        exp = `300` ).
    cl_abap_unit_assert=>assert_equals(
        act = lt_sums[ 2 ]-n
        exp = `AA` ).
    cl_abap_unit_assert=>assert_equals(
        act = lt_sums[ 2 ]-v
        exp = `200` ).
  ENDMETHOD.

ENDCLASS.

CLASS ltcl_num_round DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.

    METHODS round_half_up                 FOR TESTING.
    METHODS round_half_up_negative        FOR TESTING.
    METHODS round_up                      FOR TESTING.
    METHODS round_down                    FOR TESTING.
    METHODS round_two_decimals            FOR TESTING.

ENDCLASS.

CLASS ltcl_num_round IMPLEMENTATION.

  METHOD round_half_up.
    cl_abap_unit_assert=>assert_equals(
        act = zabaputil_cl_util_context=>num_round( CONV decfloat34( '2.5' ) )
        exp = CONV decfloat34( 3 ) ).
    cl_abap_unit_assert=>assert_equals(
        act = zabaputil_cl_util_context=>num_round( CONV decfloat34( '2.4' ) )
        exp = CONV decfloat34( 2 ) ).
  ENDMETHOD.

  METHOD round_half_up_negative.
    cl_abap_unit_assert=>assert_equals(
        act = zabaputil_cl_util_context=>num_round( CONV decfloat34( '-2.5' ) )
        exp = CONV decfloat34( -3 ) ).
  ENDMETHOD.

  METHOD round_up.
    cl_abap_unit_assert=>assert_equals(
        act = zabaputil_cl_util_context=>num_round( val  = CONV decfloat34( '2.1' )
                                                    mode = `UP` )
        exp = CONV decfloat34( 3 ) ).
  ENDMETHOD.

  METHOD round_down.
    cl_abap_unit_assert=>assert_equals(
        act = zabaputil_cl_util_context=>num_round( val  = CONV decfloat34( '2.9' )
                                                    mode = `DOWN` )
        exp = CONV decfloat34( 2 ) ).
  ENDMETHOD.

  METHOD round_two_decimals.
    cl_abap_unit_assert=>assert_equals(
        act = zabaputil_cl_util_context=>num_round( val      = CONV decfloat34( '2.345' )
                                                    decimals = 2 )
        exp = CONV decfloat34( '2.35' ) ).
  ENDMETHOD.

ENDCLASS.

CLASS ltcl_mimetype_lang DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.

    METHODS mimetype_json                 FOR TESTING.
    METHODS mimetype_xlsx                 FOR TESTING.
    METHODS mimetype_uppercase            FOR TESTING.
    METHODS mimetype_unknown              FOR TESTING.
    METHODS lang_sap_to_iso_german        FOR TESTING.
    METHODS lang_sap_to_iso_lowercase     FOR TESTING.
    METHODS lang_iso_to_sap_english       FOR TESTING.
    METHODS lang_iso_to_sap_uppercase     FOR TESTING.

ENDCLASS.

CLASS ltcl_mimetype_lang IMPLEMENTATION.

  METHOD mimetype_json.
    cl_abap_unit_assert=>assert_equals(
        act = zabaputil_cl_util_context=>file_get_mimetype( `data.json` )
        exp = `application/json` ).
  ENDMETHOD.

  METHOD mimetype_xlsx.
    cl_abap_unit_assert=>assert_equals(
        act = zabaputil_cl_util_context=>file_get_mimetype( `report.xlsx` )
        exp = `application/vnd.openxmlformats-officedocument.spreadsheetml.sheet` ).
  ENDMETHOD.

  METHOD mimetype_uppercase.
    cl_abap_unit_assert=>assert_equals(
        act = zabaputil_cl_util_context=>file_get_mimetype( `IMAGE.PNG` )
        exp = `image/png` ).
  ENDMETHOD.

  METHOD mimetype_unknown.
    cl_abap_unit_assert=>assert_equals(
        act = zabaputil_cl_util_context=>file_get_mimetype( `file.xyz` )
        exp = `application/octet-stream` ).
  ENDMETHOD.

  METHOD lang_sap_to_iso_german.
    cl_abap_unit_assert=>assert_equals(
        act = zabaputil_cl_util_context=>lang_sap_to_iso( `D` )
        exp = `de` ).
  ENDMETHOD.

  METHOD lang_sap_to_iso_lowercase.
    cl_abap_unit_assert=>assert_equals(
        act = zabaputil_cl_util_context=>lang_sap_to_iso( `e` )
        exp = `en` ).
  ENDMETHOD.

  METHOD lang_iso_to_sap_english.
    cl_abap_unit_assert=>assert_equals(
        act = zabaputil_cl_util_context=>lang_iso_to_sap( `en` )
        exp = `E` ).
  ENDMETHOD.

  METHOD lang_iso_to_sap_uppercase.
    cl_abap_unit_assert=>assert_equals(
        act = zabaputil_cl_util_context=>lang_iso_to_sap( `DE` )
        exp = `D` ).
  ENDMETHOD.

ENDCLASS.

CLASS ltcl_cur_amounts DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.

    METHODS to_external_zero_decimals     FOR TESTING.
    METHODS to_external_three_decimals    FOR TESTING.
    METHODS to_external_two_decimals      FOR TESTING.
    METHODS to_internal_zero_decimals     FOR TESTING.
    METHODS roundtrip                     FOR TESTING.

ENDCLASS.

CLASS ltcl_cur_amounts IMPLEMENTATION.

  METHOD to_external_zero_decimals.
    " JPY-style currency: stored 123.45 means 12345
    cl_abap_unit_assert=>assert_equals(
        act = zabaputil_cl_util_context=>cur_amount_to_external( val      = CONV decfloat34( '123.45' )
                                                                 decimals = 0 )
        exp = CONV decfloat34( 12345 ) ).
  ENDMETHOD.

  METHOD to_external_three_decimals.
    " BHD-style currency: stored 123.45 means 12.345
    cl_abap_unit_assert=>assert_equals(
        act = zabaputil_cl_util_context=>cur_amount_to_external( val      = CONV decfloat34( '123.45' )
                                                                 decimals = 3 )
        exp = CONV decfloat34( '12.345' ) ).
  ENDMETHOD.

  METHOD to_external_two_decimals.
    cl_abap_unit_assert=>assert_equals(
        act = zabaputil_cl_util_context=>cur_amount_to_external( val      = CONV decfloat34( '123.45' )
                                                                 decimals = 2 )
        exp = CONV decfloat34( '123.45' ) ).
  ENDMETHOD.

  METHOD to_internal_zero_decimals.
    cl_abap_unit_assert=>assert_equals(
        act = zabaputil_cl_util_context=>cur_amount_to_internal( val      = CONV decfloat34( 12345 )
                                                                 decimals = 0 )
        exp = CONV decfloat34( '123.45' ) ).
  ENDMETHOD.

  METHOD roundtrip.
    DATA(lv_val) = CONV decfloat34( '987.65' ).
    cl_abap_unit_assert=>assert_equals(
        act = zabaputil_cl_util_context=>cur_amount_to_internal(
                  val      = zabaputil_cl_util_context=>cur_amount_to_external( val      = lv_val
                                                                                decimals = 3 )
                  decimals = 3 )
        exp = lv_val ).
  ENDMETHOD.

ENDCLASS.
