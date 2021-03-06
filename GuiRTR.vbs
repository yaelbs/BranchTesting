Option Explicit
Public rsPreOtg,rsPreFreephone,rsPreTtg
Public rsFreephoneRate,rsOutput,rsXchg,rsISDNCus,rsISDNVend,rsTransitRate
Public rsCustomer,rsMaster,rsRegularVend,rsCusAgrVol,rsVenAgrVol,rsCusTier,rsVenTier,CusAGRObjRs,VendAGRObjRs,rsInterComp
Public rsRegularPrefRouteCus,rsPreRoute,rsPreStatus,rsPreHcd,rsPrecustproduct,rsPrePrefrouteMixmatc,rsPreCrp,rsPreVrp,rsPreRoutePrefroute

Public GFreephoneCDRType,GCusCDRType,GVendCDRType,CusFinalObjRs,sGlobalPrefix

Public Const IntoDenmark = "Into Denmark"
Public Const IntoNL = "Into NL"
Public Const OutOfDenmark = "Out of Denmark"
Public Const OutOfNL = "Out of NL"

'----------------------------------------------------------------------
' Function name: fGuiCollectPreFiles
' Description: The function collect all pre_xxxxx.txt files to RS objects
' Parameters: sDate - running pre files process date
' Return value: Success - True, Failure - False
' Example:
'----------------------------------------------------------------------
Public Function fGuiCollectPreFiles(sDate)

   	'Get_Pre_freephone.txt
	If fTextFileToObjRS(sPreFilesPath,"pre_freephone.txt",sPreFreephoneHeaders,sPreFreephoneColumnsTypes,rsPreFreephone,False) <> True Then
		fGuiCollectPreFiles = False
		Exit Function
	End If 

	'Get_Pre_otg.txt
	If fTextFileToObjRS(sPreFilesPath,"pre_otg.txt",sPreOtgHeaders,sPreOtgColumnsTypes,rsPreOtg,False) <> True Then
		fGuiCollectPreFiles = False
		Exit Function
	End If 

	'Get_Pre_ttg.txt
	If fTextFileToObjRS(sPreFilesPath,"pre_ttg.txt",sPreTtgHeaders,sPreTtgColumnsTypes,rsPreTtg,False) <> True Then
		fGuiCollectPreFiles = False
		Exit Function
	End If 

	'Get_Pre_Custproduct.txt
	If fTextFileToObjRS(sPreFilesPath,"pre_custproduct.txt",sPreCustproductHeaders,sPreCustproductColumnsTypes,rsPrecustproduct,False) <> True Then 
		fGuiCollectPreFiles = False
		Exit Function
	End If 

	'Get_Pre_Prefroute_mixmatc.txt
	If fTextFileToObjRS(sPreFilesPath,"pre_prefroute_mixmatch.txt",sPrePrefrouteMixmatcHeaders,sPrePrefrouteMixmatcColumnsTypes,rsPrePrefrouteMixmatc,False) <> True Then 
		fGuiCollectPreFiles = False
		Exit Function
	End If 

	'Get_Pre_crp.txt 
	If fTextFileToObjRS(sPreFilesPath,"pre_crp.txt",sPreCrpHeaders,sPreCrpColumnsTypes,rsPreCrp,False) <> True Then 
		fGuiCollectPreFiles = False
		Exit Function
	End If 

	'Get_Pre_vrp.txt
    If fTextFileToObjRS(sPreFilesPath,"pre_vrp.txt",sPreVrpHeaders,sPreVrpColumnsTypes,rsPreVrp,False) <> True Then 
		fGuiCollectPreFiles = False
		Exit Function
	End If
	  
	'Get_pre_route_prefroute.txt
	If fTextFileToObjRS(sPreFilesPath,"pre_route_prefroute.txt",sPreRoutePrefouteHeaders,sPreRoutePrefouteColumnTypes,rsPreRoutePrefroute,False) <> True Then 
		fGuiCollectPreFiles = False
		Exit Function
	End If
	
	'Get_pre_route.txt
	If fTextFileToObjRS(sPreFilesPath,"pre_route.txt",sPreRouteHeaders,sPreRouteColumnTypes,rsPreRoute,False) <> True Then 
		fGuiCollectPreFiles = False
		Exit Function
	End If

	'Get_pre_inter_comp.txt
	If fTextFileToObjRS(sPreFilesPath,"pre_inter_comp.txt",sPreInterCompHeaders,sPreInterCompColumnTypes,rsInterComp,False) <> True Then 
		fGuiCollectPreFiles = False
		Exit Function
	End If

   	'Get_pre_status.txt
	If fTextFileToObjRS(sPreFilesPath,"pre_status.txt",sPreStatusHeader,sPreStatusColumnTypes,rsPreStatus,False) <> True Then 
		fGuiCollectPreFiles = False
		Exit Function
	End If

	'Get_pre_hcd.txt
	If fTextFileToObjRS(sPreFilesPath,"pre_hcd.txt",sPreHcdHeaders,sPreHcdColumnTypes,rsPreHcd,False) <> True Then 
		fGuiCollectPreFiles = False
		Exit Function
	End If
    		
	fGuiCollectPreFiles = True

End Function
'----------------------------------------------------------------------
'----------------------------------------------------------------------
' Function name: fGuiCollectRateFiles
' Description: The function collect all [Date]-xxxxx.txt files to RS objects
' Parameters:
' Return value: Success - True, Failure - False
' Example:
'----------------------------------------------------------------------
Public function fGuiCollectRateFiles(ByVal sFileName)
	
	'Get_rate_freephone.txt
	If fTextFileToObjRS(sRateFilesPath, Left(sFileName,8) & "-freephone.txt",sFreephoneRateHeaders,sFreephoneRateColumnsTypes,rsFreephoneRate,False) <> True Then
		fGuiCollectRateFiles = False
		Exit Function
	End If 

	 'Get_Output_file.txt 
	If fTextFileToObjRS(sInputOutputPath, sFileName & ".rated" ,sOutputCdrHeaders,sOutputCdrColumnsTypes,rsOutput,False) <> True Then '& "txt.rated"
		fGuiCollectRateFiles = False
		Exit Function
	End If 

	'Get_xchg_Rate.txt
	If fTextFileToObjRS(sRateFilesPath, Left(sFileName,8) &"-xchg-rates.txt",sXchgRateHeaders,sXchgRateCdrColumnsTypes,rsXchg,False) <> True Then
		fGuiCollectRateFiles = False
		Exit Function
	End If 

	'Get_customer_agr_vol.txt
	If fTextFileToObjRS(sRateFilesPath, Left(sFileName,8) &"-customer-agr-vol.txt",sCusVenAgrVolHeaders,sCusVenAgrVolColumnsTypes,rsCusAgrVol,False) <> True Then
		fGuiCollectRateFiles = False
		Exit Function
	End If 

	'Get_vendor_agr_vol.txt
	If fTextFileToObjRS(sRateFilesPath, Left(sFileName,8) & "-vendor-agr-vol.txt",sCusVenAgrVolHeaders,sCusVenAgrVolColumnsTypes,rsVenAgrVol,False) <> True Then
		fGuiCollectRateFiles = False
		Exit Function
	End If 

	fGuiCollectRateFiles = True
	
End Function
'----------------------------------------------------------------------
' Function name: fGuiCreateIniFile
' Description: The function create .ini file to filter files by dates
' Parameters:
' Return value: 
' Example:
'----------------------------------------------------------------------
Public function fGuiCreateIniFile()

	Dim objFileWrite

	Set objFSO = CreateObject("scripting.filesystemobject")
	
	Set objFileWrite = objFSO.OpenTextFile(sCopyFilesPath &  "Schema.ini", 2, True)
	objFileWrite.Write sFilterByDatesFilesNames & "[" & Left(GlobalDictionary("FILE_NAME"),8)& "xchgrates.txt]" & vbNewLine & "ColNameHeader=True" & vbNewLine & "MaxScanRows=1"
	objFileWrite.Close

End Function
'----------------------------------------------------------------------
'----------------------------------------------------------------------
' Function name: fGuiCollectBigFiles
' Description: The function collect all big files that required 'grep' command to filter them
' Parameters:
' Return value: Success - True, Failure - False
' Example:
'----------------------------------------------------------------------
Public function fGuiCollectBigFiles(ByVal sBigFilesPath,ByVal sFileDate)

	Dim arrBigFilesNames

	arrBigFilesNames = array("-customer.txt","-vendor.txt","-customer-data.txt","-vendor-data.txt","-customer-prefroute.txt","-customer-tier.txt","-vendor-tier.txt","-master.txt","-master-data.txt","-xchg-rates.txt","-transit.txt")

	For i = 0 To Ubound (arrBigFilesNames)
		Call fCopyFileToLocalMachine(sBigFilesPath, sFileDate & arrBigFilesNames(i))
	Next

	fGuiCollectBigFiles = True

End Function

