tableextension 50043 Trans_ship_Hear_ext extends "Transfer Shipment Header"
{
    fields
    {
        field(50000; "EINV IRN No."; Text[64])
        {
            DataClassification = ToBeClassified;

        }
        field(50001; "EINV QR Code"; Blob)
        {
            DataClassification = ToBeClassified;
        }
        field(50002; "Cancel Remark"; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(50003; "Cancel IRN No."; Text[64])
        {
            DataClassification = ToBeClassified;
        }
        field(50004; "E-Way Bill Generate"; Option)
        {
            OptionCaption = ' ,To Generate,Generated';
            OptionMembers = " ","To Generate",Generated;

        }
    }

    var
        myInt: Integer;
}