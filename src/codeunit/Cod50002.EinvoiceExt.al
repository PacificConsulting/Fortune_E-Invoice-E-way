codeunit 50002 "E Invoice Auo Post Ext"
{
    trigger OnRun()
    begin

    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnAfterPostSalesDoc', '', false, false)]
    local procedure OnAfterPostSalesDoc(var SalesHeader: Record "Sales Header"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; SalesShptHdrNo: Code[20]; RetRcpHdrNo: Code[20]; SalesInvHdrNo: Code[20]; SalesCrMemoHdrNo: Code[20]; CommitIsSuppressed: Boolean; InvtPickPutaway: Boolean; var CustLedgerEntry: Record "Cust. Ledger Entry"; WhseShip: Boolean; WhseReceiv: Boolean)
    var
        SalesIheader: Record 112;
        SalesCheader: Record 114;
    begin
        if SalesInvHdrNo <> '' then begin
            SalesIheader.Reset();
            SalesIheader.SetRange("No.", SalesInvHdrNo);
            if SalesIheader.FindFirst() then
                if not (SalesIheader."GST Customer Type" in
                        [SalesIheader."GST Customer Type"::Unregistered,
                         SalesIheader."GST Customer Type"::" "])
                then
                    IF SalesHeader."Auto E-Invoice Post" then begin
                        GenerateEInvoice(SalesIheader);
                    end;
            //IF SalesHeader."Document Type" = SalesHeader."Document Type"::Order then begin
            //IF SalesIheader.GET(SalesInvHdrNo) then begin
        end else
            if SalesCrMemoHdrNo <> '' then begin
                SalesCheader.Reset();
                SalesCheader.SetRange("No.", SalesCrMemoHdrNo);
                if SalesCheader.FindFirst() then
                    if not (SalesCheader."GST Customer Type" in
                            [SalesCheader."GST Customer Type"::Unregistered,
                             SalesCheader."GST Customer Type"::" "])
                    then
                        IF SalesHeader."Auto E-Invoice Post" then begin
                            GenerateEInvoiceCreditMemo(SalesCheader);
                        end;
                //IF SalesHeader."Document Type" = SalesHeader."Document Type"::"Credit Memo" then begin
                //  if SalesCheader.get(SalesCrMemoHdrNo) then begin
            end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"TransferOrder-Post Shipment", 'OnRunOnBeforeCommit', '', false, false)]
    local procedure OnRunOnBeforeCommit(var TransferHeader: Record "Transfer Header"; var TransferShipmentHeader: Record "Transfer Shipment Header"; PostedWhseShptHeader: Record "Posted Whse. Shipment Header"; var SuppressCommit: Boolean)
    var
        TransferShipHeader: Record "Transfer Shipment Header";
    begin
        TransferShipHeader.Reset();
        TransferShipHeader.SetRange("No.", TransferShipmentHeader."No.");
        IF TransferShipHeader.FindFirst() then begin
            IF TransferHeader."Auto E-Invoice Post" then begin
                GenerateEInvoiceTransgerShipment(TransferShipHeader);
            end;
        end;
    end;

    local procedure GenerateEInvoice(Var SalesInvHeader: Record 112);
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
        ExpCustomer.GET(SalesInvHeader."Sell-to Customer No.");
        IF SalesInvHeader."GST Customer Type" = "GST Customer Type"::Export THEN BEGIN
            Natureofsupply := 'EXPWOP';
            transactiondetails := Natureofsupply + '!' + 'N' + '!' + '' + '!' + 'N';
        END ELSE
            IF ExpCustomer."GST Customer Type" = ExpCustomer."GST Customer Type"::"SEZ Unit" THEN BEGIN
                Natureofsupply := 'SEZWOP';
                transactiondetails := Natureofsupply + '!' + 'N' + '!' + '' + '!' + 'N';
            END ELSE
                transactiondetails := FORMAT(SalesInvHeader."Nature of Supply") + '!' + 'N' + '!' + '' + '!' + 'N';


        Document_Date := FORMAT(SalesInvHeader."Posting Date", 0, '<Day,2>/<Month,2>/<year4>');
        documentdetails := 'INV' + '!' + SalesInvHeader."No." + '!' + Document_Date;

        CompanyInformation.GET;
        Location.GET(SalesInvHeader."Location Code");
        State.GET(Location."State Code");
        LocPhoneNo := DELCHR(Location."Phone No.", '=', '!|@|#|$|%|^|&|*|/|''|\|-| |(|)');
        sellerdetails := Location."GST Registration No." + '!' + CompanyInformation.Name + '!' + Location.Name + '!' + Location.Address + '!' + Location."Address 2" + '!' +
        SalesInvHeader."Location Code" + '!' + Location."Post Code" + '!' + State."State Code (GST Reg. No.)" + '!' + LocPhoneNo + '!' + Location."E-Mail";

        dispatchdetails := Location.Name + '!' + Location.Address + '!' + Location."Address 2" + '!' + SalesInvHeader."Location Code" + '!' + Location."Post Code" + '!' + State.Description;

        Customer.GET(SalesInvHeader."Sell-to Customer No.");
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
                SLI.SETRANGE("Document No.", SalesInvHeader."No.");
                IF SLI.FINDFIRST THEN
                    REPEAT
                        IF (SLI.Type <> SLI.Type::" ") AND (SLI.Quantity <> 0) THEN BEGIN
                            IF SLI."GST Place of Supply" = SLI."GST Place of Supply"::"Ship-to Address" THEN
                                IF SalesInvHeader."Ship-to Code" <> '' THEN
                                    ShiptoAddress.RESET;
                            ShiptoAddress.SETRANGE(ShiptoAddress.Code, SalesInvHeader."Ship-to Code");
                            ShiptoAddress.SETRANGE(ShiptoAddress."Customer No.", SalesInvHeader."Sell-to Customer No.");
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
                IF SalesInvHeader."Ship-to Code" <> '' THEN BEGIN
                    ShiptoAddress.RESET;
                    ShiptoAddress.SETRANGE(ShiptoAddress.Code, SalesInvHeader."Ship-to Code");
                    ShiptoAddress.SETRANGE(ShiptoAddress."Customer No.", SalesInvHeader."Sell-to Customer No.");
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
        SalesInvoiceLine.SETRANGE("Document No.", SalesInvHeader."No.");
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


                IF (SalesInvHeader."Currency Code" = '') THEN BEGIN//PCPL50
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
                    IF (SalesInvHeader."Currency Code" <> '') OR (ExpCustomer."GST Customer Type" = ExpCustomer."GST Customer Type"::Export) THEN BEGIN
                        DetailedGSTLedgerEntry.RESET;
                        DetailedGSTLedgerEntry.SETCURRENTKEY("Transaction Type", "Document Type", "Document No.", "Document Line No.");
                        DetailedGSTLedgerEntry.SETRANGE("Transaction Type", DetailedGSTLedgerEntry."Transaction Type"::Sales);
                        DetailedGSTLedgerEntry.SETRANGE("Document No.", SalesInvoiceLine."Document No.");
                        DetailedGSTLedgerEntry.SETRANGE("Document Line No.", SalesInvoiceLine."Line No.");
                        IF DetailedGSTLedgerEntry.FINDSET THEN
                            REPEAT
                                IF DetailedGSTLedgerEntry."GST Component Code" = 'CGST' THEN BEGIN
                                    CGSTAmt := ABS(DetailedGSTLedgerEntry."GST Amount" / SalesInvHeader."Currency Factor");
                                    cgstrate := ABS(DetailedGSTLedgerEntry."GST %" / SalesInvHeader."Currency Factor");
                                END ELSE
                                    IF (DetailedGSTLedgerEntry."GST Component Code" = 'SGST') OR (DetailedGSTLedgerEntry."GST Component Code" = 'UTGST') THEN BEGIN
                                        SGSTAmt := ABS(DetailedGSTLedgerEntry."GST Amount" / SalesInvHeader."Currency Factor");
                                        sgstrate := ABS(DetailedGSTLedgerEntry."GST %" / SalesInvHeader."Currency Factor");
                                    END ELSE
                                        IF DetailedGSTLedgerEntry."GST Component Code" = 'IGST' THEN BEGIN
                                            IGSTAmt := ABS(DetailedGSTLedgerEntry."GST Amount" / SalesInvHeader."Currency Factor");
                                            igstrate := ABS(DetailedGSTLedgerEntry."GST %" / SalesInvHeader."Currency Factor");
                                        END ELSE
                                            IF DetailedGSTLedgerEntry."GST Component Code" = 'CESS' THEN BEGIN
                                                CESSGSTAmt := ABS(DetailedGSTLedgerEntry."GST Amount" / SalesInvHeader."Currency Factor");
                                                cessrate := (DetailedGSTLedgerEntry."GST %" / SalesInvHeader."Currency Factor");
                                            END;
                            UNTIL DetailedGSTLedgerEntry.NEXT = 0;

                        CLEAR(GSTRate);
                        IF (CGSTAmt <> 0) AND (SGSTAmt <> 0) THEN
                            GSTRate := ((cgstrate + sgstrate) / SalesInvHeader."Currency Factor");
                        IF IGSTAmt <> 0 THEN
                            GSTRate := (igstrate / SalesInvHeader."Currency Factor");
                        IF CESSGSTAmt <> 0 THEN
                            GSTRate := (cessrate / SalesInvHeader."Currency Factor");

                        //IF SalesInvoiceLine."GST Base Amount" = 0 THEN //PCPL/NSW/EINV 052522  Old Code Comment field not Exist in BC 19
                        IF GSTBaseAmtLineWise = 0 then //PCPL/NSW/EINV 052522 New Code Added
                            totaltaxableamt += (SalesInvoiceLine.Amount / SalesInvHeader."Currency Factor")
                        ELSE
                            totaltaxableamt += (GSTBaseAmtLineWise / SalesInvHeader."Currency Factor"); //PCPL/NSW/EINV 052522 New Code Added
                                                                                                        //totaltaxableamt += (SalesInvoiceLine."GST Base Amount" / "Currency Factor"); //PCPL/NSW/EINV 052522  Old Code Comment field not Exist in BC 19

                        TotalCGSTAmt += (CGSTAmt / SalesInvHeader."Currency Factor");
                        TotalSGSTAmt += (SGSTAmt / SalesInvHeader."Currency Factor");
                        TotalIGSTAmt += (IGSTAmt / SalesInvHeader."Currency Factor");
                        TotalCessGSTAmt += (CESSGSTAmt / SalesInvHeader."Currency Factor");

                        totalcessnonadvolvalue += 0;
                        TotalItemValue := ((SalesInvoiceLine."Line Amount" + CGSTAmt + SGSTAmt + IGSTAmt + CESSGSTAmt + TCSAMTLinewise) / SalesInvHeader."Currency Factor"); //PCPL/NSW/EINV 050522
                        totalinvoicevalue += ((SalesInvoiceLine."Line Amount" + CGSTAmt + SGSTAmt + IGSTAmt + CESSGSTAmt + TCSAMTLinewise) / SalesInvHeader."Currency Factor"); //PCPL/NSW/EINV 050522
                        totalcessvalueofstate += 0;
                        totaldiscount += (SalesInvoiceLine."Line Discount Amount" / SalesInvHeader."Currency Factor");
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
                IF SalesInvHeader."Currency Code" = '' THEN BEGIN //PCPL50
                    CLEAR(RoundOff);
                    IF SalesInvoiceLine."No." = '502650' THEN
                        RoundOff := SalesInvoiceLine."Line Amount";
                END
                //PCPL50 begin
                ELSE
                    IF (SalesInvHeader."Currency Code" <> '') OR (ExpCustomer."GST Customer Type" = ExpCustomer."GST Customer Type"::Export) THEN BEGIN
                        CLEAR(RoundOff);
                        IF SalesInvoiceLine."No." = '502650' THEN
                            RoundOff := (SalesInvoiceLine."Line Amount" / SalesInvHeader."Currency Factor");
                    END;
                //PCPL50 end
                // IF SalesInvoiceLine.Type=SalesInvoiceLine.Type::Item then



                IF SalesInvHeader."Currency Code" = '' THEN BEGIN //PCPL50
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
                    IF (SalesInvHeader."Currency Code" <> '') OR (ExpCustomer."GST Customer Type" = ExpCustomer."GST Customer Type"::Export) THEN BEGIN
                        IF (itemlist = '') AND (SalesInvoiceLine."No." <> '502650') THEN
                            itemlist := FORMAT(SalesInvoiceLine."Line No.") + '!' + Item."Description 2" + '!' + IsService + '!' + SalesInvoiceLine."HSN/SAC Code" + '!' + '' + '!' +
                            FORMAT(SalesInvoiceLine.Quantity) + '!' + '' + '!' + SalesInvoiceLine."Unit of Measure Code" + '!' + FORMAT(ROUND((SalesInvoiceLine."Unit Price" / SalesInvHeader."Currency Factor"), 0.01, '>')) + '!' +
                            FORMAT(SalesInvoiceLine."Line Amount" / SalesInvHeader."Currency Factor") + '!' + '0' + '!' + FORMAT(SalesInvoiceLine."Line Discount Amount" / SalesInvHeader."Currency Factor") + '!' + FORMAT(TCSAMTLineWise / SalesInvHeader."Currency Factor") +
                            '!' + FORMAT(GSTBaseAmtLineWise/*SalesInvoiceLine."Tax Base Amount" / "Currency Factor"*/) + '!' +/*FORMAT(ROUND(SalesInvoiceLine."GST %",1,'='))*/FORMAT(GSTRate) + '!' + FORMAT(IGSTAmt) + '!' + FORMAT(CGSTAmt) + '!' +
                            FORMAT(SGSTAmt) + '!' + FORMAT(cessrate) + '!' + FORMAT(CESSGSTAmt) + '!' + '0' + '!' + '0' + '!' + '0' + '!' + '0' + '!' + FORMAT(TotalItemValue) +
                            '!' + '' + '!' + '' + '!' + '' + '!' + '' + '!' + '' + '!' + '' + '' + '!' + ''
                        ELSE
                            IF SalesInvoiceLine."No." <> '502650' THEN
                                itemlist := itemlist + ';' + FORMAT(SalesInvoiceLine."Line No.") + '!' + Item."Description 2" + '!' + IsService + '!' + SalesInvoiceLine."HSN/SAC Code" +
                                '!' + '' + '!' + FORMAT(SalesInvoiceLine.Quantity) + '!' + '' + '!' + SalesInvoiceLine."Unit of Measure Code" + '!' +
                                FORMAT(ROUND((SalesInvoiceLine."Unit Price" / SalesInvHeader."Currency Factor"), 0.01, '>')) + '!' + FORMAT(SalesInvoiceLine."Line Amount" / SalesInvHeader."Currency Factor") + '!' + '0' + '!' +
                                FORMAT(SalesInvoiceLine."Line Discount Amount" / SalesInvHeader."Currency Factor") + '!' + FORMAT(TCSAMTLinewise / SalesInvHeader."Currency Factor") + '!' + FORMAT(GSTBaseAmtLineWise/*SalesInvoiceLine."Tax Base Amount" / "Currency Factor"*/) + '!' +
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
        valuedetails, EwayBillDetails, itemlist, GeneralLedgerSetup."EINV Path", SalesInvHeader."No.");
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
                IF NOT EInvoiceDetail.GET(SalesInvHeader."No.") THEN BEGIN
                    EInvoiceDetail.INIT;
                    EInvoiceDetail."Document No." := SalesInvHeader."No.";
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

                IF EInvoiceDetail.GET(SalesInvHeader."No.") THEN BEGIN
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
            ComponentAmt := TaxTypeObjHelper.GetComponentAmountFrmTransValue(TaxTransactionValue);
            //ComponentJObject.Add('Amount', ScriptDatatypeMgmt.ConvertXmlToLocalFormat(format(ComponentAmt, 0, 9), "Symbol Data Type"::NUMBER));
            JArray.Add(ComponentJObject);
        end;
        exit(ComponentAmt)

    end;
    //PCPL/NSW/EINV 050522
    local procedure GenerateEInvoiceCreditMemo(Var SalesCrHeader: Record 114);
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
        //TempBlob: Record "99008535";
        TempBlob1: Codeunit "Temp Blob";
        ServerFileNameTxt: Text;
        ClientFileNameTxt: Text;
        EInvoiceDetail: Record 50007;
        EINVPos: Text;
        GSTRate: Decimal;
        SalesCrMemoLine: Record 115;
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
        UOM: Text;
        RoundOff: Decimal;
        Natureofsupply: Text;
        ExpCustomer: Record 18;
        SCL: Record 115;
        IntS: InStream;
        outS: OutStream;


        SalesCrMemoLineNewEinv: Record "Sales Cr.Memo Line";
        TaxRecordID: RecordId;
        GSTBaseAmtLineWise: Decimal;
        ComponentJobject: JsonObject;
        TCSAMTLinewise: Decimal;
        DetailedGSTLedgerEntryNew: Record "Detailed GST Ledger Entry";
        GSTPer: Integer;
    begin
        //PCPL41-EINV
        CLEAR(Natureofsupply);
        ExpCustomer.GET(SalesCrHeader."Sell-to Customer No.");
        IF SalesCrHeader."GST Customer Type" = "GST Customer Type"::Export THEN BEGIN
            Natureofsupply := 'EXPWOP';
            transactiondetails := Natureofsupply + '!' + 'N' + '!' + '' + '!' + 'N';
        END ELSE
            IF ExpCustomer."GST Customer Type" = ExpCustomer."GST Customer Type"::"SEZ Unit" THEN BEGIN
                Natureofsupply := 'SEZWOP';
                transactiondetails := Natureofsupply + '!' + 'N' + '!' + '' + '!' + 'N';
            END ELSE
                transactiondetails := FORMAT(SalesCrHeader."Nature of Supply") + '!' + 'N' + '!' + '' + '!' + 'N';

        Document_Date := FORMAT(SalesCrHeader."Posting Date", 0, '<Day,2>/<Month,2>/<year4>');
        documentdetails := 'CRN' + '!' + SalesCrHeader."No." + '!' + Document_Date;

        CompanyInformation.GET;
        Location.GET(SalesCrHeader."Location Code");
        State.GET(Location."State Code");
        LocPhoneNo := DELCHR(Location."Phone No.", '=', '!|@|#|$|%|^|&|*|/|''|\|-| |(|)');
        sellerdetails := Location."GST Registration No." + '!' + CompanyInformation.Name + '!' + Location.Name + '!' + Location.Address + '!' + Location."Address 2" + '!' +
        SalesCrHeader."Location Code" + '!' + Location."Post Code" + '!' + State."State Code (GST Reg. No.)" + '!' + LocPhoneNo + '!' + Location."E-Mail";

        dispatchdetails := Location.Name + '!' + Location.Address + '!' + Location."Address 2" + '!' + SalesCrHeader."Location Code" + '!' + Location."Post Code" + '!' + State.Description;

        Customer.GET(SalesCrHeader."Sell-to Customer No.");
        BuyState.GET(Customer."State Code");
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
                SCL.RESET;
                SCL.SETRANGE("Document No.", SalesCrHeader."No.");
                IF SCL.FINDFIRST THEN
                    REPEAT
                        IF (SCL.Type <> SCL.Type::" ") AND (SCL.Quantity <> 0) THEN BEGIN
                            IF SCL."GST Place of Supply" = SCL."GST Place of Supply"::"Ship-to Address" THEN
                                IF SalesCrHeader."Ship-to Code" <> '' THEN
                                    ShiptoAddress.RESET;
                            ShiptoAddress.SETRANGE(ShiptoAddress.Code, SalesCrHeader."Ship-to Code");
                            ShiptoAddress.SETRANGE(ShiptoAddress."Customer No.", SalesCrHeader."Sell-to Customer No.");
                            IF ShiptoAddress.FINDFIRST THEN BEGIN
                                ShipState.GET(ShiptoAddress.State);
                                CustPhoneNo := DELCHR(ShiptoAddress."Phone No.", '=', '!|@|#|$|%|^|&|*|/|''|\|-| |(|)');
                                buyerdetails := ShiptoAddress."GST Registration No." + '!' + ShiptoAddress.Name + '!' + ShiptoAddress."Name 2" + '!' + ShiptoAddress.Address + '!' + ShiptoAddress."Address 2" + '!' +
                                ShiptoAddress.City + '!' + ShiptoAddress."Post Code" + '!' + ShipState."State Code (GST Reg. No.)" + '!' + ShipState.Description + '!' + CustPhoneNo + '!' +
                                ShiptoAddress."E-Mail";
                            END;
                        END;
                    UNTIL SCL.NEXT = 0;
            END;  //PCPL50 begin and else if end

        //PCPL0017-21-09-2021
        IF (ExpCustomer."GST Customer Type" = ExpCustomer."GST Customer Type"::Export) THEN BEGIN //PCPL0017-21-09-2021
            shipdetails := 'URP' + '!' + Customer.Name + '!' + Customer."Name 2" + '!' + Customer.Address + '!' + Customer."Address 2" + '!' +
            Customer.City + '!' + '999999' + '!' + '96';
        END ELSE //PCPL50 begin and else if end
            IF (ExpCustomer."GST Customer Type" <> ExpCustomer."GST Customer Type"::Export) THEN BEGIN //PCPL0017-21-09-2021
                IF SalesCrHeader."Ship-to Code" <> '' THEN BEGIN
                    ShiptoAddress.RESET;
                    ShiptoAddress.SETRANGE(ShiptoAddress.Code, SalesCrHeader."Ship-to Code");
                    ShiptoAddress.SETRANGE(ShiptoAddress."Customer No.", SalesCrHeader."Sell-to Customer No.");
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
        Clear(GSTBaseAmtLineWise);
        Clear(TaxRecordID);
        Clear(ComponentJobject);
        Clear(TCSAMTLinewise);
        Clear(GSTPer);

        SalesCrMemoLine.RESET;
        SalesCrMemoLine.SETCURRENTKEY("Document No.");
        SalesCrMemoLine.SETRANGE("Document No.", SalesCrHeader."No.");
        SalesCrMemoLine.SETFILTER(Type, '<>%1', SalesCrMemoLine.Type::" ");
        SalesCrMemoLine.SETFILTER(Quantity, '<>%1', 0);
        //SalesCrMemoLine.SETFILTER(SalesCrMemoLine."Unit of Measure Code",'<>%1','');
        IF SalesCrMemoLine.FINDSET THEN
            REPEAT
                CLEAR(CGSTAmt);
                CLEAR(SGSTAmt);
                CLEAR(IGSTAmt);
                CLEAR(CESSGSTAmt);
                CLEAR(cgstrate);
                CLEAR(sgstrate);
                CLEAR(igstrate);
                CLEAR(cessrate);

                Clear(GSTBaseAmtLineWise);
                Clear(TaxRecordID);
                Clear(ComponentJobject);
                Clear(TCSAMTLinewise);
                Clear(GSTPer);

                DetailedGSTLedgerEntry.RESET;
                DetailedGSTLedgerEntry.SETCURRENTKEY("Transaction Type", "Document Type", "Document No.", "Document Line No.");
                DetailedGSTLedgerEntry.SETRANGE("Transaction Type", DetailedGSTLedgerEntry."Transaction Type"::Sales);
                DetailedGSTLedgerEntry.SETRANGE("Document No.", SalesCrMemoLine."Document No.");
                DetailedGSTLedgerEntry.SETRANGE("Document Line No.", SalesCrMemoLine."Line No.");
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


                //<<PCPL/NSW/EINV 052522
                DetailedGSTLedgerEntryNew.RESET;
                DetailedGSTLedgerEntryNew.SETCURRENTKEY("Transaction Type", "Document Type", "Document No.", "Document Line No.");
                DetailedGSTLedgerEntryNew.SETRANGE("Transaction Type", DetailedGSTLedgerEntry."Transaction Type"::Sales);
                DetailedGSTLedgerEntryNew.SETRANGE("Document No.", SalesCrMemoLine."Document No.");
                DetailedGSTLedgerEntryNew.SETRANGE("Document Line No.", SalesCrMemoLine."Line No.");
                IF DetailedGSTLedgerEntryNew.FINDSET THEN begin
                    GSTPer := DetailedGSTLedgerEntry."GST %";
                end;
                //>>PCPL/NSW/EINV 052522



                CLEAR(GSTRate);
                IF (CGSTAmt <> 0) AND (SGSTAmt <> 0) THEN
                    GSTRate := cgstrate + sgstrate;
                IF IGSTAmt <> 0 THEN
                    GSTRate := igstrate;
                IF CESSGSTAmt <> 0 THEN
                    GSTRate := cessrate;


                //<<PCPL/NSW/EINV 052522
                if SalesCrMemoLineNewEinv.Get(SalesCrMemoLine."Document No.", SalesCrMemoLine."Line No.") then
                    TaxRecordID := SalesCrMemoLineNewEinv.RecordId();
                TCSAMTLinewise := GetTcsAmtLineWise(TaxRecordID, ComponentJobject);
                GSTBaseAmtLineWise := GetGSTBaseAmtLineWise(TaxRecordID, ComponentJobject);
                //>>PCPL/NSW/EINV 052522

                /* /* <<PCPL/NSW/030522 
                IF SalesCrMemoLine."GST Base Amount" = 0 THEN
                    totaltaxableamt += SalesCrMemoLine.Amount
                ELSE
                    totaltaxableamt += SalesCrMemoLine."GST Base Amount";
                */ //<<PCPL/NSW/030522

                //<<PCPL/NSW/030522     
                IF GSTBaseAmtLineWise = 0 THEN
                    totaltaxableamt += SalesCrMemoLine.Amount
                ELSE
                    totaltaxableamt += GSTBaseAmtLineWise;
                //>>PCPL/NSW/030522 

                TotalCGSTAmt += CGSTAmt;
                TotalSGSTAmt += SGSTAmt;
                TotalIGSTAmt += IGSTAmt;
                TotalCessGSTAmt += CESSGSTAmt;

                totalcessnonadvolvalue += 0;
                TotalItemValue := SalesCrMemoLine."Line Amount" + CGSTAmt + SGSTAmt + IGSTAmt + CESSGSTAmt + TCSAMTLinewise;//SalesCrMemoLine."TDS/TCS Amount"; //PCPL/NSW/030522 
                totalinvoicevalue += SalesCrMemoLine."Line Amount" + CGSTAmt + SGSTAmt + IGSTAmt + CESSGSTAmt + TCSAMTLinewise;//SalesCrMemoLine."TDS/TCS Amount"; //PCPL/NSW/030522 
                totalcessvalueofstate += 0;
                totaldiscount += SalesCrMemoLine."Line Discount Amount";
                totalothercharge += 0;//SalesCrMemoLine."Charges To Customer"; //PCPL/NSW/030522 

                IF SalesCrMemoLine."GST Group Type" = SalesCrMemoLine."GST Group Type"::Service THEN
                    IsService := 'Y'
                ELSE
                    IF SalesCrMemoLine."GST Group Type" = SalesCrMemoLine."GST Group Type"::Goods THEN
                        IsService := 'N';

                /*
                IF SalesCrMemoLine."Unit of Measure Code" = 'BL' THEN
                  UOM := 'OTH'
                ELSE IF SalesCrMemoLine."Unit of Measure Code" = 'KG' THEN
                  UOM := 'KGS'
                ELSE IF SalesCrMemoLine."Unit of Measure Code" = 'MT' THEN
                  UOM := 'MTS'
                ELSE
                  UOM := SalesCrMemoLine."Unit of Measure Code";
                */

                IF (SalesCrMemoLine.Type = SalesCrMemoLine.Type::"G/L Account") AND (SalesCrMemoLine."Unit of Measure Code" = '') THEN
                    UOM := 'NOS'
                ELSE
                    UOM := SalesCrMemoLine."Unit of Measure Code";

                CLEAR(RoundOff);
                IF SalesCrMemoLine."No." = '502650' THEN
                    RoundOff := SalesCrMemoLine."Line Amount";

                IF (itemlist = '') AND (SalesCrMemoLine."No." <> '502650') THEN
                    itemlist := FORMAT(SalesCrMemoLine."Line No.") + '!' + SalesCrMemoLine.Description + '!' + IsService + '!' + SalesCrMemoLine."HSN/SAC Code" + '!' + '' + '!' +
                    FORMAT(SalesCrMemoLine.Quantity) + '!' + '' + '!' + UOM + '!' + FORMAT(ROUND(SalesCrMemoLine."Unit Price", 0.01, '>')) + '!' +
                    FORMAT(SalesCrMemoLine."Line Amount") + '!' + '0' + '!' + FORMAT(SalesCrMemoLine."Line Discount Amount") + '!' + FORMAT(TCSAMTLinewise/*SalesCrMemoLine."TDS/TCS Amount"*/) +
                    '!' + FORMAT(GSTBaseAmtLineWise/*SalesCrMemoLine."Tax Base Amount"*/) + '!' +/*FORMAT(ROUND(SalesCrMemoLine."GST %",1,'='))*/FORMAT(GSTRate) + '!' + FORMAT(IGSTAmt) + '!' + FORMAT(CGSTAmt) + '!' +
                    FORMAT(SGSTAmt) + '!' + FORMAT(cessrate) + '!' + FORMAT(CESSGSTAmt) + '!' + '0' + '!' + '0' + '!' + '0' + '!' + '0' + '!' + FORMAT(TotalItemValue) +
                    '!' + '' + '!' + '' + '!' + '' + '!' + '' + '!' + '' + '!' + '' + '' + '!' + ''
                ELSE
                    IF SalesCrMemoLine."No." <> '502650' THEN
                        itemlist := itemlist + ';' + FORMAT(SalesCrMemoLine."Line No.") + '!' + SalesCrMemoLine.Description + '!' + IsService + '!' + SalesCrMemoLine."HSN/SAC Code" +
                        '!' + '' + '!' + FORMAT(SalesCrMemoLine.Quantity) + '!' + '' + '!' + UOM + '!' +
                        /*FORMAT(ROUND(SalesCrMemoLine."Unit Price",0.01,'>'))*/FORMAT(GSTRate) + '!' + FORMAT(SalesCrMemoLine."Line Amount") + '!' + '0' + '!' +
                        FORMAT(SalesCrMemoLine."Line Discount Amount") + '!' + FORMAT(TCSAMTLinewise/*SalesCrMemoLine."TDS/TCS Amount"*/) + '!' + FORMAT(GSTBaseAmtLineWise/*SalesCrMemoLine."Tax Base Amount"*/) + '!' +
                        FORMAT(ROUND(/*SalesCrMemoLine."GST %"*/GSTPer, 1, '=')) + '!' + FORMAT(IGSTAmt) + '!' + FORMAT(CGSTAmt) + '!' + FORMAT(SGSTAmt) + '!' + FORMAT(cessrate) + '!' +
                        FORMAT(CESSGSTAmt) + '!' + '0' + '!' + '0' + '!' + '0' + '!' + '0' + '!' + FORMAT(TotalItemValue) + '!' + '' + '!' + '' + '!' + '' + '!' + '' + '!' + '' + '!' + '' +
                        '' + '!' + ''
