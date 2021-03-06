Option Explicit

Public sDate
Public iFreephoneTypeIndex
Public iRow
Public HtmlSummaryReport
Public rsFindRows
HtmlSummaryReport = "ERROR_Summary_report"

'Yael comment branch

'----------------------------------------------------------------------
' Function name: fBusCollectData
' Description: the function running all rate and pre Files  
' Parameters:
' Return value: 
' Example:
'----------------------------------------------------------------------
Public function fBusCollectData()

	sFileName = GlobalDictionary("FILE_NAME")

'	sRTRFilesPath = "C:\cygwin64\home\"& Environment.Value("UserName")&"\"
	sRTRFilesPath = "C:\cygwin\home\"& Environment.Value("UserName")&"\"
	sRateFilesPath = "/data/cdrdata/IP/QA/rating/realtime/" & Left(sFileName,8) & "/"

	If Window("~").Exist(1) = False Then
'		SystemUtil.Run "C:\cygwin64\bin\mintty.exe", "-i /Cygwin-Terminal.ico -"
		SystemUtil.Run "C:\cygwin\bin\mintty.exe", "-i /Cygwin-Terminal.ico -"
		Wait 5
		Window("text:=~").Type "ftp Ribur01"
		Window("text:=~").Type  micReturn 
		Window("text:=~").Type "rateipmtx"
		Window("text:=~").Type  micReturn 
		Window("text:=~").Type "ipmtx1"
		Window("text:=~").Type  micReturn 
		Wait 1
	Else
		Window("~").Activate
		wait 1
	End If

	'Collect pre files 
	If fGuiCollectPreFiles("TODO://current_date") <> True Then
		Call fReport("fBusCollectData","fGuiCollectPreFiles","FAIL","Collect pre_.txt files failed",0,iReportFailRow)
		fBusCollectData = False
		Exit Function
	Else
		Call fReport("fBusCollectData","fGuiCollectPreFiles","PASS","Collect pre_.txt files succeeded",0,iReportFailRow)
	End If

	'Collect rate files
    If fGuiCollectRateFiles(sFileName) <> True Then
		Call fReport("fBusCollectData","fGuiCollectRateFiles","FAIL","Collect ["& Left(sFileName,8) &"]-xxxxx.txt rate files failed",0,iReportFailRow)
		fBusCollectData = False
		Exit Function
	Else
		Call fReport("fBusCollectData","fGuiCollectRateFiles","PASS","Collect ["& Left(sFileName,8) &"]-xxxxx.txt rate files succeeded",0,iReportFailRow)
	End If

	'''Collect big files (file that required grep command to filter them)
'	If fGuiCollectBigFiles(sRateFilesPath,Left(sFileName,8)) <> True Then
'		Call fReport("fBusCollectData","fGuiCollectBigFiles","FAIL","Collect big files failed",0,iReportFailRow)
'		fBusCollectData = False
'		Exit Function
'	Else
'		Call fReport("fBusCollectData","fGuiCollectBigFiles","PASS","Collect big files succeeded",0,iReportFailRow)
'	End If

	'''Collect Input file
'	Call fCopyFileToLocalMachine(sInputOutputPath,GlobalDictionary("FILE_NAME"))

	'Exit from ftp connection
	Window("~").Activate
	Window("text:=~").Type "quit"
	Window("text:=~").Type  micReturn

	Call fGuiCreateIniFile()

	'Navigate to local path
	Window("~").Activate
'	Window("~").Type "cd c:/cygwin64/home/" & Environment.Value("UserName")&"/"
	Window("~").Type "cd c:/cygwin/home/" & Environment.Value("UserName")&"/"
	Window("~").Type micReturn 
	
	fBusCollectData = True

