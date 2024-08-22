REPORT Z_ALGJ_26.

TYPES:

  BEGIN OF type_cepc,
    prctr TYPE cepc-prctr,
    datbi TYPE cepc-datbi,
    kokrs TYPE cepc-kokrs,
    datab TYPE cepc-datab,
    usnam TYPE cepc-usnam,
  END OF type_cepc,

  BEGIN OF type_cepct,
    spras TYPE cepct-spras,
    prctr TYPE cepct-prctr,
    datbi TYPE cepct-datbi,
    kokrs TYPE cepct-kokrs,
  END OF type_cepct,

  BEGIN OF type_tka01,
    kokrs TYPE tka01-kokrs,
    bezei TYPE tka01-bezei,
  END OF type_tka01.

DATA:
  ti_cepc  TYPE TABLE OF type_cepc,
  ti_cepct TYPE TABLE OF type_cepct,
  ti_tka01 TYPE TABLE OF type_tka01.

DATA:
  wa_cepc  TYPE type_cepc,
  wa_cepct TYPE type_cepct,
  wa_tka01 TYPE type_tka01.

DATA:
  v_area      TYPE type_cepc-kokrs,
  v_cont_area TYPE i,
  v_cont_regi TYPE i.

FREE ti_cepc.
SELECT prctr
       datbi
       kokrs
       datab
       usnam
  FROM cepc
  INTO TABLE ti_cepc
 WHERE datbi = '99991231'.

IF sy-subrc <> 0.
  FREE ti_cepc.
ENDIF.

IF ti_cepc IS NOT INITIAL.

  FREE ti_cepct.
  SELECT spras
         prctr
         datbi
         kokrs
    FROM cepct
    INTO TABLE ti_cepct
     FOR ALL ENTRIES IN ti_cepc
   WHERE spras = 'PT'
     AND prctr = ti_cepc-prctr
     AND datbi = ti_cepc-datbi
     AND kokrs = ti_cepc-kokrs.

  IF sy-subrc <> 0.
    FREE ti_cepct.
  ENDIF.

ENDIF.

FREE ti_tka01.
SELECT kokrs
       bezei
  FROM tka01
  INTO TABLE ti_tka01
   FOR ALL ENTRIES IN ti_cepc
 WHERE kokrs = ti_cepc-kokrs.

IF sy-subrc <> 0.
  FREE ti_tka01.
ENDIF.

SORT: ti_cepc  BY prctr
                  datbi
                  kokrs,
      ti_cepct BY prctr
                  datbi
                  kokrs,
      ti_tka01 BY kokrs.

LOOP AT ti_cepc INTO wa_cepc.

  CLEAR wa_cepct.
  READ TABLE ti_cepct INTO wa_cepct WITH KEY
                                    prctr = wa_cepc-prctr
                                    datbi = wa_cepc-datbi
                                    kokrs = wa_cepc-kokrs BINARY SEARCH.

  IF sy-subrc <> 0.
    CLEAR wa_cepct.
  ENDIF.

  CLEAR wa_tka01.
  READ TABLE ti_tka01 INTO wa_tka01 WITH KEY
                                    kokrs = wa_cepc-kokrs BINARY SEARCH.

  IF sy-subrc <> 0.
    CLEAR wa_tka01.
  ENDIF.


  IF v_area <> wa_cepc-kokrs.

    IF v_area IS NOT INITIAL.

      FORMAT RESET.
      FORMAT COLOR COL_TOTAL INTENSIFIED OFF.
      WRITE:
      /01 'Total de Centros de Lucro para a área', v_area, ' = ', v_cont_area,
      140 '|'.

    ENDIF.

    CLEAR v_cont_area.

    CLEAR v_area.
    FORMAT RESET.
    FORMAT COLOR COL_KEY INTENSIFIED ON.

    WRITE:
    /01 '|', 'Área de contabilidade de custos',
     40 '|', 'Denominação da área de contabilidade de custos',
    140 '|'.

    FORMAT RESET.
    FORMAT COLOR COL_HEADING INTENSIFIED OFF.
    WRITE:
    /01 '|', wa_cepc-kokrs,
     40 '|', wa_tka01-bezei,
    140 '|'.

    FORMAT RESET.
    FORMAT COLOR COL_KEY INTENSIFIED ON.

    WRITE:
    /01 '|', 'Centro de lucro',
     40 '|', 'Texto descritivo',
     60 '|', 'Criado por',
     90 '|', 'Data início validade',
    110 '|', 'Data de validade final',
    140 '|'.

    v_area = wa_cepc-kokrs.

  ENDIF. "IF v_area <> kokrs.

  FORMAT RESET.
  FORMAT COLOR COL_HEADING INTENSIFIED OFF.
  WRITE:
  /01 '|', wa_cepc-prctr,  "Centro de lucro
   40 '|', wa_tka01-bezei, "Texto descritivo
   60 '|', wa_cepc-usnam,  "Criado por
   90 '|', wa_cepc-datab,  "Data in�cio validade
  110 '|', wa_cepct-datbi, "Data de validade final
  140 '|'.
  v_cont_area = v_cont_area + 1.

  v_cont_regi = v_cont_regi + 1.

ENDLOOP.

FORMAT RESET.
FORMAT COLOR COL_TOTAL INTENSIFIED OFF.
WRITE:
/01 '|', 'Total de registros selecionados =', v_cont_regi, 140 '|'.