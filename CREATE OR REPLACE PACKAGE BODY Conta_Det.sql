CREATE OR REPLACE PACKAGE BODY Conta_Detalhada

AS

 

   v_msisdn        VARCHAR2 (100);

   v_dt_inicio     VARCHAR2 (100);

   v_dt_fim        VARCHAR2 (100);

   v_COD_PROCESSO  NUMBER(2);

   /* CURSORES */

   /*LMA20070421 - REQ 16573  FLM- INICIO */

   v_ds_voice_plan VARCHAR2 (173);

   v_cd_produto    VARCHAR2 (2);

   v_cd_grupo      VARCHAR2 (2);

   no_bolso          NUMBER;

   /*LMA20070421 - REQ 16573  FLM- FIM */

   --LMA20080513 - REQ 30843 - Separação de Contas Detalhadas - INICIO

   V_CARTAO                VARCHAR2(2);

   V_CONTROLE_VAREJO       VARCHAR2(2);

   V_CONTROLE_CORPORATIVO  VARCHAR2(2);

   --LMA20080513 - REQ 30843 - Separação de Contas Detalhadas - FIM

 

 

   CURSOR c_REQUISICAO

   IS

   --RAR20050722 - 92402 Oi Predileto Inicio

   --CJF20060524 - REQ. 1186821 AICE2.1 - In­cio    --13806-2

   /*LMA20070421 - REQ 16573 FLM - INICIO */

   --SELECT DR.*,RC.DATA_SOLICITACAO, ed.UF_DDD,SC.*,/*OP.CD_OI_PREDILETO,*/REPLACE(REPLACE(RC.NUMERO_TT,'OS', NULL),'_DEM',NULL)NMARQUIVO

      SELECT DR.NUMERO_TT ,DR.NOME_ASSINANTE,DR.PLANO_PRECO ,DR.ENDERECO_COMPOSTO ,DR.BAIRRO,DR.CEP ,DR.CIDADE,DR.ESTADO,DR.INSCRICAO_ESTADUAL,DR.CPF ,

   DR.REFERENCIA,DR.MSISDN,DR.DATA_ABERTURA ,DR.NUMERO_DIAS ,DR.INI_PERIODO ,DR.FIM_PERIODO ,DR.DS_VOICE_PLAN VOICE_PLAN ,DR.CD_PRODUTO PRODUTO,

   RC.DATA_SOLICITACAO, ed.UF_DDD,SC.*,/*OP.CD_OI_PREDILETO,*/REPLACE(REPLACE(RC.NUMERO_TT,'OS', NULL),'_DEM',NULL)NMARQUIVO, GPP.CD_GRUPO

   /*LMA20070421 - REQ 16573 FLM - FIM */

 

   /*LMA20070421 - REQ 16573 FLM - INICIO */

   --FROM REQUISICAO_CONTA RC, DADOS_REQUISICAO_CONTA DR, SERVICE_CENTERS SC, DDD_ESTADO ed

   FROM REQUISICAO_CONTA RC, DADOS_REQUISICAO_CONTA DR, SERVICE_CENTERS SC, DDD_ESTADO ed, TB_GRUPO_PLANO_PRECO GPP

   /*LMA20070421 - REQ 16573 FLM - FIM */

    WHERE

          RC.NUMERO_PROCESSO=V_COD_PROCESSO

          AND RC.NUMERO_TT=DR.NUMERO_TT

          AND SC.SC_STATE=ed.UF_DDD

          AND ed.ddd=(SUBSTR (DR.MSISDN,3,2))

          AND RC.STATUS_PROCESSAMENTO IN ('SOL','GER')

   --       AND OP.CD_MSISDN(+)= DR.MSISDN -- 13806-2

    --CJF20060725 - REQ. 1186821 AICE2.1 -Inicio

      /*LMA20070421 - REQ 16573 FLM - INICIO */

            --AND SC.cd_tipo_produto = RC.cd_tipo_produto

              AND SC.cd_tipo_produto = RC.cd_tipo_produto

              AND DR.CD_PRODUTO = GPP.CD_PRODUTO(+)

              AND DR.DS_VOICE_PLAN = GPP.DS_VOICE_PLAN(+)

 

  /*LMA20070421 - REQ 16573 FLM - FIM */

      --CJF20060725 - REQ. 1186821 AICE2.1 -Fim

    --RAR20050722 - 92402 Oi Predileto Fim

    ORDER BY RC.PRIORIDADE, RC.DATA_SOLICITACAO;

   --CJF20060524 - REQ. 1186821 AICE2.1 - Fim

 

   CURSOR c_chamada

   IS

          SELECT

                           DECODE(csc.CD_TIPO_PRODUTO,01,

                                                     DECODE(cd_opld,NULL,csc.ID_SECAO,TO_NUMBER(TO_CHAR(csc.ID_SECAO)||'.'||TO_CHAR(cd_opld))),

                                                               csc.ID_SECAO) ID_SECAO,

                               DECODE(csc.CD_TIPO_PRODUTO,01,

                                                               DECODE(cd_opld,NULL,csc.ORDEM_SECAO,TO_NUMBER(TO_CHAR(csc.ORDEM_SECAO)||'.'||TO_CHAR(cd_opld))),

                                                               csc.ORDEM_SECAO) ORDEM_SECAO,

                               csc.POSSUI_BOLSO,

                               csc.POSSUI_TOTAL,

                               csc.TAG_DETALHE,

                               csc.TAG_FINAL,

                               csc.TAG_INICIAL,

                               csc.TAG_SUPERIOR_ID,

                               csc.TAG_UNICA,

                               csc.TITULO_SECAO,

                               chamadas.*

                              /*+ INDEX(CSC PK_CONFIG_SECAO) */

          FROM

                   /*

                        CJF 20060601 REQ.1186821 AICE 2.1

                              PRIMEIRA PARTE DA QUERY

 

                   */

                (SELECT /*+ PARALLEL, INDEX(DE  IDX_DDD_ESTADO_01) */

                        RPAD (c.msisdn_b, 18, ' ') msisdn_b,

                       RPAD (de.ds_estado, 15, ' ') ds_origem,

                       TO_CHAR (dt_inicio, 'HH24:MI:SS') hora,

                        dt_inicio datetime,

                       --RPAD (DECODE (tp_periodo,'PEAK','Normal','Reduzido'),10,' ') tarif_time,

                                    Util_Chamada.TARIFACAO(tp_periodo,cd_tipo_produto) tarif_time,

                                    RPAD (TRUNC (vl_chamada), 10, ' ') valor,

                       TO_CHAR (TO_DATE (ROUND(DURACAO), 'SSSSS'),'HH24:MI:SS') duracao,

                       RPAD(Util_Chamada.format_desc_chamada (tp_tarifacao,

                                                               ds_acobrar,

                                                               ds_roaming,

                                                               tp_chamada,

                                                               cd_opld,

                                                                                             --CJF20060623 REQ 1186821 - In­cio

                                                                                             '00' --pr¨-pago comum

                                                                                             --CJF20060623 REQ 1186821 - Fim

                                                               ),18) descr,

                       ' ' tp_requisicao,

                       tp_tarifacao,

                       TO_NUMBER (tp_chamada) tp_chamada,

                       ds_roaming,

                       ds_acobrar,

                       Util_Chamada.format_zone_origin (c.cd_zona_origem)  ddd_zona_origem,

                  /* EPC20051220 - Req 55852: Franquia por tipo de uso - In­cio */

                       ds_bolso,

                                    0 icms,

                                    '00' cd_tipo_produto,

                              --CJF20060623 - REQ 1186821 AICE 2.1- In­cio

                              /*LMA20070421 - REQ 16573 FLM - INICIO*/

                                     --cd_opld,

                                   cd_opld,

                                     c.no_bolso no_bolso

                               /*LMA20070421 - REQ 16573 FLM - FIM*/

                              --CJF20060623 - REQ 1186821 AICE 2.1- Fim

                  --FROM chamada c, ddd_estado DE

                 FROM CHAMADA c, DDD_ESTADO DE, TB_BOLSO b

                  /* EPC20051220 - Req 55852: Franquia por tipo de uso - Fim */

                 WHERE c.msisdn = v_msisdn

                   AND c.dt_inicio >= TO_DATE (v_dt_inicio, 'DD/MM/YYYY HH24MISS')

                   AND c.dt_inicio <= TO_DATE (v_dt_fim, 'DD/MM/YYYY HH24MISS')

                   AND de.ddd = Util_Chamada.format_zone_origin (c.cd_zona_origem)

                   /* EPC20051220 - Req 55852: Franquia por tipo de uso - In­cio */

                   /* RSA20060330 - Fix Garantia 55852 - Inicio */

                  /* FNS20070925 - REQ15729 - inicio */

                   AND NVL(c.no_bolso, 1) = b.no_bolso

                  /* FNS20070925 - REQ15729 - Fim */

                   /* RSA20060330 - Fix Garantia 55852 - Fim */

                    /* EPC20051220 - Req 55852: Franquia por tipo de uso - Fim */

                              --CJF 20060601 - AICE Req. 1186821 - In­cio

                           AND b.CD_TIPO_PRODUTO='00'

                UNION  ALL

                            --CJF 20060601 - AICE Req. 1186821 - Fim

                        SELECT      /*+ PARALLEL, INDEX(DE  IDX_DDD_ESTADO_01) */

                                RPAD (c.msisdn_b, 18, ' ') msisdn_b,

                       RPAD (de.ds_estado, 15, ' ') ds_origem,

                       TO_CHAR (dt_inicio, 'HH24:MI:SS') hora,

                        dt_inicio datetime,

                       --RPAD (DECODE (tp_periodo,'PEAK','Normal','Reduzido'),10,' ') tarif_time,

                                    --CJF20060725 - REQ. 1186821 AICE2.1 -Inicio

                                    Util_Chamada.TARIFACAO(tp_periodo,cd_tipo_produto) tarif_time,

                                  --CJF20060725 - REQ. 1186821 AICE2.1 -Inicio

                       RPAD (TRUNC (vl_chamada), 10, ' ') valor,

                       TO_CHAR (TO_DATE (ROUND(DURACAO), 'SSSSS'),'HH24:MI:SS') duracao,

                       RPAD(Util_Chamada.format_desc_chamada (tp_tarifacao,

                                                                                             '', --ds_acobrar,

                                                               '', --ds_roaming,

                                                               tp_chamada,

                                                               cd_opld,

                                                                                             '01' -- AICE

                                                                                             ),18) descr,

                       ' ' tp_requisicao,

                       tp_tarifacao,

                       TO_NUMBER (tp_chamada) tp_chamada,

                       '' ds_roaming,

                       '' ds_acobrar,

                       Util_Chamada.format_zone_origin (c.CD_ZONA_ORIGEM_A)  ddd_zona_origem,

                       ds_bolso,

                                    Util_Chamada.ICMS_AICE(C.ICMS,vl_chamada) icms,

                                    --CJF20060623 - REQ 1186821 AICE 2.1- In­cio

                                    '01' cd_tipo_produto,

                              /*LMA20070421 - REQ 16573 FLM - INICIO*/

                                    --c.cd_opld,

                                c.cd_opld,

                                    c.no_bolso no_bolso

                              /*LMA20070421 - REQ 16573 FLM - FIM*/

                                    --CJF20060623 - REQ 1186821 AICE 2.1- fim

                  FROM CHAMADA_AICE C, DDD_ESTADO DE, TB_BOLSO B

                  WHERE c.MSISDN = v_msisdn

                   AND c.DT_INICIO >= TO_DATE (v_dt_inicio, 'DD/MM/YYYY HH24MISS')

                   AND c.DT_INICIO <= TO_DATE (v_dt_fim, 'DD/MM/YYYY HH24MISS')

                   AND de.DDD = SUBSTR (C.MSISDN,3,2)

                  /* FNS20070925 - REQ15729 - inicio */

                   AND NVL(c.NO_BOLSO , 1) = b.no_bolso

                  /* FNS20070925 - REQ15729 - Fim */

 

                       AND b.CD_TIPO_PRODUTO='01'

                        /* CJF 20060601 Req. 1186821 AICE2.1 - FIM*/

                        UNION  ALL

                SELECT msisdn msisdn_b,

                        '' ds_origem,

                        '' hora,

                        datetime,

                       '' tarif_time,

                       RPAD (TRUNC(valor), 18, ' ') valor,

                       ' ' duracao,

                       descr,

                       tp_requisicao,

                       ' ' tp_tarifacao,

                       -1 tp_chamada,

                       ' ' ds_roaming,

                       '0' ds_acobrar,

                       '' ddd_zona_origem,

                  /* EPC20051220 - Req 55852: Franquia por tipo de uso - In­cio */

                       ds_bolso,

                                    0 icms,

                  --CJF20060623 - REQ 1186821 AICE 2.1- In­cio

                                    cd_tipo_produto,

                              /*LMA20070421 - REQ 16573 FLM - INICIO*/

                                    --'' cd_opld,

                                  '' cd_opld,

                                    no_bolso

                              /*LMA20070421 - REQ 16573 FLM - FIM*/

                  --CJF20060623 - REQ 1186821 AICE 2.1- fim

               /* EPC20051220 - Req 55852: Franquia por tipo de uso - Fim */

                    FROM

                        (SELECT /*+ INDEX(IDX_HIST_REQ_03) */

                                    msisdn,

                                    hrc.tp_requisicao,

                                        DT_REQUISICAO datetime,

                                TO_NUMBER (valor) valor,

                                    /*RAR20050722 - 6512 Cheque Especial Inicio*/

                                    --'Recarga Virtual' descr

                                    /*LMA20070421 - REQ 16573 FLM - INICIO*/

                             --     DECODE(hrc.tp_requisicao, '06' ,'Oi Cr¿dito Especial', 'Recarga Virtual') descr,

                                                DECODE(hrc.tp_requisicao, '06' ,'Oi Crédito Especial', '09', 'Recarga Franquia','Recarga Virtual') descr,

                                    /*LMA20070421 - REQ 16573 FLM - FIM*/

                                    /*RAR20050722 - 6512 Cheque Especial Fim*/

                                    /*EPC20051220 - Req 55852: Franquia por tipo de uso - In­cio */

                                    ds_bolso,

                                    /*LMA20070421 - REQ 16573 FLM - INICIO*/

                                                --b.CD_TIPO_PRODUTO,

                                                b.CD_TIPO_PRODUTO,

                                            b.NO_BOLSO no_bolso

                                     /*LMA20070421 - REQ 16573 FLM - FIM*/

                          --FROM histrequisicaocredito

                          FROM HISTREQUISICAOCREDITO hrc, tb_bolso_recarga br, TB_BOLSO b

                       /* EPC20051220 - Req 55852: Franquia por tipo de uso - Fim */

                         WHERE msisdn = v_msisdn

                           AND dt_requisicao >= TO_DATE (v_dt_inicio, 'DD/MM/YYYY HH24MISS')

                           AND dt_requisicao <= TO_DATE (v_dt_fim, 'DD/MM/YYYY HH24MISS')

                           AND cd_erro = 0

                  /*RAR20050722 - 6512 Cheque Especial Inicio*/

                  --AND TP_REQUISICAO in ('00','03','04')

                   /*LMA20070421 - REQ 16573 FLM - INICIO*/

                        --   AND hrc.TP_REQUISICAO IN ('00','03','04','06')

                                       AND hrc.TP_REQUISICAO IN ('00','03','04','06','09')

                   /*LMA20070421 - REQ 16573 FLM - fim*/

                           /*RAR20050722 - 6512 Cheque Especial Fim*/

                           AND CD_CANAL <> 20

                           /* EPC20051220 - Req 55852: Franquia por tipo de uso - In­cio */

                           /* CJF20060914 BugFix AICE21 - Inicio*/

                           AND br.tp_valor(+) = hrc.tp_valor

                           AND br.tp_requisicao(+) = hrc.tp_requisicao

                                       AND br.CD_TIPO_PRODUTO(+) = hrc.CD_TIPO_PRODUTO

                            /* CJF20060914 BugFix AICE21 - Fim*/

                           /* RSA20060330 - Fix Garantia 55852 - Inicio */

                           /* FNS20070925 - REQ15729 - inicio */

                           AND NVL(br.no_bolso, 1) = b.no_bolso

                           /* FNS20070925 - REQ15729 - Fim */

 

                           /* RSA20060330 - Fix Garantia 55852 - Fim */

                           /* EPC20051220 - Req 55852: Franquia por tipo de uso - Fim */

                           /* CJF20060914 BugFix AICE21 - Inicio*/

                                                   AND b.CD_TIPO_PRODUTO = hrc.CD_TIPO_PRODUTO

                           /* CJF20060914 BugFix AICE21 - Fim*/

                                       /* CJF20060914 BugFix AICE21 - Fim*/

                                    /*LMA20070421 - REQ 16573 FLM - INICIO*/

                                      AND hrc.CD_ORIGEM <> 79

                                      /*LMA20080606 - BUGFIX 20397 - INICIO - A partir deste requerimento cd_produto passa a ser trazido */

                                     -- AND NVL(HRC.DS_VOICE_PLAN, 'MOVEL') = NVL(v_ds_voice_plan, 'MOVEL')

                                      --AND NVL(HRC.CD_PRODUTO, 'MOVEL') = NVL(v_cd_produto, 'MOVEL')

                                       /*LMA20080606 - BUGFIX 20397 - FIM*/

                                    /*LMA20070421 - REQ 16573 FLM - FIM*/

                        UNION  ALL

                        SELECT      msisdn,

                                    '-1' tp_requisicao,

                                hist.dt_ajuste datetime,

                                    /*LMA20070421 - REQ 16573 FLM - INICIO*/

                                    --hist.valor *100 valor,

                                                --'Ajuste' descr,

                                                DECODE(b.no_bolso, 3, hist.valor,hist.valor *100) valor,

                                                CASE WHEN hist.CD_TIPO_PRODUTO='01'THEN DECODE(b.no_bolso, 1, 'Ajuste/Recarga', 2, 'Ajuste/Bônus', 3, 'Ajuste Bolso Franquia')

                                                ELSE 'Ajuste' END descr,

                                    /*LMA20070421 - REQ 16573 FLM - FIM*/

                                    /* EPC20051220 - Req 55852: Franquia por tipo de uso - In­cio */

                                    ds_bolso,

                          --FROM hist_ajuste

                                     /*LMA20070421 - REQ 16573 FLM - INICIO*/

                                            --b.CD_TIPO_PRODUTO,

                                            b.CD_TIPO_PRODUTO,

                                            b.NO_BOLSO no_bolso

                                     /*LMA20070421 - REQ 16573 FLM - FIM*/

                          FROM HIST_AJUSTE hist, TB_BOLSO b

                        /* EPC20051220 - Req 55852: Franquia por tipo de uso - Fim */

                         WHERE hist.msisdn = v_msisdn

                           AND hist.dt_ajuste >= TO_DATE (v_dt_inicio, 'DD/MM/YYYY HH24MISS')

                           AND hist.dt_ajuste <= TO_DATE (v_dt_fim, 'DD/MM/YYYY HH24MISS')

                           /* EPC20051220 - Req 55852: Franquia por tipo de uso - In­cio */

                           /* RSA20060330 - Fix Garantia 55852 - Inicio */

                           /* FNS20070925 - REQ15729 - inicio */

                           AND NVL(hist.no_bolso, 1) = b.no_bolso

                         /* FNS20070925 - REQ15729 - Fim */

                           /* RSA20060330 - Fix Garantia 55852 - Fim */

                           /* EPC20051220 - Req 55852: Franquia por tipo de uso - Fim */

                                       AND b.CD_TIPO_PRODUTO=hist.CD_TIPO_PRODUTO

                        UNION  ALL

                        SELECT      a.msisdn msisdn,

                                  '01' tp_requisicao,

                                                a.dt_hora datetime,

                                    valor,

                                    'Recarga Voucher' descr,

                  /* EPC20051220 - Req 55852: Franquia por tipo de uso - In­cio */

                                                 DECODE(a.CD_TIPO_PRODUTO,'00','Recarga','01','Principal'),

                        /* EPC20051220 - Req 55852: Franquia por tipo de uso - Fim */

                                       /*LMA20070421 - REQ 16573 FLM - INICIO*/

                                            --a.CD_TIPO_PRODUTO,

                                            a.CD_TIPO_PRODUTO,

                                          /* FNS20070925 - REQ15729 - inicio */

                                            1 no_bolso

                                          /* FNS20070925 - REQ15729 - Fim */

 

                                      /*LMA20070421 - REQ 16573 FLM - FIM*/

                          FROM HISTSPACE a

                         WHERE a.msisdn = v_msisdn

                           AND a.dt_hora >= TO_DATE (v_dt_inicio, 'DD/MM/YYYY HH24MISS')

                           AND a.dt_hora <= TO_DATE (v_dt_fim, 'DD/MM/YYYY HH24MISS')

                        UNION  ALL

                        SELECT /*+ INDEX(IDX_HIST_REQ_DEBITO_01) */

                                    msisdn,

                                    DECODE(b.CD_TIPO_PRODUTO,01,hrd.tp_requisicao||'hrd',

                                                                                          hrd.tp_requisicao),

                                                dt_Requisicao DATETIME,

                                    hrd.valor valor,

                                    dt.descricao descr,

                  /* EPC20051220 - Req 55852: Franquia por tipo de uso - In­cio */

                                    ds_bolso,

                          --FROM histrequisicaodebito r, descricao_taxa dt

                                      /*LMA20070421 - REQ 16573 FLM - INICIO*/

                                            --b.CD_TIPO_PRODUTO,

                                            b.CD_TIPO_PRODUTO,

                                            B.NO_BOLSO no_bolso

                                      /*LMA20070421 - REQ 16573 FLM - FIM*/

                          FROM HISTREQUISICAODEBITO hrd, DESCRICAO_TAXA dt, tb_bolso_recarga br, TB_BOLSO b

                        /* EPC20051220 - Req 55852: Franquia por tipo de uso - Fim */

                        WHERE  hrd.msisdn = v_msisdn

                           AND hrd.dt_requisicao >= TO_DATE (v_dt_inicio, 'DD/MM/YYYY HH24MISS')

                           AND hrd.dt_requisicao <= TO_DATE (v_dt_fim, 'DD/MM/YYYY HH24MISS')

                           AND hrd.cd_canal = dt.cd_canal

                           AND cd_erro=0

                           AND hrd.cd_origem = dt.cd_origem

                           /* EPC20051220 - Req 55852: Franquia por tipo de uso - In­cio */

                           /* CJF20060914 BugFix AICE21 - Inicio*/

                           AND br.tp_valor(+) = hrd.tp_valor

                           AND br.tp_requisicao(+) = hrd.tp_requisicao

                                       AND br.CD_TIPO_PRODUTO(+) = hrd.CD_TIPO_PRODUTO

                            /* CJF20060914 BugFix AICE21 - Fim*/

                            /* RSA20060330 - Fix Garantia 55852 - Inicio */

                           /* FNS20070925 - REQ15729 - inicio */

                           AND NVL(br.no_bolso, 1) = b.no_bolso

                           /* FNS20070925 - REQ15729 - Fim */

 

                           /* RSA20060330 - Fix Garantia 55852 - Fim */

                           /* EPC20051220 - Req 55852: Franquia por tipo de uso - Fim */

                            /* CJF20060914 BugFix AICE21 - Inicio*/

                                                   AND b.CD_TIPO_PRODUTO = hrd.CD_TIPO_PRODUTO

                           /* CJF20060914 BugFix AICE21 - Fim*/

                               /*LMA20070421 - REQ 16573 FLM - INICIO*/

                                       AND hrd.CD_ORIGEM <> 79

                                       /*LMA20080606 - BUGFIX 20397 - INICIO - A partir deste requerimento cd_produto passa a ser trazido */

                                     --  AND NVL(HRD.DS_VOICE_PLAN, 'MOVEL') = NVL(v_ds_voice_plan, 'MOVEL')

                                       --AND NVL(HRD.CD_PRODUTO, 'MOVEL') = NVL(v_cd_produto, 'MOVEL')

                                       /*LMA20080606 - BUGFIX 20397 - FIM */

                               /*LMA20070421 - REQ 16573 FLM - FIM*/

                               /*LMA20070421 - REQ 16573 FLM - INICIO*/

                                    UNION ALL

 

                                    SELECT

                           msisdn,

                           hrd.TP_REQUISICAO tp_requisicao,

                                       dt_Requisicao DATETIME,

                           hrd.valor valor,

                           dt.DESCRICAO descr,

                                 ds_bolso,

                           B.CD_TIPO_PRODUTO,

                                       B.NO_BOLSO no_bolso

                                     FROM HISTREQUISICAODEBITO hrd, TB_BOLSO B, DESCRICAO_TAXA dt, TB_BOLSO_RECARGA br

                         WHERE

                                         hrd.msisdn = v_msisdn

                         AND hrd.dt_requisicao >= TO_DATE (v_dt_inicio, 'DD/MM/YYYY HH24MISS')

                         AND hrd.dt_requisicao <= TO_DATE (v_dt_fim, 'DD/MM/YYYY HH24MISS')

                         AND hrd.cd_canal = dt.cd_canal

                         AND HRD.cd_erro=0

                         AND hrd.cd_origem = dt.cd_origem

                                     AND HRD.CD_ORIGEM = 79

                         AND br.tp_valor = hrd.tp_valor

                         AND br.tp_requisicao = hrd.tp_requisicao

                               AND br.CD_TIPO_PRODUTO = hrd.CD_TIPO_PRODUTO

                        /* FNS20070925 - REQ15729 - inicio */

                         AND NVL(br.no_bolso, 1) = B.no_bolso

                        /* FNS20070925 - REQ15729 - Fim */

 

                         AND B.CD_TIPO_PRODUTO = hrd.CD_TIPO_PRODUTO

 

 

                                     UNION ALL

 

                                     SELECT

                           msisdn,

                           hrc.TP_REQUISICAO tp_requisicao,

                                       dt_Requisicao DATETIME,

                           to_number(hrc.valor) valor,

                           dt.DESCRICAO descr,

                                 ds_bolso,

                           B.CD_TIPO_PRODUTO,

                                       B.NO_BOLSO no_bolso

                                     FROM HISTREQUISICAOCREDITO hrc, TB_BOLSO B, DESCRICAO_TAXA dt, TB_BOLSO_RECARGA br

                         WHERE

                                         hrc.msisdn = v_msisdn

                         AND hrc.dt_requisicao >= TO_DATE (v_dt_inicio, 'DD/MM/YYYY HH24MISS')

                         AND hrc.dt_requisicao <= TO_DATE (v_dt_fim, 'DD/MM/YYYY HH24MISS')

                         AND hrc.cd_canal = dt.cd_canal

                         AND HRc.cd_erro=0

                         AND hrc.cd_origem = dt.cd_origem

                                     AND HRc.CD_ORIGEM = 79

                         AND br.tp_valor = hrc.tp_valor

                         AND br.tp_requisicao = hrc.tp_requisicao

                               AND br.CD_TIPO_PRODUTO = hrc.CD_TIPO_PRODUTO

                        /* FNS20070925 - REQ15729 - inicio */

                         AND NVL(br.no_bolso, 1) = B.no_bolso

                        /* FNS20070925 - REQ15729 - Fim */

 

                         AND B.CD_TIPO_PRODUTO = hrc.CD_TIPO_PRODUTO

                               /*LMA20070421 - REQ 16573 FLM - FIM*/

 

                                    UNION ALL

                                    /* REQ 13806-2 : forcar uso do indice */

                                    Select /*+ index(op) */

                                     OP.CD_OI_PREDILETO  msisdn,

                                     'OI_PRED' tp_requisicao,

                                     DT_ATIVACAO datetime,

                                     0 valor,

                                     'DESCRICAO FIXA' descr,

                                     ''ds_bolso,

                        /*LMA20070421 - REQ 16573 FLM - INICIO*/

                                     --'00'cd_tipo_produto,

                                     '00'cd_tipo_produto,

                                    /* FNS20070925 - REQ15729 - inicio */

                                      1 no_bolso

                                    /* FNS20070925 - REQ15729 - Fim */

                          /*LMA20070421 - REQ 16573 FLM - FIM*/

                                    FROM

                                     L_MUDANCAS_OI_PREDILETO OP

                                     WHERE

                                         OP.CD_MSISDN = v_msisdn

                                     AND OP.DT_DESATIVACAO is null

 

                  /*LMA20070421 - REQ.16573 FLM - INICIO - SEÇÃO SALDOS NO MOMENTO DA EMISSAO */

                        UNION ALL

                                    SELECT

                                        CLI.MSISDN msisdn,

                                          'SLD_MOM_EMISSAO' tp_requisicao,

                                          NULL datetime,

                            CLI.SALDOATUAL valor,

                            TUB.CD_UNIDADE descr, -- usando o campo descr pra retornar unidade

                            'Recargas' ds_bolso,

                            '01' cd_tipo_produto,

                                          TB.NO_BOLSO no_bolso

 

                                  FROM CLIENTES CLI, TB_UNIDADE_BOLSO TUB, TB_BOLSO TB

                                  WHERE

                                       CLI.MSISDN = v_msisdn

                                    AND TB.NO_BOLSO = TUB.NO_BOLSO

                                    AND TB.CD_TIPO_PRODUTO = CLI.CD_TIPO_PRODUTO

                                    AND TUB.DS_VOICE_PLAN = CLI.DS_VOICE_PLAN

                                    AND TUB.DS_VOICE_PLAN = v_ds_voice_plan

                                    AND CLI.CD_PRODUTO = v_cd_produto

                                AND TB.NO_BOLSO = 1

                                    UNION ALL

                       SELECT

                                            TCS.MSISDN  msisdn,

                                'SLD_MOM_EMISSAO' tp_requisicao,

                                            NULL datetime,

                              to_number(TCS.SALDOATUAL) valor,

                              TUB.CD_UNIDADE descr, -- usando o campo descr pra retornar unidade

                              TB.DS_BOLSO ds_bolso,

                              '01' cd_tipo_produto,

                                            TB.NO_BOLSO no_bolso

                                    FROM TB_CLIENTES_SALDO TCS, TB_BOLSO TB,TB_UNIDADE_BOLSO TUB

                                    WHERE

                                  TCS.MSISDN = v_msisdn

                        AND TB.NO_BOLSO = TUB.NO_BOLSO

                                    AND TB.NO_BOLSO = TCS.BUCKETID

                                    AND TUB.DS_VOICE_PLAN = v_ds_voice_plan

                                    AND TCS.CD_TIPO_PRODUTO = TB.CD_TIPO_PRODUTO

 

                        UNION ALL

                     /*LMA20070421 - REQ. 16573 FLM - FIM */

 

                                    /*

                                    SELECT msisdn,

                                           tp_requisicao,

                                             datetime,

                                             valor,

                                             descr,

                                             ds_bolso,

                                             cd_tipo_produto FROM

                                    (

                                      SELECT c.MSISDN,

                                         'SLDTTAC' tp_requisicao, /* SE¨¿O ESPECIAL AICE

                                             TO_DATE(rc.DATA_SOLICITACAO,'DD/MM/YYYY HH24MISS') datetime,

                                             c.VL_SALDO valor,

                                             'SE¨¿O ESPECIAL AICE' descr,

                                             'AICE2.1' ds_bolso,

                                             '01' cd_tipo_produto,

                                             c.DT_FIM

                                      FROM CHAMADA_AICE c,

                                             REQUISICAO_CONTA rc,

                                             DADOS_REQUISICAO_CONTA drc

                                    WHERE (TO_DATE(c.DT_INICIO,'DD/MM/YYYY HH24MISS') <= TO_DATE(v_dt_inicio,'DD/MM/YYYY HH24MISS'))

                                      AND c.msisdn          = v_msisdn

                                      AND rc.NUMERO_TT      = drc.NUMERO_TT

                                      AND c.MSISDN          = drc.MSISDN

                                      AND rc.cd_tipo_produto='01'

                                      AND dt_fim IS NOT NULL

                                      ORDER BY dt_fim DESC

                                    ) WHERE ROWNUM=1

                                    UNION ALL*/

                                    SELECT '' msisdn,

                                                 'SECFAKE' tp_requisicao,

                                                 SYSDATE datetime,

                                                 0 valor,

                                                 'SE¨¿O FAKE'descr,

                                                 ''ds_bolso,

                                          /*LMA20070421 - REQ 16573 FLM - INICIO*/

                                                 --'01'cd_tipo_produto,

                                                 '01'cd_tipo_produto,

                                             /* FNS20070925 - REQ15729 - inicio */

                                             1 no_bolso

                                             /* FNS20070925 - REQ15729 - Fim */

 

                                       /*LMA20070421 - REQ 16573 FLM - FIM*/

                                      FROM DUAL

                              )

 

                        )CHAMADAS,

                config_secao_conta CSC

                      WHERE TRUNC(CSC.id_secao) = Util_Chamada.map_sessao_conta(v_msisdn,

                                                                              tp_tarifacao,

                                                                              ds_acobrar,

                                                                              ds_roaming,

                                                                              TO_NUMBER(tp_chamada),

                                                                              tp_requisicao,

                                                                              ddd_zona_origem,

                                                                                                --CJF20060623 - REQ 1186821 AICE 2.1- In­cio

                                                                                            CHAMADAS.cd_tipo_produto, --Pr¨-Pago

                                                                                                /*LMA20070421 - REQ 16573 FLM - INICIO*/

                                                                                                --CHAMADAS.CD_OPLD)

                                                                                                CHAMADAS.CD_OPLD,

                                                                              v_cd_produto,

                                                                                                chamadas.no_bolso)

                                                                                          /*LMA20070421 - REQ 16573 FLM - FIM */

 

                                                                                                --CJF20060623 - REQ 1186821 AICE 2.1- Fim

                              AND CSC.cd_tipo_produto = chamadas.cd_tipo_produto

 

            ORDER BY   csc.ordem_secao,datetime,cd_opld;