End Function
'----------------------------------------------------------------------
'----------------------------------------------------------------------
' Function name: fBusCdrInputFile
' Description: The functuion copies CDR File from remote server to local Machine and check CDR Type
' Parameters: 
' Return value: 
' Example:
'----------------------------------------------------------------------
Public function fBusCdrInputFile()

	Dim iCountAllErrorRates,iCustProductID,iVendProductID,sFoundFile,iRouteID
   	iCountAllErrorRates = 0
    
	Set objFSO = CreateObject("scripting.filesystemobject")
    Call objFSO.CopyFile(sRTRFilesPath & GlobalDictionary("FILE_NAME"),sCopyFilesPath,True)

	Set objFileRead = objFSO.OpenTextFile(sCopyFilesPath & GlobalDictionary("FILE_NAME"), 1)
	UnconnectedRows = 0
	iRow = 1
	 
	iNumberOfRows = GlobalDictionary("ROWS")
	While iRow <= cint(iNumberOfRows) and objFileRead.AtEndOfStream = False
    	
		ErroCDRsFlag = 0 'For the new row CDR
		Call fReport("fBusCdrInputFile","<B>Check row number " & iRow & " in CDR input file '" & GlobalDictionary("FILE_NAME") & "'</B>","TITLE","",0,iReportFailRow)
		Call fGuiCdrInputFile(GlobalDictionary("FILE_NAME"),iRow)
		Call fGuiGetFieldValue(sCopyFilesPath,"TempFile.txt","STATUS",sFieldVal)  'check CDR status
		If sFieldVal <> "CONNECT" Then
			Call fReport("fBusCdrInputFile"," Check CDR status" ,"FAIL","<B>Status field in CDR number " & iRow & " is not 'CONNECT'</B>",0,iReportFailRow)
			Call fUpdateArrErrorRows("Status row is not 'CONNECT'",iReportFailRow)
			objFileRead.SkipLine  'Continue to next row CDR
			iRow = iRow + 1
			UnconnectedRows = UnconnectedRows + 1
		Else

	'--------------------------------------------------------------------------------------------------
		'Get Route_ID value by Prefix in Pre_Route.txt for all cases.
		'iRouteID = fGuiGetRouteIDValue()
	'--------------------------------------------------------------------------------------------------

	'-----Get Customer_ID/Vendor_ID

	sCustomerID = fGuiGetCustomerID(InboundTrunkVal)
	If sCustomerID = -9 Then
		Call fReport ("fBusCdrInputFile","Get <B>Customer ID</B> from Pre_Otg.txt file according 'Inbound Trunk' field -" & InboundTrunkVal,"FAIL","<B>Customer ID Not found ,test stopped!</B>",0,iReportFailRow)
		Call fUpdateArrErrorRows("Customer_ID not found",iReportFailRow)
		bErrorRate = True
		fBusFreephoneType = False
		Exit Function
	Else
		Call fReport ("fBusCdrInputFile","Get <B>Customer ID</B> from Pre_Otg.txt file according 'Inbound Trunk' field -" & InboundTrunkVal,"PASS","<B>Customer ID: " & sCustomerID & "</B>",0,iReportFailRow)
	End If

	sVendorID = fGuiGetVendorID(OutgoingTrunkVal)
	If sVendorID = -9 Then
		Call fReport ("fBusCdrInputFile","Get <B>Vendor ID</B> from Pre_Ttg.txt file according 'OutgoingTrunk' field -" & OutgoingTrunkVal,"FAIL" ,"<B>Vendor ID Not found ,test stopped!</B>",0,iReportFailRow)
		Call fUpdateArrErrorRows("Vendor_ID not found",iReportFailRow)
		bErrorRate = True
		fBusFreephoneType = False
		Exit Function
	Else
		Call fReport ("fBusCdrInputFile","Get <B>Vendor ID</B> from Pre_Ttg.txt file according 'OutgoingTrunk' field -" & OutgoingTrunkVal,"PASS","<B>Vendor ID: " & sVendorID & "</B>",0,iReportFailRow)
	End If

	'---------- Check CDR type (Freephone, ISDN, Regular...) --------

			'--- Freephone
      			If fGuiCheckFreephone() <> True Then
					Call fReport("fBusCdrInputFile","<B>Check if currect CDR row is Freephone CDR</B>","HEADER","<B>Current CDR is not Freephone</B>",0,iReportFailRow)
					GFreephoneCDRType = ""
				Else 'CDR is Freephone
					Call fReport("fBusCdrInputFile","<B>Check if currect CDR row is freephone CDR</B>","INFO","According 'Routing-table key' field current CDR is <B>Freephone <B/>",0,iReportFailRow)
					Dim bErrorRate
					bErrorRate = False
					rc = fBusFreephoneType(ObjRS,bIsFreephone,bErrorRate,sCustomerID,sVendorID)
					If rc = False and bErrorRate = False Then 'Not Freephone, check for next type - ISDN
						Call fReport("fBusCdrInputFile","Check if currect CDR row is freephone CDR","INFO","<B>Current CDR is not freephone</B>",0,iReportFailRow)
					ElseIf rc = False and bErrorRate = True Then  'Error rate (for Italy case OR customer/vendor not found)
						iCountAllErrorRates = iCountAllErrorRates + 1
						GFreephoneCDRType = "ERROR"
                    ElseIf GFreephoneCDRType = "Freephone" Then'Row is Freephone and match rate row found
						Call fReport("fBusCdrInputFile","<B>Check if currect CDR row is freephone CDR</B>","PASS","<B>Current CDR is realy freephone CDR and match rate row found</B>",0,iReportFailRow)
						fBusCdrInputFile = True
   					End If
				End If
		
			'---ISDN
				If GFreephoneCDRType = "" Then 'Not a Freephone case
					If fGuiCheckISDN() <> True Then
						Call fReport("fBusCdrInputFile","<B>Check if currect CDR row is ISDN CDR</B>","HEADER","<B>Current CDR is not ISDN</B>",0,iReportFailRow)
					Else 'CDR is ISDN
						Call fReport("fBusCdrInputFile","<B>Check if currect CDR row is ISDN CDR</B>","INFO","According 'TMR' field current CDR is <B>ISDN</B>",0,iReportFailRow)
						Dim bCusISDNError,bVenISDNError
						bCusISDNError = False
						bVenISDNError = False
						'Check ISDN Customer Case
						rcCus = fBusCusISDN(objRSCust,sCustomerID,bCusISDNError)
							If rcCus = False and bCusISDNError = True Then 'didn't find CustomerID
									GCusCDRType = "ERROR"
								ElseIf rcCus = False and bCusISDNError = False Then
									Call fReport("fBusCdrInputFile","<B>Check if currect CDR row is ISDN Customer</B> ","INFO","<B>Current CDR is not ISDN Customer</B>",0,iReportFailRow)
									GCusCDRType = "" 'Check for the next case
								ElseIf rcCus = True and bCusISDNError = False Then
									Call fReport("fBusCdrInputFile","Check if currect CDR row is ISDN Customer ","PASS","<B>Current CDR is realy ISDN Customer</B>",0,iReportFailRow)
							End If
						'Check ISDN Vendor Case
						rcVen = fBusVenISDN(objRSVend,sVendorID,bVenISDNError)
							If rcVen = False and bVenISDNError = True Then 
									GVendCDRType = "ERROR"
								ElseIf rcVen = False and bVenISDNError = False Then
									Call fReport("fBusCdrInputFile","Check if currect CDR row is ISDN Vendor ","INFO","<B>Current CDR is not ISDN Vendor</B>",0,iReportFailRow)
									GVendCDRType = "" 'Check for the next case
								ElseIf rcVen = True and bVenISDNError = False Then
									Call fReport("fBusCdrInputFile","<B>Check if currect CDR row is ISDN Vendor</B>","PASS","<B>Current CDR is realy ISDN Vendor</B>",0,iReportFailRow)
							End If
					End If
				End If

			'---Transit
			If GFreephoneCDRType = "" and GCusCDRType = "" and GVendCDRType = "" Then 'Not Freephone/ISDN cases
				If fGuiCheckTransit(sVendorID) <> True Then 'CDR is't transit according to RTK
					Call fReport("fBusCdrInputFile","<B>Check if currect CDR row is Transit CDR</B>","HEADER","<B>Current CDR is not Transit</B>",0,iReportFailRow)
   				Else 'CDR is Transit
					Call fReport("fBusCdrInputFile","<B>Check if currect CDR row is Transit CDR</B>","INFO","According 'Routing-table key' field current CDR is <B>Transit <B/>",0,iReportFailRow)
					Dim bTransErrorRate
					bTransErrorRate = False
					rc = fBusTransitType(sCustomerID,sVendorID,rsTransitRate,bTransErrorRate,sFoundFile)
					If rc = False and bTransErrorRate = True Then 'System failure
						iCountAllErrorRates = iCountAllErrorRates + 1 
						ElseIf rc = False and GCusCDRType = "ERROR" and GVendCDRType = "ERROR" Then 'Not Transit, RERROR CDR
							Call fReport("fBusCdrInputFile","Check if currect CDR row is Transit CDR","INFO","<B>Current CDR is not Transit</B>",0,iReportFailRow)
						ElseIf rc = True and GCusCDRType = "Transit" and GVendCDRType = "ERROR" Then 'Find Customer on Master file, Vendor is ERROR
							Call fReport("fBusCdrInputFile","Check if currect CDR row is Transit CDR","INFO","<B>Find Customer on master file, Vendor is ERROR</B>",0,iReportFailRow)
						ElseIf rc = True and  GCusCDRType = "Transit" and GVendCDRType = "Transit" Then 'Row is Transit and match rate row found
							Call fReport("fBusCdrInputFile","<B>Check if currect CDR row is transit CDR</B>","PASS","<B>Current CDR is realy Transit CDR and match rate row found</B>",0,iReportFailRow)
   					End If
				End If
			End if

 			'---Regular 
				If GFreephoneCDRType = "" Then 'Not a Freephone/ISDN case
					Dim bCusRegError,bVenRegError
					bCusRegError = False
					bVenRegError = False
					'Check Regular Customer case
					If GCusCDRType = "" Then
						sFoundFile = ""
						Call fReport("fBusCdrInputFile","<B>Check if currect CDR row is Regular Customer</B>","HEADER","",0,iReportFailRow)
						rcCus = fBusCusRegular(sCustomerID,bCusRegError,iCustProductID,sFoundFile)'iRouteID
						If rcCus = False and bCusRegError = True Then
								GCusCDRType = "ERROR"
							ElseIf rcCus = False and bCusRegError = False Then
								Call fReport("fBusCdrInputFile","Check if currect CDR row is Regular Customer","FAIL","<B>Current CDR is not Freephone/ISDN/Regular Customer</B>",0,iReportFailRow)
								iCountAllErrorRates = iCountAllErrorRates + 1
								bCusRegError = "ERROR" 'The current Customer CDR is ERROR -> not Freephone/ISDN/Regular
							ElseIf rcCus = True and bCusRegError = False Then
								Call fReport("fBusCdrInputFile","<B>Check if currect CDR row is Regular Customer</B>","PASS","<B>Current CDR is realy Regular Customer</B>",0,iReportFailRow)
						End If
					End If
					'Check Regular Vendor case
					If GVendCDRType = "" Then
						Call fReport("fBusCdrInputFile","<B>Check if currect CDR row is Regular Vendor</B>","HEADER","",0,iReportFailRow)
						rcVen = fBusVenRegular(sVendorID,bVenRegError,iVendProductID,sCustomerID,iCustProductID)'iRouteID
						If rcVen = False and bVenRegError = True Then
							GVendCDRType = "ERROR"
							ElseIf rcVen = False and bVenRegError = False Then
									Call fReport("fBusCdrInputFile","Check if current CDR row is Regular Vendor","FAIL","<B>Current CDR is not Freephone/ISDN/Regular Vendor</B>",0,iReportFailRow)
									iCountAllErrorRates = iCountAllErrorRates + 1
									GVendCDRType = "ERROR" 'The current Vendor CDR is ERROR -> not Freephone/ISDN/Regular
							ElseIf rcVen = True and bVenRegError = False Then
									Call fReport("fBusCdrInputFile","<B>Check if current CDR row is Regular Vendor</B>","PASS","<B>Current CDR is realy Regular Vendor</B>",0,iReportFailRow)
						End If
					End If
   				End If

		'-----------------------------------------------------> Output

   			'Check output fields file for all cases
			rsOutput.MoveFirst
			For i = 1 To iRow
				rsOutput.MoveNext  'Get to the next output CDR rate row
			Next

			'Checks Freephone output fields
			If GFreephoneCDRType = "Freephone"  Then
				Call fReport("fBusCdrInputFile","<B>Check row number " & iRow & " in CDR Output file '" & GlobalDictionary("FILE_NAME")&".rated.txt' for Freephone customer case" & "</B>","TITLE2","",0,iReportFailRow)
				If fGuiOutputValidation(GFreephoneCDRType,sCustomerID,"CUST",ObjRS,"","","303","") <> True Then
					Call fReport("fBusCdrInputFile","<B>Check Freephone Output file fields values</B>","FAIL","<B>Freephone Output file <B>customer </B>field values are not Correct</B>",0,iReportFailRow)
				Else
					Call fReport("fBusCdrInputFile","<B>Check Freephone Output file fields values</B>","PASS","<B>Freephone Output file <B>customer </B>field values are Correct</B>",0,iReportFailRow)
				End If
				Call fReport("fBusCdrInputFile","<B>Check row number " & iRow & " in CDR Output file '" & GlobalDictionary("FILE_NAME")&".rated.txt' for Freephone vendor case" & "</B>","TITLE2","",0,iReportFailRow)
				If fGuiOutputValidation(GFreephoneCDRType,sVendorID,"VEND",ObjRS,"","","303","") <> True Then
					Call fReport("fBusCdrInputFile","<B>Check Freephone Output file fields values</B>","FAIL","<B>Freephone Output file <B>vendor </B>field values are not Correct</B>",0,iReportFailRow)
				Else
					Call fReport("fBusCdrInputFile","<B>Check Freephone Output file fields values</B>","PASS","<B>Freephone Output file <B>vendor </B>field values are Correct</B>",0,iReportFailRow)
				End If	
			End If

			'Check ISDN/Transit/Regular output fields
			'Customer Output
			Select Case GCusCDRType

				Case "ISDN"
					Call fReport("fBusCdrInputFile","<B>Check row number " & iRow & " in CDR Output file '" & GlobalDictionary("FILE_NAME")&".rated.txt' for ISDN customer case" & "</B>","TITLE2","",0,iReportFailRow)
					IF fGuiOutputValidation(GCusCDRType,sCustomerID,"CUST",rsISDNCus,"","","302","") <> True Then
						Call fReport("fBusCdrInputFile","<B>Check ISDN Output file fields values</B>","FAIL","<B>ISDN Output file <B>customer </B>field values are not Correct</B>",0,iReportFailRow)
					Else
						Call fReport("fBusCdrInputFile","<B>Check ISDN Output file fields values</B>","PASS","<B>ISDN Output file <B>customer </B>field values are Correct</B>",0,iReportFailRow)
					End If

				Case "Transit"
					Call fReport("fBusCdrInputFile","<B>Check row number " & iRow & " in CDR Output file '" & GlobalDictionary("FILE_NAME")&".rated.txt' for Transit customer case" & "</B>","TITLE2","",0,iReportFailRow)
					If fGuiOutputValidation(GCusCDRType,sCustomerID,"CUST",rsTransitRate,"","","301",sFoundFile) <> True Then
						Call fReport("fBusCdrInputFile","<B>Check Transit Output file fields values</B>","FAIL","<B>Transit Output file <B>customer </B>field values are not Correct</B>",0,iReportFailRow)
					Else
						Call fReport("fBusCdrInputFile","<B>Check Transit Output file fields values</B>","PASS","<B>Transit Output file <B>customer </B>field values are Correct</B>",0,iReportFailRow)
					End If


				Case "Regular"
					Call fReport("fBusCdrInputFile","<B>Check row number " & iRow & " in CDR Output file '" & Left(GlobalDictionary("FILE_NAME"),Len(GlobalDictionary("FILE_NAME"))-4)& ".rated.txt'<BR> for Regular customer case" & "</B>","TITLE2","",0,iReportFailRow)
					IF fGuiOutputValidation(GCusCDRType,sCustomerID,"CUST",CusFinalObjRs,"","",iCustProductID,sFoundFile) <> True Then 
						Call fReport("fBusCdrInputFile","<B>Check Regular Output file fields values</B>","FAIL","<B>Regular Output file <B>customer</B> field values are not Correct</B>",0,iReportFailRow)
					Else
						Call fReport("fBusCdrInputFile","<B>Check Regular Output file fields values</B>","PASS","<B>Regular Output file <B>customer</B> field values are Correct</B>",0,iReportFailRow)
					End If

				Case "AGRRegular"
					Call fReport("fBusCdrInputFile","<B>Check row number " & iRow & " in CDR Output file '" & Left(GlobalDictionary("FILE_NAME"),Len(GlobalDictionary("FILE_NAME"))-4)& ".rated.txt'<BR> for AGR Regular customer case" & "</B>","TITLE2","",0,iReportFailRow)
					IF fGuiOutputValidation(GCusCDRType,sCustomerID,"CUST",CusFinalObjRs,CusAGRObjRs,rsCusAgrVol,iCustProductID,"") <> True Then 
						Call fReport("fBusCdrInputFile","<B>Check AGR Regular Output file fields values</B>","FAIL","<B>AGR Regular Output file <B>customer</B> field values are not Correct</B>",0,iReportFailRow)
					Else
						Call fReport("fBusCdrInputFile","<B>Check AGR Regular Output file fields values</B>","PASS","<B>AGR Regular Output file <B>customer</B> field values are Correct</B>",0,iReportFailRow)
					End If

			End Select

			'Vendor Output
			Select Case GVendCDRType
			
				Case "ISDN"
					Call fReport("fBusCdrInputFile","<B>Check row number " & iRow & " in CDR Output file '" & Left(GlobalDictionary("FILE_NAME"),Len(GlobalDictionary("FILE_NAME"))-4)& ".rated.txt'<BR> for ISDN vendor case" & "</B>","TITLE2","",0,iReportFailRow)
					IF fGuiOutputValidation(GVendCDRType,sVendorID,"VEND",rsISDNVend,"","","302","") <> True Then
						Call fReport("fBusCdrInputFile","<B>Check ISDN Output file fields values</B>","FAIL","<B>ISDN Output file <B>vendor </B>field values are not Correct</B>",0,iReportFailRow)
					Else
						Call fReport("fBusCdrInputFile","<B>Check ISDN Output file fields values</B>","PASS","<B>ISDN Output file <B>vendor </B>field values are Correct</B>",0,iReportFailRow)
					End If

				Case "Transit"
					Call fReport("fBusCdrInputFile","<B>Check row number " & iRow & " in CDR Output file '" & Left(GlobalDictionary("FILE_NAME"),Len(GlobalDictionary("FILE_NAME"))-4)& ".rated.txt'<BR> for Regular vendor case" & "</B>","TITLE2","",0,iReportFailRow)
					If fGuiOutputValidation(GVendCDRType,sVendorID,"VEND",rsTransitRate,"","","301","") <> True Then
						Call fReport("fBusCdrInputFile","<B>Check Transit Output file fields values</B>","FAIL","<B>Transit Output file <B>vendor</B> field values are not Correct",0,iReportFailRow)
					Else
						Call fReport("fBusCdrInputFile","<B>Check Transit Output file fields values</B>","PASS","<B>Transit Output file <B>vendor</B> field values are Correct",0,iReportFailRow)
					End If

				Case "Regular"
					Call fReport("fBusCdrInputFile","<B>Check row number " & iRow & " in CDR Output file '" & Left(GlobalDictionary("FILE_NAME"),Len(GlobalDictionary("FILE_NAME"))-4)& ".rated.txt'<BR> for Regular vendor case" & "</B>","TITLE2","",0,iReportFailRow)
					If fGuiOutputValidation(GVendCDRType,sVendorID,"VEND",rsRegularVend,"","",iVendProductID,"") <> True Then
						Call fReport("fBusCdrInputFile","<B>Check Regular Output file fields values</B>","FAIL","<B>Regular Output file <B>vendor</B> field values are not Correct",0,iReportFailRow)
					Else
						Call fReport("fBusCdrInputFile","<B>Check Regular Output file fields values</B>","PASS","<B>Regular Output file <B>vendor</B> field values are Correct",0,iReportFailRow)
					End If

				Case "AGRRegular"
					Call fReport("fBusCdrInputFile","<B>Check row number " & iRow & " in CDR Output file '" & Left(GlobalDictionary("FILE_NAME"),Len(GlobalDictionary("FILE_NAME"))-4)& ".rated.txt'<BR> for AGR Regular vendor case" & "</B>","TITLE2","",0,iReportFailRow)
					If fGuiOutputValidation(GVendCDRType,sVendorID,"VEND",rsRegularVend,VendAGRObjRs,VendAGRObjRs,iVendProductID,"") <> True Then
						Call fReport("fBusCdrInputFile","<B>Check AGR Regular Output file fields values</B>","FAIL","<B>AGR Regular Output file <B>vendor</B> field values are not Correct</B>",0,iReportFailRow)
					Else
						Call fReport("fBusCdrInputFile","<B>Check AGR Regular Output file fields values</B>","PASS","<B>AGR Regular Output file <B>vendor</B> field values are Correct</B>",0,iReportFailRow)
					End If

			End Select

			'Intercompany validation
			If GFreephoneCDRType <> "" OR GCusCDRType <> "" OR GVendCDRType <> "" Then
				If fGuiOutputIntercompValidation() <> True Then
					Call fReport("fBusCdrInputFile","<B>Check Intercompany Output file fields values</B>","FAIL","<B>Intercompany Output file fields values are not Correct</B>",0,iReportFailRow)
				Else
					Call fReport("fBusCdrInputFile","<B>Check Intercompany Output file fields values</B>","PASS","<B>Intercompany Output file fields values are Correct</B>",0,iReportFailRow)
				End If 
			End If

			objFileRead.SkipLine  'Continue to next row CDR
			GFreephoneCDRType = ""
			GCusCDRType = ""
			GVendCDRType = ""
   			iRow = iRow + 1
   		End If
    Wend

	'Close CMD window
	Dim iHwnd
	iHwnd = Window("~").GetROProperty("hwnd")
	Window("hwnd:=" & iHwnd).Activate
	Window("hwnd:=" & iHwnd).Close
	Dialog("mintty").WinButton("OK").Click
	Window("hwnd:=" & iHwnd).Close 

	sURL = "file:///T:/Matrix-QA/QTP-Aoutomation/QTP-RTR/QTP/RTR/Version1/Results/" & HtmlSummaryReport & "_" & sDate & ".html"
	Call fReport("","<a href=" & sURL & ">" & "Summary report of error records" & "</a>","INFO","",0,iReportFailRow)
   	Call fBusSummaryReport(sURLEmailReport)

	Call fFuncSendMailReport(sDate,sURLEmailReport)

