Option Explicit

 Public Sub test()
 Dim ws As Worksheet
 Dim output_ws As Worksheet
 Dim i As Integer
 Dim output_row As Integer
    Set ws = ThisWorkbook.Worksheets("R")
    Set output_ws = ThisWorkbook.Worksheets("output_R")
    output_row = 1
    For i = 1000 To 2 Step -1
        If Right(ws.Cells(i, 1).Value, 3) = "欠測数" Then
            ws.Rows(i).Delete
        End If
        If Left(ws.Cells(i, 1).Value, 2) = "n=" Then
            ws.Rows(i).Delete
        End If
    Next i
    output_ws.Cells.Clear
    For i = 6 To 1000
        If ws.Cells(i, 1).Font.Size = 30 Or ws.Cells(i, 1).Font.Size = 24 Then
            output_row = output_row + 1
            output_ws.Cells(output_row, 1).Value = ws.Cells(i, 1).Value
        ElseIf ws.Cells(i, 2).Value = "sp_count" Then
        Else
            Select Case ws.Cells(i, 1).Value
            Case "sp_例数"
                If ws.Cells(i + 3, 1).Value = "Mean" Then
                    output_ws.Cells(output_row, 2).Value = "N"
                    output_ws.Cells(output_row, 3).Value = ws.Cells(i, 2).Value
                    output_ws.Cells(output_row, 4).Value = "."
                    output_ws.Cells(output_row, 5).Value = ws.Cells(i + 1, 2).Value
                    output_ws.Cells(output_row, 6).Value = "."
                End If
            Case "", "mr_例数"
            Case "Mean", "Sd.", "Median", "1st Qu.", "3rd Qu.", "Min.", "Max."
                output_row = output_row + 1
                output_ws.Cells(output_row, 2).Value = ws.Cells(i, 1).Value
                output_ws.Cells(output_row, 3).Value = ws.Cells(i, 2).Value
                output_ws.Cells(output_row, 4).Value = "."
                output_ws.Cells(output_row, 5).Value = ws.Cells(i, 3).Value
                output_ws.Cells(output_row, 6).Value = "."
            Case Else
                If ws.Cells(i - 1, 2).Value <> "sp_count" Then
                    output_row = output_row + 1
                End If
                output_ws.Cells(output_row, 2).Value = ws.Cells(i, 1).Value
                output_ws.Cells(output_row, 3).Value = ws.Cells(i, 2).Value
                output_ws.Cells(output_row, 4).Value = ws.Cells(i, 3).Value
                output_ws.Cells(output_row, 5).Value = ws.Cells(i, 4).Value
                output_ws.Cells(output_row, 6).Value = ws.Cells(i, 5).Value
            End Select
        End If
    Next i
    For i = 1 To 1000
        If output_ws.Cells(i, 2).Value = "Sd." Then
            output_ws.Cells(i, 2).Value = "STD"
        End If
        If output_ws.Cells(i, 2).Value = "1st Qu." Then
            output_ws.Cells(i, 2).Value = "Q1"
        End If
        If output_ws.Cells(i, 2).Value = "3rd Qu." Then
            output_ws.Cells(i, 2).Value = "Q3"
        End If
        If output_ws.Cells(i, 2).Value = "Min." Then
            output_ws.Cells(i, 2).Value = "MIN"
        End If
        If output_ws.Cells(i, 2).Value = "Max." Then
            output_ws.Cells(i, 2).Value = "MAX"
        End If
    Next i
    For i = 1000 To 2 Step -1
        If output_ws.Cells(i, 2).Value = "" Then
            output_ws.Rows(i).Delete
        End If
    Next i
    For i = 1 To 300
        If output_ws.Cells(i, 1).Value = "オペレータ(S、O)" Then
            output_ws.Cells(i, 1).Value = "オペレータ"
        End If
        If output_ws.Cells(i, 1).Value = "陽圧呼吸による実際のアシストの回数" Then
            output_ws.Cells(i, 1).Value = "陽圧呼吸によるアシストの回数"
        End If
        output_ws.Cells(i, 1).Value = Replace(output_ws.Cells(i, 1).Value, " ", "")
    Next i
 End Sub

