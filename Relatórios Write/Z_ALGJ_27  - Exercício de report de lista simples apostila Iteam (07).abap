REPORT Z_ALGJ_27.

TYPES

  BEGIN OF type_likp,
    vbeln TYPE likp-vbeln,
    erdat TYPE likp-erdat,
    route TYPE likp-route,
  END OF type_likp,

  BEGIN OF type_lips,
    vbeln TYPE lips-vbeln,
    posnr TYPE lips-posnr,
    matnr TYPE lips-matnr,
    werks TYPE lips-werks,
    lfimg TYPE lips-lfimg,
    ntgew TYPE lips-ntgew,
  END OF type_lips,

  BEGIN OF type_tvrot,
    spras TYPE tvrot-spras,
    route TYPE tvrot-route,
    bezei TYPE tvrot-bezei,
  END OF type_tvrot.

DATA
  ti_likp  TYPE TABLE OF type_likp,
  ti_lips  TYPE TABLE OF type_lips,
  ti_tvrot TYPE TABLE OF type_tvrot.

DATA
  wa_likp  TYPE type_likp,
  wa_lips  TYPE type_lips,
  wa_tvrot TYPE type_tvrot.

DATA
  v_itinerario TYPE type_likp-route,
  v_cont_regi  TYPE i,
  v_tot_qua    TYPE type_lips-lfimg,
  v_tot_pes    TYPE type_lips-ntgew.


SELECT vbeln
       erdat
       route
  FROM likp
  INTO TABLE ti_likp.

SELECT vbeln
       posnr
       matnr
       werks
       lfimg
       ntgew
  FROM lips
  INTO TABLE ti_lips
   FOR ALL ENTRIES IN ti_likp
 WHERE vbeln = ti_likp-vbeln.

SELECT spras
       route
       bezei
  FROM tvrot
  INTO TABLE ti_tvrot
   FOR ALL ENTRIES IN ti_likp
 WHERE spras = 'PT'
   AND route = ti_likp-route.

SORT ti_likp  BY vbeln
                  route,
      ti_lips  BY vbeln,
      ti_tvrot BY route.

LOOP AT ti_likp INTO wa_likp.

  CLEAR wa_lips.
  READ TABLE ti_lips INTO wa_lips WITH KEY
                                  vbeln = wa_likp-vbeln BINARY SEARCH.

  IF sy-subrc  0.
    CONTINUE.
  ENDIF.

  CLEAR wa_tvrot.
  READ TABLE ti_tvrot INTO wa_tvrot WITH KEY
                                    route = wa_likp-route BINARY SEARCH.

  IF sy-subrc  0.
    CONTINUE.
  ENDIF.

  IF v_itinerario  wa_likp-route.

    IF v_itinerario IS NOT INITIAL.

  FORMAT RESET.
  FORMAT COLOR COL_TOTAL INTENSIFIED OFF.
  WRITE
    01 '', 50 'TOTAL', 100 '', v_tot_qua, 140 '', v_tot_pes, 170 ''.

  CLEAR v_tot_qua,
         v_tot_pes.

    ENDIF.


    FORMAT RESET.
    FORMAT COLOR COL_KEY INTENSIFIED ON.
    WRITE
      01 '', 'Itinerário',
       20 '', 'Denominação do Itinerário',
      170 ''.


    FORMAT RESET.
    FORMAT COLOR COL_HEADING INTENSIFIED OFF.
    WRITE
      01 '', wa_likp-route,
       20 '', wa_tvrot-bezei,
      170 ''.

    v_itinerario = wa_likp-route.

    FORMAT RESET.
    FORMAT COLOR COL_KEY INTENSIFIED ON.
    WRITE
      01 '', 'Fornecimento',
       20 '', 'Data de criação do registro',
       50 '', 'Item de remessa',
       70 '', 'N° do material',
       90 '', 'Centro',
      100 '', 'Quantidade fornecida de fato em UMV',
      140 '', 'Peso líquido',
      170 ''.

  ENDIF.


  FORMAT RESET.
  FORMAT COLOR COL_HEADING INTENSIFIED OFF.
  WRITE
    01 '', wa_likp-route,
     20 '', wa_likp-erdat,
     50 '', wa_lips-posnr,
     70 '', wa_lips-matnr,
     90 '', wa_lips-werks,
    100 '', wa_lips-lfimg,
    140 '', wa_lips-ntgew,
    170 ''.

v_tot_qua = v_tot_qua + wa_lips-lfimg.
v_tot_pes = v_tot_pes + wa_lips-ntgew.

v_cont_regi = v_cont_regi + 1.

ENDLOOP.

  FORMAT RESET.
  FORMAT COLOR COL_TOTAL INTENSIFIED OFF.
  WRITE
    01 '', 50 'QTDE DE REGISTROS', 100 '', v_cont_regi, 170 ''.