End Function
'----------------------------------------------------------------------
'----------------------------------------------------------------------
' Function name: fBusFreephoneType
' Description: extract customer and vendor and call bIsFreephone function
' Parameters: ObjRS, bIsFreephone, bErrorRate
' Return value: 
' Example:
'----------------------------------------------------------------------
Public function fBusFreephoneType(ByRef ObjRS,ByRef bIsFreephone,ByRef bErrorRate,ByVal sCustomerID, ByVal sVendorID )

	For iFreephoneTypeIndex = 1 to 4
		If fBusFreephone(ObjRS,sCustomerID, sVendorID, bIsFreephoneType, bErrorRate) = True Then
			bIsFreephone = True
			fBusFreephoneType = True
			Exit Function
		ElseIf bErrorRate = True Then
			fBusFreephoneType = True
			Exit Function
		End If 
	Next

	bIsFreephone = False
	fBusFreephoneType = False

End Function
'----------------------------------------------------------------------
'----------------------------------------------------------------------
' Function name: fBusFreephone
' Description: check CDR type, codeID, Italy case and find best match row.
' Parameters: ObjRS, sCustomerID, sVendorID, bIsFreephoneType, bErrorRate
' Return value: ObjRS - best match row, bIsFreephoneType, bErrorRate - if it has an error.
' Example:
'----------------------------------------------------------------------
Public function fBusFreephone(ByRef ObjRS, ByVal sCustomerID, ByVal sVendorID, ByRef bIsFreephoneType,ByRef bErrorRate)

	Dim sCdrType,sCdrCodeID

    sCdrType = fGuiFindCdrType(sCustomerID)
	Call fReport ("fBusFreephone","Get <B>CDR Type</B> to search in freephone rate file","PASS","CDR Type: " & sCdrType,0,iReportFailRow)
	sCdrCodeID = fGuiGetCdrCodeID(sCdrType)
	Call fReport ("fBusFreephone","Get <B>CDR Code ID</B> to search in freephone rate file","PASS","CDR Code ID: " & sCdrCodeID,0,iReportFailRow)

	'Check if CDR type is italy customer/vendor case
	rc = fGuiItalyCusVend(ObjRs,sCustomerID,sVendorID,sCdrType,sCdrCodeID,bErrorRate)
	If rc = True Then
		Call fReport("fBusFreephone","Check for Italy case","INFO","The current row <B>is realy Italy case</B>",0,iReportFailRow)
	ElseIf rc = False and bErrorRate = True Then 'CDR is Italy case, but no match row found -> Rate Error
		Call fReport("fBusFreephone","Check for Italy case","FAIL","No match rate row found for Italy case -> Rate Error",0,iReportFailRow)
		Call fUpdateArrErrorRows("Error CDR - no match rates row found for Italy case",iReportFailRow)
		fBusFreephone = False
		Exit Function

	Else 'CDR is not Italy case
		Call fReport("fBusFreephone","Check for Italy case","INFO","The current row is <B>not Italy case</B>",0,iReportFailRow)
		If fGuiReturnFilteredFreephoneRates(sCustomerID, sVendorID, sCdrType, sCdrCodeID, ObjRS, GlobalDictionary("FILE_NAME"),false,sFilterString) <> True Then
			Call fUpdateArrErrorRows("No match rates row found in freephone rates file",iReportFailRow)
			fBusFreephone = False
			bIsFreephoneType = False
			Exit Function
		End If 
		If fGuiReturnBestMatchPerfixNumber(ObjRS,sCdrType,sCustomerID,sFilterString) <> True Then
			Call fUpdateArrErrorRows("No match rates row found according to Customer_ID & Prefix search in freephone rates",iReportFailRow)
			fBusFreephone = False
			bIsFreephoneType = False
			Exit Function
		End If
	End If 

	fBusFreephone = True

