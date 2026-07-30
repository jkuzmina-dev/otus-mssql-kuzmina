-- !!! без параметров RECEIVE TargetQueueWWI
CREATE or alter PROCEDURE Sales.GetNewCustomer
AS
BEGIN

	DECLARE @TargetDlgHandle UNIQUEIDENTIFIER,
			@Message NVARCHAR(4000),
			@MessageType Sysname,
			@ReplyMessage NVARCHAR(4000),
			@ReplyMessageName Sysname,
			@CustomerID INT,
			@DateFrom Date, 
			@DateTo Date,
			@xml XML; 
	
	BEGIN TRAN; 

		RECEIVE TOP(1) --!!
			@TargetDlgHandle = Conversation_Handle,
			@Message = Message_Body,
			@MessageType = Message_Type_Name
		FROM dbo.TargetQueueWWI; 

		SET @xml = CAST(@Message AS XML);

		SELECT 
			@CustomerID = R.Iv.value('@CustomerID','INT'),
			@DateFrom = R.Iv.value('@DateFrom','Date'), 
			@DateTo = R.Iv.value('@DateTo','Date') 
			FROM @xml.nodes('/RequestMessage/cust') as R(Iv)

		IF EXISTS (SELECT * FROM Sales.Customers WHERE CustomerID = @CustomerID) BEGIN
			INSERT INTO Sales.CustOrders(
				CustomerID,
				DateFrom,
				DateTo,
				OrdersCount,
				CreationDateTime
			)
			VALUES(
				@CustomerID,
				@DateFrom,
				@DateTo,
				(SELECT count(OrderID)
				  FROM Sales.Orders
				  where CustomerID = @CustomerID and OrderDate between @DateFrom and @DateTo),
			     GETUTCDATE()
				 )
		END;
		
		SELECT @Message AS ReceivedRequestMessage, @MessageType; 
		
		-- Confirm and Send a reply
		IF @MessageType = N'//WWI/SB/RequestMessage' BEGIN
			SET @ReplyMessage = N'<ReplyMessage> Message received</ReplyMessage>'; 
		
			SEND ON CONVERSATION @TargetDlgHandle MESSAGE TYPE [//WWI/SB/ReplyMessage] (@ReplyMessage);
			END CONVERSATION @TargetDlgHandle; --!!!
		END 
		
		SELECT @ReplyMessage AS SentReplyMessage; 

	COMMIT TRAN;
END