'----------------------------------------------------------------------
'----------------------------------------------------------------------
' Function name: fGuiCdrInputFile
' Description: The function copies CDR input file and insert columns headers
'				The function copy each iIndex CDR row to a temp file (in loop)
' Parameters: 	sFileName - CDR full file name
'				iIndex - Index of CDR row to copy to a temp file
' Return value: Success - True, Failure - False
' Example:
'----------------------------------------------------------------------
Public Function fGuiCdrInputFile (ByVal sFileName, ByRef iIndex)

	Dim objFSO, sSaveFileData, objFileRead, objFileWrite

	Set objFSO = CreateObject("scripting.filesystemobject")
    
	Set objFileRead = objFSO.OpenTextFile(sCopyFilesPath & sFileName, 1)
	For i = 1 To iIndex
		sSaveFileData = objFileRead.ReadLine
	Next
    	  
    sSaveFileData = sInputCdrHeaders & vbNewLine & sInputCdrColumnsTypes & vbNewLine & sSaveFileData
	
	Set objFileWrite = objFSO.OpenTextFile(sCopyFilesPath & sTempFileName, 2,True)
	objFileWrite.Write sSaveFileData
	objFileWrite.Close
 
    objFileRead.Close
	
End Function
'----------------------------------------------------------------------
'----------------------------------------------------------------------
' Function name: fGuiCheckFreephone
' Description: the function check if CDR is Freephone
' Parameters:
' Return value: If Freephone - True, Else - False
' Example:
'----------------------------------------------------------------------
Public function fGuiCheckFreephone()

	'Get 'Routing-table key' value to check if CDR is Freephone 
   Call fGuiGetFieldValue(sCopyFilesPath,"TempFile.txt","Routing-table key",iFieldValue)
   If iFieldValue = 663 or iFieldValue = 723 or iFieldValue = 923 Then 
		fGuiCheckFreephone = True
	Else
		fGuiCheckFreephone = False
   End If
End Function
'----------------------------------------------------------------------
'----------------------------------------------------------------------
' Function name: fGuiFindCdrType
' Description: check FreePhone CDR type
' Parameters: sCustomerID
' Return value: 
' Example:
'----------------------------------------------------------------------
 Public function fGuiFindCdrType(ByVal sCustomerID) 

	Call fGuiGetFieldValue(sCopyFilesPath, sTempFileName, "Inbound DNIS", sInboundDNIS)
	
	'--Check if into NL
	If iFreephoneTypeIndex = 1 Then
		'Call fGuiGetFieldValue( sCopyFilesPath, sTempFileName, "Outbound DNIS", sOutboundDNIS)
		If Left(sInboundDNIS,4) = 3100 Then
			fGuiFindCdrType = IntoNL 
			Call fReport("fGuiFindCdrType","Check Freephone CDR type","INFO","Current CDR row is <B>Into NL</B> case",0,iReportFailRow)
			Exit Function
		Else
			iFreephoneTypeIndex = 2
		End If
	 Else
		iFreephoneTypeIndex = 2
	End If

'	If iFreephoneTypeIndex = 1 Then
'		 Call fGuiGetFieldValue( sCopyFilesPath, sTempFileName, "Outbound DNIS", sOutboundDNIS)
'		 iPos = InStr(1,sOutboundDNIS,"A")
'			 If iPos > 0 Then
'				If InStr(iPos,sOutboundDNIS,"1431") > 0 Then
'					fGuiFindCdrType = IntoNL 
'					Call fReport("fGuiFindCdrType","Check Freephone CDR type","INFO","Current CDR row is <B>Into NL</B> case",0,iReportFailRow)
'					Exit Function
'				Else
'					iFreephoneTypeIndex = 2
'				End If
'			 Else
'				iFreephoneTypeIndex = 2
'			 End If
'	End If
		
	'--Check if Into Denmark
	If iFreephoneTypeIndex = 2 Then
		If Left(sInboundDNIS,5) = "45801" Then
			fGuiFindCdrType = IntoDenmark 
			Call fReport("fGuiFindCdrType","Check Freephone CDR type","INFO","Current CDR row is <B>Into Denmark </B>case",0,iReportFailRow)
			Exit Function
		Else
			iFreephoneTypeIndex = 3
		End If
	End If

	'--Check if Out of Denmark 
	If iFreephoneTypeIndex = 3 Then
		If Left(sInboundDNIS,2)="04" Then
			rsPreFreephone.Filter = "CDR_CODE = '" & Left(sInboundDNIS,5) & "'"
			If rsPreFreephone.RecordCount > 0 Then
					fGuiFindCdrType = OutOfDenmark 
					rsPreFreephone.Filter = 0
					Call fReport("fGuiFindCdrType","Check Freephone CDR type","INFO","Current CDR row is <B>Out of Denmark</B> case",0,iReportFailRow)
					Exit Function
				Else
					rsPreFreephone.Filter = 0
					iFreephoneTypeIndex = 4
				End If
			Else
					iFreephoneTypeIndex = 4
			End If
	End If

	'--Check if Out of NL
	If iFreephoneTypeIndex = 4 Then
			fGuiFindCdrType = OutOfNL  
			Call fReport("fGuiFindCdrType","Check Freephone CDR type","INFO","Current CDR row is <B>Out of NL </B>case",0,iReportFailRow)
			Exit Function
	End If
	
	fGuiFindCdrType = False 

 End Function
'----------------------------------------------------------------------
'----------------------------------------------------------------------
' Function name: fGuiGetCustomerID
' Description: The Function Get Castomer_Id according InboundDNIS from rsPreOtg
' Parameters:
' Return value: sCustID - Customer Id
' Example:
'----------------------------------------------------------------------
Public Function fGuiGetCustomerID(ByRef sInboundTrunk)

	Dim sCustID
	rsPreOtg.filter = 0 'For restart in case it is not the first filter 

    Call fGuiGetFieldValue(sCopyFilesPath, sTempFileName, "Inbound Trunk", sInboundTrunk)
    rsPreOtg.filter = "TRUNK_GROUP_NUMBER = '" & sInboundTrunk & "'"  

	If rsPreOtg.RecordCount <> 1 Then
		 sCustID = -9
	Else
		rsPreOtg.MoveFirst
        sCustID = rsPreOtg.Fields("CUSTOMER_ID").Value
	End If

	fGuiGetCustomerID = sCustID
End Function

'----------------------------------------------------------------------
'----------------------------------------------------------------------
' Function name: fGuiGetVendorID
' Description: The Function Get Vendor_Id according sOutgoingTrunk from rsPreOtg
' Parameters:
' Return value: sCustID - Vendor_Id
' Example:
'----------------------------------------------------------------------
Public function fGuiGetVendorID(ByRef sOutgoingTrunk)

	Dim sVendID
	rsPreTtg.filter = 0 'For restart in case it is not the first filter

    Call fGuiGetFieldValue(sCopyFilesPath, sTempFileName, "Outgoing Trunk", sOutgoingTrunk)
	rsPreTtg.filter = "TRUNK_GROUP_NUMBER = '" & sOutgoingTrunk & "'"

	If rsPreTtg.RecordCount <> 1 Then
		 sVendID = -9
	Else
		sVendID = rsPreTtg.Fields("VENDOR_ID").Value
	End If

	fGuiGetVendorID = sVendID
End Function
'----------------------------------------------------------------------
'----------------------------------------------------------------------
' Function name: fGuiGetCdrCodeID
' Description: The Function Return the SDRCodeId according CDR type
' Parameters: sCdrType - Frephone type
' Return value: sCodeID - Code_ID
' Example:
'----------------------------------------------------------------------
public function fGuiGetCdrCodeID(sCdrType)

	Dim sCodeID

	Select Case sCdrType

		Case IntoDenmark, OutOfNL
			sCodeID = 0

		Case IntoNL
			Call fGuiGetFieldValue(sCopyFilesPath, sTempFileName, "Outbound DNIS", sOutboundDNIS)
			iPos = inStr(1,sOutboundDNIS,"1431")
			PQRCode = mid(sOutboundDNIS,iPos+4,3)
			rsPreFreephone.filter = "CDR_CODE= '" & PQRCode & "'"
			sCodeID = rsPreFreephone.Fields("CDR_CODE_ID").Value
			rsPreFreephone.filter = 0

		Case OutOfDenmark
            Call fGuiGetFieldValue(sCopyFilesPath, sTempFileName, "Inbound DNIS", sInboundDNIS)
			rsPreFreephone.filter = "CDR_CODE= '" & Left(sInboundDNIS,5) & "'"
			sCodeID = rsPreFreephone.Fields("CDR_CODE_ID").Value
			rsPreFreephone.filter = 0

	End Select

	fGuiGetCdrCodeID = sCodeID
