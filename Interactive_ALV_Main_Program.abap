
*&---------------------------------------------------------------------*
*& Report ZDUMMY_DB
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zdummy_db.
************************
***Data Declerations.
************************
TYPES: BEGIN OF ty_final,
         emp_id          TYPE zemployee_id,
         emp_name        TYPE zemployee_name,
         emp_age         TYPE zemployee_age,
         first_name      TYPE zemp_fname,
         last_name       TYPE zemp_lname,
         branch          TYPE zde_branch,
         employee_salary TYPE dmbtr,
         mobile_number   TYPE zemp_mobile,
       END OF ty_final.

DATA: lt_screen     TYPE TABLE OF screen,
      a             TYPE zemployee_id,
      lv_field      TYPE zemployee_id,
      lv_value      TYPE char50,
      lv_com        LIKE sy-ucomm,
      lv_count      TYPE i VALUE 0,
      lv_count1     TYPE i VALUE 0,
      lv_count2     TYPE i VALUE 0,
      lv_count3     TYPE i VALUE 0,
      gt_final      TYPE TABLE OF ty_final,
      gwa_final     TYPE ty_final,
      lt_returntab  TYPE TABLE OF ddshretval,
      lt_emp_p_info TYPE TABLE OF  zemployee_p_info,
      gt_emp1       TYPE TABLE OF zemployee_info,
      gt_emp2       TYPE TABLE OF zemployee_p_info,
      gt_emp3       TYPE TABLE OF zemp_sal_info,
      gwa_emp1      TYPE zemployee_info,
      gwa_emp2      TYPE zemployee_p_info,
      gwa_emp3      TYPE zemp_sal_info,
      gt_fldcat1    TYPE TABLE OF slis_fieldcat_alv,
      gt_fldcat2    TYPE TABLE OF slis_fieldcat_alv,
      gt_fldcat3    TYPE slis_t_fieldcat_alv,
      gt_fldcat4    TYPE TABLE OF slis_fieldcat_alv,
      gwa_layout1   TYPE slis_layout_alv,
      gwa_layout2   TYPE slis_layout_alv.


*********************************************
***Radio buttons to choose DB table postings.
**********************************************
SELECTION-SCREEN BEGIN OF BLOCK text-001 WITH FRAME TITLE TEXT-002.
PARAMETERS: rb_1 RADIOBUTTON GROUP grp USER-COMMAND ucom,
            rb_2 RADIOBUTTON GROUP grp,
            rb_3 RADIOBUTTON GROUP grp DEFAULT 'X',
            rb_4 RADIOBUTTON GROUP grp,
            rb_5 RADIOBUTTON GROUP grp.
SELECTION-SCREEN END OF BLOCK text-001.

****************************
***Includes for SS and CD***
****************************
INCLUDE zselection_screen.
INCLUDE zcode_development.

*****************************************
**SS for Screen Manipulations: Postings
*****************************************
AT SELECTION-SCREEN OUTPUT.
  LOOP AT SCREEN INTO DATA(lwa_screen).
    IF rb_1 EQ abap_true AND ( lwa_screen-group1 EQ 'BBB' OR lwa_screen-group1 EQ 'CCC' OR lwa_screen-group1 EQ 'DDD').
      lwa_screen-active = 0.

    ELSEIF rb_2 EQ abap_true AND ( lwa_screen-group1 EQ 'CCC' OR lwa_screen-group1 EQ 'AAA' OR lwa_screen-group1 EQ 'DDD' ).
      lwa_screen-active = 0.

    ELSEIF rb_3 EQ abap_true AND ( lwa_screen-group1 EQ 'AAA' OR lwa_screen-group1 EQ 'BBB' OR lwa_screen-group1 EQ 'DDD' ).
      lwa_screen-active = 0.

    ELSEIF rb_4 EQ abap_true AND ( lwa_screen-group1 EQ 'AAA' OR lwa_screen-group1 EQ 'BBB' OR lwa_screen-group1 EQ 'CCC' OR lwa_screen-group1 EQ 'DDD').
      lwa_screen-active = 0.

    ELSEIF rb_5 EQ abap_true AND ( lwa_screen-group1 EQ 'AAA' OR lwa_screen-group1 EQ 'BBB' OR lwa_screen-group1 EQ 'CCC').
      lwa_screen-active = 0.
    ENDIF.

    MODIFY screen FROM lwa_screen.
    CLEAR:lwa_screen.
  ENDLOOP.

