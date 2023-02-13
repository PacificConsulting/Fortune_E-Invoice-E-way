reportextension 50099 TrialBal_Ext extends "Trial Balance"
{
    dataset
    {
        modify("G/L Account")
        {
            trigger OnAfterAfterGetRecord()
            begin

                IF ("G/L Account"."Account Type" = "G/L Account"."Account Type"::Posting) THEN BEGIN
                    IF "Balance at Date" > 0 THEN
                        TotalDebitBalanceAtDateNew := TotalDebitBalanceAtDateNew + "G/L Account"."Balance at Date"
                    ELSE
                        TotalCreditBalanceAtDateNew := TotalCreditBalanceAtDateNew - "G/L Account"."Balance at Date";
                    IF "Net Change" > 0 THEN
                        TotalDebitNetChangeNew := TotalDebitNetChangeNew + "G/L Account"."Net Change"
                    ELSE
                        TotalCreditNetChangeNew := TotalCreditNetChangeNew - "G/L Account"."Net Change";
                END;

                IF PrintToExcel THEN
                    MakeExcelDataBody;
            end;

            trigger OnAfterPostDataItem()
            begin
                IF PrintToExcel THEN BEGIN
                    ExcelBuf.NewRow;
                    ExcelBuf.AddColumn('TOTALS', FALSE, '', TRUE,
                      FALSE, FALSE, '', ExcelBuf."Cell Type"::Text);
                    ExcelBuf.AddColumn('', FALSE, '', TRUE,
                      FALSE, FALSE, '', ExcelBuf."Cell Type"::Text);
                    ExcelBuf.AddColumn(TotalDebitNetChangeNew, FALSE, '', TRUE,
                      FALSE, FALSE, '', ExcelBuf."Cell Type"::Number);
                    ExcelBuf.AddColumn(TotalCreditNetChangeNew, FALSE, '', TRUE,
                      FALSE, FALSE, '', ExcelBuf."Cell Type"::Number);
                    ExcelBuf.AddColumn(TotalDebitBalanceAtDateNew, FALSE, '', TRUE,
                      FALSE, FALSE, '', ExcelBuf."Cell Type"::Number);
                    ExcelBuf.AddColumn(TotalCreditBalanceAtDateNew, FALSE, '', TRUE,
                      FALSE, FALSE, '', ExcelBuf."Cell Type"::Number);
                END;

            end;

        }

    }

    requestpage
    {

    }

    labels
    {
    }

    trigger OnPreReport()
    begin
        PrintToExcel := true;
        IF PrintToExcel THEN
            MakeExcelInfo;
    end;

    trigger OnPostReport()
    begin
        IF PrintToExcel THEN
            CreateExcelbook;

        Message('Excel Generated.....');
    end;

    var

        ExcelBuf: Record 370 temporary;
        PrintToExcel: Boolean;
        Text001: TextConst ENU = 'Trial Balance', ENN = 'Trial Balance';
        Text003: TextConst ENU = 'Debit', ENN = 'Debit';
        Text004: TextConst ENU = 'Credit', ENN = 'Credit';
        Text005: TextConst ENU = 'Company Name', ENN = 'Company Name';
        Text006: TextConst ENU = 'Report No.', ENN = 'Report No.';
        Text007: TextConst ENU = 'Report Name', ENN = 'Report Name';
        Text008: TextConst ENU = 'User ID', ENN = 'User ID';
        Text009: TextConst ENU = 'Date', ENN = 'Date';
        Text010: TextConst ENU = 'G/L Filter', ENN = 'G/L Filter';
        Text011: TextConst ENU = 'Period Filter', ENN = 'Period Filter';
        TotalDebitNetChange: Decimal;
        TotalCreditNetChange: Decimal;
        TotalDebitBalanceAtDate: Decimal;
        TotalCreditBalanceAtDate: Decimal;
        TotalDebitNetChangeNew: Decimal;
        TotalCreditNetChangeNew: Decimal;
        TotalDebitBalanceAtDateNew: Decimal;
        TotalCreditBalanceAtDateNew: Decimal;
        NewTotalDebitNetChange: Decimal;
        NewTotalCreditNetChange: Decimal;
        NewTotalDebitBalanceAtDate: Decimal;
        NewTotalCreditBalanceAtDate: Decimal;
        GroupNum: Integer;
        LastNewPage: Boolean;

    procedure MakeExcelInfo();
    begin
        ExcelBuf.SetUseInfoSheet;
        ExcelBuf.AddInfoColumn(FORMAT(Text005), FALSE, TRUE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddInfoColumn(COMPANYNAME, FALSE, FALSE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.NewRow;
        ExcelBuf.AddInfoColumn(FORMAT(Text007), FALSE, TRUE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddInfoColumn(FORMAT(Text001), FALSE, FALSE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.NewRow;
        ExcelBuf.AddInfoColumn(FORMAT(Text006), FALSE, TRUE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text);
        //ExcelBuf.AddInfoColumn(REPORT::"Trial Balance", FALSE, FALSE, FALSE, FALSE,'', ExcelBuf."Cell Type"::Number);
        ExcelBuf.NewRow;
        ExcelBuf.AddInfoColumn(FORMAT(Text008), FALSE, TRUE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddInfoColumn(USERID, FALSE, FALSE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.NewRow;
        ExcelBuf.AddInfoColumn(FORMAT(Text009), FALSE, TRUE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddInfoColumn(TODAY, FALSE, FALSE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Date);
        ExcelBuf.NewRow;
        ExcelBuf.AddInfoColumn(FORMAT(Text010), FALSE, TRUE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddInfoColumn("G/L Account".GETFILTER("No."), FALSE, FALSE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.NewRow;
        ExcelBuf.AddInfoColumn(FORMAT(Text011), FALSE, TRUE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddInfoColumn("G/L Account".GETFILTER("Date Filter"), FALSE, FALSE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.ClearNewRow;
        MakeExcelDataHeader;
    end;

    local procedure MakeExcelDataHeader();
    begin
        ExcelBuf.AddColumn("G/L Account".FIELDCAPTION("No."), FALSE, '', TRUE, FALSE, TRUE, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn("G/L Account".FIELDCAPTION(Name), FALSE, '', TRUE, FALSE, TRUE, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn(
          FORMAT("G/L Account".FIELDCAPTION("Net Change") + ' - ' + Text003), FALSE, '', TRUE, FALSE, TRUE, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn(
          FORMAT("G/L Account".FIELDCAPTION("Net Change") + ' - ' + Text004), FALSE, '', TRUE, FALSE, TRUE, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn(
          FORMAT("G/L Account".FIELDCAPTION("Balance at Date") + ' - ' + Text003), FALSE, '', TRUE, FALSE, TRUE, '',
          ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn(
          FORMAT("G/L Account".FIELDCAPTION("Balance at Date") + ' - ' + Text004), FALSE, '', TRUE, FALSE, TRUE, '',
          ExcelBuf."Cell Type"::Text);
    end;

    procedure MakeExcelDataBody();
    var
        BlankFiller: Text[250];
    begin
        BlankFiller := PADSTR(' ', MAXSTRLEN(BlankFiller), ' ');
        ExcelBuf.NewRow;
        ExcelBuf.AddColumn(
          "G/L Account"."No.", FALSE, '', "G/L Account"."Account Type" <> "G/L Account"."Account Type"::Posting, FALSE, FALSE, '',
          ExcelBuf."Cell Type"::Text);
        IF "G/L Account".Indentation = 0 THEN
            ExcelBuf.AddColumn(
              "G/L Account".Name, FALSE, '', "G/L Account"."Account Type" <> "G/L Account"."Account Type"::Posting, FALSE, FALSE, '',
              ExcelBuf."Cell Type"::Text)
        ELSE
            ExcelBuf.AddColumn(
              COPYSTR(BlankFiller, 1, 2 * "G/L Account".Indentation) + "G/L Account".Name,
              FALSE, '', "G/L Account"."Account Type" <> "G/L Account"."Account Type"::Posting, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text);

        CASE TRUE OF
            "G/L Account"."Net Change" = 0:
                BEGIN
                    ExcelBuf.AddColumn(
                      '', FALSE, '', "G/L Account"."Account Type" <> "G/L Account"."Account Type"::Posting, FALSE, FALSE, '',
                      ExcelBuf."Cell Type"::Text);
                    ExcelBuf.AddColumn(
                      '', FALSE, '', "G/L Account"."Account Type" <> "G/L Account"."Account Type"::Posting, FALSE, FALSE, '',
                      ExcelBuf."Cell Type"::Text);
                END;
            "G/L Account"."Net Change" > 0:
                BEGIN
                    ExcelBuf.AddColumn(
                      "G/L Account"."Net Change", FALSE, '', "G/L Account"."Account Type" <> "G/L Account"."Account Type"::Posting,
                      FALSE, FALSE, '#,##0.00', ExcelBuf."Cell Type"::Number);
                    ExcelBuf.AddColumn(
                      '', FALSE, '', "G/L Account"."Account Type" <> "G/L Account"."Account Type"::Posting, FALSE, FALSE, '',
                      ExcelBuf."Cell Type"::Text);
                END;
            "G/L Account"."Net Change" < 0:
                BEGIN
                    ExcelBuf.AddColumn(
                      '', FALSE, '', "G/L Account"."Account Type" <> "G/L Account"."Account Type"::Posting, FALSE, FALSE, '',
                      ExcelBuf."Cell Type"::Text);
                    ExcelBuf.AddColumn(
                      -"G/L Account"."Net Change", FALSE, '', "G/L Account"."Account Type" <> "G/L Account"."Account Type"::Posting,
                      FALSE, FALSE, '#,##0.00', ExcelBuf."Cell Type"::Number);
                END;
        END;

        CASE TRUE OF
            "G/L Account"."Balance at Date" = 0:
                BEGIN
                    ExcelBuf.AddColumn(
                      '', FALSE, '', "G/L Account"."Account Type" <> "G/L Account"."Account Type"::Posting, FALSE, FALSE, '',
                      ExcelBuf."Cell Type"::Text);
                    ExcelBuf.AddColumn(
                      '', FALSE, '', "G/L Account"."Account Type" <> "G/L Account"."Account Type"::Posting, FALSE, FALSE, '',
                      ExcelBuf."Cell Type"::Text);
                END;
            "G/L Account"."Balance at Date" > 0:
                BEGIN
                    ExcelBuf.AddColumn(
                      "G/L Account"."Balance at Date", FALSE, '', "G/L Account"."Account Type" <> "G/L Account"."Account Type"::Posting,
                      FALSE, FALSE, '#,##0.00', ExcelBuf."Cell Type"::Number);
                    ExcelBuf.AddColumn(
                      '', FALSE, '', "G/L Account"."Account Type" <> "G/L Account"."Account Type"::Posting, FALSE, FALSE, '',
                      ExcelBuf."Cell Type"::Text);
                END;
            "G/L Account"."Balance at Date" < 0:
                BEGIN
                    ExcelBuf.AddColumn(
                      '', FALSE, '', "G/L Account"."Account Type" <> "G/L Account"."Account Type"::Posting, FALSE, FALSE, '',
                      ExcelBuf."Cell Type"::Text);
                    ExcelBuf.AddColumn(
                      -"G/L Account"."Balance at Date", FALSE, '', "G/L Account"."Account Type" <> "G/L Account"."Account Type"::Posting,
                      FALSE, FALSE, '#,##0.00', ExcelBuf."Cell Type"::Number);
                END;
        END;
    end;

    procedure CreateExcelbook();
    begin
        ExcelBuf.CreateBookAndOpenExcel('', Text001, '', COMPANYNAME, USERID);
        ERROR('');
    end;

}