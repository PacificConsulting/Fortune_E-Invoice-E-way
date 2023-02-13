pageextension 50299 "Posted_sales_Inv_ext EINV" extends "Posted Sales Invoice"
{
    // version NAVW19.00.00.48466,NAVIN9.00.00.48466

    layout
    {
        modify("Your Reference")
        {
            Caption = 'Pay Reference';
        }
        addafter(General)
        {
            group("Einvoice Details")
            {
                part("E-Invoice Detail"; "E-Invoice Detail")
                {

                    SubPageLink = "Document No." = FIELD("No.");
                    ApplicationArea = all;
                }
            }
            group("E-way Bill Data")
            {
                field("E-Way Bill Generate"; "E-Way Bill Generate")
                {
                    ApplicationArea = all;

                }

            }
            group("E-Way Bill Details")
            {
                part("E-Way Bill Detail"; "E-Way Bill Detail")
                {
                    ApplicationArea = all;
                    SubPageLink = "Document No." = field("No.");

                }
            }

        }


    }
    actions
    {
        modify("Generate E-Invoice")
        {
            Visible = false;
        }
        modify("Import E-Invoice Response")
        {
            Visible = false;
        }
        modify("Cancel E-Invoice")
        {
            Visible = false;
        }
        modify("Generate IRN")
        {
            Visible = false;
        }

        addfirst("F&unctions")
        {
            action("TAX INVIOCE")
            {
                Caption = 'TAX INVIOCE';
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = New;
                ApplicationArea = all;
                Image = print;

                trigger OnAction();
                var
                    WebPrint: DotNet DefaultPrinterNew;
                begin
                    WebPrint.SetDefaultPrinter();
                    RecTSH.RESET;
                    RecTSH.SETRANGE(RecTSH."No.", "No.");
                    REPORT.RUNMODAL(50000, TRUE, FALSE, RecTSH);

                end;
            }
            action("Sales Debit Note")
            {
                Caption = 'Sales Debit Note';
                ApplicationArea = all;
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = New;
                Image = Print;

                trigger OnAction();
                begin
                    //CCIT-Harshal 28-09-2018
                    RSIH.RESET;
                    RSIH.SETRANGE(RSIH."No.", "No.");
                    REPORT.RUNMODAL(50078, TRUE, FALSE, RSIH);
                    //CCIT-Harshal 28-09-2018
                end;
            }
        }
        addafter(Dimensions)
        {
            action("Generate E-Invoice New")
            {
                Enabled = EINVGen;
                Image = ExportFile;
                Promoted = true;
                PromotedCategory = Process;
                ApplicationArea = all;
                Caption = 'Generate E-Invoice New';

                trigger OnAction();
                var
                    EwayBillGT: DotNet EInvTokenController;
                    EwayBillGEI: DotNet EInvController;
                    token: Text;
                    result: Text;
                    transactiondetails: Text;
                    documentdetails: Text;
                    sellerdetails: Text;
                    buyerdetails: Text;
                    dispatchdetails: Text;
                    shipdetails: Text;
                    exportdetails: Text;
                    paymentdetails: Text;
                    referencedetails: Text;
                    valuedetails: Text;
                    itemlist: Text;
                    CompanyInformation: Record 79;
                    Customer: Record 18;
                    DetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry";
                    SalesInvoiceLine: Record 113;
                    cgstrate: Integer;
                    sgstrate: Integer;
                    igstrate: Integer;
                    cessrate: Integer;
                    CGSTAmt: Decimal;
                    SGSTAmt: Decimal;
                    IGSTAmt: Decimal;
                    CESSGSTAmt: Decimal;
                    totaltaxableamt: Decimal;
                    totalcessnonadvolvalue: Decimal;
                    totalinvoicevalue: Decimal;
                    totalcessvalueofstate: Decimal;
                    totaldiscount: Decimal;
                    totalothercharge: Decimal;
                begin
                    //PCPL41-EINV
                    IF NOT CONFIRM('Do you want generate E-Invoice?') THEN
                        EXIT;
                    GenerateEInvoice;
                    //PCPL41-EINV
                end;
            }
            action("Cancel E-Invoice New")
            {
                Enabled = EINVCan;
                Image = Cancel;
                Promoted = true;
                PromotedCategory = Process;
                ApplicationArea = all;
                Caption = 'Cancel E-Invoice New';

                trigger OnAction();
                begin
                    //PCPL41-EINV
                    IF NOT CONFIRM('Do you want Cancel E-Invoice?') THEN
                        EXIT;
                    CancelEInvoice;
                    //PCPL41-EINV
                end;
            }
            action("Open EWAY Bill Page")
            {
                Image = open;
                Promoted = true;
                PromotedCategory = Process;
                ApplicationArea = all;
                Caption = 'Open EWAY Bill Page';
                trigger OnAction()
                var
                    EwayPage: Page 50105;
                    SIH: Record 112;
                begin
                    SIH.Reset();
                    SIH.SetRange("No.", "No.");
                    IF SIH.FindFirst() then begin
                        EwayPage.SetTableView(SIH);
                        EwayPage.RunModal();
                    end;
                end;
            }
            // action("Generate E-Way Bill")
            // {
            //     // Enabled = EWAYGEN;
            //     Image = "Action";
            //     Promoted = true;
            //     PromotedCategory = Process;
            //     ApplicationArea = all;
            //     Caption = 'Generate E-Way Bill';

            //     trigger OnAction();
            //     var
            //     // SalesPost: Codeunit 80;
            //     begin
            //         //PCPL41-EWAY
            //         IF NOT CONFIRM('Do you want generate E-Way Bill?') THEN
            //             EXIT;
            //         SalesInvHeader.Reset();
            //         SalesInvHeader.SetRange(SalesInvHeader."No.", "No.");
            //         IF SalesInvHeader.FindFirst() then begin
            //             SalesInvHeader."E-Way Bill Generate" := "E-Way Bill Generate"::"To Generate";
            //             SalesInvHeader.Modify();
            //         end;

            //         IF Rec."E-Way Bill Generate" = Rec."E-Way Bill Generate"::"To Generate" THEN
            //             CheckEwaybill_returnV
            //         ELSE
            //             ERROR('E-way Bill Generate should be "To Generate".');
            //         //PCPL41-EWAY
            //     end;
            // }
            // action("Generate E-Way (Not in use)")
            // {
            //     //Enabled = EWAYGEN;
            //     Image = "Action";
            //     Visible = false;

            //     trigger OnAction();
            //     var
            //     //SalesPost: Codeunit 80;
            //     begin
            //         //PCPL41-EWAY
            //         // IF NOT CONFIRM('Do you want generate E-Way Bill?') THEN
            //         //     EXIT;
            //         // IF Rec."E-Way Bill Generate" = Rec."E-Way Bill Generate"::"To Generate" THEN
            //         //     SalesPost.Ewaybill_returnV(Rec)
            //         // ELSE
            //         //     ERROR('E-way Bill Generate should be "To Generate".');
            //         //PCPL41-EWAY
            //     end;
            // }

        }


    }

    var
        RecTSH: Record 112;
        SalesPersonName: Text[50];
        RecSP: Record 13;
        RSIH: Record 112;
        "--------------------------": Integer;
        GlobalNULL: Variant;
        bbbb: Text;
        RecLocation: Record 14;
        //GSTManagement: Codeunit 16401;
        LRNo: Text;
        lrDate: Text;
        mont: Text;
        PDate: Text;
        Dt: Text;
        JsonString: Text;
        // GSTEInvoice: Codeunit 50008;
        //recAuthData: Record 50037;
        recGSTRegNos: Record "GST Registration Nos.";
        genledSetup: Record 98;
        signedData: Text;
        decryptedIRNResponse: Text;
        cnlrem: Text;


    //Unsupported feature: CodeModification on "OnAfterGetRecord". Please convert manually.

    trigger OnAfterGetRecord();
    begin
        //CCIT-JAGA
        CLEAR(SalesPersonName);
        IF RecSP.GET("Salesperson Code") THEN
            SalesPersonName := RecSP.Name;
        //CCIT-JAGA
    end;

    local procedure GenerateEInvoice();
    var
        EInvGT: DotNet EInvTokenController;
        EInvGEI: DotNet EInvController;
        token: Text;
        result: Text;
        resresult: Text;
        resresult1: Text;
        resresult2: Text;
        resresult3: Text;
        resresult4: Text;
        transactiondetails: Text;
        documentdetails: Text;
        sellerdetails: Text;
        buyerdetails: Text;
        dispatchdetails: Text;
        shipdetails: Text;
        exportdetails: Text;
        paymentdetails: Text;
        referencedetails: Text;
        AddDocDetails: Text;
        valuedetails: Text;
        EwayBillDetails: Text;
        itemlist: Text;
        Document_Date: Text;
        CompanyInformation: Record 79;
        Location: Record 14;
        State: Record State;
        LocPhoneNo: Text;
        Customer: Record 18;
        BuyState: Record State;
        CustPhoneNo: Text;
        ShiptoAddress: Record 222;
        ShipState: Record State;
        GeneralLedgerSetup: Record 98;
        FileMgt: Codeunit 419;
        //TempBlob: Record 99008535;  //PCPL/NSW/030522 Not Worked in BC 19
        tempB: Record "Tenant Media";
        //<<PCPL/NSW/030522
        TempBlob1: Codeunit "Temp Blob";
        Outs: OutStream;
        IntS: InStream;
        //>>PCPL/NSW/030522
        ServerFileNameTxt: Text;
        ClientFileNameTxt: Text;
        EInvoiceDetail: Record 50007;
        EINVPos: Text;
        GSTRate: Decimal;
        SalesInvoiceLine: Record 113;
        DetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry";
        cgstrate: Decimal;
        sgstrate: Decimal;
        igstrate: Decimal;
        cessrate: Decimal;
        CGSTAmt: Decimal;
        SGSTAmt: Decimal;
        IGSTAmt: Decimal;
        CESSGSTAmt: Decimal;
        TotalCGSTAmt: Decimal;
        TotalSGSTAmt: Decimal;
        TotalIGSTAmt: Decimal;
        TotalCessGSTAmt: Decimal;
        totaltaxableamt: Decimal;
        totalcessnonadvolvalue: Decimal;
        totalinvoicevalue: Decimal;
        totalcessvalueofstate: Decimal;
        totaldiscount: Decimal;
        totalothercharge: Decimal;
        TotalItemValue: Decimal;
        IsService: Text;
        RoundOff: Decimal;
        SLI: Record 113;
        Item: Record 27;
        EinvState: Text;
        Natureofsupply: Text;
        ExpCustomer: Record 18;
        //<<PCPL/NSW/EINV 052522
        TaxRecordID: RecordId;
        SalesInvLineNew: Record 113;
        ComponentJobject: JsonObject;
        TCSAMTLinewise: Decimal;
        GSTBaseAmtLineWise: Decimal;
    //>>PCPL/NSW/EINV 052522
    begin
        //PCPL41-EINV
        CLEAR(Natureofsupply);
        ExpCustomer.GET("Sell-to Customer No.");
        IF "GST Customer Type" = "GST Customer Type"::Export THEN BEGIN
            Natureofsupply := 'EXPWOP';
            transactiondetails := Natureofsupply + '!' + 'N' + '!' + '' + '!' + 'N';
        END ELSE
            IF ExpCustomer."GST Customer Type" = ExpCustomer."GST Customer Type"::"SEZ Unit" THEN BEGIN
                Natureofsupply := 'SEZWOP';
                transactiondetails := Natureofsupply + '!' + 'N' + '!' + '' + '!' + 'N';
            END ELSE
                transactiondetails := FORMAT("Nature of Supply") + '!' + 'N' + '!' + '' + '!' + 'N';


        Document_Date := FORMAT("Posting Date", 0, '<Day,2>/<Month,2>/<year4>');
        documentdetails := 'INV' + '!' + "No." + '!' + Document_Date;

        CompanyInformation.GET;
        Location.GET("Location Code");
        State.GET(Location."State Code");
        LocPhoneNo := DELCHR(Location."Phone No.", '=', '!|@|#|$|%|^|&|*|/|''|\|-| |(|)');
        sellerdetails := Location."GST Registration No." + '!' + CompanyInformation.Name + '!' + Location.Name + '!' + Location.Address + '!' + Location."Address 2" + '!' +
        "Location Code" + '!' + Location."Post Code" + '!' + State."State Code (GST Reg. No.)" + '!' + LocPhoneNo + '!' + Location."E-Mail";

        dispatchdetails := Location.Name + '!' + Location.Address + '!' + Location."Address 2" + '!' + "Location Code" + '!' + Location."Post Code" + '!' + State.Description;

        Customer.GET("Sell-to Customer No.");
        IF BuyState.GET(Customer."State Code") THEN
            CustPhoneNo := DELCHR(Customer."Phone No.", '=', '!|@|#|$|%|^|&|*|/|''|\|-| |(|)');
        buyerdetails := Customer."GST Registration No." + '!' + Customer.Name + '!' + Customer."Name 2" + '!' + Customer.Address + '!' + Customer."Address 2" + '!' +
        Customer.City + '!' + Customer."Post Code" + '!' + BuyState."State Code (GST Reg. No.)" + '!' + BuyState.Description + '!' + CustPhoneNo + '!' +
        Customer."E-Mail";

        //PCPL 38
        IF ExpCustomer."GST Customer Type" = ExpCustomer."GST Customer Type"::Export THEN BEGIN//PCPL50 begin and else if end
            IF ExpCustomer."State Code" = '' THEN
                buyerdetails := 'URP' + '!' + Customer.Name + '!' + Customer."Name 2" + '!' + Customer.Address + '!' + Customer."Address 2" + '!' +
                Customer.City + '!' + '999999' + '!' + '96' + '!' + '96' + '!' + CustPhoneNo + '!' +
                Customer."E-Mail";
            //PCPL 38
        END
        ELSE
            IF ExpCustomer."GST Customer Type" <> ExpCustomer."GST Customer Type"::Export THEN BEGIN //PCPL0017-21-09-2021
                SLI.RESET;
                SLI.SETRANGE("Document No.", "No.");
                IF SLI.FINDFIRST THEN
                    REPEAT
                        IF (SLI.Type <> SLI.Type::" ") AND (SLI.Quantity <> 0) THEN BEGIN
                            IF SLI."GST Place of Supply" = SLI."GST Place of Supply"::"Ship-to Address" THEN
                                IF "Ship-to Code" <> '' THEN
                                    ShiptoAddress.RESET;
                            ShiptoAddress.SETRANGE(ShiptoAddress.Code, Rec."Ship-to Code");
                            ShiptoAddress.SETRANGE(ShiptoAddress."Customer No.", Rec."Sell-to Customer No.");
                            IF ShiptoAddress.FINDFIRST THEN BEGIN
                                ShipState.GET(ShiptoAddress.State);
                                CustPhoneNo := DELCHR(ShiptoAddress."Phone No.", '=', '!|@|#|$|%|^|&|*|/|''|\|-| |(|)');
                                buyerdetails := ShiptoAddress."GST Registration No." + '!' + ShiptoAddress.Name + '!' + ShiptoAddress."Name 2" + '!' + ShiptoAddress.Address + '!' + ShiptoAddress."Address 2" + '!' +
                                ShiptoAddress.City + '!' + ShiptoAddress."Post Code" + '!' + ShipState."State Code (GST Reg. No.)" + '!' + ShipState.Description + '!' + CustPhoneNo + '!' +
                                ShiptoAddress."E-Mail";
                            END;
                        END;
                    UNTIL SLI.NEXT = 0;
            END;  //PCPL50 begin and else if end
                  /*
                  Customer.GET("Sell-to Customer No.");
                  BuyState.GET(Customer."State Code");
                  CustPhoneNo := DELCHR(Customer."Phone No.",'=','!|@|#|$|%|^|&|*|/|''|\|-| |(|)');
                  buyerdetails := Customer."GST Registration No."+'!'+Customer.Name+'!'+Customer."Name 2"+'!'+Customer.Address+'!'+Customer."Address 2"+'!'+
                  Customer.City+'!'+Customer."Post Code"+'!'+BuyState."State Code (GST Reg. No.)"+'!'+BuyState.Description+'!'+CustPhoneNo+'!'+
                  Customer."E-Mail";
                  */
                  //PCPL0017-21-09-2021
        IF (ExpCustomer."GST Customer Type" = ExpCustomer."GST Customer Type"::Export) THEN BEGIN //PCPL0017-21-09-2021
            shipdetails := 'URP' + '!' + Customer.Name + '!' + Customer."Name 2" + '!' + Customer.Address + '!' + Customer."Address 2" + '!' +
            Customer.City + '!' + '999999' + '!' + '96';
        END ELSE //PCPL50 begin and else if end
            IF (ExpCustomer."GST Customer Type" <> ExpCustomer."GST Customer Type"::Export) THEN BEGIN //PCPL0017-21-09-2021
                IF "Ship-to Code" <> '' THEN BEGIN
                    ShiptoAddress.RESET;
                    ShiptoAddress.SETRANGE(ShiptoAddress.Code, "Ship-to Code");
                    ShiptoAddress.SETRANGE(ShiptoAddress."Customer No.", "Sell-to Customer No.");
                    IF ShiptoAddress.FINDFIRST THEN BEGIN
                        ShipState.GET(ShiptoAddress.State);
                        shipdetails := ShiptoAddress."GST Registration No." + '!' + ShiptoAddress.Name + '!' + ShiptoAddress."Name 2" + '!' + ShiptoAddress.Address + '!' +
                        ShiptoAddress."Address 2" + '!' + ShiptoAddress.City + '!' + ShiptoAddress."Post Code" + '!' + ShipState.Description;
                    END
                END;
            END;//PCPL50 begin and else if end
        //PCPL0017-21-09-2021
        exportdetails := '';
        paymentdetails := '';
        referencedetails := '';
        AddDocDetails := '';
        EwayBillDetails := '';

        CLEAR(TotalCGSTAmt);
        CLEAR(TotalSGSTAmt);
        CLEAR(TotalIGSTAmt);
        CLEAR(TotalCessGSTAmt);
        CLEAR(totaltaxableamt);
        CLEAR(totalcessnonadvolvalue);
        CLEAR(totalinvoicevalue);
        CLEAR(totalcessvalueofstate);
        CLEAR(totaldiscount);
        CLEAR(totalothercharge);
        CLEAR(itemlist);
        Clear(TaxRecordID);
        Clear(TCSAMTLinewise);//PCPL/NSW/EINV 050522
        CLear(GSTBaseAmtLineWise);//PCPL/NSW/EINV 050522

        SalesInvoiceLine.RESET;
        SalesInvoiceLine.SETCURRENTKEY("Document No.");
        SalesInvoiceLine.SETRANGE("Document No.", "No.");
        SalesInvoiceLine.SETFILTER(Type, '<>%1', SalesInvoiceLine.Type::" ");
        SalesInvoiceLine.SETFILTER(Quantity, '<>%1', 0);
        //SalesInvoiceLine.SETFILTER(SalesInvoiceLine."Unit of Measure Code",'<>%1','');
        IF SalesInvoiceLine.FINDSET THEN
            REPEAT
                CLEAR(CGSTAmt);
                CLEAR(SGSTAmt);
                CLEAR(IGSTAmt);
                CLEAR(CESSGSTAmt);
                CLEAR(cgstrate);
                CLEAR(sgstrate);
                CLEAR(igstrate);
                CLEAR(cessrate);
                Clear(TCSAMTLinewise);//PCPL/NSW/EINV 050522
                Clear(GSTBaseAmtLineWise); //PCPL/NSW/EINV 050522


                IF ("Currency Code" = '') THEN BEGIN//PCPL50
                    DetailedGSTLedgerEntry.RESET;
                    DetailedGSTLedgerEntry.SETCURRENTKEY("Transaction Type", "Document Type", "Document No.", "Document Line No.");
                    DetailedGSTLedgerEntry.SETRANGE("Transaction Type", DetailedGSTLedgerEntry."Transaction Type"::Sales);
                    DetailedGSTLedgerEntry.SETRANGE("Document No.", SalesInvoiceLine."Document No.");
                    DetailedGSTLedgerEntry.SETRANGE("Document Line No.", SalesInvoiceLine."Line No.");
                    IF DetailedGSTLedgerEntry.FINDSET THEN
                        REPEAT
                            IF DetailedGSTLedgerEntry."GST Component Code" = 'CGST' THEN BEGIN
                                CGSTAmt := ABS(DetailedGSTLedgerEntry."GST Amount");
                                cgstrate := ABS(DetailedGSTLedgerEntry."GST %");
                            END ELSE
                                IF (DetailedGSTLedgerEntry."GST Component Code" = 'SGST') OR (DetailedGSTLedgerEntry."GST Component Code" = 'UTGST') THEN BEGIN
                                    SGSTAmt := ABS(DetailedGSTLedgerEntry."GST Amount");
                                    sgstrate := ABS(DetailedGSTLedgerEntry."GST %");
                                END ELSE
                                    IF DetailedGSTLedgerEntry."GST Component Code" = 'IGST' THEN BEGIN
                                        IGSTAmt := ABS(DetailedGSTLedgerEntry."GST Amount");
                                        igstrate := ABS(DetailedGSTLedgerEntry."GST %");
                                    END ELSE
                                        IF DetailedGSTLedgerEntry."GST Component Code" = 'CESS' THEN BEGIN
                                            CESSGSTAmt := ABS(DetailedGSTLedgerEntry."GST Amount");
                                            cessrate := DetailedGSTLedgerEntry."GST %";
                                        END;
                        UNTIL DetailedGSTLedgerEntry.NEXT = 0;

                    CLEAR(GSTRate);
                    IF (CGSTAmt <> 0) AND (SGSTAmt <> 0) THEN
                        GSTRate := cgstrate + sgstrate;
                    IF IGSTAmt <> 0 THEN
                        GSTRate := igstrate;
                    IF CESSGSTAmt <> 0 THEN
                        GSTRate := cessrate;

                    /* <<PCPL/NSW/030522
                    IF SalesInvoiceLine."GST Base Amount" = 0 THEN
                        totaltaxableamt += SalesInvoiceLine.Amount
                    ELSE
                        totaltaxableamt += SalesInvoiceLine."GST Base Amount";
                     //PCPL/NSW/030522 */

                    //<<PCPL/NSW/030522     
                    IF SalesInvoiceLine."Line Amount" = 0 then
                        totaltaxableamt += SalesInvoiceLine.Amount
                    ELSE
                        totaltaxableamt += SalesInvoiceLine."Line Amount";
                    //>>PCPL/NSW/030522     


                    TotalCGSTAmt += CGSTAmt;
                    TotalSGSTAmt += SGSTAmt;
                    TotalIGSTAmt += IGSTAmt;
                    TotalCessGSTAmt += CESSGSTAmt;
                    //<<PCPL/NSW/EINV 052522
                    if SalesInvLineNew.Get(SalesInvoiceLine."Document No.", SalesInvoiceLine."Line No.") then
                        TaxRecordID := SalesInvLineNew.RecordId();
                    TCSAMTLinewise := GetTcsAmtLineWise(TaxRecordID, ComponentJobject);
                    GSTBaseAmtLineWise := GetGSTBaseAmtLineWise(TaxRecordID, ComponentJobject);
                    //>>PCPL/NSW/EINV 052522

                    totalcessnonadvolvalue += 0;
                    TotalItemValue := SalesInvoiceLine."Line Amount" + CGSTAmt + SGSTAmt + IGSTAmt + CESSGSTAmt + TCSAMTLinewise;//SalesInvoiceLine."TDS/TCS Amount"; //PCPL/NSW/EINV 052522
                    totalinvoicevalue += SalesInvoiceLine."Line Amount" + CGSTAmt + SGSTAmt + IGSTAmt + CESSGSTAmt + TCSAMTLinewise;// SalesInvoiceLine."TDS/TCS Amount"; //PCPL/NSW/EINV 052522
                    totalcessvalueofstate += 0;
                    totaldiscount += SalesInvoiceLine."Line Discount Amount";
                    totalothercharge += 0;//SalesInvoiceLine."Charges To Customer"; //PCPL/NSW/030522 Code commented for Temp field not Exist in BC18
                END
                //  PCPL50 begin
                ELSE
                    IF ("Currency Code" <> '') OR (ExpCustomer."GST Customer Type" = ExpCustomer."GST Customer Type"::Export) THEN BEGIN
                        DetailedGSTLedgerEntry.RESET;
                        DetailedGSTLedgerEntry.SETCURRENTKEY("Transaction Type", "Document Type", "Document No.", "Document Line No.");
                        DetailedGSTLedgerEntry.SETRANGE("Transaction Type", DetailedGSTLedgerEntry."Transaction Type"::Sales);
                        DetailedGSTLedgerEntry.SETRANGE("Document No.", SalesInvoiceLine."Document No.");
                        DetailedGSTLedgerEntry.SETRANGE("Document Line No.", SalesInvoiceLine."Line No.");
                        IF DetailedGSTLedgerEntry.FINDSET THEN
                            REPEAT
                                IF DetailedGSTLedgerEntry."GST Component Code" = 'CGST' THEN BEGIN
                                    CGSTAmt := ABS(DetailedGSTLedgerEntry."GST Amount" / "Currency Factor");
                                    cgstrate := ABS(DetailedGSTLedgerEntry."GST %" / "Currency Factor");
                                END ELSE
                                    IF (DetailedGSTLedgerEntry."GST Component Code" = 'SGST') OR (DetailedGSTLedgerEntry."GST Component Code" = 'UTGST') THEN BEGIN
                                        SGSTAmt := ABS(DetailedGSTLedgerEntry."GST Amount" / "Currency Factor");
                                        sgstrate := ABS(DetailedGSTLedgerEntry."GST %" / "Currency Factor");
                                    END ELSE
                                        IF DetailedGSTLedgerEntry."GST Component Code" = 'IGST' THEN BEGIN
                                            IGSTAmt := ABS(DetailedGSTLedgerEntry."GST Amount" / "Currency Factor");
                                            igstrate := ABS(DetailedGSTLedgerEntry."GST %" / "Currency Factor");
                                        END ELSE
                                            IF DetailedGSTLedgerEntry."GST Component Code" = 'CESS' THEN BEGIN
                                                CESSGSTAmt := ABS(DetailedGSTLedgerEntry."GST Amount" / "Currency Factor");
                                                cessrate := (DetailedGSTLedgerEntry."GST %" / "Currency Factor");
                                            END;
                            UNTIL DetailedGSTLedgerEntry.NEXT = 0;

                        CLEAR(GSTRate);
                        IF (CGSTAmt <> 0) AND (SGSTAmt <> 0) THEN
                            GSTRate := ((cgstrate + sgstrate) / "Currency Factor");
                        IF IGSTAmt <> 0 THEN
                            GSTRate := (igstrate / "Currency Factor");
                        IF CESSGSTAmt <> 0 THEN
                            GSTRate := (cessrate / "Currency Factor");

                        //IF SalesInvoiceLine."GST Base Amount" = 0 THEN //PCPL/NSW/EINV 052522  Old Code Comment field not Exist in BC 19
                        IF GSTBaseAmtLineWise = 0 then //PCPL/NSW/EINV 052522 New Code Added
                            totaltaxableamt += (SalesInvoiceLine.Amount / "Currency Factor")
                        ELSE
                            totaltaxableamt += (GSTBaseAmtLineWise / "Currency Factor"); //PCPL/NSW/EINV 052522 New Code Added
                                                                                         //totaltaxableamt += (SalesInvoiceLine."GST Base Amount" / "Currency Factor"); //PCPL/NSW/EINV 052522  Old Code Comment field not Exist in BC 19

                        TotalCGSTAmt += (CGSTAmt / "Currency Factor");
                        TotalSGSTAmt += (SGSTAmt / "Currency Factor");
                        TotalIGSTAmt += (IGSTAmt / "Currency Factor");
                        TotalCessGSTAmt += (CESSGSTAmt / "Currency Factor");

                        totalcessnonadvolvalue += 0;
                        TotalItemValue := ((SalesInvoiceLine."Line Amount" + CGSTAmt + SGSTAmt + IGSTAmt + CESSGSTAmt + TCSAMTLinewise) / "Currency Factor"); //PCPL/NSW/EINV 050522
                        totalinvoicevalue += ((SalesInvoiceLine."Line Amount" + CGSTAmt + SGSTAmt + IGSTAmt + CESSGSTAmt + TCSAMTLinewise) / "Currency Factor"); //PCPL/NSW/EINV 050522
                        totalcessvalueofstate += 0;
                        totaldiscount += (SalesInvoiceLine."Line Discount Amount" / "Currency Factor");
                        totalothercharge += 0;// (SalesInvoiceLine."Charges To Customer" / "Currency Factor"); //PCPL/NSW/EINV 052522  Old Code Comment field not Exist in BC 19
                    END;
                //PCPL50 end

                IF SalesInvoiceLine."GST Group Type" = SalesInvoiceLine."GST Group Type"::Service THEN
                    IsService := 'Y'
                ELSE
                    IF SalesInvoiceLine."GST Group Type" = SalesInvoiceLine."GST Group Type"::Goods THEN
                        IsService := 'N';

                IF SalesInvoiceLine.Type = SalesInvoiceLine.Type::Item THEN
                    Item.GET(SalesInvoiceLine."No.");

                /*
                IF SalesInvoiceLine."Unit of Measure Code" = 'BL' THEN
                  UOM := 'OTH'
                ELSE IF SalesInvoiceLine."Unit of Measure Code" = 'KG' THEN
                  UOM := 'KGS'
                ELSE IF SalesInvoiceLine."Unit of Measure Code" = 'MT' THEN
                  UOM := 'MTS'
                ELSE
                  UOM := SalesInvoiceLine."Unit of Measure Code";
                */
                IF "Currency Code" = '' THEN BEGIN //PCPL50
                    CLEAR(RoundOff);
                    IF SalesInvoiceLine."No." = '502650' THEN
                        RoundOff := SalesInvoiceLine."Line Amount";
                END
                //PCPL50 begin
                ELSE
                    IF ("Currency Code" <> '') OR (ExpCustomer."GST Customer Type" = ExpCustomer."GST Customer Type"::Export) THEN BEGIN
                        CLEAR(RoundOff);
                        IF SalesInvoiceLine."No." = '502650' THEN
                            RoundOff := (SalesInvoiceLine."Line Amount" / "Currency Factor");
                    END;
                //PCPL50 end
                // IF SalesInvoiceLine.Type=SalesInvoiceLine.Type::Item then



                IF "Currency Code" = '' THEN BEGIN //PCPL50
                    IF (itemlist = '') AND (SalesInvoiceLine."No." <> '502650') THEN
                        itemlist := FORMAT(SalesInvoiceLine."Line No.") + '!' + Item."Description 2" + '!' + IsService + '!' + SalesInvoiceLine."HSN/SAC Code" + '!' + '' + '!' +
                        FORMAT(SalesInvoiceLine.Quantity) + '!' + '' + '!' + SalesInvoiceLine."Unit of Measure Code" + '!' + FORMAT(ROUND(SalesInvoiceLine."Unit Price", 0.01, '>')) + '!' +
                        FORMAT(SalesInvoiceLine."Line Amount") + '!' + '0' + '!' + FORMAT(SalesInvoiceLine."Line Discount Amount") + '!' + FORMAT(TCSAMTLinewise) +
                        '!' + FORMAT(GSTBaseAmtLineWise/*SalesInvoiceLine."Tax Base Amount"*/) + '!' +/*FORMAT(ROUND(SalesInvoiceLine."GST %",1,'='))*/FORMAT(GSTRate) + '!' + FORMAT(IGSTAmt) + '!' + FORMAT(CGSTAmt) + '!' +
                        FORMAT(SGSTAmt) + '!' + FORMAT(cessrate) + '!' + FORMAT(CESSGSTAmt) + '!' + '0' + '!' + '0' + '!' + '0' + '!' + '0' + '!' + FORMAT(TotalItemValue) +
                        '!' + '' + '!' + '' + '!' + '' + '!' + '' + '!' + '' + '!' + '' + '' + '!' + ''
                    ELSE
                        IF SalesInvoiceLine."No." <> '502650' THEN
                            itemlist := itemlist + ';' + FORMAT(SalesInvoiceLine."Line No.") + '!' + Item."Description 2" + '!' + IsService + '!' + SalesInvoiceLine."HSN/SAC Code" +
                            '!' + '' + '!' + FORMAT(SalesInvoiceLine.Quantity) + '!' + '' + '!' + SalesInvoiceLine."Unit of Measure Code" + '!' +
                            FORMAT(ROUND(SalesInvoiceLine."Unit Price", 0.01, '>')) + '!' + FORMAT(SalesInvoiceLine."Line Amount") + '!' + '0' + '!' +
                            FORMAT(SalesInvoiceLine."Line Discount Amount") + '!' + FORMAT(TCSAMTLinewise) + '!' + FORMAT(GSTBaseAmtLineWise/*SalesInvoiceLine."Tax Base Amount"*/) + '!' +
                            /*FORMAT(ROUND(SalesInvoiceLine."GST %",1,'='))*/FORMAT(GSTRate) + '!' + FORMAT(IGSTAmt) + '!' + FORMAT(CGSTAmt) + '!' + FORMAT(SGSTAmt) + '!' + FORMAT(cessrate) + '!' +
                            FORMAT(CESSGSTAmt) + '!' + '0' + '!' + '0' + '!' + '0' + '!' + '0' + '!' + FORMAT(TotalItemValue) + '!' + '' + '!' + '' + '!' + '' + '!' + '' + '!' + '' + '!' + '' +
                            '' + '!' + ''
                END
                ELSE
                    IF ("Currency Code" <> '') OR (ExpCustomer."GST Customer Type" = ExpCustomer."GST Customer Type"::Export) THEN BEGIN
                        IF (itemlist = '') AND (SalesInvoiceLine."No." <> '502650') THEN
                            itemlist := FORMAT(SalesInvoiceLine."Line No.") + '!' + Item."Description 2" + '!' + IsService + '!' + SalesInvoiceLine."HSN/SAC Code" + '!' + '' + '!' +
                            FORMAT(SalesInvoiceLine.Quantity) + '!' + '' + '!' + SalesInvoiceLine."Unit of Measure Code" + '!' + FORMAT(ROUND((SalesInvoiceLine."Unit Price" / "Currency Factor"), 0.01, '>')) + '!' +
                            FORMAT(SalesInvoiceLine."Line Amount" / "Currency Factor") + '!' + '0' + '!' + FORMAT(SalesInvoiceLine."Line Discount Amount" / "Currency Factor") + '!' + FORMAT(TCSAMTLineWise / "Currency Factor") +
                            '!' + FORMAT(GSTBaseAmtLineWise/*SalesInvoiceLine."Tax Base Amount" / "Currency Factor"*/) + '!' +/*FORMAT(ROUND(SalesInvoiceLine."GST %",1,'='))*/FORMAT(GSTRate) + '!' + FORMAT(IGSTAmt) + '!' + FORMAT(CGSTAmt) + '!' +
                            FORMAT(SGSTAmt) + '!' + FORMAT(cessrate) + '!' + FORMAT(CESSGSTAmt) + '!' + '0' + '!' + '0' + '!' + '0' + '!' + '0' + '!' + FORMAT(TotalItemValue) +
                            '!' + '' + '!' + '' + '!' + '' + '!' + '' + '!' + '' + '!' + '' + '' + '!' + ''
                        ELSE
                            IF SalesInvoiceLine."No." <> '502650' THEN
                                itemlist := itemlist + ';' + FORMAT(SalesInvoiceLine."Line No.") + '!' + Item."Description 2" + '!' + IsService + '!' + SalesInvoiceLine."HSN/SAC Code" +
                                '!' + '' + '!' + FORMAT(SalesInvoiceLine.Quantity) + '!' + '' + '!' + SalesInvoiceLine."Unit of Measure Code" + '!' +
                                FORMAT(ROUND((SalesInvoiceLine."Unit Price" / "Currency Factor"), 0.01, '>')) + '!' + FORMAT(SalesInvoiceLine."Line Amount" / "Currency Factor") + '!' + '0' + '!' +
                                FORMAT(SalesInvoiceLine."Line Discount Amount" / "Currency Factor") + '!' + FORMAT(TCSAMTLinewise / "Currency Factor") + '!' + FORMAT(GSTBaseAmtLineWise/*SalesInvoiceLine."Tax Base Amount" / "Currency Factor"*/) + '!' +
                                /*FORMAT(ROUND(SalesInvoiceLine."GST %",1,'='))*/FORMAT(GSTRate) + '!' + FORMAT(IGSTAmt) + '!' + FORMAT(CGSTAmt) + '!' + FORMAT(SGSTAmt) + '!' + FORMAT(cessrate) + '!' +
                                FORMAT(CESSGSTAmt) + '!' + '0' + '!' + '0' + '!' + '0' + '!' + '0' + '!' + FORMAT(TotalItemValue) + '!' + '' + '!' + '' + '!' + '' + '!' + '' + '!' + '' + '!' + '' +
                                '' + '!' + ''
                    END;
            UNTIL SalesInvoiceLine.NEXT = 0;

        valuedetails := FORMAT(totaltaxableamt) + '!' + FORMAT(TotalCGSTAmt) + '!' + FORMAT(TotalCGSTAmt) + '!' + FORMAT(TotalIGSTAmt) + '!' + FORMAT(TotalCessGSTAmt) + '!' +
        FORMAT(totalcessnonadvolvalue) + '!' + FORMAT(totalinvoicevalue) + '!' + FORMAT(totalcessvalueofstate) + '!' + FORMAT(RoundOff) + '!' + '0' + '!' + FORMAT(totaldiscount) + '!' +
        FORMAT(totalothercharge);

        GeneralLedgerSetup.GET;
        EInvGT := EInvGT.TokenController;
        token := EInvGT.GetToken(GeneralLedgerSetup."EINV Base URL", GeneralLedgerSetup."EINV User Name", GeneralLedgerSetup."EINV Password",
        GeneralLedgerSetup."EINV Client ID", GeneralLedgerSetup."EINV Client Secret", GeneralLedgerSetup."EINV Grant Type");
        MESSAGE(token);

        EInvGEI := EInvGEI.eInvoiceController;
        result := EInvGEI.GenerateEInvoice(GeneralLedgerSetup."EINV Base URL", token, Location."GST Registration No.", 'erp', transactiondetails,
        documentdetails, sellerdetails, buyerdetails, dispatchdetails, shipdetails, exportdetails, paymentdetails, referencedetails, AddDocDetails,
        valuedetails, EwayBillDetails, itemlist, GeneralLedgerSetup."EINV Path", "No.");
        MESSAGE(result);

        CLEAR(EINVPos);
        EINVPos := COPYSTR(result, 1, 8);

        IF EINVPos = 'SUCCESS;' THEN BEGIN
            resresult := CONVERTSTR(result, ';', ',');
            resresult1 := SELECTSTR(1, resresult);
            resresult2 := SELECTSTR(2, resresult);
            resresult3 := SELECTSTR(3, resresult);
            resresult4 := SELECTSTR(4, resresult);

            IF resresult1 = 'SUCCESS' THEN BEGIN
                IF NOT EInvoiceDetail.GET("No.") THEN BEGIN
                    EInvoiceDetail.INIT;
                    EInvoiceDetail."Document No." := "No.";
                    EInvoiceDetail."E-Invoice IRN No." := resresult2;
                    EInvoiceDetail."URL for PDF" := resresult4;

                    SLEEP(3000);
                    resresult3 := FileMgt.DownloadTempFile(resresult3);
                    SLEEP(5000);

                    //ServerFileNameTxt := FileMgt.UploadFileSilent(resresult3);
                    //FileMgt.BLOBImportFromServerFile(TempBlob, ServerFileNameTxt);//PCPL/NSW/030522 This Code is not work in BC 19
                    FileMgt.BLOBImportFromServerFile(TempBlob1, resresult3); //PCPL/MIG/NSW BC18 Customized code add coz above code not work in BC18
                    SLEEP(5000);

                    //<<PCPL/NSW/EINV 050522 New Code Added as compatible for BC 19
                    TempBlob1.CreateInStream(IntS);
                    EInvoiceDetail."E-Invoice QR Code".CreateOutStream(Outs);
                    CopyStream(Outs, IntS);
                    EInvoiceDetail."E-Invoice Acknowledgement Date Time" := CurrentDateTime;
                    //EInvoiceDetail.Modify();
                    //>>PCPL/NSW/EINV 050522


                    //EInvoiceDetail."E-Invoice QR Code" := TempBlob.Blob;//PCPL/NSW/030522 No Needed now  above code will assign Data to QR Field
                    EInvoiceDetail.INSERT;

                    /*
                   //<<PCPL/NSW/EINV 050522
                   UploadIntoStream('import File', '', '', resresult3, IntS);
                   TempBlob1.CreateOutStream(Outs);
                   Outs.WriteText(resresult3);
                   TempBlob1.CreateInStream(IntS);
                   DownloadFromStream(IntS, '', '', '', '');
                   //<<PCPL/NSW/EINV 050522
                   */

                    //FILE.ERASE(ServerFileNameTxt);

                    MESSAGE('E-Invoice has been generated.');
                END;

                IF EInvoiceDetail.GET("No.") THEN BEGIN
                    IF EInvoiceDetail."URL for PDF" = '' THEN BEGIN
                        EInvoiceDetail."URL for PDF" := resresult4;
                        EInvoiceDetail.MODIFY;
                    END;
                    MESSAGE('URL Added.');
                END;

            END;
        END ELSE
            ERROR(result);
        //PCPL41-EINV

    end;
    //PCPL/NSW/EINV 050522
    local procedure GetTcsAmtLineWise(TaxRecordID: RecordId; var JObject: JsonObject): Decimal
    var
        TaxTransactionValue: Record "Tax Transaction Value";
        TaxTypeObjHelper: Codeunit "Tax Type Object Helper";
        ComponentAmt: Decimal;
        JArray: JsonArray;
        ComponentJObject: JsonObject;
    begin
        if not GuiAllowed then
            exit;

        TaxTransactionValue.SetFilter("Tax Record ID", '%1', TaxRecordID);
        TaxTransactionValue.SetFilter("Value Type", '%1', TaxTransactionValue."Value Type"::Component);
        TaxTransactionValue.SetRange("Visible on Interface", true);
        TaxTransactionValue.SetRange("Tax Type", 'TCS');
        //if TaxTransactionValue.FindSet() then
        if TaxTransactionValue.FindFirst() then
            //repeat
            begin
            Clear(ComponentJObject);
            //ComponentJObject.Add('Component', TaxTransactionValue.GetAttributeColumName());
            //ComponentJObject.Add('Percent', ScriptDatatypeMgmt.ConvertXmlToLocalFormat(format(TaxTransactionValue.Percent, 0, 9), "Symbol Data Type"::NUMBER));
            ComponentAmt := TaxTypeObjHelper.GetComponentAmountFrmTransValue(TaxTransactionValue);
            //ComponentJObject.Add('Amount', ScriptDatatypeMgmt.ConvertXmlToLocalFormat(format(ComponentAmt, 0, 9), "Symbol Data Type"::NUMBER));
            JArray.Add(ComponentJObject);
        end;
        //        TCSAMTLinewise := ComponentAmt;
        //until TaxTransactionValue.Next() = 0;
        exit(ComponentAmt)

    end;

    local procedure GetGSTBaseAmtLineWise(TaxRecordID: RecordId; var JObject: JsonObject): Decimal
    var
        TaxTransactionValue: Record "Tax Transaction Value";
        TaxTypeObjHelper: Codeunit "Tax Type Object Helper";
        ComponentAmt: Decimal;
        JArray: JsonArray;
        ComponentJObject: JsonObject;
        ScriptDatatypeMgmt: Codeunit "Script Data Type Mgmt.";
    begin
        if not GuiAllowed then
            exit;

        TaxTransactionValue.SetFilter("Tax Record ID", '%1', TaxRecordID);
        TaxTransactionValue.SetFilter("Value Type", '%1', TaxTransactionValue."Value Type"::Component);
        TaxTransactionValue.SetRange("Visible on Interface", true);
        TaxTransactionValue.SetRange("Tax Type", 'GST');
        TaxTransactionValue.SetRange("Value ID", 10);
        //if TaxTransactionValue.FindSet() then
        if TaxTransactionValue.FindFirst() then
            //repeat
            begin
            Clear(ComponentJObject);
            ComponentJObject.Add('Component', TaxTransactionValue.GetAttributeColumName());
            ComponentJObject.Add('Percent', ScriptDatatypeMgmt.ConvertXmlToLocalFormat(format(TaxTransactionValue.Percent, 0, 9), "Symbol Data Type"::NUMBER));
            ComponentAmt := TaxTypeObjHelper.GetComponentAmountFrmTransValue(TaxTransactionValue);
            //ComponentJObject.Add('Amount', ScriptDatatypeMgmt.ConvertXmlToLocalFormat(format(ComponentAmt, 0, 9), "Symbol Data Type"::NUMBER));
            JArray.Add(ComponentJObject);
        end;
        exit(ComponentAmt)

    end;
    //PCPL/NSW/EINV 050522



    local procedure CancelEInvoice();
    var
        EInvGT: DotNet EInvTokenController;
        EInvGEC: DotNet EInvController;
        token: Text;
        result: Text;
        resresult: Text;
        resresult1: Text;
        resresult2: Text;
        GeneralLedgerSetup: Record 98;
        Location: Record 14;
        EInvoiceDetail: Record 50007;
        CancelPos: Text;
    begin
        //PCPL41-EINV
        IF EInvoiceDetail.GET("No.") THEN BEGIN
            GeneralLedgerSetup.GET;
            EInvGT := EInvGT.TokenController;
            token := EInvGT.GetToken(GeneralLedgerSetup."EINV Base URL", GeneralLedgerSetup."EINV User Name", GeneralLedgerSetup."EINV Password",
            GeneralLedgerSetup."EINV Client ID", GeneralLedgerSetup."EINV Client Secret", GeneralLedgerSetup."EINV Grant Type");

            Location.GET("Location Code");
            EInvGEC := EInvGEC.eInvoiceController;
            result := EInvGEC.CancelEInvoice(GeneralLedgerSetup."EINV Base URL", token, Location."GST Registration No.", EInvoiceDetail."E-Invoice IRN No.", EInvoiceDetail."Cancel Remark", '1',
            "No.", GeneralLedgerSetup."EINV Path");

            CLEAR(CancelPos);
            CancelPos := COPYSTR(result, 1, 2);

            IF CancelPos = 'Y;' THEN BEGIN
                resresult := CONVERTSTR(result, ';', ',');
                resresult1 := SELECTSTR(1, resresult);
                resresult2 := SELECTSTR(2, resresult);

                IF resresult1 = 'Y' THEN BEGIN
                    EInvoiceDetail."Cancel IRN No." := resresult2;
                    EInvoiceDetail."E-Invoice IRN No." := '';
                    CLEAR(EInvoiceDetail."E-Invoice QR Code");
                    CLEAR(EInvoiceDetail."URL for PDF");
                    EInvoiceDetail.MODIFY;
                    MESSAGE('E-Invoice has been cancelled');
                END;
            END ELSE
                ERROR(result);
        END;
        //PCPL41-EINV
    end;

    procedure CheckEwaybill_returnV();
    var
        Headerdata: Text;
        Linedata: Text;
        Cust: Record 18;
        PostedSalesLine: Record 113;
        Location_: Record 14;
        State_: Record State;
        StateCust: Record State;
        ShiptoCode: Record 222;
        ComInfo: Record 79;
        HSNSAN: Record "HSN/SAC";
        ShipQty: Decimal;
        cnt: Integer;
        Item_: Record 27;
        DetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry";
        CGSTAmt: Decimal;
        SGSTAmt: Decimal;
        IGSTAmt: Decimal;
        CESSGSTAmt: Decimal;
        CgstRate: Decimal;
        SgstRate: Decimal;
        IgstRate: Decimal;
        CESSgstRate: Decimal;
        TotalCGSTAmt: Decimal;
        TotalSGSTAmt: Decimal;
        TotalIGSTAmt: Decimal;
        TotalCESSGSTAmt: Decimal;
        Document_Date: Text;
        UOMeasure: Text;
        FromGST: Text;
        ToGST: Text;
        TotalTaxableAmt: Decimal;
        LineTaxableAmt: Decimal;
        LineInvoiceAmt: Decimal;
        Supply: Text;
        Subsupply: Text;
        SubSupplydescr: Text;
        PathText: Text;
        UomValue: Text;
        DocumentType: Text;
        EWayBillDetail1: Record 50008;
        GeneralLedgerSetup: Record 98;
        SalesInvLine: Record 113;
        TotaltaxableAmt1: Text;
        Ewaybill: DotNet Ewaybillcontroller;
        token: Text;
        result: Text;
        resresult: Text;
        resresult1: Text;
        resresult2: Text;
        Transport_Date: Text;
        consignee_gstin: Text;
        consignee_name: Text;
        consignee_address1: Text;
        consignee_address2: Text;
        consignee_place: Text;
        consignee_pincode: Text;
        consignee_StateofSupply: Text;
        consignee_StateName: Text;
        Ship_to_state: Record State;
        Recustomer: Record 18;
        RecshiptoAddress: Record 222;
        TotaltaxableAmtValue: Decimal;
        TotaltaxableAmtValue1: Text;
        SIH: Record 112;
        AmountToCustomer: Decimal;
        TotalGSTAmount: Decimal;
        //<<PCPL/NSW/EINV 052522
        SalesInvLineNewEway: Record 113;
        TaxRecordIDEWAY: RecordId;
        TCSAMTLinewiseEWAY: Decimal;
        GSTBaseAmtLineWiseEWAY: Decimal;
        ComponentJobjectEWAY: JsonObject;
        EWayBillDetail: Record 50008;
        SalesInvHeader: Record 112;

    //>>PCPL/NSW/EINV 052522
    //Nirmal
    begin
        //PCPL41-EWAY

        IF Cust.GET("Sell-to Customer No.") THEN;
        IF Location_.GET("Location Code") THEN;
        IF State_.GET(Location_."State Code") THEN;
        IF ShiptoCode.GET("Sell-to Customer No.", "Ship-to Code") THEN;
        IF Ship_to_state.GET(ShiptoCode.State) THEN;
        IF StateCust.GET(Cust."State Code") THEN;
        //PCPL0017
        IF "Ship-to Code" <> '' THEN BEGIN
            consignee_gstin := ShiptoCode."GST Registration No.";
        END ELSE
            consignee_gstin := Cust."GST Registration No.";
        IF "Ship-to Code" <> '' THEN BEGIN
            consignee_address1 := ShiptoCode.Address;
        END ELSE
            consignee_address1 := Cust.Address;
        IF "Ship-to Code" <> '' THEN BEGIN
            consignee_address2 := ShiptoCode."Address 2";
        END ELSE
            consignee_address2 := Cust."Address 2";
        IF "Ship-to Code" <> '' THEN BEGIN
            consignee_name := ShiptoCode.Name;
        END ELSE
            consignee_name := Cust.Name;
        IF "Ship-to Code" <> '' THEN BEGIN
            consignee_pincode := ShiptoCode."Post Code";
        END ELSE
            consignee_pincode := Cust."Post Code";
        IF "Ship-to Code" <> '' THEN BEGIN
            consignee_place := ShiptoCode.City;
        END ELSE
            consignee_place := Cust.City;
        IF "Ship-to Code" <> '' THEN BEGIN
            consignee_StateofSupply := Ship_to_state.Description;
        END ELSE
            consignee_StateofSupply := StateCust.Description;
        IF "Ship-to Code" <> '' THEN BEGIN
            consignee_StateName := Ship_to_state.Description;
        END ELSE
            consignee_StateName := StateCust.Description;


        IF SIH.get("No.") then;
        GetStatisticsPostedSalesInvAmount(SIH, TotalGSTAmount, AmountToCustomer);
        //CALCFIELDS("Amount to Customer");



        ShipQty := 0;
        LineTaxableAmt := 0;
        LineInvoiceAmt := 0;
        TotalIGSTAmt := 0;
        TotalCGSTAmt := 0;
        TotalTaxableAmt := 0;
        TotaltaxableAmtValue := 0;
        CLEAR(TotaltaxableAmtValue1);
        //<<PCPL/NSW/EINV 052522
        Clear(GSTBaseAmtLineWiseEWAY);
        Clear(TCSAMTLinewiseEWAY);
        Clear(TaxRecordIDEWAY);
        //<<PCPL/NSW/EINV 052522


        cnt := 0;
        Linedata := '[';
        SalesInvLine.RESET;
        SalesInvLine.SETCURRENTKEY("Document No.", "Line No.");
        SalesInvLine.SETRANGE("Document No.", Rec."No.");
        SalesInvLine.SETFILTER(Type, '<>%1', SalesInvLine.Type::" ");
        SalesInvLine.SETFILTER(Quantity, '<>%1', 0);
        IF SalesInvLine.FINDSET THEN
            REPEAT
                CGSTAmt := 0;
                SGSTAmt := 0;
                IGSTAmt := 0;
                CgstRate := 0;
                SgstRate := 0;
                IgstRate := 0;
                CESSGSTAmt := 0;
                CESSgstRate := 0;
                //>>PCPL/NSW/EINV 052522
                Clear(GSTBaseAmtLineWiseEWAY);
                Clear(TCSAMTLinewiseEWAY);
                Clear(TaxRecordIDEWAY);
                //<<PCPL/NSW/EINV 052522
                DetailedGSTLedgerEntry.RESET;
                DetailedGSTLedgerEntry.SETCURRENTKEY("Transaction Type", "Document Type", "Document No.", "Document Line No.");
                DetailedGSTLedgerEntry.SETRANGE("Transaction Type", DetailedGSTLedgerEntry."Transaction Type"::Sales);
                DetailedGSTLedgerEntry.SETRANGE("Document No.", SalesInvLine."Document No.");
                DetailedGSTLedgerEntry.SETRANGE("Document Line No.", SalesInvLine."Line No.");
                IF DetailedGSTLedgerEntry.FINDSET THEN
                    REPEAT
                        IF DetailedGSTLedgerEntry."GST Component Code" = 'CGST' THEN BEGIN
                            CGSTAmt := ABS(DetailedGSTLedgerEntry."GST Amount");
                            CgstRate := DetailedGSTLedgerEntry."GST %";
                            Supply := 'Outward';
                            Subsupply := 'Supply';
                            SubSupplydescr := '';
                        END ELSE
                            IF DetailedGSTLedgerEntry."GST Component Code" = 'SGST' THEN BEGIN
                                SGSTAmt := ABS(DetailedGSTLedgerEntry."GST Amount");
                                SgstRate := DetailedGSTLedgerEntry."GST %";
                                Supply := 'Outward';
                                Subsupply := 'Supply';
                                SubSupplydescr := '';
                            END ELSE
                                IF DetailedGSTLedgerEntry."GST Component Code" = 'IGST' THEN BEGIN
                                    IGSTAmt := ABS(DetailedGSTLedgerEntry."GST Amount");
                                    IgstRate := DetailedGSTLedgerEntry."GST %";
                                    Supply := 'Outward';
                                    Subsupply := 'Supply';
                                END ELSE
                                    IF DetailedGSTLedgerEntry."GST Component Code" = 'CESS' THEN BEGIN
                                        CESSGSTAmt := ABS(DetailedGSTLedgerEntry."GST Amount");
                                        CESSgstRate := DetailedGSTLedgerEntry."GST %";
                                        Supply := 'Outward';
                                        Subsupply := 'Supply';
                                    END;
                    UNTIL DetailedGSTLedgerEntry.NEXT = 0;

                /*
                IF SalesInvLine."Unit of Measure Code" = 'PAIR' THEN
                  UomValue := 'PRS'
                ELSE
                  UomValue := 'PCS';
                */

                TotalCGSTAmt += CGSTAmt;
                TotalSGSTAmt += SGSTAmt;
                TotalIGSTAmt += IGSTAmt;
                TotalCESSGSTAmt += CESSGSTAmt;

                //<<PCPL/NSW/EINV 052522
                if SalesInvLineNewEway.Get(SalesInvLine."Document No.", SalesInvLine."Line No.") then
                    TaxRecordIDEWAY := SalesInvLine.RecordId();
                TCSAMTLinewiseEWAY := GetTcsAmtLineWise(TaxRecordIDEWAY, ComponentJobjectEWAY);
                GSTBaseAmtLineWiseEWAY := GetGSTBaseAmtLineWise(TaxRecordIDEWAY, ComponentJobjectEWAY);
                //>>PCPL/NSW/EINV 052522

                //IF (SalesInvLine."GST Base Amount" = 0) AND (SalesInvLine."No." <> '502650') THEN BEGIN //PCPL/NSW/EINV 052522  Old Code Comment field not Exist in BC 19
                IF (GSTBaseAmtLineWiseEWAY = 0) AND (SalesInvLine."No." <> '502650') THEN BEGIN //PCPL/NSW/EINV 052522  New Code added
                    TotalTaxableAmt := SalesInvLine.Amount; //NEW
                    DocumentType := 'Delivery Challan';
                    Supply := 'Outward';
                    Subsupply := 'Others';
                    SubSupplydescr := 'Others';
                END ELSE BEGIN
                    //TotalTaxableAmt += SalesInvLine."GST Base Amount"; //OLD
                    TotalTaxableAmt := GSTBaseAmtLineWiseEWAY;//SalesInvLine."GST Base Amount";  //PCPL/NSW/EINV 052522 New Code Added
                    DocumentType := 'Tax Invoice';
                    Supply := 'Outward';
                    Subsupply := 'Supply';
                END;

                LineTaxableAmt += GSTBaseAmtLineWiseEWAY;//SalesInvLine."GST Base Amount";  //PCPL/NSW/EINV 052522 New Code Added
                LineInvoiceAmt += 0;//SalesInvLine."Amount To Customer"; //PCPL/NSW/EINV 052522 pass 0 coz field not eist in BC 19 

                ShipQty := SalesInvLine.Quantity;

                IF Item_.GET(SalesInvLine."No.") THEN;

                IF TotalTaxableAmt > 1000 THEN
                    TotaltaxableAmt1 := DELCHR(FORMAT(TotalTaxableAmt), '=', ',');

                TotaltaxableAmtValue += TotalTaxableAmt;
                IF TotaltaxableAmtValue > 1000 THEN
                    TotaltaxableAmtValue1 := DELCHR(FORMAT(TotaltaxableAmtValue), '=', ',');

                IF ShipQty <> 0 THEN BEGIN
                    cnt += 1;
                    IF (cnt = 1) AND (SalesInvLine."No." <> '502650') THEN
                        Linedata += '{"product_name":"' + Item_."Description 2" + '","product_description":"' + Item_."Description 2" + '","hsn_code":"' +
                        SalesInvLine."HSN/SAC Code" + '","quantity":"' + FORMAT(ShipQty) + '","unit_of_product":"' + SalesInvLine."Unit of Measure Code" + '","cgst_rate":"' + FORMAT(CgstRate) +
                        '","sgst_rate":"' + FORMAT(SgstRate) + '","igst_rate":"' + FORMAT(IgstRate) + '","cess_rate":"' + FORMAT(CESSgstRate) + '","cessNonAdvol":"' + '0' +
                        '","taxable_amount":"' + FORMAT(TotaltaxableAmt1) + '"}'
                    ELSE
                        IF SalesInvLine."No." <> '502650' THEN
                            Linedata += ',{"product_name":"' + Item_."Description 2" + '","product_description":"' + Item_."Description 2" + '","hsn_code":"' +
                            SalesInvLine."HSN/SAC Code" + '","quantity":"' + FORMAT(ShipQty) + '","unit_of_product":"' + SalesInvLine."Unit of Measure Code" + '","cgst_rate":"' + FORMAT(CgstRate) +
                            '","sgst_rate":"' + FORMAT(SgstRate) + '","igst_rate":"' + FORMAT(IgstRate) + '","cess_rate":"' + FORMAT(CESSgstRate) + '","cessNonAdvol":"' + '0' +
                              '","taxable_amount":"' + FORMAT(TotaltaxableAmt1) + '"}';
                END;
            UNTIL SalesInvLine.NEXT = 0;

        Linedata := Linedata + ']';

        GeneralLedgerSetup.GET;
        Ewaybill := Ewaybill.eWaybillController;
        token := Ewaybill.GetToken(GeneralLedgerSetup."EINV Base URL", GeneralLedgerSetup."EINV User Name", GeneralLedgerSetup."EINV Password",
        GeneralLedgerSetup."EINV Client ID", GeneralLedgerSetup."EINV Client Secret", GeneralLedgerSetup."EINV Grant Type", GeneralLedgerSetup."EINV Path");

        //IF EWayBillDetail.GET(SalesInvHdr."No.") THEN BEGIN
        Document_Date := FORMAT("Document Date", 0, '<Day,2>/<Month,2>/<year4>');
        Transport_Date := FORMAT("Posting Date", 0, '<Day,2>/<Month,2>/<year4>');  //PCPL/NSW/EINV 052522 New Code Added LR Date not Exist in BC 19 Replace With posting date
        Headerdata := '{"access_token":"' + token + '","userGstin":"' + Location_."GST Registration No." + '","supply_type":"' + Supply + '","sub_supply_type":"' + Subsupply +
         '","sub_supply_description":"' + SubSupplydescr + '","document_type":"' + DocumentType + '","document_number":"' + "No." +
         '","document_date":"' + Document_Date + '","gstin_of_consignor":"' + Location_."GST Registration No." + '","legal_name_of_consignor":"' + Location_.Name +
         '","address1_of_consignor":"' + Location_.Address + '","address2_of_consignor":"' + Location_."Address 2" + '","place_of_consignor":"' +
         Location_.City + '","pincode_of_consignor":"' + Location_."Post Code" + '","state_of_consignor":"' + State_.Description +
         '","actual_from_state_name":"' + State_.Description + '","gstin_of_consignee":"' + consignee_gstin + '","legal_name_of_consignee":"' + consignee_name +
         '","address1_of_consignee":"' + consignee_address1 + '","address2_of_consignee":"' + consignee_address2 +
         '","place_of_consignee":"' + consignee_place + '","pincode_of_consignee":"' + consignee_pincode + '","state_of_supply":"' + consignee_StateofSupply +
         '","actual_to_state_name":"' + consignee_StateName + '","transaction_type":"' + "Transaction Type" + '","other_value":"' + '' +
         '","total_invoice_value":"' + FORMAT(LineInvoiceAmt) + '","taxable_amount":"' + FORMAT(TotaltaxableAmtValue1) + '","cgst_amount":"' +
         FORMAT(TotalCGSTAmt) + '","sgst_amount":"' + FORMAT(TotalSGSTAmt) + '","igst_amount":"' + FORMAT(TotalIGSTAmt) + '","cess_amount":"' +
         FORMAT(TotalCESSGSTAmt) + '","cess_nonadvol_value":"' + '0' + '","transporter_id":"' + "Transport Vendor GSTIN" + '","transporter_name":"' +
         "Transport Vendor Name" + '","transporter_document_number":"' + ''/*"LR/RR No." */+ '","transporter_document_date":"' + Transport_Date + '","transportation_mode":"' +  //LR/RR No. Not exist in BC 19
         "Shipment Method Code" + '","transportation_distance":"' + FORMAT("Distance (Km)") + '","vehicle_number":"' +
         "Vehicle No." + '","vehicle_type":"' + 'Regular' + '","generate_status":"' + '1' + '","data_source":"' + 'erp' + '","user_ref":"' + '' +
         '","location_code":"' + Location_.Code + '","eway_bill_status":"' + FORMAT("E-Way Bill Generate") + '","auto_print":"' + 'Y' + '","email":"' +
         Location_."E-Mail" + '"}';
        //PCPL/0026
        /*
        Headerdata :='{"access_token":"'+token+'","userGstin":"'+'05AAABC0181E1ZE'+'","supply_type":"'+Supply+'","sub_supply_type":"'+Subsupply+
            '","sub_supply_description":"'+SubSupplydescr+'","document_type":"'+DocumentType+'","document_number":"'+SalesInvHdr."No."+
            '","document_date":"'+Document_Date+'","gstin_of_consignor":"'+'05AAABC0181E1ZE'+'","legal_name_of_consignor":"'+Location_.Name+
            '","address1_of_consignor":"'+Location_.Address+'","address2_of_consignor":"'+Location_."Address 2"+'","place_of_consignor":"'+
            Location_.City+'","pincode_of_consignor":"'+Location_."Post Code"+'","state_of_consignor":"'+State_.Description+
            '","actual_from_state_name":"'+State_.Description+'","gstin_of_consignee":"'+'05AAABB0639G1Z8'+'","legal_name_of_consignee":"'+Cust.Name+
            '","address1_of_consignee":"'+Cust.Address+'","address2_of_consignee":"'+Cust."Address 2"+
            '","place_of_consignee":"'+Cust.City+'","pincode_of_consignee":"'+Cust."Post Code"+'","state_of_supply":"'+StateCust.Description+
            '","actual_to_state_name":"'+StateCust.Description+'","transaction_type":"'+SalesInvHdr."Transaction Type"+'","other_value":"'+''+
            '","total_invoice_value":"'+FORMAT("Amount to Customer")+'","taxable_amount":"'+FORMAT(TotaltaxableAmt1)+'","cgst_amount":"'+
            FORMAT(TotalCGSTAmt)+'","sgst_amount":"'+FORMAT(TotalSGSTAmt) + '","igst_amount":"'+FORMAT(TotalIGSTAmt)+'","cess_amount":"'+
            FORMAT(TotalCESSGSTAmt)+'","cess_nonadvol_value":"'+'0'+'","transporter_id":"'+'05AAABC0181E1ZE'+'","transporter_name":"'+
            EWayBillDetail."Transporter Name"+'","transporter_document_number":"'+"LR/RR No."+'","transporter_document_date":"'+FORMAT("LR/RR Date")+'","transportation_mode":"'+
            EWayBillDetail."Transportation Mode"+'","transportation_distance":"'+FORMAT(EWayBillDetail."Transport Distance")+'","vehicle_number":"'+
            SalesInvHdr."Vehicle No." +'","vehicle_type":"'+'Regular'+'","generate_status":"'+'1'+'","data_source":"'+'erp'+'","user_ref":"'+''+
            '","location_code":"'+Location_.Code+'","eway_bill_status":"'+FORMAT(SalesInvHdr."E-Way Bill Generate")+'","auto_print":"'+'Y'+'","email":"'+
            Location_."E-Mail"+'"}';*/
        //END;I

        MESSAGE(Headerdata);
        MESSAGE(Linedata);
        result := Ewaybill.GenerateEwaybill(GeneralLedgerSetup."EINV Base URL", token, Headerdata, Linedata, GeneralLedgerSetup."EINV Path");

        /*
        IF (12 = STRLEN(result)) AND (result <> 'Invalid Json') THEN BEGIN
          IF EWayBillDetail.GET(SalesInvHdr."No.") THEN BEGIN
            EWayBillDetail."Eway Bill No." := result;
            EWayBillDetail."Ewaybill Error" := '';
            EWayBillDetail.MODIFY;
        
            SalesInvHdr."E-Way Bill Generate" := SalesInvHdr."E-Way Bill Generate"::Generated;
            SalesInvHdr.MODIFY;
            MESSAGE(result);
          END;
        END ELSE BEGIN
          EWayBillDetail."Ewaybill Error" := result;
          EWayBillDetail.MODIFY;
          COMMIT;
          ERROR(result);
        END;
        */
        IF result <> 'Invalid Json' THEN BEGIN
            resresult := CONVERTSTR(result, ';', ',');
            resresult1 := SELECTSTR(1, resresult);
            resresult2 := SELECTSTR(2, resresult);
        END;

        IF (12 = STRLEN(resresult1)) THEN BEGIN
            IF EWayBillDetail.GET(Rec."No.") THEN BEGIN
                EWayBillDetail."Eway Bill No." := resresult1;
                EWayBillDetail."URL for PDF" := resresult2;
                EWayBillDetail."Ewaybill Error" := '';
                EWayBillDetail.MODIFY;
                SalesInvHeader.Reset();
                SalesInvHeader.SetRange("No.", "No.");
                IF SalesInvHeader.FindFirst() then begin
                    SalesInvHeader."E-Way Bill Generate" := SalesInvHeader."E-Way Bill Generate"::Generated;
                    SalesInvHeader.MODIFY;
                end;
                MESSAGE(resresult1);
            END;
        END ELSE BEGIN
            EWayBillDetail."Ewaybill Error" := result;
            EWayBillDetail.MODIFY;
            COMMIT;
            ERROR(result);
        END;
        //PCPL41-EWAY

    end;
    //PCPL/NSW/EINV 050522
    local procedure GetTcsAmtLineWiseEway(TaxRecordID: RecordId; var JObject: JsonObject): Decimal
    var
        TaxTransactionValue: Record "Tax Transaction Value";
        TaxTypeObjHelper: Codeunit "Tax Type Object Helper";
        ComponentAmtTCS: Decimal;
        JArray: JsonArray;
        ComponentJObject: JsonObject;
    begin
        if not GuiAllowed then
            exit;

        TaxTransactionValue.SetFilter("Tax Record ID", '%1', TaxRecordID);
        TaxTransactionValue.SetFilter("Value Type", '%1', TaxTransactionValue."Value Type"::Component);
        TaxTransactionValue.SetRange("Visible on Interface", true);
        TaxTransactionValue.SetRange("Tax Type", 'TCS');
        //if TaxTransactionValue.FindSet() then
        if TaxTransactionValue.FindFirst() then
            //repeat
            begin
            Clear(ComponentJObject);
            //ComponentJObject.Add('Component', TaxTransactionValue.GetAttributeColumName());
            //ComponentJObject.Add('Percent', ScriptDatatypeMgmt.ConvertXmlToLocalFormat(format(TaxTransactionValue.Percent, 0, 9), "Symbol Data Type"::NUMBER));
            ComponentAmtTCS := TaxTypeObjHelper.GetComponentAmountFrmTransValue(TaxTransactionValue);
            //ComponentJObject.Add('Amount', ScriptDatatypeMgmt.ConvertXmlToLocalFormat(format(ComponentAmt, 0, 9), "Symbol Data Type"::NUMBER));
            JArray.Add(ComponentJObject);
        end;
        //        TCSAMTLinewise := ComponentAmt;
        //until TaxTransactionValue.Next() = 0;
        exit(ComponentAmtTCS)

    end;

    local procedure GetGSTBaseAmtLineWiseEWAY(TaxRecordID: RecordId; var JObject: JsonObject): Decimal
    var
        TaxTransactionValue: Record "Tax Transaction Value";
        TaxTypeObjHelper: Codeunit "Tax Type Object Helper";
        ComponentAmtGSTVBase: Decimal;
        JArray: JsonArray;
        ComponentJObject: JsonObject;
    begin
        if not GuiAllowed then
            exit;

        TaxTransactionValue.SetFilter("Tax Record ID", '%1', TaxRecordID);
        TaxTransactionValue.SetFilter("Value Type", '%1', TaxTransactionValue."Value Type"::Component);
        TaxTransactionValue.SetRange("Visible on Interface", true);
        TaxTransactionValue.SetRange("Tax Type", 'GST');
        TaxTransactionValue.SetRange("Value ID", 10);
        //if TaxTransactionValue.FindSet() then
        if TaxTransactionValue.FindFirst() then
            //repeat
            begin
            Clear(ComponentJObject);
            //ComponentJObject.Add('Component', TaxTransactionValue.GetAttributeColumName());
            //ComponentJObject.Add('Percent', ScriptDatatypeMgmt.ConvertXmlToLocalFormat(format(TaxTransactionValue.Percent, 0, 9), "Symbol Data Type"::NUMBER));
            ComponentAmtGSTVBase := TaxTypeObjHelper.GetComponentAmountFrmTransValue(TaxTransactionValue);
            //ComponentJObject.Add('Amount', ScriptDatatypeMgmt.ConvertXmlToLocalFormat(format(ComponentAmt, 0, 9), "Symbol Data Type"::NUMBER));
            JArray.Add(ComponentJObject);
        end;
        exit(ComponentAmtGSTVBase)

    end;
    //PCPL/NSW/EINV 050522


    procedure CheckEwaybill_returnVMsg();
    var
        Headerdata: Text;
        Linedata: Text;
        Cust: Record 18;
        PostedSalesLine: Record 113;
        Location_: Record 14;
        State_: Record State;
        StateCust: Record State;
        ShiptoCode: Record 222;
        ComInfo: Record 79;
        HSNSAN: Record "HSN/SAC";
        ShipQty: Decimal;
        cnt: Integer;
        Item_: Record 27;
        DetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry";
        CGSTAmt: Decimal;
        SGSTAmt: Decimal;
        IGSTAmt: Decimal;
        CESSGSTAmt: Decimal;
        CgstRate: Decimal;
        SgstRate: Decimal;
        IgstRate: Decimal;
        CESSgstRate: Decimal;
        TotalCGSTAmt: Decimal;
        TotalSGSTAmt: Decimal;
        TotalIGSTAmt: Decimal;
        TotalCESSGSTAmt: Decimal;
        Document_Date: Text;
        UOMeasure: Text;
        FromGST: Text;
        ToGST: Text;
        TotalTaxableAmt: Decimal;
        LineTaxableAmt: Decimal;
        LineInvoiceAmt: Decimal;
        Supply: Text;
        Subsupply: Text;
        SubSupplydescr: Text;
        PathText: Text;
        UomValue: Text;
        DocumentType: Text;
        EWayBillDetail1: Record 50008;
        GeneralLedgerSetup: Record 98;
        SalesInvLine: Record 113;
        TotaltaxableAmt1: Text;
        Ewaybill: DotNet Ewaybillcontroller;
        token: Text;
        result: Text;
        resresult: Text;
        resresult1: Text;
        resresult2: Text;
        Transport_Date: Text;
        consignee_gstin: Text;
        consignee_name: Text;
        consignee_address1: Text;
        consignee_address2: Text;
        consignee_place: Text;
        consignee_pincode: Text;
        consignee_StateofSupply: Text;
        consignee_StateName: Text;
        Ship_to_state: Record State;
        Recustomer: Record 18;
        RecshiptoAddress: Record 222;
        TotaltaxableAmtValue: Decimal;
        TotaltaxableAmtValue1: Text;
        //<<PCPL/NSW/EINV 050522
        SalesInvLineNewEwayretmsg: Record 113;
        TaxRecordIDEWAYRetMsg: RecordId;
        GSTBaseAmtLineWiseEWAYRetMSG: Decimal;
        ComponentJobjectEWAYRetMSg: JsonObject;
    //>>PCPL/NSW/EINV 050522
    begin
        IF Cust.GET("Sell-to Customer No.") THEN;
        IF Location_.GET("Location Code") THEN;
        IF State_.GET(Location_."State Code") THEN;
        IF ShiptoCode.GET("Sell-to Customer No.", "Ship-to Code") THEN;
        IF Ship_to_state.GET(ShiptoCode.State) THEN;
        IF StateCust.GET(Cust."State Code") THEN;
        IF "Ship-to Code" <> '' THEN BEGIN
            consignee_gstin := ShiptoCode."GST Registration No.";
        END ELSE
            consignee_gstin := Cust."GST Registration No.";
        IF "Ship-to Code" <> '' THEN BEGIN
            consignee_address1 := ShiptoCode.Address;
        END ELSE
            consignee_address1 := Cust.Address;
        IF "Ship-to Code" <> '' THEN BEGIN
            consignee_address2 := ShiptoCode."Address 2";
        END ELSE
            consignee_address2 := Cust."Address 2";
        IF "Ship-to Code" <> '' THEN BEGIN
            consignee_name := ShiptoCode.Name;
        END ELSE
            consignee_name := Cust.Name;
        IF "Ship-to Code" <> '' THEN BEGIN
            consignee_pincode := ShiptoCode."Post Code";
        END ELSE
            consignee_pincode := Cust."Post Code";
        IF "Ship-to Code" <> '' THEN BEGIN
            consignee_place := ShiptoCode.City;
        END ELSE
            consignee_place := Cust.City;
        IF "Ship-to Code" <> '' THEN BEGIN
            consignee_StateofSupply := Ship_to_state.Description;
        END ELSE
            consignee_StateofSupply := StateCust.Description;
        IF "Ship-to Code" <> '' THEN BEGIN
            consignee_StateName := Ship_to_state.Description;
        END ELSE
            consignee_StateName := StateCust.Description;


        //CALCFIELDS("Amount to Customer");


        ShipQty := 0;
        LineTaxableAmt := 0;
        LineInvoiceAmt := 0;
        TotalIGSTAmt := 0;
        TotalCGSTAmt := 0;
        TotalTaxableAmt := 0;
        TotaltaxableAmtValue := 0;
        CLEAR(TotaltaxableAmtValue1);
        //<<PCPL/NSW/EINV 050522
        CLEAR(TaxRecordIDEWAYRetMsg);
        CLEAR(GSTBaseAmtLineWiseEWAYRetMSG);
        CLEAR(ComponentJobjectEWAYRetMSg);
        //>>PCPL/NSW/EINV 050522

        cnt := 0;
        Linedata := '[';
        SalesInvLine.RESET;
        SalesInvLine.SETCURRENTKEY("Document No.", "Line No.");
        SalesInvLine.SETRANGE("Document No.", Rec."No.");
        SalesInvLine.SETFILTER(Type, '<>%1', SalesInvLine.Type::" ");
        SalesInvLine.SETFILTER(Quantity, '<>%1', 0);
        IF SalesInvLine.FINDSET THEN
            REPEAT
                CGSTAmt := 0;
                SGSTAmt := 0;
                IGSTAmt := 0;
                CgstRate := 0;
                SgstRate := 0;
                IgstRate := 0;
                CESSGSTAmt := 0;
                CESSgstRate := 0;
                DetailedGSTLedgerEntry.RESET;
                DetailedGSTLedgerEntry.SETCURRENTKEY("Transaction Type", "Document Type", "Document No.", "Document Line No.");
                DetailedGSTLedgerEntry.SETRANGE("Transaction Type", DetailedGSTLedgerEntry."Transaction Type"::Sales);
                DetailedGSTLedgerEntry.SETRANGE("Document No.", SalesInvLine."Document No.");
                DetailedGSTLedgerEntry.SETRANGE("Document Line No.", SalesInvLine."Line No.");
                IF DetailedGSTLedgerEntry.FINDSET THEN
                    REPEAT
                        IF DetailedGSTLedgerEntry."GST Component Code" = 'CGST' THEN BEGIN
                            CGSTAmt := ABS(DetailedGSTLedgerEntry."GST Amount");
                            CgstRate := DetailedGSTLedgerEntry."GST %";
                            Supply := 'Outward';
                            Subsupply := 'Supply';
                            SubSupplydescr := '';
                        END ELSE
                            IF DetailedGSTLedgerEntry."GST Component Code" = 'SGST' THEN BEGIN
                                SGSTAmt := ABS(DetailedGSTLedgerEntry."GST Amount");
                                SgstRate := DetailedGSTLedgerEntry."GST %";
                                Supply := 'Outward';
                                Subsupply := 'Supply';
                                SubSupplydescr := '';
                            END ELSE
                                IF DetailedGSTLedgerEntry."GST Component Code" = 'IGST' THEN BEGIN
                                    IGSTAmt := ABS(DetailedGSTLedgerEntry."GST Amount");
                                    IgstRate := DetailedGSTLedgerEntry."GST %";
                                    Supply := 'Outward';
                                    Subsupply := 'Supply';
                                END ELSE
                                    IF DetailedGSTLedgerEntry."GST Component Code" = 'CESS' THEN BEGIN
                                        CESSGSTAmt := ABS(DetailedGSTLedgerEntry."GST Amount");
                                        CESSgstRate := DetailedGSTLedgerEntry."GST %";
                                        Supply := 'Outward';
                                        Subsupply := 'Supply';
                                    END;
                    UNTIL DetailedGSTLedgerEntry.NEXT = 0;


                TotalCGSTAmt += CGSTAmt;
                TotalSGSTAmt += SGSTAmt;
                TotalIGSTAmt += IGSTAmt;
                TotalCESSGSTAmt += CESSGSTAmt;

                //<<PCPL/NSW/EINV 052522
                if SalesInvLineNewEwayretmsg.Get(SalesInvLine."Document No.", SalesInvLine."Line No.") then
                    TaxRecordIDEWAYRetMsg := SalesInvLine.RecordId();
                GSTBaseAmtLineWiseEWAYRetMSG := GetGSTBaseAmtLineWise(TaxRecordIDEWAYRetMSG, ComponentJobjectEWAYRetMSg);
                //>>PCPL/NSW/EINV 052522

                // IF (SalesInvLine."GST Base Amount" = 0) AND (SalesInvLine."No." <> '502650') THEN BEGIN //PCPL/NSW/EINV 052522 Code Commented  Field not Exist BC 190
                IF (GSTBaseAmtLineWiseEWAYRetMSG = 0) AND (SalesInvLine."No." <> '502650') THEN BEGIN //PCPL/NSW/EINV 052522 New Code added
                    TotalTaxableAmt := SalesInvLine.Amount; //NEW
                    DocumentType := 'Delivery Challan';
                    Supply := 'Outward';
                    Subsupply := 'Others';
                    SubSupplydescr := 'Others';
                END ELSE BEGIN
                    TotalTaxableAmt := GSTBaseAmtLineWiseEWAYRetMSG;//SalesInvLine."GST Base Amount"; //PCPL/NSW/EINV 052522 New Code added
                    DocumentType := 'Tax Invoice';
                    Supply := 'Outward';
                    Subsupply := 'Supply';
                END;

                LineTaxableAmt += GSTBaseAmtLineWiseEWAYRetMSG;//SalesInvLine."GST Base Amount"; //PCPL/NSW/EINV 052522 New Code added
                LineInvoiceAmt += 0;//SalesInvLine."Amount To Customer"; //PCPL/NSW/EINV 052522 Code is commented coz field not exis in BC19
                ShipQty := SalesInvLine.Quantity;

                IF Item_.GET(SalesInvLine."No.") THEN;

                IF TotalTaxableAmt > 1000 THEN
                    TotaltaxableAmt1 := DELCHR(FORMAT(TotalTaxableAmt), '=', ',');

                TotaltaxableAmtValue += TotalTaxableAmt;
                IF TotaltaxableAmtValue > 1000 THEN
                    TotaltaxableAmtValue1 := DELCHR(FORMAT(TotaltaxableAmtValue), '=', ',');

                IF ShipQty <> 0 THEN BEGIN
                    cnt += 1;
                    IF (cnt = 1) AND (SalesInvLine."No." <> '502650') THEN
                        Linedata += '{"product_name":"' + Item_."Description 2" + '","product_description":"' + Item_."Description 2" + '","hsn_code":"' +
                        SalesInvLine."HSN/SAC Code" + '","quantity":"' + FORMAT(ShipQty) + '","unit_of_product":"' + SalesInvLine."Unit of Measure Code" + '","cgst_rate":"' + FORMAT(CgstRate) +
                        '","sgst_rate":"' + FORMAT(SgstRate) + '","igst_rate":"' + FORMAT(IgstRate) + '","cess_rate":"' + FORMAT(CESSgstRate) + '","cessNonAdvol":"' + '0' +
                        '","taxable_amount":"' + FORMAT(TotaltaxableAmt1) + '"}'
                    ELSE
                        IF SalesInvLine."No." <> '502650' THEN
                            Linedata += ',{"product_name":"' + Item_."Description 2" + '","product_description":"' + Item_."Description 2" + '","hsn_code":"' +
                            SalesInvLine."HSN/SAC Code" + '","quantity":"' + FORMAT(ShipQty) + '","unit_of_product":"' + SalesInvLine."Unit of Measure Code" + '","cgst_rate":"' + FORMAT(CgstRate) +
                            '","sgst_rate":"' + FORMAT(SgstRate) + '","igst_rate":"' + FORMAT(IgstRate) + '","cess_rate":"' + FORMAT(CESSgstRate) + '","cessNonAdvol":"' + '0' +
                              '","taxable_amount":"' + FORMAT(TotaltaxableAmt1) + '"}';
                END;
            UNTIL SalesInvLine.NEXT = 0;

        Linedata := Linedata + ']';

        GeneralLedgerSetup.GET;


        Document_Date := FORMAT("Document Date", 0, '<Day,2>/<Month,2>/<year4>');
        Transport_Date := FORMAT("Posting Date", 0, '<Day,2>/<Month,2>/<year4>');  //LR/RR Date  //PCPL/NSW/EINV 052522 Fields is Replaced with Posting with LR/RR Date coz field not exis in BC19
        Headerdata := '{"access_token":"' + token + '","userGstin":"' + Location_."GST Registration No." + '","supply_type":"' + Supply + '","sub_supply_type":"' + Subsupply +
         '","sub_supply_description":"' + SubSupplydescr + '","document_type":"' + DocumentType + '","document_number":"' + "No." +
         '","document_date":"' + Document_Date + '","gstin_of_consignor":"' + Location_."GST Registration No." + '","legal_name_of_consignor":"' + Location_.Name +
         '","address1_of_consignor":"' + Location_.Address + '","address2_of_consignor":"' + Location_."Address 2" + '","place_of_consignor":"' +
         Location_.City + '","pincode_of_consignor":"' + Location_."Post Code" + '","state_of_consignor":"' + State_.Description +
         '","actual_from_state_name":"' + State_.Description + '","gstin_of_consignee":"' + consignee_gstin + '","legal_name_of_consignee":"' + consignee_name +
         '","address1_of_consignee":"' + consignee_address1 + '","address2_of_consignee":"' + consignee_address2 +
         '","place_of_consignee":"' + consignee_place + '","pincode_of_consignee":"' + consignee_pincode + '","state_of_supply":"' + consignee_StateofSupply +
         '","actual_to_state_name":"' + consignee_StateName + '","transaction_type":"' + "Transaction Type" + '","other_value":"' + '' +
         '","total_invoice_value":"' + FORMAT(LineInvoiceAmt) + '","taxable_amount":"' + FORMAT(TotaltaxableAmtValue1) + '","cgst_amount":"' +
         FORMAT(TotalCGSTAmt) + '","sgst_amount":"' + FORMAT(TotalSGSTAmt) + '","igst_amount":"' + FORMAT(TotalIGSTAmt) + '","cess_amount":"' +
         FORMAT(TotalCESSGSTAmt) + '","cess_nonadvol_value":"' + '0' + '","stransporter_id":"' + "Transport Vendor GSTIN" + '","transporter_name":"' +
         "Transport Vendor Name" + '","transporter_document_number":"' + ''/*"LR/RR No."*/ + '","transporter_document_date":"' + Transport_Date + '","transportation_mode":"' +
         "Shipment Method Code" + '","transportation_distance":"' + FORMAT("Distance (Km)") + '","vehicle_number":"' +
         "Vehicle No." + '","vehicle_type":"' + 'Regular' + '","generate_status":"' + '1' + '","data_source":"' + 'erp' + '","user_ref":"' + '' +
         '","location_code":"' + Location_.Code + '","eway_bill_status":"' + FORMAT("E-Way Bill Generate") + '","auto_print":"' + 'Y' + '","email":"' +
         Location_."E-Mail" + '"}';

        MESSAGE(Headerdata);
        MESSAGE(Linedata);
    end;

    trigger OnOpenPage()
    var
        EWayBillDetailNew: Record 50008;
        EInvoiceDetailNew: record 50007;
    begin

        //PCPL41-EINV
        EInvoiceDetailNew.RESET;
        EInvoiceDetailNew.SETRANGE("Document No.", "No.");
        IF NOT EInvoiceDetailNew.FINDFIRST THEN BEGIN
            EINVGen := TRUE;
            EINVCan := FALSE;
        END;

        EInvoiceDetailNew.RESET;
        EInvoiceDetailNew.SETRANGE("Document No.", "No.");
        EInvoiceDetailNew.SetFilter("E-Invoice IRN No.", '<>%1', '');
        IF EInvoiceDetailNew.FINDFIRST THEN BEGIN
            EINVGen := FALSE;
            EINVCan := TRUE;
        END;
        //PCPL41-EINV

        //PCPL0017-EWAY
        EWayBillDetailNew.RESET;
        EWayBillDetailNew.SETRANGE("Document No.", "No.");
        EWayBillDetailNew.SETFILTER("Eway Bill No.", '<>%1', '');
        IF EWayBillDetailNew.FINDFIRST THEN BEGIN
            EWAYGEN := FALSE;
        END ELSE
            EWAYGEN := TRUE;
        //PCPL0017-EWAY

    end;


    local procedure GetGSTBaseAmtLineWiseEWAYRetMsg(TaxRecordID: RecordId; var JObject: JsonObject): Decimal
    var
        TaxTransactionValue: Record "Tax Transaction Value";
        TaxTypeObjHelper: Codeunit "Tax Type Object Helper";
        ComponentAmtGSTVBaseretMsg: Decimal;
        JArray: JsonArray;
        ComponentJObject: JsonObject;
    begin
        if not GuiAllowed then
            exit;

        TaxTransactionValue.SetFilter("Tax Record ID", '%1', TaxRecordID);
        TaxTransactionValue.SetFilter("Value Type", '%1', TaxTransactionValue."Value Type"::Component);
        TaxTransactionValue.SetRange("Visible on Interface", true);
        TaxTransactionValue.SetRange("Tax Type", 'GST');
        TaxTransactionValue.SetRange("Value ID", 10);
        //if TaxTransactionValue.FindSet() then
        if TaxTransactionValue.FindFirst() then
            //repeat
            begin
            Clear(ComponentJObject);
            ComponentAmtGSTVBaseretMsg := TaxTypeObjHelper.GetComponentAmountFrmTransValue(TaxTransactionValue);
            JArray.Add(ComponentJObject);
        end;
        exit(ComponentAmtGSTVBaseretMsg)

    end;
    //PCPL/NSW/EINV 050522
    local procedure ConvertDt(AckDt2: Text): Text;
    var
        YYYY: Text;
        MM: Text;
        DD: Text;
        DateTime: Text;
        DT: Text;
    begin
        YYYY := COPYSTR(AckDt2, 1, 4);
        MM := COPYSTR(AckDt2, 6, 2);
        DD := COPYSTR(AckDt2, 9, 2);

        // TIME := COPYSTR(AckDt2,12,8);

        //DateTime := DD + '-' + MM + '-' + YYYY + ' ' + COPYSTR(AckDt2,11,8);
        DT := DD + '/' + MM + '/' + YYYY;
        EXIT(DT);
    end;

    local procedure GetDT(InputString: Text[30]) YourDT: DateTime;
    var
        Day: Integer;
        Month: Integer;
        Year: Integer;
        TheTime: Time;
    begin

        EVALUATE(Day, COPYSTR(InputString, 9, 2));  //2021-10-25192500
        EVALUATE(Month, COPYSTR(InputString, 6, 2));
        EVALUATE(Year, COPYSTR(InputString, 1, 4));
        EVALUATE(TheTime, COPYSTR(InputString, 11, 6));
        YourDT := CREATEDATETIME(DMY2DATE(Day, Month, Year), TheTime);


        /*EVALUATE(Day, COPYSTR(InputString,1,2));
        EVALUATE(Month, COPYSTR(InputString,4,2));
        EVALUATE(Year, COPYSTR(InputString,7,2));
        EVALUATE(TheTime, COPYSTR(InputString,12,8));
        YourDT := FORMAT(Day)+'-'+FORMAT(Month)+'-'+FORMAT(Year); */

    end;


    procedure GetStatisticsPostedSalesInvAmount(
        SalesInvHeader: Record "Sales Invoice Header";
        var GSTAmount: Decimal; var AmountToCust: Decimal)
    var
        SalesInvLine: Record "Sales Invoice Line";
        TotalAmount: decimal;
    begin
        Clear(GSTAmount);

        SalesInvLine.SetRange("Document No.", SalesInvHeader."No.");
        if SalesInvLine.FindSet() then
            repeat
                GSTAmount += GetGSTAmount(SalesInvLine.RecordId());
                TotalAmount += SalesInvLine."Line Amount" - SalesInvLine."Line Discount Amount";
            until SalesInvLine.Next() = 0;
        AmountToCust := GSTAmount + TotalAmount;
    end;

    local procedure GetGSTAmount(RecID: RecordID): Decimal
    var
        TaxTransactionValue: Record "Tax Transaction Value";
        GSTSetup: Record "GST Setup";
    begin
        if not GSTSetup.Get() then
            exit;

        TaxTransactionValue.SetRange("Tax Record ID", RecID);
        TaxTransactionValue.SetRange("Value Type", TaxTransactionValue."Value Type"::COMPONENT);
        if GSTSetup."Cess Tax Type" <> '' then
            TaxTransactionValue.SetRange("Tax Type", GSTSetup."GST Tax Type", GSTSetup."Cess Tax Type")
        else
            TaxTransactionValue.SetRange("Tax Type", GSTSetup."GST Tax Type");
        TaxTransactionValue.SetFilter(Percent, '<>%1', 0);
        if not TaxTransactionValue.IsEmpty() then
            TaxTransactionValue.CalcSums(Amount);

        exit(TaxTransactionValue.Amount);
    end;

    var
        EINVGen: Boolean;
        SalesInvHeader: Record 112;
        EINVCan: Boolean;
        EWAYGEN: Boolean;




}

