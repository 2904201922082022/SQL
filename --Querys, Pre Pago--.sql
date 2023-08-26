--Local--
SELECT ROWID,a. *  FROM  CHAMADA a     
WHERE MSISDN in ('552111163233')--,'552111163233')---,'552111163234', '552111163235')     
AND dt_inicio BETWEEN TO_DATE( '01/12/2008 00:00:01' , 'dd/mm/yyyy hh24:mi:ss')
AND TO_DATE( '30/12/2008 23:59:59' , 'dd/mm/yyyy hh24:mi:ss')     
AND (tp_tarifacao LIKE ('VCA%') OR  tp_tarifacao LIKE ('VCS%') OR tp_tarifacao LIKE('VC1A%')
OR tp_tarifacao LIKE ('CP%') OR tp_tarifacao LIKE ('PV%'))     
AND CD_ZONA_ORIGEM LIKE ('%21') AND OPERADORA = 'Oi' AND DS_ACOBRAR = '0'  


--Fora de cobertura--
SELECT rowid,a.*  FROM  CHAMADA a     
WHERE MSISDN in ('552111163233')--('552122330001','552122330002','552122330003')     
AND dt_inicio BETWEEN TO_DATE( '01/12/2008 00:00:01' , 'dd/mm/yyyy hh24:mi:ss')
AND TO_DATE( '30/12/2008 23:59:59' , 'dd/mm/yyyy hh24:mi:ss')     
AND (tp_tarifacao NOT LIKE ('VC2%') or tp_tarifacao NOT LIKE ('VC3%') or tp_tarifacao NOT LIKE ('LDI%'))     
AND (DS_ROAMING in('ROAMING TIM') or (CD_ZONA_ORIGEM not LIKE ('%21') AND OPERADORA = 'Oi'))

--Local a Cobrar--
SELECT ROWID,a.*  FROM CHAMADA a     
WHERE MSISDN in ('552111163232')--('552122330001','552122330002','552122330003')     
AND dt_inicio BETWEEN TO_DATE('01/12/2008 00:00:01' , 'dd/mm/yyyy hh24:mi:ss')
AND TO_DATE( '30/12/2008 23:59:59' , 'dd/mm/yyyy hh24:mi:ss')     
AND (tp_tarifacao LIKE ('VCA%') OR  tp_tarifacao LIKE ('VCS%') OR tp_tarifacao LIKE('VC1A%')
 OR tp_tarifacao LIKE ('CP%') OR tp_tarifacao LIKE ('PV%'))     
AND DS_ACOBRAR = '1' 

 

--Interurbanos--
SELECT *  FROM  CHAMADA     
WHERE MSISDN in ('552111163232')--('552111130001','552122330002','552122330003')     
AND dt_inicio BETWEEN TO_DATE( '01/12/2008 00:00:01' , 'dd/mm/yyyy hh24:mi:ss')
AND TO_DATE( '30/12/2008 23:59:59' , 'dd/mm/yyyy hh24:mi:ss')     
AND (TP_TARIFACAO LIKE ( 'VC2%') OR TP_TARIFACAO LIKE ('VC3%') OR  TP_TARIFACAO LIKE ('LDI%'))     
    
--Oi Total--    
SELECT *  FROM  CHAMADA     
WHERE MSISDN in ('552111163233')--('552111130001','552122330002','552122330003')     
AND dt_inicio BETWEEN TO_DATE( '01/12/2008 00:00:01' , 'dd/mm/yyyy hh24:mi:ss')
AND TO_DATE( '30/12/2008 23:59:59' , 'dd/mm/yyyy hh24:mi:ss')     
AND TP_TARIFACAO LIKE ('VC1F%')     
AND (DS_DESTINO = 'PSTN' OR DS_DESTINO = 'PLMN' )  


