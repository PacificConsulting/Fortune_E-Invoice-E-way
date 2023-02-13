dotnet
{
    assembly(PCPL.eInvoice.Integration)
    {
        type(PCPL.eInvoice.Integration.TokenController; EInvTokenController)
        {

        }
        type(PCPL.eInvoice.Integration.eInvoiceController; EInvController)
        {

        }
    }
    assembly(PCPL.eWaybill.Integration)
    {
        type(PCPL.eWaybill.Integration.eWaybillController; Ewaybillcontroller)
        {

        }
    }
    assembly(SetDefaultPrinter)
    {
        type(SetDefaultPrinter.Printer; DefaultPrinterNew)
        {

        }

    }


}