*************************************************
*****SS for F4 Functionality to Input Field******
*************************************************
AT SELECTION-SCREEN ON VALUE-REQUEST FOR :p_pid.

  SELECT emp_id
    INTO TABLE @DATA(lt_empf4)
    FROM zemployee_info.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = 'EMP_ID'
      value_org       = 'S'
    TABLES
      value_tab       = lt_empf4
      return_tab      = lt_returntab
    EXCEPTIONS
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.

  IF sy-subrc EQ 0.
    READ TABLE lt_returntab INTO DATA(lwa_returntab) INDEX 1.
    p_pid = lwa_returntab-fieldval.
*    p_empid = lwa_returntab-fieldval.
  ENDIF.

**********************
****Business Logic****
**********************
START-OF-SELECTION.
  PERFORM postings.

  IF rb_4 EQ abap_true.

***Fetching from respective DB's.
    SELECT *
      INTO TABLE @DATA(lt_emp_info)
      FROM zemployee_info.

    SELECT *
        INTO TABLE @lt_emp_p_info
        FROM zemployee_p_info
        FOR ALL ENTRIES IN @lt_emp_info
        WHERE emloyee_id = @lt_emp_info-emp_id.

    SELECT *
     INTO TABLE @DATA(lt_emp_s_info)
     FROM zemp_sal_info
     FOR ALL ENTRIES IN @lt_emp_p_info
     WHERE employee_id = @lt_emp_p_info-emloyee_id.

************************
**Basic List in ALV Grid.
************************
    LOOP AT lt_emp_info INTO DATA(lwa_emp).
      gwa_emp1-emp_id = lwa_emp-emp_id.
      gwa_emp1-emp_name = lwa_emp-emp_name.
      gwa_emp1-emp_age = lwa_emp-emp_age.
      APPEND gwa_emp1 TO gt_emp1.
      CLEAR: lwa_emp,gwa_emp1.
    ENDLOOP.

********************
***Display ALV Grid.
********************

***Layout.
    gwa_layout1-zebra = 'X'.
    gwa_layout1-colwidth_optimize = 'X'.

***Field catalog.
    ADD 1 TO lv_count.
    APPEND VALUE #( col_pos = lv_count fieldname = 'EMP_ID' seltext_m = 'Employee Id' key = 'X') TO gt_fldcat1.

    ADD 1 TO lv_count.
    APPEND VALUE #( col_pos = lv_count fieldname = 'EMP_NAME' seltext_m = 'Employee Name' ) TO gt_fldcat1.

    ADD 1 TO lv_count.
    APPEND VALUE #( col_pos = lv_count fieldname = 'EMP_AGE' seltext_m = 'Employee Age' ) TO gt_fldcat1.

    CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
      EXPORTING
        i_callback_program      = sy-repid
        i_callback_user_command = 'CLICK'
        i_grid_title            = 'Employee Information'
        is_layout               = gwa_layout1
        it_fieldcat             = gt_fldcat1
      TABLES
        t_outtab                = gt_emp1
      EXCEPTIONS
        program_error           = 1
        OTHERS                  = 2.

    CLEAR: lv_count.

***Upon choosing ALV Report radio button.

  ELSEIF rb_5 EQ abap_true.

    SELECT *
      INTO TABLE @DATA(lt_emp_info11)
      FROM zemployee_info
      WHERE emp_id IN @s_id.

    SELECT *
        INTO TABLE @DATA(lt_emp_p_info22)
        FROM zemployee_p_info
        FOR ALL ENTRIES IN @lt_emp_info11
        WHERE emloyee_id = @lt_emp_info11-emp_id.

    SELECT *
     INTO TABLE @DATA(lt_emp_s_info33)
     FROM zemp_sal_info
     FOR ALL ENTRIES IN @lt_emp_p_info22
     WHERE employee_id = @lt_emp_p_info22-emloyee_id.