End Function
'----------------------------------------------------------------------
'----------------------------------------------------------------------
' Function name: fBusCusISDN
' Description: find best match rows for customer.
' Parameters: objRSCust,sCustomerID,bCusISDNError
' Return value: objRSCust-match customer row, bCusISDNError - True if didn't find Customer
' Example:
'----------------------------------------------------------------------
Public function fBusCusISDN(ByVal objRSCust,ByVal sCustomerID,ByVal bCusISDNError)

	Dim sCutPrefix,sPrefix,sFileDate

	Call fGuiGetFieldValue(sCopyFilesPath,"TempFile.txt","INBOUND DNIS",sPrefix) 'Get prefix number	
	sCutPrefix = Left(sPrefix,1)   'Take only 1 digit from the prefix - minimum digit to look for

	sFileDate = Left(GlobalDictionary("FILE_NAME"),8)

	'Collect Customer ISDN big file
	sCommandCus = sCustomerID & "," & sCutPrefix 
	If fGuiFilterISDNMatchRows("Cus",sCommandCus,"-customer-data.txt",rsISDNCus) <> True Then
		Call fReport("fBusCusISDN","Collect ISDN customer file ","FAIL"," collecting fail ",0,iReportFailRow)	
		fGuiCollectISDNFiles = False
		Exit Function
	End If

	'Find best match row to ISDN customer
	If GCusCDRType = "ISDN" Then  
		If fGuiFindISDNMatchCustVendRow(rsISDNCus,"Customer", sCustomerID, sPrefix) <> True Then
			Call fReport ("fBusCusISDN","Get best match Customer rate row from customer - data file","INFO","Didn't find a best match row - continue to Regular test",0,iReportFailRow)
			fBusCusISDN = False
			Exit Function
   		End If
	Else
		fBusCusISDN = False
		Exit function
	End If

	fBusCusISDN = True

