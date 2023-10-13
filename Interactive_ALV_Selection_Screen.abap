*&---------------------------------------------------------------------*
*& Include          ZSELECTION_SCREEN
*&---------------------------------------------------------------------*

***Selection Screen for Employee Information Postings.
SELECTION-SCREEN BEGIN OF BLOCK text-003 WITH FRAME TITLE TEXT-004.
PARAMETERS: p_id   TYPE char5 MODIF ID aaa,
            p_name TYPE char20 MODIF ID aaa,
            p_age  TYPE int2 MODIF ID aaa .
SELECTION-SCREEN END OF BLOCK text-003.

***Selection Screen for Employee Personal Information Postings.
SELECTION-SCREEN BEGIN OF BLOCK text-005 WITH FRAME TITLE TEXT-006.
PARAMETERS: p_pid    TYPE zemployee_id MODIF ID bbb,
            p_firstn TYPE zemp_fname MODIF ID bbb,
            p_lname  TYPE zemp_lname MODIF ID bbb.
SELECTION-SCREEN END OF BLOCK text-005.

***Selection Screen for Employee Salary Information Postings.
SELECTION-SCREEN BEGIN OF BLOCK text-007 WITH FRAME TITLE TEXT-008.
PARAMETERS: p_empid  TYPE zemployee_id MODIF ID ccc,
            p_branch TYPE zde_branch MODIF ID ccc,
            p_salary TYPE dmbtr MODIF ID ccc,
            p_mobile TYPE CHAR10 MODIF ID ccc.
SELECTION-SCREEN END OF BLOCK text-007.

****************End of Selection Screen Program******************
