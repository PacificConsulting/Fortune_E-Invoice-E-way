pageextension 50303 Transfer_order_Eway extends "Transfer Order"
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
        modify("Transfer-from Code")
        {
            trigger OnAfterValidate()
            begin
                "Auto E-Invoice Post" := True;
                Modify();
            end;
        }

    }

}