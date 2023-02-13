pageextension 50298 Posted_Tra_ship_ext extends "Posted Transfer Shipment"
{
    layout
    {
        movebefore("Transport Vendor"; "Shipping Agent Code")
        modify("Shipping Agent Code")
        {
            Editable = true;
            trigger OnAfterValidate()
            var
                ShipAgent: Record "Shipping Agent";
            begin
                IF ShipAgent.GET("Shipping Agent Code") then begin
                    "Transport Vendor" := Shipagent.Name;
                end

            end;
        }

        modify("GST E-Invoice1")
        {
            Visible = false;
        }
        modify("E-Invoice Error Remarks")
        {
            Visible = false;
        }
        modify("E-Way Bill No.")
        {
            Visible = false;
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
            // group("E-way Bill Data")
            // {
            //     field("E-Way Bill Generate"; "E-Way Bill Generate")
            //     {
            //         ApplicationArea = all;
            //         Visible = false;
            //     }
            // }

        }
        addbefore("Foreign Trade")
        {
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
        modify("Generate GST E-Invoice")
        {
            Visible = false;
        }
        addafter(Dimensions)
        {
            action("Generate E-Invoice")
            {
                Enabled = EINVGenerate;
                // Enabled = true;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Visible = true;
                ApplicationArea = all;
                Image = ExportFile;

                trigger OnAction();
                begin
                    //PCPL41-EINV
                    IF NOT CONFIRM('Do you want to generate E-Invoice.', TRUE) THEN
                        EXIT;
                    GenerateEInvoice;
                    //PCPL41-EINV
                end;
            }
            action("Cancel E-Invoice")
            {
                Enabled = EINVCancel;
                Image = Cancel;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Visible = true;
                ApplicationArea = all;

                trigger OnAction();
                begin
                    //PCPL41-EINV
                    IF NOT CONFIRM('Do you want to Cancel E-Invoice.', TRUE) THEN
                        EXIT;
                    CancelEInvoice;
                    //PCPL41-EINV
                end;
            }

            action("Generate E-Way Bill")
            {
                Enabled = EWAYGEN;
                Image = "Action";
                Promoted = true;
                PromotedCategory = Process;
                ApplicationArea = all;
                Caption = 'Generate E-Way Bill';
                trigger OnAction();
                var
                    SalesPost: Codeunit 80;
                    TSH: Record "Transfer Shipment Header";
                begin
                    //PCPL41-EWAY
                    IF NOT CONFIRM('Do you want generate E-Way Bill?') THEN
                        EXIT;
                    TSH.Reset();
                    TSH.SetRange(TSH."No.", "No.");
                    IF TSH.FindFirst() then begin
                        "E-Way Bill Generate" := "E-Way Bill Generate"::"To Generate";
                        Modify();
                    end;
                    IF "E-Way Bill Generate" = "E-Way Bill Generate"::"To Generate" THEN
                        EWayBillGenerate
                    ELSE
                        ERROR('E-way Bill Generate should be "To Generate".');
                    //PCPL41-EWAY
                end;
            }

        }
    }
    //}



    local procedure GenerateEInvoice();
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

        Document_Date := FORMAT("Posting Date", 0, '<Day,2>/<Month,2>/<year4>');
        documentdetails := 'INV' + '!' + "No." + '!' + Document_Date;

        CompanyInformation.GET;
        LocFrm.GET("Transfer-from Code");
        State.GET(LocFrm."State Code");
        LocPhoneNo := DELCHR(LocFrm."Phone No.", '=', '!|@|#|$|%|^|&|*|/|''|\|-| |(|)');
        sellerdetails := LocFrm."GST Registration No." + '!' + CompanyInformation.Name + '!' + LocFrm.Name + '!' + LocFrm.Address + '!' + LocFrm."Address 2" +
        '!' + "Transfer-from Code" + '!' + LocFrm."Post Code" + '!' + State."State Code (GST Reg. No.)" + '!' + LocPhoneNo + '!' + LocFrm."E-Mail";

        dispatchdetails := LocFrm.Name + '!' + LocFrm.Address + '!' + LocFrm."Address 2" + '!' + "Transfer-from Code" + '!' + LocFrm."Post Code" + '!' +
        State.Description;

        LocTo.GET("Transfer-to Code");
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
        TransferShipmentLine.SETRANGE("Document No.", "No.");
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
        valuedetails, ewaybilldetails, itemlist, GeneralLedgerSetup."EINV Path", "No.");

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


    local procedure CancelEInvoice();
    var
        GeneralLedgerSetup: Record 98;
        LocFrm: Record 14;
        EInvGT: DotNet EInvTokenController;
        token: Text;
        EInvGEI: DotNet EInvController;
        CancelPos: Text;
        result: Text;
        resresult: Text;
        resresult1: Text;
        resresult2: Text;
    begin
        //PCPL41-EINV
        GeneralLedgerSetup.GET;
        EInvGT := EInvGT.TokenController;
        token := EInvGT.GetToken(GeneralLedgerSetup."EINV Base URL", GeneralLedgerSetup."EINV User Name", GeneralLedgerSetup."EINV Password",
        GeneralLedgerSetup."EINV Client ID", GeneralLedgerSetup."EINV Client Secret", GeneralLedgerSetup."EINV Grant Type");

        LocFrm.GET("Transfer-to Code");
        EInvGEI := EInvGEI.eInvoiceController;
        result := EInvGEI.CancelEInvoice(GeneralLedgerSetup."EINV Base URL", token, LocFrm."GST Registration No.", "EINV IRN No.", "Cancel Remark", '1',
        "No.", GeneralLedgerSetup."EINV Path");

        CLEAR(CancelPos);
        CancelPos := COPYSTR(result, 1, 2);

        IF CancelPos = 'Y;' THEN BEGIN
            resresult := CONVERTSTR(result, ';', ',');
            resresult1 := SELECTSTR(1, resresult);
            resresult2 := SELECTSTR(2, resresult);

            IF resresult1 = 'Y' THEN BEGIN
                "Cancel IRN No." := resresult2;
                "EINV IRN No." := '';
                CLEAR("EINV QR Code");
                MODIFY;
                MESSAGE('E-Invoice has been cancelled');
            END;
        END ELSE
            ERROR(result);
        //PCPL41-EINV
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
            EINVGenerate := TRUE;
            EINVCancel := FALSE;
        END;

        EInvoiceDetailNew.RESET;
        EInvoiceDetailNew.SETRANGE("Document No.", "No.");
        EInvoiceDetailNew.SetFilter("E-Invoice IRN No.", '<>%1', '');
        IF EInvoiceDetailNew.FINDFIRST THEN BEGIN
            EINVGenerate := FALSE;
            EINVCancel := TRUE;
        END;
        //PCPL41-EINV

        EWayBillDetailNew.RESET;
        EWayBillDetailNew.SETRANGE("Document No.", "No.");
        EWayBillDetailNew.SETFILTER("Eway Bill No.", '<>%1', '');
        IF EWayBillDetailNew.FINDFIRST THEN BEGIN
            EWAYGEN := FALSE;
        END ELSE
            EWAYGEN := TRUE;
        //PCPL0017-EWAY



    end;

    trigger OnAfterGetRecord()
    var
        EWayBillDetailNew: Record 50008;
    Begin

        EWayBillDetailNew.RESET;
        EWayBillDetailNew.SETRANGE("Document No.", "No.");
        EWayBillDetailNew.SETFILTER("Eway Bill No.", '<>%1', '');
        IF EWayBillDetailNew.FINDFIRST THEN BEGIN
            EWAYGEN := FALSE;
        END ELSE
            EWAYGEN := TRUE;
    End;

    var
        EINVGenerate: Boolean;
        EINVCancel: Boolean;
        EWAYGEN: Boolean;



    procedure EWayBillGenerate();
    var
        Headerdata: Text;
        Linedata: Text;
        Location_: Record 14;
        State_: Record State;
        StateCust: Record State;
        HSNSAN: Record "HSN/SAC";
        ShipQty: Decimal;
        cnt: Integer;
        Item_: Record 27;
        DetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry";
        IGSTAmt: Decimal;
        CESSGSTAmt: Integer;
        IgstRate: Decimal;
        TotalIGSTAmt: Decimal;
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
        GeneralLedgerSetup: Record 98;
        recToLoc: Record 14;
        TransferShipmentLine: Record 5745;
        TotaltaxableAmt1: Text;
        TotaltaxableAmt1Total: Decimal;
        Ewaybill: DotNet Ewaybillcontroller;
        token: Text;
        result: Text;
        TotalInvAmt: Decimal;
        UOM: Text;
        //<<PCPL/NSW/EINV 052522
        TaxRecordIDEWAY: RecordId;
        TCSAMTLinewiseEWAY: Decimal;
        GSTBaseAmtLineWiseEWAY: Decimal;
        ComponentJobjectEWAY: JsonObject;
        EWayBillDetail: Record 50008;
        TranShipLine: Record "Transfer Shipment Line";
        resresult: Text;
        resresult1: Text;
        resresult2: Text;
        TraShipHeader: Record "Transfer Shipment Header";
    //>>PCPL/NSW/EINV 052522


    begin
        //PCPL41-EWAY
        IF Location_.GET("Transfer-from Code") THEN;
        IF State_.GET(Location_."State Code") THEN;
        IF recToLoc.GET("Transfer-to Code") THEN;
        IF StateCust.GET(recToLoc."State Code") THEN;

        TotalIGSTAmt := 0;
        TotalTaxableAmt := 0;
        cnt := 0;
        Linedata := '[';
        // HSNSAN.RESET;
        // HSNSAN.SETCURRENTKEY("GST Group Code", Code);
        // IF HSNSAN.FINDSET THEN
        //         REPEAT
        IGSTAmt := 0;
        ShipQty := 0;
        IgstRate := 0;
        Clear(TotaltaxableAmt1Total);
        TransferShipmentLine.RESET;
        TransferShipmentLine.SETCURRENTKEY("Document No.", "Line No.");
        TransferShipmentLine.SETRANGE("Document No.", "No.");
        //TransferShipmentLine.SETRANGE("HSN/SAC Code", HSNSAN.Code);
        //TransferShipmentLine.SETRANGE("GST Group Code", HSNSAN."GST Group Code");
        IF TransferShipmentLine.FINDSET THEN
            REPEAT
                DetailedGSTLedgerEntry.RESET;
                DetailedGSTLedgerEntry.SETCURRENTKEY("Transaction Type", "Document Type", "Document No.", "Document Line No.");
                DetailedGSTLedgerEntry.SETRANGE("Transaction Type", DetailedGSTLedgerEntry."Transaction Type"::Sales);
                DetailedGSTLedgerEntry.SETRANGE("Document No.", TransferShipmentLine."Document No.");
                DetailedGSTLedgerEntry.SETRANGE("Document Line No.", TransferShipmentLine."Line No.");
                IF DetailedGSTLedgerEntry.FINDSET THEN
                    REPEAT
                        IF DetailedGSTLedgerEntry."GST Component Code" = 'IGST' THEN BEGIN
                            IGSTAmt := ABS(DetailedGSTLedgerEntry."GST Amount");
                            IgstRate := DetailedGSTLedgerEntry."GST %";
                            Supply := 'Outward';
                            Subsupply := 'Supply';
                        END;
                    UNTIL DetailedGSTLedgerEntry.NEXT = 0;
                /*
                IF TransferShipmentLine."Unit of Measure Code" = 'PAIR' THEN
                  UomValue := 'PRS'
                ELSE
                  UomValue := 'PCS';
                */
                TotalIGSTAmt += IGSTAmt;

                //<<PCPL/NSW/EINV 052522
                if TranShipLine.Get(TransferShipmentLine."Document No.", TransferShipmentLine."Line No.") then
                    TaxRecordIDEWAY := TransferShipmentLine.RecordId();
                TCSAMTLinewiseEWAY := GetTcsAmtLineWise(TaxRecordIDEWAY, ComponentJobjectEWAY);
                GSTBaseAmtLineWiseEWAY := GetGSTBaseAmtLineWise(TaxRecordIDEWAY, ComponentJobjectEWAY);
                //>>PCPL/NSW/EINV 052522

                //IF TransferShipmentLine."GST Base Amount" = 0 THEN BEGIN
                //clear(TotalTaxableAmt);
                IF (GSTBaseAmtLineWiseEWAY = 0) THEN BEGIN //PCPL/NSW/EINV 052522  New Code added
                    TotalTaxableAmt := TransferShipmentLine.Amount;
                    TotalInvAmt += TransferShipmentLine.Amount + IGSTAmt;
                    DocumentType := 'Delivery Challan';
                    Supply := 'Outward';
                    Subsupply := 'Others';
                    SubSupplydescr := 'Others';
                END ELSE BEGIN
                    TotalTaxableAmt += GSTBaseAmtLineWiseEWAY;//TransferShipmentLine."GST Base Amount";
                    TotalInvAmt += GSTBaseAmtLineWiseEWAY + IGSTAmt;
                    DocumentType := 'Tax Invoice';
                    Supply := 'Outward';
                    Subsupply := 'Supply';
                END;

                IF Item_.GET(TransferShipmentLine."Item No.") THEN;

                //  UNTIL TransferShipmentLine.NEXT = 0;

                IF TotalTaxableAmt > 1000 THEN
                    TotaltaxableAmt1 := DELCHR(FORMAT(TotalTaxableAmt), '=', ',');

                TotaltaxableAmt1Total += TotaltaxableAmt;

                IF TransferShipmentLine."Unit of Measure Code" = 'PKT' THEN
                    UOM := 'PAC'
                ELSE
                    UOM := TransferShipmentLine."Unit of Measure Code";

                cnt += 1;
                IF cnt = 1 THEN
                    Linedata += '{"product_name":"' + Item_.Description + '","product_description":"' + Item_.Description + '","hsn_code":"' +
                    TransferShipmentLine."HSN/SAC Code" + '","quantity":"' + FORMAT(TransferShipmentLine.Quantity) + '","unit_of_product":"' + UOM + '","cgst_rate":"' + '0' +
                    '","sgst_rate":"' + '0' + '","igst_rate":"' + FORMAT(IgstRate) + '","cess_rate":"' + '0' + '","cessNonAdvol":"' + '0' +
                    '","taxable_amount":"' + FORMAT(TotaltaxableAmt1) + '"}'
                ELSE
                    Linedata += ',{"product_name":"' + Item_.Description + '","product_description":"' + Item_.Description + '","hsn_code":"' +
                    TransferShipmentLine."HSN/SAC Code" + '","quantity":"' + FORMAT(TransferShipmentLine.Quantity) + '","unit_of_product":"' + UOM + '","cgst_rate":"' + '0' +
                    '","sgst_rate":"' + '0' + '","igst_rate":"' + FORMAT(IgstRate) + '","cess_rate":"' + '0' + '","cessNonAdvol":"' + '0' +
                    '","taxable_amount":"' + FORMAT(TotaltaxableAmt1) + '"}';

            // UNTIL HSNSAN.NEXT = 0;
            UNTIL TransferShipmentLine.NEXT = 0;

        Linedata := Linedata + ']';

        GeneralLedgerSetup.GET;
        Ewaybill := Ewaybill.eWaybillController;
        token := Ewaybill.GetToken(GeneralLedgerSetup."EINV Base URL", GeneralLedgerSetup."EINV User Name", GeneralLedgerSetup."EINV Password",
        GeneralLedgerSetup."EINV Client ID", GeneralLedgerSetup."EINV Client Secret", GeneralLedgerSetup."EINV Grant Type", GeneralLedgerSetup."EINV Path");
        IF EWayBillDetail.GET("No.") then;
        //token := Ewaybill.GetToken('https://clientbasic.mastersindia.co', 'testeway@mastersindia.co', 'Test@1234',
        //'fIXefFyxGNfDWOcCWn', 'QFd6dZvCGqckabKxTapfZgJc', 'password');
        //Original code Comment for Test DB for Testing Purpose
        /*
        Document_Date := FORMAT("Posting Date", 0, '<Day,2>/<Month,2>/<year4>');
        Headerdata := '{"access_token":"' + token + '","userGstin":"' + Location_."GST Registration No." + '","supply_type":"' + Supply + '","sub_supply_type":"' + Subsupply +
        '","sub_supply_description":"' + SubSupplydescr + '","document_type":"' + DocumentType + '","document_number":"' + "No." +
        '","document_date":"' + Document_Date + '","gstin_of_consignor":"' + Location_."GST Registration No." + '","legal_name_of_consignor":"' + Location_.Name +
        '","address1_of_consignor":"' + Location_.Address + '","address2_of_consignor":"' + Location_."Address 2" + '","place_of_consignor":"' +
        Location_.City + '","pincode_of_consignor":"' + Location_."Post Code" + '","state_of_consignor":"' + State_.Description +
        '","actual_from_state_name":"' + State_.Description + '","gstin_of_consignee":"' + recToLoc."GST Registration No." + '","legal_name_of_consignee":"' + recToLoc.Name +
        '","address1_of_consignee":"' + recToLoc.Address + '","address2_of_consignee":"' + recToLoc."Address 2" +
        '","place_of_consignee":"' + recToLoc.City + '","pincode_of_consignee":"' + recToLoc."Post Code" + '","state_of_supply":"' + StateCust.Description +
        '","actual_to_state_name":"' + StateCust.Description + '","transaction_type":"' + "Transaction Type" + '","other_value":"' + '' +
        '","total_invoice_value":"' + FORMAT(TotalInvAmt) + '","taxable_amount":"' + FORMAT(TotaltaxableAmt1Total) + '","cgst_amount":"' +
        '0' + '","sgst_amount":"' + '0' + '","igst_amount":"' + FORMAT(TotalIGSTAmt) + '","cess_amount":"' +
        '0' + '","cess_nonadvol_value":"' + '0' + '","transporter_id":"' + Location_."GST Registration No." + '","transporter_name":"' +
        EWayBillDetail."Transporter Name" + '","transporter_document_number":"' + '' + '","transporter_document_date":"' + '' + '","transportation_mode":"' +
        EWayBillDetail."Transportation Mode" + '","transportation_distance":"' + FORMAT(EWayBillDetail."Transport Distance") + '","vehicle_number":"' +
        "Vehicle No." + '","vehicle_type":"' + 'Regular' + '","generate_status":"' + '1' + '","data_source":"' + 'erp' + '","user_ref":"' + '' +
        '","location_code":"' + Location_.Code + '","eway_bill_status":"' + FORMAT("E-Way Bill Generate") + '","auto_print":"' + 'Y' + '","email":"' +
        Location_."E-Mail" + '"}';
        */
        Document_Date := FORMAT("Posting Date", 0, '<Day,2>/<Month,2>/<year4>');
        Headerdata := '{"access_token":"' + token + '","userGstin":"' + '05AAABB0639G1Z8' + '","supply_type":"' + Supply + '","sub_supply_type":"' + Subsupply +
        '","sub_supply_description":"' + SubSupplydescr + '","document_type":"' + DocumentType + '","document_number":"' + "No." +
        '","document_date":"' + Document_Date + '","gstin_of_consignor":"' + '05AAABB0639G1Z8' + '","legal_name_of_consignor":"' + Location_.Name +
        '","address1_of_consignor":"' + Location_.Address + '","address2_of_consignor":"' + Location_."Address 2" + '","place_of_consignor":"' +
        Location_.City + '","pincode_of_consignor":"' + Location_."Post Code" + '","state_of_consignor":"' + State_.Description +
        '","actual_from_state_name":"' + State_.Description + '","gstin_of_consignee":"' + '05AAABC0181E1ZE' + '","legal_name_of_consignee":"' + recToLoc.Name +
        '","address1_of_consignee":"' + recToLoc.Address + '","address2_of_consignee":"' + recToLoc."Address 2" +
        '","place_of_consignee":"' + recToLoc.City + '","pincode_of_consignee":"' + recToLoc."Post Code" + '","state_of_supply":"' + StateCust.Description +
        '","actual_to_state_name":"' + StateCust.Description + '","transaction_type":"' + "Transaction Type" + '","other_value":"' + '' +
        '","total_invoice_value":"' + FORMAT(TotalInvAmt) + '","taxable_amount":"' + FORMAT(TotaltaxableAmt1Total) + '","cgst_amount":"' +
        '0' + '","sgst_amount":"' + '0' + '","igst_amount":"' + FORMAT(TotalIGSTAmt) + '","cess_amount":"' +
        '0' + '","cess_nonadvol_value":"' + '0' + '","transporter_id":"' + '05AAABB0639G1Z8' + '","transporter_name":"' +
        "Transport Vendor" + '","transporter_document_number":"' + '' + '","transporter_document_date":"' + '' + '","transportation_mode":"' +
        "Mode of Transport" + '","transportation_distance":"' + FORMAT("Distance (Km)") + '","vehicle_number":"' +
        "Vehicle No." + '","vehicle_type":"' + 'Regular' + '","generate_status":"' + '1' + '","data_source":"' + 'erp' + '","user_ref":"' + '' +
        '","location_code":"' + Location_.Code + '","eway_bill_status":"' + FORMAT("E-Way Bill Generate") + '","auto_print":"' + 'Y' + '","email":"' +
        Location_."E-Mail" + '"}';

        //MESSAGE(Headerdata);
        //MESSAGE(Linedata);
        // result := Ewaybill.GenerateEwaybill(GeneralLedgerSetup."EINV Base URL", token, Headerdata, Linedata);
        result := Ewaybill.GenerateEwaybill(GeneralLedgerSetup."EINV Base URL", token, Headerdata, Linedata, GeneralLedgerSetup."EINV Path");

        IF result <> 'Invalid Json' THEN BEGIN
            resresult := CONVERTSTR(result, ';', ',');
            resresult1 := SELECTSTR(1, resresult);
            resresult2 := SELECTSTR(2, resresult);
        END;

        IF (12 = STRLEN(resresult1)) THEN BEGIN
            IF EWayBillDetail.GET(Rec."No.") THEN BEGIN
                //EwaybillDetail.INIT;
                EWayBillDetail."Eway Bill No." := resresult1;
                EWayBillDetail."URL for PDF" := resresult2;
                EWayBillDetail."Ewaybill Error" := '';
                EWayBillDetail."Transportation Mode" := "Mode of Transport";
                EWayBillDetail."Transport Distance" := "Distance (Km)";
                EWayBillDetail."Transporter Name" := "Transport Vendor";
                EWayBillDetail.MODIFY;
                //EWayBillDetail.Insert();
                TraShipHeader.Reset();
                TraShipHeader.SetRange("No.", "No.");
                IF TraShipHeader.FindFirst() then begin
                    TraShipHeader."E-Way Bill Generate" := TraShipHeader."E-Way Bill Generate"::Generated;
                    TraShipHeader.MODIFY;
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

        /*
        IF 12 = STRLEN(result) THEN BEGIN
            "E-Way Bill Generate" := "E-Way Bill Generate"::Generated;
            "Eway Bill No." := result;
            MODIFY;
            MESSAGE(result);
        END ELSE BEGIN
            ERROR(result);
        END;
        //PCPL41-EWAY
        */

    end;

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


}



