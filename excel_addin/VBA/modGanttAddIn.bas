Attribute VB_Name = "modGanttAddIn"
Option Explicit

Private Const SHEET_PROJECTS As String = "Projects"
Private Const SHEET_TASKS As String = "Tasks"
Private Const SHEET_RESOURCES As String = "Resources"
Private Const SHEET_CONSOLIDATED As String = "Consolidated"
Private Const SHEET_REPORT As String = "Report"

Public Sub InitializeWorkbook()
    CreateOrResetSheet SHEET_PROJECTS
    CreateOrResetSheet SHEET_TASKS
    CreateOrResetSheet SHEET_RESOURCES
    CreateOrResetSheet SHEET_CONSOLIDATED
    CreateOrResetSheet SHEET_REPORT

    SetupProjectsSheet
    SetupTasksSheet
    SetupResourcesSheet

    MsgBox "Workbook initialized. Populate Projects/Tasks/Resources then run BuildConsolidatedView.", vbInformation
End Sub

Public Sub BuildConsolidatedView()
    Dim wsTasks As Worksheet, wsCons As Worksheet
    Dim lastRow As Long, outRow As Long, i As Long

    Set wsTasks = ThisWorkbook.Worksheets(SHEET_TASKS)
    Set wsCons = ThisWorkbook.Worksheets(SHEET_CONSOLIDATED)

    wsCons.Cells.Clear
    wsCons.Range("A1:M1").Value = Array("ProjectID", "WBS", "TaskName", "Level", "StartDate", "EndDate", "%Complete", "Status", "ResourceGroup", "Person", "EffortHours", "BaselineStart", "BaselineEnd")

    lastRow = wsTasks.Cells(wsTasks.Rows.Count, "A").End(xlUp).Row
    outRow = 2

    For i = 2 To lastRow
        If Trim$(CStr(wsTasks.Cells(i, "A").Value)) <> "" Then
            wsCons.Cells(outRow, "A").Value = wsTasks.Cells(i, "A").Value
            wsCons.Cells(outRow, "B").Value = wsTasks.Cells(i, "D").Value
            wsCons.Cells(outRow, "C").Value = wsTasks.Cells(i, "E").Value
            wsCons.Cells(outRow, "D").Value = wsTasks.Cells(i, "F").Value
            wsCons.Cells(outRow, "E").Value = wsTasks.Cells(i, "G").Value
            wsCons.Cells(outRow, "F").Value = wsTasks.Cells(i, "H").Value
            wsCons.Cells(outRow, "G").Value = wsTasks.Cells(i, "I").Value
            wsCons.Cells(outRow, "H").Value = wsTasks.Cells(i, "J").Value
            wsCons.Cells(outRow, "I").Value = wsTasks.Cells(i, "K").Value
            wsCons.Cells(outRow, "J").Value = wsTasks.Cells(i, "L").Value
            wsCons.Cells(outRow, "K").Value = wsTasks.Cells(i, "M").Value
            wsCons.Cells(outRow, "L").Value = wsTasks.Cells(i, "N").Value
            wsCons.Cells(outRow, "M").Value = wsTasks.Cells(i, "O").Value
            outRow = outRow + 1
        End If
    Next i

    wsCons.Columns.AutoFit
    wsCons.Rows(1).Font.Bold = True
    MsgBox "Consolidated sheet refreshed.", vbInformation
End Sub

Public Sub RenderGantt(Optional ByVal scaleMode As String = "Month")
    Dim ws As Worksheet
    Dim lastRow As Long, r As Long
    Dim minStart As Date, maxEnd As Date
    Dim c As Long, curDate As Date
    Dim stepDays As Long

    Set ws = ThisWorkbook.Worksheets(SHEET_CONSOLIDATED)
    lastRow = ws.Cells(ws.Rows.Count, "A").End(xlUp).Row
    If lastRow < 2 Then
        MsgBox "No consolidated tasks found.", vbExclamation
        Exit Sub
    End If

    minStart = ws.Cells(2, "E").Value
    maxEnd = ws.Cells(2, "F").Value

    For r = 2 To lastRow
        minStart = MinDate(minStart, SafeDate(ws.Cells(r, "E").Value))
        maxEnd = MaxDate(maxEnd, SafeDate(ws.Cells(r, "F").Value))
    Next r

    If LCase$(scaleMode) = "day" Then
        stepDays = 1
    ElseIf LCase$(scaleMode) = "week" Then
        stepDays = 7
    Else
        stepDays = 30
    End If

    ws.Range("N:ZZ").Clear
    c = 14
    curDate = minStart

    Do While curDate <= maxEnd
        ws.Cells(1, c).Value = curDate
        ws.Cells(1, c).NumberFormat = "yyyy-mm-dd"
        curDate = DateAdd("d", stepDays, curDate)
        c = c + 1
    Loop

    Dim startTask As Date, endTask As Date
    Dim dCol As Long

    For r = 2 To lastRow
        startTask = SafeDate(ws.Cells(r, "E").Value)
        endTask = SafeDate(ws.Cells(r, "F").Value)
        For dCol = 14 To c - 1
            curDate = ws.Cells(1, dCol).Value
            If curDate >= startTask And curDate <= endTask Then
                ws.Cells(r, dCol).Interior.Color = RGB(68, 114, 196)
            End If
        Next dCol

        Select Case CLng(Nz(ws.Cells(r, "D").Value, 1))
            Case 1
                ws.Cells(r, "C").Font.Bold = True
            Case 2
                ws.Cells(r, "C").IndentLevel = 1
            Case 3
                ws.Cells(r, "C").IndentLevel = 2
        End Select
    Next r

    ws.Rows(1).Font.Bold = True
    ws.Columns("A:M").AutoFit
    MsgBox "Gantt rendered using " & scaleMode & " scale.", vbInformation
End Sub

Private Sub CreateOrResetSheet(ByVal sheetName As String)
    On Error Resume Next
    Dim ws As Worksheet
    Set ws = ThisWorkbook.Worksheets(sheetName)
    On Error GoTo 0

    If ws Is Nothing Then
        Set ws = ThisWorkbook.Worksheets.Add(After:=ThisWorkbook.Worksheets(ThisWorkbook.Worksheets.Count))
        ws.Name = sheetName
    Else
        ws.Cells.Clear
    End If
End Sub

Private Sub SetupProjectsSheet()
    Dim ws As Worksheet
    Set ws = ThisWorkbook.Worksheets(SHEET_PROJECTS)
    ws.Range("A1:F1").Value = Array("ProjectID", "ProjectName", "Owner", "StartDate", "EndDate", "Status")
    ws.Rows(1).Font.Bold = True
    ws.Columns.AutoFit
End Sub

Private Sub SetupTasksSheet()
    Dim ws As Worksheet
    Set ws = ThisWorkbook.Worksheets(SHEET_TASKS)
    ws.Range("A1:O1").Value = Array("ProjectID", "TaskID", "ParentTaskID", "WBS", "TaskName", "Level", "StartDate", "EndDate", "%Complete", "Status", "ResourceGroup", "Person", "EffortHours", "BaselineStart", "BaselineEnd")
    ws.Rows(1).Font.Bold = True
    ws.Columns.AutoFit
End Sub

Private Sub SetupResourcesSheet()
    Dim ws As Worksheet
    Set ws = ThisWorkbook.Worksheets(SHEET_RESOURCES)
    ws.Range("A1:D1").Value = Array("ResourceGroup", "Person", "CapacityHoursPerWeek", "CostRate")
    ws.Rows(1).Font.Bold = True
    ws.Columns.AutoFit
End Sub