End function 
'----------------------------------------------------------------------
'----------------------------------------------------------------------
' Function name: fBusVenISDN
' Description: find best match rows for customer.
' Parameters: objRSVend,sVendorID,bVenISDNError
' Return value: objRSVend-match vendor row, bVenISDNError - True if didn't find Vendor
' Example:
'----------------------------------------------------------------------
Public function fBusVenISDN(ByVal objRSVend,ByVal sVendorID,ByVal bVenISDNError)

	Dim sCutPrefix,sFileDate,sCommandVen

	Call fGuiGetFieldValue(sCopyFilesPath,"TempFile.txt","INBOUND DNIS",sPrefix) 'Get prefix number	
	sCutPrefix = Left(sPrefix,1)   ' Take only 1 digit from the prefix - minimum digit to look for

	sFileDate = Left(GlobalDictionary("FILE_NAME"),8)

	'Collect Vendor ISDN big file
   	sCommandVen = sVendorID & "," & sCutPrefix 
	If fGuiFilterISDNMatchRows("Vend",sCommandVen,"-vendor-data.txt",rsISDNVend) <> True Then
		Call fReport("fBusVenISDN","Collect ISDN vendor file ","FAIL"," collecting fail ",0,iReportFailRow)
		fGuiCollectISDNFiles = False
		Exit Function
	End If

	'Find best match row to ISDN vendor
	If GVendCDRType = "ISDN" Then  
		If fGuiFindISDNMatchCustVendRow(rsISDNVend, "Vendor", sVendorID, sPrefix) <> True Then
			Call fReport ("fBusVenISDN","Get best match Vendor rate row from vendor - data file","INFO","Didn't find a best match row - continue to Regular test",0,iReportFailRow)
			fBusVenISDN = False
			Exit Function
		End If
	Else
		fBusCusISDN = False
		Exit Function
	End If

	fBusVenISDN = True

