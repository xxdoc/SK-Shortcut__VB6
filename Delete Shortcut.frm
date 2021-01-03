VERSION 5.00
Begin VB.Form DeleteShortcut 
   BorderStyle     =   1  'Fixed Single
   Caption         =   "Send Selected file to the Recycle Bin (*.lnk *.pif *.url only)"
   ClientHeight    =   3210
   ClientLeft      =   3855
   ClientTop       =   1755
   ClientWidth     =   5625
   Icon            =   "Delete Shortcut.frx":0000
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   Moveable        =   0   'False
   PaletteMode     =   1  'UseZOrder
   ScaleHeight     =   3210
   ScaleWidth      =   5625
   StartUpPosition =   2  'CenterScreen
   Begin VB.Frame Frame1 
      Height          =   3195
      Left            =   3800
      TabIndex        =   2
      Top             =   -60
      Width           =   1815
      Begin VB.CommandButton Command1 
         Caption         =   "Delete to the &Recycle Bin"
         Height          =   495
         Left            =   120
         OLEDropMode     =   1  'Manual
         TabIndex        =   8
         ToolTipText     =   "Send to Recycle Bin"
         Top             =   240
         Width           =   1575
      End
      Begin VB.CommandButton cmdExit 
         Caption         =   "&Close"
         Height          =   375
         Left            =   120
         TabIndex        =   7
         ToolTipText     =   "Close delete window"
         Top             =   2760
         Width           =   1575
      End
      Begin VB.PictureBox Picture1 
         AutoSize        =   -1  'True
         Height          =   540
         Left            =   1080
         Picture         =   "Delete Shortcut.frx":0442
         ScaleHeight     =   480
         ScaleWidth      =   480
         TabIndex        =   6
         ToolTipText     =   "Send to Recycle Bin"
         Top             =   795
         Width           =   540
      End
      Begin VB.CommandButton cmdShortcutPathDialog 
         Caption         =   "&Browse for Shortcut"
         Height          =   375
         Left            =   120
         TabIndex        =   5
         ToolTipText     =   "Browse"
         Top             =   2160
         Width           =   1575
      End
      Begin VB.PictureBox Picture3 
         AutoSize        =   -1  'True
         Height          =   540
         Left            =   240
         Picture         =   "Delete Shortcut.frx":0884
         ScaleHeight     =   480
         ScaleWidth      =   480
         TabIndex        =   4
         ToolTipText     =   "Click to Delete"
         Top             =   795
         Width           =   540
      End
      Begin VB.CommandButton Command2 
         Caption         =   "&Delete without Recycle bin"
         Default         =   -1  'True
         Height          =   495
         Left            =   120
         OLEDropMode     =   1  'Manual
         TabIndex        =   3
         ToolTipText     =   "Click to Delete"
         Top             =   1470
         Width           =   1575
      End
   End
   Begin VB.Timer Timer1 
      Enabled         =   0   'False
      Interval        =   1
      Left            =   840
      Top             =   1560
   End
   Begin VB.PictureBox Picture2 
      AutoSize        =   -1  'True
      Height          =   540
      Left            =   120
      Picture         =   "Delete Shortcut.frx":114E
      ScaleHeight     =   480
      ScaleWidth      =   480
      TabIndex        =   1
      Top             =   3720
      Width           =   540
   End
   Begin VB.FileListBox File1 
      DragIcon        =   "Delete Shortcut.frx":1590
      Height          =   3210
      Left            =   0
      MultiSelect     =   2  'Extended
      OLEDragMode     =   1  'Automatic
      OLEDropMode     =   1  'Manual
      Pattern         =   "*.lnk;*.pif;*.url"
      TabIndex        =   0
      ToolTipText     =   "You can drag and Drop the specified file into the Recycle Bin as well"
      Top             =   0
      Width           =   3735
   End
End
Attribute VB_Name = "DeleteShortcut"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit
Dim iGrabX As Integer
Dim iGrabY As Integer
Dim ControlZOrder As Long

Private Type SHFILEOPSTRUCT
     hwnd As Long
     wFunc As Long
     pFrom As String
     pTo As String
     fFlags As Integer
     fAnyOperationsAborted As Boolean
     hNameMappings As Long
     lpszProgressTitle As String
End Type

