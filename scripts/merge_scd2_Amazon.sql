/*
Stored procedure to merge staging (dbo.stg_Amazon) into dbo.fct_Amazon using SCD Type 2 logic.
Business key: Col1, Col2, Col3 (adjust as needed)

Usage: execute dbo.sp_Merge_Amazon_From_Staging;
*/
SET NOCOUNT ON;

IF OBJECT_ID('dbo.sp_Merge_Amazon_From_Staging', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_Merge_Amazon_From_Staging;
GO

CREATE PROCEDURE dbo.sp_Merge_Amazon_From_Staging
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;
        -- Compute hashes on staging if not present
        UPDATE dbo.stg_Amazon
        SET BusinessKeyHash = HASHBYTES('SHA1', ISNULL(Col1,'') + '|' + ISNULL(Col2,'') + '|' + ISNULL(Col3,'')),
            RowHash = HASHBYTES('SHA1',
                ISNULL(Col1,'')+'|'+ISNULL(Col2,'')+'|'+ISNULL(Col3,'')+'|'+ISNULL(Col4,'')+'|'+ISNULL(Col5,'')+'|'+
                ISNULL(Col6,'')+'|'+ISNULL(Col7,'')+'|'+ISNULL(Col8,'')+'|'+ISNULL(Col9,'')+'|'+ISNULL(Col10,'')+'|'+
                ISNULL(Col11,'')+'|'+ISNULL(Col12,'')+'|'+ISNULL(Col13,'')+'|'+ISNULL(Col14,'')+'|'+ISNULL(Col15,'')+'|'+
                ISNULL(Col16,'')+'|'+ISNULL(Col17,'')+'|'+ISNULL(Col18,'')+'|'+ISNULL(Col19,'')+'|'+ISNULL(Col20,'')+'|'+
                ISNULL(Col21,'')+'|'+ISNULL(Col22,'')+'|'+ISNULL(Col23,'')+'|'+ISNULL(Col24,'')+'|'+ISNULL(Col25,'')+'|'+
                ISNULL(Col26,'')+'|'+ISNULL(Col27,'')+'|'+ISNULL(Col28,'')+'|'+ISNULL(Col29,'')+'|'+ISNULL(Col30,'')+'|'+
                ISNULL(Col31,'')+'|'+ISNULL(Col32,'')+'|'+ISNULL(Col33,'')+'|'+ISNULL(Col34,'')+'|'+ISNULL(Col35,'')+'|'+
                ISNULL(Col36,'')+'|'+ISNULL(Col37,'')+'|'+ISNULL(Col38,'')+'|'+ISNULL(Col39,'')+'|'+ISNULL(Col40,'')+'|'+
                ISNULL(Col41,'')+'|'+ISNULL(Col42,'')+'|'+ISNULL(Col43,'')+'|'+ISNULL(Col44,'')+'|'+ISNULL(Col45,'')+'|'+
                ISNULL(Col46,'')+'|'+ISNULL(Col47,'')+'|'+ISNULL(Col48,'')+'|'+ISNULL(Col49,'')+'|'+ISNULL(Col50,'')
            )
        WHERE BusinessKeyHash IS NULL OR RowHash IS NULL;

        DECLARE @ClosedRows INT = 0;
        DECLARE @InsertedRows INT = 0;

        -- Close existing current records that have changed
        UPDATE f
        SET f.IsCurrent = 0,
            f.EndDate = SYSUTCDATETIME()
        FROM dbo.fct_Amazon f
        INNER JOIN dbo.stg_Amazon s
            ON f.BusinessKeyHash = s.BusinessKeyHash
        WHERE f.IsCurrent = 1
          AND (f.RowHash IS NULL OR s.RowHash IS NULL OR f.RowHash <> s.RowHash);

        SET @ClosedRows = @@ROWCOUNT;

        -- Insert new records for new keys or changed rows
        INSERT INTO dbo.fct_Amazon (
            Col1, Col2, Col3, Col4, Col5, Col6, Col7, Col8, Col9, Col10,
            Col11, Col12, Col13, Col14, Col15, Col16, Col17, Col18, Col19, Col20,
            Col21, Col22, Col23, Col24, Col25, Col26, Col27, Col28, Col29, Col30,
            Col31, Col32, Col33, Col34, Col35, Col36, Col37, Col38, Col39, Col40,
            Col41, Col42, Col43, Col44, Col45, Col46, Col47, Col48, Col49, Col50,
            BusinessKeyHash, RowHash, IsCurrent, StartDate)
        SELECT
            s.Col1, s.Col2, s.Col3, s.Col4, s.Col5, s.Col6, s.Col7, s.Col8, s.Col9, s.Col10,
            s.Col11, s.Col12, s.Col13, s.Col14, s.Col15, s.Col16, s.Col17, s.Col18, s.Col19, s.Col20,
            s.Col21, s.Col22, s.Col23, s.Col24, s.Col25, s.Col26, s.Col27, s.Col28, s.Col29, s.Col30,
            s.Col31, s.Col32, s.Col33, s.Col34, s.Col35, s.Col36, s.Col37, s.Col38, s.Col39, s.Col40,
            s.Col41, s.Col42, s.Col43, s.Col44, s.Col45, s.Col46, s.Col47, s.Col48, s.Col49, s.Col50,
            s.BusinessKeyHash, s.RowHash, 1, SYSUTCDATETIME()
        FROM dbo.stg_Amazon s
        LEFT JOIN dbo.fct_Amazon f
            ON s.BusinessKeyHash = f.BusinessKeyHash
           AND f.IsCurrent = 1
        WHERE f.SurrogateKey IS NULL
           OR (f.RowHash IS NULL OR s.RowHash IS NULL OR f.RowHash <> s.RowHash);

        SET @InsertedRows = @@ROWCOUNT;

        COMMIT TRANSACTION;

        -- Return summary for monitoring
        SELECT @ClosedRows AS ClosedRows, @InsertedRows AS InsertedRows;

    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0
            ROLLBACK TRANSACTION;

        DECLARE @ErrMsg NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR('sp_Merge_Amazon_From_Staging failed: %s', 16, 1, @ErrMsg);
    END CATCH
END
GO