***Mapping to Final Internal table.

    LOOP AT lt_emp_s_info33 INTO DATA(lwa_temp3).
      gwa_final-emp_id = lwa_temp3-employee_id.
      gwa_final-branch = lwa_temp3-branch.
      gwa_final-employee_salary = lwa_temp3-employee_salary.
      gwa_final-mobile_number = lwa_temp3-mobile_number.

      READ TABLE lt_emp_p_info22 INTO DATA(lwa_temp2) WITH KEY emloyee_id = lwa_temp3-employee_id.
      IF sy-subrc EQ 0.
        gwa_final-first_name = lwa_temp2-first_name.
        gwa_final-last_name = lwa_temp2-last_name.
        READ TABLE lt_emp_info11 INTO DATA(lwa_temp1) WITH KEY emp_id = lwa_temp2-emloyee_id.
        IF sy-subrc EQ 0.
          gwa_final-emp_id = lwa_temp1-emp_id.
          gwa_final-emp_name = lwa_temp1-emp_name.
          gwa_final-emp_age = lwa_temp1-emp_age.
        ENDIF.
      ENDIF.

***Appending to Final Internal table.
      APPEND gwa_final TO gt_final.
      CLEAR: lwa_temp1,lwa_temp2.
    ENDLOOP.

***layout.
    gwa_layout2-zebra = 'X'.

***Fieldcatalog.
    ADD 1 TO lv_count3.
    APPEND VALUE #( col_pos = lv_count3 fieldname = 'EMP_ID' seltext_m = 'Employee Id' key = 'X') TO gt_fldcat4.

    ADD 1 TO lv_count3.
    APPEND VALUE #( col_pos = lv_count3 fieldname = 'EMP_NAME' seltext_m = 'Employee Name' ) TO gt_fldcat4.

    ADD 1 TO lv_count3.
    APPEND VALUE #( col_pos = lv_count3 fieldname = 'EMP_AGE' seltext_m = 'Employee Age' ) TO gt_fldcat4.

    ADD 1 TO lv_count3.
    APPEND VALUE #( col_pos = lv_count3 fieldname = 'FIRST_NAME' seltext_m = 'First Name' ) TO gt_fldcat4.

    ADD 1 TO lv_count3.
    APPEND VALUE #( col_pos = lv_count3 fieldname = 'LAST_NAME' seltext_m = 'Last Name' ) TO gt_fldcat4.

    ADD 1 TO lv_count3.
    APPEND VALUE #( col_pos = lv_count3 fieldname = 'BRANCH' seltext_m = 'Branch' ) TO gt_fldcat4.

    ADD 1 TO lv_count3.
    APPEND VALUE #( col_pos = lv_count3 fieldname = 'EMPLOYEE_SALARY' seltext_m = 'Salary' do_sum = 'X' ) TO gt_fldcat4.

    ADD 1 TO lv_count3.
    APPEND VALUE #( col_pos = lv_count3 fieldname = 'MOBILE_NUMBER' seltext_m = 'Mobile Number' ) TO gt_fldcat4.

    CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
      EXPORTING
        i_callback_program = sy-repid
        i_grid_title       = 'Employee Information'
        is_layout          = gwa_layout2
        it_fieldcat        = gt_fldcat4
      TABLES
        t_outtab           = gt_final
      EXCEPTIONS
        program_error      = 1
        OTHERS             = 2.

  ENDIF.

FORM click USING command LIKE sy-ucomm
                       index TYPE slis_selfield.
  IF command EQ '&IC1'.
    READ TABLE gt_emp1 INTO gwa_emp1 INDEX index-tabindex.
    IF sy-subrc EQ 0.
* Approach-1.
*      READ TABLE lt_emp_p_info INTO DATA(lwa_emp2) WITH KEY emloyee_id = gwa_emp1-emp_id.
*      WRITE :/ lwa_emp2-emloyee_id, lwa_emp2-first_name, lwa_emp2-last_name.

******************
* Approach-2.
      LOOP AT lt_emp_p_info INTO DATA(lwa_emp2) WHERE emloyee_id = gwa_emp1-emp_id.
        gwa_emp2-emloyee_id = lwa_emp2-emloyee_id.
        gwa_emp2-first_name = lwa_emp2-first_name.
        gwa_emp2-last_name = lwa_emp2-last_name.
        APPEND gwa_emp2 TO gt_emp2.
        CLEAR: lwa_emp2,gwa_emp2.
      ENDLOOP.

******************
* Approach-3.
*      SELECT *
*        INTO TABLE @DATA(lt_pemp_tab)
*        FROM zemployee_p_info
*        WHERE emloyee_id = @gwa_emp1-emp_id.

