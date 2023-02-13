page 50104 "E-Way Bill Detail"
{
    // version PCPL41-EWAY

    DeleteAllowed = false;
    PageType = ListPart;
    SourceTable = 50008;
    ApplicationArea = all;
    UsageCategory = Lists;
    Editable = true;
    //ModifyAllowed = true;

    layout
    {
        area(content)
        {
            field("Eway Bill No."; "Eway Bill No.")
            {
                Editable = false;
                ApplicationArea = all;
            }
            field("Ewaybill Error"; "Ewaybill Error")
            {
                ApplicationArea = all;
            }
            field("URL for PDF"; "URL for PDF")
            {
                Editable = false;
                ApplicationArea = all;
            }
            field("E-Way Bill Generate"; "E-Way Bill Generate")
            {
                ApplicationArea = all;
                Editable = Vedit;
            }
            field("Transporter Name"; "Transporter Name")
            {
                ApplicationArea = all;
                //Editable = Vedit;
                Editable = false;
            }
            field("Transportation Mode"; "Transportation Mode")
            {
                ApplicationArea = all;
                //Editable = Vedit;
                Editable = false;
            }
            field("Transport Distance"; "Transport Distance")
            {
                ApplicationArea = all;
                //Editable = Vedit;
                Editable = false;
            }

        }
    }
    trigger OnAfterGetRecord()
    begin
        IF "Eway Bill No." <> '' then
            Vedit := false
        else
            Vedit := true;
        //CurrPage.Editable(false);
    end;

    trigger OnOpenPage()
    begin
        IF "Eway Bill No." <> '' then
            Vedit := false
        else
            Vedit := true;
    end;

    var
        Vedit: Boolean;

}

