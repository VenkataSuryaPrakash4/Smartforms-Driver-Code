*&---------------------------------------------------------------------*
*& report zpro_report
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
report zpro_report.
tables: vbak.

types:begin of ty_final,
        vbeln type VBELN_VA,
        posnr type POSNR_VA,
        matnr type matnr,
        matkl type matkl,
        werks type WERKS_D,
      end of ty_final.

data: lt_final   type table of zstru_sf,
      lv_fm_name type rs38l_fnam,
      lwa_final  type zstru_sf.

selection-screen begin of block blk_1 with frame title tit_1.
select-options: s_vbeln for vbak-vbeln.
parameters: c_check as checkbox.
selection-screen end of block blk_1.


select vbeln, vbtyp
  into table @data(lt_vbak)
  from vbak
*  up to 10 rows.
  where vbeln in @s_vbeln.

if lt_vbak[] is not initial.
  select vbeln, posnr, matnr
       from vbap
    into table @data(lt_vbap)
    for all entries in @lt_vbak
    where vbeln eq @lt_vbak-vbeln.
endif.

if lt_vbap[] is not initial.
  select matnr,matkl
    into table @data(lt_mara)
    from mara
    for all entries in @lt_vbap
    where matnr eq @lt_vbap-matnr.
endif.

if lt_vbap[] is not initial.
  select matnr, werks
    into table @data(lt_marc)
    from marc
    for all entries in @lt_vbap
    where matnr eq @lt_vbap-matnr.
endif.


loop at lt_vbap into data(wa_vbap).
  lwa_final-vbeln = wa_vbap-vbeln.
  lwa_final-posnr = wa_vbap-posnr.
  lwa_final-matnr = wa_vbap-matnr.

  read table lt_mara into data(wa_mara) with key matnr = wa_vbap-matnr.
  lwa_final-matkl = wa_mara-matkl.

  read table lt_marc into data(wa_marc) with key matnr = wa_vbap-matnr.
  lwa_final-werks = wa_marc-werks.

  append lwa_final to lt_final.
  clear: wa_vbap,lwa_final,wa_mara,wa_marc.
endloop.


***fm for calling the smart forms.
call function 'SSF_FUNCTION_MODULE_NAME'
  exporting
    formname           = 'ZPRO_SF'
  importing
    fm_name            = lv_fm_name
  exceptions
    no_form            = 1
    no_function_module = 2
    others             = 3.

***fm for assigning the table to interface in smart forms.
CALL FUNCTION lv_fm_name
  TABLES
    T_PROJECT                  = lt_final
 EXCEPTIONS
   FORMATTING_ERROR           = 1
   INTERNAL_ERROR             = 2
   SEND_ERROR                 = 3
   USER_CANCELED              = 4
   OTHERS                     = 5.

if sy-subrc = 0.
endif.
