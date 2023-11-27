SELECT   FE.ENTITY_CODE "Customer Code"
        ,FE.ENTITY_NAME "Customer Name" 
        ,FA.ACC_CODE "Account Code"
        ,G2.DESCRIPTION  "Market Chain Code"
        ,G3.DESCRIPTION  "Category"
        ,GRP1.ENTITY_GRP_NAME "Sales Channel" 
        ,GRP2.ENTITY_GRP_NAME "Market Chain Name"      
        ,SUM((CASE WHEN TABLE1.AMT > TABLE1.BALANCE THEN TABLE1.BALANCE ELSE TABLE1.AMT END)) "Total Debt"        
        ,SUM(CASE WHEN TABLE1.DAY1 < 16 THEN 
                 (CASE WHEN TABLE1.AMT > TABLE1.BALANCE THEN TABLE1.BALANCE ELSE TABLE1.AMT END) 
             ELSE 0 END)  "0-15"           
        ,SUM(CASE WHEN TABLE1.DAY1 > 15 AND TABLE1.DAY1 < 31 THEN 
                  (CASE WHEN TABLE1.AMT > TABLE1.BALANCE THEN TABLE1.BALANCE ELSE TABLE1.AMT END) 
             ELSE 0 END)  "16-30"
        ,SUM(CASE WHEN TABLE1.DAY1 > 30 AND TABLE1.DAY1 < 61 THEN 
                  (CASE WHEN TABLE1.AMT > TABLE1.BALANCE THEN TABLE1.BALANCE ELSE TABLE1.AMT END) 
             ELSE 0 END)  "31-60"    
               -------------------
              ,SUM(CASE WHEN TABLE1.DAY1 > 60 AND TABLE1.DAY1 < 91 THEN 
                  (CASE WHEN TABLE1.AMT > TABLE1.BALANCE THEN TABLE1.BALANCE ELSE TABLE1.AMT END) 
             ELSE 0 END)  "61-90" 
               ,SUM(CASE WHEN TABLE1.DAY1 > 90 AND TABLE1.DAY1 < 121 THEN 
                  (CASE WHEN TABLE1.AMT > TABLE1.BALANCE THEN TABLE1.BALANCE ELSE TABLE1.AMT END) 
             ELSE 0 END)  "91-120"       
               -------------------              
        ,SUM(CASE WHEN TABLE1.DAY1 > 120 AND TABLE1.DAY1 < 181 THEN 
                 (CASE WHEN TABLE1.AMT > TABLE1.BALANCE THEN TABLE1.BALANCE ELSE TABLE1.AMT END)
             ELSE 0 END)  "121-180"      
        ,SUM(CASE WHEN TABLE1.DAY1 > 180 AND TABLE1.DAY1 < 361 THEN 
                  (CASE WHEN TABLE1.AMT > TABLE1.BALANCE THEN TABLE1.BALANCE ELSE TABLE1.AMT END) 
             ELSE 0 END)  "181-360"                                         
        ,SUM(CASE WHEN TABLE1.DAY1 > 360  THEN 
                  (CASE WHEN TABLE1.AMT > TABLE1.BALANCE THEN TABLE1.BALANCE ELSE TABLE1.AMT END) 
             ELSE 0 END)  "360 Days and Above"                      
