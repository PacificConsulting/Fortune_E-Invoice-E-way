report 50000 "Sales Tax Invoice"
{
    // version CCIT-Fortune-SG,CITS_RS

    DefaultLayout = RDLC;
    RDLCLayout = 'src/reportlayout/Sales Tax Invoice.rdl';
    ApplicationArea = all;
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem("Sales Invoice Header"; "Sales Invoice Header")
        {
            DataItemTableView = SORTING("No.");
            RequestFilterFields = "No.";
            //
            column(Ack_Date; "Sales Invoice Header"."Acknowledgement Date")
            {
            }
            column(Transport_Vendor_Name; "Transport Vendor Name")
            {

            }
            column(EWAYbillNo; EWAYDetails."Eway Bill No.")
            {

            }
            column(E_Way_Bill_Date; "E-Way Bill Date")
            {

            }

            column(IRNNo; EINVDETILS."E-Invoice IRN No.")
            {

            }
            column(QRCode; EINVDETILS."E-Invoice QR Code")
            {

            }
            column(Ship_to_Name; "Sales Invoice Header"."Ship-to Name")
            {
            }
            column(Ship_to_Address; "Sales Invoice Header"."Ship-to Address")
            {
            }
            column(Ship_to_Address_2; "Sales Invoice Header"."Ship-to Address 2")
            {
            }
            column(Ship_to_City; "Sales Invoice Header"."Ship-to City")
            {
            }
            column(Ship_to_Post_Code; "Sales Invoice Header"."Ship-to Post Code")
            {
            }
            column(Ship_to_Contact; "Sales Invoice Header"."Ship-to Contact")
            {
            }
            column(Ack_number; "Sales Invoice Header"."Acknowledgement No.")
            {
            }
            column(QR_code; "Sales Invoice Header"."E-Invoice QR")
            {
            }
            column(E_Invoice_IRN; "Sales Invoice Header"."E-Invoice IRN")
            {
            }
            column(PAYREF; "Sales Invoice Header"."Your Reference")
            {
            }
            column(PAYREFDATE; "Sales Invoice Header"."PAY REF DATE")
            {
            }
            column(TEXT005; TEXT005)
            {
            }

            dataitem(CopyLoop; Integer)
            {
                DataItemTableView = SORTING(Number);
                column(OutPutNo; OutPutNo)
                {
                }
                dataitem(PageLoop; Integer)
                {
                    DataItemTableView = SORTING(Number)
                                        WHERE(Number = CONST(1));
                    column(Shipcustname; Shipcustname)
                    {
                    }
                    column(Shipcustaddr; Shipcustaddr)
                    {
                    }
                    column(Shipcustaddr1; Shipcustaddr1)
                    {
                    }
                    column(Shipcustaddr2; Shipcustaddr2)
                    {
                    }
                    column(Shipcustcity; Shipcustcity)
                    {
                    }
                    column(Shipcustcountry; Shipcustcountry)
                    {
                    }
                    column(Shipcustphone; Shipcustphone)
                    {
                    }
                    column(Shipcustpincode; Shipcustpincode)
                    {
                    }
                    column(Shcustgstnoip; Shcustgstnoip)
                    {
                    }
                    column(Shipcustfssaino; Shipcustfssaino)
                    {
                    }
                    column(Shipcustemail; Shipcustemail)
                    {
                    }
                    column(Shipcustpersonname; Shipcustpersonname)
                    {
                    }
                    column(Shipcustpancard; ShipcustPostCode)
                    {
                    }
                    column(Shipcustgstno; Shipcustgstno)
                    {
                    }
                    column(ShipStatename; ShipStatename)
                    {
                    }
                    column(ShipStatecode; ShipStateCode)
                    {
                    }
                    column(CopyText; COPYTEXT)
                    {
                    }
                    column(LocationCode_SalesInvoiceHeader; "Sales Invoice Header"."Location Code")
                    {
                    }
                    column(TransportVendor_SalesInvoiceHeader; "Sales Invoice Header"."Transport Vendor Name")
                    {
                    }
                    column(Structure_SalesInvoiceHeader; '')//"Sales Invoice Header".Structure)
                    {
                    }
                    column(PaymentTermsCode_SalesInvoiceHeader; "Sales Invoice Header"."Payment Terms Code")
                    {
                    }
                    column(OrderDate_SalesInvoiceHeader; "Sales Invoice Header"."Order Date")
                    {
                    }
                    column(SIH_FreeSample; "Sales Invoice Header"."Free Sample")
                    {
                    }
                    column(OrderNo_SalesInvoiceHeader; "Sales Invoice Header"."Order No.")
                    {
                    }
                    column(PostingDate_SalesInvoiceHeader; "Sales Invoice Header"."Posting Date")
                    {
                    }
                    column(No_SalesInvoiceHeader; "Sales Invoice Header"."No.")
                    {
                    }
                    column(CompanyLogo; CompanyInfo.Picture)
                    {
                    }
                    column(UPILogo; CompanyInfo."UPI QR Code")
                    {
                    }

                    column(CIN_N0; CIN_N0)
                    {
                    }
                    column(PAN_No1; PAN_No1)
                    {
                    }
                    column(StateCode_; StateCode)
                    {
                    }
                    column(StateName; StateName)
                    {
                    }
                    column(StateCodeTIN; StateCodeTIN)
                    {
                    }
                    column(PageCaption; PageCaption)
                    {
                    }
                    column(CompName; CompanyInfo.Name)
                    {
                    }
                    column(CompName2; CompanyInfo."Name 2")
                    {
                    }
                    column(CompAddres; CompanyInfo.Address)
                    {
                    }
                    column(CompAddres2; CompanyInfo."Address 2")
                    {
                    }
                    column(CompCity; CompanyInfo.City)
                    {
                    }
                    column(CompPostCode; CompanyInfo."Post Code")
                    {
                    }
                    column(CompCountry; CompanyInfo.County)
                    {
                    }
                    column(CI_MSMENo; CompanyInfo."MSME No.")
                    {
                    }
                    column(SelltoCustomerName_SalesInvoiceHeader; "Sales Invoice Header"."Sell-to Customer Name")
                    {
                    }
                    column(SelltoCustomerName2_SalesInvoiceHeader; "Sales Invoice Header"."Sell-to Customer Name 2")
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
                    column(SelltoContact_SalesInvoiceHeader; "Sales Invoice Header"."Sell-to Contact")
                    {
                    }
                    column(SelltoPostCode_SalesInvoiceHeader; "Sales Invoice Header"."Sell-to Post Code")
                    {
                    }
                    column(SelltoCountryRegionCode_SalesInvoiceHeader; "Sales Invoice Header"."Sell-to Country/Region Code")
                    {
                    }
                    column(CustStatename; CustStatename)
                    {
                    }
                    column(CustStatecode; CustStatecode)
                    {
                    }
                    column(ExternalDocumentNo_SalesInvoiceHeader; "Sales Invoice Header"."External Document No.")
                    {
                    }
                    column(DocumentDate_SalesInvoiceHeader; "Sales Invoice Header"."Document Date")
                    {
                    }
                    column(ShiptoPostCode_SalesInvoiceHeader; "Sales Invoice Header"."Ship-to Post Code")
                    {
                    }
                    column(ShiptoCode_SalesInvoiceHeader; "Sales Invoice Header"."Ship-to Code")
                    {
                    }
                    column(ShiptoName_SalesInvoiceHeader; "Sales Invoice Header"."Ship-to Name")
                    {
                    }
                    column(ShiptoName2_SalesInvoiceHeader; "Sales Invoice Header"."Ship-to Name 2")
                    {
                    }
                    column(ShiptoAddress_SalesInvoiceHeader; "Sales Invoice Header"."Ship-to Address")
                    {
                    }
                    column(ShiptoAddress2_SalesInvoiceHeader; "Sales Invoice Header"."Ship-to Address 2")
                    {
                    }
                    column(ShiptoCity; "Sales Invoice Header"."Ship-to City")
                    {
                    }
                    column(ShiptoContact; "Sales Invoice Header"."Ship-to Contact")
                    {
                    }
                    column(LocName; LocName)
                    {
                    }
                    column(LocAddr1; LocAddr1)
                    {
                    }
                    column(LocAddr2; LocAddr2)
                    {
                    }
                    column(LocCity; LocCity)
                    {
                    }
                    column(LocPhone; LocPhone)
                    {
                    }

                    column(LocEmail; LocEmail)
                    {
                    }
                    column(StateCode; StateCode)
                    {
                    }

                    column(LocCountry; LocCountry)
                    {
                    }
                    column(LocFssaiNo; LocFssaiNo)
                    {
                    }
                    column(LocPinCode; LocPinCode)
                    {
                    }
                    column(LocGSTNoS; LocGSTNo)
                    {
                    }
                    column(custname; custname)
                    {
                    }
                    column(custaddr; "Sales Invoice Header"."Sell-to Address")
                    {
                    }
                    column(custaddr1; "Sales Invoice Header"."Sell-to Address 2")
                    {
                    }
                    column(custaddr2; custaddr2)
                    {
                    }
                    column(custaddr3; custaddr3)
                    {
                    }
                    column(custcity; "Sales Invoice Header"."Sell-to City")
                    {
                    }
                    column(custcountry; custcountry)
                    {
                    }
                    column(custphone; custphone)
                    {
                    }
                    column(custpincode; "Sales Invoice Header"."Sell-to Post Code")
                    {
                    }
                    column(custgstno; custgstno)
                    {
                    }
                    column(custfssaino; custfssaino)
                    {
                    }
                    column(custemail; custemail)
                    {
                    }

                    column(custpancard; custpancard)
                    {
                    }
                    column(custpersonname; custpersonname)
                    {
                    }
                    column(UINNo; UINNo)
                    {
                    }
                    column(Batch; Batch)
                    {
                    }
                    column(MFGDate; MFGDate)
                    {
                    }
                    column(EXPDate; EXPDate)
                    {
                    }
                    column(ShiptoCity_SalesInvoiceHeader; "Sales Invoice Header"."Ship-to City")
                    {
                    }
                    column(DueDate_SalesInvoiceHeader; "Sales Invoice Header"."Due Date")
                    {
                    }
                    column(LRRRNo_SalesInvoiceHeader; "Sales Invoice Header"."LR/RR No.")//)
                    {
                    }
                    column(LRRRDate_SalesInvoiceHeader; "Sales Invoice Header"."LR/RR Date")//)
                    {
                    }
                    column(VehicleNo_SalesInvoiceHeader; "Sales Invoice Header"."Vehicle No.")
                    {
                    }
                    column(ModeofTransport_SalesInvoiceHeader; "Sales Invoice Header"."Mode of Transport")
                    {
                    }
                    column(PTDesc; PTDesc)
                    {
                    }
                    column(EWayBillNo_SalesInvoiceHeader; "Sales Invoice Header"."E-Way Bill No.")
                    {
                    }
                    column(EWayBillDate_SalesInvoiceHeader; "Sales Invoice Header"."E-Way Bill Date")
                    {
                    }
                    column(SealNo_SalesInvoiceHeader; "Sales Invoice Header"."Seal No.")
                    {
                    }

                    column(AmountinWords11; AmountinWords1[1])
                    {
                    }
                    column(AmountinWords1; AmountinWords[1])
                    {
                    }


                    dataitem("Sales Invoice Line"; "Sales Invoice Line")
                    {
                        DataItemLink = "Document No." = FIELD("No.");
                        DataItemLinkReference = "Sales Invoice Header";
                        DataItemTableView = WHERE(Quantity = FILTER(<> 0));
                        column(Type_SalesInvoiceLine; "Sales Invoice Line".Type)
                        {
                        }
                        column(InvDiscountAmount_SalesInvoiceLine; "Sales Invoice Line"."Inv. Discount Amount")
                        {
                        }
                        column(SlNo; SlNo)
                        {
                        }

                        column(RateInPCS_SalesInvoiceLine; "Sales Invoice Line"."Rate In PCS")
                        {
                        }
                        column(AmountInPCS_SalesInvoiceLine; "Sales Invoice Line"."Amount In PCS")
                        {
                        }
                        column(GSTBaseAmount_SalesInvoiceLine; '')//"Sales Invoice Line"."GST Base Amount")
                        {
                        }
                        column(ConversionUOM_SalesInvoiceLine; "Sales Invoice Line"."Conversion UOM")
                        {
                        }
                        column(LineDiscountAmount_SalesInvoiceLine; "Sales Invoice Line"."Line Discount Amount")
                        {
                        }
                        column(GSTJurisdictionType_SalesInvoiceLine; "Sales Invoice Line"."GST Jurisdiction Type")
                        {
                        }
                        column(MRP_PriceNew; "Sales Invoice Line"."MRP Price")
                        {

                        }
                        column(SL_MRP_PRICE; "Sales Invoice Line"."MRP Price")//"Sales Invoice Line"."MRP Price")
                        {

                        }
                        column(TotalValue; TotalValue)
                        {

                        }
                        column(TaxBaseAmount_SalesInvoiceLine; '')//"Sales Invoice Line"."Tax Base Amount")
                        {

                        }
                        column(LineAmount_SalesInvoiceLine; "Sales Invoice Line"."Line Amount")
                        {
                        }
                        column(LineDiscount_SalesInvoiceLine; "Sales Invoice Line"."Line Discount %")
                        {
                        }
                        column(HSNSACCode_SalesInvoiceLine; "Sales Invoice Line"."HSN/SAC Code")
                        {
                        }
                        column(DocumentNo_SalesInvoiceLine; "Sales Invoice Line"."Document No.")
                        {
                        }
                        column(No_SalesInvoiceLine; "Sales Invoice Line"."No.")
                        {
                        }
                        column(Description_SalesInvoiceLine; "Sales Invoice Line".Description)
                        {
                        }
                        column(UnitofMeasure_SalesInvoiceLine; "Sales Invoice Line"."Unit of Measure")
                        {
                        }
                        column(GLquantity; GLquantity)
                        {
                        }
                        column(Quantity_SalesInvoiceLine; "Sales Invoice Line".Quantity)
                        {
                        }
                        column(ConversionQty_SalesInvoiceLine; "Sales Invoice Line"."Conversion Qty")
                        {
                        }
                        column(UnitPrice_SalesInvoiceLine; "Sales Invoice Line"."Unit Price")
                        {
                        }
                        column(Amount_SalesInvoiceLine; "Sales Invoice Line".Amount)
                        {
                        }
                        column(TCSPer; TCSPer)//"Sales Invoice Line"."TDS/TCS %")
                        {
                        }
                        column(TCSAmount; TCSAMTLinewise)//"Sales Invoice Line"."TDS/TCS Amount")
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
                        column(QtyKG; QtyKG)
                        {
                        }
                        column(QtyPCS; QtyPCS)
                        {
                        }
                        column(LineDiscAmt; LineDiscAmt)
                        {
                        }
                        column(LineTotAmt; LineTotAmt)
                        {
                        }
                        column(StorageTemp; StorageTemp)
                        {
                        }
                        column(EANCode; EANCode)
                        {
                        }
                        column(BrandName; BrandName)
                        {
                        }
                        column(InvDiscAmt; InvDiscAmt)
                        {
                        }
                        column(MRP_Price; MRP_Price)
                        {
                        }
                        column(ChargesTotal; ChargesTotal)
                        {
                        }
                        column(ConvPcsQty; ConvPcsQty)
                        {
                        }
                        column(TtlConvPcsQty; TtlConvPcsQty)
                        {
                        }


                        trigger OnAfterGetRecord();
                        var
                            SIL: Record 113;


                        begin
                            SlNo += 1;
                            ConvPcsQty := '';
                            IF RecItem.GET("Sales Invoice Line"."No.") THEN BEGIN
                                //Descp := RecItem.Description;
                                StorageTemp := RecItem."Storage Temperature";
                                EANCode := RecItem."EAN Code No.";
                                BrandName := RecItem."Brand Name";
                                MRP_Price := 0;//RecItem."MRP Price";
                                               // rdk 180919 -
                                IF (RecItem.Tolerance) /*AND ("Sales Invoice Line".Type = "Sales Invoice Line".Type::Item) */THEN BEGIN
                                    ConvPcsQty := '';
                                    TtlConvPcsQty := 0;
                                END
                                ELSE BEGIN
                                    ConvPcsQty := FORMAT("Sales Invoice Line"."Conversion Qty");
                                    TtlConvPcsQty := "Sales Invoice Line"."Conversion Qty";
                                END
                                // rdk 180919 +
                            END;
                            IF "Sales Invoice Line".Type = "Sales Invoice Line".Type::"Charge (Item)" THEN
                                ChargesTotal += "Sales Invoice Line".Quantity * "Sales Invoice Line"."Unit Price";
                            //TotalInKGAmt += TotalInKG;
                            LineTotAmt := 0;
                            LineDiscAmt := 0;
                            IF RecItem.GET("Sales Invoice Line"."No.") THEN BEGIN
                                IF RecItem."Gen. Prod. Posting Group" = 'RETAIL' THEN BEGIN
                                    LineDiscAmt := ("Sales Invoice Line"."Rate In PCS" * "Sales Invoice Line"."Conversion Qty") * ("Sales Invoice Line"."Line Discount %" / 100);
                                    LineTotAmt := ("Sales Invoice Line"."Rate In PCS" * "Sales Invoice Line"."Conversion Qty") - LineDiscAmt;
                                END
                                ELSE BEGIN
                                    LineTotAmt := "Sales Invoice Line"."Line Amount";
                                    LineDiscAmt := "Sales Invoice Line"."Line Discount Amount";
                                END
                            END;

                            CGST := 0;
                            SGST := 0;
                            IGST := 0;
                            Rate := 0;
                            Rate1 := 0;
                            //<<PCPL/MIG/NSW New Code for GST Calculation
                            //>>PCPL/BPPL/010
                            //>>PCPL/BPPL/010
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


                            /*
                            GLE.RESET;
                            GLE.SETRANGE(GLE."Document No.","Sales Invoice Line"."Document No.");
                            GLE.SETRANGE(GLE."HSN/SAC Code","Sales Invoice Line"."HSN/SAC Code");
                            GLE.SETRANGE(GLE."Transaction Type",GLE."Transaction Type"::Sales);
                            IF GLE.FINDSET THEN REPEAT
                            IF GLE."GST Component Code"='CGST' THEN BEGIN
                                CGSTHSN+=ABS(GLE."GST Amount");
                                CGSTPer:=(GLE."GST %")/2;
                            END
                            ELSE IF GLE."GST Component Code"='IGST' THEN  BEGIN
                                IGSTHSN+=ABS(GLE."GST Amount");
                                IGSTPer:=GLE."GST %";
                            END
                            ELSE IF GLE."GST Component Code"='SGST' THEN BEGIN
                                SGSTHSN+=ABS(GLE."GST Amount");
                                SGSTPer:=(GLE."GST %")/2;
                            END;
                            UNTIL GLE.NEXT=0;

                            */
                            //>>PCPL/MIG/NSW
                            /*
                            IF "Sales Invoice Line"."GST Jurisdiction Type" = "Sales Invoice Line"."GST Jurisdiction Type"::Intrastate THEN BEGIN
                                Rate := CGSTPer;//"Sales Invoice Line"."GST %"/2;
                                CGST := CGST;//"Sales Invoice Line"."Total GST Amount"/2;
                                SGST := SGST;//"Sales Invoice Line"."Total GST Amount"/2;
                            END
                            ELSE
                                IF ("Sales Invoice Line"."GST Jurisdiction Type" = "Sales Invoice Line"."GST Jurisdiction Type"::Interstate) THEN BEGIN
                                    Rate1 := IGSTPer;//"Sales Invoice Line"."GST %";
                                    IGST := IGST;//"Sales Invoice Line"."Total GST Amount";
                                END;
                                */
                            TotalCGST += CGST;
                            TotalSGST += SGST;
                            TotalIGST += IGST;

                            /*IF ("Sales Invoice Line".Type="Sales Invoice Line".Type::"G/L Account") THEN
                             GLquantity := "Sales Invoice Line"."Unit Price";*///tk commented round off total issue 191021
                            LineTotAmt := "Sales Invoice Line"."Line Amount";//CCIT_TK
                                                                             //MESSAGE('%1', GLquantity);

                            //<<PCPL/MIG/NSW
                            //IF "Sales Invoice Line"."Tax Base Amount" > 0 THEN BEGIN
                            TotalValue += TotalValue;// "Sales Invoice Line"."Tax Base Amount";
                                                     //MESSAGE('%1 %2',"Sales Invoice Line"."Tax Base Amount",TotalValue);
                                                     //END;
                                                     //>>PCPL/MIG/NSW

                            //InvDiscAmt += "Sales Invoice Line"."Inv. Discount Amount";

                            "Sales Invoice Header".CALCFIELDS("Sales Invoice Header"."Invoice Discount Amount");
                            InvDiscAmt := "Sales Invoice Header"."Invoice Discount Amount";
                            LineTotAmt1 += LineTotAmt;
                            //TotalAmount := ABS(LineTotAmt1 - InvDiscAmt) + TotalCGST + TotalSGST + TotalIGST + GLquantity + ChargesTotal + TCSAmt;
                            TotalAmount += ABS("Sales Invoice Line"."Line Amount" - "Sales Invoice Line"."Inv. Discount Amount") + CGST + SGST + IGST + GLquantity + TCSAmt;
                            GrandTotal += SGST + CGST + IGST;


                            //repCheck.InitTextVariable;
                            //repCheck.FormatNoText(AmountinWords, ROUND(TotalAmount), '');
                            //<<PCPL/MIG/NSW New COde ad for amount in words in BC18
                            AmtInWords.InitTextVariable();
                            AmtInWords.FormatNoText(AmountinWords, Round(TotalAmount), '');
                            //Message(Format(AmountinWords[1]));
                            //>>PCPL/MIG/NSW

                            // repCheck1.InitTextVariable;
                            //repCheck1.FormatNoText(AmountinWords1, ROUND(GrandTotal), '');

                            //<<PCPL/MIG/NSW New COde ad for amount in words in BC18
                            AmtInWords1.InitTextVariable();
                            AmtInWords1.FormatNoText(AmountinWords1, Round(GrandTotal), '');
                            //>>PCPL/MIG/NSW

                            //<<PCPL/MIG/NSW New code add for Tcs Amt Get
                            if SalesInvLine.Get("Sales Invoice Line"."Document No.", "Sales Invoice Line"."Line No.") then
                                TaxRecordID := SalesInvLine.RecordId();

                            GetTcsAmtLineWise(TaxRecordID, ComponentJobject);
                            GetGSTBaseAmtLinewise(TaxRecordID, ComponentJobject);

                            //Message(Format(TCSAmtLinewise));
                            //>>PCPL/MIG/NSW
                        end;

                        trigger OnPreDataItem();
                        begin

                            SlNo := 0;
                            LineTotAmt1 := 0;
                            TotalCGST := 0;
                            TotalSGST := 0;
                            TotalIGST := 0;
                            TotalAmount := 0;
                        end;
                    }
                }

                trigger OnAfterGetRecord();
                begin
                    IF Number = 1 THEN BEGIN
                        COPYTEXT := TEXT001;
                        OutPutNo += 1;
                    END

                    ELSE
                        IF Number = 2 THEN BEGIN
                            COPYTEXT := TEXT002;
                            OutPutNo += 1;
                        END

                        ELSE
                            IF Number = 3 THEN BEGIN
                                COPYTEXT := TEXT003;
                                OutPutNo += 1;
                            END;

                    /*ELSE IF Number = 4 THEN BEGIN
                       COPYTEXT := TEXT004;
                       OutPutNo += 1;
                    END;*/

                    CurrReport.PAGENO := 1;
                    GrandTotal := 0;

                    ChargesTotal := 0;
                    CLEAR(GLquantity);
                    CLEAR(TotalValue);

                end;

                trigger OnPreDataItem();
                begin
                    IF NoOfCopies <> 0 THEN
                        NoOfLoops := NoOfCopies
                    ELSE
                        NoOfLoops := 2;
                    //MESSAGE('%1',NoOfLoops);                          // ABS(NoOfCopies) + 1;
                    IF NoOfLoops <= 1 THEN
                        NoOfLoops := 1;
                    COPYTEXT := '';
                    SETRANGE(Number, 1, NoOfLoops);
                    OutPutNo := 1;
                    TotalAmount := 0;
                end;
            }

            trigger OnAfterGetRecord();
            begin
                // FormatAddr.SalesHeaderShipTo(CustAddr,"Sales Header");
                SlNo := 0;
                TotalSales := 0;
                TotalInKGAmt := 0;


                //"Sales Invoice Line"."Document No."


                "Sales Invoice Header".CALCFIELDS("E-Invoice QR");//CITS_RS 060221

                CLEAR(EINVDETILS);
                IF "Sales Invoice Header"."Nature of Supply" = "Sales Invoice Header"."Nature of Supply"::B2B THEN BEGIN
                    EINVDETILS.RESET;
                    EINVDETILS.SETRANGE("Document No.", "Sales Invoice Header"."No.");
                    IF EINVDETILS.FINDFIRST THEN BEGIN
                        IF EINVDETILS."E-Invoice IRN No." <> '' THEN begin
                            IRNNo := EINVDETILS."E-Invoice IRN No.";
                            // Message(IRNNo);
                            IF EINVDETILS.CALCFIELDS("E-Invoice QR Code") THEN;
                        end;
                    END;
                END;
                EWAYDetails.Reset();
                EWAYDetails.SetRange("Document No.", "Sales Invoice Header"."No.");
                IF EWAYDetails.FindFirst() then;



                CLEAR(PTDesc);

                CIN_N0 := CompanyInfo."CIN No.";
                PAN_No1 := CompanyInfo."P.A.N. No.";

                Reclocation.RESET;
                IF Reclocation.GET("Sales Invoice Header"."Location Code") THEN BEGIN
                    LocName := Reclocation.Name;
                    LocAddr1 := Reclocation.Address;
                    LocAddr2 := Reclocation."Address 2";
                    LocCity := Reclocation.City;
                    LocCountry := Reclocation.County;
                    LocEmail := Reclocation."E-Mail";
                    LocGSTNo := Reclocation."GST Registration No.";
                    // PAN_No1 := Reclocation."P.A.N No";
                    StateCode := Reclocation."State Code";
                    LocFssaiNo := Reclocation."FSSAI No";
                    LocPhone := Reclocation."Phone No.";
                    LocPinCode := Reclocation."Post Code";
                END;

                RecState.RESET;
                IF RecState.GET(StateCode) THEN BEGIN
                    StateName := RecState.Description;
                    StateCodeTIN := '';//RecState."State Code for TIN";
                END;
                RecCust1.RESET;
                //IF RecCust1.GET("Sales Invoice Header"."Sell-to Customer No.") THEN BEGIN
                IF RecCust1.GET("Sales Invoice Header"."Bill-to Customer No.") THEN BEGIN
                    CustStatename := RecCust1."State Code";
                    custname := RecCust1.Name;
                    custaddr := RecCust1.Address;
                    custaddr1 := RecCust1."Address 2";
                    custaddr2 := RecCust1."Address 3";
                    custaddr3 := RecCust1."Address 4";
                    custcity := RecCust1.City;
                    custcountry := RecCust1.County;
                    custphone := RecCust1."Phone No.";
                    custemail := RecCust1."E-Mail";
                    custfssaino := RecCust1."FSSAI License No";
                    custgstno := RecCust1."GST Registration No.";
                    custpancard := RecCust1."P.A.N. No.";
                    custpersonname := RecCust1.Contact;
                    UINNo := RecCust1."UIN Number";
                    custpincode := RecCust1."Post Code";
                END;
                //CCIT-SG-16042018+

                IF ("Sales Invoice Header"."Ship-to Code" <> '') THEN BEGIN
                    RecShipToAddr.RESET;
                    IF RecShipToAddr.GET("Sales Invoice Header"."Sell-to Customer No.", "Sales Invoice Header"."Ship-to Code") THEN BEGIN
                        ShipStatename := RecShipToAddr.State;
                        Shipcustname := RecShipToAddr.Name;
                        Shipcustaddr1 := RecShipToAddr.Address;
                        Shipcustaddr2 := RecShipToAddr."Address 2";
                        Shipcustcity := RecShipToAddr.City;
                        Shipcustcountry := RecShipToAddr.County;
                        Shipcustphone := RecShipToAddr."Phone No.";
                        Shipcustemail := RecShipToAddr."E-Mail";
                        Shipcustgstno := RecShipToAddr."GST Registration No.";
                        ShipcustPostCode := RecShipToAddr."Post Code";
                        Shipcustpersonname := RecShipToAddr.Contact;
                        //custpincode := RecCust1.
                    END;
                END else begin

                    IF Cust.GET("Sell-to Customer No.") THEN BEGIN
                        Shipcustname := "Sales Invoice Header"."Ship-to Name";//Cust.Name;
                                                                              // Message('%1', Shipcustname);
                        Shipcustaddr1 := "Sales Invoice Header"."Ship-to Address";//Cust.Address;
                        Shipcustaddr2 := "Sales Invoice Header"."Ship-to Address 2";//Cust."Address 2";
                        Shipcustcity := "Sales Invoice Header"."Ship-to City";//Cust.City;
                        Shipcustphone := '';//'PH: ' + Cust."Phone No.";
                        ShipcustPostCode := "Ship-to Post Code";
                        IF "Sales Invoice Header"."GST Ship-to State Code" <> '' THEN
                            ShipStatename := "GST Ship-to State Code"
                        ELSE
                            ShipStatename := Cust."State Code";
                        Shipcustgstno := Cust."GST Registration No.";
                        /*
                        IF recstateship.GET(ShipToState) THEN BEGIN
                            shipststcode := recstateship."State Code (GST Reg. No.)";
                            shipdisc := recstateship.Description;
                        END;
                        */
                    END;
                end;

                //CCIT-SG-16042018-

                RecState1.RESET;
                IF RecState1.GET(CustStatename) THEN
                    CustStatecode := RecState1."State Code (GST Reg. No.)";

                RecState1.RESET;
                IF RecState1.GET(ShipStatename) THEN
                    ShipStateCode := RecState1."State Code (GST Reg. No.)";


                RecPT.RESET;
                IF RecPT.GET("Sales Invoice Header"."Payment Terms Code") THEN
                    PTDesc := RecPT.Description;
                SIL.RESET();
                SIL.SETRANGE(SIL."Document No.", "Sales Invoice Header"."No.");
                SIL.SETFILTER("No.", '<>%1', '');
                IF SIL.FIND('-') THEN
                    REPEAT
                        TCSAmt := TCSAmt + 0;//SIL."TDS/TCS Amount";

                    UNTIL SIL.NEXT = 0;
                //  MESSAGE('%1',TCSAmt);
                //repCheck1.InitTextVariable;
                //repCheck1.FormatNoText(AmountinWords1,ROUND(TotalGSTAmountinWords,1),'');
            end;

            trigger OnPreDataItem();
            begin
                // FormatAddr.SalesHeaderShipTo(CustAddr,"Sales Header");
                //GrandTotal :=0;
                //TotalAmount := 0;
            end;
        }
    }

    requestpage
    {

        layout
        {
            area(content)
            {
                group(Functions)
                {
                    field("No Of Copies"; NoOfCopies)
                    {
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

    trigger OnInitReport();
    begin
        CompanyInfo.GET;
        CompanyInfo.CALCFIELDS(CompanyInfo.Picture);
        CompanyInfo.CalcFields(CompanyInfo."UPI QR Code");
        //FormatAddr.Company(CompanyAddr,CompanyInfo);
    end;

    var
        IRNNo: Code[100];
        EINVDETILS: Record 50007;
        EWAYDetails: Record "E-Way Bill Detail";
        TEXT001: Label 'Original';
        TEXT002: Label 'Duplicate';
        TEXT003: Label 'Triplicate';
        TEXT004: Label 'Quadraplicate';
        PageCaption: Label 'Page %1 of %2';
        TEXT005: Label '"“SUPPLY MEANT FOR EXPORT SUPPLY TO SEZ UNIT OR SEZ DEVELOPER FOR AUTHORISED OPERATIONS UNDER BOND OR LETTER OF UNDERTAKING WITHOUT PAYMENT OF INTEGRATED TAX” "';
        TotalValue: Decimal;
        GLquantity: Decimal;
        CompanyInfo: Record 79;
        FormatAddr: Codeunit 365;
        CompanyAddr: array[8] of Text;
        NoOfCopies: Integer;
        NoOfLoops: Integer;
        OutPutNo: Integer;
        COPYTEXT: Text;
        NoOfRows: Integer;
        NoOfRecords: Integer;
        recCust: Record 18;
        repCheck: Report Check;
        AmountinWords: array[5] of Text[250];
        TotalAmount: Decimal;
        recSalesLine: Record 37;
        TransferShipLine: Record 5745;
        SlNo: Integer;
        RecSalesInvLine: Record 113;
        Reclocation: Record 14;
        RecGSTSetup: Record "GST Setup";
        CGST: Decimal;
        SGST: Decimal;
        IGST: Decimal;
        Rate: Decimal;
        Rate1: Decimal;
        GrandTotal: Decimal;
        LocName: Text[100];
        LocAddr1: Text[200];
        LocAddr2: Text[200];
        LocCity: Text[30];
        LocPhone: Text[30];
        LocEmail: Text[100];
        LocCountry: Text[10];
        LocPinCode: Code[20];
        LocGSTNo: Code[15];
        RecCust1: Record 18;
        CustStatecode: Code[10];
        CustStatename: Text[20];
        RecState1: Record state;
        TotalCGST: Decimal;
        TotalSGST: Decimal;
        TotalIGST: Decimal;
        custname: Text[100];
        custaddr: Text[200];
        custaddr1: Text[200];
        custaddr2: Text[200];
        custaddr3: Text[200];
        custcity: Text[30];
        custcountry: Text[30];
        custphone: Code[30];
        custpincode: Code[20];
        custgstno: Code[15];
        custfssaino: Code[20];
        custemail: Text[100];
        custpersonname: Text[100];
        custpancard: Code[20];
        repCheck1: Report Check;
        AmountinWords1: array[5] of Text[250];
        QtyPCS: Decimal;
        QtyKG: Decimal;
        RecILE: Record 32;
        Batch: Code[20];
        MFGDate: Date;
        EXPDate: Date;
        RecPT: Record 3;
        PTDesc: Text[50];
        RecItem: Record 27;
        Descp: Text[50];
        PAN_No1: Code[15];
        StateCode: Code[10];
        RecState: Record State;
        StateName: Text[50];
        StateCodeTIN: Code[2];
        CIN_N0: Code[25];
        SalesInvoiceLine: Record 113;
        TotalSales: Decimal;
        TotalGSTAmountinWords: Decimal;
        TotalAmountinWords: Decimal;
        RecItem2: Record 27;
        RecUOM1: Record 5404;
        RateInPCS: Decimal;
        TotalInPCS: Decimal;
        TotalInKG: Decimal;
        TotalInKGAmt: Decimal;
        StorageTemp: Code[20];
        LocFssaiNo: Code[20];
        EANCode: Code[20];
        RecSIH: Record 112;
        RecSILC: Record 113;
        SalesInvLine_DiscountAmt: Decimal;
        RecILE1: Record 32;
        TotalInKG1: Decimal;
        SalesInvLine_DiscountAmt1: Decimal;
        LineDiscAmt: Decimal;
        LineTotAmt: Decimal;
        LineTotAmt1: Decimal;
        BrandName: Code[20];
        InvDiscAmt: Decimal;
        Shipcustname: Text[100];
        Shipcustaddr: Text[200];
        Shipcustaddr1: Text[200];
        Shipcustaddr2: Text[200];
        Shipcustaddr3: Text[200];
        Shipcustcity: Text[30];
        Shipcustcountry: Text[30];
        Shipcustphone: Code[30];
        Shipcustpincode: Code[20];
        Shcustgstnoip: Code[15];
        Shipcustfssaino: Code[20];
        Shipcustemail: Text[100];
        Shipcustpersonname: Text[100];
        ShipcustPostCode: Code[20];
        Shipcustgstno: Code[15];
        ShipStatename: Code[30];
        RecShipToAddr: Record 222;
        ShipStateCode: Code[20];
        MRP_Price: Decimal;
        ChargesTotal: Decimal;
        UINNo: Code[20];
        CustPostCode: Code[20];
        ConvPcsQty: Text[50];
        TtlConvPcsQty: Decimal;
        TCSAmt: Decimal;
        SIL: Record 113;
        GLE: Record "Detailed GST Ledger Entry";
        CGSTPer: Decimal;
        SGSTPer: Decimal;
        IGSTPer: Decimal;
        AmtInWords: Codeunit 50000;

        AmtInWords1: Codeunit 50000;
        SalesInvLine: Record 113;
        TaxRecordID: RecordId;
        TAXTRAVALUE: Record 20261;
        ColumnName: Text[250];
        ColumnValue: Text[2000];
        AmountTax: Decimal;
        ScriptDatatypeMgmt: Codeunit "Script Data Type Mgmt.";
        ComponentJobject: JsonObject;
        TCSAmtLinewise: Decimal;
        Cust: Record 18;
        ComInfo: Record 79;
        TCSPer: Decimal;

    //EINVDETILS:Record 50007;



    local procedure GetTaxRecIDForSalesDocument(TableID: Integer; DocumentTypeFilter: Integer; DocumentNoFilter: Text; LineNoFilter: Integer; var TaxRecordID: RecordId)
    var
        SalesLine: Record "Sales Line";
        SalesInvLine: Record "Sales Invoice Line";
        SalesCrMemoLine: Record "Sales Cr.Memo Line";
    begin
        case TableID of
            database::"Sales Line":
                if SalesLine.Get(DocumentTypeFilter, DocumentNoFilter, LineNoFilter) then
                    TaxRecordID := SalesLine.RecordId();
            database::"Sales Invoice Line":
                if SalesInvLine.Get(DocumentNoFilter, LineNoFilter) then
                    TaxRecordID := SalesInvLine.RecordId();
            database::"Sales Cr.Memo Line":
                if SalesCrMemoLine.Get(DocumentNoFilter, LineNoFilter) then
                    TaxRecordID := SalesCrMemoLine.RecordId();
        end;
    end;

    local procedure GetTcsAmtLineWise(TaxRecordID: RecordId; var JObject: JsonObject)
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
        if TaxTransactionValue.FindFirst() then begin
            Clear(ComponentJObject);
            //ComponentJObject.Add('Component', TaxTransactionValue.GetAttributeColumName());
            //ComponentJObject.Add('Percent', ScriptDatatypeMgmt.ConvertXmlToLocalFormat(format(TaxTransactionValue.Percent, 0, 9), "Symbol Data Type"::NUMBER));
            ComponentAmt := TaxTypeObjHelper.GetComponentAmountFrmTransValue(TaxTransactionValue);
            //ComponentJObject.Add('Amount', ScriptDatatypeMgmt.ConvertXmlToLocalFormat(format(ComponentAmt, 0, 9), "Symbol Data Type"::NUMBER));
            //JArray.Add(ComponentJObject);
        end;
        TCSAMTLinewise += ComponentAmt;
        TCSPer := TaxTransactionValue.Percent;
    end;

    local procedure GetGSTBaseAmtLinewise(TaxRecordID: RecordId; var JObject: JsonObject)
    var
        TaxTransactionValue: Record "Tax Transaction Value";
        TaxTypeObjHelper: Codeunit "Tax Type Object Helper";
        ComponentAmt: Decimal;
        JArray: JsonArray;
        ComponentJObject: JsonObject;
        GSTBaseAmtLineWise: Decimal;
    begin
        if not GuiAllowed then
            exit;

        TaxTransactionValue.SetFilter("Tax Record ID", '%1', TaxRecordID);
        TaxTransactionValue.SetFilter("Value Type", '%1', TaxTransactionValue."Value Type"::Component);
        TaxTransactionValue.SetRange("Visible on Interface", true);
        TaxTransactionValue.SetRange("Tax Type", 'GST');
        TaxTransactionValue.SetRange("Value ID", 10);
        if TaxTransactionValue.FindFirst() then begin
            //IF TaxTransactionValue.FindSet() then
            //  repeat
            Clear(ComponentJObject);
            ComponentJObject.Add('Component', TaxTransactionValue.GetAttributeColumName());
            ComponentJObject.Add('Percent', ScriptDatatypeMgmt.ConvertXmlToLocalFormat(format(TaxTransactionValue.Percent, 0, 9), "Symbol Data Type"::NUMBER));
            ComponentAmt := TaxTypeObjHelper.GetComponentAmountFrmTransValue(TaxTransactionValue);
            ComponentJObject.Add('Amount', ScriptDatatypeMgmt.ConvertXmlToLocalFormat(format(ComponentAmt, 0, 9), "Symbol Data Type"::NUMBER));
            JArray.Add(ComponentJObject);

        end;
        //until TaxTransactionValue.next = 0;
        GSTBaseAmtLineWise := ComponentAmt;
        //Message(Format(GSTBaseAmtLineWise));
    end;







}

