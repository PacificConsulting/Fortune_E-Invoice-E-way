reportextension 50000 Purch_Invoice extends 406
{
    dataset
    {
        modify("Purch. Inv. Line")
        {
            trigger OnAfterAfterGetRecord()
            begin
                IF "Buy-from Vendor No." = 'V0001' then
                    IF Type = Type::"G/L Account" then
                        CurrReport.Skip();

            end;
        }

    }

    requestpage
    {
        // Add changes to the requestpage here
    }

    // rendering
    // {
    //     layout(LayoutName)
    //     {
    //         Type = RDLC;
    //         LayoutFile = 'mylayout.rdl';
    //     }
    // }
}