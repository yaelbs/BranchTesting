Public iErrorCDRs 
Public iErrorFields
Public TempiRow
Dim arrErrorCDRs()
Dim arrErrorRows()
Public bReportFlag 
iErrorCDRs = 0
iErrorFields = -1
bReportFlag = 0
'----------------------------------------------------------------------
' Function name: fCeiling
' Description: 
' Parameters: 
' Return value: 
' Example:
'----------------------------------------------------------------------
Public Function fCeiling(ByVal iNum, ByVal iMultiple)

	iTemp = cInt(iNum / iMultiple)
	If iTemp < iNum / iMultiple Then
		iTemp = iTemp + 1
	End If

	fCeiling = iTemp * iMultiple

End Function
'----------------------------------------------------------------------
'----------------------------------------------------------------------
' Function name: fFormatDate
' Description: The function convert data in format mm/dd/yy to yyyymmdd 
' Parameters: sDate
' Return value: formated date string
' Example:
'----------------------------------------------------------------------
Public Function fFormatDate(sDate, sFormat)
	Dim iDay, iMonth

	iDay = cStr(day(sdate))
	If iDay < 10 Then
		iDay = "0" & iDay
	End If
	iMonth = cStr(month(sdate))
	If iMonth < 10 Then
		iMonth = "0" & iMonth
	End If

	Select Case sFormat
		Case "yyyymmdd"
			fFormatDate = year(sdate) & iMonth & iDay
		Case "mm/dd/yy"
			fFormatDate = iMonth & "/" & iDay & "/" & right(year(sdate),2)
		Case "mm/dd/yyyy"
			fFormatDate = iMonth & "/" & iDay & "/" & year(sdate)
	End Select
    
End Function
'----------------------------------------------------------------------
'----------------------------------------------------------------------
' Function name: fFormatTime
' Description: The function convert Time 
' Parameters: sTime
' Return value: formated date string
' Example:
'----------------------------------------------------------------------
Public Function fFormatTime(sTime,sFormatFrom,sFormatTO)

	Dim iHour ,iMinute ,iSecond

	Select Case sFormatFrom 

		Case "HHMMSS" 
			If Len(sTime) < 6 Then
				iToAdd = (6 - Len(sTime))
				For i = 1 To iToAdd
					sTime = "0" & sTime
				Next
			End If
			iHour = Left(sTime,2)
			iMinute = Mid(sTime,3,2)
			iSecond = Right(sTime,2)

		Case "HH:MM:SS"
			iHour = Left(sTime,2)
			iMinute = Mid(sTime,4,2)
			iSecond = Mid(sTime,7,2)
			If iHour = "12" And InStr(1,sTime,"AM") > 0 Then
					iHour = "00"
			End If

	End Select 
	
	Select Case sFormatTO
		Case "HH:MM:SS"
			fFormatTime = iHour & ":" & iMinute & ":" & iSecond
	End Select
    
End Function
'----------------------------------------------------------------------
'----------------------------------------------------------------------
' Function name: fTextFileToObjRS
' Description: The function copy file from remote server, Insert file headers and create objRS with all file data
' Parameters: sFilePath - on the remote server, sFileName, sFileHeaders, 
'				objRS - Output paramter 
' Return value: Success - True, Failure - False, objRS - Return the created objRS.
' Example:
'----------------------------------------------------------------------
Public Function fTextFileToObjRS(ByVal sFilePath, ByRef sFileName, ByVal sFileHeaders, ByVal sDefineColumnsTypes, ByRef objRS, ByVal bIsBigFile)

	err.description = Clear
	If bIsBigFile = false Then 'Not a big file
