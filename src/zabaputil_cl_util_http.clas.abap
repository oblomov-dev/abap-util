CLASS zabaputil_cl_util_http DEFINITION PUBLIC.

  PUBLIC SECTION.

    TYPES:
      BEGIN OF ty_s_http_req,
        method   TYPE string,
        body     TYPE string,
        path     TYPE string,
        t_params TYPE zabaputil_cl_util_context=>ty_t_name_value,
      END OF ty_s_http_req.

    TYPES:
      BEGIN OF ty_s_http_res,
        body          TYPE string,
        status_code   TYPE i,
        status_reason TYPE string,
      END OF ty_s_http_res.

    CLASS-METHODS client_create
      IMPORTING
        !destination  TYPE clike OPTIONAL
        url           TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO object.

    CLASS-METHODS client_call
      IMPORTING
        !method       TYPE clike
        body          TYPE clike OPTIONAL
        !destination  TYPE clike OPTIONAL
        url           TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE ty_s_http_res.

    CLASS-METHODS factory
      IMPORTING
        server        TYPE REF TO object
      RETURNING
        VALUE(result) TYPE REF TO zabaputil_cl_util_http.

    CLASS-METHODS factory_cloud
      IMPORTING
        req           TYPE REF TO object
        res           TYPE REF TO object
      RETURNING
        VALUE(result) TYPE REF TO zabaputil_cl_util_http.

    METHODS get_req_info
      RETURNING
        VALUE(result) TYPE ty_s_http_req.

    METHODS get_header_field
      IMPORTING
        val           TYPE clike
      RETURNING
        VALUE(result) TYPE string.

    METHODS get_cdata
      RETURNING
        VALUE(result) TYPE string.

    METHODS get_method
      RETURNING
        VALUE(result) TYPE string.

    METHODS set_cdata
      IMPORTING
        val TYPE clike.

    METHODS set_status
      IMPORTING
        !code  TYPE i
        reason TYPE clike.

    METHODS set_session_stateful
      IMPORTING
        val TYPE i.

    METHODS get_response_cookie
      IMPORTING
        val           TYPE clike
      RETURNING
        VALUE(result) TYPE string.

    METHODS delete_response_cookie
      IMPORTING
        val TYPE clike.

    METHODS set_header_field
      IMPORTING
        !n TYPE clike
        v  TYPE clike.

    DATA mo_server_onprem  TYPE REF TO object.
    DATA mo_request_cloud  TYPE REF TO object.
    DATA mo_response_cloud TYPE REF TO object.

  PROTECTED SECTION.

  PRIVATE SECTION.

    DATA mo_request_onprem  TYPE REF TO object.
    DATA mo_response_onprem TYPE REF TO object.

    METHODS get_request_onprem
      RETURNING
        VALUE(result) TYPE REF TO object.

    METHODS get_response_onprem
      RETURNING
        VALUE(result) TYPE REF TO object.

ENDCLASS.