UNTIL SalesCrMemoLine.NEXT = 0;

        valuedetails := FORMAT(totaltaxableamt) + '!' + FORMAT(TotalCGSTAmt) + '!' + FORMAT(TotalCGSTAmt) + '!' + FORMAT(TotalIGSTAmt) + '!' + FORMAT(TotalCessGSTAmt) + '!' +
        FORMAT(totalcessnonadvolvalue) + '!' + FORMAT(totalinvoicevalue) + '!' + FORMAT(totalcessvalueofstate) + '!' + FORMAT(RoundOff) + '!' + '0' + '!' + FORMAT(totaldiscount) + '!' +
        FORMAT(totalothercharge);

        GeneralLedgerSetup.GET;
        EInvGT := EInvGT.TokenController;
        token := EInvGT.GetToken(GeneralLedgerSetup."EINV Base URL", GeneralLedgerSetup."EINV User Name", GeneralLedgerSetup."EINV Password",
        GeneralLedgerSetup."EINV Client ID", GeneralLedgerSetup."EINV Client Secret", GeneralLedgerSetup."EINV Grant Type");

        EInvGEI := EInvGEI.eInvoiceController;
        result := EInvGEI.GenerateEInvoice(GeneralLedgerSetup."EINV Base URL", token, Location."GST Registration No.", 'erp', transactiondetails,
        documentdetails, sellerdetails, buyerdetails, dispatchdetails, shipdetails, exportdetails, paymentdetails, referencedetails, AddDocDetails,
        valuedetails, EwayBillDetails, itemlist, GeneralLedgerSetup."EINV Path", SalesCrHeader."No.");

        CLEAR(EINVPos);
        EINVPos := COPYSTR(result, 1, 8);

        IF EINVPos = 'SUCCESS;' THEN BEGIN
            resresult := CONVERTSTR(result, ';', ',');
            resresult1 := SELECTSTR(1, resresult);
            resresult2 := SELECTSTR(2, resresult);
            resresult3 := SELECTSTR(3, resresult);
            resresult4 := SELECTSTR(4, resresult);

            IF resresult1 = 'SUCCESS' THEN BEGIN
                IF NOT EInvoiceDetail.GET(SalesCrHeader."No.") THEN BEGIN
                    EInvoiceDetail.INIT;
                    EInvoiceDetail."Document No." := SalesCrHeader."No.";
                    EInvoiceDetail."E-Invoice IRN No." := resresult2;
                    EInvoiceDetail."URL for PDF" := resresult4;

                    SLEEP(3000);
                    resresult3 := FileMgt.DownloadTempFile(resresult3);

                    SLEEP(5000);
                    //ServerFileNameTxt := FileMgt.UploadFileSilent(resresult3);
                    //FileMgt.BLOBImportFromServerFile(TempBlob, ServerFileNameTxt); //PCPL/NSW/030522 This Code is not work in BC 19
                    FileMgt.BLOBImportFromServerFile(TempBlob1, resresult3); //PCPL/MIG/NSW BC18 Customized code add coz above code not work in BC18
                    SLEEP(5000);

                    //<<PCPL/NSW/EINV 050522 New Code Added as compatible for BC 19
                    TempBlob1.CreateInStream(IntS);
                    EInvoiceDetail."E-Invoice QR Code".CreateOutStream(Outs);
                    CopyStream(Outs, IntS);
                    EInvoiceDetail."E-Invoice Acknowledgement Date Time" := CurrentDateTime;
                    //EInvoiceDetail.Modify();
                    //>>    
                    //EInvoiceDetail."E-Invoice QR Code" := TempBlob.Blob; //PCPL/NSW/030522 No Needed now  above code will assign Data to QR Field
                    EInvoiceDetail.INSERT;

                    //FILE.ERASE(ServerFileNameTxt);

                    MESSAGE('E-Invoice has been generated.');
                END;
            END;
        END ELSE
            ERROR(result);
        //PCPL41-EINV

    end;

    local procedure GenerateEInvoiceTransgerShipment(Var TranShipHeader: Record "Transfer Shipment Header");
    var
        EInvGT: DotNet EInvTokenController;
        token: Text;
        EInvGEI: DotNet EInvController;
        result: Text;
        resresult: Text;
        resresult1: Text;
        resresult2: Text;
        resresult3: Text;
        resresult4: Text;
        EInvoiceDetail: Record 50007;
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
        adddocdetails: Text;
        ewaybilldetails: Text;
        CompanyInformation: Record 79;
        LocFrm: Record 14;
        State: Record State;
        LocTo: Record 14;
        BuyState: Record State;
        DetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry";
        TransferShipmentLine: Record 5745;
        IGSTAmt: Decimal;
        totaltaxableamt: Decimal;
        TotalIGSTAmt: Decimal;
        totalinvoicevalue: Decimal;
        GeneralLedgerSetup: Record 98;
        FileMgt: Codeunit 419;
        //TempBlob: Record "99008535";
        Tempblob1: Codeunit "Temp Blob";
        ServerFileNameTxt: Text;
        EINVPos: Text;
        Document_Date: Text;
        TotalItemValue: Decimal;
        UOM: Text;
        LocPhoneNo: Text;
        LocTotPhoneNo: Text;
        TotalAmt: Decimal;
        IntS: InStream;
        Outs: OutStream;
        DetailedGSTLedgerEntryNew: Record "Detailed GST Ledger Entry";
        GSTBASEAMT: Decimal;
        GSTPer: Integer;

    begin
        //PCPL41-EINV
        transactiondetails := 'B2B' + '!' + 'N' + '!' + '' + '!' + 'N';

        Document_Date := FORMAT(TranShipHeader."Posting Date", 0, '<Day,2>/<Month,2>/<year4>');
        documentdetails := 'INV' + '!' + TranShipHeader."No." + '!' + Document_Date;

        CompanyInformation.GET;
        LocFrm.GET(TranShipHeader."Transfer-from Code");
        State.GET(LocFrm."State Code");
        LocPhoneNo := DELCHR(LocFrm."Phone No.", '=', '!|@|#|$|%|^|&|*|/|''|\|-| |(|)');
        sellerdetails := LocFrm."GST Registration No." + '!' + CompanyInformation.Name + '!' + LocFrm.Name + '!' + LocFrm.Address + '!' + LocFrm."Address 2" +
        '!' + TranShipHeader."Transfer-from Code" + '!' + LocFrm."Post Code" + '!' + State."State Code (GST Reg. No.)" + '!' + LocPhoneNo + '!' + LocFrm."E-Mail";

        dispatchdetails := LocFrm.Name + '!' + LocFrm.Address + '!' + LocFrm."Address 2" + '!' + TranShipHeader."Transfer-from Code" + '!' + LocFrm."Post Code" + '!' +
        State.Description;

        LocTo.GET(TranShipHeader."Transfer-to Code");
        BuyState.GET(LocTo."State Code");
        LocTotPhoneNo := DELCHR(LocTo."Phone No.", '=', '!|@|#|$|%|^|&|*|/|''|\|-| |(|)');
        buyerdetails := LocTo."GST Registration No." + '!' + LocTo.Name + '!' + LocTo."Name 2" + '!' + LocTo.Address + '!' + LocTo."Address 2" + '!' +
        LocTo.City + '!' + LocTo."Post Code" + '!' + BuyState."State Code (GST Reg. No.)" + '!' + BuyState.Description + '!' + LocTotPhoneNo + '!' +
        LocTo."E-Mail";

        shipdetails := '';
        exportdetails := '';
        paymentdetails := '';
        referencedetails := '';
        adddocdetails := '';
        ewaybilldetails := '';

        CLEAR(IGSTAmt);
        CLEAR(TotalIGSTAmt);
        CLEAR(totaltaxableamt);
        CLEAR(totalinvoicevalue);
        CLEAR(itemlist);
        CLEAR(UOM);
        CLEAR(TotalAmt);
        Clear(GSTBASEAMT);
        Clear(GSTPer);

        TransferShipmentLine.RESET;
        TransferShipmentLine.SETCURRENTKEY("Document No.");
        TransferShipmentLine.SETRANGE("Document No.", TranShipHeader."No.");
        TransferShipmentLine.SETFILTER(TransferShipmentLine."Unit of Measure Code", '<>%1', '');
        IF TransferShipmentLine.FINDSET THEN
            REPEAT
                DetailedGSTLedgerEntry.RESET;
                DetailedGSTLedgerEntry.SETCURRENTKEY("Transaction Type", "Document Type", "Document No.", "Document Line No.");
                DetailedGSTLedgerEntry.SETRANGE("Transaction Type", DetailedGSTLedgerEntry."Transaction Type"::Sales);
                DetailedGSTLedgerEntry.SETRANGE("Document No.", TransferShipmentLine."Document No.");
                DetailedGSTLedgerEntry.SETRANGE("Document Line No.", TransferShipmentLine."Line No.");
                IF DetailedGSTLedgerEntry.FINDSET THEN
                    REPEAT
                        IF DetailedGSTLedgerEntry."GST Component Code" = 'IGST' THEN
                            IGSTAmt := ABS(DetailedGSTLedgerEntry."GST Amount")
                UNTIL DetailedGSTLedgerEntry.NEXT = 0;

                //<<PCPL/NSW/EINV   10May2022
                DetailedGSTLedgerEntryNew.RESET;
                DetailedGSTLedgerEntryNew.SETCURRENTKEY("Transaction Type", "Document Type", "Document No.", "Document Line No.");
                DetailedGSTLedgerEntryNew.SETRANGE("Transaction Type", DetailedGSTLedgerEntry."Transaction Type"::Sales);
                DetailedGSTLedgerEntryNew.SETRANGE("Document No.", TransferShipmentLine."Document No.");
                DetailedGSTLedgerEntryNew.SETRANGE("Document Line No.", TransferShipmentLine."Line No.");
                IF DetailedGSTLedgerEntryNew.FindFirst() then begin
                    GSTBASEAMT := ABS(DetailedGSTLedgerEntryNew."GST Base Amount");
                    GSTPer := DetailedGSTLedgerEntryNew."GST %";
                end else begin
                    GSTBASEAMT := 0;
                end;
                //>>PCPL/NSW/EINV   10May2022


                /* //PCPL/NSW/EINV   10May2022
                IF TransferShipmentLine."GST Base Amount" = 0 THEN BEGIN
                    TotalAmt := TransferShipmentLine.Amount;
                    TotalItemValue := TransferShipmentLine.Amount + IGSTAmt;
                END ELSE BEGIN
                    TotalAmt := TransferShipmentLine."GST Base Amount";
                    TotalItemValue := TransferShipmentLine."GST Base Amount" + IGSTAmt;
                END;
                */ //PCPL/NSW/EINV   10May2022

                IF GSTBASEAMT = 0 THEN BEGIN
                    TotalAmt := TransferShipmentLine.Amount;
                    TotalItemValue := TransferShipmentLine.Amount + IGSTAmt;
                END ELSE BEGIN
                    TotalAmt := GSTBASEAMT;
                    TotalItemValue := GSTBASEAMT + IGSTAmt;
                END;

                TotalIGSTAmt += IGSTAmt;
                totaltaxableamt += TotalAmt;
                totalinvoicevalue += TotalItemValue;

                IF TransferShipmentLine."Unit of Measure Code" = 'BL' THEN
                    UOM := 'OTH'
                ELSE
                    IF TransferShipmentLine."Unit of Measure Code" = 'KG' THEN
                        UOM := 'KGS'
                    ELSE
                        IF TransferShipmentLine."Unit of Measure Code" = 'MT' THEN
                            UOM := 'MTS'
                        ELSE
                            IF TransferShipmentLine."Unit of Measure Code" = 'PKT' THEN
                                UOM := 'PAC'
                            ELSE
                                UOM := TransferShipmentLine."Unit of Measure Code";

                IF itemlist = '' THEN
                    itemlist := FORMAT(TransferShipmentLine."Line No.") + '!' + TransferShipmentLine.Description + '!' + 'N' + '!' +
                    TransferShipmentLine."HSN/SAC Code" + '!' + '' + '!' + FORMAT(TransferShipmentLine.Quantity) + '!' + '' + '!' + UOM + '!' +
                    FORMAT(ROUND(GSTPer/*TransferShipmentLine."Unit Price"*/, 0.01, '>')) + '!' + FORMAT(TotalAmt) + '!' + '0' + '!' + '0' + '!' + '0' + '!' + FORMAT(TotalAmt) + '!' +
                    FORMAT(ROUND(GSTPer, 1, '=')) + '!' + FORMAT(IGSTAmt) + '!' + '0' + '!' + '0' + '!' + '0' + '!' + '0' + '!' + '0' + '!' + '0' + '!' + '0' +
                    '!' + '0' + '!' + FORMAT(TotalItemValue) + '!' + '' + '!' + '' + '!' + '' + '!' + '' + '!' + '' + '!' + '' + '' + '!' + ''
                ELSE
                    itemlist := itemlist + ';' + FORMAT(TransferShipmentLine."Line No.") + '!' + TransferShipmentLine.Description + '!' + 'N' + '!' +
                    TransferShipmentLine."HSN/SAC Code" + '!' + '' + '!' + FORMAT(TransferShipmentLine.Quantity) + '!' + '' + '!' + UOM + '!' +
                    FORMAT(ROUND(TransferShipmentLine."Unit Price", 0.01, '>')) + '!' + FORMAT(TotalAmt) + '!' + '0' + '!' + '0' + '!' + '0' + '!' + FORMAT(TotalAmt) + '!' +
                    FORMAT(ROUND(GSTPer/*TransferShipmentLine."GST %"*/, 1, '=')) + '!' + FORMAT(IGSTAmt) + '!' + '0' + '!' + '0' + '!' + '0' + '!' + '0' + '!' + '0' + '!' + '0' + '!' + '0' +
                    '!' + '0' + '!' + FORMAT(TotalItemValue) + '!' + '' + '!' + '' + '!' + '' + '!' + '' + '!' + '' + '!' + '' + '' + '!' + ''
        UNTIL TransferShipmentLine.NEXT = 0;

        valuedetails := FORMAT(totaltaxableamt) + '!' + '0' + '!' + '0' + '!' + FORMAT(TotalIGSTAmt) + '!' + '0' + '!' + '0' + '!' + FORMAT(totalinvoicevalue) + '!' +
        '0' + '!' + '0' + '!' + '0' + '!' + '0' + '!' + '0';

        GeneralLedgerSetup.GET;
        EInvGT := EInvGT.TokenController;
        token := EInvGT.GetToken(GeneralLedgerSetup."EINV Base URL", GeneralLedgerSetup."EINV User Name", GeneralLedgerSetup."EINV Password",
        GeneralLedgerSetup."EINV Client ID", GeneralLedgerSetup."EINV Client Secret", GeneralLedgerSetup."EINV Grant Type");

        EInvGEI := EInvGEI.eInvoiceController;
        result := EInvGEI.GenerateEInvoice(GeneralLedgerSetup."EINV Base URL", token, LocFrm."GST Registration No.", 'erp', transactiondetails,
        documentdetails, sellerdetails, buyerdetails, dispatchdetails, shipdetails, exportdetails, paymentdetails, referencedetails, adddocdetails,
        valuedetails, ewaybilldetails, itemlist, GeneralLedgerSetup."EINV Path", TranShipHeader."No.");

        CLEAR(EINVPos);
        EINVPos := COPYSTR(result, 1, 8);
        IF EINVPos = 'SUCCESS;' THEN BEGIN
            resresult := CONVERTSTR(result, ';', ',');
            resresult1 := SELECTSTR(1, resresult);
            resresult2 := SELECTSTR(2, resresult);
            resresult3 := SELECTSTR(3, resresult);
            resresult4 := SELECTSTR(4, resresult);

            IF resresult1 = 'SUCCESS' THEN BEGIN
                IF NOT EInvoiceDetail.GET(TranShipHeader."No.") THEN BEGIN
                    EInvoiceDetail.INIT;
                    EInvoiceDetail."Document No." := TranShipHeader."No.";
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

                IF EInvoiceDetail.GET(TranShipHeader."No.") THEN BEGIN
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





}