End function
'----------------------------------------------------------------------
'----------------------------------------------------------------------
' Function name: fGuiReturnBestMatchPerfixNumber
' Description: the function return the best match row from the filtered freephone rate file
' Parameters: ObjRS - contain the results from filter, CdrType
' Return value: ObjRS - best match perfix number in filtered Freephone Rate File 
' Example:
'----------------------------------------------------------------------
Public function fGuiReturnBestMatchPerfixNumber(ByRef ObjRS, ByVal CdrType,ByRef customerID, ByVal sFilterString)

    fGuiReturnBestMatchPerfixNumber = True

	'Only one result found in objRS
	If ObjRS.RecordCount = 1 Then
		GFreephoneCDRType = "Freephone" ' CDR row is Freephone
		Exit Function
	End If

	'More than one result found in objRS
	Call fGuiGetFieldValue(sCopyFilesPath, sTempFileName, "Inbound DNIS", sInboundDNIS)
	iNumberDialedInTranslated = fTranslateDialedNumber(sInboundDNIS, CdrType)
	If InStr(1,iNumberDialedInTranslated,"F") Then
		iNumberDialedInTranslated = Left(iNumberDialedInTranslated,Len(iNumberDialedInTranslated)-1)  
	End If

    Do While Len(iNumberDialedInTranslated)>1
		ObjRS.Filter = sFilterString &" and TEL_PATTERN = " & iNumberDialedInTranslated
		If ObjRS.RecordCount = 1 Then
			GFreephoneCDRType = "Freephone" ' CDR row is Freephone
		   Exit Function
		 ElseIf ObjRS.RecordCount > 0 and InStr (1,sFilterString,"CUSTOMER_ID =") = 0 Then  'Into NL case-customer not found
				Call fReport("fGuiReturnBestMatchPerfixNumber","Search for best match rate row in freephone rates file. Into NL case-customer not found","INFO","found more than one match row (takes the first one)",0,iReportFailRow)
				GFreephoneCDRType = "Freephone" ' CDR row is Freephone
				Exit Function
		 End If 
        iNumberDialedInTranslated = Left(iNumberDialedInTranslated,Len(iNumberDialedInTranslated)-1)
		ObjRS.Filter = 0
	Loop

	fGuiReturnBestMatchPerfixNumber = False
	Call fReport("fGuiReturnBestMatchPerfixNumber","Search for best match rate row in freephone rates file","FAIL","No match rates rows found",0,iReportFailRow)
    
End Function
'----------------------------------------------------------------------
'----------------------------------------------------------------------
' Function name: fGuiReturnFilteredFreephoneRates
' Description: The fuction returns filtered objRS with data match to CustomerID, sVendorID, sCdrCodeID from the freephone rate file
' Parameters: sCustomerID, sVendorID, sCdrType, sCdrCodeID, ObjFilteredRS, sFileName, bIsItalyCase, sFilterString
' Return value: sCustomerID, ObjFilteredRS - Match rows in Freephone Rate File, sFilterString
' Example:
'----------------------------------------------------------------------
Public function fGuiReturnFilteredFreephoneRates(ByRef sCustomerID,ByVal sVendorID,ByVal sCdrType, ByVal sCdrCodeID,ByRef ObjFilteredRS, ByVal sFileName,ByVal bIsItalyCase, ByRef sFilterString)

	Set ObjFilteredRS = rsFreephoneRate
	If(bIsItalyCase = True) Then 'in italy cases filter according 'divice type' field too
		sFilterString = "CUSTOMER_ID = " & sCustomerID & " and VENDOR_ID = " & sVendorID & " and CDR_CODE_ID = " & sCdrCodeID & " and DEVICE_TYPE = 2" 
	Else
		sFilterString = "CUSTOMER_ID = " & sCustomerID & " and VENDOR_ID = " & sVendorID & " and CDR_CODE_ID = " & sCdrCodeID
	End If

    ObjFilteredRS.Filter = sFilterString
	
	If ObjFilteredRS.RecordCount = 0 Then 

		If sCdrType = IntoNL and bIsItalyCase = False Then 'in into NL (not Italy case) customer not found filter according vendor id and CDR code id  
			Call fReport("fGuiReturnFilteredFreephoneRates","Filter freephone rate according Customer id, Vendor id, CDR code id","INFO","<B>No match rates rows were found</B>",0,iReportFailRow)
			ObjFilteredRS.Filter = 0
			Call fReport("fGuiReturnFilteredFreephoneRates","Filter freephone rate according Vendor id, CDR code id","INFO"," ",0,iReportFailRow)
			sFilterString = "VENDOR_ID = " & sVendorID & " and CDR_CODE_ID = " & sCdrCodeID
			ObjFilteredRS.Filter = sFilterString
			If ObjFilteredRS.RecordCount = 0 Then 
				Call fReport("fGuiReturnFilteredFreephoneRates","Filter freephone rate according Vendor id, CDR code id","FAIL","<B>No match rates rows were found for </B>" & sCdrType & "<B> case</B>",0,iReportFailRow)
				'Call fUpdateArrErrorRows("No match rates row was found for ",iReportFailRow)
				fGuiReturnFilteredFreephoneRates = False
			Else 
				Call fReport("fGuiReturnFilteredFreephoneRates","Filter freephone rate according Vendor id, CDR code id","PASS","<B>Found match rates rows for </B>" & sCdrType & "<B> case</B>",0,iReportFailRow)	
				fGuiReturnFilteredFreephoneRates  = True
			End If
			Exit Function
		End If

	Call fReport("fGuiReturnFilteredFreephoneRates","Filter freephone rate according Customer id, Vendor id, CDR code id","INFO","<B>No match rates rows were found for </B>" & sCdrType & "<B> case</B>",0,iReportFailRow)
	fGuiReturnFilteredFreephoneRates = False
	Exit Function 
	End If

    fGuiReturnFilteredFreephoneRates = True
End Function

'----------------------------------------------------------------------
'----------------------------------------------------------------------
' Function name: fGuiItalyCusVend
' Description: The function check Italy customer/Vendor raw CDR case  
' Parameters: ObjRS, sCustomerID, sVendorID, sCdrType, sCdrCodeID, bErrorRate
' Return value: ObjRS, bErrorRate
' Example:
'----------------------------------------------------------------------
Public function fGuiItalyCusVend(ByRef ObjRS, ByVal sCustomerID,ByVal sVendorID,ByVal sCdrType,ByVal sCdrCodeID,ByRef bErrorRate)

	bErrorRate = False
	Call fGuiGetFieldValue(sCopyFilesPath, sTempFileName, "Inbound Raw ANI", sInboundRawANI)

	'check Italy Customer case (Into NL/Into Den)
	If (sCdrType = IntoNL or sCdrType = IntoDenmark) and (sCustomerID = "8894" or sCustomerID = "8930" or sCustomerID = "9186" or sCustomerID = "9456" or sCustomerID = "11939") and (Left(sInboundRawANI,3) = "393") Then
		bIsItaly = True
		Call fReport("fBusFreephone","Check for Italy case","INFO","The current row <B>is Italy Customer</B>",0,iReportFailRow)
	'check Italy Vendor case (OutOfNL)
	ElseIf (sCdrType = OutOfNL) and (sVendorID = "9383" or sVendorID = "9452" or sVendorID = "9282" or sVendorID = "9731" or sVendorID = "12759" or sVendorID = "12800") and (Left(sInboundRawANI,3) = "316") Then
   		bIsItaly = True
		Call fReport("fBusFreephone","Check for Italy case","INFO","The current row <B>is Italy Vendor</B>",0,iReportFailRow)
	'Not Italy case
	Else
		bIsItaly = False
	End If

    If bIsItaly = True Then
		If fGuiReturnFilteredFreephoneRates(sCustomerID, sVendorID, sCdrType, sCdrCodeID, ObjRS, GlobalDictionary("FILE_NAME"),True,sFilterString)<> True Then
			bErrorRate = True       'Error Rate
			ObjRS.Filter = 0
		Else
			If fGuiReturnBestMatchPerfixNumber(ObjRS,sCdrType,sCustomerID,sFilterString) <> True Then
				bErrorRate = True
				ObjRS.Filter = 0
			Else
				fGuiItalyCusVend = True
				'ObjRS.Filter = 0
				Exit Function
			End If
		End If
	End If

    fGuiItalyCusVend = False
End Function
'----------------------------------------------------------------------
'----------------------------------------------------------------------
' Function name: fGuiCheckISDN
' Description: the function check if CDR is ISDN  
' Parameters: 
' Return value: If ISDN - True, Else - False
' Example:
'----------------------------------------------------------------------
Public function fGuiCheckISDN()

	'Get 'TMR' value to check if CDR is ISDN
	Call fGuiGetFieldValue(sCopyFilesPath,"TempFile.txt","TMR",iFieldValue)
	If iFieldValue = 2 Then
		fGuiCheckISDN = True
	Else 
		fGuiCheckISDN = False 
	End If
