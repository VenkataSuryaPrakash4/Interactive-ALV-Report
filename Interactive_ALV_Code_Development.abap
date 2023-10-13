*&---------------------------------------------------------------------*
*& Include          ZCODE_DEVELOPMENT
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form POSTINGS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM postings .

***Data Decleration.
  DATA: lwa_dummy TYPE zemployee_info,
        lwa_pinfo TYPE  zemployee_p_info,
        lt_fixed  TYPE TABLE OF dd07v,
        lv_flag1  TYPE c,
        lv_concat TYPE string,
        lv_flag2  TYPE c,
        lv_flag3  TYPE c,
        lv_type   TYPE dd01v-datatype,
        lwa_sinfo TYPE zemp_sal_info.

*************************************************
*********Employee Postings Validations***********
*************************************************
  IF rb_1 EQ abap_true.

***Validating Employee Id field.
    IF p_id IS NOT INITIAL.
      CALL FUNCTION 'NUMERIC_CHECK'
        EXPORTING
          string_in = p_id
        IMPORTING
          htype     = lv_type.

      IF sy-subrc EQ 0 AND lv_type EQ 'NUMC'.
        lwa_dummy-emp_id = p_id.
        CLEAR: lv_type.
      ELSE.
        lv_flag1 = 'X'.
        MESSAGE 'Employee Id should be numeric value.' TYPE 'S' DISPLAY LIKE 'E'.
      ENDIF.
    ELSE.
      lv_flag1 = 'X'.
      MESSAGE 'Employee Id cannot be empty.' TYPE 'S' DISPLAY LIKE 'E'.
    ENDIF.

***Validating Employee name field.
    IF p_name IS NOT INITIAL.
      CALL FUNCTION 'NUMERIC_CHECK'
        EXPORTING
          string_in = p_name
        IMPORTING
          htype     = lv_type.
      IF sy-subrc EQ 0 AND lv_type EQ 'CHAR'.
        lwa_dummy-emp_name = p_name.
        CLEAR: lv_type.
      ELSE.
        lv_flag1 = 'X'.
        MESSAGE 'Employee Name should be Text value.' TYPE 'S' DISPLAY LIKE 'E'.
      ENDIF.
    ELSE.
      lv_flag1 = 'X'.
      MESSAGE 'Employee name cannot be empty.' TYPE 'S' DISPLAY LIKE 'E'.
    ENDIF.
***Validating Employee Age field.

    IF p_age IS NOT INITIAL.
      lwa_dummy-emp_age = p_age.
    ELSE.
      lv_flag1 = 'X'.
      MESSAGE 'Employee Age cannot be empty.' TYPE 'S' DISPLAY LIKE 'E'.
    ENDIF.
***Validating Posting.
    IF lv_flag1 NE 'X'.
      MODIFY zemployee_info FROM lwa_dummy.
    ENDIF.

***************************************************
***Employee Personal Information Table Postings****
***************************************************
  ELSEIF rb_2 EQ abap_true.
    SELECT emp_id
      INTO TABLE @DATA(lt_emp)
      FROM zemployee_info.

***Validating Employee Id field.
    IF p_pid IS NOT INITIAL.
      IF lt_emp IS NOT INITIAL.
        READ TABLE lt_emp WITH KEY emp_id = p_pid TRANSPORTING NO FIELDS.
        IF sy-subrc EQ 0.
          lwa_pinfo-emloyee_id = p_pid.

        ELSE.
          lv_flag2 = 'X'.
          lv_concat = |Employee ID: | & |{ p_pid }| & | doesn't exist in ZEmployee_info Table. Please enter valid Employee ID. |.
          MESSAGE lv_concat TYPE 'S' DISPLAY LIKE 'E'.
        ENDIF.
      ENDIF.

    ELSEIF p_pid IS INITIAL.
      lv_flag2 = 'X'.
      MESSAGE 'Employee Id cannot be empty.' TYPE 'S' DISPLAY LIKE 'E'.
    ENDIF.
***Validating Employee First Name.
    IF p_firstn IS NOT INITIAL.
      CALL FUNCTION 'NUMERIC_CHECK'
        EXPORTING
          string_in = p_firstn
        IMPORTING
          htype     = lv_type.
      IF sy-subrc EQ 0.
        IF lv_type NE 'NUMC'.
          lwa_pinfo-first_name = p_firstn.
        ELSE.
          lv_flag2 = 'X'.
          MESSAGE 'Employee First Name cannot be number.' TYPE 'S' DISPLAY LIKE 'E'.
        ENDIF.
      ENDIF.
    ELSE.
      lv_flag2 = 'X'.
      MESSAGE 'Employee First Name cannot be empty.' TYPE 'S' DISPLAY LIKE 'E'.
    ENDIF.

