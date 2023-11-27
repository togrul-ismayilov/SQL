SELECT
    I7.DOC_DATE AS "Date",
    I8.DOC_NO AS "Doc #",
    I3.WHOUSE_CODE AS "Warehouse Code",
    I3.DESCRIPTION AS "Warehouse Name",
    I4.WHOUSE_CODE AS "Counter Warehouse Code",
    I4.DESCRIPTION AS "Counter Warehouse Name",
    I2.ITEM_CODE AS "Item Code",
    I2.ITEM_NAME AS "Item Name",
    GDT.DESCRIPTION AS "Transaction Name",
    GDT.DOC_TRA_CODE AS "Transaction Code",
    U2.UNIT_CODE AS "Unit",
    PACC.ACC_CODE AS "Accounts Code",
    PACC.ACC_DESC AS "Accounts Name",
    SUM(CASE WHEN I7.PLUS_MINUS =  1 THEN I7.QTY_PRM ELSE 0 END) AS "Entry Quantity",
    SUM(CASE WHEN I7.PLUS_MINUS = -1 THEN I7.QTY_PRM ELSE 0 END) AS "Exit Quantity",
    (
        SELECT SUM(t.PLUS_MINUS * t.QTY_PRM) 
        FROM INVT_ITEM_D t
        INNER JOIN GNLP_INV_PARAMETER G ON t.CO_ID = G.CO_ID
        WHERE t.WHOUSE_ID = I3.WHOUSE_ID
            AND t.CO_ID = I7.CO_ID
            AND t.DOC_DATE >= (
                SELECT 
                    CASE 
                        WHEN G.INV_PERIOD_START_DATE = TO_DATE('@DocDateF@','DD.MM.YYYY') THEN TRUNC(TO_DATE('@DocDateF@','DD.MM.YYYY') - 66,'YYYY') 
                        ELSE G.INV_PERIOD_START_DATE 
                    END
                FROM GNLP_INV_PARAMETER 
                WHERE TO_CHAR(G.INV_PERIOD_START_DATE, 'YYYY') = TO_CHAR(TO_DATE('@DocDateF@','DD.MM.YYYY'), 'YYYY')
            )
            AND t.DOC_DATE < CASE '@DocDateF@'
                WHEN CHR(64) || 'DocDateF' || CHR(64) THEN TO_DATE('01.01.0001', 'DD.MM.YYYY')
                WHEN 'null' THEN TO_DATE('01.01.0001', 'DD.MM.YYYY')
                ELSE TO_DATE('@DocDateF@', 'DD.MM.YYYY')
            END
            AND t.ITEM_ID IN (I2.ITEM_ID)
    ) AS "Initial Remaining Quantity",
    (
        SELECT SUM(t.PLUS_MINUS * t.QTY_PRM) 
        FROM INVT_ITEM_D t
        INNER JOIN GNLP_INV_PARAMETER G ON t.CO_ID = G.CO_ID
        WHERE t.WHOUSE_ID = I3.WHOUSE_ID
            AND t.CO_ID = I7.CO_ID
            AND t.DOC_DATE >= (
                SELECT G.INV_PERIOD_START_DATE 
                FROM GNLP_INV_PARAMETER 
                WHERE TO_CHAR(G.INV_PERIOD_START_DATE, 'YYYY') = TO_CHAR(TO_DATE('@DocDateL@','DD.MM.YYYY'), 'YYYY')
            )
            AND t.DOC_DATE <= CASE '@DocDateL@'
                WHEN CHR(64) || 'DocDateL' || CHR(64) THEN TO_DATE('31.12.9999', 'DD.MM.YYYY')
                WHEN 'null' THEN TO_DATE('31.12.9999', 'DD.MM.YYYY')
                ELSE TO_DATE('@DocDateL@', 'DD.MM.YYYY')
            END
            AND t.ITEM_ID IN (I2.ITEM_ID)
    ) AS "Final Remaining Quantity",
    SUM(CASE WHEN I7.PLUS_MINUS =  1 THEN I7.AMT_TRA ELSE 0 END) AS "Entry Amount",
    SUM(CASE WHEN I7.PLUS_MINUS =  -1 THEN I7.AMT_TRA ELSE 0 END) AS "Exit Amount"