***Field catalog.
      ADD 1 TO lv_count1.
      APPEND VALUE #( col_pos = lv_count fieldname = 'EMLOYEE_ID' seltext_m = 'Employee Id'  key = 'X') TO gt_fldcat2.

      ADD 1 TO lv_count1.
      APPEND VALUE #( col_pos = lv_count fieldname = 'FIRST_NAME' seltext_m = 'First Name' ) TO gt_fldcat2.

      ADD 1 TO lv_count1.
      APPEND VALUE #( col_pos = lv_count fieldname = 'LAST_NAME' seltext_m = 'Last Name' ) TO gt_fldcat2.

      CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
        EXPORTING
          i_callback_program      = sy-repid
          i_callback_user_command = 'SEC'
          i_grid_title            = 'Employee Personal Information'
          it_fieldcat             = gt_fldcat2
        TABLES
          t_outtab                = gt_emp2
        EXCEPTIONS
          program_error           = 1
          OTHERS                  = 2.
      CLEAR:gt_emp2,lv_count1,gt_fldcat2.
    ENDIF.
  ENDIF.
ENDFORM.

FORM sec USING sec1 LIKE sy-ucomm
                    sec2 TYPE slis_selfield.
  lv_com = sec1.
  IF lv_com EQ '&IC1'.
    READ TABLE gt_emp2 INTO DATA(lwa_emp5) INDEX sec2-tabindex.
    IF sy-subrc EQ 0.
      LOOP AT lt_emp_s_info INTO DATA(lwa_emp3) WHERE employee_id = lwa_emp5-emloyee_id.
        gwa_emp3-employee_id = lwa_emp3-employee_id.
        gwa_emp3-branch = lwa_emp3-branch.
        gwa_emp3-employee_salary = lwa_emp3-employee_salary.
        gwa_emp3-mobile_number = lwa_emp3-mobile_number.
        APPEND gwa_emp3 TO gt_emp3.

        CLEAR: gwa_emp3,lwa_emp3,lwa_emp5.
      ENDLOOP.

***Field Catalog.
      ADD 1 TO lv_count2.
      APPEND VALUE #( col_pos = lv_count fieldname = 'EMPLOYEE_ID' seltext_m = 'Employee Id'  key = 'X') TO gt_fldcat3.

      ADD 1 TO lv_count2.
      APPEND VALUE #( col_pos = lv_count fieldname = 'BRANCH' seltext_m = 'Branch' ) TO gt_fldcat3.

      ADD 1 TO lv_count2.
      APPEND VALUE #( col_pos = lv_count fieldname = 'EMPLOYEE_SALARY' seltext_m = 'Salary' ) TO gt_fldcat3.

      ADD 1 TO lv_count2.
      APPEND VALUE #( col_pos = lv_count fieldname = 'MOBILE_NUMBER' seltext_m = 'Mobile Number' ) TO gt_fldcat3.


      CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
        EXPORTING
          i_callback_program = sy-repid
*         i_grid_title       = 'Salary Information'
          it_fieldcat        = gt_fldcat3
        TABLES
          t_outtab           = gt_emp3
        EXCEPTIONS
          program_error      = 1
          OTHERS             = 2.

      CLEAR: gt_fldcat3,gt_emp3.
    ENDIF.
  ENDIF.
ENDFORM.

**************************************************************
*********************END OF MAIN PROGRAM**********************
**************************************************************

*AT LINE-SELECTION.
*  CASE sy-lsind.
*    WHEN 1.
*      GET CURSOR FIELD lv_field VALUE lv_value.
*      LOOP AT lt_emp_p_info INTO DATA(lwa_emp1) WHERE emloyee_id = lv_value.
*        DATA(lv_pos) = sy-lsind.
*        WRITE :/ lwa_emp1-emloyee_id, lwa_emp1-first_name, lwa_emp1-last_name.
*        CLEAR: lwa_emp1,lv_field,lv_value.
*      ENDLOOP.
*    WHEN 2.
*      GET CURSOR FIELD lv_field VALUE lv_value.
*      LOOP AT lt_emp_s_info INTO DATA(lwa_emp3) WHERE employee_id = lv_value.
*        WRITE :/ lwa_emp3-employee_id, lwa_emp3-branch, lwa_emp3-employee_salary, lwa_emp3-mobile_number.
*        CLEAR: lwa_emp3.
*      ENDLOOP.
*    WHEN 3.
*      sy-lsind = sy-lsind - 3.
*
*  ENDCASE.
