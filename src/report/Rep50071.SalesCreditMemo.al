report 50071 "Sales-Credit Memo"
{
    // version CCIT-Fortune-SG,CITS_RS

    DefaultLayout = RDLC;
    RDLCLayout = 'src/reportlayout/Sales-Credit Memo.rdl';
    ApplicationArea = all;
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem("Sales Cr.Memo Header"; "Sales Cr.Memo Header")
        {
            RequestFilterFields = "No.";
            column(Ack_Number; "Sales Cr.Memo Header"."E-Invoice Acknowledgment No.")
            {
            }
            column(IRNNo; EINVDETILS."E-Invoice IRN No.")
            {

            }
            column(QRCode; EINVDETILS."E-Invoice QR Code")
            {

            }
            column(QR_Code; "Sales Cr.Memo Header"."E-Invoice QR")
            {
            }
            column(E_Invoice_IRN; "Sales Cr.Memo Header"."E-Invoice IRN")
            {
            }
            column(PostingDate_SalesCrMemoHeader; "Sales Cr.Memo Header"."Posting Date")
            {
            }
            column(SelltoCustomerName_SalesCrMemoHeader; "Sales Cr.Memo Header"."Sell-to Customer Name")
            {
            }
            column(SelltoCustomerName2_SalesCrMemoHeader; "Sales Cr.Memo Header"."Sell-to Customer Name 2")
            {
            }
            column(SelltoAddress_SalesCrMemoHeader; "Sales Cr.Memo Header"."Sell-to Address")
            {
            }
            column(SelltoAddress2_SalesCrMemoHeader; "Sales Cr.Memo Header"."Sell-to Address 2")
            {
            }
            column(SelltoCity_SalesCrMemoHeader; "Sales Cr.Memo Header"."Sell-to City")
            {
            }
            column(SelltoContact_SalesCrMemoHeader; "Sales Cr.Memo Header"."Sell-to Contact")
            {
            }
            column(BilltoPostCode_SalesCrMemoHeader; "Sales Cr.Memo Header"."Bill-to Post Code")
            {
            }
            column(BilltoCounty_SalesCrMemoHeader; "Sales Cr.Memo Header"."Bill-to County")
            {
            }
            column(BilltoCountryRegionCode_SalesCrMemoHeader; "Sales Cr.Memo Header"."Bill-to Country/Region Code")
            {
            }
            column(AppliestoDocNo_SalesCrMemoHeader; "Sales Cr.Memo Header"."Applies-to Doc. No.")
            {
            }
            column(SelltoPostCode_SalesCrMemoHeader; "Sales Cr.Memo Header"."Sell-to Post Code")
            {
            }
            column(SelltoCounty_SalesCrMemoHeader; "Sales Cr.Memo Header"."Sell-to County")
            {
            }
            column(SelltoCountryRegionCode_SalesCrMemoHeader; "Sales Cr.Memo Header"."Sell-to Country/Region Code")
            {
            }
            column(LocationCode_SalesCrMemoHeader; "Sales Cr.Memo Header"."Location Code")
            {
            }
            column(SelltoCustomerNo_SalesCrMemoHeader; "Sales Cr.Memo Header"."Sell-to Customer No.")
            {
            }
            column(No_SalesCrMemoHeader; "Sales Cr.Memo Header"."No.")
            {
            }
            column(Tally_INV_No; "Sales Cr.Memo Header"."Tally Invoice No.")
            {
            }
            column(SCH_LocationCode; "Sales Cr.Memo Header"."Location Code")
            {
            }
            column(SCMH_GSTCUSTGRNNO; "Sales Cr.Memo Header"."Customer GRN/RTV No.")
            {
            }
            column(SCMH_GRNRTVDate1; "Sales Cr.Memo Header"."GRN/RTV Date")
            {
            }
            column(Cust_GSTNo; Cust_GSTNo)
            {
            }
            column(Cust_PANNo; Cust_PANNo)
            {
            }
            column(Cust_FSSAINo; Cust_FSSAINo)
            {
            }
            column(Cust_ContactPerson; Cust_ContactPerson)
            {
            }
            column(Cust_ContactPersonMob; Cust_ContactPersonMob)
            {
            }
            column(Loc_GSTNo; Loc_GSTNo)
            {
            }
            column(Loc_PANNo; Loc_PANNo)
            {
            }
            column(Loc_FSSAINo; Loc_FSSAINo)
            {
            }
            column(Loc_ContactPerson; Loc_ContactPerson)
            {
            }
            column(Loc_ContactPersonMob; Loc_ContactPersonMob)
            {
            }
            column(Loc_name; Loc_name)
            {
            }
            column(Loc_Addr; Loc_Addr)
            {
            }
            column(Loc_Addr1; Loc_Addr1)
            {
            }
            column(Loc_city; Loc_city)
            {
            }
            column(Loc_country; Loc_country)
            {
            }
            column(Loc_postcode; Loc_postcode)
            {
            }
            column(RefInvDate; RefInvDate)
            {
            }
            column(CompPicture; RecCompInfo.Picture)
            {
            }
            column(CompMSMENo; RecCompInfo."MSME No.")
            {
            }
            column(AmountinWords; AmountinWords[1])
            {
            }
            dataitem("Sales Cr.Memo Line"; "Sales Cr.Memo Line")
            {
                DataItemLink = "Document No." = FIELD("No.");
                column(LineAmount_SalesCrMemoLine; "Sales Cr.Memo Line"."Line Amount")
                {
                }
                column(ReturnReasonCode_SalesCrMemoLine; ReasonDes)
                {
                }
                column(No_SalesCrMemoLine; "Sales Cr.Memo Line"."No.")
                {
                }
                column(Description_SalesCrMemoLine; "Sales Cr.Memo Line".Description)
                {
                }
                column(UnitofMeasure_SalesCrMemoLine; "Sales Cr.Memo Line"."Unit of Measure")
                {
                }
                column(Quantity_SalesCrMemoLine; "Sales Cr.Memo Line".Quantity)
                {
                }
                column(UnitPrice_SalesCrMemoLine; "Sales Cr.Memo Line"."Unit Price")
                {
                }

                column(CGST; CGST)
                {
                }
                column(SGST; SGST)
                {
                }
                column(IGST; IGST)
                {
                }
                column(Rate; Rate)
                {
                }
                column(Rate1; Rate1)
                {
                }
                column(Srno; Srno)
                {
                }
                column(Item_Name; Item_Name)
                {
                }

                trigger OnAfterGetRecord();
                begin
                    //CCIT-JAGA 07/12/2018
                    CLEAR(ReasonDes);
                    IF RecReturnReason.GET("Sales Cr.Memo Line"."Return Reason Code") THEN
                        ReasonDes := RecReturnReason.Description;
                    //CCIT-JAGA 07/12/2018

                    // rdk 08-06-2019
                    IF RecReason.GET("Sales Cr.Memo Line"."Reason Code") THEN
                        ReasonDes := RecReason.Description;

                    Srno += 1;

                    CGST := 0;
                    SGST := 0;
                    IGST := 0;
                    Rate := 0;
                    Rate1 := 0;
                    //<<PCPL/MIG/NSW
                    GLE.RESET;
                    GLE.SETRANGE(GLE."Document No.", "Sales Cr.Memo Line"."Document No.");
                    GLE.SETRANGE(GLE."Transaction Type", GLE."Transaction Type"::Sales);
                    GLE.SETRANGE("Document Line No.", "Sales Cr.Memo Line"."Line No.");
                    IF GLE.FindSet THEN
                            repeat
                                IF GLE."GST Component Code" = 'CGST' THEN BEGIN
                                    CGST := ABS(GLE."GST Amount");
                                    Rate := (GLE."GST %");
                                END
                                ELSE
                                    IF GLE."GST Component Code" = 'IGST' THEN BEGIN
                                        IGST := ABS(GLE."GST Amount");
                                        Rate1 := GLE."GST %";
                                    END
                                    ELSE
                                        IF GLE."GST Component Code" = 'SGST' THEN BEGIN
                                            SGST := ABS(GLE."GST Amount");
                                            Rate := (GLE."GST %");
                                        END;
                            until GLE.Next = 0;
                    //>>PCPL/MIG/NSW
                    /*
                    IF "Sales Cr.Memo Line"."GST Jurisdiction Type" = "Sales Cr.Memo Line"."GST Jurisdiction Type"::Intrastate THEN BEGIN
                        Rate := 0;//"Sales Cr.Memo Line"."GST %" / 2; //PCPL/MIG/NSW Filed not Exist in BC18
                        CGST := 0;//"Sales Cr.Memo Line"."Total GST Amount" / 2; //PCPL/MIG/NSW Filed not Exist in BC18
                        SGST := 0;//"Sales Cr.Memo Line"."Total GST Amount" / 2; //PCPL/MIG/NSW Filed not Exist in BC18
                    END
                    ELSE
                        IF ("Sales Cr.Memo Line"."GST Jurisdiction Type" = "Sales Cr.Memo Line"."GST Jurisdiction Type"::Interstate) THEN BEGIN
                            Rate1 := 0;//"Sales Cr.Memo Line"."GST %"; //PCPL/MIG/NSW Filed not Exist in BC18
                            IGST := 0;//"Sales Cr.Memo Line"."Total GST Amount"; //PCPL/MIG/NSW Filed not Exist in BC18
                        END;
                        */ //Temp Commebt code Due to field is not avil in BC18

                    TotalCGST += CGST;
                    TotalSGST += SGST;
                    TotalIGST += IGST;

                    GrandTotal += SGST + CGST + IGST;

                    repCheck.InitTextVariable;
                    repCheck.FormatNoText(AmountinWords, ROUND(TotalAmount), '');



                    IF RecGL.GET("Sales Cr.Memo Line"."No.") THEN
                        Item_Name := RecGL.Name;
                end;

                trigger OnPreDataItem();
                begin
                    Srno := 0;
                end;
            }

            trigger OnAfterGetRecord();
            begin
                IF RecCust.GET("Sales Cr.Memo Header"."Sell-to Customer No.") THEN BEGIN
                    Cust_GSTNo := RecCust."GST Registration No.";
                    Cust_PANNo := RecCust."P.A.N. No.";
                    Cust_FSSAINo := RecCust."FSSAI License No";
                    Cust_ContactPerson := RecCust.Contact;
                    Cust_ContactPersonMob := RecCust."Phone No.";
                END;

                "Sales Cr.Memo Header".CALCFIELDS("E-Invoice QR");//CITS_RS 060221

                CLEAR(EINVDETILS);
                IF "Sales Cr.Memo Header"."Nature of Supply" = "Sales Cr.Memo Header"."Nature of Supply"::B2B THEN BEGIN
                    EINVDETILS.RESET;
                    EINVDETILS.SETRANGE("Document No.", "Sales Cr.Memo Header"."No.");
                    IF EINVDETILS.FINDFIRST THEN BEGIN
                        IF EINVDETILS."E-Invoice IRN No." <> '' THEN
                            IF EINVDETILS.CALCFIELDS("E-Invoice QR Code") THEN;
                    END;
                END;

                IF RecLoc.GET("Sales Cr.Memo Header"."Location Code") THEN BEGIN
                    Loc_name := RecLoc.Name;
                    Loc_Addr := RecLoc.Address;
                    Loc_Addr1 := RecLoc."Address 2";
                    Loc_city := RecLoc.City;
                    Loc_country := RecLoc.County;
                    Loc_postcode := RecLoc."Post Code";
                    Loc_GSTNo := RecLoc."GST Registration No.";
                    Loc_PANNo := RecLoc."P.A.N No";
                    Loc_FSSAINo := RecLoc."FSSAI No";
                    Loc_ContactPerson := RecLoc.Contact;
                    Loc_ContactPersonMob := RecLoc."Phone No.";
                END;

                RefInvDate := 0D;
                RecCustLedEntries.RESET;
                RecCustLedEntries.SETRANGE(RecCustLedEntries."Document No.", "Sales Cr.Memo Header"."Applies-to Doc. No.");
                IF RecCustLedEntries.FINDFIRST THEN
                    RefInvDate := RecCustLedEntries."Posting Date";
            end;
        }
    }

    requestpage
    {

        layout
        {
        }

        actions
        {
        }
    }

    labels
    {
    }

    trigger OnInitReport();
    begin
        RecCompInfo.GET;
        RecCompInfo.CALCFIELDS(Picture);
    end;

    var
        RecCompInfo: Record 79;
        RecLoc: Record 14;
        Cust_GSTNo: Code[15];
        Cust_PANNo: Code[20];
        Cust_FSSAINo: Code[20];
        Cust_ContactPerson: Text[50];
        Cust_ContactPersonMob: Text[20];
        RecCust: Record 18;
        Loc_GSTNo: Code[15];
        Loc_PANNo: Code[20];
        Loc_FSSAINo: Code[20];
        Loc_ContactPerson: Text[50];
        Loc_ContactPersonMob: Text[20];
        repCheck: Report 1401;
        AmountinWords: array[5] of Text[250];
        TotalAmount: Decimal;
        CGST: Decimal;
        SGST: Decimal;
        IGST: Decimal;
        Rate: Decimal;
        Rate1: Decimal;
        GrandTotal: Decimal;
        TotalCGST: Decimal;
        TotalSGST: Decimal;
        TotalIGST: Decimal;
        RecCustLedEntries: Record 21;
        RefInvDate: Date;
        Loc_Addr: Text[200];
        Loc_Addr1: Text[200];
        Loc_city: Text[20];
        Loc_country: Code[20];
        Loc_postcode: Code[20];
        Loc_name: Text[200];
        Srno: Integer;
        RecGL: Record 15;
        Item_Name: Text[100];
        RecReturnReason: Record 6635;
        ReasonDes: Text[50];
        RecReason: Record 231;
        GLE: Record "Detailed GST Ledger Entry";
        EINVDETILS: Record 50007;
}

