SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE OR ALTER   PROCEDURE dbo.sp_createTicket
    @subject VARCHAR(100),
    @content VARCHAR(255),
    @customer INT,
    @status TINYINT = 1,
    @category TINYINT,
    @priority TINYINT = 1,
    
    @errorCode int = NULL OUTPUT,  -- USER ID is returned if procedures gets executed without error
    @errorLine int = NULL OUTPUT,
    @errorMsg VARCHAR(500) = NULL OUTPUT,
    @select bit = 0

    AS
    BEGIN
        SET NOCOUNT ON;
        --Variables
        DECLARE @agent INT

        BEGIN TRY
            --Den Agenten mit der geringsten ticket_queue ermitteln und @agent hizufügen
            SET @agent = (SELECT TOP 1 id FROM dbo.staff WHERE id IN(SELECT sid FROM dbo.ticket_categories_staff WHERE tcid = @category)
            ORDER BY ticket_queue ASC)
            --ticket queue für diesen Agenten um 1 erhöhen
            

            INSERT INTO dbo.ticket(subject,ticket_content,customer_number,agent,status,category,priority)
            VALUES(@subject,@content,@customer,@agent,@status,@category,@priority)
            SET @errorCode = SCOPE_IDENTITY();

            IF ERROR_MESSAGE() IS NULL
            BEGIN
                UPDATE dbo.staff
                SET ticket_queue = ISNULL(ticket_queue,0) + 1
                WHERE id = @agent;
            END
        END TRY
        BEGIN CATCH
            
            SET @errorLine = ERROR_LINE()
            SET @errorMsg = ERROR_MESSAGE()
            IF ERROR_MESSAGE() like '%FK_ticket_customer%'
                SET @errorCode = -2
            ELSE IF ERROR_MESSAGE() like '%FK_ticket_categories%'
                SET @errorCode = -1
            ELSE
                SET @errorCode = -99

        END CATCH
        IF @select = 1
            SELECT @errorCode AS resultCode, @errorMsg AS errorMessage, @errorLine AS errorLine
    END
GO
