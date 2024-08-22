REPORT Z_ALGJ_28
LINE-SIZE 250.


TYPES:

  BEGIN OF type_vbrk,
    vbeln TYPE vbrk-vbeln,
    fkart TYPE vbrk-fkart,
    waerk TYPE vbrk-waerk,
    fkdat TYPE vbrk-fkdat,
    kunrg TYPE vbrk-kunrg,
  END OF type_vbrk,

  BEGIN OF type_vbrp,
    vbeln TYPE vbrp-vbeln,
    posnr TYPE vbrp-posnr,
    fkimg TYPE vbrp-fkimg,
    ntgew TYPE vbrp-ntgew,
    brgew TYPE vbrp-brgew,
    netwr TYPE vbrp-netwr,
    matnr TYPE vbrp-matnr,
  END OF type_vbrp,

  BEGIN OF type_kna1,
    kunnr TYPE kna1-kunnr,
    land1 TYPE kna1-land1,
    name1 TYPE kna1-name1,
    ort01 TYPE kna1-ort01,
    regio TYPE kna1-regio,
    stras TYPE kna1-stras,
  END OF type_kna1,

  BEGIN OF type_makt,
    matnr TYPE makt-matnr,
    spras TYPE makt-spras,
    maktx TYPE makt-maktx,
  END OF type_makt.

DATA: ti_vbrk     TYPE TABLE OF type_vbrk,
      ti_makt     TYPE TABLE OF type_makt,
      ti_vbrp     TYPE TABLE OF type_vbrp,
      ti_kna1     TYPE TABLE OF type_kna1,
      ti_kna1_aux TYPE TABLE OF type_kna1.

DATA: wa_vbrk TYPE type_vbrk,
      wa_makt TYPE type_makt,
      wa_vbrp TYPE type_vbrp,
      wa_kna1 TYPE type_kna1.

DATA:
      v_pagador TYPE type_vbrk-kunrg.

FREE ti_vbrk.
SELECT vbeln
       fkart
       waerk
       fkdat
       kunrg
  FROM vbrk
  INTO TABLE ti_vbrk
 WHERE fkart = 'F2'
   AND waerk = 'USD'.

IF sy-subrc = 0.

  LOOP AT ti_vbrk INTO wa_vbrk.

    wa_kna1-kunnr = wa_vbrk-kunrg.
    APPEND wa_kna1 TO ti_kna1_aux.

  ENDLOOP.

ENDIF.

CLEAR wa_kna1.

IF ti_vbrk IS NOT INITIAL.

  FREE ti_vbrp.
  SELECT vbeln
         posnr
         fkimg
         ntgew
         brgew
         netwr
         matnr
    FROM vbrp
    INTO TABLE ti_vbrp
     FOR ALL ENTRIES IN ti_vbrk
   WHERE vbeln = ti_vbrk-vbeln.

ENDIF.

IF ti_kna1_aux IS NOT INITIAL.

  FREE ti_kna1.
  SELECT kunnr
         land1
         name1
         ort01
         regio
         stras
    FROM kna1
    INTO TABLE ti_kna1
     FOR ALL ENTRIES IN ti_kna1_aux
   WHERE kunnr = ti_kna1_aux-kunnr
     AND land1 = 'US'.

ENDIF.

IF ti_vbrp IS NOT INITIAL.

  FREE ti_makt.
  SELECT matnr
         spras
         maktx
    FROM makt
    INTO TABLE ti_makt
     FOR ALL ENTRIES IN ti_vbrp
   WHERE matnr = ti_vbrp-matnr
     AND spras = 'PT'.

ENDIF.

SORT: ti_vbrk BY vbeln
                 kunrg,
      ti_vbrp BY vbeln
                 matnr,
      ti_kna1 BY kunnr,
      ti_makt BY matnr.


LOOP AT ti_vbrk INTO wa_vbrk.

  CLEAR wa_vbrp.
  READ TABLE ti_vbrp INTO wa_vbrp WITH KEY
                                  vbeln = wa_vbrk-vbeln BINARY SEARCH.

  CLEAR wa_kna1.
  READ TABLE ti_kna1 INTO wa_kna1 WITH KEY
                                  kunnr = wa_vbrk-kunrg BINARY SEARCH.

  CLEAR wa_makt.
  READ TABLE ti_makt INTO wa_makt WITH KEY
                                  matnr = wa_vbrp-matnr BINARY SEARCH.

  IF v_pagador <> wa_vbrk-kunrg.

    FORMAT RESET.
    FORMAT COLOR COL_KEY INTENSIFIED OFF.
    WRITE:
    /,
    /01 '|', 'Pagador',
     20 '|', 'Documento de Faturamento',
     50 '|', 'Data doc.faturamento p/índice de docs.faturamto',
    220 '|'.

    FORMAT RESET.
    FORMAT COLOR COL_HEADING INTENSIFIED OFF.
    WRITE:
    /01 '|', wa_vbrk-kunrg,
     20 '|', wa_vbrk-vbeln,
     50 '|', wa_vbrk-fkdat,
    220 '|'.

    FORMAT RESET.
    FORMAT COLOR COL_KEY INTENSIFIED OFF.
    WRITE:
    /01 '|', 'Nome',
     40 '|', 'Local',
     80 '|', 'Região',
     90 '|', 'Rua e n°',
    220 '|'.

    FORMAT RESET.
    FORMAT COLOR COL_HEADING INTENSIFIED OFF.
    WRITE:
    /01 '|', wa_kna1-name1,
     40 '|', wa_kna1-ort01,
     80 '|', wa_kna1-regio,
     90 '|', wa_kna1-stras,
    220 '|'.

    v_pagador = wa_vbrk-kunrg.

    FORMAT RESET.
    FORMAT COLOR COL_KEY INTENSIFIED OFF.
    WRITE:
    /01 '|', 'Item do documento de faturamento',
     40 '|', 'N° do material',
     60 '|', 'Texto breve de material',
    100 '|', 'Quantidade faturada efetivamente',
    120 '|', 'Peso líquido',
    140 '|', 'Peso bruto',
    160 '|', 'Valor líq. item fatu. moeda doc.',
    220 '|'.

  ENDIF. "IF v_pagador <> wa_vbrk-kunrg.

  FORMAT RESET.
  FORMAT COLOR COL_HEADING INTENSIFIED OFF.
  WRITE:
  /01 '|', wa_vbrp-posnr,
   40 '|', wa_vbrp-matnr,
   60 '|', wa_makt-maktx,
  100 '|', wa_vbrp-fkimg,
  120 '|', wa_vbrp-ntgew,
  140 '|', wa_vbrp-brgew,
  160 '|', wa_vbrp-netwr,
  220 '|'.

ENDLOOP.