End Function
'----------------------------------------------------------------------
'----------------------------------------------------------------------
' Function name: fBusTransitType
' Description: extract Transit row for customer and vendor
' Parameters: 
' Return value: 
' Example:
'----------------------------------------------------------------------
Public function fBusTransitType(ByVal sCustomerID,ByVal sVendorID, ByRef rsTransitRate, ByRef bErrorRate, ByRef sFoundFile)

	Dim sPrefix,sCutPrefix
	
	'Extract the Dialed number
	Call fGuiGetFieldValue(sCopyFilesPath, sTempFileName, "Inbound DNIS", sPrefix)
	sCutPrefix = Left(sPrefix,1)   ' Take only 1 digit from the prefix - minimum digit to look for

	sFileDate = Left(GlobalDictionary("FILE_NAME"),8) 'Files date

	'Collect Transit big file
   	sCommandTransit = sCustomerID & "," & sVendorID & "," & sCutPrefix 
	'After this function we get a file with all optional rows (cus\vend + cut prefix)
	Call fGuiDoGrepCommandInCMD(sCommandTransit, "-transit.txt") 
	wait 1

	'Set TransitObjRs with the found match rows
	If fTextFileToObjRS(sBigFilesPath & sFileDate ,"Filter-transit.txt", sTransitHeaders, sTransitColumnsTypes ,rsTransitRate,True) <> True Then
		Call fReport("fBusTransitType","Set Transit objRs","FAIL","Set Transit objRs failed",0,iReportFailRow)
		bErrorRate = True
		fBusTransitType = False
		Exit Function
	End If   

	If fGuiFindBestMatchTransitRow(rsTransitRate,sCustomerID,sVendorID,sPrefix) = True Then 'Found match row
		Call fReport("fBusTransitType","Find match rows","PASS","Find match rows for customer and vendor",0,iReportFailRow)
		GCusCDRType = "Transit"
		GVendCDRType = "Transit"
        sFoundFile = "Transit"
	Else
	'Looking for customer rate row in master file
		If fGuiFindTransBestMatchMastRow(sCustomerID,sPrefix,rsTransitRate) <> True Then
			Call fReport("fBusTransitType","Didn't find match row","FAIL","Didn't find match rows for customer on master file",0,iReportFailRow)
			GCusCDRType = "ERROR" 'Not Transit, RERROR case
			fBusTransitType = False
		Else 
			Call fReport("fBusTransitType","Find match row","PASS","Find match rows for customer on master file",0,iReportFailRow)
			GCusCDRType = "Transit"
            sFoundFile = "TransitMaster"
			fBusTransitType = True
		End If
	'Return RERROR for Vendor
		GVendCDRType = "ERROR"
	End If

