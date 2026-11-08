CLASS lhc_Technician DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR Technician RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR Technician RESULT result.

    METHODS normalizeTech FOR DETERMINE ON MODIFY
      IMPORTING keys FOR Technician~normalizeTech.

          METHODS warnSaudization FOR VALIDATE ON SAVE
      IMPORTING keys FOR Technician~warnSaudization.

ENDCLASS.

CLASS lhc_Technician IMPLEMENTATION.

  METHOD warnSaudization.
    READ ENTITIES OF zi_technician IN LOCAL MODE
      ENTITY Technician
        FIELDS ( Department Nationality )
        WITH CORRESPONDING #( keys )
      RESULT DATA(techs).

    LOOP AT techs INTO DATA(t) WHERE Department IS NOT INITIAL.
      SELECT COUNT( * ) FROM ztechnician
        WHERE department = @t-Department
        INTO @DATA(lv_total).
      SELECT COUNT( * ) FROM ztechnician
        WHERE department = @t-Department
          AND nationality = 'SAUDI'
        INTO @DATA(lv_saudi).
      IF lv_total = 0.
        CONTINUE.
      ENDIF.

      DATA(lv_new)    = COND i( WHEN t-Nationality = 'SAUDI' THEN 1 ELSE 0 ).
      DATA(lv_before) = CONV decfloat34( lv_saudi ) * 100 / lv_total.
      DATA(lv_after)  = CONV decfloat34( lv_saudi + lv_new ) * 100 / ( lv_total + 1 ).

      IF zcl_saudi_band=>band_of( lv_after ) < zcl_saudi_band=>band_of( lv_before ).
        APPEND VALUE #( %tky = t-%tky
                        %msg = new_message_with_text(
                                 severity = if_abap_behv_message=>severity-warning
                                 text     = |This hire lowers { t-Department } from { lv_before DECIMALS = 1 }% to { lv_after DECIMALS = 1 }%| ) )
          TO reported-technician.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD get_global_authorizations.
    result-%create = if_abap_behv=>auth-allowed.
    result-%update = if_abap_behv=>auth-allowed.
    result-%delete = if_abap_behv=>auth-allowed.
  ENDMETHOD.

  METHOD normalizeTech.
    READ ENTITIES OF zi_technician IN LOCAL MODE
      ENTITY Technician
        FIELDS ( Department Nationality )
        WITH CORRESPONDING #( keys )
      RESULT DATA(techs).

    DATA updates TYPE TABLE FOR UPDATE zi_technician.
    LOOP AT techs INTO DATA(t).
      IF t-Department <> to_upper( t-Department )
         OR t-Nationality <> to_upper( t-Nationality ).
        APPEND VALUE #( %tky        = t-%tky
                        Department  = to_upper( t-Department )
                        Nationality = to_upper( t-Nationality ) ) TO updates.
      ENDIF.
    ENDLOOP.
    CHECK updates IS NOT INITIAL.

    MODIFY ENTITIES OF zi_technician IN LOCAL MODE
      ENTITY Technician
        UPDATE FIELDS ( Department Nationality )
        WITH updates.
  ENDMETHOD.

ENDCLASS.
