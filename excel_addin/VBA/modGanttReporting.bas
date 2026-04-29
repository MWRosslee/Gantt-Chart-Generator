Attribute VB_Name = "modGanttReporting"
Option Explicit

Public Sub CreateStatusReport()
    Dim wsCons As Worksheet, wsReport As Worksheet
    Dim lastRow As Long, i As Long, outRow As Long
    Dim dict As Object
    Dim key As Variant

    Set wsCons = ThisWorkbook.Worksheets("Consolidated")
    Set wsReport = ThisWorkbook.Worksheets("Report")
    Set dict = CreateObject("Scripting.Dictionary")

    wsReport.Cells.Clear
    wsReport.Range("A1:D1").Value = Array("ProjectID", "Task Count", "Avg %Complete", "Open Tasks")

    lastRow = wsCons.Cells(wsCons.Rows.Count, "A").End(xlUp).Row
    For i = 2 To lastRow
        If Trim$(CStr(wsCons.Cells(i, "A").Value)) <> "" Then
            key = CStr(wsCons.Cells(i, "A").Value)
            If Not dict.Exists(key) Then
                dict.Add key, Array(0, 0#, 0)
            End If
            Dim m
            m = dict(key)
            m(0) = CLng(m(0)) + 1
            m(1) = CDbl(m(1)) + CDbl(Nz(wsCons.Cells(i, "G").Value, 0))
            If LCase$(CStr(Nz(wsCons.Cells(i, "H").Value, "open"))) <> "closed" Then
                m(2) = CLng(m(2)) + 1
            End If
            dict(key) = m
        End If
    Next i

    outRow = 2
    For Each key In dict.Keys
        Dim v
        v = dict(key)
        wsReport.Cells(outRow, "A").Value = key
        wsReport.Cells(outRow, "B").Value = v(0)
        If v(0) > 0 Then
            wsReport.Cells(outRow, "C").Value = Round(v(1) / v(0), 2)
        Else
            wsReport.Cells(outRow, "C").Value = 0
        End If
        wsReport.Cells(outRow, "D").Value = v(2)
        outRow = outRow + 1
    Next key

    wsReport.Columns.AutoFit
    wsReport.Rows(1).Font.Bold = True
    MsgBox "Status report refreshed.", vbInformation
End Sub

Public Sub ResourceLoadReport()
    Dim wsCons As Worksheet, wsReport As Worksheet
    Dim lastRow As Long, i As Long, outRow As Long
    Dim dict As Object, key As String

    Set wsCons = ThisWorkbook.Worksheets("Consolidated")
    Set wsReport = ThisWorkbook.Worksheets("Report")
    Set dict = CreateObject("Scripting.Dictionary")

    wsReport.Cells.Clear
    wsReport.Range("A1:C1").Value = Array("Person", "Total Effort Hours", "Task Count")

    lastRow = wsCons.Cells(wsCons.Rows.Count, "A").End(xlUp).Row
    For i = 2 To lastRow
        key = CStr(Nz(wsCons.Cells(i, "J").Value, "Unassigned"))
        If Not dict.Exists(key) Then
            dict.Add key, Array(0#, 0)
        End If

        Dim v
        v = dict(key)
        v(0) = CDbl(v(0)) + CDbl(Nz(wsCons.Cells(i, "K").Value, 0))
        v(1) = CLng(v(1)) + 1
        dict(key) = v
    Next i

    outRow = 2
    Dim person As Variant
    For Each person In dict.Keys
        Dim p
        p = dict(person)
        wsReport.Cells(outRow, "A").Value = person
        wsReport.Cells(outRow, "B").Value = p(0)
        wsReport.Cells(outRow, "C").Value = p(1)
        outRow = outRow + 1
    Next person

    wsReport.Columns.AutoFit
    wsReport.Rows(1).Font.Bold = True
    MsgBox "Resource load report refreshed.", vbInformation
End Sub
