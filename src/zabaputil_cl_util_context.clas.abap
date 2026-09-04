CLASS zabaputil_cl_util_context DEFINITION
  PUBLIC
  CREATE PUBLIC.

  PUBLIC SECTION.

    " abap-toolkit - Utility Functions for ABAP Cloud & Standard ABAP
    " version: `0.0.1`.
    " origin: https://github.com/oblomov-dev/abap-toolkit
    " author: https://github.com/oblomov-dev
    " license: MIT.

    CONSTANTS:
      BEGIN OF cs_ui5_msg_type,
        e TYPE string VALUE `Error` ##NO_TEXT,
        s TYPE string VALUE `Success` ##NO_TEXT,
        w TYPE string VALUE `Warning` ##NO_TEXT,
        i TYPE string VALUE `Information` ##NO_TEXT,
      END OF cs_ui5_msg_type.

    " Environment-abstracted character/format constants. Callers must read
    " these from z2ui5_cl_util instead of referencing cl_abap_char_utilities /
    " cl_abap_format directly, so the dependency on those SAP standard classes
    " lives in exactly one place (this class' class_constructor) and can be
    " ported once for non-ABAP runtimes (e.g. transpiled JS).
    CLASS-DATA cv_char_util_newline        TYPE c LENGTH 1 READ-ONLY.
    CLASS-DATA cv_char_util_cr_lf          TYPE c LENGTH 2 READ-ONLY.
    CLASS-DATA cv_char_util_horizontal_tab TYPE c LENGTH 1 READ-ONLY.
    CLASS-DATA cv_char_util_charsize       TYPE i          READ-ONLY.
    CLASS-DATA cv_format_e_xml_attr             TYPE i          READ-ONLY.

    " RTTI type-kind / kind / visibility constants, so callers can branch on
    " stored type_kind/kind fields without referencing cl_abap_typedescr /
    " cl_abap_objectdescr directly.
    CLASS-DATA cv_typedescr_typekind_table   TYPE c LENGTH 1 READ-ONLY.
    CLASS-DATA cv_typedescr_typekind_dref    TYPE c LENGTH 1 READ-ONLY.
    CLASS-DATA cv_typedescr_typekind_oref    TYPE c LENGTH 1 READ-ONLY.
    CLASS-DATA cv_typedescr_typekind_struct1 TYPE c LENGTH 1 READ-ONLY.
    CLASS-DATA cv_typedescr_typekind_struct2 TYPE c LENGTH 1 READ-ONLY.

    " the three elementary kinds whose JSON form is not their ABAP form
    " (ISO date/time strings, ISO timestamps) - what a caller converting a
    " scalar between the two representations has to branch on
    CLASS-DATA cv_typedescr_typekind_date    TYPE c LENGTH 1 READ-ONLY.
    CLASS-DATA cv_typedescr_typekind_time    TYPE c LENGTH 1 READ-ONLY.
    CLASS-DATA cv_typedescr_typekind_packed  TYPE c LENGTH 1 READ-ONLY.

    CLASS-DATA cv_typedescr_kind_struct      TYPE c LENGTH 1 READ-ONLY.
    CLASS-DATA cv_typedescr_kind_elem        TYPE c LENGTH 1 READ-ONLY.
    CLASS-DATA cv_typedescr_kind_ref         TYPE c LENGTH 1 READ-ONLY.
    CLASS-DATA cv_objectdescr_public         TYPE c LENGTH 1 READ-ONLY.

    CLASS-METHODS class_constructor.

    " Wraps the ABAP `ROLLBACK WORK` statement so the dependency on the
    " database transaction control lives in one place and can be ported once
    " for non-ABAP runtimes (e.g. transpiled JS).
    CLASS-METHODS db_rollback.

    TYPES:
      BEGIN OF ty_s_name_value,
        n TYPE string,
        v TYPE string,
      END OF ty_s_name_value.
    TYPES ty_t_name_value TYPE STANDARD TABLE OF ty_s_name_value WITH DEFAULT KEY.

    TYPES:
      BEGIN OF ty_s_token,
        key      TYPE string,
        text     TYPE string,
        visible  TYPE abap_bool,
        selkz    TYPE abap_bool,
        editable TYPE abap_bool,
      END OF ty_s_token.
    TYPES ty_t_token TYPE STANDARD TABLE OF ty_s_token WITH DEFAULT KEY.

    TYPES:
      BEGIN OF ty_s_range,
        sign   TYPE c LENGTH 1,
        option TYPE c LENGTH 2,
        low    TYPE string,
        high   TYPE string,
      END OF ty_s_range.
    TYPES ty_t_range TYPE STANDARD TABLE OF ty_s_range WITH DEFAULT KEY.

    TYPES:
      BEGIN OF ty_s_filter_multi,
        name            TYPE string,
        t_range         TYPE ty_t_range,
        t_token         TYPE ty_t_token,
        t_token_added   TYPE ty_t_token,
        t_token_removed TYPE ty_t_token,
      END OF ty_s_filter_multi.
    TYPES ty_t_filter_multi TYPE STANDARD TABLE OF ty_s_filter_multi WITH DEFAULT KEY.

    TYPES:
      BEGIN OF ty_s_sql,
        tabname        TYPE string,
        check_autoload TYPE abap_bool,
        layout_name    TYPE string,
        layout_id      TYPE string,
        count          TYPE i,
        t_ref          TYPE REF TO data,
        where          TYPE string,
        t_filter       TYPE ty_t_filter_multi,
      END OF ty_s_sql.

    TYPES:
      BEGIN OF ty_s_msg,
        text       TYPE string,
        id         TYPE string,
        no         TYPE string,
        type       TYPE string,
        v1         TYPE string,
        v2         TYPE string,
        v3         TYPE string,
        v4         TYPE string,
        timestampl TYPE timestampl,
        t_meta     TYPE ty_t_name_value,
      END OF ty_s_msg,
      ty_t_msg TYPE STANDARD TABLE OF ty_s_msg WITH DEFAULT KEY.

    TYPES:
      BEGIN OF ty_s_msg_box,
        text    TYPE string,
        type    TYPE string,
        title   TYPE string,
        details TYPE string,
        skip    TYPE abap_bool,
      END OF ty_s_msg_box.

    CLASS-METHODS ui5_get_msg_type
      IMPORTING
        val           TYPE clike
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS ui5_msg_box_format
      IMPORTING
        val           TYPE any
      RETURNING
        VALUE(result) TYPE ty_s_msg_box.

    "! Everything a message box can be built from that is NOT a message.
    "! ui5_msg_box_format( ) is asked first and answers `skip` when nothing
    "! it was handed is a message - this is what runs then, so that a box
    "! the caller asked for always has something to show: a character value
    "! (its own text, markup moved into the details), a number, a table, a
    "! nested structure or tree, an object, a data reference. `text` gets a
    "! one-line headline, `details` the data itself rendered as HTML.
    "! Complex data that is initial answers `skip` - a call over an empty
    "! table stays as silent as it is over an empty message table.
    CLASS-METHODS ui5_data_box_format
      IMPORTING
        val           TYPE any
      RETURNING
        VALUE(result) TYPE ty_s_msg_box.

    CLASS-METHODS rtti_check_serializable
      IMPORTING
        val           TYPE REF TO object
      RETURNING
        VALUE(result) TYPE abap_bool.

    CLASS-METHODS msg_get_t
      IMPORTING
        VALUE(val)    TYPE any
        VALUE(val2)   TYPE any OPTIONAL
      RETURNING
        VALUE(result) TYPE ty_t_msg.

    CLASS-METHODS rtti_get_data_element_text_l
      IMPORTING
        VALUE(val)    TYPE any
      RETURNING
        VALUE(result) TYPE string.

    " Extracts the DDIC data element name (`\TYPE=...` part of the absolute
    " name) from a component's elementary type, so callers do not reference
    " cl_abap_elemdescr directly.
    CLASS-METHODS rtti_get_ddic_type_name
      IMPORTING
        type          TYPE REF TO cl_abap_datadescr
      RETURNING
        VALUE(result) TYPE string.

    " Thin wrappers around cl_abap_typedescr=>describe_by_data(_ref), so the
    " RTTI describe calls live in one place. Return cl_abap_typedescr, which
    " already carries type_kind / kind / absolute_name.
    CLASS-METHODS rtti_get_typedescr_by_data_ref
      IMPORTING
        val           TYPE REF TO data
      RETURNING
        VALUE(result) TYPE REF TO cl_abap_typedescr.

    "! Is the data object behind the reference a STANDARD table - false for
    "! a sorted or hashed table, for anything that is no table, and for a
    "! reference RTTI cannot describe
    CLASS-METHODS rtti_check_table_standard
      IMPORTING
        val           TYPE REF TO data
      RETURNING
        VALUE(result) TYPE abap_bool.

    CLASS-METHODS rtti_get_typedescr_by_data
      IMPORTING
        val           TYPE any
      RETURNING
        VALUE(result) TYPE REF TO cl_abap_typedescr.

    TYPES:
      BEGIN OF ty_s_sel_tab_type,
        tabledescr       TYPE REF TO cl_abap_tabledescr,
        check_table_line TYPE abap_bool,
      END OF ty_s_sel_tab_type.

    " Builds a working table type from the line type of the source table. If
    " the source line is elementary it is wrapped into a `TAB_LINE` component
    " (check_table_line reports whether that happened). By default no extra
    " column is added; when add_sel_field = abap_true an additional boolean
    " flag column named sel_field_name (default `ZZSELKZ`) is inserted.
    " Keeps the dynamic RTTI type construction (describe_by_data / create) in
    " one place so it can be ported once for non-ABAP runtimes.
    " `ir_tab` keeps its Hungarian name against the `val` convention used by
    " the rest of this class: abap2UI5's frozen src/99 package passes it as a
    " NAMED argument and cannot be edited, so renaming it there is blocked -
    " and a rename only in this catalog would show up as drift on every sync.
    " Rename it once that consumer drops the call.
    CLASS-METHODS rtti_create_sel_tab_type
      IMPORTING
        ir_tab         TYPE REF TO data
        add_sel_field  TYPE abap_bool DEFAULT abap_false
        sel_field_name TYPE clike     DEFAULT `ZZSELKZ`
      RETURNING
        VALUE(result)  TYPE ty_s_sel_tab_type.

    CLASS-METHODS msg_get
      IMPORTING
        VALUE(val)    TYPE any
        VALUE(val2)   TYPE any OPTIONAL
      RETURNING
        VALUE(result) TYPE ty_s_msg.

    CLASS-METHODS msg_get_collect
      IMPORTING
        VALUE(val)    TYPE any
        VALUE(val2)   TYPE any OPTIONAL
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS msg_get_by_msg
      IMPORTING
        id            TYPE any
        no            TYPE any
        v1            TYPE any OPTIONAL
        v2            TYPE any OPTIONAL
        v3            TYPE any OPTIONAL
        v4            TYPE any OPTIONAL
      RETURNING
        VALUE(result) TYPE ty_s_msg.

    " depth guards the mutual recursion between these two (an include whose
    " expansion reaches itself would otherwise be an unbounded stack).
    " Optional and last in the list, so every existing caller is unaffected
    CLASS-METHODS rtti_get_t_attri_by_include
      IMPORTING
        !type         TYPE REF TO cl_abap_datadescr
        depth         TYPE i DEFAULT 0
      RETURNING
        VALUE(result) TYPE abap_component_tab.

    CLASS-METHODS expand_components
      IMPORTING
        val           TYPE abap_component_tab
        depth         TYPE i DEFAULT 0
      RETURNING
        VALUE(result) TYPE abap_component_tab.

    TYPES:
      BEGIN OF ty_s_fix_val,
        low   TYPE string,
        high  TYPE string,
        descr TYPE string,
      END OF ty_s_fix_val.
    TYPES ty_t_fix_val TYPE STANDARD TABLE OF ty_s_fix_val WITH DEFAULT KEY.

    CLASS-METHODS rtti_get_t_ddic_fixed_values
      IMPORTING
        rollname      TYPE clike
        langu         TYPE clike DEFAULT sy-langu
      RETURNING
        VALUE(result) TYPE ty_t_fix_val ##NEEDED.

    CLASS-METHODS check_bound_a_not_initial
      IMPORTING
        val           TYPE REF TO data
      RETURNING
        VALUE(result) TYPE abap_bool.

    CLASS-METHODS check_unassign_initial
      IMPORTING
        val           TYPE REF TO data
      RETURNING
        VALUE(result) TYPE abap_bool.

    CLASS-METHODS unassign_object
      IMPORTING
        val           TYPE any
      RETURNING
        VALUE(result) TYPE REF TO object.

    CLASS-METHODS unassign_data
      IMPORTING
        val           TYPE any
      RETURNING
        VALUE(result) TYPE REF TO data.

    CLASS-METHODS conv_get_as_data_ref
      IMPORTING
        val           TYPE data
      RETURNING
        VALUE(result) TYPE REF TO data.

    CLASS-METHODS itab_get_itab_by_csv
      IMPORTING
        val           TYPE string
      RETURNING
        VALUE(result) TYPE REF TO data.

    CLASS-METHODS itab_get_csv_by_itab
      IMPORTING
        val           TYPE any
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS filter_itab
      IMPORTING
        filter TYPE ty_t_filter_multi
      CHANGING
        val     TYPE STANDARD TABLE.

    CLASS-METHODS filter_get_multi_by_data
      IMPORTING
        val           TYPE data
      RETURNING
        VALUE(result) TYPE ty_t_filter_multi.

    CLASS-METHODS filter_get_data_by_multi
      IMPORTING
        val           TYPE ty_t_filter_multi
      RETURNING
        VALUE(result) TYPE ty_t_filter_multi.

    CLASS-METHODS filter_get_sql_where
      IMPORTING
        val           TYPE ty_t_filter_multi
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS filter_get_multi_by_sql_where
      IMPORTING
        val           TYPE clike
      RETURNING
        VALUE(result) TYPE ty_t_filter_multi.

    CLASS-METHODS filter_get_sql_by_sql_string
      IMPORTING
        val           TYPE clike
      RETURNING
        VALUE(result) TYPE ty_s_sql.

    CLASS-METHODS url_param_get
      IMPORTING
        val           TYPE string
        url           TYPE string
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS url_param_create_url
      IMPORTING
        t_params      TYPE ty_t_name_value
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS url_param_set
      IMPORTING
        url           TYPE string
        !name         TYPE string
        !value        TYPE string
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS rtti_get_classname_by_ref
      IMPORTING
        val           TYPE REF TO object
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS rtti_get_intfname_by_ref
      IMPORTING
        !in           TYPE any
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS x_get_last_t100
      IMPORTING
        val           TYPE REF TO cx_root
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS x_check_raise
      IMPORTING
        v     TYPE clike DEFAULT `CX_SY_SUBRC`
        !when TYPE abap_bool.

    CLASS-METHODS x_raise
      IMPORTING
        v TYPE clike DEFAULT `CX_SY_SUBRC`.

    CLASS-METHODS json_stringify
      IMPORTING
        !any          TYPE any
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS xml_parse
      IMPORTING
        !xml TYPE clike
      EXPORTING
        !any TYPE any.

    CLASS-METHODS xml_stringify
      IMPORTING
        !any          TYPE any
      RETURNING
        VALUE(result) TYPE string
      RAISING
        cx_xslt_serialization_error.

    CLASS-METHODS boolean_check_by_data
      IMPORTING
        val           TYPE any
      RETURNING
        VALUE(result) TYPE abap_bool.

    CLASS-METHODS boolean_abap_2_json
      IMPORTING
        val           TYPE any
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS json_parse
      IMPORTING
        val   TYPE any
      CHANGING
        !data TYPE any.

    CLASS-METHODS c_trim_upper
      IMPORTING
        val           TYPE clike
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS xml_srtti_stringify
      IMPORTING
        !data         TYPE any
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS xml_srtti_parse
      IMPORTING
        rtti_data     TYPE clike
      RETURNING
        VALUE(result) TYPE REF TO data.

    CLASS-METHODS time_get_timestampl
      RETURNING
        VALUE(result) TYPE timestampl.

    CLASS-METHODS time_subtract_seconds
      IMPORTING
        !time         TYPE timestampl
        !seconds      TYPE i
      RETURNING
        VALUE(result) TYPE timestampl.

    CLASS-METHODS c_trim
      IMPORTING
        val           TYPE any
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS c_trim_lower
      IMPORTING
        val           TYPE clike
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS url_param_get_tab
      IMPORTING
        val           TYPE clike
      RETURNING
        VALUE(result) TYPE ty_t_name_value.

    CLASS-METHODS rtti_get_t_attri_by_oref
      IMPORTING
        val           TYPE any
      RETURNING
        VALUE(result) TYPE abap_attrdescr_tab.

    CLASS-METHODS rtti_get_t_attri_by_any
      IMPORTING
        val           TYPE any
      RETURNING
        VALUE(result) TYPE cl_abap_structdescr=>component_table.

    CLASS-METHODS rtti_get_t_attri_by_table_name
      IMPORTING
        table_name    TYPE any
      RETURNING
        VALUE(result) TYPE cl_abap_structdescr=>component_table.

    CLASS-METHODS rtti_get_type_name
      IMPORTING
        val           TYPE any
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS rtti_check_class_exists
      IMPORTING
        val           TYPE clike
      RETURNING
        VALUE(result) TYPE abap_bool.

    CLASS-METHODS rtti_create_tab_by_name
      IMPORTING
        val           TYPE clike
      RETURNING
        VALUE(result) TYPE REF TO data.

    CLASS-METHODS rtti_check_type_kind_dref
      IMPORTING
        val           TYPE any
      RETURNING
        VALUE(result) TYPE abap_bool.

    CLASS-METHODS rtti_get_type_kind
      IMPORTING
        val           TYPE any
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS rtti_check_ref_data
      IMPORTING
        val           TYPE any
      RETURNING
        VALUE(result) TYPE abap_bool.

    CLASS-METHODS boolean_check_by_name
      IMPORTING
        val           TYPE string
      RETURNING
        VALUE(result) TYPE abap_bool.

    CLASS-METHODS filter_update_tokens
      IMPORTING
        val           TYPE ty_t_filter_multi
        !name         TYPE string
      RETURNING
        VALUE(result) TYPE ty_t_filter_multi.

    CLASS-METHODS filter_get_range_t_by_token_t
      IMPORTING
        val           TYPE ty_t_token
      RETURNING
        VALUE(result) TYPE ty_t_range.

    CLASS-METHODS filter_get_range_by_token
      IMPORTING
        val           TYPE string
      RETURNING
        VALUE(result) TYPE ty_s_range.

    CLASS-METHODS filter_get_token_t_by_range_t
      IMPORTING
        val           TYPE ANY TABLE
      RETURNING
        VALUE(result) TYPE ty_t_token ##NEEDED.

    CLASS-METHODS filter_get_token_range_mapping
      RETURNING
        VALUE(result) TYPE ty_t_name_value.

    CLASS-METHODS itab_corresponding
      IMPORTING
        val  TYPE STANDARD TABLE
      CHANGING
        !tab TYPE STANDARD TABLE.

    CLASS-METHODS itab_filter_by_val
      IMPORTING
        val         TYPE clike
        fields      TYPE string_table OPTIONAL
        ignore_case TYPE abap_bool DEFAULT abap_false
      CHANGING
        !tab        TYPE STANDARD TABLE.

    CLASS-METHODS itab_get_by_struc
      IMPORTING
        val           TYPE any
      RETURNING
        VALUE(result) TYPE zabaputil_cl_util_context=>ty_t_name_value.

    CLASS-METHODS itab_filter_by_t_range
      IMPORTING
        val  TYPE ty_t_filter_multi
      CHANGING
        !tab TYPE STANDARD TABLE.

    CLASS-METHODS time_get_time_by_stampl
      IMPORTING
        val           TYPE timestampl
      RETURNING
        VALUE(result) TYPE t.

    CLASS-METHODS time_get_date_by_stampl
      IMPORTING
        val           TYPE timestampl
      RETURNING
        VALUE(result) TYPE d.

    CLASS-METHODS conv_copy_ref_data
      IMPORTING
        !from         TYPE any
      RETURNING
        VALUE(result) TYPE REF TO data.

    CLASS-METHODS conv_get_xstring_by_data_uri
      IMPORTING
        val           TYPE clike
      RETURNING
        VALUE(result) TYPE xstring.

    CLASS-METHODS rtti_tab_get_relative_name
      IMPORTING
        !table        TYPE any
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS conv_exit
      IMPORTING
        convexit TYPE clike
        output   TYPE abap_bool DEFAULT abap_false
      CHANGING
        value    TYPE data.

    CLASS-METHODS rtti_check_clike
      IMPORTING
        val           TYPE any
      RETURNING
        VALUE(result) TYPE abap_bool.

    CLASS-METHODS c_contains
      IMPORTING
        val           TYPE clike
        sub           TYPE clike
      RETURNING
        VALUE(result) TYPE abap_bool.

    CLASS-METHODS c_starts_with
      IMPORTING
        val           TYPE clike
        prefix        TYPE clike
      RETURNING
        VALUE(result) TYPE abap_bool.

    CLASS-METHODS c_ends_with
      IMPORTING
        val           TYPE clike
        suffix        TYPE clike
      RETURNING
        VALUE(result) TYPE abap_bool.

    CLASS-METHODS c_split
      IMPORTING
        val           TYPE clike
        sep           TYPE clike
      RETURNING
        VALUE(result) TYPE string_table.

    CLASS-METHODS c_join
      IMPORTING
        tab           TYPE string_table
        sep           TYPE clike DEFAULT ``
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS rtti_check_table
      IMPORTING
        val           TYPE any
      RETURNING
        VALUE(result) TYPE abap_bool.

    CLASS-METHODS rtti_check_structure
      IMPORTING
        val           TYPE any
      RETURNING
        VALUE(result) TYPE abap_bool.

    CLASS-METHODS rtti_check_numeric
      IMPORTING
        val           TYPE any
      RETURNING
        VALUE(result) TYPE abap_bool.

    CLASS-METHODS time_add_seconds
      IMPORTING
        !time         TYPE timestampl
        !seconds      TYPE i
      RETURNING
        VALUE(result) TYPE timestampl.

    CLASS-METHODS time_get_stampl_by_date_time
      IMPORTING
        !date         TYPE d
        !time         TYPE t
      RETURNING
        VALUE(result) TYPE timestampl.

    CLASS-METHODS time_diff_seconds
      IMPORTING
        !time_from    TYPE timestampl
        !time_to      TYPE timestampl
      RETURNING
        VALUE(result) TYPE i.

    CLASS-METHODS conv_string_to_date
      IMPORTING
        val           TYPE clike
        format        TYPE clike DEFAULT `YYYY-MM-DD`
      RETURNING
        VALUE(result) TYPE d.

    CLASS-METHODS conv_date_to_string
      IMPORTING
        val           TYPE d
        format        TYPE clike DEFAULT `YYYY-MM-DD`
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS app_get_url
      IMPORTING
        VALUE(classname) TYPE clike
        !origin          TYPE clike
        !pathname        TYPE clike
        !search          TYPE clike
        !hash            TYPE clike OPTIONAL
      RETURNING
        VALUE(result)    TYPE string.

    CLASS-METHODS app_get_url_source_code
      IMPORTING
        !classname    TYPE clike
        !origin       TYPE clike
      RETURNING
        VALUE(result) TYPE string.

    " ========== String Extras ==========

    CLASS-METHODS c_pad_left
      IMPORTING
        val           TYPE clike
        len           TYPE i
        pad           TYPE c DEFAULT '0'
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS c_pad_right
      IMPORTING
        val           TYPE clike
        len           TYPE i
        pad           TYPE c DEFAULT ' '
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS c_truncate
      IMPORTING
        val           TYPE clike
        max           TYPE i
        ellipsis      TYPE string DEFAULT `...`
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS c_substring_safe
      IMPORTING
        val           TYPE clike
        off           TYPE i DEFAULT 0
        len           TYPE i DEFAULT -1
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS c_replace_all
      IMPORTING
        val           TYPE clike
        sub           TYPE clike
        new_val       TYPE clike
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS c_is_blank
      IMPORTING
        val           TYPE any
      RETURNING
        VALUE(result) TYPE abap_bool.

    " ========== Number Formatting ==========

    CLASS-METHODS conv_number_to_string
      IMPORTING
        val           TYPE numeric
        decimals      TYPE i DEFAULT -1
        sep_thousands TYPE c DEFAULT ''
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS conv_string_to_number
      IMPORTING
        val           TYPE clike
      RETURNING
        VALUE(result) TYPE decfloat34.

    " ========== i18n / Text Resolution ==========

    " ========== Itab Extras ==========

    CLASS-METHODS itab_sort_by
      IMPORTING
        fieldname  TYPE clike
        descending TYPE abap_bool DEFAULT abap_false
      CHANGING
        tab        TYPE STANDARD TABLE.

    CLASS-METHODS itab_slice
      IMPORTING
        tab           TYPE STANDARD TABLE
        !from         TYPE i DEFAULT 1
        !to           TYPE i DEFAULT 0
      RETURNING
        VALUE(result) TYPE REF TO data.

    CLASS-METHODS itab_paginate
      IMPORTING
        tab           TYPE STANDARD TABLE
        page          TYPE i DEFAULT 1
        page_size     TYPE i DEFAULT 20
      EXPORTING
        VALUE(result) TYPE REF TO data
        total_count   TYPE i
        total_pages   TYPE i.

    CLASS-METHODS itab_to_json
      IMPORTING
        val           TYPE any
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS itab_from_json
      IMPORTING
        val  TYPE clike
      CHANGING
        data TYPE any.

    CLASS-METHODS itab_count_by
      IMPORTING
        tab           TYPE STANDARD TABLE
        fieldname     TYPE clike
      RETURNING
        VALUE(result) TYPE ty_t_name_value.

    " ========== Validation Helpers ==========

    CLASS-METHODS check_is_email
      IMPORTING
        val           TYPE clike
      RETURNING
        VALUE(result) TYPE abap_bool.

    CLASS-METHODS check_is_numeric_string
      IMPORTING
        val           TYPE clike
      RETURNING
        VALUE(result) TYPE abap_bool.

    CLASS-METHODS check_is_date_valid
      IMPORTING
        val           TYPE clike
        format        TYPE clike DEFAULT `YYYY-MM-DD`
      RETURNING
        VALUE(result) TYPE abap_bool.

    CLASS-METHODS check_is_guid
      IMPORTING
        val           TYPE clike
      RETURNING
        VALUE(result) TYPE abap_bool.

    CLASS-METHODS check_max_length
      IMPORTING
        val           TYPE clike
        max           TYPE i
      RETURNING
        VALUE(result) TYPE abap_bool.

    " ========== Deep Comparison ==========

    CLASS-METHODS data_equals
      IMPORTING
        a             TYPE any
        b             TYPE any
      RETURNING
        VALUE(result) TYPE abap_bool.

    TYPES:
      BEGIN OF ty_s_field_diff,
        fieldname TYPE string,
        old_value TYPE string,
        new_value TYPE string,
      END OF ty_s_field_diff.
    TYPES ty_t_field_diff TYPE STANDARD TABLE OF ty_s_field_diff WITH DEFAULT KEY.

    CLASS-METHODS data_diff
      IMPORTING
        old           TYPE any
        new           TYPE any
      RETURNING
        VALUE(result) TYPE ty_t_field_diff.

    " ========== Stopwatch ==========

    CLASS-METHODS time_measure_start
      RETURNING
        VALUE(result) TYPE timestampl.

    CLASS-METHODS time_measure_stop
      IMPORTING
        start_time    TYPE timestampl
      RETURNING
        VALUE(result) TYPE i.

    " ========== Authorization Check ==========

    " ========== Enum/Domain Helpers ==========

    CLASS-METHODS enum_to_text
      IMPORTING
        domain        TYPE clike
        !value        TYPE clike
        langu         TYPE clike DEFAULT sy-langu
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS enum_get_all
      IMPORTING
        domain        TYPE clike
        langu         TYPE clike DEFAULT sy-langu
      RETURNING
        VALUE(result) TYPE ty_t_name_value.

    " ========== Deep Field Access ==========

    CLASS-METHODS data_get_by_path
      IMPORTING
        data          TYPE any
        path          TYPE clike
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS data_set_by_path
      IMPORTING
        path  TYPE clike
        !value TYPE clike
      CHANGING
        data  TYPE any.

    " ========== Lock Extensions ==========

    " ========== Number Range ==========

    " ========== Change Documents ==========

    " ========== Background Job ==========

    " ========== Email ==========

    TYPES:
      BEGIN OF ty_syst,
        index TYPE i,
        pagno TYPE i,
        tabix TYPE i,
        tfill TYPE i,
        tlopc TYPE i,
        tmaxl TYPE i,
        toccu TYPE i,
        ttabc TYPE i,
        tstis TYPE i,
        ttabi TYPE i,
        dbcnt TYPE i,
        fdpos TYPE i,
        colno TYPE i,
        linct TYPE i,
        linno TYPE i,
        linsz TYPE i,
        pagct TYPE i,
        macol TYPE i,
        marow TYPE i,
        tleng TYPE i,
        sfoff TYPE i,
        willi TYPE i,
        lilli TYPE i,
        subrc TYPE i,
        fleng TYPE i,
        cucol TYPE i,
        curow TYPE i,
        lsind TYPE i,
        listi TYPE i,
        stepl TYPE i,
        tpagi TYPE i,
        winx1 TYPE i,
        winy1 TYPE i,
        winx2 TYPE i,
        winy2 TYPE i,
        winco TYPE i,
        winro TYPE i,
        windi TYPE i,
        srows TYPE i,
        scols TYPE i,
        loopc TYPE i,
        folen TYPE i,
        fodec TYPE i,
        tzone TYPE i,
        dayst TYPE c LENGTH 1,
        ftype TYPE c LENGTH 1,
        appli TYPE x LENGTH 2,
        fdayw TYPE int1,
        ccurs TYPE p LENGTH 9 DECIMALS 0,
        ccurt TYPE p LENGTH 9 DECIMALS 0,
        debug TYPE c LENGTH 1,
        ctype TYPE c LENGTH 1,
        input TYPE c LENGTH 1,
        langu TYPE c LENGTH 1,
        modno TYPE i,
        batch TYPE c LENGTH 1,
        binpt TYPE c LENGTH 1,
        calld TYPE c LENGTH 1,
        dynnr TYPE c LENGTH 4,
        dyngr TYPE c LENGTH 4,
        newpa TYPE c LENGTH 1,
        pri40 TYPE c LENGTH 1,
        rstrt TYPE c LENGTH 1,
        wtitl TYPE c LENGTH 1,
        cpage TYPE i,
        dbnam TYPE c LENGTH 20,
        mandt TYPE c LENGTH 3,
        prefx TYPE c LENGTH 3,
        fmkey TYPE c LENGTH 3,
        pexpi TYPE n LENGTH 1,
        prini TYPE n LENGTH 1,
        primm TYPE c LENGTH 1,
        prrel TYPE c LENGTH 1,
        playo TYPE c LENGTH 5,
        prbig TYPE c LENGTH 1,
        playp TYPE c LENGTH 1,
        prnew TYPE c LENGTH 1,
        prlog TYPE c LENGTH 1,
        pdest TYPE c LENGTH 4,
        plist TYPE c LENGTH 12,
        pauth TYPE n LENGTH 2,
        prdsn TYPE c LENGTH 6,
        pnwpa TYPE c LENGTH 1,
        callr TYPE c LENGTH 8,
        repi2 TYPE c LENGTH 40,
        rtitl TYPE c LENGTH 70,
        prrec TYPE c LENGTH 12,
        prtxt TYPE c LENGTH 68,
        prabt TYPE c LENGTH 12,
        lpass TYPE c LENGTH 4,
        nrpag TYPE c LENGTH 1,
        paart TYPE c LENGTH 16,
        prcop TYPE n LENGTH 3,
        batzs TYPE c LENGTH 1,
        bspld TYPE c LENGTH 1,
        brep4 TYPE c LENGTH 4,
        batzo TYPE c LENGTH 1,
        batzd TYPE c LENGTH 1,
        batzw TYPE c LENGTH 1,
        batzm TYPE c LENGTH 1,
        ctabl TYPE c LENGTH 4,
        dbsys TYPE c LENGTH 10,
        dcsys TYPE c LENGTH 4,
        macdb TYPE c LENGTH 4,
        sysid TYPE c LENGTH 8,
        opsys TYPE c LENGTH 10,
        pfkey TYPE c LENGTH 20,
        saprl TYPE c LENGTH 4,
        tcode TYPE c LENGTH 20,
        ucomm TYPE c LENGTH 70,
        cfwae TYPE c LENGTH 5,
        chwae TYPE c LENGTH 5,
        spono TYPE n LENGTH 10,
        sponr TYPE n LENGTH 10,
        waers TYPE c LENGTH 5,
        cdate TYPE d,
        datum TYPE d,
        slset TYPE c LENGTH 14,
        subty TYPE x LENGTH 1,
        subcs TYPE c LENGTH 1,
        group TYPE c LENGTH 1,
        ffile TYPE c LENGTH 8,
        uzeit TYPE t,
        dsnam TYPE c LENGTH 8,
        tabid TYPE c LENGTH 8,
        tfdsn TYPE c LENGTH 8,
        uname TYPE c LENGTH 12,
        lstat TYPE c LENGTH 16,
        abcde TYPE c LENGTH 26,
        marky TYPE c LENGTH 1,
        sfnam TYPE c LENGTH 30,
        tname TYPE c LENGTH 30,
        msgli TYPE c LENGTH 60,
        title TYPE c LENGTH 70,
        entry TYPE c LENGTH 72,
        lisel TYPE c LENGTH 255,
        uline TYPE c LENGTH 255,
        xcode TYPE c LENGTH 70,
        cprog TYPE c LENGTH 40,
        xprog TYPE c LENGTH 40,
        xform TYPE c LENGTH 30,
        ldbpg TYPE c LENGTH 40,
        tvar0 TYPE c LENGTH 20,
        tvar1 TYPE c LENGTH 20,
        tvar2 TYPE c LENGTH 20,
        tvar3 TYPE c LENGTH 20,
        tvar4 TYPE c LENGTH 20,
        tvar5 TYPE c LENGTH 20,
        tvar6 TYPE c LENGTH 20,
        tvar7 TYPE c LENGTH 20,
        tvar8 TYPE c LENGTH 20,
        tvar9 TYPE c LENGTH 20,
        msgid TYPE c LENGTH 20,
        msgty TYPE c LENGTH 1,
        msgno TYPE n LENGTH 3,
        msgv1 TYPE c LENGTH 50,
        msgv2 TYPE c LENGTH 50,
        msgv3 TYPE c LENGTH 50,
        msgv4 TYPE c LENGTH 50,
        oncom TYPE c LENGTH 1,
        vline TYPE c LENGTH 1,
        winsl TYPE c LENGTH 79,
        staco TYPE i,
        staro TYPE i,
        datar TYPE c LENGTH 1,
        host  TYPE c LENGTH 32,
        locdb TYPE c LENGTH 1,
        locop TYPE c LENGTH 1,
        datlo TYPE d,
        timlo TYPE t,
        zonlo TYPE c LENGTH 6,
      END OF ty_syst.

    TYPES:
      BEGIN OF ty_s_data_element_text,
        header TYPE string,
        short  TYPE string,
        medium TYPE string,
        long   TYPE string,
      END OF ty_s_data_element_text.

    TYPES:
      BEGIN OF ty_s_class_descr,
        classname   TYPE string,
        description TYPE string,
      END OF ty_s_class_descr.
    TYPES ty_t_classes TYPE STANDARD TABLE OF ty_s_class_descr WITH DEFAULT KEY.

    TYPES:
      BEGIN OF ty_s_stack,
        class   TYPE string,
        include TYPE string,
        method  TYPE string,
        line    TYPE string,
      END OF ty_s_stack.
    TYPES ty_t_stack TYPE STANDARD TABLE OF ty_s_stack WITH DEFAULT KEY.

    CLASS-METHODS context_get_callstack
      RETURNING
        VALUE(result) TYPE ty_t_stack.

    CLASS-METHODS context_get_tenant
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS context_get_sy
      RETURNING
        VALUE(result) TYPE ty_syst.

    CLASS-METHODS check_abap_cloud
      RETURNING
        VALUE(result) TYPE abap_bool.

    CLASS-METHODS context_get_user_tech
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS uuid_get_c32
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS uuid_get_c22
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS rtti_get_data_element_texts
      IMPORTING
        val           TYPE clike
      RETURNING
        VALUE(result) TYPE ty_s_data_element_text.

    CLASS-METHODS conv_decode_x_base64
      IMPORTING
        val           TYPE string
      RETURNING
        VALUE(result) TYPE xstring.

    CLASS-METHODS conv_encode_x_base64
      IMPORTING
        val           TYPE xstring
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS conv_get_string_by_xstring
      IMPORTING
        val           TYPE xstring
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS conv_get_xstring_by_string
      IMPORTING
        val           TYPE string
      RETURNING
        VALUE(result) TYPE xstring.

    " read_description defaults to off: filling it costs one repository
    " read PER implementing class (SEO_CLASS_READ / XCO), and the common
    " caller - interface implementer discovery - only ever reads the
    " classname. Optional and last in the list, so it is additive
    CLASS-METHODS rtti_get_classes_impl_intf
      IMPORTING
        val              TYPE clike
        read_description TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(result)    TYPE ty_t_classes.

    " abap_true for values that can be rendered into a text without a
    " conversion dump - the elementary types. Anything structured (struct,
    " table, reference) must be excluded before a generic `|{ val }|`.
    CLASS-METHODS rtti_check_printable
      IMPORTING
        val           TYPE any
      RETURNING
        VALUE(result) TYPE abap_bool.

    " The source-code position an exception was raised at, as
    " `<program> / <include> / line <n>`; empty when the runtime supplies
    " none. Wraps cx_root->get_source_position so the dependency on the SAP
    " standard exception API stays inside this class. This is what identifies
    " the failing method for exceptions that carry no text of their own -
    " a CX_SY_MOVE_CAST_ERROR only says which types did not match, the
    " position says where.
    CLASS-METHODS error_get_source_position
      IMPORTING
        val           TYPE REF TO cx_root
      RETURNING
        VALUE(result) TYPE string.

    " Every public, non-static, non-constant attribute of an exception that
    " has a printable value - the class-specific payload the text alone does
    " not carry (source/target type of a cast error, the offending value of a
    " conversion error, DB object of an SQL error, ...). The general cx_root
    " attributes (PREVIOUS, TEXTID, IS_RESUMABLE, KERNEL_ERRID) are skipped -
    " the caller renders them itself or they carry no information.
    CLASS-METHODS error_get_attributes
      IMPORTING
        val           TYPE REF TO cx_root
      RETURNING
        VALUE(result) TYPE ty_t_name_value.

    CLASS-METHODS rtti_get_t_fixvalues
      IMPORTING
        elemdescr     TYPE REF TO cl_abap_elemdescr
        langu         TYPE clike
      RETURNING
        VALUE(result) TYPE ty_t_fix_val.

    CLASS-METHODS rtti_get_table_desrc
      IMPORTING
        tabname       TYPE clike
        langu         TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE string ##NEEDED.


    CLASS-METHODS msg_get_text
      IMPORTING
        val           TYPE any
        val2          TYPE any OPTIONAL
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS msg_get_by_sy
      RETURNING
        VALUE(result) TYPE ty_t_msg.

    CLASS-METHODS msg_map
      IMPORTING
        name          TYPE clike
        val           TYPE data
        msg           TYPE ty_s_msg
      RETURNING
        VALUE(result) TYPE ty_s_msg.

    TYPES: BEGIN OF ty_usr01,
             mandt         TYPE c LENGTH 3,     " Client
             bname         TYPE c LENGTH 12,    " User Name
             stcod         TYPE c LENGTH 20,    " Start Menu (old)
             spld          TYPE c LENGTH 4,     " Output Device
             splg          TYPE c LENGTH 1,     " Print Parameter 1
             spdb          TYPE c LENGTH 1,     " Print Parameter 2
             spda          TYPE c LENGTH 1,     " Print Parameter 3
             datfm         TYPE c LENGTH 1,     " Date Format
             dcpfm         TYPE c LENGTH 1,     " Decimal Format
             hdest         TYPE c LENGTH 8,     " Host Destination
             hmand         TYPE c LENGTH 3,     " Default Host Client
             hname         TYPE c LENGTH 12,    " Default Host Username
             menon         TYPE c LENGTH 1,     " Automatic Start
             menue         TYPE c LENGTH 20,    " Menu Name
             strtt         TYPE c LENGTH 20,    " Start Menu (again)
             langu         TYPE c LENGTH 1,     " Logon Language
             cattkennz     TYPE c LENGTH 1,     " CATT Test Status
             timefm        TYPE c LENGTH 1,     " Time Format (12h/24h)
             ianatzonecode TYPE n LENGTH 4,     " IANA Timezone Code
           END OF ty_usr01.

    TYPES:
      BEGIN OF ty_s_dfies,
        tabname     TYPE c LENGTH 30,
        fieldname   TYPE c LENGTH 30,
        langu       TYPE string,
        position    TYPE n LENGTH 4,
        offset      TYPE n LENGTH 6,
        domname     TYPE c LENGTH 30,
        rollname    TYPE c LENGTH 30,
        checktable  TYPE c LENGTH 30,
        leng        TYPE n LENGTH 6,
        intlen      TYPE n LENGTH 6,
        outputlen   TYPE n LENGTH 6,
        decimals    TYPE n LENGTH 6,
        datatype    TYPE c LENGTH 4,
        inttype     TYPE c LENGTH 1,
        reftable    TYPE c LENGTH 30,
        reffield    TYPE c LENGTH 30,
        precfield   TYPE c LENGTH 30,
        authorid    TYPE c LENGTH 3,
        memoryid    TYPE c LENGTH 20,
        logflag     TYPE c LENGTH 1,
        mask        TYPE c LENGTH 20,
        masklen     TYPE n LENGTH 4,
        convexit    TYPE c LENGTH 5,
        headlen     TYPE n LENGTH 2,
        scrlen1     TYPE n LENGTH 2,
        scrlen2     TYPE n LENGTH 2,
        scrlen3     TYPE n LENGTH 2,
        fieldtext   TYPE c LENGTH 60,
        reptext     TYPE c LENGTH 55,
        scrtext_s   TYPE c LENGTH 10,
        scrtext_m   TYPE c LENGTH 20,
        scrtext_l   TYPE c LENGTH 40,
        keyflag     TYPE c LENGTH 1,
        lowercase   TYPE c LENGTH 1,
        mac         TYPE c LENGTH 1,
        genkey      TYPE c LENGTH 1,
        noforkey    TYPE c LENGTH 1,
        valexi      TYPE c LENGTH 1,
        noauthch    TYPE c LENGTH 1,
        sign        TYPE c LENGTH 1,
        dynpfld     TYPE c LENGTH 1,
        f4availabl  TYPE c LENGTH 1,
        comptype    TYPE c LENGTH 1,
        lfieldname  TYPE c LENGTH 132,
        ltrflddis   TYPE c LENGTH 1,
        bidictrlc   TYPE c LENGTH 1,
        outputstyle TYPE n LENGTH 2,
        nohistory   TYPE c LENGTH 1,
        ampmformat  TYPE c LENGTH 1,
      END OF ty_s_dfies,
      ty_t_dfies TYPE STANDARD TABLE OF ty_s_dfies WITH DEFAULT KEY.

    CLASS-METHODS convexit_ext
      IMPORTING
        name   TYPE ty_s_dfies
        val    TYPE data
      CHANGING
        result TYPE data.

    CLASS-METHODS rtti_get_t_dfies_by_table_name
      IMPORTING
        table_name    TYPE string
      RETURNING
        VALUE(result) TYPE ty_t_dfies.

    CLASS-METHODS tab_get_where_by_dfies
      IMPORTING
        mv_check_tab_field TYPE string
        ms_data_row        TYPE REF TO data
        it_dfies           TYPE ty_t_dfies
      RETURNING
        VALUE(result)      TYPE string.

    TYPES trobj_name     TYPE c LENGTH 120.
    TYPES sxco_transport TYPE c LENGTH 20.
    TYPES:
      BEGIN OF ty_s_transport,
        short_description TYPE string,
        transport         TYPE sxco_transport,
        task              TYPE sxco_transport,
        selkz             TYPE abap_bool,
        locl              TYPE abap_bool,
      END OF ty_s_transport.

    TYPES ty_t_data TYPE STANDARD TABLE OF ty_s_transport WITH DEFAULT KEY.

    TYPES:
      BEGIN OF ty_s_dfies_2,
        tabname     TYPE c LENGTH 30,  " Table Name
        fieldname   TYPE c LENGTH 30,  " Field Name
        langu       TYPE c LENGTH 1,   " Language Key
        position    TYPE n LENGTH 4,   " Position of the field in the table
        offset      TYPE n LENGTH 6,   " Offset of a field
        domname     TYPE c LENGTH 30,  " Domain name
        rollname    TYPE c LENGTH 30,  " Data element (semantic domain)
        checktable  TYPE c LENGTH 30,  " Check Table
        leng        TYPE n LENGTH 6,   " Length (Characters)
        intlen      TYPE n LENGTH 6,   " Internal Length (Bytes)
        outputlen   TYPE n LENGTH 6,   " Output Length
        decimals    TYPE n LENGTH 6,   " Number of Decimal Places
        datatype    TYPE c LENGTH 4,   " Dynpro Data Type
        inttype     TYPE c LENGTH 1,   " ABAP Data Type (C,D,N,...)
        reftable    TYPE c LENGTH 30,  " Reference Table
        reffield    TYPE c LENGTH 30,  " Reference Field
        precfield   TYPE c LENGTH 30,  " Included Table Name
        authorid    TYPE c LENGTH 3,   " Authorization Class
        memoryid    TYPE c LENGTH 20,  " Set/Get Parameter ID
        logflag     TYPE c LENGTH 1,   " Change Documents Indicator
        mask        TYPE c LENGTH 20,  " Template
        masklen     TYPE n LENGTH 4,   " Template Length
        convexit    TYPE c LENGTH 5,   " Conversion Routine
        headlen     TYPE n LENGTH 2,   " Heading Length
        scrlen1     TYPE n LENGTH 2,   " Short Field Label Length
        scrlen2     TYPE n LENGTH 2,   " Medium Field Label Length
        scrlen3     TYPE n LENGTH 2,   " Long Field Label Length
        fieldtext   TYPE c LENGTH 60,  " Short Description
        reptext     TYPE c LENGTH 55,  " Heading
        scrtext_s   TYPE c LENGTH 10,  " Short Field Label
        scrtext_m   TYPE c LENGTH 20,  " Medium Field Label
        scrtext_l   TYPE c LENGTH 40,  " Long Field Label
        keyflag     TYPE c LENGTH 1,   " Key Field Indicator
        lowercase   TYPE c LENGTH 1,   " Lowercase Allowed
        mac         TYPE c LENGTH 1,   " Search Help Attached
        genkey      TYPE c LENGTH 1,   " Flag (X or Blank)
        noforkey    TYPE c LENGTH 1,   " Flag (X or Blank)
        valexi      TYPE c LENGTH 1,   " Fixed Values Exist
        noauthch    TYPE c LENGTH 1,   " Flag (X or Blank)
        sign        TYPE c LENGTH 1,   " Sign Flag
        dynpfld     TYPE c LENGTH 1,   " Field Displayed on Dynpro
        f4availabl  TYPE c LENGTH 1,   " Input Help Available
        comptype    TYPE c LENGTH 1,   " Component Type
        lfieldname  TYPE c LENGTH 132, " Long Field Name
        ltrflddis   TYPE c LENGTH 1,   " Left-to-Right Write Direction
        bidictrlc   TYPE c LENGTH 1,   " No BIDI Character Filtering
        outputstyle TYPE n LENGTH 2,   " Output Style (Decfloat Types)
        nohistory   TYPE c LENGTH 1,   " Input History Deactivated
        ampmformat  TYPE c LENGTH 1,   " AM/PM Time Format Indicator
      END OF ty_s_dfies_2.
    TYPES ty_t_dfies_2 TYPE STANDARD TABLE OF ty_s_dfies_2 WITH DEFAULT KEY.

    TYPES:
      BEGIN OF ty_shlp_intdescr,
        issimple         TYPE c LENGTH 1,   " Elementary Search Help Flag
        hotkey           TYPE c LENGTH 1,   " Hot Key
        selmtype         TYPE c LENGTH 1,   " Category of Selection Method
        selmethod        TYPE c LENGTH 30,  " Selection Method Name
        texttab          TYPE c LENGTH 30,  " Text Table Name
        selmexit         TYPE c LENGTH 30,  " Search Help Exit
        dialogtype       TYPE c LENGTH 1,   " Dialog Type
        ddlanguage       TYPE c LENGTH 1,   " Language Key
        ddtext           TYPE c LENGTH 60,  " Short Text
        dialoginfo       TYPE c LENGTH 1,   " Flag: SELFIELDS/LISTFIELDS read
        f4state          TYPE c LENGTH 1,   " Internal Usage Only
        tabname          TYPE c LENGTH 30,  " Table Name
        fieldname        TYPE c LENGTH 30,  " Field Name
        title            TYPE c LENGTH 60,  " Title Text
        history          TYPE c LENGTH 1,   " Deprecated Usage
        handle           TYPE int4,         " Reference Handle (int4)
        autosuggest      TYPE c LENGTH 1,   " Autosuggest Flag
        fuzzy_search     TYPE c LENGTH 1,   " Fuzzy Search Flag
        fuzzy_similarity TYPE p DECIMALS 1 LENGTH 2, " Accuracy for Fuzzy Search (DEC 2,1)
      END OF ty_shlp_intdescr.

    TYPES:
      BEGIN OF ty_ddshiface,
        shlpfield  TYPE c LENGTH 30,  " Field Name for Pass by Value to F4 Help
        valtabname TYPE c LENGTH 30,  " Structure Name for Input Help Assignment
        valfield   TYPE c LENGTH 132, " Field for Input Help Assignment
        value      TYPE c LENGTH 132, " Field Content from Dynpro
        internal   TYPE c LENGTH 1,   " Flag: Internal Representation
        dispfield  TYPE c LENGTH 1,   " Display-Only Field Flag
        f4field    TYPE c LENGTH 1,   " F4 Pressed Flag
        topshlpnam TYPE c LENGTH 30,  " Higher-Level Search Help Name
        topshlpfld TYPE c LENGTH 30,  " Field of Higher-Level Search Help
      END OF ty_ddshiface.

    TYPES:
      BEGIN OF ty_ddshfprop,
        fieldname  TYPE c LENGTH 30, " Name of Search Help Parameter
        shlpinput  TYPE c LENGTH 1,  " IMPORT Parameter Flag
        shlpoutput TYPE c LENGTH 1,  " EXPORT Parameter Flag
        shlpselpos TYPE n LENGTH 2,  " Position in Dialog Box
        shlplispos TYPE n LENGTH 2,  " Position in Hit List
        shlpseldis TYPE c LENGTH 1,  " Display Field in Dialog Box
        defaultval TYPE c LENGTH 21, " Default Value
      END OF ty_ddshfprop.

    TYPES:
      BEGIN OF ty_ddshselopt,
        shlpname  TYPE c LENGTH 30, " Name of Search Help
        shlpfield TYPE c LENGTH 30, " Name of Search Help Parameter
        sign      TYPE c LENGTH 1,  " Include/Exclude Flag (I/E)
        option    TYPE c LENGTH 2,  " Selection Option (EQ/BT/CP/..)
        low       TYPE c LENGTH 45, " Low Value for Selection
        high      TYPE c LENGTH 45, " High Value for Selection
      END OF ty_ddshselopt.

    TYPES:
      BEGIN OF ty_ddshtextsearch_field,
        fieldname TYPE c LENGTH 30, " Name of a searchable field (freely chosen, not specified by SAP)
      END OF ty_ddshtextsearch_field.

    TYPES tt_ddshtextsearch_fields TYPE STANDARD TABLE OF ty_ddshtextsearch_field WITH DEFAULT KEY.

    TYPES:
      BEGIN OF ty_ddshtextsearch,
        request TYPE c LENGTH 60,              " Text Search Request
        fields  TYPE tt_ddshtextsearch_fields, " Fields eligible for text search
      END OF ty_ddshtextsearch.

    TYPES:
      BEGIN OF ty_shlp_descr,
        shlpname   TYPE c LENGTH 30,       " Name of a Search Help
        shlptype   TYPE c LENGTH 2,        " Type of an input help (fixed values)
        intdescr   TYPE ty_shlp_intdescr,  " Placeholder for Internal Info of Search Help
        interface  TYPE STANDARD TABLE OF ty_ddshiface WITH DEFAULT KEY,                      " Placeholder for Interface of Search Help
        fielddescr TYPE STANDARD TABLE OF ty_s_dfies_2 WITH DEFAULT KEY,
        fieldprop  TYPE STANDARD TABLE OF ty_ddshfprop WITH DEFAULT KEY,
        selopt     TYPE STANDARD TABLE OF ty_ddshselopt WITH DEFAULT KEY,
        textsearch TYPE ty_ddshtextsearch,
      END OF ty_shlp_descr.

    CLASS-METHODS bus_tr_read
      RETURNING
        VALUE(mt_data) TYPE ty_t_data.

    CLASS-METHODS bus_tr_add
      IMPORTING
        ir_data      TYPE REF TO data
        iv_tabname   TYPE string
        is_transport TYPE ty_s_transport.

    CLASS-METHODS bus_search_help_read
      CHANGING
        ms_shlp        TYPE ty_shlp_descr
        mv_fname       TYPE string
        mv_table       TYPE string
        mr_data        TYPE REF TO data
        mt_result_desc TYPE ty_t_dfies_2
        mv_shlpfield   TYPE string
        mt_data        TYPE REF TO data
        ms_data_row    TYPE REF TO data.

    " ========== Business Application Log (BAL) ==========

    TYPES:
      BEGIN OF ty_s_bal_header,
        log_handle  TYPE string,
        object      TYPE string,
        subobject   TYPE string,
        external_id TYPE string,
        log_date    TYPE d,
        log_time    TYPE t,
        user        TYPE string,
        msg_count   TYPE i,
      END OF ty_s_bal_header.
    TYPES ty_t_bal_header TYPE STANDARD TABLE OF ty_s_bal_header WITH DEFAULT KEY.

    CLASS-METHODS bal_search
      IMPORTING
        object        TYPE clike OPTIONAL
        subobject     TYPE clike OPTIONAL
        id            TYPE clike OPTIONAL
        date_from     TYPE d OPTIONAL
        date_to       TYPE d OPTIONAL
        !user         TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE ty_t_bal_header.

    CLASS-METHODS bal_read_latest
      IMPORTING
        object        TYPE clike
        subobject     TYPE clike
        id            TYPE clike
      RETURNING
        VALUE(result) TYPE zabaputil_cl_util_context=>ty_s_msg.

    CLASS-METHODS bal_delete_before
      IMPORTING
        object    TYPE clike
        subobject TYPE clike OPTIONAL
        !days     TYPE i DEFAULT 30.

    CLASS-METHODS bal_read_by_type
      IMPORTING
        object        TYPE clike
        subobject     TYPE clike
        id            TYPE clike
        msg_type      TYPE clike DEFAULT `E`
      RETURNING
        VALUE(result) TYPE zabaputil_cl_util_context=>ty_t_msg.

    CLASS-METHODS bal_count
      IMPORTING
        object        TYPE clike
        subobject     TYPE clike
        id            TYPE clike
      RETURNING
        VALUE(result) TYPE i.

    CLASS-METHODS bal_read
      IMPORTING
        object        TYPE clike
        subobject     TYPE clike
        id            TYPE clike
      RETURNING
        VALUE(result) TYPE zabaputil_cl_util_context=>ty_t_msg.

    CLASS-METHODS bal_create
      IMPORTING
        object    TYPE clike
        subobject TYPE clike
        id        TYPE clike
        t_log     TYPE zabaputil_cl_util_context=>ty_t_msg.

    CLASS-METHODS bal_update
      IMPORTING
        object    TYPE clike
        subobject TYPE clike
        id        TYPE clike
        t_log     TYPE zabaputil_cl_util_context=>ty_t_msg.

    CLASS-METHODS bal_delete
      IMPORTING
        object    TYPE clike
        subobject TYPE clike
        id        TYPE clike.

    " ========== Transport Requests ==========

    TYPES:
      BEGIN OF ty_s_tr_object,
        pgmid    TYPE string,
        object   TYPE string,
        obj_name TYPE string,
      END OF ty_s_tr_object.
    TYPES ty_t_tr_object TYPE STANDARD TABLE OF ty_s_tr_object WITH DEFAULT KEY.

    TYPES:
      BEGIN OF ty_s_tr_request,
        trkorr      TYPE string,
        description TYPE string,
        owner       TYPE string,
        status      TYPE string,
        type        TYPE string,
      END OF ty_s_tr_request.
    TYPES ty_t_tr_request TYPE STANDARD TABLE OF ty_s_tr_request WITH DEFAULT KEY.

    CLASS-METHODS tr_get_objects
      IMPORTING
        trkorr        TYPE clike
      RETURNING
        VALUE(result) TYPE ty_t_tr_object.

    CLASS-METHODS tr_get_user_requests
      IMPORTING
        !user         TYPE clike DEFAULT sy-uname
        request_type  TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE ty_t_tr_request.

    CLASS-METHODS tr_get_description
      IMPORTING
        trkorr        TYPE clike
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS tr_is_released
      IMPORTING
        trkorr        TYPE clike
      RETURNING
        VALUE(result) TYPE abap_bool.

    CLASS-METHODS tr_add_object
      IMPORTING
        trkorr  TYPE clike
        pgmid   TYPE clike DEFAULT 'R3TR'
        object  TYPE clike
        obj_name TYPE clike.

    CLASS-METHODS tr_create
      IMPORTING
        text          TYPE clike
        target        TYPE clike
        type          TYPE clike DEFAULT `T`
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS tr_release
      IMPORTING
        trkorr       TYPE clike
        ignore_locks TYPE abap_bool DEFAULT abap_true.

    CLASS-METHODS tr_copy_objects
      IMPORTING
        source      TYPE clike
        destination TYPE clike.

    CLASS-METHODS tr_import
      IMPORTING
        trkorr         TYPE clike
        target_system  TYPE clike
        client         TYPE clike OPTIONAL
        ignore_version TYPE abap_bool DEFAULT abap_true
      RETURNING
        VALUE(result)  TYPE i.

    CLASS-METHODS tr_check_status
      IMPORTING
        trkorr   TYPE clike
        system   TYPE clike
      EXPORTING
        imported TYPE abap_bool
        rc       TYPE i.

    " ========== Enqueue/Dequeue Locks ==========

    TYPES:
      BEGIN OF ty_s_lock_param,
        name  TYPE c LENGTH 30,
        value TYPE string,
      END OF ty_s_lock_param.
    TYPES ty_t_lock_param TYPE STANDARD TABLE OF ty_s_lock_param WITH DEFAULT KEY.

    TYPES:
      BEGIN OF ty_s_lock,
        lock_object TYPE string,
        argument    TYPE string,
        user        TYPE string,
        mode        TYPE string,
        client      TYPE string,
        date        TYPE d,
        time        TYPE t,
        owner       TYPE string,
        owner_vb    TYPE string,
      END OF ty_s_lock.
    TYPES ty_t_lock TYPE STANDARD TABLE OF ty_s_lock WITH DEFAULT KEY.

    CLASS-METHODS lock_set
      IMPORTING
        val           TYPE clike
        t_param       TYPE ty_t_lock_param OPTIONAL
      RETURNING
        VALUE(result) TYPE abap_bool.

    CLASS-METHODS lock_set_wait
      IMPORTING
        val           TYPE clike
        t_param       TYPE ty_t_lock_param OPTIONAL
        retries       TYPE i DEFAULT 5
        delay_ms      TYPE i DEFAULT 500
      RETURNING
        VALUE(result) TYPE abap_bool.

    CLASS-METHODS lock_is_locked
      IMPORTING
        val           TYPE clike
        t_param       TYPE ty_t_lock_param OPTIONAL
      RETURNING
        VALUE(result) TYPE abap_bool.

    CLASS-METHODS lock_get_owner
      IMPORTING
        val           TYPE clike
        t_param       TYPE ty_t_lock_param OPTIONAL
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS lock_get_dequeue_by_enqueue
      IMPORTING
        val           TYPE clike
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS lock_read
      IMPORTING
        lock_object   TYPE clike OPTIONAL
        !user         TYPE clike OPTIONAL
        client        TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE ty_t_lock.

    CLASS-METHODS lock_delete
      IMPORTING
        val           TYPE clike
        t_param       TYPE ty_t_lock_param OPTIONAL
      RETURNING
        VALUE(result) TYPE abap_bool.

    CLASS-METHODS lock_delete_entries
      IMPORTING
        t_lock        TYPE ty_t_lock
      RETURNING
        VALUE(result) TYPE abap_bool.

    " ========== System Services ==========

    TYPES:
      BEGIN OF ty_s_changdoc,
        changenr  TYPE string,
        username  TYPE string,
        udate     TYPE d,
        utime     TYPE t,
        tcode     TYPE string,
        fieldname TYPE string,
        old_value TYPE string,
        new_value TYPE string,
        tabname   TYPE string,
        chngind   TYPE string,
      END OF ty_s_changdoc.
    TYPES ty_t_changdoc TYPE STANDARD TABLE OF ty_s_changdoc WITH DEFAULT KEY.

    CLASS-METHODS auth_check
      IMPORTING
        object        TYPE clike
        field         TYPE clike
        !value        TYPE clike
        activity      TYPE clike DEFAULT '03'
      RETURNING
        VALUE(result) TYPE abap_bool.

    CLASS-METHODS text_get
      IMPORTING
        msgid         TYPE clike
        msgno         TYPE clike
        v1            TYPE clike OPTIONAL
        v2            TYPE clike OPTIONAL
        v3            TYPE clike OPTIONAL
        v4            TYPE clike OPTIONAL
        langu         TYPE clike DEFAULT sy-langu
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS mail_send
      IMPORTING
        !to      TYPE string
        subject  TYPE string
        body     TYPE string
        html     TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(result) TYPE abap_bool.

    CLASS-METHODS job_submit_report
      IMPORTING
        report          TYPE clike
        variant         TYPE clike OPTIONAL
        start_immediate TYPE abap_bool DEFAULT abap_true
        job_name        TYPE clike OPTIONAL
      RETURNING
        VALUE(result)   TYPE string.

    CLASS-METHODS numrange_get_next
      IMPORTING
        object        TYPE clike
        subobject     TYPE clike DEFAULT `01`
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS changdoc_read
      IMPORTING
        objectclass   TYPE clike
        objectid      TYPE clike
        date_from     TYPE d DEFAULT '19000101'
        date_to       TYPE d DEFAULT '99991231'
      RETURNING
        VALUE(result) TYPE ty_t_changdoc.

    " ========== Source Code / Dev Tools ==========

    CLASS-METHODS source_get_method
      IMPORTING
        iv_classname  TYPE clike
        iv_methodname TYPE clike
      RETURNING
        VALUE(result) TYPE string_table.

    CLASS-METHODS source_get_method2
      IMPORTING
        iv_classname  TYPE clike
        iv_methodname TYPE clike
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS source_get_file_types
      RETURNING
        VALUE(result) TYPE string_table.

    CLASS-METHODS source_method_to_file
      IMPORTING
        it_source     TYPE string_table
      RETURNING
        VALUE(result) TYPE string.

    " ========== Calendar / Workdays ==========

    CLASS-METHODS cal_get_weekday
      IMPORTING
        !date         TYPE d
      RETURNING
        VALUE(result) TYPE i.

    CLASS-METHODS cal_is_weekend
      IMPORTING
        !date         TYPE d
      RETURNING
        VALUE(result) TYPE abap_bool.

    CLASS-METHODS cal_is_workday
      IMPORTING
        !date         TYPE d
        !calendar_id  TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE abap_bool.

    CLASS-METHODS cal_add_workdays
      IMPORTING
        !date         TYPE d
        !days         TYPE i
        !calendar_id  TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE d.

    CLASS-METHODS cal_count_workdays
      IMPORTING
        !date_from    TYPE d
        !date_to      TYPE d
        !calendar_id  TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE i.

    " ========== XLSX / ZIP ==========

    TYPES:
      BEGIN OF ty_s_zip_file,
        name    TYPE string,
        content TYPE xstring,
      END OF ty_s_zip_file.
    TYPES ty_t_zip_file TYPE STANDARD TABLE OF ty_s_zip_file WITH DEFAULT KEY.

    CLASS-METHODS conv_get_xlsx_by_itab
      IMPORTING
        val           TYPE ANY TABLE
      RETURNING
        VALUE(result) TYPE xstring.

    CLASS-METHODS conv_get_itab_by_xlsx
      IMPORTING
        val    TYPE xstring
      EXPORTING
        result TYPE REF TO data.

    CLASS-METHODS zip_pack
      IMPORTING
        !files        TYPE ty_t_zip_file
      RETURNING
        VALUE(result) TYPE xstring.

    CLASS-METHODS zip_unpack
      IMPORTING
        !val          TYPE xstring
      RETURNING
        VALUE(result) TYPE ty_t_zip_file.

    TYPES:
      BEGIN OF ty_s_http_response,
        code   TYPE i,
        reason TYPE string,
        body   TYPE string,
      END OF ty_s_http_response.

    TYPES:
      BEGIN OF ty_s_user_info,
        uname          TYPE string,
        name_formatted TYPE string,
        email          TYPE string,
        langu          TYPE string,
        timezone       TYPE string,
        date_format    TYPE string,
        decimal_format TYPE string,
      END OF ty_s_user_info.

    CLASS-METHODS c_escape_html
      IMPORTING
        val           TYPE clike
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS c_escape_json
      IMPORTING
        val           TYPE clike
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS c_levenshtein
      IMPORTING
        val1          TYPE clike
        val2          TYPE clike
      RETURNING
        VALUE(result) TYPE i.

    CLASS-METHODS url_encode
      IMPORTING
        val           TYPE clike
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS url_decode
      IMPORTING
        val           TYPE clike
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS regex_match
      IMPORTING
        val           TYPE clike
        regex         TYPE clike
      RETURNING
        VALUE(result) TYPE abap_bool.

    CLASS-METHODS regex_find_all
      IMPORTING
        val           TYPE clike
        regex         TYPE clike
      RETURNING
        VALUE(result) TYPE string_table.

    CLASS-METHODS regex_replace_all
      IMPORTING
        val           TYPE clike
        regex         TYPE clike
        new_val       TYPE clike
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS uuid_get_c36
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS uuid_conv_c32_to_c36
      IMPORTING
        val           TYPE clike
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS uuid_conv_c36_to_c32
      IMPORTING
        val           TYPE clike
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS uuid_conv_c32_to_c22
      IMPORTING
        val           TYPE clike
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS uuid_conv_c22_to_c32
      IMPORTING
        val           TYPE clike
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS itab_sum_by
      IMPORTING
        tab           TYPE ANY TABLE
        fieldname     TYPE clike
      RETURNING
        VALUE(result) TYPE decfloat34.

    CLASS-METHODS itab_distinct
      IMPORTING
        tab           TYPE ANY TABLE
        fieldname     TYPE clike
      RETURNING
        VALUE(result) TYPE string_table.

    CLASS-METHODS itab_group_sum_by
      IMPORTING
        tab           TYPE ANY TABLE
        group_by      TYPE clike
        sum_by        TYPE clike
      RETURNING
        VALUE(result) TYPE ty_t_name_value.

    CLASS-METHODS num_round
      IMPORTING
        val           TYPE decfloat34
        decimals      TYPE i DEFAULT 0
        mode          TYPE clike DEFAULT `HALF_UP`
      RETURNING
        VALUE(result) TYPE decfloat34.

    CLASS-METHODS file_get_mimetype
      IMPORTING
        val           TYPE clike
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS lang_sap_to_iso
      IMPORTING
        val           TYPE clike
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS lang_iso_to_sap
      IMPORTING
        val           TYPE clike
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS time_get_user_timezone
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS time_stampl_to_tz
      IMPORTING
        val  TYPE timestampl
        tz   TYPE clike DEFAULT `UTC`
      EXPORTING
        date TYPE d
        time TYPE t.

    CLASS-METHODS time_stampl_from_tz
      IMPORTING
        date          TYPE d
        time          TYPE t
        tz            TYPE clike DEFAULT `UTC`
      RETURNING
        VALUE(result) TYPE timestampl.

    CLASS-METHODS context_get_user_info
      IMPORTING
        uname         TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE ty_s_user_info.

    CLASS-METHODS cur_get_decimals
      IMPORTING
        val           TYPE clike
      RETURNING
        VALUE(result) TYPE i.

    CLASS-METHODS cur_amount_to_external
      IMPORTING
        val           TYPE decfloat34
        currency      TYPE clike OPTIONAL
        decimals      TYPE i DEFAULT -1
      RETURNING
        VALUE(result) TYPE decfloat34.

    CLASS-METHODS cur_amount_to_internal
      IMPORTING
        val           TYPE decfloat34
        currency      TYPE clike OPTIONAL
        decimals      TYPE i DEFAULT -1
      RETURNING
        VALUE(result) TYPE decfloat34.

    CLASS-METHODS unit_convert
      IMPORTING
        val           TYPE decfloat34
        unit_from     TYPE clike
        unit_to       TYPE clike
      RETURNING
        VALUE(result) TYPE decfloat34.

    CLASS-METHODS hash_calculate
      IMPORTING
        val           TYPE clike
        algorithm     TYPE clike DEFAULT `SHA256`
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS hash_hmac
      IMPORTING
        val           TYPE clike
        key           TYPE clike
        algorithm     TYPE clike DEFAULT `SHA256`
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS http_get
      IMPORTING
        url           TYPE clike
        t_header      TYPE ty_t_name_value OPTIONAL
      RETURNING
        VALUE(result) TYPE ty_s_http_response.

    CLASS-METHODS http_post
      IMPORTING
        url           TYPE clike
        body          TYPE clike
        content_type  TYPE clike DEFAULT `application/json`
        t_header      TYPE ty_t_name_value OPTIONAL
      RETURNING
        VALUE(result) TYPE ty_s_http_response.

    CLASS-METHODS db_check_table_exists
      IMPORTING
        val           TYPE clike
      RETURNING
        VALUE(result) TYPE abap_bool.

    CLASS-METHODS db_select_by_name
      IMPORTING
        tabname       TYPE clike
        where         TYPE clike OPTIONAL
        max_rows      TYPE i DEFAULT 0
      RETURNING
        VALUE(result) TYPE REF TO data.

    CLASS-METHODS db_count_by_name
      IMPORTING
        tabname       TYPE clike
        where         TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE i.

    CLASS-METHODS param_get_user_default
      IMPORTING
        val           TYPE clike
        uname         TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS job_get_status
      IMPORTING
        jobname       TYPE clike
        jobcount      TYPE clike
      RETURNING
        VALUE(result) TYPE string.


  PROTECTED SECTION.

    CLASS-METHODS rtti_get_class_descr_on_cloud
      IMPORTING
        classname     TYPE clike
      RETURNING
        VALUE(result) TYPE string.


    CLASS-METHODS msg_get_internal
      IMPORTING
        val           TYPE any
      RETURNING
        VALUE(result) TYPE ty_t_msg.

    CLASS-METHODS msg_get_by_oref
      IMPORTING
        val           TYPE any
      RETURNING
        VALUE(result) TYPE ty_t_msg.

    CLASS-METHODS check_is_rap_struct
      IMPORTING
        val           TYPE any
      RETURNING
        VALUE(result) TYPE abap_bool.

    CLASS-METHODS msg_get_rap
      IMPORTING
        val           TYPE any
        entity_name   TYPE string OPTIONAL
      RETURNING
        VALUE(result) TYPE ty_t_msg.

    CLASS-METHODS msg_get_rap_row
      IMPORTING
        val         TYPE any
        entity_name TYPE string OPTIONAL
      EXPORTING
        messages    TYPE ty_t_msg
        is_row      TYPE abap_bool.

    CLASS-METHODS msg_get_rap_element
      IMPORTING
        val           TYPE any
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS msg_get_rap_state_area
      IMPORTING
        val           TYPE any
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS msg_get_rap_action
      IMPORTING
        val           TYPE any
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS msg_get_rap_pid
      IMPORTING
        val           TYPE any
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS msg_get_rap_cid
      IMPORTING
        val           TYPE any
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS msg_get_rap_tky
      IMPORTING
        val           TYPE any
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS msg_get_rap_flatten
      IMPORTING
        val           TYPE any
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS get_comp_str
      IMPORTING
        val           TYPE any
        comp          TYPE clike
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS scan_flag_prefix
      IMPORTING
        val           TYPE any
        prefix        TYPE clike
      RETURNING
        VALUE(result) TYPE string_table.

    CLASS-METHODS msg_get_rap_meta
      IMPORTING
        val           TYPE any
      RETURNING
        VALUE(result) TYPE ty_t_name_value.

    CLASS-METHODS msg_get_rap_fail_text
      IMPORTING
        cause         TYPE i
      RETURNING
        VALUE(result) TYPE string.

    " What a rendered box stays inside. A data dump is a diagnostic, not a
    " report: a message box that carries 10.000 rows or follows a reference
    " graph until it runs out of stack helps nobody, and the roundtrip pays
    " for every character of it. Both limits are announced in the output
    " rather than applied silently.
    CONSTANTS cv_data_max_rows  TYPE i VALUE 100.
    CONSTANTS cv_data_max_depth TYPE i VALUE 5.
    " the headline is one line of a message box - what does not fit there is
    " in the details anyway
    CONSTANTS cv_data_max_text  TYPE i VALUE 200.

    "! Render any value into the HTML fragment the box details show. Depth
    "! is the recursion level, checked against cv_data_max_depth.
    CLASS-METHODS data_render
      IMPORTING
        val           TYPE any
        depth         TYPE i
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS data_render_tab
      IMPORTING
        val           TYPE any
        depth         TYPE i
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS data_render_struc
      IMPORTING
        val           TYPE any
        depth         TYPE i
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS data_render_oref
      IMPORTING
        val           TYPE any
        depth         TYPE i
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS data_render_dref
      IMPORTING
        val           TYPE any
        depth         TYPE i
      RETURNING
        VALUE(result) TYPE string.

    "! One named value as a list item - the shape a component of a
    "! structure and an attribute of an object both take.
    CLASS-METHODS data_render_item
      IMPORTING
        name          TYPE clike
        val           TYPE any
        depth         TYPE i
      RETURNING
        VALUE(result) TYPE string.

    "! The one line the box shows without the details being opened.
    CLASS-METHODS data_get_headline
      IMPORTING
        val           TYPE any
      RETURNING
        VALUE(result) TYPE string.

    "! Any elementary value as its text, and never an exception.
    CLASS-METHODS data_get_string
      IMPORTING
        val           TYPE any
      RETURNING
        VALUE(result) TYPE string.

    "! The text of an exception object, empty for every other object.
    CLASS-METHODS data_get_exc_text
      IMPORTING
        val           TYPE REF TO object
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS html_get_list
      IMPORTING
        items         TYPE string_table
        ordered       TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(result) TYPE string.

    "! Does this text carry HTML markup?
    CLASS-METHODS html_check
      IMPORTING
        val           TYPE clike
      RETURNING
        VALUE(result) TYPE abap_bool.

    "! HTML as the plain text behind it, capped at cv_data_max_text.
    CLASS-METHODS html_get_plain
      IMPORTING
        val           TYPE clike
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS _set_e071k
      IMPORTING
        ir_data       TYPE REF TO data
        iv_tabname    TYPE string
        is_transport  TYPE ty_s_transport
      RETURNING
        VALUE(result) TYPE REF TO data.

    CLASS-METHODS _set_e071
      IMPORTING
        iv_tabname    TYPE string
        is_transport  TYPE ty_s_transport
      RETURNING
        VALUE(result) TYPE REF TO data.

    CLASS-METHODS _get_e071k_tabkey
      IMPORTING
        line             TYPE any
        dfies            TYPE ty_t_dfies
      RETURNING
        VALUE(rv_tabkey) TYPE trobj_name.

    CLASS-METHODS _read_e070
      CHANGING
        mt_data TYPE ty_t_data.

    CLASS-METHODS set_mandt
      IMPORTING
        ir_data TYPE REF TO data.

    CLASS-METHODS rtti_get_t_attri_on_prem
      IMPORTING
        tabname       TYPE string
      RETURNING
        VALUE(result) TYPE ty_t_dfies.

    CLASS-METHODS rtti_get_t_attri_on_cloud
      IMPORTING
        tabname       TYPE string
      RETURNING
        VALUE(result) TYPE ty_t_dfies ##NEEDED.

  PRIVATE SECTION.

    CLASS-METHODS regex_create_matcher
      IMPORTING
        val           TYPE clike
        regex         TYPE clike
      RETURNING
        VALUE(result) TYPE REF TO object.

    CLASS-METHODS http_execute
      IMPORTING
        method        TYPE string
        url           TYPE string
        body          TYPE string
        content_type  TYPE string
        t_header      TYPE ty_t_name_value
      RETURNING
        VALUE(result) TYPE ty_s_http_response.

    CLASS-METHODS http_execute_cloud
      IMPORTING
        method        TYPE string
        url           TYPE string
        body          TYPE string
        content_type  TYPE string
        t_header      TYPE ty_t_name_value
      RETURNING
        VALUE(result) TYPE ty_s_http_response.

    CLASS-METHODS http_execute_std
      IMPORTING
        method        TYPE string
        url           TYPE string
        body          TYPE string
        content_type  TYPE string
        t_header      TYPE ty_t_name_value
      RETURNING
        VALUE(result) TYPE ty_s_http_response.


    CLASS-METHODS rtti_get_classes_intf_cloud
      IMPORTING
        val              TYPE clike
        read_description TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(result)    TYPE ty_t_classes.

    CLASS-METHODS rtti_get_classes_intf_std
      IMPORTING
        val              TYPE clike
        read_description TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(result)    TYPE ty_t_classes.

    CLASS-METHODS rtti_get_dtel_texts_by_ddic
      IMPORTING
        name        TYPE string
      EXPORTING
        texts       TYPE ty_s_data_element_text
        do_fallback TYPE abap_bool.

    CLASS-METHODS rtti_get_dtel_texts_by_xco
      IMPORTING
        name        TYPE string
      EXPORTING
        texts       TYPE ty_s_data_element_text
        do_fallback TYPE abap_bool.

    TYPES:
      BEGIN OF ty_s_bool_cache,
        typedescr TYPE REF TO cl_abap_typedescr,
        is_bool   TYPE abap_bool,
      END OF ty_s_bool_cache.

    CLASS-DATA mt_bool_cache TYPE HASHED TABLE OF ty_s_bool_cache WITH UNIQUE KEY typedescr.

    TYPES:
      BEGIN OF ty_s_attri_cache,
        absolute_name TYPE string,
        o_struct      TYPE REF TO cl_abap_structdescr,
        t_attri       TYPE cl_abap_structdescr=>component_table,
      END OF ty_s_attri_cache.

    CLASS-DATA mt_attri_cache TYPE HASHED TABLE OF ty_s_attri_cache WITH UNIQUE KEY absolute_name.

    " answers of rtti_check_class_exists, per roll area - the repository
    " lookup behind it is not free and the same names are asked again and
    " again by callers that probe for an optional class on every call.
    " A class created at runtime after a negative answer is the one caller
    " this cache can mislead, within one roll area only - same trade as
    " gv_check_cloud below
    TYPES:
      BEGIN OF ty_s_class_exists,
        name   TYPE string,
        exists TYPE abap_bool,
      END OF ty_s_class_exists.

    CLASS-DATA gt_class_exists TYPE HASHED TABLE OF ty_s_class_exists WITH UNIQUE KEY name.

    CLASS-METHODS filter_get_sql_cond_by_range
      IMPORTING
        fieldname     TYPE clike
        range         TYPE ty_s_range
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS filter_get_range_by_sql_cond
      IMPORTING
        val       TYPE clike
      EXPORTING
        fieldname TYPE string
        range     TYPE ty_s_range.

    CLASS-METHODS filter_sql_split_top_level
      IMPORTING
        val           TYPE clike
        sep           TYPE clike
      RETURNING
        VALUE(result) TYPE string_table.

    CLASS-METHODS filter_sql_strip_quotes
      IMPORTING
        val           TYPE clike
      RETURNING
        VALUE(result) TYPE string.

    CLASS-DATA gv_check_cloud TYPE abap_bool.
    CLASS-DATA gv_check_cloud_cached TYPE abap_bool.

    " Guards the cycle zabaputil_cx_util_error=>constructor -> uuid_get_c32 ->
    " RAISE zabaputil_cx_util_error -> ... see uuid_get_c32.
    CLASS-DATA gv_uuid_failed TYPE abap_bool.

    CLASS-METHODS bal_cloud_add_items
      IMPORTING
        log   TYPE REF TO object
        t_log TYPE zabaputil_cl_util_context=>ty_t_msg.

    CLASS-METHODS bal_cloud_build_filter
      IMPORTING
        object        TYPE clike
        subobject     TYPE clike
        id            TYPE clike
      RETURNING
        VALUE(result) TYPE REF TO object.

    CLASS-METHODS bal_std_msg_add
      IMPORTING
        handle TYPE any
        t_log  TYPE zabaputil_cl_util_context=>ty_t_msg.

    CLASS-METHODS bal_std_load_handles
      IMPORTING
        object        TYPE clike
        subobject     TYPE clike
        id            TYPE clike
      RETURNING
        VALUE(result) TYPE REF TO data.

    CLASS-METHODS bal_std_build_filter
      IMPORTING
        object        TYPE clike
        subobject     TYPE clike
        id            TYPE clike
      RETURNING
        VALUE(result) TYPE REF TO data.

    CLASS-METHODS bal_std_filter_add
      IMPORTING
        comp   TYPE clike
        value  TYPE clike
      CHANGING
        filter TYPE any.

    CLASS-METHODS bal_std_map_msg
      IMPORTING
        msg           TYPE any
      RETURNING
        VALUE(result) TYPE zabaputil_cl_util_context=>ty_s_msg.

    CLASS-METHODS lock_call_function
      IMPORTING
        val           TYPE clike
        t_param       TYPE ty_t_lock_param OPTIONAL
      RETURNING
        VALUE(result) TYPE abap_bool.

ENDCLASS.

CLASS zabaputil_cl_util_context IMPLEMENTATION.

  METHOD class_constructor.

    cv_char_util_newline        = cl_abap_char_utilities=>newline.
    cv_char_util_cr_lf          = cl_abap_char_utilities=>cr_lf.
    cv_char_util_horizontal_tab = cl_abap_char_utilities=>horizontal_tab.
    cv_char_util_charsize       = cl_abap_char_utilities=>charsize.
    cv_format_e_xml_attr        = cl_abap_format=>e_xml_attr.

    cv_typedescr_typekind_table      = cl_abap_typedescr=>typekind_table.
    cv_typedescr_typekind_dref       = cl_abap_typedescr=>typekind_dref.
    cv_typedescr_typekind_oref       = cl_abap_typedescr=>typekind_oref.
    cv_typedescr_typekind_struct1    = cl_abap_typedescr=>typekind_struct1.
    cv_typedescr_typekind_struct2    = cl_abap_typedescr=>typekind_struct2.
    cv_typedescr_typekind_date       = cl_abap_typedescr=>typekind_date.
    cv_typedescr_typekind_time       = cl_abap_typedescr=>typekind_time.
    cv_typedescr_typekind_packed     = cl_abap_typedescr=>typekind_packed.
    cv_typedescr_kind_struct         = cl_abap_typedescr=>kind_struct.
    cv_typedescr_kind_elem           = cl_abap_typedescr=>kind_elem.
    cv_typedescr_kind_ref            = cl_abap_typedescr=>kind_ref.
    cv_objectdescr_public            = cl_abap_objectdescr=>public.

  ENDMETHOD.

  METHOD db_rollback.

    ROLLBACK WORK.

  ENDMETHOD.

  METHOD boolean_abap_2_json.
      DATA temp323 TYPE string.

    IF boolean_check_by_data( val ) IS NOT INITIAL.
      
      IF val = abap_true.
        temp323 = `true`.
      ELSE.
        temp323 = `false`.
      ENDIF.
      result = temp323.
    ELSE.
      result = val.
    ENDIF.

  ENDMETHOD.

  METHOD boolean_check_by_data.
        DATA lo_descr TYPE REF TO cl_abap_typedescr.
        DATA lr_cache TYPE REF TO zabaputil_cl_util_context=>ty_s_bool_cache.
        DATA temp324 TYPE REF TO cl_abap_elemdescr.
        DATA lo_ele LIKE temp324.
        DATA temp325 TYPE zabaputil_cl_util_context=>ty_s_bool_cache.

    TRY.
        
        lo_descr = cl_abap_elemdescr=>describe_by_data( val ).

        " all supported boolean types are character-like flags, this check
        " filters out every other type before the cache lookup
        IF lo_descr->type_kind <> cl_abap_typedescr=>typekind_char.
          RETURN.
        ENDIF.

        " type descriptors are singletons, so the reference identifies the
        " type without converting/hashing the absolute name on every call
        
        READ TABLE mt_bool_cache REFERENCE INTO lr_cache
             WITH TABLE KEY typedescr = lo_descr.
        IF sy-subrc = 0.
          result = lr_cache->is_bool.
          RETURN.
        ENDIF.

        
        temp324 ?= lo_descr.
        
        lo_ele = temp324.
        result = boolean_check_by_name( lo_ele->get_relative_name( ) ).

        
        CLEAR temp325.
        temp325-typedescr = lo_descr.
        temp325-is_bool = result.
        INSERT temp325 INTO TABLE mt_bool_cache.

      CATCH cx_root ##NO_HANDLER.
    ENDTRY.

  ENDMETHOD.

  METHOD boolean_check_by_name.

    CASE val.
      WHEN `ABAP_BOOL`
          OR `XSDBOOLEAN`
          OR `FLAG`
          OR `XFLAG`
          OR `XFELD`
          OR `ABAP_BOOLEAN`
          OR `WDY_BOOLEAN`
          OR `BOOLE_D`
          OR `OS_BOOLEAN`.
        result = abap_true.
    ENDCASE.

  ENDMETHOD.

  METHOD check_bound_a_not_initial.
    DATA temp1 TYPE xsdboolean.

    IF val IS NOT BOUND.
      result = abap_false.
      RETURN.
    ENDIF.
    
    temp1 = boolc( check_unassign_initial( val ) = abap_false ).
    result = temp1.

  ENDMETHOD.

  METHOD check_unassign_initial.
    FIELD-SYMBOLS <any> TYPE data.
    DATA temp2 TYPE xsdboolean.

    IF val IS INITIAL.
      result = abap_true.
      RETURN.
    ENDIF.

    
    ASSIGN val->* TO <any>.

    
    temp2 = boolc( <any> IS INITIAL ).
    result = temp2.

  ENDMETHOD.

  METHOD conv_copy_ref_data.

    FIELD-SYMBOLS <from>   TYPE data.
    FIELD-SYMBOLS <result> TYPE data.

    IF rtti_check_ref_data( from ) IS NOT INITIAL.
      ASSIGN from->* TO <from>.
      IF <from> IS NOT ASSIGNED.
        " unbound data reference - nothing to copy, return an initial reference
        RETURN.
      ENDIF.
    ELSE.
      ASSIGN from TO <from>.
    ENDIF.
    CREATE DATA result LIKE <from>.
    ASSIGN result->* TO <result>.

    <result> = <from>.

  ENDMETHOD.

  METHOD conv_get_as_data_ref.

    GET REFERENCE OF val INTO result.

  ENDMETHOD.

  METHOD conv_get_xstring_by_data_uri.

    DATA lv_metadata TYPE string ##NEEDED.
    DATA lv_base64   TYPE string.

    SPLIT val AT `,` INTO lv_metadata lv_base64.
    result = conv_decode_x_base64( lv_base64 ).

  ENDMETHOD.

  METHOD c_trim.

    DATA temp326 TYPE string.
      DATA lv_before LIKE result.
    temp326 = val.
    result = temp326.
    " spaces and tabs alternate at either end (`\t \tx`) - one pass of each
    " leaves the inner layer standing, so strip until nothing changes
    DO 10 TIMES.
      
      lv_before = result.
      result = shift_left( shift_right( result ) ).
      result = shift_right( val = result
                            sub = cv_char_util_horizontal_tab ).
      result = shift_left( val = result
                           sub = cv_char_util_horizontal_tab ).
      IF result = lv_before.
        EXIT.
      ENDIF.
    ENDDO.

  ENDMETHOD.

  METHOD c_trim_lower.

    DATA temp327 TYPE string.
    temp327 = val.
    result = to_lower( c_trim( temp327 ) ).

  ENDMETHOD.

  METHOD c_trim_upper.

    DATA temp328 TYPE string.
    temp328 = val.
    result = to_upper( c_trim( temp328 ) ).

  ENDMETHOD.

  METHOD filter_itab.

    DATA ref TYPE REF TO data.
      DATA ls_filter LIKE LINE OF filter.
        FIELD-SYMBOLS <field> TYPE any.

    LOOP AT val REFERENCE INTO ref.

      
      LOOP AT filter INTO ls_filter.

        
        ASSIGN ref->(ls_filter-name) TO <field>.
        IF sy-subrc <> 0.
          CONTINUE.
        ENDIF.
        IF <field> NOT IN ls_filter-t_range.
          DELETE val.
          EXIT.
        ENDIF.

      ENDLOOP.

    ENDLOOP.

  ENDMETHOD.

  METHOD filter_get_multi_by_data.

    DATA temp329 TYPE abap_component_tab.
    DATA temp54 LIKE LINE OF temp329.
    DATA lr_comp LIKE REF TO temp54.
      DATA temp330 TYPE zabaputil_cl_util_context=>ty_s_filter_multi.
    temp329 = rtti_get_t_attri_by_any( val ).
    
    
    LOOP AT temp329 REFERENCE INTO lr_comp.
      
      CLEAR temp330.
      temp330-name = lr_comp->name.
      INSERT temp330 INTO TABLE result.
    ENDLOOP.

  ENDMETHOD.

  METHOD filter_get_range_by_token.

    DATA lv_value LIKE val.
    DATA lv_length TYPE i.
    lv_value = val.
    IF lv_value IS INITIAL.
      RETURN.
    ENDIF.
    
    lv_length = strlen( lv_value ) - 1.

    CASE lv_value(1).

      WHEN `=`.
        CLEAR result.
        result-sign = `I`.
        result-option = `EQ`.
        result-low = lv_value+1.
      WHEN `<`.
        IF lv_value+1(1) = `=`.
          CLEAR result.
          result-sign = `I`.
          result-option = `LE`.
          result-low = lv_value+2.
        ELSE.
          CLEAR result.
          result-sign = `I`.
          result-option = `LT`.
          result-low = lv_value+1.
        ENDIF.
      WHEN `>`.
        IF lv_value+1(1) = `=`.
          CLEAR result.
          result-sign = `I`.
          result-option = `GE`.
          result-low = lv_value+2.
        ELSE.
          CLEAR result.
          result-sign = `I`.
          result-option = `GT`.
          result-low = lv_value+1.
        ENDIF.

      WHEN `*`.
        IF lv_length > 0 AND lv_value+lv_length(1) = `*`.
          lv_value = substring( val = lv_value off = 1 len = lv_length - 1 ).
          CLEAR result.
          result-sign = `I`.
          result-option = `CP`.
          result-low = lv_value.
        ELSEIF lv_length = 0.
          " Single '*' means contains-pattern with empty value
          CLEAR result.
          result-sign = `I`.
          result-option = `CP`.
          result-low = ``.
        ENDIF.

      WHEN OTHERS.
        IF lv_value CS `...`.
          SPLIT lv_value AT `...` INTO result-low result-high.
          result-sign   = `I`.
          result-option = `BT`.
        ELSE.
          CLEAR result.
          result-sign = `I`.
          result-option = `EQ`.
          result-low = lv_value.
        ENDIF.

    ENDCASE.

  ENDMETHOD.

  METHOD filter_update_tokens.
    FIELD-SYMBOLS <temp331> TYPE zabaputil_cl_util_context=>ty_s_filter_multi.
DATA lr_filter LIKE REF TO <temp331>.
    DATA ls_token LIKE LINE OF lr_filter->t_token_removed.
      DATA temp332 TYPE zabaputil_cl_util_context=>ty_s_token.
    DATA lt_range TYPE zabaputil_cl_util_context=>ty_t_range.
    DATA temp55 LIKE LINE OF result.
    DATA temp56 LIKE sy-tabix.

    result = val.
    
    READ TABLE result WITH KEY name = name ASSIGNING <temp331>.
IF sy-subrc <> 0.
  ASSERT 1 = 0.
ENDIF.

GET REFERENCE OF <temp331> INTO lr_filter.
    
    LOOP AT lr_filter->t_token_removed INTO ls_token.
      DELETE lr_filter->t_token WHERE key = ls_token-key.
    ENDLOOP.

    LOOP AT lr_filter->t_token_added INTO ls_token.
      
      CLEAR temp332.
      temp332-key = ls_token-key.
      temp332-text = ls_token-text.
      temp332-visible = abap_true.
      temp332-editable = abap_true.
      INSERT temp332 INTO TABLE lr_filter->t_token.
    ENDLOOP.

    CLEAR lr_filter->t_token_removed.
    CLEAR lr_filter->t_token_added.

    
    
    
    temp56 = sy-tabix.
    READ TABLE result WITH KEY name = name INTO temp55.
    sy-tabix = temp56.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    lt_range = zabaputil_cl_util_context=>filter_get_range_t_by_token_t( temp55-t_token ).
    lr_filter->t_range = lt_range.

  ENDMETHOD.

  METHOD filter_get_range_t_by_token_t.

    DATA ls_token LIKE LINE OF val.
    LOOP AT val INTO ls_token.
      INSERT filter_get_range_by_token( ls_token-text ) INTO TABLE result.
    ENDLOOP.

  ENDMETHOD.

  METHOD filter_get_token_range_mapping.

    DATA temp333 TYPE zabaputil_cl_util_context=>ty_t_name_value.
    DATA temp334 LIKE LINE OF temp333.
    CLEAR temp333.
    
    temp334-n = `EQ`.
    temp334-v = `={LOW}`.
    INSERT temp334 INTO TABLE temp333.
    temp334-n = `LT`.
    temp334-v = `<{LOW}`.
    INSERT temp334 INTO TABLE temp333.
    temp334-n = `LE`.
    temp334-v = `<={LOW}`.
    INSERT temp334 INTO TABLE temp333.
    temp334-n = `GT`.
    temp334-v = `>{LOW}`.
    INSERT temp334 INTO TABLE temp333.
    temp334-n = `GE`.
    temp334-v = `>={LOW}`.
    INSERT temp334 INTO TABLE temp333.
    temp334-n = `CP`.
    temp334-v = `*{LOW}*`.
    INSERT temp334 INTO TABLE temp333.
    temp334-n = `BT`.
    temp334-v = `{LOW}...{HIGH}`.
    INSERT temp334 INTO TABLE temp333.
    temp334-n = `NB`.
    temp334-v = `!({LOW}...{HIGH})`.
    INSERT temp334 INTO TABLE temp333.
    temp334-n = `NE`.
    temp334-v = `!(={LOW})`.
    INSERT temp334 INTO TABLE temp333.
    temp334-n = `NP`.
    temp334-v = `!(*{LOW}*)`.
    INSERT temp334 INTO TABLE temp333.
    temp334-n = `!<leer>`.
    temp334-v = `!(<leer>)`.
    INSERT temp334 INTO TABLE temp333.
    temp334-n = `<leer>`.
    temp334-v = `<leer>`.
    INSERT temp334 INTO TABLE temp333.
    result = temp333.

  ENDMETHOD.

  METHOD filter_get_token_t_by_range_t.

    DATA lt_mapping TYPE zabaputil_cl_util_context=>ty_t_name_value.
    DATA temp335 TYPE ty_t_range.
    DATA lt_tab LIKE temp335.
    DATA temp336 LIKE LINE OF lt_tab.
    DATA lr_row LIKE REF TO temp336.
      DATA lv_value TYPE zabaputil_cl_util_context=>ty_s_name_value-v.
      DATA temp57 LIKE LINE OF lt_mapping.
      DATA temp58 LIKE sy-tabix.
      DATA temp337 TYPE zabaputil_cl_util_context=>ty_s_token.
    lt_mapping = filter_get_token_range_mapping( ).

    
    CLEAR temp335.
    
    lt_tab = temp335.

    itab_corresponding( EXPORTING val = val
                        CHANGING  tab = lt_tab ).

    
    
    LOOP AT lt_tab REFERENCE INTO lr_row.

      
      
      
      temp58 = sy-tabix.
      READ TABLE lt_mapping WITH KEY n = lr_row->option INTO temp57.
      sy-tabix = temp58.
      IF sy-subrc <> 0.
        ASSERT 1 = 0.
      ENDIF.
      lv_value = temp57-v.
      REPLACE `{LOW}`  IN lv_value WITH lr_row->low.
      REPLACE `{HIGH}` IN lv_value WITH lr_row->high.

      " an excluding row must not render like its including twin - negate the
      " token so the MultiInput shows the filter's real meaning
      IF lr_row->sign = `E`.
        lv_value = |!({ lv_value })|.
      ENDIF.

      
      CLEAR temp337.
      temp337-key = lv_value.
      temp337-text = lv_value.
      temp337-visible = abap_true.
      temp337-editable = abap_true.
      INSERT temp337 INTO TABLE result.
    ENDLOOP.

  ENDMETHOD.

  METHOD itab_filter_by_val.
    " TRANSPILER NOTE: ABAP CS is always case-insensitive, so the two match
    " branches below differ deliberately: ignore_case = abap_true uses
    " to_upper + CS (JS: toLowerCase().includes(toLowerCase())), the default
    " uses find( ) for a genuinely case-sensitive match (JS: plain includes()).
    FIELD-SYMBOLS <row>   TYPE any.
    FIELD-SYMBOLS <field> TYPE any.

    DATA temp338 TYPE string.
    DATA lv_search LIKE temp338.
    DATA lv_field_count TYPE i.
      DATA lv_tabix LIKE sy-tabix.
      DATA lv_check_found LIKE abap_false.
      DATA lv_index TYPE i.
          DATA lv_name LIKE LINE OF fields.
          DATA temp59 LIKE LINE OF fields.
          DATA temp60 LIKE sy-tabix.
        DATA lv_value TYPE string.
    IF ignore_case = abap_true.
      temp338 = to_upper( val ).
    ELSE.
      temp338 = val.
    ENDIF.
    
    lv_search = temp338.
    
    lv_field_count = lines( fields ).

    LOOP AT tab ASSIGNING <row>.

      
      lv_tabix = sy-tabix.
      
      lv_check_found = abap_false.
      
      lv_index = 1.
      DO.
        IF fields IS INITIAL.
          ASSIGN COMPONENT lv_index OF STRUCTURE <row> TO <field>.
          IF sy-subrc <> 0.
            IF lv_index = 1.
              " elementary line type (e.g. string_table) has no components -
              " match against the whole line instead of deleting every row
              ASSIGN <row> TO <field>.
            ELSE.
              EXIT.
            ENDIF.
          ENDIF.
        ELSE.
          IF lv_index > lv_field_count.
            EXIT.
          ENDIF.
          
          
          
          temp60 = sy-tabix.
          READ TABLE fields INDEX lv_index INTO temp59.
          sy-tabix = temp60.
          IF sy-subrc <> 0.
            ASSERT 1 = 0.
          ENDIF.
          lv_name = temp59.
          ASSIGN COMPONENT lv_name OF STRUCTURE <row> TO <field>.
          IF sy-subrc <> 0.
            lv_index = lv_index + 1.
            CONTINUE.
          ENDIF.
        ENDIF.

        
        lv_value = |{ <field> }|.
        IF ignore_case = abap_true.
          lv_value = to_upper( lv_value ).
          IF lv_value CS lv_search.
            lv_check_found = abap_true.
            EXIT.
          ENDIF.
        ELSEIF find( val = lv_value
                     sub = lv_search ) >= 0.
          " Case-sensitive: use find() because CS is always case-insensitive
          lv_check_found = abap_true.
          EXIT.
        ENDIF.

        lv_index = lv_index + 1.
      ENDDO.

      IF lv_check_found = abap_false.
        DELETE tab INDEX lv_tabix.
      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD itab_get_csv_by_itab.

    FIELD-SYMBOLS <tab> TYPE table.
    DATA lt_lines TYPE string_table.
    DATA lv_line TYPE string.
    DATA temp339 TYPE REF TO cl_abap_tabledescr.
    DATA tab LIKE temp339.
    DATA temp340 TYPE REF TO cl_abap_structdescr.
    DATA struc LIKE temp340.
    DATA temp341 TYPE abap_component_tab.
    DATA temp61 LIKE LINE OF temp341.
    DATA lr_comp LIKE REF TO temp61.
    DATA lr_row TYPE REF TO data.
      DATA lv_index TYPE i.
        FIELD-SYMBOLS <row> TYPE data.
        FIELD-SYMBOLS <field> TYPE any.
        DATA lv_field_val TYPE string.

    ASSIGN val TO <tab>.
    
    temp339 ?= cl_abap_typedescr=>describe_by_data( <tab> ).
    
    tab = temp339.

    
    temp340 ?= tab->get_table_line_type( ).
    
    struc = temp340.

    CLEAR lv_line.
    
    temp341 = struc->get_components( ).
    
    
    LOOP AT temp341 REFERENCE INTO lr_comp.
      lv_line = |{ lv_line }{ lr_comp->name };|.
    ENDLOOP.
    INSERT lv_line INTO TABLE lt_lines.

    
    LOOP AT <tab> REFERENCE INTO lr_row.

      CLEAR lv_line.
      
      lv_index = 1.
      DO.
        
        ASSIGN lr_row->* TO <row>.
        
        ASSIGN COMPONENT lv_index OF STRUCTURE <row> TO <field>.
        IF sy-subrc <> 0.
          EXIT.
        ENDIF.
        lv_index = lv_index + 1.
        
        lv_field_val = |{ <field> }|.
        REPLACE ALL OCCURRENCES OF `;` IN lv_field_val WITH `,`.
        lv_line = |{ lv_line }{ lv_field_val };|.
      ENDDO.
      INSERT lv_line INTO TABLE lt_lines.
    ENDLOOP.

    result = concat_lines_of( table = lt_lines sep = cv_char_util_cr_lf ).

  ENDMETHOD.

  METHOD itab_get_itab_by_csv.

    DATA lt_comp TYPE cl_abap_structdescr=>component_table.
    FIELD-SYMBOLS <tab> TYPE STANDARD TABLE.
    DATA lr_row TYPE REF TO data.

    TYPES temp1 TYPE STANDARD TABLE OF string WITH DEFAULT KEY.
DATA lt_rows TYPE temp1.
    TYPES temp2 TYPE STANDARD TABLE OF string WITH DEFAULT KEY.
DATA lt_cols TYPE temp2.
    DATA temp62 LIKE LINE OF lt_rows.
    DATA temp63 LIKE sy-tabix.
    DATA temp342 LIKE LINE OF lt_cols.
    DATA lr_col LIKE REF TO temp342.
      DATA lv_name TYPE string.
      DATA temp343 TYPE abap_componentdescr.
    DATA struc TYPE REF TO cl_abap_structdescr.
    DATA temp344 TYPE REF TO cl_abap_datadescr.
    DATA data LIKE temp344.
    DATA o_table_desc TYPE REF TO cl_abap_tabledescr.
    DATA temp345 LIKE LINE OF lt_rows.
    DATA lr_rows LIKE REF TO temp345.
        FIELD-SYMBOLS <row> TYPE data.
        FIELD-SYMBOLS <field> TYPE any.
    SPLIT val AT cv_char_util_newline INTO TABLE lt_rows.
    

    
    
    temp63 = sy-tabix.
    READ TABLE lt_rows INDEX 1 INTO temp62.
    sy-tabix = temp63.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    SPLIT temp62 AT `;` INTO TABLE lt_cols.

    
    
    LOOP AT lt_cols REFERENCE INTO lr_col.

      
      lv_name = c_trim_upper( lr_col->* ).
      REPLACE ALL OCCURRENCES OF ` ` IN lv_name WITH `_`.

      
      CLEAR temp343.
      temp343-name = lv_name.
      temp343-type = cl_abap_elemdescr=>get_c( 40 ).
      INSERT temp343 INTO TABLE lt_comp.
    ENDLOOP.

    
    struc = cl_abap_structdescr=>get( lt_comp ).
    
    temp344 ?= struc.
    
    data = temp344.
    
    o_table_desc = cl_abap_tabledescr=>create( p_line_type  = data
                                                     p_table_kind = cl_abap_tabledescr=>tablekind_std
                                                     p_unique     = abap_false ).

    CREATE DATA result TYPE HANDLE o_table_desc.
    ASSIGN result->* TO <tab>.
    DELETE lt_rows WHERE table_line IS INITIAL.

    
    
    LOOP AT lt_rows REFERENCE INTO lr_rows FROM 2.

      SPLIT lr_rows->* AT `;` INTO TABLE lt_cols.
      CREATE DATA lr_row TYPE HANDLE struc.

      LOOP AT lt_cols REFERENCE INTO lr_col.
        
        ASSIGN lr_row->* TO <row>.
        
        ASSIGN COMPONENT sy-tabix OF STRUCTURE <row> TO <field>.
        IF sy-subrc <> 0.
          EXIT.
        ENDIF.
        <field> = lr_col->*.
      ENDLOOP.

      INSERT <row> INTO TABLE <tab>.
    ENDLOOP.

  ENDMETHOD.

  METHOD json_parse.
        DATA x TYPE REF TO cx_root.
    TRY.

        zabaputil_cl_ajson=>parse( val )->to_abap( EXPORTING iv_corresponding = abap_true
                                               IMPORTING ev_container     = data ).

        
      CATCH cx_root INTO x.
        RAISE EXCEPTION TYPE zabaputil_cx_util_error
          EXPORTING
            val = x.
    ENDTRY.
  ENDMETHOD.

  METHOD json_stringify.
        DATA temp346 TYPE REF TO zabaputil_if_ajson.
        DATA li_ajson LIKE temp346.
        DATA x TYPE REF TO cx_root.
    TRY.

        
        temp346 ?= zabaputil_cl_ajson=>create_empty( ).
        
        li_ajson = temp346.
        result = li_ajson->set( iv_path = `/`
                                iv_val  = any )->stringify( ).

        
      CATCH cx_root INTO x.
        RAISE EXCEPTION TYPE zabaputil_cx_util_error
          EXPORTING
            val = x.
    ENDTRY.
  ENDMETHOD.

  METHOD rtti_check_class_exists.

    " cached per name - see gt_class_exists at the declaration
    DATA lv_name TYPE string.
    DATA lr_hit TYPE REF TO zabaputil_cl_util_context=>ty_s_class_exists.
    DATA temp347 TYPE zabaputil_cl_util_context=>ty_s_class_exists.
    lv_name = to_upper( val ).

    
    READ TABLE gt_class_exists REFERENCE INTO lr_hit WITH TABLE KEY name = lv_name.
    IF sy-subrc = 0.
      result = lr_hit->exists.
      RETURN.
    ENDIF.

    TRY.
        cl_abap_classdescr=>describe_by_name( EXPORTING  p_name         = val
                                              EXCEPTIONS type_not_found = 1 ).
        IF sy-subrc = 0.
          result = abap_true.
        ENDIF.

      CATCH cx_root ##NO_HANDLER.
    ENDTRY.

    
    CLEAR temp347.
    temp347-name = lv_name.
    temp347-exists = result.
    INSERT temp347 INTO TABLE gt_class_exists.

  ENDMETHOD.

  METHOD rtti_check_ref_data.
        DATA lo_typdescr TYPE REF TO cl_abap_typedescr.
        DATA temp348 TYPE REF TO cl_abap_refdescr.
        DATA lo_referenced TYPE REF TO cl_abap_typedescr.
        DATA temp3 TYPE xsdboolean.

    TRY.
        " a kind comparison, not a CAST probe: the cast raised
        " CX_SY_MOVE_CAST_ERROR for every NON-reference value, and the
        " non-reference is the COMMON case on this path (every value routed
        " through conv_copy_ref_data asks) - deciding a type question by
        " exception is orders of magnitude more expensive than comparing.
        " cl_abap_refdescr covers data and object references alike, and so
        " does kind_ref
        
        lo_typdescr = cl_abap_typedescr=>describe_by_data( val ).
        IF lo_typdescr->kind <> cl_abap_typedescr=>kind_ref.
          RETURN.
        ENDIF.
        " kind_ref covers object references too, and the one caller that
        " dereferences on a true answer (conv_copy_ref_data: `from->*`)
        " cannot do that to an object reference. Only a reference to DATA
        " answers true
        
        temp348 ?= lo_typdescr.
        
        lo_referenced = temp348->get_referenced_type( ).
        
        temp3 = boolc( lo_referenced->kind <> cl_abap_typedescr=>kind_class AND lo_referenced->kind <> cl_abap_typedescr=>kind_intf ).
        result = temp3.
      CATCH cx_root ##NO_HANDLER.
    ENDTRY.

  ENDMETHOD.

  METHOD rtti_check_type_kind_dref.

    DATA lv_type_kind TYPE abap_typekind.
    DATA temp4 TYPE xsdboolean.
    lv_type_kind = cl_abap_datadescr=>get_data_type_kind( val ).
    
    temp4 = boolc( lv_type_kind = cl_abap_typedescr=>typekind_dref ).
    result = temp4.

  ENDMETHOD.

  METHOD rtti_get_classname_by_ref.
    DATA lv_classname TYPE abap_abstypename.

    " an unbound reference has no class - answer with an empty name instead
    " of letting the RTTI call fail. Callers ask this while rendering (error
    " context, response header), where a half-built object graph is normal
    IF val IS NOT BOUND.
      RETURN.
    ENDIF.

    
    lv_classname = cl_abap_classdescr=>get_class_name( val ).
    result = substring_after( val = lv_classname
                              sub = `\CLASS=` ).

  ENDMETHOD.

  METHOD rtti_get_intfname_by_ref.

    DATA rtti TYPE REF TO cl_abap_typedescr.
    DATA temp349 TYPE REF TO cl_abap_refdescr.
    DATA ref LIKE temp349.
    DATA name TYPE abap_abstypename.
    rtti = cl_abap_typedescr=>describe_by_data( in  ).
    
    temp349 ?= rtti.
    
    ref = temp349.
    
    name = ref->get_referenced_type( )->absolute_name.
    result = substring_after( val = name
                              sub = `\INTERFACE=` ).

  ENDMETHOD.

  METHOD rtti_get_type_kind.

    result = cl_abap_datadescr=>get_data_type_kind( val ).

  ENDMETHOD.

  METHOD rtti_get_type_name.
        DATA lo_descr TYPE REF TO cl_abap_typedescr.
        DATA temp350 TYPE REF TO cl_abap_elemdescr.
        DATA lo_ele LIKE temp350.
    TRY.

        
        lo_descr = cl_abap_elemdescr=>describe_by_data( val ).
        
        temp350 ?= lo_descr.
        
        lo_ele = temp350.
        result = lo_ele->get_relative_name( ).

      CATCH cx_root ##NO_HANDLER.
    ENDTRY.
  ENDMETHOD.

  METHOD rtti_get_t_attri_by_include.

    DATA type_desc TYPE REF TO cl_abap_typedescr.
    DATA temp351 TYPE REF TO cl_abap_structdescr.
    DATA sdescr LIKE temp351.
    DATA comps TYPE abap_component_tab.
    cl_abap_typedescr=>describe_by_name( EXPORTING  p_name         = type->absolute_name
                                         RECEIVING  p_descr_ref    = type_desc
                                         EXCEPTIONS type_not_found = 1 ).
    " classic exception method: a missing type sets sy-subrc and leaves the
    " ref unbound instead of raising - check it, or get_components below
    " dumps with CX_SY_REF_IS_INITIAL
    IF sy-subrc <> 0 OR type_desc IS NOT BOUND.
      RAISE EXCEPTION TYPE zabaputil_cx_util_error
        EXPORTING
          val = |Include type '{ type->absolute_name }' not found|.
    ENDIF.
    
    temp351 ?= type_desc.
    
    sdescr = temp351.
    
    comps = sdescr->get_components( ).
    result = expand_components( val   = comps
                                depth = depth ).

  ENDMETHOD.

  METHOD expand_components.
    DATA temp352 LIKE LINE OF val.
    DATA lr_comp LIKE REF TO temp352.
        DATA lt_incl TYPE abap_component_tab.

    " see the declaration: bounded so a cyclic include chain surfaces as a
    " readable error instead of a stack-overflow dump. 16 nested include
    " levels is far beyond any real DDIC structure
    IF depth > 16.
      RAISE EXCEPTION TYPE zabaputil_cx_util_error
        EXPORTING
          val = `RTTI_INCLUDE_RECURSION - include expansion exceeded 16 levels (cyclic include?)`.
    ENDIF.

    
    
    LOOP AT val REFERENCE INTO lr_comp.
      IF lr_comp->as_include = abap_true.
        
        lt_incl = rtti_get_t_attri_by_include( type  = lr_comp->type
                                                     depth = depth + 1 ).
        APPEND LINES OF lt_incl TO result.
      ELSE.
        APPEND lr_comp->* TO result.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD rtti_get_t_attri_by_oref.

    DATA lo_obj_ref TYPE REF TO cl_abap_typedescr.
    DATA temp353 TYPE REF TO cl_abap_classdescr.
    lo_obj_ref = cl_abap_objectdescr=>describe_by_object_ref( val ).
    
    temp353 ?= lo_obj_ref.
    result = temp353->attributes.

  ENDMETHOD.

  METHOD rtti_get_t_attri_by_any.

    DATA lo_struct        TYPE REF TO cl_abap_structdescr.
    DATA lo_type          TYPE REF TO cl_abap_typedescr.
    " declared, not CONV string( ) - see error_get_attributes
    DATA lv_absolute_name TYPE string.
        DATA temp354 TYPE REF TO cl_abap_structdescr.
        DATA temp355 TYPE REF TO cl_abap_structdescr.
        DATA temp64 TYPE REF TO cl_abap_tabledescr.
    DATA lr_cache TYPE REF TO zabaputil_cl_util_context=>ty_s_attri_cache.
    DATA comps TYPE abap_component_tab.
      DATA temp356 TYPE zabaputil_cl_util_context=>ty_s_attri_cache.

    TRY.
        lo_type = cl_abap_typedescr=>describe_by_data( val ).
        IF lo_type->kind = cl_abap_typedescr=>kind_ref.
          lo_type = cl_abap_typedescr=>describe_by_data_ref( val ).
        ENDIF.
      CATCH cx_root.
        TRY.
            lo_type = cl_abap_typedescr=>describe_by_data_ref( val ).
          CATCH cx_root.
            lo_type = cl_abap_structdescr=>describe_by_name( val ).
        ENDTRY.
    ENDTRY.

    CASE lo_type->kind.
      WHEN cl_abap_typedescr=>kind_struct.
        
        temp354 ?= lo_type.
        lo_struct = temp354.
      WHEN cl_abap_typedescr=>kind_table.
        
        
        temp64 ?= lo_type.
        temp355 ?= temp64->get_table_line_type( ).
        lo_struct = temp355.
      WHEN OTHERS.
        lo_struct ?= lo_type.
    ENDCASE.

    " descriptor instances are singletons per type, so the identity check
    " guards against absolute names reused by other (local/anonymous) types
    lv_absolute_name = lo_struct->absolute_name.
    
    READ TABLE mt_attri_cache REFERENCE INTO lr_cache
         WITH TABLE KEY absolute_name = lv_absolute_name.
    IF sy-subrc = 0 AND lr_cache->o_struct = lo_struct.
      result = lr_cache->t_attri.
      RETURN.
    ENDIF.

    
    comps = lo_struct->get_components( ).
    result = expand_components( comps ).

    IF lr_cache IS BOUND.
      lr_cache->o_struct = lo_struct.
      lr_cache->t_attri  = result.
    ELSE.
      
      CLEAR temp356.
      temp356-absolute_name = lv_absolute_name.
      temp356-o_struct = lo_struct.
      temp356-t_attri = result.
      INSERT temp356 INTO TABLE mt_attri_cache.
    ENDIF.

  ENDMETHOD.

  METHOD rtti_get_t_ddic_fixed_values.
        DATA temp357 TYPE string.
        DATA typedescr TYPE REF TO cl_abap_typedescr.
        DATA temp358 TYPE REF TO cl_abap_elemdescr.
        DATA elemdescr LIKE temp358.

    IF rollname IS INITIAL.
      RETURN.
    ENDIF.

    TRY.

        
        temp357 = rollname.
        
        cl_abap_typedescr=>describe_by_name( EXPORTING  p_name         = temp357
                                             RECEIVING  p_descr_ref    = typedescr
                                             EXCEPTIONS type_not_found = 1
                                                        OTHERS         = 2 ).
        IF sy-subrc <> 0.
          RETURN.
        ENDIF.

        
        temp358 ?= typedescr.
        
        elemdescr = temp358.

        result = rtti_get_t_fixvalues( elemdescr = elemdescr
                                       langu     = langu ).

      CATCH cx_root ##NO_HANDLER.
    ENDTRY.

  ENDMETHOD.

  METHOD rtti_tab_get_relative_name.

    FIELD-SYMBOLS <table> TYPE any.
        DATA typedesc TYPE REF TO cl_abap_typedescr.
            DATA temp359 TYPE REF TO cl_abap_tabledescr.
            DATA tabledesc LIKE temp359.
            DATA temp360 TYPE REF TO cl_abap_structdescr.
            DATA structdesc LIKE temp360.

    TRY.
        
        typedesc = cl_abap_typedescr=>describe_by_data( table ).

        CASE typedesc->kind.

          WHEN cl_abap_typedescr=>kind_table.
            
            temp359 ?= typedesc.
            
            tabledesc = temp359.
            
            temp360 ?= tabledesc->get_table_line_type( ).
            
            structdesc = temp360.
            result = structdesc->get_relative_name( ).
            RETURN.

          WHEN typedesc->kind_ref.

            ASSIGN table->* TO <table>.
            result = rtti_tab_get_relative_name( <table> ).

        ENDCASE.
      CATCH cx_root ##NO_HANDLER.
    ENDTRY.

  ENDMETHOD.

  METHOD conv_exit.

    DATA temp361 TYPE string.
    DATA conex LIKE temp361.
    IF output = abap_true.
      temp361 = |CONVERSION_EXIT_{ convexit }_OUTPUT|.
    ELSE.
      temp361 = |CONVERSION_EXIT_{ convexit }_INPUT|.
    ENDIF.
    
    conex = temp361.

    TRY.
        IF convexit = `CUNIT`.

          CALL FUNCTION conex
            EXPORTING
              input    = value
              language = sy-langu
            IMPORTING
              output   = value
            EXCEPTIONS
              OTHERS   = 99.

        ELSE.

          CALL FUNCTION conex
            EXPORTING
              input  = value
            IMPORTING
              output = value
            EXCEPTIONS
              OTHERS = 99.

        ENDIF.

      CATCH cx_root ##NO_HANDLER.
    ENDTRY.

  ENDMETHOD.

  METHOD convexit_ext.
      DATA conv TYPE string.
      DATA conex TYPE c LENGTH 30.
      DATA lv_tab TYPE c LENGTH 5.

    IF check_abap_cloud( ) IS NOT INITIAL.

    ELSE.

      
      conv = |CONVERSION_EXIT_{ name-convexit }_INPUT|.
      
      
      lv_tab = 'TFDIR'.

      SELECT SINGLE funcname FROM (lv_tab) INTO conex
        WHERE funcname = conv
        .

      IF sy-subrc = 0.

        CALL FUNCTION conex
          EXPORTING
            input         = val
          IMPORTING
            output        = result
          EXCEPTIONS
            error_message = 1
            OTHERS        = 2.
        IF sy-subrc <> 0.
          RAISE EXCEPTION TYPE zabaputil_cx_util_error.
        ENDIF.

      ENDIF.

    ENDIF.

  ENDMETHOD.

  METHOD filter_get_sql_by_sql_string.

    DATA temp362 TYPE string.
    DATA lv_sql LIKE temp362.
    DATA lv_squished LIKE lv_sql.
    DATA lv_dummy TYPE string.
    DATA lv_tab TYPE string.
    DATA lv_upper TYPE string.
      DATA lv_pos TYPE i.
    temp362 = val.
    
    lv_sql = temp362.

    
    lv_squished = lv_sql.
    REPLACE ALL OCCURRENCES OF ` ` IN lv_squished WITH ``.
    lv_squished = to_upper( lv_squished ).
    
    
    SPLIT lv_squished AT `SELECTFROM` INTO lv_dummy lv_tab.
    SPLIT lv_tab AT `FIELDS` INTO lv_tab lv_dummy.
    SPLIT lv_tab AT `WHERE` INTO lv_tab lv_dummy.

    result-tabname = lv_tab.

    
    lv_upper = to_upper( lv_sql ).
    IF lv_upper CS ` WHERE `.
      
      lv_pos = sy-fdpos + 7.
      result-where = c_trim( substring( val = lv_sql
                                        off = lv_pos ) ).
      result-t_filter = filter_get_multi_by_sql_where( result-where ).
    ENDIF.

  ENDMETHOD.

  METHOD time_get_date_by_stampl.
    DATA ls_sy TYPE zabaputil_cl_util_context=>ty_syst.
    DATA lv_dummy TYPE t.
    ls_sy = zabaputil_cl_util_context=>context_get_sy( ).
    
    CONVERT TIME STAMP val TIME ZONE ls_sy-zonlo INTO DATE result TIME lv_dummy.
  ENDMETHOD.

  METHOD time_get_timestampl.
    GET TIME STAMP FIELD result.
  ENDMETHOD.

  METHOD time_get_time_by_stampl.
    DATA ls_sy TYPE zabaputil_cl_util_context=>ty_syst.
    DATA lv_dummy TYPE d.
    ls_sy = zabaputil_cl_util_context=>context_get_sy( ).
    
    CONVERT TIME STAMP val TIME ZONE ls_sy-zonlo INTO DATE lv_dummy TIME result.
  ENDMETHOD.

  METHOD time_subtract_seconds.

    result = cl_abap_tstmp=>subtractsecs( tstmp = time
                                          secs  = seconds ).

  ENDMETHOD.

  METHOD unassign_data.

    FIELD-SYMBOLS <unassign> TYPE any.

    " IS ASSIGNED, not sy-subrc: on some runtimes ASSIGN ref->* of an
    " unbound reference leaves sy-subrc untouched, so a stale value from an
    " earlier statement decided the answer - a stale 4 read as "not
    " assigned" and a stale 0 let the initial field symbol through. The
    " symbol is declared fresh in this method and assigned exactly once, so
    " no UNASSIGN is needed before the test
    ASSIGN val->* TO <unassign>.
    IF <unassign> IS NOT ASSIGNED.
      RETURN.
    ENDIF.
    result = <unassign>.

  ENDMETHOD.

  METHOD unassign_object.

    FIELD-SYMBOLS <unassign> TYPE any.

    " same reasoning as unassign_data directly above
    ASSIGN val->* TO <unassign>.
    IF <unassign> IS NOT ASSIGNED.
      RETURN.
    ENDIF.
    result = <unassign>.

  ENDMETHOD.

  METHOD url_param_create_url.

    DATA ls_param LIKE LINE OF t_params.
    LOOP AT t_params INTO ls_param.
      result = |{ result }{ ls_param-n }={ ls_param-v }&|.
    ENDLOOP.
    result = shift_right( val = result
                          sub = `&` ).

  ENDMETHOD.

  METHOD url_param_get.

    DATA lt_params TYPE zabaputil_cl_util_context=>ty_t_name_value.
    DATA lv_val TYPE string.
    DATA temp363 TYPE string.
    DATA temp364 TYPE zabaputil_cl_util_context=>ty_s_name_value.
    lt_params = url_param_get_tab( url ).
    
    lv_val = c_trim_lower( val ).
    
    CLEAR temp363.
    
    READ TABLE lt_params INTO temp364 WITH KEY n = lv_val.
    IF sy-subrc = 0.
      temp363 = temp364-v.
    ENDIF.
    result = temp363.

  ENDMETHOD.

  METHOD url_param_get_tab.

    " a full URL or a request URI carries a path before its query: cut at
    " the FIRST `?` only. A later `?` is a legal, unencoded character of a
    " value (`title=why?`) - cutting there dropped every parameter before
    " it, and the caller fell back to its defaults.
    " declared, not DATA( ) from a generic CLIKE parameter, which is
    " "fixed type STRING used for generic type CLIKE" in the extended check
    DATA lv_search TYPE string.
    DATA lv_startup TYPE string.
      DATA lv_packed TYPE string.
      DATA lv_rest TYPE string.
    TYPES temp3 TYPE STANDARD TABLE OF string WITH DEFAULT KEY.
DATA lt_param TYPE temp3.
    DATA temp365 LIKE LINE OF lt_param.
    DATA lr_param LIKE REF TO temp365.
      DATA lv_name TYPE string.
      DATA lv_value TYPE string.
      DATA temp366 TYPE zabaputil_cl_util_context=>ty_s_name_value.
    lv_search = val.
    IF lv_search CS `?`.
      lv_search = substring_after( val = lv_search
                                   sub = `?` ).
    ENDIF.

    " The FLP packs the target's own parameters into ONE value,
    " sap-startup-params, with its `=` and `&` percent-encoded. Prepend &
    " before searching so it is also unwrapped when it is the first/only
    " query parameter (typical FLP target mapping). Only THAT value is
    " decoded: decoding the whole query first tore every legitimately
    " encoded `&` or `=` in any other value apart (`a=x%26y` became the
    " two parameters a=x and y=), and url_param_create_url wrote the
    " damage back into every generated link
    
    lv_startup = substring_after( val = |&{ lv_search }|
                                        sub = `&sap-startup-params=` ).
    IF lv_startup IS NOT INITIAL.
      
      
      SPLIT lv_startup AT `&` INTO lv_packed lv_rest.
      lv_packed = replace( val  = lv_packed
                           sub  = `%3D`
                           with = `=`
                           occ  = 0 ).
      " RFC 3986 allows lowercase hex digits in percent-encodings, so decode
      " %3d the same way as %3D (%26 contains no letters and needs no twin)
      lv_packed = replace( val  = lv_packed
                           sub  = `%3d`
                           with = `=`
                           occ  = 0 ).
      lv_packed = replace( val  = lv_packed
                           sub  = `%26`
                           with = `&`
                           occ  = 0 ).
      lv_search = lv_packed.
      IF lv_rest IS NOT INITIAL.
        lv_search = |{ lv_packed }&{ lv_rest }|.
      ENDIF.
    ENDIF.

    

    SPLIT lv_search AT `&` INTO TABLE lt_param.

    
    
    LOOP AT lt_param REFERENCE INTO lr_param.
      
      
      SPLIT lr_param->* AT `=` INTO lv_name lv_value.
      " an empty segment (empty search string, trailing &) would otherwise
      " produce a phantom nameless parameter that url_param_create_url
      " writes back out as a stray `=&`
      IF lv_name IS INITIAL.
        CONTINUE.
      ENDIF.
      " normalize the name so lookups are case-insensitive on every input
      " shape (with or without a leading path/question mark) - the value
      " keeps its original case
      
      CLEAR temp366.
      temp366-n = c_trim_lower( lv_name ).
      temp366-v = lv_value.
      INSERT temp366 INTO TABLE result.
    ENDLOOP.

  ENDMETHOD.

  METHOD url_param_set.

    DATA lt_params TYPE zabaputil_cl_util_context=>ty_t_name_value.
    DATA lv_n TYPE string.
    DATA lv_v TYPE string.
    DATA temp367 LIKE LINE OF lt_params.
    DATA lr_params LIKE REF TO temp367.
      DATA temp368 TYPE zabaputil_cl_util_context=>ty_s_name_value.
    lt_params = url_param_get_tab( url ).
    
    lv_n = c_trim_lower( name ).
    
    lv_v = c_trim( value ).

    
    
    LOOP AT lt_params REFERENCE INTO lr_params
         WHERE n = lv_n.
      lr_params->v = lv_v.
    ENDLOOP.
    IF sy-subrc <> 0.
      
      CLEAR temp368.
      temp368-n = lv_n.
      temp368-v = lv_v.
      INSERT temp368 INTO TABLE lt_params.
    ENDIF.

    result = url_param_create_url( lt_params ).

  ENDMETHOD.

  METHOD xml_parse.

    IF xml IS INITIAL.
      CLEAR any.
      RETURN.
    ENDIF.

    CALL TRANSFORMATION id
         SOURCE XML xml
         RESULT data = any.

  ENDMETHOD.

  METHOD xml_srtti_parse.

    DATA srtti TYPE REF TO object.
    DATA rtti_type TYPE REF TO cl_abap_typedescr.
    DATA lo_datadescr TYPE REF TO cl_abap_datadescr.
    FIELD-SYMBOLS <variable> TYPE data.
    CALL TRANSFORMATION id SOURCE XML rtti_data RESULT srtti = srtti.

    
    CALL METHOD srtti->(`GET_RTTI`)
      RECEIVING
        rtti = rtti_type.

    
    lo_datadescr ?= rtti_type.

    CREATE DATA result TYPE HANDLE lo_datadescr.
    
    ASSIGN result->* TO <variable>.
    CALL TRANSFORMATION id SOURCE XML rtti_data RESULT dobj = <variable>.

  ENDMETHOD.

  METHOD xml_srtti_stringify.
      DATA srtti TYPE REF TO object.
      DATA lv_classname TYPE string.
          DATA lx_srtti TYPE REF TO cx_root.
          DATA lv_text TYPE string.

    IF rtti_check_class_exists( `ZCL_SRTTI_TYPEDESCR` ) = abap_true.

      
      
      lv_classname = `ZCL_SRTTI_TYPEDESCR`.
      CALL METHOD (lv_classname)=>(`CREATE_BY_DATA_OBJECT`)
        EXPORTING
          data_object = data
        RECEIVING
          srtti       = srtti.
      CALL TRANSFORMATION id SOURCE srtti = srtti dobj = data RESULT XML result.

    ELSE.

      TRY.
          CALL METHOD zabaputil_cl_srt_typedescr=>(`CREATE_BY_DATA_OBJECT`)
            EXPORTING
              data_object = data
            RECEIVING
              srtti       = srtti.
          CALL TRANSFORMATION id SOURCE srtti = srtti dobj = data RESULT XML result.

          
        CATCH cx_root INTO lx_srtti.

          " keep the root cause - a transformation error on the caller's own
          " data must not be masked behind a bare UNSUPPORTED_FEATURE
          
          lv_text = `UNSUPPORTED_FEATURE`.
          RAISE EXCEPTION TYPE zabaputil_cx_util_error
            EXPORTING
              val      = lv_text
              previous = lx_srtti.

      ENDTRY.
    ENDIF.

  ENDMETHOD.

  METHOD xml_stringify.

    CALL TRANSFORMATION id
         SOURCE data = any
         RESULT XML result
         OPTIONS data_refs = `heap-or-create`.

  ENDMETHOD.

  METHOD x_check_raise.

    IF when = abap_true.
      RAISE EXCEPTION TYPE zabaputil_cx_util_error
        EXPORTING
          val = v.
    ENDIF.

  ENDMETHOD.

  METHOD x_get_last_t100.

    DATA x LIKE val.
    x = val.
    DO.

      IF x->previous IS BOUND.
        x = x->previous.
        CONTINUE.
      ENDIF.

      EXIT.
    ENDDO.

    result = x->get_text( ).

  ENDMETHOD.

  METHOD x_raise.

    RAISE EXCEPTION TYPE zabaputil_cx_util_error
      EXPORTING
        val = v.

  ENDMETHOD.

  METHOD rtti_get_t_attri_by_table_name.
        DATA lo_obj TYPE REF TO cl_abap_typedescr.
        DATA temp369 TYPE REF TO cl_abap_structdescr.
        DATA lo_struct LIKE temp369.
            DATA temp370 TYPE REF TO cl_abap_tabledescr.
            DATA lo_tab LIKE temp370.
            DATA temp371 TYPE REF TO cl_abap_structdescr.
    DATA lt_comps TYPE abap_component_tab.
    DATA temp372 LIKE LINE OF lt_comps.
    DATA lr_comp LIKE REF TO temp372.
        DATA lt_attri TYPE abap_component_tab.

    IF table_name IS INITIAL.
      RAISE EXCEPTION TYPE zabaputil_cx_util_error
        EXPORTING
          val = `TABLE_NAME_INITIAL_ERROR`.
    ENDIF.

    TRY.
        
        cl_abap_structdescr=>describe_by_name( EXPORTING  p_name         = table_name
                                               RECEIVING  p_descr_ref    = lo_obj
                                               EXCEPTIONS type_not_found = 1
                                                          OTHERS         = 2
            ).

        IF sy-subrc <> 0.
          RAISE EXCEPTION TYPE zabaputil_cx_util_error
            EXPORTING
              val = |TABLE_NOT_FOUD_NAME___{ table_name }|.
        ENDIF.
        
        temp369 ?= lo_obj.
        
        lo_struct = temp369.

      CATCH cx_root.

        TRY.
            cl_abap_structdescr=>describe_by_name( EXPORTING  p_name         = table_name
                                                   RECEIVING  p_descr_ref    = lo_obj
                                                   EXCEPTIONS type_not_found = 1
                                                              OTHERS         = 2
            ).
            IF sy-subrc <> 0.
              RAISE EXCEPTION TYPE zabaputil_cx_util_error
                EXPORTING
                  val = |TABLE_NOT_FOUD_NAME___{ table_name }|.
            ENDIF.

            
            temp370 ?= lo_obj.
            
            lo_tab = temp370.
            
            temp371 ?= lo_tab->get_table_line_type( ).
            lo_struct = temp371.
          CATCH cx_root.
            RETURN.
        ENDTRY.

    ENDTRY.

    
    lt_comps = lo_struct->get_components( ).

    
    
    LOOP AT lt_comps REFERENCE INTO lr_comp.
      IF lr_comp->as_include = abap_true.
        
        lt_attri = rtti_get_t_attri_by_include( lr_comp->type ).
        INSERT LINES OF lt_attri INTO TABLE result.
      ELSE.
        INSERT lr_comp->* INTO TABLE result.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD itab_corresponding.

    FIELD-SYMBOLS <row_in>  TYPE any.
    FIELD-SYMBOLS <row_out> TYPE any.

    LOOP AT val ASSIGNING <row_in>.
      APPEND INITIAL LINE TO tab ASSIGNING <row_out>.
      MOVE-CORRESPONDING <row_in> TO <row_out>.
    ENDLOOP.

  ENDMETHOD.

  METHOD itab_get_by_struc.

    DATA lt_attri TYPE abap_component_tab.
    DATA temp373 LIKE LINE OF lt_attri.
    DATA lr_attri LIKE REF TO temp373.
      FIELD-SYMBOLS <component> TYPE any.
          DATA temp374 TYPE zabaputil_cl_util_context=>ty_s_name_value.
    lt_attri = rtti_get_t_attri_by_any( val ).
    
    
    LOOP AT lt_attri REFERENCE INTO lr_attri.

      
      ASSIGN COMPONENT lr_attri->name OF STRUCTURE val TO <component>.
      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.

      CASE rtti_get_type_kind( <component> ).

        " skip components that cannot be moved into the string value: tables,
        " nested structures and references would raise an unhandled move
        " error at runtime
        WHEN cl_abap_typedescr=>typekind_table OR
             cl_abap_typedescr=>typekind_struct1 OR
             cl_abap_typedescr=>typekind_struct2 OR
             cl_abap_typedescr=>typekind_dref OR
             cl_abap_typedescr=>typekind_oref.

        WHEN OTHERS.
          
          CLEAR temp374.
          temp374-n = lr_attri->name.
          temp374-v = <component>.
          INSERT temp374 INTO TABLE result.
      ENDCASE.

    ENDLOOP.

  ENDMETHOD.

  METHOD itab_filter_by_t_range.

    DATA ref TYPE REF TO data.
      DATA ls_filter LIKE LINE OF val.
        FIELD-SYMBOLS <field> TYPE any.

    LOOP AT tab REFERENCE INTO ref.
      
      LOOP AT val INTO ls_filter.

        IF ls_filter-t_range IS INITIAL.
          CONTINUE.
        ENDIF.

        
        ASSIGN ref->(ls_filter-name) TO <field>.
        IF sy-subrc <> 0.
          CONTINUE.
        ENDIF.
        IF <field> NOT IN ls_filter-t_range.
          DELETE tab.
          EXIT.
        ENDIF.

      ENDLOOP.
    ENDLOOP.

  ENDMETHOD.

  METHOD filter_get_data_by_multi.

    DATA ls_filter LIKE LINE OF val.
    LOOP AT val INTO ls_filter.
      IF lines( ls_filter-t_range ) > 0
        OR lines( ls_filter-t_token ) > 0.
        INSERT ls_filter INTO TABLE result.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD filter_get_sql_where.

    DATA ls_filter LIKE LINE OF val.
      DATA lv_field_where TYPE string.
      DATA ls_range LIKE LINE OF ls_filter-t_range.
        DATA lv_cond TYPE string.
    LOOP AT val INTO ls_filter.

      IF ls_filter-t_range IS INITIAL.
        CONTINUE.
      ENDIF.

      
      lv_field_where = ``.
      
      LOOP AT ls_filter-t_range INTO ls_range.
        
        lv_cond = filter_get_sql_cond_by_range( fieldname = ls_filter-name
                                                      range     = ls_range ).
        IF lv_cond IS INITIAL.
          CONTINUE.
        ENDIF.
        IF lv_field_where IS INITIAL.
          lv_field_where = lv_cond.
        ELSE.
          lv_field_where = |{ lv_field_where } OR { lv_cond }|.
        ENDIF.
      ENDLOOP.

      IF lv_field_where IS INITIAL.
        CONTINUE.
      ENDIF.

      IF result IS INITIAL.
        result = |( { lv_field_where } )|.
      ELSE.
        result = |{ result } AND ( { lv_field_where } )|.
      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD filter_get_sql_cond_by_range.

    DATA lv_low TYPE string.
    DATA lv_high TYPE string.
    DATA lv_option LIKE range-option.
    DATA lv_like TYPE string.
    lv_low = replace( val  = range-low
                            sub  = `'`
                            with = `''`
                            occ  = 0 ).
    
    lv_high = replace( val  = range-high
                             sub  = `'`
                             with = `''`
                             occ  = 0 ).
    
    lv_option = range-option.

    IF range-sign = `E`.
      CASE lv_option.
        WHEN `EQ`. lv_option = `NE`.
        WHEN `NE`. lv_option = `EQ`.
        WHEN `LT`. lv_option = `GE`.
        WHEN `LE`. lv_option = `GT`.
        WHEN `GT`. lv_option = `LE`.
        WHEN `GE`. lv_option = `LT`.
        WHEN `CP`. lv_option = `NP`.
        WHEN `NP`. lv_option = `CP`.
        WHEN `BT`. lv_option = `NB`.
        WHEN `NB`. lv_option = `BT`.
      ENDCASE.
    ENDIF.

    
    lv_like = ``.
    CASE lv_option.
      WHEN `EQ`.
        result = |{ fieldname } = '{ lv_low }'|.
      WHEN `NE`.
        result = |{ fieldname } <> '{ lv_low }'|.
      WHEN `LT`.
        result = |{ fieldname } < '{ lv_low }'|.
      WHEN `LE`.
        result = |{ fieldname } <= '{ lv_low }'|.
      WHEN `GT`.
        result = |{ fieldname } > '{ lv_low }'|.
      WHEN `GE`.
        result = |{ fieldname } >= '{ lv_low }'|.
      WHEN `CP`.
        lv_like = lv_low.
        REPLACE ALL OCCURRENCES OF `*` IN lv_like WITH `%`.
        REPLACE ALL OCCURRENCES OF `+` IN lv_like WITH `_`.
        result = |{ fieldname } LIKE '{ lv_like }'|.
      WHEN `NP`.
        lv_like = lv_low.
        REPLACE ALL OCCURRENCES OF `*` IN lv_like WITH `%`.
        REPLACE ALL OCCURRENCES OF `+` IN lv_like WITH `_`.
        result = |{ fieldname } NOT LIKE '{ lv_like }'|.
      WHEN `BT`.
        result = |{ fieldname } BETWEEN '{ lv_low }' AND '{ lv_high }'|.
      WHEN `NB`.
        result = |{ fieldname } NOT BETWEEN '{ lv_low }' AND '{ lv_high }'|.
    ENDCASE.

  ENDMETHOD.

  METHOD filter_get_multi_by_sql_where.

    DATA temp375 TYPE string.
    DATA lv_where TYPE string.
    DATA lt_groups TYPE string_table.
    DATA lv_group LIKE LINE OF lt_groups.
      DATA lv_len TYPE i.
      DATA lt_conds TYPE string_table.
      DATA ls_filter TYPE ty_s_filter_multi.
      DATA lv_cond LIKE LINE OF lt_conds.
        DATA ls_range TYPE ty_s_range.
        DATA lv_fieldname TYPE string.
    temp375 = val.
    
    lv_where = c_trim( temp375 ).
    IF lv_where IS INITIAL.
      RETURN.
    ENDIF.

    
    lt_groups = filter_sql_split_top_level( val = lv_where
                                                  sep = ` AND ` ).

    
    LOOP AT lt_groups INTO lv_group.

      lv_group = c_trim( lv_group ).
      
      lv_len = strlen( lv_group ).

      IF lv_len >= 2
         AND lv_group(1) = `(`
         AND substring( val = lv_group
                        off = lv_len - 1
                        len = 1 ) = `)`.
        lv_group = c_trim( substring( val = lv_group
                                      off = 1
                                      len = lv_len - 2 ) ).
      ENDIF.

      
      lt_conds = filter_sql_split_top_level( val = lv_group
                                                   sep = ` OR ` ).

      
      CLEAR ls_filter.

      
      LOOP AT lt_conds INTO lv_cond.

        
        
        CLEAR ls_range.
        CLEAR lv_fieldname.

        filter_get_range_by_sql_cond(
          EXPORTING val       = c_trim( lv_cond )
          IMPORTING fieldname = lv_fieldname
                    range     = ls_range ).

        IF ls_range-option IS INITIAL.
          CONTINUE.
        ENDIF.

        IF ls_filter-name IS INITIAL.
          ls_filter-name = lv_fieldname.
        ENDIF.
        INSERT ls_range INTO TABLE ls_filter-t_range.

      ENDLOOP.

      IF ls_filter-name IS NOT INITIAL.
        INSERT ls_filter INTO TABLE result.
      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD filter_get_range_by_sql_cond.
    DATA temp376 TYPE string.
    DATA lv_cond LIKE temp376.
    DATA lv_rest TYPE string.
    DATA lv_low TYPE string.
    DATA lv_high TYPE string.
    DATA lv_like TYPE string.

    CLEAR range.
    CLEAR fieldname.

    
    temp376 = val.
    
    lv_cond = temp376.
    range-sign = `I`.

    
    
    
    

    IF lv_cond CS ` NOT BETWEEN `.
      SPLIT lv_cond AT ` NOT BETWEEN ` INTO fieldname lv_rest.
      SPLIT lv_rest AT ` AND ` INTO lv_low lv_high.
      range-option = `NB`.
      range-low    = filter_sql_strip_quotes( lv_low ).
      range-high   = filter_sql_strip_quotes( lv_high ).
      RETURN.
    ENDIF.

    IF lv_cond CS ` BETWEEN `.
      SPLIT lv_cond AT ` BETWEEN ` INTO fieldname lv_rest.
      SPLIT lv_rest AT ` AND ` INTO lv_low lv_high.
      range-option = `BT`.
      range-low    = filter_sql_strip_quotes( lv_low ).
      range-high   = filter_sql_strip_quotes( lv_high ).
      RETURN.
    ENDIF.

    IF lv_cond CS ` NOT LIKE `.
      SPLIT lv_cond AT ` NOT LIKE ` INTO fieldname lv_rest.
      lv_like = filter_sql_strip_quotes( lv_rest ).
      REPLACE ALL OCCURRENCES OF `%` IN lv_like WITH `*`.
      REPLACE ALL OCCURRENCES OF `_` IN lv_like WITH `+`.
      range-option = `NP`.
      range-low    = lv_like.
      RETURN.
    ENDIF.

    IF lv_cond CS ` LIKE `.
      SPLIT lv_cond AT ` LIKE ` INTO fieldname lv_rest.
      lv_like = filter_sql_strip_quotes( lv_rest ).
      REPLACE ALL OCCURRENCES OF `%` IN lv_like WITH `*`.
      REPLACE ALL OCCURRENCES OF `_` IN lv_like WITH `+`.
      range-option = `CP`.
      range-low    = lv_like.
      RETURN.
    ENDIF.

    IF lv_cond CS ` <> `.
      SPLIT lv_cond AT ` <> ` INTO fieldname lv_rest.
      range-option = `NE`.
      range-low    = filter_sql_strip_quotes( lv_rest ).
      RETURN.
    ENDIF.

    IF lv_cond CS ` <= `.
      SPLIT lv_cond AT ` <= ` INTO fieldname lv_rest.
      range-option = `LE`.
      range-low    = filter_sql_strip_quotes( lv_rest ).
      RETURN.
    ENDIF.

    IF lv_cond CS ` >= `.
      SPLIT lv_cond AT ` >= ` INTO fieldname lv_rest.
      range-option = `GE`.
      range-low    = filter_sql_strip_quotes( lv_rest ).
      RETURN.
    ENDIF.

    IF lv_cond CS ` < `.
      SPLIT lv_cond AT ` < ` INTO fieldname lv_rest.
      range-option = `LT`.
      range-low    = filter_sql_strip_quotes( lv_rest ).
      RETURN.
    ENDIF.

    IF lv_cond CS ` > `.
      SPLIT lv_cond AT ` > ` INTO fieldname lv_rest.
      range-option = `GT`.
      range-low    = filter_sql_strip_quotes( lv_rest ).
      RETURN.
    ENDIF.

    IF lv_cond CS ` = `.
      SPLIT lv_cond AT ` = ` INTO fieldname lv_rest.
      range-option = `EQ`.
      range-low    = filter_sql_strip_quotes( lv_rest ).
      RETURN.
    ENDIF.

  ENDMETHOD.

  METHOD filter_sql_split_top_level.

    DATA temp377 TYPE string.
    DATA lv_val LIKE temp377.
    DATA temp378 TYPE string.
    DATA lv_sep LIKE temp378.
    DATA lv_len TYPE i.
    DATA lv_sep_len TYPE i.
    DATA lv_depth TYPE i.
    DATA lv_start TYPE i.
    DATA lv_pos TYPE i.
    DATA lv_in_quote LIKE abap_false.
    DATA lv_in_between LIKE abap_false.
      DATA lv_char TYPE string.
    temp377 = val.
    
    lv_val = temp377.
    
    temp378 = sep.
    
    lv_sep = temp378.
    
    lv_len = strlen( lv_val ).
    
    lv_sep_len = strlen( lv_sep ).
    
    lv_depth = 0.
    
    lv_start = 0.
    
    lv_pos = 0.
    
    lv_in_quote = abap_false.
    
    lv_in_between = abap_false.

    IF lv_val IS INITIAL.
      RETURN.
    ENDIF.

    IF lv_sep_len = 0.
      INSERT lv_val INTO TABLE result.
      RETURN.
    ENDIF.

    WHILE lv_pos < lv_len.

      
      lv_char = lv_val+lv_pos(1).

      IF lv_char = `'`.
        IF lv_in_quote = abap_false.
          lv_in_quote = abap_true.
        ELSE.
          lv_in_quote = abap_false.
        ENDIF.
        lv_pos = lv_pos + 1.
        CONTINUE.
      ENDIF.

      IF lv_in_quote = abap_true.
        lv_pos = lv_pos + 1.
        CONTINUE.
      ENDIF.

      IF lv_char = `(`.
        lv_depth = lv_depth + 1.
        lv_pos = lv_pos + 1.
        CONTINUE.
      ENDIF.

      IF lv_char = `)`.
        lv_depth = lv_depth - 1.
        lv_pos = lv_pos + 1.
        CONTINUE.
      ENDIF.

      " Track BETWEEN ... AND to avoid splitting at the AND inside BETWEEN
      " Only check when current char is B or b (performance: skip to_upper on every pos)
      IF lv_depth = 0 AND lv_in_between = abap_false
         AND ( lv_char = `B` OR lv_char = `b` )
         AND lv_pos + 8 <= lv_len
         AND to_upper( lv_val+lv_pos(8) ) = `BETWEEN `.
        lv_in_between = abap_true.
        lv_pos = lv_pos + 8.
        CONTINUE.
      ENDIF.

      " The first AND after BETWEEN is the range AND, not a logical AND
      " Only check when current char is space (the ` AND ` pattern starts with space)
      IF lv_in_between = abap_true
         AND lv_char = ` `
         AND lv_pos + 5 <= lv_len
         AND to_upper( lv_val+lv_pos(5) ) = ` AND `.
        lv_in_between = abap_false.
        lv_pos = lv_pos + 5.
        CONTINUE.
      ENDIF.

      IF lv_depth = 0
         AND lv_in_between = abap_false
         AND lv_pos + lv_sep_len <= lv_len
         AND lv_val+lv_pos(lv_sep_len) = lv_sep.
        INSERT substring( val = lv_val
                          off = lv_start
                          len = lv_pos - lv_start ) INTO TABLE result.
        lv_pos = lv_pos + lv_sep_len.
        lv_start = lv_pos.
        CONTINUE.
      ENDIF.

      lv_pos = lv_pos + 1.

    ENDWHILE.

    INSERT substring( val = lv_val
                      off = lv_start ) INTO TABLE result.

  ENDMETHOD.

  METHOD filter_sql_strip_quotes.
    DATA lv_len TYPE i.

    result = c_trim( val ).
    
    lv_len = strlen( result ).

    IF lv_len >= 2
       AND result(1) = `'`
       AND substring( val = result
                      off = lv_len - 1
                      len = 1 ) = `'`.
      result = substring( val = result
                          off = 1
                          len = lv_len - 2 ).
      result = replace( val  = result
                        sub  = `''`
                        with = `'`
                        occ  = 0 ).
    ENDIF.

  ENDMETHOD.

  METHOD msg_get_t.

    result = msg_get_internal( val ).
    IF result IS INITIAL AND val2 IS NOT INITIAL.
      result = msg_get_internal( val2 ).
    ENDIF.

  ENDMETHOD.

  METHOD rtti_check_clike.

    " typekind_clike and typekind_csequence are generic kinds - RTTI never
    " reports them for an actual data object, so branching on them was dead.
    " N/D/T are character-like in every operation that matters here (they can
    " be moved to a string and rendered in a string template without a dump).
    DATA lv_type TYPE string.
    lv_type = rtti_get_type_kind( val ).
    CASE lv_type.
      WHEN cl_abap_datadescr=>typekind_char OR
          cl_abap_datadescr=>typekind_string OR
          cl_abap_datadescr=>typekind_num OR
          cl_abap_datadescr=>typekind_date OR
          cl_abap_datadescr=>typekind_time.
        result = abap_true.
    ENDCASE.

  ENDMETHOD.

  METHOD rtti_check_printable.

    IF rtti_check_clike( val ) = abap_true.
      result = abap_true.
      RETURN.
    ENDIF.

    CASE rtti_get_type_kind( val ).
      WHEN cl_abap_datadescr=>typekind_int OR
          cl_abap_datadescr=>typekind_int1 OR
          cl_abap_datadescr=>typekind_int2 OR
          cl_abap_datadescr=>typekind_packed OR
          cl_abap_datadescr=>typekind_float OR
          cl_abap_datadescr=>typekind_hex.
        result = abap_true.
    ENDCASE.

  ENDMETHOD.

  METHOD error_get_source_position.

    " typed like the EXPORTING parameters of get_source_position (syrepid is
    " CHAR40) - they are passed by reference, so a string would not be
    " type-compatible here
    DATA lv_program TYPE c LENGTH 40.
    DATA lv_include TYPE c LENGTH 40.
    DATA lv_line    TYPE i.

    IF val IS NOT BOUND.
      RETURN.
    ENDIF.

    " open-abap - the transpiled JS runtime behind the node tests - implements
    " get_source_position by reading a field that only the RAISE statement
    " writes, and fails with a JS TypeError for every other exception (a
    " runtime-thrown one, or one built with NEW). That error is not an ABAP
    " exception, so the TRY below cannot intercept it and the caller would go
    " down instead of reporting the error it was diagnosing. sy-saprl is
    " `OPEN` on that runtime and a real release everywhere else.
    IF sy-saprl = `OPEN`.
      RETURN.
    ENDIF.

    TRY.
        val->get_source_position( IMPORTING program_name = lv_program
                                            include_name = lv_include
                                            source_line  = lv_line ).
      CATCH cx_root ##NO_HANDLER.
        " never let the diagnostic be the reason a caller fails
    ENDTRY.

    IF lv_program IS INITIAL AND lv_line IS INITIAL.
      RETURN.
    ENDIF.

    result = c_trim( lv_program ).
    " the include is the interesting part for a class (...CM001 = the method
    " that raised); repeating it when it equals the program adds nothing
    IF lv_include IS NOT INITIAL AND lv_include <> lv_program.
      result = |{ result } / { c_trim( lv_include ) }|.
    ENDIF.
    IF lv_line IS NOT INITIAL.
      result = |{ result } / line { lv_line }|.
    ENDIF.

  ENDMETHOD.

  METHOD error_get_attributes.

    " declared, NOT `DATA(lv_name) = CONV string( lr_attri->name )`: a CONV
    " that is the whole right-hand side of an assignment is "Redundant
    " conversion for type STRING" in SLIN - the assignment converts by
    " itself. The variable stays a string on purpose: the RTTI name is a
    " CHAR field whose trailing blanks have no business in the rendered name
    DATA lv_name TYPE string.

    FIELD-SYMBOLS <comp> TYPE any.
        DATA lt_attri TYPE abap_attrdescr_tab.
    DATA temp379 LIKE LINE OF lt_attri.
    DATA lr_attri LIKE REF TO temp379.
      DATA temp380 TYPE zabaputil_cl_util_context=>ty_s_name_value.

    IF val IS NOT BOUND.
      RETURN.
    ENDIF.

    TRY.
        
        lt_attri = rtti_get_t_attri_by_oref( val ).
      CATCH cx_root ##NO_HANDLER.
        RETURN.
    ENDTRY.

    
    
    LOOP AT lt_attri REFERENCE INTO lr_attri
         WHERE visibility  = cv_objectdescr_public
           AND is_constant = abap_false
           AND is_class    = abap_false.

      CASE lr_attri->name.
          " rendered by the caller (PREVIOUS as the next chain entry,
          " KERNEL_ERRID as its own line) or without information value
        WHEN `PREVIOUS` OR `TEXTID` OR `IS_RESUMABLE` OR `KERNEL_ERRID`.
          CONTINUE.
      ENDCASE.

      lv_name = lr_attri->name.
      ASSIGN val->(lv_name) TO <comp>.
      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.
      IF rtti_check_printable( <comp> ) = abap_false OR <comp> IS INITIAL.
        CONTINUE.
      ENDIF.

      
      CLEAR temp380.
      temp380-n = lv_name.
      temp380-v = c_trim( |{ <comp> }| ).
      INSERT temp380 INTO TABLE result.
    ENDLOOP.

  ENDMETHOD.

  METHOD ui5_get_msg_type.

    CASE val.
      WHEN `E`.
        result = cs_ui5_msg_type-e.
      WHEN `S`.
        result = cs_ui5_msg_type-s.
      WHEN `W`.
        result = cs_ui5_msg_type-w.
      WHEN OTHERS.
        result = cs_ui5_msg_type-i.
    ENDCASE.

  ENDMETHOD.

  METHOD rtti_create_tab_by_name.

    DATA struct_desc TYPE REF TO cl_abap_typedescr.
    DATA temp381 TYPE REF TO cl_abap_datadescr.
    DATA data_desc LIKE temp381.
    DATA gr_dyntable_typ TYPE REF TO cl_abap_tabledescr.
    struct_desc = cl_abap_structdescr=>describe_by_name( val ).
    
    temp381 ?= struct_desc.
    
    data_desc = temp381.
    
    gr_dyntable_typ = cl_abap_tabledescr=>create( data_desc ).
    CREATE DATA result TYPE HANDLE gr_dyntable_typ.

  ENDMETHOD.

  METHOD msg_get.

    DATA lt_msg TYPE zabaputil_cl_util_context=>ty_t_msg.
    DATA temp382 TYPE zabaputil_cl_util_context=>ty_s_msg.
    DATA temp383 TYPE zabaputil_cl_util_context=>ty_s_msg.
    lt_msg = msg_get_t( val  = val
                              val2 = val2 ).
    
    CLEAR temp382.
    
    READ TABLE lt_msg INTO temp383 INDEX 1.
    IF sy-subrc = 0.
      temp382 = temp383.
    ENDIF.
    result = temp382.

  ENDMETHOD.

  METHOD msg_get_collect.

    DATA temp384 TYPE string_table.
    DATA temp65 TYPE zabaputil_cl_util_context=>ty_t_msg.
    FIELD-SYMBOLS <r> LIKE LINE OF temp65.
      DATA temp66 LIKE LINE OF temp384.
    CLEAR temp384.
    
    temp65 = msg_get_t( val = val val2 = val2 ).
    
    LOOP AT temp65 ASSIGNING <r>.
      
      temp66 = |- { <r>-text }|.
      INSERT temp66 INTO TABLE temp384.
    ENDLOOP.
    result = concat_lines_of(
      table = temp384
      sep   = cv_char_util_newline ).

  ENDMETHOD.

  METHOD rtti_get_data_element_text_l.

    result = rtti_get_data_element_texts( val )-long.

  ENDMETHOD.

  METHOD rtti_get_ddic_type_name.

    DATA temp386 TYPE REF TO cl_abap_elemdescr.
    temp386 ?= type.
    result = substring_after( val = temp386->absolute_name
                              sub = `\TYPE=` ).

  ENDMETHOD.

  METHOD rtti_get_typedescr_by_data_ref.

    result = cl_abap_typedescr=>describe_by_data_ref( val ).

  ENDMETHOD.

  METHOD rtti_get_typedescr_by_data.

    result = cl_abap_typedescr=>describe_by_data( val ).

  ENDMETHOD.

  METHOD rtti_create_sel_tab_type.

    DATA lt_comp TYPE cl_abap_structdescr=>component_table.

    FIELD-SYMBOLS <tab> TYPE ANY TABLE.
    DATA temp387 TYPE REF TO cl_abap_tabledescr.
    DATA lo_table LIKE temp387.
        DATA temp388 TYPE REF TO cl_abap_structdescr.
        DATA lo_struct LIKE temp388.
        DATA temp389 TYPE REF TO cl_abap_elemdescr.
        DATA lo_elem LIKE temp389.
        DATA temp390 TYPE abap_componentdescr.
    DATA temp391 LIKE sy-subrc.
      DATA lo_type_bool TYPE REF TO cl_abap_typedescr.
      DATA temp392 TYPE abap_componentdescr.
      DATA temp67 TYPE REF TO cl_abap_datadescr.
    DATA lo_line_type TYPE REF TO cl_abap_structdescr.
    ASSIGN ir_tab->* TO <tab>.

    
    temp387 ?= cl_abap_typedescr=>describe_by_data( <tab> ).
    
    lo_table = temp387.
    TRY.
        
        temp388 ?= lo_table->get_table_line_type( ).
        
        lo_struct = temp388.
        lt_comp = lo_struct->get_components( ).
      CATCH cx_root.
        result-check_table_line = abap_true.
        
        temp389 ?= lo_table->get_table_line_type( ).
        
        lo_elem = temp389.
        
        CLEAR temp390.
        temp390-name = `TAB_LINE`.
        temp390-type = lo_elem.
        INSERT temp390 INTO TABLE lt_comp.
    ENDTRY.

    
    READ TABLE lt_comp WITH KEY name = sel_field_name TRANSPORTING NO FIELDS.
    temp391 = sy-subrc.
    IF add_sel_field = abap_true
        AND NOT temp391 = 0.
      
      lo_type_bool = cl_abap_typedescr=>describe_by_name( `ABAP_BOOL` ).
      
      CLEAR temp392.
      temp392-name = sel_field_name.
      
      temp67 ?= lo_type_bool.
      temp392-type = temp67.
      INSERT temp392 INTO TABLE lt_comp.
    ENDIF.

    
    lo_line_type = cl_abap_structdescr=>create( lt_comp ).
    result-tabledescr = cl_abap_tabledescr=>create( lo_line_type ).

  ENDMETHOD.

  METHOD msg_get_by_msg.

    DATA temp393 TYPE ty_s_msg.
    DATA ls_msg LIKE temp393.
    CLEAR temp393.
    temp393-id = id.
    temp393-no = no.
    temp393-v1 = v1.
    temp393-v2 = v2.
    temp393-v3 = v3.
    temp393-v4 = v4.
    
    ls_msg = temp393.
    result = msg_get( ls_msg ).

  ENDMETHOD.

  METHOD c_contains.
    " Note: ABAP CS operator is CASE-INSENSITIVE.
    " JS transpilation must use a case-insensitive comparison
    " (e.g. val.toLowerCase().includes(sub.toLowerCase())).
    DATA temp394 TYPE string.
    DATA temp5 TYPE xsdboolean.
    temp394 = val.
    
    temp5 = boolc( temp394 CS sub ).
    result = temp5.

  ENDMETHOD.

  METHOD c_starts_with.

    DATA temp395 TYPE string.
    DATA lv_val LIKE temp395.
    DATA temp396 TYPE string.
    DATA lv_prefix LIKE temp396.
    DATA lv_len TYPE i.
    DATA temp6 TYPE xsdboolean.
    temp395 = val.
    
    lv_val = temp395.
    
    temp396 = prefix.
    
    lv_prefix = temp396.
    
    lv_len = strlen( lv_prefix ).

    IF strlen( lv_val ) < lv_len.
      result = abap_false.
      RETURN.
    ENDIF.

    
    temp6 = boolc( lv_val(lv_len) = lv_prefix ).
    result = temp6.

  ENDMETHOD.

  METHOD c_ends_with.

    DATA temp397 TYPE string.
    DATA lv_val LIKE temp397.
    DATA temp398 TYPE string.
    DATA lv_suffix LIKE temp398.
    DATA lv_len_suffix TYPE i.
    DATA lv_len_val TYPE i.
    DATA lv_off TYPE i.
    DATA temp7 TYPE xsdboolean.
    temp397 = val.
    
    lv_val = temp397.
    
    temp398 = suffix.
    
    lv_suffix = temp398.
    
    lv_len_suffix = strlen( lv_suffix ).
    
    lv_len_val = strlen( lv_val ).

    IF lv_len_val < lv_len_suffix.
      result = abap_false.
      RETURN.
    ENDIF.

    
    lv_off = lv_len_val - lv_len_suffix.
    
    temp7 = boolc( lv_val+lv_off(lv_len_suffix) = lv_suffix ).
    result = temp7.

  ENDMETHOD.

  METHOD c_split.

    SPLIT val AT sep INTO TABLE result.

  ENDMETHOD.

  METHOD c_join.

    DATA lv_line LIKE LINE OF tab.
    LOOP AT tab INTO lv_line.
      IF sy-tabix > 1.
        result = result && sep.
      ENDIF.
      result = result && lv_line.
    ENDLOOP.

  ENDMETHOD.

  METHOD rtti_check_table.

    DATA lv_type_kind TYPE abap_typekind.
    DATA temp8 TYPE xsdboolean.
    lv_type_kind = cl_abap_datadescr=>get_data_type_kind( val ).
    
    temp8 = boolc( lv_type_kind = cl_abap_typedescr=>typekind_table ).
    result = temp8.

  ENDMETHOD.

  METHOD rtti_check_structure.
        DATA lo_type TYPE REF TO cl_abap_typedescr.
        DATA temp9 TYPE xsdboolean.

    TRY.
        
        lo_type = cl_abap_typedescr=>describe_by_data( val ).
        
        temp9 = boolc( lo_type->kind = cl_abap_typedescr=>kind_struct ).
        result = temp9.
      CATCH cx_root.
        result = abap_false.
    ENDTRY.

  ENDMETHOD.

  METHOD rtti_check_numeric.

    DATA lv_type_kind TYPE abap_typekind.
    lv_type_kind = cl_abap_datadescr=>get_data_type_kind( val ).
    CASE lv_type_kind.
      WHEN cl_abap_typedescr=>typekind_int
          OR cl_abap_typedescr=>typekind_int1
          OR cl_abap_typedescr=>typekind_int2
          OR cl_abap_typedescr=>typekind_packed
          OR cl_abap_typedescr=>typekind_float
          OR cl_abap_typedescr=>typekind_decfloat
          OR cl_abap_typedescr=>typekind_decfloat16
          OR cl_abap_typedescr=>typekind_decfloat34
          OR cl_abap_typedescr=>typekind_num.
        result = abap_true.
    ENDCASE.

  ENDMETHOD.

  METHOD time_add_seconds.

    result = cl_abap_tstmp=>add( tstmp = time
                                 secs  = seconds ).

  ENDMETHOD.

  METHOD time_get_stampl_by_date_time.

    DATA ls_sy TYPE zabaputil_cl_util_context=>ty_syst.
    ls_sy = zabaputil_cl_util_context=>context_get_sy( ).
    CONVERT DATE date TIME time INTO TIME STAMP result TIME ZONE ls_sy-zonlo.

  ENDMETHOD.

  METHOD time_diff_seconds.

    DATA lv_diff TYPE i.
    lv_diff = cl_abap_tstmp=>subtract( tstmp1 = time_to
                                              tstmp2 = time_from ).
    result = lv_diff.

  ENDMETHOD.

  METHOD conv_string_to_date.

    DATA temp399 TYPE string.
    DATA lv_val LIKE temp399.
    DATA temp400 TYPE string.
    DATA lv_fmt LIKE temp400.
    DATA lv_yyyy_off TYPE i.
    DATA lv_mm_off TYPE i.
    DATA lv_dd_off TYPE i.
    DATA lv_clean TYPE string.
    DATA lv_i TYPE i.
      DATA lv_c TYPE string.
    DATA lv_fmt_clean TYPE string.
    DATA lv_year TYPE string.
    DATA lv_month TYPE string.
    DATA lv_day TYPE string.
    DATA lv_pos TYPE i.
    temp399 = val.
    
    lv_val = temp399.
    
    temp400 = format.
    
    lv_fmt = temp400.
    
    lv_yyyy_off = find( val = lv_fmt sub = `YYYY` ).
    
    lv_mm_off   = find( val = lv_fmt sub = `MM` ).
    
    lv_dd_off   = find( val = lv_fmt sub = `DD` ).

    
    lv_clean = ``.
    
    lv_i = 0.
    WHILE lv_i < strlen( lv_val ).
      
      lv_c = lv_val+lv_i(1).
      IF lv_c >= `0` AND lv_c <= `9`.
        lv_clean = lv_clean && lv_c.
      ENDIF.
      lv_i = lv_i + 1.
    ENDWHILE.

    
    lv_fmt_clean = ``.
    lv_i = 0.
    WHILE lv_i < strlen( lv_fmt ).
      lv_c = lv_fmt+lv_i(1).
      IF lv_c = `Y` OR lv_c = `M` OR lv_c = `D`.
        lv_fmt_clean = lv_fmt_clean && lv_c.
      ENDIF.
      lv_i = lv_i + 1.
    ENDWHILE.

    
    lv_year  = ``.
    
    lv_month = ``.
    
    lv_day   = ``.

    
    lv_pos = 0.
    lv_i = 0.
    WHILE lv_i < strlen( lv_fmt_clean ).
      lv_c = lv_fmt_clean+lv_i(1).
      CASE lv_c.
        WHEN `Y`.
          lv_year = lv_year && lv_clean+lv_pos(1).
        WHEN `M`.
          lv_month = lv_month && lv_clean+lv_pos(1).
        WHEN `D`.
          lv_day = lv_day && lv_clean+lv_pos(1).
      ENDCASE.
      lv_pos = lv_pos + 1.
      lv_i = lv_i + 1.
    ENDWHILE.

    result = lv_year && lv_month && lv_day.

  ENDMETHOD.

  METHOD conv_date_to_string.

    DATA temp401 TYPE string.
    DATA lv_fmt LIKE temp401.
    DATA temp402 TYPE string.
    DATA lv_date LIKE temp402.
    DATA lv_year TYPE string.
    DATA lv_month TYPE string.
    DATA lv_day TYPE string.
    temp401 = format.
    
    lv_fmt = temp401.
    
    temp402 = val.
    
    lv_date = temp402.

    
    lv_year  = lv_date(4).
    
    lv_month = lv_date+4(2).
    
    lv_day   = lv_date+6(2).

    result = lv_fmt.
    REPLACE `YYYY` IN result WITH lv_year.
    REPLACE `MM`   IN result WITH lv_month.
    REPLACE `DD`   IN result WITH lv_day.

  ENDMETHOD.

  METHOD ui5_msg_box_format.

    DATA lt_msg TYPE zabaputil_cl_util_context=>ty_t_msg.
    DATA lv_lines TYPE i.
    DATA lv_type TYPE string.
    DATA temp68 LIKE LINE OF lt_msg.
    DATA temp69 LIKE sy-tabix.
      DATA temp403 LIKE LINE OF lt_msg.
      DATA temp404 LIKE sy-tabix.
    DATA lt_detail_items TYPE string_table.
    DATA temp405 LIKE LINE OF lt_msg.
    DATA lr_msg LIKE REF TO temp405.
      DATA temp406 LIKE LINE OF lt_detail_items.
    lt_msg = msg_get_t( val ).

    " a structure that carries none of the message components maps to an
    " entry with no text at all - that is not a message, it is data, and it
    " used to reach the box as a popup with a blank line in it. Dropping it
    " here is what lets `skip` mean "nothing in here is a message" and lets
    " the caller fall back to ui5_data_box_format( )
    DELETE lt_msg WHERE text IS INITIAL.

    
    lv_lines = lines( lt_msg ).

    IF lv_lines = 0.
      result-skip = abap_true.
      RETURN.
    ENDIF.

    " the box takes its type/title from the FIRST message, also when several
    " are collapsed into one box below
    
    
    
    temp69 = sy-tabix.
    READ TABLE lt_msg INDEX 1 INTO temp68.
    sy-tabix = temp69.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    lv_type = ui5_get_msg_type( temp68-type ).
    result-title = lv_type.
    result-type  = to_lower( lv_type ).

    IF lv_lines = 1.
      
      
      temp404 = sy-tabix.
      READ TABLE lt_msg INDEX 1 INTO temp403.
      sy-tabix = temp404.
      IF sy-subrc <> 0.
        ASSERT 1 = 0.
      ENDIF.
      result-text = temp403-text.
      RETURN.
    ENDIF.

    " several messages: a counting headline plus every text as a bullet
    result-text = | { lv_lines } Messages found: |.
    
    
    
    LOOP AT lt_msg REFERENCE INTO lr_msg.
      
      temp406 = |<li>{ lr_msg->text }</li>|.
      INSERT temp406 INTO TABLE lt_detail_items.
    ENDLOOP.
    result-details = `<ul>` && concat_lines_of( lt_detail_items ) && `</ul>`.

  ENDMETHOD.

  METHOD ui5_data_box_format.

    " a character value is its own text, whatever is in it - an empty one
    " included, which is the shape message_box_display( lv_text ) has always
    " had and is not this method's to change
    IF rtti_check_clike( val ) = abap_true.
      IF html_check( val ) = abap_true.
        " markup in the box text would be shown as the tags it is written
        " with - a message box renders its text as plain text and its
        " DETAILS as formatted text, so that is where HTML belongs. The
        " plain text behind it stays as the headline
        result-text    = html_get_plain( val ).
        result-details = val.
      ELSE.
        result-text = val.
      ENDIF.
      RETURN.
    ENDIF.

    " a number, a date, a hex value: shown the way the runtime writes it
    IF rtti_check_printable( val ) = abap_true.
      result-text = data_get_string( val ).
      RETURN.
    ENDIF.

    " complex data that is initial stays silent. A caller that hands over
    " the result table of a call it just made expects no box when the call
    " returned nothing
    IF val IS INITIAL.
      result-skip = abap_true.
      RETURN.
    ENDIF.

    result-text    = data_get_headline( val ).
    result-details = data_render( val   = val
                                  depth = 0 ).

    IF result-text IS INITIAL AND result-details IS INITIAL.
      result-skip = abap_true.
    ENDIF.

  ENDMETHOD.

  METHOD data_render.

    " the recursion stops here rather than in every branch below, and says
    " in the output that it did
    IF depth > cv_data_max_depth.
      result = `<em>...</em>`.
      RETURN.
    ENDIF.

    CASE rtti_get_type_kind( val ).
      WHEN cl_abap_datadescr=>typekind_table.
        result = data_render_tab( val   = val
                                  depth = depth ).
      WHEN cl_abap_datadescr=>typekind_struct1 OR cl_abap_datadescr=>typekind_struct2.
        result = data_render_struc( val   = val
                                    depth = depth ).
      WHEN cl_abap_datadescr=>typekind_oref.
        result = data_render_oref( val   = val
                                   depth = depth ).
      WHEN cl_abap_datadescr=>typekind_dref.
        result = data_render_dref( val   = val
                                   depth = depth ).
      WHEN OTHERS.
        result = c_escape_html( data_get_string( val ) ).
    ENDCASE.

  ENDMETHOD.

  METHOD data_render_tab.

    DATA lt_item TYPE string_table.
    DATA lv_no   TYPE i.

    FIELD-SYMBOLS <tab> TYPE ANY TABLE.
    FIELD-SYMBOLS <row> TYPE ANY.
        DATA temp407 LIKE LINE OF lt_item.
      DATA temp408 LIKE LINE OF lt_item.

    ASSIGN val TO <tab>.
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    
    LOOP AT <tab> ASSIGNING <row>.
      lv_no = lv_no + 1.
      IF lv_no > cv_data_max_rows.
        
        temp407 = |<li><em>... { lines( <tab> ) - cv_data_max_rows } more entries</em></li>|.
        INSERT temp407
               INTO TABLE lt_item.
        EXIT.
      ENDIF.
      
      temp408 = |<li>{ data_render( val = <row> depth = depth + 1 ) }</li>|.
      INSERT temp408 INTO TABLE lt_item.
    ENDLOOP.

    result = html_get_list( items   = lt_item
                            ordered = abap_true ).

  ENDMETHOD.

  METHOD data_render_struc.

    DATA lt_item TYPE string_table.
    " declared, not CONV string( ) - see error_get_attributes
    DATA lv_name TYPE string.

    FIELD-SYMBOLS <comp> TYPE any.
        DATA lt_attri TYPE abap_component_tab.
    DATA temp409 LIKE LINE OF lt_attri.
    DATA lr_attri LIKE REF TO temp409.

    TRY.
        
        lt_attri = rtti_get_t_attri_by_any( val ).
      CATCH cx_root.
        " a structure RTTI cannot describe still has a value - the caller
        " keeps the headline, the details stay empty
        RETURN.
    ENDTRY.

    
    
    LOOP AT lt_attri REFERENCE INTO lr_attri.
      lv_name = lr_attri->name.
      ASSIGN COMPONENT lv_name OF STRUCTURE val TO <comp>.
      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.
      INSERT data_render_item( name  = lv_name
                               val   = <comp>
                               depth = depth ) INTO TABLE lt_item.
    ENDLOOP.

    result = html_get_list( lt_item ).

  ENDMETHOD.

  METHOD data_render_oref.

    DATA lo_obj  TYPE REF TO object.
    DATA lt_item TYPE string_table.
    " declared, not CONV string( ) - see error_get_attributes
    DATA lv_name TYPE string.

    FIELD-SYMBOLS <comp> TYPE any.
        DATA lt_attri TYPE abap_attrdescr_tab.
    DATA temp410 LIKE LINE OF lt_attri.
    DATA lr_attri LIKE REF TO temp410.

    TRY.
        lo_obj = val.
      CATCH cx_root.
        RETURN.
    ENDTRY.
    IF lo_obj IS NOT BOUND.
      RETURN.
    ENDIF.

    " an exception carries its own text, and that text is the whole story -
    " its attributes are the placeholders that are already substituted in it
    result = data_get_exc_text( lo_obj ).
    IF result IS NOT INITIAL.
      result = c_escape_html( result ).
      RETURN.
    ENDIF.

    TRY.
        
        lt_attri = rtti_get_t_attri_by_oref( lo_obj ).
      CATCH cx_root.
        RETURN.
    ENDTRY.

    " the public state is what an object can show of itself; a constant is
    " the type's, not this instance's, and a class attribute is nobody's
    
    
    LOOP AT lt_attri REFERENCE INTO lr_attri                  "#EC CI_SORTSEQ
         WHERE visibility  = cv_objectdescr_public
           AND is_constant = abap_false
           AND is_class    = abap_false.
      lv_name = lr_attri->name.
      ASSIGN lo_obj->(lv_name) TO <comp>.
      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.
      INSERT data_render_item( name  = lv_name
                               val   = <comp>
                               depth = depth ) INTO TABLE lt_item.
    ENDLOOP.

    result = html_get_list( lt_item ).

  ENDMETHOD.

  METHOD data_render_dref.

    DATA lr_data TYPE REF TO data.

    FIELD-SYMBOLS <val> TYPE any.

    TRY.
        lr_data = val.
      CATCH cx_root.
        RETURN.
    ENDTRY.
    IF lr_data IS NOT BOUND.
      RETURN.
    ENDIF.

    ASSIGN lr_data->* TO <val>.
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    " a reference is no level of its own for the reader, but it is one for
    " the recursion: a structure that points at itself would otherwise
    " never reach the depth limit
    result = data_render( val   = <val>
                          depth = depth + 1 ).

  ENDMETHOD.

  METHOD data_render_item.

    DATA lv_val TYPE string.
    lv_val = data_render( val   = val
                                depth = depth + 1 ).

    result = |<li><strong>{ c_escape_html( name ) }</strong>: { lv_val }</li>|.

  ENDMETHOD.

  METHOD data_get_headline.

    FIELD-SYMBOLS <tab> TYPE ANY TABLE.
        DATA lv_lines TYPE i.
            DATA lt_attri TYPE abap_component_tab.
        DATA lo_obj TYPE REF TO object.

    CASE rtti_get_type_kind( val ).

      WHEN cl_abap_datadescr=>typekind_table.
        ASSIGN val TO <tab>.
        
        lv_lines = lines( <tab> ).
        IF lv_lines = 1.
          result = `Table with 1 entry`.
        ELSE.
          result = |Table with { lv_lines } entries|.
        ENDIF.

      WHEN cl_abap_datadescr=>typekind_struct1 OR cl_abap_datadescr=>typekind_struct2.
        TRY.
            
            lt_attri = rtti_get_t_attri_by_any( val ).
            result = |Structure with { lines( lt_attri ) } fields|.
          CATCH cx_root.
            result = `Structure`.
        ENDTRY.

      WHEN cl_abap_datadescr=>typekind_oref.
        
        TRY.
            lo_obj = val.
            result = |Object { rtti_get_classname_by_ref( lo_obj ) }|.
          CATCH cx_root.
            result = `Object`.
        ENDTRY.

      WHEN OTHERS.
        result = `Data`.

    ENDCASE.

  ENDMETHOD.

  METHOD data_get_string.

    " the plain assignment is what turns an elementary value into its text
    " - the same trick get_comp_str( ) uses. A value the runtime refuses to
    " convert must not be the reason a box does not appear
    TRY.
        result = val.
      CATCH cx_root ##NO_HANDLER.
    ENDTRY.

    " a number reaches a character target right-aligned in the length its
    " type needs (` 12` for an i on some runtimes), and a CHAR field brings
    " its padding along - neither is what the value says
    result = c_trim( result ).

  ENDMETHOD.

  METHOD data_get_exc_text.
        DATA temp411 TYPE REF TO cx_root.
        DATA lx LIKE temp411.

    TRY.
        
        temp411 ?= val.
        
        lx = temp411.
        result = lx->get_text( ).
      CATCH cx_root ##NO_HANDLER.
        " not an exception, or one that cannot render itself
    ENDTRY.

  ENDMETHOD.

  METHOD html_get_list.

    IF items IS INITIAL.
      RETURN.
    ENDIF.

    IF ordered = abap_true.
      result = `<ol>` && concat_lines_of( items ) && `</ol>`.
    ELSE.
      result = `<ul>` && concat_lines_of( items ) && `</ul>`.
    ENDIF.

  ENDMETHOD.

  METHOD html_check.

    " a closing tag is the one shape a business text does not produce by
    " accident; the void elements are the ones that have none. CS ignores
    " case, so `</DIV>` and `<BR/>` are covered with it
    DATA temp10 TYPE xsdboolean.
    temp10 = boolc( val CS `</` OR val CS `<br` OR val CS `<hr` OR val CS `<img` ).
    result = temp10.

  ENDMETHOD.

  METHOD html_get_plain.

    DATA lv_rest TYPE string.
    DATA lv_pos  TYPE i.

    lv_rest = val.

    " everything between < and > goes, and a blank takes its place so that
    " `<td>a</td><td>b</td>` does not read as `ab`
    WHILE lv_rest CS `<`.
      lv_pos = sy-fdpos.
      result = result && substring( val = lv_rest
                                    len = lv_pos ) && ` `.
      lv_rest = substring( val = lv_rest
                           off = lv_pos ).
      IF lv_rest CS `>`.
        lv_pos = sy-fdpos + 1.
        lv_rest = substring( val = lv_rest
                             off = lv_pos ).
      ELSE.
        CLEAR lv_rest.
      ENDIF.
    ENDWHILE.

    result = result && lv_rest.

    " the entities the stripped text would otherwise show as written
    REPLACE ALL OCCURRENCES OF `&nbsp;` IN result WITH ` `.
    REPLACE ALL OCCURRENCES OF `&lt;` IN result WITH `<`.
    REPLACE ALL OCCURRENCES OF `&gt;` IN result WITH `>`.
    REPLACE ALL OCCURRENCES OF `&amp;` IN result WITH `&`.
    CONDENSE result.

    IF strlen( result ) > cv_data_max_text.
      result = substring( val = result
                          len = cv_data_max_text ) && `...`.
    ENDIF.

  ENDMETHOD.

  METHOD rtti_check_table_standard.

    DATA lo_tab TYPE REF TO cl_abap_tabledescr.
        DATA lo_type TYPE REF TO cl_abap_typedescr.
        DATA temp11 TYPE xsdboolean.

    TRY.
        
        lo_type = cl_abap_typedescr=>describe_by_data_ref( val ).
        IF lo_type->kind <> cl_abap_typedescr=>kind_table.
          RETURN.
        ENDIF.
        lo_tab ?= lo_type.
        
        temp11 = boolc( lo_tab->table_kind = cl_abap_tabledescr=>tablekind_std ).
        result = temp11.
      CATCH cx_root ##NO_HANDLER.
    ENDTRY.

  ENDMETHOD.

  METHOD rtti_check_serializable.
        DATA temp412 TYPE REF TO if_serializable_object.
        DATA lo_dummy LIKE temp412.

    IF val IS NOT BOUND.
      result = abap_true.
      RETURN.
    ENDIF.
    TRY.
        
        temp412 ?= val.
        
        lo_dummy = temp412.
        result = abap_true.
      CATCH cx_root.
        result = abap_false.
    ENDTRY.

  ENDMETHOD.

  METHOD app_get_url.

    DATA lt_param TYPE zabaputil_cl_util_context=>ty_t_name_value.
    DATA temp413 TYPE zabaputil_cl_util_context=>ty_s_name_value.
    DATA temp414 TYPE string.
    DATA lv_hash LIKE temp414.
      DATA lv_content LIKE lv_hash.
        DATA lv_off TYPE i.
    lt_param = url_param_get_tab( search ).
    DELETE lt_param WHERE n = `app_start`.
    
    CLEAR temp413.
    temp413-n = `app_start`.
    temp413-v = to_lower( classname ).
    INSERT temp413 INTO TABLE lt_param.

    " keep only the launchpad shell part of the hash: the app-owned part
    " (leading `/` standalone, or everything after `&/` inside the FLP)
    " carries THIS app's route/app-state, which the backend prefers over
    " app_start - appending it verbatim would re-open the current app
    " instead of the requested one
    
    temp414 = hash.
    
    lv_hash = temp414.
    IF lv_hash IS NOT INITIAL.
      
      lv_content = lv_hash.
      IF lv_content(1) = `#`.
        lv_content = substring( val = lv_content
                                off = 1 ).
      ENDIF.
      IF lv_content IS INITIAL OR lv_content(1) = `/`.
        " pure app hash (route or app-state) - drop it entirely
        lv_hash = ``.
      ELSE.
        " inside the FLP keep the shell part, cut the app part after `&/`
        
        lv_off = find( val = lv_content
                             sub = `&/` ).
        IF lv_off = 0.
          lv_hash = ``.
        ELSEIF lv_off > 0.
          lv_hash = |#{ lv_content(lv_off) }|.
        ELSE.
          lv_hash = |#{ lv_content }|.
        ENDIF.
      ENDIF.
    ENDIF.

    result = |{ origin }{ pathname }?| && url_param_create_url( lt_param ) && lv_hash.

  ENDMETHOD.

  METHOD app_get_url_source_code.

    result = |{ origin }/sap/bc/adt/oo/classes/{ classname }/source/main|.

  ENDMETHOD.

  " ========== String Extras ==========

  METHOD c_pad_left.
    DATA temp415 TYPE string.
    DATA temp70 TYPE string.
    DATA lv_pad LIKE temp70.

    result = val.
    " pad is TYPE c - space value would be trimmed by && (same as c_pad_right fix)
    
    temp415 = pad.
    
    IF pad IS INITIAL.
      temp70 = ` `.
    ELSE.
      temp70 = temp415.
    ENDIF.
    
    lv_pad = temp70.
    WHILE strlen( result ) < len.
      result = lv_pad && result.
    ENDWHILE.

  ENDMETHOD.

  METHOD c_pad_right.
    DATA temp416 TYPE string.
    DATA temp71 TYPE string.
    DATA lv_pad LIKE temp71.

    result = val.
    " pad is TYPE c - a space value IS INITIAL in ABAP and CONV string trims it.
    " Preserve the space explicitly via COND.
    
    temp416 = pad.
    
    IF pad IS INITIAL.
      temp71 = ` `.
    ELSE.
      temp71 = temp416.
    ENDIF.
    
    lv_pad = temp71.
    WHILE strlen( result ) < len.
      result = result && lv_pad.
    ENDWHILE.

  ENDMETHOD.

  METHOD c_truncate.

    DATA temp417 TYPE string.
    DATA lv_val LIKE temp417.
      DATA lv_ellipsis_len TYPE i.
        DATA lv_cut TYPE i.
    temp417 = val.
    
    lv_val = temp417.
    IF strlen( lv_val ) <= max.
      result = lv_val.
    ELSE.
      
      lv_ellipsis_len = strlen( ellipsis ).
      IF max > lv_ellipsis_len.
        
        lv_cut = max - lv_ellipsis_len.
        result = substring( val = lv_val off = 0 len = lv_cut ) && ellipsis.
      ELSE.
        result = substring( val = lv_val off = 0 len = max ).
      ENDIF.
    ENDIF.

  ENDMETHOD.

  METHOD c_substring_safe.

    DATA temp418 TYPE string.
    DATA lv_val LIKE temp418.
    DATA lv_strlen TYPE i.
    DATA lv_off LIKE off.
    DATA lv_len LIKE len.
    temp418 = val.
    
    lv_val = temp418.
    
    lv_strlen = strlen( lv_val ).

    
    lv_off = off.
    IF lv_off < 0.
      lv_off = 0.
    ENDIF.
    IF lv_off >= lv_strlen.
      result = ``.
      RETURN.
    ENDIF.

    
    lv_len = len.
    IF lv_len < 0 OR lv_off + lv_len > lv_strlen.
      lv_len = lv_strlen - lv_off.
    ENDIF.

    result = substring( val = lv_val off = lv_off len = lv_len ).

  ENDMETHOD.

  METHOD c_replace_all.

    result = val.
    REPLACE ALL OCCURRENCES OF sub IN result WITH new_val.

  ENDMETHOD.

  METHOD c_is_blank.

    DATA temp419 TYPE string.
    DATA lv_val LIKE temp419.
    DATA temp12 TYPE xsdboolean.
    temp419 = val.
    
    lv_val = temp419.
    
    temp12 = boolc( c_trim( lv_val ) IS INITIAL ).
    result = temp12.

  ENDMETHOD.

  " ========== Number Formatting ==========

  METHOD conv_number_to_string.

    DATA lv_str TYPE string.
      DATA lv_fmt TYPE string.
      DATA lv_dot_pos TYPE i.
        DATA lv_int_part TYPE string.
        DATA lv_dec_part TYPE string.
        DATA temp420 TYPE string.
      DATA lv_dot TYPE i.
      DATA temp421 TYPE string.
      DATA lv_integer LIKE temp421.
      DATA temp422 TYPE string.
      DATA lv_decimal LIKE temp422.
      DATA lv_negative TYPE string.
      DATA lv_result TYPE string.
      DATA lv_count TYPE i.
      DATA lv_i TYPE i.

    IF decimals >= 0.
      
      lv_fmt = |{ val }|.
      
      lv_dot_pos = find( val = lv_fmt sub = `.` ).
      IF lv_dot_pos < 0.
        lv_str = lv_fmt.
        IF decimals > 0.
          lv_str = lv_str && `.` && repeat( val = `0` occ = decimals ).
        ENDIF.
      ELSE.
        
        lv_int_part = lv_fmt(lv_dot_pos).
        
        lv_dec_part = substring( val = lv_fmt off = lv_dot_pos + 1 ).
        IF strlen( lv_dec_part ) > decimals.
          lv_dec_part = lv_dec_part(decimals).
        ELSEIF strlen( lv_dec_part ) < decimals.
          lv_dec_part = lv_dec_part && repeat( val = `0` occ = decimals - strlen( lv_dec_part ) ).
        ENDIF.
        
        IF decimals > 0.
          temp420 = lv_int_part && `.` && lv_dec_part.
        ELSE.
          temp420 = lv_int_part.
        ENDIF.
        lv_str = temp420.
      ENDIF.
    ELSE.
      lv_str = |{ val }|.
    ENDIF.

    IF sep_thousands IS NOT INITIAL.
      
      lv_dot = find( val = lv_str sub = `.` ).
      
      IF lv_dot >= 0.
        temp421 = lv_str(lv_dot).
      ELSE.
        temp421 = lv_str.
      ENDIF.
      
      lv_integer = temp421.
      
      IF lv_dot >= 0.
        temp422 = substring( val = lv_str off = lv_dot ).
      ELSE.
        CLEAR temp422.
      ENDIF.
      
      lv_decimal = temp422.
      
      lv_negative = ``.
      IF strlen( lv_integer ) > 0 AND lv_integer(1) = `-`.
        lv_negative = `-`.
        lv_integer = substring( val = lv_integer off = 1 ).
      ENDIF.
      
      lv_result = ``.
      
      lv_count = 0.
      
      lv_i = strlen( lv_integer ) - 1.
      WHILE lv_i >= 0.
        IF lv_count > 0 AND lv_count MOD 3 = 0.
          lv_result = sep_thousands && lv_result.
        ENDIF.
        lv_result = lv_integer+lv_i(1) && lv_result.
        lv_count = lv_count + 1.
        lv_i = lv_i - 1.
      ENDWHILE.
      lv_str = lv_negative && lv_result && lv_decimal.
    ENDIF.

    result = lv_str.

  ENDMETHOD.

  METHOD conv_string_to_number.

    DATA temp423 TYPE string.
    DATA lv_val TYPE string.
    DATA lv_clean TYPE string.
    DATA lv_i TYPE i.
      DATA lv_c TYPE string.
        DATA lv_rest TYPE string.
    DATA lv_dot_count TYPE i.
    temp423 = val.
    
    lv_val = c_trim( temp423 ).

    " Heuristic: A comma is treated as DECIMAL separator when it is the
    " LAST separator in the string (no further comma or dot follows).
    " Otherwise it is treated as THOUSANDS separator and skipped.
    " Edge case: '1,000' (no dot) is interpreted as 1.000 (decimal), NOT 1000.
    " This matches European number formatting conventions.
    " Normalize: keep only digits, minus, and decimal point
    
    lv_clean = ``.
    
    lv_i = 0.
    WHILE lv_i < strlen( lv_val ).
      
      lv_c = lv_val+lv_i(1).
      IF lv_c >= `0` AND lv_c <= `9`.
        lv_clean = lv_clean && lv_c.
      ELSEIF lv_c = `-` AND lv_i = 0.
        lv_clean = lv_clean && lv_c.
      ELSEIF lv_c = `.`.
        lv_clean = lv_clean && lv_c.
      ELSEIF lv_c = `,`.
        " Check if comma is decimal separator (last separator in string)
        
        lv_rest = substring( val = lv_val off = lv_i + 1 ).
        IF lv_rest NA `,` AND lv_rest NA `.`.
          lv_clean = lv_clean && `.`.
        ENDIF.
        " Otherwise it's a thousands separator — skip it
      ENDIF.
      lv_i = lv_i + 1.
    ENDWHILE.

    " Validate the normalized value explicitly: it needs at least one
    " digit and at most one decimal point (e.g. European format `1.234,56`
    " normalizes to the invalid `1.234.56`). Return 0 for invalid input -
    " the JS transpiler converts such strings leniently instead of raising
    
    FIND ALL OCCURRENCES OF `.` IN lv_clean MATCH COUNT lv_dot_count.
    IF lv_dot_count > 1 OR lv_clean NA `0123456789`.
      result = 0.
      RETURN.
    ENDIF.

    TRY.
        result = lv_clean.
      CATCH cx_root.
        result = 0.
    ENDTRY.

  ENDMETHOD.

  " ========== i18n / Text Resolution ==========

  " ========== Itab Extras ==========

  METHOD itab_sort_by.

    " SORT itab BY (dynamic) is not supported by the JS transpiler used
    " for the Node unit tests - extract the sort key per row into a
    " helper table, sort that statically and rebuild the table
    TYPES: BEGIN OF ty_s_sort_key,
             key_str TYPE string,
             key_num TYPE decfloat34,
             idx     TYPE i,
           END OF ty_s_sort_key.
    TYPES temp4 TYPE STANDARD TABLE OF ty_s_sort_key WITH DEFAULT KEY.
DATA lt_key TYPE temp4.
    DATA lv_numeric TYPE abap_bool.

    DATA lv_field TYPE string.
    FIELD-SYMBOLS <row> TYPE ANY.
      DATA lv_tabix LIKE sy-tabix.
      FIELD-SYMBOLS <val> TYPE any.
      FIELD-SYMBOLS <key> LIKE LINE OF lt_key.
    DATA lr_copy TYPE REF TO data.
    FIELD-SYMBOLS <tab_copy> TYPE STANDARD TABLE.
      FIELD-SYMBOLS <src> TYPE any.
    lv_field = to_upper( fieldname ).

    
    LOOP AT tab ASSIGNING <row>.
      
      lv_tabix = sy-tabix.
      
      ASSIGN COMPONENT lv_field OF STRUCTURE <row> TO <val>.
      IF sy-subrc <> 0.
        RETURN.
      ENDIF.
      IF lv_tabix = 1.
        lv_numeric = rtti_check_numeric( <val> ).
      ENDIF.
      
      APPEND INITIAL LINE TO lt_key ASSIGNING <key>.
      IF lv_numeric = abap_true.
        <key>-key_num = <val>.
      ELSE.
        <key>-key_str = <val>.
      ENDIF.
      <key>-idx = lv_tabix.
    ENDLOOP.

    IF descending = abap_true.
      SORT lt_key BY key_num DESCENDING key_str DESCENDING.
    ELSE.
      SORT lt_key BY key_num ASCENDING key_str ASCENDING.
    ENDIF.

    
    CREATE DATA lr_copy LIKE tab.
    
    ASSIGN lr_copy->* TO <tab_copy>.
    <tab_copy> = tab.

    CLEAR tab.
    LOOP AT lt_key ASSIGNING <key>.
      
      READ TABLE <tab_copy> INDEX <key>-idx ASSIGNING <src>.
      IF sy-subrc = 0.
        APPEND <src> TO tab.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD itab_slice.

    " Create a copy of the source table (same type) and return the slice.
    DATA temp424 TYPE REF TO cl_abap_tabledescr.
    DATA lo_tabledescr LIKE temp424.
    FIELD-SYMBOLS <result> TYPE STANDARD TABLE.
    FIELD-SYMBOLS <row> TYPE any.
    DATA lv_lines TYPE i.
    DATA temp425 TYPE i.
    DATA lv_to LIKE temp425.
    DATA temp426 TYPE i.
    DATA lv_from LIKE temp426.
    temp424 ?= cl_abap_typedescr=>describe_by_data( tab ).
    
    lo_tabledescr = temp424.
    CREATE DATA result TYPE HANDLE lo_tabledescr.

    
    
    ASSIGN result->* TO <result>.

    
    lv_lines = lines( tab ).
    
    IF to <= 0 OR to > lv_lines.
      temp425 = lv_lines.
    ELSE.
      temp425 = to.
    ENDIF.
    
    lv_to = temp425.
    
    IF from < 1.
      temp426 = 1.
    ELSE.
      temp426 = from.
    ENDIF.
    
    lv_from = temp426.

    LOOP AT tab ASSIGNING <row> FROM lv_from TO lv_to.
      INSERT <row> INTO TABLE <result>.
    ENDLOOP.

  ENDMETHOD.

  METHOD itab_paginate.
    DATA temp427 TYPE i.
    DATA lv_from TYPE i.
    DATA lv_to TYPE i.

    total_count = lines( tab ).
    
    IF page_size <= 0.
      temp427 = 1.
    ELSE.
      temp427 = ( total_count + page_size - 1 ) / page_size.
    ENDIF.
    total_pages = temp427.

    
    lv_from = ( page - 1 ) * page_size + 1.
    
    lv_to   = page * page_size.

    result = itab_slice( tab  = tab
                         from = lv_from
                         to   = lv_to ).

  ENDMETHOD.

  METHOD itab_to_json.

    result = json_stringify( val ).

  ENDMETHOD.

  METHOD itab_from_json.

    json_parse( EXPORTING val = val
                CHANGING data = data ).

  ENDMETHOD.

  METHOD itab_count_by.

    FIELD-SYMBOLS <row>   TYPE any.
    FIELD-SYMBOLS <field> TYPE any.
      DATA lv_val TYPE string.
      FIELD-SYMBOLS <entry> TYPE zabaputil_cl_util_context=>ty_s_name_value.
        DATA temp428 TYPE i.
        DATA lv_count TYPE i.
        DATA temp429 TYPE zabaputil_cl_util_context=>ty_s_name_value.

    LOOP AT tab ASSIGNING <row>.
      ASSIGN COMPONENT fieldname OF STRUCTURE <row> TO <field>.
      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.
      
      lv_val = |{ <field> }|.
      
      READ TABLE result ASSIGNING <entry> WITH KEY n = lv_val.
      IF sy-subrc = 0.
        
        temp428 = <entry>-v.
        
        lv_count = temp428 + 1.
        <entry>-v = |{ lv_count }|.
      ELSE.
        
        CLEAR temp429.
        temp429-n = lv_val.
        temp429-v = `1`.
        INSERT temp429 INTO TABLE result.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  " ========== Validation Helpers ==========

  METHOD check_is_email.

    DATA temp430 TYPE string.
    DATA lv_val TYPE string.
    DATA lv_local TYPE string.
    DATA lv_domain TYPE string.
    DATA lv_extra TYPE string.
    temp430 = val.
    
    lv_val = c_trim( temp430 ).

    IF lv_val IS INITIAL.
      result = abap_false.
      RETURN.
    ENDIF.

    " Basic email validation: contains exactly one @, has text before and after,
    " domain part contains at least one dot
    
    
    
    SPLIT lv_val AT `@` INTO lv_local lv_domain lv_extra.
    IF lv_extra IS NOT INITIAL OR lv_local IS INITIAL OR lv_domain IS INITIAL.
      result = abap_false.
      RETURN.
    ENDIF.

    IF lv_domain NA `.`.
      result = abap_false.
      RETURN.
    ENDIF.

    result = abap_true.

  ENDMETHOD.

  METHOD check_is_numeric_string.

    DATA temp431 TYPE string.
    DATA lv_val TYPE string.
    DATA lv_i TYPE i.
    DATA lv_has_dot LIKE abap_false.
      DATA lv_c TYPE string.
    temp431 = val.
    
    lv_val = c_trim( temp431 ).

    IF lv_val IS INITIAL.
      result = abap_false.
      RETURN.
    ENDIF.

    
    lv_i = 0.
    
    lv_has_dot = abap_false.
    WHILE lv_i < strlen( lv_val ).
      
      lv_c = lv_val+lv_i(1).
      IF lv_c >= `0` AND lv_c <= `9`.
        " digit ok
      ELSEIF lv_c = `-` AND lv_i = 0.
        " leading minus ok
      ELSEIF lv_c = `+` AND lv_i = 0.
        " leading plus ok
      ELSEIF ( lv_c = `.` OR lv_c = `,` ) AND lv_has_dot = abap_false.
        lv_has_dot = abap_true.
      ELSE.
        result = abap_false.
        RETURN.
      ENDIF.
      lv_i = lv_i + 1.
    ENDWHILE.

    result = abap_true.

  ENDMETHOD.

  METHOD check_is_date_valid.

    " declared, not CONV string( ) - see error_get_attributes
    DATA lv_check TYPE string.
        DATA lv_date TYPE d.
        DATA temp13 TYPE xsdboolean.

    TRY.
        
        lv_date = conv_string_to_date( val = val format = format ).
        " Check the date is actually valid (not 00000000 and not invalid like Feb 30)
        IF lv_date IS INITIAL.
          result = abap_false.
          RETURN.
        ENDIF.
        " ABAP validates dates on assignment — if it passed conv_string_to_date it's valid
        lv_check = lv_date.
        
        temp13 = boolc( lv_check <> `00000000` ).
        result = temp13.
      CATCH cx_root.
        result = abap_false.
    ENDTRY.

  ENDMETHOD.

  METHOD check_is_guid.

    DATA temp432 TYPE string.
    DATA lv_val TYPE string.
    DATA lv_clean TYPE string.
    DATA lv_len TYPE i.
    DATA lv_upper TYPE string.
    DATA lv_i TYPE i.
      DATA lv_c TYPE string.
    temp432 = val.
    
    lv_val = c_trim( temp432 ).
    
    lv_clean = c_replace_all( val = lv_val sub = `-` new_val = `` ).
    
    lv_len = strlen( lv_clean ).

    " Accept 32 chars (raw) or 36 chars (with dashes)
    IF lv_len <> 32.
      result = abap_false.
      RETURN.
    ENDIF.

    " All characters must be hex digits
    
    lv_upper = to_upper( lv_clean ).
    
    lv_i = 0.
    WHILE lv_i < 32.
      
      lv_c = lv_upper+lv_i(1).
      IF NOT ( ( lv_c >= `0` AND lv_c <= `9` ) OR ( lv_c >= `A` AND lv_c <= `F` ) ).
        result = abap_false.
        RETURN.
      ENDIF.
      lv_i = lv_i + 1.
    ENDWHILE.

    result = abap_true.

  ENDMETHOD.

  METHOD check_max_length.

    DATA temp433 TYPE string.
    DATA lv_val LIKE temp433.
    DATA temp14 TYPE xsdboolean.
    temp433 = val.
    
    lv_val = temp433.
    
    temp14 = boolc( strlen( lv_val ) <= max ).
    result = temp14.

  ENDMETHOD.

  " ========== Deep Comparison ==========

  METHOD data_equals.
        DATA temp15 TYPE xsdboolean.

    TRY.
        
        temp15 = boolc( a = b ).
        result = temp15.
      CATCH cx_root.
        result = abap_false.
    ENDTRY.

  ENDMETHOD.

  METHOD data_diff.

    FIELD-SYMBOLS <old_field> TYPE any.
    FIELD-SYMBOLS <new_field> TYPE any.

    DATA lt_comps TYPE abap_component_tab.
    DATA temp434 LIKE LINE OF lt_comps.
    DATA lr_comp LIKE REF TO temp434.
        DATA temp435 TYPE zabaputil_cl_util_context=>ty_s_field_diff.
    lt_comps = rtti_get_t_attri_by_any( old ).

    
    
    LOOP AT lt_comps REFERENCE INTO lr_comp.
      ASSIGN COMPONENT lr_comp->name OF STRUCTURE old TO <old_field>.
      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.
      ASSIGN COMPONENT lr_comp->name OF STRUCTURE new TO <new_field>.
      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.
      IF <old_field> <> <new_field>.
        
        CLEAR temp435.
        temp435-fieldname = lr_comp->name.
        temp435-old_value = |{ <old_field> }|.
        temp435-new_value = |{ <new_field> }|.
        INSERT temp435 INTO TABLE result.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  " ========== Stopwatch ==========

  METHOD time_measure_start.

    GET TIME STAMP FIELD result.

  ENDMETHOD.

  METHOD time_measure_stop.

    DATA lv_now TYPE timestampl.
    DATA lv_diff TYPE i.
    lv_now = time_get_timestampl( ).
    
    lv_diff = cl_abap_tstmp=>subtract( tstmp1 = lv_now
                                              tstmp2 = start_time ).
    result = lv_diff * 1000.  " convert seconds to milliseconds

  ENDMETHOD.

  " ========== Authorization Check ==========

  " ========== Enum/Domain Helpers ==========

  METHOD enum_to_text.

    DATA lt_all TYPE zabaputil_cl_util_context=>ty_t_name_value.
    DATA temp436 TYPE string.
    DATA lv_val LIKE temp436.
    DATA temp437 TYPE string.
    DATA temp438 TYPE zabaputil_cl_util_context=>ty_s_name_value.
    lt_all = enum_get_all( domain = domain langu = langu ).
    
    temp436 = value.
    
    lv_val = temp436.
    
    CLEAR temp437.
    
    READ TABLE lt_all INTO temp438 WITH KEY n = lv_val.
    IF sy-subrc = 0.
      temp437 = temp438-v.
    ENDIF.
    result = temp437.

  ENDMETHOD.

  METHOD enum_get_all.
        DATA temp439 TYPE string.
        DATA lo_type TYPE REF TO cl_abap_typedescr.
        DATA temp440 TYPE REF TO cl_abap_elemdescr.
        DATA lo_elem LIKE temp440.
        DATA lt_fix TYPE zabaputil_cl_util_context=>ty_t_fix_val.
        DATA ls_fix LIKE LINE OF lt_fix.
          DATA temp441 TYPE zabaputil_cl_util_context=>ty_s_name_value.

    TRY.
        
        temp439 = domain.
        
        cl_abap_typedescr=>describe_by_name( EXPORTING  p_name         = temp439
                                             RECEIVING  p_descr_ref    = lo_type
                                             EXCEPTIONS type_not_found = 1
                                                        OTHERS         = 2 ).
        IF sy-subrc <> 0.
          RETURN.
        ENDIF.

        
        temp440 ?= lo_type.
        
        lo_elem = temp440.
        
        lt_fix = rtti_get_t_fixvalues( elemdescr = lo_elem
                                              langu     = langu ).

        
        LOOP AT lt_fix INTO ls_fix.
          
          CLEAR temp441.
          temp441-n = ls_fix-low.
          temp441-v = ls_fix-descr.
          INSERT temp441 INTO TABLE result.
        ENDLOOP.

      CATCH cx_root ##NO_HANDLER.
    ENDTRY.

  ENDMETHOD.

  " ========== Deep Field Access ==========

  METHOD data_get_by_path.

    FIELD-SYMBOLS <current> TYPE any.
    FIELD-SYMBOLS <field>   TYPE any.
    TYPES temp5 TYPE STANDARD TABLE OF string WITH DEFAULT KEY.
DATA lt_segments TYPE temp5.
    DATA lv_segment LIKE LINE OF lt_segments.
      DATA lv_seg TYPE string.

    ASSIGN data TO <current>.

    

    SPLIT path AT `-` INTO TABLE lt_segments.

    
    LOOP AT lt_segments INTO lv_segment.
      
      lv_seg = c_trim_upper( lv_segment ).
      IF lv_seg IS INITIAL.
        CONTINUE.
      ENDIF.
      ASSIGN COMPONENT lv_seg OF STRUCTURE <current> TO <field>.
      IF sy-subrc <> 0.
        result = ``.
        RETURN.
      ENDIF.
      ASSIGN <field> TO <current>.
    ENDLOOP.

    result = |{ <current> }|.

  ENDMETHOD.

  METHOD data_set_by_path.

    FIELD-SYMBOLS <current> TYPE any.
    FIELD-SYMBOLS <field>   TYPE any.
    TYPES temp6 TYPE STANDARD TABLE OF string WITH DEFAULT KEY.
DATA lt_segments TYPE temp6.
    DATA lv_last_idx TYPE i.
    DATA lv_segment LIKE LINE OF lt_segments.
      DATA lv_seg TYPE string.

    ASSIGN data TO <current>.

    

    SPLIT path AT `-` INTO TABLE lt_segments.
    
    lv_last_idx = lines( lt_segments ).

    
    LOOP AT lt_segments INTO lv_segment.
      
      lv_seg = c_trim_upper( lv_segment ).
      IF lv_seg IS INITIAL.
        CONTINUE.
      ENDIF.
      ASSIGN COMPONENT lv_seg OF STRUCTURE <current> TO <field>.
      IF sy-subrc <> 0.
        RETURN.
      ENDIF.
      IF sy-tabix = lv_last_idx.
        <field> = value.
      ELSE.
        ASSIGN <field> TO <current>.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  " ========== BAL Extensions ==========

  " ========== Transport Extensions ==========

  " ========== Lock Extensions ==========

  " ========== Number Range ==========

  " ========== Change Documents ==========

  " ========== Background Job ==========

  " ========== Email ==========

  METHOD context_get_user_tech.
        DATA temp442 TYPE string.
        DATA lv_result LIKE temp442.
        DATA lv_class TYPE string.
        DATA x TYPE REF TO cx_root.

    TRY.

        
        CLEAR temp442.
        
        lv_result = temp442.
        
        lv_class = `CL_ABAP_CONTEXT_INFO`.

        IF check_abap_cloud( ) IS NOT INITIAL.
          CALL METHOD (lv_class)=>(`GET_USER_TECHNICAL_NAME`)
            RECEIVING
              rv_technical_name = lv_result.
        ELSE.
          CALL METHOD (lv_class)=>(`GET_USER_BUSINESS_PARTNER_ID`)
            RECEIVING
              rv_business_partner_id = lv_result.
        ENDIF.

        result = lv_result.

        
      CATCH cx_root INTO x.
        RAISE EXCEPTION TYPE zabaputil_cx_util_error
          EXPORTING
            previous = x.
    ENDTRY.

  ENDMETHOD.

  METHOD check_abap_cloud.

    IF gv_check_cloud_cached = abap_true.
      result = gv_check_cloud.
      RETURN.
    ENDIF.

    TRY.
        cl_abap_typedescr=>describe_by_name( `T100` ).
        gv_check_cloud = abap_false.
      CATCH cx_root.
        gv_check_cloud = abap_true.
    ENDTRY.
    gv_check_cloud_cached = abap_true.
    result = gv_check_cloud.

  ENDMETHOD.

  METHOD rtti_get_t_fixvalues.

    TYPES:
      BEGIN OF fixvalue,
        low        TYPE c LENGTH 10,
        high       TYPE c LENGTH 10,
        option     TYPE c LENGTH 2,
        ddlanguage TYPE c LENGTH 1,
        ddtext     TYPE c LENGTH 60,
      END OF fixvalue.
    TYPES fixvalues TYPE STANDARD TABLE OF fixvalue WITH DEFAULT KEY.
    DATA lt_values TYPE fixvalues.

    DATA lv_langu  TYPE c LENGTH 1.
    DATA temp1     LIKE LINE OF lt_values.
    DATA lr_fix    LIKE REF TO temp1.
    DATA temp2     TYPE ty_s_fix_val.

    lv_langu = ` `.
    lv_langu = langu.

    CALL METHOD elemdescr->(`GET_DDIC_FIXED_VALUES`)
      EXPORTING
        p_langu        = lv_langu
      RECEIVING
        p_fixed_values = lt_values
      EXCEPTIONS
        not_found      = 1
        no_ddic_type   = 2
        OTHERS         = 3.

    LOOP AT lt_values REFERENCE INTO lr_fix.

      CLEAR temp2.
      temp2-low   = lr_fix->low.
      temp2-high  = lr_fix->high.
      temp2-descr = lr_fix->ddtext.
      INSERT temp2
             INTO TABLE result.

    ENDLOOP.

  ENDMETHOD.

  METHOD conv_decode_x_base64.
    DATA lv_web_http_name TYPE c LENGTH 19.
    DATA classname        TYPE c LENGTH 15.

    TRY.

        lv_web_http_name = `CL_WEB_HTTP_UTILITY`.
        CALL METHOD (lv_web_http_name)=>(`DECODE_X_BASE64`)
          EXPORTING
            encoded = val
          RECEIVING
            decoded = result.

      CATCH cx_root.

        classname = `CL_HTTP_UTILITY`.
        CALL METHOD (classname)=>(`DECODE_X_BASE64`)
          EXPORTING
            encoded = val
          RECEIVING
            decoded = result.

    ENDTRY.

  ENDMETHOD.

  METHOD conv_encode_x_base64.
    DATA lv_web_http_name TYPE c LENGTH 19.
    DATA classname        TYPE c LENGTH 15.

    TRY.

        lv_web_http_name = `CL_WEB_HTTP_UTILITY`.
        CALL METHOD (lv_web_http_name)=>(`ENCODE_X_BASE64`)
          EXPORTING
            unencoded = val
          RECEIVING
            encoded   = result.

      CATCH cx_root.

        classname = `CL_HTTP_UTILITY`.
        CALL METHOD (classname)=>(`ENCODE_X_BASE64`)
          EXPORTING
            unencoded = val
          RECEIVING
            encoded   = result.

    ENDTRY.

  ENDMETHOD.

  METHOD conv_get_string_by_xstring.

    DATA conv          TYPE REF TO object.
    DATA conv_codepage TYPE c LENGTH 21.
    DATA conv_in_class TYPE c LENGTH 18.

    TRY.

        conv_codepage = `CL_ABAP_CONV_CODEPAGE`.
        CALL METHOD (conv_codepage)=>create_in
          RECEIVING
            instance = conv.

        CALL METHOD conv->(`IF_ABAP_CONV_IN~CONVERT`)
          EXPORTING
            source = val
          RECEIVING
            result = result.

      CATCH cx_root.

        conv_in_class = `CL_ABAP_CONV_IN_CE`.
        CALL METHOD (conv_in_class)=>create
          EXPORTING
            encoding = `UTF-8`
          RECEIVING
            conv     = conv.

        CALL METHOD conv->(`CONVERT`)
          EXPORTING
            input = val
          IMPORTING
            data  = result.
    ENDTRY.

  ENDMETHOD.

  METHOD conv_get_xstring_by_string.

    DATA conv           TYPE REF TO object.
    DATA conv_codepage  TYPE c LENGTH 21.
    DATA conv_out_class TYPE c LENGTH 19.

    TRY.

        conv_codepage = `CL_ABAP_CONV_CODEPAGE`.
        CALL METHOD (conv_codepage)=>create_out
          RECEIVING
            instance = conv.

        CALL METHOD conv->(`IF_ABAP_CONV_OUT~CONVERT`)
          EXPORTING
            source = val
          RECEIVING
            result = result.

      CATCH cx_root.

        conv_out_class = `CL_ABAP_CONV_OUT_CE`.
        CALL METHOD (conv_out_class)=>create
          EXPORTING
            encoding = `UTF-8`
          RECEIVING
            conv     = conv.

        CALL METHOD conv->(`CONVERT`)
          EXPORTING
            data   = val
          IMPORTING
            buffer = result.
    ENDTRY.

  ENDMETHOD.

  METHOD rtti_get_classes_impl_intf.

    IF check_abap_cloud( ) IS NOT INITIAL.
      result = rtti_get_classes_intf_cloud( val              = val
                                            read_description = read_description ).
    ELSE.
      result = rtti_get_classes_intf_std( val              = val
                                          read_description = read_description ).
    ENDIF.

  ENDMETHOD.

  METHOD rtti_get_classes_intf_cloud.

    DATA obj TYPE REF TO object.
    FIELD-SYMBOLS <any> TYPE any.
    DATA lt_implementation_names TYPE string_table.
    DATA BEGIN OF ls_clskey.
    DATA clsname TYPE c LENGTH 30.
    DATA END OF ls_clskey.
    DATA xco_cp_abap         TYPE c LENGTH 11.
    DATA implementation_name LIKE LINE OF lt_implementation_names.
    DATA ls_class            LIKE LINE OF result.

    ls_clskey-clsname = val.

    xco_cp_abap = `XCO_CP_ABAP`.
    CALL METHOD (xco_cp_abap)=>interface
      EXPORTING
        iv_name      = ls_clskey-clsname
      RECEIVING
        ro_interface = obj.

    ASSIGN obj->(`IF_XCO_AO_INTERFACE~IMPLEMENTATIONS`) TO <any>.
    IF sy-subrc <> 0.
      RAISE EXCEPTION TYPE cx_sy_dyn_call_illegal_class.
    ENDIF.
    obj = <any>.

    ASSIGN obj->(`IF_XCO_INTF_IMPLEMENTATIONS_FC~ALL`) TO <any>.
    IF sy-subrc <> 0.
      RAISE EXCEPTION TYPE cx_sy_dyn_call_illegal_class.
    ENDIF.
    obj = <any>.

    CALL METHOD obj->(`IF_XCO_INTF_IMPLEMENTATIONS~GET_NAMES`)
      RECEIVING
        rt_names = lt_implementation_names.

    LOOP AT lt_implementation_names INTO implementation_name.

      CLEAR ls_class.
      ls_class-classname = implementation_name.
      IF read_description = abap_true.
        " a class the XCO layer cannot describe (deleted mid-list, locked)
        " keeps its slot with a blank description - one broken implementer
        " must not hide every other one from the caller
        TRY.
            ls_class-description = rtti_get_class_descr_on_cloud( implementation_name ).
          CATCH cx_root ##NO_HANDLER.
        ENDTRY.
      ENDIF.
      INSERT ls_class INTO TABLE result.
    ENDLOOP.

  ENDMETHOD.

  METHOD rtti_get_classes_intf_std.

    TYPES BEGIN OF ty_s_impl.
    TYPES clsname    TYPE c LENGTH 30.
    TYPES refclsname TYPE c LENGTH 30.
    TYPES END OF ty_s_impl.
    " DEFAULT KEY on purpose: this table is passed to the classic function
    " module SEO_INTERFACE_IMPLEM_GET_ALL (impkeys), whose formal parameter is
    " a STANDARD TABLE WITH DEFAULT KEY. WITH EMPTY KEY makes the table type
    " incompatible, so the CALL FUNCTION fails and no implementers are returned
    " (silently breaking user-exit discovery). Never change this key type.
    TYPES temp7 TYPE STANDARD TABLE OF ty_s_impl WITH DEFAULT KEY.
DATA lt_impl TYPE temp7.
    "#EC DEFAULT_KEY
    TYPES BEGIN OF ty_s_key.
    TYPES intkey TYPE c LENGTH 30.
    TYPES END OF ty_s_key.
    DATA ls_key TYPE ty_s_key.
    DATA BEGIN OF ls_clskey.
    DATA clsname TYPE c LENGTH 30.
    DATA END OF ls_clskey.
    DATA class    TYPE REF TO data.
    DATA type     TYPE c LENGTH 12.
    FIELD-SYMBOLS <class> TYPE data.
    DATA lr_impl  TYPE REF TO ty_s_impl.
    FIELD-SYMBOLS <description> TYPE any.
    DATA ls_class TYPE ty_s_class_descr.
    DATA lv_fm    TYPE string.

    ls_key-intkey = val.

    lv_fm = `SEO_INTERFACE_IMPLEM_GET_ALL`.
    CALL FUNCTION lv_fm
      EXPORTING
        intkey        = ls_key
      IMPORTING
        impkeys       = lt_impl
      EXCEPTIONS
        error_message = 1
        OTHERS        = 2.
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    type = `SEOC_CLASS_R`.
    CREATE DATA class TYPE (type).

    ASSIGN class->* TO <class>.

    LOOP AT lt_impl REFERENCE INTO lr_impl.

      CLEAR ls_class.
      ls_class-classname = lr_impl->clsname.

      IF read_description = abap_true.

        CLEAR <class>.
        ls_clskey-clsname = lr_impl->clsname.

        lv_fm = `SEO_CLASS_READ`.
        CALL FUNCTION lv_fm
          EXPORTING
            clskey        = ls_clskey
          IMPORTING
            class         = <class>
          EXCEPTIONS
            error_message = 1
            OTHERS        = 2.
        " a class the repository cannot read (deleted mid-list, inactive,
        " locked) keeps its slot with a blank description. This used to
        " RAISE, which turned ONE broken implementer into an empty result
        " for the caller - and a caller that swallows that reads it as
        " "nothing implements this interface anywhere", with no error to
        " point at
        IF sy-subrc = 0.
          ASSIGN
            COMPONENT `DESCRIPT`
            OF STRUCTURE <class>
            TO <description>.
          ASSERT sy-subrc = 0.
          ls_class-description = <description>.
        ENDIF.

      ENDIF.
      INSERT
        ls_class
        INTO TABLE result.
    ENDLOOP.

  ENDMETHOD.

  METHOD rtti_get_data_element_texts.

    DATA data_element_name TYPE string.
    DATA lv_do_fallback    TYPE abap_bool.

    data_element_name = val.

    TRY.
        rtti_get_dtel_texts_by_ddic( EXPORTING name        = data_element_name
                                     IMPORTING texts       = result
                                               do_fallback = lv_do_fallback ).
      CATCH cx_root.
        rtti_get_dtel_texts_by_xco( EXPORTING name        = data_element_name
                                    IMPORTING texts       = result
                                              do_fallback = lv_do_fallback ).
    ENDTRY.

    IF lv_do_fallback = abap_true AND result IS INITIAL.
      result-header = val.
      result-long = val.
      result-medium = val.
      result-short = val.
    ENDIF.

  ENDMETHOD.

  METHOD rtti_get_dtel_texts_by_ddic.

    DATA ddic_ref TYPE REF TO data.
    DATA: BEGIN OF ddic,
            reptext   TYPE string,
            scrtext_s TYPE string,
            scrtext_m TYPE string,
            scrtext_l TYPE string,
          END OF ddic.
    DATA struct_descr TYPE REF TO cl_abap_structdescr.
    FIELD-SYMBOLS <ddic> TYPE data.
    DATA lo_typedescr TYPE REF TO cl_abap_typedescr.
    DATA data_descr   TYPE REF TO cl_abap_datadescr.

    CLEAR texts.
    do_fallback = abap_false.

    cl_abap_typedescr=>describe_by_name( `T100` ).

    struct_descr ?= cl_abap_structdescr=>describe_by_name( `DFIES` ).

    CREATE DATA ddic_ref TYPE HANDLE struct_descr.

    ASSIGN ddic_ref->* TO <ddic>.
    ASSERT sy-subrc = 0.

    cl_abap_elemdescr=>describe_by_name( EXPORTING  p_name      = name
                                         RECEIVING  p_descr_ref = lo_typedescr
                                         EXCEPTIONS OTHERS      = 1 ).
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    data_descr ?= lo_typedescr.

    CALL METHOD data_descr->(`GET_DDIC_FIELD`)
      RECEIVING
        p_flddescr   = <ddic>
      EXCEPTIONS
        not_found    = 1
        no_ddic_type = 2
        OTHERS       = 3.
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    MOVE-CORRESPONDING <ddic> TO ddic.
    texts-header = ddic-reptext.
    texts-short  = ddic-scrtext_s.
    texts-medium = ddic-scrtext_m.
    texts-long   = ddic-scrtext_l.
    do_fallback  = abap_true.

  ENDMETHOD.

  METHOD rtti_get_dtel_texts_by_xco.

    DATA data_element TYPE REF TO object.
    DATA content      TYPE REF TO object.
    DATA exists       TYPE abap_bool.
    DATA lv_xco_cp_abap_dictionary TYPE string.

    CLEAR texts.
    do_fallback = abap_false.

    TRY.
        lv_xco_cp_abap_dictionary = `XCO_CP_ABAP_DICTIONARY`.
        CALL METHOD (lv_xco_cp_abap_dictionary)=>(`DATA_ELEMENT`)
          EXPORTING
            iv_name         = name
          RECEIVING
            ro_data_element = data_element.

        CALL METHOD data_element->(`IF_XCO_AD_DATA_ELEMENT~EXISTS`)
          RECEIVING
            rv_exists = exists.

        IF exists = abap_false.
          RETURN.
        ENDIF.

        CALL METHOD data_element->(`IF_XCO_AD_DATA_ELEMENT~CONTENT`)
          RECEIVING
            ro_content = content.

        CALL METHOD content->(`IF_XCO_DTEL_CONTENT~GET_HEADING_FIELD_LABEL`)
          RECEIVING
            rs_heading_field_label = texts-header.

        CALL METHOD content->(`IF_XCO_DTEL_CONTENT~GET_SHORT_FIELD_LABEL`)
          RECEIVING
            rs_short_field_label = texts-short.

        CALL METHOD content->(`IF_XCO_DTEL_CONTENT~GET_MEDIUM_FIELD_LABEL`)
          RECEIVING
            rs_medium_field_label = texts-medium.

        CALL METHOD content->(`IF_XCO_DTEL_CONTENT~GET_LONG_FIELD_LABEL`)
          RECEIVING
            rs_long_field_label = texts-long.

        do_fallback = abap_true.

      CATCH cx_root.
        do_fallback = abap_true.
    ENDTRY.

  ENDMETHOD.

  METHOD uuid_get_c22.

    DATA lv_uuid      TYPE c LENGTH 22.
    DATA lv_classname TYPE string.
    DATA lv_fm        TYPE string.

    TRY.

        TRY.

            lv_classname = `CL_SYSTEM_UUID`.
            CALL METHOD (lv_classname)=>if_system_uuid_static~create_uuid_c22
              RECEIVING
                uuid = lv_uuid.

          CATCH cx_sy_dyn_call_illegal_class.

            lv_fm = `GUID_CREATE`.
            CALL FUNCTION lv_fm
              IMPORTING
                ev_guid_22 = lv_uuid.

        ENDTRY.

        result = lv_uuid.

      CATCH cx_root.
        ASSERT 1 = 0.
    ENDTRY.

    result = replace( val  = result
                      sub  = `}`
                      with = `0`
                      occ  = 0 ).
    result = replace( val  = result
                      sub  = `{`
                      with = `0`
                      occ  = 0 ).
    result = replace( val  = result
                      sub  = `"`
                      with = `0`
                      occ  = 0 ).
    result = replace( val  = result
                      sub  = `'`
                      with = `0`
                      occ  = 0 ).

  ENDMETHOD.

  METHOD uuid_get_c32.
    DATA lv_uuid      TYPE c LENGTH 32.
    DATA lv_classname TYPE string.
    DATA lv_fm        TYPE string.
        DATA lx_uuid TYPE REF TO cx_root.

    TRY.

        TRY.

            lv_classname = `CL_SYSTEM_UUID`.
            CALL METHOD (lv_classname)=>if_system_uuid_static~create_uuid_c32
              RECEIVING
                uuid = lv_uuid.

          CATCH cx_root.

            lv_fm = `GUID_CREATE`.
            CALL FUNCTION lv_fm
              IMPORTING
                ev_guid_32 = lv_uuid.

        ENDTRY.

        result = lv_uuid.

        
      CATCH cx_root INTO lx_uuid.
        " both UUID mechanisms failed - raise the framework exception so the
        " consumer's single top-level catch can turn it into a handled error.
        " ASSERT would raise the uncatchable ASSERTION_FAILED and bypass that
        " catch (short dump instead of a handled error response).
        " zabaputil_cx_util_error=>constructor itself calls uuid_get_c32, so the
        " raise below re-enters this method. gv_uuid_failed makes that nested
        " call return an empty UUID instead of raising again (endless recursion
        " until the stack overflows, which would defeat the handled error above).
        IF gv_uuid_failed = abap_true.
          RETURN.
        ENDIF.
        gv_uuid_failed = abap_true.
        TRY.
            RAISE EXCEPTION TYPE zabaputil_cx_util_error
              EXPORTING
                val = lx_uuid.
          CLEANUP.
            CLEAR gv_uuid_failed.
        ENDTRY.
    ENDTRY.
  ENDMETHOD.

  METHOD rtti_get_class_descr_on_cloud.
        DATA obj TYPE REF TO object.
        DATA content TYPE REF TO object.
        DATA lv_classname TYPE c LENGTH 30.
        DATA xco_cp_abap TYPE c LENGTH 11.
    TRY.

        
        
        
        

        lv_classname = classname.

        xco_cp_abap = `XCO_CP_ABAP`.
        CALL METHOD (xco_cp_abap)=>(`CLASS`)
          EXPORTING
            iv_name  = lv_classname
          RECEIVING
            ro_class = obj.

        CALL METHOD obj->(`IF_XCO_AO_CLASS~CONTENT`)
          RECEIVING
            ro_content = content.

        CALL METHOD content->(`IF_XCO_CLAS_CONTENT~GET_SHORT_DESCRIPTION`)
          RECEIVING
            rv_short_description = result.

      CATCH cx_root ##NO_HANDLER.
    ENDTRY.
  ENDMETHOD.

  METHOD context_get_tenant.

    "DATA(tenant_info) = xco_cp=>current->tenant( ).
    "DATA(account_id) = tenant_info->get_global_account_id( ).

  ENDMETHOD.

  METHOD context_get_callstack.
      DATA current_obj TYPE REF TO object.
      DATA stack TYPE REF TO object.
      DATA full_stack TYPE REF TO object.
      DATA format_source TYPE REF TO object.
      DATA format_obj2 TYPE REF TO object.
      DATA format_obj3 TYPE REF TO object.
      DATA text_obj TYPE REF TO object.
      DATA lv_xco_cp TYPE c LENGTH 6.
      DATA ro_lines TYPE REF TO object.
      FIELD-SYMBOLS <current> TYPE any.
      FIELD-SYMBOLS <any> TYPE any.
      FIELD-SYMBOLS <call_stack> TYPE any.
      FIELD-SYMBOLS <format> TYPE any.
      FIELD-SYMBOLS <format2> TYPE any.
      DATA lv_assign TYPE string.
      DATA r TYPE REF TO data.
      FIELD-SYMBOLS <lt_lines> TYPE string_table.
      DATA text LIKE LINE OF <lt_lines>.
        DATA temp443 TYPE ty_s_stack.
        DATA ls_stack LIKE temp443.

    IF check_abap_cloud( ) IS NOT INITIAL.

      
      
      
      
      
      
      
      
      
      
      
      
      
      

      "1 format source
      
      lv_assign = `XCO_CP_CALL_STACK=>LINE_NUMBER_FLAVOR->SOURCE`.
      ASSIGN (lv_assign) TO <format>.

      lv_assign = `XCO_CP_CALL_STACK=>FORMAT`.
      ASSIGN (lv_assign) TO <format2>.
      format_obj2 = <format2>.

      CALL METHOD format_obj2->(`IF_XCO_CP_CS_FORMAT_FACTORY~ADT`)
        RECEIVING
          ro_adt = format_obj3.

      CALL METHOD format_obj3->(`WITH_LINE_NUMBER_FLAVOR`)
        EXPORTING
          io_line_number_flavor = <format>
        RECEIVING
          ro_me                 = format_source.

      lv_xco_cp = `XCO_CP`.
      ASSIGN (lv_xco_cp)=>(`CURRENT`) TO <current>.
      current_obj = <current>.

      ASSIGN current_obj->(`IF_XCO_CP_STD_CURRENT~CALL_STACK`) TO <call_stack>.
      stack = <call_stack>.

      CALL METHOD stack->(`IF_XCO_CP_STD_CUR_API_CLL_STCK~FULL`)
        RECEIVING
          ro_full = full_stack.

      
      CREATE DATA r TYPE REF TO (`IF_XCO_CS_FORMAT`).
      ASSIGN r->* TO <any>.
      <any> ?= format_source.

      CALL METHOD full_stack->(`IF_XCO_CP_CALL_STACK~AS_TEXT`)
        EXPORTING
          io_format = <any>
        RECEIVING
          ro_text   = text_obj.

      CALL METHOD text_obj->(`IF_XCO_TEXT~GET_LINES`)
        RECEIVING
          ro_lines = ro_lines.

      
      ASSIGN ro_lines->(`IF_XCO_STRINGS~VALUE`) TO <lt_lines>.

      
      LOOP AT <lt_lines> INTO text.
        
        CLEAR temp443.
        
        ls_stack = temp443.
        SPLIT text AT ` ` INTO ls_stack-class ls_stack-include ls_stack-method.
        INSERT ls_stack INTO TABLE result.
      ENDLOOP.

      DELETE result INDEX 1.

    ENDIF.

  ENDMETHOD.

  METHOD context_get_sy.

    MOVE-CORRESPONDING sy TO result.

  ENDMETHOD.


  METHOD msg_get_text.

    DATA lt_msg TYPE zabaputil_cl_util_context=>ty_t_msg.
      DATA temp444 LIKE LINE OF lt_msg.
      DATA temp445 LIKE sy-tabix.
    lt_msg = msg_get_t( val = val val2 = val2 ).
    IF lt_msg IS NOT INITIAL.
      
      
      temp445 = sy-tabix.
      READ TABLE lt_msg INDEX 1 INTO temp444.
      sy-tabix = temp445.
      IF sy-subrc <> 0.
        ASSERT 1 = 0.
      ENDIF.
      result = temp444-text.
    ENDIF.

  ENDMETHOD.

  METHOD msg_get_by_sy.

    result = msg_get_t( context_get_sy( ) ).

  ENDMETHOD.

  METHOD msg_get_internal.

    DATA lv_kind TYPE string.
        FIELD-SYMBOLS <tab> TYPE ANY TABLE.
        FIELD-SYMBOLS <row> TYPE ANY.
          DATA lt_tab TYPE zabaputil_cl_util_context=>ty_t_msg.
        DATA lt_attri TYPE abap_component_tab.
        DATA temp446 TYPE ty_s_msg.
        DATA ls_result LIKE temp446.
        DATA temp447 LIKE LINE OF lt_attri.
        DATA ls_attri LIKE REF TO temp447.
          FIELD-SYMBOLS <comp> TYPE any.
          DATA temp448 TYPE zabaputil_cl_util_context=>ty_s_msg.
    lv_kind = rtti_get_type_kind( val ).
    CASE lv_kind.

      WHEN cl_abap_datadescr=>typekind_table.
        
        ASSIGN val TO <tab>.
        
        LOOP AT <tab> ASSIGNING <row>.
          
          lt_tab = msg_get_internal( <row> ).
          INSERT LINES OF lt_tab INTO TABLE result.
        ENDLOOP.

      WHEN cl_abap_datadescr=>typekind_struct1 OR cl_abap_datadescr=>typekind_struct2.

        IF val IS INITIAL.
          RETURN.
        ENDIF.

        IF check_is_rap_struct( val ) = abap_true.
          result = msg_get_rap( val ).
          RETURN.
        ENDIF.

        
        lt_attri = rtti_get_t_attri_by_any( val ).

        
        CLEAR temp446.
        
        ls_result = temp446.
        
        
        LOOP AT lt_attri REFERENCE INTO ls_attri.
          
          ASSIGN COMPONENT ls_attri->name OF STRUCTURE val TO <comp>.
          IF sy-subrc <> 0.
            CONTINUE.
          ENDIF.

          IF ls_attri->name = `ITEM`.
            lt_tab = msg_get_internal( <comp> ).
            INSERT LINES OF lt_tab INTO TABLE result.
            RETURN.
          ELSE.
            ls_result = msg_map( name = ls_attri->name val = <comp> msg = ls_result ).
          ENDIF.

        ENDLOOP.
        IF ls_result-text IS INITIAL AND ls_result-id IS NOT INITIAL.
          ls_result-id = to_upper( ls_result-id ).
          MESSAGE ID ls_result-id TYPE `I` NUMBER ls_result-no
                  WITH ls_result-v1 ls_result-v2 ls_result-v3 ls_result-v4
                  INTO ls_result-text.
        ENDIF.
        INSERT ls_result INTO TABLE result.

      WHEN cl_abap_datadescr=>typekind_oref.
        result = msg_get_by_oref( val ).

      WHEN OTHERS.

        " skip an empty character value like the struct branch does -
        " otherwise msg_get_t's val2 fallback can never take over and the
        " caller renders a message box with blank text
        IF rtti_check_clike( val ) IS NOT INITIAL AND val IS NOT INITIAL.
          
          CLEAR temp448.
          temp448-text = val.
          INSERT temp448 INTO TABLE result.
        ENDIF.
    ENDCASE.

  ENDMETHOD.

  METHOD msg_get_by_oref.

    FIELD-SYMBOLS <comp> TYPE any.
        DATA temp449 TYPE REF TO cx_root.
        DATA lx LIKE temp449.
        DATA temp450 TYPE ty_s_msg.
        DATA ls_result LIKE temp450.
        DATA lt_attri_o TYPE abap_attrdescr_tab.
        DATA temp451 LIKE LINE OF lt_attri_o.
        DATA ls_attri_o LIKE REF TO temp451.
          DATA lv_name LIKE ls_attri_o->name.
        DATA obj TYPE REF TO object.
            DATA lr_tab TYPE REF TO data.
            FIELD-SYMBOLS <tab2> TYPE data.
            DATA lt_tab2 TYPE zabaputil_cl_util_context=>ty_t_msg.

    TRY.
        
        temp449 ?= val.
        
        lx = temp449.
        
        CLEAR temp450.
        temp450-type = `E`.
        temp450-text = lx->get_text( ).
        
        ls_result = temp450.
        
        lt_attri_o = rtti_get_t_attri_by_oref( val ).
        
        
        LOOP AT lt_attri_o REFERENCE INTO ls_attri_o
             WHERE visibility = cv_objectdescr_public.
          
          lv_name = ls_attri_o->name.
          ASSIGN lx->(lv_name) TO <comp>.
          IF sy-subrc <> 0.
            CONTINUE.
          ENDIF.
          ls_result = msg_map( name = ls_attri_o->name val = <comp> msg = ls_result ).
        ENDLOOP.
        INSERT ls_result INTO TABLE result.
      CATCH cx_root.

        
        obj = val.

        TRY.

            
            CREATE DATA lr_tab TYPE (`if_bali_log=>ty_item_table`).
            
            ASSIGN lr_tab->* TO <tab2>.

            CALL METHOD obj->(`IF_BALI_LOG~GET_ALL_ITEMS`)
              RECEIVING
                item_table = <tab2>.

            
            lt_tab2 = msg_get_internal( <tab2> ).
            INSERT LINES OF lt_tab2 INTO TABLE result.

          CATCH cx_root.

            TRY.

                CREATE DATA lr_tab TYPE (`BAPIRETTAB`).
                ASSIGN lr_tab->* TO <tab2>.

                CALL METHOD obj->(`ZIF_LOGGER~EXPORT_TO_TABLE`)
                  RECEIVING
                    rt_bapiret = <tab2>.

                lt_tab2 = msg_get_internal( <tab2> ).
                INSERT LINES OF lt_tab2 INTO TABLE result.

              CATCH cx_root.

                lt_attri_o = rtti_get_t_attri_by_oref( val ).
                LOOP AT lt_attri_o REFERENCE INTO ls_attri_o
                     WHERE visibility = cv_objectdescr_public.
                  lv_name = ls_attri_o->name.
                  ASSIGN obj->(lv_name) TO <comp>.
                  IF sy-subrc <> 0.
                    CONTINUE.
                  ENDIF.
                  ls_result = msg_map( name = ls_attri_o->name val = <comp> msg = ls_result ).
                ENDLOOP.
                INSERT ls_result INTO TABLE result.

            ENDTRY.
        ENDTRY.
    ENDTRY.

  ENDMETHOD.

  METHOD msg_map.

    result = msg.
    CASE name.
      WHEN `ID` OR `MSGID`.
        result-id = val.
      WHEN `NO` OR `NUMBER` OR `MSGNO`.
        result-no = val.
      WHEN `MESSAGE` OR `TEXT`.
        result-text = val.
      WHEN `TYPE` OR `MSGTY` OR `M_SEVERITY`.
        result-type = val.
      WHEN `MESSAGE_V1` OR `MSGV1` OR `V1`.
        result-v1 = val.
      WHEN `MESSAGE_V2` OR `MSGV2` OR `V2`.
        result-v2 = val.
      WHEN `MESSAGE_V3` OR `MSGV3` OR `V3`.
        result-v3 = val.
      WHEN `MESSAGE_V4` OR `MSGV4` OR `V4`.
        result-v4 = val.
      WHEN `TIME_STMP`.
        result-timestampl = val.
    ENDCASE.

  ENDMETHOD.

  METHOD check_is_rap_struct.

    DATA lt_attri TYPE abap_component_tab.
    DATA temp452 LIKE LINE OF lt_attri.
    DATA ls_attri LIKE REF TO temp452.
      FIELD-SYMBOLS <tab> TYPE any.
          DATA temp453 TYPE REF TO cl_abap_tabledescr.
          DATA lo_tab LIKE temp453.
          DATA lo_line TYPE REF TO cl_abap_datadescr.
          DATA temp454 TYPE REF TO cl_abap_structdescr.
          DATA lt_comps TYPE abap_component_tab.
          DATA temp455 LIKE LINE OF lt_comps.
          DATA ls_comp LIKE REF TO temp455.
    lt_attri = rtti_get_t_attri_by_any( val ).

    
    
    LOOP AT lt_attri REFERENCE INTO ls_attri.
      CASE ls_attri->name.
        WHEN `%MSG` OR `%FAIL` OR `%OTHER`.
          result = abap_true.
          RETURN.
      ENDCASE.
    ENDLOOP.

    LOOP AT lt_attri REFERENCE INTO ls_attri.
      
      ASSIGN COMPONENT ls_attri->name OF STRUCTURE val TO <tab>.
      CHECK sy-subrc = 0.
      CHECK rtti_get_type_kind( <tab> ) = cl_abap_datadescr=>typekind_table.

      TRY.
          
          temp453 ?= cl_abap_typedescr=>describe_by_data( <tab> ).
          
          lo_tab = temp453.
          
          lo_line = lo_tab->get_table_line_type( ).
          CHECK lo_line->kind = cl_abap_typedescr=>kind_struct.
          
          temp454 ?= lo_line.
          
          lt_comps = temp454->get_components( ).
          
          
          LOOP AT lt_comps REFERENCE INTO ls_comp.
            IF ls_comp->name = `%MSG` OR ls_comp->name = `%FAIL`.
              result = abap_true.
              RETURN.
            ENDIF.
          ENDLOOP.
        CATCH cx_root ##NO_HANDLER.
      ENDTRY.
    ENDLOOP.

  ENDMETHOD.

  METHOD msg_get_rap.

    DATA lv_kind TYPE string.
    DATA lv_is_row TYPE abap_bool.
    DATA lt_attri TYPE abap_component_tab.
    DATA temp456 LIKE LINE OF lt_attri.
    DATA ls_attri LIKE REF TO temp456.
      FIELD-SYMBOLS <tab> TYPE any.
      FIELD-SYMBOLS <ftab> TYPE ANY TABLE.
      FIELD-SYMBOLS <row> TYPE ANY.
    lv_kind = rtti_get_type_kind( val ).
    IF lv_kind <> cl_abap_datadescr=>typekind_struct1
       AND lv_kind <> cl_abap_datadescr=>typekind_struct2.
      RETURN.
    ENDIF.

    
    msg_get_rap_row( EXPORTING val         = val
                               entity_name = entity_name
                     IMPORTING messages    = result
                               is_row      = lv_is_row ).
    IF lv_is_row = abap_true.
      RETURN.
    ENDIF.

    
    lt_attri = rtti_get_t_attri_by_any( val ).
    
    
    LOOP AT lt_attri REFERENCE INTO ls_attri.
      
      ASSIGN COMPONENT ls_attri->name OF STRUCTURE val TO <tab>.
      CHECK sy-subrc = 0.
      CHECK rtti_get_type_kind( <tab> ) = cl_abap_datadescr=>typekind_table.

      
      ASSIGN <tab> TO <ftab>.

      
      LOOP AT <ftab> ASSIGNING <row>.
        IF rtti_get_type_kind( <row> ) = cl_abap_datadescr=>typekind_oref.
          IF <row> IS NOT INITIAL.
            TRY.
                INSERT LINES OF msg_get_t( <row> ) INTO TABLE result.
              CATCH cx_root ##NO_HANDLER.
            ENDTRY.
          ENDIF.
        ELSE.
          INSERT LINES OF msg_get_rap( val         = <row>
                                       entity_name = ls_attri->name ) INTO TABLE result.
        ENDIF.
      ENDLOOP.
    ENDLOOP.

  ENDMETHOD.

  METHOD msg_get_rap_row.
    DATA lv_meta_built TYPE abap_bool.
    DATA lt_meta TYPE ty_t_name_value.
    FIELD-SYMBOLS <msg> TYPE any.
            DATA lt_one TYPE zabaputil_cl_util_context=>ty_t_msg.
            FIELD-SYMBOLS <m> LIKE LINE OF lt_one.
    FIELD-SYMBOLS <fail> TYPE any.
      FIELD-SYMBOLS <cause> TYPE any.
        DATA lv_cause TYPE i.
        DATA lv_text TYPE string.
        DATA temp457 TYPE zabaputil_cl_util_context=>ty_s_msg.

    CLEAR messages.
    is_row = abap_false.

    " the meta block is built LAZILY: msg_get_rap_meta walks the row's
    " components three times over (element/action/tky scans), and the
    " common row in a RAP response table carries neither a filled %MSG nor
    " a %FAIL - building the block up front threw that work away per row
    
    

    
    ASSIGN COMPONENT `%MSG` OF STRUCTURE val TO <msg>.
    IF sy-subrc = 0.
      is_row = abap_true.
      IF <msg> IS NOT INITIAL.
        lt_meta = msg_get_rap_meta( val ).
        lv_meta_built = abap_true.
        TRY.
            
            lt_one = msg_get_t( <msg> ).
            
            LOOP AT lt_one ASSIGNING <m>.
              <m>-t_meta = lt_meta.
            ENDLOOP.
            INSERT LINES OF lt_one INTO TABLE messages.
          CATCH cx_root ##NO_HANDLER.
        ENDTRY.
      ENDIF.
    ENDIF.

    
    ASSIGN COMPONENT `%FAIL` OF STRUCTURE val TO <fail>.
    IF sy-subrc = 0.
      is_row = abap_true.
      
      ASSIGN COMPONENT `CAUSE` OF STRUCTURE <fail> TO <cause>.
      IF sy-subrc = 0.
        IF lv_meta_built = abap_false.
          lt_meta = msg_get_rap_meta( val ).
        ENDIF.
        
        lv_cause = <cause>.
        
        lv_text = msg_get_rap_fail_text( lv_cause ).
        IF entity_name IS NOT INITIAL.
          lv_text = |{ entity_name }: { lv_text }|.
        ENDIF.
        
        CLEAR temp457.
        temp457-type = `E`.
        temp457-text = lv_text.
        temp457-t_meta = lt_meta.
        INSERT temp457 INTO TABLE messages.
      ENDIF.
    ENDIF.

  ENDMETHOD.

  METHOD get_comp_str.

    FIELD-SYMBOLS <comp> TYPE any.
    ASSIGN COMPONENT comp OF STRUCTURE val TO <comp>.
    IF sy-subrc = 0.
      result = <comp>.
    ENDIF.

  ENDMETHOD.

  METHOD scan_flag_prefix.

    DATA lv_len TYPE i.
    DATA lt_attri TYPE abap_component_tab.
    DATA temp458 LIKE LINE OF lt_attri.
    DATA ls_attri LIKE REF TO temp458.
      FIELD-SYMBOLS <flag> TYPE any.
    lv_len = strlen( prefix ).
    
    lt_attri = rtti_get_t_attri_by_any( val ).
    
    
    LOOP AT lt_attri REFERENCE INTO ls_attri.
      CHECK strlen( ls_attri->name ) > lv_len.
      CHECK ls_attri->name(lv_len) = prefix.
      
      ASSIGN COMPONENT ls_attri->name OF STRUCTURE val TO <flag>.
      CHECK sy-subrc = 0.
      CHECK <flag> IS NOT INITIAL.
      APPEND ls_attri->name+lv_len TO result.
    ENDLOOP.

  ENDMETHOD.

  METHOD msg_get_rap_element.

    DATA lt_suffix TYPE string_table.
    lt_suffix = scan_flag_prefix( val       = val
                                        prefix = `%ELEMENT-` ).
    result = concat_lines_of( table = lt_suffix
                              sep   = `, ` ).

  ENDMETHOD.

  METHOD msg_get_rap_state_area.

    result = get_comp_str( val     = val
                           comp = `%STATE_AREA` ).

  ENDMETHOD.

  METHOD msg_get_rap_action.

    DATA lt_suffix TYPE string_table.
    DATA temp459 TYPE string.
    DATA temp460 TYPE string.
    lt_suffix = scan_flag_prefix( val       = val
                                        prefix = `%OP-%ACTION-` ).
    
    CLEAR temp459.
    
    READ TABLE lt_suffix INTO temp460 INDEX 1.
    IF sy-subrc = 0.
      temp459 = temp460.
    ENDIF.
    result = temp459.

  ENDMETHOD.

  METHOD msg_get_rap_pid.

    result = get_comp_str( val     = val
                           comp = `%PID` ).

  ENDMETHOD.

  METHOD msg_get_rap_cid.

    result = get_comp_str( val     = val
                           comp = `%CID` ).

  ENDMETHOD.

  METHOD msg_get_rap_tky.

    FIELD-SYMBOLS <tky> TYPE any.
    ASSIGN COMPONENT `%TKY` OF STRUCTURE val TO <tky>.
    IF sy-subrc <> 0 OR <tky> IS INITIAL.
      RETURN.
    ENDIF.
    result = msg_get_rap_flatten( <tky> ).

  ENDMETHOD.

  METHOD msg_get_rap_flatten.

    DATA lv_kind TYPE string.
    DATA lt_attri TYPE abap_component_tab.
    DATA temp461 LIKE LINE OF lt_attri.
    DATA ls_attri LIKE REF TO temp461.
      FIELD-SYMBOLS <comp> TYPE any.
      DATA lv_sub_kind TYPE string.
        DATA lv_sub TYPE string.
            DATA lv_str TYPE string.
    lv_kind = rtti_get_type_kind( val ).
    IF lv_kind <> cl_abap_datadescr=>typekind_struct1
       AND lv_kind <> cl_abap_datadescr=>typekind_struct2.
      RETURN.
    ENDIF.

    
    lt_attri = rtti_get_t_attri_by_any( val ).
    
    
    LOOP AT lt_attri REFERENCE INTO ls_attri.
      
      ASSIGN COMPONENT ls_attri->name OF STRUCTURE val TO <comp>.
      CHECK sy-subrc = 0.

      
      lv_sub_kind = rtti_get_type_kind( <comp> ).
      IF lv_sub_kind = cl_abap_datadescr=>typekind_struct1
         OR lv_sub_kind = cl_abap_datadescr=>typekind_struct2.
        
        lv_sub = msg_get_rap_flatten( <comp> ).
        IF lv_sub IS NOT INITIAL.
          IF result IS NOT INITIAL.
            result = |{ result }, |.
          ENDIF.
          result = |{ result }{ lv_sub }|.
        ENDIF.
      ELSEIF <comp> IS NOT INITIAL.
        TRY.
            
            lv_str = <comp>.
            IF result IS NOT INITIAL.
              result = |{ result }, |.
            ENDIF.
            result = |{ result }{ ls_attri->name }={ lv_str }|.
          CATCH cx_root ##NO_HANDLER.
        ENDTRY.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD msg_get_rap_meta.

    DATA lv TYPE string.
      DATA temp462 TYPE zabaputil_cl_util_context=>ty_s_name_value.
      DATA temp463 TYPE zabaputil_cl_util_context=>ty_s_name_value.
      DATA temp464 TYPE zabaputil_cl_util_context=>ty_s_name_value.
      DATA temp465 TYPE zabaputil_cl_util_context=>ty_s_name_value.
      DATA temp466 TYPE zabaputil_cl_util_context=>ty_s_name_value.
      DATA temp467 TYPE zabaputil_cl_util_context=>ty_s_name_value.

    lv = msg_get_rap_element( val ).
    IF lv IS NOT INITIAL.
      
      CLEAR temp462.
      temp462-n = `element`.
      temp462-v = lv.
      INSERT temp462 INTO TABLE result.
    ENDIF.

    lv = msg_get_rap_state_area( val ).
    IF lv IS NOT INITIAL.
      
      CLEAR temp463.
      temp463-n = `state_area`.
      temp463-v = lv.
      INSERT temp463 INTO TABLE result.
    ENDIF.

    lv = msg_get_rap_action( val ).
    IF lv IS NOT INITIAL.
      
      CLEAR temp464.
      temp464-n = `action`.
      temp464-v = lv.
      INSERT temp464 INTO TABLE result.
    ENDIF.

    lv = msg_get_rap_pid( val ).
    IF lv IS NOT INITIAL.
      
      CLEAR temp465.
      temp465-n = `pid`.
      temp465-v = lv.
      INSERT temp465 INTO TABLE result.
    ENDIF.

    lv = msg_get_rap_cid( val ).
    IF lv IS NOT INITIAL.
      
      CLEAR temp466.
      temp466-n = `cid`.
      temp466-v = lv.
      INSERT temp466 INTO TABLE result.
    ENDIF.

    lv = msg_get_rap_tky( val ).
    IF lv IS NOT INITIAL.
      
      CLEAR temp467.
      temp467-n = `tky`.
      temp467-v = lv.
      INSERT temp467 INTO TABLE result.
    ENDIF.

  ENDMETHOD.

  METHOD msg_get_rap_fail_text.

    DATA temp468 TYPE string.
    CASE cause.
      WHEN 0.
        temp468 = `Operation failed`.
      WHEN 1.
        temp468 = `Entity not found`.
      WHEN 2.
        temp468 = `Entity is locked`.
      WHEN 3.
        temp468 = `Authorization failure`.
      WHEN 4.
        temp468 = `Concurrent modification`.
      WHEN 5.
        temp468 = `Concurrent modification`.
      WHEN 6.
        temp468 = `Operation disabled`.
      WHEN 7.
        temp468 = `Operation forbidden`.
      WHEN 8.
        temp468 = `Semantic error`.
      WHEN 9.
        temp468 = `Determination failed`.
      WHEN 10.
        temp468 = `Permission denied`.
      WHEN 11.
        temp468 = `Validation failed`.
      WHEN OTHERS.
        temp468 = |Operation failed (cause code { cause })|.
    ENDCASE.
    result = temp468.

  ENDMETHOD.

  METHOD rtti_get_t_attri_on_prem.

    DATA structdescr TYPE REF TO cl_abap_structdescr.
    DATA dfies       TYPE REF TO data.
    DATA s_dfies     TYPE ty_s_dfies.

    FIELD-SYMBOLS <dfies> TYPE STANDARD TABLE.
    FIELD-SYMBOLS <line>  TYPE any.

    DATA temp9           TYPE cl_abap_structdescr=>component_table.
    DATA comps           LIKE temp9.
    DATA temp10          TYPE REF TO cl_abap_structdescr.
    DATA lo_struct       LIKE temp10.
    DATA new_struct_desc TYPE REF TO cl_abap_structdescr.
    DATA new_table_desc  TYPE REF TO cl_abap_tabledescr.
    DATA comp            LIKE LINE OF comps.
    FIELD-SYMBOLS <value>      TYPE any.
    FIELD-SYMBOLS <value_dest> TYPE any.

    comps = temp9.

*    TYPES: BEGIN OF ty_s_dfies,
*             tabname     TYPE c LENGTH 30,
*             fieldname   TYPE c LENGTH 30,
*             langu       TYPE c LENGTH 1,
*             position    TYPE n LENGTH 4,
*             offset      TYPE n LENGTH 6,
*             domname     TYPE c LENGTH 30,
*             rollname    TYPE c LENGTH 30,
*             checktable  TYPE c LENGTH 30,
*             leng        TYPE n LENGTH 6,
*             intlen      TYPE n LENGTH 6,
*             outputlen   TYPE n LENGTH 6,
*             decimals    TYPE n LENGTH 6,
*             datatype    TYPE c LENGTH 4,
*             inttype     TYPE c LENGTH 1,
*             reftable    TYPE c LENGTH 30,
*             reffield    TYPE c LENGTH 30,
*             precfield   TYPE c LENGTH 30,
*             authorid    TYPE c LENGTH 3,
*             memoryid    TYPE c LENGTH 20,
*             logflag     TYPE c LENGTH 1,
*             mask        TYPE c LENGTH 20,
*             masklen     TYPE n LENGTH 4,
*             convexit    TYPE c LENGTH 5,
*             headlen     TYPE n LENGTH 2,
*             scrlen1     TYPE n LENGTH 2,
*             scrlen2     TYPE n LENGTH 2,
*             scrlen3     TYPE n LENGTH 2,
*             fieldtext   TYPE c LENGTH 60,
*             reptext     TYPE c LENGTH 55,
*             scrtext_s   TYPE c LENGTH 10,
*             scrtext_m   TYPE c LENGTH 20,
*             scrtext_l   TYPE c LENGTH 40,
*             keyflag     TYPE c LENGTH 1,
*             lowercase   TYPE c LENGTH 1,
*             mac         TYPE c LENGTH 1,
*             genkey      TYPE c LENGTH 1,
*             noforkey    TYPE c LENGTH 1,
*             valexi      TYPE c LENGTH 1,
*             noauthch    TYPE c LENGTH 1,
*             sign        TYPE c LENGTH 1,
*             dynpfld     TYPE c LENGTH 1,
*             f4availabl  TYPE c LENGTH 1,
*             comptype    TYPE c LENGTH 1,
*             lfieldname  TYPE c LENGTH 132,
*             ltrflddis   TYPE c LENGTH 1,
*             bidictrlc   TYPE c LENGTH 1,
*             outputstyle TYPE n LENGTH 2,
*             nohistory   TYPE c LENGTH 1,
*             ampmformat  TYPE c LENGTH 1,
*           END OF ty_s_dfies.
*    temp10 ?= cl_abap_structdescr=>describe_by_name( `TY_S_DFIES` ).

    temp10 ?= cl_abap_structdescr=>describe_by_name( `DFIES` ).

    lo_struct = temp10.
    comps = lo_struct->get_components( ).

    TRY.

        new_struct_desc = cl_abap_structdescr=>create( comps ).

        new_table_desc = cl_abap_tabledescr=>create( p_line_type  = new_struct_desc
                                                     p_table_kind = cl_abap_tabledescr=>tablekind_std ).

        CREATE DATA dfies TYPE HANDLE new_table_desc.

        ASSIGN dfies->* TO <dfies>.
        IF <dfies> IS NOT ASSIGNED.
          RETURN.
        ENDIF.

        IF tabname IS INITIAL.
          RAISE EXCEPTION TYPE zabaputil_cx_util_error
            EXPORTING
              val = `RTTI_BY_NAME_TAB_INITIAL`.
        ENDIF.

        structdescr ?= cl_abap_structdescr=>describe_by_name( tabname ).
        <dfies> = structdescr->get_ddic_field_list( ).

        LOOP AT <dfies> ASSIGNING <line>.

          LOOP AT comps INTO comp.

            ASSIGN COMPONENT comp-name OF STRUCTURE <line> TO <value>.
            IF <value> IS NOT ASSIGNED.
              CONTINUE.
            ENDIF.

            ASSIGN COMPONENT comp-name OF STRUCTURE s_dfies TO <value_dest>.
            IF <value_dest> IS NOT ASSIGNED.
              CONTINUE.
            ENDIF.

            <value_dest> = <value>.

            UNASSIGN <value>.
            UNASSIGN <value_dest>.

          ENDLOOP.

          APPEND s_dfies TO result.
          CLEAR s_dfies.

        ENDLOOP.

      CATCH cx_root ##NO_HANDLER.
    ENDTRY.

  ENDMETHOD.

  METHOD rtti_get_t_attri_on_cloud.

    DATA obj TYPE REF TO object.
    DATA lv_tabname TYPE c LENGTH 16.
    DATA lr_ddfields TYPE REF TO data.
    TYPES ty_c30 TYPE c LENGTH 30.
    TYPES temp8 TYPE STANDARD TABLE OF ty_c30 WITH DEFAULT KEY.
DATA names TYPE temp8.
    FIELD-SYMBOLS <any> TYPE any.
    FIELD-SYMBOLS <field> TYPE simple.
    FIELD-SYMBOLS <ddfields> TYPE ANY TABLE.
            DATA lv_method2 TYPE string.
            DATA workaround TYPE string.
            DATA temp469 TYPE REF TO cl_abap_structdescr.
    DATA lt_comp TYPE abap_component_tab.
    DATA temp470 LIKE LINE OF lt_comp.
    DATA lr_comp LIKE REF TO temp470.
      DATA lv_check_key LIKE abap_false.
      DATA temp471 LIKE sy-subrc.
      DATA temp472 TYPE zabaputil_cl_util_context=>ty_s_dfies.

* convert to correct type,
    lv_tabname = tabname.

    TRY.
        TRY.
            
            lv_method2 = `XCO_CP_ABAP_DICTIONARY`.
            CALL METHOD (lv_method2)=>(`DATABASE_TABLE`)
              EXPORTING
                iv_name           = lv_tabname
              RECEIVING
                ro_database_table = obj.
            ASSIGN obj->(`IF_XCO_DATABASE_TABLE~FIELDS->IF_XCO_DBT_FIELDS_FACTORY~KEY`) TO <any>.
            IF sy-subrc  <> 0.
* fallback to RTTI, KEY field does not exist in S/4 2020
              RAISE EXCEPTION TYPE cx_sy_dyn_call_illegal_class.
            ENDIF.
            obj = <any>.
            CALL METHOD obj->(`IF_XCO_DBT_FIELDS~GET_NAMES`)
              RECEIVING
                rt_names = names.
          CATCH cx_sy_dyn_call_illegal_class.
            
            workaround = `DDFIELDS`.
            CREATE DATA lr_ddfields TYPE (workaround).
            ASSIGN lr_ddfields->* TO <ddfields>.
            ASSERT sy-subrc = 0.
            
            temp469 ?= cl_abap_typedescr=>describe_by_name( lv_tabname ).
            <ddfields> = temp469->get_ddic_field_list( ).
            LOOP AT <ddfields> ASSIGNING <any>.
              ASSIGN COMPONENT `KEYFLAG` OF STRUCTURE <any> TO <field>.
              IF sy-subrc <> 0 OR <field> <> abap_true.
                CONTINUE.
              ENDIF.
              ASSIGN COMPONENT `FIELDNAME` OF STRUCTURE <any> TO <field>.
              ASSERT sy-subrc = 0.
              APPEND <field> TO names.
            ENDLOOP.
        ENDTRY.
      CATCH cx_root ##NO_HANDLER.
    ENDTRY.


    
    lt_comp  =  zabaputil_cl_util_context=>rtti_get_t_attri_by_any( tabname ).
    
    
    LOOP AT lt_comp REFERENCE INTO lr_comp.

      
      lv_check_key = abap_false.
      
      READ TABLE names WITH KEY table_line = lr_comp->name TRANSPORTING NO FIELDS.
      temp471 = sy-subrc.
      IF temp471 = 0.
        lv_check_key = abap_true.
      ENDIF.

      
      CLEAR temp472.
      temp472-fieldname = lr_comp->name.
      temp472-rollname = lr_comp->name.
      temp472-keyflag = lv_check_key.
      temp472-scrtext_s = lr_comp->name.
      temp472-scrtext_m = lr_comp->name.
      temp472-scrtext_l = lr_comp->name.
      INSERT temp472 INTO TABLE result.

    ENDLOOP.
*            structdescr->
*        <dfies> = structdescr->get_ddic_field_list( ).

*        LOOP AT <dfies> ASSIGNING <line>.
*
*          LOOP AT comps INTO comp.
*
*            ASSIGN COMPONENT comp-name OF STRUCTURE <line> TO <value>.
*            IF <value> IS NOT ASSIGNED.
*              CONTINUE.
*            ENDIF.
*
*            ASSIGN COMPONENT comp-name OF STRUCTURE s_dfies TO <value_dest>.
*            IF <value_dest> IS NOT ASSIGNED.
*              CONTINUE.
*            ENDIF.
*
*            <value_dest> = <value>.
*
*            UNASSIGN <value>.
*            UNASSIGN <value_dest>.
*
*          ENDLOOP.
*
*          APPEND s_dfies TO result.
*          CLEAR s_dfies.
*
*        ENDLOOP.



*    DATA db        TYPE REF TO object.
*    DATA fields    TYPE REF TO object.
*    DATA r_names   TYPE REF TO data.
*    DATA t_param   TYPE abap_parmbind_tab.
*    DATA field     TYPE REF TO object.
*    DATA content   TYPE REF TO object.
*    DATA r_content TYPE REF TO data.
*    DATA type      TYPE REF TO object.
*    DATA element   TYPE REF TO object.
*    DATA tab       TYPE c LENGTH 16.
*
*    FIELD-SYMBOLS <any>   TYPE any.
*    FIELD-SYMBOLS <names> TYPE STANDARD TABLE.
*    FIELD-SYMBOLS <name>  TYPE any.
*    FIELD-SYMBOLS <fiel>  TYPE REF TO object.
*
*    tab = tabname.
*
*    CALL METHOD (`XCO_CP_ABAP_DICTIONARY`)=>database_table
*      EXPORTING
*        iv_name           = tab
*      RECEIVING
*        ro_database_table = db.
*
*    ASSIGN db->(`IF_XCO_DATABASE_TABLE~FIELDS->IF_XCO_DBT_FIELDS_FACTORY~ALL`) TO <any>.
*
*    IF sy-subrc <> 0.
*      RETURN.
*    ENDIF.
*
*    fields = <any>.
*
*    CREATE DATA r_names TYPE (`SXCO_T_AD_FIELD_NAMES`).
*    ASSIGN r_names->* TO <Names>.
*    IF <Names> IS NOT ASSIGNED.
*      RETURN.
*    ENDIF.
*
*    CALL METHOD fields->(`IF_XCO_DBT_FIELDS~GET_NAMES`)
*      RECEIVING
*        rt_names = <Names>.
*
*    LOOP AT <Names> ASSIGNING <name>.
*
*      CLEAR t_param.
*
*      INSERT VALUE #( name  = `IV_NAME`
*                      kind  = cl_abap_objectdescr=>exporting
*                      value = REF #( <name> ) ) INTO TABLE t_param.
*      INSERT VALUE #( name  = `RO_FIELD`
*                      kind  = cl_abap_objectdescr=>receiving
*                      value = REF #( field ) ) INTO TABLE t_param.
*
*      CALL METHOD db->(`IF_XCO_DATABASE_TABLE~FIELD`)
*        PARAMETER-TABLE t_param.
*
*      ASSIGN t_param[ name = `RO_FIELD` ] TO FIELD-SYMBOL(<line>).
*      IF <line> IS NOT ASSIGNED.
*        CONTINUE.
*      ENDIF.
*      ASSIGN <line>-value->* TO <fiel>.
*      IF <fiel> IS NOT ASSIGNED.
*        CONTINUE.
*      ENDIF.
*
*      CALL METHOD <fiel>->(`IF_XCO_DBT_FIELD~CONTENT`)
*        RECEIVING
*          ro_content = content.
*
*      CREATE DATA r_content TYPE (`IF_XCO_DBT_FIELD_CONTENT=>TS_CONTENT`).
*      ASSIGN r_content->* TO FIELD-SYMBOL(<Content>) CASTING TYPE (`IF_XCO_DBT_FIELD_CONTENT=>TS_CONTENT`).
*      IF <content> IS NOT ASSIGNED.
*        CONTINUE.
*      ENDIF.
*
*      CALL METHOD content->(`IF_XCO_DBT_FIELD_CONTENT~GET`)
*        RECEIVING
*          rs_content = <Content>.
*
*      ASSIGN COMPONENT `KEY_INDICATOR` OF STRUCTURE <content> TO FIELD-SYMBOL(<key>).
*      IF <key> IS NOT ASSIGNED.
*        CONTINUE.
*      ENDIF.
*      ASSIGN COMPONENT `SHORT_DESCRIPTION` OF STRUCTURE <content> TO FIELD-SYMBOL(<text>).
*      IF <text> IS NOT ASSIGNED.
*        CONTINUE.
*      ENDIF.
*      ASSIGN COMPONENT `TYPE` OF STRUCTURE <content> TO FIELD-SYMBOL(<type>).
*      IF <type> IS NOT ASSIGNED.
*        CONTINUE.
*      ENDIF.
*
*      type = <type>.
*
*      CALL METHOD type->(`IF_XCO_DBT_FIELD_TYPE~GET_DATA_ELEMENT`)
*        RECEIVING
*          ro_data_element = element.
*
*      IF <text> IS INITIAL.
*        <text> = <name>.
*      ENDIF.
*
*      ASSIGN element->(`IF_XCO_AD_OBJECT~NAME`) TO FIELD-SYMBOL(<rname>).
*      IF <rname> IS NOT ASSIGNED.
*        CONTINUE.
*      ENDIF.
*
*      IF sy-subrc = 0.
*        result = VALUE #( BASE result
*                          ( fieldname = <name> keyflag = <key> tabname = tab scrtext_s = <text> rollname = <rname> ) ).
*      ELSE.
*        result = VALUE #( BASE result
*                          ( fieldname = <name> keyflag = <key> tabname = tab scrtext_s = <text> rollname = <name> ) ).
*      ENDIF.
*
*      UNASSIGN <Content>.
*      UNASSIGN <key>.
*      UNASSIGN <Text>.
*      UNASSIGN <type>.
*      UNASSIGN <rname>.
*
*    ENDLOOP.

  ENDMETHOD.

  METHOD rtti_get_t_dfies_by_table_name.

    IF zabaputil_cl_util_context=>check_abap_cloud( ) IS NOT INITIAL.
      result = rtti_get_t_attri_on_cloud( table_name ).
    ELSE.
      result = rtti_get_t_attri_on_prem( table_name ).
    ENDIF.

  ENDMETHOD.

  METHOD rtti_get_table_desrc.

    DATA ddtext TYPE c LENGTH 60.
      DATA lan LIKE sy-langu.
          DATA lv_tabname TYPE string.

    IF langu IS NOT SUPPLIED.
      
      lan = sy-langu.
    ELSE.
      lan = langu.
    ENDIF.

    IF zabaputil_cl_util_context=>check_abap_cloud( ) IS NOT INITIAL.

      ddtext = tabname.

    ELSE.

      TRY.
          
          lv_tabname = `dd02t`.
          SELECT SINGLE ddtext
            FROM (lv_tabname) INTO ddtext
            WHERE tabname    = tabname
              AND ddlanguage = lan
            .
        CATCH cx_root ##NO_HANDLER.
          " DD02T not available (e.g. JS transpiler runtime) - fall
          " back to the table name below
      ENDTRY.

    ENDIF.

    IF ddtext IS NOT INITIAL.
      result = ddtext.
    ELSE.
      result = tabname.
    ENDIF.

  ENDMETHOD.

  METHOD bus_search_help_read.

    TYPES temp9 TYPE TABLE OF string.
DATA lt_result_tab TYPE temp9.
    DATA ls_comp       TYPE abap_componentdescr.
    DATA lt_comps      TYPE abap_component_tab.
    DATA lo_datadescr  TYPE REF TO cl_abap_datadescr.
    DATA lr_line       TYPE REF TO data.

    " data ls_shlp type shlp_descr.

    DATA lr_shlp       TYPE REF TO data.

    DATA lv_type TYPE string.
    FIELD-SYMBOLS <shlp> TYPE any.
    DATA lv_tabname TYPE c LENGTH 30.
    DATA lv_fieldname TYPE c LENGTH 30.
      DATA lv_fm TYPE string.
        DATA lr_t_shlp TYPE REF TO data.
        DATA lv_type2 TYPE string.
        FIELD-SYMBOLS <shlp2> TYPE STANDARD TABLE.
        FIELD-SYMBOLS <row2> TYPE any.
      DATA temp473 LIKE LINE OF ms_shlp-interface.
      DATA r_interface LIKE REF TO temp473.
        FIELD-SYMBOLS <any> TYPE any.
        FIELD-SYMBOLS <value> TYPE any.
    DATA interface LIKE LINE OF ms_shlp-interface.
        DATA temp474 TYPE zabaputil_cl_util_context=>ty_shlp_descr-selopt.
        DATA temp475 LIKE LINE OF temp474.
        DATA temp72 TYPE zabaputil_cl_util_context=>ty_ddshselopt-option.
    DATA fieldrop LIKE LINE OF ms_shlp-fieldprop.
      DATA valule LIKE fieldrop-defaultval.
      DATA temp476 TYPE zabaputil_cl_util_context=>ty_shlp_descr-selopt.
      DATA temp477 LIKE LINE OF temp476.
      DATA temp73 TYPE zabaputil_cl_util_context=>ty_ddshselopt-option.
    DATA field_props LIKE LINE OF ms_shlp-fieldprop.
      DATA temp478 TYPE zabaputil_cl_util_context=>ty_s_dfies_2.
      DATA temp479 TYPE zabaputil_cl_util_context=>ty_s_dfies_2.
      DATA descption LIKE temp478.
    DATA temp480 LIKE sy-subrc.
    DATA strucdescr TYPE REF TO cl_abap_structdescr.
    DATA tabdescr TYPE REF TO cl_abap_tabledescr.
    FIELD-SYMBOLS <fs_target_tab> TYPE STANDARD TABLE.
    DATA result_line LIKE LINE OF lt_result_tab.
      FIELD-SYMBOLS <fs_line> TYPE data.
      DATA result_desc LIKE LINE OF mt_result_desc.
        FIELD-SYMBOLS <line_content> TYPE any.
    FIELD-SYMBOLS <tab> TYPE STANDARD TABLE.
    FIELD-SYMBOLS <line> TYPE any.
      FIELD-SYMBOLS <row> TYPE any.
    lv_type = `SHLP_DESCR`.
    CREATE DATA lr_shlp TYPE (lv_type).
    
    ASSIGN lr_shlp->* TO <shlp>.

    
    
    lv_tabname = mv_table.
    lv_fieldname = mv_fname.

    IF ms_shlp IS INITIAL.
      " Suchhilfe lesen
      
      lv_fm = `F4IF_DETERMINE_SEARCHHELP`.
      CALL FUNCTION lv_fm
        EXPORTING
          tabname           = lv_tabname
          fieldname         = lv_fieldname
        IMPORTING
          shlp              = <shlp>
        EXCEPTIONS
          field_not_found   = 1
          no_help_for_field = 2
          inconsistent_help = 3
          OTHERS            = 4.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zabaputil_cx_util_error
          EXPORTING
            val = |F4IF_DETERMINE_SEARCHHELP failed for { lv_tabname }-{ lv_fieldname }|.
      ENDIF.
      MOVE-CORRESPONDING <shlp> TO ms_shlp.

      IF ms_shlp-intdescr-issimple = abap_false.

*      DATA lt_shlp       TYPE shlp_desct.
        
        
        lv_type2 = `SHLP_DESCT`.
        CREATE DATA lr_t_shlp TYPE (lv_type2).
        
        ASSIGN lr_t_shlp->* TO <shlp2>.

        lv_fm = `F4IF_EXPAND_SEARCHHELP`.
        CALL FUNCTION lv_fm
          EXPORTING
            shlp_top = ms_shlp
          IMPORTING
            shlp_tab = <shlp2>.

*        DATA(ls_row) = CORRESPONDING #( <shlp2>[ 1 ] OPTIONAL ).
        
        READ TABLE <shlp2> INDEX 1 ASSIGNING <row2>.
        MOVE-CORRESPONDING <row2> TO ms_shlp.
      ENDIF.
    ENDIF.

    IF mr_data IS BOUND.
      " Values from Caller app to Interface Values
      
      
      LOOP AT ms_shlp-interface REFERENCE INTO r_interface WHERE value IS INITIAL.

        
        ASSIGN mr_data->* TO <any>.
        
        ASSIGN COMPONENT r_interface->shlpfield OF STRUCTURE <any> TO <value>.

        IF sy-subrc <> 0.
          CONTINUE.
        ENDIF.

        r_interface->value = <value>.

      ENDLOOP.
    ENDIF.

    " Interface Fixed Values to Selopt
    
    LOOP AT ms_shlp-interface INTO interface.

      " Match the name of the SH Field to the Input field name
      IF interface-valfield = mv_fname.
        mv_shlpfield = interface-shlpfield.
      ENDIF.

      IF interface-value IS NOT INITIAL.

        
        CLEAR temp474.
        temp474 = ms_shlp-selopt.
        
        temp475-shlpfield = interface-shlpfield.
        temp475-shlpname = interface-valtabname.
        
        IF interface-value CA `*`.
          temp72 = `CP`.
        ELSE.
          temp72 = `EQ`.
        ENDIF.
        temp475-option = temp72.
        temp475-sign = `I`.
        temp475-low = interface-value.
        INSERT temp475 INTO TABLE temp474.
        ms_shlp-selopt = temp474.

      ENDIF.

    ENDLOOP.

    
    LOOP AT ms_shlp-fieldprop INTO fieldrop.

      IF fieldrop-defaultval IS INITIAL.
        CONTINUE.
      ENDIF.

      
      valule = fieldrop-defaultval.
      REPLACE ALL OCCURRENCES OF `'` IN valule WITH ``.

      
      CLEAR temp476.
      temp476 = ms_shlp-selopt.
      
      temp477-shlpfield = fieldrop-fieldname.
      
      IF fieldrop-defaultval CA `*`.
        temp73 = `CP`.
      ELSE.
        temp73 = `EQ`.
      ENDIF.
      temp477-option = temp73.
      temp477-sign = `I`.
      temp477-low = valule.
      INSERT temp477 INTO TABLE temp476.
      ms_shlp-selopt = temp476.

    ENDLOOP.

    CREATE DATA lr_shlp TYPE (lv_type).
    ASSIGN lr_shlp->* TO <shlp>.
    CLEAR: <shlp>.
    MOVE-CORRESPONDING ms_shlp TO <shlp>.

    lv_fm = `F4IF_SELECT_VALUES`.
    CALL FUNCTION lv_fm
      EXPORTING
        shlp           = <shlp>
        sort           = space
        call_shlp_exit = abap_true
      TABLES
        record_tab     = lt_result_tab
        recdescr_tab   = mt_result_desc.

    SORT ms_shlp-fieldprop BY shlplispos ASCENDING.

    
    LOOP AT ms_shlp-fieldprop INTO field_props WHERE shlplispos IS NOT INITIAL.

      
      CLEAR temp478.
      
      READ TABLE mt_result_desc INTO temp479 WITH KEY fieldname = field_props-fieldname.
      IF sy-subrc = 0.
        temp478 = temp479.
      ENDIF.
      
      descption = temp478.

      ls_comp-name  = descption-fieldname.
      ls_comp-type ?= cl_abap_datadescr=>describe_by_name( descption-rollname ).
      APPEND ls_comp TO lt_comps.

    ENDLOOP.

    
    READ TABLE lt_comps WITH KEY name = `ROW_ID` TRANSPORTING NO FIELDS.
    temp480 = sy-subrc.
    IF NOT temp480 = 0.
      lo_datadescr ?= cl_abap_datadescr=>describe_by_name( `INT4` ).
      ls_comp-name  = `ROW_ID`.
      ls_comp-type ?= lo_datadescr.
      APPEND ls_comp TO lt_comps.
    ENDIF.

    
    strucdescr = cl_abap_structdescr=>create( p_components = lt_comps ).

    
    tabdescr = cl_abap_tabledescr=>create( p_line_type = strucdescr ).

    IF mt_data IS NOT BOUND.
      CREATE DATA mt_data TYPE HANDLE tabdescr.
    ENDIF.

    
    ASSIGN mt_data->* TO <fs_target_tab>.

    CLEAR <fs_target_tab>.

    " we don`t want to lose all inputs in row ...
    IF ms_data_row IS NOT BOUND.
      CREATE DATA ms_data_row TYPE HANDLE strucdescr.
    ENDIF.

    
    LOOP AT lt_result_tab INTO result_line.

      CREATE DATA lr_line TYPE HANDLE strucdescr.
      
      ASSIGN lr_line->* TO <fs_line>.

      
      LOOP AT mt_result_desc INTO result_desc.

        
        ASSIGN COMPONENT result_desc-fieldname OF STRUCTURE <fs_line>
               TO <line_content>.

        IF sy-subrc <> 0.
          CONTINUE.
        ENDIF.

        IF result_desc-leng < result_desc-intlen.
          " interne Darstellung anders als externe Darstellung
          " UNICODE, offset halbieren
          result_desc-offset = result_desc-offset / 2.
        ENDIF.

        TRY.
            <line_content> = result_line+result_desc-offset(result_desc-outputlen).
          CATCH cx_root.

            TRY.
                " String table will crash if value length <> outputlen
                <line_content> = result_line+result_desc-offset.
              CATCH cx_root ##NO_HANDLER.
            ENDTRY.
        ENDTRY.

      ENDLOOP.

      INSERT <fs_line> INTO TABLE <fs_target_tab>.

    ENDLOOP.

    " Set default values
    LOOP AT ms_shlp-interface INTO interface.

      IF interface-value IS NOT INITIAL.

        UNASSIGN <any>.
        ASSIGN ms_data_row->* TO <any>.
        ASSIGN COMPONENT interface-shlpfield OF STRUCTURE <any> TO <value>.

        IF sy-subrc <> 0.
          CONTINUE.
        ENDIF.
        <value> = interface-value.

      ENDIF.

    ENDLOOP.

*    LOOP AT ms_shlp-fieldprop INTO fieldrop.
*
*      IF fieldrop-defaultval IS NOT INITIAL.
*
*        ASSIGN COMPONENT fieldrop-fieldname OF STRUCTURE ms_data_row->* TO <value>.
*
*        IF sy-subrc <> 0.
*          CONTINUE.
*        ENDIF.
*        <value> = fieldrop-defaultval.
*       REPLACE ALL OCCURRENCES OF ``` in <value> with ``.
*      ENDIF.
*
*    ENDLOOP.

*    set_row_id( ).

    
    

    ASSIGN mt_data->* TO <tab>.

    LOOP AT <tab> ASSIGNING <line>.

      
      ASSIGN COMPONENT 'ROW_ID' OF STRUCTURE <line> TO <row>.
      IF <row> IS ASSIGNED.
        <row> = sy-tabix.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD tab_get_where_by_dfies.

    DATA val TYPE string.

    DATA temp481 LIKE LINE OF it_dfies.
    DATA dfies LIKE REF TO temp481.
      FIELD-SYMBOLS <row> TYPE data.
      FIELD-SYMBOLS <value> TYPE any.
        DATA and TYPE string.
        DATA escape TYPE string.
    LOOP AT it_dfies REFERENCE INTO dfies.

      IF NOT ( dfies->keyflag = abap_true OR dfies->fieldname = mv_check_tab_field ).
        CONTINUE.
      ENDIF.

      
      ASSIGN ms_data_row->* TO <row>.

      
      ASSIGN COMPONENT dfies->fieldname OF STRUCTURE <row> TO <value>.
      IF <value> IS NOT ASSIGNED.
        CONTINUE.
      ENDIF.
      IF <value> IS INITIAL.
        CONTINUE.
      ENDIF.

      IF result IS NOT INITIAL.
        
        and = ` AND `.
      ENDIF.

      IF <value> CA `_`.
        
        escape = `ESCAPE '#'`.
      ELSE.
        CLEAR escape.
      ENDIF.

      val = <value>.

      IF val CA `_`.
        REPLACE ALL OCCURRENCES OF `_` IN val WITH `#_`.
      ENDIF.

      result = |{ result }{ and } ( { dfies->fieldname } LIKE '%{ val }%' { escape } )|.

    ENDLOOP.

  ENDMETHOD.

  METHOD _get_e071k_tabkey.

    DATA lv_type       TYPE c LENGTH 1.
    DATA lv_tabkey     TYPE c LENGTH 999.
    DATA lv_tabkey_len TYPE i.
    DATA lv_field_len  TYPE i.
    DATA lv_offset     TYPE i.

    DATA s_dfies LIKE LINE OF dfies.
      FIELD-SYMBOLS <value> TYPE any.
    LOOP AT dfies INTO s_dfies WHERE keyflag = abap_true.

      
      ASSIGN COMPONENT s_dfies-fieldname OF STRUCTURE line TO <value>.
      IF <value> IS NOT ASSIGNED.
        CONTINUE.
      ENDIF.

      lv_type = cl_abap_typedescr=>describe_by_data( <value> )->type_kind.

      IF lv_type NA 'CDNT'.
        lv_tabkey+lv_tabkey_len = '*'.
        rv_tabkey = lv_tabkey.
        RETURN.
      ELSE.
        lv_field_len = cl_abap_typedescr=>describe_by_data( <value> )->length / zabaputil_cl_util_context=>cv_char_util_charsize.
      ENDIF.

      lv_field_len = cl_abap_typedescr=>describe_by_data( <value> )->length / zabaputil_cl_util_context=>cv_char_util_charsize.
      lv_tabkey+lv_tabkey_len(lv_field_len) = <value>.
      lv_tabkey_len = lv_tabkey_len + lv_field_len.

    ENDLOOP.

    IF lv_tabkey_len > 119.

      IF lv_tabkey CS '_'.
        lv_offset = sy-fdpos.
        lv_tabkey+lv_offset = '*'.
      ELSE.
        lv_tabkey+119 = '*'.
      ENDIF.

    ENDIF.
    rv_tabkey = lv_tabkey.
  ENDMETHOD.

  METHOD bus_tr_add.
      FIELD-SYMBOLS <e071> TYPE any.
      FIELD-SYMBOLS <t_e071k> TYPE STANDARD TABLE.
      FIELD-SYMBOLS <t_e071> TYPE STANDARD TABLE.
      DATA r_e071k TYPE REF TO data.
      DATA r_e071 TYPE REF TO data.
      DATA fb1 TYPE c LENGTH 27.
      DATA fb2 TYPE c LENGTH 25.

    IF zabaputil_cl_util_context=>check_abap_cloud( ) IS NOT INITIAL.

    ELSE.

      
      
      

      " We need to set the MANDT is necessary
      set_mandt( ir_data ).

      
      r_e071k = _set_e071k( ir_data      = ir_data
                                  iv_tabname   = iv_tabname
                                  is_transport = is_transport ).
      ASSIGN r_e071k->* TO <e071>.
      IF <e071> IS INITIAL.
        RETURN.
      ENDIF.

      
      r_e071 = _set_e071( iv_tabname   = iv_tabname
                                is_transport = is_transport ).

      ASSIGN r_e071k->* TO <t_e071k>.
      ASSIGN r_e071->* TO <t_e071>.

      
      fb1 = 'TR_APPEND_TO_COMM_OBJS_KEYS'.
      CALL FUNCTION fb1
        EXPORTING
          wi_trkorr     = is_transport-transport
          iv_dialog     = abap_false
        TABLES
          wt_e071       = <t_e071>
          wt_e071k      = <t_e071k>
        EXCEPTIONS
          error_message = 1
          OTHERS        = 2.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zabaputil_cx_util_error.
      ENDIF.

      
      fb2 = 'TR_SORT_AND_COMPRESS_COMM'.
      CALL FUNCTION fb2
        EXPORTING
          iv_trkorr     = is_transport-task
        EXCEPTIONS
          error_message = 1
          OTHERS        = 2.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zabaputil_cx_util_error.
      ELSE.
        COMMIT WORK AND WAIT.
      ENDIF.

    ENDIF.

  ENDMETHOD.

  METHOD _set_e071k.

    DATA t_e071k TYPE REF TO data.
    DATA s_e071k TYPE REF TO data.

    FIELD-SYMBOLS <t_e071k> TYPE STANDARD TABLE.
    FIELD-SYMBOLS <s_e071k> TYPE any.
    FIELD-SYMBOLS <value>   TYPE any.
    FIELD-SYMBOLS <tab>     TYPE STANDARD TABLE.
    FIELD-SYMBOLS <line>    TYPE any.

    DATA t_comp TYPE abap_component_tab.
        DATA struct_desc TYPE REF TO cl_abap_structdescr.
        DATA table_desc TYPE REF TO cl_abap_tabledescr.
    DATA dfies TYPE zabaputil_cl_util_context=>ty_t_dfies.
    t_comp = zabaputil_cl_util_context=>rtti_get_t_attri_by_table_name( 'E071K' ).

    TRY.

        
        struct_desc = cl_abap_structdescr=>create( t_comp ).

        
        table_desc = cl_abap_tabledescr=>create( p_line_type  = struct_desc
                                                       p_table_kind = cl_abap_tabledescr=>tablekind_std ).

        CREATE DATA t_e071k TYPE HANDLE table_desc.
        CREATE DATA s_e071k TYPE HANDLE struct_desc.

        ASSIGN t_e071k->* TO <t_e071k>.
        ASSIGN s_e071k->* TO <s_e071k>.

      CATCH cx_root ##NO_HANDLER.
    ENDTRY.

    
    dfies = rtti_get_t_dfies_by_table_name( iv_tabname ).

*   is_transport-transport = assign_value( component = 'TRKORR'
*                                          structure = <s_e071k> ).                                         )

    ASSIGN COMPONENT 'TRKORR' OF STRUCTURE <s_e071k> TO <value>.
    IF <value> IS NOT ASSIGNED.
      RETURN.
    ELSE.
      <value> = is_transport-task.
    ENDIF.
    UNASSIGN <value>.
    ASSIGN COMPONENT 'PGMID' OF STRUCTURE <s_e071k> TO <value>.
    IF <value> IS NOT ASSIGNED.
      RETURN.
    ELSE.
      <value> = 'R3TR'.
    ENDIF.
    UNASSIGN <value>.
    ASSIGN COMPONENT 'MASTERTYPE' OF STRUCTURE <s_e071k> TO <value>.
    IF <value> IS NOT ASSIGNED.
      RETURN.
    ELSE.
      <value> = 'TABU'.
    ENDIF.
    UNASSIGN <value>.
    ASSIGN COMPONENT 'OBJECT' OF STRUCTURE <s_e071k> TO <value>.
    IF <value> IS NOT ASSIGNED.
      RETURN.
    ELSE.
      <value> = 'TABU'.
    ENDIF.
    UNASSIGN <value>.
    ASSIGN COMPONENT 'MASTERNAME' OF STRUCTURE <s_e071k> TO <value>.
    IF <value> IS NOT ASSIGNED.
      RETURN.
    ELSE.
      <value> = iv_tabname.
    ENDIF.
    UNASSIGN <value>.
    ASSIGN COMPONENT 'OBJNAME' OF STRUCTURE <s_e071k> TO <value>.
    IF <value> IS NOT ASSIGNED.
      RETURN.
    ELSE.
      <value> = iv_tabname.
    ENDIF.
    UNASSIGN <value>.

    ASSIGN ir_data->* TO <tab>.

*    IF <tab> IS INITIAL.
*      RETURN.
*    ENDIF.

    LOOP AT <tab> ASSIGNING <line>.

      ASSIGN COMPONENT 'TABKEY' OF STRUCTURE <s_e071k> TO <value>.
      IF <value> IS NOT ASSIGNED.
        RETURN.
      ELSE.
        <value> = _get_e071k_tabkey( dfies = dfies
                                     line  = <line> ).
      ENDIF.

      APPEND <s_e071k> TO <t_e071k>.

    ENDLOOP.

    result = t_e071k.

  ENDMETHOD.

  METHOD _set_e071.

    DATA t_e071 TYPE REF TO data.
    DATA s_e071 TYPE REF TO data.

    FIELD-SYMBOLS <t_e071> TYPE STANDARD TABLE.
    FIELD-SYMBOLS <s_e071> TYPE any.
    FIELD-SYMBOLS <value>  TYPE any.

    DATA t_comp TYPE abap_component_tab.
        DATA struct_desc_new TYPE REF TO cl_abap_structdescr.
        DATA table_desc_new TYPE REF TO cl_abap_tabledescr.
    t_comp = zabaputil_cl_util_context=>rtti_get_t_attri_by_table_name( 'E071' ).

    TRY.

        
        struct_desc_new = cl_abap_structdescr=>create( t_comp ).

        
        table_desc_new = cl_abap_tabledescr=>create( p_line_type  = struct_desc_new
                                                           p_table_kind = cl_abap_tabledescr=>tablekind_std ).

        CREATE DATA t_e071 TYPE HANDLE table_desc_new.
        CREATE DATA s_e071 TYPE HANDLE struct_desc_new.

        ASSIGN t_e071->* TO <t_e071>.
        ASSIGN s_e071->* TO <s_e071>.

      CATCH cx_root ##NO_HANDLER.
    ENDTRY.

    ASSIGN COMPONENT 'TRKORR' OF STRUCTURE <s_e071> TO <value>.
    IF <value> IS NOT ASSIGNED.
      RETURN.
    ELSE.
      <value> = is_transport-task.
    ENDIF.
    UNASSIGN <value>.
    ASSIGN COMPONENT 'PGMID' OF STRUCTURE <s_e071> TO <value>.
    IF <value> IS NOT ASSIGNED.
      RETURN.
    ELSE.
      <value> = 'R3TR'.
    ENDIF.
    UNASSIGN <value>.
    ASSIGN COMPONENT 'OBJECT' OF STRUCTURE <s_e071> TO <value>.
    IF <value> IS NOT ASSIGNED.
      RETURN.
    ELSE.
      <value> = 'TABU'.
    ENDIF.
    UNASSIGN <value>.
    ASSIGN COMPONENT 'OBJ_NAME' OF STRUCTURE <s_e071> TO <value>.
    IF <value> IS NOT ASSIGNED.
      RETURN.
    ELSE.
      <value> = iv_tabname.
    ENDIF.
    UNASSIGN <value>.
    ASSIGN COMPONENT 'OBJFUNC' OF STRUCTURE <s_e071> TO <value>.
    IF <value> IS NOT ASSIGNED.
      RETURN.
    ELSE.
      <value> = 'K'.
    ENDIF.
    UNASSIGN <value>.

    APPEND <s_e071> TO <t_e071>.

    result = t_e071.

  ENDMETHOD.

  METHOD _read_e070.

    DATA lo_tab  TYPE REF TO data.
    DATA lo_line TYPE REF TO data.
    DATA ls_data TYPE ty_s_transport.

    FIELD-SYMBOLS <table> TYPE STANDARD TABLE.
    FIELD-SYMBOLS <line>  TYPE any.
    FIELD-SYMBOLS <value> TYPE any.

    DATA table_name TYPE c LENGTH 4.
        DATA t_comp TYPE abap_component_tab.
        DATA new_struct_desc TYPE REF TO cl_abap_structdescr.
        DATA new_table_desc TYPE REF TO cl_abap_tabledescr.
        DATA where TYPE string.
    table_name = 'E070'.

    TRY.
        
        t_comp = zabaputil_cl_util_context=>rtti_get_t_attri_by_table_name( table_name ).

        
        new_struct_desc = cl_abap_structdescr=>create( t_comp ).

        
        new_table_desc = cl_abap_tabledescr=>create( p_line_type  = new_struct_desc
                                                           p_table_kind = cl_abap_tabledescr=>tablekind_std ).

        CREATE DATA lo_tab TYPE HANDLE new_table_desc.
        CREATE DATA lo_line TYPE HANDLE new_struct_desc.

        ASSIGN lo_tab->* TO <table>.
        ASSIGN lo_line->* TO <line>.

        
        where =
        |( TRFUNCTION EQ 'Q' ) AND ( TRSTATUS EQ 'D' ) AND ( KORRDEV EQ 'CUST' ) AND ( AS4USER EQ '{ sy-uname }' )|.

        SELECT trkorr
               trfunction
               trstatus
               tarsystem
               korrdev
               as4user
               as4date
               as4time
               strkorr
          FROM (table_name) INTO TABLE <table>
          WHERE (where)
          .
        IF sy-subrc <> 0.
          RETURN.
        ENDIF.
      CATCH cx_root ##NO_HANDLER.
    ENDTRY.

    LOOP AT <table> INTO <line>.

      ASSIGN COMPONENT 'TRKORR' OF STRUCTURE <line> TO <value>.
      IF <value> IS NOT ASSIGNED.
        CONTINUE.
      ELSE.
        ls_data-transport = <value>.
      ENDIF.

      UNASSIGN <value>.

      ASSIGN COMPONENT 'STRKORR' OF STRUCTURE <line> TO <value>.
      IF <value> IS NOT ASSIGNED.
        CONTINUE.
      ELSE.
        ls_data-task = <value>.
      ENDIF.

      UNASSIGN <value>.

      APPEND ls_data TO mt_data.

    ENDLOOP.

  ENDMETHOD.

  METHOD bus_tr_read.
      DATA lo_tab TYPE REF TO data.
      DATA lo_line TYPE REF TO data.
      FIELD-SYMBOLS <table> TYPE STANDARD TABLE.
      FIELD-SYMBOLS <line> TYPE any.
      FIELD-SYMBOLS <value> TYPE any.
      DATA table_name TYPE c LENGTH 4.
          DATA t_comp TYPE abap_component_tab.
          DATA new_struct_desc TYPE REF TO cl_abap_structdescr.
          DATA new_table_desc TYPE REF TO cl_abap_tabledescr.
          DATA index TYPE i.
          DATA line LIKE LINE OF mt_data.
              DATA where TYPE string.
          DATA data TYPE REF TO zabaputil_cl_util_context=>ty_s_transport.

    IF zabaputil_cl_util_context=>check_abap_cloud( ) IS NOT INITIAL.

*          data(lo_current_user) = xco_cp=>sy->user( ).
*
*    DATA(lo_kind_filter) = xco_cp_transport=>filter->kind( xco_cp_transport=>kind->task ).
*    DATA(lo_owner_filter) = xco_cp_transport=>filter->owner( xco_cp_abap_sql=>constraint->equal( lo_current_user->name ) ).
*    DATA(lo_status_filter) = xco_cp_transport=>filter->status( xco_cp_transport=>status->modifiable ).
*    DATA(lo_type_filter) = xco_cp_transport=>filter->type( io_type = xco_cp_transport=>type->customizing_task ).
*    DATA(lt_transports) = xco_cp_cts=>transports->where( VALUE #( ( lo_kind_filter )
*                                                                  ( lo_owner_filter )
*                                                                  ( lo_status_filter )
*                                                                  ( lo_type_filter ) )
*    )->resolve( xco_cp_transport=>resolution->request ).
*
*    LOOP AT lt_transports INTO DATA(lo_transport).
*      DATA(lo_transport_request) = lo_transport->get_request( ).
*
*      DATA(prop) = lo_transport_request->properties( )->get( ).
*
*      DATA(tasks) = lo_transport_request->get_tasks( ).
*
*      LOOP AT tasks INTO DATA(task).
*
*        IF lo_current_user->name = task->properties( )->get_owner( )->name.
*
*          DATA(data) = VALUE ty_s_data( short_description = prop-short_description
*                                        transport         = lo_transport_request->value
*                                        task              = task->value ).
*          APPEND data TO mt_data.
*
*        ENDIF.
*
*      ENDLOOP.
*
*    ENDLOOP.

    ELSE.

      
      

      
      
      

      _read_e070( CHANGING mt_data = mt_data ).

      
      table_name = 'E07T'.

      TRY.
          
          t_comp = zabaputil_cl_util_context=>rtti_get_t_attri_by_table_name( table_name ).

          
          new_struct_desc = cl_abap_structdescr=>create( t_comp ).

          
          new_table_desc = cl_abap_tabledescr=>create( p_line_type  = new_struct_desc
                                                             p_table_kind = cl_abap_tabledescr=>tablekind_std ).

          CREATE DATA lo_tab TYPE HANDLE new_table_desc.
          CREATE DATA lo_line TYPE HANDLE new_struct_desc.

          ASSIGN lo_tab->* TO <table>.
          ASSIGN lo_line->* TO <line>.

          
          index = 0.

          
          LOOP AT mt_data INTO line.
            index = index + 1.
            IF index = 1.
              
              where = |TRKORR EQ '{ line-task }'|.
            ELSE.
              where = |{ where } OR TRKORR EQ '{ line-task }'|.
            ENDIF.
            where = |( { where } )|.
          ENDLOOP.

          SELECT trkorr
                 langu
                 as4text
            FROM (table_name) INTO TABLE <table>
            WHERE (where)
            .
          IF sy-subrc <> 0.
            RETURN.
          ENDIF.

        CATCH cx_root ##NO_HANDLER.
      ENDTRY.

      LOOP AT <table> INTO <line>.

        ASSIGN COMPONENT 'TRKORR' OF STRUCTURE <line> TO <value>.
        IF <value> IS NOT ASSIGNED.
          CONTINUE.
        ELSE.

          
          READ TABLE mt_data REFERENCE INTO data WITH KEY task = <value>.
          IF sy-subrc = 0.

            ASSIGN COMPONENT 'AS4TEXT' OF STRUCTURE <line> TO <value>.
            IF <value> IS NOT ASSIGNED.
              CONTINUE.
            ELSE.

              data->short_description = <value>.

            ENDIF.

          ENDIF.

        ENDIF.

      ENDLOOP.

    ENDIF.

  ENDMETHOD.

  METHOD set_mandt.

    FIELD-SYMBOLS <tab>  TYPE STANDARD TABLE.
    FIELD-SYMBOLS <line> TYPE any.
      FIELD-SYMBOLS <row> TYPE any.

    ASSIGN ir_data->* TO <tab>.

    LOOP AT <tab> ASSIGNING <line>.

      
      ASSIGN COMPONENT `MANDT` OF STRUCTURE <line> TO <row>.
      IF <row> IS ASSIGNED.

        TRY.
            <row> = sy-mandt.
          CATCH cx_root ##NO_HANDLER.
        ENDTRY.

      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD bal_search.
      DATA lo_filter TYPE REF TO object.
      DATA lo_db TYPE REF TO object.
      TYPES temp10 TYPE STANDARD TABLE OF REF TO object.
DATA lt_logs TYPE temp10.
      DATA lv_class TYPE string.
          DATA temp482 TYPE string.
          DATA lv_obj_f LIKE temp482.
          DATA temp483 TYPE string.
          DATA lv_sub_f LIKE temp483.
          DATA temp484 TYPE string.
          DATA lv_id_f LIKE temp484.
            DATA temp485 TYPE d.
            DATA lv_from LIKE temp485.
            DATA temp486 TYPE d.
            DATA lv_to LIKE temp486.
          DATA lo_log LIKE LINE OF lt_logs.
            DATA temp487 TYPE ty_s_bal_header.
            DATA ls_hdr_c LIKE temp487.
                DATA lo_header TYPE REF TO object.
    DATA lv_fm TYPE string.
    DATA lr_filter TYPE REF TO data.
    DATA lr_headers TYPE REF TO data.
    FIELD-SYMBOLS <filter> TYPE any.
    FIELD-SYMBOLS <headers> TYPE STANDARD TABLE.
    FIELD-SYMBOLS <header> TYPE any.
    FIELD-SYMBOLS <comp> TYPE any.
    FIELD-SYMBOLS <range> TYPE STANDARD TABLE.
    FIELD-SYMBOLS <rline> TYPE any.
    DATA lr_rline TYPE REF TO data.
          DATA temp488 TYPE d.
          DATA temp489 TYPE d.
          DATA temp490 TYPE ty_s_bal_header.
          DATA ls_hdr LIKE temp490.

    IF zabaputil_cl_util_context=>check_abap_cloud( ) IS NOT INITIAL.
      " Cloud: use CL_BALI_LOG_FILTER + CL_BALI_LOG_DB
      
      
      

      

      TRY.
          lv_class = `CL_BALI_LOG_FILTER`.
          CALL METHOD (lv_class)=>(`CREATE`)
            RECEIVING
              filter = lo_filter.

          
          IF object IS NOT INITIAL.
            temp482 = object.
          ELSE.
            temp482 = ``.
          ENDIF.
          
          lv_obj_f = temp482.
          
          IF subobject IS NOT INITIAL.
            temp483 = subobject.
          ELSE.
            temp483 = ``.
          ENDIF.
          
          lv_sub_f = temp483.
          
          IF id IS NOT INITIAL.
            temp484 = id.
          ELSE.
            temp484 = ``.
          ENDIF.
          
          lv_id_f = temp484.
          CALL METHOD lo_filter->(`SET_DESCRIPTOR`)
            EXPORTING
              object      = lv_obj_f
              subobject   = lv_sub_f
              external_id = lv_id_f.

          IF date_from IS NOT INITIAL OR date_to IS NOT INITIAL.
            
            IF date_from IS NOT INITIAL.
              temp485 = date_from.
            ELSE.
              temp485 = '19000101'.
            ENDIF.
            
            lv_from = temp485.
            
            IF date_to IS NOT INITIAL.
              temp486 = date_to.
            ELSE.
              temp486 = sy-datum.
            ENDIF.
            
            lv_to = temp486.
            CALL METHOD lo_filter->(`SET_CREATE_DATE`)
              EXPORTING
                from_date = lv_from
                to_date   = lv_to.
          ENDIF.

          lv_class = `CL_BALI_LOG_DB`.
          CALL METHOD (lv_class)=>(`GET_INSTANCE`)
            RECEIVING
              db_handler = lo_db.

          CALL METHOD lo_db->(`LOAD_LOGS_VIA_FILTER`)
            EXPORTING
              filter           = lo_filter
              read_only_header = abap_true
            RECEIVING
              log_table        = lt_logs.

          
          LOOP AT lt_logs INTO lo_log.
            
            CLEAR temp487.
            
            ls_hdr_c = temp487.
            TRY.
                
                CALL METHOD lo_log->(`GET_HEADER`)
                  RECEIVING
                    header = lo_header.
                CALL METHOD lo_header->(`GET_OBJECT`)
                  RECEIVING
                    object = ls_hdr_c-object.
                CALL METHOD lo_header->(`GET_SUBOBJECT`)
                  RECEIVING
                    subobject = ls_hdr_c-subobject.
                CALL METHOD lo_header->(`GET_EXTERNAL_ID`)
                  RECEIVING
                    external_id = ls_hdr_c-external_id.
              CATCH cx_root ##NO_HANDLER.
            ENDTRY.
            INSERT ls_hdr_c INTO TABLE result.
          ENDLOOP.

        CATCH cx_root ##NO_HANDLER.
      ENDTRY.
      RETURN.
    ENDIF.

    " Standard ABAP: use BAL_DB_SEARCH
    
    
    
    
    
    
    
    
    
    

    TRY.
        CREATE DATA lr_filter TYPE ('BAL_S_LFIL').
        ASSIGN lr_filter->* TO <filter>.

        IF object IS NOT INITIAL.
          ASSIGN COMPONENT `OBJECT` OF STRUCTURE <filter> TO <range>.
          CREATE DATA lr_rline LIKE LINE OF <range>.
          ASSIGN lr_rline->* TO <rline>.
          ASSIGN COMPONENT `SIGN` OF STRUCTURE <rline> TO <comp>. <comp> = `I`.
          ASSIGN COMPONENT `OPTION` OF STRUCTURE <rline> TO <comp>. <comp> = `EQ`.
          ASSIGN COMPONENT `LOW` OF STRUCTURE <rline> TO <comp>. <comp> = object.
          INSERT <rline> INTO TABLE <range>.
        ENDIF.

        IF subobject IS NOT INITIAL.
          ASSIGN COMPONENT `SUBOBJECT` OF STRUCTURE <filter> TO <range>.
          CREATE DATA lr_rline LIKE LINE OF <range>.
          ASSIGN lr_rline->* TO <rline>.
          ASSIGN COMPONENT `SIGN` OF STRUCTURE <rline> TO <comp>. <comp> = `I`.
          ASSIGN COMPONENT `OPTION` OF STRUCTURE <rline> TO <comp>. <comp> = `EQ`.
          ASSIGN COMPONENT `LOW` OF STRUCTURE <rline> TO <comp>. <comp> = subobject.
          INSERT <rline> INTO TABLE <range>.
        ENDIF.

        IF id IS NOT INITIAL.
          ASSIGN COMPONENT `EXTNUMBER` OF STRUCTURE <filter> TO <range>.
          CREATE DATA lr_rline LIKE LINE OF <range>.
          ASSIGN lr_rline->* TO <rline>.
          ASSIGN COMPONENT `SIGN` OF STRUCTURE <rline> TO <comp>. <comp> = `I`.
          ASSIGN COMPONENT `OPTION` OF STRUCTURE <rline> TO <comp>. <comp> = `EQ`.
          ASSIGN COMPONENT `LOW` OF STRUCTURE <rline> TO <comp>. <comp> = id.
          INSERT <rline> INTO TABLE <range>.
        ENDIF.

        IF date_from IS NOT INITIAL OR date_to IS NOT INITIAL.
          ASSIGN COMPONENT `ALDATE` OF STRUCTURE <filter> TO <range>.
          CREATE DATA lr_rline LIKE LINE OF <range>.
          ASSIGN lr_rline->* TO <rline>.
          ASSIGN COMPONENT `SIGN` OF STRUCTURE <rline> TO <comp>. <comp> = `I`.
          ASSIGN COMPONENT `OPTION` OF STRUCTURE <rline> TO <comp>. <comp> = `BT`.
          ASSIGN COMPONENT `LOW` OF STRUCTURE <rline> TO <comp>.
          
          IF date_from IS NOT INITIAL.
            temp488 = date_from.
          ELSE.
            temp488 = '19000101'.
          ENDIF.
          <comp> = temp488.
          ASSIGN COMPONENT `HIGH` OF STRUCTURE <rline> TO <comp>.
          
          IF date_to IS NOT INITIAL.
            temp489 = date_to.
          ELSE.
            temp489 = sy-datum.
          ENDIF.
          <comp> = temp489.
          INSERT <rline> INTO TABLE <range>.
        ENDIF.

        IF user IS NOT INITIAL.
          ASSIGN COMPONENT `ALUSER` OF STRUCTURE <filter> TO <range>.
          CREATE DATA lr_rline LIKE LINE OF <range>.
          ASSIGN lr_rline->* TO <rline>.
          ASSIGN COMPONENT `SIGN` OF STRUCTURE <rline> TO <comp>. <comp> = `I`.
          ASSIGN COMPONENT `OPTION` OF STRUCTURE <rline> TO <comp>. <comp> = `EQ`.
          ASSIGN COMPONENT `LOW` OF STRUCTURE <rline> TO <comp>. <comp> = user.
          INSERT <rline> INTO TABLE <range>.
        ENDIF.

        CREATE DATA lr_headers TYPE ('BALHDR_T').
        ASSIGN lr_headers->* TO <headers>.

        lv_fm = `BAL_DB_SEARCH`.
        CALL FUNCTION lv_fm
          EXPORTING
            i_s_log_filter = <filter>
          IMPORTING
            e_t_log_header = <headers>
          EXCEPTIONS
            OTHERS         = 1.
        IF sy-subrc <> 0.
          RETURN.
        ENDIF.

        LOOP AT <headers> ASSIGNING <header>.
          
          CLEAR temp490.
          
          ls_hdr = temp490.
          ASSIGN COMPONENT `LOG_HANDLE` OF STRUCTURE <header> TO <comp>.
          IF sy-subrc = 0. ls_hdr-log_handle = <comp>. ENDIF.
          ASSIGN COMPONENT `OBJECT` OF STRUCTURE <header> TO <comp>.
          IF sy-subrc = 0. ls_hdr-object = <comp>. ENDIF.
          ASSIGN COMPONENT `SUBOBJECT` OF STRUCTURE <header> TO <comp>.
          IF sy-subrc = 0. ls_hdr-subobject = <comp>. ENDIF.
          ASSIGN COMPONENT `EXTNUMBER` OF STRUCTURE <header> TO <comp>.
          IF sy-subrc = 0. ls_hdr-external_id = <comp>. ENDIF.
          ASSIGN COMPONENT `ALDATE` OF STRUCTURE <header> TO <comp>.
          IF sy-subrc = 0. ls_hdr-log_date = <comp>. ENDIF.
          ASSIGN COMPONENT `ALTIME` OF STRUCTURE <header> TO <comp>.
          IF sy-subrc = 0. ls_hdr-log_time = <comp>. ENDIF.
          ASSIGN COMPONENT `ALUSER` OF STRUCTURE <header> TO <comp>.
          IF sy-subrc = 0. ls_hdr-user = <comp>. ENDIF.
          INSERT ls_hdr INTO TABLE result.
        ENDLOOP.

      CATCH cx_root ##NO_HANDLER.
    ENDTRY.

  ENDMETHOD.

  METHOD bal_read_latest.

    DATA lt_msgs TYPE zabaputil_cl_util_context=>ty_t_msg.
      DATA temp491 LIKE LINE OF lt_msgs.
      DATA temp492 LIKE sy-tabix.
    lt_msgs = bal_read( object    = object
                              subobject = subobject
                              id        = id ).
    IF lt_msgs IS NOT INITIAL.
      
      
      temp492 = sy-tabix.
      READ TABLE lt_msgs INDEX lines( lt_msgs ) INTO temp491.
      sy-tabix = temp492.
      IF sy-subrc <> 0.
        ASSERT 1 = 0.
      ENDIF.
      result = temp491.
    ENDIF.

  ENDMETHOD.

  METHOD bal_delete_before.

    DATA temp493 TYPE d.
    DATA lv_cutoff LIKE temp493.
      DATA lo_filter_c TYPE REF TO object.
      DATA lo_db_c TYPE REF TO object.
      TYPES temp11 TYPE STANDARD TABLE OF REF TO object.
DATA lt_logs_c TYPE temp11.
      DATA lv_cls TYPE string.
          DATA temp494 TYPE string.
          DATA lv_sub_c LIKE temp494.
          DATA temp495 TYPE d.
          DATA lo_log_c LIKE LINE OF lt_logs_c.
    DATA lv_fm TYPE string.
    DATA lr_filter TYPE REF TO data.
    FIELD-SYMBOLS <filter> TYPE any.
    FIELD-SYMBOLS <range> TYPE STANDARD TABLE.
    FIELD-SYMBOLS <rline> TYPE any.
    FIELD-SYMBOLS <comp> TYPE any.
    DATA lr_rline TYPE REF TO data.
    temp493 = sy-datum - days.
    
    lv_cutoff = temp493.

    IF zabaputil_cl_util_context=>check_abap_cloud( ) IS NOT INITIAL.
      " Cloud: use CL_BALI_LOG_DB to delete via filter
      
      
      

      

      TRY.
          lv_cls = `CL_BALI_LOG_FILTER`.
          CALL METHOD (lv_cls)=>(`CREATE`)
            RECEIVING
              filter = lo_filter_c.

          
          IF subobject IS NOT INITIAL.
            temp494 = subobject.
          ELSE.
            temp494 = ``.
          ENDIF.
          
          lv_sub_c = temp494.
          CALL METHOD lo_filter_c->(`SET_DESCRIPTOR`)
            EXPORTING
              object      = object
              subobject   = lv_sub_c
              external_id = ``.

          
          temp495 = '19000101'.
          CALL METHOD lo_filter_c->(`SET_CREATE_DATE`)
            EXPORTING
              from_date = temp495
              to_date   = lv_cutoff.

          lv_cls = `CL_BALI_LOG_DB`.
          CALL METHOD (lv_cls)=>(`GET_INSTANCE`)
            RECEIVING
              db_handler = lo_db_c.

          CALL METHOD lo_db_c->(`LOAD_LOGS_VIA_FILTER`)
            EXPORTING
              filter    = lo_filter_c
            RECEIVING
              log_table = lt_logs_c.

          
          LOOP AT lt_logs_c INTO lo_log_c.
            CALL METHOD lo_db_c->(`DELETE_LOG`)
              EXPORTING
                log = lo_log_c.
          ENDLOOP.

          COMMIT WORK AND WAIT.

        CATCH cx_root ##NO_HANDLER.
      ENDTRY.
      RETURN.
    ENDIF.

    " Standard ABAP: use BAL_DB_DELETE
    
    
    
    
    
    
    

    TRY.
        CREATE DATA lr_filter TYPE ('BAL_S_LFIL').
        ASSIGN lr_filter->* TO <filter>.

        ASSIGN COMPONENT `OBJECT` OF STRUCTURE <filter> TO <range>.
        CREATE DATA lr_rline LIKE LINE OF <range>.
        ASSIGN lr_rline->* TO <rline>.
        ASSIGN COMPONENT `SIGN` OF STRUCTURE <rline> TO <comp>. <comp> = `I`.
        ASSIGN COMPONENT `OPTION` OF STRUCTURE <rline> TO <comp>. <comp> = `EQ`.
        ASSIGN COMPONENT `LOW` OF STRUCTURE <rline> TO <comp>. <comp> = object.
        INSERT <rline> INTO TABLE <range>.

        IF subobject IS NOT INITIAL.
          ASSIGN COMPONENT `SUBOBJECT` OF STRUCTURE <filter> TO <range>.
          CREATE DATA lr_rline LIKE LINE OF <range>.
          ASSIGN lr_rline->* TO <rline>.
          ASSIGN COMPONENT `SIGN` OF STRUCTURE <rline> TO <comp>. <comp> = `I`.
          ASSIGN COMPONENT `OPTION` OF STRUCTURE <rline> TO <comp>. <comp> = `EQ`.
          ASSIGN COMPONENT `LOW` OF STRUCTURE <rline> TO <comp>. <comp> = subobject.
          INSERT <rline> INTO TABLE <range>.
        ENDIF.

        ASSIGN COMPONENT `ALDATE` OF STRUCTURE <filter> TO <range>.
        CREATE DATA lr_rline LIKE LINE OF <range>.
        ASSIGN lr_rline->* TO <rline>.
        ASSIGN COMPONENT `SIGN` OF STRUCTURE <rline> TO <comp>. <comp> = `I`.
        ASSIGN COMPONENT `OPTION` OF STRUCTURE <rline> TO <comp>. <comp> = `BT`.
        ASSIGN COMPONENT `LOW` OF STRUCTURE <rline> TO <comp>. <comp> = '19000101'.
        ASSIGN COMPONENT `HIGH` OF STRUCTURE <rline> TO <comp>. <comp> = lv_cutoff.
        INSERT <rline> INTO TABLE <range>.

        lv_fm = `BAL_DB_DELETE`.
        CALL FUNCTION lv_fm
          EXPORTING
            i_s_log_filter = <filter>
          EXCEPTIONS
            OTHERS         = 1.
        IF sy-subrc = 0.
          COMMIT WORK AND WAIT.
        ENDIF.

      CATCH cx_root ##NO_HANDLER.
    ENDTRY.

  ENDMETHOD.

  METHOD bal_read_by_type.

    DATA lt_all TYPE zabaputil_cl_util_context=>ty_t_msg.
    DATA ls_msg LIKE LINE OF lt_all.
    lt_all = bal_read( object    = object
                             subobject = subobject
                             id        = id ).

    
    LOOP AT lt_all INTO ls_msg
         WHERE type = msg_type.
      INSERT ls_msg INTO TABLE result.
    ENDLOOP.

  ENDMETHOD.

  METHOD bal_count.

    DATA lt_msgs TYPE zabaputil_cl_util_context=>ty_t_msg.
    lt_msgs = bal_read( object    = object
                              subobject = subobject
                              id        = id ).
    result = lines( lt_msgs ).

  ENDMETHOD.

  METHOD bal_read.
TYPES BEGIN OF ty_item.
TYPES log_item_number TYPE i.
TYPES item TYPE REF TO object.
TYPES END OF ty_item.
      TYPES temp12 TYPE STANDARD TABLE OF ty_item.
DATA lt_items TYPE temp12.
      DATA lo_filter TYPE REF TO object.
      DATA lo_db TYPE REF TO object.
      TYPES temp13 TYPE STANDARD TABLE OF REF TO object.
DATA lt_logs TYPE temp13.
      DATA lv_text TYPE string.
      DATA lv_class TYPE string.
      DATA lv_severity TYPE c LENGTH 1.
      DATA lv_msgid TYPE string.
      DATA lv_msgno TYPE string.
      DATA lv_msgv1 TYPE string.
      DATA lv_msgv2 TYPE string.
      DATA lv_msgv3 TYPE string.
      DATA lv_msgv4 TYPE string.
          DATA lo_log LIKE LINE OF lt_logs.
            DATA temp496 LIKE lt_items.
            DATA ls_item LIKE LINE OF lt_items.
              DATA temp497 TYPE zabaputil_cl_util_context=>ty_s_msg.
              DATA ls_msg LIKE temp497.
      DATA lv_fm TYPE string.
      DATA lr_handles TYPE REF TO data.
      DATA lr_single TYPE REF TO data.
      DATA lr_msgh TYPE REF TO data.
      DATA lr_msg TYPE REF TO data.
      FIELD-SYMBOLS <handles> TYPE STANDARD TABLE.
      FIELD-SYMBOLS <handle> TYPE any.
      FIELD-SYMBOLS <single> TYPE STANDARD TABLE.
      FIELD-SYMBOLS <msgh> TYPE STANDARD TABLE.
      FIELD-SYMBOLS <mh> TYPE any.
      FIELD-SYMBOLS <msg> TYPE any.
          DATA lx_read TYPE REF TO cx_root.

    IF zabaputil_cl_util_context=>check_abap_cloud( ) IS NOT INITIAL.

      " Load the persisted logs (incl. items) via the released filter API and map
      " each item back to the framework's z2ui5_cl_util=>ty_s_msg structure with full metadata.
      
      

      
      
      

      
      
      
      
      
      
      
      
      

      TRY.
          lo_filter = bal_cloud_build_filter( object    = object
                                              subobject = subobject
                                              id        = id ).

          lv_class = `CL_BALI_LOG_DB`.
          CALL METHOD (lv_class)=>(`GET_INSTANCE`)
            RECEIVING
              db_handler = lo_db.

          CALL METHOD lo_db->(`LOAD_LOGS_VIA_FILTER`)
            EXPORTING
              filter    = lo_filter
            RECEIVING
              log_table = lt_logs.

          
          LOOP AT lt_logs INTO lo_log.

            
            CLEAR temp496.
            lt_items = temp496.
            CALL METHOD lo_log->(`GET_ALL_ITEMS`)
              RECEIVING
                item_table = lt_items.

            
            LOOP AT lt_items INTO ls_item.
              IF ls_item-item IS NOT BOUND.
                CONTINUE.
              ENDIF.

              
              CLEAR temp497.
              
              ls_msg = temp497.

              lv_text = ``.
              CALL METHOD ls_item-item->(`GET_MESSAGE_TEXT`)
                RECEIVING
                  message_text = lv_text.
              ls_msg-text = lv_text.

              TRY.
                  CALL METHOD ls_item-item->(`GET_SEVERITY`)
                    RECEIVING
                      severity = lv_severity.
                  ls_msg-type = lv_severity.
                CATCH cx_root ##NO_HANDLER.
              ENDTRY.

              TRY.
                  CALL METHOD ls_item-item->(`GET_MESSAGE_ID`)
                    RECEIVING
                      id = lv_msgid.
                  ls_msg-id = lv_msgid.
                CATCH cx_root ##NO_HANDLER.
              ENDTRY.

              TRY.
                  CALL METHOD ls_item-item->(`GET_MESSAGE_NUMBER`)
                    RECEIVING
                      number = lv_msgno.
                  ls_msg-no = lv_msgno.
                CATCH cx_root ##NO_HANDLER.
              ENDTRY.

              TRY.
                  CALL METHOD ls_item-item->(`GET_MESSAGE_VARIABLE_1`)
                    RECEIVING
                      variable_1 = lv_msgv1.
                  ls_msg-v1 = lv_msgv1.
                  CALL METHOD ls_item-item->(`GET_MESSAGE_VARIABLE_2`)
                    RECEIVING
                      variable_2 = lv_msgv2.
                  ls_msg-v2 = lv_msgv2.
                  CALL METHOD ls_item-item->(`GET_MESSAGE_VARIABLE_3`)
                    RECEIVING
                      variable_3 = lv_msgv3.
                  ls_msg-v3 = lv_msgv3.
                  CALL METHOD ls_item-item->(`GET_MESSAGE_VARIABLE_4`)
                    RECEIVING
                      variable_4 = lv_msgv4.
                  ls_msg-v4 = lv_msgv4.
                CATCH cx_root ##NO_HANDLER.
              ENDTRY.

              INSERT ls_msg INTO TABLE result.
            ENDLOOP.

          ENDLOOP.

        CATCH cx_root.
          RETURN.
      ENDTRY.

    ELSE.

      
      
      
      
      
      
      
      
      
      
      

      TRY.
          lr_handles = bal_std_load_handles( object    = object
                                             subobject = subobject
                                             id        = id ).
          IF lr_handles IS NOT BOUND.
            RETURN.
          ENDIF.
          ASSIGN lr_handles->* TO <handles>.

          CREATE DATA lr_single TYPE ('BAL_T_LOGH').
          ASSIGN lr_single->* TO <single>.
          CREATE DATA lr_msgh TYPE ('BAL_T_MSGH').
          ASSIGN lr_msgh->* TO <msgh>.
          CREATE DATA lr_msg TYPE ('BAL_S_MSG').
          ASSIGN lr_msg->* TO <msg>.

          LOOP AT <handles> ASSIGNING <handle>.

            CLEAR <single>.
            INSERT <handle> INTO TABLE <single>.

            CLEAR <msgh>.
            lv_fm = `BAL_GLB_SEARCH_MSG`.
            CALL FUNCTION lv_fm
              EXPORTING
                i_t_log_handle = <single>
              IMPORTING
                e_t_msg_handle = <msgh>
              EXCEPTIONS
                OTHERS         = 1.
            IF sy-subrc <> 0.
              CONTINUE.
            ENDIF.

            LOOP AT <msgh> ASSIGNING <mh>.
              CLEAR <msg>.
              lv_fm = `BAL_LOG_MSG_READ`.
              CALL FUNCTION lv_fm
                EXPORTING
                  i_s_msg_handle = <mh>
                IMPORTING
                  e_s_msg        = <msg>
                EXCEPTIONS
                  OTHERS         = 1.
              IF sy-subrc = 0.
                INSERT bal_std_map_msg( <msg> ) INTO TABLE result.
              ENDIF.
            ENDLOOP.

          ENDLOOP.

          
        CATCH cx_root INTO lx_read.
          RAISE EXCEPTION TYPE zabaputil_cx_util_error
            EXPORTING
              val = lx_read.
      ENDTRY.

    ENDIF.

  ENDMETHOD.

  METHOD bal_create.
      DATA lo_header TYPE REF TO object.
      DATA lo_log TYPE REF TO object.
      DATA lo_db TYPE REF TO object.
      DATA lv_class TYPE string.
      DATA lv_fm TYPE string.
      DATA lr_log TYPE REF TO data.
      DATA lr_handle TYPE REF TO data.
      DATA lr_handles TYPE REF TO data.
      FIELD-SYMBOLS <log> TYPE any.
      FIELD-SYMBOLS <handle> TYPE any.
      FIELD-SYMBOLS <handles> TYPE STANDARD TABLE.
      FIELD-SYMBOLS <comp> TYPE any.
          DATA lx_create TYPE REF TO cx_root.

    IF zabaputil_cl_util_context=>check_abap_cloud( ) IS NOT INITIAL.

      " ABAP Cloud: released Business Application Log API (cl_bali_*).
      " All access is dynamic so this class still compiles on lower releases.
      " The class names are kept in variables - a string literal inside the
      " dynamic component selector ( '...' )=>( '...' ) is not valid ABAP.
      " Returning parameter names follow the released API (header/log/db_handler).
      
      
      
      

      TRY.
          lv_class = `CL_BALI_HEADER_SETTER`.
          CALL METHOD (lv_class)=>(`CREATE`)
            EXPORTING
              object      = object
              subobject   = subobject
              external_id = id
            RECEIVING
              header      = lo_header.

          lv_class = `CL_BALI_LOG`.
          CALL METHOD (lv_class)=>(`CREATE`)
            RECEIVING
              log = lo_log.

          CALL METHOD lo_log->(`SET_HEADER`)
            EXPORTING
              header = lo_header.

          bal_cloud_add_items( log   = lo_log
                               t_log = t_log ).

          lv_class = `CL_BALI_LOG_DB`.
          CALL METHOD (lv_class)=>(`GET_INSTANCE`)
            RECEIVING
              db_handler = lo_db.

          CALL METHOD lo_db->(`SAVE_LOG`)
            EXPORTING
              log = lo_log.

          COMMIT WORK AND WAIT.

        CATCH cx_root.
          RETURN.
      ENDTRY.

    ELSE.

      " Standard ABAP / on-premise: classic Business Application Log function modules.
      
      
      
      
      
      
      
      

      TRY.
          CREATE DATA lr_log TYPE ('BAL_S_LOG').
          ASSIGN lr_log->* TO <log>.
          ASSIGN COMPONENT `OBJECT` OF STRUCTURE <log> TO <comp>.
          <comp> = object.
          ASSIGN COMPONENT `SUBOBJECT` OF STRUCTURE <log> TO <comp>.
          <comp> = subobject.
          ASSIGN COMPONENT `EXTNUMBER` OF STRUCTURE <log> TO <comp>.
          <comp> = id.

          CREATE DATA lr_handle TYPE ('BALLOGHNDL').
          ASSIGN lr_handle->* TO <handle>.

          lv_fm = `BAL_LOG_CREATE`.
          CALL FUNCTION lv_fm
            EXPORTING
              i_s_log      = <log>
            IMPORTING
              e_log_handle = <handle>
            EXCEPTIONS
              OTHERS       = 1.
          IF sy-subrc <> 0.
            RETURN.
          ENDIF.

          bal_std_msg_add( handle = <handle>
                           t_log  = t_log ).

          CREATE DATA lr_handles TYPE ('BAL_T_LOGH').
          ASSIGN lr_handles->* TO <handles>.
          INSERT <handle> INTO TABLE <handles>.

          lv_fm = `BAL_DB_SAVE`.
          CALL FUNCTION lv_fm
            EXPORTING
              i_t_log_handle = <handles>
            EXCEPTIONS
              OTHERS         = 1.
          IF sy-subrc = 0.
            COMMIT WORK AND WAIT.
          ENDIF.

          
        CATCH cx_root INTO lx_create.
          RAISE EXCEPTION TYPE zabaputil_cx_util_error
            EXPORTING
              val = lx_create.
      ENDTRY.

    ENDIF.

  ENDMETHOD.

  METHOD bal_update.
      DATA lo_filter TYPE REF TO object.
      DATA lo_db TYPE REF TO object.
      TYPES temp14 TYPE STANDARD TABLE OF REF TO object.
DATA lt_logs TYPE temp14.
      DATA lv_class TYPE string.
          DATA lo_log LIKE LINE OF lt_logs.
          DATA temp74 LIKE LINE OF lt_logs.
          DATA temp75 LIKE sy-tabix.
      DATA lv_fm TYPE string.
      DATA lr_handles TYPE REF TO data.
      FIELD-SYMBOLS <handles> TYPE STANDARD TABLE.
      FIELD-SYMBOLS <handle> TYPE any.
          DATA lx_update TYPE REF TO cx_root.

    IF zabaputil_cl_util_context=>check_abap_cloud( ) IS NOT INITIAL.

      " Load the existing log and append items. If no log exists, create a new one.
      
      
      

      

      TRY.
          lo_filter = bal_cloud_build_filter( object    = object
                                              subobject = subobject
                                              id        = id ).

          lv_class = `CL_BALI_LOG_DB`.
          CALL METHOD (lv_class)=>(`GET_INSTANCE`)
            RECEIVING
              db_handler = lo_db.

          CALL METHOD lo_db->(`LOAD_LOGS_VIA_FILTER`)
            EXPORTING
              filter    = lo_filter
            RECEIVING
              log_table = lt_logs.

          IF lt_logs IS INITIAL.
            bal_create( object    = object
                        subobject = subobject
                        id        = id
                        t_log     = t_log ).
            RETURN.
          ENDIF.

          " Append to the first (most recent) log
          
          
          
          temp75 = sy-tabix.
          READ TABLE lt_logs INDEX 1 INTO temp74.
          sy-tabix = temp75.
          IF sy-subrc <> 0.
            ASSERT 1 = 0.
          ENDIF.
          lo_log = temp74.
          bal_cloud_add_items( log   = lo_log
                               t_log = t_log ).

          CALL METHOD lo_db->(`SAVE_LOG`)
            EXPORTING
              log = lo_log.

          COMMIT WORK AND WAIT.

        CATCH cx_root.
          " Fallback: create new log if update fails
          bal_create( object    = object
                      subobject = subobject
                      id        = id
                      t_log     = t_log ).
      ENDTRY.

    ELSE.

      " Append the given messages to an already persisted log; create a new one if none exists.
      
      
      
      

      TRY.
          lr_handles = bal_std_load_handles( object    = object
                                             subobject = subobject
                                             id        = id ).
          IF lr_handles IS NOT BOUND.
            bal_create( object    = object
                        subobject = subobject
                        id        = id
                        t_log     = t_log ).
            RETURN.
          ENDIF.

          ASSIGN lr_handles->* TO <handles>.
          IF <handles> IS INITIAL.
            bal_create( object    = object
                        subobject = subobject
                        id        = id
                        t_log     = t_log ).
            RETURN.
          ENDIF.

          READ TABLE <handles> INDEX 1 ASSIGNING <handle>.
          bal_std_msg_add( handle = <handle>
                           t_log  = t_log ).

          lv_fm = `BAL_DB_SAVE`.
          CALL FUNCTION lv_fm
            EXPORTING
              i_t_log_handle = <handles>
            EXCEPTIONS
              OTHERS         = 1.
          IF sy-subrc = 0.
            COMMIT WORK AND WAIT.
          ENDIF.

          
        CATCH cx_root INTO lx_update.
          RAISE EXCEPTION TYPE zabaputil_cx_util_error
            EXPORTING
              val = lx_update.
      ENDTRY.

    ENDIF.

  ENDMETHOD.

  METHOD bal_delete.
      DATA lo_filter TYPE REF TO object.
      DATA lo_db TYPE REF TO object.
      TYPES temp15 TYPE STANDARD TABLE OF REF TO object.
DATA lt_logs TYPE temp15.
      DATA lv_class TYPE string.
          DATA lo_log LIKE LINE OF lt_logs.
      DATA lv_fm TYPE string.
      DATA lr_filter TYPE REF TO data.
      FIELD-SYMBOLS <filter> TYPE any.
          DATA lx_delete TYPE REF TO cx_root.

    IF zabaputil_cl_util_context=>check_abap_cloud( ) IS NOT INITIAL.

      
      
      

      

      TRY.
          lo_filter = bal_cloud_build_filter( object    = object
                                              subobject = subobject
                                              id        = id ).

          lv_class = `CL_BALI_LOG_DB`.
          CALL METHOD (lv_class)=>(`GET_INSTANCE`)
            RECEIVING
              db_handler = lo_db.

          CALL METHOD lo_db->(`LOAD_LOGS_VIA_FILTER`)
            EXPORTING
              filter    = lo_filter
            RECEIVING
              log_table = lt_logs.

          
          LOOP AT lt_logs INTO lo_log.
            CALL METHOD lo_db->(`DELETE_LOG`)
              EXPORTING
                log = lo_log.
          ENDLOOP.

          COMMIT WORK AND WAIT.

        CATCH cx_root.
          RETURN.
      ENDTRY.

    ELSE.

      
      
      

      TRY.
          lr_filter = bal_std_build_filter( object    = object
                                            subobject = subobject
                                            id        = id ).
          ASSIGN lr_filter->* TO <filter>.

          lv_fm = `BAL_DB_DELETE`.
          CALL FUNCTION lv_fm
            EXPORTING
              i_s_log_filter = <filter>
            EXCEPTIONS
              OTHERS         = 1.
          IF sy-subrc = 0.
            COMMIT WORK AND WAIT.
          ENDIF.

          
        CATCH cx_root INTO lx_delete.
          RAISE EXCEPTION TYPE zabaputil_cx_util_error
            EXPORTING
              val = lx_delete.
      ENDTRY.

    ENDIF.

  ENDMETHOD.

  METHOD tr_get_objects.
          DATA lo_transport TYPE REF TO object.
          TYPES temp16 TYPE STANDARD TABLE OF REF TO object.
DATA lt_objects_c TYPE temp16.
          DATA lv_xco TYPE string.
          DATA temp498 TYPE string.
          DATA lv_trkorr_c LIKE temp498.
          DATA lo_objects_api TYPE REF TO object.
          DATA lo_all TYPE REF TO object.
          DATA lo_obj LIKE LINE OF lt_objects_c.
            DATA ls_obj_c TYPE ty_s_tr_object.
    DATA lr_objects TYPE REF TO data.
    DATA lr_header TYPE REF TO data.
    FIELD-SYMBOLS <objects> TYPE STANDARD TABLE.
    FIELD-SYMBOLS <object> TYPE any.
    FIELD-SYMBOLS <header> TYPE any.
    FIELD-SYMBOLS <comp> TYPE any.
    DATA lv_fm TYPE string.
          DATA temp499 TYPE ty_s_tr_object.
          DATA ls_obj LIKE temp499.

    IF zabaputil_cl_util_context=>check_abap_cloud( ) IS NOT INITIAL.
      " Cloud: use XCO_CP_CTS
      TRY.
          
          

          
          lv_xco = `XCO_CP_CTS`.
          
          temp498 = trkorr.
          
          lv_trkorr_c = temp498.

          CALL METHOD (lv_xco)=>(`TRANSPORT`)
            EXPORTING
              iv_transport = lv_trkorr_c
            RECEIVING
              ro_transport = lo_transport.

          
          CALL METHOD lo_transport->(`OBJECTS`)
            RECEIVING
              ro_objects = lo_objects_api.

          
          CALL METHOD lo_objects_api->(`ALL`)
            RECEIVING
              ro_all = lo_all.

          CALL METHOD lo_all->(`GET`)
            RECEIVING
              rt_objects = lt_objects_c.

          
          LOOP AT lt_objects_c INTO lo_obj.
            
            CLEAR ls_obj_c.
            TRY.
                CALL METHOD lo_obj->(`GET_PGMID`)
                  RECEIVING
                    rv_pgmid = ls_obj_c-pgmid.
                CALL METHOD lo_obj->(`GET_TYPE`)
                  RECEIVING
                    rv_type = ls_obj_c-object.
                CALL METHOD lo_obj->(`GET_NAME`)
                  RECEIVING
                    rv_name = ls_obj_c-obj_name.
              CATCH cx_root ##NO_HANDLER.
            ENDTRY.
            INSERT ls_obj_c INTO TABLE result.
          ENDLOOP.

        CATCH cx_root ##NO_HANDLER.
      ENDTRY.
      RETURN.
    ENDIF.

    " Standard ABAP: use TR_GET_OBJECTS_OF_REQ_AN_TASKS
    
    
    
    
    
    
    

    TRY.
        CREATE DATA lr_objects TYPE STANDARD TABLE OF (`E071`).
        ASSIGN lr_objects->* TO <objects>.

        CREATE DATA lr_header TYPE (`TRWBO_REQUEST_HEADER`).
        ASSIGN lr_header->* TO <header>.
        ASSIGN COMPONENT `TRKORR` OF STRUCTURE <header> TO <comp>.
        <comp> = trkorr.

        lv_fm = `TR_GET_OBJECTS_OF_REQ_AN_TASKS`.
        CALL FUNCTION lv_fm
          EXPORTING
            is_request_header = <header>
          IMPORTING
            et_objects        = <objects>
          EXCEPTIONS
            OTHERS            = 1.
        IF sy-subrc <> 0.
          RETURN.
        ENDIF.

        LOOP AT <objects> ASSIGNING <object>.
          
          CLEAR temp499.
          
          ls_obj = temp499.
          ASSIGN COMPONENT `PGMID` OF STRUCTURE <object> TO <comp>.
          IF sy-subrc = 0. ls_obj-pgmid = <comp>. ENDIF.
          ASSIGN COMPONENT `OBJECT` OF STRUCTURE <object> TO <comp>.
          IF sy-subrc = 0. ls_obj-object = <comp>. ENDIF.
          ASSIGN COMPONENT `OBJ_NAME` OF STRUCTURE <object> TO <comp>.
          IF sy-subrc = 0. ls_obj-obj_name = <comp>. ENDIF.
          INSERT ls_obj INTO TABLE result.
        ENDLOOP.

      CATCH cx_root ##NO_HANDLER.
    ENDTRY.

  ENDMETHOD.

  METHOD tr_get_user_requests.
          DATA lv_xco TYPE string.
          DATA lo_filter_tr TYPE REF TO object.
          DATA lo_status_f TYPE REF TO object.
          DATA lo_owner_f TYPE REF TO object.
          TYPES temp17 TYPE STANDARD TABLE OF REF TO object.
DATA lt_transports TYPE temp17.
          DATA temp500 TYPE string.
          DATA temp76 TYPE string.
          DATA lv_user_c LIKE temp500.
          DATA lo_where TYPE REF TO object.
          DATA lo_tr LIKE LINE OF lt_transports.
            DATA ls_req_c TYPE ty_s_tr_request.
                DATA lo_props TYPE REF TO object.
                DATA ls_prop TYPE REF TO data.
                FIELD-SYMBOLS <prop> TYPE any.
                FIELD-SYMBOLS <pcomp> TYPE any.
                DATA lv_tr_value TYPE string.
    DATA lv_user TYPE c LENGTH 12.
    DATA lv_type TYPE c LENGTH 1.
    DATA lr_data TYPE REF TO data.
    FIELD-SYMBOLS <tab> TYPE STANDARD TABLE.
    FIELD-SYMBOLS <row> TYPE any.
    FIELD-SYMBOLS <comp> TYPE any.
        DATA lv_tab1 TYPE string.
        DATA lv_tab2 TYPE string.
        DATA lv_where TYPE string.
        DATA lt_comp TYPE abap_component_tab.
        DATA lo_struct TYPE REF TO cl_abap_structdescr.
        DATA lo_table TYPE REF TO cl_abap_tabledescr.
          DATA temp501 TYPE ty_s_tr_request.
          DATA ls_req LIKE temp501.

    IF zabaputil_cl_util_context=>check_abap_cloud( ) IS NOT INITIAL.
      " Cloud: use XCO_CP_CTS transport filter
      TRY.
          
          lv_xco = `XCO_CP_CTS`.
          
          
          
          


          
          
          IF user IS NOT INITIAL.
            temp76 = user.
          ELSE.
            temp76 = sy-uname.
          ENDIF.
          temp500 = temp76.
          
          lv_user_c = temp500.

          " Get modifiable transports for user
          CALL METHOD (lv_xco)=>(`TRANSPORTS`)
            RECEIVING
              ro_transports = lo_filter_tr.

          
          CALL METHOD lo_filter_tr->(`ALL`)
            RECEIVING
              ro_all = lo_where.

          CALL METHOD lo_where->(`GET`)
            RECEIVING
              rt_transports = lt_transports.

          
          LOOP AT lt_transports INTO lo_tr.
            
            CLEAR ls_req_c.
            TRY.
                
                CALL METHOD lo_tr->(`PROPERTIES`)
                  RECEIVING
                    ro_properties = lo_props.
                
                CALL METHOD lo_props->(`GET`)
                  RECEIVING
                    rs_properties = ls_prop.
                
                
                ASSIGN ls_prop->* TO <prop>.
                ASSIGN COMPONENT `OWNER` OF STRUCTURE <prop> TO <pcomp>.
                IF sy-subrc = 0. ls_req_c-owner = <pcomp>. ENDIF.
                IF ls_req_c-owner <> lv_user_c.
                  CONTINUE.
                ENDIF.
                ASSIGN COMPONENT `SHORT_DESCRIPTION` OF STRUCTURE <prop> TO <pcomp>.
                IF sy-subrc = 0. ls_req_c-description = <pcomp>. ENDIF.
                ASSIGN COMPONENT `STATUS` OF STRUCTURE <prop> TO <pcomp>.
                IF sy-subrc = 0. ls_req_c-status = <pcomp>. ENDIF.
                ASSIGN COMPONENT `TYPE` OF STRUCTURE <prop> TO <pcomp>.
                IF sy-subrc = 0. ls_req_c-type = <pcomp>. ENDIF.

                
                CALL METHOD lo_tr->(`GET_VALUE`)
                  RECEIVING
                    rv_value = lv_tr_value.
                ls_req_c-trkorr = lv_tr_value.

              CATCH cx_root ##NO_HANDLER.
            ENDTRY.
            IF ls_req_c-trkorr IS NOT INITIAL.
              INSERT ls_req_c INTO TABLE result.
            ENDIF.
          ENDLOOP.

        CATCH cx_root ##NO_HANDLER.
      ENDTRY.
      RETURN.
    ENDIF.

    " Standard ABAP: use dynamic SELECT from E070/E07T
    
    
    
    
    
    

    TRY.
        lv_user = user.
        lv_type = request_type.

        
        lv_tab1 = `E070`.
        
        lv_tab2 = `E07T`.
        
        lv_where = |AS4USER = '{ lv_user }' AND TRSTATUS IN ('D','L')|.

        " First read transports from E070
        
        lt_comp = zabaputil_cl_util_context=>rtti_get_t_attri_by_table_name( lv_tab1 ).
        
        lo_struct = cl_abap_structdescr=>create( lt_comp ).
        
        lo_table = cl_abap_tabledescr=>create( lo_struct ).
        CREATE DATA lr_data TYPE HANDLE lo_table.
        ASSIGN lr_data->* TO <tab>.

        SELECT trkorr as4user trstatus trfunction
          FROM (lv_tab1) INTO CORRESPONDING FIELDS OF TABLE <tab>
          WHERE (lv_where)
          .

        LOOP AT <tab> ASSIGNING <row>.
          
          CLEAR temp501.
          
          ls_req = temp501.
          ASSIGN COMPONENT `TRKORR` OF STRUCTURE <row> TO <comp>.
          IF sy-subrc = 0. ls_req-trkorr = <comp>. ENDIF.
          ASSIGN COMPONENT `AS4USER` OF STRUCTURE <row> TO <comp>.
          IF sy-subrc = 0. ls_req-owner = <comp>. ENDIF.
          ASSIGN COMPONENT `TRSTATUS` OF STRUCTURE <row> TO <comp>.
          IF sy-subrc = 0. ls_req-status = <comp>. ENDIF.
          ASSIGN COMPONENT `TRFUNCTION` OF STRUCTURE <row> TO <comp>.
          IF sy-subrc = 0. ls_req-type = <comp>. ENDIF.

          IF lv_type IS NOT INITIAL AND ls_req-type <> lv_type.
            CONTINUE.
          ENDIF.

          " Get description from E07T
          ls_req-description = tr_get_description( ls_req-trkorr ).
          INSERT ls_req INTO TABLE result.
        ENDLOOP.

      CATCH cx_root ##NO_HANDLER.
    ENDTRY.

  ENDMETHOD.

  METHOD tr_get_description.
          DATA lo_tr_d TYPE REF TO object.
          DATA lv_xco_d TYPE string.
          DATA temp502 TYPE string.
          DATA lo_props_d TYPE REF TO object.
    DATA lv_trkorr TYPE c LENGTH 20.
        DATA lv_tab TYPE string.
        DATA lv_where TYPE string.

    IF zabaputil_cl_util_context=>check_abap_cloud( ) IS NOT INITIAL.
      " Cloud: use XCO_CP_CTS
      TRY.
          
          
          lv_xco_d = `XCO_CP_CTS`.
          
          temp502 = trkorr.
          CALL METHOD (lv_xco_d)=>(`TRANSPORT`)
            EXPORTING
              iv_transport = temp502
            RECEIVING
              ro_transport = lo_tr_d.
          
          CALL METHOD lo_tr_d->(`PROPERTIES`)
            RECEIVING
              ro_properties = lo_props_d.
          CALL METHOD lo_props_d->(`GET_SHORT_DESCRIPTION`)
            RECEIVING
              rv_short_description = result.
        CATCH cx_root ##NO_HANDLER.
      ENDTRY.
      RETURN.
    ENDIF.

    " Standard: dynamic SELECT from E07T
    
    lv_trkorr = trkorr.

    TRY.
        
        lv_tab = `E07T`.
        
        lv_where = |TRKORR = '{ lv_trkorr }' AND LANGU = '{ sy-langu }'|.

        SELECT SINGLE as4text
          FROM (lv_tab) INTO result
          WHERE (lv_where)
          .
      CATCH cx_root ##NO_HANDLER.
    ENDTRY.

  ENDMETHOD.

  METHOD tr_is_released.
          DATA lo_tr_r TYPE REF TO object.
          DATA lv_xco_r TYPE string.
          DATA temp503 TYPE string.
          DATA lo_props_r TYPE REF TO object.
          DATA lv_status_c TYPE string.
          DATA temp16 TYPE xsdboolean.
    DATA lv_trkorr TYPE c LENGTH 20.
    DATA lv_status TYPE c LENGTH 1.
        DATA lv_tab TYPE string.
        DATA lv_where TYPE string.
        DATA temp17 TYPE xsdboolean.

    IF zabaputil_cl_util_context=>check_abap_cloud( ) IS NOT INITIAL.
      " Cloud: use XCO_CP_CTS
      TRY.
          
          
          lv_xco_r = `XCO_CP_CTS`.
          
          temp503 = trkorr.
          CALL METHOD (lv_xco_r)=>(`TRANSPORT`)
            EXPORTING
              iv_transport = temp503
            RECEIVING
              ro_transport = lo_tr_r.
          
          CALL METHOD lo_tr_r->(`PROPERTIES`)
            RECEIVING
              ro_properties = lo_props_r.
          
          CALL METHOD lo_props_r->(`GET_STATUS`)
            RECEIVING
              rv_status = lv_status_c.
          
          temp16 = boolc( lv_status_c = `RELEASED` OR lv_status_c = `R` ).
          result = temp16.
        CATCH cx_root.
          result = abap_false.
      ENDTRY.
      RETURN.
    ENDIF.

    " Standard: dynamic SELECT from E070
    
    
    lv_trkorr = trkorr.

    TRY.
        
        lv_tab = `E070`.
        
        lv_where = |TRKORR = '{ lv_trkorr }'|.

        SELECT SINGLE trstatus
          FROM (lv_tab) INTO lv_status
          WHERE (lv_where)
          .
        
        temp17 = boolc( lv_status = `R` ).
        result = temp17.
      CATCH cx_root.
        result = abap_false.
    ENDTRY.

  ENDMETHOD.

  METHOD tr_add_object.

    DATA lv_fm       TYPE string.
    DATA lv_trkorr   TYPE c LENGTH 20.
    DATA lv_pgmid    TYPE c LENGTH 4.
    DATA lv_object   TYPE c LENGTH 4.
    DATA lv_obj_name TYPE c LENGTH 120.
        DATA lx TYPE REF TO zabaputil_cx_util_error.
        DATA x TYPE REF TO cx_root.

    lv_trkorr   = trkorr.
    lv_pgmid    = pgmid.
    lv_object   = object.
    lv_obj_name = obj_name.

    TRY.
        lv_fm = `TR_ORDER_CHOICE_CORRECTION`.
        CALL FUNCTION lv_fm
          EXPORTING
            iv_category    = lv_pgmid
            iv_object      = lv_object
            iv_obj_name    = lv_obj_name
            iv_order       = lv_trkorr
          EXCEPTIONS
            OTHERS         = 1.
        IF sy-subrc <> 0.
          RAISE EXCEPTION TYPE zabaputil_cx_util_error
            EXPORTING
              val = `TR_ADD_OBJECT failed`.
        ENDIF.

        
      CATCH zabaputil_cx_util_error INTO lx.
        RAISE EXCEPTION lx.
        
      CATCH cx_root INTO x.
        RAISE EXCEPTION TYPE zabaputil_cx_util_error
          EXPORTING
            val = x.
    ENDTRY.

  ENDMETHOD.

  METHOD tr_create.
        DATA lr_header TYPE REF TO data.
        FIELD-SYMBOLS <header> TYPE any.
        FIELD-SYMBOLS <trkorr> TYPE any.
        DATA lv_class TYPE string.
        DATA x TYPE REF TO cx_root.

    " Create an empty transport request (default type `T` = transport of copies).
    " Uses the released class CL_ADT_CTS_MANAGEMENT, available on standard ABAP
    " (>= 7.51) and ABAP Cloud. Called dynamically so the source stays compilable
    " on all targets - on releases where the class is missing a clean
    " z2ui5_cx_util_error is raised instead of a short dump.
    TRY.

        
        
        
        

        CREATE DATA lr_header TYPE (`TRWBO_REQUEST_HEADER`).
        ASSIGN lr_header->* TO <header>.

        lv_class = `CL_ADT_CTS_MANAGEMENT`.
        CALL METHOD (lv_class)=>(`CREATE_EMPTY_REQUEST`)
          EXPORTING
            iv_type           = type
            iv_text           = text
            iv_target         = target
          IMPORTING
            es_request_header = <header>.

        ASSIGN COMPONENT `TRKORR` OF STRUCTURE <header> TO <trkorr>.
        result = <trkorr>.

        
      CATCH cx_root INTO x.
        RAISE EXCEPTION TYPE zabaputil_cx_util_error
          EXPORTING
            previous = x.
    ENDTRY.

  ENDMETHOD.

  METHOD tr_release.
        DATA lo_api TYPE REF TO object.
        DATA lv_class TYPE string.
        DATA x TYPE REF TO cx_root.

    " Release a transport request via the released CTS REST API
    " (CL_CTS_REST_API_FACTORY). Works on standard ABAP and ABAP Cloud.
    TRY.

        
        

        lv_class = `CL_CTS_REST_API_FACTORY`.
        CALL METHOD (lv_class)=>(`CREATE_INSTANCE`)
          RECEIVING
            result = lo_api.

        CALL METHOD lo_api->(`RELEASE`)
          EXPORTING
            iv_trkorr       = trkorr
            iv_ignore_locks = ignore_locks.

        
      CATCH cx_root INTO x.
        RAISE EXCEPTION TYPE zabaputil_cx_util_error
          EXPORTING
            previous = x.
    ENDTRY.

  ENDMETHOD.

  METHOD tr_copy_objects.
        DATA lr_headers TYPE REF TO data.
        FIELD-SYMBOLS <headers> TYPE ANY TABLE.
        FIELD-SYMBOLS <header> TYPE any.
        FIELD-SYMBOLS <trkorr> TYPE any.
        FIELD-SYMBOLS <strkorr> TYPE any.
        DATA lv_fm TYPE string.
        DATA lx_known TYPE REF TO zabaputil_cx_util_error.
        DATA x TYPE REF TO cx_root.

    " Copying objects between requests relies on the classic transport
    " functions (TR_COPY_COMM) which are not released on ABAP Cloud.
    IF zabaputil_cl_util_context=>check_abap_cloud( ) IS NOT INITIAL.
      RAISE EXCEPTION TYPE zabaputil_cx_util_error
        EXPORTING
          val = `tr_copy_objects is not supported on ABAP Cloud`.
    ENDIF.

    " Copy all objects/commands of a source request (and its tasks) into a
    " target request via the classic transport functions. Called dynamically
    " so the statement stays compilable on ABAP Cloud as well, even though the
    " function modules only exist on-premise.
    TRY.

        
        
        
        
        
        

        CREATE DATA lr_headers TYPE (`TRWBO_REQUEST_HEADERS`).
        ASSIGN lr_headers->* TO <headers>.

        lv_fm = `TR_READ_REQUEST_WITH_TASKS`.
        CALL FUNCTION lv_fm
          EXPORTING
            iv_trkorr          = source
          IMPORTING
            et_request_headers = <headers>
          EXCEPTIONS
            invalid_input      = 1
            OTHERS             = 2.
        IF sy-subrc <> 0.
          RAISE EXCEPTION TYPE zabaputil_cx_util_error
            EXPORTING
              val = `TR_READ_REQUEST_WITH_TASKS failed`.
        ENDIF.

        LOOP AT <headers> ASSIGNING <header>.

          ASSIGN COMPONENT `TRKORR`  OF STRUCTURE <header> TO <trkorr>.
          ASSIGN COMPONENT `STRKORR` OF STRUCTURE <header> TO <strkorr>.
          IF <trkorr> <> source AND <strkorr> <> source.
            CONTINUE.
          ENDIF.

          lv_fm = `TR_COPY_COMM`.
          CALL FUNCTION lv_fm
            EXPORTING
              wi_dialog                = abap_false
              wi_trkorr_from           = <trkorr>
              wi_trkorr_to             = destination
              wi_without_documentation = abap_false
            EXCEPTIONS
              OTHERS                   = 1.
          IF sy-subrc <> 0.
            RAISE EXCEPTION TYPE zabaputil_cx_util_error
              EXPORTING
                val = `TR_COPY_COMM failed`.
          ENDIF.

        ENDLOOP.

        
      CATCH zabaputil_cx_util_error INTO lx_known.
        RAISE EXCEPTION lx_known.
        
      CATCH cx_root INTO x.
        RAISE EXCEPTION TYPE zabaputil_cx_util_error
          EXPORTING
            previous = x.
    ENDTRY.

  ENDMETHOD.

  METHOD tr_import.
        DATA lv_system TYPE c LENGTH 8.
        DATA lv_client TYPE c LENGTH 3.
        DATA lv_retcode TYPE c LENGTH 4.
        DATA lr_exc TYPE REF TO data.
        FIELD-SYMBOLS <exc> TYPE any.
        DATA lv_fm TYPE string.
        DATA lx_known TYPE REF TO zabaputil_cx_util_error.
        DATA x TYPE REF TO cx_root.

    " Importing transports via TMS (TMS_MGR_*) is not available on ABAP Cloud.
    IF zabaputil_cl_util_context=>check_abap_cloud( ) IS NOT INITIAL.
      RAISE EXCEPTION TYPE zabaputil_cx_util_error
        EXPORTING
          val = `tr_import is not supported on ABAP Cloud`.
    ENDIF.

    " Import a transport request into a target system via TMS. The target
    " system may be given as `SYSTEM` or `SYSTEM.CLIENT`; an explicit client
    " parameter takes precedence, otherwise the current client is used.
    TRY.

        
        
        
        
        
        

        SPLIT target_system AT `.` INTO lv_system lv_client.
        IF lv_client IS INITIAL.
          IF client IS NOT INITIAL.
            lv_client = client.
          ELSE.
            lv_client = sy-mandt.
          ENDIF.
        ENDIF.

        CREATE DATA lr_exc TYPE (`STMSCALERT`).
        ASSIGN lr_exc->* TO <exc>.

        lv_fm = `TMS_MGR_REFRESH_IMPORT_QUEUES`.
        CALL FUNCTION lv_fm
          EXPORTING
            iv_system    = lv_system
            iv_monitor   = abap_true
            iv_verbose   = abap_true
          IMPORTING
            es_exception = <exc>
          EXCEPTIONS
            OTHERS       = 99.
        IF sy-subrc = 99.
          RAISE EXCEPTION TYPE zabaputil_cx_util_error
            EXPORTING
              val = `TMS_MGR_REFRESH_IMPORT_QUEUES failed`.
        ENDIF.

        lv_fm = `TMS_MGR_IMPORT_TR_REQUEST`.
        CALL FUNCTION lv_fm
          EXPORTING
            iv_system                  = lv_system
            iv_request                 = trkorr
            iv_client                  = lv_client
            iv_ignore_cvers            = ignore_version
          IMPORTING
            ev_tp_ret_code             = lv_retcode
          EXCEPTIONS
            read_config_failed         = 1
            table_of_requests_is_empty = 2
            OTHERS                     = 3.
        IF sy-subrc <> 0.
          RAISE EXCEPTION TYPE zabaputil_cx_util_error
            EXPORTING
              val = `TMS_MGR_IMPORT_TR_REQUEST failed`.
        ENDIF.

        result = lv_retcode.

        
      CATCH zabaputil_cx_util_error INTO lx_known.
        RAISE EXCEPTION lx_known.
        
      CATCH cx_root INTO x.
        RAISE EXCEPTION TYPE zabaputil_cx_util_error
          EXPORTING
            previous = x.
    ENDTRY.

  ENDMETHOD.

  METHOD tr_check_status.
        DATA lr_settings TYPE REF TO data.
        DATA lr_cofile TYPE REF TO data.
        DATA lr_sysline TYPE REF TO data.
        FIELD-SYMBOLS <settings> TYPE any.
        FIELD-SYMBOLS <systems> TYPE ANY TABLE.
        FIELD-SYMBOLS <sysline> TYPE any.
        FIELD-SYMBOLS <cofile> TYPE any.
        FIELD-SYMBOLS <comp> TYPE any.
        DATA lv_fm TYPE string.
        DATA lx_known TYPE REF TO zabaputil_cx_util_error.
        DATA x TYPE REF TO cx_root.

    " Reading the transport log (TR_READ_GLOBAL_INFO_OF_REQUEST) is not
    " available on ABAP Cloud.
    IF zabaputil_cl_util_context=>check_abap_cloud( ) IS NOT INITIAL.
      RAISE EXCEPTION TYPE zabaputil_cx_util_error
        EXPORTING
          val = `tr_check_status is not supported on ABAP Cloud`.
    ENDIF.

    " Read the import status (imported flag + return code) of a request in a
    " given system via the classic transport log API.
    TRY.

        
        
        
        
        
        
        
        
        

        CREATE DATA lr_settings TYPE (`CTSLG_SETTINGS`).
        ASSIGN lr_settings->* TO <settings>.
        ASSIGN COMPONENT `SYSTEMS` OF STRUCTURE <settings> TO <systems>.

        CREATE DATA lr_sysline LIKE LINE OF <systems>.
        ASSIGN lr_sysline->* TO <sysline>.
        <sysline> = system.
        INSERT <sysline> INTO TABLE <systems>.

        CREATE DATA lr_cofile TYPE (`CTSLG_COFILE`).
        ASSIGN lr_cofile->* TO <cofile>.

        lv_fm = `TR_READ_GLOBAL_INFO_OF_REQUEST`.
        CALL FUNCTION lv_fm
          EXPORTING
            iv_trkorr   = trkorr
            is_settings = <settings>
          IMPORTING
            es_cofile   = <cofile>.

        ASSIGN COMPONENT `EXISTS` OF STRUCTURE <cofile> TO <comp>.
        IF <comp> = abap_false.
          RAISE EXCEPTION TYPE zabaputil_cx_util_error
            EXPORTING
              val = `request does not exist in target system`.
        ENDIF.

        ASSIGN COMPONENT `IMPORTED` OF STRUCTURE <cofile> TO <comp>.
        imported = <comp>.
        ASSIGN COMPONENT `RC` OF STRUCTURE <cofile> TO <comp>.
        rc = <comp>.

        
      CATCH zabaputil_cx_util_error INTO lx_known.
        RAISE EXCEPTION lx_known.
        
      CATCH cx_root INTO x.
        RAISE EXCEPTION TYPE zabaputil_cx_util_error
          EXPORTING
            previous = x.
    ENDTRY.

  ENDMETHOD.

  METHOD bal_cloud_add_items.

    DATA lo_item  TYPE REF TO object.
    DATA lv_msgty TYPE c LENGTH 1.
    DATA lv_class TYPE string.

    DATA ls_log LIKE LINE OF t_log.
    LOOP AT t_log INTO ls_log.

      lv_msgty = ls_log-type.

      IF ls_log-id IS NOT INITIAL AND ls_log-no IS NOT INITIAL.
        lv_class = `CL_BALI_MESSAGE_SETTER`.
        CALL METHOD (lv_class)=>(`CREATE`)
          EXPORTING
            severity   = lv_msgty
            id         = ls_log-id
            number     = ls_log-no
            variable_1 = ls_log-v1
            variable_2 = ls_log-v2
            variable_3 = ls_log-v3
            variable_4 = ls_log-v4
          RECEIVING
            message    = lo_item.
      ELSE.
        lv_class = `CL_BALI_FREE_TEXT_SETTER`.
        CALL METHOD (lv_class)=>(`CREATE`)
          EXPORTING
            severity  = lv_msgty
            text      = ls_log-text
          RECEIVING
            free_text = lo_item.
      ENDIF.

      CALL METHOD log->(`ADD_ITEM`)
        EXPORTING
          item = lo_item.

    ENDLOOP.

  ENDMETHOD.

  METHOD bal_cloud_build_filter.

    DATA lo_filter TYPE REF TO object.
    DATA lv_class  TYPE string.

    lv_class = `CL_BALI_LOG_FILTER`.
    CALL METHOD (lv_class)=>(`CREATE`)
      RECEIVING
        filter = lo_filter.

    CALL METHOD lo_filter->(`SET_DESCRIPTOR`)
      EXPORTING
        object      = object
        subobject   = subobject
        external_id = id.

    result = lo_filter.

  ENDMETHOD.

  METHOD bal_std_msg_add.

    DATA lv_fm    TYPE string.
    DATA lr_msg   TYPE REF TO data.
    DATA lv_msgty TYPE c LENGTH 1.
    DATA lv_text  TYPE c LENGTH 200.
    FIELD-SYMBOLS <msg>  TYPE any.
    FIELD-SYMBOLS <comp> TYPE any.

    DATA ls_log LIKE LINE OF t_log.
    LOOP AT t_log INTO ls_log.

      IF ls_log-id IS NOT INITIAL AND ls_log-no IS NOT INITIAL.

        CREATE DATA lr_msg TYPE ('BAL_S_MSG').
        ASSIGN lr_msg->* TO <msg>.
        ASSIGN COMPONENT `MSGTY` OF STRUCTURE <msg> TO <comp>.
        <comp> = ls_log-type.
        ASSIGN COMPONENT `MSGID` OF STRUCTURE <msg> TO <comp>.
        <comp> = ls_log-id.
        ASSIGN COMPONENT `MSGNO` OF STRUCTURE <msg> TO <comp>.
        <comp> = ls_log-no.
        ASSIGN COMPONENT `MSGV1` OF STRUCTURE <msg> TO <comp>.
        <comp> = ls_log-v1.
        ASSIGN COMPONENT `MSGV2` OF STRUCTURE <msg> TO <comp>.
        <comp> = ls_log-v2.
        ASSIGN COMPONENT `MSGV3` OF STRUCTURE <msg> TO <comp>.
        <comp> = ls_log-v3.
        ASSIGN COMPONENT `MSGV4` OF STRUCTURE <msg> TO <comp>.
        <comp> = ls_log-v4.

        lv_fm = `BAL_LOG_MSG_ADD`.
        CALL FUNCTION lv_fm
          EXPORTING
            i_log_handle = handle
            i_s_msg      = <msg>
          EXCEPTIONS
            OTHERS       = 1.

      ELSE.

        lv_msgty = ls_log-type.
        lv_text  = ls_log-text.
        lv_fm    = `BAL_LOG_MSG_ADD_FREE_TEXT`.
        CALL FUNCTION lv_fm
          EXPORTING
            i_log_handle = handle
            i_msgty      = lv_msgty
            i_text       = lv_text
          EXCEPTIONS
            OTHERS       = 1.

      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD bal_std_load_handles.

    DATA lv_fm      TYPE string.
    DATA lr_filter  TYPE REF TO data.
    DATA lr_headers TYPE REF TO data.
    FIELD-SYMBOLS <filter>  TYPE any.
    FIELD-SYMBOLS <headers> TYPE SORTED TABLE.
    FIELD-SYMBOLS <handles> TYPE SORTED TABLE.

    lr_filter = bal_std_build_filter( object    = object
                                      subobject = subobject
                                      id        = id ).
    ASSIGN lr_filter->* TO <filter>.

    CREATE DATA lr_headers TYPE ('BALHDR_T').
    ASSIGN lr_headers->* TO <headers>.

    lv_fm = `BAL_DB_SEARCH`.
    CALL FUNCTION lv_fm
      EXPORTING
        i_s_log_filter = <filter>
      IMPORTING
        e_t_log_header = <headers>
      EXCEPTIONS
        OTHERS         = 1.
    IF sy-subrc <> 0 OR <headers> IS INITIAL.
      RETURN.
    ENDIF.

    CREATE DATA result TYPE ('BAL_T_LOGH').
    ASSIGN result->* TO <handles>.

    lv_fm = `BAL_DB_LOAD`.
    CALL FUNCTION lv_fm
      EXPORTING
        i_t_log_header = <headers>
      IMPORTING
        e_t_log_handle = <handles>
      EXCEPTIONS
        OTHERS         = 1.

  ENDMETHOD.

  METHOD bal_std_build_filter.

    FIELD-SYMBOLS <filter> TYPE any.

    CREATE DATA result TYPE ('BAL_S_LFIL').
    ASSIGN result->* TO <filter>.

    bal_std_filter_add( EXPORTING comp   = `OBJECT`
                                  value  = object
                        CHANGING  filter = <filter> ).
    bal_std_filter_add( EXPORTING comp   = `SUBOBJECT`
                                  value  = subobject
                        CHANGING  filter = <filter> ).
    bal_std_filter_add( EXPORTING comp   = `EXTNUMBER`
                                  value  = id
                        CHANGING  filter = <filter> ).

  ENDMETHOD.

  METHOD bal_std_filter_add.

    DATA lr_line TYPE REF TO data.
    FIELD-SYMBOLS <range> TYPE STANDARD TABLE.
    FIELD-SYMBOLS <line>  TYPE any.
    FIELD-SYMBOLS <comp>  TYPE any.

    IF value IS INITIAL.
      RETURN.
    ENDIF.

    ASSIGN COMPONENT comp OF STRUCTURE filter TO <range>.
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    CREATE DATA lr_line LIKE LINE OF <range>.
    ASSIGN lr_line->* TO <line>.
    ASSIGN COMPONENT `SIGN` OF STRUCTURE <line> TO <comp>.
    <comp> = `I`.
    ASSIGN COMPONENT `OPTION` OF STRUCTURE <line> TO <comp>.
    <comp> = `EQ`.
    ASSIGN COMPONENT `LOW` OF STRUCTURE <line> TO <comp>.
    <comp> = value.
    INSERT <line> INTO TABLE <range>.

  ENDMETHOD.

  METHOD bal_std_map_msg.

    DATA lv_fm   TYPE string.
    DATA lv_text TYPE c LENGTH 200.
    FIELD-SYMBOLS <comp> TYPE any.

    ASSIGN COMPONENT `MSGTY` OF STRUCTURE msg TO <comp>.
    IF sy-subrc = 0.
      result-type = <comp>.
    ENDIF.
    ASSIGN COMPONENT `MSGID` OF STRUCTURE msg TO <comp>.
    IF sy-subrc = 0.
      result-id = <comp>.
    ENDIF.
    ASSIGN COMPONENT `MSGNO` OF STRUCTURE msg TO <comp>.
    IF sy-subrc = 0.
      result-no = <comp>.
    ENDIF.
    ASSIGN COMPONENT `MSGV1` OF STRUCTURE msg TO <comp>.
    IF sy-subrc = 0.
      result-v1 = <comp>.
    ENDIF.
    ASSIGN COMPONENT `MSGV2` OF STRUCTURE msg TO <comp>.
    IF sy-subrc = 0.
      result-v2 = <comp>.
    ENDIF.
    ASSIGN COMPONENT `MSGV3` OF STRUCTURE msg TO <comp>.
    IF sy-subrc = 0.
      result-v3 = <comp>.
    ENDIF.
    ASSIGN COMPONENT `MSGV4` OF STRUCTURE msg TO <comp>.
    IF sy-subrc = 0.
      result-v4 = <comp>.
    ENDIF.
    ASSIGN COMPONENT `TIME_STMP` OF STRUCTURE msg TO <comp>.
    IF sy-subrc = 0.
      result-timestampl = <comp>.
    ENDIF.

    TRY.
        lv_fm = `MESSAGE_TEXT_BUILD`.
        CALL FUNCTION lv_fm
          EXPORTING
            msgid               = result-id
            msgnr               = result-no
            msgv1               = result-v1
            msgv2               = result-v2
            msgv3               = result-v3
            msgv4               = result-v4
          IMPORTING
            message_text_output = lv_text.
        result-text = lv_text.
      CATCH cx_root.
        result-text = result-v1.
    ENDTRY.

  ENDMETHOD.

  METHOD lock_set.

    result = lock_call_function( val     = val
                                 t_param = t_param ).

  ENDMETHOD.

  METHOD lock_set_wait.

    DATA lv_remaining LIKE retries.
    lv_remaining = retries.

    WHILE lv_remaining > 0.
      result = lock_set( val     = val
                          t_param = t_param ).
      IF result = abap_true.
        RETURN.
      ENDIF.
      lv_remaining = lv_remaining - 1.
      IF lv_remaining > 0.
        WAIT UP TO delay_ms / 1000 SECONDS.
      ENDIF.
    ENDWHILE.

  ENDMETHOD.

  METHOD lock_is_locked.

    " Try to set the lock — if it fails, the object is locked.
    DATA lv_locked TYPE abap_bool.
    lv_locked = lock_set( val     = val
                                 t_param = t_param ).
    IF lv_locked = abap_true.
      " We got it — release immediately
      lock_delete( val     = val
                   t_param = t_param ).
      result = abap_false.
    ELSE.
      result = abap_true.
    ENDIF.

  ENDMETHOD.

  METHOD lock_get_owner.
        DATA lt_locks TYPE zabaputil_cl_util_context=>ty_t_lock.
        DATA lv_arg TYPE string.
        DATA ls_param LIKE LINE OF t_param.
        DATA lv_name TYPE string.
        DATA ls_lock LIKE LINE OF lt_locks.

    TRY.
        
        lt_locks = lock_read( ).

        " Build the lock argument from params for matching
        
        lv_arg = ``.
        
        LOOP AT t_param INTO ls_param.
          lv_arg = lv_arg && ls_param-value.
        ENDLOOP.

        
        lv_name = zabaputil_cl_util_context=>c_trim_upper( val ).
        REPLACE `ENQUEUE_` IN lv_name WITH ``.

        
        LOOP AT lt_locks INTO ls_lock
             WHERE lock_object CS lv_name.
          IF lv_arg IS INITIAL OR ls_lock-argument CS lv_arg.
            result = ls_lock-user.
            RETURN.
          ENDIF.
        ENDLOOP.

      CATCH cx_root ##NO_HANDLER.
    ENDTRY.

  ENDMETHOD.

  METHOD lock_get_dequeue_by_enqueue.

    result = replace( val  = zabaputil_cl_util_context=>c_trim_upper( val )
                      sub  = `ENQUEUE_`
                      with = `DEQUEUE_` ).

  ENDMETHOD.

  METHOD lock_read.

    DATA lr_enq TYPE REF TO data.
    FIELD-SYMBOLS <lt_enq>   TYPE STANDARD TABLE.
    FIELD-SYMBOLS <ls_enq>   TYPE any.
    FIELD-SYMBOLS <lv_value> TYPE any.
    DATA lv_client     TYPE c LENGTH 3.
    DATA lv_name       TYPE c LENGTH 30.
    DATA lv_uname      TYPE c LENGTH 12.
    DATA lt_param      TYPE abap_func_parmbind_tab.
    DATA ls_param      TYPE abap_func_parmbind.
    DATA lt_exception  TYPE abap_func_excpbind_tab.
    DATA ls_exception  TYPE abap_func_excpbind.
    DATA lv_function   TYPE string.
    DATA ls_lock       TYPE ty_s_lock.
        DATA lx_error TYPE REF TO zabaputil_cx_util_error.
        DATA lx_root TYPE REF TO cx_root.

    TRY.
        CREATE DATA lr_enq TYPE STANDARD TABLE OF (`SEQG3`).
        ASSIGN lr_enq->* TO <lt_enq>.

        IF client IS INITIAL.
          lv_client = zabaputil_cl_util_context=>context_get_sy( )-mandt.
        ELSE.
          lv_client = client.
        ENDIF.
        lv_name  = lock_object.
        lv_uname = user.

        ls_param-name = `GCLIENT`.
        ls_param-kind = abap_func_exporting.
        GET REFERENCE OF lv_client INTO ls_param-value.
        INSERT ls_param INTO TABLE lt_param.

        ls_param-name = `GNAME`.
        GET REFERENCE OF lv_name INTO ls_param-value.
        INSERT ls_param INTO TABLE lt_param.

        ls_param-name = `GUNAME`.
        GET REFERENCE OF lv_uname INTO ls_param-value.
        INSERT ls_param INTO TABLE lt_param.

        ls_param-name = `ENQ`.
        ls_param-kind = abap_func_tables.
        GET REFERENCE OF <lt_enq> INTO ls_param-value.
        INSERT ls_param INTO TABLE lt_param.

        ls_exception-name  = `OTHERS`.
        ls_exception-value = 4.
        INSERT ls_exception INTO TABLE lt_exception.

        lv_function = `ENQUEUE_READ`.
        CALL FUNCTION lv_function
          PARAMETER-TABLE lt_param
          EXCEPTION-TABLE lt_exception.
        IF sy-subrc <> 0.
          RAISE EXCEPTION TYPE zabaputil_cx_util_error EXPORTING val = `LOCK_READ_FAILED`.
        ENDIF.

        LOOP AT <lt_enq> ASSIGNING <ls_enq>.
          CLEAR ls_lock.
          ASSIGN COMPONENT `GNAME` OF STRUCTURE <ls_enq> TO <lv_value>.
          IF sy-subrc = 0.
            ls_lock-lock_object = <lv_value>.
          ENDIF.
          ASSIGN COMPONENT `GARG` OF STRUCTURE <ls_enq> TO <lv_value>.
          IF sy-subrc = 0.
            ls_lock-argument = <lv_value>.
          ENDIF.
          ASSIGN COMPONENT `GUNAME` OF STRUCTURE <ls_enq> TO <lv_value>.
          IF sy-subrc = 0.
            ls_lock-user = <lv_value>.
          ENDIF.
          ASSIGN COMPONENT `GMODE` OF STRUCTURE <ls_enq> TO <lv_value>.
          IF sy-subrc = 0.
            ls_lock-mode = <lv_value>.
          ENDIF.
          ASSIGN COMPONENT `GCLIENT` OF STRUCTURE <ls_enq> TO <lv_value>.
          IF sy-subrc = 0.
            ls_lock-client = <lv_value>.
          ENDIF.
          ASSIGN COMPONENT `GTDATE` OF STRUCTURE <ls_enq> TO <lv_value>.
          IF sy-subrc = 0.
            ls_lock-date = <lv_value>.
          ENDIF.
          ASSIGN COMPONENT `GTTIME` OF STRUCTURE <ls_enq> TO <lv_value>.
          IF sy-subrc = 0.
            ls_lock-time = <lv_value>.
          ENDIF.
          ASSIGN COMPONENT `GUSR` OF STRUCTURE <ls_enq> TO <lv_value>.
          IF sy-subrc = 0.
            ls_lock-owner = <lv_value>.
          ENDIF.
          ASSIGN COMPONENT `GUSRVB` OF STRUCTURE <ls_enq> TO <lv_value>.
          IF sy-subrc = 0.
            ls_lock-owner_vb = <lv_value>.
          ENDIF.
          INSERT ls_lock INTO TABLE result.
        ENDLOOP.

        
      CATCH zabaputil_cx_util_error INTO lx_error.
        RAISE EXCEPTION lx_error.
        
      CATCH cx_root INTO lx_root.
        RAISE EXCEPTION TYPE zabaputil_cx_util_error EXPORTING val = lx_root.
    ENDTRY.

  ENDMETHOD.

  METHOD lock_delete.

    result = lock_call_function( val     = lock_get_dequeue_by_enqueue( val )
                                 t_param = t_param ).

  ENDMETHOD.

  METHOD lock_delete_entries.

    DATA lr_enq TYPE REF TO data.
    FIELD-SYMBOLS <lt_enq>   TYPE STANDARD TABLE.
    FIELD-SYMBOLS <ls_enq>   TYPE any.
    FIELD-SYMBOLS <lv_value> TYPE any.
    DATA lr_row        TYPE REF TO data.
    DATA ls_lock       TYPE ty_s_lock.
    DATA lv_check_upd  TYPE i.
    DATA lv_subrc      TYPE sy-subrc.
    DATA lt_param      TYPE abap_func_parmbind_tab.
    DATA ls_param      TYPE abap_func_parmbind.
    DATA lt_exception  TYPE abap_func_excpbind_tab.
    DATA ls_exception  TYPE abap_func_excpbind.
    DATA lv_function   TYPE string.
        DATA temp18 TYPE xsdboolean.

    TRY.
        CREATE DATA lr_enq TYPE STANDARD TABLE OF (`SEQG3`).
        ASSIGN lr_enq->* TO <lt_enq>.
        CREATE DATA lr_row TYPE (`SEQG3`).
        ASSIGN lr_row->* TO <ls_enq>.

        LOOP AT t_lock INTO ls_lock.
          CLEAR <ls_enq>.
          ASSIGN COMPONENT `GNAME` OF STRUCTURE <ls_enq> TO <lv_value>.
          IF sy-subrc = 0.
            <lv_value> = ls_lock-lock_object.
          ENDIF.
          ASSIGN COMPONENT `GARG` OF STRUCTURE <ls_enq> TO <lv_value>.
          IF sy-subrc = 0.
            <lv_value> = ls_lock-argument.
          ENDIF.
          ASSIGN COMPONENT `GUNAME` OF STRUCTURE <ls_enq> TO <lv_value>.
          IF sy-subrc = 0.
            <lv_value> = ls_lock-user.
          ENDIF.
          ASSIGN COMPONENT `GMODE` OF STRUCTURE <ls_enq> TO <lv_value>.
          IF sy-subrc = 0.
            <lv_value> = ls_lock-mode.
          ENDIF.
          ASSIGN COMPONENT `GCLIENT` OF STRUCTURE <ls_enq> TO <lv_value>.
          IF sy-subrc = 0.
            <lv_value> = ls_lock-client.
          ENDIF.
          ASSIGN COMPONENT `GUSR` OF STRUCTURE <ls_enq> TO <lv_value>.
          IF sy-subrc = 0.
            <lv_value> = ls_lock-owner.
          ENDIF.
          ASSIGN COMPONENT `GUSRVB` OF STRUCTURE <ls_enq> TO <lv_value>.
          IF sy-subrc = 0.
            <lv_value> = ls_lock-owner_vb.
          ENDIF.
          INSERT <ls_enq> INTO TABLE <lt_enq>.
        ENDLOOP.

        IF <lt_enq> IS INITIAL.
          result = abap_true.
          RETURN.
        ENDIF.

        ls_param-name = `CHECK_UPD_REQUESTS`.
        ls_param-kind = abap_func_exporting.
        GET REFERENCE OF lv_check_upd INTO ls_param-value.
        INSERT ls_param INTO TABLE lt_param.

        ls_param-name = `SUBRC`.
        ls_param-kind = abap_func_importing.
        GET REFERENCE OF lv_subrc INTO ls_param-value.
        INSERT ls_param INTO TABLE lt_param.

        ls_param-name = `ENQ`.
        ls_param-kind = abap_func_tables.
        GET REFERENCE OF <lt_enq> INTO ls_param-value.
        INSERT ls_param INTO TABLE lt_param.

        ls_exception-name  = `OTHERS`.
        ls_exception-value = 4.
        INSERT ls_exception INTO TABLE lt_exception.

        lv_function = `ENQUE_DELETE`.
        CALL FUNCTION lv_function
          PARAMETER-TABLE lt_param
          EXCEPTION-TABLE lt_exception.

        
        temp18 = boolc( sy-subrc = 0 AND lv_subrc = 0 ).
        result = temp18.

      CATCH cx_root.
        result = abap_false.
    ENDTRY.

  ENDMETHOD.

  METHOD auth_check.

    DATA lv_object   TYPE c LENGTH 10.
    DATA lv_field    TYPE c LENGTH 10.
    DATA lv_value    TYPE c LENGTH 40.
    DATA lv_activity TYPE c LENGTH 2.
    DATA temp19 TYPE xsdboolean.

    lv_object   = object.
    lv_field    = field.
    lv_value    = value.
    lv_activity = activity.

    AUTHORITY-CHECK OBJECT lv_object
      ID lv_field FIELD lv_value
      ID 'ACTVT' FIELD lv_activity.

    
    temp19 = boolc( sy-subrc = 0 ).
    result = temp19.

  ENDMETHOD.

  METHOD text_get.

    DATA lv_msgid TYPE c LENGTH 20.
    DATA lv_msgno TYPE n LENGTH 3.
    DATA lv_msgv1 TYPE c LENGTH 50.
    DATA lv_msgv2 TYPE c LENGTH 50.
    DATA lv_msgv3 TYPE c LENGTH 50.
    DATA lv_msgv4 TYPE c LENGTH 50.
    DATA lv_text  TYPE c LENGTH 200.
        DATA lv_fm TYPE string.

    lv_msgid = msgid.
    lv_msgno = msgno.
    lv_msgv1 = v1.
    lv_msgv2 = v2.
    lv_msgv3 = v3.
    lv_msgv4 = v4.

    TRY.
        
        lv_fm = `MESSAGE_TEXT_BUILD`.
        CALL FUNCTION lv_fm
          EXPORTING
            msgid               = lv_msgid
            msgnr               = lv_msgno
            msgv1               = lv_msgv1
            msgv2               = lv_msgv2
            msgv3               = lv_msgv3
            msgv4               = lv_msgv4
          IMPORTING
            message_text_output = lv_text.
        result = lv_text.
      CATCH cx_root.
        result = |{ lv_msgid } { lv_msgno }: { lv_msgv1 } { lv_msgv2 } { lv_msgv3 } { lv_msgv4 }|.
    ENDTRY.

  ENDMETHOD.

  METHOD mail_send.
      DATA lo_mail_c TYPE REF TO object.
      DATA lv_cls_c TYPE string.
    DATA lo_mail TYPE REF TO object.
    DATA lo_sender TYPE REF TO object.
    DATA lo_recipient TYPE REF TO object.
    DATA lo_doc TYPE REF TO object.
    DATA lr_body TYPE REF TO data.
    DATA lr_line TYPE REF TO data.
    DATA lv_class TYPE string.
    DATA lv_subject TYPE c LENGTH 50.
    DATA lv_type TYPE c LENGTH 3.
    DATA lv_address TYPE c LENGTH 241.
    FIELD-SYMBOLS <body> TYPE STANDARD TABLE.
    FIELD-SYMBOLS <line> TYPE any.
    FIELD-SYMBOLS <field> TYPE any.
    DATA temp504 LIKE lv_type.
        DATA lt_lines TYPE string_table.
        DATA lv_body_line LIKE LINE OF lt_lines.

    IF zabaputil_cl_util_context=>check_abap_cloud( ) IS NOT INITIAL.
      " Cloud: use CL_BCS_MAIL_MESSAGE (released cloud mail API)
      
      

      TRY.
          lv_cls_c = `CL_BCS_MAIL_MESSAGE`.
          CALL METHOD (lv_cls_c)=>(`CREATE_INSTANCE`)
            RECEIVING
              result = lo_mail_c.

          CALL METHOD lo_mail_c->(`SET_SENDER`)
            EXPORTING
              iv_address = zabaputil_cl_util_context=>context_get_user_tech( ) && `@placeholder.local`.

          CALL METHOD lo_mail_c->(`ADD_RECIPIENT`)
            EXPORTING
              iv_address = to.

          CALL METHOD lo_mail_c->(`SET_SUBJECT`)
            EXPORTING
              iv_subject = subject.

          IF html = abap_true.
            CALL METHOD lo_mail_c->(`SET_MAIN`)
              EXPORTING
                iv_content_type = `text/html`
                iv_content_text = body.
          ELSE.
            CALL METHOD lo_mail_c->(`SET_MAIN`)
              EXPORTING
                iv_content_type = `text/plain`
                iv_content_text = body.
          ENDIF.

          CALL METHOD lo_mail_c->(`SEND`)
            RECEIVING
              result = result.

        CATCH cx_root.
          result = abap_false.
      ENDTRY.
      RETURN.
    ENDIF.

    " Standard ABAP: use CL_BCS
    
    
    
    
    
    
    
    
    
    
    
    
    

    lv_subject = subject.
    lv_address = to.
    
    IF html = abap_true.
      temp504 = `HTM`.
    ELSE.
      temp504 = `RAW`.
    ENDIF.
    lv_type    = temp504.

    TRY.
        " Create BCS instance
        lv_class = `CL_BCS`.
        CALL METHOD (lv_class)=>(`CREATE_PERSISTENT`)
          RECEIVING
            result = lo_mail.

        " Sender
        lv_class = `CL_SAPUSER_BCS`.
        CALL METHOD (lv_class)=>(`CREATE`)
          EXPORTING
            i_user = sy-uname
          RECEIVING
            result = lo_sender.
        CALL METHOD lo_mail->(`SET_SENDER`)
          EXPORTING
            i_sender = lo_sender.

        " Recipient
        lv_class = `CL_CAM_ADDRESS_BCS`.
        CALL METHOD (lv_class)=>(`CREATE_INTERNET_ADDRESS`)
          EXPORTING
            i_address_string = lv_address
          RECEIVING
            result           = lo_recipient.
        CALL METHOD lo_mail->(`ADD_RECIPIENT`)
          EXPORTING
            i_recipient = lo_recipient.

        " Build body text table
        CREATE DATA lr_body TYPE (`BCSY_TEXT`).
        ASSIGN lr_body->* TO <body>.
        CREATE DATA lr_line TYPE (`SOLI`).
        ASSIGN lr_line->* TO <line>.

        
        lt_lines = zabaputil_cl_util_context=>c_split( val = body sep = zabaputil_cl_util_context=>cv_char_util_newline ).
        
        LOOP AT lt_lines INTO lv_body_line.
          ASSIGN COMPONENT `LINE` OF STRUCTURE <line> TO <field>.
          <field> = lv_body_line.
          INSERT <line> INTO TABLE <body>.
        ENDLOOP.

        " Create document
        lv_class = `CL_DOCUMENT_BCS`.
        CALL METHOD (lv_class)=>(`CREATE_DOCUMENT`)
          EXPORTING
            i_type    = lv_type
            i_text    = <body>
            i_subject = lv_subject
          RECEIVING
            result    = lo_doc.

        CALL METHOD lo_mail->(`SET_DOCUMENT`)
          EXPORTING
            i_document = lo_doc.
        CALL METHOD lo_mail->(`SET_SEND_IMMEDIATELY`)
          EXPORTING
            i_send_immediately = abap_true.

        CALL METHOD lo_mail->(`SEND`)
          RECEIVING
            result = result.
        COMMIT WORK AND WAIT.

      CATCH cx_root.
        result = abap_false.
    ENDTRY.

  ENDMETHOD.

  METHOD job_submit_report.
    DATA lv_fm TYPE string.
    DATA lv_jobname TYPE c LENGTH 32.
    DATA lv_jobcount TYPE c LENGTH 8.
    DATA lv_report TYPE c LENGTH 40.
    DATA lv_variant TYPE c LENGTH 14.
    DATA temp505 LIKE lv_jobname.
        DATA lx TYPE REF TO zabaputil_cx_util_error.
        DATA x TYPE REF TO cx_root.

    IF zabaputil_cl_util_context=>check_abap_cloud( ) IS NOT INITIAL.
      " Cloud: Application Jobs have a different architecture (job catalog + templates).
      " Direct report submission is not available. Raise informative exception.
      RAISE EXCEPTION TYPE zabaputil_cx_util_error
        EXPORTING
          val = `job_submit_report: On ABAP Cloud use CL_APJ_RT_API with a registered job catalog entry instead`.
    ENDIF.

    " Standard ABAP: JOB_OPEN / JOB_SUBMIT / JOB_CLOSE
    
    
    
    
    

    lv_report = report.
    lv_variant = variant.
    
    IF job_name IS NOT INITIAL.
      temp505 = job_name.
    ELSE.
      temp505 = |Z2UI5_{ sy-datum }{ sy-uzeit }|.
    ENDIF.
    lv_jobname = temp505.

    TRY.
        lv_fm = `JOB_OPEN`.
        CALL FUNCTION lv_fm
          EXPORTING
            jobname  = lv_jobname
          IMPORTING
            jobcount = lv_jobcount
          EXCEPTIONS
            OTHERS   = 1.
        IF sy-subrc <> 0.
          RAISE EXCEPTION TYPE zabaputil_cx_util_error
            EXPORTING
              val = `JOB_OPEN failed`.
        ENDIF.

        lv_fm = `JOB_SUBMIT`.
        CALL FUNCTION lv_fm
          EXPORTING
            authcknam = sy-uname
            jobcount  = lv_jobcount
            jobname   = lv_jobname
            report    = lv_report
            variant   = lv_variant
          EXCEPTIONS
            OTHERS    = 1.
        IF sy-subrc <> 0.
          RAISE EXCEPTION TYPE zabaputil_cx_util_error
            EXPORTING
              val = `JOB_SUBMIT failed`.
        ENDIF.

        lv_fm = `JOB_CLOSE`.
        IF start_immediate = abap_true.
          CALL FUNCTION lv_fm
            EXPORTING
              jobcount  = lv_jobcount
              jobname   = lv_jobname
              strtimmed = abap_true
            EXCEPTIONS
              OTHERS    = 1.
        ELSE.
          CALL FUNCTION lv_fm
            EXPORTING
              jobcount  = lv_jobcount
              jobname   = lv_jobname
            EXCEPTIONS
              OTHERS    = 1.
        ENDIF.
        IF sy-subrc <> 0.
          RAISE EXCEPTION TYPE zabaputil_cx_util_error
            EXPORTING
              val = `JOB_CLOSE failed`.
        ENDIF.

        result = lv_jobname.

        
      CATCH zabaputil_cx_util_error INTO lx.
        RAISE EXCEPTION lx.
        
      CATCH cx_root INTO x.
        RAISE EXCEPTION TYPE zabaputil_cx_util_error
          EXPORTING
            val = x.
    ENDTRY.

  ENDMETHOD.

  METHOD numrange_get_next.

    DATA lv_object  TYPE c LENGTH 10.
    DATA lv_nr_sub  TYPE c LENGTH 2.
    DATA lv_number  TYPE c LENGTH 20.
          DATA lv_cls TYPE string.
          DATA lv_fm TYPE string.
        DATA lx TYPE REF TO zabaputil_cx_util_error.
        DATA x TYPE REF TO cx_root.

    lv_object = object.
    lv_nr_sub = subobject.

    TRY.
        IF zabaputil_cl_util_context=>check_abap_cloud( ) IS NOT INITIAL.
          " Cloud: use CL_NUMBERRANGE_RUNTIME
          
          lv_cls = `CL_NUMBERRANGE_RUNTIME`.
          CALL METHOD (lv_cls)=>(`NUMBER_GET`)
            EXPORTING
              nr_range_nr = lv_nr_sub
              object      = lv_object
            IMPORTING
              number      = lv_number.
        ELSE.
          " Standard: use NUMBER_GET_NEXT FM
          
          lv_fm = `NUMBER_GET_NEXT`.
          CALL FUNCTION lv_fm
            EXPORTING
              nr_range_nr = lv_nr_sub
              object      = lv_object
            IMPORTING
              number      = lv_number
            EXCEPTIONS
              OTHERS      = 1.
          IF sy-subrc <> 0.
            RAISE EXCEPTION TYPE zabaputil_cx_util_error
              EXPORTING
                val = |NUMBER_GET_NEXT failed for { lv_object }/{ lv_nr_sub }|.
          ENDIF.
        ENDIF.

        result = lv_number.

        
      CATCH zabaputil_cx_util_error INTO lx.
        RAISE EXCEPTION lx.
        
      CATCH cx_root INTO x.
        RAISE EXCEPTION TYPE zabaputil_cx_util_error
          EXPORTING
            val = x.
    ENDTRY.

  ENDMETHOD.

  METHOD changdoc_read.
          DATA lv_cds TYPE string.
          DATA lv_where_c TYPE string.
          FIELD-SYMBOLS <cds_tab> TYPE STANDARD TABLE.
          FIELD-SYMBOLS <cds_row> TYPE any.
          FIELD-SYMBOLS <cds_fld> TYPE any.
          DATA lr_cds_tab TYPE REF TO data.
          DATA lt_comp_c TYPE abap_component_tab.
          DATA lo_struct_c TYPE REF TO cl_abap_structdescr.
          DATA lo_table_c TYPE REF TO cl_abap_tabledescr.
            DATA temp506 TYPE ty_s_changdoc.
            DATA ls_doc_c LIKE temp506.
    DATA lv_fm TYPE string.
    DATA lv_objectclas TYPE c LENGTH 15.
    DATA lv_objectid TYPE c LENGTH 90.
    DATA lr_headers TYPE REF TO data.
    DATA lr_positions TYPE REF TO data.
    FIELD-SYMBOLS <headers> TYPE STANDARD TABLE.
    FIELD-SYMBOLS <positions> TYPE STANDARD TABLE.
    FIELD-SYMBOLS <hdr> TYPE any.
    FIELD-SYMBOLS <pos> TYPE any.
    FIELD-SYMBOLS <comp> TYPE any.
          DATA temp507 TYPE ty_s_changdoc.
          DATA ls_doc LIKE temp507.
              DATA ls_pos LIKE ls_doc.

    IF zabaputil_cl_util_context=>check_abap_cloud( ) IS NOT INITIAL.
      " Cloud: use released CDS view I_ChangeDocument
      TRY.
          
          lv_cds = `I_CHANGEDOCUMENTITEM`.
          
          lv_where_c = |OBJECTCLASS = '{ objectclass }' AND OBJECTID = '{ objectid }'|.
          IF date_from IS NOT INITIAL.
            lv_where_c = |{ lv_where_c } AND CREATIONDATE >= '{ date_from }'|.
          ENDIF.
          IF date_to IS NOT INITIAL AND date_to <> '99991231'.
            lv_where_c = |{ lv_where_c } AND CREATIONDATE <= '{ date_to }'|.
          ENDIF.

          
          
          
          

          
          lt_comp_c = zabaputil_cl_util_context=>rtti_get_t_attri_by_table_name( lv_cds ).
          
          lo_struct_c = cl_abap_structdescr=>create( lt_comp_c ).
          
          lo_table_c = cl_abap_tabledescr=>create( lo_struct_c ).
          CREATE DATA lr_cds_tab TYPE HANDLE lo_table_c.
          ASSIGN lr_cds_tab->* TO <cds_tab>.

          SELECT *
            FROM (lv_cds) INTO CORRESPONDING FIELDS OF TABLE <cds_tab>
            WHERE (lv_where_c)
            .

          LOOP AT <cds_tab> ASSIGNING <cds_row>.
            
            CLEAR temp506.
            
            ls_doc_c = temp506.
            ASSIGN COMPONENT `CHANGEDOCOBJECTCLASS` OF STRUCTURE <cds_row> TO <cds_fld>.
            IF sy-subrc <> 0.
              ASSIGN COMPONENT `OBJECTCLASS` OF STRUCTURE <cds_row> TO <cds_fld>.
            ENDIF.
            ASSIGN COMPONENT `CHANGEDOCUMENT` OF STRUCTURE <cds_row> TO <cds_fld>.
            IF sy-subrc = 0. ls_doc_c-changenr = <cds_fld>. ENDIF.
            ASSIGN COMPONENT `CREATEDBYUSER` OF STRUCTURE <cds_row> TO <cds_fld>.
            IF sy-subrc = 0. ls_doc_c-username = <cds_fld>. ENDIF.
            ASSIGN COMPONENT `CREATIONDATE` OF STRUCTURE <cds_row> TO <cds_fld>.
            IF sy-subrc = 0. ls_doc_c-udate = <cds_fld>. ENDIF.
            ASSIGN COMPONENT `CREATIONTIME` OF STRUCTURE <cds_row> TO <cds_fld>.
            IF sy-subrc = 0. ls_doc_c-utime = <cds_fld>. ENDIF.
            ASSIGN COMPONENT `TRANSACTIONCODE` OF STRUCTURE <cds_row> TO <cds_fld>.
            IF sy-subrc = 0. ls_doc_c-tcode = <cds_fld>. ENDIF.
            ASSIGN COMPONENT `CHNGEDOCITEMFIELDNAME` OF STRUCTURE <cds_row> TO <cds_fld>.
            IF sy-subrc = 0. ls_doc_c-fieldname = <cds_fld>. ENDIF.
            ASSIGN COMPONENT `CHNGEDOCITEMNEWVALUE` OF STRUCTURE <cds_row> TO <cds_fld>.
            IF sy-subrc = 0. ls_doc_c-new_value = <cds_fld>. ENDIF.
            ASSIGN COMPONENT `CHNGEDOCITEMOLDVALUE` OF STRUCTURE <cds_row> TO <cds_fld>.
            IF sy-subrc = 0. ls_doc_c-old_value = <cds_fld>. ENDIF.
            ASSIGN COMPONENT `CHANGEDOCITEMTABLENAME` OF STRUCTURE <cds_row> TO <cds_fld>.
            IF sy-subrc = 0. ls_doc_c-tabname = <cds_fld>. ENDIF.
            ASSIGN COMPONENT `CHNGEDOCITEMCHNGIND` OF STRUCTURE <cds_row> TO <cds_fld>.
            IF sy-subrc = 0. ls_doc_c-chngind = <cds_fld>. ENDIF.
            INSERT ls_doc_c INTO TABLE result.
          ENDLOOP.

        CATCH cx_root ##NO_HANDLER.
      ENDTRY.
      RETURN.
    ENDIF.

    " Standard ABAP: use CHANGEDOCUMENT_READ_HEADERS/POSITIONS FMs
    
    
    
    
    
    
    
    
    
    

    lv_objectclas = objectclass.
    lv_objectid   = objectid.

    TRY.
        CREATE DATA lr_headers TYPE STANDARD TABLE OF (`CDHDR`).
        CREATE DATA lr_positions TYPE STANDARD TABLE OF (`CDPOS`).
        ASSIGN lr_headers->* TO <headers>.
        ASSIGN lr_positions->* TO <positions>.

        lv_fm = `CHANGEDOCUMENT_READ_HEADERS`.
        CALL FUNCTION lv_fm
          EXPORTING
            objectclass = lv_objectclas
            objectid    = lv_objectid
            date_of_change = date_from
          TABLES
            i_cdhdr     = <headers>
          EXCEPTIONS
            OTHERS      = 1.
        IF sy-subrc <> 0.
          RETURN.
        ENDIF.

        LOOP AT <headers> ASSIGNING <hdr>.

          
          CLEAR temp507.
          
          ls_doc = temp507.
          ASSIGN COMPONENT `CHANGENR` OF STRUCTURE <hdr> TO <comp>.
          IF sy-subrc = 0. ls_doc-changenr = <comp>. ENDIF.
          ASSIGN COMPONENT `USERNAME` OF STRUCTURE <hdr> TO <comp>.
          IF sy-subrc = 0. ls_doc-username = <comp>. ENDIF.
          ASSIGN COMPONENT `UDATE` OF STRUCTURE <hdr> TO <comp>.
          IF sy-subrc = 0. ls_doc-udate = <comp>. ENDIF.
          ASSIGN COMPONENT `UTIME` OF STRUCTURE <hdr> TO <comp>.
          IF sy-subrc = 0. ls_doc-utime = <comp>. ENDIF.
          ASSIGN COMPONENT `TCODE` OF STRUCTURE <hdr> TO <comp>.
          IF sy-subrc = 0. ls_doc-tcode = <comp>. ENDIF.

          " Read positions for this change number
          CLEAR <positions>.
          lv_fm = `CHANGEDOCUMENT_READ_POSITIONS`.
          CALL FUNCTION lv_fm
            EXPORTING
              changenumber = ls_doc-changenr
            TABLES
              editpos      = <positions>
            EXCEPTIONS
              OTHERS       = 1.

          IF <positions> IS INITIAL.
            INSERT ls_doc INTO TABLE result.
          ELSE.
            LOOP AT <positions> ASSIGNING <pos>.
              
              ls_pos = ls_doc.
              ASSIGN COMPONENT `FNAME` OF STRUCTURE <pos> TO <comp>.
              IF sy-subrc = 0. ls_pos-fieldname = <comp>. ENDIF.
              ASSIGN COMPONENT `VALUE_OLD` OF STRUCTURE <pos> TO <comp>.
              IF sy-subrc = 0. ls_pos-old_value = <comp>. ENDIF.
              ASSIGN COMPONENT `VALUE_NEW` OF STRUCTURE <pos> TO <comp>.
              IF sy-subrc = 0. ls_pos-new_value = <comp>. ENDIF.
              ASSIGN COMPONENT `TABNAME` OF STRUCTURE <pos> TO <comp>.
              IF sy-subrc = 0. ls_pos-tabname = <comp>. ENDIF.
              ASSIGN COMPONENT `CHNGIND` OF STRUCTURE <pos> TO <comp>.
              IF sy-subrc = 0. ls_pos-chngind = <comp>. ENDIF.
              INSERT ls_pos INTO TABLE result.
            ENDLOOP.
          ENDIF.

        ENDLOOP.

      CATCH cx_root ##NO_HANDLER.
    ENDTRY.

  ENDMETHOD.

  METHOD source_get_method.

    DATA object TYPE REF TO object.
    FIELD-SYMBOLS <any> TYPE any.
    DATA lt_source       TYPE string_table.
    DATA lt_string       TYPE string_table.
    DATA lv_class        TYPE string.
    DATA lv_method       TYPE string.
    DATA xco_cp_abap     TYPE c LENGTH 11.
    DATA lv_name         TYPE c LENGTH 13.
    DATA lv_check_method LIKE abap_false.
    DATA lv_source       LIKE LINE OF lt_source.
    DATA lv_source_upper TYPE string.

    TRY.

        lv_class  = to_upper( iv_classname ).
        lv_method = to_upper( iv_methodname ).

        xco_cp_abap = `XCO_CP_ABAP`.
        CALL METHOD (xco_cp_abap)=>(`CLASS`)
          EXPORTING
            iv_name  = lv_class
          RECEIVING
            ro_class = object.

        ASSIGN object->(`IF_XCO_AO_CLASS~IMPLEMENTATION`) TO <any>.
        ASSERT sy-subrc = 0.
        object = <any>.

        CALL METHOD object->(`IF_XCO_CLAS_IMPLEMENTATION~METHOD`)
          EXPORTING
            iv_name   = lv_method
          RECEIVING
            ro_method = object.

        CALL METHOD object->(`IF_XCO_CLAS_I_METHOD~CONTENT`)
          RECEIVING
            ro_content = object.

        CALL METHOD object->(`IF_XCO_CLAS_I_METHOD_CONTENT~GET_SOURCE`)
          RECEIVING
            rt_source = result.

      CATCH cx_root.

        lv_name = `CL_OO_FACTORY`.
        CALL METHOD (lv_name)=>(`CREATE_INSTANCE`)
          RECEIVING
            result = object.

        CALL METHOD object->(`IF_OO_CLIF_SOURCE_FACTORY~CREATE_CLIF_SOURCE`)
          EXPORTING
            clif_name = lv_class
          RECEIVING
            result    = object.

        CALL METHOD object->(`IF_OO_CLIF_SOURCE~GET_SOURCE`)
          IMPORTING
            source = lt_source.

        lv_check_method = abap_false.

        LOOP AT lt_source INTO lv_source.

          lv_source_upper = to_upper( lv_source ).

          IF lv_source_upper CS `ENDMETHOD`.
            lv_check_method = abap_false.
          ENDIF.

          IF lv_source_upper CS |METHOD { lv_method }|.
            lv_check_method = abap_true.
            CONTINUE.
          ENDIF.

          IF lv_check_method = abap_true.
            INSERT lv_source INTO TABLE lt_string.
          ENDIF.

        ENDLOOP.

        result = lt_string.

    ENDTRY.

  ENDMETHOD.

  METHOD source_get_method2.

    DATA lt_source TYPE string_table.
    lt_source = source_get_method( iv_classname  = iv_classname
                                         iv_methodname = iv_methodname ).

    result = source_method_to_file( lt_source ).

  ENDMETHOD.

  METHOD source_get_file_types.

    DATA lv_types TYPE string.
    lv_types = |abap, abc, actionscript, ada, apache_conf, applescript, asciidoc, assembly_x86, autohotkey, batchfile, bro, c9search, c_cpp, cirru, clojure, cobol, coffee, coldfusion, csharp, css, curly, d, dart, diff, django, dockerfile, | &&
|dot, drools, eiffel, yaml, ejs, elixir, elm, erlang, forth, fortran, ftl, gcode, gherkin, gitignore, glsl, gobstones, golang, groovy, haml, handlebars, haskell, haskell_cabal, haxe, hjson, html, html_elixir, html_ruby, ini, io, jack, jade, java, ja| &&
      |vascri| &&
|pt, json, jsoniq, jsp, jsx, julia, kotlin, latex, lean, less, liquid, lisp, live_script, livescript, logiql, lsl, lua, luapage, lucene, makefile, markdown, mask, matlab, mavens_mate_log, maze, mel, mips_assembler, mipsassembler, mushcode, mysql, ni| &&
|x, nsis, objectivec, ocaml, pascal, perl, pgsql, php, plain_text, powershell, praat, prolog, properties, protobuf, python, r, razor, rdoc, rhtml, rst, ruby, rust, sass, scad, scala, scheme, scss, sh, sjs, smarty, snippets, soy_template, space, sql,| &&
      | sqlserver, stylus, svg, swift, swig, tcl, tex, text, textile, toml, tsx, twig, typescript, vala, vbscript, velocity, verilog, vhdl, wollok, xml, xquery, terraform, slim, redshift, red, puppet, php_laravel_blade, mixal, jssm, fsharp, edifact,| &&
      | csp, cssound_score, cssound_orchestra, cssound_document| ##NO_TEXT.
    SPLIT lv_types AT `,` INTO TABLE result.

  ENDMETHOD.

  METHOD source_method_to_file.

    DATA lv_source LIKE LINE OF it_source.
    LOOP AT it_source INTO lv_source.
      IF strlen( lv_source ) > 1.
        result = result && lv_source+1 && zabaputil_cl_util_context=>cv_char_util_newline.
      ELSE.
        result = result && zabaputil_cl_util_context=>cv_char_util_newline.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD lock_call_function.

    DATA lt_param      TYPE abap_func_parmbind_tab.
    DATA ls_param      TYPE abap_func_parmbind.
    DATA ls_lock_param TYPE ty_s_lock_param.
    DATA lr_value      TYPE REF TO string.
    DATA lt_exception  TYPE abap_func_excpbind_tab.
    DATA ls_exception  TYPE abap_func_excpbind.
    DATA lv_function   TYPE string.
        DATA temp20 TYPE xsdboolean.

    TRY.
        LOOP AT t_param INTO ls_lock_param.
          ls_param-name = ls_lock_param-name.
          ls_param-kind = abap_func_exporting.
          CREATE DATA lr_value.
          lr_value->* = ls_lock_param-value.
          ls_param-value = lr_value.
          INSERT ls_param INTO TABLE lt_param.
        ENDLOOP.

        ls_exception-name  = `OTHERS`.
        ls_exception-value = 4.
        INSERT ls_exception INTO TABLE lt_exception.

        lv_function = zabaputil_cl_util_context=>c_trim_upper( val ).
        CALL FUNCTION lv_function
          PARAMETER-TABLE lt_param
          EXCEPTION-TABLE lt_exception.

        
        temp20 = boolc( sy-subrc = 0 ).
        result = temp20.

      CATCH cx_root.
        result = abap_false.
    ENDTRY.

  ENDMETHOD.

  METHOD cal_get_weekday.

    " 1900-01-01 was a Monday, so the day distance modulo 7 yields the weekday
    DATA temp508 TYPE d.
    DATA lv_days TYPE d.
    temp508 = `19000101`.
    
    lv_days = date - temp508.
    result = lv_days MOD 7 + 1.

  ENDMETHOD.

  METHOD cal_is_weekend.

    DATA temp21 TYPE xsdboolean.
    temp21 = boolc( cal_get_weekday( date ) >= 6 ).
    result = temp21.

  ENDMETHOD.

  METHOD cal_is_workday.
    DATA temp22 TYPE xsdboolean.

    IF calendar_id IS NOT INITIAL.
      zabaputil_cl_util_context=>x_raise( `cal_is_workday: factory calendar support is not yet implemented` ).
    ENDIF.

    
    temp22 = boolc( cal_is_weekend( date ) = abap_false ).
    result = temp22.

  ENDMETHOD.

  METHOD cal_add_workdays.

    DATA lv_remaining TYPE i.
    DATA temp509 TYPE i.
    DATA lv_step LIKE temp509.
    lv_remaining = abs( days ).
    
    IF days < 0.
      temp509 = -1.
    ELSE.
      temp509 = 1.
    ENDIF.
    
    lv_step = temp509.

    result = date.
    WHILE lv_remaining > 0.
      result = result + lv_step.
      IF cal_is_workday( date = result calendar_id = calendar_id ) = abap_true.
        lv_remaining = lv_remaining - 1.
      ENDIF.
    ENDWHILE.

  ENDMETHOD.

  METHOD cal_count_workdays.

    DATA lv_date LIKE date_from.
    DATA temp510 TYPE i.
    DATA lv_step LIKE temp510.
    lv_date = date_from.
    
    IF date_to < date_from.
      temp510 = -1.
    ELSE.
      temp510 = 1.
    ENDIF.
    
    lv_step = temp510.

    WHILE lv_date <> date_to.
      lv_date = lv_date + lv_step.
      IF cal_is_workday( date = lv_date calendar_id = calendar_id ) = abap_true.
        result = result + 1.
      ENDIF.
    ENDWHILE.

  ENDMETHOD.

  METHOD conv_get_xlsx_by_itab.

*    DATA(write_access) = xco_cp_xlsx=>document->empty( )->write_access( ).
*    DATA(worksheet) = write_access->get_workbook( )->worksheet->at_position( 1 ).
*    DATA(selection_pattern) = xco_cp_xlsx_selection=>pattern_builder->simple_from_to( )->get_pattern( ).
*    worksheet->select( selection_pattern
*               )->row_stream(
*               )->operation->write_from( REF #( val )
*               )->execute( ).
*    result = write_access->get_file_content( ).

  ENDMETHOD.

  METHOD conv_get_itab_by_xlsx.

*    CLEAR result.
*    DATA(document) = xco_cp_xlsx=>document->for_file_content( val )->read_access( ).
*    DATA(sheet) = document->get_workbook( )->worksheet->at_position( 1 ).
*    DATA(pattern) = xco_cp_xlsx_selection=>pattern_builder->simple_from_to( )->get_pattern( ).
*    sheet->select( pattern
*            )->row_stream(
*            )->operation->write_to( REF #( result )
*            )->set_value_transformation( xco_cp_xlsx_read_access=>value_transformation->string_value
*            )->execute( ).

  ENDMETHOD.

  METHOD zip_pack.

    DATA lo_zip TYPE REF TO object.
        DATA ls_file LIKE LINE OF files.
        DATA x TYPE REF TO cx_root.

    TRY.

        CREATE OBJECT lo_zip TYPE ('CL_ABAP_ZIP').
        
        LOOP AT files INTO ls_file.
          CALL METHOD lo_zip->('ADD')
            EXPORTING
              name    = ls_file-name
              content = ls_file-content.
        ENDLOOP.
        CALL METHOD lo_zip->('SAVE')
          RECEIVING
            zip = result.

        
      CATCH cx_root INTO x.
        RAISE EXCEPTION TYPE zabaputil_cx_util_error EXPORTING val = x.
    ENDTRY.

  ENDMETHOD.

  METHOD zip_unpack.

    DATA lo_zip    TYPE REF TO object.
    DATA lv_name   TYPE string.
    DATA ls_result LIKE LINE OF result.

    FIELD-SYMBOLS <files> TYPE ANY TABLE.
    FIELD-SYMBOLS <file>  TYPE any.
    FIELD-SYMBOLS <name>  TYPE any.
        DATA x TYPE REF TO cx_root.

    TRY.

        CREATE OBJECT lo_zip TYPE ('CL_ABAP_ZIP').
        CALL METHOD lo_zip->('LOAD')
          EXPORTING
            zip = val.

        ASSIGN lo_zip->('FILES') TO <files>.
        LOOP AT <files> ASSIGNING <file>.
          ASSIGN COMPONENT `NAME` OF STRUCTURE <file> TO <name>.
          lv_name = <name>.

          CLEAR ls_result.
          ls_result-name = lv_name.
          CALL METHOD lo_zip->('GET')
            EXPORTING
              name    = lv_name
            IMPORTING
              content = ls_result-content.
          INSERT ls_result INTO TABLE result.
        ENDLOOP.

        
      CATCH cx_root INTO x.
        RAISE EXCEPTION TYPE zabaputil_cx_util_error EXPORTING val = x.
    ENDTRY.

  ENDMETHOD.

  METHOD c_escape_html.

    result = val.
    REPLACE ALL OCCURRENCES OF `&` IN result WITH `&amp;`.
    REPLACE ALL OCCURRENCES OF `<` IN result WITH `&lt;`.
    REPLACE ALL OCCURRENCES OF `>` IN result WITH `&gt;`.
    REPLACE ALL OCCURRENCES OF `"` IN result WITH `&quot;`.
    REPLACE ALL OCCURRENCES OF `'` IN result WITH `&#39;`.

  ENDMETHOD.

  METHOD c_escape_json.

    DATA lv_cr TYPE c LENGTH 1.
    lv_cr = cv_char_util_cr_lf(1).

    result = val.
    REPLACE ALL OCCURRENCES OF `\` IN result WITH `\\`.
    REPLACE ALL OCCURRENCES OF `"` IN result WITH `\"`.
    REPLACE ALL OCCURRENCES OF lv_cr IN result WITH `\r`.
    REPLACE ALL OCCURRENCES OF cv_char_util_newline IN result WITH `\n`.
    REPLACE ALL OCCURRENCES OF cv_char_util_horizontal_tab IN result WITH `\t`.

  ENDMETHOD.

  METHOD c_levenshtein.

    TYPES ty_t_int TYPE STANDARD TABLE OF i WITH DEFAULT KEY.

    DATA temp511 TYPE string.
    DATA lv_a LIKE temp511.
    DATA temp512 TYPE string.
    DATA lv_b LIKE temp512.
    DATA lv_la TYPE i.
    DATA lv_lb TYPE i.
    DATA lt_prev TYPE ty_t_int.
    DATA lt_curr TYPE ty_t_int.
    DATA lv_j TYPE i.
    DATA lv_i TYPE i.
      DATA temp513 LIKE LINE OF lt_curr.
        DATA temp514 TYPE i.
        DATA lv_cost LIKE temp514.
        DATA lv_min TYPE i.
        DATA temp77 LIKE LINE OF lt_curr.
        DATA temp78 LIKE sy-tabix.
        DATA lv_del TYPE i.
        DATA temp79 LIKE LINE OF lt_prev.
        DATA temp80 LIKE sy-tabix.
        DATA lv_sub TYPE i.
        DATA temp81 LIKE LINE OF lt_prev.
        DATA temp82 LIKE sy-tabix.
    DATA temp515 LIKE LINE OF lt_prev.
    DATA temp516 LIKE sy-tabix.
    temp511 = val1.
    
    lv_a = temp511.
    
    temp512 = val2.
    
    lv_b = temp512.
    
    lv_la = strlen( lv_a ).
    
    lv_lb = strlen( lv_b ).

    IF lv_la = 0.
      result = lv_lb.
      RETURN.
    ENDIF.
    IF lv_lb = 0.
      result = lv_la.
      RETURN.
    ENDIF.

    
    
    

    WHILE lv_j <= lv_lb.
      APPEND lv_j TO lt_prev.
      lv_j = lv_j + 1.
    ENDWHILE.

    
    WHILE lv_i < lv_la.

      CLEAR lt_curr.
      
      temp513 = lv_i + 1.
      APPEND temp513 TO lt_curr.

      lv_j = 0.
      WHILE lv_j < lv_lb.

        
        IF lv_a+lv_i(1) = lv_b+lv_j(1).
          temp514 = 0.
        ELSE.
          temp514 = 1.
        ENDIF.
        
        lv_cost = temp514.
        
        
        
        temp78 = sy-tabix.
        READ TABLE lt_curr INDEX lv_j + 1 INTO temp77.
        sy-tabix = temp78.
        IF sy-subrc <> 0.
          ASSERT 1 = 0.
        ENDIF.
        lv_min = temp77 + 1.
        
        
        
        temp80 = sy-tabix.
        READ TABLE lt_prev INDEX lv_j + 2 INTO temp79.
        sy-tabix = temp80.
        IF sy-subrc <> 0.
          ASSERT 1 = 0.
        ENDIF.
        lv_del = temp79 + 1.
        IF lv_del < lv_min.
          lv_min = lv_del.
        ENDIF.
        
        
        
        temp82 = sy-tabix.
        READ TABLE lt_prev INDEX lv_j + 1 INTO temp81.
        sy-tabix = temp82.
        IF sy-subrc <> 0.
          ASSERT 1 = 0.
        ENDIF.
        lv_sub = temp81 + lv_cost.
        IF lv_sub < lv_min.
          lv_min = lv_sub.
        ENDIF.
        APPEND lv_min TO lt_curr.

        lv_j = lv_j + 1.
      ENDWHILE.

      lt_prev = lt_curr.
      lv_i = lv_i + 1.
    ENDWHILE.

    
    
    temp516 = sy-tabix.
    READ TABLE lt_prev INDEX lv_lb + 1 INTO temp515.
    sy-tabix = temp516.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    result = temp515.

  ENDMETHOD.

  METHOD url_encode.

    CONSTANTS lc_unreserved TYPE string VALUE `ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_.~`.

    DATA temp517 TYPE string.
    DATA lv_val LIKE temp517.
    DATA lv_len TYPE i.
    DATA lv_i TYPE i.
      DATA lv_char TYPE string.
        DATA lv_x TYPE xstring.
        DATA lv_j TYPE i.
          DATA lv_hex TYPE c LENGTH 2.
    temp517 = val.
    
    lv_val = temp517.
    
    lv_len = strlen( lv_val ).
    

    WHILE lv_i < lv_len.

      
      lv_char = substring( val = lv_val
                                 off = lv_i
                                 len = 1 ).

      IF lv_char <> ` ` AND lv_char CO lc_unreserved.
        result = result && lv_char.
      ELSE.
        
        lv_x = conv_get_xstring_by_string( lv_char ).
        
        lv_j = 0.
        WHILE lv_j < xstrlen( lv_x ).
          
          lv_hex = lv_x+lv_j(1).
          result = result && `%` && lv_hex.
          lv_j = lv_j + 1.
        ENDWHILE.
      ENDIF.

      lv_i = lv_i + 1.
    ENDWHILE.

  ENDMETHOD.

  METHOD url_decode.

    DATA temp518 TYPE string.
    DATA lv_val LIKE temp518.
    DATA lv_len TYPE i.
    DATA lv_i TYPE i.
    DATA lv_xbuf TYPE xstring.
      DATA lv_char TYPE string.
        DATA lv_x TYPE x LENGTH 1.
    temp518 = val.
    
    lv_val = temp518.
    
    lv_len = strlen( lv_val ).
    
    

    WHILE lv_i < lv_len.

      
      lv_char = substring( val = lv_val
                                 off = lv_i
                                 len = 1 ).

      IF lv_char = `%` AND lv_i + 2 < lv_len.
        
        lv_x = to_upper( substring( val = lv_val
                                    off = lv_i + 1
                                    len = 2 ) ).
        CONCATENATE lv_xbuf lv_x INTO lv_xbuf IN BYTE MODE.
        lv_i = lv_i + 3.
        CONTINUE.
      ENDIF.

      IF lv_xbuf IS NOT INITIAL.
        result = result && conv_get_string_by_xstring( lv_xbuf ).
        CLEAR lv_xbuf.
      ENDIF.

      IF lv_char = `+`.
        result = result && ` `.
      ELSE.
        result = result && lv_char.
      ENDIF.

      lv_i = lv_i + 1.
    ENDWHILE.

    IF lv_xbuf IS NOT INITIAL.
      result = result && conv_get_string_by_xstring( lv_xbuf ).
    ENDIF.

  ENDMETHOD.

  METHOD regex_create_matcher.

    DATA lo_regex TYPE REF TO object.
    DATA lv_class TYPE string.

    IF check_abap_cloud( ) = abap_true.

      lv_class = `CL_ABAP_REGEX`.
      CALL METHOD (lv_class)=>create_pcre
        EXPORTING
          pattern = regex
        RECEIVING
          regex   = lo_regex.

      CALL METHOD lo_regex->(`CREATE_MATCHER`)
        EXPORTING
          text    = val
        RECEIVING
          matcher = result.

    ELSE.

      lv_class = `CL_ABAP_MATCHER`.
      CALL METHOD (lv_class)=>create
        EXPORTING
          pattern = regex
          text    = val
        RECEIVING
          matcher = result.

    ENDIF.

  ENDMETHOD.

  METHOD regex_match.

    DATA lo_matcher TYPE REF TO object.
    lo_matcher = regex_create_matcher( val   = val
                                             regex = regex ).

    CALL METHOD lo_matcher->(`MATCH`)
      RECEIVING
        success = result.

  ENDMETHOD.

  METHOD regex_find_all.

    DATA lv_success TYPE abap_bool.
    DATA lv_off     TYPE i.
    DATA lv_len     TYPE i.

    DATA temp519 TYPE string.
    DATA lv_val LIKE temp519.
    DATA lo_matcher TYPE REF TO object.
    temp519 = val.
    
    lv_val = temp519.
    
    lo_matcher = regex_create_matcher( val   = lv_val
                                             regex = regex ).

    DO.
      CALL METHOD lo_matcher->(`FIND_NEXT`)
        RECEIVING
          success = lv_success.
      IF lv_success = abap_false.
        EXIT.
      ENDIF.

      CALL METHOD lo_matcher->(`GET_OFFSET`)
        RECEIVING
          offset = lv_off.
      CALL METHOD lo_matcher->(`GET_LENGTH`)
        RECEIVING
          length = lv_len.

      IF lv_len = 0.
        EXIT.
      ENDIF.

      APPEND substring( val = lv_val
                        off = lv_off
                        len = lv_len ) TO result.
    ENDDO.

  ENDMETHOD.

  METHOD regex_replace_all.

    DATA lv_success TYPE abap_bool.
    DATA lv_off     TYPE i.
    DATA lv_len     TYPE i.
    DATA lv_pos     TYPE i.

    DATA temp520 TYPE string.
    DATA lv_val LIKE temp520.
    DATA lo_matcher TYPE REF TO object.
    temp520 = val.
    
    lv_val = temp520.
    
    lo_matcher = regex_create_matcher( val   = lv_val
                                             regex = regex ).

    DO.
      CALL METHOD lo_matcher->(`FIND_NEXT`)
        RECEIVING
          success = lv_success.
      IF lv_success = abap_false.
        EXIT.
      ENDIF.

      CALL METHOD lo_matcher->(`GET_OFFSET`)
        RECEIVING
          offset = lv_off.
      CALL METHOD lo_matcher->(`GET_LENGTH`)
        RECEIVING
          length = lv_len.

      IF lv_len = 0.
        EXIT.
      ENDIF.

      result = result && substring( val = lv_val
                                    off = lv_pos
                                    len = lv_off - lv_pos ) && new_val.
      lv_pos = lv_off + lv_len.
    ENDDO.

    result = result && substring( val = lv_val
                                  off = lv_pos ).

  ENDMETHOD.

  METHOD uuid_get_c36.

    result = uuid_conv_c32_to_c36( uuid_get_c32( ) ).

  ENDMETHOD.

  METHOD uuid_conv_c32_to_c36.

    DATA lv_c32 TYPE string.
    lv_c32 = to_upper( c_trim( val ) ).

    IF strlen( lv_c32 ) <> 32.
      x_raise( `INVALID_UUID_C32` ).
    ENDIF.

    result = lv_c32(8) && `-` && lv_c32+8(4) && `-` && lv_c32+12(4) && `-` && lv_c32+16(4) && `-` && lv_c32+20(12).

  ENDMETHOD.

  METHOD uuid_conv_c36_to_c32.

    result = to_upper( c_trim( val ) ).
    REPLACE ALL OCCURRENCES OF `-` IN result WITH ``.

    IF strlen( result ) <> 32.
      x_raise( `INVALID_UUID_C36` ).
    ENDIF.

  ENDMETHOD.

  METHOD uuid_conv_c32_to_c22.

    CONSTANTS lc_b64 TYPE string VALUE `ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_`.

    DATA lv_c32 TYPE string.
    DATA lv_x TYPE xstring.
    DATA lv_i TYPE i.
    DATA lv_xlen TYPE i.
      DATA temp521 TYPE i.
      DATA lv_b1 LIKE temp521.
      DATA lv_b2 TYPE i.
      DATA lv_b3 TYPE i.
        DATA lv_i2 TYPE i.
        DATA temp522 TYPE i.
      DATA lv_n TYPE i.
    lv_c32 = to_upper( c_trim( val ) ).

    IF strlen( lv_c32 ) <> 32.
      x_raise( `INVALID_UUID_C32` ).
    ENDIF.

    
    lv_x = lv_c32.

    
    
    lv_xlen = xstrlen( lv_x ).

    WHILE lv_i < lv_xlen.

      
      temp521 = lv_x+lv_i(1).
      
      lv_b1 = temp521.
      
      
      lv_b2 = -1.
      lv_b3 = -1.
      IF lv_i + 1 < lv_xlen.
        lv_b2 = lv_x+lv_i(2) MOD 256.
      ENDIF.
      IF lv_i + 2 < lv_xlen.
        
        lv_i2 = lv_i + 2.
        
        temp522 = lv_x+lv_i2(1).
        lv_b3 = temp522.
      ENDIF.

      
      lv_n = lv_b1 * 65536.
      IF lv_b2 >= 0.
        lv_n = lv_n + lv_b2 * 256.
      ENDIF.
      IF lv_b3 >= 0.
        lv_n = lv_n + lv_b3.
      ENDIF.

      result = result && substring( val = lc_b64
                                    off = lv_n DIV 262144
                                    len = 1 )
                      && substring( val = lc_b64
                                    off = ( lv_n DIV 4096 ) MOD 64
                                    len = 1 ).
      IF lv_b2 >= 0.
        result = result && substring( val = lc_b64
                                      off = ( lv_n DIV 64 ) MOD 64
                                      len = 1 ).
      ENDIF.
      IF lv_b3 >= 0.
        result = result && substring( val = lc_b64
                                      off = lv_n MOD 64
                                      len = 1 ).
      ENDIF.

      lv_i = lv_i + 3.
    ENDWHILE.

  ENDMETHOD.

  METHOD uuid_conv_c22_to_c32.

    CONSTANTS lc_b64 TYPE string VALUE `ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_`.

    DATA lv_c22 TYPE string.
    DATA lv_x TYPE xstring.
    DATA lv_xb TYPE x LENGTH 1.
    DATA lv_i TYPE i.
    DATA lv_len TYPE i.
      DATA lv_take TYPE i.
      DATA lv_n TYPE i.
      DATA lv_k TYPE i.
        DATA lv_pos TYPE i.
        DATA lv_char TYPE string.
        DATA lv_idx TYPE i.
    DATA lv_c TYPE c LENGTH 32.
    lv_c22 = c_trim( val ).
    REPLACE ALL OCCURRENCES OF `+` IN lv_c22 WITH `-`.
    REPLACE ALL OCCURRENCES OF `/` IN lv_c22 WITH `_`.

    IF strlen( lv_c22 ) <> 22.
      x_raise( `INVALID_UUID_C22` ).
    ENDIF.

    
    
    
    
    lv_len = strlen( lv_c22 ).

    WHILE lv_i < lv_len.

      
      lv_take = lv_len - lv_i.
      IF lv_take > 4.
        lv_take = 4.
      ENDIF.

      
      
      lv_n = 0.
      lv_k = 0.
      WHILE lv_k < lv_take.
        
        lv_pos = lv_i + lv_k.
        
        lv_char = substring( val = lv_c22
                                   off = lv_pos
                                   len = 1 ).
        
        FIND lv_char IN lc_b64 MATCH OFFSET lv_idx.
        IF sy-subrc <> 0.
          x_raise( `INVALID_UUID_C22` ).
        ENDIF.
        lv_n = lv_n * 64 + lv_idx.
        lv_k = lv_k + 1.
      ENDWHILE.

      CASE lv_take.
        WHEN 4.
          lv_xb = lv_n DIV 65536.
          CONCATENATE lv_x lv_xb INTO lv_x IN BYTE MODE.
          lv_xb = ( lv_n DIV 256 ) MOD 256.
          CONCATENATE lv_x lv_xb INTO lv_x IN BYTE MODE.
          lv_xb = lv_n MOD 256.
          CONCATENATE lv_x lv_xb INTO lv_x IN BYTE MODE.
        WHEN 3.
          lv_xb = lv_n DIV 1024.
          CONCATENATE lv_x lv_xb INTO lv_x IN BYTE MODE.
          lv_xb = ( lv_n DIV 4 ) MOD 256.
          CONCATENATE lv_x lv_xb INTO lv_x IN BYTE MODE.
        WHEN 2.
          lv_xb = lv_n DIV 16.
          CONCATENATE lv_x lv_xb INTO lv_x IN BYTE MODE.
      ENDCASE.

      lv_i = lv_i + lv_take.
    ENDWHILE.

    IF xstrlen( lv_x ) <> 16.
      x_raise( `INVALID_UUID_C22` ).
    ENDIF.

    
    lv_c = lv_x.
    result = lv_c.

  ENDMETHOD.

  METHOD itab_sum_by.

    FIELD-SYMBOLS <row> TYPE any.
    DATA lv_fieldname TYPE string.
      FIELD-SYMBOLS <val> TYPE any.
    lv_fieldname = to_upper( fieldname ).

    LOOP AT tab ASSIGNING <row>.
      
      ASSIGN COMPONENT lv_fieldname OF STRUCTURE <row> TO <val>.
      IF sy-subrc = 0.
        result = result + <val>.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD itab_distinct.

    FIELD-SYMBOLS <row> TYPE any.
    DATA lv_fieldname TYPE string.
      FIELD-SYMBOLS <val> TYPE any.
      DATA temp523 TYPE string.
      DATA lv_str LIKE temp523.
    lv_fieldname = to_upper( fieldname ).

    LOOP AT tab ASSIGNING <row>.
      
      ASSIGN COMPONENT lv_fieldname OF STRUCTURE <row> TO <val>.
      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.
      
      temp523 = <val>.
      
      lv_str = temp523.
      READ TABLE result WITH KEY table_line = lv_str TRANSPORTING NO FIELDS.
      IF sy-subrc <> 0.
        APPEND lv_str TO result.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD itab_group_sum_by.

    TYPES:
      BEGIN OF ty_s_sum,
        n   TYPE string,
        sum TYPE decfloat34,
      END OF ty_s_sum.

    TYPES temp18 TYPE STANDARD TABLE OF ty_s_sum WITH DEFAULT KEY.
DATA lt_sum TYPE temp18.
    FIELD-SYMBOLS <row> TYPE any.

    DATA lv_group_by TYPE string.
    DATA lv_sum_by TYPE string.
      FIELD-SYMBOLS <group> TYPE any.
      FIELD-SYMBOLS <val> TYPE any.
      DATA temp524 TYPE string.
      DATA lv_group LIKE temp524.
      FIELD-SYMBOLS <sum> TYPE ty_s_sum.
        DATA temp525 TYPE ty_s_sum.
      DATA temp526 TYPE zabaputil_cl_util_context=>ty_s_name_value.
    lv_group_by = to_upper( group_by ).
    
    lv_sum_by = to_upper( sum_by ).

    LOOP AT tab ASSIGNING <row>.

      
      ASSIGN COMPONENT lv_group_by OF STRUCTURE <row> TO <group>.
      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.
      
      ASSIGN COMPONENT lv_sum_by OF STRUCTURE <row> TO <val>.
      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.

      
      temp524 = <group>.
      
      lv_group = temp524.
      
      READ TABLE lt_sum ASSIGNING <sum> WITH KEY n = lv_group.
      IF sy-subrc <> 0.
        
        CLEAR temp525.
        temp525-n = lv_group.
        APPEND temp525 TO lt_sum ASSIGNING <sum>.
      ENDIF.
      <sum>-sum = <sum>-sum + <val>.

    ENDLOOP.

    LOOP AT lt_sum ASSIGNING <sum>.
      
      CLEAR temp526.
      temp526-n = <sum>-n.
      temp526-v = |{ <sum>-sum }|.
      APPEND temp526 TO result.
    ENDLOOP.

  ENDMETHOD.

  METHOD num_round.

    DATA lv_factor TYPE decfloat34 VALUE 1.
    DATA lv_sign TYPE decfloat34 VALUE 1.
    DATA lv_abs TYPE decfloat34.
    DATA lv_rounded TYPE decfloat34.
    DATA lv_half TYPE decfloat34 VALUE '0.5'.
    DATA temp527 TYPE string.
    DATA lv_mode TYPE string.

    DO decimals TIMES.
      lv_factor = lv_factor * 10.
    ENDDO.

    
    IF val < 0.
      lv_sign = -1.
    ENDIF.

    
    lv_abs = val * lv_sign * lv_factor.
    
    
    
    temp527 = mode.
    
    lv_mode = to_upper( temp527 ).

    lv_rounded = trunc( lv_abs ).

    CASE lv_mode.
      WHEN `UP`.
        IF frac( lv_abs ) > 0.
          lv_rounded = lv_rounded + 1.
        ENDIF.
      WHEN `DOWN`.
        " truncation is already rounding toward zero
      WHEN OTHERS.
        IF frac( lv_abs ) >= lv_half.
          lv_rounded = lv_rounded + 1.
        ENDIF.
    ENDCASE.

    result = lv_rounded * lv_sign / lv_factor.

  ENDMETHOD.

  METHOD file_get_mimetype.

    DATA lv_name TYPE string.
    TYPES temp19 TYPE STANDARD TABLE OF string WITH DEFAULT KEY.
DATA lt_parts TYPE temp19.
    DATA lv_ext LIKE LINE OF lt_parts.
    DATA temp83 LIKE LINE OF lt_parts.
    DATA temp84 LIKE sy-tabix.
    lv_name = to_lower( c_trim( val ) ).
    

    SPLIT lv_name AT `.` INTO TABLE lt_parts.
    
    
    
    temp84 = sy-tabix.
    READ TABLE lt_parts INDEX lines( lt_parts ) INTO temp83.
    sy-tabix = temp84.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    lv_ext = temp83.

    CASE lv_ext.
      WHEN `txt` OR `text` OR `log` OR `md`.
        result = `text/plain`.
      WHEN `html` OR `htm`.
        result = `text/html`.
      WHEN `css`.
        result = `text/css`.
      WHEN `csv`.
        result = `text/csv`.
      WHEN `js` OR `mjs`.
        result = `text/javascript`.
      WHEN `json`.
        result = `application/json`.
      WHEN `xml`.
        result = `application/xml`.
      WHEN `pdf`.
        result = `application/pdf`.
      WHEN `zip`.
        result = `application/zip`.
      WHEN `png`.
        result = `image/png`.
      WHEN `jpg` OR `jpeg`.
        result = `image/jpeg`.
      WHEN `gif`.
        result = `image/gif`.
      WHEN `svg`.
        result = `image/svg+xml`.
      WHEN `webp`.
        result = `image/webp`.
      WHEN `ico`.
        result = `image/x-icon`.
      WHEN `mp3`.
        result = `audio/mpeg`.
      WHEN `mp4`.
        result = `video/mp4`.
      WHEN `woff`.
        result = `font/woff`.
      WHEN `woff2`.
        result = `font/woff2`.
      WHEN `ttf`.
        result = `font/ttf`.
      WHEN `otf`.
        result = `font/otf`.
      WHEN `xlsx`.
        result = `application/vnd.openxmlformats-officedocument.spreadsheetml.sheet`.
      WHEN `xls`.
        result = `application/vnd.ms-excel`.
      WHEN `docx`.
        result = `application/vnd.openxmlformats-officedocument.wordprocessingml.document`.
      WHEN `doc`.
        result = `application/msword`.
      WHEN `pptx`.
        result = `application/vnd.openxmlformats-officedocument.presentationml.presentation`.
      WHEN `ppt`.
        result = `application/vnd.ms-powerpoint`.
      WHEN OTHERS.
        result = `application/octet-stream`.
    ENDCASE.

  ENDMETHOD.

  METHOD lang_sap_to_iso.

    CONSTANTS lc_map TYPE string VALUE `A:af;B:he;C:zh;D:de;E:en;F:fr;G:el;H:hu;I:it;J:ja;K:da;L:pl;M:zf;N:nl;O:no;P:pt;Q:sk;R:ru;S:es;T:tr;U:fi;V:sv;W:bg;X:lt;Y:lv`.

    DATA lv_sap TYPE string.
    TYPES temp20 TYPE STANDARD TABLE OF string WITH DEFAULT KEY.
DATA lt_pairs TYPE temp20.
    DATA lv_pair LIKE LINE OF lt_pairs.
      DATA lv_key TYPE string.
      DATA lv_iso TYPE string.
        DATA lv_tab TYPE string.
    lv_sap = to_upper( c_trim( val ) ).

    

    SPLIT lc_map AT `;` INTO TABLE lt_pairs.
    
    LOOP AT lt_pairs INTO lv_pair.
      
      
      SPLIT lv_pair AT `:` INTO lv_key lv_iso.
      IF lv_key = lv_sap.
        result = lv_iso.
        RETURN.
      ENDIF.
    ENDLOOP.

    TRY.
        
        lv_tab = `T002`.
        SELECT SINGLE laiso FROM (lv_tab) INTO result WHERE spras = lv_sap .
        IF sy-subrc = 0.
          result = to_lower( result ).
        ELSE.
          CLEAR result.
        ENDIF.
      CATCH cx_root.
        CLEAR result.
    ENDTRY.

  ENDMETHOD.

  METHOD lang_iso_to_sap.

    CONSTANTS lc_map TYPE string VALUE `A:af;B:he;C:zh;D:de;E:en;F:fr;G:el;H:hu;I:it;J:ja;K:da;L:pl;M:zf;N:nl;O:no;P:pt;Q:sk;R:ru;S:es;T:tr;U:fi;V:sv;W:bg;X:lt;Y:lv`.

    DATA lv_iso TYPE string.
    TYPES temp21 TYPE STANDARD TABLE OF string WITH DEFAULT KEY.
DATA lt_pairs TYPE temp21.
    DATA lv_pair LIKE LINE OF lt_pairs.
      DATA lv_key TYPE string.
      DATA lv_map_iso TYPE string.
        DATA lv_tab TYPE string.
        DATA lv_laiso TYPE string.
    lv_iso = to_lower( c_trim( val ) ).

    

    SPLIT lc_map AT `;` INTO TABLE lt_pairs.
    
    LOOP AT lt_pairs INTO lv_pair.
      
      
      SPLIT lv_pair AT `:` INTO lv_key lv_map_iso.
      IF lv_map_iso = lv_iso.
        result = lv_key.
        RETURN.
      ENDIF.
    ENDLOOP.

    TRY.
        
        lv_tab = `T002`.
        
        lv_laiso = to_upper( lv_iso ).
        SELECT SINGLE spras FROM (lv_tab) INTO result WHERE laiso = lv_laiso .
        IF sy-subrc <> 0.
          CLEAR result.
        ENDIF.
      CATCH cx_root.
        CLEAR result.
    ENDTRY.

  ENDMETHOD.

  METHOD time_get_user_timezone.

    DATA lv_class TYPE string.
    FIELD-SYMBOLS <zonlo> TYPE any.

    TRY.
        lv_class = `CL_ABAP_CONTEXT_INFO`.
        CALL METHOD (lv_class)=>(`GET_USER_TIME_ZONE`)
          RECEIVING
            rv_time_zone = result.
      CATCH cx_root.
        ASSIGN (`SY-ZONLO`) TO <zonlo>.
        IF sy-subrc = 0.
          result = <zonlo>.
        ENDIF.
    ENDTRY.

  ENDMETHOD.

  METHOD time_stampl_to_tz.

    DATA lv_tz TYPE c LENGTH 6.
    lv_tz = tz.

    CONVERT TIME STAMP val TIME ZONE lv_tz INTO DATE date TIME time.

  ENDMETHOD.

  METHOD time_stampl_from_tz.

    DATA lv_tz TYPE c LENGTH 6.
    lv_tz = tz.

    CONVERT DATE date TIME time INTO TIME STAMP result TIME ZONE lv_tz.

  ENDMETHOD.

  METHOD context_get_user_info.

    DATA lv_class TYPE string.
    DATA lv_tab   TYPE string.

    DATA temp528 TYPE string.
    DATA temp85 TYPE string.
    DATA lv_uname LIKE temp85.
          DATA lv_persnumber TYPE c LENGTH 10.
          DATA lv_addrnumber TYPE c LENGTH 10.
    temp528 = sy-uname.
    
    IF uname IS NOT INITIAL.
      temp85 = to_upper( c_trim( uname ) ).
    ELSE.
      temp85 = temp528.
    ENDIF.
    
    lv_uname = temp85.

    result-uname    = lv_uname.
    result-langu    = sy-langu.
    result-timezone = time_get_user_timezone( ).

    IF check_abap_cloud( ) = abap_true.

      lv_class = `CL_ABAP_CONTEXT_INFO`.
      TRY.
          CALL METHOD (lv_class)=>(`GET_USER_FORMATTED_NAME`)
            RECEIVING
              rv_formatted_name = result-name_formatted.
        CATCH cx_root ##NO_HANDLER.
      ENDTRY.
      TRY.
          CALL METHOD (lv_class)=>(`GET_USER_DATE_FORMAT`)
            RECEIVING
              rv_date_format = result-date_format.
        CATCH cx_root ##NO_HANDLER.
      ENDTRY.
      TRY.
          CALL METHOD (lv_class)=>(`GET_USER_DECIMAL_FORMAT`)
            RECEIVING
              rv_decimal_format = result-decimal_format.
        CATCH cx_root ##NO_HANDLER.
      ENDTRY.

    ELSE.

      TRY.
          lv_tab = `USER_ADDR`.
          SELECT SINGLE name_textc FROM (lv_tab) INTO result-name_formatted WHERE bname = lv_uname .
        CATCH cx_root ##NO_HANDLER.
      ENDTRY.

      TRY.
          lv_tab = `USR01`.
          SELECT SINGLE datfm FROM (lv_tab) INTO result-date_format WHERE bname = lv_uname .
          SELECT SINGLE dcpfm FROM (lv_tab) INTO result-decimal_format WHERE bname = lv_uname .
        CATCH cx_root ##NO_HANDLER.
      ENDTRY.

      TRY.
          
          
          lv_tab = `USR21`.
          SELECT SINGLE persnumber FROM (lv_tab) INTO lv_persnumber WHERE bname = lv_uname .
          SELECT SINGLE addrnumber FROM (lv_tab) INTO lv_addrnumber WHERE bname = lv_uname .
          IF sy-subrc = 0.
            lv_tab = `ADR6`.
            SELECT SINGLE smtp_addr FROM (lv_tab) INTO result-email WHERE persnumber = lv_persnumber AND addrnumber = lv_addrnumber .
          ENDIF.
        CATCH cx_root ##NO_HANDLER.
      ENDTRY.

    ENDIF.

  ENDMETHOD.

  METHOD cur_get_decimals.

    DATA lv_tab TYPE string.

    DATA lv_curr TYPE string.
    lv_curr = to_upper( c_trim( val ) ).
    result = 2.

    TRY.
        lv_tab = `TCURX`.
        SELECT SINGLE currdec FROM (lv_tab) INTO result WHERE currkey = lv_curr .
        IF sy-subrc <> 0.
          result = 2.
        ENDIF.
      CATCH cx_root.
        TRY.
            lv_tab = `I_CURRENCY`.
            SELECT SINGLE decimals FROM (lv_tab) INTO result WHERE currency = lv_curr .
            IF sy-subrc <> 0.
              result = 2.
            ENDIF.
          CATCH cx_root.
            result = 2.
        ENDTRY.
    ENDTRY.

  ENDMETHOD.

  METHOD cur_amount_to_external.

    DATA lv_dec LIKE decimals.
    DATA lv_factor TYPE decfloat34 VALUE 1.
    lv_dec = decimals.
    IF lv_dec < 0.
      lv_dec = cur_get_decimals( currency ).
    ENDIF.

    

    IF lv_dec < 2.
      DO 2 - lv_dec TIMES.
        lv_factor = lv_factor * 10.
      ENDDO.
      result = val * lv_factor.
    ELSEIF lv_dec > 2.
      DO lv_dec - 2 TIMES.
        lv_factor = lv_factor * 10.
      ENDDO.
      result = val / lv_factor.
    ELSE.
      result = val * lv_factor.
    ENDIF.

  ENDMETHOD.

  METHOD cur_amount_to_internal.

    DATA lv_dec LIKE decimals.
    DATA lv_factor TYPE decfloat34 VALUE 1.
    lv_dec = decimals.
    IF lv_dec < 0.
      lv_dec = cur_get_decimals( currency ).
    ENDIF.

    

    IF lv_dec < 2.
      DO 2 - lv_dec TIMES.
        lv_factor = lv_factor * 10.
      ENDDO.
      result = val / lv_factor.
    ELSEIF lv_dec > 2.
      DO lv_dec - 2 TIMES.
        lv_factor = lv_factor * 10.
      ENDDO.
      result = val * lv_factor.
    ELSE.
      result = val * lv_factor.
    ENDIF.

  ENDMETHOD.

  METHOD unit_convert.

    DATA lv_fm  TYPE string.
    DATA lv_tab TYPE string.
      DATA lv_in TYPE f.
      DATA lv_out TYPE f.
      DATA lv_ui TYPE c LENGTH 3.
      DATA lv_uo TYPE c LENGTH 3.
TYPES BEGIN OF ty_s_uom.
TYPES unitofmeasuresinumerator TYPE decfloat34.
TYPES unitofmeasuresidenominator TYPE decfloat34.
TYPES unitofmeasuresiexponent TYPE i.
TYPES END OF ty_s_uom.
          DATA ls_uom_from TYPE ty_s_uom.
          DATA ls_uom_to TYPE ty_s_uom.
          DATA lv_num_from TYPE decfloat34.
          DATA lv_den_from TYPE decfloat34.
          DATA lv_exp_from TYPE i.
          DATA lv_num_to TYPE decfloat34.
          DATA lv_den_to TYPE decfloat34.
          DATA lv_exp_to TYPE i.
          DATA lv_from TYPE string.
          DATA lv_to TYPE string.
          DATA lv_factor_from TYPE decfloat34.
          DATA lv_factor_to TYPE decfloat34.
          DATA lv_ten TYPE decfloat34 VALUE 10.

    IF unit_from = unit_to.
      result = val.
      RETURN.
    ENDIF.

    IF check_abap_cloud( ) = abap_false.

      
      
      
      

      lv_in = val.
      lv_ui = to_upper( c_trim( unit_from ) ).
      lv_uo = to_upper( c_trim( unit_to ) ).

      lv_fm = `UNIT_CONVERSION_SIMPLE`.
      CALL FUNCTION lv_fm
        EXPORTING
          input         = lv_in
          unit_in       = lv_ui
          unit_out      = lv_uo
        IMPORTING
          output        = lv_out
        EXCEPTIONS
          error_message = 1
          OTHERS        = 2.
      IF sy-subrc <> 0.
        x_raise( `UNIT_CONVERSION_FAILED` ).
      ENDIF.

      result = lv_out.

    ELSE.

      TRY.
          
          
          
          
          
          
          
          
          

          
          lv_from = to_upper( c_trim( unit_from ) ).
          
          lv_to = to_upper( c_trim( unit_to ) ).

          lv_tab = `I_UNITOFMEASURE`.
          SELECT SINGLE unitofmeasuresinumerator unitofmeasuresidenominator unitofmeasuresiexponent
            FROM (lv_tab) INTO CORRESPONDING FIELDS OF ls_uom_from
            WHERE unitofmeasure = lv_from
            .
          IF sy-subrc <> 0.
            x_raise( `UNIT_CONVERSION_FAILED` ).
          ENDIF.
          SELECT SINGLE unitofmeasuresinumerator unitofmeasuresidenominator unitofmeasuresiexponent
            FROM (lv_tab) INTO CORRESPONDING FIELDS OF ls_uom_to
            WHERE unitofmeasure = lv_to
            .
          IF sy-subrc <> 0.
            x_raise( `UNIT_CONVERSION_FAILED` ).
          ENDIF.

          lv_num_from = ls_uom_from-unitofmeasuresinumerator.
          lv_den_from = ls_uom_from-unitofmeasuresidenominator.
          lv_exp_from = ls_uom_from-unitofmeasuresiexponent.
          lv_num_to   = ls_uom_to-unitofmeasuresinumerator.
          lv_den_to   = ls_uom_to-unitofmeasuresidenominator.
          lv_exp_to   = ls_uom_to-unitofmeasuresiexponent.

          
          
          

          lv_factor_from = lv_num_from / lv_den_from.
          DO lv_exp_from TIMES.
            lv_factor_from = lv_factor_from * lv_ten.
          ENDDO.
          DO lv_exp_from * -1 TIMES.
            lv_factor_from = lv_factor_from / lv_ten.
          ENDDO.

          lv_factor_to = lv_num_to / lv_den_to.
          DO lv_exp_to TIMES.
            lv_factor_to = lv_factor_to * lv_ten.
          ENDDO.
          DO lv_exp_to * -1 TIMES.
            lv_factor_to = lv_factor_to / lv_ten.
          ENDDO.

          result = val * lv_factor_from / lv_factor_to.

        CATCH cx_root.
          x_raise( `UNIT_CONVERSION_FAILED` ).
      ENDTRY.

    ENDIF.

  ENDMETHOD.

  METHOD hash_calculate.

    DATA lv_class TYPE string.
    DATA lv_alg   TYPE c LENGTH 10.
    DATA lv_data  TYPE string.

    lv_alg = to_upper( c_trim( algorithm ) ).
    lv_data = val.

    TRY.
        lv_class = `CL_ABAP_MESSAGE_DIGEST`.
        CALL METHOD (lv_class)=>(`CALCULATE_HASH_FOR_CHAR`)
          EXPORTING
            if_algorithm  = lv_alg
            if_data       = lv_data
          IMPORTING
            ef_hashstring = result.
      CATCH cx_root.
        x_raise( `HASH_CALCULATION_FAILED` ).
    ENDTRY.

  ENDMETHOD.

  METHOD hash_hmac.

    DATA lv_class TYPE string.
    DATA lv_alg   TYPE c LENGTH 10.
    DATA lv_data  TYPE string.
    DATA temp529 TYPE string.
    DATA lv_key TYPE xstring.

    lv_alg = to_upper( c_trim( algorithm ) ).
    lv_data = val.
    
    temp529 = key.
    
    lv_key = conv_get_xstring_by_string( temp529 ).

    TRY.
        lv_class = `CL_ABAP_HMAC`.
        CALL METHOD (lv_class)=>(`CALCULATE_HMAC_FOR_CHAR`)
          EXPORTING
            if_algorithm  = lv_alg
            if_key        = lv_key
            if_data       = lv_data
          IMPORTING
            ef_hmacstring = result.
      CATCH cx_root.
        x_raise( `HMAC_CALCULATION_FAILED` ).
    ENDTRY.

  ENDMETHOD.

  METHOD http_get.

    DATA temp530 TYPE string.
    temp530 = url.
    result = http_execute( method       = `GET`
                           url          = temp530
                           body         = ``
                           content_type = ``
                           t_header     = t_header ).

  ENDMETHOD.

  METHOD http_post.

    DATA temp531 TYPE string.
    DATA temp86 TYPE string.
    DATA temp1 TYPE string.
    temp531 = url.
    
    temp86 = body.
    
    temp1 = content_type.
    result = http_execute( method       = `POST`
                           url          = temp531
                           body         = temp86
                           content_type = temp1
                           t_header     = t_header ).

  ENDMETHOD.

  METHOD http_execute.

    IF check_abap_cloud( ) = abap_true.
      result = http_execute_cloud( method       = method
                                   url          = url
                                   body         = body
                                   content_type = content_type
                                   t_header     = t_header ).
    ELSE.
      result = http_execute_std( method       = method
                                 url          = url
                                 body         = body
                                 content_type = content_type
                                 t_header     = t_header ).
    ENDIF.

  ENDMETHOD.

  METHOD http_execute_cloud.

    DATA lo_dest   TYPE REF TO object.
    DATA lo_client TYPE REF TO object.
    DATA lo_req    TYPE REF TO object.
    DATA lo_resp   TYPE REF TO object.
    DATA lr_status TYPE REF TO data.
    DATA lv_class  TYPE string.
    FIELD-SYMBOLS <status> TYPE any.
        DATA ls_header LIKE LINE OF t_header.
        FIELD-SYMBOLS <code> TYPE any.
        FIELD-SYMBOLS <reason> TYPE any.
        DATA lx_error TYPE REF TO cx_root.

    TRY.

        lv_class = `CL_HTTP_DESTINATION_PROVIDER`.
        CALL METHOD (lv_class)=>(`CREATE_BY_URL`)
          EXPORTING
            i_url              = url
          RECEIVING
            r_http_destination = lo_dest.

        lv_class = `CL_WEB_HTTP_CLIENT_MANAGER`.
        CALL METHOD (lv_class)=>(`CREATE_BY_HTTP_DESTINATION`)
          EXPORTING
            i_destination = lo_dest
          RECEIVING
            r_client      = lo_client.

        CALL METHOD lo_client->(`IF_WEB_HTTP_CLIENT~GET_HTTP_REQUEST`)
          RECEIVING
            r_value = lo_req.

        
        LOOP AT t_header INTO ls_header.
          CALL METHOD lo_req->(`IF_WEB_HTTP_REQUEST~SET_HEADER_FIELD`)
            EXPORTING
              i_name  = ls_header-n
              i_value = ls_header-v.
        ENDLOOP.

        IF content_type IS NOT INITIAL.
          CALL METHOD lo_req->(`IF_WEB_HTTP_REQUEST~SET_HEADER_FIELD`)
            EXPORTING
              i_name  = `Content-Type`
              i_value = content_type.
        ENDIF.

        IF body IS NOT INITIAL.
          CALL METHOD lo_req->(`IF_WEB_HTTP_REQUEST~SET_TEXT`)
            EXPORTING
              i_text = body.
        ENDIF.

        CALL METHOD lo_client->(`IF_WEB_HTTP_CLIENT~EXECUTE`)
          EXPORTING
            i_method   = method
          RECEIVING
            r_response = lo_resp.

        CALL METHOD lo_resp->(`IF_WEB_HTTP_RESPONSE~GET_TEXT`)
          RECEIVING
            r_value = result-body.

        CREATE DATA lr_status TYPE (`IF_WEB_HTTP_RESPONSE=>HTTP_STATUS`).
        ASSIGN lr_status->* TO <status>.
        CALL METHOD lo_resp->(`IF_WEB_HTTP_RESPONSE~GET_STATUS`)
          RECEIVING
            r_value = <status>.

        
        ASSIGN COMPONENT `CODE` OF STRUCTURE <status> TO <code>.
        IF sy-subrc = 0.
          result-code = <code>.
        ENDIF.
        
        ASSIGN COMPONENT `REASON` OF STRUCTURE <status> TO <reason>.
        IF sy-subrc = 0.
          result-reason = <reason>.
        ENDIF.

        CALL METHOD lo_client->(`IF_WEB_HTTP_CLIENT~CLOSE`).

        
      CATCH cx_root INTO lx_error.
        RAISE EXCEPTION TYPE zabaputil_cx_util_error
          EXPORTING
            val = lx_error.
    ENDTRY.

  ENDMETHOD.

  METHOD http_execute_std.

    DATA lo_client TYPE REF TO object.
    DATA lo_req    TYPE REF TO object.
    DATA lo_resp   TYPE REF TO object.
    DATA lv_class  TYPE string.
    FIELD-SYMBOLS <obj> TYPE any.
        DATA ls_header LIKE LINE OF t_header.
        DATA lx_error TYPE REF TO cx_root.

    TRY.

        lv_class = `CL_HTTP_CLIENT`.
        CALL METHOD (lv_class)=>(`CREATE_BY_URL`)
          EXPORTING
            url    = url
          IMPORTING
            client = lo_client.

        ASSIGN lo_client->(`IF_HTTP_CLIENT~REQUEST`) TO <obj>.
        IF sy-subrc <> 0.
          x_raise( `HTTP_REQUEST_FAILED` ).
        ENDIF.
        lo_req = <obj>.

        CALL METHOD lo_req->(`IF_HTTP_REQUEST~SET_METHOD`)
          EXPORTING
            method = method.

        
        LOOP AT t_header INTO ls_header.
          CALL METHOD lo_req->(`IF_HTTP_ENTITY~SET_HEADER_FIELD`)
            EXPORTING
              name  = ls_header-n
              value = ls_header-v.
        ENDLOOP.

        IF content_type IS NOT INITIAL.
          CALL METHOD lo_req->(`IF_HTTP_ENTITY~SET_CONTENT_TYPE`)
            EXPORTING
              content_type = content_type.
        ENDIF.

        IF body IS NOT INITIAL.
          CALL METHOD lo_req->(`IF_HTTP_ENTITY~SET_CDATA`)
            EXPORTING
              data = body.
        ENDIF.

        CALL METHOD lo_client->(`IF_HTTP_CLIENT~SEND`)
          EXCEPTIONS
            OTHERS = 1.
        IF sy-subrc <> 0.
          x_raise( `HTTP_SEND_FAILED` ).
        ENDIF.

        CALL METHOD lo_client->(`IF_HTTP_CLIENT~RECEIVE`)
          EXCEPTIONS
            OTHERS = 1.
        IF sy-subrc <> 0.
          x_raise( `HTTP_RECEIVE_FAILED` ).
        ENDIF.

        ASSIGN lo_client->(`IF_HTTP_CLIENT~RESPONSE`) TO <obj>.
        IF sy-subrc <> 0.
          x_raise( `HTTP_RECEIVE_FAILED` ).
        ENDIF.
        lo_resp = <obj>.

        CALL METHOD lo_resp->(`IF_HTTP_RESPONSE~GET_STATUS`)
          IMPORTING
            code   = result-code
            reason = result-reason.

        CALL METHOD lo_resp->(`IF_HTTP_ENTITY~GET_CDATA`)
          RECEIVING
            data = result-body.

        CALL METHOD lo_client->(`IF_HTTP_CLIENT~CLOSE`)
          EXCEPTIONS
            OTHERS = 1.

        
      CATCH cx_root INTO lx_error.
        RAISE EXCEPTION TYPE zabaputil_cx_util_error
          EXPORTING
            val = lx_error.
    ENDTRY.

  ENDMETHOD.

  METHOD db_check_table_exists.

    DATA lr_data TYPE REF TO data.

    DATA lv_name TYPE string.
    lv_name = to_upper( c_trim( val ) ).

    TRY.
        CREATE DATA lr_data TYPE (lv_name).
        result = abap_true.
      CATCH cx_root.
        result = abap_false.
    ENDTRY.

  ENDMETHOD.

  METHOD db_select_by_name.

    DATA lv_tab TYPE string.
    DATA temp532 TYPE string.
    DATA lv_where LIKE temp532.
    FIELD-SYMBOLS <tab> TYPE STANDARD TABLE.
        DATA lx_error TYPE REF TO cx_root.
    lv_tab = to_upper( c_trim( tabname ) ).
    
    temp532 = where.
    
    lv_where = temp532.

    result = rtti_create_tab_by_name( lv_tab ).
    
    ASSIGN result->* TO <tab>.

    TRY.
        IF max_rows > 0.
          SELECT * FROM (lv_tab) INTO TABLE <tab> WHERE (lv_where)  UP TO max_rows ROWS.
        ELSE.
          SELECT * FROM (lv_tab) INTO TABLE <tab> WHERE (lv_where) .
        ENDIF.
        
      CATCH cx_root INTO lx_error.
        RAISE EXCEPTION TYPE zabaputil_cx_util_error
          EXPORTING
            val = lx_error.
    ENDTRY.

  ENDMETHOD.

  METHOD db_count_by_name.

    DATA lv_tab TYPE string.
    DATA temp533 TYPE string.
    DATA lv_where LIKE temp533.
        DATA lx_error TYPE REF TO cx_root.
    lv_tab = to_upper( c_trim( tabname ) ).
    
    temp533 = where.
    
    lv_where = temp533.

    TRY.
        SELECT COUNT(*) FROM (lv_tab) INTO result WHERE (lv_where) .
        
      CATCH cx_root INTO lx_error.
        RAISE EXCEPTION TYPE zabaputil_cx_util_error
          EXPORTING
            val = lx_error.
    ENDTRY.

  ENDMETHOD.

  METHOD param_get_user_default.

    DATA lv_tab TYPE string.

    DATA temp534 TYPE string.
    DATA temp87 TYPE string.
    DATA lv_uname LIKE temp87.
    DATA lv_parid TYPE string.
    temp534 = sy-uname.
    
    IF uname IS NOT INITIAL.
      temp87 = to_upper( c_trim( uname ) ).
    ELSE.
      temp87 = temp534.
    ENDIF.
    
    lv_uname = temp87.
    
    lv_parid = to_upper( c_trim( val ) ).

    TRY.
        lv_tab = `USR05`.
        SELECT SINGLE parva FROM (lv_tab) INTO result WHERE bname = lv_uname AND parid = lv_parid .
        IF sy-subrc <> 0.
          CLEAR result.
        ENDIF.
      CATCH cx_root.
        CLEAR result.
    ENDTRY.

  ENDMETHOD.

  METHOD job_get_status.

    DATA lv_tab TYPE string.

    DATA lv_jobname TYPE string.
    DATA lv_jobcount TYPE string.
    lv_jobname = to_upper( c_trim( jobname ) ).
    
    lv_jobcount = c_trim( jobcount ).

    TRY.
        lv_tab = `TBTCO`.
        SELECT SINGLE status FROM (lv_tab) INTO result WHERE jobname = lv_jobname AND jobcount = lv_jobcount .
        IF sy-subrc <> 0.
          CLEAR result.
        ENDIF.
      CATCH cx_root.
        CLEAR result.
    ENDTRY.

  ENDMETHOD.


ENDCLASS.
