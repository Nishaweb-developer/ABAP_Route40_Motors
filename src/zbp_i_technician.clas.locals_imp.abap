CLASS lhc_Technician DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR Technician RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR Technician RESULT result.

    METHODS normalizeTech FOR DETERMINE ON MODIFY
      IMPORTING keys FOR Technician~normalizeTech.

ENDCLASS.

CLASS lhc_Technician IMPLEMENTATION.

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
