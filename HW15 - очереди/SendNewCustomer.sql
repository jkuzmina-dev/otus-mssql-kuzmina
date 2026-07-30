CREATE or alter PROCEDURE Sales.SendNewCustomer @CustomerID INT, @DateFrom Date, @DateTo Date
AS
BEGIN
	SET NOCOUNT ON;

	--Send to the Target	
	DECLARE @InitDlgHandle UNIQUEIDENTIFIER; --!!!
	DECLARE @RequestMessage NVARCHAR(4000);
		
	BEGIN TRAN --!!!

		SELECT @RequestMessage = (SELECT CustomerID, @DateFrom as DateFrom, @DateTo as DateTo
								  FROM Sales.Customers AS cust
								  WHERE CustomerID = @CustomerID
								  FOR XML AUTO, root('RequestMessage')); 
		
		--Determine the Initiator Service, Target Service and the Contract 
		BEGIN DIALOG @InitDlgHandle --!!!
		FROM SERVICE [//WWI/SB/InitiatorService] TO SERVICE '//WWI/SB/TargetService'
		ON CONTRACT [//WWI/SB/Contract]
		WITH ENCRYPTION = OFF; 

		--Send the Message
		SEND ON CONVERSATION @InitDlgHandle MESSAGE TYPE [//WWI/SB/RequestMessage] (@RequestMessage);
		
		SELECT @RequestMessage AS SentRequestMessage;
	
	COMMIT TRAN 
END
GO