***Validating Employee Last Name.
    IF p_lname IS NOT INITIAL.
      CALL FUNCTION 'NUMERIC_CHECK'
        EXPORTING
          string_in = p_lname
        IMPORTING
          htype     = lv_type.
      IF sy-subrc EQ 0.
        IF lv_type NE 'NUMC'.
          lwa_pinfo-last_name = p_lname.
        ELSE.
          lv_flag2 = 'X'.
          MESSAGE 'Employee Last Name cannot be number.' TYPE 'S' DISPLAY LIKE 'E'.
        ENDIF.
      ENDIF.
    ELSE.
      lv_flag2 = 'X'.
      MESSAGE 'Employee Last Name cannot be empty.' TYPE 'S' DISPLAY LIKE 'E'.
    ENDIF.
    IF lv_flag2 NE 'X'.
      MODIFY zemployee_p_info FROM lwa_pinfo.
    ENDIF.
    CLEAR: lv_concat.

************************************************
***Employee Salary Information Table Postings***
************************************************
  ELSEIF rb_3 EQ abap_true.
    SELECT emp_id
      INTO TABLE @DATA(lt_emp1)
      FROM zemployee_info.

***Validating Employee Id Field.
    IF p_empid IS NOT INITIAL.
      IF lt_emp1 IS NOT INITIAL.
        READ TABLE lt_emp1 WITH KEY emp_id =  p_empid TRANSPORTING NO FIELDS.
        IF sy-subrc EQ 0.
          lwa_sinfo-employee_id = p_empid.
        ELSE.
          lv_flag3 = 'X'.
          lv_concat = |Employee ID: | & |{ p_empid }| & | doesn't exist in ZEmployee_info Table. Please enter valid Employee ID. |.
          MESSAGE lv_concat TYPE 'S' DISPLAY LIKE 'E'.
        ENDIF.
      ENDIF.
    ELSEIF p_empid IS INITIAL.
      lv_flag3 = 'X'.
      MESSAGE 'Employee Id cannot be empty.' TYPE 'S' DISPLAY LIKE 'E'.
    ENDIF.

***Validating Branch Code.
    IF p_branch IS NOT INITIAL.
      CALL FUNCTION 'DDUT_DOMVALUES_GET'
        EXPORTING
          name          = 'ZBRANCH'
          langu         = sy-langu
        TABLES
          dd07v_tab     = lt_fixed
        EXCEPTIONS
          illegal_input = 1
          OTHERS        = 2.

      IF sy-subrc EQ 0.
        IF lt_fixed IS NOT INITIAL.
          READ TABLE lt_fixed WITH KEY domvalue_l = p_branch TRANSPORTING NO FIELDS.
          IF sy-subrc EQ 0.
            lwa_sinfo-branch = p_branch.
          ELSE.
            lv_flag3 = 'X'.
            MESSAGE 'Choose the correct Branch code.' TYPE 'S' DISPLAY LIKE 'E'.
          ENDIF.
        ENDIF.
      ENDIF.
    ELSEIF p_branch IS INITIAL.
      lv_flag3 = 'X'.
      MESSAGE 'Employee Branch cannot be empty.' TYPE 'S' DISPLAY LIKE 'E'.
    ENDIF.

***Validating Employee Salary Field.
    IF p_salary IS NOT INITIAL.
      lwa_sinfo-employee_salary = p_salary.
    ELSE.
      lv_flag3 = 'X'.
      MESSAGE 'Employee Salary cannot be empty.' TYPE 'S' DISPLAY LIKE 'E'.
    ENDIF.

**Validating Mobile Field.

    DATA : lv_len TYPE i.
    lv_len = strlen( p_mobile ).

    IF p_mobile IS NOT INITIAL.
      CALL FUNCTION 'NUMERIC_CHECK'
        EXPORTING
          string_in = p_mobile
        IMPORTING
          htype     = lv_type.

      IF sy-subrc EQ 0.
        IF lv_type EQ 'NUMC' AND lv_len EQ 10.
          lwa_sinfo-mobile_number = p_mobile.
        ELSE.
          lv_flag3 = 'X'.
          MESSAGE 'Mobile Number must be 10 digit number.' TYPE 'S' DISPLAY LIKE 'E'.
        ENDIF.
      ENDIF.
    ELSEIF p_mobile IS INITIAL.
      lv_flag3 = 'X'.
      MESSAGE 'Mobile Number cannot be empty.' TYPE 'S' DISPLAY LIKE 'E'.
    ENDIF.

    IF lv_flag3 NE 'X'.
      MODIFY zemp_sal_info FROM lwa_sinfo.
    ENDIF.
    CLEAR:lv_concat.
  ENDIF.
ENDFORM.