FROM
(         SELECT FD.DOC_DATE
                ,(TO_DATE('@pDocdateF@', 'DD.MM.YYYY')  - FD.DOC_DATE) DAY1
                ,FD.ENTITY_ID EID             
                ,FD.AMT AMT
                ,SUM(FD.AMT) OVER (PARTITION BY FD.ENTITY_ID  ORDER BY FD.DOC_DATE ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) -  NVL(FC.AMT_CREDIT,0) BALANCE
       
         FROM       FINT_FIN_D FD 
        left  join FINT_FIN_m          fm on fd.fin_m_id   = fm.fin_m_id
         INNER JOIN  FIND_ENTITY         FE ON FD.ENTITY_ID        = FE.ENTITY_ID
         INNER JOIN GNLD_COMPANY        CM ON FD.CO_ID            = CM.CO_ID
         INNER JOIN GNLD_BRANCH         BR ON FD.BRANCH_ID        = BR.BRANCH_ID
         INNER JOIN FIND_CO_ENTITY     FE2 ON FE.ENTITY_ID        = FE2.ENTITY_ID   AND FE2.CO_ID=BR.CO_ID
         LEFT  JOIN GNLD_CATEGORIES     G1 ON FE.CATEGORIES1_ID   = G1.CATEGORIES_ID
         LEFT  JOIN GNLD_CATEGORIES     G2 ON FE.CATEGORIES2_ID   = G2.CATEGORIES_ID 
         LEFT  JOIN GNLD_CATEGORIES     G3 ON FE.CATEGORIES3_ID   = G3.CATEGORIES_ID 
         LEFT  JOIN FIND_ENTITY_GROUP GRP1 ON FE2.ENTITY_GRP_ID   = GRP1.ENTITY_GRP_ID 
         LEFT  JOIN FIND_ENTITY_GROUP GRP2 ON FE2.ENTITY_GRP2_ID  = GRP2.ENTITY_GRP_ID 
         LEFT  JOIN (SELECT FD.ENTITY_ID
                           ,SUM(FD.AMT) AMT_CREDIT     
                     FROM       FINT_FIN_D          FD 
                     left  join FINT_FIN_m          fm on fd.fin_m_id   = fm.fin_m_id
                     INNER JOIN FIND_ENTITY         FE ON FD.ENTITY_ID        = FE.ENTITY_ID
                     INNER JOIN GNLD_COMPANY        CM ON FD.CO_ID            = CM.CO_ID  
                     INNER JOIN GNLD_BRANCH         BR ON FD.BRANCH_ID        = BR.BRANCH_ID
                     INNER JOIN FIND_CO_ENTITY     FE2 ON FE.ENTITY_ID        = FE2.ENTITY_ID AND FE2.CO_ID=CM.CO_ID
                     LEFT  JOIN GNLD_CATEGORIES     G1 ON FE.CATEGORIES1_ID   = G1.CATEGORIES_ID
                     LEFT  JOIN GNLD_CATEGORIES     G2 ON FE.CATEGORIES2_ID   = G2.CATEGORIES_ID 
                     LEFT  JOIN GNLD_CATEGORIES     G3 ON FE.CATEGORIES3_ID   = G3.CATEGORIES_ID 
                     LEFT  JOIN FIND_ENTITY_GROUP GRP1 ON FE2.ENTITY_GRP_ID   = GRP1.ENTITY_GRP_ID
                     LEFT  JOIN FIND_ENTITY_GROUP GRP2 ON FE2.ENTITY_GRP2_ID   = GRP2.ENTITY_GRP_ID 
                     WHERE        CM.CO_CODE = '@pCoCode@' 
                              AND (BR.BRANCH_CODE IN        (SELECT CODE FROM TABLE(RP_SPLIT('@pBranchCodes@'))) OR        '@pBranchCodes@' = 'null')    
                              AND (FE.ENTITY_CODE >= '@pEntityCodeF@' OR '@pEntityCodeF@' = 'null')    
                              AND (FE.ENTITY_CODE <= '@pEntityCodeL@' OR '@pEntityCodeL@' = 'null')    
                              AND FD.DOC_DATE <= TO_DATE('@pDocdateF@', 'DD.MM.YYYY') 
                             AND FE2.CO_ID=CM.CO_ID
                              AND FD.PLUS_MINUS  = -1
                              AND (G1.CATEGORIES_CODE  IN (SELECT CODE FROM TABLE(RP_SPLIT('@Categories1Codes@'))) OR '@Categories1Codes@' = 'null') 
                              AND (GRP2.ENTITY_GRP_CODE IN  (SELECT CODE FROM TABLE(RP_SPLIT('@EntityGrpCode2@'))) OR '@EntityGrpCode2@' = 'null') 
                              AND (G3.CATEGORIES_CODE IN (SELECT CODE FROM TABLE(RP_SPLIT('@Categories3Codes@'))) OR '@Categories3Codes@' = 'null')
                              AND (GRP1.ENTITY_GRP_CODE   = '@EntityGrpCode1@'  or '@EntityGrpCode1@'   = 'null' ) 
                     GROUP BY FD.ENTITY_ID,CM.CO_CODE ) FC ON FD.ENTITY_ID = FC.ENTITY_ID
                     
        WHERE        CM.CO_CODE = '@pCoCode@' 
                              AND (BR.BRANCH_CODE IN        (SELECT CODE FROM TABLE(RP_SPLIT('@pBranchCodes@'))) OR        '@pBranchCodes@' = 'null')    
                              AND (FE.ENTITY_CODE >= '@pEntityCodeF@' OR '@pEntityCodeF@' = 'null')    
                              AND (FE.ENTITY_CODE <= '@pEntityCodeL@' OR '@pEntityCodeL@' = 'null')    
                              AND FD.DOC_DATE <= TO_DATE('@pDocdateF@', 'DD.MM.YYYY') 
                              AND FE2.CO_ID=CM.CO_ID
                              AND FD.PLUS_MINUS  = 1
                              AND (G1.CATEGORIES_CODE  IN (SELECT CODE FROM TABLE(RP_SPLIT('@Categories1Codes@'))) OR '@Categories1Codes@' = 'null') 
                              AND (GRP2.ENTITY_GRP_CODE IN  (SELECT CODE FROM TABLE(RP_SPLIT('@EntityGrpCode2@'))) OR '@EntityGrpCode2@' = 'null') 
                              AND (G3.CATEGORIES_CODE IN (SELECT CODE FROM TABLE(RP_SPLIT('@Categories3Codes@'))) OR '@Categories3Codes@' = 'null')
                              AND (GRP1.ENTITY_GRP_CODE   = '@EntityGrpCode1@'  or '@EntityGrpCode1@'   = 'null' ) 
                           and FD.DOC_NO<>'Devir 2020'
         ORDER BY FD.DOC_DATE, FD.ENTITY_ID
)          TABLE1
INNER JOIN FIND_ENTITY FE ON TABLE1.EID = FE.ENTITY_ID
INNER JOIN FIND_CO_ENTITY     FE2 ON FE.ENTITY_ID        = FE2.ENTITY_ID 
LEFT  JOIN GNLD_CATEGORIES     G1 ON FE.CATEGORIES1_ID   = G1.CATEGORIES_ID
LEFT  JOIN GNLD_CATEGORIES     G2 ON FE.CATEGORIES2_ID   = G2.CATEGORIES_ID 
LEFT  JOIN GNLD_CATEGORIES     G3 ON FE.CATEGORIES3_ID   = G3.CATEGORIES_ID 
LEFT  JOIN FIND_ENTITY_GROUP GRP1 ON FE2.ENTITY_GRP_ID   = GRP1.ENTITY_GRP_ID
LEFT  JOIN FIND_ENTITY_GROUP GRP2 ON FE2.ENTITY_GRP2_ID   = GRP2.ENTITY_GRP_ID  
LEFT JOIN FIND_ACC            FA  ON  FE2.ACC_ID    =FA.ACC_ID
INNER JOIN GNLD_COMPANY        CM ON FE2.CO_ID            = CM.CO_ID  
WHERE   CM.CO_CODE = '@pCoCode@' AND TABLE1.BALANCE > 0
GROUP BY
         FE2.CO_ID
        ,FE.ENTITY_CODE 
        ,FE.ENTITY_NAME 
        ,FE.TAX_NO
        ,G1.DESCRIPTION 
        ,G2.DESCRIPTION 
        ,G3.DESCRIPTION 
        ,FA.ACC_CODE 
        ,GRP1.ENTITY_GRP_NAME
        ,GRP2.ENTITY_GRP_NAME 
ORDER BY 1,2,3,4,5,6,7,8,9,10;
