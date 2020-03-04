import 'package:anad_magicar/repository/center_repository.dart';
import 'package:anad_magicar/ui/screen/payment/current_plan_form.dart';
import 'package:flutter/material.dart';

class InvoiceForm extends StatefulWidget {
  InvoiceForm({Key key}) : super(key: key);

  @override
  _InvoiceFormState createState() {
    return _InvoiceFormState();
  }
}

class _InvoiceFormState extends State<InvoiceForm> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return new CurrentPlanForm(user: centerRepository.getUserInfo(), currentInvoice: null);
  }
}
