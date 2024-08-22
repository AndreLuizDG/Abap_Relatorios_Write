REPORT z_algj_21.

TYPES
  BEGIN OF type_kna1,
    kunnr TYPE kna1-kunnr,
    name1 TYPE kna1-name1,
    ort01 TYPE kna1-ort01,
    stras TYPE kna1-stras,
    erdat TYPE kna1-erdat,
  END OF type_kna1.

DATA
      ti_kna1 TYPE TABLE OF type_kna1.

DATA
  wa_kna1   TYPE type_kna1.

DATA
      cont_reg TYPE i.

START-OF-SELECTION.
  PERFORM zf_selecao_de_dados.

END-OF-SELECTION.
  PERFORM zf_top_of_page.
  PERFORM zf_processamento_exibicao.

FORM zf_selecao_de_dados.

  FREE ti_kna1.
  SELECT kunnr
         name1
         ort01
         stras
         erdat
    FROM kna1
    INTO TABLE ti_kna1
   WHERE    name1 LIKE 'a%'
         OR name1 LIKE 'e%'
         OR name1 LIKE 'i%'
         OR name1 LIKE 'o%'
         OR name1 LIKE 'u%'
         OR name1 LIKE 'A%'
         OR name1 LIKE 'E%'
         OR name1 LIKE 'I%'
         OR name1 LIKE 'O%'
  OR name1 LIKE 'U%'.

  IF sy-subrc  0.
    FREE ti_kna1.
    MESSAGE 'Nenhum resultado encontrado.' TYPE 'S' DISPLAY LIKE 'E'.
    LEAVE LIST-PROCESSING.
  ENDIF.

ENDFORM.

FORM zf_top_of_page.

  FORMAT RESET.
  FORMAT COLOR COL_HEADING INTENSIFIED ON.
  ULINE.
  WRITE 00  '', 'Cliente',
          10  '', 'Nome',
          50  '', 'Local',
          95  '', 'Rua e n°',
          135 '', 'Data criação',
          150 ''.
  ULINE.

ENDFORM.

FORM zf_processamento_exibicao.

  FORMAT RESET.
  IF sy-subrc EQ 0.
    LOOP AT ti_kna1 INTO wa_kna1.
      WRITE 01  '', wa_kna1-kunnr,
              10  '', wa_kna1-name1,
              50  '', wa_kna1-ort01,
              95  '', wa_kna1-stras,
              135 '', wa_kna1-erdat,
              150 ''.
      ULINE.
      ADD 1 TO cont_reg.
    ENDLOOP.

    WRITE2  'TOTAL DE REGISTROS ENCONTRADOS ', cont_reg.
  ENDIF.

ENDFORM.