tableextension 50041 Gen_Led_setup extends "General Ledger Setup"
{
    fields
    {
        field(50008; "EINV Base URL"; Text[50])
        {
            Description = 'PCPL-NSW-07';
        }
        field(50009; "EINV User Name"; Text[50])
        {
            Description = 'PCPL-NSW-07';
        }
        field(50010; "EINV Password"; Text[20])
        {
            Description = 'PCPL-NSW-07';
        }
        field(50011; "EINV Client ID"; Text[40])
        {
            Description = 'PCPL-NSW-07';
        }
        field(50012; "EINV Client Secret"; Text[40])
        {
            Description = 'PCPL-NSW-07';
        }
        field(50013; "EINV Grant Type"; Text[15])
        {
            Description = 'PCPL-NSW-07';
        }
        field(50014; "EINV Path"; Text[50])
        {
            Description = 'PCPL-NSW-07';
        }
    }

    var
        myInt: Integer;
}