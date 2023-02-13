pageextension 50302 Sales_orderEinv_ext extends "Sales Order"
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