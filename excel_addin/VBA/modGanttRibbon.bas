Attribute VB_Name = "modGanttRibbon"
Option Explicit

Public Sub RunDayScale()
    RenderGantt "Day"
End Sub

Public Sub RunWeekScale()
    RenderGantt "Week"
End Sub

Public Sub RunMonthScale()
    RenderGantt "Month"
End Sub