'		Call fCopyFileToLocalMachine(sFilePath,sFileName)
	End If

	If fCopyFileAndInsertHeaders(sFileName,sFileHeaders,sDefineColumnsTypes) <> True Then
		fTextFileToObjRS = False
		Exit Function
	End If

   	set objdbCon = createobject("adodb.connection")
	objdbCon.connectionstring = "Provider=Microsoft.Jet.OLEDB.4.0;Data Source="& sCopyFilesPath &";Extended Properties=""text;HDR=Yes;FMT=Delimited"";"
	objdbCon.CursorLocation = 3
	objdbCon.Open
	err.clear
    Set o = CreateObject("scripting.filesystemobject")
	Set sPathFileName = o.GetFolder("T:\Matrix-QA\QTP-Aoutomation\QTP-RTR\QTP\RTR\Version1\CopyFiles\")
	For each objFile in sPathFileName.Files
		If objFile.Name = sFileName Then
			If objFile.Size < 100000000 Then
            		sSQL = "select * from " & sFileName
      				Set objRS = objdbCon.Execute(sSQL)
				Exit For
			End If
		End If
	Next
	
	If err.description <> "" Then
		Call fReport("fTextFileToObjRS","Create Text file '" & sFileName & "' to ObjRS","FAIL","Error: " & err.description,0,iReportFailRow)
		fTextFileToObjRS = False
		Exit Function
	End If

	fTextFileToObjRS = True

End Function
'----------------------------------------------------------------------
'----------------------------------------------------------------------
' Function name: fCopyFileAndInsertHeaders
' Description: The function copies File to CopyFiles folder and insert columns headers
' Parameters: sFileName, sHeaders - string of file's headers
' Return value: Success - True, Failure - False
' Example:
'----------------------------------------------------------------------
Public function fCopyFileAndInsertHeaders(ByRef sFileName, ByVal sHeaders, ByVal sDefineColumnsTypes)

	Dim objFSO,objFileRead,sSaveFileData,objFileWrite,bIsBigFile,bEmptyFile
	bIsBigFile = False
	err.description = Clear

	Setting ("DefaultTimeout") = 20000
	
	If sFileName <> GlobalDictionary("FILE_NAME")&".rated" Then       
	   Set objFSO = CreateObject("scripting.filesystemobject")
       Call objFSO.CopyFile(sRTRFilesPath & sFileName, sCopyFilesPath & replace(sFileName,"-",""), True)
	Else                                                       'connect to Output Text file         
	   Set objFSO = CreateObject("scripting.filesystemobject")
	   Call objFSO.CopyFile(sRTRFilesPath & sFileName, sCopyFilesPath & Left(GlobalDictionary("FILE_NAME"),12)&"rated"&".txt", True)
	   sFileName = Left(GlobalDictionary("FILE_NAME"),12)&"rated"&".txt"
	End If
	  
	sFileName = replace(sFileName,"-","")

	Set objFileRead = objFSO.OpenTextFile(sCopyFilesPath & sFileName, 1)
	sSaveFileData = objFileRead.ReadAll
	sSaveFileData =  sHeaders & vbNewLine & sDefineColumnsTypes & vbNewLine & sSaveFileData
	Set objFileWrite = objFSO.OpenTextFile(sCopyFilesPath &  sFileName, 2, True)
	objFileWrite.Write sSaveFileData
	objFileWrite.Close

	If err.description <> "" and err.description <> "Input past end of file" Then ' And bEmptyFile = False Then 
		Call fReport("fCopyFileAndInsertHeaders","Copy " & sFileName ,"FAIL","Error: " & err.description,0,iReportFailRow)
		fCopyFileAndInsertHeaders = False
		Exit Function
	End If

	fCopyFileAndInsertHeaders = True

End Function
'----------------------------------------------------------------------
'----------------------------------------------------------------------
' Function name: fCopyFileToLocalMachine
' Description: The function copies a file from Ribur01 to the local machine
' Parameters: sFilePath - on the remote server, sFileName
' Return value: 
' Example:
'----------------------------------------------------------------------
Public Function fCopyFileToLocalMachine(sFilePath, sFileName)

		'sFilePath - E.g. /data/cdrdata/IP/QA/rating/realtime/
		'sFileName - E.g. 201210180020.txt

		sFileDate = Left(GlobalDictionary("FILE_NAME"),8)

		Window("text:=~").Type "cd " & sFilePath
		Window("text:=~").Type  micReturn
		Window("text:=~").Type "get " & sFileName
		Window("text:=~").Type  micReturn

        'While right(Trim(Window("~").GetVisibleText),1) <> ">"
		While instr(1,right(Trim(Window("~").GetVisibleText),6),"ftp") = 0
			Wait 2
		Wend

    	fCopyFileToLocalMachine = True

End Function
'----------------------------------------------------------------------
'----------------------------------------------------------------------
' Function name: fTranslateDialedNumber
' Description: Translate (-convert) the sInboundDNIS to NUMBER_DIALED_IN_TRANSLATED according the CDR type
' Parameters: sInboundDNIS, CdrType
' Return value: Translated number
' Example:
'----------------------------------------------------------------------
Public function fTranslateDialedNumber(ByVal sInboundDNIS, ByVal sCdrType)

	Dim sTranslatedNumber

	Select Case sCdrType
		Case IntoDenmark, OutOfNL
			sTranslatedNumber = Left(sInboundDNIS, len(sInboundDNIS)-1)

		Case IntoNL
			sTranslatedNumber = Replace(sInboundDNIS,"3100","3114",1,1)

		Case OutOfDenmark
            sTranslatedNumber = Right(sInboundDNIS, len(sInboundDNIS)-5)
	End Select

	fTranslateDialedNumber = sTranslatedNumber

End Function
'----------------------------------------------------------------------
'----------------------------------------------------------------------
' Function name: fGuiGetFieldValue
' Description:The function get field name and return field value
' Parameters: 	sFilePath, sFileName - File to search in 
'				sFieldName - field to search
' Return value: sFieldVal - return the field value
' Example:
'----------------------------------------------------------------------
Public function fGuiGetFieldValue(ByVal sFilePath, ByVal sFileName, ByVal sFieldName, ByRef sFieldVal)

	set objdbCon = createobject("adodb.connection")
	objdbCon.connectionstring = "Provider=Microsoft.Jet.OLEDB.4.0;Data Source="& sFilePath &";Extended Properties=""text;HDR=Yes;FMT=Delimited;"";"
	objdbCon.CursorLocation = 3
	objdbCon.Open

	sSQL = "select *  from " & sFileName
	Set objRS = objdbCon.Execute(sSQL)
'	objRS.MoveFirst
	objRs.MoveNext
    sFieldVal = objRS.Fields(sFieldName).Value
    
	fGuiGetFieldValue = True

End Function
'----------------------------------------------------------------------
'----------------------------------------------------------------------
' Function name: fUpdateArrErrorRows
' Description:
' Parameters: 
' Return value:
' Example:
'----------------------------------------------------------------------
Public function fUpdateArrErrorRows(ByVal ErrorReason,ByVal iReportFailRow)

	If iRow = 1 and iErrorFields = -1 Then
		iErrorFields = 0 'The first record  - the arr start from 0
		TempiRow = 0 'Sum of error records
   		ReDim arrErrorCDRs(0) 'Dinamic arr
		ReDim arrErrorRows(0) 
   	Else 
		ReDim Preserve arrErrorCDRs(iErrorFields)
		ReDim Preserve arrErrorRows(iErrorFields)
   	End If
    
   	If iRow > TempiRow Then 'New record
		TempiRow = iRow  'Update Temp row parameter
		arrErrorCDRs(iErrorFields) = "<B><U>Row number " & iRow & " failed</U><BR>Error reason:</B>" & ErrorReason
		iErrorCDRs = iErrorCDRs + 1
	Else
		arrErrorCDRs(iErrorFields) = "<B>Error reason:</B>" & ErrorReason 
   	End If

	arrErrorRows(iErrorFields) = iReportFailRow
	iErrorFields = iErrorFields + 1 'Update error records index 	

   	fUpdateArrErrorRows = True

End function
'----------------------------------------------------------------------
'----------------------------------------------------------------------
' Function name: fReport
' Description: The function writes row to the report
' Parameters: sStepName, sStepDesc, sStatus, sStatusReason, iReportTo
'				sStatus: "PASS"/"FAIL"/"INFO"/"HEADER"/"TITLE"
'				iReportTo: 0 = Both, 1 = Only QTP report, 2 = Only HTML report
' Return value: 
' Example:
'-----------------------------------------------------------------------
Public Function fReport(ByVal sStepName, ByVal sStepDesc, ByVal sStatus, ByVal sStatusReason, ByVal iReportTo, ByRef iReportFailRow)

	If iReportTo <> 2 Then
		'Write to QTP resutls report
		Select Case sStatus
			Case uCase("PASS")
				Reporter.ReportEvent micPass, sStepName, sStatusReason
			Case uCase("FAIL")
				Reporter.ReportEvent micFail, sStepName, sStatusReason
			Case uCase("INFO")
				Reporter.ReportEvent micWarning, sStepName, sStatusReason
		End Select
	End If

	If iReportTo <> 1 Then
		'Write to HTML results Report
		Call fWriteHtmlReportRow(sStepName, sStepDesc, sStatus, sStatusReason, iReportFailRow)
	End If

End Function
'---------------------------------------------------------------------------
'---------------------------------------------------------------------------
' Function name: fCreateHtmlReport
' Description: The function creates HTML Report
' Parameters: sTestName
' Return value: 
' Example:
'---------------------------------------------------------------------------			  			
Public sResultFile
Public iReportRow
iReportRow = 0

Public Function fCreateHtmlReport(ByVal sTestName)

            Dim sFileName

            If sTestName <> HtmlSummaryReport Then
				sDate = Now
				sDate = Replace(sDate, " ", "_")
				sDate = Replace(sDate, "/", "_")
				sDate = Replace(sDate, ":", "_")
			Else
				bReportFlag = 1
			End If

            sFileName = sTestName & "_" & sDate & ".html"
            
            sResultFile = "T:\Matrix-QA\QTP-Aoutomation\QTP-RTR\QTP\RTR\Version1\Results\" & sFileName
           
            Set objFSO = CreateObject("Scripting.FileSystemObject")
            Set objFile = objFSO.CreateTextFile(sResultFile, True)

            objFile.WriteLine("<HTML>")
            objFile.WriteLine("<HEAD>")

            objFile.WriteLine("<SCRIPT language=vbscript>")
            objFile.WriteLine("Public Function fFilterByStatus()")
            objFile.WriteLine("Dim i")

            objFile.WriteLine("For i = 1 to Document.GetElementById(""tblReports"").Rows.Length")

            objFile.WriteLine("If Trim(Document.GetElementById(""lstStatus"").Value) = ""Status"" Or Trim(Document.GetElementById(""tdStatus"" & i).InnerText) = Trim(Document.GetElementById(""lstStatus"").Value) Then")
            objFile.WriteLine("Document.GetElementById(""trElement"" & i).Style.Display=""block""")
            objFile.WriteLine("Else")
            objFile.WriteLine("Document.GetElementById(""trElement"" & i).Style.Display=""none""")
            objFile.WriteLine("End If")
            objFile.WriteLine("Next")
                                                            
            objFile.WriteLine("End Function")
            objFile.WriteLine("</SCRIPT>")
            
            objFile.WriteLine("</HEAD>")

            objFile.WriteLine("<TITLE>QTP Execution Report - " & sDate & "</TITLE>")
            objFile.WriteLine("<BODY>")
            
            objFile.WriteLine("<TABLE style='FONT-FAMILY: Verdana; font-size: 11px; border-bottom: 1px solid black'>")
            objFile.WriteLine("<TR style='background-color: #607B8B; border-bottom: 1px black solid'>")
            objFile.WriteLine("<TD>")
            objFile.WriteLine("<FONT color=white>Test Name:</FONT>")
            objFile.WriteLine("</TD>")
            objFile.WriteLine("<TD>")
            objFile.WriteLine("<FONT color=white>" & sTestName & "</FONT>")
            objFile.WriteLine("</TD>")
            objFile.WriteLine("</TR>")
            objFile.WriteLine("</TABLE>")
              
            objFile.WriteLine("<TABLE width=100% style='FONT-FAMILY: Verdana; font-size: 11px; border-bottom:1px solid black; margin:0px'>")
            objFile.WriteLine("<TR style='background-color: FAEBD7; border-bottom: 1px black solid'>")
            objFile.WriteLine("<TD width=5%>")
            objFile.WriteLine("Step ID")
            objFile.WriteLine("</TD>")
            objFile.WriteLine("<TD width=10%>")
            objFile.WriteLine("Step Name")
            objFile.WriteLine("</TD>")
            objFile.WriteLine("<TD width=50%>")
            objFile.WriteLine("Step Description")
            objFile.WriteLine("</TD>")
            objFile.WriteLine("<TD width=5%>")
            objFile.WriteLine("<select id=lstStatus OnChange=""fFilterByStatus()""><option value=Status>Status</option><option value=FAIL>FAIL</option><option value=PASS>PASS</option></select>")
            objFile.WriteLine("</TD>")
            objFile.WriteLine("<TD width=30%>")
            objFile.WriteLine("Status Reason")
            objFile.WriteLine("</TD>")
            objFile.WriteLine("</TR>")
            objFile.WriteLine("<TBODY id=tblReports>")

			objFile.WriteLine("</TBODY>")
            objFile.WriteLine("</TABLE>")
            objFile.WriteLine("<BR>")
            
            objFile.WriteLine("</BODY>")
            objFile.WriteLine("</HTML>")
            objFile.Close
            
End Function
'---------------------------------------------------------------------------
'---------------------------------------------------------------------------
' Function name: fWriteHtmlReportRow
' Description: The function writes row to the HTML Report
' Parameters: sStepName, sStepDesc, sStatus, sStatusReason
'			  sStatus: "PASS"/"FAIL"/"INFO"/"HEADER"/"TITLE"
' Return value: 
' Example:
'---------------------------------------------------------------------------
Public Function fWriteHtmlReportRow(ByVal sStepName, ByVal sStepDesc, ByVal sStatus, ByVal sStatusReason, ByRef iReportFailRow)

           Dim sTr, sSaveStatus

		   sSaveStatus = sStatus
           iReportRow = iReportRow + 1


           Set objFSO = CreateObject("Scripting.FileSystemObject")
           Set objFile = objFSO.OpenTextFile(sResultFile, 1)

           sStr = objFile.ReadAll
           objFile.Close

           If sStatus = "TITLE" Then
				sTr = "<TR id=trElement" & iReportRow & " style='background-color: #236B8E; color: white; height: 25px;'>"
		   ElseIf sStatus = "TITLE2" Then
				sTr = "<TR id=trElement" & iReportRow & " style='background-color: #98AFC7'>"
		   ElseIf sStatus = "HEADER" Then
				sTr = "<TR id=trElement" & iReportRow & " style='background-color: #BCC6CC'>"
		   Else
'				If iReportRow Mod 2 = 0 Then
'							sTr = "<TR id=trElement" & iReportRow & " style='background-color: C0C0C0'>"
'				Else
							sTr = "<TR id=trElement" & iReportRow & ">"
'				End If
						iReportFailRow = "trElement" & iReportRow 'For update links in ERROR CDR's report
		   End If
           
            If sStatus = "FAIL" Then
                        sStatus = "<TD id=tdStatus" & iReportRow & " style='background-color: FF0000'>" & sStatus & "</TD>"
            ElseIf sStatus = "PASS" Then
                        sStatus = "<TD id=tdStatus" & iReportRow & " style='background-color: 00FF00'>" & sStatus & "</TD>"
			ElseIf sStatus = "INFO" Then
						sStatus = "<TD id=tdStatus" & iReportRow & " style='background-color: FFFF00'>" & sStatus & "</TD>"
			ElseIf sStatus = "HEADER"  Then'Header
						sStatus = "<TD id=tdStatus" & iReportRow & " style='background-color:'></TD>" '& sStatus & "</TD>"
			ElseIf sStatus = "TITLE" Then'Function Name header
						sStatus = "<TD id=tdStatus" & iReportRow & " style='background-color:'></TD>" '& sStatus & "</TD>"
			ElseIf sStatus = "TITLE2" Then
						sStatus = "<TD id=tdStatus" & iReportRow & " style='background-color:'></TD>" '& sStatus & "</TD>"
            End If
			
			sURL = "file:///T:/Matrix-QA/QTP-Aoutomation/QTP-RTR/QTP/RTR/Version1/Results/" & HtmlSummaryReport & "_" & sDate & ".html"

			If sSaveStatus = "" Then
				If InStr(1,sStatus,"FAIL") > 0 and bReportFlag = 0 Then
					sStr = Replace(sStr, "</TBODY>", sTr & "<TD><a href = " & sURL & "#" & 5+iReportRow & ">" & "Link to ERROR row: " & iReportRow & "</a></TD><TH>" & sStepName & "</TH><TH id=tdStatus666>" & sStepDesc & "</TH>" & sStatus & "<TD>" & sStatusReason & "</TD></TR></TBODY>")
				Else
					sStr = Replace(sStr, "</TBODY>", sTr & "<TD>" & iReportRow & "</TD><TH>" & sStepName & "</TH><TH id=tdStatus666>" & sStepDesc & "</TH>" & sStatus & "<TD>" & sStatusReason & "</TD></TR></TBODY>")
				End If
   			Else
				If InStr(1,sStatus,"FAIL") > 0 and bReportFlag = 0 Then					
					sStr = Replace(sStr, "</TBODY>", sTr & "<TD><a href = " & sURL & "#" & 5+iReportRow & ">" & iReportRow & "</a></TD><TD>" & sStepName & "</TD><TD id=tdStatus666'>" & sStepDesc & "</TD>" & sStatus & "<TD>" & sStatusReason & "</TD></TR></TBODY>")
				Else
					sStr = Replace(sStr, "</TBODY>", sTr & "<TD>" & iReportRow & "</TD><TD>" & sStepName & "</TD><TD id=tdStatus666'>" & sStepDesc & "</TD>" & sStatus & "<TD>" & sStatusReason & "</TD></TR></TBODY>")
				End If
			End If

            Set objFile = objFSO.OpenTextFile(sResultFile, 2)
            objFile.Write sStr
            objFile.Close

     End Function
'---------------------------------------------------------------------------
'---------------------------------------------------------------------------
' Function name: fGetWeekday
' Description: The function return the weekday of the sDate
' Parameters: sDate
' Return value: weekday - 0(Sun) - 6(Sut)
' Example:
'---------------------------------------------------------------------------
Function fGetWeekday(sDate)

	Dim iDay

	iDay = Weekday(datevalue(cdate(sDate)),1)
	fGetWeekday = iDay - 1

End Function
'---------------------------------------------------------------------------
'---------------------------------------------------------------------------
' Function name: fFuncSendMailReport
' Description: The function send mail report at the end of test
' Parameters: 
' Return value: 
' Example:
'---------------------------------------------------------------------------
Public Function fFuncSendMailReport(ByVal sRunDate, ByVal sURLEmailReport)
    
       Set objMessage = CreateObject("CDO.Message") 
       objMessage.From = "RTR_IP_Automation_Report" '"rtr.email.sender@gmail.com" 
       objMessage.To = GlobalDictionary("EMAIL ADDRESS") 
       objMessage.CC = GlobalDictionary("CC")
       objMessage.BCC = GlobalDictionary("BCC")
       objMessage.Subject = "RTR - Automation report" 
       objMessage.HTMLBody = "<h4>RTR - Automation report</h4>Automation runs at " & sRunDate & ".</br>Running completed. Click <a href= " & sURLEmailReport & " >Here</a> to see a summary report</br>" 'Replace by file path
    
       objMessage.Configuration.Fields.Item _ 
       ("http://schemas.microsoft.com/cdo/configuration/sendusing")=2
       
       'Name or IP of remote SMTP server 
       objMessage.Configuration.Fields.Item _ 
       ("http://schemas.microsoft.com/cdo/configuration/smtpserver")="smtp.nyc.ibasis.net"
       
       objMessage.Configuration.Fields.Item _ 
       ("http://schemas.microsoft.com/cdo/configuration/smtpserverport")=25 

       objMessage.Configuration.Fields.Update

       objMessage.Send
End Function
'---------------------------------------------------------------------------
