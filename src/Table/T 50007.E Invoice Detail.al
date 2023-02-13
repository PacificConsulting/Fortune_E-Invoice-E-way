table 50007 "E-Invoice Detail"
{
    // version PCPL41-EINV

    DrillDownPageID = 132;
    LookupPageID = 132;
    Permissions = TableData 112 = r;

    fields
    {
        field(1; "Document No."; Code[20])
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(2; "E-Invoice IRN No."; Code[64])
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(3; "E-Invoice Bill Error"; Code[10])
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(4; "Cancel Remark"; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(5; "Cancel IRN No."; Code[64])
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(6; "E-Invoice QR Code"; BLOB)
        {
            DataClassification = ToBeClassified;
            SubType = Bitmap;
        }
        field(7; "URL for PDF"; Text[100])
        {
            DataClassification = ToBeClassified;
            Editable = false;
            ExtendedDatatype = URL;
        }
        field(8; "E-Invoice Acknowledgement Date Time"; DateTime)
        {
            DataClassification = ToBeClassified;   
        }
    }

    keys
    {
        key(Key1; "Document No.")
        {
        }
    }

    fieldgroups
    {
    }
}