End Function
'----------------------------------------------------------------------
'----------------------------------------------------------------------
' Function name: fGuiFilterISDNMatchRows
' Description: the function filter the big files (customer data+vendor data) according the cut prefix and copy it to objRS and verify that the objRS is not empty  
' Parameters: 
' Return value: If succeeded - True, Else - False
' Example:
'----------------------------------------------------------------------
Public Function fGuiFilterISDNMatchRows(ByVal CusORVend,ByVal sCommand,ByVal sFileName,ByRef ObjRS)

	Call fGuiDoGrepCommandInCMD(sCommand, sFileName) 'after this function we get a file with all optional rows (cus\vend + cut prefix)
	wait 1

	sFileDate = Left(GlobalDictionary("FILE_NAME"),8)
	'Call fCopyFileToLocalMachine(sBigFilesPath & sFileDate,"Filter-" & sFileName)

	Set o = CreateObject("scripting.filesystemobject")   'check if the spesific file is empty
'		Set sPathFileName = o.GetFolder("C:\cygwin64\home\"& Environment.Value("UserName")&"\")
		Set sPathFileName = o.GetFolder("C:\cygwin\home\"& Environment.Value("UserName")&"\")
		For each objFile in sPathFileName.Files
			If objFile.Name = "Filter-" & sFileName Then
				If objFile.Size > 0 Then
	
					If fTextFileToObjRS(sBigFilesPath & sFileDate ,"Filter-" & sFileName, sCustomerVendorDataHeaders, sCustomerVendorDataColumnsTypes ,ObjRS,True) <> True Then
						fGuiFilterISDNMatchRows = False
						Exit Function
					Else   'found match rows for ISDN customer \ vendor
						Select Case CusORVend
							Case "Cus"
								Call fReport("fGuiFilterISDNMatchRows","<B>Seems that Customer is ISDN</B>","INFO"," found match rows for customer",0,iReportFailRow)
								GCusCDRType = "ISDN"
							Case "Vend"
								Call fReport("fGuiFilterISDNMatchRows","<B>Seems that Vendor is ISDN</B>","INFO"," found match rows for vendor",0,iReportFailRow)
								GVendCDRType = "ISDN"
						End Select
						Exit For 'Breake the loop
					End If
				
				End If

				Select Case CusORVend  'didn't find match rows for ISDN customer \ vendor
					Case "Cus"
						Call fReport("fGuiFilterISDNMatchRows","<B>Customer is not ISDN</B>","INFO","didn't find match row for customer",0,iReportFailRow)
						GCusCDRType = "Regular"
					Case "Vend"
						Call fReport("fGuiFilterISDNMatchRows","<B>Vendor is not ISDN</B>","INFO","didn't find match row for vendor",0,iReportFailRow)
						GVendCDRType = "Regular"
				End Select
				Exit For
			End If
		Next
	fGuiFilterISDNMatchRows = True
	
End Function
'----------------------------------------------------------------------
'----------------------------------------------------------------------
' Function name: fGuiDoGrepCommandInCMD
' Description: the function do the grep command to get match rows for big files
' Parameters: the command, sFileName
' Return value: create new file with the filtered rows
' Example:
'----------------------------------------------------------------------
Public Function fGuiDoGrepCommandInCMD(sCommand, sFileName)

		sFileDate = Left(GlobalDictionary("FILE_NAME"),8)
   	
		Dim iHwnd
		If Window("~").Exist(1) = False Then
'			SystemUtil.Run "C:\cygwin64\bin\mintty.exe", "-i /Cygwin-Terminal.ico -"
			SystemUtil.Run "C:\cygwin\bin\mintty.exe", "-i /Cygwin-Terminal.ico -"
			Wait 5
			iHwnd = Window("~").GetROProperty("hwnd")
		Else
			iHwnd = Window("~").GetROProperty("hwnd")
			Window("hwnd:=" & iHwnd).Activate
			wait 1
		End If

'		Window("hwnd:=" & iHwnd).Type "cd c:/cygwin64/home/" & Environment.Value("UserName")&"/"
'		Window("hwnd:=" & iHwnd).Type micReturn 
'		If Instr (1,sCommand,"grep") > 0 Then 'Grep command with |
'			Window("hwnd:=" & iHwnd).Type "grep " & sCommand & " >" & "Filter-" & sFileName 
'		Else
			Window("hwnd:=" & iHwnd).Type "grep " & sCommand & " " & sFileDate & sFileName & " >" & "Filter" & sFileName 
'		End If
		
		Window("hwnd:=" & iHwnd).Type micReturn
		
		While right(Trim(Window("hwnd:=" & iHwnd).GetVisibleText),1) <> "#"
			Wait 2
		Wend
		
		'Wait 1

End Function
'----------------------------------------------------------------------
'----------------------------------------------------------------------
' Function name: fGuiFindISDNMatchCustVendRow
' Description:the function find match row on customer\vendor - data files
' Parameters:ISDNObjRS, customer\vendor - CustORVendID, CustORVendID, sPrefix
' Return value: ISDNObjRS- contain best match row
' Example:
'----------------------------------------------------------------------
public function fGuiFindISDNMatchCustVendRow(ByRef ISDNObjRS,ByVal CustORVend,ByVal CustORVendID,ByVal sPrefix)

	sFileName = GlobalDictionary("FILE_NAME")
	
	If instr(1,sPrefix,"F") > 0 Then
		sDialedNumber = left(sPrefix, Len(sPrefix)-1) 'take off the F
	Else
		sDialedNumber = sPrefix
	End If

	Select Case CustORVend
		Case "Customer"
			sISDNFileName =  "Filtercustomerdata.txt"
		Case "Vendor"
			sISDNFileName = "Filtervendordata.txt"
	End Select
	
	Do While Len(sDialedNumber)>=1
		sFilterString = " PARTNER_ID = " & CustORVendID & " and TEL_PATTERN =  " & sDialedNumber
		ISDNObjRS.Filter = sFilterString

		If ISDNObjRS.RecordCount > 0 and ISDNObjRS.RecordCount < 5 Then  '(in ISDN case exist 4 identity rows)-
			fGuiFindISDNMatchCustVendRow = True                                      ' find best match rows (can be more than one)
		    Exit Function
		End If
		sDialedNumber = Left(sDialedNumber,Len(sDialedNumber)-1)
		ISDNObjRS.Filter = 0
	Loop

	fGuiFindISDNMatchCustVendRow = False

End Function

'----------------------------------------------------------------------
'----------------------------------------------------------------------
' Function name: fGuiCheckTransit
' Description: the function check if CDR is Transit
' Parameters:
' Return value: If Transit - True, Else - False
' Example:
'----------------------------------------------------------------------
Public function fGuiCheckTransit(ByVal sVendorID)

	'Get 'Routing-table key' value to check if CDR is Transit 
   Call fGuiGetFieldValue(sCopyFilesPath,"TempFile.txt","Routing-table key",iFieldValue)
   If iFieldValue = 743 or (iFieldValue = 658 and sVendorID <> 12903) Then
		fGuiCheckTransit = True
	Else
		fGuiCheckTransit = False
   End If

End Function
'----------------------------------------------------------------------
'----------------------------------------------------------------------
' Function name: fGuiFindBestMatchTransitRow
' Description:the function find match row on Transit file
' Parameters: 
' Return value: 
' Example:
'----------------------------------------------------------------------
public function fGuiFindBestMatchTransitRow(ByRef rsTransitRate,ByVal sCustomerID,ByVal sVendorID,ByVal sPrefix)

	Dim sFileName,sDialedNumber,sCallDate

	sFileName = Left(GlobalDictionary("FILE_NAME"),8)

	Call fGuiGetFieldValue(sCopyFilesPath,sTempFileName,"Date",sCallDate)'Get Call Date from the Input CDR
	sCallDate = fFormatDate(sCallDate,"mm/dd/yyyy")
	
	If instr(1,sPrefix,"F") > 0 Then
		sDialedNumber = left(sPrefix, Len(sPrefix)-1) 'take off the F
	Else
		sDialedNumber = sPrefix
	End If

	'Loop to find the best matched transit row
	Do While Len(sDialedNumber)>=1
		sFilterString = "CUSTOMER_ID = " & sCustomerID & " and VENDOR_ID = " & sVendorID & " and TEL_PATTERN =  " & sDialedNumber & " and END_DATE like '" &  sCallDate & "%'"  
		rsTransitRate.Filter = sFilterString 

		If rsTransitRate.RecordCount = 1 Then
			fGuiFindBestMatchTransitRow = True                                    
		    Exit Function
		End If

		sDialedNumber = Left(sDialedNumber,Len(sDialedNumber)-1)
		rsTransitRate.Filter = 0
	Loop

	fGuiFindBestMatchTransitRow = False

End Function
'----------------------------------------------------------------------
'----------------------------------------------------------------------
' Function name: fGuiFindTransBestMatchMastRow
' Description: The function find best match rows for Customer in Master file
' Parameters: sCustomerID, sPrefix
' Return value: 
' Example:
'----------------------------------------------------------------------
Public function fGuiFindTransBestMatchMastRow(ByVal sCustomerID,ByVal sPrefix,ByRef sCustRowObjRs)
	Dim sDialedNumber,sFileName,sCallDate,sFileDate

	sFileName = "master"

	Call fGuiGetFieldValue(sCopyFilesPath,sTempFileName,"Date",sCallDate)'Get Call Date from the Input CDR
	sCallDate = fFormatDate(sCallDate,"mm/dd/yyyy")
	sCommand = Left(sPrefix,2) & ".*," & Left(sCallDate,11) & ".*"

	Call fGuiDoGrepCommandInCMD(sCommand, "-" & sFileName & ".txt")

	If fTextFileToObjRS(sRTRFilesPath ,"Filter-" & sFileName & ".txt", sCustMastVendHeaders, sCustMastVendColumnsTypes ,rsMaster,True) <> True Then
		fGuiFindTransBestMatchMastRow = False
		Exit Function
	End If   'found match rows for Transit customer 

	If instr(1,sPrefix,"F") > 0 Then
		sDialedNumber = left(sPrefix, Len(sPrefix)-1) 'Take off the F
	Else
		sDialedNumber = sPrefix
	End If

	Do While Len(sDialedNumber)>=1
			sFilterString = "TEL_PATTERN = " & sDialedNumber & " and PARTNER_ID = " & sCustomerID & " and END_DATE like '" & sCallDate & "%'"
			rsMaster.Filter = sFilterString
			If rsMaster.RecordCount = 1 Then
				fGuiFindTransBestMatchMastRow = True
				Set sCustRowObjRs = rsMaster'.Clone 'The rows taked from Master.txt
				Exit Function
			End If
		sDialedNumber = Left(sDialedNumber,Len(sDialedNumber)-1)
		rsMaster.Filter = 0
	Loop
	
	fGuiFindTransBestMatchMastRow = False
	bTransErrorRate = True

End Function
'----------------------------------------------------------------------
'----------------------------------------------------------------------
' Function name: fGuiFindRegBestMatchCustMastVendRow
' Description: The function find best match rows for Customer/Master and Vendor files
' Parameters: RegularObjRS, PartnerID-customer\vendor_ID, sPrefix
' Return value: RegularObjRS - contain best match rows
' Example:
'----------------------------------------------------------------------
Public function fGuiFindRegBestMatchCustMastVendRow(ByRef RegularObjRS,ByVal sPartnerID,ByVal sPrefix,ByRef sFilterCommand,ByRef sPartnerType,ByRef IsFound,ByVal sFileName)

	Dim sDialedNumber,sRegularFileName,sFilterString,sCallDate
	
	If instr(1,sPrefix,"F") > 0 Then
		sDialedNumber = left(sPrefix, Len(sPrefix)-1) 'Take off the F
	Else
		sDialedNumber = sPrefix
	End If

	Call fGuiGetFieldValue(sCopyFilesPath,sTempFileName,"Date",sCallDate)'Get Call Date from the Input CDR
	sCallDate = fFormatDate(sCallDate,"mm/dd/yyyy")

	Do While Len(sDialedNumber)>=1

		If sFileName <> "master" Then
			sFilterString = "TEL_PATTERN = " & sDialedNumber & " and PARTNER_ID = " & sPartnerID & " and End_Date like '" & sCallDate & "%'"
		Else 
			sFilterString = "TEL_PATTERN = " & sDialedNumber & " and End_Date like '" & sCallDate & "%'"
		End If

        RegularObjRS.Filter = sFilterString
		
    	If RegularObjRS.RecordCount > 0 and RegularObjRS.RecordCount < 4 Then  				'(in Regular case can be exist 3 identity rows 
			sFilterCommand = sFilterString 'Save filter string for filter by TOD later			'with different Period_ID)
			sPartnerType = "Regular"					
			IsFound = True															 'find best match rows (can be more than one)      
			fGuiFindRegBestMatchCustMastVendRow = True                            				
 		    Exit Function                                                            
		End If

		sDialedNumber = Left(sDialedNumber,Len(sDialedNumber)-1)
		RegularObjRS.Filter = 0
	Loop

	fGuiFindRegBestMatchCustMastVendRow = False

