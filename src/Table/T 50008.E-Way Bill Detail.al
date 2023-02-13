table 50008 "E-Way Bill Detail"
{
    // version PCPL41-EWAY

    DrillDownPageID = 132;
    LookupPageID = 132;
    Permissions = TableData 112 = r;

    fields
    {
        field(1; "Document No."; Code[20])
        {
            DataClassification = ToBeClassified;
            Editable = true;
        }
        field(2; "Eway Bill No."; Text[12])
        {
            DataClassification = ToBeClassified;
            Editable = true;
        }
        field(3; "Ewaybill Error"; Text[250])
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(4; "Transporter Id"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(5; "Transporter Name"; Text[50])
        {
            DataClassification = ToBeClassified;
        }
        field(6; "Transport Distance"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(7; "Transportation Mode"; Text[10])
        {
            DataClassification = ToBeClassified;
        }
        field(8; "URL for PDF"; Text[100])
        {
            DataClassification = ToBeClassified;
            Editable = true;
            ExtendedDatatype = URL;
        }
        field(9; "E-Way Bill Generate"; Option)
        {
            DataClassification = ToBeClassified;
            OptionCaption = ' ,To Generate,Generated';
            OptionMembers = " ","To Generate",Generated;
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

