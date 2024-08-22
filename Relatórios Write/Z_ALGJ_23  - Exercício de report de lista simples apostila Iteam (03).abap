REPORT Z_ALGJ_23.

TYPES:

  BEGIN OF type_vbak,
    vbeln TYPE vbak-vbeln,
    erdat TYPE vbak-erdat,
    auart TYPE vbak-auart,
    kunnr TYPE vbak-kunnr,
  END OF type_vbak,

  BEGIN OF type_vbap,
    vbeln  TYPE vbap-vbeln,
    posnr  TYPE vbap-posnr,
    matnr  TYPE vbap-matnr,
    kwmeng TYPE vbap-kwmeng,
    netwr  TYPE vbap-netwr,
  END OF type_vbap.

DATA:
  ti_vbak TYPE TABLE OF type_vbak,
  ti_vbap TYPE TABLE OF type_vbap.

DATA:
  wa_vbak TYPE type_vbak,
  wa_vbap TYPE type_vbap.

DATA:
  v_emissor  TYPE vbak-kunnr,
  v_contador TYPE i.

SELECT vbeln
       erdat
       auart
       kunnr
  FROM vbak
  INTO TABLE ti_vbak.

IF sy-subrc = 0.

  LOOP AT ti_vbak INTO wa_vbak.
    IF wa_vbak-erdat+4(2) <> '08'.
      DELETE ti_vbak INDEX sy-tabix.
    ENDIF.
  ENDLOOP.

ELSE.

  FREE ti_vbak.
  MESSAGE 'Dados não encontrados!' TYPE 'S' DISPLAY LIKE 'E'.
  LEAVE LIST-PROCESSING.

ENDIF.

IF ti_vbak IS NOT INITIAL.

  SELECT vbeln
         posnr
         matnr
         kwmeng
         netwr
    FROM vbap
    INTO TABLE ti_vbap
     FOR ALL ENTRIES IN ti_vbak
   WHERE vbeln = ti_vbak-vbeln.

  IF sy-subrc <> 0.

    FREE ti_vbap.
    MESSAGE 'Dados não encontrados!' TYPE 'S' DISPLAY LIKE 'E'.
    LEAVE LIST-PROCESSING.

  ENDIF.

ENDIF.

SORT: ti_vbak BY vbeln,
      ti_vbap BY vbeln.


LOOP AT ti_vbak INTO wa_vbak.

  READ TABLE ti_vbap INTO wa_vbap WITH KEY
                                  vbeln = wa_vbak-vbeln BINARY SEARCH.

  IF sy-tabix <> 1.
    v_contador = v_contador + 1.
  ENDIF.

  IF v_emissor NE wa_vbak-kunnr.


    FORMAT RESET.

    IF sy-tabix <> 1.
      ULINE.
      WRITE:/ 'Emissor: ', v_emissor.
      WRITE:/ 'Total de Registros: ', v_contador.

      CLEAR v_contador.
    ENDIF.

    v_emissor = wa_vbak-kunnr.

    FORMAT COLOR COL_HEADING INTENSIFIED ON.
    ULINE.
    WRITE: /01 '|', 'Emissor',
            15 '|', 'Tipo de doc.',
            30 '|', 'Data de criaçãodo',
            60 '|', 'Doc. de vendas',
            80 '|', 'Item do doc. vendas',
           100 '|', 'N° do material',
           120 '|', 'Quantidade da ordem',
           140 '|', 'Valor líquido do item',
           180 '|'.
    ULINE.

  ENDIF.

  FORMAT RESET.
  WRITE:
        /01 '|', wa_vbak-kunnr,
         15 '|', wa_vbak-auart,
         30 '|', wa_vbak-erdat,
         60 '|', wa_vbak-vbeln,
         80 '|', wa_vbap-posnr,
        100 '|', wa_vbap-matnr,
        120 '|', wa_vbap-kwmeng,
        140 '|', wa_vbap-netwr,
        180 '|'.


ENDLOOP.