End Function
'----------------------------------------------------------------------
'----------------------------------------------------------------------
' Function name: fBusCusRegular
' Description: 
' Parameters: sFoundFile - parameter for the output validation
' Return value: sFoundFile - the file name that the matched row found
' Example:
'----------------------------------------------------------------------
Public function fBusCusRegular(ByVal sCustomerID,ByRef bCusRegError,ByRef iCustProductID,ByRef sFoundFile) ',ByRef iRouteID

	Dim sPrefix,IsCusFound,IsCusPrefFound,IsMastFound
	IsCusFound = False
	IsCusPrefFound = False
	IsMastFound = False 

	'Get prefix number
	Call fGuiGetFieldValue(sCopyFilesPath,"TempFile.txt","INBOUND DNIS",sPrefix) 

	'Collect Customer.txt file by 'Prefix'
	Call fReport("fBusCusRegular","<B>Filter Best Match Row By Prefix in Customer.txt file</B>","HEADER","",0,iReportFailRow)
	If fGuiGetMatchRowsInCusMasVen(rsCustomer,sCustomerID,sPrefix,"customer",sFilterCusCommand,GCusCDRType,IsCusFound) <> True Then
		Call fReport("fBusCusRegular","Get Best Match Row By <B>Prefix</B> in Customer.txt file","INFO","Didn't find matched rows ",0,iReportFailRow)
	Else 
		Call fReport("fBusCusRegular","Get Best Match Row By <B>Prefix</B> in Customer.txt file","INFO","Found matched rows",0,iReportFailRow)
	End If

	'Collect Customer_Pref_Route.txt by PR_ID
	Call fReport("fBusCusRegular","<B>Filter Best Match Row By PR_ID in Customer_PrefRoute.txt file</B>","HEADER","",0,iReportFailRow)
	If fGuiGetBestRowByPrefRouteID(rsRegularPrefRouteCus,sCustomerID,sPrefix,sFilterCusPrefCommand,GCusCDRType,IsCusPrefFound) <> True Then
		Call fReport("fBusCusRegular","Get Best Match Row By <B>Preferred_Route_ID</B> in Customer_Pref_Route.txt file","INFO","Didn't find matched rows ",0,iReportFailRow)
   	Else 
		Call fReport("fBusCusRegular","Get Best Match Row By <B>Preferred_Route_ID</B> in Customer_Pref_Route.txt file","INFO","Found matched rows ",0,iReportFailRow)
	End If

	'Check if didn't find match rows - if 'True' - go to look for in Master.txt
	If IsCusFound = False and IsCusPrefFound = False Then 'Didn't find match rows at Customer/Customer_Pref_Route.txt
			'Collect Master.txt file by 'Prefix' -> Regular Customer end case
			Call fReport("fBusCusRegular","<B>Filter Best Match Row By Prefix in Master.txt file</B>","HEADER","",0,iReportFailRow)
			If fGuiGetMatchRowsInCusMasVen(rsMaster,sCustomerID,sPrefix,"master",sFilterMastCommand,GCusCDRType,IsMastFound) <> True Then
				bCusRegError = True 'Error rate -> Didn't find match rate row for Customer at all.
				Call fReport("fBusCusRegular","Regular <B>customer end case</B> - search matched rows in Master.txt file","FAIL","<B>Didn't find matched rows for Customer at all - CUSTOMER RATE ERROR</B>",0,iReportFailRow)
				Call fUpdateArrErrorRows("Didn't find match rate row for Customer at all",iReportFailRow)
				fBusCusRegular = False
				Exit Function
			Else
				Call fReport("fBusCusRegular","Regular <B>customer end case</B> - search matched rows in Master.txt file","INFO","Found matched rows",0,iReportFailRow)
			End If
   	End If

	'Check where are found the best matched rows and set them in Customer ObjRs
	Call fGuiSetFinalCustomerObjRs(CusFinalObjRs,sFilterCusCommand,sFilterCusPrefCommand,sFilterMastCommand,sFilterFinalCommand,bCusRegError,sFoundFile) ',iRouteID
	If bCusRegError = True Then
		Call fReport("fBusCusRegular","fGuiSetFinalCustomerObjRs","FAIL","<B>ERROR Rate</B> - found matched rows for Regular Customer in both files - Customer.txt & Customer_Prefroute.txt with same 'Prefix' length",0,iReportFailRow)
		fBusCusRegular = False ' ERROR rate -> In Case that found match rows in both files - Customer.txt & Customer_Prefroute.txt with same 'Prefix' length
   		Exit Function
	Else 
		Call fReport("fBusCusRegular","Set Customer Final ObjRs","PASS","<B>The matched rows found in " & sFoundFile & ".txt file</B>",0,iReportFailRow)
	End If
	
	CusFinalObjRs.Filter = sFilterFinalCommand 'Need to filter the new objRs (after set.clone command)

'	'Get Route_ID value by prefix in pre_route.txt file
	'iRouteID = fGuiGetRouteIDForRegCusCase()
'	iRouteID = fGuiGetRouteIDValue()

	If sFoundFile <> "Master" Then 'While the matched row is from Master.txt - need to skip on the next steps
		'Get Period_ID
		'Filter match rows by Period_ID for get Customer best match row
		If CusFinalObjRs.RecordCount > 1 Then
			Call fReport("fBusCusRegular","Check Period_ID value for Customer","INFO","",0,iReportFailRow)
			If fGuiCheckTOD(CusFinalObjRs,"customer",sFilterFinalCommand) <> True Then
				fBusCusRegular = False
			End If
		End If
	
	'Check agreement indicator for Customer
		If IsNull(CusFinalObjRs.Fields("Agreement_ID").Value) <> True OR CusFinalObjRs.Fields("Agreement_ID").Value <> 0 Then 'Agreement_ID has a value
			Call fReport("fBusCusRegular","<B>Agreement_ID <> NULL/0, go to check Customer AGR case</B>","HEADER","",0,iReportFailRow)
			'Get Sum_Vol from AGR_Vol file
			SumVol = fGuiGetAgrVolMatchRow(CusFinalObjRs,rsCusAgrVol,"Customer")
			'Check Tier indicator
			Call fReport("fBusCusRegular","<B>Check Tier volumn for Customer AGR case</B>","HEADER","",0,iReportFailRow)
			If fGuiGetTierMatchRow("customer",CusFinalObjRs,sCustomerID,SumVol,CusAGRObjRs,GCusCDRType) <> True Then ',iRouteID
				fBusCusRegular = False
			End If
		Else
			Call fReport("fBusCusRegular","<B>Agreement_ID = NULL/0 -> the specific case isn't AGR case","HEADER","",0,iReportFailRow)
		End If
   	End If

	'Get Product_ID or Secondary+Product_ID for Cus/Vend
	Call fReport("fBusCusRegular","<B>Check Customer Product_ID</B>","HEADER","",0,iReportFailRow)
	iCustProductID = fGuiGetRegCustProductID(CusFinalObjRs,rsPreCustProduct,rsPrePrefrouteMixmatc,sCustomerID)

	fBusCusRegular = True