--Oi Total para outras cidades--
Select * from chamada where msisdn in ('552111163232','552111163233','552111163234','552111163235') and
(tp_tarifacao LIKE ('VC2Fix%') OR  tp_tarifacao LIKE ('VC3Fix%') and DS_DESTINO = 'PSTN') OR
(tp_tarifacao LIKE ('VC2FixOi%') OR  tp_tarifacao LIKE ('VC3FixOi%') and DS_DESTINO = 'PLMN') OR
(tp_tarifacao LIKE ('VC2Fix%') OR  tp_tarifacao LIKE ('VC3Fix%') and DS_DESTINO = 'PLMN') OR
(tp_tarifacao LIKE ('LDIFix%') and DS_DESTINO = 'PSTN')

 


--SMS--
SELECT *  FROM  CHAMADA     
WHERE MSISDN in ('552111163239')--('552111130001','552122330002','552122330003')     
AND dt_inicio BETWEEN TO_DATE( '01/12/2008 00:00:01' , 'dd/mm/yyyy hh24:mi:ss')
AND TO_DATE( '30/12/2008 23:59:59' , 'dd/mm/yyyy hh24:mi:ss')     
AND TP_CHAMADA IN ('4','5') 

--GPRS WEB--
SELECT *  FROM  CHAMADA     
WHERE MSISDN in ('552111163232')--('552111130001','552122330002','552122330003')     
AND dt_inicio BETWEEN TO_DATE( '01/12/2008 00:00:01' , 'dd/mm/yyyy hh24:mi:ss')
AND TO_DATE( '30/12/2008 23:59:59' , 'dd/mm/yyyy hh24:mi:ss')     
AND TP_CHAMADA IN ('6')      
AND TP_TARIFACAO NOT LIKE  ('%WAP%') 

--GPRS WAP--
SELECT *  FROM  CHAMADA     
WHERE MSISDN in ('552111163232')--('552111130001','552122330002','552122330003')     
AND dt_inicio BETWEEN TO_DATE( '01/12/2008 00:00:01' , 'dd/mm/yyyy hh24:mi:ss')
AND TO_DATE( '30/12/2008 23:59:59' , 'dd/mm/yyyy hh24:mi:ss')     
AND TP_CHAMADA IN ('6')      
AND TP_TARIFACAO  LIKE  ('%WAP%')

--MMS--
SELECT * FROM CHAMADA      
WHERE MSISDN in ('552111163232')--('552111130001')--,'552122330002','552122330003')     
AND dt_inicio BETWEEN TO_DATE( '01/12/2008 00:00:01' , 'dd/mm/yyyy hh24:mi:ss')
AND TO_DATE( '30/12/2008 23:59:59' , 'dd/mm/yyyy hh24:mi:ss')     
AND TP_CHAMADA = '8'

 

--Predileto--
SELECT * FROM L_MUDANCAS_OI_PREDILETO WHERE CD_MSISDN IN ('552111163239')--,'552111130002','552122330003') 

--

SELECT * FROM CHAMADA_AICE WHERE MSISDN IN ('552111163233')--,'552111130006','552111130007','552111130008')  

SELECT * FROM CLIENTES --WHERE MSISDN IN ('552111163233')--,'552111130006','552111130007','552111130008')

SELECT * FROM TB_CLIENTES_SALDO --WHERE MSISDN IN ('552111163233')--,'552111130006','552111130007','552111130008')

SELECT * FROM HIST_AJUSTE WHERE MSISDN IN ('552111163235')--('552111130005','552111130006','552111130007','552111130008') 

SELECT * FROM HISTSPACE --WHERE MSISDN IN ('552111163235')--voucher_number IN ('923861084','923861085','923861086','923861087') 

SELECT * FROM HISTREQUISICAOCREDITO WHERE MSISDN IN ('552111163235')--,'552111130006','552111130007','552111130008') AND CD_ERRO = '0'

--Taxas de serviço--
SELECT rowid,a.* FROM HISTREQUISICAODEBITO a      
WHERE msisdn in ('552111163232','552111163233','552111163234','552111163235')     


AND hrd.dt_requisicao BETWEEN TO_DATE( '01/11/2008 00:00:01' , 'dd/mm/yyyy hh24:mi:ss')
AND TO_DATE( '15/11/2008 23:59:59' , 'dd/mm/yyyy hh24:mi:ss')     
AND hrd.cd_canal = dt.cd_canal     
AND cd_erro=0     
AND hrd.cd_origem = dt.cd_origem