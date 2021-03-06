VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "CCMail"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
' Class Custom Mail for SmartApp
Option Explicit

Private Outlook As Object
Private Mail As Object
Private recipent As String ' mattias / edgar
Private subject As String
Private body As String
Private errlistrow As Integer
Private mType As Integer
' Multiple arrays for errors becase cannot foreach loop multidimensional array
' Can have list of thousand errors. If exceeding that, CCMail will fail probably
Private ObjectList(0 To 1000) As String
Private ModuleList(0 To 1000) As String
Private ErrMsgList(0 To 1000) As String
Private ErrCodeList(0 To 1000) As String
Private ErrSourceList(0 To 1000) As String
Private SAPStatusMsgList(0 To 1000) As String
Private hasErrorList As Boolean ' kolla om det blir fel!!

Public Enum mailType
    CErrorReport = 1
    CStatsCannotBeWritten = 2
End Enum

' called in sub SendMail - initializing outlook and setting content.
Private Sub PrepareForSend()
    Set Outlook = CreateObject("Outlook.Application")
    Set Mail = Outlook.Createitem(0)
    SetContent ' parameter recipent
    Mail.subject = subject
    Mail.body = body
    If GetEmailOption = "Yes" Then
    recipent = "eedgcan; qolsmat; " & Environ("Username")
    Else
    recipent = "eedgcan; qolsmat; "
    End If
    Mail.To = recipent
End Sub

' Must be called manually before SendMail. Sets content (error report list or fail to write statistics report enum)
Public Sub Init(ByVal ErrorType As Integer)
    mType = ErrorType
    ObjectList(0) = "Object: " & vbTab
    ModuleList(0) = "Module: " & vbTab
    ErrMsgList(0) = "Error message: " & vbTab
    ErrCodeList(0) = "Error code: " & vbTab
    ErrSourceList(0) = "Source: " & vbTab
    SAPStatusMsgList(0) = "SAP Statusbar: "
    errlistrow = errlistrow + 1
    hasErrorList = False
End Sub

' "Constructor"
Private Sub Class_Initialize()
    Debug.Print "Mail Class initiated"
End Sub

' Set content of mail. Calling sub to get error list.
Private Sub SetContent(Optional ByVal modulename As String, Optional ByVal obj As String)
    Select Case (mType)
        Case CErrorReport
            subject = "Auto error report from PFM SmartApp"
            body = "The following objects have generated errors: " & vbNewLine & vbNewLine & _
                        GetErrorList & vbNewLine & _
                        "This mail has been generated by PFM SmartApp Version " & "4." & Format(FileDateTime("C:\Users\" & Environ("Username") & "\AppData\Roaming\Microsoft\AddIns\PFM_SmartApp.xlam"), "YYMMDDHHSS") & " by user " & Application.UserName & " on " & WeekdayName(Weekday(Now, vbMonday)) & ", " & Format(Now(), "yyyy-mm-dd hh:mm", vbMonday)
        Case CStatsCannotBeWritten
            subject = "Statistics cannot be written to file"
            body = Application.UserName & " is trying to update the statistics file but it is not possible." & vbNewLine & _
                        "/ PFM SmartApp"
    End Select
End Sub

' For every error there is, add the error to the error arrays. Parameters for all error information
Public Function BuildErrorList(ByVal obj As String, ByVal module As String, ByVal errcode As String, ByVal errmsg As String, ByVal errsource As String, ByVal sapstatus As String)
    hasErrorList = True
    ObjectList(errlistrow) = obj
    ModuleList(errlistrow) = module
    ErrCodeList(errlistrow) = errcode
    ErrMsgList(errlistrow) = errmsg
    ErrSourceList(errlistrow) = errsource
    SAPStatusMsgList(errlistrow) = sapstatus
    
    errlistrow = errlistrow + 1
End Function

' Build a string for the error information, gets called in sub SetContent.
Private Function GetErrorList()
    Dim i As Integer
    Dim ErrorString As String
    For i = 0 To errlistrow - 1
        ErrorString = ErrorString & ObjectList(i) & " | " & _
                                    ModuleList(i) & " | " & _
                                    ErrCodeList(i) & " | " & _
                                    ErrMsgList(i) & " | " & _
                                    ErrSourceList(i) & " | " & _
                                    SAPStatusMsgList(i) & vbNewLine
    Next i
    GetErrorList = ErrorString
End Function

' Send the mail.
Public Sub SendMail()
    PrepareForSend
    Mail.Send
End Sub

' Check if the class have got any errors reported for error list. If false, do not send the mail.
Public Function CheckIfErrorListExists() As Boolean
    CheckIfErrorListExists = hasErrorList
End Function

' Comments

'        Case CCrashReport ' redundant because SmartApp cant send if already crashed
'            subject = "Auto crash report from PFM SmartApp"
'            body = "The macro has crashed at " & obj & " in module " & modulename & "." & vbNewLine & _
'                        "/ PFM SmartApp"
