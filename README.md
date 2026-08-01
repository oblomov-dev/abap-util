[![ABAP_702](https://github.com/abap-util/abap-util/actions/workflows/ABAP_702.yaml/badge.svg)](https://github.com/abap-util/abap-util/actions/workflows/ABAP_702.yaml)
[![ABAP_STANDARD](https://github.com/abap-util/abap-util/actions/workflows/ABAP_STANDARD.yaml/badge.svg)](https://github.com/abap-util/abap-util/actions/workflows/ABAP_STANDARD.yaml)
[![ABAP_CLOUD](https://github.com/abap-util/abap-util/actions/workflows/ABAP_CLOUD.yaml/badge.svg)](https://github.com/abap-util/abap-util/actions/workflows/ABAP_CLOUD.yaml)
<br>
[![auto_build](https://github.com/abap-util/abap-util/actions/workflows/auto_build.yml/badge.svg)](https://github.com/abap-util/abap-util/actions/workflows/auto_build.yml)
[![auto_downport](https://github.com/abap-util/abap-util/actions/workflows/auto_downport.yaml/badge.svg)](https://github.com/abap-util/abap-util/actions/workflows/auto_downport.yaml)
<br>
[![test_unit](https://github.com/abap-util/abap-util/actions/workflows/test_unit.yaml/badge.svg)](https://github.com/abap-util/abap-util/actions/workflows/test_unit.yaml)
[![test_rename](https://github.com/abap-util/abap-util/actions/workflows/test_rename.yaml/badge.svg)](https://github.com/abap-util/abap-util/actions/workflows/test_rename.yaml)

# abap-util
Utility Functions for ABAP Cloud & Standard ABAP

📖 **[Documentation](https://abap-util.github.io/docs/)** — guides and full API reference

#### Key Features
* Simplified SAP APIs as class-based methods — one façade class, no function modules to remember
* Hides language version differences between ABAP Cloud and Standard ABAP
* Function scope: strings, JSON/XML/CSV/XLSX, RTTI, messages, logging, locks, calendar, transports, persistence and more

#### Compatibility
* S/4 Public Cloud and BTP ABAP Environment (ABAP Cloud)
* S/4 Private Cloud and On-Premise (ABAP Cloud, Standard ABAP)
* R/3 NetWeaver AS ABAP 7.02 or higher (Standard ABAP)

#### Credits
* [ajson](https://github.com/sbcgua/ajson)
* [S-RTTI](https://github.com/sandraros/S-RTTI)
* [steampunkification](https://github.com/heliconialabs/steampunkification)

#### Installation
Install via [abapGit](https://abapgit.org) - clone this repository into your SAP system.

#### Consumption Model — Copy, Don't Depend

abap-util is designed to be consumed **as a vendored copy, not as an installed dependency**. abapGit has no dependency management, so a hard dependency between repositories would force users to install packages in the correct order and keep versions in sync. Instead, this repository is the **master catalog containing all utility classes with all methods**, and each downstream project decides which classes it needs and embeds a **renamed copy** of exactly those (e.g. `zabaputil_cl_util_context`, and where needed `zabaputil_cl_util_http` or `zabaputil_cx_error`). Only the context class is additionally **trimmed at method level** to the methods the project actually uses; other classes are copied as-is:

| Project | Vendored Copy | Scope |
|---|---|---|
| [abap2UI5](https://github.com/abap2UI5/abap2UI5) | `z2ui5_cl_a2ui5_context` (`src/00/03/`) | methods used by the core framework |
| [popups](https://github.com/abap2UI5-addons/popups) | `z2ui5_cl_popup_context` (`src/00/`) | methods used by the popup apps |

This gives every consumer a zero-dependency installation ("clone and go") and full namespace isolation (several projects — even on different versions — can coexist in one system with their own copy), while this repository remains the place where all methods converge, are unit-tested, and are kept compatible with all ABAP releases.

**How the cycle works:**
* **Copy per class:** each project vendors a renamed copy of the classes it needs. Only the context class is additionally reduced at **method level** — unused methods are removed (the private helpers a kept method needs stay in the copy).
* **Develop locally:** when a project needs a new utility method during development, it is simply written directly into the project's local context class — no upstream detour required.
* **AI sync-back:** every few weeks an AI compares abap-util with all consumers, detects methods that were added downstream, and merges them into this repository — so abap-util always returns to being the superset of all methods, and every other consumer can adopt them from here. Fix it here, then update the copies.

#### Usage

###### Strings
```abap
DATA(lv_upper) = zabaputil_cl_util_context=>c_trim_upper( ` Hello World  ` ). " => 'HELLO WORLD'
DATA(lv_lower) = zabaputil_cl_util_context=>c_trim_lower( ` Hello World  ` ). " => 'hello world'
DATA(lv_trim)  = zabaputil_cl_util_context=>c_trim( ` Hello World  ` ).       " => 'Hello World'

" Predicates
DATA(lv_has)   = zabaputil_cl_util_context=>c_contains(    val = `Hello World`  sub    = `World` ). " => abap_true
DATA(lv_pre)   = zabaputil_cl_util_context=>c_starts_with( val = `Hello World`  prefix = `Hello` ). " => abap_true
DATA(lv_suf)   = zabaputil_cl_util_context=>c_ends_with(   val = `Hello World`  suffix = `World` ). " => abap_true

" Split & Join
DATA(lt_parts) = zabaputil_cl_util_context=>c_split( val = `a,b,c`  sep = `,` ). " => ('a' 'b' 'c')
DATA(lv_csv)   = zabaputil_cl_util_context=>c_join(  tab = lt_parts  sep = `;` ). " => 'a;b;c'

" Padding, truncating, replacing
DATA(lv_pad)   = zabaputil_cl_util_context=>c_pad_left(    val = `42`  len = 5 ).            " => '00042'
DATA(lv_cut)   = zabaputil_cl_util_context=>c_truncate(    val = `Hello World`  max = 8 ).   " => 'Hello...'
DATA(lv_rep)   = zabaputil_cl_util_context=>c_replace_all( val = `a-b-c`  sub = `-`  new_val = `_` ). " => 'a_b_c'
DATA(lv_sub)   = zabaputil_cl_util_context=>c_substring_safe( val = `abc`  off = 1  len = 99 ). " no dump => 'bc'
DATA(lv_blank) = zabaputil_cl_util_context=>c_is_blank( `   ` ). " => abap_true
```

###### Validation
```abap
DATA(lv_ok1) = zabaputil_cl_util_context=>check_is_email(          `mail@example.com` ). " => abap_true
DATA(lv_ok2) = zabaputil_cl_util_context=>check_is_numeric_string( `12.34` ).            " => abap_true
DATA(lv_ok3) = zabaputil_cl_util_context=>check_is_date_valid(     `2025-02-30` ).       " => abap_false
DATA(lv_ok4) = zabaputil_cl_util_context=>check_is_guid(           lv_uuid ).
DATA(lv_ok5) = zabaputil_cl_util_context=>check_max_length( val = lv_input  max = 40 ).
```

###### JSON
```abap
" Structure to JSON
DATA(lv_json) = zabaputil_cl_util_context=>json_stringify( ls_flight ).
" => '{"CARRID":"LH","CONNID":"0400","FLDATE":"2025-01-15"}'

" JSON to Structure
zabaputil_cl_util_context=>json_parse(
    val  = lv_json
    data = ls_flight ).
```

###### XML
```abap
" Serialize any ABAP data to XML
DATA(lv_xml) = zabaputil_cl_util_context=>xml_stringify( ls_data ).

" Deserialize XML back to ABAP data
zabaputil_cl_util_context=>xml_parse(
    xml = lv_xml
    any = ls_data ).
```

###### UUID
```abap
DATA(lv_uuid_32) = zabaputil_cl_util_context=>uuid_get_c32( ). " => '550E8400E29B41D4A716446655440000'
DATA(lv_uuid_22) = zabaputil_cl_util_context=>uuid_get_c22( ). " => 'VQ6EAOKbQdSnFkRmVU'
DATA(lv_uuid_36) = zabaputil_cl_util_context=>uuid_get_c36( ). " => '550E8400-E29B-41D4-A716-446655440000'

" Convert between formats
DATA(lv_c36) = zabaputil_cl_util_context=>uuid_conv_c32_to_c36( lv_uuid_32 ).
DATA(lv_c32) = zabaputil_cl_util_context=>uuid_conv_c36_to_c32( lv_c36 ).
DATA(lv_c22) = zabaputil_cl_util_context=>uuid_conv_c32_to_c22( lv_uuid_32 ).
```

###### Escaping & URL Encoding
```abap
DATA(lv_html) = zabaputil_cl_util_context=>c_escape_html( `Tom & <b>Jerry</b>` ). " => 'Tom &amp; &lt;b&gt;Jerry&lt;/b&gt;'
DATA(lv_json) = zabaputil_cl_util_context=>c_escape_json( `say "hi"` ).           " => 'say \"hi\"'

DATA(lv_enc) = zabaputil_cl_util_context=>url_encode( `a b&c=ä` ). " => 'a%20b%26c%3D%C3%A4'
DATA(lv_dec) = zabaputil_cl_util_context=>url_decode( lv_enc ).    " => 'a b&c=ä'
```

###### Regular Expressions
PCRE on ABAP Cloud, POSIX on Standard ABAP - same API everywhere.
```abap
DATA(lv_match) = zabaputil_cl_util_context=>regex_match(    val = `ID-4711`  regex = `^ID-\d+$` ). " => abap_true
DATA(lt_nums)  = zabaputil_cl_util_context=>regex_find_all( val = `a1 b22 c333`  regex = `\d+` ).  " => ('1' '22' '333')
DATA(lv_new)   = zabaputil_cl_util_context=>regex_replace_all(
    val     = `a1b2`
    regex   = `\d`
    new_val = `#` ). " => 'a#b#'
```

###### Hashing & HMAC
```abap
DATA(lv_hash) = zabaputil_cl_util_context=>hash_calculate( `Hello World` ).                   " SHA256 hex string
DATA(lv_sha1) = zabaputil_cl_util_context=>hash_calculate( val = `Hello`  algorithm = `SHA1` ).
DATA(lv_hmac) = zabaputil_cl_util_context=>hash_hmac( val = `payload`  key = `secret` ).      " HMAC-SHA256
```

###### Outbound HTTP Client
Unified API - `cl_web_http_client` on ABAP Cloud, `cl_http_client` on-premise.
```abap
DATA(ls_response) = zabaputil_cl_util_context=>http_get( `https://api.example.com/data` ).
" => ls_response-code = 200, ls_response-body = '...'

DATA(ls_result) = zabaputil_cl_util_context=>http_post(
    url          = `https://api.example.com/items`
    body         = lv_json
    content_type = `application/json`
    t_header     = VALUE #( ( n = `Authorization`  v = `Bearer ...` ) ) ).
```

###### Currency & Units
```abap
DATA(lv_decimals) = zabaputil_cl_util_context=>cur_get_decimals( `JPY` ). " => 0 (TCURX / I_Currency)

" Shift internal amounts to their display value and back
DATA(lv_display)  = zabaputil_cl_util_context=>cur_amount_to_external( val = lv_amount  currency = `JPY` ).
DATA(lv_internal) = zabaputil_cl_util_context=>cur_amount_to_internal( val = lv_display currency = `JPY` ).

" Unit conversion (UNIT_CONVERSION_SIMPLE / I_UnitOfMeasure)
DATA(lv_meters) = zabaputil_cl_util_context=>unit_convert( val = CONV decfloat34( 2 )  unit_from = `KM`  unit_to = `M` ).
```

###### Languages
```abap
DATA(lv_iso) = zabaputil_cl_util_context=>lang_sap_to_iso( `D` ).  " => 'de'
DATA(lv_sap) = zabaputil_cl_util_context=>lang_iso_to_sap( `en` ). " => 'E'
```

###### RTTI
```abap
" Check if a class exists
IF zabaputil_cl_util_context=>rtti_check_class_exists( 'ZCL_MY_CLASS' ) = abap_true.
  " ...
ENDIF.

" Get type name of any variable
DATA(lv_type) = zabaputil_cl_util_context=>rtti_get_type_name( ls_flight ). " => 'SFLIGHT'

" Create dynamic internal table by DDIC name
DATA(lr_table) = zabaputil_cl_util_context=>rtti_create_tab_by_name( 'SFLIGHT' ).

" Get component list of a structure
DATA(lt_components) = zabaputil_cl_util_context=>rtti_get_t_attri_by_any( ls_flight ).
```

###### URL Parameters
```abap
" Read a parameter from URL
DATA(lv_id) = zabaputil_cl_util_context=>url_param_get(
    val = 'ID'
    url = '/sap/bc/http/myapp?ID=12345&MODE=edit' ). " => '12345'

" Build a URL from parameters
DATA(lv_url) = zabaputil_cl_util_context=>url_param_create_url(
    t_params = VALUE #(
        ( n = 'ID'   v = '12345' )
        ( n = 'MODE' v = 'edit' ) ) ). " => 'ID=12345&MODE=edit'

" Add/update a parameter
DATA(lv_new_url) = zabaputil_cl_util_context=>url_param_set(
    url   = '/app?ID=1'
    name  = 'LANG'
    value = 'DE' ). " => '/app?ID=1&LANG=DE'
```

###### Base64 & Encoding
```abap
" String <-> xstring
DATA(lv_xstring) = zabaputil_cl_util_context=>conv_get_xstring_by_string( 'Hello' ).
DATA(lv_string)  = zabaputil_cl_util_context=>conv_get_string_by_xstring( lv_xstring ).

" Base64 encode/decode
DATA(lv_base64)  = zabaputil_cl_util_context=>conv_encode_x_base64( lv_xstring ).
DATA(lv_decoded) = zabaputil_cl_util_context=>conv_decode_x_base64( lv_base64 ).
```

###### CSV
```abap
" Internal table to CSV
DATA(lv_csv) = zabaputil_cl_util_context=>itab_get_csv_by_itab( lt_flights ).

" CSV to internal table (returns data reference)
DATA(lr_itab) = zabaputil_cl_util_context=>itab_get_itab_by_csv( lv_csv ).
```

###### XLSX / Excel
```abap
" Internal table to Excel
DATA(lv_xlsx) = zabaputil_cl_util_context=>conv_get_xlsx_by_itab( lt_flights ).

" Excel to internal table
zabaputil_cl_util_context=>conv_get_itab_by_xlsx(
    EXPORTING val    = lv_xlsx
    IMPORTING result = lr_data ).
```

###### Internal Tables
```abap
" Move corresponding rows between tables of different row types
zabaputil_cl_util_context=>itab_corresponding(
    EXPORTING val = lt_source
    CHANGING  tab = lt_target ).

" Filter table in place by a substring across all clike fields
zabaputil_cl_util_context=>itab_filter_by_val(
    EXPORTING val = `LH`
    CHANGING  tab = lt_flights ).

" Project a flat structure to a list of name/value pairs
DATA(lt_kv) = zabaputil_cl_util_context=>itab_get_by_struc( ls_flight ).
" => [ ( name = 'CARRID' value = 'LH' ) ( name = 'CONNID' value = '0400' ) ... ]

" Sort, slice & paginate dynamically
zabaputil_cl_util_context=>itab_sort_by(
    EXPORTING fieldname = `PRICE`  descending = abap_true
    CHANGING  tab       = lt_flights ).

DATA(lr_top10) = zabaputil_cl_util_context=>itab_slice( tab = lt_flights  from = 1  to = 10 ).

zabaputil_cl_util_context=>itab_paginate(
    EXPORTING tab         = lt_flights  page = 2  page_size = 20
    IMPORTING result      = lr_page
              total_count = lv_count
              total_pages = lv_pages ).

" Count rows grouped by a field
DATA(lt_counts) = zabaputil_cl_util_context=>itab_count_by( tab = lt_flights  fieldname = `CARRID` ).
" => [ ( n = 'LH' v = '42' ) ( n = 'AA' v = '17' ) ... ]

" Aggregations
DATA(lv_total)    = zabaputil_cl_util_context=>itab_sum_by(       tab = lt_flights  fieldname = `PRICE` ).
DATA(lt_carriers) = zabaputil_cl_util_context=>itab_distinct(     tab = lt_flights  fieldname = `CARRID` ).
DATA(lt_sums)     = zabaputil_cl_util_context=>itab_group_sum_by( tab = lt_flights  group_by = `CARRID`  sum_by = `PRICE` ).
```

###### Data Compare & Access
```abap
" Deep equality for any two values
DATA(lv_same) = zabaputil_cl_util_context=>data_equals( a = ls_before  b = ls_after ).

" Field-by-field diff of two structures
DATA(lt_diff) = zabaputil_cl_util_context=>data_diff( old = ls_before  new = ls_after ).
" => [ ( fieldname = 'PRICE' old_value = '100' new_value = '120' ) ... ]

" Read/write nested fields by path
DATA(lv_city) = zabaputil_cl_util_context=>data_get_by_path( data = ls_order  path = `CUSTOMER-ADDRESS-CITY` ).
zabaputil_cl_util_context=>data_set_by_path(
    EXPORTING path  = `CUSTOMER-ADDRESS-CITY`  value = `Berlin`
    CHANGING  data  = ls_order ).
```

###### Range & Token Filters
```abap
" Build select-options ranges programmatically
DATA(ls_eq) = zabaputil_cl_util_range=>eq( `LH` ).        " I EQ 'LH'
DATA(ls_bt) = zabaputil_cl_util_range=>bt( low = `100` high = `200` ).
DATA(ls_cp) = zabaputil_cl_util_range=>cp( `LH*` ).        " I CP 'LH*'
DATA(ls_ne) = zabaputil_cl_util_range=>ne( `XX` ).         " E EQ 'XX'

" Token strings (e.g. from a UI search field) <-> ranges
DATA(ls_range) = zabaputil_cl_util_context=>filter_get_range_by_token( `>=100` ).
DATA(lt_token) = zabaputil_cl_util_context=>filter_get_token_t_by_range_t( lt_range ).

" Apply a multi-field filter on an internal table in place
zabaputil_cl_util_context=>filter_itab(
    EXPORTING filter = lt_filter
    CHANGING  val    = lt_flights ).
```

###### Messages
```abap
" Resolve any message-like input (sy, exception, T100 record, ...) to a single text
DATA(lv_text) = zabaputil_cl_util_msg=>msg_get_text( sy ).

" Get the current sy-msg* as a typed message table (type, id, number, text, ...)
DATA(lt_msg)  = zabaputil_cl_util_msg=>msg_get_by_sy( ).

" Map an arbitrary value to a message text via a configurable mapping
DATA(lv_mapped) = zabaputil_cl_util_msg=>msg_map( name = `STATUS` ).

" Resolve a T100 message with placeholders
DATA(lv_t100) = zabaputil_cl_util_context=>text_get( msgid = `ZMY_MESSAGES`  msgno = `001`  v1 = `42` ).

" Domain fixed values as text (enum-style)
DATA(lv_text) = zabaputil_cl_util_context=>enum_to_text( domain = `ZSTATUS`  value = `A` ). " => 'Active'
DATA(lt_all)  = zabaputil_cl_util_context=>enum_get_all( domain = `ZSTATUS` ).
```

###### Timestamps
```abap
DATA(lv_now)  = zabaputil_cl_util_context=>time_get_timestampl( ).
DATA(lv_past) = zabaputil_cl_util_context=>time_subtract_seconds( time = lv_now  seconds = 3600 ).
DATA(lv_next) = zabaputil_cl_util_context=>time_add_seconds(      time = lv_now  seconds = 60 ).
DATA(lv_diff) = zabaputil_cl_util_context=>time_diff_seconds(     time_from = lv_past  time_to = lv_now ).
DATA(lv_date) = zabaputil_cl_util_context=>time_get_date_by_stampl( lv_now ).
DATA(lv_time) = zabaputil_cl_util_context=>time_get_time_by_stampl( lv_now ).

" Build a timestampl from date/time
DATA(lv_stmp) = zabaputil_cl_util_context=>time_get_stampl_by_date_time(
    date = sy-datum
    time = sy-uzeit ).

" Date <-> string with format pattern
DATA(lv_iso)  = zabaputil_cl_util_context=>conv_date_to_string(   val = sy-datum    format = `YYYY-MM-DD` ).
DATA(lv_dat)  = zabaputil_cl_util_context=>conv_string_to_date(   val = `2024-03-15` format = `YYYY-MM-DD` ).

" Stopwatch - measure runtime in milliseconds
DATA(lv_start) = zabaputil_cl_util_context=>time_measure_start( ).
" ... do work ...
DATA(lv_ms)    = zabaputil_cl_util_context=>time_measure_stop( lv_start ).

" Time zones
DATA(lv_tz) = zabaputil_cl_util_context=>time_get_user_timezone( ).
zabaputil_cl_util_context=>time_stampl_to_tz(
    EXPORTING val  = lv_now
              tz   = `CET`
    IMPORTING date = lv_date
              time = lv_time ).
DATA(lv_stamp) = zabaputil_cl_util_context=>time_stampl_from_tz( date = lv_date  time = lv_time  tz = `CET` ).
```

###### Calendar & Workdays
```abap
DATA(lv_wd)   = zabaputil_cl_util_context=>cal_get_weekday( sy-datum ).  " 1 = Monday ... 7 = Sunday
DATA(lv_we)   = zabaputil_cl_util_context=>cal_is_weekend(  sy-datum ).
DATA(lv_work) = zabaputil_cl_util_context=>cal_is_workday(  sy-datum ).  " optional: calendar_id for factory calendars

" Workday arithmetic
DATA(lv_due)  = zabaputil_cl_util_context=>cal_add_workdays(   date = sy-datum  days = 5 ).
DATA(lv_days) = zabaputil_cl_util_context=>cal_count_workdays( date_from = lv_start_date  date_to = lv_end_date ).
```

###### Error Handling
```abap
" Raise exception conditionally
zabaputil_cl_util_context=>x_check_raise( when = xsdbool( sy-subrc <> 0 ) ).

" Raise exception directly
zabaputil_cl_util_context=>x_raise( 'Something went wrong' ).

" Get last T100 message from exception
TRY.
    " ...
  CATCH cx_root INTO DATA(lx_error).
    DATA(lv_msg) = zabaputil_cl_util_context=>x_get_last_t100( lx_error ).
ENDTRY.
```

###### Context
```abap
DATA(lv_user)  = zabaputil_cl_util_context=>context_get_user_tech( ). " => 'DEVELOPER'
DATA(lv_cloud) = zabaputil_cl_util_context=>check_abap_cloud( ). " => abap_true / abap_false
DATA(lt_stack) = zabaputil_cl_util_context=>context_get_callstack( ).

" User details - cl_abap_context_info on Cloud, USR01/USER_ADDR/ADR6 on-premise
DATA(ls_user) = zabaputil_cl_util_context=>context_get_user_info( ).
" => uname, name_formatted, email, langu, timezone, date_format, decimal_format
```

###### HTTP Handler
```abap
" On-Premise
DATA(lo_http) = zabaputil_cl_util_http=>factory( server = lo_server ).

" ABAP Cloud
DATA(lo_http) = zabaputil_cl_util_http=>factory_cloud( req = lo_req  res = lo_res ).

" Unified API - works the same in both environments
DATA(ls_req_info) = lo_http->get_req_info( ).  " method, body, path, params
DATA(lv_body)     = lo_http->get_cdata( ).
DATA(lv_method)   = lo_http->get_method( ).
lo_http->set_cdata( lv_json ).
lo_http->set_status( code = 200  reason = 'OK' ).
```

###### Logging
```abap
DATA(lo_log) = NEW zabaputil_cl_util_log( ).
lo_log->info(    `Step 1 completed` ).
lo_log->warning( `Cache miss, falling back` ).
lo_log->error(   `Step 3 failed` ).
lo_log->success( `Done` ).

" Add an exception directly
TRY.
    " ...
  CATCH cx_root INTO DATA(lx).
    lo_log->add( lx ).
ENDTRY.

IF lo_log->has_error( ) = abap_true.
  " ...
ENDIF.

DATA(lv_csv_log)  = lo_log->to_csv( ).   " Export as CSV
DATA(lv_xlsx_log) = lo_log->to_xlsx( ).  " Export as XLSX
DATA(lt_messages) = lo_log->to_msg( ).   " Get as message table
DATA(lv_text)     = lo_log->to_string( ).
```

###### Application Log (BAL)
```abap
" Search application logs
DATA(lt_logs) = zabaputil_cl_util_context=>bal_search(
    object    = `ZMY_APP`
    date_from = lv_start_date ).

" Read the latest message / messages of a specific type
DATA(ls_last)   = zabaputil_cl_util_context=>bal_read_latest(  object = `ZMY_APP`  subobject = `IMPORT`  id = `RUN1` ).
DATA(lt_errors) = zabaputil_cl_util_context=>bal_read_by_type( object = `ZMY_APP`  subobject = `IMPORT`  id = `RUN1`  msg_type = `E` ).
DATA(lv_count)  = zabaputil_cl_util_context=>bal_count(        object = `ZMY_APP`  subobject = `IMPORT`  id = `RUN1` ).

" Housekeeping: delete logs older than N days
zabaputil_cl_util_context=>bal_delete_before( object = `ZMY_APP`  days = 30 ).
```

###### Locks (Enqueue/Dequeue)
```abap
" Set / check / release a lock
DATA(lv_locked) = zabaputil_cl_util_context=>lock_set( `ZMY_LOCK_OBJECT` ).
DATA(lv_is)     = zabaputil_cl_util_context=>lock_is_locked( `ZMY_LOCK_OBJECT` ).
DATA(lv_owner)  = zabaputil_cl_util_context=>lock_get_owner( `ZMY_LOCK_OBJECT` ).
zabaputil_cl_util_context=>lock_delete( `ZMY_LOCK_OBJECT` ).

" Retry until the lock is available (5 retries, 500 ms delay by default)
DATA(lv_got_it) = zabaputil_cl_util_context=>lock_set_wait( val = `ZMY_LOCK_OBJECT`  retries = 10 ).

" Read current lock entries
DATA(lt_locks) = zabaputil_cl_util_context=>lock_read( lock_object = `ZMY_LOCK_OBJECT` ).
```

###### ZIP
```abap
" Pack files into a ZIP archive
DATA(lv_zip) = zabaputil_cl_util_context=>zip_pack( VALUE #(
    ( name = `data.json`  content = lv_json_x )
    ( name = `readme.txt` content = lv_text_x ) ) ).

" Unpack a ZIP archive
DATA(lt_files) = zabaputil_cl_util_context=>zip_unpack( lv_zip ). " => name + content per file
```

###### Transport Requests
```abap
DATA(lt_requests) = zabaputil_cl_util_context=>tr_get_user_requests( ).             " my open requests
DATA(lt_objects)  = zabaputil_cl_util_context=>tr_get_objects( `DEVK900123` ).
DATA(lv_descr)    = zabaputil_cl_util_context=>tr_get_description( `DEVK900123` ).
DATA(lv_released) = zabaputil_cl_util_context=>tr_is_released( `DEVK900123` ).

zabaputil_cl_util_context=>tr_add_object(
    trkorr   = `DEVK900123`
    object   = `CLAS`
    obj_name = `ZCL_MY_CLASS` ).
```

###### System Utilities
```abap
" Authorization check
IF zabaputil_cl_util_context=>auth_check( object = `S_TCODE`  field = `TCD`  value = `SE38` ) = abap_true.
  " ...
ENDIF.

" Next number from a number range
DATA(lv_number) = zabaputil_cl_util_context=>numrange_get_next( object = `ZMY_NR` ).

" Read change documents
DATA(lt_changes) = zabaputil_cl_util_context=>changdoc_read(
    objectclass = `ZMY_OBJECT`
    objectid    = lv_object_id ).

" Submit a report as background job
DATA(lv_job) = zabaputil_cl_util_context=>job_submit_report( report = `ZMY_REPORT`  variant = `DEFAULT` ).

" Send an e-mail
zabaputil_cl_util_context=>mail_send(
    to      = `mail@example.com`
    subject = `Import finished`
    body    = `<h1>Done!</h1>`
    html    = abap_true ).

" User parameter defaults (SPA/GPA, table USR05)
DATA(lv_plant) = zabaputil_cl_util_context=>param_get_user_default( `WRK` ).

" Background job status (table TBTCO)
DATA(lv_status) = zabaputil_cl_util_context=>job_get_status( jobname = `ZMY_JOB`  jobcount = lv_jobcount ).

" Generic DB access by table name
DATA(lv_exists) = zabaputil_cl_util_context=>db_check_table_exists( `T000` ).
DATA(lr_rows)   = zabaputil_cl_util_context=>db_select_by_name( tabname = `T000`  max_rows = 10 ).
DATA(lv_count)  = zabaputil_cl_util_context=>db_count_by_name( tabname = `T000` ).

" Misc helpers
DATA(lv_dist) = zabaputil_cl_util_context=>c_levenshtein( val1 = `kitten`  val2 = `sitting` ). " => 3
DATA(lv_mime) = zabaputil_cl_util_context=>file_get_mimetype( `report.xlsx` ).
DATA(lv_val)  = zabaputil_cl_util_context=>num_round( val = CONV decfloat34( '2.345' )  decimals = 2 ). " => 2.35
```

###### XML Builder
Fluent builder for nested XML / UI5 view fragments.
`__` opens an element (must be closed with `n( )`), `_` writes a self-closing leaf,
`p` adds a single attribute, the `p =` parameter takes an attribute table.
```abap
DATA(lo_view) = zabaputil_cl_util_xml=>factory(
  )->__( n = `View` ns = `mvc`
         p = VALUE #( ( n = `xmlns`     v = `sap.m` )
                      ( n = `xmlns:mvc` v = `sap.ui.core.mvc` ) ) ).

DATA(lo_page) = lo_view->__( n = `Page`
  p = VALUE #( ( n = `title`         v = `Hello` )
               ( n = `showNavButton` v = `true` ) ) ).

lo_page->__( `content`
  )->_( n = `Button` p = VALUE #( ( n = `text` v = `Click me` ) )
  )->n( ).  " close <content>

DATA(lv_xml)        = lo_view->stringify( ).
DATA(lv_xml_pretty) = lo_view->stringify( indent = abap_true ).
```

###### Persistence
```abap
" Save any ABAP value under a composite handle (key/value store)
DATA(lv_id) = zabaputil_cl_util_db=>save(
    uname  = sy-uname
    handle = `FILTER`
    data   = ls_filter ).

" Load it back
zabaputil_cl_util_db=>load_by_handle(
    EXPORTING uname  = sy-uname
              handle = `FILTER`
    IMPORTING result = ls_filter ).

zabaputil_cl_util_db=>delete_by_handle( uname = sy-uname  handle = `FILTER` ).
```

#### Documentation
The full API reference with all methods, parameters and further examples lives at **[abap-util.github.io/docs](https://abap-util.github.io/docs/)**.

#### Contribution & Support
Pull requests are welcome! Whether you're fixing bugs, adding new functionality, or improving documentation, your contributions are highly appreciated. If you encounter any problems, feel free to open an issue.
