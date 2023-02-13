tableextension 50044 SalesHeaderEInv_ext extends "Sales Header"
{
    fields
    {
        field(50125; "Auto E-Invoice Post"; Boolean)
        {
            Description = 'PCPL-NSW-07 02June22';
        }
    }

    var
        myInt: Integer;
}