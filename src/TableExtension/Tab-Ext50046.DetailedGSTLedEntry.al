tableextension 50046 DetailedGSTLedgerEntry_Ext extends "Detailed GST Ledger Entry"
{
    fields
    {
        field(50013; "E-Way No."; Text[50])
        {
            //DataClassification = ToBeClassified;
            FieldClass = FlowField;
            CalcFormula = max("E-Way Bill Detail"."Eway Bill No." where("Document No." = field("Document No.")));

        }
        field(50014; "E-Way Bill Date"; Date)
        {
            //DataClassification = ToBeClassified;
            FieldClass = FlowField;
            CalcFormula = max("Sales Invoice Header"."E-Way Bill Date" where("No." = field("Document No.")));
        }
        // Add changes to table fields here
    }

    var
        myInt: Integer;
}