End Function
'----------------------------------------------------------------------
'----------------------------------------------------------------------
' Function name: fGuiGetBestRowByPrefRouteID
' Description: The function find match rows by PR_ID for customer Regular
' Parameters: rsPreRoutePrefroute - ObgRs for filter PR_ID value
' Return value: 
' Example:
'----------------------------------------------------------------------
Public function fGuiGetBestRowByPrefRouteID(ByRef rsRegularPrefRouteCus,ByVal sCustomerID,ByVal sPrefix,ByRef sFilterCusPrefCommand,ByRef GCusCDRType,ByRef IsFound)

	Dim sFilterString,iPR_ID,sFileDate,arrDate,sCallDate,sPRCommand
	IsFound = False

	rsPreRoutePrefroute.Filter = 0

	If instr(1,sPrefix,"F") > 0 Then
		sPrefix = left(sPrefix, Len(sPrefix)-1) 'Take off the F
   	End If

	While IsFound = False and Len(sPrefix)>=1 'Loop for find the best match row from Pre_Route_Prefroute.txt
	
		'Get the Route_ID and PR_ID by Prefix value from Pre_Route_Prefroute.txt
		Do While Len(sPrefix)>=1 
			sFilterString = "TEL_PATTERN = " & sPrefix 
			
			rsPreRoutePrefroute.Filter = sFilterString
	
			If rsPreRoutePrefroute.RecordCount = 1 Then                                   
				Call fReport("fGuiGetBestRowForEndCaseRegCustomer","Get best match row from Route_Prefroute.txt by <B>'Prefix' = " & sPrefix & "</B>" ,"INFO","Found a match row - <B>PR_ID = " & rsPreRoutePrefroute.Fields("PREFERRED_ROUTE_ID").Value & "</B>",0,iReportFailRow)
				Exit Do                                                            
			End If
	
			sPrefix = Left(sPrefix,Len(sPrefix)-1)
			rsPreRoutePrefroute.Filter = 0
		Loop
	
		'Get Preferred_route_id value
		iPR_ID = rsPreRoutePrefroute.Fields("PREFERRED_ROUTE_ID").Value
	
		'Collect Regular Customer_Prefroute big file , filter according PR_ID
		sFileDate = Left(GlobalDictionary("FILE_NAME"),8)
		'Filter according Customer_ID & PR_ID by Grep command                
		'sPRCommand = "," & iPR_ID & ", " & sFileDate & "-customer-prefroute.txt | grep ," & sCustomerID& ","
		sPRCommand = "," & sCustomerID & ",.*," & iPR_ID & "," ' & sFileDate & "-customer-prefroute.txt" 
		
		'Filter by CMD and create filter Customer_Prefroute results file
		Call fGuiDoGrepCommandInCMD(sPRCommand,"-customer-prefroute.txt")

   		Set O = CreateObject("scripting.filesystemobject")   'check if the spesific file is empty
