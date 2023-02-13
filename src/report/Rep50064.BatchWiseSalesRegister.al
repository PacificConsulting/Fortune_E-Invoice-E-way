report 50064 "Batch Wise Sales Register"
{
    // version CCIT-TK

    DefaultLayout = RDLC;
    //RDLCLayout = 'src/reportlayout/Batch Wise Sales Register.rdl';
    ProcessingOnly = true;
    ApplicationArea = all;
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem("Sales Invoice Header"; "Sales Invoice Header")
        {
            RequestFilterFields = "No.", "Location Code", "Salesperson Code";
            dataitem("Sales Invoice Line"; "Sales Invoice Line")
            {
                DataItemLink = "Document No." = FIELD("No.");
                DataItemTableView = SORTING("Document No.", "Line No.")
                                    ORDER(Ascending)
                                    WHERE(Quantity = FILTER(<> 0),
                                          Type = FILTER('Item' | 'G/L Account'));
                RequestFilterFields = "No.";

                trigger OnAfterGetRecord();
                begin
                    /*//CCIT-SG-07052019
                    IF "Sales Invoice Line".Type = "Sales Invoice Line".Type::"G/L Account" THEN BEGIN
                      IF NOT ("Sales Invoice Line"."No." = '3011001')OR ("Sales Invoice Line"."No." ='301110')OR ("Sales Invoice Line"."No." ='301120')
                        OR ("Sales Invoice Line"."No." ='301130')OR ("Sales Invoice Line"."No." ='301140')OR ("Sales Invoice Line"."No." ='301170') THEN
                          CurrReport.SKIP;
                    END;
                    //CCIT-SG-07052019*/ //ccit vivek
                    Clear(SIHACKDATETIME);
                    EINVDET.Reset();
                    EINVDET.SetRange("Document No.", "Sales Invoice Header"."No.");
                    IF EINVDET.FindFirst() then begin
                        SIHACKDATETIME := EINVDET."E-Invoice Acknowledgement Date Time";
                    end;

                    CLEAR(FreightChargesTot);
                    CLEAR(FreightCharges);
                    CLEAR(PackingCharges);
                    CLEAR(ForwardingCharges);
                    CLEAR(ShippingCharges);  //15112021 CCIT AN
                    Sr_No += 1;

                    CGST := 0;
                    SGST := 0;
                    IGST := 0;
                    Rate := 0;
                    Rate1 := 0;
                    InvoiceValue := 0;

                    RecSalesPrice.RESET;
                    IF RecSalesPrice.GET("Sales Invoice Line"."No.") THEN
                        PriceperKG := RecSalesPrice."Conversion Price Per PCS";

                    RecItem.RESET;
                    IF RecItem.GET("Sales Invoice Line"."No.") THEN BEGIN
                        BrandName := RecItem."Brand Name";
                        StorageCategory := FORMAT(RecItem."Storage Categories");
                        VendorNo := RecItem."Vendor No.";
                        SalesCategory := RecItem."Sales Category";
                    END;
                    Clear(VendName);
                    IF RecVend.GET(VendorNo) THEN
                        VendName := RecVend.Name;
                    /*
                    IF ("Sales Invoice Line"."GST Jurisdiction Type" = "Sales Invoice Line"."GST Jurisdiction Type"::Intrastate) THEN BEGIN
                        Rate := 0;//"Sales Invoice Line"."GST %"/2; //PCPL/MIG/NSW Filed not Exist in BC18
                        CGST := 0;//"Sales Invoice Line"."Total GST Amount"/2; //PCPL/MIG/NSW Filed not Exist in BC18
                        SGST := 0;//"Sales Invoice Line"."Total GST Amount"/2; //PCPL/MIG/NSW Filed not Exist in BC18
                    END
                    ELSE
                        IF ("Sales Invoice Line"."GST Jurisdiction Type" = "Sales Invoice Line"."GST Jurisdiction Type"::Interstate) THEN BEGIN
                            Rate1 := 0;// "Sales Invoice Line"."GST %"; //PCPL/MIG/NSW Filed not Exist in BC18
                            IGST := 0;// "Sales Invoice Line"."Total GST Amount"; //PCPL/MIG/NSW Filed not Exist in BC18
                        END;        

                    */
                    //>>PCPL/BPPL/010
                    GLE.RESET;
                    GLE.SETRANGE(GLE."Document No.", "Sales Invoice Line"."Document No.");
                    GLE.SETRANGE(GLE."Transaction Type", GLE."Transaction Type"::Sales);
                    //GLE.SETRANGE("Document Line No.", "Sales Invoice Line"."Line No.");
                    IF GLE.FindSet THEN
                        repeat
                            IF GLE."GST Component Code" = 'CGST' THEN BEGIN
                                //CGST := ABS(GLE."GST Amount") / 2;
                                CGST += ABS(GLE."GST Amount");
                                Rate := (GLE."GST %");
                            END
                            ELSE
                                IF GLE."GST Component Code" = 'IGST' THEN BEGIN
                                    IGST += ABS(GLE."GST Amount");
                                    Rate1 := GLE."GST %";
                                END
                                ELSE
                                    IF GLE."GST Component Code" = 'SGST' THEN BEGIN
                                        // SGST := ABS(GLE."GST Amount") / 2;
                                        SGST += ABS(GLE."GST Amount");
                                        Rate := (GLE."GST %");
                                    END;
                        until GLE.Next = 0;


                    TotalCGST += CGST;
                    TotalSGST += SGST;
                    TotalIGST += IGST;

                    /*RecSIL.RESET;
                    RecSIL.SETRANGE(RecSIL.Type,RecSIL.Type::"Charge (Item)");
                    RecSIL.SETRANGE(RecSIL."Document No.","Document No.");
                    IF RecSIL.FINDFIRST THEN
                      REPEAT
                        IF RecSIL."No." = 'FREIGHT' THEN
                          FreightCharges := FreightCharges + ROUND(RecSIL.Amount)
                        //ELSE IF RecSOLD."Tax/Charge Group" = 'TRANSPORT' THEN
                          //TransportCharges := TransportCharges + ROUND(RecSOLD.Amount)
                        ELSE IF RecSIL."No." = 'PACKING CHARGES' THEN
                          PackingCharges := PackingCharges + ROUND(RecSIL.Amount)
                        ELSE IF RecSIL."No." = 'FORWARDING CHARGES' THEN
                          ForwardingCharges := ForwardingCharges + ROUND(RecSIL.Amount);
                        FreightChargesTot := FreightCharges + TransportCharges;
                      UNTIL RecSIL."Net Weight"=0;*/
                    RecVLE.RESET;
                    RecVLE.SETRANGE(RecVLE."Document No.", "Document No.");
                    RecVLE.SETRANGE(RecVLE."Item No.", "No.");
                    RecVLE.SETFILTER("Gen. Prod. Posting Group", '<>%1', 'RETAIL');
                    IF RecVLE.FINDFIRST THEN
                        REPEAT
                            IF RecVLE."Gen. Prod. Posting Group" = 'FREIGHT' THEN
                                FreightCharges := FreightCharges + ROUND(RecVLE."Sales Amount (Actual)")
                            ELSE
                                IF RecVLE."Gen. Prod. Posting Group" = 'PACK CHAR' THEN
                                    PackingCharges := PackingCharges + ROUND(RecVLE."Sales Amount (Actual)")
                                ELSE
                                    IF RecVLE."Gen. Prod. Posting Group" = 'FOR&CHAR' THEN
                                        ForwardingCharges := ForwardingCharges + ROUND(RecVLE."Sales Amount (Actual)")//FreightChargesTot := FreightCharges + TransportCharges;
                                                                                                                      // 15112021  CCIT AN
                                    ELSE
                                        IF RecVLE."Gen. Prod. Posting Group" = 'SHIPPING' THEN
                                            //ELSE IF RecVLE."Gen. Prod. Posting Group" = 'SHIPPINGLI' THEN
                                            ShippingCharges := ShippingCharges + ROUND(RecVLE."Sales Amount (Actual)");
                            FreightChargesTot := FreightCharges + TransportCharges;
                        //15112021 CCIT AN
                        UNTIL RecVLE.NEXT = 0;
                    //13082020//


                    /*
                    RecSOLD.RESET;
                    RecSOLD.SETRANGE(RecSOLD.Type,RecSOLD.Type::Sale);
                    RecSOLD.SETRANGE(RecSOLD."Invoice No.","Sales Invoice Line"."Document No.");
                    RecSOLD.SETRANGE(RecSOLD."Item No.","Sales Invoice Line"."No.");
                    RecSOLD.SETRANGE(RecSOLD."Tax/Charge Type",RecSOLD."Tax/Charge Type"::Charges);
                    RecSOLD.SETRANGE(RecSOLD."Line No.","Sales Invoice Line"."Line No.");
                    RecSOLD.SETRANGE(RecSOLD."Document Type",RecSOLD."Document Type"::Invoice);
                    IF RecSOLD.FIND('-') THEN
                      REPEAT
                        IF RecSOLD."Tax/Charge Group" = 'FREIGHT' THEN
                          FreightCharges := FreightCharges + ROUND(RecSOLD.Amount)
                        ELSE IF RecSOLD."Tax/Charge Group" = 'TRANSPORT' THEN
                          TransportCharges := TransportCharges + ROUND(RecSOLD.Amount)
                        ELSE IF RecSOLD."Tax/Charge Group" = 'PACKING' THEN
                          PackingCharges := PackingCharges + ROUND(RecSOLD.Amount)
                        ELSE IF RecSOLD."Tax/Charge Group" = 'FORWARDING' THEN
                          ForwardingCharges := ForwardingCharges + ROUND(RecSOLD.Amount);
                        FreightChargesTot := FreightCharges + TransportCharges;
                      UNTIL RecSOLD.NEXT = 0;
                    */
                    TotalConvQty += ROUND("Sales Invoice Line"."Conversion Qty", 1, '=');

                    IF "Sales Invoice Line".Type = "Sales Invoice Line".Type::Item THEN //19-04-2019
                        TotalQty += "Sales Invoice Line".Quantity;
                    TotalBaseValue += "Sales Invoice Line".Quantity * "Sales Invoice Line"."Unit Price";
                    //InvoiceValue := (("Sales Invoice Line".Quantity*"Sales Invoice Line"."Unit Price")+FreightChargesTot+PackingCharges+ForwardingCharges+IGST+CGST+SGST+"Sales Invoice Line"."TDS/TCS Amount"-"Sales Invoice Line"."Line Discount Amount");
                    InvoiceValue := (("Sales Invoice Line".Quantity * "Sales Invoice Line"."Unit Price") + FreightChargesTot + PackingCharges + ShippingCharges + ForwardingCharges + IGST + CGST + SGST + 0 - "Sales Invoice Line"."Line Discount Amount"); //PCPL/MIG/NSW Filed not Exist in BC18 TDS FIeld
                    TotalInvoiceValue += InvoiceValue;
                    Clear(Batch);
                    Clear(MfgDate);
                    Clear(ExpDate);
                    RecSIH.RESET;
                    RecSIH.SETRANGE(RecSIH."No.", "Sales Invoice Line"."Document No.");
                    IF RecSIH.FIND('-') THEN //BEGIN
                        REPEAT
                            RecPstdIvPickLine.RESET;
                            RecPstdIvPickLine.SETRANGE(RecPstdIvPickLine."Source No.", RecSIH."Order No.");
                            RecPstdIvPickLine.SETRANGE(RecPstdIvPickLine."Item No.", "Sales Invoice Line"."No.");
                            IF RecPstdIvPickLine.FIND('-') THEN begin
                                repeat
                                    Clear(Batch);
                                    Batch := RecPstdIvPickLine."Lot No.";
                                    MfgDate := RecPstdIvPickLine."Warranty Date";
                                    ExpDate := RecPstdIvPickLine."Expiration Date";
                                    MakeExcelDataBody;
                                until RecPstdIvPickLine.Next() = 0; //PCPL_0070
                            END;
                        UNTIL RecSIH.NEXT = 0;

                    //end;

                    //  UNTIL RecSIH.NEXT = 0;
                    // END;
                    //END;

                    //MakeExcelDataBody;

                end;

                trigger OnPostDataItem();
                begin
                    //MakeExcelDataBody;
                end;
            }

            trigger OnAfterGetRecord();
            begin

                IF RecCust.GET("Sales Invoice Header"."Sell-to Customer No.") THEN BEGIN
                    CustomerBusinessFormat := RecCust."Business Format / Outlet Name";
                    CustName := RecCust.Name;
                    CustName2 := RecCust."Name 2";
                    SalesReporting := RecCust."Sales Reporting Field";
                    SalespersonCode := RecCust."Salesperson Code";
                    DeliveryOutlet := RecCust."Delivery Outlet";
                END;

                RecSalesPerson.RESET;
                IF RecSalesPerson.GET(SalespersonCode) THEN
                    SalesPersonName := RecSalesPerson.Name;

                SalesPerson_Trans := '';

                IF RecSalesPerson.GET("Sales Invoice Header"."Salesperson Code") THEN
                    SalesPerson_Trans := RecSalesPerson.Name;
                //++CCIT-TK-TICKETID-311221
                CLEAR(OrderNo);
                IF "Sales Invoice Header"."Order No." <> '' THEN BEGIN
                    OrderNo := "Sales Invoice Header"."Order No.";
                END ELSE BEGIN
                    RecSIL.RESET();
                    RecSIL.SETRANGE(RecSIL."Document No.", "Sales Invoice Header"."No.");
                    IF RecSIL.FIND('-') THEN BEGIN
                        RECSSH.RESET();
                        RECSSH.SETRANGE(RECSSH."No.", RecSIL."Shipment No.");
                        IF RECSSH.FIND('-') THEN BEGIN
                            OrderNo := RECSSH."Order No.";
                        END;
                    END;
                END;

                //--CCIT-TK-TICKETID-311221
            end;

            trigger OnPostDataItem();
            begin

                //IF Document_Type = Document_Type :: Invoice THEN
                //MakeExcelDataFooter;
            end;

            trigger OnPreDataItem();
            begin
                //CCIT-PRI-280318
                CLEAR(LocCode);
                RecUserBranch.RESET;
                RecUserBranch.SETRANGE(RecUserBranch."User ID", USERID);
                IF RecUserBranch.FINDFIRST THEN
                    REPEAT
                        LocCode := LocCode + '|' + RecUserBranch."Location Code";
                    UNTIL RecUserBranch.NEXT = 0;

                LocCodeText := DELCHR(LocCode, '<', '|');

                IF LocCodeText <> '' THEN
                    "Sales Invoice Header".SETFILTER("Sales Invoice Header"."Location Code", LocCodeText);
                //CCIT-PRI-280318
                /*
                IF Document_Type <> Document_Type :: Invoice THEN
                "Sales Invoice Header".SETRANGE  ("No.",'','');
                */
                IF (From_Date <> 0D) AND (To_Date <> 0D) THEN
                    "Sales Invoice Header".SETRANGE("Sales Invoice Header"."Posting Date", From_Date, To_Date)
                ELSE
                    IF (AsOnDate <> 0D) THEN
                        "Sales Invoice Header".SETRANGE("Sales Invoice Header"."Posting Date", 99990101D, AsOnDate);

            end;
        }
        dataitem("Sales Cr.Memo Header"; "Sales Cr.Memo Header")
        {
            RequestFilterFields = "No.", "Location Code", "Salesperson Code";
            dataitem("Sales Cr.Memo Line"; "Sales Cr.Memo Line")
            {
                DataItemLink = "Document No." = FIELD("No.");
                DataItemTableView = SORTING("Document No.", "Line No.")
                                    ORDER(Ascending)
                                    WHERE(Quantity = FILTER(<> 0),
                                          Type = FILTER('Item' | 'G/L Account'));
                RequestFilterFields = "No.";

                trigger OnAfterGetRecord();
                begin
                    /*//CCIT-SG-07052019
                    IF "Sales Cr.Memo Line".Type = "Sales Cr.Memo Line".Type::"G/L Account" THEN BEGIN
                      IF NOT ("Sales Cr.Memo Line"."No." = '3011001')OR ("Sales Cr.Memo Line"."No." ='301110')OR ("Sales Cr.Memo Line"."No." ='301120')
                        OR ("Sales Cr.Memo Line"."No." ='301130')OR ("Sales Cr.Memo Line"."No." ='301140')OR ("Sales Cr.Memo Line"."No." ='301170') THEN
                          CurrReport.SKIP;
                    END;
                    //CCIT-SG-07052019*/ //ccit - vivek

                    Clear(SCHACKDATETIME);
                    EINVDET1.Reset();
                    EINVDET1.SetRange("Document No.", "Sales Cr.Memo Header"."No.");
                    IF EINVDET1.FindFirst() then begin
                        SCHACKDATETIME := EINVDET1."E-Invoice Acknowledgement Date Time";
                    end;

                    CLEAR(FreightChargesTot1);
                    CLEAR(FreightCharges1);
                    CLEAR(PackingCharges1);
                    CLEAR(ForwardingCharges1);

                    Sr_No1 += 1;

                    CGST1 := 0;
                    SGST1 := 0;
                    IGST1 := 0;
                    Rate01 := 0;
                    Rate101 := 0;
                    InvoiceValue1 := 0;

                    RecSalesPrice.RESET;
                    IF RecSalesPrice.GET("Sales Cr.Memo Line"."No.") THEN
                        PriceperKG1 := RecSalesPrice."Conversion Price Per PCS";


                    RecItem.RESET;
                    IF RecItem.GET("Sales Cr.Memo Line"."No.") THEN BEGIN
                        BrandName1 := RecItem."Brand Name";
                        StorageCategory1 := FORMAT(RecItem."Storage Categories");
                        VendorNo1 := RecItem."Vendor No.";
                        SalesCategory := RecItem."Sales Category";
                    END;
                    Clear(VendName1);
                    IF RecVend.GET(VendorNo1) THEN
                        VendName1 := RecVend.Name;

                    RecGSTSetup1.RESET;
                    RecLocation1.RESET;

                    IF RecLocation1.GET("Sales Cr.Memo Header"."Location Code") THEN
                        GST_Location_Code1 := RecLocation1."State Code";


                    IF RecCust.GET("Sales Cr.Memo Header"."Bill-to Customer No.") THEN
                        GST_Bill_Code1 := RecCust."State Code";
                    /*
                    IF ("Sales Cr.Memo Line"."GST Jurisdiction Type" = "Sales Cr.Memo Line"."GST Jurisdiction Type"::Intrastate) THEN BEGIN
                        Rate01 := 0;//"Sales Cr.Memo Line"."GST %"/2;  //PCPL/MIG/NSW Filed not Exist in BC18
                        CGST1 := 0;// "Sales Cr.Memo Line"."Total GST Amount"/2;//PCPL/MIG/NSW Filed not Exist in BC18
                        SGST1 := 0;//"Sales Cr.Memo Line"."Total GST Amount"/2;//PCPL/MIG/NSW Filed not Exist in BC18
                    END
                    ELSE
                        IF ("Sales Cr.Memo Line"."GST Jurisdiction Type" = "Sales Cr.Memo Line"."GST Jurisdiction Type"::Interstate) THEN BEGIN
                            Rate101 := 0;//"Sales Cr.Memo Line"."GST %";//PCPL/MIG/NSW Filed not Exist in BC18
                            IGST1 := 0;//"Sales Cr.Memo Line"."Total GST Amount"; //PCPL/MIG/NSW Filed not Exist in BC18
                        END;
                        */

                    //>>PCPL/BPPL/010
                    GLE.RESET;
                    GLE.SETRANGE(GLE."Document No.", "Sales Cr.Memo Line"."Document No.");
                    GLE.SETRANGE(GLE."Transaction Type", GLE."Transaction Type"::Sales);
                    //GLE.SETRANGE("Document Line No.", "Sales Cr.Memo Line"."Line No.");
                    IF GLE.FindSet THEN
                        repeat
                            IF GLE."GST Component Code" = 'CGST' THEN BEGIN
                                //CGST := ABS(GLE."GST Amount") / 2;
                                CGST1 += ABS(GLE."GST Amount");
                                Rate01 := (GLE."GST %");
                            END
                            ELSE
                                IF GLE."GST Component Code" = 'IGST' THEN BEGIN
                                    IGST1 += ABS(GLE."GST Amount");
                                    Rate101 := GLE."GST %";
                                END
                                ELSE
                                    IF GLE."GST Component Code" = 'SGST' THEN BEGIN
                                        // SGST := ABS(GLE."GST Amount") / 2;
                                        SGST1 += ABS(GLE."GST Amount");
                                        Rate01 := (GLE."GST %");
                                    END;
                        until GLE.Next = 0;
                    TotalCGST1 += CGST1;
                    TotalSGST1 += SGST1;
                    TotalIGST1 += IGST1;

                    /*RecSCML.RESET;
                    RecSCML.SETRANGE(RecSCML.Type,RecSCML.Type::"Charge (Item)");
                    RecSCML.SETRANGE(RecSCML."Document No.","Document No.");
                    IF RecSCML.FINDFIRST THEN
                      REPEAT
                        IF RecSCML."No." = 'FREIGHT' THEN
                          FreightCharges := FreightCharges + ROUND(RecSCML.Amount)
                        //ELSE IF RecSOLD."Tax/Charge Group" = 'TRANSPORT' THEN
                          //TransportCharges := TransportCharges + ROUND(RecSOLD.Amount)
                        ELSE IF RecSCML."No." = 'PACKING CHARGES' THEN
                          PackingCharges := PackingCharges + ROUND(RecSCML.Amount)
                        ELSE IF RecSCML."No." = 'FORWARDING CHARGES' THEN
                          ForwardingCharges := ForwardingCharges + ROUND(RecSCML.Amount);
                        FreightChargesTot := FreightCharges + TransportCharges;
                      UNTIL RecSCML."Net Weight"=0;*/

                    RecVLE.RESET;
                    RecVLE.SETRANGE(RecVLE."Document No.", "Document No.");
                    RecVLE.SETRANGE(RecVLE."Item No.", "No.");
                    RecVLE.SETFILTER("Gen. Prod. Posting Group", '<>%1', 'RETAIL');
                    IF RecVLE.FINDFIRST THEN
                        REPEAT
                            IF RecVLE."Gen. Prod. Posting Group" = 'FREIGHT' THEN
                                FreightCharges := FreightCharges + ROUND(RecVLE."Sales Amount (Actual)")
                            ELSE
                                IF RecVLE."Gen. Prod. Posting Group" = 'PACK CHAR' THEN
                                    PackingCharges := PackingCharges + ROUND(RecVLE."Sales Amount (Actual)")
                                ELSE
                                    IF RecVLE."Gen. Prod. Posting Group" = 'FOR&CHAR' THEN
                                        ForwardingCharges := ForwardingCharges + ROUND(RecVLE."Sales Amount (Actual)");
                            FreightChargesTot := FreightCharges + TransportCharges;
                        UNTIL RecVLE.NEXT = 0;
                    //13082020//

                    /*
                    RecSOLD.RESET;
                    RecSOLD.SETRANGE(RecSOLD.Type,RecSOLD.Type::Sale);
                    RecSOLD.SETRANGE(RecSOLD."Invoice No.","Sales Cr.Memo Line"."Document No.");
                    RecSOLD.SETRANGE(RecSOLD."Item No.","Sales Cr.Memo Line"."No.");
                    RecSOLD.SETRANGE(RecSOLD."Tax/Charge Type",RecSOLD."Tax/Charge Type"::Charges);
                    RecSOLD.SETRANGE(RecSOLD."Line No.","Sales Cr.Memo Line"."Line No.");
                    RecSOLD.SETRANGE(RecSOLD."Document Type",RecSOLD."Document Type"::Invoice);
                    IF RecSOLD.FINDFIRST THEN
                      REPEAT
                        IF (RecSOLD."Tax/Charge Group" = 'FREIGHT') THEN
                          FreightCharges1 := FreightCharges1 + ROUND(RecSOLD.Amount)
                         ELSE IF RecSOLD."Tax/Charge Group" = 'TRANSPORT' THEN
                          TransportCharges1 := TransportCharges1 + ROUND(RecSOLD.Amount)
                        ELSE IF RecSOLD."Tax/Charge Group" = 'PACKING' THEN
                          PackingCharges1 := PackingCharges1 + ROUND(RecSOLD.Amount)
                        ELSE IF RecSOLD."Tax/Charge Group" = 'FORWARDING' THEN
                          ForwardingCharges1 := ForwardingCharges1 + ROUND(RecSOLD.Amount);
                     //MESSAGE('%1',FreightCharges1);
                       FreightChargesTot1 += FreightCharges1 + TransportCharges1;
                     UNTIL RecSOLD.NEXT = 0;
                    */
                    IF "Sales Cr.Memo Line".Type = "Sales Cr.Memo Line".Type::Item THEN //19-04-2019
                        TotalQty1 += "Sales Cr.Memo Line".Quantity;

                    TotalConvQty1 += ROUND("Sales Cr.Memo Line"."Conversion Qty", 1, '=');
                    TotalBaseValue1 += "Sales Cr.Memo Line"."Unit Price" * "Sales Cr.Memo Line".Quantity;

                    InvoiceValue1 := (("Sales Cr.Memo Line".Quantity * "Sales Cr.Memo Line"."Unit Price") + FreightChargesTot1 + PackingCharges1 + ForwardingCharges1 + IGST1 + CGST1 + SGST1 + (0) - "Sales Cr.Memo Line"."Line Discount Amount"); //PCPL/MIG/NSW Filed not Exist in BC18 TDS Amount not excist
                    TotalInvoiceValue1 += InvoiceValue1;
                    /*
                    RecILE.RESET;
                    RecILE.SETRANGE(RecILE."Document No.","Sales Cr.Memo Line"."Document No.");
                    RecILE.SETRANGE(RecILE."Item No.","Sales Cr.Memo Line"."No.");
                    RecILE.SETRANGE(RecILE."Lot No.","Sales Cr.Memo Line"."Lot No.");
                    */
                    Clear(batch1);
                    Clear(mfgdate1);
                    Clear(expdate1);
                    RecSCMH.RESET;
                    RecSCMH.SETRANGE(RecSCMH."No.", "Sales Cr.Memo Line"."Document No.");
                    IF RecSCMH.FIND('-') THEN BEGIN
                        REPEAT
                            RecPstdInvPutAwayLine.RESET;
                            RecPstdInvPutAwayLine.SETRANGE(RecPstdInvPutAwayLine."Source No.", RecSCMH."Return Order No.");
                            RecPstdInvPutAwayLine.SETRANGE(RecPstdInvPutAwayLine."Item No.", "Sales Cr.Memo Line"."No.");
                            IF RecPstdInvPutAwayLine.FIND('-') THEN
                                //repeat
                                    batch1 := RecPstdInvPutAwayLine."Lot No.";
                            mfgdate1 := RecPstdInvPutAwayLine."Warranty Date";
                            expdate1 := RecPstdInvPutAwayLine."Expiration Date";
                        // until RecPstdInvPutAwayLine.Next() = 0; //PCPL_0070
                        UNTIL RecSCMH.NEXT = 0;
                    END;
                    IF "Sales Cr.Memo Line".Type = "Sales Cr.Memo Line".Type::"G/L Account" then begin
                        batch1 := '';
                        mfgdate1 := 0D;
                        expdate1 := 0D;
                    end;

                    RecILE.Reset();
                    RecILE.SetRange("Item No.", "Sales Cr.Memo Line"."No.");
                    RecILE.SetRange("Lot No.", batch1);
                    if RecILE.FindFirst then begin
                        expdate1 := RecILE."Expiration Date";
                    end;

                    txtNo := '';
                    IF "Sales Cr.Memo Header"."Pre-Assigned No." <> '' THEN BEGIN
                        txtNo := "Sales Cr.Memo Header"."Pre-Assigned No."
                    END ELSE BEGIN
                        txtNo := "Sales Cr.Memo Header"."Return Order No.";
                    END;//tk
                    MakeExcelDataBody1;

                end;
            }

            trigger OnAfterGetRecord();
            begin

                IF RecCust.GET("Sales Cr.Memo Header"."Sell-to Customer No.") THEN BEGIN
                    CustomerBusinessFormat1 := RecCust."Business Format / Outlet Name";
                    CustName1 := RecCust.Name;
                    CustName22 := RecCust."Name 2";
                    SalesReporting1 := RecCust."Sales Reporting Field";
                    SalespersonCode1 := RecCust."Salesperson Code";
                    DeliveryOutlet1 := RecCust."Delivery Outlet";
                END;

                RecSalesPerson.RESET;
                IF RecSalesPerson.GET(SalespersonCode1) THEN
                    SalesPersonName1 := RecSalesPerson.Name;

                SalesPerson_Trans := '';

                IF RecSalesPerson.GET("Sales Cr.Memo Header"."Salesperson Code") THEN
                    SalesPerson_Trans := RecSalesPerson.Name;
            end;

            trigger OnPostDataItem();
            begin
                //IF Document_Type = Document_Type :: "Credit Note" THEN
                MakeExcelDataFooter1;
            end;

            trigger OnPreDataItem();
            begin
                //CCIT-PRI-280318
                IF LocCodeText <> '' THEN
                    "Sales Cr.Memo Header".SETFILTER("Sales Cr.Memo Header"."Location Code", LocCodeText);
                //CCIT-PRI-280318
                /*
                IF Document_Type <> Document_Type :: "Credit Note" THEN
                "Sales Cr.Memo Header".SETRANGE  ("No.",'','');
                */
                IF (From_Date <> 0D) AND (To_Date <> 0D) THEN
                    "Sales Cr.Memo Header".SETRANGE("Sales Cr.Memo Header"."Posting Date", From_Date, To_Date)
                ELSE
                    IF (AsOnDate <> 0D) THEN
                        "Sales Cr.Memo Header".SETRANGE("Sales Cr.Memo Header"."Posting Date", 99990101D, AsOnDate);
                //  TodayDate :=TODAY;

            end;
        }
    }

    requestpage
    {
        SaveValues = true;

        layout
        {
            area(content)
            {
                field("Document Type"; Document_Type)
                {
                    Visible = false;
                }
                group("From Date - To Date Filters")
                {
                    field("From Date"; From_Date)
                    {

                        trigger OnValidate();
                        begin
                            IF (AsOnDate <> 0D) THEN BEGIN
                                From_Date := 0D;
                                To_Date := 0D;
                                MESSAGE('As On Date allready Entered...');
                            END;
                        end;
                    }
                    field("To Date"; To_Date)
                    {

                        trigger OnValidate();
                        begin
                            IF (AsOnDate <> 0D) THEN BEGIN
                                From_Date := 0D;
                                To_Date := 0D;
                                MESSAGE('As On Date allready Entered...');
                            END;
                        end;
                    }
                }
                group("As On Date Filter")
                {
                    field("As On Date"; AsOnDate)
                    {

                        trigger OnValidate();
                        begin
                            IF (From_Date <> 0D) AND (To_Date <> 0D) THEN BEGIN
                                AsOnDate := 0D;
                                MESSAGE('From Date - To Date allready Entered...');
                            END;
                        end;
                    }
                }
            }
        }

        actions
        {
        }
    }

    labels
    {
    }

    trigger OnPostReport();
    begin
        //IF Document_Type = Document_Type :: Invoice THEN
        CreateExcelbook;
        //ELSE IF Document_Type = Document_Type :: "Credit Note" THEN
        // CreateExcelbook1;
    end;

    trigger OnPreReport();
    begin
        //MakeExcelInfo;
        //IF Document_Type = Document_Type :: Invoice THEN
        MakeExcelDataHeader;
        //ELSE IF Document_Type = Document_Type :: "Credit Note" THEN
        //MakeExcelDataHeader1;

        Sr_No := 0;
        Sr_No1 := 0;

        TotalCGST := 0;
        TotalSGST := 0;
        TotalIGST := 0;
        TotalConvQty := 0;
        TotalQty := 0;
        TotalBaseValue := 0;
        TotalInvoiceValue := 0;

        TotalCGST1 := 0;
        TotalSGST1 := 0;
        TotalIGST1 := 0;
        TotalConvQty1 := 0;
        TotalQty1 := 0;
        TotalBaseValue1 := 0;
        TotalInvoiceValue1 := 0;

    end;

    var
        EINVDET: Record 50007;
        EINVDET1: Record 50007;
        SIHACKDATETIME: datetime;
        SCHACKDATETIME: datetime;
        RECSSH: Record 110;
        OrderNo: Code[20];
        txtNo: Code[30];
        CustName22: Text[50];
        CustName2: Text[50];
        RecILE: Record 32;
        Document_Type: Option " ",Invoice,"Credit Note";
        ExcelBuf: Record 370 temporary;
        Sr_No: Integer;
        RecCust: Record 18;
        CustomerBusinessFormat: Text[100];
        CustName: Text[100];
        VerticalSubCategory: Code[50];
        CGST: Decimal;
        SGST: Decimal;
        IGST: Decimal;
        Rate: Decimal;
        Rate1: Decimal;
        RecGSTSetup: Record "GST Setup";
        TotalCGST: Decimal;
        TotalSGST: Decimal;
        TotalIGST: Decimal;
        TotalConvQty: Decimal;
        TotalQty: Decimal;
        TotalBaseValue: Decimal;
        TotalInvoiceValue: Decimal;
        Sr_No1: Integer;
        CGST1: Decimal;
        SGST1: Decimal;
        IGST1: Decimal;
        Rate01: Decimal;
        Rate101: Decimal;
        RecGSTSetup1: Record "GST Setup";
        RecLocation1: Record 14;
        GST_Location_Code1: Code[20];
        GST_Bill_Code1: Code[20];
        CustomerBusinessFormat1: Text[100];
        CustName1: Text[100];
        TotalCGST1: Decimal;
        TotalSGST1: Decimal;
        TotalIGST1: Decimal;
        TotalConvQty1: Decimal;
        TotalQty1: Decimal;
        TotalBaseValue1: Decimal;
        TotalInvoiceValue1: Decimal;
        //RecSOLD : Record "13798";
        FreightCharges: Decimal;
        PackingCharges: Decimal;
        ForwardingCharges: Decimal;
        FreightCharges1: Decimal;
        PackingCharges1: Decimal;
        ForwardingCharges1: Decimal;
        RecItem: Record 27;
        BrandName: Code[20];
        BrandName1: Code[20];
        RecSalesPrice: Record 7002;
        PriceperKG: Decimal;
        PriceperKG1: Decimal;
        RecSalesPerson: Record 13;
        SalesPersonName: Text[50];
        SalesPersonName1: Text[50];
        StorageCategory: Text[20];
        StorageCategory1: Text[20];
        RecVend: Record 23;
        VendorNo: Code[20];
        VendName: Text[50];
        VendorNo1: Code[20];
        VendName1: Text[50];
        InvoiceValue1: Decimal;
        InvoiceValue: Decimal;
        TransportCharges: Decimal;
        TransportCharges1: Decimal;
        FreightChargesTot: Decimal;
        FreightChargesTot1: Decimal;
        From_Date: Date;
        To_Date: Date;
        AsOnDate: Date;
        RecUserBranch: Record 50029;
        LocCode: Code[1024];
        LocCodeText: Text[1024];
        RecSIL: Record 113;
        RecSCML: Record 115;
        SalesReporting: Text[200];
        SalesReporting1: Text[200];
        MonthDateChr: Text[50];
        SalesCategory: Text[200];
        SalespersonCode: Code[20];
        SalespersonCode1: Code[20];
        RecReasonCode: Record 231;
        ReasonCodeTxt: Text[250];
        SalesPerson_Trans: Text[50];
        RecPstdIvPickLine: Record 7343;
        RecPstdIvPickLine11: Record 7343;
        RecPstdIvPickHeader: Record 7342;
        RecPstdInvPutAwayLine: Record 7341;
        Batch: Text[50];
        MfgDate: Date;
        ExpDate: Date;
        RecSIH: Record 112;
        RecSalesInvoiceline: Record 113;
        RecSCMH: Record 114;
        batch1: Text[50];
        mfgdate1: Date;
        expdate1: Date;
        DeliveryOutlet: Text[50];
        DeliveryOutlet1: Text;
        TodayDate: Date;
        RecVLE: Record 5802;
        ShippingCharges: Decimal;
        GLE: Record "Detailed GST Ledger Entry";

    procedure MakeExcelInfo();
    begin
        /*
        ExcelBuf.NewRow;
        ExcelBuf.AddInfoColumn('SALES REGISTER',FALSE,'',TRUE,FALSE,FALSE,'',ExcelBuf."Cell Type"::Text);
        */

    end;

    procedure CreateExcelbook();
    begin
        //ExcelBuf.CreateBookAndOpenExcel('F:\Reports\Sales Register Invoice.xlsx', 'Sales Register Invoice', 'Sales Register Invoice', COMPANYNAME, USERID);
        //ExcelBuf.CreateBookAndOpenExcel('E:\Reports\Batch Wise Sales Register.xlsx', 'Batch Wise Sales Register', 'Batch Wise Sales Register', COMPANYNAME, USERID);
        ExcelBuf.CreateBookAndOpenExcel('D:\reports\Batch Wise Sales Register.xlsx', 'Batch Wise Sales Register', 'Batch Wise Sales Register', COMPANYNAME, USERID);
        //PCPL/MIG/NSW Filed not Exist in BC18
    end;

    procedure MakeExcelDataHeader();
    begin
        ExcelBuf.NewRow;
        //ExcelBuf.AddColumn('Sales Register Invoice ',FALSE,'',TRUE,FALSE,TRUE,'',ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn('Batch Wise Sales Register', FALSE, '', TRUE, FALSE, TRUE, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.NewRow;
        ExcelBuf.NewRow;
        IF (From_Date <> 0D) AND (To_Date <> 0D) THEN
            ExcelBuf.AddColumn('From Date : ' + FORMAT(From_Date) + '  TO   ' + FORMAT(To_Date), FALSE, '', TRUE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text)
        ELSE
            IF (AsOnDate <> 0D) THEN
                ExcelBuf.AddColumn('As On Date : ' + FORMAT(AsOnDate), FALSE, '', TRUE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.NewRow;
        ExcelBuf.AddColumn('Date : ' + FORMAT(SYSTEM.TODAY), FALSE, '', TRUE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.NewRow;
        ExcelBuf.AddColumn('Time : ' + FORMAT(TIME), FALSE, '', TRUE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.NewRow;
        ExcelBuf.NewRow;

        //ExcelBuf.AddColumn('Document Number',FALSE,'',TRUE,FALSE,FALSE,'',ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn('Serial Number', FALSE, '', TRUE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn('Branch Name', FALSE, '', TRUE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn('Sales Person', FALSE, '', TRUE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text);
        //ExcelBuf.AddColumn('Sales Person Trans',FALSE,'',TRUE,FALSE,FALSE,'',ExcelBuf."Cell Type"::Text);//03-06-2019
        ExcelBuf.AddColumn('Customer Code', FALSE, '', TRUE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn('Customer Name', FALSE, '', TRUE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn('Delivery Outlet', FALSE, '', TRUE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text);//tk
        ExcelBuf.AddColumn('Sales Reporting Field', FALSE, '', TRUE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text);//New
                                                                                                                   //ExcelBuf.AddColumn('Customer Group',FALSE,'',TRUE,FALSE,FALSE,'',ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn('Document Type', FALSE, '', TRUE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text);
        //ExcelBuf.AddColumn('Customer Order No',FALSE,'',TRUE,FALSE,FALSE,'',ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn('Customer Order Date', FALSE, '', TRUE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text);//Extra in Sales Invoice

        ExcelBuf.AddColumn('ERP SO No', FALSE, '', TRUE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn('ERP SO Date', FALSE, '', TRUE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text);

        ExcelBuf.AddColumn('ERP INV No', FALSE, '', TRUE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn('ERP INV DATE', FALSE, '', TRUE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn('ERP INV Month', FALSE, '', TRUE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text);//10-04-2019
        ExcelBuf.AddColumn('Ref.INV No', FALSE, '', TRUE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text);
        //ExcelBuf.AddColumn('E-Way Bill No.',FALSE,'',TRUE,FALSE,FALSE,'',ExcelBuf."Cell Type"::Text);
        //ExcelBuf.AddColumn('E-Way Bill Date.',FALSE,'',TRUE,FALSE,FALSE,'',ExcelBuf."Cell Type"::Text);
        //ExcelBuf.AddColumn('Zone',FALSE,'',TRUE,FALSE,FALSE,'',ExcelBuf."Cell Type"::Text);
        //ExcelBuf.AddColumn('Customer Business format / Outlet Name',FALSE,'',TRUE,FALSE,FALSE,'',ExcelBuf."Cell Type"::Text);
        //ExcelBuf.AddColumn('Customer posting group',FALSE,'',TRUE,FALSE,FALSE,'',ExcelBuf."Cell Type"::Text);
        //ExcelBuf.AddColumn('Gen. Bus. Posting Group',FALSE,'',TRUE,FALSE,FALSE,'',ExcelBuf."Cell Type"::Text);
        //ExcelBuf.AddColumn('Vertical Sub Category',FALSE,'',TRUE,FALSE,FALSE,'',ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn('Purchase vendor name', FALSE, '', TRUE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn('Item code', FALSE, '', TRUE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn('Item name', FALSE, '', TRUE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn('Batch', FALSE, '', TRUE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn('Mfg Date', FALSE, '', TRUE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn('Expiry Date', FALSE, '', TRUE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn('Sales Category', FALSE, '', TRUE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text);
        //ExcelBuf.AddColumn('Brand Name',FALSE,'',TRUE,FALSE,FALSE,'',ExcelBuf."Cell Type"::Text);
        ////ExcelBuf.AddColumn('Product Group Code',FALSE,'',TRUE,FALSE,FALSE,'',ExcelBuf."Cell Type"::Text);
        //ExcelBuf.AddColumn('Storage Category',FALSE,'',TRUE,FALSE,FALSE,'',ExcelBuf."Cell Type"::Text);
        //ExcelBuf.AddColumn('UOM',FALSE,'',TRUE,FALSE,FALSE,'',ExcelBuf."Cell Type"::Text);
        //ExcelBuf.AddColumn('Price Group',FALSE,'',TRUE,FALSE,FALSE,'',ExcelBuf."Cell Type"::Text);
        //ExcelBuf.AddColumn('Sales In PCS',FALSE,'',TRUE,FALSE,FALSE,'',ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn('Sales In KGS', FALSE, '', TRUE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn('Customer Price Group', FALSE, '', TRUE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text);

        ExcelBuf.AddColumn('Special Price', FALSE, '', TRUE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn('Base value', FALSE, '', TRUE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn('Freight', FALSE, '', TRUE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn('Packing charges', FALSE, '', TRUE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn('Forwarding charges', FALSE, '', TRUE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text);
        //ExcelBuf.AddColumn('DP/DF',FALSE,'',TRUE,FALSE,FALSE,'',ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn('IGST', FALSE, '', TRUE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn('CGST', FALSE, '', TRUE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn('SGST', FALSE, '', TRUE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn('Discount', FALSE, '', TRUE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn('TCS Value', FALSE, '', TRUE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn('Invoice Value', FALSE, '', TRUE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn('CR Reason Code', FALSE, '', TRUE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn('GST Group', FALSE, '', TRUE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn('HSN Code', FALSE, '', TRUE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn('Acknowledgement No', FALSE, '', TRUE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn('Acknowledgement Date', FALSE, '', TRUE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn('Tally/Temp Invoice No.', FALSE, '', TRUE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn('Shipping Charges', FALSE, '', TRUE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text);//15112021 CCIT AN

    end;

    procedure MakeExcelDataBody();
    begin
        ExcelBuf.NewRow;
        //ExcelBuf.AddColumn("Sales Invoice Line"."Document No.",FALSE,'',FALSE,FALSE,FALSE,'',ExcelBuf."Cell Type"::Number);
        ExcelBuf.AddColumn(Sr_No, FALSE, '', FALSE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Number);
        ExcelBuf.AddColumn("Sales Invoice Header"."Location Code", FALSE, '', FALSE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn(SalesPersonName, FALSE, '', FALSE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text);
        //ExcelBuf.AddColumn(SalesPerson_Trans,FALSE,'',FALSE,FALSE,FALSE,'',ExcelBuf."Cell Type"::Text); //03-06-2019

        ExcelBuf.AddColumn("Sales Invoice Header"."Sell-to Customer No.", FALSE, '', FALSE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text);

        ExcelBuf.AddColumn("Sales Invoice Header"."Sell-to Customer Name" + "Sales Invoice Header"."Sell-to Customer Name 2", FALSE, '', FALSE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn(DeliveryOutlet, FALSE, '', FALSE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text);//tk
        ExcelBuf.AddColumn(SalesReporting, FALSE, '', FALSE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text);//New
        //ExcelBuf.AddColumn("Sales Invoice Header"."Customer Price Group",FALSE,'',FALSE,FALSE,FALSE,'',ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn('Invoice', FALSE, '', FALSE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text);
        //ExcelBuf.AddColumn("Sales Invoice Header"."External Document No.",FALSE,'',FALSE,FALSE,FALSE,'',ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn("Sales Invoice Header"."Order Date", FALSE, '', FALSE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Date);

        ExcelBuf.AddColumn(OrderNo, FALSE, '', FALSE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Number);
        ExcelBuf.AddColumn("Sales Invoice Header"."Document Date", FALSE, '', FALSE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Date);

        ExcelBuf.AddColumn("Sales Invoice Header"."No.", FALSE, '', FALSE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Number);
        //ExcelBuf.AddColumn('',FALSE,'',FALSE,FALSE,FALSE,'',ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn("Sales Invoice Header"."Posting Date", FALSE, '', FALSE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Date);

        MonthDateChr := FORMAT("Sales Invoice Header"."Posting Date", 0, '<Month Text>-<Year>');//10-04-2019
        ExcelBuf.AddColumn(MonthDateChr, FALSE, '', FALSE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text);//10-04-2019

        ExcelBuf.AddColumn('', FALSE, '', FALSE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Number);
        //ExcelBuf.AddColumn("Sales Invoice Header"."E-Way Bill No.",FALSE,'',FALSE,FALSE,FALSE,'',ExcelBuf."Cell Type"::Text);
        //ExcelBuf.AddColumn("Sales Invoice Header"."E-Way Bill Date",FALSE,'',FALSE,FALSE,FALSE,'',ExcelBuf."Cell Type"::Date);
        //ExcelBuf.AddColumn("Sales Invoice Header"."Shortcut Dimension 2 Code",FALSE,'',FALSE,FALSE,FALSE,'',ExcelBuf."Cell Type"::Text);
        //ExcelBuf.AddColumn(CustomerBusinessFormat,FALSE,'',FALSE,FALSE,FALSE,'',ExcelBuf."Cell Type"::Text);
        //ExcelBuf.AddColumn("Sales Invoice Header"."Customer Posting Group",FALSE,'',FALSE,FALSE,FALSE,'',ExcelBuf."Cell Type"::Text);
        //ExcelBuf.AddColumn("Sales Invoice Header"."Gen. Bus. Posting Group",FALSE,'',FALSE,FALSE,FALSE,'',ExcelBuf."Cell Type"::Text);
        //ExcelBuf.AddColumn("Sales Invoice Header"."Vertical Sub Category",FALSE,'',FALSE,FALSE,FALSE,'',ExcelBuf."Cell Type"::Number);
        ExcelBuf.AddColumn(VendName, FALSE, '', FALSE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn("Sales Invoice Line"."No.", FALSE, '', FALSE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Number);
        ExcelBuf.AddColumn("Sales Invoice Line".Description, FALSE, '', FALSE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn(Batch, FALSE, '', FALSE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn(MfgDate, FALSE, '', FALSE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Date);
        ExcelBuf.AddColumn(ExpDate, FALSE, '', FALSE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Date);
        //ExcelBuf.AddColumn("Sales Invoice Line"."Sales Category",FALSE,'',FALSE,FALSE,FALSE,'',ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn(SalesCategory, FALSE, '', FALSE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text);
        //ExcelBuf.AddColumn(BrandName,FALSE,'',FALSE,FALSE,FALSE,'',ExcelBuf."Cell Type"::Text);
        //ExcelBuf.AddColumn("Sales Invoice Line"."Item Category Code",FALSE,'',FALSE,FALSE,FALSE,'',ExcelBuf."Cell Type"::Text);
        //ExcelBuf.AddColumn("Sales Invoice Line"."Product Group Code",FALSE,'',FALSE,FALSE,FALSE,'',ExcelBuf."Cell Type"::Text);
        //ExcelBuf.AddColumn(StorageCategory,FALSE,'',FALSE,FALSE,FALSE,'',ExcelBuf."Cell Type"::Text);
        //ExcelBuf.AddColumn("Sales Invoice Line"."Unit of Measure Code",FALSE,'',FALSE,FALSE,FALSE,'',ExcelBuf."Cell Type"::Text);
        //ExcelBuf.AddColumn("Sales Invoice Line"."Customer Price Group",FALSE,'',FALSE,FALSE,FALSE,'',ExcelBuf."Cell Type"::Text);
        //ExcelBuf.AddColumn(ROUND("Sales Invoice Line"."Conversion Qty",1,'='),FALSE,'',FALSE,FALSE,FALSE,'',ExcelBuf."Cell Type"::Number);
        IF "Sales Invoice Line".Type = "Sales Invoice Line".Type::Item THEN //19-04-2019
            ExcelBuf.AddColumn("Sales Invoice Line".Quantity, FALSE, '', FALSE, FALSE, FALSE, '#,##0.00', ExcelBuf."Cell Type"::Number)
        ELSE
            ExcelBuf.AddColumn(0, FALSE, '', FALSE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Number);

        //ExcelBuf.AddColumn("Sales Invoice Line"."Fill Rate %",FALSE,'',FALSE,FALSE,FALSE,'',ExcelBuf."Cell Type"::Number);
        ExcelBuf.AddColumn("Sales Invoice Line"."Customer Price Group", FALSE, '', FALSE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn("Sales Invoice Line"."Special Price", FALSE, '', FALSE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Number);
        //ExcelBuf.AddColumn("Sales Invoice Line"."Unit Price",FALSE,'',FALSE,FALSE,FALSE,'',ExcelBuf."Cell Type"::Number);
        ExcelBuf.AddColumn("Sales Invoice Line".Quantity * "Sales Invoice Line"."Unit Price", FALSE, '', FALSE, FALSE, FALSE, '#,##0.00', ExcelBuf."Cell Type"::Number);

        ExcelBuf.AddColumn(FreightChargesTot, FALSE, '', FALSE, FALSE, FALSE, '#,##0.00', ExcelBuf."Cell Type"::Number);
        ExcelBuf.AddColumn(PackingCharges, FALSE, '', FALSE, FALSE, FALSE, '#,##0.00', ExcelBuf."Cell Type"::Number);
        ExcelBuf.AddColumn(ForwardingCharges, FALSE, '', FALSE, FALSE, FALSE, '#,##0.00', ExcelBuf."Cell Type"::Number);
        //ExcelBuf.AddColumn('DP/DF',FALSE,'',FALSE,FALSE,FALSE,'',ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn(IGST, FALSE, '', FALSE, FALSE, FALSE, '#,##0.00', ExcelBuf."Cell Type"::Number);
        ExcelBuf.AddColumn(CGST, FALSE, '', FALSE, FALSE, FALSE, '#,##0.00', ExcelBuf."Cell Type"::Number);
        ExcelBuf.AddColumn(SGST, FALSE, '', FALSE, FALSE, FALSE, '#,##0.00', ExcelBuf."Cell Type"::Number);
        ExcelBuf.AddColumn("Sales Invoice Line"."Line Discount Amount", FALSE, '#,##0.00', FALSE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Number);
        ExcelBuf.AddColumn(0, FALSE, '', FALSE, FALSE, FALSE, '#,##0.00', ExcelBuf."Cell Type"::Number); //PCPL/MIG/NSW Filed not Exist in BC18 TDS Amunt field
        ExcelBuf.AddColumn(InvoiceValue, FALSE, '', FALSE, FALSE, FALSE, '#,##0.00', ExcelBuf."Cell Type"::Number);
        ExcelBuf.AddColumn('', FALSE, '', FALSE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn("Sales Invoice Line"."GST Group Code", FALSE, '', FALSE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn("Sales Invoice Line"."HSN/SAC Code", FALSE, '', FALSE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn("Sales Invoice Header"."Acknowledgement No.", FALSE, '', FALSE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text);//CCIT-tk
        ExcelBuf.AddColumn(SIHACKDATETIME, FALSE, '', FALSE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text);//CCIT_TK
        ExcelBuf.AddColumn('', FALSE, '', FALSE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text);//CCIT_TK
        ExcelBuf.AddColumn(ShippingCharges, FALSE, '', FALSE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text);//15112021 CCIT AN
    end;

    procedure MakeExcelDataFooter();
    begin
        ExcelBuf.NewRow;
        ExcelBuf.NewRow;
        ExcelBuf.AddColumn('Total', FALSE, '', TRUE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text);
        //ExcelBuf.AddColumn('',FALSE,'',FALSE,FALSE,FALSE,'',ExcelBuf."Cell Type"::Number);
        //ExcelBuf.AddColumn('',FALSE,'',FALSE,FALSE,FALSE,'',ExcelBuf."Cell Type"::Date);
        ExcelBuf.AddColumn('', FALSE, '', FALSE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text);

        ExcelBuf.AddColumn('', FALSE, '', FALSE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn('', FALSE, '', FALSE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn('', FALSE, '', FALSE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text); //03-06-2019
        ExcelBuf.AddColumn('', FALSE, '', FALSE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Number);
        ExcelBuf.AddColumn('', FALSE, '', FALSE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Number);//New
        ExcelBuf.AddColumn('', FALSE, '', FALSE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Number);
        ExcelBuf.AddColumn('', FALSE, '', FALSE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Number);
        ExcelBuf.AddColumn('', FALSE, '', FALSE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Number);
        ExcelBuf.AddColumn('', FALSE, '', FALSE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Number);
        ExcelBuf.AddColumn('', FALSE, '', FALSE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Number);

        ExcelBuf.AddColumn('', FALSE, '', FALSE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Number);
        ExcelBuf.AddColumn('', FALSE, '', FALSE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Number);

        ExcelBuf.AddColumn('', FALSE, '', FALSE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Number);
        ExcelBuf.AddColumn('', FALSE, '', FALSE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Number);
        ExcelBuf.AddColumn('', FALSE, '', FALSE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Number);

        ExcelBuf.AddColumn('', FALSE, '', FALSE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Number);
        ExcelBuf.AddColumn('', FALSE, '', FALSE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Number);
        ExcelBuf.AddColumn('', FALSE, '', FALSE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Number);
        ExcelBuf.AddColumn('', FALSE, '', FALSE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Number);
        ExcelBuf.AddColumn('', FALSE, '', FALSE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Number);
        ExcelBuf.AddColumn('', FALSE, '', FALSE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Number);
        ExcelBuf.AddColumn('', FALSE, '', FALSE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Number);
        ExcelBuf.AddColumn('', FALSE, '', FALSE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Number);
        ExcelBuf.AddColumn('', FALSE, '', FALSE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Number);
        ExcelBuf.AddColumn('', FALSE, '', FALSE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Number);
        ExcelBuf.AddColumn('', FALSE, '', FALSE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Number);
        ExcelBuf.AddColumn('', FALSE, '', FALSE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Number);
        ExcelBuf.AddColumn('', FALSE, '', FALSE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Number);
        ExcelBuf.AddColumn(TotalConvQty, FALSE, '', TRUE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Number);
        ExcelBuf.AddColumn(TotalQty, FALSE, '', TRUE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Number);
        ExcelBuf.AddColumn('', FALSE, '', FALSE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Number);
        ExcelBuf.AddColumn('', FALSE, '', FALSE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Number);

        ExcelBuf.AddColumn(TotalBaseValue, FALSE, '', TRUE, FALSE, FALSE, '#,##0.00', ExcelBuf."Cell Type"::Number);
        ExcelBuf.AddColumn('', FALSE, '', FALSE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Number);
        ExcelBuf.AddColumn('', FALSE, '', FALSE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Number);
        ExcelBuf.AddColumn('', FALSE, '', FALSE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Number);
        //ExcelBuf.AddColumn('',FALSE,'',FALSE,FALSE,FALSE,'',ExcelBuf."Cell Type"::Number);
        ExcelBuf.AddColumn(TotalIGST, FALSE, '', TRUE, FALSE, FALSE, '#,##0.00', ExcelBuf."Cell Type"::Number);
        ExcelBuf.AddColumn(TotalCGST, FALSE, '', TRUE, FALSE, FALSE, '#,##0.00', ExcelBuf."Cell Type"::Number);
        ExcelBuf.AddColumn(TotalSGST, FALSE, '', TRUE, FALSE, FALSE, '#,##0.00', ExcelBuf."Cell Type"::Number);
        ExcelBuf.AddColumn('', FALSE, '', FALSE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Number);
        ExcelBuf.AddColumn(TotalInvoiceValue, FALSE, '', TRUE, FALSE, FALSE, '#,##0.00', ExcelBuf."Cell Type"::Number);
        ExcelBuf.AddColumn('', FALSE, '', FALSE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Number);
        /*{//15112021 CCIT AN
        ExcelBuf.AddColumn('',FALSE,'',FALSE,FALSE,FALSE,'',ExcelBuf."Cell Type"::Number);
        ExcelBuf.AddColumn('',FALSE,'',FALSE,FALSE,FALSE,'',ExcelBuf."Cell Type"::Number);
        ExcelBuf.AddColumn('',FALSE,'',FALSE,FALSE,FALSE,'',ExcelBuf."Cell Type"::Number);
        ExcelBuf.AddColumn('',FALSE,'',FALSE,FALSE,FALSE,'',ExcelBuf."Cell Type"::Number);
        ExcelBuf.AddColumn('',FALSE,'',FALSE,FALSE,FALSE,'',ExcelBuf."Cell Type"::Number);
        ExcelBuf.AddColumn('',FALSE,'',FALSE,FALSE,FALSE,'',ExcelBuf."Cell Type"::Number);
        ExcelBuf.AddColumn('',FALSE,'',FALSE,FALSE,FALSE,'',ExcelBuf."Cell Type"::Number);
        ExcelBuf.AddColumn('',FALSE,'',FALSE,FALSE,FALSE,'',ExcelBuf."Cell Type"::Number);
        ExcelBuf.AddColumn('',FALSE,'',TRUE,FALSE,FALSE,'',ExcelBuf."Cell Type"::Number);//15112021 CCIT AN Shipping charges total
        }*/


    end;

    procedure MakeExcelInfo1();
    begin
        /*
        ExcelBuf.NewRow;
        ExcelBuf.AddInfoColumn('SALES REGISTER',FALSE,'',TRUE,FALSE,FALSE,'',ExcelBuf."Cell Type"::Text);
        */

    end;

    procedure CreateExcelbook1();
    begin
        ExcelBuf.CreateBookAndOpenExcel('D:\Reports\Sales Register Credit Note.xlsx', 'Sales Register Credit Note', 'Sales Register Credit Note', COMPANYNAME, USERID);
        //PCPL/MIG/NSW Filed not Exist in BC18
    end;

    procedure MakeExcelDataHeader1();
    begin
        ExcelBuf.NewRow;
        ExcelBuf.AddColumn('Sales Register Credit Note', FALSE, '', TRUE, FALSE, TRUE, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.NewRow;
        ExcelBuf.NewRow;

        //ExcelBuf.AddColumn('Document Number',FALSE,'',TRUE,FALSE,FALSE,'',ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn('Serial Number', FALSE, '', TRUE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn('Branch Name', FALSE, '', TRUE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn('Sales Person', FALSE, '', TRUE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text);
        //ExcelBuf.AddColumn('Sales Person Trans',FALSE,'',TRUE,FALSE,FALSE,'',ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn('Customer Code', FALSE, '', TRUE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn('Customer Name', FALSE, '', TRUE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text);

        ExcelBuf.AddColumn('Delivery Outlet', FALSE, '', TRUE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text);//tk

        ExcelBuf.AddColumn('Sales Reporting Field', FALSE, '', TRUE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text);//New

        //ExcelBuf.AddColumn('Customer Group',FALSE,'',TRUE,FALSE,FALSE,'',ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn('Document Type', FALSE, '', TRUE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text);
        //ExcelBuf.AddColumn('Customer Order No',FALSE,'',TRUE,FALSE,FALSE,'',ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn('Customer Order Date', FALSE, '', TRUE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn('ERP SO No', FALSE, '', TRUE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn('ERP SO Date', FALSE, '', TRUE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text);

        ExcelBuf.AddColumn('ERP INV No', FALSE, '', TRUE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn('ERP INV Date', FALSE, '', TRUE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text);

        //ExcelBuf.AddColumn('Zone',FALSE,'',TRUE,FALSE,FALSE,'',ExcelBuf."Cell Type"::Text);
        //ExcelBuf.AddColumn('Customer Business format / Outlet Name',FALSE,'',TRUE,FALSE,FALSE,'',ExcelBuf."Cell Type"::Text);
        //ExcelBuf.AddColumn('Customer posting group',FALSE,'',TRUE,FALSE,FALSE,'',ExcelBuf."Cell Type"::Text);
        //ExcelBuf.AddColumn('Gen. Bus. Posting Group',FALSE,'',TRUE,FALSE,FALSE,'',ExcelBuf."Cell Type"::Text);
        //ExcelBuf.AddColumn('Vertical Sub Category',FALSE,'',TRUE,FALSE,FALSE,'',ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn('Purchase vendor name', FALSE, '', TRUE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn('Item code', FALSE, '', TRUE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn('Item name', FALSE, '', TRUE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn('Batch', FALSE, '', TRUE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn('Mfg Date', FALSE, '', TRUE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn('Expiry Date', FALSE, '', TRUE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn('Sales Category', FALSE, '', TRUE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text);

        //ExcelBuf.AddColumn('Brand Name',FALSE,'',TRUE,FALSE,FALSE,'',ExcelBuf."Cell Type"::Text);
        //ExcelBuf.AddColumn('Item Category Code',FALSE,'',TRUE,FALSE,FALSE,'',ExcelBuf."Cell Type"::Text);
        //ExcelBuf.AddColumn('Product Group Code',FALSE,'',TRUE,FALSE,FALSE,'',ExcelBuf."Cell Type"::Text);
        //ExcelBuf.AddColumn('Storage Category',FALSE,'',TRUE,FALSE,FALSE,'',ExcelBuf."Cell Type"::Text);
        //ExcelBuf.AddColumn('UOM',FALSE,'',TRUE,FALSE,FALSE,'',ExcelBuf."Cell Type"::Text);
        //ExcelBuf.AddColumn('Price Group',FALSE,'',TRUE,FALSE,FALSE,'',ExcelBuf."Cell Type"::Text);
        //ExcelBuf.AddColumn('Sales In PCS',FALSE,'',TRUE,FALSE,FALSE,'',ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn('Sales In KGS', FALSE, '', TRUE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text);
        //ExcelBuf.AddColumn('Fill Rate%',FALSE,'',TRUE,FALSE,FALSE,'',ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn('Customer Price Group', FALSE, '', TRUE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text);

        ExcelBuf.AddColumn('Special Price', FALSE, '', TRUE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text);
        //ExcelBuf.AddColumn('Price per kg',FALSE,'',TRUE,FALSE,FALSE,'',ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn('Base value', FALSE, '', TRUE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text);

        ExcelBuf.AddColumn('Freight', FALSE, '', TRUE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn('Packing charges', FALSE, '', TRUE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn('Forwarding charges', FALSE, '', TRUE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text);
        //ExcelBuf.AddColumn('DP/DF',FALSE,'',TRUE,FALSE,FALSE,'',ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn('IGST', FALSE, '', TRUE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn('CGST', FALSE, '', TRUE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn('SGST', FALSE, '', TRUE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn('Discount', FALSE, '', TRUE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn('TCS Value', FALSE, '', TRUE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn('Invoice Value', FALSE, '', TRUE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn('CR Reason Code', FALSE, '', TRUE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn('GST Group', FALSE, '', TRUE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn('HSN Code', FALSE, '', TRUE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn('Acknowledgement No', FALSE, '', TRUE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn('Acknowledgement Date', FALSE, '', TRUE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn('Tally/Temp Invoice No.', FALSE, '', TRUE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text);

    end;

    procedure MakeExcelDataBody1();
    begin
        ExcelBuf.NewRow;
        //ExcelBuf.AddColumn("Sales Cr.Memo Header"."No.",FALSE,'',FALSE,FALSE,FALSE,'',ExcelBuf."Cell Type"::Number);
        ExcelBuf.AddColumn(Sr_No1, FALSE, '', FALSE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Number);
        ExcelBuf.AddColumn("Sales Cr.Memo Header"."Location Code", FALSE, '', FALSE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn(SalesPersonName1, FALSE, '', FALSE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text);
        //ExcelBuf.AddColumn(SalesPerson_Trans ,FALSE,'',FALSE,FALSE,FALSE,'',ExcelBuf."Cell Type"::Text); //03-06/2019
        ExcelBuf.AddColumn("Sales Cr.Memo Header"."Sell-to Customer No.", FALSE, '', FALSE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text);

        ExcelBuf.AddColumn("Sales Cr.Memo Header"."Sell-to Customer Name" + "Sales Cr.Memo Header"."Sell-to Customer Name 2", FALSE, '', FALSE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn(DeliveryOutlet1, FALSE, '', FALSE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text);//New
        ExcelBuf.AddColumn(SalesReporting1, FALSE, '', FALSE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text);//New

        //ExcelBuf.AddColumn("Sales Cr.Memo Header"."Shortcut Dimension 1 Code",FALSE,'',FALSE,FALSE,FALSE,'',ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn('Credit Note', FALSE, '', FALSE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text);
        //ExcelBuf.AddColumn("Sales Cr.Memo Header"."External Document No.",FALSE,'',FALSE,FALSE,FALSE,'',ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn('', FALSE, '', FALSE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text);
        //ExcelBuf.AddColumn('',FALSE,'',FALSE,FALSE,FALSE,'',ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn(txtNo, FALSE, '', FALSE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn("Sales Cr.Memo Header"."Document Date", FALSE, '', FALSE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Date);
        ExcelBuf.AddColumn("Sales Cr.Memo Header"."No.", FALSE, '', FALSE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn("Sales Cr.Memo Header"."Posting Date", FALSE, '', FALSE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Date);

        MonthDateChr := FORMAT("Sales Cr.Memo Header"."Posting Date", 0, '<Month Text>-<Year>');//10-04-2019
        ExcelBuf.AddColumn(MonthDateChr, FALSE, '', FALSE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text);//10-04-2019

        ExcelBuf.AddColumn("Sales Cr.Memo Header"."Applies-to Doc. No.", FALSE, '', FALSE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text);
        //ExcelBuf.AddColumn("Sales Cr.Memo Header"."Posting Date",FALSE,'',FALSE,FALSE,FALSE,'',ExcelBuf."Cell Type"::Date);
        //ExcelBuf.AddColumn("Sales Cr.Memo Header"."Shortcut Dimension 2 Code",FALSE,'',FALSE,FALSE,FALSE,'',ExcelBuf."Cell Type"::Text);
        //ExcelBuf.AddColumn('',FALSE,'',FALSE,FALSE,FALSE,'',ExcelBuf."Cell Type"::Text);
        //ExcelBuf.AddColumn('',FALSE,'',FALSE,FALSE,FALSE,'',ExcelBuf."Cell Type"::Text);
        //ExcelBuf.AddColumn("Sales Cr.Memo Header"."Business Format / Outlet Name",FALSE,'',FALSE,FALSE,FALSE,'',ExcelBuf."Cell Type"::Text);
        //ExcelBuf.AddColumn("Sales Cr.Memo Header"."Customer Posting Group",FALSE,'',FALSE,FALSE,FALSE,'',ExcelBuf."Cell Type"::Text);
        //ExcelBuf.AddColumn("Sales Cr.Memo Header"."Gen. Bus. Posting Group",FALSE,'',FALSE,FALSE,FALSE,'',ExcelBuf."Cell Type"::Text);
        //ExcelBuf.AddColumn("Sales Cr.Memo Header"."Vertical Sub Category",FALSE,'',FALSE,FALSE,FALSE,'',ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn(VendName1, FALSE, '', FALSE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn("Sales Cr.Memo Line"."No.", FALSE, '', FALSE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Number);
        ExcelBuf.AddColumn("Sales Cr.Memo Line".Description, FALSE, '', FALSE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Number);
        ExcelBuf.AddColumn(batch1, FALSE, '', FALSE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn(mfgdate1, FALSE, '', FALSE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Date);
        ExcelBuf.AddColumn(expdate1, FALSE, '', FALSE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Date);

        //ExcelBuf.AddColumn("Sales Cr.Memo Line"."Sales Category",FALSE,'',FALSE,FALSE,FALSE,'',ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn(SalesCategory, FALSE, '', FALSE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text);
        //ExcelBuf.AddColumn(BrandName1,FALSE,'',FALSE,FALSE,FALSE,'',ExcelBuf."Cell Type"::Text);
        //ExcelBuf.AddColumn("Sales Cr.Memo Line"."Item Category Code",FALSE,'',FALSE,FALSE,FALSE,'',ExcelBuf."Cell Type"::Text);
        //ExcelBuf.AddColumn("Sales Cr.Memo Line"."Product Group Code",FALSE,'',FALSE,FALSE,FALSE,'',ExcelBuf."Cell Type"::Text);
        //ExcelBuf.AddColumn(StorageCategory1,FALSE,'',FALSE,FALSE,FALSE,'',ExcelBuf."Cell Type"::Text);
        //ExcelBuf.AddColumn("Sales Cr.Memo Line"."Unit of Measure Code",FALSE,'',FALSE,FALSE,FALSE,'',ExcelBuf."Cell Type"::Text);
        //ExcelBuf.AddColumn("Sales Cr.Memo Line"."Customer Price Group",FALSE,'',FALSE,FALSE,FALSE,'',ExcelBuf."Cell Type"::Text);
        //ExcelBuf.AddColumn(-ROUND("Sales Cr.Memo Line"."Conversion Qty",1,'='),FALSE,'',FALSE,FALSE,FALSE,'',ExcelBuf."Cell Type"::Number);
        IF "Sales Cr.Memo Line".Type = "Sales Cr.Memo Line".Type::Item THEN
            ExcelBuf.AddColumn(-"Sales Cr.Memo Line".Quantity, FALSE, '', FALSE, FALSE, FALSE, '#,##0.00', ExcelBuf."Cell Type"::Number)
        ELSE
            ExcelBuf.AddColumn(0, FALSE, '', FALSE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Number);
        //ExcelBuf.AddColumn(-"Sales Cr.Memo Line"."Fill Rate %",FALSE,'',FALSE,FALSE,FALSE,'',ExcelBuf."Cell Type"::Number);
        ExcelBuf.AddColumn("Sales Cr.Memo Line"."Customer Price Group", FALSE, '', FALSE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn("Sales Cr.Memo Line"."Special Price", FALSE, '', FALSE, FALSE, FALSE, '#,##0.00', ExcelBuf."Cell Type"::Number);
        //ExcelBuf.AddColumn("Sales Cr.Memo Line"."Unit Price",FALSE,'',FALSE,FALSE,FALSE,'',ExcelBuf."Cell Type"::Number);
        ExcelBuf.AddColumn(-("Sales Cr.Memo Line".Quantity * "Sales Cr.Memo Line"."Unit Price"), FALSE, '', FALSE, FALSE, FALSE, '#,##0.00', ExcelBuf."Cell Type"::Number);

        ExcelBuf.AddColumn(FreightChargesTot1, FALSE, '', FALSE, FALSE, FALSE, '#,##0.00', ExcelBuf."Cell Type"::Number);
        ExcelBuf.AddColumn(PackingCharges1, FALSE, '', FALSE, FALSE, FALSE, '#,##0.00', ExcelBuf."Cell Type"::Number);
        ExcelBuf.AddColumn(ForwardingCharges1, FALSE, '', FALSE, FALSE, FALSE, '#,##0.00', ExcelBuf."Cell Type"::Number);
        //ExcelBuf.AddColumn('DP/DF',FALSE,'',FALSE,FALSE,FALSE,'',ExcelBuf."Cell Type"::Number);
        ExcelBuf.AddColumn(-IGST1, FALSE, '', FALSE, FALSE, FALSE, '#,##0.00', ExcelBuf."Cell Type"::Number);
        ExcelBuf.AddColumn(-CGST1, FALSE, '', FALSE, FALSE, FALSE, '#,##0.00', ExcelBuf."Cell Type"::Number);
        ExcelBuf.AddColumn(-SGST1, FALSE, '', FALSE, FALSE, FALSE, '#,##0.00', ExcelBuf."Cell Type"::Number);
        ExcelBuf.AddColumn("Sales Cr.Memo Line"."Line Discount Amount", FALSE, '', FALSE, FALSE, FALSE, '#,##0.00', ExcelBuf."Cell Type"::Number);
        ExcelBuf.AddColumn(0, FALSE, '', FALSE, FALSE, FALSE, '#,##0.00', ExcelBuf."Cell Type"::Number); //PCPL/MIG/NSW Filed not Exist in BC18 TDS TCS amount field
        ExcelBuf.AddColumn(-InvoiceValue1, FALSE, '', FALSE, FALSE, FALSE, '#,##0.00', ExcelBuf."Cell Type"::Number);
        //ExcelBuf.AddColumn("Sales Cr.Memo Line"."Return Reason Code",FALSE,'',FALSE,FALSE,FALSE,'',ExcelBuf."Cell Type"::Text);
        IF RecReasonCode.GET("Sales Cr.Memo Line"."Reason Code") THEN
            ReasonCodeTxt := RecReasonCode.Description
        ELSE
            ReasonCodeTxt := '';
        ExcelBuf.AddColumn(ReasonCodeTxt, FALSE, '', FALSE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn("Sales Cr.Memo Line"."GST Group Code", FALSE, '', FALSE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn("Sales Cr.Memo Line"."HSN/SAC Code", FALSE, '', FALSE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn("Sales Cr.Memo Header"."E-Invoice Acknowledgment No.", FALSE, '', FALSE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text);//CCIT_TK
        ExcelBuf.AddColumn(SIHACKDATETIME, FALSE, '', FALSE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text);//CCIT_TK
        ExcelBuf.AddColumn("Sales Cr.Memo Header"."Tally Invoice No.", FALSE, '', FALSE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text);//CCIT_TK
    end;

    procedure MakeExcelDataFooter1();
    begin

        ExcelBuf.NewRow;
        ExcelBuf.NewRow;
        ExcelBuf.AddColumn('Total', FALSE, '', TRUE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text);
        //ExcelBuf.AddColumn('',FALSE,'',FALSE,FALSE,FALSE,'',ExcelBuf."Cell Type"::Number);
        ExcelBuf.AddColumn('', FALSE, '', FALSE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn('', FALSE, '', FALSE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Date);
        ExcelBuf.AddColumn('', FALSE, '', FALSE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn('', FALSE, '', FALSE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn('', FALSE, '', FALSE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text);//New

        ExcelBuf.AddColumn('', FALSE, '', FALSE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text);//New
        ExcelBuf.AddColumn('', FALSE, '', FALSE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text); //03-06-2019
        ExcelBuf.AddColumn('', FALSE, '', FALSE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn('', FALSE, '', FALSE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Number);
        ExcelBuf.AddColumn('', FALSE, '', FALSE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Number);
        ExcelBuf.AddColumn('', FALSE, '', FALSE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Number);
        ExcelBuf.AddColumn('', FALSE, '', FALSE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Number);

        ExcelBuf.AddColumn('', FALSE, '', FALSE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Number);
        ExcelBuf.AddColumn('', FALSE, '', FALSE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Number);
        ExcelBuf.AddColumn('', FALSE, '', FALSE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text);//New
        ExcelBuf.AddColumn('', FALSE, '', FALSE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Number);
        ExcelBuf.AddColumn('', FALSE, '', FALSE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Number);
        ExcelBuf.AddColumn('', FALSE, '', FALSE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Number);
        ExcelBuf.AddColumn('', FALSE, '', FALSE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Number);
        ExcelBuf.AddColumn('', FALSE, '', FALSE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text);

        ExcelBuf.AddColumn('', FALSE, '', FALSE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Date);
        //ExcelBuf.AddColumn('',FALSE,'',FALSE,FALSE,FALSE,'',ExcelBuf."Cell Type"::Text);
        //ExcelBuf.AddColumn('',FALSE,'',FALSE,FALSE,FALSE,'',ExcelBuf."Cell Type"::Text);
        //ExcelBuf.AddColumn('',FALSE,'',FALSE,FALSE,FALSE,'',ExcelBuf."Cell Type"::Number);
        //ExcelBuf.AddColumn('',FALSE,'',FALSE,FALSE,FALSE,'',ExcelBuf."Cell Type"::Number);
        ExcelBuf.AddColumn(TotalQty - TotalQty1, FALSE, '', TRUE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Number);
        //ExcelBuf.AddColumn(TotalBaseValue1,FALSE,'',TRUE,FALSE,FALSE,'',ExcelBuf."Cell Type"::Number);
        //ExcelBuf.AddColumn('',FALSE,'',FALSE,FALSE,FALSE,'',ExcelBuf."Cell Type"::Number);
        //ExcelBuf.AddColumn('',FALSE,'',FALSE,FALSE,FALSE,'',ExcelBuf."Cell Type"::Number);

        //ExcelBuf.AddColumn('',FALSE,'',FALSE,FALSE,FALSE,'',ExcelBuf."Cell Type"::Number);
        //ExcelBuf.AddColumn('',FALSE,'',FALSE,FALSE,FALSE,'',ExcelBuf."Cell Type"::Number);
        //ExcelBuf.AddColumn('',FALSE,'',FALSE,FALSE,FALSE,'',ExcelBuf."Cell Type"::Number);
        //ExcelBuf.AddColumn('',FALSE,'',FALSE,FALSE,FALSE,'',ExcelBuf."Cell Type"::Number);
        //ExcelBuf.AddColumn('',FALSE,'',FALSE,FALSE,FALSE,'',ExcelBuf."Cell Type"::Number);

        //ExcelBuf.AddColumn(TotalConvQty-TotalConvQty1,FALSE,'',TRUE,FALSE,FALSE,'',ExcelBuf."Cell Type"::Number);
        //ExcelBuf.AddColumn(TotalQty-TotalQty1,FALSE,'',TRUE,FALSE,FALSE,'',ExcelBuf."Cell Type"::Number);
        ExcelBuf.AddColumn('', FALSE, '', FALSE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Number);
        ExcelBuf.AddColumn('', FALSE, '', FALSE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Number);

        ExcelBuf.AddColumn('', FALSE, '', TRUE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Number);
        //ExcelBuf.AddColumn(TotalBaseValue1,FALSE,'',TRUE,FALSE,FALSE,'',ExcelBuf."Cell Type"::Number);
        ExcelBuf.AddColumn('', FALSE, '', FALSE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Number);
        ExcelBuf.AddColumn('', FALSE, '', FALSE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Number);
        ExcelBuf.AddColumn('', FALSE, '', FALSE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Number);
        //ExcelBuf.AddColumn('',FALSE,'',FALSE,FALSE,FALSE,'',ExcelBuf."Cell Type"::Number);
        ExcelBuf.AddColumn(TotalIGST - TotalIGST1, FALSE, '', TRUE, FALSE, FALSE, '#,##0.00', ExcelBuf."Cell Type"::Number);
        ExcelBuf.AddColumn(TotalCGST - TotalCGST1, FALSE, '', TRUE, FALSE, FALSE, '#,##0.00', ExcelBuf."Cell Type"::Number);
        ExcelBuf.AddColumn(TotalSGST - TotalSGST1, FALSE, '', TRUE, FALSE, FALSE, '#,##0.00', ExcelBuf."Cell Type"::Number);

        ExcelBuf.AddColumn('', FALSE, '', FALSE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn('', FALSE, '', FALSE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn(TotalInvoiceValue - TotalInvoiceValue1, FALSE, '', TRUE, FALSE, FALSE, '#,##0.00', ExcelBuf."Cell Type"::Number);
        ExcelBuf.AddColumn('', FALSE, '', FALSE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text);

        /*{//15112021 CCIT AN
        ExcelBuf.AddColumn('',FALSE,'',FALSE,FALSE,FALSE,'',ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn('',FALSE,'',FALSE,FALSE,FALSE,'',ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn('',FALSE,'',FALSE,FALSE,FALSE,'',ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn('',FALSE,'',FALSE,FALSE,FALSE,'',ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn('',FALSE,'',FALSE,FALSE,FALSE,'',ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn('',FALSE,'',FALSE,FALSE,FALSE,'',ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn('',FALSE,'',FALSE,FALSE,FALSE,'',ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn('',FALSE,'',FALSE,FALSE,FALSE,'',ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn('Total SC2',FALSE,'',TRUE,FALSE,FALSE,'',ExcelBuf."Cell Type"::Number); // Shipping charges total
        //15112021 CCIT AN }
        */

    end;
}

