pageextension 50304 SalesCreditMemo_Einv_ext extends "Sales Credit Memo"
{
    layout
    {
        addafter(Status)
        {
            field("Auto E-Invoice Post"; "Auto E-Invoice Post")
            {
                ApplicationArea = all;
            }
        }
        modify("Sell-to Customer No.")
        {
            trigger OnAfterValidate()
            begin
                "Auto E-Invoice Post" := True;
                Modify();
            end;
        }

    }

    actions
    {
        // Add changes to page actions here
    }

    var
        myInt: Integer;
}