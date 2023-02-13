pageextension 50301 General_led_Set_Ext extends "General Ledger Setup"
{
    layout
    {
        addafter("Payroll Transaction Import")
        {
            group("E-Invoice Setup")
            {
                Caption = 'E-Invoice Setup';
                Visible = true;
                field("EINV Base URL"; "EINV Base URL")
                {
                    ApplicationArea = all;
                }
                field("EINV Client ID"; "EINV Client ID")
                {
                    ApplicationArea = all;
                }
                field("EINV Client Secret"; "EINV Client Secret")
                {
                    ApplicationArea = all;
                }
                field("EINV Grant Type"; "EINV Grant Type")
                {
                    ApplicationArea = all;
                }
                field("EINV Path"; "EINV Path")
                {
                    ApplicationArea = all;
                }
                field("EINV User Name"; "EINV User Name")
                {
                    ApplicationArea = all;
                }
                field("EINV Password"; "EINV Password")
                {
                    ApplicationArea = all;
                }

            }
        }
    }

    actions
    {

    }

    var
        myInt: Integer;
}