FROM 
    INVT_ITEM_D I7
    INNER JOIN GNLP_INV_PARAMETER G4 ON I7.CO_ID = G4.CO_ID
    INNER JOIN GNLD_COMPANY G1 ON I7.CO_ID = G1.CO_ID
    INNER JOIN INVD_ITEM I2 ON I7.ITEM_ID = I2.ITEM_ID
    INNER JOIN INVD_BRANCH_ITEM IB ON I2.ITEM_ID = IB.ITEM_ID AND IB.CO_ID = I7.CO_ID
    LEFT JOIN INVD_ITEM_ACC_INTG INT ON IB.I_ACC_INTG_TYPE_CODE_ID = INT.I_ACC_INTG_TYPE_CODE_ID AND ACC_INTG_TYPE_ID = 48 AND INT.CO_ID = I7.CO_ID
    LEFT JOIN INVD_ITEM_UNIT II2 ON I2.ITEM_ID = II2.ITEM_ID AND I2.UNIT_ID = II2.UNIT_ID AND II2.UNIT2_ID = 169
    LEFT JOIN FIND_ACC PACC ON PACC.ACC_ID = INT.PURCHASE_ACC_ID
    INNER JOIN INVT_ITEM_M I8 ON I7.ITEM_M_ID = I8.ITEM_M_ID
    LEFT JOIN GNLD_DOC_TRA GDT ON I8.DOC_TRA_ID = GDT.DOC_TRA_ID
    LEFT JOIN INVD_UNIT U2 ON I2.UNIT_ID = U2.UNIT_ID
    INNER JOIN INVD_WHOUSE I3 ON I7.WHOUSE_ID = I3.WHOUSE_ID
    LEFT JOIN INVD_WHOUSE I4 ON I7.WHOUSE2_ID = I4.WHOUSE_ID
WHERE 
    G1.CO_CODE = '@CoCode@'
    AND (
        GDT.DOC_TRA_CODE IN (SELECT CODE FROM TABLE(RP_SPLIT('@DocTraCode@'))) 
        OR '@DocTraCode@' = 'null'
    )
    AND (
        I3.WHOUSE_CODE IN (SELECT CODE FROM TABLE(RP_SPLIT('@WhouseCode@'))) 
        OR '@WhouseCode@' = 'null'
    )
    AND (
        I2.ITEM_CODE >= '@ItemCodeF@' OR '@ItemCodeF@' = 'null'
    )
    AND (
        I2.ITEM_CODE <= '@ItemCodeL@' OR '@ItemCodeL@' = 'null'
    )
    AND I7.DOC_DATE >= CASE '@DocDateF@'
        WHEN CHR(64) || 'DocDateF' || CHR(64) THEN TO_DATE('01.01.0001', 'DD.MM.YYYY')
        WHEN 'null' THEN TO_DATE('01.01.0001', 'DD.MM.YYYY')
        ELSE TO_DATE('@DocDateF@', 'DD.MM.YYYY')
    END
    AND I7.DOC_DATE <= CASE '@DocDateL@'
        WHEN CHR(64) || 'DocDateL' || CHR(64) THEN TO_DATE('31.12.9999', 'DD.MM.YYYY')
        WHEN 'null' THEN TO_DATE('31.12.9999','DD.MM.YYYY')
        ELSE TO_DATE('@DocDateL@', 'DD.MM.YYYY')
    END
GROUP BY 
    I7.CO_ID,
    I2.ITEM_CODE, 
    I2.ITEM_ID,
	I2.ITEM_NAME,
    I7.DOC_DATE,
    I8.DOC_NO,
    I3.WHOUSE_CODE,
    I3.WHOUSE_id,
    I3.DESCRIPTION, 
    I4.WHOUSE_CODE,
    I4.DESCRIPTION,
    GDT.DESCRIPTION,
    GDT.DOC_TRA_CODE,
    U2.UNIT_CODE,
    PACC.ACC_CODE,
    PACC.ACC_DESC,
    I7.PLUS_MINUS;