CLASS zabaputil_cl_util_http IMPLEMENTATION.

  METHOD client_create.

    DATA lv_classname TYPE c LENGTH 14.
    DATA lv_destination TYPE c LENGTH 32.
    DATA temp16 TYPE string.
    DATA lv_url LIKE temp16.
        DATA x TYPE REF TO cx_root.
    lv_classname = `CL_HTTP_CLIENT`.

    
    lv_destination = destination.
    
    temp16 = url.
    
    lv_url = temp16.

    TRY.

        IF lv_destination IS NOT INITIAL AND lv_destination <> `NONE`.

          CALL METHOD (lv_classname)=>create_by_destination
            EXPORTING
              destination              = lv_destination
            IMPORTING
              client                   = result
            EXCEPTIONS
              argument_not_found       = 1
              destination_not_found    = 2
              destination_no_authority = 3
              plugin_not_active        = 4
              internal_error           = 5
              OTHERS                   = 6.

        ELSE.

          CALL METHOD (lv_classname)=>create_by_url
            EXPORTING
              url                = lv_url
            IMPORTING
              client             = result
            EXCEPTIONS
              argument_not_found = 1
              plugin_not_active  = 2
              internal_error     = 3
              OTHERS             = 4.

        ENDIF.

        IF sy-subrc <> 0.
          CLEAR result.
        ENDIF.

        
      CATCH cx_root INTO x.
        RAISE EXCEPTION TYPE zabaputil_cx_util_error
          EXPORTING val = x.
    ENDTRY.

    IF result IS NOT BOUND.
      RAISE EXCEPTION TYPE zabaputil_cx_util_error
        EXPORTING val = `HTTP_CLIENT_CREATE_ERROR - check the destination/url configuration`.
    ENDIF.

  ENDMETHOD.

  METHOD client_call.

    DATA lo_request  TYPE REF TO object.
    DATA lo_response TYPE REF TO object.
    DATA lv_message  TYPE string.
    FIELD-SYMBOLS <any> TYPE any.

    DATA lo_client TYPE REF TO object.
        DATA temp17 TYPE string.
        DATA lv_method LIKE temp17.
        DATA temp18 TYPE string.
        DATA lv_body LIKE temp18.
        DATA x TYPE REF TO cx_root.
    lo_client = client_create( destination = destination
                                     url         = url ).

    TRY.

        ASSIGN lo_client->(`REQUEST`) TO <any>.
        ASSERT sy-subrc = 0.
        lo_request = <any>.

        
        temp17 = method.
        
        lv_method = temp17.
        CALL METHOD lo_request->(`SET_METHOD`)
          EXPORTING
            method = lv_method.

        
        temp18 = body.
        
        lv_body = temp18.
        CALL METHOD lo_request->(`SET_CDATA`)
          EXPORTING
            data = lv_body.

        CALL METHOD lo_client->(`SEND`)
          EXCEPTIONS
            http_communication_failure = 1
            http_invalid_state         = 2
            http_processing_failed     = 3
            http_invalid_timeout       = 4
            OTHERS                     = 5.

        IF sy-subrc = 0.
          CALL METHOD lo_client->(`RECEIVE`)
            EXCEPTIONS
              http_communication_failure = 1
              http_invalid_state         = 2
              http_processing_failed     = 3
              OTHERS                     = 4.
        ENDIF.

        IF sy-subrc <> 0.
          CALL METHOD lo_client->(`GET_LAST_ERROR`)
            IMPORTING
              message = lv_message.
          CALL METHOD lo_client->(`CLOSE`)
            EXCEPTIONS
              OTHERS = 1.
          RAISE EXCEPTION TYPE zabaputil_cx_util_error
            EXPORTING val = |HTTP_COMMUNICATION_ERROR - { lv_message }|.
        ENDIF.

        ASSIGN lo_client->(`RESPONSE`) TO <any>.
        ASSERT sy-subrc = 0.
        lo_response = <any>.

        CALL METHOD lo_response->(`GET_CDATA`)
          RECEIVING
            data = result-body.

        CALL METHOD lo_response->(`GET_STATUS`)
          IMPORTING
            code   = result-status_code
            reason = result-status_reason.

        CALL METHOD lo_client->(`CLOSE`)
          EXCEPTIONS
            OTHERS = 1.

        
      CATCH cx_root INTO x.
        " CLOSE on the failure path too: every throw between client_create
        " and the success-path CLOSE above (a failing dynamic GET_CDATA /
        " GET_STATUS, the RESPONSE assign) used to leave the connection
        " open for the lifetime of the work process
        IF lo_client IS BOUND.
          TRY.
              CALL METHOD lo_client->(`CLOSE`)
                EXCEPTIONS
                  OTHERS = 1.
            CATCH cx_root ##NO_HANDLER.
          ENDTRY.
        ENDIF.
        RAISE EXCEPTION TYPE zabaputil_cx_util_error
          EXPORTING val = x.
    ENDTRY.

  ENDMETHOD.

  METHOD delete_response_cookie.

    DATA temp19 TYPE string.
    DATA lv_val LIKE temp19.
      DATA object TYPE REF TO object.
    temp19 = val.
    
    lv_val = temp19.

    IF mo_server_onprem IS BOUND.

      
      object = get_response_onprem( ).

      CALL METHOD object->(`DELETE_COOKIE`)
        EXPORTING
          name = lv_val.

    ENDIF.

  ENDMETHOD.

  METHOD get_response_cookie.

    DATA temp20 TYPE string.
    DATA lv_val LIKE temp20.
      DATA object TYPE REF TO object.
    temp20 = val.
    
    lv_val = temp20.

    IF mo_server_onprem IS BOUND.

      
      object = get_response_onprem( ).

      CALL METHOD object->(`GET_COOKIE`)
        EXPORTING
          name  = lv_val
        IMPORTING
          value = result.

      " reading a response cookie has no released counterpart in ABAP
      " Cloud - there is nothing to answer with there
    ENDIF.

  ENDMETHOD.

  METHOD get_header_field.

    DATA temp21 TYPE string.
    DATA lv_val LIKE temp21.
      DATA object TYPE REF TO object.
    temp21 = val.
    
    lv_val = temp21.

    IF mo_server_onprem IS BOUND.

      
      object = get_request_onprem( ).

      CALL METHOD object->(`GET_HEADER_FIELD`)
        EXPORTING
          name  = lv_val
        RECEIVING
          value = result.

    ELSE.

      CALL METHOD mo_request_cloud->(`IF_WEB_HTTP_REQUEST~GET_HEADER_FIELD`)
        EXPORTING
          i_name  = lv_val
        RECEIVING
          r_value = result.

    ENDIF.

  ENDMETHOD.

  METHOD set_header_field.

    DATA temp22 TYPE string.
    DATA lv_n LIKE temp22.
    DATA temp23 TYPE string.
    DATA lv_v LIKE temp23.
      DATA temp24 TYPE string.
      DATA lv_cr LIKE temp24.
      DATA temp25 TYPE string.
      DATA lv_lf LIKE temp25.
      DATA object TYPE REF TO object.
    temp22 = n.
    
    lv_n = temp22.
    
    temp23 = v.
    
    lv_v = temp23.

    " strip CR/LF from both halves before they reach the stack: a header
    " name or value that carries a line break splits the response into two
    " (response splitting), and the halves of a header are routinely
    " derived from request data by the caller. The stack may reject
    " embedded CRLF itself, but nothing here should depend on it
    IF lv_n CA zabaputil_cl_util_context=>cv_char_util_cr_lf
        OR lv_v CA zabaputil_cl_util_context=>cv_char_util_cr_lf.
      
      temp24 = zabaputil_cl_util_context=>cv_char_util_cr_lf(1).
      
      lv_cr = temp24.
      
      temp25 = zabaputil_cl_util_context=>cv_char_util_cr_lf+1(1).
      
      lv_lf = temp25.
      REPLACE ALL OCCURRENCES OF lv_cr IN lv_n WITH ``.
      REPLACE ALL OCCURRENCES OF lv_lf IN lv_n WITH ``.
      REPLACE ALL OCCURRENCES OF lv_cr IN lv_v WITH ``.
      REPLACE ALL OCCURRENCES OF lv_lf IN lv_v WITH ``.
    ENDIF.

    IF mo_server_onprem IS BOUND.

      
      object = get_response_onprem( ).

      CALL METHOD object->(`SET_HEADER_FIELD`)
        EXPORTING
          name  = lv_n
          value = lv_v.

    ELSE.

      CALL METHOD mo_response_cloud->(`IF_WEB_HTTP_RESPONSE~SET_HEADER_FIELD`)
        EXPORTING
          i_name  = lv_n
          i_value = lv_v.

    ENDIF.

  ENDMETHOD.

  METHOD factory.

    CREATE OBJECT result.
    result->mo_server_onprem = server.

  ENDMETHOD.

  METHOD factory_cloud.

    CREATE OBJECT result.
    result->mo_request_cloud  = req.
    result->mo_response_cloud = res.

  ENDMETHOD.

  METHOD get_cdata.
      DATA object TYPE REF TO object.

    IF mo_server_onprem IS BOUND.

      
      object = get_request_onprem( ).

      CALL METHOD object->(`GET_CDATA`)
        RECEIVING
          data = result.

    ELSE.

      CALL METHOD mo_request_cloud->(`IF_WEB_HTTP_REQUEST~GET_TEXT`)
        RECEIVING
          r_value = result.

    ENDIF.

  ENDMETHOD.

  METHOD get_method.
      DATA object TYPE REF TO object.

    IF mo_server_onprem IS BOUND.

      
      object = get_request_onprem( ).

      CALL METHOD object->(`IF_HTTP_REQUEST~GET_METHOD`)
        RECEIVING
          method = result.

    ELSE.

      CALL METHOD mo_request_cloud->(`IF_WEB_HTTP_REQUEST~GET_METHOD`)
        RECEIVING
          r_value = result.

    ENDIF.

  ENDMETHOD.

  METHOD set_cdata.
      DATA object TYPE REF TO object.

    IF mo_server_onprem IS BOUND.

      
      object = get_response_onprem( ).

      CALL METHOD object->(`SET_CDATA`)
        EXPORTING
          data = val.

    ELSE.

      CALL METHOD mo_response_cloud->(`IF_WEB_HTTP_RESPONSE~SET_TEXT`)
        EXPORTING
          i_text = val.

    ENDIF.

  ENDMETHOD.

  METHOD set_status.

    DATA temp26 TYPE string.
    DATA lv_reason LIKE temp26.
      DATA object TYPE REF TO object.
    temp26 = reason.
    
    lv_reason = temp26.

    IF mo_server_onprem IS BOUND.

      
      object = get_response_onprem( ).

      CALL METHOD object->(`IF_HTTP_RESPONSE~SET_STATUS`)
        EXPORTING
          code   = code
          reason = lv_reason.

    ELSE.

      CALL METHOD mo_response_cloud->(`IF_WEB_HTTP_RESPONSE~SET_STATUS`)
        EXPORTING
          i_code   = code
          i_reason = lv_reason.

    ENDIF.

  ENDMETHOD.

  METHOD set_session_stateful.

    IF mo_server_onprem IS BOUND.

      CALL METHOD mo_server_onprem->(`SET_SESSION_STATEFUL`)
        EXPORTING
          stateful = val.

      " stateful sessions are not released in ABAP Cloud - no-op there
    ENDIF.

  ENDMETHOD.

  METHOD get_req_info.

    result-body     = get_cdata( ).
    result-method   = get_method( ).
    result-path     = get_header_field( `~path` ).
    result-t_params = zabaputil_cl_util_context=>url_param_get_tab( get_header_field( `~request_uri` ) ).

  ENDMETHOD.

  METHOD get_request_onprem.
      FIELD-SYMBOLS <any> TYPE any.

    IF mo_request_onprem IS NOT BOUND.
      
      ASSIGN mo_server_onprem->(`REQUEST`) TO <any>.
      ASSERT sy-subrc = 0.
      mo_request_onprem = <any>.
    ENDIF.

    result = mo_request_onprem.

  ENDMETHOD.

  METHOD get_response_onprem.
      FIELD-SYMBOLS <any> TYPE any.

    IF mo_response_onprem IS NOT BOUND.
      
      ASSIGN mo_server_onprem->(`RESPONSE`) TO <any>.
      ASSERT sy-subrc = 0.
      mo_response_onprem = <any>.
    ENDIF.

    result = mo_response_onprem.

  ENDMETHOD.

ENDCLASS.