Private Declare Function SHFileOperation Lib "shell32.dll" Alias "SHFileOperationA" (lpFileOp As SHFILEOPSTRUCT) As Long

Private Const FO_DELETE = &H3
Private Const FOF_ALLOWUNDO = &H40

Private Sub cmdExit_Click()
Unload Me
End Sub

Private Sub cmdShortcutPathDialog_Click()
Dim udtBrowseInfo As BROWSEINFO
Dim lRet As Long
Dim lPathID As Long
Dim sPath As String
Dim nNullPos As Integer

File1.SetFocus

'Specify the window handle for the owner of the dialog box
udtBrowseInfo.hOwner = Me.hwnd

'Specify the root to start browsing from;
'if null, My Computer is the root
udtBrowseInfo.pidlRoot = 0&

'Specify a title.  This is not the caption of the dialog.  Useful for
'adding any kind of additional information or instructions
udtBrowseInfo.lpszTitle = "Select a folder"

'Specify any flags; See Declarations section
udtBrowseInfo.ulFlags = BIF_RETURNONLYFSDIRS

'Call the function.
'The return value is a pointer to an item identifier list that
'specifies the location of the selected folder.
'If the user cancels the dialog box, the return value is 0.
lPathID = SHBrowseForFolder(udtBrowseInfo)

sPath = Space$(512)
lRet = SHGetPathFromIDList(lPathID, sPath)

If lRet Then
    nNullPos = InStr(sPath, vbNullChar)
    File1 = Left(sPath, nNullPos - 1)
End If

End Sub

Private Sub Command1_Click()
Dim FileOperation As SHFILEOPSTRUCT
Dim lReturn As Long

If File1.ListIndex = -1 Then
    MsgBox "Are you sure you want to delete this file", vbOKCancel + vbQuestion, "Delete"
    File1.SetFocus
End If
    If vbOK Then
    Picture1.Picture = Picture2.Picture
    DeleteShortcut.Icon = Picture2.Picture
    Else
    If vbCancel Then
    Exit Sub
End If
End If


With FileOperation
    .wFunc = FO_DELETE
    .pFrom = File1.Path & "\" & File1.List(File1.ListIndex)     'fichier sélectionné dans la liste
    .fFlags = FOF_ALLOWUNDO
End With

lReturn = SHFileOperation(FileOperation)

Timer1.Enabled = True

End Sub

Private Sub Command1_DragDrop(Source As Control, X As Single, Y As Single)
Command1_Click
Timer1.Enabled = True

End Sub

Private Sub Command2_Click()
Kill File1.Path & "\" & File1.List(File1.ListIndex)
Timer1.Enabled = True
End Sub

Private Sub Form_Load()
DeleteShortcut.Icon = Picture1
File1.Path = App.Path
End Sub

Private Sub Picture1_DblClick()
Dim FileOperation As SHFILEOPSTRUCT
    FileOperation.fFlags = FOF_ALLOWUNDO

End Sub

Private Sub Picture1_DragDrop(Source As Control, X As Single, Y As Single)
Command1_Click
Timer1.Enabled = True

End Sub

Private Sub File1_OLEDragDrop(Data As DataObject, Effect As Long, Button As Integer, Shift As Integer, X As Single, Y As Single)
'control was dropped somewhere so move it to the point where it was dropped and offset it by the coordinates within the control where you are dragging
File1.Move File1.Left + X - iGrabX, File1.Top + Y - iGrabY
End Sub
Private Sub File1_MouseDown(Button As Integer, Shift As Integer, X As Single, Y As Single)
If Button = vbLeftButton Then
    'remember what part of the control you are dragging by
    iGrabX = X
    iGrabY = Y
    
    'begin dragging the control
    File1.Drag vbBeginDrag
Else
    ControlZOrder = File1.hwnd
End If
End Sub
Private Sub File1_MouseUp(Button As Integer, Shift As Integer, X As Single, Y As Single)
If Button = vbLeftButton Then
    'mouse button released so stop dragging
    File1.Drag vbEndDrag
End If
End Sub

Private Sub Picture3_Click()
Command2_Click
Timer1.Enabled = True
End Sub

Private Sub Timer1_Timer()
      File1.Refresh
      Timer1.Enabled = False
End Sub