End Function
'----------------------------------------------------------------------
'----------------------------------------------------------------------
' Function name: fBusVenRegular
' Description: 
' Parameters: 
' Return value: 
' Example:
'----------------------------------------------------------------------
Public function fBusVenRegular(ByVal sVendorID,ByRef bVenRegError,ByRef iVendProductID,ByVal sCustomerID,ByVal iCustProductID) ',ByVal iRouteID

	Dim sPrefix,IsVendFound

	'Get prefix number
	Call fGuiGetFieldValue(sCopyFilesPath,"TempFile.txt","INBOUND DNIS",sPrefix) 

	'Collect Vendor.txt file by 'Prefix'
	Call fReport("fBusCusRegular","<B>Filter Best Match Row By Prefix in Vendor.txt file</B>","HEADER","",0,iReportFailRow)
	If fGuiGetMatchRowsInCusMasVen(rsRegularVend,sVendorID,sPrefix,"vendor",sFilterVendCommand,GVendCDRType,IsVendFound) <> True Then
		Call fReport("fBusVenRegular","fGuiGetMatchRowsInCusMasVen","FAIL","<B>Didn't find matched rows for Vendor at all - VENDOR RATE ERROR</B>",0,iReportFailRow)
		Call fUpdateArrErrorRows("Didn't find a match row for Vandor at all",iReportFailRow)
		bVenRegError = True
		fBusVenRegular = False
		Exit Function
   	Else 
		Call fReport("fBusVenRegular","Get Best Match Row By <B>Prefix</B> in Vendor.txt file","INFO","<B>Found</B> matched rows",0,iReportFailRow)
	End If

	'Get PeriodID
	'Filter match rows by Period_ID for get Vendor best match row
	If rsRegularVend.RecordCount > 1 Then
		Call fReport("fBusVenRegular","Check Period_ID value for Vendor","INFO","",0,iReportFailRow)
		If fGuiCheckTOD(rsRegularVend,"vendor",sFilterVendCommand) <> True Then
			fBusVenRegular = False
			Exit Function
		End If
	End If
  
	'Check agreement indicator for Vendor
	If IsNull(rsRegularVend.Fields("Agreement_ID").Value) <> True OR rsRegularVend.Fields("Agreement_ID").Value <> 0 Then 'Agreement_ID has a value
		Call fReport("fBusVenRegular","<B>Agreement_ID <> NULL/0 -> go to check Vendor AGR case</B>","HEADER","",0,iReportFailRow)
		'Get Sum_Vol from AGR_Vol file
		SumVol = fGuiGetAgrVolMatchRow(rsRegularVend,rsVenAgrVol,"Vendor")
		Call fReport("fBusVenRegular","<B>Check Tier volumn for Vendor AGR case</B>","HEADER","",0,iReportFailRow)
		'Check Tier indicator
		If fGuiGetTierMatchRow("vendor",rsRegularVend,sVendorID,SumVol,VendAGRObjRs,GVendCDRType) <> True Then ',iRouteID
			Call fReport("fBusVenRegular","Get best match TierVolume row for Customer","FAIL","<B>Didn't find </B> a match TierVolume row",0,iReportFailRow)
			fBusVenRegular = False
		End If
	End If

	'Get Vendor Product_ID 
	Call fReport("fBusVenRegular","<B>Check Vendor Product_ID</B>","HEADER","",0,iReportFailRow)
	iVendProductID = fGuiGetRegVendProductID(CusFinalObjRs,rsPreCustProduct,rsPrePrefrouteMixmatc,sCustomerID,iCustProductID)

	fBusVenRegular = True
	
End Function
'----------------------------------------------------------------------
'----------------------------------------------------------------------
' Function name: FBusSummaryReport
' Description: The function write to the HTML report summary report of all error record and the error reason
' Parameters: 
' Return value: 
' Example:
'----------------------------------------------------------------------
Public Function fBusSummaryReport(ByRef sURL)

	sURL = "file:///T:/Matrix-QA/QTP-Aoutomation/QTP-RTR/QTP/RTR/Version1/Results/RTR_IP" & "_" & sDate & ".html"

	Call fCreateHtmlReport(HtmlSummaryReport)

  	Call fReport("<B>TOTAL CDRs :</B>","<B>" & iRow-1 & "</B>","INFO","",0,iReportFailRow)
   	Call fReport("<B>TOTAL <font color='00FF00'>PASSED</font> :</B>","<B>" &(iRow-1) - iErrorCDRs & "</B>","INFO","",0,iReportFailRow)
	Call fReport("<B>TOTAL <font color='FF0000'>FAILED</font> :</B>","<B>" & iErrorCDRs & "</B>","INFO","",0,iReportFailRow)
	Call fReport("","<B>" & "SUMMAERY REPORT OF ERROR RECORDS" & "</B>","TITLE","",0,iReportFailRow)
	
	If Ubound(arrErrorCDRs) = -1 Then
		Call fReport("","<B>All CDRs are correct!</B>","TITLE2","",0,iReportFailRow)
		Call fReport ("","<a href=" & sURL & ">Link to Details Summary Report </a>","PASS","",0,iReportFailRow)
	Else
		Call fReport("","<B>Failed CDRs detailes:</B>","TITLE2","",0,iReportFailRow) 
		Dim i 
		i = 0
   		While i <= uBound(arrErrorCDRs)
			Call fReport ("",arrErrorCDRs(i)& "<BR><a href=" & sURL & "#" & arrErrorRows(i) & ">Link to the specific failed field </a>","FAIL","",0,iReportFailRow)
			i = i + 1
		Wend
	End If

End function
'----------------------------------------------------------------------
