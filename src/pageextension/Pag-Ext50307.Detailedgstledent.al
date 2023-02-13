pageextension 50307 Detailed_gst_LedEnt_Ext extends "Detailed GST Ledger Entry"
{
    layout
    {
        addafter("Bill of Entry Date")
        {
            field("IRN No."; "IRN No.")
            {
                ApplicationArea = all;
            }
            field("Acknowledge No."; "Acknowledge No.")
            {
                ApplicationArea = all;
            }

            field("Acknowledge Date"; "Acknowledge Date")
            {
                ApplicationArea = all;
            }
            field("E-invoice Remark"; "E Invoice Remark")
            {
                ApplicationArea = all;
            }
            field("Transfer Order No."; "Transfer Order No.")
            {
                ApplicationArea = all;
            }
            field("Transfer Order Date"; "Transfer Order Date")
            {
                ApplicationArea = all;
            }

            //field()
        }
        addafter("GST Place of Supply")
        {
            field("E-Way No."; "E-Way No.")
            {
                ApplicationArea = all;
            }
            field("E-Way Bill Date"; "E-Way Bill Date")
            {
                ApplicationArea = all;
            }

        }
    }

    actions
    {

    }
    trigger OnAfterGetRecord()
    begin
        CLEAR("IRN No.");
        CLEAR("Acknowledge No.");
        CLEAR("Acknowledge Date");
        CLEAR("Transfer Order No.");
        CLEAR("Transfer Order Date");
        CLEAR("E Invoice Remark");//CCIT_TK

        IF "Transaction Type" = "Transaction Type"::Sales THEN BEGIN
            IF "Document Type" = "Document Type"::Invoice THEN BEGIN
                SalesInvHeader.RESET();
                SalesInvHeader.SETRANGE("No.", "Document No.");
                IF SalesInvHeader.FIND('-') THEN BEGIN
                    EINVDetail.Reset();
                    EINVDetail.SetRange("Document No.", SalesInvHeader."No.");
                    IF EINVDetail.FindFirst() then begin
                        "IRN No." := EINVDetail."E-Invoice IRN No.";
                        "Acknowledge No." := SalesInvHeader."Acknowledgement No.";
                        "Acknowledge Date" := EINVDetail."E-Invoice Acknowledgement Date Time";
                        "E Invoice Remark" := EINVDetail."E-Invoice Bill Error";//CCIT_TK
                    end;
                END;
                TransferShipHeader.SETRANGE("No.", "Document No.");
                IF TransferShipHeader.FIND('-') THEN BEGIN
                    EINVDetail.Reset();
                    EINVDetail.SetRange("Document No.", TransferShipHeader."No.");
                    IF EINVDetail.FindFirst() then begin
                        "IRN No." := EINVDetail."E-Invoice IRN No.";
                        "Acknowledge No." := SalesInvHeader."Acknowledgement No.";
                        "Acknowledge Date" := EINVDetail."E-Invoice Acknowledgement Date Time";
                        "E Invoice Remark" := EINVDetail."E-Invoice Bill Error";//CCIT_TK
                    end;
                END;
            END;
            IF "Document Type" = "Document Type"::"Credit Memo" THEN BEGIN
                SalesCrHeader.RESET();
                SalesCrHeader.SETRANGE("No.", "Document No.");
                IF SalesCrHeader.FIND('-') THEN BEGIN
                    EINVDetail.Reset();
                    EINVDetail.SetRange("Document No.", SalesCrHeader."No.");
                    IF EINVDetail.FindFirst() then begin
                        "IRN No." := EINVDetail."E-Invoice IRN No.";
                        "Acknowledge No." := SalesInvHeader."Acknowledgement No.";
                        "Acknowledge Date" := EINVDetail."E-Invoice Acknowledgement Date Time";
                        "E Invoice Remark" := EINVDetail."E-Invoice Bill Error";//CCIT_TK
                    end;
                END;
            END;

        END;
        //  IF "Original Doc. Type" = "Original Doc. Type"::"Transfer Shipment" THEN BEGIN
        RecTransferShipmentHeader.RESET();
        RecTransferShipmentHeader.SETRANGE("No.", "Document No.");
        IF RecTransferShipmentHeader.FIND('-') THEN BEGIN
            "Transfer Order No." := RecTransferShipmentHeader."Transfer Order No.";
            "Transfer Order Date" := RecTransferShipmentHeader."Transfer Order Date";
            IF "Customer/Vendor Name" = '' then begin
                "Customer/Vendor Name" := RecTransferShipmentHeader."Transfer-from Code";
                Modify();
            end;
        END;
        // END;

        //IF "Original Doc. Type" = "Original Doc. Type"::"Transfer Receipt" THEN BEGIN
        RecTransferReceiptHeader.RESET();
        RecTransferReceiptHeader.SETRANGE("No.", "Document No.");
        IF RecTransferReceiptHeader.FIND('-') THEN BEGIN
            "Transfer Order No." := RecTransferReceiptHeader."Transfer Order No.";
            "Transfer Order Date" := RecTransferReceiptHeader."Transfer Order Date";
            IF "Customer/Vendor Name" = '' then begin
                "Customer/Vendor Name" := RecTransferReceiptHeader."Transfer-to Code";
                Modify();
            end;
        END;
        //END;
    end;

    var
        EINVDetail: Record 50007;
        "IRN No.": Text;
        "Acknowledge No.": Text;
        "Acknowledge Date": DateTime;
        "E Invoice Remark": Text;

        SalesInvHeader: Record "Sales Invoice Header";
        SalesCrHeader: Record "Sales Cr.Memo Header";
        TransferShipHeader: Record "Transfer Shipment Header";
        "Transfer Order No.": Text;
        "Transfer Order Date": Date;
        RecTransferShipmentHeader: Record "Transfer Shipment Header";
        RecTransferReceiptHeader: Record "Transfer Receipt Header";
}