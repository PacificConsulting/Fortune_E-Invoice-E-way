report 50078 "Sales-Debit Note"
{
    // version CCIT,CITS_RS

    DefaultLayout = RDLC;
    RDLCLayout = 'src/reportlayout/Sales-Debit Note.rdl';
    ApplicationArea = all;
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem("Sales Invoice Header"; "Sales Invoice Header")
        {
            //DataItemTableView = '';  //PCPL/MIG/NSW Filed not Exist in BC18
            RequestFilterFields = "No.";
            column(LocationCode_SalesInvoiceHeader; "Sales Invoice Header"."Location Code")
            {
            }
            column(RefInvNo; RefInvNo)
            {

            }
            column(RefInvDate; RefInvDate)
            {

            }
            column(Loc_Name; Loc_Name)
            {

            }
            column(IRNNo; EINVDETILS."E-Invoice IRN No.")
            {

            }
            column(QRCode; EINVDETILS."E-Invoice QR Code")
            {

            }
            column(E_Invoice_IRN; "Sales Invoice Header"."E-Invoice IRN")
            {
            }
            column(Ack_Number; "Sales Invoice Header"."Acknowledgement No.")
            {
            }
            column(QR_Code; "Sales Invoice Header"."E-Invoice QR")
            {
            }
            column(PreAssignedNo_SalesInvoiceHeader; "Sales Invoice Header"."Pre-Assigned No.")
            {
            }
            column(DocumentDate_SalesInvoiceHeader; "Sales Invoice Header"."Posting Date")
            {
            }
            column(ExternalDocumentNo_SalesInvoiceHeader; "Sales Invoice Header"."External Document No.")
            {
            }
            column(PostingDate_SalesInvoiceHeader; "Sales Invoice Header"."Posting Date")
            {
            }
            column(No_SalesInvoiceHeader; "Sales Invoice Header"."No.")
            {
            }
            column(SelltoCustomerName_SalesInvoiceHeader; "Sales Invoice Header"."Sell-to Customer Name")
            {
            }
            column(SelltoPostCode_SalesInvoiceHeader; "Sales Invoice Header"."Sell-to Post Code")
            {
            }
            column(SelltoAddress_SalesInvoiceHeader; "Sales Invoice Header"."Sell-to Address")
            {
            }
            column(SelltoAddress2_SalesInvoiceHeader; "Sales Invoice Header"."Sell-to Address 2")
            {
            }
            column(SelltoCity_SalesInvoiceHeader; "Sales Invoice Header"."Sell-to City")
            {
            }
            column(SelltoCounty_SalesInvoiceHeader; "Sales Invoice Header"."Sell-to County")
            {
            }
            column(AppliestoDocNo_SalesInvoiceHeader; "Sales Invoice Header"."Applies-to Doc. No.")
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
            column(AppDocDate; AppDocDate)
            {
            }
            column(CompPicture; RecCompInfo.Picture)
            {
            }

            dataitem("Sales Invoice Line"; "Sales Invoice Line")
            {
                DataItemLink = "Document No." = FIELD("No.");
                DataItemTableView = WHERE(Description = FILTER(<> 'Round Off'),
                                          Type = FILTER("G/L Account" | Item));
                column(Description_SalesInvoiceLine; "Sales Invoice Line".Description)
                {
                }
                column(LineAmount_SalesInvoiceLine; "Sales Invoice Line"."Line Amount")
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
                column(Srno; Srno)
                {
                }
                column(SCL_Comment; SCL_Comment)
                {
                }
                column(GrandTotal; GrandTotal)
                {
                }
                column(Total; Total)
                {
                }
                column(RefInvoiceDate; RefInvoiceDate)
                {

                }
                column(RefInvoiceNo; RefInvoiceNo)
                {

                }

                trigger OnAfterGetRecord();
                begin

                    Srno += 1;
                    Total := 0;
                    CGST := 0;
                    SGST := 0;
                    IGST := 0;

                    IF "Sales Invoice Line"."GST Jurisdiction Type" = "Sales Invoice Line"."GST Jurisdiction Type"::Intrastate THEN BEGIN
                        CGST := 0;//"Sales Invoice Line"."Total GST Amount"/2; //PCPL/MIG/NSW Filed not Exist in BC18
                        SGST := 0;//"Sales Invoice Line"."Total GST Amount"/2; //PCPL/MIG/NSW Filed not Exist in BC18
                    END
                    ELSE
                        IF "Sales Invoice Line"."GST Jurisdiction Type" = "Sales Invoice Line"."GST Jurisdiction Type"::Interstate THEN BEGIN
                            IGST := 0;//"Sales Invoice Line"."Total GST Amount"; //PCPL/MIG/NSW Filed not Exist in BC18
                        END;
                    GLE.RESET;
                    GLE.SETRANGE(GLE."Document No.", "Sales Invoice Line"."Document No.");
                    GLE.SETRANGE(GLE."Transaction Type", GLE."Transaction Type"::Sales);
                    GLE.SETRANGE("Document Line No.", "Sales Invoice Line"."Line No.");
                    IF GLE.FindSet THEN
                        repeat
                            IF GLE."GST Component Code" = 'CGST' THEN BEGIN
                                //CGST := ABS(GLE."GST Amount") / 2;
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
                                        // SGST := ABS(GLE."GST Amount") / 2;
                                        SGST := ABS(GLE."GST Amount");
                                        Rate := (GLE."GST %");
                                    END;
                        until GLE.Next = 0;

                    Total := "Sales Invoice Line"."Line Amount" + CGST + SGST + IGST;
                    GrandTotal += Total;

                    //Message('Ref Date & Ref No');
                    RecILE.Reset();
                    RecILE.SetRange("Item No.", "No.");
                    RecILE.SetRange("Posting Date", "Posting Date");
                    if RecILE.FindFirst() then begin
                        RefInvoiceNo := RecILE."Document No.";
                        RefInvoiceDate := RecILE."Posting Date";
                    end;



                end;

                trigger OnPreDataItem();
                begin
                    Srno := 0;
                end;
            }

            trigger OnAfterGetRecord();
            begin
                RecCust.RESET;
                RecCust.SETRANGE(RecCust."No.", "Sales Invoice Header"."Sell-to Customer No.");
                IF RecCust.FINDFIRST THEN BEGIN
                    Cust_Address := RecCust.Address;
                    Cust_PANNo := RecCust."P.A.N. No.";
                    Cust_FSSAINo := RecCust."FSSAI License No";
                    Cust_ContactPerson := RecCust.Contact;
                    Cust_ContactPersonMob := RecCust."Phone No.";
                    Cust_GSTNo := RecCust."GST Registration No.";
                END;

                "Sales Invoice Header".CALCFIELDS("E-Invoice QR");//CITS_RS 080221

                CLEAR(EINVDETILS);
                IF "Sales Invoice Header"."Nature of Supply" = "Sales Invoice Header"."Nature of Supply"::B2B THEN BEGIN
                    EINVDETILS.RESET;
                    EINVDETILS.SETRANGE("Document No.", "Sales Invoice Header"."No.");
                    IF EINVDETILS.FINDFIRST THEN BEGIN
                        IF EINVDETILS."E-Invoice IRN No." <> '' THEN
                            IF EINVDETILS.CALCFIELDS("E-Invoice QR Code") THEN;
                    END;
                END;

                RecLoc.RESET;
                RecLoc.SETRANGE(RecLoc.Code, "Sales Invoice Header"."Location Code");
                IF RecLoc.FINDFIRST THEN BEGIN
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
                    Loc_Name := Recloc.Name;
                END;
                RecSCL.RESET;
                RecSCL.SETRANGE(RecSCL."No.", "Sales Invoice Header"."No.");
                IF RecSCL.FINDFIRST THEN
                    SCL_Comment := RecSCL.Comment;

                //CCIT-PRI-160119
                // CLEAR(AppDocDate);
                //RecSIH.RESET;
                // RecSIH.SETRANGE(RecSIH."No.", "Sales Invoice Header"."Applies-to Doc. No.");
                // IF RecSIH.FINDFIRST THEN begin
                //   AppDocDate := RecSIH."Posting Date";
                //end;

                //CCIT-PRI-160119
                Clear(RefInvNo);
                Clear(RefInvDate);
                RefInvo.Reset();
                RefInvo.SetRange("Document No.", "Sales Invoice Header"."No.");
                RefInvo.SetRange("Document Type", RefInvo."Document Type"::Invoice);
                IF RefInvo.FindFirst() then begin
                    RefInvNo := RefInvo."Reference Invoice Nos.";

                    RecSIH.Reset();
                    RecSIH.SetRange("No.", RefInvNo);
                    IF RecSIH.FindFirst() then begin
                        RefInvDate := RecSIH."Posting Date";
                    end;

                end;


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
        RecSHL: Record 112;
        RecSIL: Record 113;
        RecSCL: Record 44;
        RecCompInfo: Record 79;
        RecLoc: Record 14;
        Cust_Address: Text;
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

        Loc_Addr: Text[200];
        Loc_Addr1: Text[200];
        Loc_city: Text[20];
        Loc_country: Code[20];
        Loc_postcode: Code[20];
        Loc_name: Text[200];
        Srno: Integer;
        SCL_Comment: Text[80];
        RecSIH: Record 112;
        AppDocDate: Date;
        Total: Decimal;
        GLE: Record "Detailed GST Ledger Entry";
        RecILE: Record 32;
        RefInvoiceNo: Code[20];
        RefInvoiceDate: Date;
        EINVDETILS: Record 50007;
        RefInvo: Record 18011;
        RefInvNo: Code[50];
        RefInvDate: Date;



}