'		Set sObjFileName = O.GetFile("C:\cygwin64\home\"& Environment.Value("UserName")&"\Filter-customer-prefroute.txt")
		Set sObjFileName = O.GetFile("C:\cygwin\home\"& Environment.Value("UserName")&"\Filter-customer-prefroute.txt")

		'Continue to filter by New PR_ID while didn't find match rows
		If sObjFileName.Size > 0 Then 
			'Set collected file to Cust_Pref_Route ObjRS - rsRegularPrefRouteCus
			If fTextFileToObjRS(sBigFilesPath & sFileDate ,"Filter-customer-prefroute.txt" ,sCusPrefrouteHeaders,sCusPrefrouteColumnsTypes,rsRegularPrefRouteCus,True) <> True Then
   				fGuiGetBestRowByPrefRouteID = False 'Failed
				Exit Function
			End If
		
			Call fGuiGetFieldValue(sCopyFilesPath, sTempFileName, "Date", sCallDate)'Call date
			sCallDate = fFormatDate(sCallDate,"mm/dd/yyyy")
			
			'Find the best match rows by date
      		sFilterString = "PARTNER_ID = " & sCustomerID & " and PREFERRED_ROUTE_ID = " & iPR_ID & " and End_Date like '" & sCallDate & "%'"
			rsRegularPrefRouteCus.Filter = sFilterString
		
			If rsRegularPrefRouteCus.RecordCount > 0 and rsRegularPrefRouteCus.RecordCount < 4 Then  '(in Regular case can be exist 3 identity rows 																				  
				IsFound = True    'Found match rows                            								 'with different of Period_ID 
				sFilterCusPrefCommand = sFilterString 'Save filter string for filter by TOD later
				GCusCDRType	= "Regular"
				Call fReport("fGuiGetBestRowByPrefRouteID","Get Customer_PrefRoute.txt match row by <B>Preferred_Route_ID = " & iPR_ID & "</B>","PASS","Found match rows by <B>" & iPR_ID & "</B> PR_ID",0,iReportFailRow)
   			Else
				Call fReport("fGuiGetBestRowByPrefRouteID","Get Customer_PrefRoute.txt match row by <B>Preferred_Route_ID = " & iPR_ID & "</B>","INFO","Didn't find matched rows by the specific PR_ID",0,iReportFailRow)
				IsFound = False 'Didn't find a match row
				sPrefix = Left(sPrefix,Len(sPrefix)-1)
				rsRegularPrefRouteCus.Filter = 0
   			End If

		Else
   			sPrefix = Left(sPrefix,Len(sPrefix)-1)
			rsPreRoutePrefroute.Filter = 0 'Restart rsPreRoutePrefroute
		End If
   	Wend

	If IsFound = False Then
		fGuiGetBestRowByPrefRouteID = False 'Didn't find match rowws
	Else
		fGuiGetBestRowByPrefRouteID = True  'Found match rows  
	End If

End Function
'----------------------------------------------------------------------
'----------------------------------------------------------------------
' Function name: fGuiGetMatchRowsInCusMasVen
' Description: The function find match rows by Prefix and Partner_ID with CMD
			  'The function used with 'fGuiFindRegBestMatchCustMastVendRow' function
' Parameters: 
' Return value: 
' Example:

'----------------------------------------------------------------------
Public Function fGuiGetMatchRowsInCusMasVen(ByRef ObjRs,ByVal sPartnerID,ByVal sPrefix,ByVal sFileName,ByRef sFilterCommand,ByRef sPartnerType,ByRef IsFound)

	Dim sCommand,sFileDate
	sFileDate = Left(GlobalDictionary("FILE_NAME"),8)

	'Collect Customer/Master - big files.
	'Part of Grep command for big fiels (the complete command created in 'fGuiDoGrepCommandInCMD' function)
	'sCommand = Left(sPrefix,1) & " " & sFileDate & "-" & sFileName & ".txt | grep ," & sPartnerID & ","
	'sCommand = "," & sPartnerID & ", " & sFileDate & "-" & sFileName & ".txt | grep ^" & Left(sPrefix,2) 
	If sFileName <> "master" Then 'Should filter by Prefix & Partner
		sCommand = Left(sPrefix,2) & ".*," & sPartnerID  & "," '& sFileDate & "-" & sFileName & ".txt" 
	Else
		Call fGuiGetFieldValue(sCopyFilesPath,sTempFileName,"Date",sCallDate)'Get Call Date from the Input CDR
		sCallDate = fFormatDate(sCallDate,"mm/dd/yyyy")
		sCommand = Left(sPrefix,2) & ".*," & Left(sCallDate,11) & ".*"
	End If
	
	'After this function we get a file with all optional rows 
	Call fGuiDoGrepCommandInCMD(sCommand, "-" & sFileName & ".txt")

   	'Set collected file to ObjRS
'	If fTextFileToObjRS(sBigFilesPath & sFileDate ,"Filter-" & sFileName & ".txt" ,sCustMastVendHeaders,sCustMastVendColumnsTypes,ObjRs,True) <> True Then
'		fGuiGetMatchRowsInCusMasVen = False ' Failed
'		Exit Function
'	End If

	If fTextFileToObjRS(sRTRFilesPath  ,"Filter-" & sFileName & ".txt" ,sCustMastVendHeaders,sCustMastVendColumnsTypes,ObjRs,True) <> True Then
		fGuiGetMatchRowsInCusMasVen = False ' Failed
		Exit Function
	End If

	'Get the best match rows by Prefix+Partner+Date
	If fGuiFindRegBestMatchCustMastVendRow(ObjRs,sPartnerID,sPrefix,sFilterCommand,sPartnerType,IsFound,sFileName) <> True Then
		fGuiGetMatchRowsInCusMasVen = False
	Else
		fGuiGetMatchRowsInCusMasVen = True
	End If

End Function
'----------------------------------------------------------------------
'----------------------------------------------------------------------
' Function name: fGuiCheckTOD
' Description: The function check TOD for Cus/Vend 
' Parameters: 
' Return value: 
' Example:
'----------------------------------------------------------------------
Public Function fGuiCheckTOD(ByRef ObjRS,ByVal CusOrVend,ByVal sFilterCommand)

	Dim PR_ID,RouteID,VendorID,sFileName,sFilterString,sCallDate,iDay,iTime,definitionsObjRS,PeriodID
	PeriodID = 0
	'Extract requiered data for Cus or Vend
	Select Case CusOrVend
	
		Case "customer"
			sFileName = "pre_crp.txt"
			PR_ID = ObjRS.Fields("PREFERRED_ROUTE_ID").value
			sFilterString = "PREFERRED_ROUTE_ID = " & PR_ID
			Set definitionsObjRS = rsPreCrp
		Case "vendor"
			sFileName = "pre_vrp.txt"
			RouteID = ObjRS.Fields("ROUTE_ID").value
			VendorID = ObjRS.Fields("PARTNER_ID").value
			sFilterString = "Vendor_ID = " & VendorID & " and ROUTE_ID = " & RouteID
			Set definitionsObjRS = rsPreVrp
	End Select

	'Filter ObjRS to find a match definitions row
	definitionsObjRS.Filter = sFilterString
	If definitionsObjRS.RecordCount <> 1 Then
		Call fReport("fGuiCheckTOD","Filter " & sFileName ,"FAIL","Didn't find a match definitions row",0,iReportFailRow)
		Call fUpdateArrErrorRows("Didn't find a match definitions row in " & sFileName,iReportFailRow)
		fGuiCheckTOD = False
		Exit Function
	End If

	'Get Call date from input file (2nd field)
	 Call fGuiGetFieldValue(sCopyFilesPath, sTempFileName,"Date", sCallDate)

	'Get Call (input) weekday and time
	iDay = fGetWeekday(sCallDate)
   	iTime = fFormatTime(Right(sCallDate,11),"HH:MM:SS","HH:MM:SS")
	sCallDate = fFormatDate(sCallDate,"mm/dd/yyyy") 'TBD like that to time

	'Get definitions of the definition match row
	iWeekendStartDay = definitionsObjRS.Fields("Weekend_Start_Day").value
	iWeekendEndDay = definitionsObjRS.Fields("Weekend_End_Day").value
	iWeekendStartTime = fFormatTime(definitionsObjRS.Fields("Weekend_Start_Time").value,"HHMMSS","HH:MM:SS")
	iWeekendEndTime = fFormatTime(definitionsObjRS.Fields("Weekend_End_Time").value,"HHMMSS","HH:MM:SS")
	iOffPeakStartTime = fFormatTime(definitionsObjRS.Fields("Off-Peak_Start_Time").value,"HHMMSS","HH:MM:SS")
	iOffPeakEndTime = fFormatTime(definitionsObjRS.Fields("Off-Peak_End_Time").value,"HHMMSS","HH:MM:SS")

	'Find match TOD according to the definitions

	'Check Weekend days range
	If iWeekendStartDay > iWeekendEndDay Then
		If iDay < iWeekendEndDay Then
			iDay = iDay + 6 'Add the total of Week Days(6) for iDay value only while iDay < WeekendEndDate
		End If
		iWeekendEndDay = iWeekendEndDay + 6 'Add the total of Week Days(6) for weekend value only while WeekendEndDay < WeekendStartDay
   	End If

	If iDay >= iWeekendStartDay and iDay <= iWeekendEndDay Then 'Check if the days in the rang, If yes - continue to check if the time too.
		'Check Weekend hours range
		If iWeekendStartTime >= iWeekendEndTime Then 'Reverse range
			If (iTime >= iWeekendStartTime and iTime <= "23:59:59") OR (iTime >= "00:00:00" and iTime <= iWeekendEndTime) Then
				PeriodID = 3 'WeekEnd
  			End If
		Else 'Straight range
			If iTime >= iWeekendStartTime and iTime <= iWeekendEndTime Then
				PeriodID = 3 'WeekEnd
			End If
		End If
	End If 

	If PeriodID = 0 Then
		'Check OffPeak hours range 
		If iOffPeakStartTime >= iOffPeakEndTime Then 'Reverse range
			If (iTime >= iOffPeakStartTime and iTime <= "23:59:59") OR (iTime >= "00:00:00" and iTime <= iOffPeakEndTime) Then 
				PeriodID = 2 'OffPeak
			End If
		Else 'Straight range
			If iTime > iOffPeakStartTime and iTime < iOffPeakEndTime Then
				PeriodID = 2 'OffPeak
			End If
		End If
	End If

	If PeriodID = 0 Then 'Not Weekend and Not Offpeak
		PeriodID = 1 'Peak
	End If

	Call fReport("fGuiCheckTOD","Select the <B>best</B> match row for "& CusOrVend & " according to <B>Period_ID = " & PeriodID & "</B>","INFO","<B>Period_ID = " & PeriodID & "</B>",0,iReportFailRow)
	'Filter Cus/Vend ObjRS according to TOD definition
	ObjRS.Filter = sFilterCommand & " and Rate-Period-Id = " & PeriodID

	definitionsObjRS.Filter = 0

	fGuiCheckTOD = True
	
End Function
'----------------------------------------------------------------------
'----------------------------------------------------------------------
' Function name: fGuiSetFinalCustomerObjRs
' Description: The function check from which file the match rows will take for Regular customer case
' Parameters: 
' Return value: 
' Example:
'----------------------------------------------------------------------
Public Function fGuiSetFinalCustomerObjRs(ByRef CusFinalObjRs,ByVal sFilterCusCommand,ByVal sFilterCusPrefCommand,ByVal sFilterMastCommand,ByRef sFilterFinalCommand,ByRef bCusRegError,ByRef sFoundFile) ',ByRef iRouteID

	Dim iCusPrefixLen,iCusPrefPrefixLen

	'Check if found in Master file
	If lcase(TypeName(rsMaster)) = lcase("Recordset") Then
		Set CusFinalObjRs = rsMaster.Clone 'The rows taked from Master.txt
		sFoundFile = "Master" 'Flag for assign if found in Master
		sFilterFinalCommand = sFilterMastCommand 'Set filter command for filter by TOM later
		'iRouteID = fGuiGetRouteIDValue()'Set Route_ID value by filter pre_Route by Input prefix
		iRouteID = rsMaster.Fields("Route_ID").Value
	'	iRouteID = fGuiGetRouteIDForRegCusCase() 'Set Route_ID value by filter pre_Route by used Pre_Route_PrefRoute prefix
		rsMaster.Filter = 0
   		Exit Function
	End If

	'Check if found rows in both files
	If rsCustomer.RecordCount < 4 and rsRegularPrefRouteCus.RecordCount < 4 Then 'Found in both files

   		iCusPrefixLen = Len(rsCustomer.Fields("TEL_PATTERN").Value) 'Length of Prefix from Customer match rows
		iCusPrefPrefixLen = Len(rsRegularPrefRouteCus.Fields("TEL_PATTERN").Value) 'Length of Prefix from Customer_Pref_Route match rows

		If iCusPrefixLen > iCusPrefPrefixLen Then
			Set CusFinalObjRs = rsCustomer.Clone
			sFoundFile = "Customer"
			sFilterFinalCommand = sFilterCusCommand
			'iRouteID = fGuiGetRouteIDValue()'Set Route_ID value by filter pre_Route by Input prefix
			'iRouteID = fGuiGetRouteIDForRegCusCase() 'Set Route_ID value by filter pre_Route by used Pre_Route_PrefRoute prefix
			iRouteID = rsCustomer.Fields("Route_ID").Value
  			rsCustomer.Filter = 0
			Exit Function
		ElseIf iCusPrefixLen < iCusPrefPrefixLen Then
			Set CusFinalObjRs = rsRegularPrefRouteCus.Clone
			sFoundFile = "CusPrefRoute"
			sFilterFinalCommand = sFilterCusPrefCommand
			'iRouteID = fGuiGetRouteIDValue()'Set Route_ID value by filter pre_Route by Input prefix
			'iRouteID = fGuiGetRouteIDForRegCusCase()'Set Route_ID value by filter pre_Route by used Pre_Route_PrefRoute prefix
  			'rsPreRoutePrefroute.Filter = 0
			rsRegularPrefRouteCus.Filter = 0
			Exit Function
		Else 'Both have same length
			Call fUpdateArrErrorRows("ERROR Rate - found match rows for Regular Customer in both files - Customer.txt & Customer_Prefroute.txt with same 'Prefix' length",iReportFailRow)
			bCusRegError = True
   			rsCustomer.Filter = 0
			rsRegularPrefRouteCus.Filter = 0
  			Exit Function
		End If

	End If

	'If found rows only in one file
	If rsCustomer.RecordCount < 4 and rsRegularPrefRouteCus.RecordCount > 4 Then
		Set CusFinalObjRs = rsCustomer.Clone
		sFoundFile = "Customer"
		sFilterFinalCommand = sFilterCusCommand
		'iRouteID = fGuiGetRouteIDValue()'Set Route_ID value by filter pre_Route by Input prefix
		iRouteID = rsCustomer.Fields("Route_ID").Value
  		'iRouteID = fGuiGetRouteIDForRegCusCase() 'Set Route_ID value
		rsCustomer.Filter = 0
		Exit Function
	Else
		Set CusFinalObjRs = rsRegularPrefRouteCus.Clone
		sFoundFile = "CusPrefRoute"
		sFilterFinalCommand = sFilterCusPrefCommand
		'iRouteID = fGuiGetRouteIDValue()'Set Route_ID value by filter pre_Route by Input prefix
   		'iRouteID = fGuiGetRouteIDForRegCusCase()'Set Route_ID value by filter pre_Route by used Pre_Route_PrefRoute prefix
        'rsPreRoutePrefroute.Filter = 0
		rsRegularPrefRouteCus.Filter = 0
		Exit Function
	End If

	Call fUpdateArrErrorRows("Set Customer Final ObjRs - Fail",iReportFailRow)
	fGuiSetFinalCustomerObjRs = False

End Function
'----------------------------------------------------------------------
'----------------------------------------------------------------------
' Function name: fGuiGetRegCustProductID
' Description: The function find Reguler Customer Product_ID
' Parameters: 
' Return value: 
' Example:
'----------------------------------------------------------------------
Public function fGuiGetRegCustProductID(ByVal CusFinalObjRs,ByVal rsPreCustProduct,ByVal rsPrePrefrouteMixmatc,ByVal sCustomerID)

	Dim sFilterString,iPR_ID,sCallDate,iCustProductID,iCustSeconProductID

	sFilterString = "CUSTOMER_ID = " & sCustomerID 'Filter by Customer_ID
	rsPreCustProduct.Filter = sFilterString
	If rsPreCustProduct.RecordCount = 0 Then
		Call fReport("fGuiGetRegCustProductID","Filter Pre_CustProduct to get Product_ID","FAIL","No record found - filter fail",0,iReportFailRow)
		Call fUpdateArrErrorRows("No record found  after filter Pre_CustProduct ObjRs to get Product_ID",iReportFailRow)
		Exit Function
	End If

	If IsNull(rsPreCustProduct.Fields("SECONDARY_PRODUCT_ID").Value) Then 
		iProductID = rsPreCustProduct.Fields("PRODUCT_ID").Value 'There is no 'Secondary_Product_ID'
		Call fReport("fGuiGetRegCustProductID","Get Product_ID value","PASS","<B>Product_ID = " & iProductID & "</B>",0,iReportFailRow)
		rsPreCustProduct.Filter = 0
	Else
		iPR_ID = CusFinalObjRs.Fields("PREFERRED_ROUTE_ID").Value 'Get PR_ID from the match row
		iCustProductID = rsPreCustProduct.Fields("PRODUCT_ID").Value 'Get PRODUCT_ID from Pre_Cust_Product filtered row
		iCustSeconProductID = rsPreCustProduct.Fields("SECONDARY_PRODUCT_ID").Value 'Get SECONDARY_PRODUCT_ID from Pre_Cust_Product filtered row
		Call fGuiGetFieldValue(sCopyFilesPath,sTempFileName,"Date",sCallDate)'Get Call Date from the Input CDR
		sCallDate = fFormatDate(sCallDate,"yyyymmdd")'Format date from mm/dd/yy to yyyymmdd

		'Filter Pre_Prefroute_Mixmatc.txt by PR_ID + Product_ID + Secondary_Product_ID (from the Pre_Cust_Product filtered row) + Date
		sFilterString = "PREFERRED_ROUTE_ID = " & iPR_ID & " and PRODUCT_ID = " & iCustProductID & " and SECONDARY_PRODUCT_ID = " & iCustSeconProductID & " and DATE = " & sCallDate
		rsPrePrefrouteMixmatc.Filter = sFilterString
		If rsPrePrefrouteMixmatc.RecordCount = 0 Then
			Call fReport("fGuiGetRegCustProductID","Filter Pre_Prefroute_Mixmatch to get Secondary_Product_ID","FAIL","No record found - filter fail",0,iReportFailRow)
			Call fUpdateArrErrorRows("No record found  after filter Pre_Prefroute_Mixmatch ObjRs to get Secondary_Product_ID",iReportFailRow)
			Exit Function
		End If
		iProductID = rsPrePrefrouteMixmatc.Fields("MIXMATCH_PRODUCT_ID").Value 'Get 'Secondary_Product_ID' value
		Call fReport("fGuiGetRegCustProductID","Get Product_ID value","PASS","<B>Secondary Product_ID = " & iProductID & "</B>",0,iReportFailRow)
		rsPrePrefrouteMixmatc.Filter = 0
	End If

	fGuiGetRegCustProductID = iProductID

End function
'----------------------------------------------------------------------
'----------------------------------------------------------------------
' Function name: fGuiGetRegVendProductID
' Description: The function find Reguler Vendor Product_ID
' Parameters: 
' Return value: 
' Example:
'----------------------------------------------------------------------
Public function fGuiGetRegVendProductID(ByVal CusFinalObjRs,ByVal rsPreCustProduct,ByVal rsPrePrefrouteMixmatc,ByVal sCustomerID,ByVal iCustProductID)

	Dim iPos

	If InStr(1,GVendCDRType,"Regular") > 0 Then 'Vendor is Regular case

		iPos = InStr(1,GCusCDRType,"Regular") 	'Check Customer Product
		If iPos > 0 Then 'Customer is Regular
			fGuiGetRegVendProductID = iCustProductID 'If Customer is Regular & Vendor is Regular - Vendor Product = Customer Product
			Exit function
		ElseIf iPos = 0 Then'Customer is NOT Regular case 
		'If Customer is NOT Regular case, and Vendor is Regular case -							
				'Vendor Product = Customer Product in case that Customer was Regular case
		fGuiGetRegVendProductID = fGuiGetRegCustProductID(CusFinalObjRs,rsPreCustProduct,rsPrePrefrouteMixmatc,sCustomerID)
	   End If
	End If

End Function
'----------------------------------------------------------------------
'----------------------------------------------------------------------
' Function name: fGuiGetAgrVolMatchRow
' Description: The function get sum of volumn in AGR cases
' Parameters: CusMatchRowObjRs - the best match row that found.
' Return value: 
' Example:
'----------------------------------------------------------------------
Public Function fGuiGetAgrVolMatchRow(ByVal CusVenMatchRowObjRs,ByRef AgrVolObjRs,ByVal CusOrVen)

	Dim sFilterString

	'Filter Agr_Vol file by 'Agreement_ID' + 'MVC_Group_Subseq_ID' from the rate matched row
    sFilterString = "Agreement_ID = " & CusVenMatchRowObjRs.Fields("Agreement_ID").Value & " and MVC_Group_Subseq_ID = " &  CusVenMatchRowObjRs.Fields("MVC_Group_Subseq_ID").Value 
	AgrVolObjRs.Filter = sFilterString

	If AgrVolObjRs.RecordCount <> 1 Then
		Call fReport("fGuiGetAgrVolMatchRow","Filter " & CusOrVen & "_AGR_Vol.txt file","FAIL","Didn't find a matched AGR_Vol row",0,iReportFailRow)
		Call fUpdateArrErrorRows("Didn't find a match AGR_Vol row",iReportFailRow)
		fGuiGetAgrVolMatchRow = False
		Exit Function
	Else
		Call fReport("fGuiGetAgrVolMatchRow","Filter " & CusOrVen & "_AGR_Vol.txt file","PASS","found a matched AGR_Vol row",0,iReportFailRow) 
	End If
	
	fGuiGetAgrVolMatchRow = AgrVolObjRs.fields("SUM").Value

End Function
'----------------------------------------------------------------------
'----------------------------------------------------------------------
' Function name: fGuiGetRouteIDForRegCusCase
' Description: The function get Route_ID for Regular customer case
' Parameters: 
' Return value: 
' Example:
'----------------------------------------------------------------------
Public function fGuiGetRouteIDForRegCusCase()

	Dim iPrefix,sFilterString
	rsPreRoute.Filter = 0
    	
	'Get prefix value used in PreRoutePrefRoute matched row
	iPrefix = rsPreRoutePrefroute.Fields("TEL_PATTERN").Value
	sFilterString = "Route_Tel_Prefix = " & iPrefix

	rsPreRoute.Filter = sFilterString

	If rsPreRoute.Recordcount > 1 Then
		Call fUpdateArrErrorRows("Didn't find a matched row in Pre_Route.txt file",iReportFailRow)
		rsPreRoutePrefroute.Filter = 0
	Else 
		rsPreRoutePrefroute.Filter = 0
		'Return Pre_Route -> Route_ID
		fGuiGetRouteIDForRegCusCase = rsPreRoute.Fields("ROUTE_ID").Value
	End If

End function
'----------------------------------------------------------------------
''----------------------------------------------------------------------
' Function name: fGuiGetRouteIDValue
' Description: The function get Route_ID from Pre_route.txt file by Prefix value
' Parameters: 
' Return value: 
' Example:
'----------------------------------------------------------------------
Public function fGuiGetRouteIDValue()'ByVal sCDRCase

'	If sCDRCase = "Freephone" Then
'		iPrefix = sGlobalPrefix	
'	Else 
'   		Call fGuiGetFieldValue(sCopyFilesPath, sTempFileName, "Inbound DNIS", iPrefix)
'   	End If

	rsPreRoutePrefroute.fields("TEL_PATTERN").Value 'Get Prefix value
	
   	rsPreRoute.Filter = 0

'	While Len(iPrefix) > 0 'Filter pre_route.txt by Prefix value
'		rsPreRoute.Filter = "Route_Tel_Prefix = " & iPrefix
'		If rsPreRoute.Recordcount = 1 Then
'			fGuiGetRouteIDValue = rsPreRoute.Fields("ROUTE_ID").Value
'			'rsPreRoute.Filter = 0
'			Exit function
'		End If
'		rsPreRoute.Filter = 0
'		iPrefix = Left(iPrefix,Len(iPrefix)-1)
'	Wend

	rsPreRoute.Filter = "Route_Tel_Prefix = " & iPrefix

	If rsPreRoute.Recordcount = 1 Then
		fGuiGetRouteIDValue = rsPreRoute.Fields("ROUTE_ID").Value
		'rsPreRoute.Filter = 0
		Exit function
	Else
		Call fReport("fGuiGetRouteIDValue","Get Route_ID value from matched Pre_route.txt row","FAIL","<B>Didn't Find</B> a match row in Pre_route.txt",0,iReportFailRow)
		Call fUpdateArrErrorRows("Didn't find a matched row in Pre_Route.txt file",iReportFailRow)
		fGuiGetRouteIDValue = 0 'Didn't find
	End If

End function 
'----------------------------------------------------------------------
' Function name: fGuiGetTierMatchRow
' Description: The function get tier match row for regular with AGR cases
' Parameters: ObjRs - the Customer/Vendor matched found row
' Return value: 
' Example:
'----------------------------------------------------------------------
Public function fGuiGetTierMatchRow(ByVal sPartnerType,ByRef ObjRs,ByVal sPartnerID,ByVal SumVol,ByRef AGRObjRs,ByRef sGlobalType)

	Dim sCommand,iAgrID,iPeriodID,iMVC,SetObjRs,sFilterString,sFileDate ',iRouteID

	iAgrID = ObjRs.Fields("Agreement_ID").Value
	iPeriodID = ObjRs.Fields("Rate-Period-Id").Value
	iMVC = ObjRs.Fields("MVC_Group_Subseq_ID").Value
   	sFileDate = Left(GlobalDictionary("FILE_NAME"),8)
	Call fGuiGetFieldValue(sCopyFilesPath, sTempFileName, "Date", sCallDate)
	sCallDate = fFormatDate(sCallDate,"mm/dd/yyyy")
	'Get RouteID for the rate row (according Ravit updateing)
	iRouteID = ObjRs.Fields("ROUTE_ID").Value

   	'sCommand = sPartnerID & " " & sFileDate & "-" & sPartnerType & "-tier.txt | grep ," & iAgrID & "," & iRouteID & "," & iPeriodID & "," & iMVC & "," & Left(sCallDate,10)
	sCommand = sPartnerID & "," & iAgrID & "," & iRouteID & "," & iPeriodID & "," & iMVC & "," & Left(sCallDate,10) 
									 
	'Filter by CMD
	Call fGuiDoGrepCommandInCMD(sCommand,"-" & sPartnerType & "-tier.txt") 'Filter Tier matched rows
 
   	'Set collected file to ObjRS
	If fTextFileToObjRS(sBigFilesPath & sFileDate ,"Filter-" & sPartnerType & "-tier.txt" ,sCusVenTierHeaders,sCusVenColumnsTypes,SetObjRs,True) <> True Then
   		fGuiGetTierMatchRow = False ' Failed
		Exit Function
	End If

	'Found the best match tier volume row
	For i=1 To SetObjRs.RecordCount
		sFilterString = "AGR_TIER_ID = " & i
		SetObjRs.Filter = sFilterString
		If SetObjRs.Fields("Tier-Volume").Value >= SumVol Then
			Call fReport("fGuiGetTierMatchRow","Get best match TierVolume row for Customer","PASS","<B>Found</B> a match row in Tier.txt",0,iReportFailRow)
			Set AGRObjRs = SetObjRs.Clone
			AGRObjRs.Filter = sFilterString 'Filter by sFilterString after set.Clone command
            sGlobalType = "AGRRegular"
			fGuiGetTierMatchRow = True
			Exit Function
		End If
	Next

	Call fUpdateArrErrorRows("Set TierVolumn matched row - fail",iReportFailRow)
    fGuiGetTierMatchRow = False

End function
'----------------------------------------------------------------------
