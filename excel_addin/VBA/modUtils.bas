Attribute VB_Name = "modUtils"
Option Explicit

Public Function Nz(ByVal v As Variant, Optional ByVal fallback As Variant = "") As Variant
    If IsError(v) Then
        Nz = fallback
    ElseIf IsNull(v) Or IsEmpty(v) Then
        Nz = fallback
    ElseIf Trim$(CStr(v)) = "" Then
        Nz = fallback
    Else
        Nz = v
    End If
End Function

Public Function SafeDate(ByVal v As Variant) As Date
    If IsDate(v) Then
        SafeDate = CDate(v)
    Else
        SafeDate = Date
    End If
End Function

Public Function MaxDate(ByVal a As Date, ByVal b As Date) As Date
    If a >= b Then
        MaxDate = a
    Else
        MaxDate = b
    End If
End Function

Public Function MinDate(ByVal a As Date, ByVal b As Date) As Date
    If a <= b Then
        MinDate = a
    Else
        MinDate = b
    End If
End Function
