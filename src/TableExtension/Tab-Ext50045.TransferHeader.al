tableextension 50045 Transfer_Header_Eway_ext extends "Transfer Header"
{
    fields
    {
        field(50140; "Auto E-Invoice Post"; Boolean)
        {
            Description = 'PCPL-NSW-07 02June22';
        }
    }

    var
        myInt: Integer;
}