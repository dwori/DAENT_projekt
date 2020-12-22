GO
CREATE OR ALTER PROCEDURE sp_changePriority
    @ticket_id  INT,
    @priority TINYINT,

    --Error Handeling ;)
    @errorCode INT = NULL OUTPUT, 
    @errorLine int = NULL OUTPUT,
    @errorMsg VARCHAR(500) = NULL OUTPUT,
    @select bit = 0
    


        AS
        BEGIN
            SET NOCOUNT ON;
            BEGIN TRY


            --Wenn Ticket existiert, f�hre Code aus.
            IF (SELECT COUNT(*) FROM dbo.ticket WHERE id = @ticket_id AND priority = @priority) = 1
            THROW 50004, 'ticket has already this priority',1;

            IF (SELECT COUNT(*) FROM dbo.ticket WHERE id = @ticket_id) = 1
            BEGIN
                UPDATE ticket
                SET priority = @priority
                WHERE id = @ticket_id

            END
            ELSE
                THROW 50025,'This ticket does not exist!',1;

            SET @errorCode = @priority

            END TRY
            BEGIN CATCH
            SET @errorLine = ERROR_LINE()
            SET @errorMsg = ERROR_MESSAGE()
            IF ERROR_MESSAGE() like '%FK_ticket_priorities%'
                SET @errorCode = -1
            ELSE IF ERROR_MESSAGE() like '%FK_ticket%'
                SET @errorCode = -2

            ELSE IF ERROR_NUMBER() >= 50000
                SET @errorCode = (ERROR_NUMBER() - 50000) * -1
            ELSE
                SET @errorCode = -99
        END CATCH
        IF @select = 1
             SELECT @errorCode AS errorCode,
            @errorMsg AS errorMsg,
            @errorLine AS errorLine
        ELSE IF @errorCode > 0
            SELECT @errorCode AS userId
        END
GO