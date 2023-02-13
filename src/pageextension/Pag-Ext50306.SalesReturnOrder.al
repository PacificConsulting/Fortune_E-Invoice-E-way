pageextension 50306 "SalesReturn_Order_ext" extends "Sales Return Order"
{
    layout
    {
        modify("Sell-to Customer No.")
        {
            trigger OnAfterValidate()
            begin
                "Auto E-Invoice Post" := True;
                Modify();
            end;
        }
        addafter("GRN/RTV Date")
        {
            field("Auto E-Invoice Post"; "Auto E-Invoice Post")
            {
                ApplicationArea = All;
            }
        }

    }
}