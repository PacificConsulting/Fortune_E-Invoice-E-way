report 50051 "Sales - Goods Return"
{
    // version CCIT-JAGA

    DefaultLayout = RDLC;
    RDLCLayout = 'src/reportlayout/Sales - Goods Return.rdl';
    ApplicationArea = all;
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem("Return Receipt Header"; "Return Receipt Header")
        {
            RequestFilterFields = "No.";
            column(CIN_N0; CIN_N0)
            {
            }
            column(E_Mail; E_Mail)
            {
            }
            column(PhoneNo; PhoneNo)
            {
            }
            column(CompanyInfo1_Picture; CompanyInfo1.Picture)
            {
            }
            column(CompRegNo; '')//CompanyInfo1."Company Registration  No.") 
            {
            }
            column(No_ReturnReceiptHeader; "Return Receipt Header"."No.")
            {
            }
            column(SalesInvioce_No; RefNo)
            {
            }
            column(SalesInv_PstDt; RefDt)
            {
            }
            column(PostingDate_ReturnReceiptHeader; "Return Receipt Header"."Posting Date")
            {
            }
            column(BilltoCustomerNo_ReturnReceiptHeader; "Return Receipt Header"."Bill-to Customer No.")
            {
            }
            column(BilltoName_ReturnReceiptHeader; "Return Receipt Header"."Bill-to Name")
            {
            }
            column(BilltoAddress_ReturnReceiptHeader; "Return Receipt Header"."Bill-to Address")
            {
            }
            column(BilltoAddress2_ReturnReceiptHeader; "Return Receipt Header"."Bill-to Address 2")
            {
            }
            column(BilltoCity_ReturnReceiptHeader; "Return Receipt Header"."Bill-to City")
            {
            }
            column(Tally_Inv_No; "Return Receipt Header"."Tally Invoice No.")
            {
            }
            column(Customer_GRN_RTV_No_; "Customer GRN/RTV No.")
            {

            }
            column(GRN_RTV_Date; "GRN/RTV Date")
            {

            }
            column(StateName; StateName)
            {
            }
            column(CountryName; CountryName)
            {
            }
            column(CustRegNo; CustRegNo)
            {
            }
            column(OutletName; OutletName)
            {
            }
            column(DocNo; DocNo)
            {
            }
            column(ShiptoCode_ReturnReceiptHeader; "Return Receipt Header"."Ship-to Code")
            {
            }
            column(ShiptoName_ReturnReceiptHeader; "Return Receipt Header"."Ship-to Name")
            {
            }
            column(ShiptoAddress_ReturnReceiptHeader; "Return Receipt Header"."Ship-to Address")
            {
            }
            column(ShiptoAddress2_ReturnReceiptHeader; "Return Receipt Header"."Ship-to Address 2")
            {
            }
            column(ShiptoCity_ReturnReceiptHeader; "Return Receipt Header"."Ship-to City")
            {
            }
            column(ExternalDocumentNo_ReturnReceiptHeader; "Return Receipt Header"."External Document No.")
            {
            }
            column(OrderDate_ReturnReceiptHeader; "Return Receipt Header"."Order Date")
            {
            }
            column(ReturnOrderNo_ReturnReceiptHeader; "Return Receipt Header"."Return Order No.")
            {
            }
            column(DocumentDate_ReturnReceiptHeader; "Return Receipt Header"."Document Date")
            {
            }
            column(SalesPerName; SalesPerName)
            {
            }
            column(CGSTTotal; CGSTTotal)
            {
            }
            column(SGSTTotal; SGSTTotal)
            {
            }
            column(IGSTTotal; IGSTTotal)
            {
            }
            column(Total1; Total1)
            {
            }
            column(CGSTAmt; CGSTAmt)
            {
            }
            column(SGSTAmt; SGSTAmt)
            {
            }
            column(IGSTAmt; IGSTAmt)
            {
            }
            column(CGSTRate; CGSTRate)
            {
            }
            column(IGSTRate; IGSTRate)
            {
            }
            column(DiscountAmt; DiscountAmt)
            {
            }
            column(Cust_PANNo; Cust_PANNo)
            {
            }
            column(Loc_Name; Loc_Name)
            {
            }
            column(Loc_Addr1; Loc_Addr1)
            {
            }
            column(Loc_Addr2; Loc_Addr2)
            {
            }
            column(LocationCode_ReturnReceiptHeader; "Return Receipt Header"."Location Code")
            {
            }
            column(Loc_city; Loc_city)
            {
            }
            column(Loc_country; Loc_country)
            {
            }
            column(Loc_PANNo; Loc_PANNo)
            {
            }
            column(Loc_PostCode; Loc_PostCode)
            {
            }
            column(Loc_GSTNo; Loc_GSTNo)
            {
            }
            column(Loc_FSSAINo; Loc_FSSAINo)
            {
            }
            column(Cust_FSSAINo; Cust_FSSAINo)
            {
            }
            dataitem("Return Receipt Line"; "Return Receipt Line")
            {
                DataItemLink = "Document No." = FIELD("No.");
                column(HSNSACCode_ReturnReceiptLine; SCL."HSN/SAC Code")//"Return Receipt Line"."HSN/SAC Code") //PCPL/MIG/NSW
                {
                }
                column(UnitPrice_ReturnReceiptLine; "Return Receipt Line"."Unit Price")
                {
                }
                column(LineDiscount_ReturnReceiptLine; "Return Receipt Line"."Line Discount %")
                {
                }
                column(IRNNo; EINVDETILS."E-Invoice IRN No.")
                {

                }
                column(QRCode; EINVDETILS."E-Invoice QR Code")
                {

                }

                column(HSNSCL; SCL."HSN/SAC Code")
                {

                }

                trigger OnAfterGetRecord();
                begin
                    //----

                    //IF ("Return Receipt Line"."GST Jurisdiction Type" = "Return Receipt Line"."GST Jurisdiction Type"::Intrastate) THEN BEGIN
                    ILE.SETCURRENTKEY("Document No.");
                    ILE.SETRANGE("Document No.", "Document No.");
                    ILE.SETRANGE("Document Type", ILE."Document Type"::"Sales Return Receipt");
                    IF ILE.FindFirst() then begin
                        ValueEntry.Reset();
                        ValueEntry.SetRange("Item Ledger Entry No.", ILE."Entry No.");
                        ValueEntry.SetRange("Document Type", ValueEntry."Document Type"::"Sales Credit Memo");
                        IF ValueEntry.FindFirst() then begin
                            SCH.Reset();
                            SCH.SetRange("No.", ValueEntry."Document No.");
                            IF SCH.FindFirst() then begin
                                SCL.Reset();
                                SCL.SetRange("Document No.", SCH."No.");
                                IF SCL.FindFirst() then;

                            end;
                        end;
                    end;

                    CLEAR(EINVDETILS);
                    IF SCH."Nature of Supply" = SCH."Nature of Supply"::B2B THEN BEGIN
                        EINVDETILS.RESET;
                        EINVDETILS.SETRANGE("Document No.", SCH."No.");
                        IF EINVDETILS.FINDFIRST THEN BEGIN
                            IF EINVDETILS."E-Invoice IRN No." <> '' THEN
                                IF EINVDETILS.CALCFIELDS("E-Invoice QR Code") THEN;
                        END;
                    END;
                    //Nirmal
                    /*
                    CGSTRate := 0;//"Return Receipt Line"."GST %/2; //PCPL/MIG/NSW
                    CGSTAmt := 0;//"Return Receipt Line"."Total GST Amount" / 2; //PCPL/MIG/NSW
                    SGSTAmt := 0;//"Return Receipt Line"."Total GST Amount" /2; //PCPL/MIG/NSW
                                 //END
                                 //ELSE IF ("Return Receipt Line"."GST Jurisdiction Type" = "Return Receipt Line"."GST Jurisdiction Type"::Interstate) THEN BEGIN

                    IGSTRate := 0;//"Return Receipt Line"."GST %"; //PCPL/MIG/NSW
                    IGSTAmt := 0;//"Return Receipt Line"."Total GST Amount"; //PCPL/MIG/NSW
                                 //END;
                                 //>>PCPL/BPPL/010
                    */
                    GLE.RESET;
                    GLE.SETRANGE(GLE."Document No.", ValueEntry."Document No.");
                    GLE.SETRANGE(GLE."Transaction Type", GLE."Transaction Type"::Sales);
                    //GLE.SETRANGE("Document Line No.", ValueEntry."Line No.");
                    IF GLE.FindSet THEN
                        repeat
                            IF GLE."GST Component Code" = 'CGST' THEN BEGIN
                                //CGST := ABS(GLE."GST Amount") / 2;
                                CGSTAmt := ABS(GLE."GST Amount");
                                CGSTRate := (GLE."GST %");
                            END
                            ELSE
                                IF GLE."GST Component Code" = 'IGST' THEN BEGIN
                                    IGSTAmt := ABS(GLE."GST Amount");
                                    IGSTRate := GLE."GST %";
                                END
                                ELSE
                                    IF GLE."GST Component Code" = 'SGST' THEN BEGIN
                                        // SGST := ABS(GLE."GST Amount") / 2;
                                        SGSTAmt := ABS(GLE."GST Amount");
                                        SGSTRate := (GLE."GST %");
                                    END;
                        until GLE.Next = 0;


                    CGSTTotal += CGSTAmt;
                    SGSTTotal += SGSTAmt;
                    IGSTTotal += IGSTAmt;

                    Total1 := CGSTTotal + SGSTTotal + IGSTTotal;


                end;

                trigger OnPreDataItem();
                begin
                    CGSTAmt := 0;
                    SGSTAmt := 0;
                    IGSTAmt := 0;
                    CGSTRate := 0;
                    SGSTRate := 0;
                    IGSTRate := 0;
                end;
            }
            dataitem("Posted Invt. Put-away Header"; "Posted Invt. Put-away Header")
            {
                DataItemLink = "Source No." = FIELD("No.");
                dataitem("Posted Invt. Put-away Line"; "Posted Invt. Put-away Line")
                {
                    DataItemLink = "No." = FIELD("No.");
                    column(AmountInWords; AmountInWords[1])
                    {
                    }
                    column(Sr_No; Sr_No)
                    {
                    }
                    column(Description_PostedInvtPutawayLine; "Posted Invt. Put-away Line".Description)
                    {
                    }
                    column(LotNo_PostedInvtPutawayLine; "Posted Invt. Put-away Line"."Lot No.")
                    {
                    }
                    column(ManufacturingDate_PostedInvtPutawayLine; "Posted Invt. Put-away Line"."Manufacturing Date")
                    {
                    }
                    column(ExpirationDate_PostedInvtPutawayLine; "Posted Invt. Put-away Line"."Expiration Date")
                    {
                    }
                    column(Quantity_PostedInvtPutawayLine; "Posted Invt. Put-away Line".Quantity)
                    {
                    }
                    column(UnitofMeasureCode_PostedInvtPutawayLine; "Posted Invt. Put-away Line"."Unit of Measure Code")
                    {
                    }
                    column(ReasonCode_PostedInvtPutawayLine; ReasonDes)
                    {
                    }
                    column(UnitPrice; UnitPrice)
                    {
                    }
                    column(DiscountPercent; DiscountPercent)
                    {
                    }
                    column(LineDiscAmt; LineDiscAmt)
                    {
                    }
                    column(FinalLineAmt; FinalLineAmt)
                    {
                    }
                    column(ManDate; ManDate)
                    {
                    }
                    column(ExpDate; ExpDate)
                    {
                    }


                    trigger OnAfterGetRecord()
                    var
                        AmtInWords: Codeunit "Amount In Words";
                    begin
                        Sr_No += 1;

                        //CCIT-JAGA 07/12/2018
                        CLEAR(ReasonDes);
                        IF RecReasonCode.GET("Posted Invt. Put-away Line"."Reason Code") THEN
                            ReasonDes := RecReasonCode.Description;
                        //CCIT-JAGA 07/12/2018

                        RecRRL.RESET;
                        RecRRL.SETRANGE(RecRRL."Return Order No.", "Source No.");
                        RecRRL.SETRANGE(RecRRL."No.", "Item No.");
                        IF RecRRL.FINDFIRST THEN BEGIN
                            UnitPrice := RecRRL."Unit Price";
                            DiscountPercent := RecRRL."Line Discount %";
                        END;

                        LineAmount := "Posted Invt. Put-away Line".Quantity * UnitPrice;
                        LineDiscAmt := LineAmount * (DiscountPercent / 100);
                        FinalLineAmt := LineAmount - LineDiscAmt;

                        TotFinalAmt := TotFinalAmt + FinalLineAmt;

                        Total11 := Total1 + TotFinalAmt - DiscountAmt;

                        //MESSAGE('%1  %2   %3',DiscountAmt,Total1,Total11);

                        //---
                        //recCheck.InitTextVariable;
                        //recCheck.FormatNoText(AmountInWords, ROUND(Total11), '');
                        AmtInWords.InitTextVariable();
                        AmtInWords.FormatNoText(AmountinWords, Round(Total11), '');
                        //---
                        //Message('Exp Date & Man Date');
                        RecILE.Reset();
                        RecILE.SetRange("Item No.", "Item No.");
                        RecILE.SetRange("Lot No.", "Lot No.");
                        if RecILE.FindFirst then begin
                            ManDate := RecILE."Warranty Date";
                            ExpDate := RecILE."Expiration Date";


                        end;

                    end;

                }
            }

            trigger OnAfterGetRecord();
            begin
                CIN_N0 := CompanyInfo1."CIN No.";

                IF "Return Receipt Header"."Applies-to Doc. No." <> '' THEN
                    IF RecPSI.GET("Return Receipt Header"."Applies-to Doc. No.") THEN BEGIN
                        RefDt := RecPSI."Posting Date";
                        RefNo := "Return Receipt Header"."Applies-to Doc. No.";
                    END;

                IF "Return Receipt Header"."Tally Invoice No." <> '' THEN
                    RefNo := "Return Receipt Header"."Tally Invoice No.";

                RecSCMH.RESET;
                RecSCMH.SETRANGE(RecSCMH."Return Order No.", "Return Order No.");
                IF RecSCMH.FINDFIRST THEN
                    RecSCMH.CALCFIELDS(RecSCMH."Invoice Discount Amount");
                DiscountAmt := RecSCMH."Invoice Discount Amount";

                RecCust.RESET;
                IF RecCust.GET("Return Receipt Header"."Sell-to Customer No.") THEN BEGIN
                    StateCode := RecCust."State Code";
                    CountryCode := RecCust."Country/Region Code";
                    CustRegNo := RecCust."GST Registration No.";
                    OutletName := RecCust."Business Format / Outlet Name";
                    Cust_FSSAINo := RecCust."FSSAI License No";
                    Cust_PANNo := RecCust."P.A.N. No.";
                END;

                RecState.RESET;
                IF RecState.GET(StateCode) THEN
                    StateName := RecState.Description;

                RecCountry.RESET;
                IF RecCountry.GET(CountryCode) THEN
                    CountryName := RecCountry.Name;

                RecSalesperson.RESET;
                IF RecSalesperson.GET("Salesperson Code") THEN
                    SalesPerName := RecSalesperson.Name;

                RecLoc.RESET;
                IF RecLoc.GET("Return Receipt Header"."Location Code") THEN BEGIN
                    PhoneNo := RecLoc."Phone No.";
                    E_Mail := RecLoc."E-Mail";
                    Loc_Name := RecLoc.Name;
                    Loc_Addr1 := RecLoc.Address;
                    Loc_Addr2 := RecLoc."Address 2";
                    Loc_city := RecLoc.City;
                    Loc_country := RecLoc.County;
                    Loc_GSTNo := RecLoc."GST Registration No.";
                    Loc_PostCode := RecLoc."Post Code";
                    Loc_FSSAINo := RecLoc."FSSAI No";
                    Loc_PANNo := RecLoc."P.A.N No";
                END;
                //CCIT-SG-21022019
                RecSalesCrMemoHead.RESET;
                RecSalesCrMemoHead.SETRANGE(RecSalesCrMemoHead."Return Order No.", "Return Receipt Header"."Return Order No.");
                IF RecSalesCrMemoHead.FINDFIRST THEN
                    DocNo := RecSalesCrMemoHead."No.";
                //CCIT-SG-21022019
            end;

            trigger OnPreDataItem();
            begin
                CLEAR(PhoneNo);
                CLEAR(E_Mail);
                CLEAR(DiscountAmt);
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
        GLSetup.GET;
        SalesSetup.GET;
        CASE SalesSetup."Logo Position on Documents" OF
            SalesSetup."Logo Position on Documents"::"No Logo":
                ;
            SalesSetup."Logo Position on Documents"::Left:
                BEGIN
                    CompanyInfo1.GET;
                    CompanyInfo1.CALCFIELDS(Picture);
                END;
            SalesSetup."Logo Position on Documents"::Center:
                BEGIN
                    CompanyInfo2.GET;
                    CompanyInfo2.CALCFIELDS(Picture);
                END;
            SalesSetup."Logo Position on Documents"::Right:
                BEGIN
                    CompanyInfo3.GET;
                    CompanyInfo3.CALCFIELDS(Picture);
                END;
        END;
    end;

    trigger OnPreReport();
    begin

        Sr_No := 0;

        CLEAR(LineAmount);
        CLEAR(LineDiscAmt);
        CLEAR(FinalLineAmt);
        CLEAR(TotFinalAmt);
        CLEAR(Total11);
        CLEAR(CGSTTotal);
        CLEAR(SGSTTotal);
        CLEAR(IGSTTotal);

        RecComp.GET;
        RecComp.CALCFIELDS(Picture);
    end;

    var
        CIN_N0: Code[25];
        Loc_Name: Text[50];
        Sr_No: Integer;
        RecComp: Record 79;
        GLSetup: Record 98;
        SalesSetup: Record 311;
        CompanyInfo1: Record 79;
        CompanyInfo2: Record 79;
        CompanyInfo3: Record 79;
        RecRRL: Record 6661;
        UnitPrice: Decimal;
        DiscountPercent: Decimal;
        RecCust: Record 18;
        StateCode: Code[10];
        CountryCode: Code[10];
        RecState: Record State;
        RecCountry: Record 9;

        StateName: Text[50];
        CountryName: Text[50];
        CustRegNo: Code[15];
        OutletName: Text[100];
        RecSalesperson: Record 13;
        SalesPerName: Text[50];
        CGSTAmt: Decimal;
        SGSTAmt: Decimal;
        IGSTAmt: Decimal;
        CGSTRate: Decimal;
        SGSTRate: Decimal;
        IGSTRate: Decimal;
        CGSTTotal: Decimal;
        SGSTTotal: Decimal;
        IGSTTotal: Decimal;
        Total1: Decimal;
        recCheck: Report 1401;
        AmountInWords: array[2] of Text[1024];
        LineAmount: Decimal;
        LineDiscAmt: Decimal;
        FinalLineAmt: Decimal;
        TotFinalAmt: Decimal;
        Total11: Decimal;
        RecLoc: Record 14;
        PhoneNo: Text[30];
        E_Mail: Text[80];
        RecSCMH: Record 114;
        DiscountAmt: Decimal;
        Cust_PANNo: Code[20];
        Loc_Addr1: Text[200];
        Loc_Addr2: Text[200];
        Loc_city: Text[20];
        Loc_country: Text[20];
        Loc_PANNo: Code[20];
        Loc_PostCode: Code[20];
        Loc_GSTNo: Code[15];
        Loc_FSSAINo: Code[20];
        Cust_FSSAINo: Code[20];
        RecReasonCode: Record 231;
        ReasonDes: Text[50];
        RecSalesCrMemoHead: Record 114;
        DocNo: Code[20];
        RecPSI: Record 112;
        RefDt: Date;
        RefNo: Code[50];
        RecILE: Record 32;
        ManDate: Date;
        ExpDate: Date;
        GLE: Record "Detailed GST Ledger Entry";
        ILE: Record 32;
        ValueEntry: Record "Value Entry";
        EINVDETILS: Record 50007;
        SCH: Record "Sales Cr.Memo Header";
        SCL: Record "Sales Cr.Memo Line";





}

