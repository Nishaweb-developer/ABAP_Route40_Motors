CLASS lhc_Technician DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      keys REQUEST requested_authorizations FOR Technician RESULT result.

       METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
  REQUEST requested_authorizations FOR Technician RESULT result.

ENDCLASS.

CLASS lhc_Technician IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

   METHOD get_global_authorizations.
  result-%create = if_abap_behv=>auth-allowed.
  result-%update = if_abap_behv=>auth-allowed.
  result-%delete = if_abap_behv=>auth-allowed.
ENDMETHOD.

ENDCLASS.
