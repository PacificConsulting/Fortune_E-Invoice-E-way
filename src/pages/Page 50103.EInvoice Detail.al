page 50103 "E-Invoice Detail"
{
    // version PCPL41-EINV

    PageType = ListPart;
    SourceTable = 50007;
    ApplicationArea = all;
    UsageCategory = Lists;
    Editable = false;
    Caption = 'E-Invoice Detail';

    layout
    {
        area(content)
        {

            field("E-Invoice IRN No."; "E-Invoice IRN No.")
            {

                ApplicationArea = all;
            }
            field("E-Invoice QR Code"; "E-Invoice QR Code")
            {
                Editable = false;
                ApplicationArea = all;
            }
            field("Cancel Remark"; "Cancel Remark")
            {
                ApplicationArea = all;
            }
            field("Cancel IRN No."; "Cancel IRN No.")
            {
                ApplicationArea = all;
            }
            field("URL for PDF"; "URL for PDF")
            {
                ApplicationArea = all;

            }


        }
    }

    actions
    {
    }
}

