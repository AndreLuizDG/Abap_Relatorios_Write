REPORT Z_ALGJ_22.

TYPES:

  BEGIN OF type_ekko,
    ebeln TYPE ekko-ebeln,
    bukrs TYPE ekko-bukrs,
    bsart TYPE ekko-bsart,
    aedat TYPE ekko-aedat,
    lifnr TYPE ekko-lifnr,
    ekorg TYPE ekko-ekorg,
    ekgrp TYPE ekko-ekgrp,
  END OF type_ekko,

  BEGIN OF type_ekpo,
    ebeln TYPE ekpo-ebeln,
    ebelp TYPE ekpo-ebelp,
    matnr TYPE ekpo-matnr,
    werks TYPE ekpo-werks,
  END OF type_ekpo.

DATA:
  ti_ekko TYPE TABLE OF type_ekko,
  ti_ekpo TYPE TABLE OF type_ekpo.
DATA:
  s_ekko TYPE type_ekko,
  s_ekpo TYPE type_ekpo.
DATA:
  wc_empresa  TYPE type_ekko-bukrs,
  wi_contador TYPE i.


FREE ti_ekko.
SELECT ebeln
       bukrs
       bsart
       aedat
       lifnr
       ekorg
       ekgrp
  FROM ekko
  INTO TABLE ti_ekko
 WHERE bsart = 'NB'.

IF sy-subrc <> 0.

  FREE ti_ekko.
  MESSAGE 'Dados de compra não encontrados!' TYPE 'S' DISPLAY LIKE 'E'.

ENDIF.

IF ti_ekko IS NOT INITIAL.

  FREE ti_ekpo.
  SELECT ebeln
         ebelp
         matnr
         werks
    FROM ekpo
    INTO TABLE ti_ekpo
     FOR ALL ENTRIES IN ti_ekko
   WHERE ebeln = ti_ekko-ebeln
     AND matnr LIKE 'T%'.

ENDIF.


SORT: ti_ekpo BY ebeln.

LOOP AT ti_ekko INTO s_ekko.

  READ TABLE ti_ekpo INTO s_ekpo
                     WITH KEY ebeln = s_ekko-ebeln BINARY SEARCH.
  IF sy-subrc <> 0.
    CONTINUE.
  ENDIF.

    wi_contador = wi_contador + 1.

  IF wc_empresa NE s_ekko-bukrs.


    FORMAT RESET.

    IF sy-tabix <> 1.
      ULINE.
      WRITE:/ 'EMPRESA: ', wc_empresa.
      WRITE:/ 'TOTAL DE REGISTROS: ', wi_contador.

      CLEAR wi_contador.
    ENDIF.

    wc_empresa = s_ekko-bukrs.

    FORMAT COLOR COL_HEADING INTENSIFIED ON.
    ULINE.
    WRITE: /01 '|', 'No. doc compras',
            20 '|', 'Empresa',
            40 '|', 'Data',
            60 '|', 'No. fornecedor',
            80 '|', 'Org. compras',
           100 '|', 'Grupo compradores',
           120 '|', 'No. item doc compras',
           140 '|', 'No. material',
           160 '|', 'Centro',
           180 '|'.
    ULINE.

  ENDIF.

  FORMAT RESET.
  WRITE:
         /0 '|',  s_ekko-ebeln,
         20 '|',  s_ekko-bukrs,
         40 '|',  s_ekko-aedat,
         60 '|',  s_ekko-lifnr,
         80 '|',  s_ekko-ekorg,
         100 '|', s_ekko-ekgrp,
         120 '|', s_ekpo-ebelp,
         140 '|', s_ekpo-matnr,
         160 '|', s_ekpo-werks,
         180 '|'.

ENDLOOP.